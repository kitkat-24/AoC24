using Printf
# Read data and parse
test = stack(readlines("day06/test.txt"); dims=1);
grid = stack(readlines("day06/input.txt"); dims=1);

mutable struct Guard
    idx
    const states
    const moves 

    # Inner constructor for constants
    function Guard(i)
        new(i, "^>v<", [CartesianIndex(-1,0), CartesianIndex(0,1), CartesianIndex(1,0), CartesianIndex(0,-1)])
    end
end

function turn!(guard)
    guard.idx = guard.idx % length(guard.states) + 1
end

function setIdx!(guard, state)
    guard.idx = findfirst(isequal(state), guard.states)
end

function move(guard, idx::CartesianIndex)
    idx = idx + guard.moves[guard.idx]
end

function marker(guard::Guard)
    (guard.idx == 1 || guard.idx == 3) ? '|' : '-'
end

function walkPath(grid, findCycles)
    path = copy(grid)
    idx = findfirst(grid .== '^')
    guard = Guard(1)
    nextIdx = move(guard, idx)
    path[idx] = marker(guard)
    turns = Set()
    while (checkbounds(Bool, grid, nextIdx))
        if isObst(grid[nextIdx])
            newTurn = (idx, guard.idx)
            # If we make a turn we made before, we're in a cycle
            if findCycles && newTurn ∈ turns
                return path, true
            end
            push!(turns, (idx, guard.idx))
            turn!(guard)
            path[idx] = '+'
        else
            idx = nextIdx
            # path[idx] = marker(guard)
        end
        # if path[idx] != '+'; path[idx] = guard.states[guard.idx]; end
        if path[idx] != '+'; path[idx] = marker(guard); end
        nextIdx = move(guard, idx)
        # printMat(path)
        # sleep(0.1)
    end

    return path, false
end

function printMat(m)
    for i = axes(m,1)
        for j = axes(m,2)
            print(m[i,j])
        end
        println()
    end
end

# Brute force! Fuckit!
function findObstructions(grid, path)
    obstaclesFound = 0
    for idx ∈ eachindex(grid)
        if grid[idx] == '#' || grid[idx] == '^'
            continue
        end
        g2 = copy(grid)
        g2[idx] = 'O'
        # printMat(g2)
        p2, obst = walkPath(g2, true)
        # if obst
        #     # printMat(p2)
        # end
        obstaclesFound += obst 
    end
    return obstaclesFound
end

inPath(c) = c != '.' && c != '#'
isObst(c) = c == '#' || c == 'O'

# grid = test;
# P1
@time path, _ = walkPath(grid, false);
printMat(path)
@printf "P1: %d locations visited!\n" sum(inPath.(path))
#P2
@time numObst = findObstructions(grid, path)