using Printf 


# Read data and parse
test = readlines("day05/test.txt")
lines = readlines("day05/input.txt")

function parseRules(lines)
    rules = Dict{Int, Set{Int}}()
    updatesReached = false
    updates = Vector{String}()
    for line in lines
        if line == ""
            updatesReached = true; 
            continue
        end

        if !updatesReached # We're reading rules
            nums = parse.(Int, split(line,'|'))
            if !haskey(rules, nums[1])
                rules[nums[1]] = Set{Int}()
            end
            push!(rules[nums[1]], nums[2])
        else
            push!(updates, line)
        end
    end
    return rules, updates 
end

function p1(rules, updates)
    count = 0
    for update in updates
        pages = parse.(Int, split(update, ","))
        lt(x,y) = haskey(rules, x) && y ∈ rules[x]
        
        if issorted(pages, lt=lt)
            midPage = pages[ceil(Int, length(pages)/2)]
            # @printf "Valid page: %s\n" update
            # @printf "count: %d + %d = %d\n" count midPage count+midPage
            count += midPage
        end
    end
    return count
end

function p2(rules, updates)
    count = 0
    for update in updates
        pages = parse.(Int, split(update, ","))
        lt(x,y) = haskey(rules, x) && y ∈ rules[x]
        
        if !issorted(pages, lt=lt)
            sort!(pages, lt=lt)
            midPage = pages[ceil(Int, length(pages)/2)]
            # @printf "Fixed page: %s\n" pages
            # @printf "count: %d + %d = %d\n" count midPage count+midPage
            count += midPage
        end
    end
    return count
end
            
rules, updates = parseRules(lines)
@time printstyled("P1: Mid page count = $(p1(rules, updates))\n")
@time printstyled("P2: Mid page count = $(p2(rules, updates))\n")
