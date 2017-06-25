[![Build Status](https://travis-ci.org/mumuki/mulang.svg?branch=master)](https://travis-ci.org/mumuki/mulang)

Mulang
======
> The Universal, Multi Language, Multi Paradigm code analyzer

## Getting Started

Better than explaining what Mulang is, let's see what can do it for you.

Let's start simple - we have the following JS expression:

```javascript
var pepita = {lugar: bsAs1, peso: 20};
var bsAs1 = bsAs
```

We want to recognize some code patterns on it, so we will first load the expression into Mulang:

```
$ ghci
> :m Language.Mulang.All
> let e = js "var pepita = {lugar: bsAs1, peso: 20}; var bsAs1 = bsAs"
```

Now the magic begins. We want to know if the code expression uses a certain binding - that could be a variable, function, or anything that has a name:

```haskell
> uses (named "bsAs") e
True
> uses (named "rosario") e
False
```

That _seems_ easy, but just in case you are wondering: no, Mulang doesn't perform a `string.contains` or something like that :stuck_out_tongue: :

```haskell
> uses (named "bs") e
False
```

So let's ask something more interesting - does `bsAs1` use the binding `bsAs`?

```haskell
> scoped (uses (named "bsAs")) "bsAs1"  e
True
```

And does it use `rosario`?

```haskell
> scoped (uses (named "rosario")) "bsAs1"  e
False
```

What about the object `pepita`? Does it use `bsAs1` or `rosario`?

```haskell
> scoped (uses (named "bsAs1")) "pepita"  e
True
> scoped (uses (named "rosario")) "pepita"  e
False
```

Does `pepita` use `bsAs`?

```haskell
> scoped (uses (named "bsAs")) "pepita"  e
False
```

Oh, wait there! We know, it is true that it does not use **exactly** that variable, but come on, `bsAs1` does use `bsAs`! Wouldn't it be sweet to be transitive?

You ask for it, you get it:

```haskell
> transitive (uses (named "bsAs")) "pepita"  e
True
```

I know what you are thinking:  now you wan't to be stricter, you want to know if `pepita.lugar` uses bsAs1 - ignoring that `peso` attribute. Piece of cake:

```haskell
> scopedList (uses (named "bsAs1")) ["pepita", "lugar"]  e
True
> scopedList (uses (named "bsAs1")) ["pepita", "peso"]  e
False
```

Nice, we know. But not very awesome, it only can tell you if you are using a _binding_, right? Eeer. Good news, it can tell you much much much more things:

* `declaresMethod`: **objects paradigm** is a given method declared?
* `declaresAttribute`: **objects paradigm** is a given attribute declared?
* `declaresClass`: **objects paradigm** is a given class declared?
* `declaresObject`: **objects paradigm** is a given named object declared?
* `declaresFunction`: **functional/imperative paradigm** is a given function declared?
* `declaresTypeSignature`: **any paradigm** is a given computation type signature declared?
* `declaresTypeAlias`: **any paradigm** is a given type synonym declared?
* `declaresRecursively`: **any paradigm** is a given computation declared using recusion?
* `declaresComputation`: **any paradigm** that is, does the given computation  - method, predicate, function, etc - exist?
* `declaresComputationWithArity`: **any paradigm** that is, does the given computation arity match the given criteria
* `declaresComputationWithExactArity`: **any paradigm** that is, does the given computation have the exact given arity?
* `declaresRule`: **logic paradigm** is a given logic rule declared?
* `declaresFact`: **logic paradigm** is a given logic fact declared?
* `declaresPredicate`: **logic paradigm** is a given rule o fact declared?
* `usesIf`
* `usesWhile`
* `usesLambda`
* `usesGuards`
* `usesComposition`
* `usesComprehensions`
* `usesAnonymousVariable`
* `usesUnifyOperator`
* `hasRedundantIf`
* `hasRedundantGuards`
* `hasRedundantParameter`
* `hasRedundantLambda`
* `hasRedundantBooleanComparison`
* `hasRedundantLocalVariableReturn`
* `hasAssignmentReturn`
* `doesTypeTest`
* `doesNullTest`
* `returnsNull`
* `hasTooShortBindings`
* `hasWrongCaseBindings`
* `hasMisspelledBindings`
* `isLongCode`: **any code** has the code long sequences of statements?
* `hasCodeDuplication`: **any paradigm** has the given code simple literal code duplication?

For example, let's go trickier:

Does that piece of code declare any attribute?

```haskell
> declaresAttribute anyone e
True
```

But does it declare an attribute like 'eso'?

```haskell
> declaresAttribute (like "eso") e
True
```

And does `pepita` use any if within its definition?

```haskell
> scoped usesIf "pepita" e
False
```

Does something in the following code...

```haskell
let e = js "var bar = {baz: function(){ return g }, foo: function(){ return null }}"
```

...return null?

```haskell
> returnsNull e
True
```

is it the `foo` method in `bar`? or the `baz` method?

```haskell
> scopedList returnsNull ["bar", "foo"] e
True
> scopedList returnsNull ["bar", "baz"] e
False
```

But instead of asking one by one, we could use `detect` :wink: :

```haskell
> detect returnsNull e
["bar","foo"]
```

_Which means that there are null returns within  `bar` and also within `foo`_

## An universal tool

The really awesome is here: it is an universal tool which can _potentially_ work with every programming language. it natively supports:

  * JS (ES5)
  * Haskell
  * Prolog
  * Gobstones
  * Mulang itself, expressed as a JSON AST.

So in order to use it with a particular language, you have to:

* either add explicit support in this repo, or
* translate your language into one of the natively supported ones, or
* translate your language to the Mulang JSON AST

## Installing it

Mulang is just a Haskell library. You can install it though cabal.

But if you are not the Haskell inclined gal or guy - ok, I will try to forgive you - this code comes with a command line too. So you don't even have to typecheck!

## Sample CLI usage

### With advanced expectations:

```bash
$ mulang '
{
   "sample" : {
      "tag" : "CodeSample",
      "language" : "Haskell",
      "content" : "x = 1"
   },
   "spec" : {
      "expectations" : [
         {
            "tag" : "Advanced",
            "subject" : [ "x" ],
            "object" : { "tag" : "Anyone" },
            "negated" : false,
            "verb" : "uses",
            "transitive" : false
         }
      ],
      "smellsSet" : { "tag" : "NoSmells" },
      "signatureAnalysisType" : { "tag" : "NoSignatures" }
   }
}
' | json_pp
{
   "expectationResults" : [
      {
         "expectation" : {
            "subject" : [
               "x"
            ],
            "verb" : "uses",
            "tag" : "Advanced",
            "object" : {
               "tag" : "Anyone"
            },
            "negated" : false,
            "transitive" : false
         },
         "result" : false
      }
   ],
   "smells" : [],
   "tag" : "AnalysisCompleted",
   "signatures" : []
}
```

### With basic expectations

```bash
$ mulang '
{
   "sample" : {
      "tag" : "CodeSample",
      "language" : "Haskell",
      "content" : "x = 1"
   },
   "spec" : {
      "signatureAnalysisType" : { "tag" : "NoSignatures" },
      "smellsSet" : { "tag" : "NoSmells" },
      "expectations" : [
         {
            "tag" : "Basic",
            "binding" : "x",
            "inspection" : "HasBinding"
         }
      ]
   }
}
' | json_pp
{
   "tag" : "AnalysisCompleted",
   "smells" : [],
   "expectationResults" : [
      {
         "result" : true,
         "expectation" : {
            "tag" : "Basic",
            "binding" : "x",
            "inspection" : "HasBinding"
         }
      }
   ],
   "signatures" : []
}
```

### With signature analysis

```bash
$ mulang '
{
   "sample" : {
      "tag" : "CodeSample",
      "language" : "JavaScript",
      "content" : "function foo(x, y) { return x + y; }"
   },
   "spec" : {
      "expectations" : [],
      "smellsSet" : { "tag" : "NoSmells" },
      "signatureAnalysisType" : {
        "tag" : "StyledSignatures",
        "style" : "HaskellStyle"
      }
   }
}
' | json_pp
{
   "expectationResults" : [],
   "smells" : [],
   "signatures" : [
      "-- foo x y"
   ],
   "tag" : "AnalysisCompleted"
}
```

### With broken input

```bash
$ mulang '
{
   "sample" : {
      "tag" : "CodeSample",
      "language" : "JavaScript",
      "content" : "function foo(x, y { return x + y; }"
   },
   "spec" : {
      "expectations" : [],
      "smellsSet" : { "tag" : "NoSmells" },
      "signatureAnalysisType" : {
        "tag" : "StyledSignatures",
        "style" : "HaskellStyle"
      }
   }
}' | json_pp
{
   "tag" : "AnalysisFailed",
   "reason" : "Sample code parsing error"
}
```

### With AST as input

```bash
$ mulang '
{
   "sample" : {
      "tag" : "MulangSample",
      "ast" : {
         "tag" : "Sequence",
         "contents" : [
            {
              "tag" : "Variable",
              "contents" : [
                "x",
                { "tag" : "MuNumber", "contents" : 1 }
              ]
            },
            {
              "tag" : "Variable",
              "contents" : [
                "y",
                { "tag" : "MuNumber", "contents" : 2 }
              ]
            }
         ]
      }
   },
   "spec" : {
      "smellsSet" : {
        "tag" : "NoSmells"
      },
      "signatureAnalysisType" : {
         "tag" : "StyledSignatures",
         "style" : "HaskellStyle"
      },
      "expectations" : []
   }
}
' | json_pp
{
   "expectationResults" : [],
   "smells" : [],
   "tag" : "AnalysisCompleted",
   "signatures" : [
      "-- x",
      "-- y"
   ]
}
```

### With Smell Analysis, by inclusion

```bash
$ mulang '
{
   "sample" : {
      "tag" : "CodeSample",
      "language" : "JavaScript",
      "content" : "function foo(x, y) { return null; }"
   },
   "spec" : {
      "expectations" : [],
      "smellsSet" : {
        "tag" : "OnlySmells",
        "include" : [
          "ReturnsNull",
          "DoesNullTest"
        ]
      },
      "signatureAnalysisType" : {
        "tag" : "StyledSignatures",
        "style" : "HaskellStyle"
      }
   }
}
' | json_pp
{
   "tag" : "AnalysisCompleted",
   "expectationResults" : [],
   "signatures" : [
      "-- foo x y"
   ],
   "smells" : [
      {
         "tag" : "Basic",
         "binding" : "foo",
         "inspection" : "ReturnsNull"
      }
   ]
}
```

### With Smell Analysis, by exclusion

```bash
$ mulang '
{
   "sample" : {
      "tag" : "CodeSample",
      "language" : "JavaScript",
      "content" : "function foo(x, y) { return null; }"
   },
   "spec" : {
      "expectations" : [],
      "smellsSet" : {
        "tag" : "AllSmells",
        "exclude" : [
          "ReturnsNull"
        ]
      },
      "signatureAnalysisType" : {
        "tag" : "StyledSignatures",
        "style" : "HaskellStyle"
      }
   }
}
' | json_pp
{
   "smells" : [],
   "signatures" : [
      "-- foo x y"
   ],
   "tag" : "AnalysisCompleted",
   "expectationResults" : []
}
```

### With expressiveness smells

Expressivnes smells are like other smells - they can be included or excluded using the `smellsSet` settings. However, their behaviour is also controlled
by the `domainLanguage` setting, which you _can_ configure:

```bash
$ mulang '
{
   "sample" : {
      "tag" : "CodeSample",
      "language" : "Prolog",
      "content" : "son(Parent, Son):-parentOf(Son, Parent).parentOf(bart, homer)."
   },
   "spec" : {
      "expectations" : [],
      "smellsSet" : { "tag" : "AllSmells", "exclude" : [] },
      "domainLanguage" : {
         "caseStyle" : "SnakeCase",
         "minimumBindingSize" : 4,
         "jargon" : ["id"]
      },
      "signatureAnalysisType" : { "tag" : "NoSignatures" }
   }
}' | json_pp
{
   "tag" : "AnalysisCompleted",
   "signatures" : [],
   "smells" : [
      {
         "tag" : "Basic",
         "inspection" : "HasTooShortBindings",
         "binding" : "son"
      },
      {
         "binding" : "parentOf",
         "tag" : "Basic",
         "inspection" : "HasWrongCaseBindings"
      }
   ],
   "expectationResults" : []
}
```

Also, if you want to use `HasMisspelledBindings` smell, you _need_ to specify a dictionary - with must be ordered, downcased and with unique words only:

```bash
$ mulang  '
{
   "sample" : {
      "tag" : "CodeSample",
      "language" : "JavaScript",
      "content" : "function foo(x, y) { return null; }"
   },
   "spec" : {
      "expectations" : [],
      "smellsSet" : { "tag" : "AllSmells", "exclude" : [] },
      "domainLanguage" : { "dictionaryFilePath" : "/usr/share/dict/words" },
      "signatureAnalysisType" : { "tag" : "NoSignatures" }
   }
}' | json_pp
{
   "tag" : "AnalysisCompleted",
   "expectationResults" : [],
   "signatures" : [],
   "smells" : [
      {
         "inspection" : "ReturnsNull",
         "tag" : "Basic",
         "binding" : "foo"
      },
      {
         "inspection" : "HasMisspelledBindings",
         "tag" : "Basic",
         "binding" : "foo"
      }
   ]
}
```

## Expectations, Signatures and Smells

Mulang CLI can do three different kinds of analysis:

* **Expectation analysis**: you can provide an expression - called `inspection` - that will be tested against the provied program. Expectations answer questions like: _does the function X call the function Y?_ or _does the program use if's?_. It comes in two flavors:
     * **basic expectations**: are composed by a binding and an inspection
     * **advanced expectations**: are composed by
       * subject
       * verb
       * object
       * flags
* **Smell analysis**: instead of asking explcit questions to the program, the smells analysis implicitly runs specific inspections - that denote bad code - in orden to know if any of them is matched.
* **Signature analysis**: report the signatures of the computations present in source code.

## Building mulang from source

### Setup

To generate `mulang` executable, you have to build the project using [stack](https://haskellstack.org):

1. Install stack: `wget -qO- https://get.haskellstack.org/ | sh`
2. Go to the mulang project directory and setup it: `stack setup`
3. Build the project: `stack build`

### Rungs

Mulang uses the `rungs` command to parse the Gobstones language - if you don't install it, Gobstones tests will fail:

```
$ wget https://github.com/gobstones/gs-weblang-cli/releases/download/v1.3.3/rungs-ubuntu64 -O rungs
$ chmod u+x rungs
$ sudo mv rungs ~/.local/bin
```

### Installing and creating an executable


```bash
$ stack install
$ mulang
```

That will generate a `mulang` executable in the folder `~/.local/bin`.

### Running tests

```bash
$ stack test --fast
```

### Watching changes


```bash
$ stack test --fast --file-watch
```

### Loading mulang in the REPL

```
stack ghci
```
