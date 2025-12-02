// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/ITraitSwapWrapper.sol";
import "./libraries/TraitDefinition.sol";

// Contract: TraitSwapWrapper
// Role: The NFT asset that users own and trade after depositing the original NFT.
// It stores the modifiable trait data.
contract TraitSwapWrapper is ERC721, Ownable, ITraitSwapWrapper {
    using TraitDefinition for TraitDefinition.TraitState;

    address private minter; // Address of the TraitSwapEscrow contract
    mapping(uint256 => TraitDefinition.TraitState) private tokenStates;

    constructor() ERC721("WrappedTraitNFT", "WTN") {}

    // Initializes the minter address (must be the Escrow contract address)
    function initialize(address minterAddress) external override onlyOwner {
        require(minter == address(0), "Already initialized");
        minter = minterAddress;
    }

    modifier onlyMinter() {
        require(msg.sender == minter, "Not the minter");
        _;
    }

    // --- Minter-Only Functions ---

    function mint(address to, uint256 tokenId, TraitDefinition.TraitState memory state) external override onlyMinter {
        _mint(to, tokenId);
        tokenStates[tokenId] = state;
    }

    function burn(uint256 tokenId) external override onlyMinter {
        _burn(tokenId);
        delete tokenStates[tokenId];
    }

    // This is the function called by the Escrow to change a single trait value
    function updateTrait(uint256 tokenId, string memory key, string memory newValue) external override onlyMinter {
        int256 index = tokenStates[tokenId].traits.findTraitIndex(key);
        require(index != -1, "Trait key not found");
        
        tokenStates[tokenId].traits[uint256(index)].value = newValue;
    }

    // --- View Functions ---

    function getTraitState(uint256 tokenId) external view override returns (TraitDefinition.TraitState memory) {
        return tokenStates[tokenId];
    }

    // Overriding base tokenURI to expose custom metadata logic (not fully implemented here)
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        // In a real application, this would construct a JSON URI based on tokenStates[tokenId]
        return super.tokenURI(tokenId);
    }
}
