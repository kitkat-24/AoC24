# Read in data
left = Vector{Int32}();
right = Vector{Int32}();
for line in eachline("input.txt")
    nums = split(line)
    append!(left, parse(Int32, nums[1]))
    append!(right, parse(Int32, nums[2]))
end

# Sort them to do comparisons of smallest-to-smallest, etc.
sort!(left)
sort!(right)

distances = Vector{Int32}()
for (v1, v2) in zip(left,right)
    append!(distances, abs(v2 - v1))
end
dist = sum(distances)

# Part two
appearances = Dict{Int32, Int32}()
for num in left
    if !haskey(appearances, num)
        appearances[num] = sum(num .== right)
    end
end
similarity = sum(map(v -> v * appearances[v], left))