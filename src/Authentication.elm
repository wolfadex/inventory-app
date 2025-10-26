module Authentication exposing (..)

import Backend


type Authentication
    = Authenticated Backend.User
    | Authenticating
    | Unauthenticated