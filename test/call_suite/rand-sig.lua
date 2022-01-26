require"config"

rtypes   = "v"..types

math.randomseed(seed)
local id
local uniq_sigs = { }
for i = 1, ncases do
  local l = ''
  repeat
    local nargs = math.random(minargs,maxargs)
    id = math.random(#rtypes)
    local sig = { rtypes:sub(id,id)}
    for j = 1, nargs do
      id = math.random(#types)
      sig[#sig+1] = types:sub(id,id)
    end
	l = table.concat(sig)
    -- reject dupes
  until uniq_sigs[l] == nil
  uniq_sigs[l] = 1
  io.write(l.."\n")
end

