{-# LANGUAGE KindSignatures #-}
module Acadia.Records where
import GHC.Records (HasField(getField))
import GHC.TypeLits (Symbol)

data Record1 (k1 :: Symbol) v1 = Record1 v1
instance HasField k1 (Record1 k1 v1) v1 where getField (Record1 v) = v

data Record2 (k1 :: Symbol) v1 (k2 :: Symbol) v2 = Record2 v1 v2
instance HasField k1 (Record2 k1 v1 k2 v2) v1 where getField (Record2 v _) = v
instance HasField k2 (Record2 k1 v1 k2 v2) v2 where getField (Record2 _ v) = v

data Record3 (k1 :: Symbol) v1 (k2 :: Symbol) v2 (k3 :: Symbol) v3 = Record3 v1 v2 v3
instance HasField k1 (Record3 k1 v1 k2 v2 k3 v3) v1 where getField (Record3 v _ _) = v
instance HasField k2 (Record3 k1 v1 k2 v2 k3 v3) v2 where getField (Record3 _ v _) = v
instance HasField k3 (Record3 k1 v1 k2 v2 k3 v3) v3 where getField (Record3 _ _ v) = v

data Record4 (k1 :: Symbol) v1 (k2 :: Symbol) v2 (k3 :: Symbol) v3 (k4 :: Symbol) v4 = Record4 v1 v2 v3 v4
instance HasField k1 (Record4 k1 v1 k2 v2 k3 v3 k4 v4) v1 where getField (Record4 v _ _ _) = v
instance HasField k2 (Record4 k1 v1 k2 v2 k3 v3 k4 v4) v2 where getField (Record4 _ v _ _) = v
instance HasField k3 (Record4 k1 v1 k2 v2 k3 v3 k4 v4) v3 where getField (Record4 _ _ v _) = v
instance HasField k4 (Record4 k1 v1 k2 v2 k3 v3 k4 v4) v4 where getField (Record4 _ _ _ v) = v

