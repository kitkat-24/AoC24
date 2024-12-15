using DataStructures


function readInput(fn)
    text = readlines("day14/$(fn).txt")
    exp = r"(-?\d+),(-?\d+)[^\d^-]*(-?\d+),(-?\d+)"
    robots = []
    for line in text
        m = match(exp, line)
        push!(robots, (p = parse.(Int, [m[1],m[2]]), v = parse.(Int, [m[3],m[4]])))
    end
    robots
end

function gridBounds(fn)
    if fn == "test"
        return 11, 7
    elseif fn == "input"
        return 101, 103
    else
        error("uh oh")
    end
end

function printGrid(xs, ys, bounds)
    grid = ['.' for _ in 1:bounds[2], _ in 1:bounds[1]]
    robots = counter(Pair)
    for (x,y) in zip(xs,ys)
        p = Pair(x,y)
        robots[p] += 1
    end
    for (k,v) ∈ robots
        grid[k[2]+1, k[1]+1] = Char('0' + v)
    end
    display(grid)
    grid
end

function simulate(robots, turns, bounds)
    x = []; y = []
    for robot ∈ robots
        # Just do all turns at once
        pf = robot.p + turns * robot.v
        # Wrap back into grid
        pf = pf .% bounds
        # Wrap negatives
        pf[1] = pf[1] < 0 ? pf[1] + bounds[1] : pf[1]
        pf[2] = pf[2] < 0 ? pf[2] + bounds[2] : pf[2]
        push!(x, pf[1])
        push!(y, pf[2])
    end

    # grid = printGrid(x,y,bounds)

    mid = floor.(Int, bounds ./ 2)
    # grid[mid[2], :] .= ' '
    # grid[:, mid[1]] .= ' '
    # display(grid)
    q1 = sum((x .< mid[1]) .&& (y .< mid[2]))
    q2 = sum((x .> mid[1]) .&& (y .< mid[2]))
    q3 = sum((x .< mid[1]) .&& (y .> mid[2]))
    q4 = sum((x .> mid[1]) .&& (y .> mid[2]))
    safetyFactor = q1*q2*q3*q4
end

fn = "input"
robots = readInput(fn)
gridSize = gridBounds(fn)
simulate(robots, 100, gridSize)