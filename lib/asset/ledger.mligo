#import "errors.mligo" "Errors"
#import "allowance.mligo" "Allowance"

type t = (address, (nat * Allowance.t)) big_map

let get_for_user (ledger:t) (owner: address) : (nat * Allowance.t) =
    match Big_map.find_opt owner ledger with
    | Some tokens -> tokens
    | None -> (0n, (Map.empty :Allowance.t))

let update_for_user (ledger:t) (owner: address) (amount_ : nat) (allowances : Allowance.t) : t =
    Big_map.update owner (Some (amount_,allowances)) ledger


let set_approval (ledger:t) (owner: address) (spender : address) (allowed_amount: nat) : t =
      let (tokens, allowances) = get_for_user ledger owner in
      let previous_allowances = Allowance.get_allowed_amount allowances spender in
      let _ = assert_with_error (previous_allowances = 0n || allowed_amount = 0n) Errors.vulnerable_operation in
      let allowances = Allowance.set_allowed_amount allowances spender allowed_amount in
      let ledger = update_for_user ledger owner tokens allowances in
      ledger


let decrease_token_amount_for_user (ledger : t) (spender : address) (from_ : address) (amount_ : nat) : t =
    let (tokens, allowances) = get_for_user ledger from_ in
    let new_allowances = if (spender = from_) then 
        allowances
    else
        Allowance.decrease_allowance allowances spender amount_
    in
    let _ = assert_with_error (tokens >= amount_) Errors.not_enough_balance in
    let tokens = abs(tokens - amount_) in
    let ledger = update_for_user ledger from_ tokens new_allowances in
    ledger


let increase_token_amount_for_user (ledger : t) (to_ : address) (amount_ : nat) : t =
    let (tokens, allowances) = get_for_user ledger to_ in
    let tokens = tokens + amount_ in
    let ledger = update_for_user ledger to_ tokens allowances in
    ledger

