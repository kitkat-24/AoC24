using Printf
# Read data and parse
# test = stack(readlines("day06/test.txt"); dims=1);
grid = stack(readlines("day06/input.txt"); dims=1);


turn(guardState) = guardState = guardState % 4 + 1
# move(guard::Guard, idx::CartesianIndex) = idx = idx + guardMoves[guard.idx]
# marker(guard::Guard) = (guard.idx == 1 || guard.idx == 3) ? '|' : '-'
# vert(guard::Guard) = guard.idx % 2 == 1

isObst(c) = c == '#' || c == 'O'
inPath(c) = c != '.' && !isObst(c)

function printMat(m)
    for i = axes(m,1)
        for j = axes(m,2)
            print(m[i,j])
        end
        println()
    end
end

function walkPath(grid, startIdx, findCycles)
    guardMoves = [CartesianIndex(-1,0), CartesianIndex(0,1), CartesianIndex(1,0), CartesianIndex(0,-1)]
    path = [startIdx]
    idx = startIdx
    guardState = 1 # Start facing up
    @inbounds nextIdx = idx + guardMoves[guardState]
    turns = Set()
    while (checkbounds(Bool, grid, nextIdx))
        if isObst(grid[nextIdx])
            newTurn = (idx, guardState)
            # If we make a turn we made before, we're in a cycle
            if findCycles && newTurn ∈ turns
                return path, true
            end
            push!(turns, newTurn)
            guardState = turn(guardState)
        else
            idx = nextIdx
        end
        if !findCycles
            push!(path, idx)
        end
        @inbounds nextIdx = idx + guardMoves[guardState]
    end

    return path, false
end

function findObstructions(grid, path)
    obstaclesFound = 0
    g2 = copy(grid)
    start = findfirst(grid .== '^')
    for idx ∈ path
        if grid[idx] == '^'
            continue
        end
        g2[idx] = 'O'
        p2, obst = walkPath(g2, start, true)
        obstaclesFound += obst
        g2[idx] = '.' # Reset grid
    end
    return obstaclesFound
end

# grid = test;

# P1
@time path, _ = walkPath(grid, findfirst(grid .== '^'), false);
uniquePath = unique(path)
# @profview path, _ = walkPath(grid, false)
# printMat(path)
@printf "P1: %d locations visited!\n" length(uniquePath)

#P2
@time numObst = findObstructions(grid, uniquePath)
@profview begin
    for i = 1:10
        numObst = findObstructions(grid, uniquePath)
    end
end
@printf "P2: %d possible obstructions!\n" numObst