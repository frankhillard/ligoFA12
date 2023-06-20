#import "./helper/bootstrap.mligo" "Bootstrap"
#import "./helper/assert.mligo" "Assert"
#import "./asset.instance.mligo" "Asset"

type storage = Asset.storage

let assert_allowance
    (contract_address : (Asset.parameter, Asset.storage) typed_address )
    (owner : address)
    (spender : address)
    (expected_allowance : nat) =
    let storage = Test.get_storage contract_address in
    let ledger = storage.ledger in
    match (Big_map.find_opt owner ledger) with
    | Some amt_allow -> 
        let () = match (Map.find_opt spender amt_allow.1) with
        | Some v -> assert (v = expected_allowance)
        | None -> failwith "incorrect allowance"
        in
        () 
    | None -> failwith "incorret address"
    

let assert_balances
  (contract_address : (Asset.parameter, Asset.storage) typed_address )
  (a, b, c : (address * nat) * (address * nat) * (address * nat)) =
  let (owner1, balance1) = a in
  let (owner2, balance2) = b in
  let (owner3, balance3) = c in
  let storage = Test.get_storage contract_address in
  let ledger = storage.ledger in
  let () = match (Big_map.find_opt owner1 ledger) with
    Some amt -> assert (amt.0 = balance1)
  | None -> failwith "incorret address"
  in
  let () = match (Big_map.find_opt owner2 ledger) with
    Some amt ->  assert (amt.0 = balance2)
  | None -> failwith "incorret address"
  in
  let () = match (Big_map.find_opt owner3 ledger) with
    Some amt -> assert (amt.0 = balance3)
  | None -> failwith "incorret address"
  in
  ()


let test_atomic_tansfer_success =
    let (asset, owners, operators) = Bootstrap.boot_asset_and_accounts(10n, 10n, 10n) in
    // let ((t_addr,_,_), owners, operators) = get_initial_storage (10n, 10n, 10n) in
    let (owner1, owner2, owner3) = owners in
    let (op1, _op2, _op3) = operators in

    let transfer_1 = (owner1, (owner2, 2n)) in
    let transfer_2 = (owner1, (owner3, 3n)) in
    let transfer_3 = (owner2, (owner3, 2n)) in
    let transfer_4 = (owner2, (owner1, 3n)) in

    let () = Test.set_source op1 in
    let _ = Test.transfer_to_contract_exn asset.contr (Transfer transfer_1) 0tez in
    let _ = Test.transfer_to_contract_exn asset.contr (Transfer transfer_2) 0tez in
    let _ = Test.transfer_to_contract_exn asset.contr (Transfer transfer_3) 0tez in
    let _ = Test.transfer_to_contract_exn asset.contr (Transfer transfer_4) 0tez in
    let () = assert_balances asset.taddr ((owner1, 8n), (owner2, 7n), (owner3, 15n)) in
    ()



let test_failure_transfer_without_enough_allowance =
    let (asset, owners, operators) = Bootstrap.boot_asset_and_accounts(10n, 10n, 10n) in
    let (owner1, owner2, _owner3) = owners in
    let (_op1, op2, _op3) = operators in

    let () = Test.set_source op2 in
    let transfer_1 = (owner2, (owner1, 6n)) in
    let r = Test.transfer_to_contract asset.contr (Transfer transfer_1) 0tez in
    Assert.string_failure r Asset.FA12.Errors.not_enough_allowance

let test_success_transfer_allowance_must_decrease =
    let (asset, owners, operators) = Bootstrap.boot_asset_and_accounts(10n, 10n, 10n) in
    let (owner1, owner2, _owner3) = owners in
    let (_op1, op2, _op3) = operators in

    let () = Test.set_source op2 in
    let transfer_1 = (owner2, (owner1, 2n)) in
    let _ = Test.transfer_to_contract_exn asset.contr (Transfer transfer_1) 0tez in
    let store = Test.get_storage asset.taddr in
    let () = Test.log(store) in
    let () = assert_allowance asset.taddr owner2 op2 3n in
    ()

// let test_failure_owner_transfer_without_enough_balance =
//     let (asset, owners, operators) = Bootstrap.boot_asset_and_accounts(10n, 10n, 10n) in
//     let (owner1, owner2, _owner3) = owners in
//     let (_op1, _op2, _op3) = operators in

//     let () = Test.set_source owner2 in
//     let transfer_1 = (owner2, (owner1, 11n)) in
//     let r = Test.transfer_to_contract asset.contr (Transfer transfer_1) 0tez in
//     let () = Test.log(r) in
//     Assert.string_failure r Asset.FA12.Errors.not_enough_balance

// let test_failure_transfer_without_enough_balance =
//     let (asset, owners, operators) = Bootstrap.boot_asset_and_accounts(10n, 10n, 10n) in
//     let (owner1, owner2, owner3) = owners in
//     let (_op1, op2, _op3) = operators in

//     let transfer_1 = (owner2, (owner1, 1n)) in
//     let transfer_2 = (owner2, (owner3, 10n)) in

//     let () = Test.set_source op2 in
//     let _ = Test.transfer_to_contract_exn asset.contr (Transfer transfer_1) 0tez in
//     let () = assert_balances asset.taddr ((owner1, 11n), (owner2, 9n), (owner3, 10n)) in

//     let store = Test.get_storage asset.taddr in
//     let () = Test.log(store) in
//     let r = Test.transfer_to_contract asset.contr (Transfer transfer_2) 0tez in
//     let () = Test.log(r) in
//     Assert.string_failure r Asset.FA12.Errors.not_enough_balance

