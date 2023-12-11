#import "asset.mligo" "Asset_helper"

let boot_accounts () =
    let () = Test.reset_state 7n ([10000000tez; 4000000tez; 4000000tez; 4000000tez; 4000000tez; 4000000tez; 4000000tez] : tez list) in
    let accounts =
        Test.nth_bootstrap_account 1,
        Test.nth_bootstrap_account 2,
        Test.nth_bootstrap_account 3,
        Test.nth_bootstrap_account 4,
        Test.nth_bootstrap_account 5,
        Test.nth_bootstrap_account 6
    in
    accounts

let boot_asset_and_accounts (a, b, c : nat * nat * nat) =
    let (owner1, owner2, owner3, op1, op2, op3) = boot_accounts() in
    let owners = (owner1, owner2, owner3) in
    let ops = (op1, op2, op3) in

    let owner1_allowances = Map.literal ([ (op1, 10n); ]) in
    let owner2_allowances = Map.literal ([ (op1, 5n); (op2, 5n); ]) in
    let owner3_allowances = Map.literal ([ (op1, 4n); (op2, 3n); (op3, 3n); ]) in

    let ledger = Big_map.literal ([
      (owner1, (a, owner1_allowances));
      (owner2, (b, owner2_allowances));
      (owner3, (c, owner3_allowances));
    ])
    in

    let token_info = (Map.empty: (string, bytes) map) in
    let token_metadata = Big_map.literal([ 
        (0n, { token_id   = 0n; token_info = token_info; })
    ])
    in
    let metadata = Big_map.literal([
        ("", Bytes.pack("tezos-storage:contents"));
        ("contents", ("54657374546F6B656E": bytes))
      ]) 
    in
    let asset = Asset_helper.originate(
        Asset_helper.base_storage(ledger, token_metadata, a + b + c, metadata)
    ) in
    asset, owners, ops