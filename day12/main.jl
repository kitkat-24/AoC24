readInput(fname) = stack(readlines("day12/$(fname).txt"); dims=1)

function bfs!(groupMap, grid, i, g)
    adj = CartesianIndex.(((1,0), (0,1), (-1,0), (0,-1)))
    groupMap[i] = g
    Q = [i]
    perim = 0
    while !isempty(Q)
        v = popfirst!(Q)
        perimScore = 4 # Each node v starts at potential perimeter of 4
        # Use generator for less allocation (making this a list increased runtime by 33% due to GC according to @time)
        neighbors = (v + a for a in adj if checkbounds(Bool, grid, v+a) && grid[v+a] == grid[v])
        for n ∈ neighbors
            if groupMap[n] == 0
                groupMap[n] = g
                push!(Q, n)
            end
            perimScore -= 1 # Each valid neighbor means no perimeter for v there, even if it was already visited
        end
        perim += perimScore
    end
    perim
end

# Approach: Start at an ungrouped tile, use BFS to flood-fill out the group,
# counting the perimeter as we go
function findGroups(grid)
    groupMap = zeros(UInt16, size(grid)) # Input is 140x140 so max 19600 unique groups

    i = findfirst(groupMap .== 0)
    g = 1
    perims = []
    groups = []
    while !isnothing(i)
        push!(perims, bfs!(groupMap, grid, i, g))
        push!(groups, g)
        g += 1
        i = findfirst(groupMap .== 0)
    end
    groupMap, groups, perims
end

function p1Cost(areas, perims)
    sum(areas .* perims)
end

# Given we already have groups, just walk along the edge of each group to count the sides
function countSides(groups, gmap)
    adj = CartesianIndex.(((1,0), (0,1), (-1,0), (0,-1)))
    down, right, up, left = adj
    sides = []
    # "Corner kernel
    ck = collect(CartesianIndices((2,2))) .- CartesianIndex(1,1)

    # I am not dealing with literal edge cases rn...
    x,y = size(gmap)
    gmap2 = typemax(eltype(gmap)) .* ones(eltype(gmap), x+2,y+2)
    gmap2[2:end-1,2:end-1] = gmap

    val(x) = gmap2[x]

    for g ∈ groups
        idx = gmap2 .== g
        if sum(idx) == 1
            push!(sides, 4)
            continue
        end
        same(x) = val(x) == g

        corners = 0
        for i ∈ findall(idx)
            if !same(i + down) && !same(i + right) # bottom-right
                corners += 1
            end
            if !same(i + right) && !same(i + up) # top-right
                corners += 1
            end
            if !same(i + up) && !same(i + left) # top-left
                corners += 1
            end
            if !same(i + left) && !same(i + down) # bottom-left
                corners += 1
            end
            # Concave corners
            if same(i+left) && same(i+up) && !same(i+left+up) # bottom-right
                corners += 1
            end
            if same(i+down) && same(i+left) && !same(i+down+left) # top-right
                corners += 1
            end
            if same(i+right) && same(i+down) && !same(i+right+down) # top-left
                corners += 1
            end
            if same(i+up) && same(i+right) && !same(i+up+right) # bottom-left
                corners += 1
            end
        end
        push!(sides, corners)
    end
    sides
end

function p2Cost(areas, sides)
    sum(areas .* sides)
end

@time begin
    file = "input"
    grid = readInput(file)
    gmap, groups, perims = findGroups(grid)
    areas = [sum(gmap .== g) for g ∈ groups]
    cost = p1Cost(areas, perims)
    println("P1 cost for $(file) = $(cost)")

    sides = countSides(groups, gmap)
    cost = p2Cost(areas, sides)
    println("P2 cost for $(file) = $(cost)")
end