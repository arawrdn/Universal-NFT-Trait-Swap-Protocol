// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/ITraitSwapWrapper.sol";
import "./libraries/TraitDefinition.sol";

contract TraitSwapEscrow is Ownable {
    using TraitDefinition for TraitDefinition.TraitState;

    ITraitSwapWrapper public immutable wrapper;

    struct SwapOffer {
        address offerer;
        uint256 offererOriginalId;
        address targetNFTAddress;
        uint256 targetOriginalId; 
        string traitToSwapKey;
        bool isActive;
    }

    mapping(uint256 => SwapOffer) public offersByWrapperId;
    uint256 private nextWrapperId = 1;

    event OfferCreated(uint256 indexed wrapperId, address indexed offerer);
    event SwapExecuted(uint256 indexed wrapperIdA, uint256 indexed wrapperIdB, string traitKey);
    event OfferCanceled(uint256 indexed wrapperId, address indexed offerer);

    constructor(address wrapperAddress) {
        wrapper = ITraitSwapWrapper(wrapperAddress);
    }

    function depositAndOffer(
        address originalNFTAddress,
        uint256 originalTokenId,
        TraitDefinition.Trait[] memory initialTraits,
        address targetNFTAddress,
        uint256 targetOriginalId,
        string memory traitToSwapKey
    ) external {
        // 1. Transfer original NFT to this escrow contract
        IERC721(originalNFTAddress).transferFrom(msg.sender, address(this), originalTokenId);

        TraitDefinition.TraitState memory state = TraitDefinition.TraitState({
            originalNFTAddress: originalNFTAddress,
            originalTokenId: originalTokenId,
            traits: initialTraits
        });

        uint256 newWrapperId = nextWrapperId++;

        // 2. Mint the new Wrapper NFT to the user
        wrapper.mint(msg.sender, newWrapperId, state);

        // 3. Create the offer
        offersByWrapperId[newWrapperId] = SwapOffer({
            offerer: msg.sender,
            offererOriginalId: originalTokenId,
            targetNFTAddress: targetNFTAddress,
            targetOriginalId: targetOriginalId,
            traitToSwapKey: traitToSwapKey,
            isActive: true
        });

        emit OfferCreated(newWrapperId, msg.sender);
    }

    function executeSwap(uint256 offererWrapperId, uint256 targetWrapperId) external {
        SwapOffer storage offer = offersByWrapperId[offererWrapperId];
        require(offer.isActive, "Offer not active");
        require(msg.sender == wrapper.ownerOf(targetWrapperId), "Must own the target wrapper NFT");

        string memory traitKey = offer.traitToSwapKey;

        // 1. Get the current trait values from both Wrappers
        TraitDefinition.TraitState memory stateA = wrapper.getTraitState(offererWrapperId);
        TraitDefinition.TraitState memory stateB = wrapper.getTraitState(targetWrapperId);
        
        int256 indexA = stateA.traits.findTraitIndex(traitKey);
        int256 indexB = stateB.traits.findTraitIndex(traitKey);

        require(indexA != -1 && indexB != -1, "Trait key missing in one or both Wrappers");
        
        string memory traitValueA = stateA.traits[uint256(indexA)].value;
        string memory traitValueB = stateB.traits[uint256(indexB)].value;
        
        // 2. Perform the atomic swap update on the Wrapper NFTs
        wrapper.updateTrait(offererWrapperId, traitKey, traitValueB);
        wrapper.updateTrait(targetWrapperId, traitKey, traitValueA);

        // 3. Update ownership of the Wrappers (optional, often kept by original owner)
        // If ownership needs to swap: wrapper.transferFrom(offer.offerer, msg.sender, offererWrapperId); etc.
        
        // 4. Mark offer as complete
        offer.isActive = false;

        emit SwapExecuted(offererWrapperId, targetWrapperId, traitKey);
    }

    function cancelOffer(uint256 wrapperId) external {
        SwapOffer storage offer = offersByWrapperId[wrapperId];
        require(offer.offerer == msg.sender, "Not the offerer");
        require(offer.isActive, "Offer not active");

        // 1. Burn the Wrapper NFT
        wrapper.burn(wrapperId);

        // 2. Transfer the original NFT back to the user
        IERC721(offer.targetNFTAddress).transferFrom(address(this), msg.sender, offer.offererOriginalId);

        // 3. Delete the offer record
        delete offersByWrapperId[wrapperId];

        emit OfferCanceled(wrapperId, msg.sender);
    }
}
