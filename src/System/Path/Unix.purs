module System.Path.Unix where

  -- Some random unix path things that are useful.

  import Data.Array (filter)
  import Data.Foldable (foldl)
  import Data.String (charAt, joinWith, length, split)

  infixr 5 </>
  (</>) :: String -> String -> String
  (</>) p p' = joinPath [p, p']

  absolute :: String -> Boolean
  absolute p = charAt 0 p == "/"

  joinPath :: [String] -> String
  joinPath = nonEmpty >>> joinWith "/" >>> normalize

  normalize :: String -> String
  normalize p = split "/" p
              # nonEmpty
              # normalizeDots
              # joinWith "/"
              # leading
              # trailing
    where
      leading :: String -> String
      leading p' | absolute p = "/" ++ p'
      leading p'              = p'
      trailing :: String -> String
      trailing p' | charAt (length p - 1) p == "/" && length p > 1 = p' ++ "/"
      trailing p'                                                  = p'
      normalizeDots :: [String] -> [String]
      normalizeDots []          = []
      normalizeDots (".":ps)    = normalizeDots ps
      normalizeDots (_:"..":ps) = normalizeDots ps
      normalizeDots ("..":ps)   = normalizeDots ps
      normalizeDots (p':ps)     = p' : normalizeDots ps

  nonEmpty :: [String] -> [String]
  nonEmpty = filter ((/=) "")
