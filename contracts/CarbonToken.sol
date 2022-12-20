// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/*
 * This contract is used to educational purpose only and is not audited or tested.
 * For a production enviroment use the Open Zeppelin ERC-20 implementation.
 */

contract CarbonToken {
    // State variables
    string public constant NAME = "Carbon";
    string public constant SYMBOL = "CRBN";

    uint8 public constant DECIMALS = 18;
    uint256 public constant TOTAL_SUPPLY = 1000000 * 10**DECIMALS;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    address public owner;

    // Events
    event Transfer(address indexed _from, address indexed _to, uint256 _amount);

    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _amount
    );

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

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
        uint256 fixedAmount = fixAmount(_amount);
        /// You need to send almost 1 token
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

    function fixAmount(uint256 _amount) private pure returns(uint256) {
        return _amount * 10**DECIMALS;
    }
}
