# Auto Const

This CLI package automatic add the `Const` keyword in your dart code.

It also removes any unnecessary const keywords.

## Installation

```bash
 dart pub global activate auto_const
```

## Requirements

This cli uses dart analyze and the rule `prefer_const_constructors` to identify where add const, this means that you must have enabled this rule in your analysis_optins.yaml, this way:

```
linter:
  rules:
    - prefer_const_constructors
```

## Running

To run the cli simple execute in the project root:

```bash
dart-auto-const
```

It will analyze your code with `dart analyze`, add const in all places reported by analyzer and remove any const that is not necessary anymore (also reported by analyzer).
