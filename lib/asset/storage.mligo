#import "allowance.mligo" "Allowance"
#import "ledger.mligo" "Ledger"
#import "token_metadata.mligo" "TokenMetadata"

type t = {
    ledger : Ledger.t;
    token_metadata : TokenMetadata.t;
    totalSupply : nat;
    //   /* Note: memoizing the sum of all participant balance reduce the cost of getTotalSupply entrypoint.
    //      However, with this pattern the value has to be manually set at origination which can lead to consistency issues.
    //   */
   }

let get_amount_for_owner (s:t) (owner : address) : nat =
    let (amount_, _) = Ledger.get_for_user s.ledger owner in
    amount_

let get_allowances_for_owner (s:t) (owner : address) : Allowance.t =
    let (_, allowances) = Ledger.get_for_user s.ledger owner in
    allowances

let get_ledger (s:t) : Ledger.t = s.ledger

let set_ledger (s:t) (ledger:Ledger.t) : t =
    {s with ledger=ledger}

