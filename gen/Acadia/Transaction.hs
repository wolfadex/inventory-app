module Acadia.Transaction (Transaction(..)) where

import qualified Data.ByteString.Builder as B
import qualified Acadia.Bytes.Decode as D

data Transaction a =
  Transaction B.Builder (D.Decoder a)

