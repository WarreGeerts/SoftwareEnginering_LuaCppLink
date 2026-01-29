//-----------------------------------------------------------------
// Main Game File
// C++ Source - Game.cpp - version v8_01
//-----------------------------------------------------------------

//-----------------------------------------------------------------
// Include Files
//-----------------------------------------------------------------
#include "Game.h"
#include <iostream>

//-----------------------------------------------------------------
// Game Member Functions																				
//-----------------------------------------------------------------

Game::Game()
{
	m_pTileFont = new Font(_T("Segoe UI"), true, false, false, 40); 
	m_pAnnouncementFont = new Font(_T("Segoe UI"), true, false, false, 65); 
	m_pTitleFont = new Font(_T("Segoe UI"), true, false, true, 140); 
}

Game::~Game()
{
	delete m_pTileFont;
	delete m_pAnnouncementFont;
	delete m_pTitleFont;

	m_pTileFont = nullptr;
	m_pAnnouncementFont = nullptr;
	m_pTitleFont = nullptr;
}

void Game::Initialize()
{
	// Code that needs to execute (once) at the start of the game, before the game window is created

	AbstractGame::Initialize();
	GAME_ENGINE->SetTitle(_T("2048"));

	GAME_ENGINE->SetWidth(475);
	GAME_ENGINE->SetHeight(475);
	GAME_ENGINE->SetFrameRate(50);
}

void Game::Start()
{
	// Insert code that needs to execute (once) at the start of the game, after the game window is created

	// 1. Initialize Lua state once
	m_Lua.open_libraries(
		sol::lib::base,
		sol::lib::math,   
		sol::lib::table,
		sol::lib::string
	);

	Binding(m_Lua);

	auto res = m_Lua.safe_script_file("Game/game_2048.lua");
	if (!res.valid()) {
		sol::error err = res;
		OutputDebugStringA(err.what());
	}

	sol::protected_function init = m_Lua["Init"];
	auto r = init();
	if (!r.valid()) {
		sol::error err = r;
		OutputDebugStringA(err.what());
	}
}

void Game::End()
{
	// Insert code that needs to execute when the game ends
}

void Game::Paint(RECT rect) const
{
	// Insert paint code 

	sol::protected_function draw = m_Lua["Draw"];
	sol::protected_function_result r = draw();
	if (!r.valid()) {
		sol::error err = r;
		OutputDebugStringA(err.what());  // check VS Output window
	}

	//load lua script
}

void Game::Tick()
{
	sol::protected_function update = m_Lua["Update"];
	auto r = update();
	if (!r.valid()) {
		sol::error err = r;
		OutputDebugStringA(err.what());
	}

	// Insert non-paint code that needs to execute each tick 
}

void Game::MouseButtonAction(bool isLeft, bool isDown, int x, int y, WPARAM wParam)
{
	// Insert code for a mouse button action

	/* Example:
	if (isLeft == true && isDown == true) // is it a left mouse click?
	{
		if ( x > 261 && x < 261 + 117 ) // check if click lies within x coordinates of choice
		{
			if ( y > 182 && y < 182 + 33 ) // check if click also lies within y coordinates of choice
			{
				GAME_ENGINE->MessageBox(_T("Clicked."));
			}
		}
	}
	*/
}

void Game::MouseWheelAction(int x, int y, int distance, WPARAM wParam)
{
	// Insert code for a mouse wheel action
}

void Game::MouseMove(int x, int y, WPARAM wParam)
{
	// Insert code that needs to execute when the mouse pointer moves across the game window

	/* Example:
	if ( x > 261 && x < 261 + 117 ) // check if mouse position is within x coordinates of choice
	{
		if ( y > 182 && y < 182 + 33 ) // check if mouse position also is within y coordinates of choice
		{
			GAME_ENGINE->MessageBox("Mouse move.");
		}
	}
	*/
}

void Game::CheckKeyboard()
{
	// Here you can check if a key is pressed down
	// Is executed once per frame  

	if (GAME_ENGINE->IsKeyDown(VK_LEFT)) m_Lua["keyLeft"] = true; else m_Lua["keyLeft"] = false;
	if (GAME_ENGINE->IsKeyDown(VK_UP)) m_Lua["keyUp"] = true; else m_Lua["keyUp"] = false;
	if (GAME_ENGINE->IsKeyDown(VK_DOWN)) m_Lua["keyDown"] = true; else m_Lua["keyDown"] = false;
	if (GAME_ENGINE->IsKeyDown(VK_RIGHT)) m_Lua["keyRight"] = true; else m_Lua["keyRight"] = false;
	if (GAME_ENGINE->IsKeyDown('R')) m_Lua["keyRestart"] = true; else m_Lua["keyRestart"] = false;
	if (GAME_ENGINE->IsKeyDown(VK_SPACE) || GAME_ENGINE->IsKeyDown(VK_RETURN)) m_Lua["startKey"] = true; else m_Lua["startKey"] = false;
}

void Game::KeyPressed(TCHAR key)
{
	// DO NOT FORGET to use SetKeyList() !!

	// Insert code that needs to execute when a key is pressed
	// The function is executed when the key is *released*
	// You need to specify the list of keys with the SetKeyList() function

	/* Example:
	switch (key)
	{
	case _T('K'): case VK_LEFT:
		GAME_ENGINE->MessageBox("Moving left.");
		break;
	case _T('L'): case VK_DOWN:
		GAME_ENGINE->MessageBox("Moving down.");
		break;
	case _T('M'): case VK_RIGHT:
		GAME_ENGINE->MessageBox("Moving right.");
		break;
	case _T('O'): case VK_UP:
		GAME_ENGINE->MessageBox("Moving up.");
		break;
	case VK_ESCAPE:
		GAME_ENGINE->MessageBox("Escape menu.");
	}
	*/
}

void Game::CallAction(Caller* callerPtr)
{
	// Insert the code that needs to execute when a Caller (= Button, TextBox, Timer, Audio) executes an action
}

void Game::Binding(sol::state& lua)
{
	// 2. Bind GameEngine
    lua.new_usertype<GameEngine>("GameEngine",

        // State -------------------------------------------------
        "SetColor",
        [](GameEngine& ge, sol::table color) {
            int r = color["r"];
            int g = color["g"];
            int b = color["b"];
            ge.SetColor(RGB(r, g, b));
        },

        "SetFont",
        [](GameEngine& ge, Font* font) {
            ge.SetFont(font);
        },

        "FillWindowRect",
        [](GameEngine& ge, sol::table color) {
            int r = color["r"];
            int g = color["g"];
            int b = color["b"];
            return ge.FillWindowRect(RGB(r, g, b));
        },

        "GetDrawColor",
        &GameEngine::GetDrawColor,

        "Repaint",
        &GameEngine::Repaint,

        // Lines & rectangles ------------------------------------
        "DrawLine",
        &GameEngine::DrawLine,

        "DrawRect",
        &GameEngine::DrawRect,

        "FillRect",
        static_cast<bool (GameEngine::*)(int, int, int, int) const>(
            &GameEngine::FillRect),

        "FillRectAlpha",
        static_cast<bool (GameEngine::*)(int, int, int, int, int) const>(
            &GameEngine::FillRect),

        "DrawRoundRect",
        &GameEngine::DrawRoundRect,

        "FillRoundRect",
        &GameEngine::FillRoundRect,

        // Ovals & arcs -----------------------------------------
        "DrawOval",
        &GameEngine::DrawOval,

        "FillOval",
        static_cast<bool (GameEngine::*)(int, int, int, int) const>(
            &GameEngine::FillOval),

        "FillOvalAlpha",
        static_cast<bool (GameEngine::*)(int, int, int, int, int) const>(
            &GameEngine::FillOval),

        "DrawArc",
        &GameEngine::DrawArc,

        "FillArc",
        &GameEngine::FillArc,

        // Text --------------------------------------------------
        "DrawString",
        static_cast<int (GameEngine::*)(const tstring&, int, int) const>(
            &GameEngine::DrawString),

        "DrawStringRect",
        static_cast<int (GameEngine::*)(const tstring&, int, int, int, int) const>(
            &GameEngine::DrawString),

        // Bitmaps ----------------------------------------------
        "DrawBitmap",
        static_cast<bool (GameEngine::*)(const Bitmap*, int, int) const>(
            &GameEngine::DrawBitmap),

        "DrawBitmapRegion",
        static_cast<bool (GameEngine::*)(const Bitmap*, int, int, RECT) const>(
            &GameEngine::DrawBitmap),

        // Polygons ---------------------------------------------
		"DrawPolygon",
		[](GameEngine& ge, const std::vector<POINT>& pts, int count) {
			return ge.DrawPolygon(pts.data(), count);
		},

		"DrawPolygonEx",
		[](GameEngine& ge, const std::vector<POINT>& pts, int count, bool close) {
			return ge.DrawPolygon(pts.data(), count, close);
		},

		"FillPolygon",
		[](GameEngine& ge, const std::vector<POINT>& pts, int count) {
			return ge.FillPolygon(pts.data(), count);
		},

		"FillPolygonEx",
		[](GameEngine& ge, const std::vector<POINT>& pts, int count, bool close) {
			return ge.FillPolygon(pts.data(), count, close);
		}
    );

    // 3. Expose engine instance
    lua["cpp_gameEngine"] = GAME_ENGINE;
	lua["tileFont"] = m_pTileFont;   
	lua["announcementFont"] = m_pAnnouncementFont;   
	lua["titleFont"] = m_pTitleFont;  

	lua["windowWidth"] = GAME_ENGINE->GetWidth();
	lua["windowHeight"] = GAME_ENGINE->GetHeight();

}

