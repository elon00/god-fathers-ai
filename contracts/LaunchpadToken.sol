// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title GodFathersAIToken
 * @notice God Fathers AI ($GODFATHER) - Autonomous Paternal Wisdom, Generational Mentorship, Moral Guardianship & Sacred Heritage Protection Protocol
 */
contract GodFathersAIToken {
    string public name = "God Fathers AI";
    string public symbol = "GODFATHER";
    uint8 public constant decimals = 18;
    uint256 public totalSupply;
    uint256 public constant INITIAL_PRICE = 0.0001 ether;
    uint256 public constant CURVE_SLOPE = 1e10;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event CurveMint(address indexed backer, uint256 tokenAmount, uint256 ethDonation);
    event HeritageDisbursement(string indexed category, address indexed recipient, uint256 amountWei, bytes32 indexed proofHash);

    function calculateCost(uint256 amount) public view returns (uint256) {
        uint256 currentSupply = totalSupply;
        uint256 baseCost = amount * INITIAL_PRICE;
        uint256 curveFactor = (CURVE_SLOPE * ((currentSupply + amount)**2 - currentSupply**2)) / 2e18;
        return baseCost + curveFactor;
    }

    function mint(uint256 amount) external payable returns (bool) {
        require(amount > 0, "Zero donation amount");
        uint256 cost = calculateCost(amount);
        require(msg.value >= cost, "Insufficient donation for bonding curve");

        totalSupply += amount;
        balanceOf[msg.sender] += amount;
        emit Transfer(address(0), msg.sender, amount);
        emit CurveMint(msg.sender, amount, cost);

        if (msg.value > cost) {
            payable(msg.sender).transfer(msg.value - cost);
        }
        return true;
    }

    function disburseHeritageGrant(
        string memory category,
        address recipient,
        uint256 amount,
        bytes32 proofHash
    ) external returns (bool) {
        require(balanceOf[msg.sender] >= amount, "Insufficient treasury reserve");
        balanceOf[msg.sender] -= amount;
        balanceOf[recipient] += amount;
        emit Transfer(msg.sender, recipient, amount);
        emit HeritageDisbursement(category, recipient, amount, proofHash);
        return true;
    }
}
