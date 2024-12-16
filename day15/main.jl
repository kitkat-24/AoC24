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

# Move via left block
function buildBlockTreeBFS(map, root, move)
    tree = []
    Q = [root]
    while !isempty(Q)
        v = popfirst!(Q)
        push!(tree, v)
        nextL = v + move; nextR = v + move + CI(0,1)
        # println("Root = $(v), nextL = $(nextL), nextR = $(nextR)")
        if map[nextL] == WALL || map[nextR] == WALL # Whole tree cannot move!
            return nothing
        end

        if map[nextL] == BOXL # Just one box directly lined up
            push!(Q, nextL)
        else
            if map[nextL] == BOXR
                push!(Q, v + move + CI(0,-1))
            end
            if map[nextR] == BOXL
                push!(Q, nextR)
            end
        end
    end
    # We want "deepest" nodes first
    return reverse(tree)
end

function executeP2!(map, rpos, move)
    # Simple cases first (no pushing, horizontal pushing)
    next = rpos + move
    if map[next] == EMPTY # Just move and done!
        map[next] = ROBOT
        map[rpos] = EMPTY
        return rpos + move
    end
    if map[next] == WALL # Can't move!
        return rpos
    end
    if move[1] == 0 # Horizonal moves are like P1
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
        # Root is the left-half of the box the robot is directly pushing
        if map[next] == BOXR
            root = next + CI(0,-1)
        else
            root = next
        end
        boxes = buildBlockTreeBFS(map, root, move)
        if !isnothing(boxes) # we can move
            # println("Map pre tree move:")
            # printState(map)
            # println("Tree: $(boxes)")
            # Boxes should be ordered so first elements are the bottom of the
            # tree (so that we don't overwrite anything while moving)
            for box ∈ boxes
                map[box + move] = BOXL
                map[box + move + CI(0,1)] = BOXR
                map[box] = EMPTY
                map[box + CI(0,1)] = EMPTY
            end
            map[next] = ROBOT
            map[rpos] = EMPTY
            # println("Map after tree move:")
            # printState(map)
            rpos = next
        end
    end
    # Otherwise, there is no space to push stuff into, so can't move
    return rpos
end

function printState(map)
    for row ∈ axes(map,1)
        println(String(map[row,:]))
    end
end

function gpsScore(map, p1)
    c = p1 ? BOX : BOXL
    idx = findall(map .== c)
    return sum(x -> 100*(x[1]-1) + (x[2]-1), idx)
end

function solve(fn; p1=true)
    moves = Dict('v' => CI(1,0), '>' => CI(0,1), '^' => CI(-1,0), '<' => CI(0,-1))
    map, commands = readInput(fn)
    if !p1
        map = widen(map)
        printState(map)
    end
    rpos = findfirst(map .== ROBOT)
    for comm ∈ commands
        if p1
            rpos = executeP1!(map, rpos, moves[comm])
        else
            rpos = executeP2!(map, rpos, moves[comm])
        end
    end

    printState(map)

    return gpsScore(map, p1), map
end

@time score = solve("input", p1=true)
println("P1: score = $(score)")

@time score2, map2 = solve("input", p1=false)
println("P2: score = $(score2)")