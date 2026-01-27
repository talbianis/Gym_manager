@echo off
echo ======================================
echo     CLEAN EVERYTHING (No Build)
echo ======================================
echo.

echo 1. Killing running processes...
taskkill /f /im gym_manager.exe 2>nul
taskkill /f /im dart.exe 2>nul
taskkill /f /im cmake.exe 2>nul
timeout /t 1 /nobreak >nul

echo 2. Cleaning Flutter...
flutter clean

echo 3. Deleting build directories...
if exist build (
    echo Deleting: build\
    rmdir /s /q build
    echo ✅ Deleted
)

if exist release (
    echo Deleting: release\
    rmdir /s /q release
    echo ✅ Deleted
)

echo 4. Cleaning CMake cache...
cd windows
if exist CMakeFiles (
    echo Deleting: windows\CMakeFiles\
    rmdir /s /q CMakeFiles
    echo ✅ Deleted
)

if exist CMakeCache.txt (
    echo Deleting: windows\CMakeCache.txt
    del CMakeCache.txt
    echo ✅ Deleted
)

del *.vcxproj* 2>nul
del *.sln 2>nul
cd ..

echo 5. Deleting old packages...
if exist Gym_Manager*.zip (
    echo Deleting old ZIP files...
    del Gym_Manager*.zip
    echo ✅ Deleted
)

if exist Gym_Manager_v* (
    echo Deleting old release folders...
    rmdir /s /q Gym_Manager_v* 2>nul
    echo ✅ Deleted
)

echo.
echo ======================================
echo ✅ CLEANUP COMPLETE!
echo ======================================
echo Everything cleaned. Ready for fresh build.
echo.
pause