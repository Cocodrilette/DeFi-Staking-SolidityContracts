// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/*
 * This contract is used to educational purpose only and is not audited or tested.
 * For a production enviroment use the Open Zeppelin ERC-20 implementation.
 */

contract FireToken {
    // State variables
    string public constant NAME = "Fire";
    string public constant SYMBOL = "FIRE";

    uint8 public constant DECIMALS = 18;
    uint256 public constant TOTAL_SUPPLY = 1000000 * 10**DECIMALS;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    mapping(address => bool) public alreadyClaim;

    address public owner;

    // Events
    event Transfer(address indexed _from, address indexed _to, uint256 _amount);

    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _amount
    );

    // Functions
    constructor() {
        balanceOf[msg.sender] = TOTAL_SUPPLY;
        owner = msg.sender;
    }

    function approve(address _spender, uint256 _amount)
        public
        returns (bool success)
    {
        allowance[msg.sender][_spender] = fixAmount(_amount);

        emit Approval(msg.sender, _spender, _amount);

        return true;
    }

    function transfer(address _to, uint256 _amount) public returns (bool) {
        /// You need to send almost 1 token
        uint256 fixedAmount = fixAmount(_amount);

        require(fixedAmount > 0, "You must send almost 1 token");
        require(balanceOf[msg.sender] >= fixedAmount, "Insufficient funds.");

        balanceOf[msg.sender] -= fixedAmount;
        balanceOf[_to] += fixedAmount;

        emit Transfer(msg.sender, _to, _amount);

        return true;
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _amount
    ) public returns (bool) {
        uint256 fixedAmount = fixAmount(_amount);

        require(balanceOf[_from] >= fixedAmount, "Insufficient funds.");
        require(
            allowance[_from][msg.sender] >= fixedAmount,
            "Insufficient funds approved."
        );

        balanceOf[_from] -= fixedAmount;
        balanceOf[_to] += fixedAmount;
        allowance[_from][msg.sender] -= fixedAmount;

        emit Transfer(_from, _to, _amount);

        return true;
    }

    // Send 1000 tokens to the sender only once
    function claimTokens() public {
        address sender = msg.sender;

        if (!alreadyClaim[sender]) {
            alreadyClaim[sender] = true;

            balanceOf[sender] = fixAmount(1000);
            return;
        }

        revert();
    }

    function fixAmount(uint256 _amount) private pure returns (uint256) {
        return _amount * 10**DECIMALS;
    }
}
