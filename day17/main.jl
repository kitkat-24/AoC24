# Day 17: Chronospacial Computer
# We're back in computer architecture 101!

fn = "test1"
instructions = 

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

function execute(fn)
    reg, instructions = readProgram(fn)
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
            push!(output, v & 0x7)
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

fn = "input"
reg, output = execute(fn)
print(join(string.(output), ","))