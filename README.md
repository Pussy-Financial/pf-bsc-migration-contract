## How This Works
**Burn Wallet:** The contract uses `BURN_ADDRESS` (`0x000000000000000000000000000000000000dEaD`) as the recipient for V1 tokens. Tokens sent here are effectively removed from circulation because no one has access to this address.

## Migration Flow

1. Users approve the migration contract to transfer their V1 tokens.
2. When `migrate` is called, V1 tokens are sent to the burn wallet.
3. V2 tokens are then transferred to the user at a 1:1 rate.

## Owner Privileges

The owner can still withdraw unclaimed V2 tokens for other uses, like community incentives or refunds.

## Deployment Notes

Make sure you communicate that users must approve the migration contract to transfer their V1 tokens. For example:

```solidity
v1Token.approve(address(migrationContract), amount);
```

## Steps to Use `index.html`

1. Replace the following placeholders in the script:
    - `YOUR_V1_TOKEN_ADDRESS_HERE`: Address of your V1 token contract.
    - `YOUR_V2_TOKEN_ADDRESS_HERE`: Address of your V2 token contract.
    - `YOUR_MIGRATION_CONTRACT_ADDRESS_HERE`: Address of your migration contract.
    - `v1TokenABI`: The ABI of your V1 token contract.
    - `migrationContractABI`: The ABI of your migration contract.

2. Host this HTML file using any simple web server (or even locally).

3. Ask users to:
    - Connect their MetaMask wallet by clicking "Connect Wallet."
    - Enter the amount of V1 tokens they wish to migrate.
    - Approve the V1 token transfer.
    - Click "Migrate Tokens" to complete the migration.
