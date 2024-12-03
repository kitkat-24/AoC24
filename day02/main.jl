@time begin
# Read data and parse
lines = readlines("day02/input.txt")
lines = split.(lines," ")
levels = map(v -> parse.(Int, v), lines)

# P1
function isSafe(x)
    d = diff(x)
    safe = all(sign.(d) .== sign(d[1])) && all(abs.(d) .>= 1 .&& abs.(d) .<= 3)
end
safe = map(isSafe, levels)
p1 = sum(safe)

# P2
unsafe = findall(.!safe)
# Honestly just writing this the lazy way
badLevels = levels[unsafe]
p2 = p1

for level in badLevels
    for i in range(1,length(level))
        idx = collect(range(1,length(level)))
        deleteat!(idx, i)
        if isSafe(level[idx])
            global p2 += 1
            break
        end
    end
end
p2
end