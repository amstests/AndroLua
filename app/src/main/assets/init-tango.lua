local Thread = luajava.bindClass 'java.lang.Thread'

local cim = require 'call_in_mainthread'
local copas = require 'copas'
local tango_s_copas = require 'tango.server.copas_socket'
local tango_server,rl = tango_s_copas.new
  { 
    port=12345,
    pcall = function(f, arg1, ...)
      local res
      if type(arg1) == 'userdata' then
        -- luajava call
        -- WARNING: this breaks tango access control
        res = {cim.mainthread_call(f,arg1,...)}
      else
        res = {copcall(f,arg1,...)}
      end
      return unpack(res)
    end
  }

copas.addserver(tango_server, rl)
print "entering loop"
-- function copas.loop(timeout)
  copas.running = true
  while not copas.finished() do
    cim.mainthread_process()
    if copas.step() then
      -- print "+"
    else
      Thread:sleep(500)
    end
  end
  copas.running = false
-- end

print 'tango RPC quit'
