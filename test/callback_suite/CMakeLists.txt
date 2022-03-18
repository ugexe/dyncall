add_executable(callback_suite env.c do_test.c main.c)
target_link_libraries(callback_suite dyncall_s dyncallback_s)

