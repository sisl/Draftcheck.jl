# Draftcheck.jl

[![Build Status](https://travis-ci.org/sisl/Draftcheck.jl.svg?branch=master)](https://travis-ci.org/sisl/Draftcheck.jl) [![Coverage Status](https://coveralls.io/repos/sisl/Draftcheck.jl/badge.svg?branch=master&service=github)](https://coveralls.io/github/sisl/Draftcheck.jl?branch=master)

Draftcheck.jl checks LaTeX documents for common errors using regular expressions. It was inspired by the Python package [draftcheck](https://github.com/ebnn/draftcheck).

## Usage

We can check a single document like this:
```julia
check("myfile.tex", "rules.jl")
```
By default, it will follow `\input` and `\include` links if you specify a single file. You can override this by specifying `follow_links = false`. If you want to specify an array of files, we can do the following:
```julia
check(["myfile1.tex", "myfile2.tex", "myfile3.tex"], "rules.jl")
```
By default, it will not follow links, but this can be overridden.

## Rules

A rule specifies a name, a regular expression, and an error message. Here is an example:
```julia
rule("url", r"(?<!\\url{)(\bhttps?://)[^\s.]+\.[-A-Za-z0-9+&@#/%?=~_|!:,.;]+", "Wrap URLs with the \\url command.")
```
The name is "url". See `example.jl` for an example set of rules.

We can ignore rules in a particular line by adding a comment that says "OK" and then the name of the rule. For example:
```latex
$1x2$ % OK times
```

## Authors

This package is based on some code developed by Cara Ip while an intern at the Stanford Intelligent Systems Laboratory.
