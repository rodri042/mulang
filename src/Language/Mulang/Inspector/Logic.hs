module Language.Mulang.Inspector.Logic (
  usesNot,
  usesFindall,
  usesForall,
  usesUnifyOperator,
  declaresFact,
  declaresRule,
  declaresPredicate) where

import Language.Mulang
import Language.Mulang.Binding
import Language.Mulang.Inspector.Generic
import Language.Mulang.Inspector.Combiner

declaresFact :: BindingPredicate -> Inspection
declaresFact = containsDeclaration f
  where f (FactDeclaration _ _) = True
        f _                     = False

declaresRule :: BindingPredicate -> Inspection
declaresRule = containsDeclaration f
  where f (RuleDeclaration _ _ _) = True
        f _                       = False

usesNot :: Inspection
usesNot = containsExpression f
  where f (Not  _) = True
        f _ = False

usesFindall :: Inspection
usesFindall = containsExpression f
  where f (Findall  _ _ _) = True
        f _ = False

usesForall :: Inspection
usesForall = containsExpression f
  where f (Forall  _ _) = True
        f _ = False

usesUnifyOperator :: Inspection
usesUnifyOperator = containsExpression f
  where f (Exist "=" _) = True
        f _ = False

declaresPredicate :: BindingPredicate -> Inspection
declaresPredicate pred = alternative (declaresFact pred) (declaresRule pred)