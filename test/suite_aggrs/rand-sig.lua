require"config"

-- assure aggr chars are present in pairs (can be weighted, though), to avoid
-- inf loops; closing chars are allowe to appear alone, as they are ignored
-- without any opening char (does not make a lot of sense, though)
pairs_op = { '{', '<' } --, '[' }
pairs_cl = { '}', '>' } --, ']' }

aggr_op_pattern = '[%'..table.concat(pairs_op,'%')..']'

for i = 1, #pairs_op do
  if string.find(types, '%'..pairs_op[i]) and not string.find(types, '%'..pairs_cl[i]) then
    types = types..pairs_cl[i]
  end
end

rtypes   = "v"..types

function mkaggr(n_nest, maxdepth, o, c)
  local s = o

  repeat
    local id = math.random(#types)
    local t = types:sub(id,id)
    s = s..mktype(t, n_nest, maxdepth, o)

    -- member (which cannot be first char) as array? Disallow multidimensional arrays
    if #s > 1 and t ~= c and s:sub(-1) ~= ']' and math.random(arraydice) == 1 then
      s = s..'['..math.random(maxarraylen)..']'
    end
  until t == c

  return s
end

function mktype(t, n_nest, maxdepth, aggr_open)
  -- aggregate opener?
  local aggr_i = 0
  for i = 1, #pairs_op do
    if pairs_op[i] == t then
      aggr_i = i
      break
    end
  end

  -- ignore new aggregates if above depth limit
  if aggr_i ~= 0 and t == pairs_op[aggr_i] then
    if n_nest < maxdepth then
      return mkaggr(n_nest + 1, maxdepth, pairs_op[aggr_i], pairs_cl[aggr_i])
    else
      return ''
    end
  end

  -- aggregate closer?
  for i = 1, #pairs_cl do
    if pairs_cl[i] == t then
      aggr_i = i
      break
    end
  end

  -- if closing char, without any open, ignore
  if aggr_i ~= 0 and (aggr_open == nil or pairs_op[aggr_i] ~= aggr_open) then
    return ''
  end

  return t
end

function contains_empty_aggr(s)
  for i = 1, #pairs_op do
    if string.match(s, '%'..pairs_op[i]..'%'..pairs_cl[i]) ~= nil then
      return true
    end
  end
  return false
end

math.randomseed(seed)
local id
local uniq_sigs = { }
for i = 1, ncases do
  local l = ''
  repeat
    local nargs = math.random(minargs,maxargs)
    id = math.random(#rtypes)
    local sig = { mktype(rtypes:sub(id,id), 0, math.random(maxaggrdepth), nil) } -- random depth avoids excessive nesting
    for j = 1, nargs do
      id = math.random(#types)
      sig[#sig+1] = mktype(types:sub(id,id), 0, math.random(maxaggrdepth), nil) -- random depth avoids excessive nesting
    end
    l = table.concat(sig)
    -- reject dupes, sigs without any aggregate (as this is about aggrs after all), and empty ones (if not wanted)
  until string.match(l, aggr_op_pattern) ~= nil and uniq_sigs[l] == nil and (emptyaggrs or not contains_empty_aggr(l))
  uniq_sigs[l] = 1
  io.write(l.."\n")
end

