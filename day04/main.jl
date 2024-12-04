# Read data and parse
test1 = readlines("day04/test1.txt")
lines = readlines("day04/input.txt")


function explore(text, i, dir, depth)
    next = ['M', 'A', 'S']
    if !checkbounds(Bool, text, i+dir)
        return false
    end
    if text[i+dir] != next[depth]
        return false
    end
    if depth == 3
        return true # Yippee!
    end

    explore(text, i+dir, dir, depth+1)
end

function testPrint(text)
    for row = axes(text)[1]
        for col = axes(text)[2]
            print(text[row,col])
        end
        println()
    end
end

function p1(text)
    invalid = trues(size(text))

    # Construct cardinal direction offset indices
    adj = [CartesianIndex(m1,m2) for m2 = -1:1 for m1 = -1:1 if m1 != 0 || m2 != 0]

    count = 0
    for i ∈ eachindex(IndexCartesian(), text)
        if text[i] == 'X' # Every XMAS needs its X!
            for dir ∈ adj
                i2 = [i+dir*k for k ∈ 0:3]
                if explore(text, i, dir, 1)
                    invalid[i2] .= false
                    count += 1
                end
            end
        end
    end

    # text[invalid] .= '.'

    return count
end

function checkX(text, i, corners)
    c = 0
    for cc in corners
        if !checkbounds(Bool, text, i+cc) || !checkbounds(Bool, text, i-cc)
            continue
        end
        if text[i+cc] == 'M' && text[i-cc] == 'S'
            c += 1
        end
    end
    return c == 2
end

function p2(text)
    invalid = trues(size(text))

    # Construct diagonal direction offset indices
    adj = [CartesianIndex(m1,m2) for m2 = -1:2:1 for m1 = -1:2:1]

    count = 0
    for i ∈ eachindex(IndexCartesian(), text)
        if text[i] == 'A' # Every X-MAS needs its A!
            if checkX(text, i, adj)
                i2 = [i+dir for dir in adj]
                invalid[i2] .= false
                invalid[i] = false
                count += 1
            end
        end
    end

    # text[invalid] .= '.'
    # testPrint(text)

    return count
end

text = reduce(vcat, permutedims.(collect.(lines)))
p1(text)
p2(text)