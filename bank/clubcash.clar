;; Title: Club Cash Purchases of Digital Land 
;; Only For Reference
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; SIP009 interface (testnet)
;;(impl-trait 'ST32XCD69XPS3GKDEXAQ29PJRDSD5AR643GY0C3Q5.nft-trait.nft-trait)
 
;; SIP009 interface (mainnet)
;;(impl-trait 'SP39EMTZG4P7D55FMEQXEB8ZEQEK0ECBHB1GD8GMT.nft-trait.nft-trait)

;; Define Constants
;;

(define-constant CONTRACT_OWNER tx-sender)
(define-constant VERSION "v0.0.6") ;; Version string

;; Define Errors
;;

(define-constant ERR_NOT_AUTHORIZED (err u401)) ;;: Not authorized for the operation
(define-constant ERR_ALREADY_MINTED (err u402)) ;;: already registered
(define-constant ERR_NOT_FOUND (err u404)) ;;:::::: no map entry
(define-constant ERR_STX_TRANSFER (err u405)) ;;::: non-sponsored purchase
(define-constant ERR_PRICE_TOO_LOW (err u406)) ;;:: tried to submit a tx with low or no fee
(define-constant ERR_PAYMENT_FAILURE (err u407)) ;; minting not paid
(define-constant ERR_SENDING_PAYMENT (err u408)) ;; error while sending the payment 
(define-constant ERR_LOW_BALANCE (err u409)) ;;:::: landlord deposited funds are insufficient 
(define-constant ERR_CANT_MAP_RP (err u410)) ;;::::::: map insert error, check data
(define-constant ERR_CANT_MAP_PLACE (err u411)) ;;::::::: map insert error, check data
(define-constant ERR_UPDATING_BAL (err u412)) ;;: failure updating balance 
(define-constant ERR_TOKEN_TRANSFER (err u500)) ;;: failure during a token transfer operation 

;; Define Vars
;;
(define-data-var fari-nominal   uint u125) ;;: Define FARI Nominal Value
(define-data-var fari-discount  uint u50)  ;;: Define FARI Digital Land Discount
(define-data-var last-id        uint u0)
(define-data-var fees           uint u2000000)
(define-data-var club1K         uint u1500)
(define-data-var club10K        uint u15000)
(define-data-var club100K       uint u150000)
(define-data-var club1M         uint u1500000)


;; Payments - has minting for this place been paid?
(define-map payments { osm-tid: uint, landlord: principal } { amount: uint, paid: bool })

;; Bank Teller simul - landlord balance gained thru incentives, coupons, airdrops, offers, etc.
(define-map bank-teller { landlord: principal } { balance: uint }) 

;; FARI:: Land valuations in FARI
(define-map valuation-fari { osm-tid: uint } { price-fari: uint }) 

;; STX:: Land valuations in STX
(define-map valuation-stx { osm-tid: uint } { price-stx: uint }) 

;; USD:: Land valuations in USD
(define-map valuation-usd { osm-tid: uint } { price-usd: uint }) 

;; Private functions
;;


;; Read-only functions
;;

;; Returns version of the 
;; clubcash contract
;; @returns string-ascii
(define-read-only (get-version) 
    VERSION)

;; Get min fees 
;; Returns minimum fees
;; @returns uint 
(define-read-only (get-fees)
    (var-get fees))

;; Get club coupon values
;; to support flex redemption
;; @returns uint 
(define-read-only (get-club1K)
    (var-get club1K))

(define-read-only (get-club10K)
    (var-get club10K))

(define-read-only (get-club100K)
    (var-get club100K))        

(define-read-only (get-club1M)
    (var-get club1M))

;; Get payment info
;; @returns map 
(define-read-only (get-payment (landlord principal) (osm-tid uint))
  (map-get? payments {osm-tid: osm-tid, landlord: landlord}))

;; Asset specific public functions
;;

;; Set fees 
;; Returns minimum fees
;; @returns uint 
(define-public (set-fees (new-fee uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) (err ERR_NOT_AUTHORIZED))
    (ok (var-set fees new-fee))))  

;; Set coupon values 
;; Returns redemption vals
;; @returns uint 

;; 1K
(define-public (set-club1K (new-1K uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) (err ERR_NOT_AUTHORIZED))
    (ok (var-set club1K new-1K)))) 

;; 10K
(define-public (set-club10K (new-10K uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) (err ERR_NOT_AUTHORIZED))
    (ok (var-set club10K new-10K)))) 

;; 100K
(define-public (set-club100K (new-100K uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) (err ERR_NOT_AUTHORIZED))
    (ok (var-set club100K new-100K)))) 

;; 1M
(define-public (set-club1M (new-1M uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) (err ERR_NOT_AUTHORIZED))
    (ok (var-set club1M new-1M)))) 

;; ;; Reedem coupons
;; ;; Assigns a balance to coupon holders
;; ;; upon NFT transfer
;; ;; @returns bool 

(define-public (redeem-1k (token-id uint))
  (begin
 ;; (try! (contract-call? .club-1k transfer token-id tx-sender CONTRACT_OWNER))
  (map-set bank-teller { landlord: tx-sender } { balance: (+ (get-usd-balance) (get-club1K))})
  (ok true)))

(define-public (redeem-10k (token-id uint))
  (begin
 ;; (try! (contract-call? .club-10k transfer token-id tx-sender CONTRACT_OWNER))
  (map-set bank-teller { landlord: tx-sender } { balance: (+ (get-usd-balance) (get-club10K))})
  (ok true)))

(define-public (redeem-100k (token-id uint))
  (begin
  ;; (try! (contract-call? .club-100k transfer token-id tx-sender CONTRACT_OWNER))
   (map-set bank-teller { landlord: tx-sender } { balance: (+ (get-usd-balance) (get-club100K))})
   (ok true)))

(define-public (redeem-1M (token-id uint))
  (begin
 ;; (try! (contract-call? .club-1M transfer token-id tx-sender CONTRACT_OWNER))
  (map-set bank-teller { landlord: tx-sender } { balance: (+ (get-usd-balance) (get-club1M))})
  (ok true)))

;; ;; Tear mini-coupons
;; ;; Allows Club NFT holders to mint 
;; ;; a lower denomination NFT to sell, trade or gift!
;; ;; @returns bool 

(define-public (cash-out-1k)
  (begin
   (asserts! (> (get-usd-balance) (get-club1K)) (err ERR_LOW_BALANCE))
   (map-set bank-teller { landlord: tx-sender } { balance: (- (get-usd-balance) (get-club1K))})
  ;; (try! (as-contract (contract-call? .club-1k mint tx-sender)))
   (ok true)))

(define-public (cash-out-10K)
  (begin
   (asserts! (> (get-usd-balance) (get-club10K)) (err ERR_LOW_BALANCE))
   (map-set bank-teller { landlord: tx-sender } { balance: (- (get-usd-balance) (get-club10K))}) 
  ;; (try! (as-contract (contract-call? .club-10k mint tx-sender)))
   (ok true))) 

(define-public (cash-out-100K)
  (begin
  (asserts! (> (get-usd-balance) (get-club100K)) (err ERR_LOW_BALANCE))
  (map-set bank-teller { landlord: tx-sender } { balance: (- (get-usd-balance) (get-club100K))})
  ;;(try! (as-contract (contract-call? .club-100k mint tx-sender)))
   (ok true)))

;; Payment and registration
;;

;; ;; FARI :::: Just-in-time valuation before minting
;; ;; Avoids underpricing, high tx fees, etc
;; ;; @returns bool 
(define-public (set-fari-price (osm-tid uint) (price-fari uint))
  (begin
  (asserts! (is-eq contract-caller CONTRACT_OWNER) ERR_NOT_AUTHORIZED)
  ;;(map-set valuation-fari osm-tid fari-price)

  (map-set valuation-fari { osm-tid: osm-tid } { price-fari: price-fari})
  (ok true)))

;; ;; STX :::: Just-in-time valuation before minting
;; ;; Avoids underpricing, high tx fees, etc
;; ;; @returns bool 
(define-public (set-stx-price (osm-tid uint) (price-stx uint))
  (begin
  (asserts! (is-eq contract-caller CONTRACT_OWNER) ERR_NOT_AUTHORIZED)

   (map-set valuation-stx { osm-tid: osm-tid } { price-stx: price-stx})
  ;;(map-set valuation-stx osm-tid stx-price)
  (ok true))) 

;; ;; FARI :::: Just-in-time valuation before minting
;; ;; Avoids underpricing, high tx fees, etc
;; ;; @returns uint 
(define-read-only (get-price-fari (osm-tid uint))
 (default-to u0 (get price-fari (map-get? valuation-fari {osm-tid: osm-tid}))))

;; ;; STX :::: Just-in-time valuation before minting
;; ;; Avoids underpricing, high tx fees, etc
;; ;; @returns uint 
(define-read-only (get-price-stx (osm-tid uint))
 (default-to u0 (get price-stx (map-get? valuation-stx {osm-tid: osm-tid})))) 

;; ;; USD :::: Just-in-time valuation before minting
;; ;; Avoids underpricing, high tx fees, etc
;; ;; @returns uint 
(define-read-only (get-price-usd (osm-tid uint))
 (default-to u0 (get price-usd (map-get? valuation-usd {osm-tid: osm-tid})))) 

;; ;; Get Balance :: check USD balance after NFT deposits
;; ;; @returns uint 
(define-read-only (get-usd-balance)
  (default-to u0 (get balance (map-get? bank-teller {landlord: tx-sender})))) 


;; ;; Club mint. This mints via Club NFT Coupons
;; ;; Only pays network fees, rest sponsored by coupons
;; ;; @returns bool 
(define-public (club-mint (osm-tid uint) (landlord principal) (json (string-ascii 256)))
  (begin
   (asserts! ( > (get-usd-balance) (get-price-usd osm-tid)) (err ERR_LOW_BALANCE))
   (unwrap-panic (stx-transfer? (var-get fees) tx-sender CONTRACT_OWNER))
   
    (map-insert payments 
        { osm-tid: osm-tid, landlord: tx-sender } 
        { amount: (var-get fees), paid: true })
    (map-set bank-teller { landlord: tx-sender } 
        {balance: (- (get-usd-balance) (get-price-usd osm-tid)) })
    (unwrap-panic (as-contract (mint osm-tid landlord json)))
    (ok true)))
