
-- replace print
local Log = luajava.bindClass 'android.util.Log'
function print(...)
  local args = {...}
  Log:d("lua-print", args[1])
end
