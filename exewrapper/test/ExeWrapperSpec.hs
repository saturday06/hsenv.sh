module ExeWrapperSpec where

import Test.Hspec(describe, Spec, it, shouldBe)
import Control.Monad(forM_)
import SpecHelper
import ExeWrapper

spec :: Spec
spec = do
  describe "takeRight" $ do
    forM_ [
        (1, [1, 2, 3], [3]),
        (2, [1, 2, 3], [2, 3]),
        (3, [1, 2, 3], [1, 2, 3]),
        (4, [1, 2, 3], [1, 2, 3]),
        (0, [1], []),
        (1, [1], [1]),
        (2, [1], [1]),
        (0, [1], [])
      ] $ \(n, list, result) ->
        it ("takes " ++ show n ++ " elements of " ++ show list ++ " from right") $
          takeRight n list `shouldBe` result

  describe "dropRight" $ do
    forM_ [
        (1, [1, 2, 3], [1, 2]),
        (2, [1, 2, 3], [1]),
        (3, [1, 2, 3], []),
        (4, [1, 2, 3], []),
        (0, [1], [1]),
        (1, [1], []),
        (2, [1], []),
        (0, [1], [1])
      ] $ \(n, list, result) ->
        it ("drops " ++ show n ++ " elements of " ++ show list ++ " from right") $
          dropRight n list `shouldBe` result

  describe "splitByDelimiter" $ do
    forM_ [
        ("a", ',', ["a"]),
        (",", ',', ["", ""]),
        ("a,", ',', ["a", ""]),
        (",a", ',', ["", "a"]),
        (",,", ',', ["", "", ""]),
        (",a,", ',', ["", "a", ""]),
        ("", ',', [])
      ] $ \(str, delim, result) ->
        it ("splits " ++ show str ++ " by " ++ show delim) $
          splitByDelimiter delim str `shouldBe` result

  describe "isVersion" $ do
    forM_ [
        ("1", True),
        ("1.", False),
        (".1", False),
        ("1.a", False),
        ("1.9", True),
        ("1a", False),
        ("12", True),
        ("", False)
      ] $ \(str, result) ->
        it ("checks " ++ show str ++ " is a version") $
          isVersion str `shouldBe` result

  describe "removeVersion" $ do
    forM_ [
        ("foo-1", "foo"),
        ("-1", ""),
        ("1", "1"),
        ("foo-1.", "foo-1."),
        ("bar-.1", "bar-.1"),
        ("bar-1.a", "bar-1.a"),
        ("baz-1.9", "baz"),
        ("baz-1a", "baz-1a"),
        ("baz-10", "baz"),
        ("ba1", "ba1")
      ] $ \(str, result) ->
        it ("removes a version from " ++ show str) $
          removeVersion str `shouldBe` result
