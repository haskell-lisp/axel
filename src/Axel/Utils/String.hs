{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE TemplateHaskell #-}

module Axel.Utils.String where

import Control.Lens.Combinators (_head)
import Control.Lens.Operators ((%~))

import Data.Char (chr, ord, toUpper)
import qualified Data.Text as T (pack, replace, unpack)

import GHC.Exts (IsString(fromString))

import Language.Haskell.TH.Quote (QuasiQuoter(QuasiQuoter))

capitalize :: String -> String
capitalize = _head %~ toUpper

replace :: String -> String -> String -> String
replace needle replacement haystack =
  T.unpack $ T.replace (T.pack needle) (T.pack replacement) (T.pack haystack)

-- Adapted from http://hackage.haskell.org/package/string-quote-0.0.1/docs/src/Data-String-Quote.html#s.
s :: QuasiQuoter
s =
  QuasiQuoter
    ((\a -> [|fromString a|]) . filter (/= '\r'))
    (error "Cannot use s as a pattern")
    (error "Cannot use s as a type")
    (error "Cannot use s as a dec")

handleStringEscapes :: String -> String
handleStringEscapes =
  concatMap $ \case
    '\\' -> "\\\\"
    c -> [c]

bold :: String -> String
bold = map boldCharacter
  where
    boldRanges = [('a', 'z', '𝗮'), ('A', 'Z', '𝗔'), ('0', '9', '𝟬')]
    boldDelta x =
      foldl
        (\acc (rangeStart, rangeEnd, boldStart) ->
           if x `elem` [rangeStart .. rangeEnd]
             then ord boldStart - ord rangeStart
             else acc)
        0
        boldRanges
    boldCharacter x = chr $ (+ boldDelta x) $ ord x

indent :: Int -> String -> String
indent width = unlines . map (replicate width ' ' <>) . lines
