using Printf
# Tried using StaticArrays.jl to see if that would help with performance,
# instead it caused mysterious giga allocations and tons of extra GC...
# literally was allocating 180 MiB for P1 with ans::SVector{Int} and
# numbers::SVector{SVector{Int}}. Now allocating 25 KiB. I don't get it man...

test = readlines("day07/test.txt")
input = readlines("day07/input.txt")


function parseInput(line)
    tok = split(line)
    ans = parse(Int, tok[1][1:end-1])
    nums = parse.(Int, tok[2:end])
    return ans, nums
end

function permToStr(perm, base, len)
    ans = ""
    for i = 1:len
        if perm % base == 0
            ans = "+" * ans
        elseif perm % base == 1
            ans = "*" * ans
        else
            ans = "||" * ans
        end
        perm /= base
    end
    return ans
end

function operate(perm, base, acc, num)
    if perm % base == 0
        acc += num
    elseif perm % base == 1
        acc *= num
    elseif perm % base == 2 # Concatenate numbers
        acc = acc * 10^(ceil(Int, log10(num+1))) + num
    else
        error("uh oh!")
    end
end

function findTrueConstraints(answers, numbers; base=2)
    solvable = Vector{Bool}()
    solutions = Vector{Int}()
    for idx ∈ eachindex(answers)
        nums = numbers[idx]
        nOp = length(nums) - 1
        nPerms = base ^ nOp
        # Encode operators as 0 => +, 1 => * so we can just count an integer
        acc = nums[1]
        for perm = 0:nPerms-1
            p2 = perm
            acc = nums[1]
            i = 2
            for _ = 1:nOp
                acc = operate(p2, base, acc, nums[i])
                if acc > answers[idx]
                    break
                end
                p2 ÷= base
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


data = parseInput.(input)
answers = [d[1] for d in data]
numbers = [d[2] for d in data]

@time solvable, solns = findTrueConstraints(answers, numbers)
@printf "P1: Sum of true test values = %d\n" sum(answers[solvable])

# Only look at ones not already solvable
idx = findall(.!solvable)
@time fixable, fixSolns = findTrueConstraints(answers[idx], numbers[idx], base=3)
@printf "P2: Sum of true test values = %d\n" sum(answers[solvable]) + sum(answers[idx[fixable]])

