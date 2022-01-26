suite_aggrs for dyncall written in C and Lua.

Tests aggregates (structs, unions and arrays) passed by value, along with
other, non-aggregate args.

A macro AGGR_MISALIGN can be used in globals.c to intentionally misalign
aggregate instances.

@@@ unions and arrays missing

