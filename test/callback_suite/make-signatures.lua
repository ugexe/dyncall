require "config"
require "math"
require "string"


function randomSignatures()
  package.path = '../common/?.lua;' .. package.path
  require"rand-sig"
end


function orderedSignature(x)
  local signature = ""
  local typeindex
  local nargtypes = string.len(types)
  while true do
    if x < nargtypes then break end
    typeindex = 1 + math.mod(x, nargtypes)
    signature = signature .. string.sub(types, typeindex, typeindex)
    x = math.floor( x / nargtypes )
  end
  typeindex = 1 + x
  signature = signature .. ")" .. string.sub(types, typeindex, typeindex)
  return signature
end


function orderedSignatures()
  local i 
  for i = 1, ncases do
    io.write( orderedSignature(offset+i*step) .. "\n" )
  end
end


function designedSignatures()
 for line in io.lines(designfile) do
   io.write( line )
   io.write( "\n" )
 end
end


if mode == "random" then
  randomSignatures()
elseif mode == "ordered" then
  orderedSignatures()
elseif mode == "designed" then
  designedSignatures()
else
  error("'mode' must be 'random', 'ordered' or 'designed'")
end

io.flush()

