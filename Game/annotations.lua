---@meta

--- @alias COLORREF integer
--- @alias HWND userdata

---@class POINT
---@field x integer
---@field y integer

---@class RECT
---@field left integer
---@field top integer
---@field right integer
---@field bottom integer

--- @class RGB
--- @field r integer
--- @field g integer
--- @field b integer

---@class Bitmap
local Bitmap = {}

---@class Font
local Font = {}


--- GameEngine class
--- @class GameEngine
--- @field drawColor COLORREF
--- @field window HWND
GameEngine = {}


-- State ---------------------------------------------------------

---Set the current draw color.
---@param color RGB
function GameEngine:SetColor(color) end

---Set the current font for text drawing.
---@param font Font
function GameEngine:SetFont(font) end

---Fill the entire window with a color.
---@param color RGB
---@return boolean success
function GameEngine:FillWindowRect(color) end

---Get the current draw color.
---@return COLORREF
function GameEngine:GetDrawColor() end

---Request a repaint of the window.
---@return boolean success
function GameEngine:Repaint() end

-- Lines & rectangles --------------------------------------------

---Draw a line from (x1,y1) to (x2,y2).
---@param x1 integer
---@param y1 integer
---@param x2 integer
---@param y2 integer
---@return boolean success
function GameEngine:DrawLine(x1, y1, x2, y2) end

---Draw a rectangle outline.
---@param left integer
---@param top integer
---@param right integer
---@param bottom integer
---@return boolean success
function GameEngine:DrawRect(left, top, right, bottom) end

---Fill a rectangle.
---@param left integer
---@param top integer
---@param right integer
---@param bottom integer
---@return boolean success
function GameEngine:FillRect(left, top, right, bottom) end

---Fill a rectangle with opacity (0–255).
---@param left integer
---@param top integer
---@param right integer
---@param bottom integer
---@param opacity integer
---@return boolean success
function GameEngine:FillRectAlpha(left, top, right, bottom, opacity) end

---Draw a rounded rectangle outline.
---@param left integer
---@param top integer
---@param right integer
---@param bottom integer
---@param radius integer
---@return boolean success
function GameEngine:DrawRoundRect(left, top, right, bottom, radius) end

---Fill a rounded rectangle.
---@param left integer
---@param top integer
---@param right integer
---@param bottom integer
---@param radius integer
---@return boolean success
function GameEngine:FillRoundRect(left, top, right, bottom, radius) end

-- Ovals & arcs --------------------------------------------------

---Draw an oval outline inside the rectangle.
---@param left integer
---@param top integer
---@param right integer
---@param bottom integer
---@return boolean success
function GameEngine:DrawOval(left, top, right, bottom) end

---Fill an oval.
---@param left integer
---@param top integer
---@param right integer
---@param bottom integer
---@return boolean success
function GameEngine:FillOval(left, top, right, bottom) end

---Fill an oval with opacity (0–255).
---@param left integer
---@param top integer
---@param right integer
---@param bottom integer
---@param opacity integer
---@return boolean success
function GameEngine:FillOvalAlpha(left, top, right, bottom, opacity) end

---Draw an arc.
---@param left integer
---@param top integer
---@param right integer
---@param bottom integer
---@param startDegree integer
---@param angle integer
---@return boolean success
function GameEngine:DrawArc(left, top, right, bottom, startDegree, angle) end

---Fill a pie‑slice arc.
---@param left integer
---@param top integer
---@param right integer
---@param bottom integer
---@param startDegree integer
---@param angle integer
---@return boolean success
function GameEngine:FillArc(left, top, right, bottom, startDegree, angle) end

-- Text ----------------------------------------------------------

---Draw text at a position.
---@param text string
---@param left integer
---@param top integer
---@return integer result
function GameEngine:DrawString(text, left, top) end

---Draw wrapped text inside a rectangle.
---@param text string
---@param left integer
---@param top integer
---@param right integer
---@param bottom integer
---@return integer result
function GameEngine:DrawStringRect(text, left, top, right, bottom) end

-- Bitmaps -------------------------------------------------------

---Draw a full bitmap at a position.
---@param bmp Bitmap
---@param left integer
---@param top integer
---@return boolean success
function GameEngine:DrawBitmap(bmp, left, top) end

---Draw a bitmap region at a position.
---@param bmp Bitmap
---@param left integer
---@param top integer
---@param source RECT
---@return boolean success
function GameEngine:DrawBitmapRegion(bmp, left, top, source) end

-- Polygons ------------------------------------------------------

---Draw a polygon.
---@param pts POINT[]
---@param count integer
---@return boolean success
function GameEngine:DrawPolygon(pts, count) end

---Draw a polygon, optionally closing it.
---@param pts POINT[]
---@param count integer
---@param close boolean
---@return boolean success
function GameEngine:DrawPolygonEx(pts, count, close) end

---Fill a polygon.
---@param pts POINT[]
---@param count integer
---@return boolean success
function GameEngine:FillPolygon(pts, count) end

---Fill a polygon, optionally closing it.
---@param pts POINT[]
---@param count integer
---@param close boolean
---@return boolean success
function GameEngine:FillPolygonEx(pts, count, close) end

--- GameEngine c++ variable exposed to lua
--- @type GameEngine
cpp_gameEngine = nil

--- @type boolean
keyLeft = nil
--- @type boolean
keyRight = nil
--- @type boolean
keyUp = nil
--- @type boolean
keyDown = nil
--- @type boolean
keyRestart = nil
--- @type boolean
startKey = nil

--- tile font
--- @type Font
tileFont = nil
--- announcement font
--- @type Font
announcementFont = nil
--- title font
--- @type Font
titleFont = nil

--- width of the full application window
--- @type integer
windowWidth = nil
--- height of the full application window
--- @type integer
windowHeight = nil