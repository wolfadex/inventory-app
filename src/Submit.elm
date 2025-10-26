module Submit exposing (..)

type Submit a e
    = Fresh
    | Submitting
    | Submitted a
    | Failed e