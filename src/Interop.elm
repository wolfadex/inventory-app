port module Interop exposing
    ( Flags, decoder
    , reportUnexpectedFlags
    , onDocumentPointerDown
    )

{-|

@docs Flags, decoder

@docs reportUnexpectedFlags
@docs onDocumentPointerDown

-}

import Json.Decode as Json



-- FLAGS


{-| Initial JSON data passed in from `assets/elm-land.ts` into
the `Shared.init` function
-}
type alias Flags =
    { windowWidth : Float
    }


{-| How to safely convert the raw JSON into flags
-}
decoder : Json.Decoder Flags
decoder =
    Json.map Flags
        (Json.field "windowWidth" Json.float)



-- OUTGOING PORTS (Elm to JS)


{-| Scroll to the section with the given ID
-}
port reportUnexpectedFlags : { error : String } -> Cmd msg



-- INCOMING PORTS (JS to Elm)


{-| Sent from JS on document pointer down occurs
-}
port onDocumentPointerDown : (Json.Value -> msg) -> Sub msg
