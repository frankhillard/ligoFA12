#import "./helper/bootstrap.mligo" "Bootstrap"
#import "./helper/assert.mligo" "Assert"
#import "./helper/asset.mligo" "Asset_helper"
#import "./asset.instance.mligo" "Asset"

type storage = Asset.FA12_TOKEN.storage

let test_atomic_transfer_success =
    let (asset, owners, operators) = Bootstrap.boot_asset_and_accounts(10n, 10n, 10n) in
    let (owner1, owner2, owner3) = owners in
    let (_op1, _op2, _op3) = operators in

    let transfer_1 = (owner1, (owner2, 2n)) in

    let () = Test.set_source owner1 in
    let _ = Test.transfer_exn asset.taddr (Transfer (transfer_1)) 0tez in
    let () = Asset_helper.assert_balances asset.taddr ((owner1, 8n), (owner2, 12n), (owner3, 10n)) in
    ()

let test_multiple_transfer_success =
    let (asset, owners, operators) = Bootstrap.boot_asset_and_accounts(10n, 10n, 10n) in
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
    let () = Asset_helper.assert_balances asset.taddr ((owner1, 8n), (owner2, 7n), (owner3, 15n)) in
    ()

// let test_failure_transfer_without_enough_allowance =
//     let (asset, owners, operators) = Bootstrap.boot_asset_and_accounts(10n, 10n, 10n) in
//     let (owner1, owner2, _owner3) = owners in
//     let (_op1, op2, _op3) = operators in

//     let () = Test.set_source op2 in
//     let transfer_1 = (owner2, (owner1, 6n)) in
//     let r = Test.transfer_to_contract asset.contr (Transfer transfer_1) 0tez in
//     Assert.allowance_failure r Asset.FA12.Errors.not_enough_allowance

let test_success_transfer_allowance_must_decrease =
    let (asset, owners, operators) = Bootstrap.boot_asset_and_accounts(10n, 10n, 10n) in
    let (owner1, owner2, _owner3) = owners in
    let (_op1, op2, _op3) = operators in

    let () = Test.set_source op2 in
    let transfer_1 = (owner2, (owner1, 2n)) in
    let _ = Test.transfer_to_contract_exn asset.contr (Transfer transfer_1) 0tez in
    let () = Asset_helper.assert_allowance asset.taddr owner2 op2 3n in
    ()

let test_success_transfer_allowance_must_decrease_full =
    let (asset, owners, operators) = Bootstrap.boot_asset_and_accounts(10n, 10n, 10n) in
    let (owner1, owner2, _owner3) = owners in
    let (_op1, op2, _op3) = operators in

    let () = Test.set_source op2 in
    let transfer_1 = (owner2, (owner1, 5n)) in
    let _ = Test.transfer_to_contract_exn asset.contr (Transfer transfer_1) 0tez in
    let () = Asset_helper.assert_allowance asset.taddr owner2 op2 0n in
    ()

let test_failure_owner_transfer_without_enough_balance =
    let (asset, owners, operators) = Bootstrap.boot_asset_and_accounts(10n, 10n, 10n) in
    let (owner1, owner2, _owner3) = owners in
    let (_op1, _op2, _op3) = operators in

    let () = Test.set_source owner2 in
    let transfer_1 = (owner2, (owner1, 11n)) in
    let r = Test.transfer_to_contract asset.contr (Transfer transfer_1) 0tez in
    Assert.string_failure r Asset.FA12.Errors.not_enough_balance

// let test_failure_transfer_without_enough_balance =
//     let (asset, owners, operators) = Bootstrap.boot_asset_and_accounts(10n, 10n, 10n) in
//     let (owner1, owner2, owner3) = owners in
//     let (_op1, op2, _op3) = operators in

//     let transfer_1 = (owner2, (owner1, 1n)) in
//     let transfer_2 = (owner2, (owner3, 10n)) in

//     let () = Test.set_source op2 in
//     let r = Test.transfer_to_contract asset.contr (Transfer transfer_1) 0tez in
//     let () = Assert.tx_success r in
//     let () = Asset_helper.assert_balances asset.taddr ((owner1, 11n), (owner2, 9n), (owner3, 10n)) in

//     let r = Test.transfer_to_contract asset.contr (Transfer transfer_2) 0tez in
//     Assert.allowance_failure r Asset.FA12.Errors.not_enough_allowance
