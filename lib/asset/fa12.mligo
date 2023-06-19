#import "errors.mligo" "Errors"
#import "allowance.mligo" "Allowance"
#import "ledger.mligo" "Ledger"
#import "token_metadata.mligo" "TokenMetadata"
#import "storage.mligo" "Storage"

// /* Errors */
// export namespace Errors {
//   export let notEnoughBalance   = "NotEnoughBalance";
//   export let notEnoughAllowance = "NotEnoughAllowance";
//   /* Extra error, see: https://docs.google.com/document/d/1YLPtQxZu1UAvO9cZ1O2RPXBbT0mooh4DYKjA_jp-RLM/edit */
//   export let vulnerable_operation = "Switching allowances from N to M is a vulnerability";
// };

// export namespace Allowance {
//   export type spender        = address;
//   export type allowed_amount = nat;
//   export type t = map<spender, allowed_amount>;

//   export let get_allowed_amount = (a:t, spender:spender) : nat => {
//     return match(Map.find_opt(spender,a), {
//       Some: (v : allowed_amount) => v, 
//       None: () => 0 as nat
//     });
//   };

//   export let set_allowed_amount = (a:t, spender:spender, allowed_amount:allowed_amount) : t => {
//     if (allowed_amount > (0 as nat)) {
//       return Map.add(spender, allowed_amount, a)
//     } else {
//       return a;
//     }
//   }
// };


// export namespace Ledger {
//    export type owner      = address;
//    export type spender    = address;
//    export type amount_    = nat;
//    export type t = big_map<owner, [amount_, Allowance.t]>;

//    export let get_for_user = (ledger:t, owner: owner) : [amount_,Allowance.t] => {
//       return match(Big_map.find_opt(owner, ledger), {
//         Some: (tokens : [amount_, Allowance.t]) => tokens,
//         None: () => [0 as nat,Map.empty as Allowance.t]
//       });
//    };

//    export let update_for_user = (ledger:t, owner: owner, amount_ : amount_, allowances : Allowance.t) : t => {
//       return Big_map.update(owner, (Some ([amount_,allowances])), ledger)
//    };

//    export let set_approval = (ledger:t, owner: owner, spender : spender, allowed_amount: amount_) : t => {
//       let [tokens, allowances] = get_for_user(ledger, owner);
//       let previous_allowances = Allowance.get_allowed_amount(allowances, spender);
//       let _ = assert_with_error((previous_allowances == (0 as nat) || allowed_amount == (0 as nat)), Errors.vulnerable_operation);
//       let allowances = Allowance.set_allowed_amount(allowances, spender, allowed_amount);
//       let ledger     = update_for_user(ledger, owner, tokens, allowances);
//       return ledger
//    };

//    export let decrease_token_amount_for_user = (ledger : t, spender : spender, from_ : owner, amount_ : amount_) : t => {
//       let [tokens, allowances] = get_for_user(ledger, from_);
//       let allowed_amount = Allowance.get_allowed_amount(allowances, spender);
//       if (spender == from_) { 
//         allowed_amount = tokens;
//       };
//       let _ = assert_with_error((allowed_amount >= amount_), Errors.notEnoughAllowance);
//       let _ = assert_with_error((tokens >= amount_), Errors.notEnoughBalance);
//       let tokens = abs(tokens - amount_);
//       let ledger = update_for_user(ledger, from_, tokens, allowances);
//       return ledger
//    };

//    export let increase_token_amount_for_user = (ledger : t, to_   : owner, amount_ : amount_) : t => {
//       let [tokens, allowances] = get_for_user(ledger, to_);
//       let tokens = tokens + amount_;
//       let ledger = update_for_user(ledger, to_, tokens, allowances);
//       return ledger
//    };
// };

// export namespace TokenMetadata {
//    /**
//       This should be initialized at origination, conforming to either
//       TZIP-12 : https://gitlab.com/tezos/tzip/-/blob/master/proposals/tzip-12/tzip-12.md#token-metadata
//       or TZIP-16 : https://gitlab.com/tezos/tzip/-/blob/master/proposals/tzip-12/tzip-12.md#contract-metadata-tzip-016
//    */
//    export type data = {
//        token_id : nat,
//        token_info : map<string, bytes>
//     };
//    export type t = data;
// };

// export namespace Storage {
//    export type t = {
//       ledger : Ledger.t,
//       token_metadata : TokenMetadata.t,
//       totalSupply : nat,
//       /* Note: memoizing the sum of all participant balance reduce the cost of getTotalSupply entrypoint.
//          However, with this pattern the value has to be manually set at origination which can lead to consistency issues.
//       */
//    };

//    export let get_amount_for_owner = (s:t, owner : address) : nat => {
//       let [amount_, _] = Ledger.get_for_user(s.ledger, owner);
//       return amount_
//    };

//    export let get_allowances_for_owner = (s:t, owner : address) : Allowance.t => {
//       let [_, allowances] = Ledger.get_for_user(s.ledger, owner);
//       return allowances
//    };

//    export let get_ledger = (s:t) : Ledger.t => s.ledger;
//    export let set_ledger = (s:t, ledger:Ledger.t) : t => {
//        return {...s, ledger: ledger}
//    }

// };

type storage = Storage.t


// /** transfer entrypoint */
type transfer = (address * (address * nat))

let transfer ((from_, to_value), s : transfer * storage) : operation list * storage =
   let (to_, value) = to_value in
   let ledger1 = Storage.get_ledger s in
   let ledger2 = Ledger.decrease_token_amount_for_user ledger1 (Tezos.get_sender ()) from_ value in
   let ledger = Ledger.increase_token_amount_for_user ledger2 to_ value in
   let s1 = Storage.set_ledger s ledger in
   (([] : operation list), s1)


// /** approve */
type approve = address * nat
let approve ((spender,value), s : approve * storage) : operation list * storage =
   let ledger1 = Storage.get_ledger s in
   let ledger = Ledger.set_approval ledger1 (Tezos.get_sender ()) spender value in
   let s1 = Storage.set_ledger s ledger in
   (([] : operation list), s1)


// /** getAllowance entrypoint */
type getAllowance = ((address * address) * nat contract)
let getAllowance ((owner_spender,callback), s: getAllowance * storage) : operation list * storage =
   let (owner,spender) = owner_spender in
   let a = Storage.get_allowances_for_owner s owner in
   let allowed_amount = Allowance.get_allowed_amount a spender in
   let operation = Tezos.transaction allowed_amount 0tez callback in
   ([operation], s)


// /** getBalance entrypoint */
type getBalance = address * nat contract 
let getBalance ((owner,callback), s : getBalance * storage) : operation list * storage =
   let balance_ = Storage.get_amount_for_owner s owner in
   let operation = Tezos.transaction balance_ 0tez callback in
   ([operation], s)


// /** getTotalSupply entrypoint */
type getTotalSupply = (unit * nat contract)
let getTotalSupply ((_,callback), s : getTotalSupply * storage) : operation list * storage =
   let operation = Tezos.transaction s.totalSupply 0tez callback in
   ([operation], s)

type parameter = 
| Transfer of transfer 
| Approve of approve 
| GetAllowance of getAllowance 
| GetBalance of getBalance 
| GetTotalSupply of getTotalSupply

let main ((p,s): (parameter * storage)) : operation list * storage =
    match p with
      Transfer pp -> transfer pp s
    | Approve p-> approve p s
    | GetAllowance p-> getAllowance p s
    | GetBalance p-> getBalance p s
    | GetTotalSupply p-> getTotalSupply p s

