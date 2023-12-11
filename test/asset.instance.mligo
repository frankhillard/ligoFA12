#import "../lib/asset/fa12.mligo" "FA12"

type storage = FA12.storage

type parameter = [@layout comb] 
| X of unit
| GetTotalSupply of FA12.getTotalSupply
| GetBalance of FA12.getBalance  
| GetAllowance of FA12.getAllowance 
| Approve of FA12.approve 
| Transfer of FA12.transfer


[@entry]
let transfer (p: FA12.transfer) (s: storage) : operation list * storage =
  FA12.transfer(p, s)

[@entry]
let approve (p: FA12.approve) (s: storage) : operation list * storage =
  FA12.approve(p, s)

[@entry]
let getAllowance (p: FA12.getAllowance) (s: storage) : operation list * storage =
  FA12.getAllowance(p, s)

[@entry]
let getBalance (p: FA12.getBalance) (s: storage) : operation list * storage =
  FA12.getBalance(p, s)

[@entry]
let getTotalSupply (p: FA12.getTotalSupply) (s: storage) : operation list * storage =
  FA12.getTotalSupply(p, s)

[@entry]
let x (_p: unit) (s: storage) : operation list * storage =
  [], s
