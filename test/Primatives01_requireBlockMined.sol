// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Primatives/Primatives01.sol";
import "./Helper.sol";

contract Primatives01_requireBlockMined is Primatives01, Test, Helper  {

  function setUp () public {
    setupFork();
  }

  function testBlockIsNotMined () public {
    // when block is ahead of current block, revert with `BlockNotMined()`
    vm.expectRevert(BlockNotMined.selector);
    requireBlockMined(defaultBlock + 1);
  }

  function testBlockIsMining () public view {
    // when block is equal to current block, don't revert
    requireBlockMined(defaultBlock);
  }

  function testBlockIsMined () public view {
    // when block is behind current block, don't revert
    requireBlockMined(defaultBlock - 1);
  }

}
