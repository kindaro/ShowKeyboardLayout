#!/usr/bin/env runhaskell

{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ExtendedDefaultRules #-}
{-# OPTIONS_GHC -fno-warn-type-defaults #-}

module Main where

import Control.Arrow

import Shelly
import qualified Data.Text as T
import qualified Data.Text.IO as TIO
default (T.Text)

main :: IO ()
main = do
    values <- setxkbmap
    key <- xset
    TIO.putStrLn $ values !! key

xset :: IO Int
xset = fmap parse output
    where

        output :: IO T.Text
        output = shelly . silently $ run "xset" ["-q"]

        parse :: T.Text -> Int
        parse = T.lines
            >>> filter (T.isInfixOf "LED") >>> head
            >>> T.words >>> (!! 9) >>> flip T.index 4
            >>> (:[]) >>> (read :: String -> Int)

setxkbmap :: IO [T.Text]
setxkbmap = fmap parse output
    where
        output :: IO T.Text
        output = shelly . silently $ run "setxkbmap" ["-query"]

        parse :: T.Text -> [T.Text]
        parse = T.lines
            >>> filter (T.isInfixOf "layout") >>> head
            >>> T.words >>> (!! 1)
            >>> T.splitOn ","

-- % xset -q | grep -A 0 'LED' | cut -c63-63
-- % setxkbmap -query | grep layout | tr -s ' ' | cut -d ' ' -f 2
