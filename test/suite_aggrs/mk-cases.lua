require"math"
local max = math.max
local maxargs = 0

local n_aggrs = 0
local seen_aggrs = { }


function trim(l) return l:gsub("^%s+",""):gsub("%s+$","") end
function mkcase(id,sig)
  local sig = trim(sig)
  -- @@@ return value hard-guessed by first char, doesn't hold anymore
  local h = { "/* ",id,":",sig," */ ",sig:sub(1,1), " f", id,"(","" }
  local t = { "" }
  local pos = 1
  local n_nest = 0
  local aggr
  local aggr_sig = ''
  for i = 2, #sig do 
    local name = "a"..pos
    local ch   = sig:sub(i,i)

    aggr_sig = aggr_sig..ch

    -- aggregate nest level change?
    if ch == '{' then
      n_nest = n_nest + 1
      aggr = { }
      aggr_sig = ch  -- @@@ handle nesting
    else
      if ch == '}' then  -- @@@ handle nesting, here, by reusing structs
        n_nest = n_nest - 1
        -- aggr sig complete?
        if n_nest == 0 then
          -- register yet unseen aggregates, key is sig, val is body and name
          if seen_aggrs[aggr_sig] == nil then
            n_aggrs = n_aggrs + 1
            ch = 'A'..n_aggrs
            seen_aggrs[aggr_sig] = { aggr, ch }
          end
          ch = seen_aggrs[aggr_sig][2]
        end
      else
        if n_nest > 0 then
          aggr[#aggr+1] = ch
          aggr[#aggr+1] = 'm'..(#aggr >> 1)
        end
      end
    end

    if n_nest == 0 then
      -- struct types (more than one char) need copying via a func
      if #ch > 1 then
        h[#h+1] = 'struct '..ch.." "..name
        t[#t+1] = 'f_cp'..ch..'(V_a['..pos.."],&"..name..");"
      else
        h[#h+1] = ch.." "..name
        t[#t+1] = "V_"..ch.."["..pos.."]="..name..";"
      end
      h[#h+1] = ","

      pos = pos + 1
    end
  end
  maxargs = max(maxargs, pos-1)
  h[#h] = "){"
  t[#t+1] = "ret_"..sig:sub(1,1).."("..(pos-1)..")}\n"
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
  local s = { "char const * G_sigtab[] = {\n"}
  for k,v in pairs(sigs) do
    s[#s+1] = '\t"'..v..'",\n'
  end
  s[#s+1] = "};\n"
  return table.concat(s,"")
end

function mkall()
  local lineno = 0
  local sigtab = { }
  local cases = ''
  for line in io.lines() do
    local sig = trim(line)
    cases = cases..mkcase(lineno,sig)
    sigtab[#sigtab+1] = sig
    lineno = lineno + 1
  end

  agg_sizes = {}
  agg_sigs  = {}
  agg_names = {}
  for k, v in pairs(seen_aggrs) do
    st = 'struct '..v[2]

    agg_sizes[#agg_sizes + 1] = 'sizeof('..st..')'
    agg_sigs [#agg_sigs  + 1] = k
    agg_names[#agg_names + 1] = v[2]

    -- struct def
    io.write('/* '..k..' */\n')
    io.write(st..'{ ')
    for i = 1, #v[1], 2 do
      io.write(v[1][i]..' '..v[1][i+1]..'; ')
    end
    io.write("};\n")

    -- struct cp and cmp funcs
    s = {
      'void f_cp'..v[2]..'('..st..' *x, const '..st..' *y) { ',
      'int f_cmp'..v[2]..'(const '..st..' *x, const '..st..' *y) { return '
    }
    o = { '=', '==', '; ', ' && '  }
    for t = 1, 2 do
      io.write(s[t])
      b = {}
      for i = 1, #v[1], 2 do
        b[#b+1] = 'x->'..v[1][i+1]..' '..o[t]..' y->'..v[1][i+1];
      end
      if #b == 0 then
        b[1] = '1'  -- to handle empty structs
      end
      io.write(table.concat(b,o[t+2]).."; };\n")
    end

    -- convenient dcnewstruct helper funcs
    io.write('DCstruct* f_newdcst'..v[2]..'() { DCstruct* st = dcNewStruct('..(#v[1]>>1)..', sizeof('..st..'), 0, 1); ')
    for i = 1, #v[1], 2 do
      io.write("dcStructField(st, '"..v[1][i].."', offsetof("..st..', '..v[1][i+1]..'), 1); ')
    end
    io.write(" dcCloseStruct(st); return st; };\n")
  end

  io.write(cases)
  io.write(mkfuntab(lineno))
  io.write(mksigtab(sigtab))
  io.write('const char* G_agg_sigs[]  = {\n\t"'..table.concat(agg_sigs, '",\n\t"')..'"\n};\n')
  io.write('int G_agg_sizes[] = {\n\t'..table.concat(agg_sizes, ',\n\t')..'\n};\n')
  io.write('funptr G_agg_newdcstfuncs[] = {\n\t(funptr)&f_newdcst'..table.concat(agg_names, ',\n\t(funptr)&f_newdcst')..'\n};\n')
  io.write('funptr G_agg_cmpfuncs[] = {\n\t(funptr)&f_cmp'..table.concat(agg_names, ',\n\t(funptr)&f_cmp')..'\n};\n')
  io.write("int G_maxargs = "..maxargs..";\n")
end

mkall()

