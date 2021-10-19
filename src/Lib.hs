{-# language TemplateHaskell, TypeApplications #-}

module Lib where

import Cls
import C ()
import Data.Foldable
import DiscoverInstances
import Data.Typeable

import Language.Haskell.TH

do
    instances <- reifyInstances ''Cls [VarT (mkName "a")]
    runIO $ for_ instances $ \instanceDec -> do
        print instanceDec
    pure []

do
    runIO $ forInstances $$(discoverInstances @Cls) $ \prxy -> do
        print $ typeOf prxy
    pure []

libMain :: IO [String]
libMain = do
    forInstances $$(discoverInstances @Cls) $ \prxy -> do
        print $ typeOf prxy
        pure (show (typeOf prxy))
