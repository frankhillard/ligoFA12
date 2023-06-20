#import "../lib/asset/fa12.mligo" "FA12"

type storage = FA12.storage

type parameter = //[@layout:comb] 
| Transfer of FA12.transfer 
| Approve of FA12.approve 
| GetAllowance of FA12.getAllowance 
| GetBalance of FA12.getBalance 
| GetTotalSupply of FA12.getTotalSupply

let main ((p,s): (parameter * storage)) : operation list * storage =
    match p with
      Transfer (pp : FA12.transfer) -> FA12.transfer( (pp.0, pp.1), s)
    | Approve p-> FA12.approve(p, s)
    | GetAllowance p-> FA12.getAllowance(p, s)
    | GetBalance p-> FA12.getBalance(p, s)
    | GetTotalSupply p-> FA12.getTotalSupply(p, s)
