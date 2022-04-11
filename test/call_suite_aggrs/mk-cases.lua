require"config"
require"math"

-- use shared helpers to generate cases
package.path = '../common/?.lua;' .. package.path
require"mk-cases"


local max_numargs = 0



function put_sig_rtype_first(sig)
  return sig:sub(sig:find(')')+1,-1)..sig:sub(1,sig:find(')')-1)
end


-- returns one case as str; accumulates unique idx => aggr-sig in aggrs
-- (sequentially) and aggr-sig => {body,name} in seen_aggrs (depth first for
-- nested aggrs, so sub-aggrs conveniently precede parents)
function mkcase(id, sig, aggrs, seen_aggrs)
  local sig = trim(sig)
  local fsig = put_sig_rtype_first(sig)
  local h = { "/* ",id,":",sig," */ " }
  local t = { "" }
  local pos = -1
  local n_nest = 0
  local aggr = { }
  local aggr_sig = { }
  aggr[0] = { }     -- non-sequential [0] collects all non-aggr types (not used, though)
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
      -- register (sub)aggrs on closing char
      if ch == '}' or ch == '>' then
        -- only add unseen aggregates, key is aggr sig, val is body and name
        if seen_aggrs[aggr_sig[n_nest]] == nil then
          aggrs[#aggrs+1] = aggr_sig[n_nest]
          if ch == '}' then ch = 'struct ' else ch = 'union ' end
		  ch = ch..'A'..#aggrs
          seen_aggrs[aggr_sig[n_nest]] = { aggr[n_nest], ch }
        end
        ch = seen_aggrs[aggr_sig[n_nest]][2]

        n_nest = n_nest - 1
        aggr_sig[n_nest] = aggr_sig[n_nest]..aggr_sig[n_nest+1]
      end

      -- add member type and var name to aggr
      if ch ~= '{' and ch ~= '}' and ch ~= '<' and ch ~= '>' then
        aggr[n_nest][#aggr[n_nest]+1] = ch
        aggr[n_nest][#aggr[n_nest]+1] = 'm'..(#aggr[n_nest] >> 1)
      end

      -- no nesting (= actual func args), generate case code
      if n_nest == 0 then
        h[#h+1] = ch
        -- aggregate types have more than one char
        if #h[#h] > 1 then
          if aggrcpsimple then
            t[#t+1] = '*('..h[#h]..'*)V_a['..pos.."]="..name..";"
          else
            t[#t+1] = 'f_cp'..h[#h]:match('A.*')..'(V_a['..pos.."],&"..name..");"
          end
          if aggrmutabletest then
            t[#t] = t[#t]..'memset(&'..name..',0,sizeof('..name..'));'
          end
        else
          t[#t+1] = "V_"..ch.."["..pos.."]="..name..";"
        end

        -- is return type or func arg?
        if pos == -1 then
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
  max_numargs = math.max(max_numargs, pos)
  h[#h] = "){"
  if #h[6] == 1 then
    t[#t+1] = "ret_"..h[6].."("..pos..")}\n"
  else
    t[#t+1] = "ret_a("..pos..","..h[6]..")}\n"
  end
  return table.concat(h,"")..table.concat(t,"")
end


function mkaggrdefs(aggrs, seen_aggrs)
  local agg_defs  = { }
  local agg_sizes = { }
  local agg_sigs  = { }
  local agg_names = { }

  for a = 1, #aggrs do
    local k = aggrs[a]
    local v = seen_aggrs[k]
    local am = v[1]            -- aggregate members
    local at = v[2]            -- aggregate type
    local an = at:match('A.*') -- aggregate name (w/o struct or union)

    -- aggregate def
    aggr_def = '/* '..k..' */\n'
    if aggrpacking ~= 0 then
      local pack = aggrpacking
      if pack < 0 then
        pack = math.floor(math.pow(2,math.floor(math.log(math.random(math.abs(pack)),2))))
      end
      aggr_def = aggr_def..'#pragma pack(push,'..pack..')\n'
    end

    aggr_def = aggr_def..at..' { '
    for i = 1, #am, 2 do
      aggr_def = aggr_def..am[i]..' '..am[i+1]..'; '
    end
    aggr_def = aggr_def..'};\n'

    if aggrpacking ~= 0 then
      aggr_def = aggr_def..'#pragma pack(pop)\n'
    end

    -- aggregate cp and cmp funcs
    s = {
      'void f_cp'..an..'('..at..' *x, const '..at..' *y) { ',
      'int f_cmp'..an..'(const '..at..' *x, const '..at..' *y) { return '
    }
    o = { '=', '==', 'f_cp', 'f_cmp', '; ', ' && ', '', '1' }
    for t = 1, 2 do
      if t ~= 1 or aggrcpsimple == false then
        aggr_def = aggr_def..s[t]
        local b = {}
        for i = 1, #am, 2 do
          local mn, mc = split_array_decl(am[i+1]) -- aggr member name and (array) count
          local fmt = ''
          if mc ~= nil then -- need array suffixes?
            fmt = '[%d]'
          else
            mc = 1
          end
       
          for j = 1, mc do
            name = mn..fmt:format(j-1)
			amn = am[i]:match('A.*')
            if amn then -- is aggr?
              b[#b+1] = o[t+2]..amn..'(&x->'..name..', &y->'..name..')'
            else
              b[#b+1] = 'x->'..name..' '..o[t]..' y->'..name
            end
          end
        end
        if #b == 0 then  -- to handle empty aggregates
          b[1] = o[t+6]
        end
        aggr_def = aggr_def..table.concat(b,o[t+4])..'; };\n'
      end
    end

    -- write convenient dcNewAggr() helper/wrapper funcs
    aggr_def = aggr_def..'DCaggr* f_touchdcst'..an..'() {\n\tstatic DCaggr* a = NULL;\n\tif(!a) {\n\t\ta = dcNewAggr('..(#am>>1)..', sizeof('..at..'));\n\t\t'
    for i = 1, #am, 2 do
      local mn, mc = split_array_decl(am[i+1])
      if mc == nil then
        mc = 1
      end
      amn = am[i]:match('A.*')
      if amn then -- is aggr?
        --aggr_def = aggr_def..'dcAggrField(at, DC_SIGCHAR_AGGREGATE, offsetof('..at..', '..mn..'), '..mc..', f_touchdcst'..amn..'());\n\t\t'
        aggr_def = aggr_def.."AFa("..at..','..mn..','..mc..','..amn..')\n\t\t'
      else
        --aggr_def = aggr_def.."dcAggrField(at, '"..am[i].."', offsetof("..at..', '..mn..'), '..mc..');\n\t\t'
        aggr_def = aggr_def.."AF('"..am[i].."',"..at..','..mn..','..mc..')\n\t\t'
      end
    end

    agg_defs [#agg_defs  + 1] = aggr_def..'dcCloseAggr(a);\n\t}\n\treturn a;\n};'
    agg_sizes[#agg_sizes + 1] = 'sizeof('..at..')'
    agg_sigs [#agg_sigs  + 1] = k
    agg_names[#agg_names + 1] = an
  end

  return agg_defs, agg_sizes, agg_sigs, agg_names
end


function mkall()
  local lineno = 0
  local sigtab = { }
  local cases = ''
  local aggrs = { }
  local seen_aggrs = { }


  for line in io.lines() do
    local sig = trim(line)
    cases = cases..mkcase(lineno, sig, aggrs, seen_aggrs)
    sigtab[#sigtab+1] = sig
    lineno = lineno + 1
  end

  local agg_defs, agg_sizes, agg_sigs, agg_names = mkaggrdefs(aggrs, seen_aggrs)

  -- make table.concat work
  if #agg_names > 0 then
    table.insert(agg_names, 1, '')
  end

  io.write(table.concat(agg_defs,'\n')..'\n')
  io.write(cases)
  io.write(mkfuntab(lineno, 'f', 'funptr', 'G_funtab', true))
  io.write(mksigtab(sigtab, '', 'G_sigtab'))
  io.write('const char* G_agg_sigs[]  = {\n\t"'..table.concat(agg_sigs, '",\n\t"')..'"\n};\n')
  io.write('int G_agg_sizes[] = {\n\t'..table.concat(agg_sizes, ',\n\t')..'\n};\n')
  io.write('funptr G_agg_touchdcstfuncs[] = {'..string.sub(table.concat(agg_names, ',\n\t(funptr)&f_touchdcst'),2)..'\n};\n')
  io.write('funptr G_agg_cmpfuncs[] = {'..string.sub(table.concat(agg_names, ',\n\t(funptr)&f_cmp'),2)..'\n};\n')
  io.write("int G_maxargs = "..max_numargs..";\n")
end

math.randomseed(seed)
mkall()

