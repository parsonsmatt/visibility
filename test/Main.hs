{-# language TypeApplications, TemplateHaskell #-}

module Main where

import DiscoverInstances
import Language.Haskell.TH
import Data.Foldable
import Data.Typeable
import Cls
import Lib

import C

do
    instances <- reifyInstances ''Cls [VarT (mkName "a")]
    runIO $ for_ instances $ \instanceDec -> do
        print instanceDec
    pure []

do
    runIO $ forInstances $$(discoverInstances @Cls) $ \prxy -> do
        print $ typeOf prxy
    pure []

main :: IO ()
main = do
    putStrLn " ~ * ~ * ~ instances discovered in main ~ * ~ * ~"
    mainStrs <- forInstances $$(discoverInstances @Cls) $ \prxy -> do
        print $ typeOf prxy
        pure $ show $ typeOf prxy

    putStrLn " ~ * ~ * ~ instances discovered in lib ~ * ~ * ~"

    libStrs <- libMain

    if mainStrs /= libStrs
        then error "test failed as instances differ"
        else pure ()
