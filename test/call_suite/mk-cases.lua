require"math"
local max = math.max
local maxargs = 0

function trim(l) return l:gsub("^%s+",""):gsub("%s+$","") end
function mkcase(id,sig)
  local sig = trim(sig)
  local h = { "/* ",id,":",sig," */ ",sig:sub(-1), " f", id,"(","" }
  local t = { "" }
  local pos = 0
  maxargs = max(maxargs, #sig-2)
  for i = 1, #sig-2 do 
    local name = "a"..pos
    local ch   = sig:sub(i,i)
    h[#h+1] = ch.." "..name
    h[#h+1] = ","
    t[#t+1] = "V_"..ch.."["..pos.."]="..name..";"
    pos = pos + 1
  end
  h[#h] = "){"
  t[#t+1] = "ret_"..sig:sub(-1).."("..pos..")}\n"
  return table.concat(h,"")..table.concat(t,"")
end

function mkfuntab(n)
  local s = { "funptr G_funtab[] = {\n"}
  for i = 0, n-1 do
    s[#s+1] = "\t(funptr)&f"..i..",\n"
  end
  s[#s+1] = "};\n"
  return table.concat(s,"")
end

function mksigtab(sigs)
  local s = { "const char * G_sigtab[] = {\n"}
  for k,v in pairs(sigs) do
    s[#s+1] = '\t"'..v..'",\n'
  end
  s[#s+1] = "};\n"
  return table.concat(s,"")
end

function mkall()
  local lineno = 0
  local sigtab = { }
  for line in io.lines() do
    local sig = trim(line)
    io.write(mkcase(lineno,sig))
    sigtab[#sigtab+1] = sig
    lineno = lineno + 1
  end
  io.write(mkfuntab(lineno))
  io.write(mksigtab(sigtab))
  io.write("int G_maxargs = "..maxargs..";\n")
end

mkall()

