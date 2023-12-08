(* Assert contract call results in failwith with given string *)
let string_failure (res : test_exec_result) (expected : string) : unit =
    let expected = Test.eval expected in
    match res with
        | Fail (Rejected (actual,_)) -> assert (actual = expected)
        | Fail (Balance_too_low _err) -> Test.failwith "contract failed: balance too low"
        | Fail (Other s) -> Test.failwith s
        | Success _ -> Test.failwith "Transaction should fail"

(* Assert contract result is successful *)
let tx_success (res: test_exec_result) : unit =
    match res with
        | Success(_) -> ()
        | Fail (Rejected (error,_)) ->
            let () = Test.log(error) in
            Test.failwith "Transaction should not fail"
        | Fail _ -> Test.failwith "Transaction should not fail"

(* Decompile a michelson_program for a given type *)
// let decompile_hack (type a) (m : michelson_program) : a =
//   let cte = Test.register_constant m in
//   let f (() : unit) (_ : a option) : operation list * a option =
//     [], Some (Tezos.constant cte : a) in
//   let taux, _, _ = Test.originate f None 0tez in
//   let _ = Test.transfer_to_contract_exn (Test.to_contract taux) () 0tez in
//   Option.unopt (Test.get_storage taux)

// (* Assert contract call results in failwith with given `"notEnoughAllowance" (required, current)` format *)
// let allowance_failure (res : test_exec_result) (expected : string) : unit =
//     // let expected = Test.eval expected in // instead of decompile_hack
//     match res with
//         | Fail (Rejected (actual,_)) -> 
//             let ec : string * (nat * nat) = decompile_hack actual in
//             assert (ec.0 = expected)
//         | Fail (Balance_too_low _err) -> Test.failwith "contract failed: balance too low"
//         | Fail (Other s) -> Test.failwith s
//         | Success _ -> Test.failwith "Transaction should fail"