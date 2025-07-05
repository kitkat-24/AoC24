using DataStructures


function readInput(fname) 
    s = split.(readlines("day18/$(fname).txt"), ',')
    i = [parse.(Int, line) for line in s]
    c = [CartesianIndex(x...) for x in i]
    c .+= CartesianIndex(1,1) # Convert from 0- to 1-indexed
end

function dijkstra(grid, start, goal)
    dist = DefaultDict{CartesianIndex{2},Int}(typemax(Int))
    dist[start] = 0
    prev = Dict{CartesianIndex{2}, CartesianIndex{2}}()
    Q = PriorityQueue{CartesianIndex{2}, Int}()
    Q[start] = 0
    adj = CartesianIndex.(((1,0), (0,1), (-1,0), (0,-1)))

    while !isempty(Q)
        u = dequeue!(Q)
        if u == goal
            return u, dist, prev
        end

        for m ∈ adj
            n = u + m
            if checkbounds(Bool, grid, n) && grid[n] == 0
                cost = 1
                alt = dist[u] + cost
                if alt < dist[n]
                    dist[n] = alt
                    prev[n] = u
                    Q[n] = alt
                elseif alt == dist[n]
                    prev[n] = u
                    Q[n] = alt
                end
            end
        end
    end
    return [], [], [] # Want to know when no path, not just error
end

function printState(map)
    for row ∈ axes(map,1)
        println(String(map[row,:]))
    end
end

function printPath(grid, endNode, startPt, prev)
    g2 = repeat(['.'], inner=size(grid))
    g2[grid .== 1] .= '#'
    cur = endNode

    while true
        cur = prev[cur]
        g2[cur] = 'O'
        if cur == startPt
            break
        end
    end

    printState(g2)
    return sum(g2 .== 'O')
end


# P1
blocks = readInput("input")
blocksTrunc = blocks[1:1024] # Only first kilobyte
grid = zeros(Int, 71, 71)
startPt = CartesianIndex(1,1)
endPt = CartesianIndex(71,71)
grid[blocksTrunc] .= 1
foundEnd, dist, prev = dijkstra(grid, startPt, endPt)
printPath(grid, endPt, startPt, prev)

# P2
@time begin
grid = zeros(Int, 71, 71)
grid[blocksTrunc] .= 1
for k = 1025:length(blocks)
    grid[blocks[k]] = 1
    foundEnd, dist, prev = dijkstra(grid, startPt, endPt)
    if isempty(dist)
        println("Found blocker at blocks[$(k)]: $(blocks[k][1]-1),$(blocks[k][2]-1)")
        break
    end
end
end