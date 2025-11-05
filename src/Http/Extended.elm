module Http.Extended exposing
    ( Error(..)
    , Headers
    , Request
    , Response
    , errorCodec
    , requestDecode
    , responseEncode
    )

import Http.Method exposing (Method)
import Http.Status exposing (Status)
import Json.Decode
import Json.Encode
import Serialize


type Error
    = Field { name : String, message : String }
    | Generic String


errorCodec : Serialize.Codec Error
errorCodec =
    Serialize.customType
        (\fieldEncoder genericEncoder value ->
            case value of
                Field v ->
                    fieldEncoder v

                Generic v ->
                    genericEncoder v
        )
        |> Serialize.variant1 Field fieldErrorCodec
        |> Serialize.variant1 Generic Serialize.string
        |> Serialize.finishCustomType


fieldErrorCodec : Serialize.Codec { name : String, message : String }
fieldErrorCodec =
    Serialize.record (\name message -> { name = name, message = message })
        |> Serialize.field .name Serialize.string
        |> Serialize.field .message Serialize.string
        |> Serialize.finishRecord


type alias Headers =
    List ( String, String )


type alias Request =
    { path : String
    , method : Method
    , headers : Headers
    , body : String
    }


type alias Response =
    { status : Status
    , headers : Headers
    , body : String
    }


requestDecode : Json.Decode.Decoder Request
requestDecode =
    Json.Decode.map4 Request
        (Json.Decode.field "path" Json.Decode.string)
        (Json.Decode.field "method"
            (Json.Decode.string
                |> Json.Decode.andThen
                    (\methodStr ->
                        case Http.Method.fromString methodStr of
                            Just method ->
                                Json.Decode.succeed method

                            Nothing ->
                                Json.Decode.fail ("Unknown method: " ++ methodStr)
                    )
            )
        )
        (Json.Decode.field "headers"
            (Json.Decode.list
                (Json.Decode.list Json.Decode.string
                    |> Json.Decode.andThen
                        (\vals ->
                            case vals of
                                [ key, value ] ->
                                    Json.Decode.succeed ( key, value )

                                _ ->
                                    Json.Decode.fail "Invalid header"
                        )
                )
            )
        )
        (Json.Decode.field "body" Json.Decode.string)


responseEncode : Response -> Json.Encode.Value
responseEncode response =
    Json.Encode.object
        [ ( "status", Json.Encode.int <| Http.Status.toInt response.status )
        , ( "headers", Json.Encode.list (\( key, value ) -> Json.Encode.list Json.Encode.string [ key, value ]) response.headers )
        , ( "body", Json.Encode.string response.body )
        ]
