{-# LANGUAGE ImportQualifiedPost #-}

module Acadia.Api (authenticateCodec) where

import Serialize
import Serialize ((&))
import Backend qualified
import Acadia.Records

authenticateCodec :: Codec e Backend.AuthInfo
authenticateCodec =
    record Record2
    & field (\(Record2 email _) -> email) string
    & field (\(Record2 _ password) -> password) string
    & finishRecord