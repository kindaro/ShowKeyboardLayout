#!/usr/bin/env runhaskell

{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ExtendedDefaultRules #-}
{-# OPTIONS_GHC -fno-warn-type-defaults #-}
{-# LANGUAGE ForeignFunctionInterface #-}

module Main where

import Foreign.C.String
import Foreign.C.Types
import Foreign.Marshal.Alloc
import Foreign.Ptr
import Foreign.Storable
import System.IO.Unsafe

type Display = Int -- cz idk

main = putStrLn . show $ openDisplay

openDisplay = unsafePerformIO $
    alloca $ \display_name -> alloca $ \event_rtrn -> alloca $ \error_rtrn ->
        alloca $ \major_in_out -> alloca $ \minor_in_out -> alloca $ \reason_rtrn -> do
            poke display_name nullPtr
            poke major_in_out 1
            poke minor_in_out 0
            dpy <- c_XkbOpenDisplay display_name event_rtrn error_rtrn
                                        major_in_out minor_in_out reason_rtrn
            event_rtrn_peek <- peek event_rtrn
            error_rtrn_peek <- peek error_rtrn
            major_in_out_peek <- peek major_in_out
            minor_in_out_peek <- peek minor_in_out
            reason_rtrn_peek <- peek reason_rtrn
            return ( dpy
                   , event_rtrn_peek
                   , error_rtrn_peek
                   , major_in_out_peek
                   , minor_in_out_peek
                   , reason_rtrn_peek
                   )

--  Display * XkbOpenDisplay
--      (display_name, event_rtrn, error_rtrn, major_in_out, minor_in_out, reason_rtrn)
foreign import ccall unsafe "XkbOpenDisplay"
    c_XkbOpenDisplay :: Ptr CString -- hardware display name
                     -> Ptr CInt -- backfilled with the extension base event code
                     -> Ptr CInt -- backfilled with the extension base error code
                     -> Ptr CInt -- compile time lib major version in, server major version out
                     -> Ptr CInt -- compile time lib minor version in, server minor version out
                     -> Ptr CInt -- backfilled with a status code
                     -> IO (Ptr Display)
