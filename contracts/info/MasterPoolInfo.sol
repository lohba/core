/*
PoolInfo

https://github.com/gysr-io/core

SPDX-License-Identifier: MIT
*/

pragma solidity 0.8.4;

import "../interfaces/IPool.sol";
import "../interfaces/IStakingModule.sol";
import "../interfaces/IRewardModule.sol";
import "./ERC20StakingModuleInfo.sol";
import "./ERC721StakingModuleInfo.sol";
import "./PoolInfo.sol";
import "./ERC20FriendlyRewardModuleInfo.sol";
import "./ERC20CompetitiveRewardModuleInfo.sol";

/**
 * @title Pool info library
 *
 * @notice this implements the Pool info library, which provides read-only
 * convenience functions to query additional information and metadata
 * about the core Pool contract.
 */

contract MasterPoolInfo {
    
    mapping(address => address) public moduleToLibrary;
    address ERC20StakingModule;
    address ERC721StakingModule;
    address ERC20CompetitiveRewardModule;
    address ERC20FriendlyRewardModule;
    address ERC721RewardModule;

    constructor(address ERC20StakingModuleAddress, address ERC721StakingModuleAddress, address ERC20FriendlySRewardModuleAddress, address ERC20FCompetitiveSRewardModule) {
        address ERC20StakingModule = ERC20StakingModuleAddress;
        address ERC721StakingModule = ERC721StakingModuleAddress;
        address ERC20FriendlyRewardModule = ERC20FriendlySRewardModuleAddress;
        address ERC20CompetitiveRewardModule = ERC20FCompetitiveSRewardModule;
    }

    function getReward(address wallet, address poolAddress) view external returns(uint256) {
        address stakingModule;
        address rewardModule;
        address stakingModuleType;
        address rewardModuleType;
        uint256 shares;
        uint256 reward;
        uint256 timeMultiplier;
        uint256 gysrMultiplier;
        uint256 gysr;

        (stakingModule, rewardModule, stakingModuleType, rewardModuleType) = PoolInfo.modules(poolAddress);
        (reward, timeMultiplier, gysrMultiplier) = ERC20FriendlyRewardModuleInfo.rewards(rewardModule, wallet, shares);
        (reward, timeMultiplier, gysrMultiplier) = ERC20CompetitiveRewardModuleInfo.rewards(rewardModule, wallet, shares, gysr);
        
        if(stakingModuleType == ERC20StakingModule) {
            shares = ERC20StakingModuleInfo.shares(stakingModule, wallet, 0);
        } else if (stakingModuleType == ERC721StakingModule) {
            shares = ERC721StakingModuleInfo.shares(stakingModule, wallet, 0);
        } else {
            revert("unknown staking module type");
        }
        if(rewardModuleType == ERC20FriendlyRewardModule) {
            (reward, timeMultiplier, gysrMultiplier) = ERC20FriendlyRewardModuleInfo.rewards(rewardModule, wallet, shares);
        } else if (rewardModuleType == ERC20CompetitiveRewardModule) {
            (reward, timeMultiplier, gysrMultiplier) = ERC20CompetitiveRewardModuleInfo.rewards(rewardModule, wallet, shares, gysr);
        } else {
            revert("unknown reward moduel type");
        }
        return reward;
    }

}
