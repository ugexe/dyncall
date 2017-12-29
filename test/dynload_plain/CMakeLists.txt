add_executable(dynload_plain dynload_plain.c)
target_link_libraries(dynload_plain dynload_s ${CMAKE_DL_LIBS})
exec_program("ls /lib*/libc.so* | sort -V -r | head -1" OUTPUT_VARIABLE DEF_C_DYLIB)
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -DDEF_C_DYLIB=\\\"${DEF_C_DYLIB}\\\"")

