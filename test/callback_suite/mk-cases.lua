require "config"

function trim(l) return l:gsub("^%s+",""):gsub("%s+$","") end
function mkcase(id,sig)
  local rtype = string.sub(sig, -1)
  local i = 1
  local args = { rtype }
  while i < #sig do
    c = string.sub(sig, i, i)
    if(c == ')') then
      break
    end
    if(c == '_') then -- filter out prefixes
      i = i + 1
    else
	  args[#args+1] = c
    end
    i = i + 1
  end
  return "F" .. (#args-1) .. "(f" .. id .. "," .. table.concat(args,',') .. ")\n"
end

-- use shared helpers to generate cases
package.path = '../common/?.lua;' .. package.path
require"mk-cases"


function mkall()
  -- force minargs for ordered mode
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
        argset = argset .. "K_##M" .. j .. "[" .. j .. "]"
      end
    end
    line = line .. argdef .. ") void ID(void* addr) { write_V_##R(" .. i .. ", ((" .. api .. " R(*)("  .. argdef .. "))addr)(" .. argset .. "));}\n"
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
  io.write(mkfuntab(lineno, 'f', 'funptr', 'G_funtab', false))
  io.write(mksigtab(sigtab, ccprefix, 'G_sigtab'))
  io.write("int G_maxargs = "..maxargs..";\n")
end

mkall()

