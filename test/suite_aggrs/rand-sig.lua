require"config"

-- assure aggr chars are present in pairs (can be weighted, though), to avoid
-- inf loops
if string.match(types,'{') and not string.match(types,'}') then types = types..'}' end

rtypes   = "v"..types


function mkstruct(n_nest, maxdepth)
  local s = "{"

  repeat
    local id = math.random(#types)
    local t = types:sub(id,id)
    s = s..mktype(t, n_nest, maxdepth)
  until t == '}'

  return s
end

function mktype(t, n_nest, maxdepth)
  -- ignore new structs if above depth limit
  if t == '{' then
    if n_nest < maxdepth then
      return mkstruct(n_nest + 1, maxdepth)
    else
      return ''
    end
  end

  -- if '}', without any open, use empty struct
  if n_nest == 0 and t == '}' then
    return "{}"
  end

  return t
end


math.randomseed(seed)
local id
local uniq_sigs = { }
for i = 1, ncases do
  local nargs = math.random(minargs,maxargs)
  local l = ''
  repeat
    id = math.random(#rtypes)
    local sig = { mktype(rtypes:sub(id,id), 0, math.random(maxaggrdepth)) } -- random depth avoids excessive nesting
    for j = 1, nargs do
      id = math.random(#types)
      sig[#sig+1] = mktype(types:sub(id,id), 0, math.random(maxaggrdepth)) -- random depth avoids excessive nesting
    end
    l = table.concat(sig)
    -- reject dupes, sigs without any aggregate (as this is about aggrs after all), and empty ones (if not wanted)
  until string.match(l, '{') ~= nil and uniq_sigs[l] == nil and (emptyaggrs or string.match(l, '{}') == nil)
  uniq_sigs[l] = 1
  io.write(l.."\n")
end

