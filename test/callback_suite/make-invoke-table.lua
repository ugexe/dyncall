require "config"

local i
for i = 1, ncases do
  line = "&f" .. i .. ",\n"
  io.write(line)
end

