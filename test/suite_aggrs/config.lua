-- user config for rand-sig.lua:
minargs      = 0
maxargs      = 16
maxaggrdepth = 3    -- max nesting depth of aggregates, 1 = no nesting
emptyaggrs   = true -- whether to allow empty aggregates or not
ncases       = 400
types        = "csijlpfd{}<>"  -- {...} for structs, <...> for unions
seed         = 2112

-- specify types more than once to increase relative occurance, e.g.:

-- this favors non-aggregate args, especially ints (and also increases avg num of aggregate fields):
--types       = "ccssiiiiijjllpfd{}"

-- this heavily favors nested structs, while not having any union:
--types       = "csijlpfd{{{{{{}"

-- this heavily favors flat and short/empty aggregates:
--types       = "csijlpfd{}}}}}}<>>>>>"
