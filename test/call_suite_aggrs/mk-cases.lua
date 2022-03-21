require"config"
require"math"
local max_numargs = 0

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

function put_sig_rtype_first(sig)
  return sig:sub(sig:find(')')+1,-1)..sig:sub(1,sig:find(')')-1)
end


function trim(l) return l:gsub("^%s+",""):gsub("%s+$","") end
function mkcase(id,sig)
  local sig = trim(sig)
  local fsig = put_sig_rtype_first(sig)
  local h = { "/* ",id,":",sig," */ " }
  local t = { "" }
  local pos = 0
  local n_nest = 0
  local aggr = { }
  local aggr_sig = { }
  aggr[0] = { }     -- non-sequential [0] collects all non-aggr types
  aggr_sig[0] = ''
  for i = 1, #fsig do
    local name = "a"..pos
    local ch   = fsig:sub(i,i)


    -- aggregate nest level change?
    if ch == '{' or ch == '<' then
      n_nest = n_nest + 1
      aggr[n_nest] = { }
      aggr_sig[n_nest] = ''
    end

    aggr_sig[n_nest] = aggr_sig[n_nest]..ch

    -- array? Just append to name of member var from prev loop
    if ch:match('[%[%]0123456789]') ~= nil then
      aggr[n_nest][#aggr[n_nest]] = aggr[n_nest][#aggr[n_nest]]..ch
    else

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

      -- no nesting (= actual func args), generate case code
      if n_nest == 0 then
        h[#h+1] = canon_type(ch)
        -- aggregate types have more than one
        if #h[#h] > 1 then
          if aggrcpsimple then
            t[#t+1] = '*('..h[#h]..'*)V_a['..pos.."]="..name..";"
          else
            t[#t+1] = 'f_cp'..h[#h]:sub(8)..'(V_a['..pos.."],&"..name..");"
          end
          if aggrmutabletest then
            t[#t] = t[#t]..'memset(&'..name..',0,sizeof('..name..'));'
          end
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
  end
  max_numargs = math.max(max_numargs, pos-1)
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

function split_array_decl(s)
  local name = s
  local n = nil  -- not an array
  local array_i = s:find('%[')
  if array_i ~= nil then
    name = name:sub(1, array_i-1)
    n = tonumber(s:sub(array_i):match('[0123456789]+'))
  end
  return { name, n }
end

function mkall()
  local lineno = 0
  local sigtab = { }
  local cases = ''
  for line in io.lines() do
    local sig = trim(line)
    cases = cases..mkcase(lineno,sig)
    sigtab[#sigtab+1] = put_sig_rtype_first(sig)
    lineno = lineno + 1
  end

  agg_sizes = {}
  agg_sigs  = {}
  agg_names = {}
  for a = 1, #aggrs do
    local k = aggrs[a]
    local v = seen_aggrs[k]
    local at = canon_type(v[2])  -- aggregate type
    local am = v[1]              -- aggregate members

    agg_sizes[#agg_sizes + 1] = 'sizeof('..at..')'
    agg_sigs [#agg_sigs  + 1] = k
    agg_names[#agg_names + 1] = at:sub(8)

    -- aggregate def
    io.write('/* '..k..' */\n')
    if aggrpacking ~= 0 then
      local pack = aggrpacking
      if pack < 0 then
        pack = math.floor(math.pow(2,math.floor(math.log(math.random(math.abs(pack)),2))))
      end
      io.write('#pragma pack(push,'..pack..')\n')
    end

    io.write(at..' { ')
    for i = 1, #am, 2 do
      io.write(am[i]..' '..am[i+1]..'; ')
    end
    io.write("};\n")

    if aggrpacking ~= 0 then
      io.write('#pragma pack(pop)\n')
    end

    -- aggregate cp and cmp funcs
    s = {
      'void f_cp'..at:sub(8)..'('..at..' *x, const '..at..' *y) { ',
      'int f_cmp'..at:sub(8)..'(const '..at..' *x, const '..at..' *y) { return '
    }
    o = { '=', '==', 'f_cp', 'f_cmp', '; ', ' && ', '', '1' }
    for t = 1, 2 do
      if t ~= 1 or aggrcpsimple == false then
        io.write(s[t])
        local b = {}
        for i = 1, #am, 2 do
          local m = split_array_decl(am[i+1])
          local fmt = ''
          if m[2] ~= nil then -- need array suffixes?
            fmt = '[%d]'
          else
            m[2] = 1
          end
       
          for j = 1, m[2] do
            name = m[1]..string.format(fmt, j-1)
            if string.match(am[i], ' ') then -- aggregate canonical types contain at least one space
              b[#b+1] = o[t+2]..am[i]:sub(8)..'(&x->'..name..', &y->'..name..')'
            else
              b[#b+1] = 'x->'..name..' '..o[t]..' y->'..name
            end
          end
        end
        if #b == 0 then  -- to handle empty aggregates
          b[1] = o[t+6]
        end
        io.write(table.concat(b,o[t+4]).."; };\n")
      end
    end

    -- convenient dcnewstruct helper funcs
    io.write('DCaggr* f_touchdcst'..at:sub(8)..'() {\n\tstatic DCaggr* at = NULL;\n\tif(!at) {\n\t\tat = dcNewAggr('..(#am>>1)..', sizeof('..at..'), DC_TRUE);\n\t\t')
    for i = 1, #am, 2 do
      local m = split_array_decl(am[i+1])
      if m[2] == nil then -- need array suffixes?
        m[2] = 1
      end
      if string.match(am[i], ' ') then -- aggregate canonical types contain at least one space
        --io.write('dcAggrField(at, DC_SIGCHAR_AGGREGATE, offsetof('..at..', '..m[1]..'), '..m[2]..', f_touchdcst'..am[i]:sub(8)..'());\n\t\t')
        io.write("AFa("..at..','..m[1]..','..m[2]..','..am[i]:sub(8)..')\n\t\t')
      else
        --io.write("dcAggrField(at, '"..am[i].."', offsetof("..at..', '..m[1]..'), '..m[2]..');\n\t\t')
        io.write("AF('"..am[i].."',"..at..','..m[1]..','..m[2]..')\n\t\t')
      end
    end
    io.write("dcCloseAggr(at);\n\t}\n\treturn at;\n};\n")
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
  io.write("int G_maxargs = "..max_numargs..";\n")
end

math.randomseed(seed)
mkall()

