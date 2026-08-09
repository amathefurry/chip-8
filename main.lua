-- MEMORY --
local MEMORY_SIZE = 0x1000 -- 4096 bits
local PROGRAM_START = 0x200 -- first 512 bits are reserved for the interpreter
local MEMORY = {}

function meminit()
    for i = 0, 0xFFF do
        MEMORY[i] = 0
    end

    for i = 1, #data do
        MEMORY[0x200 + i - 1] = data:byte(i) -- again, first 512 bytes are reserved for the interpreter
    end
end

local pc = PROGRAM_START -- pc stamds for "Program Counter" and it stores the address of where
local I = 0 -- index register
local V = {} -- V0..VF

local stack = {} -- LIFO
local stack_pointer = 1 -- points to the last element in the stack

local delay_timer = 0 -- if not 0 then decreases
local sound_timer = 0 -- if not 0 then it makes a sound and decreases

function tick_timers()
    if delay_timer > 0 then
        delay_timer = delay_timer - 1
    end
    if sound_timer > 0 then
        sound_timer = sound_timer - 1
    end
end

local sampleRate = 44100
local soundFrequency = 440

local soundData = love.sound.newSoundData(
    sampleRate,
    sampleRate,
    16,
    1
)

for i = 0, sampleRate - 1 do
    local t = i / sampleRate
    local sample = math.sin(2 * math.pi * soundFrequency * t)
    soundData:setSample(i, sample)
end

local beep = love.audio.newSource(soundData, "static")
beep:setLooping(true)

-- DISPLAY --
local DISPLAY_WIDTH = 64
local DISPLAY_HEIGHT = 32
local DISPLAY = {}

local function reset() -- resets everything
    for i = 1, MEMORY_SIZE - 1 do
        MEMORY[i] = 0
    end
    for i = 0, 0xF do
        V[i] = 0
    end

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

local function clear_screen() -- resets screen (literally copied some of the earlierr reset() function)
     for y = 1, DISPLAY_HEIGHT do -- number of rows, height (yes, these comments were copied too)
            DISPLAY[y] = {}
        for x = 1, DISPLAY_WIDTH do -- number of cols, width
            DISPLAY[y][x]=false
        end
    end
end

local function draw(y, x, n)
    V[0xF] = 0
    for i = 1, n do
        local byte = MEMORY[I + i]
        for j = 1, 8 do
            DISPLAY[y % 32][x % 64 + j - 1] = DISPLAY[y % 32][x % 64 + j - 1] ^ MEMORY[I + i + 8 - j]
            V[0xF] = DISPLAY[y % 32][x % 64 + j - 1] & MEMORY[I + i + 8 - j]
        end
end

local function load_rom(filename)
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
    ]] --

    local function execute(opcode)
        local op = (opcode >> 12) & 0xF
        local x = (opcode >> 4) & 0xF
        local y = (opcode >> 8) & 0xF
        local N = opcode & 0xF
        local NN = opcode & 0xFF
        local NNN = opcode & 0xFFF

        if op == 0x0 then
            if x == 0x0 then -- note to self consider NNN == 0x0E0
                if NN == 0xE0 then
                    clear_screen();
                end
            end
        
        elseif op == 0x1 then
            pc = NNN
        
        elseif op == 0x2 then
        
        elseif op == 0x3 then
        
        elseif op == 0x4 then
        
        elseif op == 0x5 then
        
        elseif op == 0x6 then
            v[x] = NN
        
        elseif op == 0x7 then
            v[x] = v[x] + NN;
        
        elseif op == 0x8 then
        
        elseif op == 0x9 then
        
        elseif op == 0xA then
        
            I = NNN
        
        elseif op == 0xB then
        
        elseif op == 0xC then
        
        elseif op == 0xD then
            draw(v[x] & 63,v[y] & 31,n)
        
        elseif op == 0xE then
        
        elseif op == 0xF then
        
        else 
            error(string.format("Unknown opcode: %04X", opcode))
        end
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

local timer_accumulator = 0

function love.update(dt)
    timer_accumulator = timer_accumulator + dt
    
    while timer_accumulator >= 1 / 60 do
        timer_accumulator = timer_accumulator - 1 / 60
        tick_timers()
    end

    if sound_timer > 0 then
        if not beep:isPlaying() then
            beep:play()
        end
    else if beep:isPlaying() then
        beep:stop()
    end
end

function love.draw()
    for y = 1, 32 do
        for x = 1, 64 do
            local px = DISPLAY[y][x]
            if px == 1 then
                love.graphics.setColor(1, 1, 1)
            else
                love.graphics.setColor(0, 0, 0)
            end
            love.graphics.rectangle("fill", x * 12, y * 12, 12, 12)
        end
    end
end
end
end
end