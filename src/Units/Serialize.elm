module Units.Serialize exposing (..)

import Quantity exposing (Qauntity(..))
import Serialize


quantity : Serialize.Codec (Quantity Float units)
quantity =
    Serialize.customType (\enc (Quantity value) -> enc value)
        |> Serialize.variant1 Quantity Serialize.float
        |> Serialize.finishCustomType
