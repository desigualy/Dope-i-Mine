# Minimal stub CMakeLists to avoid compiling large native sources during local debug.
cmake_minimum_required(VERSION 3.14)
project(rive_common_stub LANGUAGES CXX C)
set(PLUGIN_NAME "rive_common_plugin")

# Use only the lightweight plugin source that registers a no-op plugin.
add_library(${PLUGIN_NAME} SHARED rive_plugin.cpp)
apply_standard_settings(${PLUGIN_NAME})
set_target_properties(${PLUGIN_NAME} PROPERTIES CXX_VISIBILITY_PRESET hidden)
target_compile_definitions(${PLUGIN_NAME} PRIVATE FLUTTER_PLUGIN_IMPL)
target_link_libraries(${PLUGIN_NAME} PRIVATE flutter flutter_wrapper_plugin)
if(MSVC)
  target_compile_options(${PLUGIN_NAME} PRIVATE /WX-)
  target_compile_features(${PLUGIN_NAME} PRIVATE cxx_std_17)
else()
  target_compile_features(${PLUGIN_NAME} PRIVATE cxx_std_17)
endif()