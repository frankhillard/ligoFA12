#import "./helper/bootstrap.mligo" "Bootstrap"
#import "./helper/assert.mligo" "Assert"
#import "./helper/asset.mligo" "Asset_helper"
#import "./asset.instance.mligo" "Asset"

type storage = Asset.storage

let test_extra_entrypoint_success =
    let (asset, owners, operators) = Bootstrap.boot_asset_and_accounts(10n, 10n, 10n) in
    let (owner1, owner2, owner3) = owners in
    let (op1, op2, op3) = operators in

    let () = Test.set_source owner1 in
    let _ = Test.transfer_exn asset.taddr (X ()) 0tez in
    let () = Asset_helper.assert_balances asset.taddr ((owner1, 10n), (owner2, 10n), (owner3, 10n)) in
    let () = Asset_helper.assert_allowance asset.taddr owner1 op1 10n in
    let () = Asset_helper.assert_allowance asset.taddr owner2 op1 5n in
    let () = Asset_helper.assert_allowance asset.taddr owner2 op2 5n in
    let () = Asset_helper.assert_allowance asset.taddr owner3 op1 4n in
    let () = Asset_helper.assert_allowance asset.taddr owner3 op2 3n in
    let () = Asset_helper.assert_allowance asset.taddr owner3 op3 3n in
    ()
