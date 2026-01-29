cmake_minimum_required(VERSION 3.20)

project(LuaGameEngine
    LANGUAGES CXX C
)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

include(FetchContent)

# Fetch Lua
FetchContent_Declare(
    lua
    GIT_REPOSITORY https://github.com/marovira/lua.git
    GIT_TAG        5.4.4
)
FetchContent_MakeAvailable(lua)

# Fetch sol2
FetchContent_Declare(
    sol2
    GIT_REPOSITORY https://github.com/ThePhD/sol2.git
    GIT_TAG        v3.3.0
)

# Disable building sol2 tests/examples
set(SOL2_BUILD_TESTS OFF CACHE BOOL "" FORCE)
set(SOL2_BUILD_EXAMPLES OFF CACHE BOOL "" FORCE)

FetchContent_MakeAvailable(sol2)

# Paths inside the repo
set(ENGINE_SRC_DIR "${CMAKE_SOURCE_DIR}/Project/src")
set(ENGINE_INC_DIR "${CMAKE_SOURCE_DIR}/Project/inc")
set(RES_DIR "${CMAKE_SOURCE_DIR}/Project/resources")

file(GLOB_RECURSE ENGINE_SOURCES
    "${ENGINE_SRC_DIR}/*.cpp"
    "${ENGINE_SRC_DIR}/*.c"
)

add_executable(LuaGameEngine WIN32
    ${ENGINE_SOURCES}
)

# Engine includes
target_include_directories(LuaGameEngine
    PRIVATE
        ${ENGINE_INC_DIR}
)

# Lua headers
target_link_libraries(LuaGameEngine PRIVATE lua::lua)

FetchContent_GetProperties(sol2)
if(sol2_SOURCE_DIR) 
    target_include_directories(LuaGameEngine
        PRIVATE
            "${sol2_SOURCE_DIR}/include"
    )
endif()

set(GAME_SCRIPT_DIR "${CMAKE_SOURCE_DIR}/Game")

add_custom_command(TARGET LuaGameEngine POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy_directory
            "${GAME_SCRIPT_DIR}"
            "$<TARGET_FILE_DIR:LuaGameEngine>/Game"
)

