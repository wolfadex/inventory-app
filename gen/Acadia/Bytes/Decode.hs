{-# LANGUAGE BangPatterns, CPP, ExtendedLiterals, MagicHash, PackageImports,
Rank2Types, UnboxedTuples #-}
module Acadia.Bytes.Decode
  ( Decoder(..)
  , fromByteString
  , fromByteStrings
  --
  , bool
  , charBE
  , charLE
  --
  , uint8
  , uint16BE
  , uint32BE
  , uint64BE
  , uint16LE
  , uint32LE
  , uint64LE
  --
  , int8
  , int16BE
  , int32BE
  , int64BE
  , int16LE
  , int32LE
  , int64LE
  --
  , float32BE
  , float64BE
  , float32LE
  , float64LE
  --
  , string
  , uuid
  , timeBE
  , timeLE
  --
  , map
  , map2
  , map3
  , fail
  , succeed
  , andThen
  , list
  --
  , Result(..)
  , Stepper
  , Continue
  )
  where


import "base" Prelude hiding (fail, map)
import qualified Data.Array.Byte as Byte
import qualified Data.ByteString.Internal as BS
import qualified Data.Char as Char
import qualified Data.Text.Internal as Text
import GHC.Exts (isTrue#)
import GHC.Float (castWord32ToFloat, castWord64ToDouble)
import GHC.ForeignPtr (ForeignPtr(..), ForeignPtrContents)
import GHC.Int
import GHC.IO (IO(IO))
import GHC.Prim
import GHC.Word

import qualified Acadia.Time as Time
import qualified Acadia.Uuid as Uuid

#include <ghcautoconf.h>
-- to import WORDS_BIGENDIAN



-- DECODER


newtype Decoder a =
  Decoder (forall r. Ref -> Addr# -> Addr# -> Stepper a r -> IO (Result r))


type Ref =
  ForeignPtrContents


type Stepper a r =
  Ref -> Addr# -> Addr# -> a -> IO (Result r)


type Continue a =
  Ref -> Addr# -> Addr# -> IO (Result a)


data Result a
  = Ok Int# !a
  | Stall (Continue a)
  | Err



-- FROM BYTE STRING


fromByteString :: Decoder a -> BS.ByteString -> IO (Maybe a)
fromByteString (Decoder k) (BS.BS (ForeignPtr addr ref) (I# len)) =
  do  result <- k ref addr (plusAddr# addr len) finalize
      case result of
        Ok 0# a -> return (Just a)
        Ok _  _ -> return Nothing
        Stall _ -> return Nothing
        Err     -> return Nothing


fromByteStrings :: Decoder a -> [BS.ByteString] -> IO (Maybe a)
fromByteStrings (Decoder k) chunks0 =
    loop chunks0 (Stall (\r p e -> k r p e finalize))
  where
    loop chunks result =
      case chunks of
        [] ->
          case result of
            Ok 0# a -> return (Just a)
            Ok _  _ -> return Nothing
            Stall _ -> return Nothing
            Err     -> return Nothing

        BS.BS (ForeignPtr addr ref) (I# len) : rest ->
          case result of
            Ok _ _ ->
              case len of
                0# -> loop rest result
                _  -> return Nothing

            Stall c -> loop rest =<< c ref addr (plusAddr# addr len)
            Err     -> return Nothing


finalize :: Stepper a a
finalize _ pos end value =
  return $ Ok (minusAddr# end pos) value



-- BOOL


bool :: Decoder Bool
bool =
  do  b <- uint8
      if b <= 1
        then pure (b == 1)
        else fail



-- CHAR


charBE :: Decoder Char
charBE =
  do  c <- uint32BE
      if c <= 0x10FFFF
        then pure (Char.chr (fromIntegral c))
        else fail


charLE :: Decoder Char
charLE =
  do  c <- uint32LE
      if c <= 0x10FFFF
        then pure (Char.chr (fromIntegral c))
        else fail



-- INTEGERS


int8    :: Decoder Int8
int16BE :: Decoder Int16
int32BE :: Decoder Int32
int64BE :: Decoder Int64
int16LE :: Decoder Int16
int32LE :: Decoder Int32
int64LE :: Decoder Int64

int8    = byte     getInt8
int16BE = fixed 2# getInt16_BE step_BE (\w -> I16# (intToInt16# (word2Int# (word64ToWord# w))))
int32BE = fixed 4# getInt32_BE step_BE (\w -> I32# (intToInt32# (word2Int# (word64ToWord# w))))
int64BE = fixed 8# getInt64_BE step_BE (\w -> I64# (word64ToInt64# w))
int16LE = fixed 2# getInt16_LE step_LE (\w -> I16# (intToInt16# (word2Int# (word64ToWord# (uncheckedShiftRL64# w 48#)))))
int32LE = fixed 4# getInt32_LE step_LE (\w -> I32# (intToInt32# (word2Int# (word64ToWord# (uncheckedShiftRL64# w 32#)))))
int64LE = fixed 8# getInt64_LE step_LE (\w -> I64# (word64ToInt64# w))

uint8    :: Decoder Word8
uint16BE :: Decoder Word16
uint32BE :: Decoder Word32
uint64BE :: Decoder Word64
uint16LE :: Decoder Word16
uint32LE :: Decoder Word32
uint64LE :: Decoder Word64

uint8    = byte getWord8
uint16BE = fixed 2# getWord16_BE step_BE (\w -> W16# (wordToWord16# (word64ToWord# w)))
uint32BE = fixed 4# getWord32_BE step_BE (\w -> W32# (wordToWord32# (word64ToWord# w)))
uint64BE = fixed 8# getWord64_BE step_BE (\w -> W64# w)
uint16LE = fixed 2# getWord16_LE step_LE (\w -> W16# (wordToWord16# (word64ToWord# (uncheckedShiftRL64# w 48#))))
uint32LE = fixed 4# getWord32_LE step_LE (\w -> W32# (wordToWord32# (word64ToWord# (uncheckedShiftRL64# w 32#))))
uint64LE = fixed 8# getWord64_LE step_LE (\w -> W64# w)



-- FLOAT


float32BE :: Decoder Float
float32LE :: Decoder Float

float64BE :: Decoder Double
float64LE :: Decoder Double

float32BE = castWord32ToFloat  <$> uint32BE
float32LE = castWord32ToFloat  <$> uint32LE

float64BE = castWord64ToDouble <$> uint64BE
float64LE = castWord64ToDouble <$> uint64LE



-- GET BYTES


{-# INLINE getWord8     #-}
{-# INLINE getWord16_LE #-}
{-# INLINE getWord32_LE #-}
{-# INLINE getWord64_LE #-}
{-# INLINE getWord16_BE #-}
{-# INLINE getWord32_BE #-}
{-# INLINE getWord64_BE #-}

{-# INLINE getInt8     #-}
{-# INLINE getInt16_LE #-}
{-# INLINE getInt32_LE #-}
{-# INLINE getInt64_LE #-}
{-# INLINE getInt16_BE #-}
{-# INLINE getInt32_BE #-}
{-# INLINE getInt64_BE #-}

getWord8     :: Addr# -> IO Word8
getWord16_LE :: Addr# -> IO Word16
getWord32_LE :: Addr# -> IO Word32
getWord64_LE :: Addr# -> IO Word64
getWord16_BE :: Addr# -> IO Word16
getWord32_BE :: Addr# -> IO Word32
getWord64_BE :: Addr# -> IO Word64

getInt8      :: Addr# -> IO Int8
getInt16_LE  :: Addr# -> IO Int16
getInt32_LE  :: Addr# -> IO Int32
getInt64_LE  :: Addr# -> IO Int64
getInt16_BE  :: Addr# -> IO Int16
getInt32_BE  :: Addr# -> IO Int32
getInt64_BE  :: Addr# -> IO Int64

getWord8 a = IO $ \s0 -> case readWord8OffAddr# a 0# s0 of { (# s1, w #) -> (# s1, W8# w #) }
getInt8  a = IO $ \s0 -> case readInt8OffAddr#  a 0# s0 of { (# s1, w #) -> (# s1, I8# w #) }

#if defined(WORDS_BIGENDIAN)
getWord16_LE a = IO $ \s0 -> case readWord16OffAddr# a 0# s0 of { (# s1, w #) -> (# s1, W16# (wordToWord16# (byteSwap16# (word16ToWord# w))) #) }
getWord32_LE a = IO $ \s0 -> case readWord32OffAddr# a 0# s0 of { (# s1, w #) -> (# s1, W32# (wordToWord32# (byteSwap32# (word32ToWord# w))) #) }
getWord64_LE a = IO $ \s0 -> case readWord64OffAddr# a 0# s0 of { (# s1, w #) -> (# s1, W64# (              (byteSwap64# (              w))) #) }
getWord16_BE a = IO $ \s0 -> case readWord16OffAddr# a 0# s0 of { (# s1, w #) -> (# s1, W16# w #) }
getWord32_BE a = IO $ \s0 -> case readWord32OffAddr# a 0# s0 of { (# s1, w #) -> (# s1, W32# w #) }
getWord64_BE a = IO $ \s0 -> case readWord64OffAddr# a 0# s0 of { (# s1, w #) -> (# s1, W64# w #) }

getInt16_LE a = IO $ \s0 -> case readWord16OffAddr# a 0# s0 of { (# s1, w #) -> (# s1, I16# (intToInt16# (word2Int# (byteSwap16# (word16ToWord# w)))) #) }
getInt32_LE a = IO $ \s0 -> case readWord32OffAddr# a 0# s0 of { (# s1, w #) -> (# s1, I32# (intToInt32# (word2Int# (byteSwap32# (word32ToWord# w)))) #) }
getInt64_LE a = IO $ \s0 -> case readWord64OffAddr# a 0# s0 of { (# s1, w #) -> (# s1, I64# (word64ToInt64#         (byteSwap64# (              w)) ) #) }
getInt16_BE a = IO $ \s0 -> case readInt16OffAddr#  a 0# s0 of { (# s1, w #) -> (# s1, I16# w #) }
getInt32_BE a = IO $ \s0 -> case readInt32OffAddr#  a 0# s0 of { (# s1, w #) -> (# s1, I32# w #) }
getInt64_BE a = IO $ \s0 -> case readInt64OffAddr#  a 0# s0 of { (# s1, w #) -> (# s1, I64# w #) }
#else
getWord16_LE a = IO $ \s0 -> case readWord16OffAddr# a 0# s0 of { (# s1, w #) -> (# s1, W16# w #) }
getWord32_LE a = IO $ \s0 -> case readWord32OffAddr# a 0# s0 of { (# s1, w #) -> (# s1, W32# w #) }
getWord64_LE a = IO $ \s0 -> case readWord64OffAddr# a 0# s0 of { (# s1, w #) -> (# s1, W64# w #) }
getWord16_BE a = IO $ \s0 -> case readWord16OffAddr# a 0# s0 of { (# s1, w #) -> (# s1, W16# (wordToWord16# (byteSwap16# (word16ToWord# w))) #) }
getWord32_BE a = IO $ \s0 -> case readWord32OffAddr# a 0# s0 of { (# s1, w #) -> (# s1, W32# (wordToWord32# (byteSwap32# (word32ToWord# w))) #) }
getWord64_BE a = IO $ \s0 -> case readWord64OffAddr# a 0# s0 of { (# s1, w #) -> (# s1, W64# (              (byteSwap64# (              w))) #) }

getInt16_LE a = IO $ \s0 -> case readInt16OffAddr#  a 0# s0 of { (# s1, w #) -> (# s1, I16# w #) }
getInt32_LE a = IO $ \s0 -> case readInt32OffAddr#  a 0# s0 of { (# s1, w #) -> (# s1, I32# w #) }
getInt64_LE a = IO $ \s0 -> case readInt64OffAddr#  a 0# s0 of { (# s1, w #) -> (# s1, I64# w #) }
getInt16_BE a = IO $ \s0 -> case readWord16OffAddr# a 0# s0 of { (# s1, w #) -> (# s1, I16# (intToInt16# (word2Int# (byteSwap16# (word16ToWord# w)))) #) }
getInt32_BE a = IO $ \s0 -> case readWord32OffAddr# a 0# s0 of { (# s1, w #) -> (# s1, I32# (intToInt32# (word2Int# (byteSwap32# (word32ToWord# w)))) #) }
getInt64_BE a = IO $ \s0 -> case readWord64OffAddr# a 0# s0 of { (# s1, w #) -> (# s1, I64# (word64ToInt64#         (byteSwap64# (              w)) ) #) }
#endif



-- BYTE


{-# INLINE byte #-}
byte :: (Addr# -> IO a) -> Decoder a
byte func =
  Decoder $ \ref pos end ok ->
    if isTrue# (ltAddr# pos end)
    then ok ref (plusAddr# pos 1#) end =<< func pos
    else return $ Stall (byteHelp func ok)


byteHelp :: (Addr# -> IO a) -> Stepper a r -> Continue r
byteHelp func ok =
  \ref pos end ->
    if isTrue# (ltAddr# pos end)
    then ok ref (plusAddr# pos 1#) end =<< func pos
    else return $ Stall (byteHelp func ok)



-- FIXED


{-# INLINE fixed #-}
fixed :: Int# -> (Addr# -> IO a) -> (Word64# -> Addr# -> Word64#) -> (Word64# -> a) -> Decoder a
fixed width func step backup =
  Decoder $ \ref pos end ok ->
    let
      !newPos = plusAddr# pos width
    in
    if isTrue# (leAddr# newPos end)
    then ok ref newPos end =<< func pos
    else fixedHelp width step backup 0#Word64 ok ref pos end


fixedHelp :: Int# -> (Word64# -> Addr# -> Word64#) -> (Word64# -> a) -> Word64# -> Stepper a r -> Ref -> Addr# -> Addr# -> IO (Result r)
fixedHelp width step backup state ok ref pos end =
    loop width state pos
  where
    loop w s p =
      if isTrue# (ltAddr# p end)
      then
        if isTrue# (w ==# 1#)
        then ok ref (plusAddr# p 1#) end (backup (step s p))
        else loop (w -# 1#) (step s p) (plusAddr# p 1#)
      else
        return $ Stall (fixedHelp w step backup s ok)


step_BE :: Word64# -> Addr# -> Word64#
step_BE state pos =
  or64#
    (uncheckedShiftL64# state 8#)
    (wordToWord64# (word8ToWord# (indexWord8OffAddr# pos 0#)))


step_LE :: Word64# -> Addr# -> Word64#
step_LE state pos =
  or64#
    (uncheckedShiftRL64# state 8#)
    (byteSwap64# (wordToWord64# (word8ToWord# (indexWord8OffAddr# pos 0#))))



-- TEXT


string :: Word32 -> Decoder Text.Text
string (W32# n) =
  Decoder $ \ref pos end ok ->
    let
      !len    = word2Int# (word32ToWord# n)
      !newPos = plusAddr# pos len
    in
    if isTrue# (leAddr# newPos end)
    then
      case steps utf8_fsm pos newPos 0#Word8 of
        0#Word8 -> ok ref newPos end =<< fromAddr toText pos newPos
        _       -> return Err
    else
      case steps utf8_fsm pos end 0#Word8 of
        12#Word8 ->
          return Err

        s ->
          do  let !got = minusAddr# end pos
              return $ Stall $ stringHelp s [Chunk ref pos got] got (len -# got) ok


stringHelp :: Word8# -> [Chunk] -> Int# -> Int# -> Stepper Text.Text a -> Continue a
stringHelp state revs have want ok =
  \ref pos end ->
    let
      !newPos = plusAddr# pos want
    in
    if isTrue# (leAddr# newPos end)
    then
      case steps utf8_fsm pos newPos state of
        0#Word8 -> ok ref newPos end =<< fromChunks toText (have +# want) (Chunk ref pos want : revs)
        _       -> return Err
    else
      case steps utf8_fsm pos end state of
        12#Word8 ->
          return Err

        s ->
          do  let !got = minusAddr# end pos
              return $ Stall $ stringHelp s (Chunk ref pos got : revs) (have +# got) (want -# got) ok


toText :: ByteArray# -> Text.Text
toText ba =
  Text.Text (Byte.ByteArray ba) 0 (I# (sizeofByteArray# ba))



-- UUID


uuid :: Decoder Uuid.Uuid
uuid =
  Uuid.Uuid <$> uint64BE <*> uint64BE



-- TIME


timeBE :: Decoder Time.Posix
timeLE :: Decoder Time.Posix

timeBE = Time.fromPostgresMicroseconds <$> uint64BE
timeLE = Time.fromPostgresMicroseconds <$> uint64LE



--------------------------------------------------------------------------------
-- HELPERS ---------------------------------------------------------------------
--------------------------------------------------------------------------------



-- FROM ADDR


{-# INLINE fromAddr #-}
fromAddr :: (ByteArray# -> a) -> Addr# -> Addr# -> IO a
fromAddr func pos end =
  IO $ \s0 ->
    let
      !len = minusAddr# end pos
    in
    case newByteArray# len                   s0 of { (# s1, mba #) ->
    case copyAddrToByteArray# pos mba 0# len s1 of {    s2         ->
    case unsafeFreezeByteArray#   mba        s2 of { (# s3, ba  #) ->
      (# s3, func ba #)
    }}}



-- FROM CHUNKS


data Chunk =
  Chunk Ref Addr# Int#


fromChunks :: (ByteArray# -> a) -> Int# -> [Chunk] -> IO a
fromChunks func size revs =
  IO $ \s0 ->
    case newByteArray# size s0 of
      (# s1, mba #) ->
        go mba 0# (reverse revs) s1
  where
    go mba off chunks s0 =
      case chunks of
        [] ->
          case unsafeFreezeByteArray# mba s0 of
            (# s1, ba #) ->
              (# s1, func ba #)

        Chunk ref pos len : rest ->
          case copyAddrToByteArray# pos mba off len s0 of { s1 ->
          case touch# ref                           s1 of { s2 ->
            go mba (off +# len) rest s2
          }}



-- INSTANCES


instance Functor Decoder where
  {-# INLINE fmap #-}
  fmap func (Decoder k) =
    Decoder $ \ref pos end ok ->
      let
        ok' r p e value = ok r p e (func value)
      in
      k ref pos end ok'


instance Applicative Decoder where
  {-# INLINE pure #-}
  pure = succeed

  {-# INLINE (<*>) #-}
  (<*>) (Decoder kF) (Decoder kV) =
    Decoder $ \ref pos end ok ->
      let
        okF r p e func =
          let
            okV rV pV eV value = ok rV pV eV (func value)
          in
          kV r p e okV
      in
      kF ref pos end okF


instance Monad Decoder where
  {-# INLINE (>>=) #-}
  (>>=) (Decoder kA) callback =
    Decoder $ \ref pos end ok ->
      let
        okA r p e a =
          case callback a of
            Decoder kB -> kB r p e ok
      in
      kA ref pos end okA


{-# INLINE succeed #-}
succeed :: a -> Decoder a
succeed a =
  Decoder $ \ref pos end ok ->
    ok ref pos end a


{-# INLINE fail #-}
fail :: Decoder a
fail =
  Decoder $ \_ _ _ _ ->
    return Err


andThen :: (a -> Decoder b) -> Decoder a -> Decoder b
andThen callback (Decoder kA) =
  Decoder $ \ref pos end ok ->
    let
      okA r p e a =
        case callback a of
          Decoder kB -> kB r p e ok
    in
    kA ref pos end okA


list :: Decoder a -> Decoder [a]
list decoder =
    loop []
  where
    loop revs =
      do  chunkSize <- uint32LE
          case chunkSize of
            0 -> return (reverse revs)
            n -> loop =<< go n revs

    go i revs =
      if i > 0
      then
        do  a <- decoder
            go (i - 1) (a:revs)
      else
        return revs



-- MAPS


{-# INLINE map #-}
map :: (a -> b) -> Decoder a -> Decoder b
map func (Decoder k) =
  Decoder $ \ref pos end ok ->
    let
      ok' r p e value = ok r p e (func value)
    in
    k ref pos end ok'


{-# INLINE map2 #-}
map2 :: (a -> b -> v) -> Decoder a -> Decoder b -> Decoder v
map2 func dA dB =
  do  a <- dA
      b <- dB
      return (func a b)


{-# INLINE map3 #-}
map3 :: (a -> b -> c -> v) -> Decoder a -> Decoder b -> Decoder c -> Decoder v
map3 func dA dB dC =
  do  a <- dA
      b <- dB
      c <- dC
      return (func a b c)



-- VALIDATION FSM
--
-- This table is adapted from Bjoern's UTF-8 FSM in C.
--
-- This one disallows the NUL character. It is not allowed in Postgres strings
-- and can cause problems with the frontend/backend protocol.
--
-- Copyright (c) 2008-2010 Bjoern Hoehrmann <bjoern@hoehrmann.de>
-- Available under an MIT license, with a great explanation of the code at:
--   http://bjoern.hoehrmann.de/utf-8/decoder/dfa/


data FSM =
  FSM Addr#


utf8_fsm :: FSM
utf8_fsm =
  FSM
    "\x08\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x09\x09\x09\x09\x09\x09\x09\x09\x09\x09\x09\x09\x09\x09\x09\x09\x07\x07\x07\x07\x07\x07\x07\x07\x07\x07\x07\x07\x07\x07\x07\x07\x07\x07\x07\x07\x07\x07\x07\x07\x07\x07\x07\x07\x07\x07\x07\x07\x08\x08\x02\x02\x02\x02\x02\x02\x02\x02\x02\x02\x02\x02\x02\x02\x02\x02\x02\x02\x02\x02\x02\x02\x02\x02\x02\x02\x02\x02\x02\x02\x0a\x03\x03\x03\x03\x03\x03\x03\x03\x03\x03\x03\x03\x04\x03\x03\x0b\x06\x06\x06\x05\x08\x08\x08\x08\x08\x08\x08\x08\x08\x08\x08\x00\x0c\x18\x24\x3c\x60\x54\x0c\x0c\x0c\x30\x48\x0c\x0c\x0c\x0c\x0c\x0c\x0c\x0c\x0c\x0c\x0c\x0c\x0c\x00\x0c\x0c\x0c\x0c\x0c\x00\x0c\x00\x0c\x0c\x0c\x18\x0c\x0c\x0c\x0c\x0c\x18\x0c\x18\x0c\x0c\x0c\x0c\x0c\x0c\x0c\x0c\x0c\x18\x0c\x0c\x0c\x0c\x0c\x18\x0c\x0c\x0c\x0c\x0c\x0c\x0c\x18\x0c\x0c\x0c\x0c\x0c\x0c\x0c\x0c\x0c\x24\x0c\x24\x0c\x0c\x0c\x24\x0c\x0c\x0c\x0c\x0c\x24\x0c\x24\x0c\x0c\x0c\x24\x0c\x0c\x0c\x0c\x0c\x0c\x0c\x0c\x0c\x0c"#


{-# INLINE steps #-}
steps :: FSM -> Addr# -> Addr# -> Word8# -> Word8#
steps (FSM tbl) start end s0 =
    loop start s0
  where
    loop pos state =
      if isTrue# (ltAddr# pos end)
      then loop (plusAddr# pos 1#) (step1 tbl state (indexWord8OffAddr# pos 0#))
      else state


{-# INLINE step1 #-}
step1 :: Addr# -> Word8# -> Word8# -> Word8#
step1 tbl state word =
  let
    !tran = indexInt8OffAddr# tbl (word2Int# (word8ToWord# word))
  in
  indexWord8OffAddr# tbl (256# +# word2Int# (word8ToWord# state) +# int8ToInt# tran)
