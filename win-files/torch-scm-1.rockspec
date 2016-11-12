package = "torch"
version = "scm-1"

source = {
   url = "git://github.com/torch/torch7.git",
}

description = {
   summary = "Torch7",
   detailed = [[
   ]],
   homepage = "https://github.com/torch/torch7",
   license = "BSD"
}

dependencies = {
   "lua >= 5.1",
   "paths >= 1.0",
   "cwrap >= 1.0"
}

build = {
   type = "command",
   build_command = [[
cmake -E make_directory build && cd build && cmake .. -DCMAKE_BUILD_TYPE=Release -G "NMake Makefiles" -DLUA=$(LUA) -DLUALIB=$(LUALIB) -DLUA_BINDIR="$(LUA_BINDIR)" -DLUA_INCDIR="$(LUA_INCDIR)" -DLUA_LIBDIR="$(LUA_LIBDIR)" -DLUADIR="$(LUADIR)" -DLIBDIR="$(LIBDIR)" -DCMAKE_INSTALL_PREFIX="$(PREFIX)" && $(MAKE) -j$(getconf _NPROCESSORS_ONLN)
]],
     platforms = {
      windows = {
           build_command = [[
cmake -E make_directory build && cd build && cmake .. -DCMAKE_BUILD_TYPE=Release -G "NMake Makefiles" -DLUA=$(LUA) -DLUALIB=$(LUALIB) -DLUA_BINDIR="$(LUA_BINDIR)" -DLUA_INCDIR="$(LUA_INCDIR)" -DLUA_LIBDIR="$(LUA_LIBDIR)" -DLUADIR="$(LUADIR)" -DLIBDIR="$(LIBDIR)" -DCMAKE_INSTALL_PREFIX="$(PREFIX)" -DBLAS_LIBRARIES="$(LIBDIR)/../../../../lib/mkl_core_dll.lib;$(LIBDIR)/../../../../lib/mkl_intel_lp64_dll.lib;$(LIBDIR)/../../../../lib/mkl_blas95_lp64.lib;$(LIBDIR)/../../../../lib/mkl_sequential_dll.lib" -DBLAS_INFO=mkl -DLAPACK_LIBRARIES=$(LIBDIR)/../../../../lib/mkl_lapack95_lp64.lib -DLAPACK_FOUND=TRUE && $(MAKE)
]]
      }
   },
   install_command = "cd build && $(MAKE) install"
}