using Printf
using DataStructures
test = read("day09/test.txt", String)
input = read("day09/input.txt", String)

struct MemBlock
    addr
    len
    id
end

struct EmptyBlock
    addr
    len
end
Base.isless(a::EmptyBlock, b::EmptyBlock) = a.addr < b.addr
Base.isless(a::MemBlock, b::MemBlock) = a.addr < b.addr


function buildMemMap(data)
    files = Vector{MemBlock}()
    spaces = [BinaryMinHeap{EmptyBlock}() for _ = 1:9]

    id = 0
    addr = 0
    data = parse.(Int, (c for c in data))
    for (i, n) ∈ enumerate(data)
        if i % 2 == 1
            # for j = 0:n-1
                push!(files, MemBlock(addr, n, id))
            # end
            id += 1
        else
            if n > 0
                push!(spaces[n], EmptyBlock(addr, n))
            end
        end
        addr += n
    end
    return files, spaces, addr
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

# Heap based approach based on reading other solutions. Takes about 3ms on my
# machine, was actually slower to remove all elements when computing the
# checksum lmao
function solveP2Heap(files, spaces)
    f2 = Vector{MemBlock}()

    for file ∈ reverse(files)
        found = false
        for n = file.len:9
            if !isempty(spaces[n])
                s = pop!(spaces[n])
                n2 = s.len - file.len
                if n2 > 0 # Re-allocate new empty space
                    push!(spaces[n2], EmptyBlock(s.addr + file.len, n2))
                end
                push!(f2, MemBlock(s.addr, file.len, file.id))
                found = true
                break
            end
        end
        if !found
            push!(f2, file)
        end
    end
    return f2, spaces
end

computeChecksum(mem) = sum(((i-1)*mem[i] for i ∈ eachindex(mem) if mem[i] >= 0))

function computeChecksumHeap(files)
    c = 0
    sort!(files)
    for f in files
        for i = 0:f.len-1
            c += f.id * (f.addr+i)
        end
    end
    return c
end

@time begin # P1
data = input;
mem = buildMemMap(data)
solveP1!(mem)
@printf "P1: checksum = %d\n" computeChecksum(mem)
end

# @time begin # P2
data = input;
@time files, spaces, len = buildMemMap(data);
# printMemMap(mem)
@time defraggedFiles, spaces = solveP2Heap(files, spaces);
# printMemMap(mem)
@time @printf "P2: checksum = %d\n" computeChecksumHeap(defraggedFiles)
# end

