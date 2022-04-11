function trim(s)
  return s:gsub("^%s+",""):gsub("%s+$","")
end

-- parse array notation, e.g. returns "a", 4 for "a[4]"
function split_array_decl(s)
  local name = s
  local n = nil  -- not an array
  local i = s:find('%[')
  if i ~= nil then
    name = name:sub(1, i-1)
    n = tonumber(s:sub(i):match('[0123456789]+'))
  end
  return name, n
end

function mkfuntab(n, prefix, t, array_name, with_cast)
  local s = { t.." "..array_name.."[] = {\n"}
  local cast = ''
  if with_cast == true then
    cast = '('..t..')'
  end
  for i = 0, n-1 do
    s[#s+1] = "\t"..cast.."&"..prefix..i..",\n"
  end
  s[#s+1] = "};\n"
  return table.concat(s,"")
end

-- @@@ sigprefix should be added by generators, not here
function mksigtab(sigs, sigprefix, array_name)
  local s = { "const char * "..array_name.."[] = {\n"}
  for k,v in pairs(sigs) do
    s[#s+1] = '\t"'..sigprefix..v..'",\n'
  end
  s[#s+1] = "};\n"
  return table.concat(s,"")
end

