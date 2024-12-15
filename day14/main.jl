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

function printGrid(pf, bounds)
    grid = [['.' for _ in 1:bounds[1]] for _ in 1:bounds[2]]
    robots = counter(Pair)
    for p ∈ pf
        p2 = Pair(p[1], p[2])
        robots[p2] += 1
    end
    for (k,v) ∈ robots
        grid[k[2]+1][k[1]+1] = Char('0' + v)
    end
    for line ∈ grid
        println(String(line))
    end
    grid
end

function moveBot(p, v, t, bounds)
    pf = p + t * v
    # Wrap back into grid
    pf = pf .% bounds
    # Wrap negatives
    pf[1] = pf[1] < 0 ? pf[1] + bounds[1] : pf[1]
    pf[2] = pf[2] < 0 ? pf[2] + bounds[2] : pf[2]
    pf
end

function simulate(robots, turns, bounds)
    pf = map(bot -> moveBot(bot.p, bot.v, turns, bounds), robots)
    x = [p[1] for p ∈ pf]
    y = [p[2] for p ∈ pf]

    mid = floor.(Int, bounds ./ 2)
    q1 = sum((x .< mid[1]) .&& (y .< mid[2]))
    q2 = sum((x .> mid[1]) .&& (y .< mid[2]))
    q3 = sum((x .< mid[1]) .&& (y .> mid[2]))
    q4 = sum((x .> mid[1]) .&& (y .> mid[2]))
    safetyFactor = q1*q2*q3*q4
    safetyFactor, (q1,q2,q3,q4), pf
end

function findXmasTree(robots, bounds)
    t = 1
    while t < 10000
        _, quads, pf = simulate(robots, t, bounds)
        for p ∈ pf
            dist = 15
            numNear = mapreduce(x -> sqrt((x[1]-p[1])^2 + (x[2]-p[2])^2) < dist, +, pf)
            if numNear > 200
                printGrid(pf, bounds)
                println("Found tree (turns = $(t)? N to continue, Y to exit")
                r = readline()
                println("Read: $(r)")
                @goto doneLoop
                if r == 'N'
                    break
                end
            end
        end
        t += 1
        if t % 100 == 0
            println("Turn $(t)/10000")
        end
    end
    @label doneLoop
    t
end

fn = "input"
robots = readInput(fn)
gridSize = gridBounds(fn)
simulate(robots, 100, gridSize)

findXmasTree(robots, gridSize)