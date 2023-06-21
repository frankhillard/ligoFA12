#import "errors.mligo" "Errors"

type t = (address, nat) map

let get_allowed_amount (a:t) (spender:address) : nat =
    match Map.find_opt spender a with
    | Some v -> v 
    | None -> 0n

let set_allowed_amount (a:t) (spender:address) (allowed_amount: nat) : t =
        Map.add spender allowed_amount a

let decrease_allowance (a:t) (spender:address) (decrease_amount: nat) : t =
    match Map.find_opt spender a with
    | Some v -> 
        let _ = if (v < decrease_amount) then
                //  TZIP-7 specifies that it should fail with requested allowance and current allowance
                ([%Michelson ({| { FAILWITH } |} : string * (nat * nat) -> unit)]
                (Errors.not_enough_allowance, (decrease_amount, v)) : unit)
            else
                ()
        in
        let new_allowed_amount = abs(v - decrease_amount) in
        if new_allowed_amount > 0n then
            Map.update spender (Some(new_allowed_amount)) a
        else
            Map.remove spender a
    | None -> 
            //  TZIP-7 specifies that it should fail with requested allowance and current allowance
            ([%Michelson ({| { FAILWITH } |} : string * (nat * nat) -> t)]
            (Errors.not_enough_allowance, (decrease_amount, 0n)) : t)
