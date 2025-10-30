{-# LANGUAGE DataKinds #-}
{-# LANGUAGE ImportQualifiedPost #-}

module Acadia.Api
  ( authInfoCodec,
    authenticateCodec,
    getUserSelfCodec,
  )
where

import Acadia.Records
import Backend qualified
import Data.Text (Text)
import Serialize
import Serialize ((&))

authenticateCodec :: Codec e ()
authenticateCodec =
  unit

authInfoCodec :: Codec e Backend.AuthInfo
authInfoCodec =
  record Record2
    & field (\(Record2 email _) -> email) string
    & field (\(Record2 _ password) -> password) string
    & finishRecord

getUserSelfCodec :: Codec e (Backend.User, Maybe Backend.Organization)
getUserSelfCodec =
  tuple userCodec (Serialize.maybe organizationCodec)

userCodec :: Codec e Backend.User
userCodec =
  record Record2
    & field (\(Record2 id _) -> id) userIdCodec
    & field (\(Record2 _ primaryEmail) -> primaryEmail) string
    & finishRecord

userIdCodec :: Codec e Backend.UserID
userIdCodec =
  customType (\enc (Backend.UserID val) -> enc val)
    & variant1 Backend.UserID uuid
    & finishCustomType

organizationCodec :: Codec e Backend.Organization
organizationCodec =
  record Record2
    & field (\(Record2 id _) -> id) organizationIdCodec
    & field (\(Record2 _ name) -> name) string
    & finishRecord

organizationIdCodec :: Codec e Backend.OrganizationID
organizationIdCodec =
  customType (\enc (Backend.OrganizationID val) -> enc val)
    & variant1 Backend.OrganizationID uuid
    & finishCustomType

createOrganizationCodec :: Codec e (Record1 "name" Text)
createOrganizationCodec =
  record Record1
    & field (\(Record1 name) -> name) string
    & finishRecord
