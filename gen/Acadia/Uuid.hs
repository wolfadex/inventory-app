{-# LANGUAGE BangPatterns, CPP, ExtendedLiterals, MagicHash, PackageImports,
QuasiQuotes, UnboxedTuples #-}
module Acadia.Uuid
  ( Uuid(..)
  --
  , toHex
  , fromHex
  --
  , toBase64
  , fromBase64
  )
  where


import "base" Prelude
import qualified Data.Array.Byte as Byte
import qualified Data.Text.Internal as Text
import Foreign.Storable
import GHC.Exts (isTrue#)
import GHC.Int (Int(I#))
import GHC.IO (IO(IO))
import GHC.Prim
import GHC.Ptr (Ptr(Ptr))
import GHC.ST (ST(ST), runST)
import GHC.Word (Word64(W64#))

#include <ghcautoconf.h>
-- to import WORDS_BIGENDIAN



-- UUID


data Uuid =
  Uuid
    {-# UNPACK #-} !Word64
    {-# UNPACK #-} !Word64
  deriving (Eq, Ord)



-- TO HEX
--
-- Using the 3AB066DD-68A0-4F00-B95E-BC56BE214BEA style


toHex :: Uuid -> Text.Text
toHex (Uuid (W64# lo) (W64# hi)) =
  runST $ ST $ \s0 ->
    case newByteArray# 36#          s0 of { (# s1, mba #) ->
    case writer mba                 s1 of {    s2         ->
    case unsafeFreezeByteArray# mba s2 of { (# s3, ba  #) ->
      (# s3, Text.Text (Byte.ByteArray ba) 0 36 #)
    }}}
  where
    writer mba s0 =
      case quad mba  0# (lo >># 48#) s0  of { s1  ->
      case quad mba  4# (lo >># 32#) s1  of { s2  ->
      case dash mba  8#              s2  of { s3  ->
      case quad mba  9# (lo >># 16#) s3  of { s4  ->
      case dash mba 13#              s4  of { s5  ->
      case quad mba 14# (lo        ) s5  of { s6  ->
      case dash mba 18#              s6  of { s7  ->
      case quad mba 19# (hi >># 48#) s7  of { s8  ->
      case dash mba 23#              s8  of { s9  ->
      case quad mba 24# (hi >># 32#) s9  of { s10 ->
      case quad mba 28# (hi >># 16#) s10 of { s11 ->
      case quad mba 32# (hi        ) s11 of { s12 ->
        s12
      }}}}}}}}}}}}

    !letters = "0123456789ABCDEF"#

    quad mba i w s0 =
      case hex mba (i      ) (w >># 12#) s0 of { s1 ->
      case hex mba (i +# 1#) (w >>#  8#) s1 of { s2 ->
      case hex mba (i +# 2#) (w >>#  4#) s2 of { s3 ->
      case hex mba (i +# 3#) (w        ) s3 of { s4 -> s4 }}}}

    dash mba i   s0 = writeWord8Array# mba i 0x2D#Word8 s0
    hex  mba i w s0 = writeWord8Array# mba i (letter w) s0

    letter w = indexWord8OffAddr# letters (mask w)
    mask   w = word2Int# (word64ToWord# (and64# 0xF#Word64 w))



-- FROM HEX


fromHex :: Text.Text -> Maybe Uuid
fromHex (Text.Text (Byte.ByteArray ba) (I# off) (I# len)) =
  if isTrue# (len ==# 36#)
  then fromHex_ ba off
  else Nothing


fromHex_ :: ByteArray# -> Int# -> Maybe Uuid
fromHex_ ba off =
  if isTrue# (ltWord64# bits 0x10000#Word64)
  && isDash 8#
  && isDash 13#
  && isDash 18#
  && isDash 23#
    then Just $! Uuid (W64# lo) (W64# hi)
    else Nothing
  where
    a = fromQuad ba (off       )
    b = fromQuad ba (off +#  4#)
    c = fromQuad ba (off +#  9#)
    d = fromQuad ba (off +# 14#)
    e = fromQuad ba (off +# 19#)
    f = fromQuad ba (off +# 24#)
    g = fromQuad ba (off +# 28#)
    h = fromQuad ba (off +# 32#)

    bits = a `or64#` b `or64#` c `or64#` d `or64#` e `or64#` f `or64#` g `or64#` h

    lo = uncheckedShiftL64# a 48# `or64#` uncheckedShiftL64# b 32# `or64#` uncheckedShiftL64# c 16# `or64#` d
    hi = uncheckedShiftL64# e 48# `or64#` uncheckedShiftL64# f 32# `or64#` uncheckedShiftL64# g 16# `or64#` h

    isDash o =
      isTrue# (eqWord8# 0x2D#Word8 (indexWord8Array# ba o))


fromQuad :: ByteArray# -> Int# -> Word64#
fromQuad ba off =
  if isTrue# (ltWord8# bits 0x10#Word8)
    then shiftL a 12# `or64#` shiftL b 8# `or64#` shiftL c 4# `or64#` shiftL d 0#
    else 0x10000#Word64
  where
    a = indexWord8OffAddr# tbl (word2Int# (word8ToWord# (indexWord8Array# ba (off       ))))
    b = indexWord8OffAddr# tbl (word2Int# (word8ToWord# (indexWord8Array# ba (off +#  1#))))
    c = indexWord8OffAddr# tbl (word2Int# (word8ToWord# (indexWord8Array# ba (off +#  2#))))
    d = indexWord8OffAddr# tbl (word2Int# (word8ToWord# (indexWord8Array# ba (off +#  3#))))

    bits = a `orWord8#` b `orWord8#` c `orWord8#` d

    !tbl =
      "\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x00\x01\x02\x03\x04\x05\x06\x07\x08\x09\x10\x10\x10\x10\x10\x10\x10\x0A\x0B\x0C\x0D\x0E\x0F\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x0A\x0B\x0C\x0D\x0E\x0F\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10"#

    shiftL w o = uncheckedShiftL64# (wordToWord64# (word8ToWord# w)) o



-- TO BASE64


toBase64 :: Uuid -> Text.Text
toBase64 (Uuid (W64# lo) (W64# hi)) =
  runST $ ST $ \s0 ->
    case newByteArray# 22#          s0 of { (# s1, mba #) ->
    case writer mba                 s1 of {    s2         ->
    case unsafeFreezeByteArray# mba s2 of { (# s3, ba  #) ->
      (# s3, Text.Text (Byte.ByteArray ba) 0 22 #)
    }}}
  where
    writer mba s0 =
      case write mba  0# (lo >># 58#)                       s0  of { s1  ->
      case write mba  1# (lo >># 52#)                       s1  of { s2  ->
      case write mba  2# (lo >># 46#)                       s2  of { s3  ->
      case write mba  3# (lo >># 40#)                       s3  of { s4  ->
      case write mba  4# (lo >># 34#)                       s4  of { s5  ->
      case write mba  5# (lo >># 28#)                       s5  of { s6  ->
      case write mba  6# (lo >># 22#)                       s6  of { s7  ->
      case write mba  7# (lo >># 16#)                       s7  of { s8  ->
      case write mba  8# (lo >># 10#)                       s8  of { s9  ->
      case write mba  9# (lo >>#  4#)                       s9  of { s10 ->
      case write mba 10# ((hi >># 62#) `or64#` (lo <<# 2#)) s10 of { s11 ->
      case write mba 11# (hi >># 56#)                       s11 of { s12 ->
      case write mba 12# (hi >># 50#)                       s12 of { s13 ->
      case write mba 13# (hi >># 44#)                       s13 of { s14 ->
      case write mba 14# (hi >># 38#)                       s14 of { s15 ->
      case write mba 15# (hi >># 32#)                       s15 of { s16 ->
      case write mba 16# (hi >># 26#)                       s16 of { s17 ->
      case write mba 17# (hi >># 20#)                       s17 of { s18 ->
      case write mba 18# (hi >># 14#)                       s18 of { s19 ->
      case write mba 19# (hi >>#  8#)                       s19 of { s20 ->
      case write mba 20# (hi >>#  2#)                       s20 of { s21 ->
      case write mba 21# (hi <<#  4#)                       s21 of { s22 ->
        s22
      }}}}}}}}}}}}}}}}}}}}}}

    !letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"#

    write mba i w s =
      writeWord8Array# mba i (indexWord8OffAddr# letters (word2Int# (word64ToWord# (and64# 0x3F#Word64 w)))) s


{-# INLINE (>>#) #-}
{-# INLINE (<<#) #-}

(>>#) :: Word64# -> Int# -> Word64#
(<<#) :: Word64# -> Int# -> Word64#

(>>#) = uncheckedShiftRL64#
(<<#) = uncheckedShiftL64#



-- FROM BASE64


fromBase64 :: Text.Text -> Maybe Uuid
fromBase64 (Text.Text (Byte.ByteArray ba) (I# off) (I# len)) =
  if isTrue# (len ==# 22#)
  then fromBase64_ ba off
  else Nothing


fromBase64_ :: ByteArray# -> Int# -> Maybe Uuid
fromBase64_ ba off =
  if isTrue# (ltWord8# bits 0x40#Word8)
  && isTrue# (andWord8# v 0xF#Word8 `eqWord8#` 0#Word8)
    then Just $! Uuid (W64# lo) (W64# hi)
    else Nothing
  where
    a = indexWord8OffAddr# tbl (word2Int# (word8ToWord# (indexWord8Array# ba (off       ))))
    b = indexWord8OffAddr# tbl (word2Int# (word8ToWord# (indexWord8Array# ba (off +#  1#))))
    c = indexWord8OffAddr# tbl (word2Int# (word8ToWord# (indexWord8Array# ba (off +#  2#))))
    d = indexWord8OffAddr# tbl (word2Int# (word8ToWord# (indexWord8Array# ba (off +#  3#))))
    e = indexWord8OffAddr# tbl (word2Int# (word8ToWord# (indexWord8Array# ba (off +#  4#))))
    f = indexWord8OffAddr# tbl (word2Int# (word8ToWord# (indexWord8Array# ba (off +#  5#))))
    g = indexWord8OffAddr# tbl (word2Int# (word8ToWord# (indexWord8Array# ba (off +#  6#))))
    h = indexWord8OffAddr# tbl (word2Int# (word8ToWord# (indexWord8Array# ba (off +#  7#))))
    i = indexWord8OffAddr# tbl (word2Int# (word8ToWord# (indexWord8Array# ba (off +#  8#))))
    j = indexWord8OffAddr# tbl (word2Int# (word8ToWord# (indexWord8Array# ba (off +#  9#))))
    k = indexWord8OffAddr# tbl (word2Int# (word8ToWord# (indexWord8Array# ba (off +# 10#))))
    l = indexWord8OffAddr# tbl (word2Int# (word8ToWord# (indexWord8Array# ba (off +# 11#))))
    m = indexWord8OffAddr# tbl (word2Int# (word8ToWord# (indexWord8Array# ba (off +# 12#))))
    n = indexWord8OffAddr# tbl (word2Int# (word8ToWord# (indexWord8Array# ba (off +# 13#))))
    o = indexWord8OffAddr# tbl (word2Int# (word8ToWord# (indexWord8Array# ba (off +# 14#))))
    p = indexWord8OffAddr# tbl (word2Int# (word8ToWord# (indexWord8Array# ba (off +# 15#))))
    q = indexWord8OffAddr# tbl (word2Int# (word8ToWord# (indexWord8Array# ba (off +# 16#))))
    r = indexWord8OffAddr# tbl (word2Int# (word8ToWord# (indexWord8Array# ba (off +# 17#))))
    s = indexWord8OffAddr# tbl (word2Int# (word8ToWord# (indexWord8Array# ba (off +# 18#))))
    t = indexWord8OffAddr# tbl (word2Int# (word8ToWord# (indexWord8Array# ba (off +# 19#))))
    u = indexWord8OffAddr# tbl (word2Int# (word8ToWord# (indexWord8Array# ba (off +# 20#))))
    v = indexWord8OffAddr# tbl (word2Int# (word8ToWord# (indexWord8Array# ba (off +# 21#))))

    !tbl =
      "\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x3E\x40\x40\x40\x3F\x34\x35\x36\x37\x38\x39\x3A\x3B\x3C\x3D\x40\x40\x40\x40\x40\x40\x40\x00\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0A\x0B\x0C\x0D\x0E\x0F\x10\x11\x12\x13\x14\x15\x16\x17\x18\x19\x40\x40\x40\x40\x40\x40\x1A\x1B\x1C\x1D\x1E\x1F\x20\x21\x22\x23\x24\x25\x26\x27\x28\x29\x2A\x2B\x2C\x2D\x2E\x2F\x30\x31\x32\x33\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40\x40"#

    !bits =
      a `orWord8#` b `orWord8#` c `orWord8#` d `orWord8#`
      e `orWord8#` f `orWord8#` g `orWord8#` h `orWord8#`
      i `orWord8#` j `orWord8#` k `orWord8#` l `orWord8#`
      m `orWord8#` n `orWord8#` o `orWord8#` p `orWord8#`
      q `orWord8#` r `orWord8#` s `orWord8#` t `orWord8#`
      u `orWord8#` v

    shiftL w offset = uncheckedShiftL64#  (wordToWord64# (word8ToWord# w)) offset
    shiftR w offset = uncheckedShiftRL64# (wordToWord64# (word8ToWord# w)) offset

    !lo =
        shiftL a 58# `or64#`
        shiftL b 52# `or64#`
        shiftL c 46# `or64#`
        shiftL d 40# `or64#`
        shiftL e 34# `or64#`
        shiftL f 28# `or64#`
        shiftL g 22# `or64#`
        shiftL h 16# `or64#`
        shiftL i 10# `or64#`
        shiftL j  4# `or64#`
        shiftR k  2#

    !hi =
        shiftL k 62# `or64#`
        shiftL l 56# `or64#`
        shiftL m 50# `or64#`
        shiftL n 44# `or64#`
        shiftL o 38# `or64#`
        shiftL p 32# `or64#`
        shiftL q 26# `or64#`
        shiftL r 20# `or64#`
        shiftL s 14# `or64#`
        shiftL t  8# `or64#`
        shiftL u  2# `or64#`
        shiftR v  4#



-- STORABLE


instance Storable Uuid where
  sizeOf _ = 16
  alignment _ = 1

  peekByteOff (Ptr ptr) (I# off) =
    do  let !addr = plusAddr# ptr off
        x <- getWord64_BE addr 0#
        y <- getWord64_BE addr 1#
        return $ Uuid x y

  pokeByteOff (Ptr ptr) (I# off) (Uuid (W64# x) (W64# y)) =
    do  let !addr = plusAddr# ptr off
        setWord64_BE addr 0# x
        setWord64_BE addr 1# y


{-# INLINE getWord64_BE #-}
{-# INLINE setWord64_BE #-}

getWord64_BE :: Addr# -> Int# -> IO Word64
setWord64_BE :: Addr# -> Int# -> Word64# -> IO ()

#if defined(WORDS_BIGENDIAN)
getWord64_BE a i   = IO $ \s0 -> case readWord64OffAddr#  a i   s0 of { (# s1, w #) -> (# s1, W64# w #) }
setWord64_BE a i w = IO $ \s0 -> case writeWord64OffAddr# a i w s0 of {    s1       -> (# s1, ()     #) }
#else
getWord64_BE a i   = IO $ \s0 -> case readWord64OffAddr#  a i                 s0 of { (# s1, w #) -> (# s1, W64# (byteSwap64# w) #) }
setWord64_BE a i w = IO $ \s0 -> case writeWord64OffAddr# a i (byteSwap64# w) s0 of {    s1       -> (# s1, ()                   #) }
#endif
