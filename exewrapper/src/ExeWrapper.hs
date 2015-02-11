#!/usr/bin/env runhaskell
{-# OPTIONS_GHC -cpp #-}

#ifdef CABAL_EXECUTABLE
module ExeWrapper where
#else
module Main where
#endif

import System.Directory (doesFileExist, getDirectoryContents, removeFile, copyFile, canonicalizePath, getCurrentDirectory, getPermissions, doesDirectoryExist, executable)
import System.Environment (getArgs, getEnvironment, getExecutablePath, getEnv)
import System.Exit (exitWith, ExitCode(ExitSuccess), exitFailure)
import System.FilePath (addTrailingPathSeparator, getSearchPath, takeBaseName, takeDirectory, pathSeparator, dropTrailingPathSeparator, searchPathSeparator, takeExtension, dropExtension, takeFileName, (</>))
import System.IO (stderr, hPutStrLn)
import System.Process (createProcess, CreateProcess(env), proc, waitForProcess)
import Data.List (nub, intercalate, tails, isPrefixOf, isSuffixOf)
import Data.Char (isAlpha, toLower, isDigit)
import Control.Monad (filterM)

#if __GLASGOW_HASKELL__ >= 710

#else

#endif

#if !defined(mingw32_HOST_OS)
import System.Posix.Files (createSymbolicLink)
#endif

isWindows :: Bool
copyOrSymbolicLink :: FilePath -> FilePath -> IO ()
#ifdef mingw32_HOST_OS
isWindows = True
copyOrSymbolicLink targetPath linkPath = copyFile targetPath linkPath
#else
isWindows = False
copyOrSymbolicLink targetPath linkPath = createSymbolicLink targetPath linkPath
#endif

-- TODO: Runtime
packageDbSuffix :: String
#if __GLASGOW_HASKELL__ >= 706
packageDbSuffix = "db"
#else
packageDbSuffix = "conf"
#endif

takeRight :: Int -> [a] -> [a]
takeRight n list = (reverse (take n (reverse list)))

dropRight :: Int -> [a] -> [a]
dropRight n list = (reverse (drop n (reverse list)))

dropExeExtension :: String -> String
dropExeExtension str =
  if isWindows && isSuffixOf (map toLower exeExtension) (map toLower str) then
    dropRight (length exeExtension) str
  else
    str

-- TODO: Nooooooooooooooo!!!!!
isScript :: Bool
isScript = ".hs" /= takeRight 3 __FILE__

exeExtension :: String
exeExtension = if isWindows then ".exe" else ""

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

getProgramPath :: IO FilePath
getProgramPath = do
  path <-
    if isScript then do
      cd <- getCurrentDirectory
      return (cd </> __FILE__)
    else
      getExecutablePath
  return path

getHsenvPath :: IO FilePath
getHsenvPath = do
  programPath <- getProgramPath
  canonicalizePath (takeDirectory(takeDirectory programPath))

isCabalCommand :: String -> Bool
isCabalCommand arg = length arg > 0 && head arg /= '-' && not (all (not . isAlpha) arg)

readPackageDbs :: IO [String]
readPackageDbs = do
  hsenvPath <- getHsenvPath
  cabalPackageConfPath <- getCabalPackageConfPath
  str <- readFile (hsenvPath </> "ghc.package.conf.d.path")
  return ((splitByDelimiter searchPathSeparator str) ++ [cabalPackageConfPath])

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
  cabalPackageConfPath <- getCabalPackageConfPath
  packageDbArg <- return (
    if (elem commandArg [
      "configure",
      "install",
      "upgrade"])
    then ["--package-db=" ++ cabalPackageConfPath]
    else [])
  return (["--config-file=" ++ hsenvPath </> "cabal" </> "config"] ++ builddirArg ++ packageDbArg)

getCabalPackageConfPath :: IO String
getCabalPackageConfPath = do
  hsenvPath <- getHsenvPath
  return (hsenvPath </> "cabal.package.conf.d")

getGhcArgs :: IO [String]
getGhcArgs = do
  packageDbs <- readPackageDbs
  return (["-no-user-package-" ++ packageDbSuffix] ++
          map (("-package-" ++ packageDbSuffix ++ "=") ++)  packageDbs)

getGhcPkgArgs :: IO [String]
getGhcPkgArgs = do
  packageDbs <- readPackageDbs
  return (["--no-user-package-" ++ packageDbSuffix] ++
          map (("--package-" ++ packageDbSuffix ++ "=") ++)  packageDbs)

isCabal :: String -> Bool
isCabal executableFileName = (removeVersion (dropExeExtension executableFileName)) == "cabal"

isVersion :: String -> Bool
isVersion str = length splittedByDot > 0 && (all (\s -> length s > 0 && (all isDigit s)) splittedByDot)
  where splittedByDot = splitByDelimiter '.' str

removeVersion :: String -> String
removeVersion name =
  if (length splittedName) >= 2 && isVersion (last splittedName) then
    intercalate "-" (dropRight 1 splittedName)
  else
    name
  where splittedName = (splitByDelimiter '-' name)

getAdditionalArgs :: String -> IO [String]
getAdditionalArgs executableFileName = do
  app <- return (removeVersion (dropExeExtension executableFileName))
  if isCabal executableFileName then
    getCabalArgs
  else if app == "ghc" || app == "ghci" || app == "runghc" then
    getGhcArgs
  else if app == "ghc-pkg" then
    getGhcPkgArgs
  else
    return []

getShimPath :: IO FilePath
getShimPath = do
  hsenvPath <- getHsenvPath
  return (hsenvPath </> "bin")

getShimOriginPath :: IO FilePath
getShimOriginPath = do
  hsenvPath <- getHsenvPath
  return (hsenvPath </> "libexec" </>"shim" ++ exeExtension)

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
    targetPath <- return (shimPath </> realFile)
    targetPathExist <- doesFileExist targetPath
    if targetPathExist then
      return ()
    else
      copyOrSymbolicLink shimOriginPath targetPath

getDirectoryExecutableFiles :: FilePath -> IO [FilePath]
getDirectoryExecutableFiles dir = do
  contents <- (getDirectoryContents dir)
  files <- filterM (\f -> doesFileExist (dir </> f)) contents
  filterM (\f -> isExecutable(dir </> f)) files

rehash :: IO ()
rehash = do
  hsenvPath <- getHsenvPath
  shimFiles <- getDirectoryExecutableFiles (hsenvPath </> "bin")
  cabalBinFiles <- getDirectoryExecutableFiles (hsenvPath </> "cabal" </> "bin")
  bootstrapCabalBinFiles <- getDirectoryExecutableFiles (hsenvPath </> "bootstrap" </> "cabal" </> "bin")
  ghcBinFiles <- getDirectoryExecutableFiles (hsenvPath </> "ghc" </> "bin")
  realFiles <- return (nub (ghcBinFiles ++ cabalBinFiles ++ bootstrapCabalBinFiles ++ (map (++ exeExtension) [
                        "cabal", "ghc", "ghc-mod", "ghc-pkg", "ghci", "runghc"])))
  mapM (addShim shimFiles) realFiles
  mapM (removeShim realFiles) shimFiles
  return ()

run = do
  programPath <- getProgramPath
  let executableFileName = takeFileName programPath
  hsenvPath <- getHsenvPath
  let binPath = hsenvPath </> "bin"
  cabalBinPath <- return (hsenvPath </> "cabal" </> "bin")
  bootstrapCabalBinPath <- return (hsenvPath </> "bootstrap" </> "cabal" </> "bin")
  ghcBinPath <- return (hsenvPath </> "ghc" </> "bin")
  mingwBinPath <- return (hsenvPath </> "mingw" </> "bin")
  mingwBinPathExists <- doesFileExist mingwBinPath
  searchPath <- getSearchPath
  cleanSearchPath <- cleanupSearchPath searchPath
  newSearchPath <- return searchPath
  newSearchPath <- return
    ((if mingwBinPathExists && elem mingwBinPath cleanSearchPath then [] else [mingwBinPath]) ++ newSearchPath)
  newSearchPath <- return
    ((if elem binPath cleanSearchPath then [] else [binPath]) ++ newSearchPath)
  newSearchPath <- return
    (newSearchPath ++ if isCabal executableFileName then [cabalBinPath] else [])
    
  pathEnvStr <- return (intercalate [searchPathSeparator] newSearchPath)
  env <- getEnvironment
  newEnv <- return ((map (\kv -> if (fst kv) == "PATH" then ("PATH", pathEnvStr) else kv) env))
  cleanNewSearchPath <- cleanupSearchPath newSearchPath
  realExecutableSearchPath <-
    return ([cabalBinPath] ++ [bootstrapCabalBinPath]  ++ [ghcBinPath] ++
            (drop 1 (dropWhile (/= binPath) cleanNewSearchPath)))
  realExecutableCandidates <-
    return (map (\dir -> (addTrailingPathSeparator dir) ++ executableFileName) realExecutableSearchPath)
  realExecutables <- filterM (\exe -> doesFileExist exe) realExecutableCandidates
  if (length realExecutables) == 0 then do
    hPutStrLn stderr (executableFileName ++ " wrapper: Couldn't find real " ++ executableFileName ++ " program")
    exitFailure
  else do
    realExecutable <- return (head realExecutables)
    args <- getArgs
    additionalArgs <- getAdditionalArgs executableFileName
    (_, _, _, processHandle) <- createProcess (proc realExecutable (additionalArgs ++ args)) { env = Just newEnv }
    exitCode <- waitForProcess processHandle
    if exitCode == ExitSuccess && isCabal executableFileName then do
      rehash
    else
      return ()
    exitWith exitCode

#ifndef CABAL_EXECUTABLE
main = run
#endif
