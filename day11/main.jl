using Memoization
test = parse.(Int, split(read("day11/test.txt", String)))
input = parse.(Int, split(read("day11/input.txt", String)))

@memoize function blink(stone)
    if stone == 0
        return [1]
    elseif ceil(Int, log10(stone+1)) % 2 == 0
        n = 10^(ceil(Int, log10(stone+1)) ÷ 2)
        return [stone ÷ n, stone % n]
    else
        return [stone * 2024]
    end
end

@time begin
stones = copy(input)
nBlinks = 25
for n = 1:nBlinks
    i = 1
    global stones = reduce(vcat, blink.(stones))
end
println("Numbers of stones after $(nBlinks) is $(length(stones))")
end