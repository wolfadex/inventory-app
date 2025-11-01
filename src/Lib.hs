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
import Data.Text (Text)
import Data.Text qualified as Text
import Data.Text.Encoding qualified as TextEncoding
import Data.Time.Calendar
import Data.Time.Clock
import Debug.Trace
import GHC.Generics
import GHC.Records (getField)
import Network.HTTP.Client.Conduit qualified as HTTPC
import Network.HTTP.Simple qualified as HTTP
import Network.Wai
import Network.Wai.Handler.Warp
import Prelude.Compat
import Serialize ((&))
import Serialize qualified
import Servant
import Servant.API qualified
import System.Directory
import Web.Cookie
import Prelude ()

type AppAPI = "api" :> AuthAPI -- :<|> OrganizationAPI)

type AuthAPI =
  "auth"
    :> ( "authenticate" :> ReqBody '[OctetStream] ByteString :> Header "Cookie" Text :> Post '[OctetStream] (Headers '[Header "Set-Cookie" SetCookie] ByteString)
           :<|> "self" :> Header "Cookie" Text :> Post '[OctetStream] (Headers '[Header "Set-Cookie" SetCookie] ByteString)
       )

-- type OrganizationAPI = "organizations" :> Get '[JSON] [User]

-- ENDPOINTS

authenticate :: ByteString -> Maybe Text -> Handler (Headers '[Header "Set-Cookie" SetCookie] ByteString)
authenticate input cookies = do
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
              (resp, cookies_) <- acadiaRequest cookies $ Backend.authenticate authArgs
              acadiaResponse (Serialize.encodeToBytes authenticateCodec resp, Debug.Trace.trace ("Cookies: " <> show cookies_) cookies_)

self :: Maybe Text -> Handler (Headers '[Header "Set-Cookie" SetCookie] ByteString)
self cookies = do
  (resp, cookies_) <- acadiaRequest cookies Backend.getUserSelf
  -- pure $ Serialize.encodeToBytes getUserSelfCodec resp
  acadiaResponse (Serialize.encodeToBytes getUserSelfCodec resp, cookies_)

-- HELPERS

acadiaResponse :: (ByteString, [SetCookie]) -> Handler (Headers '[Header "Set-Cookie" SetCookie] ByteString)
acadiaResponse (respData, cookies_) =
  pure $ case cookies_ of
    [] -> Servant.API.noHeader respData
    cookie : _ -> Servant.API.addHeader cookie respData

acadiaRequest :: Maybe Text -> Acadia.Transaction.Transaction a -> Handler (a, [SetCookie])
acadiaRequest maybeCookies (Acadia.Transaction.Transaction postBody decoder) = do
  response <-
    HTTP.parseRequest_ "http://localhost:9000"
      & HTTP.setRequestMethod "POST"
      & HTTP.setRequestBodyLBS (BB.toLazyByteString postBody)
      & HTTP.setRequestHeader "Cookie" [TextEncoding.encodeUtf8 $ Maybe.fromMaybe "" maybeCookies]
      & HTTP.httpBS
  let body = HTTP.getResponseBody response
  value <- liftIO $ Acadia.Bytes.Decode.fromByteString decoder body
  case value of
    Nothing -> throwError $ err500 {errBody = "Database error"}
    Just a -> pure (a, cookieJarToSetCookies $ (\j -> Debug.Trace.trace ("Jar: " <> show j) j) $ HTTPC.responseCookieJar response)

cookieJarToSetCookies :: HTTPC.CookieJar -> [SetCookie]
cookieJarToSetCookies jar =
  map toSetCookie (HTTPC.destroyCookieJar jar)
  where
    toSetCookie c =
      defaultSetCookie
        { setCookieName = HTTPC.cookie_name c,
          setCookieValue = HTTPC.cookie_value c,
          setCookiePath = Just (HTTPC.cookie_path c),
          setCookieDomain = Just (HTTPC.cookie_domain c),
          setCookieExpires = Just $ HTTPC.cookie_expiry_time c,
          setCookieSecure = HTTPC.cookie_secure_only c,
          setCookieHttpOnly = HTTPC.cookie_http_only c
        }

-- SERVANT

server :: Server AppAPI
server =
  authenticate :<|> self

userAPI :: Proxy AppAPI
userAPI = Proxy

app :: Application
app = serve userAPI server

startServer :: IO ()
startServer = run 8000 app