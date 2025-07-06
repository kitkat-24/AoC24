using DataStructures


readdata(fname) = stack(readlines("day20/$(fname).txt"); dims=1)

START = 'S'
END = 'E'
WALL = '#'
OPEN = '.'

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
            if checkbounds(Bool, grid, n) && grid[n] != WALL
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

function searchSkips(path, track)
    adj = CartesianIndex.(((1,0), (0,1), (-1,0), (0,-1)))
    indices = Dict((p => i for (i,p) in enumerate(path)))
    skips = []

    for s in path
        for d in adj
            # If inbounds AND skipping a real wall AND land in valid tile
            if checkbounds(Bool, track, s+2*d) && track[s+d] == WALL && track[s+2*d] != WALL
                distSaved = indices[s+2*d] - indices[s] - 2 # We spend 2ps doing the skip
                if distSaved > 0 # Skipping backwards won't help...
                    push!(skips, (s, s+2*d, distSaved))
                end
            end
        end
    end

    return skips
end

function buildPath(startPt, endPt, prev)
    path = [endPt]
    while true
        push!(path, prev[path[end]])
        if path[end] == startPt
            break
        end
    end
    return path
end

# Test
begin
    track = readdata("test")
    startPt = findfirst(track .== START)
    endPt = findfirst(track .== END)

    _, dist, prev = dijkstra(track, startPt, endPt)
    baseDist = dist[endPt]
    path = buildPath(startPt, endPt, prev)
    @assert length(path) == baseDist + 1
    reverse!(path) # Make it start at the start point...

    skips = searchSkips(path, track)
    idx = findall((s[3] >= 20 for s in skips))
    skips[idx]
end

# P1
@time begin
    track = readdata("input")
    startPt = findfirst(track .== START)
    endPt = findfirst(track .== END)

    _, dist, prev = dijkstra(track, startPt, endPt)
    baseDist = dist[endPt]
    path = buildPath(startPt, endPt, prev)
    @assert length(path) == baseDist + 1
    reverse!(path) # Make it start at the start point...

    skips = searchSkips(path, track)
    idx = findall((s[3] >= 100 for s in skips))
    length(idx)
end

