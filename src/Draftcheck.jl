module Draftcheck

export check, rule

function get_all_filenames(filename)
    filenames = []
    _add_all_filenames!(filename, filenames, [])
    return filenames
end
function _add_all_filenames!(filename, filenames, paths)
    if filename ∈ filenames
        return
    end
    if isfile(filename)
        push!(filenames, filename)
        if dirname(filename) ∉ paths
            push!(paths, dirname(filename))
        end
        for line in readlines(filename)
            for a in eachmatch(r"\\input{([^}]+)}", line)
                if a.captures[1] ∉ filenames
                    _add_all_filenames!(a.captures[1], filenames, paths)
                end
            end
            for a in eachmatch(r"\\include{([^}]+)}", line)
                if a.captures[1] ∉ filenames
                    _add_all_filenames!(a.captures[1], filenames, paths)
                end
            end
        end
    elseif !endswith(filename, ".tex")
        _add_all_filenames!(filename * ".tex", filenames, paths)
    else
        for path in paths
            f = joinpath(path, filename)
            if isfile(f)
                _add_all_filenames!(f, filenames, paths)
                return
            end
        end
        @warn("Missing file $filename")
    end
end

struct Rule
    name
    regex
    err
end
rules = []
function rule(name, regex, err)
    global rules
    push!(rules, Rule(name, regex, err))
end

function check(filename, rule_file; follow_links = true, allowed = Allowed())
    success = true
    if !isempty(rule_file)
        global rules = []
        include(rule_file)
    end
    if follow_links
        check(get_all_filenames(filename), "", allowed = allowed)
        return
    end

    global rules
    for (counter, line) in enumerate(readlines(filename))
        comment = occursin(r"%", line)
        if !comment
            for r in rules
                if occursin(r.regex, line) && !occursin(Regex("% OK $(r.name)"), line)
                    s = "$(r.name): $(r.err)\n$filename: $counter\n$(lstrip(line))"
                    if !contains(allowed, s)
                        println(s)
                        println()
                        success = false
                    end
                end
            end
        end
    end
    return success
end

struct Allowed
    data::Set{String}
end

function Allowed(; filename::String = "allowed.txt")
    w = Allowed(Set{String}())
    if !isfile(filename)
        return w
    end
    s = ""
    for (i, line) in enumerate(readlines(filename))
        j = mod1(i, 4)
        if j == 1
            s = line
        elseif j < 4
            s *= "\n$line"
        else
            push!(w.data, s)
        end
    end
    return w
end

contains(w::Allowed, s::String) = s ∈ w.data

function check(filenames::Vector, rule_file; follow_links = false, allowed = Allowed())
    if !isempty(rule_file)
        global rules = []
        include(rule_file)
    end
    return all(check(f, "", follow_links = follow_links, allowed = allowed) for f in filenames)
end

end # module
