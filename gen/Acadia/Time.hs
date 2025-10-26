{-# LANGUAGE PackageImports #-}
module Acadia.Time
  ( Posix
  , toPostgresMicroseconds
  , fromPostgresMicroseconds
  )
  where


import "base" Prelude
import Data.Word (Word64)



-- POSIX


newtype Posix = Posix Word64
  deriving (Eq, Ord)



-- POSTGRES MICROSECONDS


toPostgresMicroseconds :: Posix -> Word64
toPostgresMicroseconds (Posix t) =
  t


fromPostgresMicroseconds :: Word64 -> Posix
fromPostgresMicroseconds us =
  Posix us


