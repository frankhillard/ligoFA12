#import "../asset.instance.mligo" "Asset"

type taddr = (Asset.parameter, Asset.storage) typed_address
type contr = Asset.parameter contract
type originated = {
    addr: address;
    taddr: taddr;
    contr: contr;
}

(* Base storage *)
let base_storage (ledger, token_metadata, total_supply : Asset.FA12.Ledger.t * Asset.FA12.TokenMetadata.t * nat) : Asset.storage = {
    ledger = ledger;
    token_metadata = token_metadata;
    totalSupply = total_supply;
    //   metadata = Big_map.literal [
    //     ("", Bytes.pack("tezos-storage:contents"));
    //     ("contents", ("": bytes))
    //   ];
    //metadata = Big_map.literal([(("contents" : string), ("536563757265" : bytes))]);
}

(* Originate a Asset contract with given init_storage storage *)
let originate (init_storage : Asset.storage) =
    let (taddr, _, _) = Test.originate_uncurried Asset.main init_storage 0mutez in
    let contr = Test.to_contract taddr in
    let addr = Tezos.address contr in
    {addr = addr; taddr = taddr; contr = contr}