require"math"
local max = math.max
local maxargs = 0

local aggrs = { }
local seen_aggrs = { }


function canon_type(t)
  -- aggregate types start with special (closing) char
  c = ({ ['}'] = 'struct ', ['>'] = 'union  ' })[t:sub(1,1)]
  if c ~= nil then
    return c..'A'..t:sub(2)
  end
  return t
end

function trim(l) return l:gsub("^%s+",""):gsub("%s+$","") end
function mkcase(id,sig)
  local sig = trim(sig)
  local h = { "/* ",id,":",sig," */ " }
  local t = { "" }
  local pos = 0
  local n_nest = 0
  local aggr = { }
  local aggr_sig = { }
  aggr[0] = { }     -- non-sequential [0] collects all non-aggr types
  aggr_sig[0] = ''
  for i = 1, #sig do
    local name = "a"..pos
    local ch   = sig:sub(i,i)

    -- aggregate nest level change?
    if ch == '{' or ch == '<' then
      n_nest = n_nest + 1
      aggr[n_nest] = { }
      aggr_sig[n_nest] = ''
    end

    aggr_sig[n_nest] = aggr_sig[n_nest]..ch

    if ch == '}' or ch == '>' then
      -- register yet unseen aggregates, key is sig, val is body and name
      if seen_aggrs[aggr_sig[n_nest]] == nil then
        aggrs[#aggrs+1] = aggr_sig[n_nest]
        ch = ch..#aggrs
        seen_aggrs[aggr_sig[n_nest]] = { aggr[n_nest], ch }
      end
      ch = seen_aggrs[aggr_sig[n_nest]][2]

      n_nest = n_nest - 1
      aggr_sig[n_nest] = aggr_sig[n_nest]..aggr_sig[n_nest+1]
    end

    if ch ~= '{' and ch ~= '}' and ch ~= '<' and ch ~= '>' then
      aggr[n_nest][#aggr[n_nest]+1] = canon_type(ch)
      aggr[n_nest][#aggr[n_nest]+1] = 'm'..(#aggr[n_nest] >> 1)
    end


    if n_nest == 0 then
      h[#h+1] = canon_type(ch)
      -- aggregate types (more than one char) need copying via a func
      if #h[#h] > 1 then
        t[#t+1] = 'f_cp'..h[#h]:sub(8)..'(V_a['..pos.."],&"..name..");"
      else
        t[#t+1] = "V_"..ch.."["..pos.."]="..name..";"
      end

      -- is return type or func arg?
      if pos == 0 then
        h[#h+1] = " f"..id.."("
        h[#h+1] = ''
        t[#t] = ''  -- clear; aggr return type handled explicitly
      else
        h[#h+1] = ' '..name
        h[#h+1] = ","
      end

      pos = pos + 1
    end
  end
  maxargs = max(maxargs, pos-1)
  h[#h] = "){"
  if #h[6] == 1 then
    t[#t+1] = "ret_"..h[6].."("..(pos-1)..")}\n"
  else
    t[#t+1] = "ret_a("..(pos-1)..","..h[6]..")}\n"
  end
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
  for a = 1, #aggrs do
    k = aggrs[a]
	v = seen_aggrs[k]
    st = canon_type(v[2])

    agg_sizes[#agg_sizes + 1] = 'sizeof('..st..')'
    agg_sigs [#agg_sigs  + 1] = k
    agg_names[#agg_names + 1] = st:sub(8)

    -- aggregate def
    io.write('/* '..k..' */\n')
    io.write(st..' { ')
    for i = 1, #v[1], 2 do
      io.write(v[1][i]..' '..v[1][i+1]..'; ')
    end
    io.write("};\n")

    -- aggregate cp and cmp funcs
    s = {
      'void f_cp'..st:sub(8)..'('..st..' *x, const '..st..' *y) { ',
      'int f_cmp'..st:sub(8)..'(const '..st..' *x, const '..st..' *y) { return '
    }
    o = { '=', '==', 'f_cp', 'f_cmp', '; ', ' && ', '', '1' }
    for t = 1, 2 do
      io.write(s[t])
      b = {}
      for i = 1, #v[1], 2 do
        if string.match(v[1][i], ' ') then -- aggregate canonical types contain at least one space
		  b[#b+1] = o[t+2]..v[1][i]:sub(8)..'(&x->'..v[1][i+1]..', &y->'..v[1][i+1]..')';
		else
          b[#b+1] = 'x->'..v[1][i+1]..' '..o[t]..' y->'..v[1][i+1];
		end
      end
      if #b == 0 then  -- to handle empty aggregates
        b[1] = o[t+6]
      end
      io.write(table.concat(b,o[t+4]).."; };\n")
    end

    -- convenient dcnewstruct helper funcs
    io.write('DCstruct* f_touchdcst'..st:sub(8)..'() {\n\tstatic DCstruct* st = NULL;\n\tif(!st) {\n\t\tst = dcNewStruct('..(#v[1]>>1)..', sizeof('..st..'), DC_TRUE);\n\t\t')
    for i = 1, #v[1], 2 do
      if string.match(v[1][i], ' ') then -- aggregate canonical types contain at least one space
	    io.write('dcStructField(st, DC_SIGCHAR_STRUCT, offsetof('..st..', '..v[1][i+1]..'), 1, f_touchdcst'..v[1][i]:sub(8)..'());\n\t\t')
	  else
        io.write("dcStructField(st, '"..v[1][i].."', offsetof("..st..', '..v[1][i+1]..'), 1);\n\t\t')
	  end
    end
    io.write("dcCloseStruct(st);\n\t}\n\treturn st;\n};\n")
  end

  -- make table.concat work
  if #agg_names > 0 then
    table.insert(agg_names, 1, '')
  end

  io.write(cases)
  io.write(mkfuntab(lineno))
  io.write(mksigtab(sigtab))
  io.write('const char* G_agg_sigs[]  = {\n\t"'..table.concat(agg_sigs, '",\n\t"')..'"\n};\n')
  io.write('int G_agg_sizes[] = {\n\t'..table.concat(agg_sizes, ',\n\t')..'\n};\n')
  io.write('funptr G_agg_touchdcstfuncs[] = {'..string.sub(table.concat(agg_names, ',\n\t(funptr)&f_touchdcst'),2)..'\n};\n')
  io.write('funptr G_agg_cmpfuncs[] = {'..string.sub(table.concat(agg_names, ',\n\t(funptr)&f_cmp'),2)..'\n};\n')
  io.write("int G_maxargs = "..maxargs..";\n")
end

mkall()

