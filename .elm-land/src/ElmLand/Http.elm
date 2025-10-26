-- 📦 Standard module for https://elm.land 🌈 --


module ElmLand.Http exposing
    ( Request, get, post, put, delete
    , Expect
    , expectString, expectJson, expectBytes
    , Response, expectStringResponse, expectBytesResponse
    , map, toCmd
    )

{-| A version of `elm/http` that allows you to represent an
HTTP request as a value. Useful when working with effects.

@docs Request, get, post, put, delete

@docs Expect
@docs expectString, expectJson, expectBytes

@docs Response, expectStringResponse, expectBytesResponse

@docs map, toCmd

-}

import Bytes exposing (Bytes)
import Bytes.Decode
import Http
import Json.Decode


type alias Request msg =
    { method : String
    , url : String
    , headers : List Http.Header
    , body : Http.Body
    , expect : Expect msg
    , timeout : Maybe Float
    , tracker : Maybe String
    }


get :
    { url : String
    , decoder : Json.Decode.Decoder value
    , onResponse : Result Http.Error value -> msg
    }
    -> Request msg
get props =
    { method = "GET"
    , url = props.url
    , headers = []
    , body = Http.emptyBody
    , expect = expectJson props.onResponse props.decoder
    , timeout = Nothing
    , tracker = Nothing
    }


post :
    { url : String
    , body : Json.Decode.Value
    , decoder : Json.Decode.Decoder value
    , onResponse : Result Http.Error value -> msg
    }
    -> Request msg
post props =
    { method = "POST"
    , url = props.url
    , headers = []
    , body = Http.jsonBody props.body
    , expect = expectJson props.onResponse props.decoder
    , timeout = Nothing
    , tracker = Nothing
    }


put :
    { url : String
    , body : Json.Decode.Value
    , decoder : Json.Decode.Decoder value
    , onResponse : Result Http.Error value -> msg
    }
    -> Request msg
put props =
    { method = "PUT"
    , url = props.url
    , headers = []
    , body = Http.jsonBody props.body
    , expect = expectJson props.onResponse props.decoder
    , timeout = Nothing
    , tracker = Nothing
    }


delete :
    { url : String
    , decoder : Json.Decode.Decoder value
    , onResponse : Result Http.Error value -> msg
    }
    -> Request msg
delete props =
    { method = "DELETE"
    , url = props.url
    , headers = []
    , body = Http.emptyBody
    , expect = expectJson props.onResponse props.decoder
    , timeout = Nothing
    , tracker = Nothing
    }


map : (msg1 -> msg2) -> Request msg1 -> Request msg2
map fn req =
    { method = req.method
    , url = req.url
    , headers = req.headers
    , body = req.body
    , expect = mapExpect fn req.expect
    , timeout = req.timeout
    , tracker = req.tracker
    }


toCmd : Request msg -> Cmd msg
toCmd req =
    Http.request
        { method = req.method
        , url = req.url
        , headers = req.headers
        , body = req.body
        , expect = toHttpExpect req.expect
        , timeout = req.timeout
        , tracker = req.tracker
        }



-- EXPECT


type alias Response body =
    Http.Response body


expectBytesResponse : (Result error value -> msg) -> (Response Bytes -> Result error value) -> Expect msg
expectBytesResponse toMsg toResult =
    ExpectBytesResponse (toMsg << toResult)


expectStringResponse : (Result error value -> msg) -> (Response String -> Result error value) -> Expect msg
expectStringResponse toMsg toResult =
    ExpectStringResponse (toMsg << toResult)


type Expect msg
    = ExpectWhatever (Result Http.Error () -> msg)
    | ExpectBytesResponse (Response Bytes -> msg)
    | ExpectStringResponse (Response String -> msg)


expectWhatever : (Result Http.Error () -> msg) -> Expect msg
expectWhatever toMsg =
    ExpectWhatever toMsg


expectString : (Result Http.Error String -> msg) -> Expect msg
expectString toMsg =
    ExpectStringResponse (toHttpResult >> toMsg)


expectJson : (Result Http.Error value -> msg) -> Json.Decode.Decoder value -> Expect msg
expectJson toMsg decoder =
    ExpectStringResponse
        (toHttpResult
            >> Result.andThen
                (Json.Decode.decodeString decoder
                    >> Result.mapError (Json.Decode.errorToString >> Http.BadBody)
                )
            >> toMsg
        )


expectBytes : (Result Http.Error value -> msg) -> Bytes.Decode.Decoder value -> Expect msg
expectBytes toMsg decoder =
    ExpectBytesResponse
        (toHttpResult
            >> Result.andThen
                (Bytes.Decode.decode decoder
                    >> Result.fromMaybe "Unexpected bytes"
                    >> Result.mapError Http.BadBody
                )
            >> toMsg
        )


mapExpect : (msg1 -> msg2) -> Expect msg1 -> Expect msg2
mapExpect fn expect =
    case expect of
        ExpectWhatever toMsg ->
            ExpectWhatever (toMsg >> fn)

        ExpectBytesResponse toMsg ->
            ExpectBytesResponse (toMsg >> fn)

        ExpectStringResponse toMsg ->
            ExpectStringResponse (toMsg >> fn)


toHttpExpect : Expect msg -> Http.Expect msg
toHttpExpect expect =
    case expect of
        ExpectWhatever toMsg ->
            Http.expectWhatever toMsg

        ExpectBytesResponse toMsg ->
            Http.expectBytesResponse
                (\res ->
                    case res of
                        Ok response ->
                            toMsg response

                        Err response ->
                            toMsg response
                )
                Ok

        ExpectStringResponse toMsg ->
            Http.expectStringResponse
                (\res ->
                    case res of
                        Ok response ->
                            toMsg response

                        Err response ->
                            toMsg response
                )
                Ok


toHttpResult : Response body -> Result Http.Error body
toHttpResult response =
    case response of
        Http.BadUrl_ url ->
            Err (Http.BadUrl url)

        Http.Timeout_ ->
            Err Http.Timeout

        Http.NetworkError_ ->
            Err Http.NetworkError

        Http.BadStatus_ meta _ ->
            Err (Http.BadStatus meta.statusCode)

        Http.GoodStatus_ meta body ->
            Ok body
