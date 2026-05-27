Title: Windows/MSVC build fixes for `rive_common` (avoid Clang-only flags, add MSVC guards, enable C++20)

Summary

On Windows/MSVC the `rive_common` plugin (used by the `rive` package) currently fails to build because:

- The plugin's Windows CMake unconditionally adds GCC/Clang `-W...` flags which cause `cl.exe` to error (D8021).
- In some versions a `VS_PLATFORM_TOOLSET` was forced to `ClangCL`, causing MSBuild `MSB8020` when ClangCL isn't installed.
- Some generated sources require C++20 features (designated initializers) and very large object files require `/bigobj`.

Reproduction

1. Create a Flutter project that depends on `rive` / `rive_common`.
2. `flutter run -d windows` on a machine with Visual Studio (MSVC) installed.
3. Observe failures like `cl D8021` and later `error C7555` and `C4576`.

Proposed changes

1. Avoid passing GCC/Clang `-W...` flags to MSVC by guarding CMake flags with `if(MSVC)` / `else()`.
2. Do not force `VS_PLATFORM_TOOLSET` to `ClangCL` — allow user's Visual Studio selection or document Clang requirement.
3. For MSVC, enable `cxx_std_20` (or at least `/std:c++20`) and add `/bigobj` when needed to compile large third-party sources (e.g., HarfBuzz) and to support designated initializers.
4. Ensure warnings-as-errors (`/WX`) is not globally applied to plugin third-party code; disable for the plugin target on MSVC.

Example patch (attached): updates `windows/CMakeLists.txt` to set MSVC-specific flags and features and avoid `-W` flags being applied to `cl.exe`.

Testing notes

- I've applied the proposed changes locally in the pub cache and they resolved `-W`/D8021 and MSB8020 issues; subsequent MSVC errors were reduced but some generated FFI bindings still needed C++20 and `/bigobj` to compile.
- The attached patch contains the minimal changes that should be safe to merge for Windows users using MSVC.

Request

Please review and consider merging. Happy to refine the guards or add CI to validate Windows/MSVC builds.

/cc @maintainers
