{-# LANGUAGE DeriveGeneric #-}

module Language.Mulang.Cli.Compiler(
    compile,
    Expectation(..),
    BindingPattern(..)) where

import GHC.Generics
import Data.Aeson
import Language.Mulang.Inspector
import Language.Mulang.Inspector.Combiner
import Language.Mulang.Binding (Binding, BindingPredicate)
import Data.List (isInfixOf)
import Data.List.Split (splitOn)

data BindingPattern = Named String | Like String | Anyone deriving (Show, Eq, Generic)

data Expectation =  Advanced {
                      subject :: [String] ,
                      verb :: String,
                      object :: BindingPattern,
                      transitive :: Bool,
                      negated :: Bool
                    } 
                    | Basic {
                      binding :: String,
                      inspection :: String
                    } deriving (Show, Eq, Generic)

instance FromJSON BindingPattern
instance FromJSON Expectation

instance ToJSON BindingPattern
instance ToJSON Expectation

compile :: Expectation -> Inspection
compile (Advanced s v o t n) = compileSubject s t . compileNegation n $ compileInspection v (compilePattern o)
compile (Basic b i)          = (compile . toAdvanced b (withoutNegation splitedInspection)) isNegated
                               where splitedInspection = splitOn ":" i
                                     isNegated = elem "Not" splitedInspection

withoutNegation :: [String] -> [String]
withoutNegation = filter (/= "Not")

toAdvanced :: String -> [String] -> Bool -> Expectation
toAdvanced b ["HasBinding"]          = Advanced [] "declares" (Named b) False
toAdvanced b ["HasUsage", x]         = Advanced [b] "uses" (Named x) True
toAdvanced b ["HasArity", n]         = Advanced [] ("declaresWithArity" ++ n) (Named b) False
toAdvanced b ["HasTypeSignature"]    = Advanced [] "declaresTypeSignature" (Named b) False
toAdvanced b ["HasTypeDeclaration"]  = Advanced [] "declaresTypeAlias" (Named b) False

--HasComposition  Haskell
--HasComprehension  Haskell
--HasConditional  Haskell
--HasDirectRecursion  Haskell, Prolog
--HasGuards Haskell
--HasIf Haskell
--HasLambda Haskell
--HasRepeatOf:target  Gobstones
--HasForall Prolog
--HasFindall  Prolog
--HasNot  Prolog
--HasWhile  

compileNegation :: Bool -> Inspection -> Inspection
compileNegation False i = i
compileNegation _     i = negative i

compileInspection :: String -> BindingPredicate -> Inspection
compileInspection "declaresObject"         pred = declaresObject pred
compileInspection "declaresAttribute"      pred = declaresAttribute pred
compileInspection "declaresMethod"         pred = declaresMethod pred
compileInspection "declaresFunction"       pred = declaresFunction pred
compileInspection "declaresTypeAlias"      pred = declaresTypeAlias pred
compileInspection "declaresTypeSignature"  pred = declaresTypeSignature pred
compileInspection "declares"               pred = declares pred
compileInspection "declaresRecursively"    pred = declares pred
compileInspection "declaresWithArity0"     pred = declaresWithArity 0 pred
compileInspection "declaresWithArity1"     pred = declaresWithArity 1 pred
compileInspection "declaresWithArity2"     pred = declaresWithArity 2 pred
compileInspection "declaresWithArity3"     pred = declaresWithArity 3 pred
compileInspection "declaresWithArity4"     pred = declaresWithArity 4 pred
compileInspection "uses"                   pred = uses pred
compileInspection "usesComposition"        _    = usesComposition
compileInspection "usesGuards"             _    = usesGuards
compileInspection "usesIf"                 _    = usesIf
compileInspection "usesWhile"              _    = usesWhile
compileInspection "usesLambda"             _    = usesLambda
compileInspection "usesComprehension"      _    = usesComprehension
compileInspection "usesAnnonymousVariable" _    = usesAnnonymousVariable

compilePattern :: BindingPattern -> BindingPredicate
compilePattern (Named o) = named o
compilePattern (Like o)  = like o
compilePattern _         = anyone

compileSubject :: [String] -> Bool -> (Inspection -> Inspection)
compileSubject s True          = (`transitiveList` s)
compileSubject s _             = (`scopedList` s)

