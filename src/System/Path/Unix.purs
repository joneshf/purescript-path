module System.Path.Unix where

  -- Some random unix path things that are useful.

  import Data.Array (filter, last)
  import Data.Foldable (foldl)
  import Data.Maybe (fromMaybe, Maybe(..))
  import Data.Path (FilePath())
  import Data.Char (Char(), charString)
  import Data.String (charAt, drop, joinWith, length, split)

  infixr 5 </>

  (</>) :: FilePath -> FilePath -> FilePath
  (</>) "" p                                = p
  (</>) p  ""                               = p
  (</>) p p' | hasTrailing p && absolute p' = p ++ drop 1 p'
  (</>) p p' | hasTrailing p                = p ++ p'
  (</>) p p' | absolute p'                  = p ++ p'
  (</>) p p'                                = p ++ "/" ++ p'

  absolute :: FilePath -> Boolean
  absolute p = (charString <$> charAt 0 p) == Just "/"

  hasTrailing :: FilePath -> Boolean
  hasTrailing p = (charString <$> charAt (length p - 1) p) == Just "/"

  joinPath :: [FilePath] -> FilePath
  joinPath ps = foldl (</>) "" $ nonEmpty ps

  normalize :: FilePath -> FilePath
  normalize p = split "/" p
              # nonEmpty
              # normalizeDots
              # joinWith "/"
              # leading
              # trailing
    where
      leading :: FilePath -> FilePath
      leading p' | absolute p = "/" ++ p'
      leading p'              = p'
      trailing :: FilePath -> FilePath
      trailing p' | hasTrailing p  && length p > 1 = p' ++ "/"
      trailing p'                                  = p'
      normalizeDots :: [FilePath] -> [FilePath]
      normalizeDots []                  = []
      normalizeDots (".":ps)            = normalizeDots ps
      normalizeDots (p':_:"..":"..":ps) = normalizeDots (p':"..":ps)
      normalizeDots (_:"..":ps)         = normalizeDots ps
      normalizeDots ("..":ps)           = normalizeDots ps
      normalizeDots (p':ps)             = p' : normalizeDots ps

  nonEmpty :: [FilePath] -> [FilePath]
  nonEmpty ps = filter ((/=) "") ps

  basename :: FilePath -> FilePath
  basename p = split "/" p
             # last
             # fromMaybe ""
