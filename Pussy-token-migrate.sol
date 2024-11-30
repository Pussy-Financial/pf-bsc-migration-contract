// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IV1Token {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

interface IV2Token {
    function transfer(address recipient, uint256 amount) external returns (bool);
}

contract PussyTokenMigrate {
    IV1Token public v1Token;
    IV2Token public v2Token;
    address public owner;
    bool public paused = false;
    address constant BURN_ADDRESS = 0x000000000000000000000000000000000000dEaD;

    event Migrated(address indexed user, uint256 amount);
    event Withdrawal(address indexed owner, uint256 amount);
    event Paused();
    event Unpaused();

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    modifier whenNotPaused() {
        require(!paused, "Migration is paused");
        _;
    }
    
    constructor(address _v1Token, address _v2Token) {
        v1Token = IV1Token(_v1Token);
        v2Token = IV2Token(_v2Token);
        owner = msg.sender;
    }

    function migrate(uint256 amount) external whenNotPaused {
        require(amount > 0, "Amount must be greater than zero");

        // Check the user's V1 token balance
        uint256 userBalance = v1Token.balanceOf(msg.sender);
        require(userBalance >= amount, "Insufficient V1 token balance");

        // Transfer V1 tokens from the user to the burn address
        require(v1Token.transferFrom(msg.sender, BURN_ADDRESS, amount), "V1 token transfer failed");

        // Transfer V2 tokens to the user
        require(v2Token.transfer(msg.sender, amount), "V2 token transfer failed");

        emit Migrated(msg.sender, amount);
    }

    // Allows removing any leftover V2 tokens from the contract after migration is complete. ( old burnt bsc tokens, tokens stuck in old bridge tokens, etc )
    function withdrawV2Tokens(uint256 amount) external onlyOwner {
        require(v2Token.transfer(owner, amount), "Withdrawal failed");
        emit Withdrawal(owner, amount);
    }

    // Pausing the contract will prevent any further migrations, along with pausing if a vulnerability is found.
    function pause() external onlyOwner {
        paused = true;
        emit Paused();
    }

    // Unpausing the contract will allow migrations to continue.
    function unpause() external onlyOwner {
        paused = false;
        emit Unpaused();
    }
}
