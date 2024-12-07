using Printf
# Tried using StaticArrays.jl to see if that would help with performance,
# instead it caused mysterious giga allocations and tons of extra GC...
# literally was allocating 180 MiB for P1 with ans::SVector{Int} and
# numbers::SVector{SVector{Int}}. Now allocating 25 KiB. I don't get it man...

test = readlines("day07/test.txt")
# input = test;
input = readlines("day07/input.txt")


function parseInput(line)
    tok = split(line)
    ans = parse(Int, tok[1][1:end-1])
    nums = parse.(Int, tok[2:end])
    return ans, nums
end

data = parseInput.(input)
answers = [d[1] for d in data]
numbers = [d[2] for d in data]

function permToStr(perm, len)
    ans = ""
    for i = 1:len
        ans = (perm & 1 == 1 ? "*" : "+") * ans
        perm >>= 1
    end
    return ans
end

function findTrueConstraints(answers, numbers)
    solvable = Vector{Bool}()
    solutions = Vector{Int}()
    for idx ∈ eachindex(answers)
        nums = numbers[idx]
        nOp = length(nums) - 1
        nPerms = 2 ^ nOp
        # Encode operators as 0 => +, 1 => * so we can just count an integer
        acc = 0
        for perm = 0:nPerms-1
            mask = nPerms >> 1
            acc = nums[1]
            i = 2
            for _ = 1:nOp
                if perm & mask == 0
                    acc += nums[i]
                else
                    acc *= nums[i]
                end
                mask >>= 1
                i += 1
            end

            if acc == answers[idx]
                push!(solvable, true)
                push!(solutions, perm)
                break
            end
        end
        if acc != answers[idx]
            push!(solvable, false)
            push!(solutions, -1)
        end
    end
    return solvable, solutions
end

function sumP1(answers, solvable)
    sum(answers[solvable])
end


@time solvable, solns = findTrueConstraints(answers, numbers)
@printf "P1: Sum of true test values = %d" sumP1(answers, solvable)


