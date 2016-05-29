-- System Enhancing Functions
-- This file contains general use functions not directly related to Crimson Scripter

-- String trimmer
function trim(s)
  if (s ~= nil and s ~= "") then
	return (s:gsub("^%s*(.-)%s*$", "%1"))
  else return "" end
end

-- Round numbers
function round(x)
  return x>=0 and math.floor(x+0.5) or math.ceil(x-0.5)
end

-- PHP-like explode
function explode(div,str)
	pos = 0
	arr = {}
	for st,sp in function() return string.find(str,div,pos,true) end do
		table.insert(arr,string.sub(str,pos,st-1))
		pos = sp + 1
	end
	table.insert(arr,string.sub(str,pos))
	return arr
end