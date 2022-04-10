function trim(s)
  return s:gsub("^%s+",""):gsub("%s+$","")
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

