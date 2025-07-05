# Day 17: Chronospacial Computer
# We're back in computer architecture 101!

mutable struct Reg # The computer's registers
    A::Int 
    B::Int 
    C::Int 
end

function readProgram(fn)
    lines = readlines("day17/$(fn).txt")
    reg = Reg(0,0,0)
    reg.A = parse(Int, last(split(lines[1])))
    reg.B = parse(Int, last(split(lines[2])))
    reg.C = parse(Int, last(split(lines[3])))

    instructions = parse.(Int, split(last(split(lines[5])), ","))

    return reg, instructions
end

function getValue(reg, op, combo)
    if combo && op > 3
        if op == 4
            return reg.A 
        elseif op == 5
            return reg.B 
        elseif op == 6 
            return reg.C 
        else
            error("Invalid command!")
        end
    else # literal value
        return op 
    end
end

function execute(reg, instructions, p2)
    ip = 0 # instruction pointer
    output = Vector{Int}()

    while ip < length(instructions)
        opcode, val = instructions[ip+1], instructions[ip+2]
        if opcode == 0 # adv
            v = getValue(reg, val, true)
            reg.A ÷= 2^v
            ip += 2
        elseif opcode == 1 # bxl
            v = getValue(reg, val, false)
            reg.B ⊻= v
            ip += 2
        elseif opcode == 2 # bst
            v = getValue(reg, val, true)
            reg.B = v & 0x7
            ip += 2
        elseif opcode == 3 # jnz
            if reg.A != 0
                v = getValue(reg, val, false)
                ip = v
            else
                ip += 2
            end
        elseif opcode == 4 # bxc 
            reg.B = reg.B ⊻ reg.C
            ip += 2
        elseif opcode == 5 # out 
            v = getValue(reg, val, true)
            res = v & 0x7
            # Return early for bad result
            if p2 && res != instructions[length(output)+1]
                return reg, output
            end
            push!(output, res)
            ip += 2
        elseif opcode == 6 # bdv 
            v = getValue(reg, val, true)
            reg.B = reg.A ÷ 2^v
            ip += 2
        elseif opcode == 7 # cdv 
            v = getValue(reg, val, true)
            reg.C = reg.A ÷ 2^v
            ip += 2
        end

    end

    return reg, output
end

function p1()
    fn = "input"
    reg, instructions = readProgram(fn)
    @time reg, output = execute(reg, instructions, false)
    println(reg)
    println(output)
    ans = join(string.(output), ",")
    println("test")
    ans == read("day17/p1_ans.txt", String)
    println(ans)
end
p1()

#P2 
# @time begin
function p2()
    a2 = 0
    fn = "input"
    reg, instructions = readProgram(fn)
    reg.A = a2
    println("aaa")
    while true 
        _, output = execute(reg, instructions, true)
        
        if output == instructions
            break
        end
        a2 += 1
        # Reset registers for next try
        reg.A = a2
        reg.B = 0
        reg.C = 0

        if a2 % 1e5 == 0
            println(a2)
        end

        # if a2 == 10e6 
        #     break
        # end
    end
    println(a2)
end

# Simplify logic:
##################################
# 1)
# B = A & 0x7
# B = B ⊻ 0x3
# C = A ÷ 2^B 
# A = A ÷ 8
# B = B ⊻ 0x5
# B = B ⊻ C
# o = B & 0x7 # Output value
##################################
# 2)
# B = (A & 0b111) ⊻ 0b011
# C = A ÷ ((A & 0b111) ⊻ 0b011)
# A = A >> 3
# B = ((A & 0b111) ⊻ 0b011) ⊻ 0b101

# Hardcode the input logic
function p2hc()
    a2 = 0
    fn = "input"
    reg, instructions = readProgram(fn)
    reg.A = a2

    a_input = 0
    while true 
        A = a_input
        B = 0
        C = 0

        # Execute program
        it = 1
        while true 
            B = A & 0x7
            B = B ⊻ 0x3
            C = A ÷ 2^B 
            A = A ÷ 8
            B = B ⊻ 0x5
            B = B ⊻ C
            o = B & 0x7 # Output value
            if o != instructions[it] # Failed to print
                break
            elseif A == 0 # Reached end 
                break
            end
            it += 1
        end
        if a_input % 10_000_000 == 0
            println(a_input)
        end
        if it == length(instructions) # Printed whole program
            break
        end
        a_input += 1
    end
    println(a_input)
end

p2hc()
