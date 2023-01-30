// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "uniswap-v3-core/Interfaces/IUniswapV3Pool.sol";
import "../src/TokenHelper/TokenHelper.sol";

contract Helper is Test {

  uint256 public defaultBlock = 16_485_101;
  uint256 public mainnetFork;

  address public WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
  address public USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;

  Token public WETH_Token = Token(TokenStandard.ERC20, WETH, 0x0, 0);
  Token public USDC_Token = Token(TokenStandard.ERC20, USDC, 0x0, 0);

  IUniswapV3Pool USDC_ETH_FEE500_UNISWAP_V3_POOL = IUniswapV3Pool(0x88e6A0c2dDD26FEEb64F039a2c41296FcB3f5640);
  

  function setupFork () public {
    setupFork(defaultBlock);
  }

  function setupFork (uint blockNumber) public {
    mainnetFork = vm.createFork(vm.envString("MAINNET_RPC_URL"), blockNumber);
    vm.selectFork(mainnetFork);
  }

}
