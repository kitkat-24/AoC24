testGrid = parse.(UInt8, stack(readlines("day10/test.txt"); dims=1))
input = parse.(UInt8, stack(readlines("day10/input.txt"); dims=1))

function solve(grid; p1=true)
    trailheads = findall(grid.==0)
    scores = []
    for n ∈ trailheads
        visited = Dict{CartesianIndex{2},Bool}(n => true)
        push!(scores, dfs(n, grid, visited, p1))
    end
    return scores
end

function dfs(n, grid, visited, p1)
    if grid[n] == 9
        return 1
    end

    count = 0
    directions = CartesianIndex.(((1,0), (0,1), (-1,0), (0,-1)))
    for d ∈ directions
        p = n + d
        if checkbounds(Bool, grid, p) && !get(visited, p, false) && grid[p] == grid[n] + 1
            visited[p] = p1 & true # We want to find each endpoint once in P1, but as many times as possible in P2
            count += dfs(p, grid, visited, p1)
        end
    end
    return count
end

@time scores = solve(input, p1=true);
println("P1 sum of scores = $(sum(scores))")

@time scores = solve(input, p1=false);
println("P2 sum of scores = $(sum(scores))")
