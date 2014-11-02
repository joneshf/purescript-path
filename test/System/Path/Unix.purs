module Test.System.Path.Unix where

  import Data.Foldable (and)
  import Data.Function (on)

  import System.Path.Unix

  import Test.StrongCheck
    ( AlphaNumString()
    , QC()
    , quickCheck
    , runAlphaNumString
    )

  propNormalize :: AlphaNumString -> AlphaNumString -> AlphaNumString -> Boolean
  propNormalize str str' str'' = and
    [ propNormalizeIdentity str
    , propNormalize1DotDot str str'
    , propNormalizeManyDotDot str str' str''
    ]

  propNormalizeIdentity :: AlphaNumString -> Boolean
  propNormalizeIdentity str =
    normalize (runAlphaNumString str) == runAlphaNumString str

  -- TODO: These seem pretty janky.
  -- Should be actual properties here, rather than these hardcoded cases.

  propNormalize1DotDot :: AlphaNumString -> AlphaNumString -> Boolean
  propNormalize1DotDot str str' =
    let first = runAlphaNumString str
        second = runAlphaNumString str'
    in normalize (first </> ".." </> second) == second

  propNormalizeManyDotDot :: AlphaNumString -> AlphaNumString -> AlphaNumString -> Boolean
  propNormalizeManyDotDot str str' str''=
    let first = runAlphaNumString str
        second = runAlphaNumString str'
        third = runAlphaNumString str''
    in normalize (first </> second </> ".." </> ".." </> ".." </> ".." </> third) == third

  main :: QC Unit
  main = quickCheck propNormalize
