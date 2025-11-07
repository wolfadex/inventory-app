module Serialize exposing
    ( Codec
    , decodeFromBytes, encodeToBytes
    , decodeFromString, encodeToString, encodeSimple
    , toBytesDecoder, toBytesEncoder
    , int
    , int8, int16, int32, int64
    , uint8, uint16, uint32, uint64
    , float
    , float32, float64
    , bool, string
    , list, array, set, dict
    , byte, bytes
    , time
    , uuid
    , enum
    , tuple
    , unit
    , customType
    , variant0, variant1, variant2, variant3, variant4, variant5, variant6, variant7, variant8
    , finishCustomType
    , CustomTypeCodec, VariantEncoder
    , record, field, finishRecord
    , RecordCodec
    , maybe, result
    , map
    , lazy
    )

{-|

@docs Codec

@docs decodeFromBytes, encodeToBytes
@docs decodeFromString, encodeToString, encodeSimple
@docs toBytesDecoder, toBytesEncoder

@docs int
@docs int8, int16, int32, int64
@docs uint8, uint16, uint32, uint64
@docs float
@docs float32, float64
@docs bool, string
@docs list, array, set, dict
@docs byte, bytes

@docs time
@docs uuid

@docs enum
@docs tuple
@docs unit

@docs customType
@docs variant0, variant1, variant2, variant3, variant4, variant5, variant6, variant7, variant8
@docs finishCustomType
@docs CustomTypeCodec, VariantEncoder

@docs record, field, finishRecord
@docs RecordCodec

@docs maybe, result

@docs map
@docs lazy

-}

import Acadia.Float32
import Acadia.Float64
import Acadia.Int16
import Acadia.Int32
import Acadia.Int64
import Acadia.Int8
import Acadia.Time
import Acadia.UInt16
import Acadia.UInt32
import Acadia.UInt64
import Acadia.UInt8
import Acadia.Uuid
import Array exposing (Array)
import Base64
import Bytes
import Bytes.Decode as BD
import Bytes.Encode as BE
import Dict exposing (Dict)
import Json.Decode as JD
import Json.Encode as JE
import Regex exposing (Regex)
import Set exposing (Set)
import Toop exposing (T4(..), T5(..), T6(..), T7(..), T8(..))



-- DEFINITION


{-| A value that knows how to encode and decode an Elm data structure.
-}
type Codec a
    = Codec
        { encoder : a -> BE.Encoder
        , decoder : BD.Decoder a
        }



-- DECODE


endian : Bytes.Endianness
endian =
    Bytes.BE


{-| Extracts the `Decoder` contained inside the `Codec`.
-}
toBytesDecoder : Codec a -> BD.Decoder a
toBytesDecoder (Codec m) =
    m.decoder


decodeFromString : Codec a -> String -> Maybe a
decodeFromString codec base64 =
    case decode base64 of
        Just bytes_ ->
            decodeFromBytes codec bytes_

        Nothing ->
            Nothing


{-| Convert an Elm value into a string. This string contains only url safe characters, so you can do the following:

    import Serialize as S

    myUrl =
        "www.mywebsite.com/?data=" ++ S.encodeToString S.float 1234

and not risk generating an invalid url.

-}
encodeToString : Codec a -> a -> String
encodeToString codec =
    encodeToBytes codec >> replaceBase64Chars


{-| Run a `Codec` to turn a sequence of bytes into an Elm value.
-}
decodeFromBytes : Codec a -> Bytes.Bytes -> Maybe a
decodeFromBytes codec bytes_ =
    let
        decoder =
            toBytesDecoder codec
    in
    BD.decode decoder bytes_


decode : String -> Maybe Bytes.Bytes
decode base64text =
    let
        replaceChar rematch =
            case rematch.match of
                "-" ->
                    "+"

                _ ->
                    "/"

        strlen =
            String.length base64text
    in
    if strlen == 0 then
        BE.encode (BE.sequence []) |> Just

    else
        let
            hanging =
                modBy 4 strlen

            ilen =
                if hanging == 0 then
                    0

                else
                    4 - hanging
        in
        Regex.replace replaceFromUrl replaceChar (base64text ++ String.repeat ilen "=")
            |> Base64.toBytes


replaceFromUrl : Regex
replaceFromUrl =
    Regex.fromString "[-_]" |> Maybe.withDefault Regex.never



-- ENCODE


{-| Extracts the encoding function contained inside the `Codec`.
-}
toBytesEncoder : Codec a -> a -> BE.Encoder
toBytesEncoder (Codec m) =
    m.encoder


encodeSimple : BE.Encoder -> Bytes.Bytes
encodeSimple encoder =
    BE.sequence
        [ -- BE.unsignedInt8 version
          -- ,
          encoder
        ]
        |> BE.encode


{-| Convert an Elm value into a sequence of bytes.
-}
encodeToBytes : Codec a -> a -> Bytes.Bytes
encodeToBytes codec value =
    BE.sequence
        [ -- BE.unsignedInt8 version
          -- ,
          value |> toBytesEncoder codec
        ]
        |> BE.encode


replaceBase64Chars : Bytes.Bytes -> String
replaceBase64Chars =
    let
        replaceChar rematch =
            case rematch.match of
                "+" ->
                    "-"

                "/" ->
                    "_"

                _ ->
                    ""
    in
    Base64.fromBytes >> Maybe.withDefault "" >> Regex.replace replaceForUrl replaceChar


replaceForUrl : Regex
replaceForUrl =
    Regex.fromString "[\\+/=]" |> Maybe.withDefault Regex.never



-- BASE


build : (a -> BE.Encoder) -> BD.Decoder a -> Codec a
build encoder_ decoder_ =
    Codec
        { encoder = encoder_
        , decoder = decoder_
        }


{-| Codec for serializing a `String`
-}
string : Codec String
string =
    build
        (\text ->
            BE.sequence
                [ BE.unsignedInt32 endian (BE.getStringWidth text)
                , BE.string text
                ]
        )
        (BD.unsignedInt32 endian
            |> BD.andThen BD.string
        )


{-| Codec for serializing a `Bool`
-}
bool : Codec Bool
bool =
    build
        (\value ->
            if value then
                BE.unsignedInt8 1

            else
                BE.unsignedInt8 0
        )
        (BD.unsignedInt8
            |> BD.andThen
                (\value ->
                    case value of
                        0 ->
                            BD.succeed False

                        1 ->
                            BD.succeed True

                        _ ->
                            BD.fail
                )
        )


int : Codec Int
int =
    build
        (toFloat >> BE.float64 endian)
        (BD.float64 endian |> BD.map round)


int8 : Codec Acadia.Int8.Int8
int8 =
    build
        Acadia.Int8.encode
        Acadia.Int8.decode


int16 : Codec Acadia.Int16.Int16
int16 =
    build
        Acadia.Int16.encodeBE
        Acadia.Int16.decodeBE


int32 : Codec Acadia.Int32.Int32
int32 =
    build
        Acadia.Int32.encodeBE
        Acadia.Int32.decodeBE


int64 : Codec Acadia.Int64.Int64
int64 =
    build
        Acadia.Int64.encodeBE
        Acadia.Int64.decodeBE


uint8 : Codec Acadia.UInt8.UInt8
uint8 =
    build
        Acadia.UInt8.encode
        Acadia.UInt8.decode


uint16 : Codec Acadia.UInt16.UInt16
uint16 =
    build
        Acadia.UInt16.encodeBE
        Acadia.UInt16.decodeBE


uint32 : Codec Acadia.UInt32.UInt32
uint32 =
    build
        Acadia.UInt32.encodeBE
        Acadia.UInt32.decodeBE


uint64 : Codec Acadia.UInt64.UInt64
uint64 =
    build
        Acadia.UInt64.encodeBE
        Acadia.UInt64.decodeBE


float : Codec Float
float =
    build
        (BE.float64 endian)
        (BD.float64 endian)


float32 : Codec Acadia.Float32.Float32
float32 =
    build
        Acadia.Float32.encodeBE
        Acadia.Float32.decodeBE


float64 : Codec Acadia.Float64.Float64
float64 =
    build
        Acadia.Float64.encodeBE
        Acadia.Float64.decodeBE


time : Codec Acadia.Time.Posix
time =
    build
        Acadia.Time.encodeBE
        Acadia.Time.decodeBE


uuid : Codec Acadia.Uuid.Uuid
uuid =
    build
        Acadia.Uuid.encode
        Acadia.Uuid.decode


{-| Codec for serializing a `Char`
-}
char : Codec Char
char =
    let
        charEncode text =
            BE.sequence
                [ BE.unsignedInt32 endian (String.length text)
                , BE.string text
                ]
    in
    build
        (String.fromChar >> charEncode)
        (BD.unsignedInt32 endian
            |> BD.andThen BD.string
            |> BD.andThen
                (\text ->
                    case String.uncons text of
                        Just ( char_, _ ) ->
                            BD.succeed char_

                        Nothing ->
                            BD.fail
                )
        )



-- DATA STRUCTURES


{-| Codec for serializing a `Maybe`

    import Serialize as S

    maybeIntCodec : S.Codec (Maybe Int)
    maybeIntCodec =
        S.maybe S.int

-}
maybe : Codec a -> Codec (Maybe a)
maybe justCodec =
    customType
        (\nothingEncoder justEncoder value ->
            case value of
                Nothing ->
                    nothingEncoder

                Just value_ ->
                    justEncoder value_
        )
        |> variant0 Nothing
        |> variant1 Just justCodec
        |> finishCustomType


{-| Codec for serializing a `List`

    import Serialize as S

    listOfStringsCodec : S.Codec (List String)
    listOfStringsCodec =
        S.list S.string

-}
list : Codec a -> Codec (List a)
list codec =
    build
        (listEncode (toBytesEncoder codec))
        (BD.unsignedInt32 endian
            |> BD.andThen
                (\length ->
                    BD.loop ( length, [] )
                        (listStep (toBytesDecoder codec))
                )
        )


listEncode : (a -> BE.Encoder) -> List a -> BE.Encoder
listEncode encoder_ list_ =
    list_
        |> List.map encoder_
        |> (::) (BE.unsignedInt32 endian (List.length list_))
        |> BE.sequence


listStep : BD.Decoder a -> ( Int, List a ) -> BD.Decoder (BD.Step ( Int, List a ) (List a))
listStep decoder_ ( n, xs ) =
    if n <= 0 then
        BD.succeed (BD.Done (List.reverse xs))

    else
        BD.map
            (\x ->
                BD.Loop ( n - 1, x :: xs )
            )
            decoder_


{-| Codec for serializing an `Array`
-}
array : Codec a -> Codec (Array a)
array codec =
    list codec |> map Array.fromList Array.toList


{-| Codec for serializing a `Dict`

    import Serialize as S

    type alias Name =
        String

    peoplesAgeCodec : S.Codec (Dict Name Int)
    peoplesAgeCodec =
        S.dict S.string S.int

-}
dict : Codec comparable -> Codec a -> Codec (Dict comparable a)
dict keyCodec valueCodec =
    list (tuple keyCodec valueCodec)
        |> map Dict.fromList Dict.toList


{-| Codec for serializing a `Set`
-}
set : Codec comparable -> Codec (Set comparable)
set codec =
    list codec |> map Set.fromList Set.toList


{-| Codec for serializing `()` (aka `Unit`).
-}
unit : Codec ()
unit =
    build
        (always (BE.sequence []))
        (BD.succeed ())


{-| Codec for serializing a tuple with 2 elements

    import Serialize as S

    pointCodec : S.Codec ( Float, Float )
    pointCodec =
        S.tuple S.float S.float

-}
tuple : Codec a -> Codec b -> Codec ( a, b )
tuple codecFirst codecSecond =
    record Tuple.pair
        |> field Tuple.first codecFirst
        |> field Tuple.second codecSecond
        |> finishRecord


{-| Codec for serializing a `Result`
-}
result : Codec error -> Codec value -> Codec (Result error value)
result errorCodec valueCodec =
    customType
        (\errEncoder okEncoder value ->
            case value of
                Err err ->
                    errEncoder err

                Ok ok ->
                    okEncoder ok
        )
        |> variant1 Err errorCodec
        |> variant1 Ok valueCodec
        |> finishCustomType


{-| Codec for serializing [`Bytes`](https://package.elm-lang.org/packages/elm/bytes/latest/).
This is useful in combination with `mapValid` for encoding and decoding data using some specialized format.

    import Image exposing (Image)
    import Serialize as S

    imageCodec : S.Codec String Image
    imageCodec =
        S.bytes
            |> S.mapValid
                (Image.decode >> Result.fromMaybe "Failed to decode PNG image.")
                Image.toPng

-}
bytes : Codec Bytes.Bytes
bytes =
    build
        (\bytes_ ->
            BE.sequence
                [ BE.unsignedInt32 endian (Bytes.width bytes_)
                , BE.bytes bytes_
                ]
        )
        (BD.unsignedInt32 endian
            |> BD.andThen BD.bytes
        )


{-| Codec for serializing an integer ranging from 0 to 255.
This is useful if you have a small integer you want to serialize and not use up a lot of space.

    import Serialize as S

    type alias Color =
        { red : Int
        , green : Int
        , blue : Int
        }

    color : S.Codec Color
    color =
        Color.record Color
            |> S.field .red byte
            |> S.field .green byte
            |> S.field .blue byte
            |> S.finishRecord

**Warning:** values greater than 255 or less than 0 will wrap around.
So if you encode -1 you'll get back 255 and if you encode 257 you'll get back 1.

-}
byte : Codec Int
byte =
    build
        BE.unsignedInt8
        BD.unsignedInt8


{-| A codec for serializing an item from a list of possible items.
If you try to encode an item that isn't in the list then the first item is defaulted to.

    import Serialize as S

    type DaysOfWeek
        = Monday
        | Tuesday
        | Wednesday
        | Thursday
        | Friday
        | Saturday
        | Sunday

    daysOfWeekCodec : S.Codec DaysOfWeek
    daysOfWeekCodec =
        S.enum Monday [ Tuesday, Wednesday, Thursday, Friday, Saturday, Sunday ]

Note that inserting new items in the middle of the list or removing items is a breaking change.
It's safe to add items to the end of the list though.

-}
enum : a -> List a -> Codec a
enum defaultItem items =
    let
        getIndex value =
            items
                |> findIndex ((==) value)
                |> Maybe.withDefault -1
                |> (+) 1

        getItem index =
            if index < 0 then
                Nothing

            else if index > List.length items then
                Nothing

            else
                getAt (index - 1) items |> Maybe.withDefault defaultItem |> Just
    in
    build
        (getIndex >> BE.unsignedInt32 endian)
        (BD.unsignedInt32 endian
            |> BD.andThen
                (\index ->
                    case getItem index of
                        Nothing ->
                            BD.fail

                        Just a ->
                            BD.succeed a
                )
        )


getAt : Int -> List a -> Maybe a
getAt idx xs =
    if idx < 0 then
        Nothing

    else
        List.head <| List.drop idx xs


{-| <https://github.com/elm-community/list-extra/blob/f9faf1cfa1cec24f977313b1b63e2a1064c36eed/src/List/Extra.elm#L620>
-}
findIndex : (a -> Bool) -> List a -> Maybe Int
findIndex =
    findIndexHelp 0


{-| <https://github.com/elm-community/list-extra/blob/f9faf1cfa1cec24f977313b1b63e2a1064c36eed/src/List/Extra.elm#L625>
-}
findIndexHelp : Int -> (a -> Bool) -> List a -> Maybe Int
findIndexHelp index predicate list_ =
    case list_ of
        [] ->
            Nothing

        x :: xs ->
            if predicate x then
                Just index

            else
                findIndexHelp (index + 1) predicate xs



-- OBJECTS


{-| A partially built Codec for a record.
-}
type RecordCodec a b
    = RecordCodec
        { encoder : a -> List BE.Encoder
        , decoder : BD.Decoder b
        }


{-| Start creating a codec for a record.

    import Serialize as S

    type alias Point =
        { x : Int
        , y : Int
        }

    pointCodec : S.Codec Point
    pointCodec =
        S.record Point
            -- Note that adding, removing, or reordering fields will prevent you from decoding any data you've previously encoded.
            |> S.field .x S.int
            |> S.field .y S.int
            |> S.finishRecord

-}
record : b -> RecordCodec a b
record ctor =
    RecordCodec
        { encoder = \_ -> []
        , decoder = BD.succeed ctor
        }


{-| Add a field to the record we are creating a codec for.
-}
field : (a -> f) -> Codec f -> RecordCodec a (f -> b) -> RecordCodec a b
field getter codec (RecordCodec recordCodec) =
    RecordCodec
        { encoder = \v -> (toBytesEncoder codec <| getter v) :: recordCodec.encoder v
        , decoder =
            BD.map2 (\cons fieldVal -> cons fieldVal)
                recordCodec.decoder
                (toBytesDecoder codec)
        }


{-| Finish creating a codec for a record.
-}
finishRecord : RecordCodec a a -> Codec a
finishRecord (RecordCodec codec) =
    Codec
        { encoder =
            codec.encoder
                >> List.reverse
                >> BE.sequence
        , decoder = codec.decoder
        }



-- CUSTOM


{-| A partially built codec for a custom type.
-}
type CustomTypeCodec a match v
    = CustomTypeCodec
        { match : match
        , decoder : Int -> BD.Decoder v -> BD.Decoder v
        , idCounter : Int
        }


{-| Starts building a `Codec` for a custom type.
You need to pass a pattern matching function, see the FAQ for details.

    import Serialize as S

    type Semaphore
        = Red Int String Bool
        | Yellow Float
        | Green

    semaphoreCodec : S.Codec Semaphore
    semaphoreCodec =
        S.customType
            (\redEncoder yellowEncoder greenEncoder value ->
                case value of
                    Red i s b ->
                        redEncoder i s b

                    Yellow f ->
                        yellowEncoder f

                    Green ->
                        greenEncoder
            )
            -- Note that removing a variant, inserting a variant before an existing one, or swapping two variants will prevent you from decoding any data you've previously encoded.
            |> S.variant3 Red S.int S.string S.bool
            |> S.variant1 Yellow S.float
            |> S.variant0 Green
            -- It's safe to add new variants here later though
            |> S.finishCustomType

-}
customType : match -> CustomTypeCodec { youNeedAtLeastOneVariant : () } match value
customType match =
    CustomTypeCodec
        { match = match
        , decoder = \_ -> identity
        , idCounter = 0
        }


{-| -}
type VariantEncoder
    = VariantEncoder ( BE.Encoder, JE.Value )


variant :
    ((List BE.Encoder -> VariantEncoder) -> a)
    -> BD.Decoder v
    -> CustomTypeCodec z (a -> b) v
    -> CustomTypeCodec () b v
variant matchPiece decoderPiece (CustomTypeCodec am) =
    let
        enc : List BE.Encoder -> VariantEncoder
        enc v =
            ( BE.unsignedInt16 endian am.idCounter :: v |> BE.sequence
            , JE.null
            )
                |> VariantEncoder

        decoder_ : Int -> BD.Decoder v -> BD.Decoder v
        decoder_ tag orElse =
            if tag == am.idCounter then
                decoderPiece

            else
                am.decoder tag orElse
    in
    CustomTypeCodec
        { match = am.match <| matchPiece enc
        , decoder = decoder_
        , idCounter = am.idCounter + 1
        }


{-| Define a variant with 0 parameters for a custom type.
-}
variant0 : v -> CustomTypeCodec z (VariantEncoder -> a) v -> CustomTypeCodec () a v
variant0 ctor =
    variant
        (\c -> c [])
        (BD.succeed ctor)


{-| Define a variant with 1 parameters for a custom type.
-}
variant1 :
    (a -> v)
    -> Codec a
    -> CustomTypeCodec z ((a -> VariantEncoder) -> b) v
    -> CustomTypeCodec () b v
variant1 ctor m1 =
    variant
        (\c v ->
            c
                [ toBytesEncoder m1 v
                ]
        )
        (BD.map ctor (toBytesDecoder m1))


{-| Define a variant with 2 parameters for a custom type.
-}
variant2 :
    (a -> b -> v)
    -> Codec a
    -> Codec b
    -> CustomTypeCodec z ((a -> b -> VariantEncoder) -> c) v
    -> CustomTypeCodec () c v
variant2 ctor m1 m2 =
    variant
        (\c v1 v2 ->
            [ toBytesEncoder m1 v1
            , toBytesEncoder m2 v2
            ]
                |> c
        )
        (BD.map2 ctor
            (toBytesDecoder m1)
            (toBytesDecoder m2)
        )


{-| Define a variant with 3 parameters for a custom type.
-}
variant3 :
    (a -> b -> c -> v)
    -> Codec a
    -> Codec b
    -> Codec c
    -> CustomTypeCodec z ((a -> b -> c -> VariantEncoder) -> partial) v
    -> CustomTypeCodec () partial v
variant3 ctor m1 m2 m3 =
    variant
        (\c v1 v2 v3 ->
            [ toBytesEncoder m1 v1
            , toBytesEncoder m2 v2
            , toBytesEncoder m3 v3
            ]
                |> c
        )
        (BD.map3 ctor
            (toBytesDecoder m1)
            (toBytesDecoder m2)
            (toBytesDecoder m3)
        )


{-| Define a variant with 4 parameters for a custom type.
-}
variant4 :
    (a -> b -> c -> d -> v)
    -> Codec a
    -> Codec b
    -> Codec c
    -> Codec d
    -> CustomTypeCodec z ((a -> b -> c -> d -> VariantEncoder) -> partial) v
    -> CustomTypeCodec () partial v
variant4 ctor m1 m2 m3 m4 =
    variant
        (\c v1 v2 v3 v4 ->
            [ toBytesEncoder m1 v1
            , toBytesEncoder m2 v2
            , toBytesEncoder m3 v3
            , toBytesEncoder m4 v4
            ]
                |> c
        )
        (BD.map4 ctor
            (toBytesDecoder m1)
            (toBytesDecoder m2)
            (toBytesDecoder m3)
            (toBytesDecoder m4)
        )


{-| Define a variant with 5 parameters for a custom type.
-}
variant5 :
    (a -> b -> c -> d -> e -> v)
    -> Codec a
    -> Codec b
    -> Codec c
    -> Codec d
    -> Codec e
    -> CustomTypeCodec z ((a -> b -> c -> d -> e -> VariantEncoder) -> partial) v
    -> CustomTypeCodec () partial v
variant5 ctor m1 m2 m3 m4 m5 =
    variant
        (\c v1 v2 v3 v4 v5 ->
            [ toBytesEncoder m1 v1
            , toBytesEncoder m2 v2
            , toBytesEncoder m3 v3
            , toBytesEncoder m4 v4
            , toBytesEncoder m5 v5
            ]
                |> c
        )
        (BD.map5 ctor
            (toBytesDecoder m1)
            (toBytesDecoder m2)
            (toBytesDecoder m3)
            (toBytesDecoder m4)
            (toBytesDecoder m5)
        )


{-| Define a variant with 6 parameters for a custom type.
-}
variant6 :
    (a -> b -> c -> d -> e -> f -> v)
    -> Codec a
    -> Codec b
    -> Codec c
    -> Codec d
    -> Codec e
    -> Codec f
    -> CustomTypeCodec z ((a -> b -> c -> d -> e -> f -> VariantEncoder) -> partial) v
    -> CustomTypeCodec () partial v
variant6 ctor m1 m2 m3 m4 m5 m6 =
    variant
        (\c v1 v2 v3 v4 v5 v6 ->
            [ toBytesEncoder m1 v1
            , toBytesEncoder m2 v2
            , toBytesEncoder m3 v3
            , toBytesEncoder m4 v4
            , toBytesEncoder m5 v5
            , toBytesEncoder m6 v6
            ]
                |> c
        )
        (BD.map5
            (\a b c d ( e, f ) -> ctor a b c d e f)
            (toBytesDecoder m1)
            (toBytesDecoder m2)
            (toBytesDecoder m3)
            (toBytesDecoder m4)
            (BD.map2 Tuple.pair
                (toBytesDecoder m5)
                (toBytesDecoder m6)
            )
        )


{-| Define a variant with 7 parameters for a custom type.
-}
variant7 :
    (a -> b -> c -> d -> e -> f -> g -> v)
    -> Codec a
    -> Codec b
    -> Codec c
    -> Codec d
    -> Codec e
    -> Codec f
    -> Codec g
    -> CustomTypeCodec z ((a -> b -> c -> d -> e -> f -> g -> VariantEncoder) -> partial) v
    -> CustomTypeCodec () partial v
variant7 ctor m1 m2 m3 m4 m5 m6 m7 =
    variant
        (\c v1 v2 v3 v4 v5 v6 v7 ->
            [ toBytesEncoder m1 v1
            , toBytesEncoder m2 v2
            , toBytesEncoder m3 v3
            , toBytesEncoder m4 v4
            , toBytesEncoder m5 v5
            , toBytesEncoder m6 v6
            , toBytesEncoder m7 v7
            ]
                |> c
        )
        (BD.map5
            (\a b c ( d, e ) ( f, g ) -> ctor a b c d e f g)
            (toBytesDecoder m1)
            (toBytesDecoder m2)
            (toBytesDecoder m3)
            (BD.map2 Tuple.pair
                (toBytesDecoder m4)
                (toBytesDecoder m5)
            )
            (BD.map2 Tuple.pair
                (toBytesDecoder m6)
                (toBytesDecoder m7)
            )
        )


{-| Define a variant with 8 parameters for a custom type.
-}
variant8 :
    (a -> b -> c -> d -> e -> f -> g -> h -> v)
    -> Codec a
    -> Codec b
    -> Codec c
    -> Codec d
    -> Codec e
    -> Codec f
    -> Codec g
    -> Codec h
    -> CustomTypeCodec z ((a -> b -> c -> d -> e -> f -> g -> h -> VariantEncoder) -> partial) v
    -> CustomTypeCodec () partial v
variant8 ctor m1 m2 m3 m4 m5 m6 m7 m8 =
    variant
        (\c v1 v2 v3 v4 v5 v6 v7 v8 ->
            [ toBytesEncoder m1 v1
            , toBytesEncoder m2 v2
            , toBytesEncoder m3 v3
            , toBytesEncoder m4 v4
            , toBytesEncoder m5 v5
            , toBytesEncoder m6 v6
            , toBytesEncoder m7 v7
            , toBytesEncoder m8 v8
            ]
                |> c
        )
        (BD.map5
            (\a b ( c, d ) ( e, f ) ( g, h ) -> ctor a b c d e f g h)
            (toBytesDecoder m1)
            (toBytesDecoder m2)
            (BD.map2 Tuple.pair
                (toBytesDecoder m3)
                (toBytesDecoder m4)
            )
            (BD.map2 Tuple.pair
                (toBytesDecoder m5)
                (toBytesDecoder m6)
            )
            (BD.map2 Tuple.pair
                (toBytesDecoder m7)
                (toBytesDecoder m8)
            )
        )


{-| Finish creating a codec for a custom type.
-}
finishCustomType : CustomTypeCodec () (a -> VariantEncoder) a -> Codec a
finishCustomType (CustomTypeCodec am) =
    build
        (am.match >> (\(VariantEncoder ( a, _ )) -> a))
        (BD.unsignedInt16 endian
            |> BD.andThen
                (\tag ->
                    am.decoder tag BD.fail
                )
        )



---- MAPPING


{-| Map from one codec to another codec

    import Serialize as S

    type UserId
        = UserId Int

    userIdCodec : S.Codec e UserId
    userIdCodec =
        S.int |> S.map UserId (\(UserId id) -> id)

Note that there's nothing preventing you from encoding Elm values that will map to some different value when you decode them.
I recommend writing tests for Codecs that use `map` to make sure you get back the same Elm value you put in.
[Here's some helper functions to get you started.](https://github.com/MartinSStewart/elm-geometry-serialize/blob/6f2244c28631ede1b864cb43541d1573dc628904/tests/Tests.elm#L49-L74)

-}
map : (a -> b) -> (b -> a) -> Codec a -> Codec b
map fromBytes_ toBytes_ codec =
    build
        (\v -> toBytes_ v |> toBytesEncoder codec)
        (toBytesDecoder codec |> BD.map fromBytes_)



-- STACK UNSAFE


{-| Handle situations where you need to define a codec in terms of itself.

    import Serialize as S

    type Peano
        = Peano (Maybe Peano)

    {-| The compiler will complain that this function causes an infinite loop.
    -}
    badPeanoCodec : S.Codec e Peano
    badPeanoCodec =
        S.maybe badPeanoCodec |> S.map Peano (\(Peano a) -> a)

    {-| Now the compiler is happy!
    -}
    goodPeanoCodec : S.Codec e Peano
    goodPeanoCodec =
        S.maybe (S.lazy (\() -> goodPeanoCodec)) |> S.map Peano (\(Peano a) -> a)

**Warning:** This is not stack safe.

In general if you have a type that contains itself, like with our the Peano example, then you're at risk of a stack overflow while decoding.
Even if you're translating your nested data into a list before encoding, you're at risk, because the function translating back after decoding can cause a stack overflow if the original value was nested deeply enough.
Be careful here, and test your codecs using elm-test with larger inputs than you ever expect to see in real life.

-}
lazy : (() -> Codec a) -> Codec a
lazy f =
    build
        (\value -> toBytesEncoder (f ()) value)
        (BD.succeed () |> BD.andThen (\() -> toBytesDecoder (f ())))
