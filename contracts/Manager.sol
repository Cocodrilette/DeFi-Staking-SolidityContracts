// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./FireToken.sol";
import "./CarbonToken.sol";

contract Manager {
    // State variables
    string public constant name = "Elements Manager";
    address public owner;

    FireToken public fireToken;
    CarbonToken public carbonToken;

    address[] public stakers;
    mapping(address => uint256) public stakingBalance;
    mapping(address => bool) public hasStaked;
    mapping(address => bool) public isStaking;

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function stakeTokens(uint256 _amount) public {
        address sender = msg.sender;
        /*
         * Amount > 0 already checked in FireToken contract
         */
        fireToken.transferFrom(msg.sender, address(this), _amount);
        stakingBalance[sender] += _amount;

        if (!hasStaked[sender]) {
            stakers.push(sender);
            hasStaked[sender] = true;
        }

        if (!isStaking[sender]) isStaking[msg.sender] = true;
    }

    function unstakeTokens() public {
        uint256 currBalance = stakingBalance[msg.sender];
        // This line avoid reentracy atacks
        stakingBalance[msg.sender] -= currBalance;
        /*
         * Check if the sender actually have staked tokens
         */
        require(currBalance > 0, "You have not tokens staked.");

        fireToken.transfer(msg.sender, currBalance);

        isStaking[msg.sender] = false;
    }

    function issueTokens() public onlyOwner {
        for (uint256 i = 0; i < stakers.length; i++) {
            address recipient = stakers[i];
            uint256 currBalance = stakingBalance[recipient];
            stakingBalance[recipient] -= currBalance;

            if (currBalance > 0) {
                carbonToken.transfer(recipient, currBalance);
            }
        }
    }

    function setStakeTokenContract(FireToken _fireToken) public onlyOwner {
        fireToken = _fireToken;
    }

    function setRewardTokenContract(CarbonToken _carbonToken) public onlyOwner {
        carbonToken = _carbonToken;
    }
}
