module Authentication exposing (Authentication(..))

import Backend


type Authentication
    = Authenticated Backend.User
    | Authenticating
    | Unauthenticated
