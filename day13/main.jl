using LinearAlgebra
using Printf

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

function solve(fn, p2=false)
    problems = readInput(fn)
    costs = [3, 1]
    c = 0
    for p ∈ problems
        if p2; p[2] .+= 10000000000000; end
        # println(p)
        x = p[1] \ p[2]
        # @printf "%0.4f, %0.4f\n" x[1] x[2]
        if all(@. abs(x - round(x)) <= 1e-4)
            c1 = costs ⋅ round.(x)
            c += c1
        end
    end
    c
end

@time p1 = solve("input")
println("P1 answer: $(Int(p1))")

@time p2 = solve("input", true)
println("P2 answer: $(Int(p2))")

