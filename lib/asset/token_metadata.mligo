
//    /**
//       This should be initialized at origination, conforming to 
//       or TZIP-16 : https://gitlab.com/marigold/tzip/-/blob/master/proposals/tzip-16/tzip-16.md
//    */
type data = {
    token_id : nat;
    token_info : (string, bytes) map;
}

type t = data
