// module FA12 = struct

   #import "errors.mligo" "Errors"
   #import "allowance.mligo" "Allowance"
   #import "ledger.mligo" "Ledger"
   #import "token_metadata.mligo" "TokenMetadata"
   #import "storage.mligo" "Storage"

   type storage = Storage.t

   // /** transfer entrypoint */
   type transfer = (address * (address * nat))
   let transfer ((from_, to_value), s: transfer * storage) : operation list * storage =
      let (to_, value) = to_value in
      let ledger1 = Storage.get_ledger s in
      let ledger2 = Ledger.decrease_token_amount_for_user ledger1 (Tezos.get_sender ()) from_ value in
      let ledger = Ledger.increase_token_amount_for_user ledger2 to_ value in
      let s1 = Storage.set_ledger s ledger in
      (([] : operation list), s1)

   // /** approve */
   type approve = address * nat
   let approve ((spender,value), s : approve * storage) : operation list * storage =
      let ledger1 = Storage.get_ledger s in
      let ledger = Ledger.set_approval ledger1 (Tezos.get_sender ()) spender value in
      let s1 = Storage.set_ledger s ledger in
      (([] : operation list), s1)

   // /** getAllowance entrypoint */
   type getAllowance = ((address * address) * nat contract)
   let getAllowance ((owner_spender,callback), s: getAllowance * storage) : operation list * storage =
      let (owner,spender) = owner_spender in
      let a = Storage.get_allowances_for_owner s owner in
      let allowed_amount = Allowance.get_allowed_amount a spender in
      let operation = Tezos.transaction allowed_amount 0tez callback in
      ([operation], s)

   // /** getBalance entrypoint */
   type getBalance = address * nat contract 
   let getBalance ((owner,callback), s : getBalance * storage) : operation list * storage =
      let balance_ = Storage.get_amount_for_owner s owner in
      let operation = Tezos.transaction balance_ 0tez callback in
      ([operation], s)

   // /** getTotalSupply entrypoint */
   type getTotalSupply = (unit * nat contract)
   let getTotalSupply ((_,callback), s : getTotalSupply * storage) : operation list * storage =
      let operation = Tezos.transaction s.total_supply 0tez callback in
      ([operation], s)

   // type parameter = 
   // | Transfer of transfer 
   // | Approve of approve 
   // | GetAllowance of getAllowance 
   // | GetBalance of getBalance 
   // | GetTotalSupply of getTotalSupply


// end