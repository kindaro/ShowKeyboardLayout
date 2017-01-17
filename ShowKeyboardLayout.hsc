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

#include <X11/extensions/XKBrules.h>

type Display = Int -- cz idk

data XkbRF_VarDefs = XkbRF_VarDefs
                        { model        :: Ptr CString
                        , layout       :: Ptr CString
                        , variant      :: Ptr CString
                        , options      :: Ptr CString
                        , sz_extra     :: CUShort
                        , num_extra    :: CUShort
                        , extra_names  :: Ptr CString
                        , extra_values :: Ptr (Ptr CString)
                        }

instance Storable XkbRF_VarDefs where
    sizeOf _ = (#size XkbRF_VarDefsRec)
    alignment _ = alignment (undefined :: CDouble)
    peek ptr = do
        model_peek        <- ( #peek XkbRF_VarDefsRec, model        ) ptr
        layout_peek       <- ( #peek XkbRF_VarDefsRec, layout       ) ptr
        variant_peek      <- ( #peek XkbRF_VarDefsRec, variant      ) ptr
        options_peek      <- ( #peek XkbRF_VarDefsRec, options      ) ptr
        sz_extra_peek     <- ( #peek XkbRF_VarDefsRec, sz_extra     ) ptr
        num_extra_peek    <- ( #peek XkbRF_VarDefsRec, num_extra    ) ptr
        extra_names_peek  <- ( #peek XkbRF_VarDefsRec, extra_names  ) ptr
        extra_values_peek <- ( #peek XkbRF_VarDefsRec, extra_values ) ptr
        return (XkbRF_VarDefs
                -- I could hugely improve here if I can use labels without "_peek" -- TODO
            model_peek layout_peek variant_peek
            options_peek sz_extra_peek num_extra_peek
            extra_names_peek extra_values_peek)
    poke ptr x = do
        ( #poke XkbRF_VarDefsRec, model        ) ptr (model x)
        ( #poke XkbRF_VarDefsRec, layout       ) ptr (layout x)
        ( #poke XkbRF_VarDefsRec, variant      ) ptr (variant x)
        ( #poke XkbRF_VarDefsRec, options      ) ptr (options x)
        ( #poke XkbRF_VarDefsRec, sz_extra     ) ptr (sz_extra x)
        ( #poke XkbRF_VarDefsRec, num_extra    ) ptr (num_extra x)
        ( #poke XkbRF_VarDefsRec, extra_names  ) ptr (extra_names x)
        ( #poke XkbRF_VarDefsRec, extra_values ) ptr (extra_values x)

main = putStrLn . show $ openDisplay

openDisplay = unsafePerformIO $
    alloca $ \display_name -> alloca $ \event_rtrn -> alloca $ \error_rtrn ->
        alloca $ \major_in_out -> alloca $ \minor_in_out -> alloca $ \reason_rtrn -> do

            poke display_name nullPtr
            poke major_in_out 1
            poke minor_in_out 0

            dpy <- c_XkbOpenDisplay display_name event_rtrn error_rtrn
                                        major_in_out minor_in_out reason_rtrn

            event_rtrn_peek   <- peek event_rtrn
            error_rtrn_peek   <- peek error_rtrn
            major_in_out_peek <- peek major_in_out
            minor_in_out_peek <- peek minor_in_out
            reason_rtrn_peek  <- peek reason_rtrn

            return ( dpy
                   , event_rtrn_peek
                   , error_rtrn_peek
                   , major_in_out_peek
                   , minor_in_out_peek
                   , reason_rtrn_peek
                   )

getValues dpy = unsafePerformIO $
    alloca $ \rules -> alloca $ \vd -> do
        statusCode <- c_XkbRF_GetNamesProp dpy rules vd
        -- if statusCode == 0 then return undefined -- TODO
        rules_peek <- peek rules
        vd_peek <- peek vd
        return (rules, vd)

--  Display * XkbOpenDisplay
--      (display_name, event_rtrn, error_rtrn, major_in_out, minor_in_out, reason_rtrn)
foreign import ccall unsafe "XkbOpenDisplay"
    c_XkbOpenDisplay :: Ptr CString -- hardware display name
                     -> Ptr CInt    -- backfilled with the extension base event code
                     -> Ptr CInt    -- backfilled with the extension base error code
                     -> Ptr CInt    -- compile time lib major version in, server major version out
                     -> Ptr CInt    -- compile time lib minor version in, server minor version out
                     -> Ptr CInt    -- backfilled with a status code
                     -> IO (Ptr Display)

foreign import ccall unsafe "XkbRF_GetNamesProp"
    c_XkbRF_GetNamesProp :: Ptr Display -> Ptr Int -> Ptr XkbRF_VarDefs -> IO CInt

