module Draftcheck

export check, rule

function get_all_filenames(filename)
    filenames = []
    _add_all_filenames!(filename, filenames, [])
    return filenames
end
function _add_all_filenames!(filename, filenames, paths)
    if in(filename, filenames)
        return
    end
    if isfile(filename)
        push!(filenames, filename)
        if !in(dirname(filename), paths)
            push!(paths, dirname(filename))
        end
        for line in readlines(filename)
            for a in eachmatch(r"\\input{([^}]+)}", line)
                if !in(a.captures[1], filenames)
                    _add_all_filenames!(a.captures[1], filenames, paths)
                end
            end
            for a in eachmatch(r"\\include{([^}]+)}", line)
                if !in(a.captures[1], filenames)
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

function check(filename, rule_file; follow_links = true)
    if !isempty(rule_file)
        global rules = []
        include(rule_file)
    end
    if follow_links
        check(get_all_filenames(filename), "")
        return
    end
    global rules
    counter = 1
    for line in readlines(filename)
        comment = occursin(r"%", line)
        if !comment
            for r in rules
                if occursin(r.regex, line) && !occursin(Regex("% OK $(r.name)"), line)
                    printstyled("$(r.name): ", color=:yellow, bold=true)
                    println(r.err)
                    printstyled("$filename: $counter", color=:green)
                    println()
                    new = println("$(lstrip(line))")
                    println()
                end
            end
        end
        counter +=1
    end
end

function check(filenames::Vector, rule_file; follow_links = false)
    if !isempty(rule_file)
        global rules = []
        include(rule_file)
    end
    for f in filenames
        check(f, "", follow_links = follow_links)
    end
end

end # module
