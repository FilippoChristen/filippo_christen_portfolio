cmake_minimum_required(VERSION 3.20)

project(fpbo LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

file(GLOB_RECURSE SOURCES
    "${PROJECT_SOURCE_DIR}/src/*.cpp"
)

file(GLOB_RECURSE HEADERS
    "${PROJECT_SOURCE_DIR}/include/*.hpp"
    "${PROJECT_SOURCE_DIR}/include/*.h"
)

add_executable(fpbo
    ${SOURCES}
    ${HEADERS}
)

target_include_directories(fpbo
    PRIVATE
        "${PROJECT_SOURCE_DIR}/include"
)