{-# LANGUAGE ExistentialQuantification #-}
{-# LANGUAGE GADTs #-}
{-# LANGUAGE RankNTypes #-}

module Serialize
  ( Codec,
    CustomTypeCodec,
    Error (..),
    RecordCodec,
    VariantEncoder (..),
    -- array,
    bool,
    byte,
    -- bytes,
    customType,
    decodeFromBytes,
    dict,
    encodeToBytes,
    enum,
    field,
    finishCustomType,
    finishRecord,
    float32,
    float64,
    int16,
    int32,
    int64,
    int8,
    list,
    map,
    mapError,
    mapValid,
    maybe,
    record,
    result,
    set,
    string,
    time,
    tuple,
    uint16,
    uint32,
    uint64,
    uint8,
    unit,
    uuid,
    variant0,
    variant1,
    variant2,
    variant3,
    variant4,
    variant5,
    variant6,
    variant7,
    variant8,
    (&),
  )
where

import qualified Acadia.Bytes.Decode as BD
import qualified Acadia.Bytes.Encode as BE
import qualified Acadia.Result as R
import qualified Acadia.Time as Time
import qualified Acadia.Uuid as Uuid
import Control.Monad (replicateM)
import qualified Data.Array as A
import qualified Data.ByteString as BS
import qualified Data.ByteString.Builder as BB
import qualified Data.ByteString.Lazy as BSL
import Data.Functor ((<&>))
import Data.Int
import qualified Data.Map.Strict as M
import qualified Data.Set as S
import qualified Data.Text as T
import qualified Data.Text.Encoding as TE
import Data.Word
import Prelude hiding (map, maybe)
import qualified Prelude

-- | A value that knows how to encode and decode a Haskell data structure.
data Codec e a = Codec
  { encoder :: a -> BE.Builder,
    decoder :: BD.Decoder (R.Result (Error e) a)
  }

-- | Possible errors that can occur when decoding.
data Error e
  = CustomError e
  | DataCorrupted
  | SerializerOutOfDate
  deriving (Show, Eq)

version :: Word8
version = 1

-- | Run a Codec to turn a sequence of bytes into a Haskell value.
decodeFromBytes :: Codec e a -> BS.ByteString -> IO (R.Result (Error e) a)
decodeFromBytes codec bytes_ =
  let decoder_ =
        BD.uint8 >>= \value ->
          if value <= 0
            then
              return $ R.Err DataCorrupted
            else
              if value == version
                then
                  decoder codec
                else
                  return $ R.Err SerializerOutOfDate
   in do
        result <- BD.fromByteString decoder_ bytes_
        return $ case result of
          Just value -> value
          Nothing -> R.Err DataCorrupted

-- | Convert a Haskell value into a sequence of bytes.
encodeToBytes :: Codec e a -> a -> BS.ByteString
encodeToBytes codec value =
  BSL.toStrict $
    BB.toLazyByteString $
      BE.sequence
        [ BE.uint8 version,
          encoder codec value
        ]

build :: (a -> BE.Builder) -> BD.Decoder (R.Result (Error e) a) -> Codec e a
build = Codec

-- | Codec for serializing a String (Text)
string :: Codec e T.Text
string =
  build
    ( \text ->
        BE.sequence
          [ BE.uint32BE (fromIntegral $ BE.getSizeString text),
            BE.string text
          ]
    )
    ( BD.uint32BE >>= \byteCount ->
        BD.string (fromIntegral byteCount) <&> R.Ok
    )

-- | Codec for serializing a Bool
bool :: Codec e Bool
bool =
  build
    (\value -> BE.uint8 $ if value then 1 else 0)
    ( BD.uint8 <&> \value -> case value of
        0 -> R.Ok False
        1 -> R.Ok True
        _ -> R.Err DataCorrupted
    )

int8 :: Codec e Int8
int8 = build BE.int8 (BD.int8 <&> R.Ok)

int16 :: Codec e Int16
int16 = build (BE.int16BE) (BD.int16BE <&> R.Ok)

int32 :: Codec e Int32
int32 = build (BE.int32BE) (BD.int32BE <&> R.Ok)

int64 :: Codec e Int64
int64 = build (BE.int64BE) (BD.int64BE <&> R.Ok)

uint8 :: Codec e Word8
uint8 = build BE.uint8 (BD.uint8 <&> R.Ok)

uint16 :: Codec e Word16
uint16 = build (BE.uint16BE) (BD.uint16BE <&> R.Ok)

uint32 :: Codec e Word32
uint32 = build (BE.uint32BE) (BD.uint32BE <&> R.Ok)

uint64 :: Codec e Word64
uint64 = build (BE.uint64BE) (BD.uint64BE <&> R.Ok)

float32 :: Codec e Float
float32 = build (BE.float32BE) (BD.float32BE <&> R.Ok)

float64 :: Codec e Double
float64 = build (BE.float64BE) (BD.float64BE <&> R.Ok)

time :: Codec e Time.Posix
time =
  build
    (BE.uint64BE . Time.toPostgresMicroseconds)
    ((fmap Time.fromPostgresMicroseconds BD.uint64BE) <&> R.Ok)

uuid :: Codec e Uuid.Uuid
uuid = build BE.uuid (BD.uuid <&> R.Ok)

-- | Codec for serializing a Maybe
maybe :: Codec e a -> Codec e (Maybe a)
maybe justCodec =
  customType
    ( \nothingEncoder justEncoder value ->
        case value of
          Nothing -> nothingEncoder
          Just v -> justEncoder v
    )
    & variant0 Nothing
    & variant1 Just justCodec
    & finishCustomType

-- | Codec for serializing a list
list :: Codec e a -> Codec e [a]
list codec =
  build
    (listEncode (encoder codec))
    ( BD.uint32BE >>= \len ->
        listDecode (fromIntegral len) (decoder codec)
    )

listEncode :: (a -> BE.Builder) -> [a] -> BE.Builder
listEncode enc xs =
  BE.sequence $
    BE.uint32BE (fromIntegral $ length xs)
      : Prelude.map enc xs

listDecode :: Int -> BD.Decoder (R.Result (Error e) a) -> BD.Decoder (R.Result (Error e) [a])
listDecode n dec
  | n <= 0 = return $ R.Ok []
  | otherwise = do
      results <- replicateM n dec
      return $ R.fromEither $ sequenceA $ Prelude.map R.toEither results

-- -- | Codec for serializing an Array
-- array :: Codec e a -> Codec e (A.Array Int a)
-- array codec = mapHelper (fmap (A.listArray (0, -1) . \xs -> A.listArray (0, length xs - 1) xs)) A.elems (list codec)

-- | Codec for serializing a Dict (Map)
dict :: (Ord k) => Codec e k -> Codec e v -> Codec e (M.Map k v)
dict keyCodec valueCodec =
  list (tuple keyCodec valueCodec)
    & mapHelper (R.fromEither . fmap M.fromList . R.toEither) M.toList

-- | Codec for serializing a Set
set :: (Ord a) => Codec e a -> Codec e (S.Set a)
set codec = list codec & mapHelper (R.fromEither . fmap S.fromList . R.toEither) S.toList

-- | Codec for serializing () (Unit)
unit :: Codec e ()
unit = build (const $ BE.sequence []) (return $ R.Ok ())

-- | Codec for serializing a tuple with 2 elements
tuple :: Codec e a -> Codec e b -> Codec e (a, b)
tuple codecFirst codecSecond =
  record (,)
    & field fst codecFirst
    & field snd codecSecond
    & finishRecord

-- | Codec for serializing a Result
result :: Codec e err -> Codec e val -> Codec e (Either err val)
result errorCodec valueCodec =
  customType
    ( \errEncoder okEncoder value ->
        case value of
          Left err -> errEncoder err
          Right ok -> okEncoder ok
    )
    & variant1 Left errorCodec
    & variant1 Right valueCodec
    & finishCustomType

-- -- | Codec for serializing Bytes (ByteString)
-- bytes :: Codec e BS.ByteString
-- bytes =
--   build
--     ( \bs ->
--         BE.sequence
--           [ BE.uint32BE (fromIntegral $ BS.length bs),
--             BE.bytes bs
--           ]
--     )
--     ( BD.uint32BE >>= \len ->
--         BD.bytes (fromIntegral len) <&> R.Ok
--     )

-- | Codec for serializing an integer ranging from 0 to 255
byte :: Codec e Int
byte =
  build
    (BE.uint8 . fromIntegral)
    (BD.uint8 <&> (R.Ok . fromIntegral))

-- | A codec for serializing an item from a list of possible items
enum :: (Eq a) => a -> [a] -> Codec e a
enum defaultItem items =
  let getIndex value =
        case findIndex (== value) items of
          Just i -> i + 1
          Nothing -> 0
      getItem index
        | index < 0 = R.Err DataCorrupted
        | index > length items = R.Err DataCorrupted
        | otherwise = R.Ok $ case (getAt (index - 1) items) of
            Just item -> item
            Nothing -> defaultItem
   in build
        (BE.uint32BE . fromIntegral . getIndex)
        (BD.uint32BE <&> (getItem . fromIntegral))

getAt :: Int -> [a] -> Maybe a
getAt idx xs
  | idx < 0 = Nothing
  | otherwise = listToMaybe $ drop idx xs
  where
    listToMaybe [] = Nothing
    listToMaybe (x : _) = Just x

findIndex :: (a -> Bool) -> [a] -> Maybe Int
findIndex = findIndexHelp 0

findIndexHelp :: Int -> (a -> Bool) -> [a] -> Maybe Int
findIndexHelp _ _ [] = Nothing
findIndexHelp idx pred (x : xs)
  | pred x = Just idx
  | otherwise = findIndexHelp (idx + 1) pred xs

-- RECORDS

data RecordCodec e a b = RecordCodec
  { recordEncoder :: a -> [BE.Builder],
    recordDecoder :: BD.Decoder (R.Result (Error e) b),
    fieldIndex :: Int
  }

record :: b -> RecordCodec e a b
record ctor =
  RecordCodec
    { recordEncoder = const [],
      recordDecoder = return $ R.Ok ctor,
      fieldIndex = 0
    }

field :: (a -> f) -> Codec e f -> RecordCodec e a (f -> b) -> RecordCodec e a b
field getter codec rec =
  RecordCodec
    { recordEncoder = \v -> encoder codec (getter v) : recordEncoder rec v,
      recordDecoder = do
        f <- recordDecoder rec
        x <- decoder codec
        return $ case (f, x) of
          (R.Ok fOk, R.Ok xOk) -> R.Ok $ fOk xOk
          (R.Err err, _) -> R.Err err
          (_, R.Err err) -> R.Err err,
      fieldIndex = fieldIndex rec + 1
    }

finishRecord :: RecordCodec e a a -> Codec e a
finishRecord rec =
  Codec
    { encoder = BE.sequence . reverse . recordEncoder rec,
      decoder = recordDecoder rec
    }

-- CUSTOM TYPES

data CustomTypeCodec a e match v = CustomTypeCodec
  { match :: match,
    customDecoder :: Int -> BD.Decoder (R.Result (Error e) v) -> BD.Decoder (R.Result (Error e) v),
    idCounter :: Int
  }

data VariantEncoder = VariantEncoder BE.Builder

customType :: match -> CustomTypeCodec () e match value
customType m =
  CustomTypeCodec
    { match = m,
      customDecoder = \_ -> id,
      idCounter = 0
    }

variant ::
  ((([BE.Builder] -> VariantEncoder) -> a)) ->
  BD.Decoder (R.Result (Error e) v) ->
  CustomTypeCodec z e (a -> b) v ->
  CustomTypeCodec () e b v
variant matchPiece decoderPiece am =
  let enc v =
        VariantEncoder $
          BE.sequence $
            BE.uint16BE (fromIntegral $ idCounter am) : v
      decoder_ tag orElse =
        if tag == idCounter am
          then
            decoderPiece
          else
            customDecoder am tag orElse
   in CustomTypeCodec
        { match = match am $ matchPiece enc,
          customDecoder = decoder_,
          idCounter = idCounter am + 1
        }

variant0 :: v -> CustomTypeCodec z e (VariantEncoder -> a) v -> CustomTypeCodec () e a v
variant0 ctor =
  variant (\c -> c []) (return $ R.Ok ctor)

variant1 ::
  (a -> v) ->
  Codec e a ->
  CustomTypeCodec z e ((a -> VariantEncoder) -> b) v ->
  CustomTypeCodec () e b v
variant1 ctor m1 =
  variant
    (\c v -> c [encoder m1 v])
    (decoder m1 <&> result1 ctor)

result1 :: (a -> b) -> R.Result e a -> R.Result e b
result1 ctor (R.Ok ok) = R.Ok $ ctor ok
result1 _ (R.Err err) = R.Err err

variant2 ::
  (a -> b -> v) ->
  Codec e a ->
  Codec e b ->
  CustomTypeCodec z e ((a -> b -> VariantEncoder) -> c) v ->
  CustomTypeCodec () e c v
variant2 ctor m1 m2 =
  variant
    (\c v1 v2 -> c [encoder m1 v1, encoder m2 v2])
    (result2 ctor <$> decoder m1 <*> decoder m2)

result2 :: (a -> b -> c) -> R.Result e a -> R.Result e b -> R.Result e c
result2 ctor (R.Ok ok1) (R.Ok ok2) = R.Ok $ ctor ok1 ok2
result2 _ (R.Err err) _ = R.Err err
result2 _ _ (R.Err err) = R.Err err

variant3 ::
  (a -> b -> c -> v) ->
  Codec e a ->
  Codec e b ->
  Codec e c ->
  CustomTypeCodec z e ((a -> b -> c -> VariantEncoder) -> p) v ->
  CustomTypeCodec () e p v
variant3 ctor m1 m2 m3 =
  variant
    (\c v1 v2 v3 -> c [encoder m1 v1, encoder m2 v2, encoder m3 v3])
    (result3 ctor <$> decoder m1 <*> decoder m2 <*> decoder m3)

result3 :: (a -> b -> c -> d) -> R.Result e a -> R.Result e b -> R.Result e c -> R.Result e d
result3 ctor (R.Ok ok1) (R.Ok ok2) (R.Ok ok3) = R.Ok $ ctor ok1 ok2 ok3
result3 _ (R.Err err) _ _ = R.Err err
result3 _ _ (R.Err err) _ = R.Err err
result3 _ _ _ (R.Err err) = R.Err err

variant4 ::
  (a -> b -> c -> d -> v) ->
  Codec e a ->
  Codec e b ->
  Codec e c ->
  Codec e d ->
  CustomTypeCodec z e ((a -> b -> c -> d -> VariantEncoder) -> p) v ->
  CustomTypeCodec () e p v
variant4 ctor m1 m2 m3 m4 =
  variant
    (\c v1 v2 v3 v4 -> c [encoder m1 v1, encoder m2 v2, encoder m3 v3, encoder m4 v4])
    (result4 ctor <$> decoder m1 <*> decoder m2 <*> decoder m3 <*> decoder m4)

result4 :: (a -> b -> c -> d -> e) -> R.Result err a -> R.Result err b -> R.Result err c -> R.Result err d -> R.Result err e
result4 ctor (R.Ok ok1) (R.Ok ok2) (R.Ok ok3) (R.Ok ok4) = R.Ok $ ctor ok1 ok2 ok3 ok4
result4 _ (R.Err err) _ _ _ = R.Err err
result4 _ _ (R.Err err) _ _ = R.Err err
result4 _ _ _ (R.Err err) _ = R.Err err
result4 _ _ _ _ (R.Err err) = R.Err err

variant5 ::
  (a -> b -> c -> d -> e -> v) ->
  Codec err a ->
  Codec err b ->
  Codec err c ->
  Codec err d ->
  Codec err e ->
  CustomTypeCodec z err ((a -> b -> c -> d -> e -> VariantEncoder) -> p) v ->
  CustomTypeCodec () err p v
variant5 ctor m1 m2 m3 m4 m5 =
  variant
    (\c v1 v2 v3 v4 v5 -> c [encoder m1 v1, encoder m2 v2, encoder m3 v3, encoder m4 v4, encoder m5 v5])
    (result5 ctor <$> decoder m1 <*> decoder m2 <*> decoder m3 <*> decoder m4 <*> decoder m5)

result5 :: (a -> b -> c -> d -> e -> f) -> R.Result err a -> R.Result err b -> R.Result err c -> R.Result err d -> R.Result err e -> R.Result err f
result5 ctor (R.Ok ok1) (R.Ok ok2) (R.Ok ok3) (R.Ok ok4) (R.Ok ok5) = R.Ok $ ctor ok1 ok2 ok3 ok4 ok5
result5 _ (R.Err err) _ _ _ _ = R.Err err
result5 _ _ (R.Err err) _ _ _ = R.Err err
result5 _ _ _ (R.Err err) _ _ = R.Err err
result5 _ _ _ _ (R.Err err) _ = R.Err err
result5 _ _ _ _ _ (R.Err err) = R.Err err

variant6 ::
  (a -> b -> c -> d -> e -> f -> v) ->
  Codec err a ->
  Codec err b ->
  Codec err c ->
  Codec err d ->
  Codec err e ->
  Codec err f ->
  CustomTypeCodec z err ((a -> b -> c -> d -> e -> f -> VariantEncoder) -> p) v ->
  CustomTypeCodec () err p v
variant6 ctor m1 m2 m3 m4 m5 m6 =
  variant
    (\c v1 v2 v3 v4 v5 v6 -> c [encoder m1 v1, encoder m2 v2, encoder m3 v3, encoder m4 v4, encoder m5 v5, encoder m6 v6])
    (result6 ctor <$> decoder m1 <*> decoder m2 <*> decoder m3 <*> decoder m4 <*> ((,) <$> decoder m5 <*> decoder m6))

result6 :: (a -> b -> c -> d -> e -> f -> g) -> R.Result err a -> R.Result err b -> R.Result err c -> R.Result err d -> (R.Result err e, R.Result err f) -> R.Result err g
result6 ctor (R.Ok ok1) (R.Ok ok2) (R.Ok ok3) (R.Ok ok4) (R.Ok ok5, R.Ok ok6) = R.Ok $ ctor ok1 ok2 ok3 ok4 ok5 ok6
result6 _ (R.Err err) _ _ _ _ = R.Err err
result6 _ _ (R.Err err) _ _ _ = R.Err err
result6 _ _ _ (R.Err err) _ _ = R.Err err
result6 _ _ _ _ (R.Err err) _ = R.Err err
result6 _ _ _ _ _ (R.Err err, _) = R.Err err
result6 _ _ _ _ _ (_, R.Err err) = R.Err err

variant7 ::
  (a -> b -> c -> d -> e -> f -> g -> v) ->
  Codec err a ->
  Codec err b ->
  Codec err c ->
  Codec err d ->
  Codec err e ->
  Codec err f ->
  Codec err g ->
  CustomTypeCodec z err ((a -> b -> c -> d -> e -> f -> g -> VariantEncoder) -> p) v ->
  CustomTypeCodec () err p v
variant7 ctor m1 m2 m3 m4 m5 m6 m7 =
  variant
    (\c v1 v2 v3 v4 v5 v6 v7 -> c [encoder m1 v1, encoder m2 v2, encoder m3 v3, encoder m4 v4, encoder m5 v5, encoder m6 v6, encoder m7 v7])
    (result7 ctor <$> decoder m1 <*> decoder m2 <*> decoder m3 <*> ((,) <$> decoder m4 <*> decoder m5) <*> ((,) <$> decoder m6 <*> decoder m7))

result7 :: (a -> b -> c -> d -> e -> f -> g -> h) -> R.Result err a -> R.Result err b -> R.Result err c -> (R.Result err d, R.Result err e) -> (R.Result err f, R.Result err g) -> R.Result err h
result7 ctor (R.Ok ok1) (R.Ok ok2) (R.Ok ok3) (R.Ok ok4, R.Ok ok5) (R.Ok ok6, R.Ok ok7) = R.Ok $ ctor ok1 ok2 ok3 ok4 ok5 ok6 ok7
result7 _ (R.Err err) _ _ _ _ = R.Err err
result7 _ _ (R.Err err) _ _ _ = R.Err err
result7 _ _ _ (R.Err err) _ _ = R.Err err
result7 _ _ _ _ (R.Err err, _) _ = R.Err err
result7 _ _ _ _ (_, R.Err err) _ = R.Err err
result7 _ _ _ _ _ (R.Err err, _) = R.Err err
result7 _ _ _ _ _ (_, R.Err err) = R.Err err

variant8 ::
  (a -> b -> c -> d -> e -> f -> g -> h -> v) ->
  Codec err a ->
  Codec err b ->
  Codec err c ->
  Codec err d ->
  Codec err e ->
  Codec err f ->
  Codec err g ->
  Codec err h ->
  CustomTypeCodec z err ((a -> b -> c -> d -> e -> f -> g -> h -> VariantEncoder) -> p) v ->
  CustomTypeCodec () err p v
variant8 ctor m1 m2 m3 m4 m5 m6 m7 m8 =
  variant
    (\c v1 v2 v3 v4 v5 v6 v7 v8 -> c [encoder m1 v1, encoder m2 v2, encoder m3 v3, encoder m4 v4, encoder m5 v5, encoder m6 v6, encoder m7 v7, encoder m8 v8])
    (result8 ctor <$> decoder m1 <*> decoder m2 <*> ((,) <$> decoder m3 <*> decoder m4) <*> ((,) <$> decoder m5 <*> decoder m6) <*> ((,) <$> decoder m7 <*> decoder m8))

result8 :: (a -> b -> c -> d -> e -> f -> g -> h -> i) -> R.Result err a -> R.Result err b -> (R.Result err c, R.Result err d) -> (R.Result err e, R.Result err f) -> (R.Result err g, R.Result err h) -> R.Result err i
result8 ctor (R.Ok ok1) (R.Ok ok2) (R.Ok ok3, R.Ok ok4) (R.Ok ok5, R.Ok ok6) (R.Ok ok7, R.Ok ok8) = R.Ok $ ctor ok1 ok2 ok3 ok4 ok5 ok6 ok7 ok8
result8 _ (R.Err err) _ _ _ _ = R.Err err
result8 _ _ (R.Err err) _ _ _ = R.Err err
result8 _ _ _ (R.Err err, _) _ _ = R.Err err
result8 _ _ _ (_, R.Err err) _ _ = R.Err err
result8 _ _ _ _ (R.Err err, _) _ = R.Err err
result8 _ _ _ _ (_, R.Err err) _ = R.Err err
result8 _ _ _ _ _ (R.Err err, _) = R.Err err
result8 _ _ _ _ _ (_, R.Err err) = R.Err err

finishCustomType :: CustomTypeCodec () e (a -> VariantEncoder) a -> Codec e a
finishCustomType am =
  build
    (\v -> let VariantEncoder enc = match am v in enc)
    ( BD.uint16BE >>= \tag ->
        customDecoder am (fromIntegral tag) (return $ R.Err DataCorrupted)
    )

-- MAPPING

map :: (a -> b) -> (b -> a) -> Codec e a -> Codec e b
map fromBytes toBytes codec =
  mapHelper
    ( \value -> case value of
        R.Ok ok -> R.Ok $ fromBytes ok
        R.Err err -> R.Err err
    )
    toBytes
    codec

mapHelper :: (R.Result (Error e) a -> R.Result (Error e) b) -> (b -> a) -> Codec e a -> Codec e b
mapHelper fromBytes toBytes codec =
  build
    (\v -> encoder codec $ toBytes v)
    (decoder codec <&> fromBytes)

mapValid :: (a -> R.Result e b) -> (b -> a) -> Codec e a -> Codec e b
mapValid fromBytes toBytes codec =
  build
    (\v -> encoder codec $ toBytes v)
    ( decoder codec <&> \value ->
        case value of
          R.Ok ok -> case fromBytes ok of
            R.Ok ok' -> R.Ok ok'
            R.Err err -> R.Err $ CustomError err
          R.Err err -> R.Err err
    )

mapError :: (e1 -> e2) -> Codec e1 a -> Codec e2 a
mapError mapFunc codec =
  build
    (encoder codec)
    (decoder codec <&> mapErrorHelper mapFunc)

mapErrorHelper :: (e -> a) -> R.Result (Error e) b -> R.Result (Error a) b
mapErrorHelper mapFunc result =
  case result of
    R.Ok val -> R.Ok val
    R.Err err -> R.Err $ case err of
      CustomError custom -> CustomError $ mapFunc custom
      DataCorrupted -> DataCorrupted
      SerializerOutOfDate -> SerializerOutOfDate

-- Helper for (&) operator
(&) :: a -> (a -> b) -> b
(&) = flip ($)

infixl 1 &