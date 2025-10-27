{-# LANGUAGE DataKinds #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeOperators #-}


module Lib
    ( startServer
    ) where


import qualified Acadia.Transaction
import qualified Backend

import Prelude ()
import Prelude.Compat

import Control.Monad.Except
import Control.Monad.Reader
import Data.Aeson
import Data.Aeson.Types
-- import Data.Attoparsec.ByteString
import Data.ByteString (ByteString)
import Data.List
import Data.Maybe (Maybe)
import qualified Data.Maybe as Maybe
-- import Data.String.Conversions
import Data.Time.Calendar
import Data.Time.Clock
import GHC.Generics
-- import Network.HTTP.Media ((//), (/:))
import Network.Wai
import Network.Wai.Handler.Warp
import Servant
-- import Servant.API
import System.Directory
-- import Servant.Types.SourceT (source)




type AppAPI = "api" :> (AuthAPI :<|> OrganizationAPI)

type AuthAPI = "auth" :>
    (    "authenticate" :> Get '[JSON] (Backend.User, Maybe Backend.Organization)
    :<|> "user" :> Get '[JSON] (Backend.User, Maybe Backend.Organization)
    )

type OrganizationAPI = "organizations" :> Get '[JSON] [User]

data User = User {
  name :: String,
  age :: Int,
  email :: String
} deriving (Show, Generic)

instance ToJSON User

authenticate :: (Backend.User, Maybe Backend.Organization)
authenticate =
    Backend.
  [ User "Isaac Newton"    372 "isaac@newton.co.uk"
  , User "Albert Einstein" 136 "ae@mc2.org"
  ]

organization :: [User]
organization =
    [ User "Isaac Newton"    372 "isaac@newton.co.uk"
    ]

server :: Server AppAPI
server = pure authenticate
    :<|> pure organization

userAPI :: Proxy AppAPI
userAPI = Proxy

app1 :: Application
app1 = serve userAPI server

startServer :: IO ()
startServer = run 8000 app1