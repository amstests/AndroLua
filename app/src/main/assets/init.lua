-- AndroLua init
--  you can change and place to /sdcard/Android/data/com.github.ildar.AndroidLuaSDK/files

-- replace print
local Log = luajava.bindClass 'android.util.Log'
local print_spooler_fifo = require("fifo") () ; print_spooler_fifo:setempty(function() return nil; end)
function print_spooler()
  assert( not coroutine.running(), "print_spooler() cannot be used from a coroutine" )
  local msg_tab = print_spooler_fifo:pop()
  while msg_tab do
    Log:v("lua-print", table.concat(msg_tab,'\t'))
    msg_tab = print_spooler_fifo:pop()
  end
end
function print(...)
  local args = {...}
  if tostring(args[1]):find("No such method") then
    print_spooler_fifo:push( { debug.traceback() } )
  end
  for i=1,#args do
    args[i] = tostring(args[i])
  end
  print_spooler_fifo:push( args )
  if not coroutine.running() then
    print_spooler()
  end
end

print "AndroidLuaSDK init finished"
