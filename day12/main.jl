readInput(fname) = stack(readlines("day12/$(fname).txt"); dims=1)

# Theory: assign every tile to a unique group, then merge until all tiles either
# have no adjacent ones with the same value, or all neighbors are in the same
# group
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

function p1Cost(groupMap, groups, perims)
    areas = [sum(groupMap .== g) for g ∈ groups]
    sum(areas .* perims)
end

@time begin
    file = "input"
    grid = readInput(file)
    gmap, groups, perims = findGroups(grid)
    cost = p1Cost(gmap, groups, perims)
    println("P1 cost for $(file) = $(cost)")
end