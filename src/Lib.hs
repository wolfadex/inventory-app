{-# LANGUAGE DataKinds #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE ImportQualifiedPost #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeApplications #-}
{-# LANGUAGE TypeOperators #-}

module Lib
  ( startServer,
  )
where

import Acadia.Api
import Acadia.Bytes.Decode qualified
import Acadia.Records
import Acadia.Result
import Acadia.Transaction qualified
import Backend qualified
import Control.Monad.Except
import Control.Monad.Reader
import Data.Aeson
import Data.Aeson.Types
import Data.ByteString (ByteString)
import Data.ByteString qualified as BS
import Data.ByteString.Builder qualified as BB
import Data.ByteString.Lazy qualified as BSL
import Data.List
import Data.Maybe (Maybe)
import Data.Maybe qualified as Maybe
import Data.Text qualified as Text
import Data.Time.Calendar
import Data.Time.Clock
import Debug.Trace
import GHC.Generics
import GHC.Records (getField)
import Network.HTTP.Simple qualified as HTTP
import Network.Wai
import Network.Wai.Handler.Warp
import Prelude.Compat
import Serialize ((&))
import Serialize qualified
import Servant
import System.Directory
import Prelude ()

type AppAPI = "api" :> AuthAPI -- :<|> OrganizationAPI)

type AuthAPI =
  "auth"
    :> ( "authenticate" :> ReqBody '[OctetStream] ByteString :> Post '[OctetStream] ByteString
           :<|> "self" :> Post '[OctetStream] ByteString
       )

-- type OrganizationAPI = "organizations" :> Get '[JSON] [User]

authenticate :: ByteString -> Handler ByteString
authenticate input = do
  result <- liftIO $ Serialize.decodeFromBytes authInfoCodec input
  case result of
    Err error -> throwError $ err400 {errBody = "Bad body"}
    Ok authArgs -> do
      let email = getField @"email" authArgs
      let password = getField @"password" authArgs
      if Text.length email < 3
        then
          throwError $ err400 {errBody = "Invalid email"}
        else
          if Text.length password < 8
            then
              throwError $ err400 {errBody = "Invalid password"}
            else do
              resp <- acadiaRequest $ Backend.authenticate authArgs
              pure $ Serialize.encodeToBytes authenticateCodec resp

self :: Handler ByteString
self = do
  resp <- acadiaRequest Backend.getUserSelf
  pure $ Serialize.encodeToBytes getUserSelfCodec resp

acadiaRequest :: Acadia.Transaction.Transaction a -> Handler a
acadiaRequest (Acadia.Transaction.Transaction postBody decoder) = do
  response <-
    HTTP.parseRequest_ "http://localhost:9000"
      & HTTP.setRequestMethod "POST"
      & HTTP.setRequestBodyLBS (BB.toLazyByteString postBody)
      & HTTP.httpBS
  let body = HTTP.getResponseBody response
  value <- liftIO $ Acadia.Bytes.Decode.fromByteString decoder body
  case value of
    Nothing -> throwError $ err500 {errBody = "Database error"}
    Just a -> pure a

server :: Server AppAPI
server =
  authenticate :<|> self

userAPI :: Proxy AppAPI
userAPI = Proxy

app :: Application
app = serve userAPI server

startServer :: IO ()
startServer = run 8000 app