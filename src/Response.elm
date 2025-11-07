module Response exposing (Response(..))


type Response error value
    = Loading
    | Success value
    | Failure error
