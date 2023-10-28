// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import { FiatTokenV3 } from "../src/USDC/UsdcV3.sol";
import { IERC20 } from "../src/TradingCenter.sol";

contract UscdV3Test is Test {
    string ETHEREUM_MAINNET_RPC_URL = vm.envString("ETHEREUM_MAINNET_RPC_URL");
    uint256 ethMainnetFork;
    uint256 BLOCK_NUMBER = vm.envUint("BLOCK_NUMBER");

    address constant usdcOwner = 0xFcb19e6a322b27c06842A71e8c725399f049AE3a;
    address constant usdcProxyContractAddress = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address whitelister = makeAddr("whitelister");
    address whitelistUser1 = makeAddr("whitelist_user1");
    address whitelistUser2 = makeAddr("whitelist_user2");
    address normalUser1 = makeAddr("normal_user1");

    FiatTokenV3 usdcV3;
    FiatTokenV3 proxyUsdcV3;

    function setUp() public {
        ethMainnetFork = vm.createFork(ETHEREUM_MAINNET_RPC_URL);
        vm.selectFork(ethMainnetFork);
        vm.rollFork(BLOCK_NUMBER);

        vm.startPrank(usdcOwner);
        usdcV3 = new FiatTokenV3();
        vm.stopPrank();
    }

    function testUpgradeUSDC() public { 
        vm.startPrank(_adminAddress());
        (bool success, ) = address(usdcProxyContractAddress).call(abi.encodeWithSignature("upgradeTo(address)", address(usdcV3)));
        assertEq(success, true);
        vm.stopPrank();

        proxyUsdcV3 = FiatTokenV3(usdcProxyContractAddress);
        proxyUsdcV3.initializeV3(whitelister);
        assertEq(proxyUsdcV3.version(), "3");
        assertEq(proxyUsdcV3.whitelister(), whitelister);
    }

    function testWhitelist() public {
        vm.startPrank(_adminAddress());
        (bool success, ) = address(usdcProxyContractAddress).call(abi.encodeWithSignature("upgradeTo(address)", address(usdcV3)));
        assertEq(success, true);
        vm.stopPrank();

        proxyUsdcV3 = FiatTokenV3(usdcProxyContractAddress);
        proxyUsdcV3.initializeV3(whitelister);

        // Only whitelister can whitelist
        vm.expectRevert();
        proxyUsdcV3.whitelist(whitelistUser1);

        vm.startPrank(whitelister);
        proxyUsdcV3.whitelist(whitelistUser1);
        proxyUsdcV3.whitelist(whitelistUser2);
        vm.stopPrank();

        assertEq(true, proxyUsdcV3.isWhitelisted(whitelistUser1));
        assertEq(true, proxyUsdcV3.isWhitelisted(whitelistUser1));
        assertEq(false, proxyUsdcV3.isWhitelisted(normalUser1));

        // Only whitelister can unWhitelist
        vm.expectRevert();
        proxyUsdcV3.unWhitelist(whitelistUser1);

        vm.startPrank(whitelister);
        proxyUsdcV3.unWhitelist(whitelistUser1);
        vm.stopPrank();

        assertEq(false, proxyUsdcV3.isWhitelisted(whitelistUser1));

        assertEq(block.number, 18454357);
        assertEq(23023608301838452, proxyUsdcV3.totalSupply());
    }

    function testMint() public {
        vm.startPrank(_adminAddress());
        (bool success, ) = address(usdcProxyContractAddress).call(abi.encodeWithSignature("upgradeTo(address)", address(usdcV3)));
        assertEq(success, true);
        vm.stopPrank();

        proxyUsdcV3 = FiatTokenV3(usdcProxyContractAddress);
        proxyUsdcV3.initializeV3(whitelister);

        // Only whitelisted can mint
        vm.expectRevert();
        proxyUsdcV3.mint(100);

        vm.prank(whitelister);
        proxyUsdcV3.whitelist(whitelistUser1);

        uint256 totalSupply = proxyUsdcV3.totalSupply();
        assertEq(0, proxyUsdcV3.balanceOf(whitelistUser1));
        vm.prank(whitelistUser1);
        proxyUsdcV3.mint(100);
        assertEq(100, proxyUsdcV3.balanceOf(whitelistUser1));
        assertEq(totalSupply + 100, proxyUsdcV3.totalSupply());
    }

    function testTransfer() public {
        vm.startPrank(_adminAddress());
        (bool success, ) = address(usdcProxyContractAddress).call(abi.encodeWithSignature("upgradeTo(address)", address(usdcV3)));
        assertEq(success, true);
        vm.stopPrank();

        proxyUsdcV3 = FiatTokenV3(usdcProxyContractAddress);
        proxyUsdcV3.initializeV3(whitelister);

        vm.prank(whitelister);
        proxyUsdcV3.whitelist(whitelistUser1);

        vm.prank(whitelistUser1);
        proxyUsdcV3.mint(100);
        assertEq(100, proxyUsdcV3.balanceOf(whitelistUser1));

        // Only whitelist user can transfer
        vm.expectRevert();
        vm.prank(normalUser1);
        proxyUsdcV3.transfer(whitelistUser2, 50);

        vm.prank(whitelistUser1);
        proxyUsdcV3.transfer(whitelistUser2, 50);
        assertEq(50, proxyUsdcV3.balanceOf(whitelistUser1));
        assertEq(50, proxyUsdcV3.balanceOf(whitelistUser2));
    }

    function testTransferFrom() public {
        vm.startPrank(_adminAddress());
        (bool success, ) = address(usdcProxyContractAddress).call(abi.encodeWithSignature("upgradeTo(address)", address(usdcV3)));
        assertEq(success, true);
        vm.stopPrank();

        proxyUsdcV3 = FiatTokenV3(usdcProxyContractAddress);
        proxyUsdcV3.initializeV3(whitelister);

        vm.startPrank(whitelister);
        proxyUsdcV3.whitelist(whitelistUser1);
        proxyUsdcV3.whitelist(whitelistUser2);
        vm.stopPrank();

        vm.prank(whitelistUser1);
        proxyUsdcV3.mint(100);
        assertEq(100, proxyUsdcV3.balanceOf(whitelistUser1));

        // transferFrom caller must be whitelisted
        vm.expectRevert();
        vm.prank(normalUser1);
        proxyUsdcV3.transferFrom(whitelistUser1, whitelistUser2, 50);

        // transferFrom parameter 1 must be whitelisted
        vm.expectRevert();
        vm.prank(whitelistUser1);
        proxyUsdcV3.transferFrom(normalUser1, whitelistUser2, 50);

        vm.prank(whitelistUser1);
        proxyUsdcV3.approve(whitelistUser2, 50);
        vm.prank(whitelistUser2);
        proxyUsdcV3.transferFrom(whitelistUser1, normalUser1, 50);
        assertEq(50, proxyUsdcV3.balanceOf(whitelistUser1));
        assertEq(50, proxyUsdcV3.balanceOf(normalUser1));
    }

    function _adminAddress() internal pure returns (address value) {
        return 0x807a96288A1A408dBC13DE2b1d087d10356395d2;
    }
}