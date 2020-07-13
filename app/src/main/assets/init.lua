-- AndroLua init
--  you can change and place to /sdcard/Android/data/com.github.ildar.AndroidLuaSDK/files

-- replace print
local Log = luajava.bindClass 'android.util.Log'
local cim = require 'call_in_mainthread'
function print(...)
  local args = {...}
  for i=1,#args do
    args[i] = tostring(args[i])
  end
  if coroutine.running() then
    cim.mainthread_call(Log.v, Log, "lua-print-co", table.concat(args,'\t'))
  else
    cim.mainthread_process()
    Log:v("lua-print", table.concat(args,'\t'))
  end
--[[  if tostring(args[1]):find("No such method") then
    print( { debug.traceback() } )
  end
]]
end

print "AndroidLuaSDK init finished"

-- uncomment to have debug session
-- require("mobdebug").loop()

-- uncomment to have Tango RPC session
-- require 'init-tango'
