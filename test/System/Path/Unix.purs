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
    ]

  propNormalizeIdentity :: AlphaNumString -> Boolean
  propNormalizeIdentity str =
    normalize (runAlphaNumString str) == runAlphaNumString str

  -- TODO: These seem pretty janky.
  -- Should be actual properties here, rather than these hardcoded cases.

  normalize1DotDot :: AlphaNumString -> AlphaNumString -> Boolean
  normalize1DotDot str str' =
    let first = runAlphaNumString str
        second = runAlphaNumString str'
    in normalize (first </> ".." </> second) == second

  normalizeManyDotDot :: AlphaNumString -> AlphaNumString -> AlphaNumString -> Boolean
  normalizeManyDotDot str str' str'' =
    let first = runAlphaNumString str
        second = runAlphaNumString str'
        third = runAlphaNumString str''
    in normalize (joinPath [first, second, third, "..", "..", "..", "..", third]) == third

  propUnixWinIso :: AlphaNumString -> AlphaNumString -> AlphaNumString -> Boolean
  propUnixWinIso str str' str'' =
    let first = runAlphaNumString str
        second = runAlphaNumString str'
        third = runAlphaNumString str''
        unixPath = "C:" </> first </> second </> third
        winPath = "C:\\" ++ first ++ "\\" ++ second ++ "\\" ++ third
    in win2Unix (unix2Win unixPath) == unixPath

  main :: QC Unit
  main = do
    quickCheck propNormalize
    quickCheck normalize1DotDot
    quickCheck normalizeManyDotDot
    quickCheck propUnixWinIso
