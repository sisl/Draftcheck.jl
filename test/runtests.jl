using Draftcheck

check(joinpath(dirname(@__FILE__), "..", "example", "test.tex"), joinpath(dirname(@__FILE__), "..", "example", "example.jl"))
