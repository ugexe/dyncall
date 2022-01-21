require"config"

-- assure aggr chars are present in pairs (can be weighted, though), to avoid
-- inf loops
if string.match(types,'{') and not string.match(types,'}') then types = types..'}' end

rtypes   = "v"..types


function mkstruct(n_nest)
  local s = "{"

  repeat
    local id = math.random(#types)
    local t = types:sub(id,id)
    s = s..mktype(t, n_nest)
  until t == '}'

  return s
end

function mktype(t, n_nest)
  -- ignore new structs if above depth limit
  if t == '{' then
    if n_nest < maxaggrdepth then
      return mkstruct(n_nest + 1)
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
for i = 1, ncases do
  id = math.random(#rtypes)
  local nargs = math.random(minargs,maxargs)
  local sig   = { mktype(rtypes:sub(id,id), 0) }
  for j = 1, nargs do
    id = math.random(#types)
    sig[#sig+1] = mktype(types:sub(id,id), 0)
  end
  io.write(table.concat(sig))
  io.write("\n")
end

