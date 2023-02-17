// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "uniswap-v3-core/Interfaces/IUniswapV3Pool.sol";
import "openzeppelin/utils/Strings.sol";
import "../src/Interfaces/ITwapAdapter.sol";
import "../src/TokenHelper/TokenHelper.sol";
import "../src/Primitives/Primitives01.sol";
import "./Mocks/MockPriceOracle.sol";
import "./Mocks/MockPrimitiveInternals.sol";
import "./Mocks/MockTokenHelperInternals.sol";
import "./Utils/Filler.sol";

contract Helper is Test {

  ITwapAdapter public twapAdapter;
  ITwapAdapter public twapInverseAdapter;
  Primitives01 public primitives;
  MockPriceOracle public mockPriceOracle;
  MockPrimitiveInternals public primitiveInternals;
  MockTokenHelperInternals public tokenHelper;
  Filler public filler;

  // TWAP prices are in fixed point X96 (2**96)

  // TWAP price for interval 1000s - 0s: ~0.000645 USDC/ETH
  uint256 public MAGIC_TWAP_PRICE_USDC_ETH_1000_0 = 51128994256875305254096266510654458404;
  // inverse ~1549.574 ETH/USDC
  uint256 public MAGIC_TWAP_PRICE_ETH_USDC_1000_0 = 122769904368744749859;
  
  
  // TWAP price for interval 2000s - 1000s: ~0.000646 USDC/ETH
  uint256 public MAGIC_TWAP_PRICE_USDC_ETH_2000_1000 = 51185264279942680916728141158213785257;
  // inverse ~1547.871 ETH/USDC
  uint256 public MAGIC_TWAP_PRICE_ETH_USDC_2000_1000 = 122634938466976106938;

  uint256 public BLOCK_JAN_25_2023 = 16_485_101;
  uint256 public BLOCK_FEB_12_2023 = 16_614_361;

  address public WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
  address public USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
  address public DOODLES = 0x8a90CAb2b38dba80c64b7734e58Ee1dB38B8992e;
  address public THE_MEMES = 0x33FD426905F149f8376e227d0C9D3340AaD17aF1;

  Token public WETH_Token = Token(TokenStandard.ERC20, WETH, 0x0, 0);
  Token public USDC_Token = Token(TokenStandard.ERC20, USDC, 0x0, 0);
  Token public DOODLES_Token = Token(TokenStandard.ERC721, DOODLES, 0x0, 0);
  Token public THE_MEMES_Token = Token(TokenStandard.ERC1155, THE_MEMES, 0x0, 0);

  IERC20 public WETH_ERC20 = IERC20(WETH);
  IERC20 public USDC_ERC20 = IERC20(USDC);
  IERC721 public DOODLES_ERC721 = IERC721(DOODLES);
  IERC1155 public THE_MEMES_ERC1155 = IERC1155(THE_MEMES);

  IUniswapV3Pool USDC_ETH_FEE500_UNISWAP_V3_POOL = IUniswapV3Pool(0x88e6A0c2dDD26FEEb64F039a2c41296FcB3f5640);

  address public USDC_WHALE = 0x99C9fc46f92E8a1c0deC1b1747d010903E884bE1;
  address public ETH_WHALE = 0x00000000219ab540356cBB839Cbe05303d7705Fa;
  address public WETH_WHALE = 0xBA12222222228d8Ba445958a75a0704d566BF2C8;

  // Doodle Id's owned by 0x3111114529b97dAeF7A03FD10054dBBA2a085826 in BLOCK_FEB_12_2023:
  //    9878, 9785, 9592, 9107, 8064, 8038, 7754, 5268, 4631, 3989, 3643, 3206, 3110, 3104,
  //    2847, 2829, 2756, 2701, 2388, 2284, 1170, 476, 368
  address public DOODLE_WHALE = 0x3111114529b97dAeF7A03FD10054dBBA2a085826;

  // Merkle root for Id's 9878, 9785, 9592, 9107, 8064, 8038, 7754
  bytes32 DOODLE_WHALE_MERKLE_ROOT = 0x08f3eb3db4c2471f4f86ffafecd871a4e98a451613c9f437c1e8b7ffd54647cb;

  // memes vault, owns a lot of all the memes
  address public THE_MEMES_WHALE = 0xc6400A5584db71e41B0E5dFbdC769b54B91256CD;

  // owns 2 FIRSTGM (id=8)
  address public THE_MEMES_MINNOW = 0x001442C1a4C7CA5EC68091fc246FF9377e234510;

  // Merkle root for Id's 8, 14, 64
  bytes32 THE_MEMES_MERKLE_ROOT = 0x23dccdb06adb5c64caf600b3476f3036e612ad58436f2a5de84d447c165bae38;

  Token public DOODLES_Token_With_Merkle_Root = Token(TokenStandard.ERC721, DOODLES, DOODLE_WHALE_MERKLE_ROOT, 0);
  Token public DOODLES_Token_476 = Token(TokenStandard.ERC721, DOODLES, 0x0, 476);
  Token public THE_MEMES_FIRSTGM_Token = Token(TokenStandard.ERC1155, THE_MEMES, 0x0, 8);
  Token public THE_MEMES_GMGM_Token = Token(TokenStandard.ERC1155, THE_MEMES, 0x0, 14);
  Token public THE_MEMES_Token_With_Merkle_root = Token(TokenStandard.ERC1155, THE_MEMES, THE_MEMES_MERKLE_ROOT, 0);
  Token public ETH_TOKEN = Token(TokenStandard.ETH, address(0), 0x0, 0);

  address RANDOM_1 = 0xb6F5284E09C7D1E6456A496D839593291D8d7C08;

  address TRADER_1 = 0x7F3b23B48Ad3f38f519Fa743f497F0589729aCE5;

  // [token][id][holder][0] = initialBalance
  // [token][id][holder][1] = finalBalance
  mapping(address => mapping(uint => mapping(address => uint[2]))) private balances;

  // [holder][0] = balance tracking started
  // [holder][1] = balance tracking ended
  mapping(address => bool[2]) private balanceTracking;

  IdsMerkleProof EMPTY_IDS_MERKLE_PROOF = IdsMerkleProof(
    new uint[](0),
    new bytes32[](0),
    new bool[](0)
  );

  function setupAll () public {
    // setup with default fork
    setupAll(BLOCK_JAN_25_2023);
  }

  function setupAll (uint blockNumber) public {
    setupFork(blockNumber);
    setupContracts();
  }

  function setupContracts () public {
    setupTwapAdapter();
    setupTwapInverseAdapter();
    setupTestContracts();
  }

  function setupTwapAdapter () public {
    bytes memory code = vm.getCode('out/TwapAdapter.sol/TwapAdapter.json');
    address addr;
    assembly {
      addr := create(0, add(code, 0x20), mload(code))
      if iszero(addr) { revert (0, 0) }
    }
    twapAdapter = ITwapAdapter(addr);
  }

  function setupTwapInverseAdapter () public {
    bytes memory code = vm.getCode('out/TwapInverseAdapter.sol/TwapInverseAdapter.json');
    address addr;
    assembly {
      addr := create(0, add(code, 0x20), mload(code))
      if iszero(addr) { revert (0, 0) }
    }
    twapInverseAdapter = ITwapAdapter(addr);
  }

  function setupTestContracts () public {
    primitives = new Primitives01();
    mockPriceOracle = new MockPriceOracle();
    primitiveInternals = new MockPrimitiveInternals();
    tokenHelper = new MockTokenHelperInternals();
  }

  function setupFork (uint blockNumber) public {
    uint fork = vm.createFork(vm.envString("MAINNET_RPC_URL"), blockNumber);
    vm.selectFork(fork);
  }

  function startBalances (address holder) public {
    balanceTracking[holder][0] = true;
    balances[WETH][0][holder][0] = WETH_ERC20.balanceOf(holder);
    balances[USDC][0][holder][0] = USDC_ERC20.balanceOf(holder);
  }

  function endBalances (address holder) public {
    if (!balanceTracking[holder][0]) {
      revert("endBalances() called without startBalances()");
    }
    balanceTracking[holder][1] = true;
    balances[WETH][0][holder][1] = WETH_ERC20.balanceOf(holder);
    balances[USDC][0][holder][1] = USDC_ERC20.balanceOf(holder);
  }

  function diffBalance (address token, address holder) public returns (int) {
    return diffBalance(token, 0, holder);
  }

  function diffBalance (address token, uint id, address holder) public returns (int) {
    if (!balanceTracking[holder][0]) {
      revert("diffBalances() called without startBalances()");
    }
    if (!balanceTracking[holder][1]) {
      revert("diffBalances() called without endBalances()");
    }
    uint[2] memory _balances = balances[token][id][holder];
    return int(_balances[1]) - int(_balances[0]);
  }

  // Seeds filler contract with:
  //    ETH:       32_500000000000000000
  //    WETH:      13_500000000000000000
  //    USDC:      128000_000000
  //    DOODLES:   5268, 4631, 3989
  //    THE_MEMES: [8]:5, [14]:7, [55]:13
  function setupFiller () public {
    filler = new Filler();
    uint[] memory doodlesIds = new uint[](3);
    doodlesIds[0] = 5268;
    doodlesIds[1] = 4631;
    doodlesIds[2] = 3989;
    uint[] memory memesIds = new uint[](3);
    memesIds[0] = 8;
    memesIds[1] = 14;
    memesIds[2] = 55;
    uint[] memory memesAmounts = new uint[](3);
    memesAmounts[0] = 5;
    memesAmounts[1] = 7;
    memesAmounts[2] = 13;
    seedAssets(
      address(filler),
      32_500000000000000000,
      13_500000000000000000,
      128_000_000000,
      doodlesIds,
      memesIds,
      memesAmounts
    );
  }

  // Seeds TRADER_1 with:
  //    ETH:       8_000000000000000000
  //    WETH:      2_000000000000000000
  //    USDC:      10_000_000000
  //    DOODLES:   3643, 3206
  //    THE_MEMES: [8]:2, [14]:3
  function setupTrader1 () public {
    uint[] memory doodlesIds = new uint[](2);
    doodlesIds[0] = 3643;
    doodlesIds[1] = 3206;
    uint[] memory memesIds = new uint[](2);
    memesIds[0] = 8;
    memesIds[1] = 14;
    uint[] memory memesAmounts = new uint[](2);
    memesAmounts[0] = 2;
    memesAmounts[1] = 3;
    seedAssets(
      TRADER_1,
      8_000000000000000000,
      2_000000000000000000,
      10_000_000000,
      doodlesIds,
      memesIds,
      memesAmounts
    );
  }

  function seedAssets (
    address holder,
    uint ethAmount,
    uint wethAmount,
    uint usdcAmount,
    uint[] memory doodlesIds,
    uint[] memory memesIds,
    uint[] memory memesAmounts
  ) public {
    if(block.number != BLOCK_FEB_12_2023) {
      revert("seedAssets setup requires fork for BLOCK_FEB_12_2023");
    }

    vm.deal(holder, ethAmount);

    vm.prank(WETH_WHALE);
    WETH_ERC20.transfer(holder, wethAmount);

    vm.prank(USDC_WHALE);
    USDC_ERC20.transfer(holder, usdcAmount);

    for(uint8 i=0; i < doodlesIds.length; i++) {
      vm.prank(DOODLE_WHALE);
      DOODLES_ERC721.transferFrom(DOODLE_WHALE, holder, doodlesIds[i]);
    }

    vm.prank(THE_MEMES_WHALE);
    THE_MEMES_ERC1155.safeBatchTransferFrom(THE_MEMES_WHALE, holder, memesIds, memesAmounts, '');
  }

  function merkleProofForDoodle9107 () public returns (IdsMerkleProof memory idsMerkleProof) {
    uint[] memory ids = new uint[](1);
    ids[0] = 9107;

    bytes32[] memory proof = new bytes32[](2);
    proof[0] = 0xab5623858b421d453a6ea4a4873a731863781529261bcc39f0160f476e1217a5;
    proof[1] = 0x0db851939cf734f5e0f3eafe70ccfbcb5509e5a8ade8c6ace7c1d1d1cfc841a5;

    idsMerkleProof = IdsMerkleProof(ids, proof, new bool[](0));
  }

  function invalidMerkleProof () public returns (IdsMerkleProof memory idsMerkleProof) {
    uint[] memory ids = new uint[](1);
    ids[0] = 1234;

    bytes32[] memory proof = new bytes32[](3);
    proof[0] = 0xb0f1b2dc479b6baed16151fbb6cebd075c54c10d3e48a8e6c67334a3382a9c20;
    proof[1] = 0xab5623858b421d453a6ea4a4873a731863781529261bcc39f0160f476e1217a5;
    proof[2] = 0xc97ce8d1e731b4088a0419629557892a06ca5462a6083a0cf6e92a1d5a720b75;

    idsMerkleProof = IdsMerkleProof(ids, proof, new bool[](0));
  }

  function merkleMultiProofForDoodles_9592_7754_9107 () public returns (IdsMerkleProof memory idsMerkleProof) {
    uint[] memory ids = new uint[](3);
    ids[0] = 9592;
    ids[1] = 7754;
    ids[2] = 9107;

    bytes32[] memory proof = new bytes32[](1);
    proof[0] = 0x0db851939cf734f5e0f3eafe70ccfbcb5509e5a8ade8c6ace7c1d1d1cfc841a5;

    bool[] memory proofFlags = new bool[](3);
    proofFlags[0] = true;
    proofFlags[1] = true;
    proofFlags[2] = false;

    idsMerkleProof = IdsMerkleProof(ids, proof, proofFlags);
  }

  function merkleMultiProofForTheMemes_14_8 () public returns (IdsMerkleProof memory idsMerkleProof) {
    uint[] memory ids = new uint[](2);
    ids[0] = 14;
    ids[1] = 8;
  
    bytes32[] memory proof = new bytes32[](1);
    proof[0] = 0x86b497a4c646080e1b92d6d127798c22334da8d4795695f4a1f0a4855e09600c;

    bool[] memory proofFlags = new bool[](2);
    proofFlags[0] = false;
    proofFlags[1] = true;

    idsMerkleProof = IdsMerkleProof(ids, proof, proofFlags);
  }

}
