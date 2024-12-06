using Printf 


# Read data and parse
test = readlines("day05/test.txt")
lines = readlines("day05/input.txt")

function p1(lines)
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

    count = 0
    for update in updates
        pages = parse.(Int, split(update, ","))
        prev = Set{Int}()
        valid = true
        for i = 1:length(pages)
            page = pages[length(pages) - i + 1]
            union!(prev, haskey(rules, page) ? rules[page] : Set{Int}())
            for j = 1:length(pages)-i
                if pages[j] ∈ prev
                    # @printf "Update: %s\nPage %d breaks rules of %s\n" update pages[j] pages[length(pages)-i+1:end]
                    valid = false
                    break
                end
            end
            if !valid 
                break
            end
        end
        
        if valid 
            midPage = pages[ceil(Int, length(pages)/2)]
            # @printf "Valid page: %s\n" update
            # @printf "count: %d + %d = %d\n" count midPage count+midPage
            count += midPage
        end
    end
    return count
end
            

@time printstyled("P1: Mid page count = $(p1(lines))\n")
    