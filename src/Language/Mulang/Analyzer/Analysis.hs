{-# LANGUAGE DeriveGeneric #-}

module Language.Mulang.Analyzer.Analysis (
  Expectation(..),

  Analysis(..),
  AnalysisSpec(..),
  SmellsSet(..),
  DomainLanguage(..),
  CaseStyle(..),
  Smell,
  SignatureAnalysisType(..),
  TestAnalysisType(..),
  InterpreterOptions(..),
  SignatureStyle(..),
  Fragment(..),
  Language(..),

  AnalysisResult(..),
  ExpectationResult(..)) where

import GHC.Generics

import Language.Mulang.Ast
import Language.Mulang.Builder (NormalizationOptions)
import Language.Mulang.Interpreter.Runner (TestResult)

---
-- Common structures
--

type Smell = String
type Inspection = String

data Expectation = Expectation {
  binding :: String,
  inspection :: Inspection
} deriving (Show, Eq, Generic)

--
-- Analysis input structures
--

data Analysis = Analysis {
  sample :: Fragment,
  spec :: AnalysisSpec
} deriving (Show, Eq, Generic)

data AnalysisSpec = AnalysisSpec {
  expectations :: Maybe [Expectation],
  smellsSet :: Maybe SmellsSet,
  signatureAnalysisType :: Maybe SignatureAnalysisType,
  testAnalysisType :: Maybe TestAnalysisType,
  domainLanguage :: Maybe DomainLanguage,
  includeIntermediateLanguage :: Maybe Bool
} deriving (Show, Eq, Generic)

data DomainLanguage = DomainLanguage {
  dictionaryFilePath :: Maybe FilePath,
  caseStyle :: Maybe CaseStyle,
  minimumIdentifierSize :: Maybe Int,
  jargon :: Maybe [String]
} deriving (Show, Eq, Generic)

data CaseStyle
  = CamelCase
  | SnakeCase
  | RubyCase deriving (Show, Eq, Generic)

data SmellsSet
  = NoSmells { include :: Maybe [Smell] }
  | AllSmells { exclude :: Maybe [Smell] } deriving (Show, Eq, Generic)

data SignatureAnalysisType
  = NoSignatures
  | DefaultSignatures
  | StyledSignatures { style :: SignatureStyle } deriving (Show, Eq, Generic)

data SignatureStyle
  = MulangStyle
  | UntypedCStyle
  | HaskellStyle
  | PrologStyle deriving (Show, Eq, Generic)

data Fragment
  = MulangSample { ast :: Expression, normalizationOptions :: Maybe NormalizationOptions }
  | CodeSample { language :: Language, content :: Code } deriving (Show, Eq, Generic)

data InterpreterOptions = InterpreterOptions {
  strictReturns :: Maybe Bool,
  strictShortCircuit :: Maybe Bool
} deriving (Show, Eq, Generic)

data TestAnalysisType
  = NoTests
  | EmbeddedTests { interpreterOptions :: Maybe InterpreterOptions }
  | ExternalTests {
      test :: Fragment,
      extra :: Maybe Fragment,
      interpreterOptions :: Maybe InterpreterOptions
    } deriving (Show, Eq, Generic)

data Language
  =  Json
  |  Java
  |  JavaScript
  |  Prolog
  |  Haskell
  |  Python
  |  Python2
  |  Python3
  |  Ruby
  |  Php
  deriving (Show, Eq, Generic)


--
-- Analysis Output structures
--

data AnalysisResult
  = AnalysisCompleted {
      expectationResults :: [ExpectationResult],
      smells :: [Expectation],
      signatures :: [Code],
      testResults :: [TestResult],
      intermediateLanguage :: Maybe Expression }
  | AnalysisFailed { reason :: String } deriving (Show, Eq, Generic)

data ExpectationResult = ExpectationResult {
  expectation :: Expectation,
  result :: Bool
} deriving (Show, Eq, Generic)


