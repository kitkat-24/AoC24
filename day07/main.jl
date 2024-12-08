using Printf
using Polyester
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
    solvable = falses(size(answers))
    solutions = -1 * ones(size(answers))
    @batch for i ∈ eachindex(answers)
        nums = numbers[i]
        nOp = length(nums) - 1
        nPerms = base ^ nOp
        # Encode operators as 0 => +, 1 => * so we can just count an integer
        acc = nums[1]
        for perm = 0:nPerms-1
            p2 = perm
            acc = nums[1]
            j = 2
            for _ = 1:nOp
                acc = operate(p2, base, acc, nums[j])
                if acc > answers[i]
                    break
                end
                p2 ÷= base
                j += 1
            end

            if acc == answers[i]
                solvable[i] = true
                solutions[i] = perm
                break
            end
        end
    end
    return solvable, solutions
end

# Second version based on other solutions I saw on reddit and discussions with
# ppl there
# Main point is recursive solution makes it easy to cut off sub-trees from
# permutation search when one operation makes all child solutions invalid.
# Further intuition: due to the left-to-right operands, we can instead pull the
# last numbers out and invert their operations to reduce the answer to 0 (for a
# valid equation) or < 0 and return
function solveTuah(ans, nums, c)
    if length(nums) == 1 # base case
        return ans == only(nums)
    end

    nums, v = nums[1:end-1], nums[end]
    l = nextpow(10, v+1)
    # Failing conditions: ans - v <= 0, ans v == 0, ans % l != v
    return ((ans > v && solveTuah(ans - v, nums, c))
        || (ans % v == 0 && solveTuah(ans ÷ v, nums, c))
        || (c && ans % l == v && solveTuah(ans ÷ l, nums, c)))
end


data = parseInput.(input)
answers = [d[1] for d in data]
numbers = [d[2] for d in data]

# @time solvable, solns = findTrueConstraints(answers, numbers)
@time solvable = solveTuah.(answers, numbers, false)
@printf "P1: Sum of true test values = %d\n" sum(answers[solvable])

# Only look at ones not already solvable
idx = findall(.!solvable)
# @time fixable, fixSolns = findTrueConstraints(answers[idx], numbers[idx], base=3)
# @printf "P2: Sum of true test values = %d\n" sum(answers[solvable]) + sum(answers[idx[fixable]])
# Much faster! I tried threading it, but that was actually slower. I guess it's
# not intensive enough to benefit from the thread overhead now? idk
@time fixable2 = solveTuah.(answers[idx], numbers[idx], true)
@printf "P2v2: Sum of true test values = %d\n" sum(answers[solvable]) + sum(answers[idx[fixable2]])


