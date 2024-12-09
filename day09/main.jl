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

function solve!(mem)
    a = 1; b = length(mem)
    # printMemMap(mem)
    while a < b
        if mem[a] >= 0
            a += 1
        elseif mem[b] < 0
            b -= 1
        else # Have a free block at a and full one at b. Swap!
            mem[a] = mem[b]
            mem[b] = -1
            # printMemMap(mem)
        end
    end
    return findlast(mem .>= 0)
end

computeP1(mem, endex) = sum(((i-1)*mem[i] for i ∈ 1:endex))

@time begin
data = input;
mem = buildMemMap(data)
endex = solve!(mem)
@printf "P1: checksum = %d\n" computeP1(mem, endex)
end