#import "./helper/bootstrap.mligo" "Bootstrap"
#import "./helper/assert.mligo" "Assert"
#import "./helper/asset.mligo" "Asset_helper"
#import "./asset.instance.mligo" "Asset"

type storage = Asset.storage

let test_success_approve =
    let (asset, owners, operators) = Bootstrap.boot_asset_and_accounts(10n, 10n, 10n) in
    let (owner1, _owner2, _owner3) = owners in
    let (_op1, _op2, op3) = operators in

    let () = Test.set_source owner1 in
    let approve_op3 = (op3, 1n) in
    let r = Test.transfer_to_contract asset.contr (Approve approve_op3) 0tez in
    let () = Assert.tx_success r in
    let () = Asset_helper.assert_allowance asset.taddr owner1 op3 1n in
    ()

let test_failure_approve_modify_allowance =
    let (asset, owners, operators) = Bootstrap.boot_asset_and_accounts(10n, 10n, 10n) in
    let (owner1, _owner2, _owner3) = owners in
    let (op1, _op2, _op3) = operators in

    let () = Test.set_source owner1 in
    let approve_op1 = (op1, 1n) in
    let r = Test.transfer_to_contract asset.contr (Approve approve_op1) 0tez in
    Assert.string_failure r Asset.FA12.Errors.vulnerable_operation

let test_success_approve_modify_allowance =
    let (asset, owners, operators) = Bootstrap.boot_asset_and_accounts(10n, 10n, 10n) in
    let (owner1, _owner2, _owner3) = owners in
    let (op1, _op2, _op3) = operators in

    // SET ALLOWANCE TO 0 FOR OP1
    let () = Test.set_source owner1 in
    let approve_op1 = (op1, 0n) in
    let r = Test.transfer_to_contract asset.contr (Approve approve_op1) 0tez in
    let () = Assert.tx_success r in
    let () = Asset_helper.assert_allowance asset.taddr owner1 op1 0n in

    // SET ALLOWANCE TO 1 FOR OP1
    let approve_op1 = (op1, 1n) in
    let r = Test.transfer_to_contract asset.contr (Approve approve_op1) 0tez in
    let () = Assert.tx_success r in
    let () = Asset_helper.assert_allowance asset.taddr owner1 op1 1n in
    ()