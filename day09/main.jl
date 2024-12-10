using Printf
test = read("day09/test.txt", String)
input = read("day09/input.txt", String)


function buildMemMap(data)
    memory = Vector{Int}()
    id = 0
    data = parse.(Int, (c for c in data))
    for (i, n) ∈ enumerate(data)
        val = i % 2 == 1 ? id : -1
        for j = 1:n
            push!(memory, val)
        end
        id += i % 2 == 1 ? 1 : 0
    end
    return memory
end

function printMemMap(mem)
    getChar(c) = c >= 0 ? string(c) : "."
    println(join((getChar(c) for c ∈ mem)))
end

function solveP1!(mem)
    a = 1; b = length(mem)
    while a < b
        if mem[a] >= 0
            a += 1
        elseif mem[b] < 0
            b -= 1
        else # Have a free block at a and full one at b. Swap!
            mem[a] = mem[b]
            mem[b] = -1
        end
    end
    return findlast(mem .>= 0)
end

# @views macro turns mem[...] slices into views (no allocation)
@views function solveP2!(mem)
    b = length(mem)
    astart = 1 # Used to not re-examine full blocks (again saved like 40% runtime)
    while b > 0
        if mem[b] == -1
            b -= 1
        else
            # Compute contiguous block size
            b2 = b
            while b2 - 1 > 0 && mem[b2-1] == mem[b]
                b2 -= 1
            end
            n = b - b2 + 1

            # Search for block to fill
            a = astart
            first = true
            while a <= b - n
                if mem[a] >= 0
                    a += 1
                    astart = first ? a : astart
                    continue
                end
                first = false

                # Nasty unrolled loop instead of all(mem[...]) to get rid of # allocations, saved ~40% runtime
                contiguous = true
                for a2 = a+1:a+n-1
                    if mem[a2] != -1
                        contiguous = false
                        break
                    end
                end
                if contiguous
                    mem[a:a+n-1] .= mem[b2:b]
                    mem[b2:b] .= -1
                    break
                end
                a += n
            end

            b -= n # advance to next block
        end
    end
end

computeChecksum(mem) = sum(((i-1)*mem[i] for i ∈ eachindex(mem) if mem[i] >= 0))

@time begin # P1
data = input;
mem = buildMemMap(data)
solveP1!(mem)
@printf "P1: checksum = %d\n" computeChecksum(mem)
end

@time begin # P2
data = input;
mem = buildMemMap(data)
# printMemMap(mem)
solveP2!(mem)
# printMemMap(mem)
@printf "P2: checksum = %d\n" computeChecksum(mem)
end

