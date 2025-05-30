# Stack Index Fund Smart Contract

A decentralized index fund implementation on the Stacks blockchain that enables users to gain exposure to multiple assets through a single pooled token.

## Features

- **Auto-rebalancing** index fund mechanism
- **SIP-010** compliant token integration
- **Proportional** minting and redemption
- **Admin controls** for reserve management
- **Real-time** balance and stats queries

## Contract Architecture

### Core Components

1. **Token Integration**
```clarity
(use-trait sip-010-trait .sip-010-trait.sip-010-trait)
```

2. **Reserve Management**
- Maintains two token reserves (Token A & Token B)
- Tracks total index tokens
- Maps user balances

### Key Functions

#### Minting
```clarity
(define-public (mint-index (token-a <sip-010-trait>) 
                          (token-b <sip-010-trait>) 
                          (amount-a uint) 
                          (amount-b uint))
```
- Accepts deposits of both tokens
- Mints index tokens proportionally
- Updates reserves and balances

#### Redemption
```clarity
(define-public (redeem-index (token-a <sip-010-trait>) 
                            (token-b <sip-010-trait>) 
                            (amount uint))
```
- Burns index tokens
- Returns proportional amounts of underlying assets
- Updates reserves and balances

## Setup

1. Deploy the contract to Stacks blockchain
2. Initialize with token contract addresses:
   - Token A (e.g., Arkadiko)
   - Token B (e.g., Wrapped Bitcoin)

## Usage

### For Users

1. **Minting Index Tokens**
```clarity
(contract-call? .stack-index mint-index token-a token-b amount-a amount-b)
```

2. **Redeeming Index Tokens**
```clarity
(contract-call? .stack-index redeem-index token-a token-b amount)
```

3. **Checking Balance**
```clarity
(contract-call? .stack-index get-user-index-balance user)
```

### For Admins

```clarity
(contract-call? .stack-index admin-update-reserves new-a new-b)
```

## Security

- Admin-only functions protected by principal checks
- Balance checks before transfers
- Arithmetic overflow protection

## Development

Built with:
- Clarity Smart Contract Language
- SIP-010 Token Standard
- Stacks Blockchain

