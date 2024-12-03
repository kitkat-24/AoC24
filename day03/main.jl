@time begin
# Read data and parse
lines = readlines("day03/input.txt")

# P1
expr = r"mul\((\d{1,3}),(\d{1,3})\)"
sum = 0
for data in lines
    for m in eachmatch(expr, data)
        n1, n2 = parse(Int,m[1]), parse(Int,m[2])
        global sum += n1*n2
    end
end
sum
end
