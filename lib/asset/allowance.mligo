#import "errors.mligo" "Errors"

type spender = address
type allowed_amount = nat
type t = (spender, allowed_amount) map

let get_allowed_amount (a:t) (spender:spender) : nat =
    match Map.find_opt spender a with
    | Some v -> v 
    | None -> 0n

let set_allowed_amount (a:t) (spender:spender) (allowed_amount:allowed_amount) : t =
        Map.add spender allowed_amount a

let decrease_allowance (a:t) (spender:spender) (allowed_amount:allowed_amount) : t =
    match Map.find_opt spender a with
    | Some v -> 
        let _ = assert_with_error(v >= allowed_amount) Errors.not_enough_allowance in
        let new_allowed_amount = abs(v - allowed_amount) in
        if new_allowed_amount > 0n then
            Map.update spender (Some(new_allowed_amount)) a
        else
            Map.remove spender a
    | None -> failwith(Errors.not_enough_allowance)