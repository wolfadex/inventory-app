module Backend.Transaction exposing (map)

{-| Helpers for working with transactions

@docs map

-}

import Acadia.Bytes.Decode as Decode
import Acadia.Bytes.Encode as Encode
import Acadia.Transaction exposing (Transaction)


{-| Convert a transaction with one value into another
-}
map : (a -> b) -> Transaction a -> Transaction b
map fn (Acadia.Transaction.Transaction encoder decoder) =
    Acadia.Transaction.Transaction
        encoder
        (Decode.map fn decoder)
