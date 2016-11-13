rem - visual studio 2015 community
rem    https://beta.visualstudio.com/vs/community/
rem
rem - cmake installed at C:\Program Files (x86)\CMake\bin\cmake.exe (3.6.2-amd64)
rem       https://cmake.org/files/v3.6/cmake-3.6.2-win64-x64.msi
rem
rem Target build:
rem - windows 64 bit

setlocal
call "%VS140COMNTOOLS%\..\..\VC\bin\amd64\vcvars64.bat"
@echo on

SET "TORCH_LUA_VERSION=LUAJIT21"

set BASE=%~dp0
set "THIS_DIR=%BASE%"
set "PREFIX=%BASE%install"

set "CMAKE_LIBRARY_PATH=%BASE%/include:%BASE%/lib:%CMAKE_LIBRARY_PATH%"
set "CMAKE_PREFIX_PATH=%PREFIX%"

git submodule update --init --recursive

echo BASE: %BASE%

echo luajit-rocks
mkdir "%BASE%build"
cd "%BASE%build"
cmake ..\exe\luajit-rocks -DWITH_%TORCH_LUA_VERSION%=ON -DCMAKE_INSTALL_PREFIX=%PREFIX% -G "NMake Makefiles" -DCMAKE_BUILD_TYPE=Release
if errorlevel 1 goto :error
nmake
if errorlevel 1 goto :error
cmake -DCMAKE_INSTALL_PREFIX=%PREFIX% -G "NMake Makefiles" -P cmake_install.cmake -DCMAKE_BUILD_TYPE=Release
if errorlevel 1 goto :error

set "LUA_CPATH=%BASE%/install/?.DLL;%BASE%/install/LIB/?.DLL;?.DLL"
set "LUA_DEV=%BASE%/install"
set "LUA_PATH=;;%BASE%/install/?;%BASE%/install/?.lua;%BASE%/install/lua/?;%BASE%/install/lua/?.lua;%BASE%/install/lua/?/init.lua
set "PATH=%PATH%;%BASE%\install;%BASE%\install\bin"
luajit -e "print('ok')"
if errorlevel 1 goto :error
echo did luajit
cmd /c luarocks
if errorlevel 1 goto :error
echo did luarocks

copy "%BASE%\win-files\cmake.cmd" "%BASE%\install"
if errorlevel 1 exit goto :error
echo did copy of cmake

echo "Installing core Torch packages"
cd %THIS_DIR%\pkg\cwrap
cmd /c luarocks make rocks/cwrap-scm-1.rockspec
if errorlevel 1 goto :error
cd %THIS_DIR%\pkg\paths
cmd /c luarocks make rocks/paths-scm-1.rockspec
if errorlevel 1 goto :error

mkdir "%BASE%\install\lib"
set "MKL_DIR=C:\Program Files (x86)\IntelSWTools\compilers_and_libraries_2017\windows"
set "MKL_LIB_DIR=%MKL_DIR%\mkl\lib\intel64_win"
copy "%MKL_LIB_DIR%\mkl_blas95_lp64.lib" "%BASE%\install\lib"
copy "%MKL_LIB_DIR%\mkl_core_dll.lib" "%BASE%\install\lib"
copy "%MKL_LIB_DIR%\mkl_intel_lp64_dll.lib" "%BASE%\install\lib"
copy "%MKL_LIB_DIR%\mkl_lapack95_lp64.lib" "%BASE%\install\lib"
copy "%MKL_LIB_DIR%\mkl_sequential_dll.lib" "%BASE%\install\lib"
copy "%MKL_DIR%\redist\intel64_win\mkl\mkl_avx2.dll" "%BASE%\install"
copy "%MKL_DIR%\redist\intel64_win\mkl\mkl_core.dll" "%BASE%\install"
copy "%MKL_DIR%\redist\intel64_win\mkl\mkl_sequential.dll" "%BASE%\install"

cd %THIS_DIR%\pkg\torch
cmd /c luarocks make %Base%/win-files/torch-scm-1.rockspec
if errorlevel 1 goto :error
cd %THIS_DIR%\pkg\xlua
cmd /c luarocks make xlua-1.0-0.rockspec
if errorlevel 1 goto :error
cd %THIS_DIR%\extra\nn
cmd /c luarocks make rocks/nn-scm-1.rockspec
if errorlevel 1 goto :error

popd

luajit -e "require('torch')"
if errorlevel 1 exit /B 1

luajit -e "require('torch'); torch.test()"
if errorlevel 1 exit /B 1

luajit -e "require('nn'); nn.test()"
if errorlevel 1 exit /B 1

goto :eof

:error
echo something went wrong ...