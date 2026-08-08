-- MEMORY --
local MEMORY_SIZE = 0x1000 -- 4096 bits
local PROGRAM_START = 0x200 -- first 512 bits are reserved for the interpreter
local MEMORY = {}

for i = 0, 0xFFF do
    MEMORY[i] = 0
end

for i = 1, #data do
    MEMORY[0x200 + i - 1] = data:byte(i) -- again, first 512 bytes are reserved for the interpreter
end

local pc = PROGRAM_START -- pc stamds for "Program Counter" and it stores the address of where
local I = 0 -- index register
local V = {} -- V0..VF

local function reset()
    for i = 1, MEMORY_SIZE - 1 do
        MEMORY[i] = 0
    end
    for i = 0, 0xF do
        V[i] = 0
    end

-- DISPLAY --
local DISPLAY_WIDTH = 64
local DISPLAY_HEIGHT = 32
local DISPLAY = {}

for y = 1, DISPLAY_HEIGHT do -- number of rows, height
    DISPLAY[y] = {}
    for x = 1, DISPLAY_WIDTH do -- number of cols, width
        DISPLAY[y][x]=false
    end

        -- TODO: clear stack
    
    for y = 1, DISPLAY_HEIGHT do -- rows
        display[y] = {}

        for x = 1, DISPLAY_WIDTH do -- cols
            display[y][x] = false
        end
    end

    -- TODO: clear keypad
    
    I = 0
    pc = PROGRAM_START

    -- TODO: deal with timers and sp
end

local function load_rom(filename) do
    local file = assert(io.open(filename, rb))
    local data = file:read("*all")
    assert(file:close())

    assert(#data <= MEMORY_SIZE - PROGRAM_START, "ROM is too large")
    for i = 1, #data do
        memory[PROGRAM_START + i - 1] = data:byte(i)
    end
end

local function fetch()
    -- to fail in case maybe you fuck up something about pc and go out of bounds
    assert(
        pc >= 0 and pc + 1 < MEMORY_SIZE,
        string.format("PC out of bounds: %04X", pc)
    )

    local hi = memory[pc]
    local lo = memory[pc + 1]
    return (hi << 8) | lo
end

function love.load(arg)
    
    --[[
    local inp = assert(io.open(arg[1], "rb"))
    local data = inp:read("*all")
    assert(inp:close())
 
     -- SNIPPET THAT CHECKS INPUT
    for i = 1, #data, 16 do
        io.write(string.format("%08x: ", i - 1))
        for j = 0, 14, 2 do
            if i + j + 1 <= #data then
                local high = data:byte(i + j)
                local low = data:byte(i + j + 1)
                io.write(string.format("%02x%02x ", high, low))
            elseif i + j <= #data then
                io.write(string.format("%02x   ", data:byte(i + j)))
            end
        end
        io.write("\n")
    end
    ]]--

    local function execute(opcode)
        local op = (opcode >> 12) & 0xF
        local x = (opcode >> 4) & 0xF
        local y = (opcode >> 8) & 0xF
        local N = opcode & 0xF
        local NN = opcode & 0xFF
        local NNN = opcode & 0xFFF

        if op == 0x0 then
        elseif op == 0x1 then
            pc = NNN
        elseif op == 0x2 then
        elseif op == 0x3 then
        elseif op == 0x4 then
        elseif op == 0x5 then
        elseif op == 0x6 then
        elseif op == 0x7 then
        elseif op == 0x8 then
        elseif op == 0x9 then
        elseif op == 0xA then
        elseif op == 0xB then
        elseif op == 0xC then
        elseif op == 0xD then
        elseif op == 0xE then
        elseif op == 0xF then
        else 
            error(string.format("Unknown opcode: %04X", opcode))
        end

    --[[
    refer to https://en.wikipedia.org/wiki/Endianness#/media/File:32bit-Endianess.svg
    to understand the high-low naming
    ]]--
    for i = 1, #data, 2 do -- every instruction is 2 byte long
        local high = data:byte(i)
        local low = data:byte(i+1)
        local opcode = (high << 8) | low -- equivalent of opcode = high*0x100 + low
    end

    local function cycle()
        local opcode = fetch()

        pc = pc + 2
    end
end

function love.update(dt)
end

function love.draw()
end
