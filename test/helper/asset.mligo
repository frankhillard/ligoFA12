#import "../asset.instance.mligo" "Asset"

type taddr = (Asset.FA12_TOKEN.parameter, Asset.FA12_TOKEN.storage) typed_address
type contr = Asset.FA12_TOKEN.parameter contract
type originated = {
    addr: address;
    taddr: taddr;
    contr: contr;
}

(* Base storage *)
let base_storage (ledger, token_metadata, total_supply, metadata : Asset.FA12_TOKEN.FA12.Ledger.t * Asset.FA12_TOKEN.FA12.TokenMetadata.t * nat * Asset.FA12_TOKEN.FA12.Storage.Metadata.t) : Asset.FA12_TOKEN.storage = {
    ledger = ledger;
    token_metadata = token_metadata;
    total_supply = total_supply;
    metadata = metadata;
}

(* Originate a Asset contract with given init_storage storage *)
let originate (init_storage : Asset.FA12_TOKEN.storage) =
    let result = Test.originate (contract_of Asset.FA12_TOKEN) init_storage 0mutez in
    let contr = Test.to_contract result.addr in
    let addr = Tezos.address contr in
    {addr = addr; taddr = result.addr; contr = contr}

(* Verifies allowance amount for a given owner and spender *)
let assert_allowance
    (contract_address : (Asset.FA12_TOKEN.parameter, Asset.FA12_TOKEN.storage) typed_address )
    (owner : address)
    (spender : address)
    (expected_allowance : nat) =
    let storage = Test.get_storage contract_address in
    let ledger = storage.ledger in
    match (Big_map.find_opt owner ledger) with
    | Some amt_allow -> 
        let () = match (Map.find_opt spender amt_allow.1) with
        | Some v -> assert (v = expected_allowance)
        | None -> assert (expected_allowance = 0n)
        in
        () 
    | None -> failwith "incorret address"
    
(* Verifies balances of 3 accounts *)
let assert_balances
  (contract_address : ((Asset.FA12_TOKEN.parameter), Asset.FA12_TOKEN.storage) typed_address )
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
