using LinearAlgebra

function readInput(fn)
    text = split(replace(read("day13/$(fn).txt", String), r"\r"=>""), "\n\n")
    exp = r"(\d+)[^\d]*(\d+)\n[^\d]*(\d+)[^\d]*(\d+)\n[^\d]*(\d+)[^\d]*(\d+)" # This is nasty but it works (match one whole problem at once)
    problems = []
    for block in text
        m = match(exp, block)
        a = parse.(Int, [m[1], m[3], m[2], m[4]])
        A = [a[1] a[2]; a[3] a[4]]
        b = parse.(Int, [m[5], m[6]])
        push!(problems, Pair(A, b))
    end
    problems
end

function solveP1(fn)
    problems = readInput(fn)
    costs = [3, 1]
    c = 0
    for p ∈ problems
        x = p[1] \ p[2]
        if all(@. abs(x - round(x)) <= 1e-10)
            c1 = costs ⋅ round.(x)
            c += c1
        end
    end
    c
end

@time p1 = solveP1("input")
println("P1 answer: $(Int(p1))")

