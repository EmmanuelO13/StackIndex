;; Auto-Rebalancing Index Fund Smart Contract (Stacks / Clarity)

;; Constants for SIP010 token contracts (update these with actual contract principals)
(use-trait sip-010-trait .sip-010-trait.sip-010-trait)
(define-constant TOKEN-A-CONTRACT 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR.arkadiko-token)
(define-constant TOKEN-B-CONTRACT 'SP3DX3H4FEYZJZ586MFBS25ZW3HZDMEW92260R2PR.wrapped-bitcoin-token)

;; Token contracts implement the SIP010 trait internally

;; Admin constant
(define-constant ADMIN 'ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG)

;; Index token is represented internally, not as a SIP010

;; Data Variables
(define-data-var total-index-tokens uint u0)
(define-data-var reserve-a uint u0)
(define-data-var reserve-b uint u0)

;; User balances in index tokens
(define-map user-balances principal uint)

;; Utility to get min of two uints
(define-private (min (x uint) (y uint))
  (if (< x y) x y))

;; MINT index tokens based on equal contribution of token A and B
(define-public (mint-index (token-a <sip-010-trait>) (token-b <sip-010-trait>) (amount-a uint) (amount-b uint))
  (begin
    ;; Transfer tokens to contract
    (try! (contract-call? token-a transfer amount-a tx-sender (as-contract tx-sender) none))
    (try! (contract-call? token-b transfer amount-b tx-sender (as-contract tx-sender) none))
    (let 
      ((minted (min amount-a amount-b))
       (current (default-to u0 (map-get? user-balances tx-sender))))
      (map-set user-balances tx-sender (+ current minted))
      (var-set total-index-tokens (+ (var-get total-index-tokens) minted))
      (var-set reserve-a (+ (var-get reserve-a) amount-a))
      (var-set reserve-b (+ (var-get reserve-b) amount-b))
      (ok minted))))

;; REDEEM index tokens for underlying assets
(define-public (redeem-index (token-a <sip-010-trait>) (token-b <sip-010-trait>) (amount uint))
  (let 
    ((user-balance (default-to u0 (map-get? user-balances tx-sender)))
     (total (var-get total-index-tokens))
     (share (/ (* amount u1000000) total))
     (return-a (/ (* share (var-get reserve-a)) u1000000))
     (return-b (/ (* share (var-get reserve-b)) u1000000)))
    
    (asserts! (>= user-balance amount) (err u401))
    
    ;; Transfer reserves to user
    (try! (contract-call? token-a transfer return-a (as-contract tx-sender) tx-sender none))
    (try! (contract-call? token-b transfer return-b (as-contract tx-sender) tx-sender none))
    
    ;; Update balances
    (var-set reserve-a (- (var-get reserve-a) return-a))
    (map-set user-balances tx-sender (- user-balance amount))
    (var-set total-index-tokens (- (var-get total-index-tokens) amount))
    
    (ok true)))

;; ADMIN: Update reserves manually (e.g., post-rebalance)
(define-public (admin-update-reserves (new-a uint) (new-b uint))
  (begin
    (asserts! (is-eq tx-sender ADMIN) (err u401))
    (var-set reserve-a new-a)
    (var-set reserve-b new-b)
    (ok true)))

;; READ ONLYS

(define-read-only (get-user-index-balance (user principal))
  (ok (default-to u0 (map-get? user-balances user))))

(define-read-only (get-index-stats)
  (ok {
    reserve-a: (var-get reserve-a),
    reserve-b: (var-get reserve-b),
    total-index: (var-get total-index-tokens)
  }))
