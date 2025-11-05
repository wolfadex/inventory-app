module Submit exposing (Submit(..))


type Submit a e
    = Fresh
    | Submitting
    | Failed e
