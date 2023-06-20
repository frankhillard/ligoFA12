#import "./asset.instance.mligo" "Asset"
// #import "../lib/asset/fa12.mligo" "Asset"

type storage = Asset.storage

let get_initial_storage (a, b, c : nat * nat * nat) =
  let () = Test.reset_state 6n ([] : tez list) in

  let owner1 = Test.nth_bootstrap_account 0 in
  let owner2 = Test.nth_bootstrap_account 1 in
  let owner3 = Test.nth_bootstrap_account 2 in

  let owners = (owner1, owner2, owner3) in

  let op1 = Test.nth_bootstrap_account 3 in
  let op2 = Test.nth_bootstrap_account 4 in
  let op3 = Test.nth_bootstrap_account 5 in

  let ops = (op1, op2, op3) in

    let owner1_allowances = Map.literal ([ (op1, 1n); ]) in
    let owner2_allowances = Map.literal ([ (op1, 1n); (op2, 2n); ]) in
    let owner3_allowances = Map.literal ([ (op1, 1n); (op2, 2n); (op3, 3n); ]) in

  let ledger = Big_map.literal ([
      (owner1, (a, owner1_allowances));
      (owner2, (b, owner2_allowances));
      (owner3, (c, owner3_allowances));
    ])
  in

  let token_info = (Map.empty: (string, bytes) map) in
  let token_metadata = 
    { token_id   = 0n; token_info = token_info; }
  in

  let initial_storage = {
    //   metadata = Big_map.literal [
    //     ("", Bytes.pack("tezos-storage:contents"));
    //     ("contents", ("": bytes))
    //   ];
      ledger         = ledger;
      token_metadata = token_metadata;
      totalSupply = a + b + c;
  } in
  initial_storage, owners, ops

let assert_balances
  (contract_address : (Asset.parameter, storage) typed_address )
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
    let initial_storage, owners, operators = get_initial_storage (10n, 10n, 10n) in
    let (owner1, owner2, owner3) = owners in
    let (op1, op2, op3) = operators in
//   let owner1 = List_helper.nth_exn 0 owners in
//   let owner2 = List_helper.nth_exn 1 owners in
//   let owner3 = List_helper.nth_exn 2 owners in
//   let op1    = List_helper.nth_exn 0 operators in

    let transfer_1 = (owner1, (owner2, 2n)) in
    let transfer_2 = (owner1, (owner3, 3n)) in

    let transfer_3 = (owner2, (owner3, 2n)) in
    let transfer_4 = (owner2, (owner1, 3n)) in

//   let transfer_requests = ([
//     ({from_=owner1; txs=([{to_=owner2;token_id=0n;amount=2n};{to_=owner3;token_id=0n;amount=3n}] :
//     Asset.FA12.to_value)});
//     ({from_=owner2; txs=([{to_=owner3;token_id=0n;amount=2n};{to_=owner1;token_id=0n;amount=3n}] :
//     Asset.to_value)});
//   ] : Asset.FA12.transfer)
//   in
  let () = Test.set_source op1 in
  let (t_addr,_,_) = Test.originate Asset.main initial_storage 0tez in
  let contr = Test.to_contract t_addr in
  let _ = Test.transfer_to_contract_exn contr (Transfer transfer_1) 0tez in
  let _ = Test.transfer_to_contract_exn contr (Transfer transfer_2) 0tez in
  let _ = Test.transfer_to_contract_exn contr (Transfer transfer_3) 0tez in
  let _ = Test.transfer_to_contract_exn contr (Transfer transfer_4) 0tez in
  let () = assert_balances t_addr ((owner1, 8n), (owner2, 7n), (owner3, 15n)) in
  ()