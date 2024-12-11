using Memoization
test = parse.(Int, split(read("day11/test.txt", String)))
input = parse.(Int, split(read("day11/input.txt", String)))

# Just return # of stones spawned by a certain number of blinks for a given stone so we can process recursively
@memoize Dict function blink(stone, depth)
    if depth == 0
        return 1
    end

    if stone == 0
        return blink(1, depth - 1)
    else
        digits = ceil(Int, log10(stone+1))
        if iseven(digits)
            n = 10^(digits >> 1)
            return blink(stone ÷ n, depth - 1) + blink(stone % n, depth - 1)
        else
            return blink(stone * 2024, depth - 1)
        end
    end
end

@time begin
stones = copy(input)
nBlinks = 75
nStones = sum(blink.(stones, nBlinks))
println("Numbers of stones after $(nBlinks) blinks is $(nStones)")
end