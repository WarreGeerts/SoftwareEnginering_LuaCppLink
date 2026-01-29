local GRID_SIZE = 4
local TILE_SIZE = 80
local PADDING   = 10
local BOARD_X   = 50
local BOARD_Y   = 50

local board = {}
local score = 0
local gameOver = false
local gameWon  = false

local STATE_MENU = "menu"
local STATE_GAME = "game"

local state = STATE_MENU

local prevLeft, prevRight, prevUp, prevDown = false, false, false, false

---@type boolean
keyLeft = false
---@type boolean
keyRight = false
---@type boolean
keyUp = false
---@type boolean
keyDown = false
---@type boolean
keyRestart = false
---@type boolean
startKey = false


pendingMove = nil 

local tileColors = {
    [0]    = { r = 205, g = 193, b = 180 },
    [2]    = { r = 238, g = 228, b = 218 },
    [4]    = { r = 237, g = 224, b = 200 },
    [8]    = { r = 242, g = 177, b = 121 },
    [16]   = { r = 245, g = 149, b = 99 },
    [32]   = { r = 246, g = 124, b = 95 },
    [64]   = { r = 246, g = 94,  b = 59 },
    [128]  = { r = 237, g = 207, b = 114 },
    [256]  = { r = 237, g = 204, b = 97 },
    [512]  = { r = 237, g = 200, b = 80 },
    [1024] = { r = 237, g = 197, b = 63 },
    [2048] = { r = 237, g = 194, b = 46 },
}

local function randTileValue()
    -- about 90% 2, 10% 4
    if math.random() < 0.9 then return 2 else return 4 end
end

local function resetBoard()
    board = {}
    for r = 1, GRID_SIZE do
        board[r] = {}
        for c = 1, GRID_SIZE do
            board[r][c] = 0
        end
    end
    score = 0
    gameOver = false
    gameWon  = false
end

local function emptyCells()
    local cells = {}
    for r = 1, GRID_SIZE do
        for c = 1, GRID_SIZE do
            if board[r][c] == 0 then
                cells[#cells+1] = { r = r, c = c }
            end
        end
    end
    return cells
end

local function spawnRandomTile()
    local cells = emptyCells()
    if #cells == 0 then return end
    local idx = math.random(1, #cells)
    local cell = cells[idx]
    if not cell then return end       
    board[cell.r][cell.c] = randTileValue()
end

local function canMergeOrMove()
    if #emptyCells() > 0 then return true end
    for r = 1, GRID_SIZE do
        for c = 1, GRID_SIZE do
            local v = board[r][c]
            if r < GRID_SIZE and board[r+1][c] == v then return true end
            if c < GRID_SIZE and board[r][c+1] == v then return true end
        end
    end
    return false
end

local function compressAndMerge(line)
    local result = {}
    local gained = 0

    for i = 1, #line do
        if line[i] ~= 0 then
            result[#result+1] = line[i]
        end
    end

    local i = 1
    while i <= #result - 1 do
        if result[i] ~= 0 and result[i] == result[i+1] then
            local newVal = result[i] * 2
            result[i] = newVal
            result[i+1] = 0
            gained = math.floor(gained + newVal)       -- score increases by merged tile value
            if newVal == 2048 then
                gameWon = true
            end
            i = i + 2
        else
            i = i + 1
        end
    end

    local final = {}
    for j = 1, #result do
        if result[j] ~= 0 then
            final[#final+1] = result[j]
        end
    end
    while #final < GRID_SIZE do
        final[#final+1] = 0
    end

    return final, gained
end

local function moveLeft()
    local moved = false
    local gainedTotal = 0
    for r = 1, GRID_SIZE do
        local row = {}
        for c = 1, GRID_SIZE do
            row[c] = board[r][c]
        end
        local newRow, gained = compressAndMerge(row)
        gainedTotal = gainedTotal + gained
        for c = 1, GRID_SIZE do
            if newRow[c] ~= board[r][c] then
                moved = true
            end
            board[r][c] = newRow[c]
        end
    end
    score = score + gainedTotal
    return moved
end

local function moveRight()
    local moved = false
    local gainedTotal = 0
    for r = 1, GRID_SIZE do
        local row = {}
        for c = 1, GRID_SIZE do
            row[c] = board[r][GRID_SIZE - c + 1]
        end
        local newRow, gained = compressAndMerge(row)
        gainedTotal = gainedTotal + gained
        for c = 1, GRID_SIZE do
            local v = newRow[c]
            if v ~= board[r][GRID_SIZE - c + 1] then
                moved = true
            end
            board[r][GRID_SIZE - c + 1] = v
        end
    end
    score = score + gainedTotal
    return moved
end

local function moveUp()
    local moved = false
    local gainedTotal = 0
    for c = 1, GRID_SIZE do
        local col = {}
        for r = 1, GRID_SIZE do
            col[r] = board[r][c]
        end
        local newCol, gained = compressAndMerge(col)
        gainedTotal = gainedTotal + gained
        for r = 1, GRID_SIZE do
            if newCol[r] ~= board[r][c] then
                moved = true
            end
            board[r][c] = newCol[r]
        end
    end
    score = score + gainedTotal
    return moved
end

local function moveDown()
    local moved = false
    local gainedTotal = 0
    for c = 1, GRID_SIZE do
        local col = {}
        for r = 1, GRID_SIZE do
            col[r] = board[GRID_SIZE - r + 1][c]
        end
        local newCol, gained = compressAndMerge(col)
        gainedTotal = gainedTotal + gained
        for r = 1, GRID_SIZE do
            local v = newCol[r]
            if v ~= board[GRID_SIZE - r + 1][c] then
                moved = true
            end
            board[GRID_SIZE - r + 1][c] = v
        end
    end
    score = score + gainedTotal
    return moved
end

local function consumeInput()
    local dir = nil

    if keyLeft and not prevLeft then
        dir = "left"
    elseif keyRight and not prevRight then
        dir = "right"
    elseif keyUp and not prevUp then
        dir = "up"
    elseif keyDown and not prevDown then
        dir = "down"
    end

    prevLeft, prevRight, prevUp, prevDown =
        keyLeft, keyRight, keyUp, keyDown

    return dir
end

local function drawBackground()
    cpp_gameEngine:FillWindowRect({ r = 250, g = 248, b = 239 })
    cpp_gameEngine:SetColor({ r = 187, g = 173, b = 160 })
    cpp_gameEngine:FillRoundRect(
        BOARD_X,
        BOARD_Y,
        BOARD_X + GRID_SIZE * (TILE_SIZE + PADDING) + PADDING,
        BOARD_Y + GRID_SIZE * (TILE_SIZE + PADDING) + PADDING,
        10
    )
end

local function getTileColor(value)
    return tileColors[value] or { r = 60, g = 58, b = 50 }
end

local function drawTile(r, c, value)
    local x = math.floor(BOARD_X + PADDING + (c - 1) * (TILE_SIZE + PADDING))
    local y = math.floor(BOARD_Y + PADDING + (r - 1) * (TILE_SIZE + PADDING))

    local color = getTileColor(value)
    cpp_gameEngine:SetColor(color)
    cpp_gameEngine:FillRoundRect(x, y, x + TILE_SIZE, y + TILE_SIZE, 5)

    if value ~= 0 then
        cpp_gameEngine:SetFont(tileFont)
        cpp_gameEngine:SetColor({ r = 119, g = 110, b = 101 })

        local text = tostring(value)
        local len  = #text

        -- base center
        local centerX = x + TILE_SIZE / 2
        local centerY = y + TILE_SIZE / 2

        -- offsets for each digit to be placed in the middle of the square
        local offsetX = 0
        if len == 1 then
            offsetX = -9
        elseif len == 2 then
            offsetX = -18
        elseif len == 3 then
            offsetX = -26
        else 
            offsetX = -34
        end

        local offsetY = -20    
        local textX = math.floor(centerX + offsetX)
        local textY = math.floor(centerY + offsetY)

        cpp_gameEngine:DrawString(text, textX, textY)
    end
end


-- ======================================= PRIVATE FUNCTIONS FOR GAMEPLAY =======================================
local function InitGame()
    resetBoard()
    spawnRandomTile()
    spawnRandomTile()
end

local function UpdateGame()
    if gameOver and keyRestart or gameWon and keyRestart then
        Init()
        return
    end
    
    if not gameWon then
        local dir = consumeInput()
        if not dir then return end

        local moved = false
        if dir == "left" then
         moved = moveLeft()
         elseif dir == "right" then
            moved = moveRight()
         elseif dir == "up" then
           moved = moveUp()
         elseif dir == "down" then
             moved = moveDown()
         end

      if moved then
            spawnRandomTile()
            if not canMergeOrMove() then
            gameOver = true
            end
        end
    end
end

local function DrawGame()
    drawBackground()

    for r = 1, GRID_SIZE do
        for c = 1, GRID_SIZE do
            drawTile(r, c, board[r][c])
        end
    end

    -- score display
    cpp_gameEngine:SetFont(tileFont)
    cpp_gameEngine:SetColor({ r = 119, g = 110, b = 101 })
    cpp_gameEngine:DrawString("Score: " .. tostring(score), BOARD_X, BOARD_Y - 40)

    if gameWon then 
        -- Announcement text
        cpp_gameEngine:SetFont(announcementFont)
        cpp_gameEngine:SetColor({ r = 119, g = 110, b = 101 })
        cpp_gameEngine:FillRoundRect(20,math.floor(windowHeight/3),math.floor(windowWidth - 20),70 + math.floor(windowHeight/3),7)
        cpp_gameEngine:SetColor({ r = 255, g = 255, b = 255 })
        cpp_gameEngine:DrawString("You made 2048!", 50, 0 + math.floor(windowHeight/3) )
        -- retry text
        cpp_gameEngine:SetFont(tileFont)
        cpp_gameEngine:SetColor({ r = 119, g = 110, b = 101 })
        cpp_gameEngine:FillRoundRect(70,math.floor(windowHeight/2),math.floor(windowWidth - 70),45 + math.floor(windowHeight/2),7)
        cpp_gameEngine:SetColor({ r = 255, g = 255, b = 255 })
        cpp_gameEngine:DrawString("Press 'r' to restart!", 110, 0 + math.floor(windowHeight/2) )

    elseif gameOver then
        -- announcement text
        cpp_gameEngine:SetFont(announcementFont)
        cpp_gameEngine:SetColor({ r = 119, g = 110, b = 101 })
        cpp_gameEngine:FillRoundRect(20,0 + math.floor(windowHeight/3),math.floor(windowWidth - 20),70 + math.floor(windowHeight/3),7)
        cpp_gameEngine:SetColor({ r = 255, g = 255, b = 255 })
        cpp_gameEngine:DrawString("Game Over!",110, 0 + math.floor(windowHeight/3))
        -- retry text
        cpp_gameEngine:SetFont(tileFont)
        cpp_gameEngine:SetColor({ r = 119, g = 110, b = 101 })
        cpp_gameEngine:FillRoundRect(70,math.floor(windowHeight/2),math.floor(windowWidth - 70),45 + math.floor(windowHeight/2),7)
        cpp_gameEngine:SetColor({ r = 255, g = 255, b = 255 })
        cpp_gameEngine:DrawString("Press 'r' to restart!", 110, 0 + math.floor(windowHeight/2) )
    end
end

local function DrawMenu()
    -- background
    drawBackground()
    for r = 1, GRID_SIZE do
        for c = 1, GRID_SIZE do
            drawTile(r, c, board[r][c])
        end
    end

    -- title
    cpp_gameEngine:SetFont(titleFont)
    cpp_gameEngine:SetColor({ r = 119, g = 110, b = 101 })
    cpp_gameEngine:DrawString("2048", 115, 60)

    -- button rectangle
    local btnLeft   = 95
    local btnTop    = 200
    local btnRight  = btnLeft + 280
    local btnBottom = btnTop + 75
    
    cpp_gameEngine:SetColor({ r = 143, g = 122, b = 102 })
    cpp_gameEngine:FillRoundRect(btnLeft, btnTop, btnRight, btnBottom, 10)
    
    -- button text
    cpp_gameEngine:SetFont(tileFont)
    cpp_gameEngine:SetColor({ r = 249, g = 246, b = 242 })
    cpp_gameEngine:DrawString("Press Enter / Space", btnLeft + 10, btnTop + 18)
end

-- ======================================= PUBLIC FUNCTIONS CALLED IN CPP =======================================

-- edge detection for startKey
local prevStartKey = false

local function checkStartPressedOnce()
    local pressed = startKey and not prevStartKey
    prevStartKey = startKey
    return pressed
end

function Init()
    resetBoard()

    state = STATE_MENU
    prevStartKey = false
end

function Update()
    if state == STATE_MENU then
        if checkStartPressedOnce() then -- Made so that game doesnt get initialised more than once when starting
            InitGame()
            state = STATE_GAME
        end
        return
    end

    if state == STATE_GAME then
        UpdateGame()
    end
end

function Draw()
    if state == STATE_MENU then
        DrawMenu()
    elseif state == STATE_GAME then
        DrawGame()
    end
end