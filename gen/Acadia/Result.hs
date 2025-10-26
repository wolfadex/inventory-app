{-# LANGUAGE PatternSynonyms #-}
module Acadia.Result
  ( Result(Ok, Err)
  , toEither
  , fromEither
  )
  where


import Data.Coerce (coerce)


-- NOTE: Result is defined in a funny way so that you can use `coerce` to
-- convert to `Either` without any overhead. For example:
--
--   convertList :: [Result x a] -> [Either x a]
--   convertList = coerce
--
--   convertDict :: Map.Map k (Result x a) -> Map.Map k (Either x a)
--   convertDict = coerce
--


newtype Result x a = Result (Either x a)

{-# INLINE Ok #-}
pattern Ok :: a -> Result x a
pattern Ok a = Result (Right a)

{-# INLINE Err #-}
pattern Err :: x -> Result x a
pattern Err x = Result (Left x)

{-# COMPLETE Ok, Err #-}


{-# INLINE toEither #-}
toEither :: Result x a -> Either x a
toEither =
  coerce


{-# INLINE fromEither #-}
fromEither :: Either x a -> Result x a
fromEither =
  coerce
