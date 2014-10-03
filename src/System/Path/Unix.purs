module System.Path.Unix where

  -- Some random unix path things that are useful.

  import Data.Array (filter)
  import Data.Foldable (foldl)
  import Data.Path (FilePath())
  import Data.String (charAt, joinWith, length, split)

  infixr 5 </>

  (</>) :: FilePath -> FilePath -> FilePath
  (</>) p p' = joinPath [p, p']

  absolute :: FilePath -> Boolean
  absolute p = charAt 0 p == "/"

  joinPath :: [FilePath] -> FilePath
  joinPath = nonEmpty >>> joinWith "/" >>> normalize

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
      trailing p' | charAt (length p - 1) p == "/" && length p > 1 = p' ++ "/"
      trailing p'                                                  = p'
      normalizeDots :: [FilePath] -> [FilePath]
      normalizeDots []          = []
      normalizeDots (".":ps)    = normalizeDots ps
      normalizeDots (_:"..":ps) = normalizeDots ps
      normalizeDots ("..":ps)   = normalizeDots ps
      normalizeDots (p':ps)     = p' : normalizeDots ps

  nonEmpty :: [FilePath] -> [FilePath]
  nonEmpty = filter ((/=) "")
