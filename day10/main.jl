testGrid = parse.(UInt8, stack(readlines("day10/test.txt"); dims=1))
input = parse.(UInt8, stack(readlines("day10/input.txt"); dims=1))

module M
    struct Node
        pos::CartesianIndex{2}
        val::UInt8
        prev::Union{Nothing, CartesianIndex{2}}
        next::Vector{CartesianIndex{2}}

        function Node(pos, val, prev)
            new(pos, val, prev, Vector{CartesianIndex{2}}())
        end
    end
end

function solve(grid; p1=true)
    idx = findall(grid.==0)
    trailheads = M.Node.(idx, grid[idx], nothing)
    nodes = Dict{CartesianIndex{2}, M.Node}([t.pos for t in trailheads] .=> trailheads)
    scores = []
    for n ∈ trailheads
        visited = Dict{CartesianIndex{2},Bool}(n.pos => true)
        push!(scores, dfs(n, nodes, grid, visited, p1))
    end
    return scores, nodes
end

function dfs(n, nodes, grid, visited, p1)
    if n.val == 9
        return 1
    end

    count = 0
    directions = CartesianIndex.(((1,0), (0,1), (-1,0), (0,-1)))
    for d ∈ directions
        p = n.pos + d
        if checkbounds(Bool, grid, p) && !get(visited, p, false) && grid[p] == n.val + 1
            n2 = get!(nodes, p, M.Node(p, grid[p], n.pos))
            push!(n.next, n2.pos)
            visited[p] = p1 & true
            count += dfs(n2, nodes, grid, visited, p1)
        end
    end
    return count
end

@time scores, nodes = solve(input, p1=true);
println("P1 sum of scores = $(sum(scores))")

@time scores, nodes = solve(input, p1=false);
println("P2 sum of scores = $(sum(scores))")
