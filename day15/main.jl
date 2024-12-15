function readInput(fn)
    blocks = split(read("day15/$(fn).txt", String), "\n\n")
    map = stack(split(blocks[1], "\n"); dims=1)
    commands = replace(blocks[2], "\n"=>"")
    return map, commands
end

CI(x,y) = CartesianIndex(x,y) # Covenience wrapper
const WALL  = '#'
const EMPTY = '.'
const ROBOT = '@'
const BOX   = 'O'
const BOXL  = '['
const BOXR  = ']'

function widen(map)
    m2 = [map map] # Lazy allocation
    for i ∈ eachindex(IndexCartesian(), map)
        x1 = CI(i[1], 2*(i[2]-1)+1)
        x2 = CI(i[1], 2*i[2])
        if map[i] == ROBOT
            m2[x1] = map[i]
            m2[x2] = EMPTY
        elseif map[i] == BOX
            m2[x1] = BOXL
            m2[x2] = BOXR
        else
            m2[x1] = map[i]
            m2[x2] = map[i]
        end
    end
    return m2
end

function executeP1!(map, rpos, move)
    # Explore direction of move
    next = rpos + move
    if map[next] == EMPTY # Just move and done!
        map[next] = ROBOT
        map[rpos] = EMPTY
        return rpos + move
    end
    while map[next] == BOX
        next = next + move
    end
    if map[next] == EMPTY # Can shove box(es)
        # Smart movement: only need to change 3 positions, not whole run
        map[next] = BOX
        map[rpos + move] = ROBOT
        map[rpos] = EMPTY
        return rpos + move
    end
    # Otherwise, there is no space to push stuff into, so can't move
    return rpos
end

function buildBlockTreeDFS(map, root, move)
end

function executeP2!(map, rpos, move)
    # Simple cases first (no pushing, horizontal pushing)
    next = rpos + move
    if map[next] == EMPTY # Just move and done!
        map[next] = ROBOT
        map[rpos] = EMPTY
        return rpos + move
    end
    if move[1] == 0
        while map[next] == BOXL || map[next] == BOXR
            next = next + move
        end
        if map[next] == EMPTY # Can shove box(es)
            # Now have to do whole shift :(
            if next[2] < rpos[2]
                map[next[1], next[2]:rpos[2]-1] = map[next[1], next[2]+1:rpos[2]]
            else
                map[next[1], rpos[2]+1:next[2]] = map[next[1], rpos[2]:next[2]-1]
            end
            map[rpos] = EMPTY
            return rpos + move
        end
    else # Now there is (potentially) a cascading tree of overlaping boxes and walls :(
        # We will DFS the tree bc any blocked node blocks all parents
    end
    # Otherwise, there is no space to push stuff into, so can't move
    return rpos
end

function printState(map)
    for row ∈ axes(map,1)
        println(String(map[row,:]))
    end
end

function gpsScore(map, p2)
    c = p2 ? BOXL : BOX
    idx = findall(map .== c)
    return sum(x -> 100*(x[1]-1) + (x[2]-1), idx)
end

function solve(fn; p2=false)
    map, commands = readInput(fn)
    moves = Dict('v' => CI(1,0), '>' => CI(0,1), '^' => CI(-1,0), '<' => CI(0,-1))
    rpos = findfirst(map .== ROBOT)
    for comm ∈ commands
        rpos = executeP1!(map, rpos, moves[comm])
    end

    # printState(map)

    return gpsScore(map, p2)
end

@time score = solve("input", p2=false)
println("P1: score = $(score)")

# @time score2 = solve("input", p2=true)
# println("P2: score = $(score2)")