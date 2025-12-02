// Uses Wagmi or a direct WalletConnect SDK wrapper for connection management.

import { useAccount, useConnect, useDisconnect } from 'wagmi';
import { mainnet, polygon, base } from 'wagmi/chains';
import { createWeb3Modal, defaultWagmiConfig } from '@web3modal/wagmi';

// Your persistent WalletConnect Project ID
const projectId = 'a5f9260bc9bca570190d3b01f477fc45'; 

const metadata = {
  name: 'TraitSwap Protocol',
  description: 'NFT Trait Swapping DApp',
  url: 'https://traitswap.app',
  icons: ['https://avatars.githubusercontent.com/u/37784886']
};

const chains = [mainnet, polygon, base];
const wagmiConfig = defaultWagmiConfig({ chains, projectId, metadata });

// Create modal
createWeb3Modal({ wagmiConfig, projectId, chains });

export const useWalletConnect = () => {
  const { address, isConnected, isConnecting } = useAccount();
  const { connect, connectors } = useConnect();
  const { disconnect } = useDisconnect();

  return {
    address,
    isConnected,
    isConnecting,
    connect,
    disconnect,
    // The Web3Modal component handles the UI connection button/logic
  };
};
