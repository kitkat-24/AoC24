using DataStructures


readInput(fn) = stack(readlines("day16/$(fn).txt"); dims=1)
const WALL = '#'
const START = 'S'
const END = 'E'
const EMPTY = '.'
CI(x,y) = CartesianIndex(x,y)
const C2 = CartesianIndex{2}

function printState(map)
    for row ∈ axes(map,1)
        println(String(map[row,:]))
    end
end
turnLeft(dir) = CI(-dir[2], dir[1])
turnRight(dir) = CI(dir[2], -dir[1])
turnAround(dir) = turnRight(turnRight(dir))
const dirChars = Dict(CI(0,1) => '>', CI(1,0) => 'v', CI(0,-1) => '<', CI(-1,0) => '^')

# A* algorithm implementation. h is heuristic function
function jankStar(grid, start, goal, h)
    prevPath = Dict() # Value is previous node and direction to this node
    gScore = DefaultDict(Base.max_values(Int), start => 0)
    # Estimated cost via heuristic
    fScore = DefaultDict(Base.max_values(Int), start => h(start))
    # ordering = Base.Order.Lt((a,b) -> fScore[a] < fScore[b])
    frontier = PriorityQueue(start => fScore[start])

    dir = CI(0,1) # Always start facing east
    funcs = (turnLeft, identity, turnRight)
    costs = (1001, 1, 1001)

    println(frontier)
    while !isempty(frontier)
        cur = dequeue!(frontier)

        if cur == goal
            return gScore[cur], cur, prevPath
        end

        if haskey(prevPath, cur)
            _, dir = prevPath[cur]
        end

        dirs = map(f -> f(dir), funcs)
        for (step, cost) ∈ zip(dirs, costs)
            neighbor = cur + step
            if grid[neighbor] == WALL
                continue
            end
            tScore = gScore[cur] + cost
            if tScore < gScore[neighbor]
                prevPath[neighbor] = (cur, step)
                gScore[neighbor] = tScore
                fScore[neighbor] = tScore + h(neighbor)
                frontier[neighbor] = fScore[neighbor]
            end
        end
    end

    return nothing, nothing # Uh oh!
end

function printPath(grid, endPt, startPt, path)
    g2 = copy(grid)
    cur = endPt
    while true
        cur, dir = path[cur]
        if cur == startPt
            break
        end
        g2[cur] = dirChars[dir]
    end
    printState(g2)
end


fn = "input"
grid = readInput(fn);
# printState(grid)
startPt = findfirst(grid .== START)
goalPt = findfirst(grid .== END)
h(idx) = abs(idx[1] - goalPt[1]) + abs(idx[2] - goalPt[2])
# h(idx) = 0
@time score, endPt, path = jankStar(grid, startPt, goalPt, h);
if endPt != goalPt
    fprintf("Uh oh! Bad path computed...")
end
printPath(grid, endPt, startPt, path)
println("P1 score for $(fn): $(score)")

