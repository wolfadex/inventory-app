module Response exposing (..)


type Response value
    = Loading
    | Success value
    | Failure String