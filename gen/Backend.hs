{-# OPTIONS_GHC -fno-warn-unused-imports -fno-warn-missing-signatures #-}
{-# LANGUAGE DataKinds, OverloadedRecordDot #-}
module Backend(UserID(..),OrganizationID(..),FoodID(..),RoleID(..),SuperUser(..),Food,User,Organization,Role,Session,UserRow,Permission,OrganizationRow,OrganizationUsers,logout,addFood,getFoods,getUserSelf,authenticate,createOrganization) where

import qualified Acadia.Bytes.Decode as D
import qualified Acadia.Bytes.Encode as E
import qualified Acadia.Password as Password
import qualified Acadia.Records
import qualified Acadia.Result as Result
import qualified Acadia.Time as Time
import qualified Acadia.Transaction
import qualified Acadia.Uuid as Uuid
import qualified Data.Int as Int
import qualified Data.Maybe as Maybe
import qualified Data.Text as Text
import qualified Data.Word as Word

type Food =
  Acadia.Records.Record4 "id" FoodID "name" Text.Text "owningOrganization" OrganizationID "createdBy" UserID

type User =
  Acadia.Records.Record2 "id" Uuid.Uuid "primaryEmail" Text.Text

type Organization =
  Acadia.Records.Record2 "id" Uuid.Uuid "name" Text.Text

type Role =
  Acadia.Records.Record2 "id" RoleID "food" Permission

type Session =
  Acadia.Records.Record4 "cookie" Uuid.Uuid "user" UserID "organization" (Maybe.Maybe OrganizationID) "expires" Time.Posix

type UserRow =
  Acadia.Records.Record4 "id" UserID "pw_hash" Password.Hash "created" Time.Posix "primaryEmail" Text.Text

type Permission =
  Acadia.Records.Record4 "create" Bool "read" Bool "update" Bool "delete" Bool

type OrganizationRow =
  Acadia.Records.Record3 "id" OrganizationID "owner" UserID "name" Text.Text

type OrganizationUsers =
  Acadia.Records.Record3 "organizationID" OrganizationID "userID" UserID "roleID" RoleID

newtype UserID =
  UserID Uuid.Uuid

newtype OrganizationID =
  OrganizationID Uuid.Uuid

newtype FoodID =
  FoodID Uuid.Uuid

newtype RoleID =
  RoleID Uuid.Uuid

data SuperUser =
  SuperUser

e_ARG_0 =
  \s -> E.sequence [E.uint32BE (E.getSizeString s),E.string s]

e_ARG_2 =
  \v -> 
  let
    v_name = v.name
    o0 = 0
    o1 = o0 + E.getSizeString v_name
    e0 = E.string v_name
  in
  E.sequence [E.uint32BE o1,e0]

e_ARG_1 =
  \v -> 
  let
    v_email = v.email
    v_password = v.password
    o0 = 4
    o1 = o0 + E.getSizeString v_email
    e0 = E.string v_email
    o2 = o1 + E.getSizeString v_password
    e1 = E.string v_password
  in
  E.sequence [E.uint32BE o2,E.uint32LE o1,e0,e1]

d_ARG_1 =
  D.andThen (\n -> if n < (0 :: Int32) then D.fail else D.string (fromIntegral n)) D.int32BE

d_ARG_4 =
  D.andThen (\n -> if n /= (16 :: Int32) then D.fail else D.uuid) D.int32BE

d_ARG_0 =
  D.andThen (\n -> if n /= (0 :: Int32) then D.fail else D.succeed ()) D.int32BE

d_ARG_2 =
  D.andThen (\n -> if n < (16 :: Int32) then D.fail else D.andThen (\x_id -> 
  let
    o0 = 16
  in
  D.andThen (\x_primaryEmail -> D.succeed (Acadia.Records.Record2 x_id x_primaryEmail)) (D.string (fromIntegral n - o0))) D.uuid) D.int32BE

d_ARG_3 =
  D.andThen (\n -> if n < (1 :: Int32) then D.fail else d_VARIANT_0 (fromIntegral n)) D.int32BE

d_VARIANT_0 =
  \size -> D.andThen (\tag -> 
  case tag of
    0 -> if size < (17 :: Word32) then D.fail else D.andThen (\x_0_id -> 
      let
        o0 = 17
      in
      D.andThen (\x_0_name -> D.succeed (Maybe.Just (Acadia.Records.Record2 x_0_id x_0_name))) (D.string (size - o0))) D.uuid
    1 -> if size /= (1 :: Word32) then D.fail else D.succeed Maybe.Nothing
    _ -> D.fail) D.uint8

logout :: Acadia.Transaction.Transaction ()
logout =
  Acadia.Transaction.Transaction (E.sequence [E.uint32BE 0,E.uint32BE 0]) (D.succeed ())

addFood :: Text.Text -> Acadia.Transaction.Transaction ()
addFood =
  \v0 -> Acadia.Transaction.Transaction (E.sequence [E.uint32BE 0,E.uint32BE 1,e_ARG_0 v0]) d_ARG_0

getFoods :: Acadia.Transaction.Transaction [Text.Text]
getFoods =
  Acadia.Transaction.Transaction (E.sequence [E.uint32BE 0,E.uint32BE 2]) (D.list d_ARG_1)

getUserSelf :: Acadia.Transaction.Transaction (User,Maybe.Maybe Organization)
getUserSelf =
  Acadia.Transaction.Transaction (E.sequence [E.uint32BE 0,E.uint32BE 3]) (D.map2 (\a b -> (a,b)) d_ARG_2 d_ARG_3)

authenticate :: Acadia.Records.Record2 "email" Text.Text "password" Text.Text -> Acadia.Transaction.Transaction ()
authenticate =
  \v0 -> Acadia.Transaction.Transaction (E.sequence [E.uint32BE 0,E.uint32BE 4,e_ARG_1 v0]) (D.succeed ())

createOrganization :: Acadia.Records.Record1 "name" Text.Text -> Acadia.Transaction.Transaction Organization
createOrganization =
  \v0 -> Acadia.Transaction.Transaction (E.sequence [E.uint32BE 0,E.uint32BE 5,e_ARG_2 v0]) (D.andThen (\id -> D.andThen (\name -> D.succeed (Acadia.Records.Record2 id name)) d_ARG_1) d_ARG_4)

