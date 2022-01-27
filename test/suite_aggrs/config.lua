-- user config for rand-sig.lua:
minargs      = 0
maxargs      = 16
maxaggrdepth = 3    -- max nesting depth of aggregates, 1 = no nesting
emptyaggrs   = true -- whether to allow empty aggregates or not
ncases       = 400
types        = "csijlpfd{}"
seed         = 2112

-- specify types more than once to increase relative occurance, e.g.:

-- this favors non-struct args, especially ints (and also increases avg num of struct fields):
--types       = "ccssiiiiijjllpfd{}"

-- this heavily favors nested structs:
--types       = "csijlpfd{{{{{{}"

-- this heavily favors flat and short/empty structs:
--types       = "csijlpfd{}}}}}}"
