using Memoization


function readdata(fname)
    data = readlines("day19/$(fname).txt")
    towels = String.(split(data[1], ", ")) # Allocate new strings rather than SubString views
    patterns = data[3:end]
    return towels, patterns
end

@memoize function isPossible(pattern, towels)
# function isPossible(pattern, towels)
    possible = false
    for tok in towels
        # Token is valid, and there is more to match
        # Do "DFS" greedy matching to accelerate through runs
        i = 1
        n = length(tok)
        while i+n-1 <= length(pattern) && pattern[i:i+n-1] == tok
            i += n
        end
        if i == length(pattern) + 1 # We consumed whole pattern to the end with this token
            return true
        elseif i > length(pattern) + 1 # We overran with the last pattern
            println("Hit new case!")
        elseif i > 1 # We consumed part of the pattern with this token
            if isPossible(pattern[i:end], towels) # Always return true as soon as possible case is found
                return true
            end
        end
    end

    # Fell through = could not match up whole pattern
    return possible
end

@memoize function numPossible(pattern, towels)
    # While for P1 we just returned early if it was possible at all, for P2 we
    # need to count all solutions. It's possible if ways > 0
    ways = 0
    for tok in towels
        n = length(tok)
        if n < length(pattern) && pattern[1:n] == tok
            ways += numPossible(pattern[n+1:end], towels)
        elseif n == length(pattern) && pattern == tok
            ways += 1
        end
    end
    return ways
end

towels, patterns = readdata("test")
isPossible("bbr", towels)
possible = [isPossible(p, towels) for p in patterns]
for i = eachindex(possible)
    println("$(patterns[i]) is $(possible[i] ? "possible" : "impossible")")
end
isPossible("bwurrg", towels)

# P1
towels, patterns = readdata("input")
@time possible = [isPossible(p, towels) for p in patterns]
println("$(sum(possible)) designs are possible")

# P2
towels, patterns = readdata("test")
possible = [numPossible(p, towels) for p in patterns]
for i = eachindex(possible)
    println("$(patterns[i]) has $(possible[i]) possibilities")
end

towels, patterns = readdata("input")
@time possible = [numPossible(p, towels) for p in patterns];
println("There are $(sum(possible)) designs possible")