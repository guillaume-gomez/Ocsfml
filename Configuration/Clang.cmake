set(GCC_COMPATIBLE_COMPILER 1) 
set(TESTS_INSTALL_PREFIX "${CMAKE_INSTALL_PREFIX}/share/Ocsfml")
set(EXTERNAL_CPP_INSTALL_PREFIX "${CMAKE_INSTALL_PREFIX}/include/Ocsfml")
set(CPP_COMPILER ${CMAKE_CXX_COMPILER})
set(LIB_MAKER "ar")
set(DLL_LINKER "${CMAKE_CXX_COMPILER}")
set(LINK_STDLIB_STA "A \"-cclib\" ; A \"-lc++\"")
set(LINK_STDLIB_DYN "A \"-cclib\" ; A \"-lc++\"")
set(OBJ_FLAG "-o")
set(LIB_FLAG "-q")
set(INCLUDEPATH_FLAG "-I")
set(OPTIMIZATION_LEVEL "-g" )
set(COMPILATION_FLAGS "A \"${OPTIMIZATION_LEVEL}\" ; A \"-fPIC\" ; A \"-Wno-switch\" ; A \"-I${EXTERNAL_CPP_INSTALL_PREFIX}\";A \"-std=c++0x\" ;A \"-stdlib=libc++\"; A \"-c\"")
set(LINKING_LIB_FLAGS "A \"\"")
set(LINKING_DLL_FLAGS "A \"-shared\"")
if( ${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
    set(LINKING_DLL_FLAGS "${LINKING_DLL_FLAGS} ; A \"-Wl,flat_namespace\" ; A\"-Wl,undefined suppress\"")
endif()
set(MAKE_STATIC_COMMAND "make_archive")
set(OBJ_EXTENSION "o")
set(LIB_EXTENSION "a")
set(OCSFML_LINKPATH "A \"-L${OCAML_DIR}/site-lib/ocsfml\"")

if(${CPP_DEV_MODE})
  add_definitions(
    -fPIC ${OPTIMIZATION_LEVEL} -std=c++0x -stdlib=libc++
    )
endif()
