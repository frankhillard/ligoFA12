type spender = address
type allowed_amount = nat
type t = (spender, allowed_amount) map

let get_allowed_amount (a:t) (spender:spender) : nat =
    match Map.find_opt spender a with
    | Some v -> v 
    | None -> 0n

let set_allowed_amount (a:t) (spender:spender) (allowed_amount:allowed_amount) : t =
    if allowed_amount > 0n then
        Map.add spender allowed_amount a
    else
        a

