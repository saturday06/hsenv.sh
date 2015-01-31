{-# OPTIONS_GHC -cpp #-}

module Main where

import System.Directory
import System.Environment
import System.Exit
import System.FilePath
import System.Process
import Data.List
import Data.Char
import Control.Monad

-- TODO: Runtime
packageDbSuffix :: String
#if __GLASGOW_HASKELL__ >= 706
packageDbSuffix = "db"
#else
packageDbSuffix = "conf"
#endif

-- TODO: Oooooooooooooops!!!!!
isWindows :: Bool
isWindows = searchPathSeparator == ';'

exeExt :: String
exeExt = if isWindows then ".exe" else ""

isExecutable :: FilePath -> IO Bool
isExecutable path =
  if isWindows then do
    extension <- return (map toLower (takeExtension path))
    pathext <- getEnv("PATHEXT")
    matches <- return (filter (== extension) (map (\ext -> map toLower ext) (splitByDelimiter searchPathSeparator pathext)))
    return (length matches > 0)
  else do
    permissions <- getPermissions path
    return (executable permissions)

-- http://stackoverflow.com/questions/4503958/what-is-the-best-way-to-split-a-string-by-a-delimiter-functionally
splitByDelimiter :: Char -> String -> [String]
splitByDelimiter _ "" = []
splitByDelimiter delimiter list =
  map (takeWhile (/= delimiter) . tail)
    (filter (isPrefixOf [delimiter])
      (tails
        (delimiter : list)))

cleanupSearchPath :: [FilePath] -> IO [FilePath]
cleanupSearchPath searchPath = do
  foundSearchPath <- filterM doesDirectoryExist searchPath
  cleanSearchPath <- mapM canonicalizePath foundSearchPath
  return (map (\dir -> dropTrailingPathSeparator dir) cleanSearchPath)

getHsenvPath :: IO FilePath
getHsenvPath = do
  executablePath <- getExecutablePath
  canonicalizePath (takeDirectory(takeDirectory(takeDirectory executablePath)))

isCabalCommand :: String -> Bool
isCabalCommand arg = length arg > 0 && head arg /= '-' && not (all (not . isAlpha) arg)

readPackageDbs :: IO [String]
readPackageDbs = do
  hsenvPath <- getHsenvPath
  str <- readFile (hsenvPath </> "ghc_package_path_var")
  return (splitByDelimiter pathSeparator str)

getCabalArgs :: IO [String]
getCabalArgs = do
  hsenvPath <- getHsenvPath
  args <- getArgs
  commandArg <- return (head ((filter isCabalCommand args) ++ [""])) -- TODO:
  builddirArg <- return (if (elem commandArg [
    "build",
    "clean",
    "configure",
    "copy",
    "haddock",
    "hscolour",
    "install",
    "register",
    "sdist",
    "test",
    "upgrade"]) then ["--builddir=" ++ hsenvPath </> "tmp" </> "cabal-builddir"] else [])
  packageDbs <- readPackageDbs
  packageDbArg <- return (if (elem commandArg [
    "configure",
    "install",
    "upgrade"]) then map ("--package-db=" ++)  packageDbs else [])
  return (["--config-file=" ++ hsenvPath </> "cabal" </> "config"] ++ builddirArg ++ packageDbArg)

getGhcArgs :: IO [String]
getGhcArgs = do
  packageDbs <- readPackageDbs
  return (["-no-user-package-" ++ packageDbSuffix] ++
          map (("-package-" ++ packageDbSuffix ++ "=") ++)  packageDbs)

getGhcModArgs :: IO [String]
getGhcModArgs = do
  packageDbs <- readPackageDbs
  packageDbArgs <- return (map (\db -> "-package-" ++ packageDbSuffix ++ "=" ++ db) packageDbs)
  return (["-g"] ++ ["-no-user-package-" ++ packageDbSuffix] ++
          (foldr (++) [] (map (\arg -> ["-g", arg]) packageDbArgs)))

getGhcPkgArgs :: IO [String]
getGhcPkgArgs = do
  packageDbs <- readPackageDbs
  return (["--no-user-package-" ++ packageDbSuffix] ++
          map (("--package-" ++ packageDbSuffix ++ "=") ++)  packageDbs)

isCabal :: String -> Bool
isCabal executableFileName = (takeBaseName executableFileName) == "cabal"

getAdditionalArgs :: String -> IO [String]
getAdditionalArgs executableFileName = do
  app <- return (takeBaseName executableFileName)
  if isCabal executableFileName then
    getCabalArgs
  else if app == "ghc" || app == "ghci" || app == "runghc" then
    getGhcArgs
  else if app == "ghc-pkg" then
    getGhcPkgArgs
  else if app == "ghc-mod" then
    getGhcModArgs
  else
    return []

getShimPath :: IO FilePath
getShimPath = do
  hsenvPath <- getHsenvPath
  return (hsenvPath </> "usr" </> "bin")

getShimOriginPath :: IO FilePath
getShimOriginPath = do
  hsenvPath <- getHsenvPath
  return (hsenvPath </> "shim" ++ exeExt)

removeShim :: [FilePath] -> FilePath -> IO ()
removeShim realFiles shimFile = do
  if elem shimFile realFiles then do
    return ()
  else do
    shimPath <- getShimPath
    removeFile (shimPath </> shimFile)

addShim :: [FilePath] -> FilePath -> IO ()
addShim shimFiles realFile = do
  if elem realFile shimFiles then do
    return ()
  else do
    shimPath <- getShimPath
    shimOriginPath <- getShimOriginPath
    copyFile shimOriginPath (shimPath </> realFile)

getDirectoryExecutableFiles :: FilePath -> IO [FilePath]
getDirectoryExecutableFiles dir = do
  contents <- (getDirectoryContents dir)
  files <- filterM (\f -> doesFileExist (dir </> f)) contents
  filterM (\f -> isExecutable(dir </> f)) files

rehash :: IO ()
rehash = do
  hsenvPath <- getHsenvPath
  shimFiles <- getDirectoryExecutableFiles (hsenvPath </> "usr" </> "bin")
  cabalBinFiles <- getDirectoryExecutableFiles (hsenvPath </> "cabal" </> "bin")
  ghcBinFiles <- getDirectoryExecutableFiles (hsenvPath </> "ghc" </> "bin")
  realFiles <- return (ghcBinFiles ++ cabalBinFiles ++ (map (++ exeExt) [
                        "cabal", "ghc", "ghc-mod", "ghc-pkg", "ghci", "runghc"]))
  mapM (addShim shimFiles) realFiles
  mapM (removeShim realFiles) shimFiles
  return ()

main = do
  executablePath <- getExecutablePath
  executableFileName <- return (takeFileName executablePath)
  hsenvPath <- getHsenvPath
  usrBinPath <- return (hsenvPath </> "usr" </> "bin")
  cabalBinPath <- return (hsenvPath </> "cabal" </> "bin")
  ghcBinPath <- return (hsenvPath </> "ghc" </> "bin")
  mingwBinPath <- return (hsenvPath </> "mingw" </> "bin")
  mingwBinPathExists <- doesFileExist mingwBinPath
  searchPath <- getSearchPath
  cleanSearchPath <- cleanupSearchPath searchPath
  newSearchPath <- return searchPath
  newSearchPath <- return
    ((if mingwBinPathExists && elem mingwBinPath cleanSearchPath then [] else [mingwBinPath]) ++ newSearchPath)
  newSearchPath <- return
    ((if elem usrBinPath cleanSearchPath then [] else [usrBinPath]) ++ newSearchPath)
  pathEnvStr <- return (intercalate ";" newSearchPath)
  setEnv "PATH" pathEnvStr
  cleanNewSearchPath <- cleanupSearchPath newSearchPath
  realExecutableSearchPath <-
    return ([cabalBinPath] ++ [ghcBinPath] ++
            (drop 1 (dropWhile (/= usrBinPath) cleanNewSearchPath)))
  realExecutableCandidates <-
    return (map (\dir -> (addTrailingPathSeparator dir) ++ executableFileName) realExecutableSearchPath)
  realExecutables <- filterM (\exe -> doesFileExist exe) realExecutableCandidates
  if (length realExecutables) == 0 then do
    putStrLn (executableFileName ++ " wrapper: Couldn't find real " ++ executableFileName ++ " program")
    exitFailure
  else do
    realExecutable <- return (head realExecutables)
    args <- getArgs
    additionalArgs <- getAdditionalArgs executableFileName
    (_, _, _, processHandle) <- createProcess (proc realExecutable (additionalArgs ++ args))
    exitCode <- waitForProcess processHandle
    if exitCode == ExitSuccess && isCabal executableFileName then do
      rehash
    else
      return ()
    exitWith exitCode
