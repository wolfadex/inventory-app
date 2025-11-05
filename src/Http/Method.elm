module Http.Method exposing (Method(..), fromString, toString)


type Method
    = Get
    | Head
    | Post
    | Put
    | Delete
    | Connect
    | Options
    | Trace
    | Patch


toString : Method -> String
toString method =
    case method of
        Get ->
            "GET"

        Head ->
            "HEAD"

        Post ->
            "POST"

        Put ->
            "PUT"

        Delete ->
            "DELETE"

        Connect ->
            "CONNECT"

        Options ->
            "OPTIONS"

        Trace ->
            "TRACE"

        Patch ->
            "PATCH"


fromString : String -> Maybe Method
fromString str =
    case str of
        "GET" ->
            Just Get

        "HEAD" ->
            Just Head

        "POST" ->
            Just Post

        "PUT" ->
            Just Put

        "DELETE" ->
            Just Delete

        "CONNECT" ->
            Just Connect

        "OPTIONS" ->
            Just Options

        "TRACE" ->
            Just Trace

        "PATCH" ->
            Just Patch

        _ ->
            Nothing
