#!/usr/bin/env runhaskell

{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ExtendedDefaultRules #-}
{-# OPTIONS_GHC -fno-warn-type-defaults #-}
{-# LANGUAGE ForeignFunctionInterface #-}

module Main where

main = putStrLn . show $ c_exp 13

foreign import ccall "exp" c_exp :: Double -> Double
