using DataStructures
import Base: +,-


readInput(fn) = stack(readlines("day16/$(fn).txt"); dims=1)
const WALL = '#'
const START = 'S'
const END = 'E'
const EMPTY = '.'
CI(x,y) = CartesianIndex(x,y)
const C2 = CartesianIndex{2}
@enum Direction East = 1 South = 2 West = 3 North = 4
+(a::Direction, b::Int) = Direction(Int(a) % 4 + b)
function -(a::Direction, b::Int)
    c = Int(a) - b
    return c == 0 ? North : Direction(c)
end
struct Node
    pos::C2
    dir::Direction
end

function printState(map)
    for row ∈ axes(map,1)
        println(String(map[row,:]))
    end
end
turnLeft(dir) = CI(-dir[2], dir[1])
turnRight(dir) = CI(dir[2], -dir[1])
turnAround(dir) = turnRight(turnRight(dir))
const dirChars = Dict(CI(0,1) => '>', CI(1,0) => 'v', CI(0,-1) => '<', CI(-1,0) => '^')
const offsets = Dict(East => CI(0,1), South => CI(1,0), West => CI(0,-1), North => CI(-1,0))

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

function dijkstra(grid, start, goal)
    startNode = Node(start, East)
    dist = DefaultDict{Node,Int}(typemax(Int))
    dist[startNode] = 0
    prev = Dict{Node,Node}()
    Q = PriorityQueue{Node, Int}()
    Q[startNode] = 0

    while !isempty(Q)
        u = dequeue!(Q)
        if u.pos == goal
            return u, dist, prev
        end

        for (n, cost) ∈ zip((Node(u.pos + offsets[u.dir], u.dir), Node(u.pos, u.dir-1), Node(u.pos, u.dir+1)), [1, 1000, 1000])
            if grid[n.pos] != WALL
                alt = dist[u] + cost
                if alt < dist[n]
                    dist[n] = alt
                    prev[n] = u
                    Q[n] = alt
                end
            end
        end
    end
    error("Didn't find goal!")
end

function printPath(grid, endNode, startPt, path)
    g2 = copy(grid)
    cur = endNode
    while true
        cur = path[cur]
        if cur.pos == startPt
            break
        end
        g2[cur.pos] = dirChars[offsets[cur.dir]]
    end
    printState(g2)
end


fn = "input"
grid = readInput(fn);
# printState(grid)
startPt = findfirst(grid .== START)
goalPt = findfirst(grid .== END)
# h(idx) = abs(idx[1] - goalPt[1]) + abs(idx[2] - goalPt[2])
# h(idx) = 0
# @time score, endPt, path = jankStar(grid, startPt, goalPt, h);
@time endNode, dist, prev = dijkstra(grid, startPt, goalPt)
dist[endNode]
# if endPt != goalPt
#     fprintf("Uh oh! Bad path computed...")
# end
printPath(grid, endNode, startPt, prev)
# println("P1 score for $(fn): $(score)")

