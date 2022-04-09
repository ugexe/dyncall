require "config"

function trim(l) return l:gsub("^%s+",""):gsub("%s+$","") end
function mkcase(id,sig)
  local nargs = string.len(sig) - 2 -- @@@STRUCT wrong, b/c ignores callconv prefixes
  local rtype = string.sub(sig, nargs + 2, nargs + 2)
  local s   = "F" .. nargs .. "(f" .. id .. "," .. rtype
  for i = 1, nargs do
    local type  = string.sub(sig, i, i)
    s = s .. "," .. type 
  end
  s = s .. ")\n"
  return s
end

-- @@@STRUCT same as in call_suite{,_aggrs}, share?
function mkfuntab(n)
  local s = { "funptr G_funtab[] = {\n"}
  for i = 0, n-1 do
    s[#s+1] = "\t&f"..i..",\n"
  end
  s[#s+1] = "};\n"
  return table.concat(s,"")
end

-- @@@STRUCT same as in call_suite{,_aggrs}, share?
function mksigtab(sigs)
  local s = { "const char * G_sigtab[] = {\n"}
  for k,v in pairs(sigs) do
    s[#s+1] = '\t"'..v..'",\n'
  end
  s[#s+1] = "};\n"
  return table.concat(s,"")
end

function mkall()
  -- force minargs for ordered mode @@@STRUCT why?
  if mode == "ordered" then
    minargs = 0
  end

  -- case macros
  local i
  for i = minargs, maxargs do
    local line = "#define F" .. i .. "(ID,R"
    local argdef = ""
    local argset = ""
    if i > 0 then
      line = line .. ","
      local j
      for j = 0, i-1 do
        if j > 0 then 
          argdef = argdef .. ","
          argset = argset .. ","
        end
        argdef = argdef .. "M" .. j
        argset = argset .. "M[" .. j .. "].M" .. j
      end
    end
    line = line .. argdef .. ") void ID(void* addr) { Result.R = ((CONFIG_API R(*)("  .. argdef .. "))addr)(" .. argset .. ");}\n"
    io.write(line)
  end

  -- cases
  local lineno = 0
  local sigtab = { }
  local cases = ''
  for line in io.lines() do
    local sig = trim(line)
    cases = cases..mkcase(lineno,sig)
    sigtab[#sigtab+1] = sig
    lineno = lineno + 1
  end

  io.write(cases)
  io.write(mkfuntab(lineno))
  io.write(mksigtab(sigtab))
  io.write("int G_maxargs = "..maxargs..";\n")
end

mkall()

