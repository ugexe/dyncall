-- user config for rand-sig.lua:
minargs      = 0
maxargs      = 16
minaggrfields= 0    -- 0 allows for empty structs/unions
maxaggrfields= 12
maxarraylen  = 16   -- note some callconvs pass structs via regs, so using big numbers here will reduce those cases
arraydice    = 40   -- how often to turn a member into an array (1 out of arraydice-times)
maxaggrdepth = 3    -- max nesting depth of aggregates, 1 = no nesting
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
