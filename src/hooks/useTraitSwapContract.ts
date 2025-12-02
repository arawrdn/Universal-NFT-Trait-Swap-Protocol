// Custom hook to simplify contract interaction using AppKit/Ethers/Wagmi
import { useWriteContract, useReadContract, useWaitForTransactionReceipt } from 'wagmi';
import { ESCROW_ADDRESS, ESCROW_ABI } from '../utils/contractAddresses'; 

// Utility function to call depositAndOffer from the TraitSwapEscrow contract
export const useDepositOffer = () => {
  const { writeContract, data: hash, isPending } = useWriteContract();

  const depositAndOffer = (
    originalNFTAddress: string,
    originalTokenId: bigint,
    initialTraits: any[], 
    targetOriginalId: bigint,
    targetNFTAddress: string,
    traitToSwapKey: string
  ) => {
    writeContract({
      address: ESCROW_ADDRESS,
      abi: ESCROW_ABI,
      functionName: 'depositAndOffer',
      args: [
        originalNFTAddress,
        originalTokenId,
        initialTraits,
        targetOriginalId,
        targetNFTAddress,
        traitToSwapKey,
      ],
    });
  };

  const { isLoading: isConfirming, isSuccess: isConfirmed } = useWaitForTransactionReceipt({
    hash,
  });

  return { depositAndOffer, hash, isPending, isConfirming, isConfirmed };
};
