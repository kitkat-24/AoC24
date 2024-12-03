# Read data and parse
test1 = read("day03/test.txt", String)
test2 = read("day03/test2.txt", String)
lines = readlines("day03/input.txt")

function p1(lines)
    expr = r"mul\((\d{1,3}),(\d{1,3})\)"
    sum = 0
    for data in lines
        for m in eachmatch(expr, data)
            n1, n2 = parse(Int,m[1]), parse(Int,m[2])
            sum += n1*n2
        end
    end
    sum
end

function p2(lines)
    expr = r"do\(\)|don't\(\)|mul\((\d{1,3}),(\d{1,3})\)"
    sum = 0
    enabled = true
    for data in lines
        for m in eachmatch(expr, data)
            if m.match == "do()"
                enabled = true
                continue
            elseif m.match == "don't()"
                enabled = false
            end

            if !enabled
                continue
            end

            n1, n2 = parse(Int,m[1]), parse(Int,m[2])
            sum += n1*n2
        end
    end
    sum
end

ans1 = @time p1(lines)

ans2 = @time p2(lines)
