// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Interface for the V1 token
interface IV1Token {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

// Interface for the V2 token
interface IV2Token {
    function transfer(address recipient, uint256 amount) external returns (bool);
}

contract TokenMigrator {
    IV1Token public v1Token;
    IV2Token public v2Token;
    address public owner;
    address public constant BURN_ADDRESS = 0x000000000000000000000000000000000000dEaD;

    event Migrated(address indexed user, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    constructor(address _v1Token, address _v2Token) {
        v1Token = IV1Token(_v1Token);
        v2Token = IV2Token(_v2Token);
        owner = msg.sender;
    }

    // Migrate tokens from V1 to V2
    function migrate(uint256 amount) external {
        require(amount > 0, "Amount must be greater than zero");

        // Transfer V1 tokens from the user to the burn address
        require(v1Token.transferFrom(msg.sender, BURN_ADDRESS, amount), "V1 token transfer failed");

        // Transfer V2 tokens to the user
        require(v2Token.transfer(msg.sender, amount), "V2 token transfer failed");

        emit Migrated(msg.sender, amount);
    }

    // Owner can withdraw unclaimed V2 tokens
    function withdrawV2Tokens(uint256 amount) external onlyOwner {
        require(v2Token.transfer(owner, amount), "Withdrawal failed");
    }
}
