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
import Control.Monad
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
import Data.Monoid
import Data.Text (Text)
import Data.Text qualified as Text
import Data.Text.Encoding qualified as TextEncoding
import Data.Text.Lazy qualified as TextLazy
import Data.Time.Calendar
import Data.Time.Clock
import Debug.Trace
import GHC.Generics
import GHC.Records (getField)
import Network.HTTP.Client.Conduit qualified as HTTPC
import Network.HTTP.Simple qualified as HTTP
import Network.HTTP.Types.Status
import Network.Wai
import Network.Wai.Handler.Warp
import Prelude.Compat
import Serialize ((&))
import Serialize qualified
import Servant
import Servant.API qualified
import System.Directory
import Web.Cookie
import Web.Scotty
import Web.Scotty.Cookie
import Prelude ()

-- type AppAPI = "api" :> AuthAPI -- :<|> OrganizationAPI)

-- type AuthAPI =
--   "auth"
--     :> ( "authenticate" :> ReqBody '[OctetStream] ByteString :> Header "Cookie" Text :> Post '[OctetStream] (Headers '[Header "Set-Cookie" SetCookie] ByteString)
--            :<|> "self" :> Header "Cookie" Text :> Post '[OctetStream] (Headers '[Header "Set-Cookie" SetCookie] ByteString)
--        )

-- -- type OrganizationAPI = "organizations" :> Get '[JSON] [User]

-- -- ENDPOINTS

-- authenticate :: ByteString -> Maybe Text -> Handler (Headers '[Header "Set-Cookie" SetCookie] ByteString)
-- authenticate input cookies = do
--   result <- liftIO $ Serialize.decodeFromBytes authInfoCodec input
--   case result of
--     Err error -> throwError $ err400 {errBody = "Bad body"}
--     Ok authArgs -> do
--       let email = getField @"email" authArgs
--       let password = getField @"password" authArgs
--       if Text.length email < 3
--         then
--           throwError $ err400 {errBody = "Invalid email"}
--         else
--           if Text.length password < 8
--             then
--               throwError $ err400 {errBody = "Invalid password"}
--             else do
--               (resp, cookies_) <- acadiaRequest cookies $ Backend.authenticate authArgs
--               acadiaResponse (Serialize.encodeToBytes authenticateCodec resp, Debug.Trace.trace ("Cookies: " <> show cookies_) cookies_)

-- self :: Maybe Text -> Handler (Headers '[Header "Set-Cookie" SetCookie] ByteString)
-- self cookies = do
--   (resp, cookies_) <- acadiaRequest cookies Backend.getUserSelf
--   -- pure $ Serialize.encodeToBytes getUserSelfCodec resp
--   acadiaResponse (Serialize.encodeToBytes getUserSelfCodec resp, cookies_)

-- HELPERS

-- acadiaResponse :: (ByteString, [SetCookie]) -> Handler (Headers '[Header "Set-Cookie" SetCookie] ByteString)
-- acadiaResponse (respData, cookies_) =
--   pure $ case cookies_ of
--     [] -> Servant.API.noHeader respData
--     cookie : _ -> Servant.API.addHeader cookie respData

-- acadiaRequest :: Maybe Text -> Acadia.Transaction.Transaction a -> Handler (a, [SetCookie])
-- acadiaRequest maybeCookies (Acadia.Transaction.Transaction postBody decoder) = do
--   response <-
--     HTTP.parseRequest_ "http://localhost:9000"
--       & HTTP.setRequestMethod "POST"
--       & HTTP.setRequestBodyLBS (BB.toLazyByteString postBody)
--       & HTTP.setRequestHeader "Cookie" [TextEncoding.encodeUtf8 $ Maybe.fromMaybe "" maybeCookies]
--       & HTTP.httpBS
--   let body = HTTP.getResponseBody response
--   value <- liftIO $ Acadia.Bytes.Decode.fromByteString decoder body
--   case value of
--     Nothing -> throwError $ err500 {errBody = "Database error"}
--     Just a -> pure (a, cookieJarToSetCookies $ (\j -> Debug.Trace.trace ("Jar: " <> show j) j) $ HTTPC.responseCookieJar response)

-- acadiaResponse :: (ByteString, [SetCookie]) -> Handler (Headers '[Header "Set-Cookie" SetCookie] ByteString)
-- acadiaResponse (respData, cookies_) =
--   pure $ case cookies_ of
--     [] -> Servant.API.noHeader respData
--     cookie : _ -> Servant.API.addHeader cookie respData

-- acadiaRequest :: Maybe Text -> Acadia.Transaction.Transaction a -> Handler (a, HTTPC.CookieJar)
-- acadiaRequest maybeCookies (Acadia.Transaction.Transaction postBody decoder) = do
--   response <-
--     HTTP.parseRequest_ "http://localhost:9000"
--       & HTTP.setRequestMethod "POST"
--       & HTTP.setRequestBodyLBS (BB.toLazyByteString postBody)
--       & HTTP.setRequestHeader "Cookie" [TextEncoding.encodeUtf8 $ Maybe.fromMaybe "" maybeCookies]
--       & HTTP.httpBS
--   let body = HTTP.getResponseBody response
--   value <- liftIO $ Acadia.Bytes.Decode.fromByteString decoder body
--   case value of
--     Nothing -> throwError $ err500 {errBody = "Database error"}
--     Just a -> pure (a, cookieJarToSetCookies $ (\j -> Debug.Trace.trace ("Jar: " <> show j) j) $ HTTPC.responseCookieJar response)

-- cookieJarToSetCookies :: HTTPC.CookieJar -> [SetCookie]
-- cookieJarToSetCookies jar =
--   map toSetCookie (HTTPC.destroyCookieJar jar)
--   where
--     toSetCookie c =
--       defaultSetCookie
--         { setCookieName = HTTPC.cookie_name c,
--           setCookieValue = HTTPC.cookie_value c,
--           setCookiePath = Just (HTTPC.cookie_path c),
--           setCookieDomain = Just (HTTPC.cookie_domain c),
--           setCookieExpires = Just $ HTTPC.cookie_expiry_time c,
--           setCookieSecure = HTTPC.cookie_secure_only c,
--           setCookieHttpOnly = HTTPC.cookie_http_only c
--         }

-- SERVANT

-- server :: Server AppAPI
-- server =
--   authenticate :<|> self

-- userAPI :: Proxy AppAPI
-- userAPI = Proxy

-- app :: Application
-- app = serve userAPI server

startServer :: IO ()
startServer =
  -- run 8000 app
  scotty 8000 $ do
    post "/api/auth/self" $ do
      user <- fmap (Maybe.fromMaybe "") $ getCookie "u"
      resp <- acadiaRequest (Debug.Trace.trace ("User?: " <> show user) user) $ Backend.getUserSelf
      case resp of
        Nothing -> do
          status status500
          text "Database error"
        Just (resp_, cookies_) -> do
          setHeader "Cookie" $ TextLazy.pack $ show cookies_
          raw $ BSL.fromStrict $ Serialize.encodeToBytes getUserSelfCodec resp_

    post "/api/auth/authenticate" $ do
      -- let carl = Debug.Trace.trace "55" 55
      -- input <- body
      -- result <- liftIO $ Serialize.decodeFromBytes authInfoCodec $ BSL.toStrict $ Debug.Trace.trace ("Input: " <> show input) input
      -- case result of
      --   Err error -> do
      --     status status400
      --     text "Bad body"
      --   Ok authArgs -> do
      --     let email = properDebug "email" $ getField @"email" authArgs
      --     let password = properDebug "pass" $ getField @"password" authArgs
      --     if Text.length email < 3
      --       then do
      --         status status400
      --         text "Invalid email"
      --       else
      --         if Text.length password < 8
      --           then do
      --             status status400
      --             text "Invalid password"
      --           else do
      --             user <- fmap (Maybe.fromMaybe "") $ getCookie "u"
      --             resp <- acadiaRequest user $ Backend.authenticate authArgs
      --             case resp of
      --               Nothing -> do
      --                 status status500
      --                 text "Database error"
      --               Just (resp_, cookies_) -> do
      --                 setHeader "Cookie" $ TextLazy.pack $ Debug.Trace.trace ("Cook??" <> show cookies_) $ show cookies_
      --                 raw $ BSL.fromStrict $ Serialize.encodeToBytes authenticateCodec resp_
      let (Acadia.Transaction.Transaction bod dec) = Backend.authenticate (Record2 "wolfadex@gmail.com" "1234asdf")
      response <-
        HTTP.parseRequest_ "http://localhost:9000"
          & HTTP.setRequestMethod "POST"
          & HTTP.setRequestBodyLBS (BB.toLazyByteString bod)
          -- & HTTP.setRequestHeader "Cookie" [TextEncoding.encodeUtf8 cookie]
          & properDebug "req"
          & HTTP.httpBS
      -- let body = HTTP.getResponseBody (properDebug "resp" response)
      let carl = properDebug "jeff" response
      text "CARL"

acadiaRequest :: Text -> Acadia.Transaction.Transaction a -> ActionM (Maybe (a, HTTPC.CookieJar))
acadiaRequest cookie (Acadia.Transaction.Transaction postBody decoder) = do
  response <-
    HTTP.parseRequest_ "http://localhost:9000"
      & HTTP.setRequestMethod "POST"
      & HTTP.setRequestBodyLBS (BB.toLazyByteString $ properDebug "postBody" postBody)
      & HTTP.setRequestHeader "Cookie" [TextEncoding.encodeUtf8 cookie]
      & properDebug "req"
      & HTTP.httpBS
  let body = HTTP.getResponseBody (properDebug "resp" response)
  value <- liftIO $ Acadia.Bytes.Decode.fromByteString decoder body
  pure $ fmap (\a -> (a, HTTPC.responseCookieJar response)) value

properDebug :: (Show a) => String -> a -> a
properDebug tag a =
  Debug.Trace.trace (tag <> ": " <> show a) a

-- case value of
--   Nothing -> do
--     status 500
--     text "Database error"
--   Just a -> pure (a, HTTPC.responseCookieJar response)

-- acadiaResponse :: (ByteString, [SetCookie]) -> Handler (Headers '[Header "Set-Cookie" SetCookie] ByteString)
-- acadiaResponse (respData, cookies_) =
--   pure $ case cookies_ of
--     [] -> Servant.API.noHeader respData
--     cookie : _ -> Servant.API.addHeader cookie respData

-- cookieJarToSetCookies :: HTTPC.CookieJar -> [SetCookie]
-- cookieJarToSetCookies jar =
--   map toSetCookie (HTTPC.destroyCookieJar jar)
--   where
--     toSetCookie c =
--       defaultSetCookie
--         { setCookieName = HTTPC.cookie_name c,
--           setCookieValue = HTTPC.cookie_value c,
--           setCookiePath = Just (HTTPC.cookie_path c),
--           setCookieDomain = Just (HTTPC.cookie_domain c),
--           setCookieExpires = Just $ HTTPC.cookie_expiry_time c,
--           setCookieSecure = HTTPC.cookie_secure_only c,
--           setCookieHttpOnly = HTTPC.cookie_http_only c
--         }