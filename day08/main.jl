testGrid = stack(readlines("day08/test.txt"); dims=1)
grid = stack(readlines("day08/input.txt"); dims=1)

isAntenna(c) = c != '.'
printMat(m) = println(join((join(m[i,:]) for i in axes(m,1)), "\n"))
getPairs(x) = (Pair(x[i], x[j]) for i = eachindex(x) for j = i:length(x) if i != j)

function solve(grid, p2)
    antIdx = findall(isAntenna.(grid))
    antennas = unique(grid[antIdx])
    antiNodes = Set()

    for ant ∈ antennas
        idx = antIdx[grid[antIdx] .== ant]

        for p ∈ getPairs(idx)
            slope = p.second - p.first
            if p2
                for op ∈ [+, -] # Forwards and backwards
                    n = 0
                    point = op(p.first, slope*n)
                    while checkbounds(Bool, grid, point)
                        push!(antiNodes, point)
                        n += 1
                        point = op(p.first, slope*n)
                    end
                end
            else
                a1 = p.first - slope
                if checkbounds(Bool, grid, a1)
                    push!(antiNodes, a1)
                end
                a2 = p.second + slope
                if checkbounds(Bool, grid, a2)
                    push!(antiNodes, a2)
                end
            end
        end
    end
    return antiNodes
end

function showAns(grid, nodes)
    grid = copy(grid)
    for node ∈ nodes
        if !isAntenna(grid[node])
            grid[node] = '#'
        end
    end
    printMat(grid)
end

@time nodes = solve(grid, false)
showAns(grid,nodes)
println("P1 anti-node count: $(length(nodes))")

@time nodes = solve(grid, true)
# showAns(grid,nodes)
println("P2 anti-node count: $(length(nodes))")
