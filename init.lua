require 'android.import'

function goapp(mod,arg)
    service:launchLuaActivity(activity,mod,arg)
end

function killapp()
-- until we get it right...
--~     if current_activity ~= activity then
--~         current_activity:finish()
--~     end
end

PK = luajava.package
W = PK 'android.widget'
G = PK 'android.graphics'
V = PK 'android.view'
A = PK 'android'
L = PK 'java.lang'
U = PK 'java.util'
IO = PK 'java.io'
N = PK 'java.net'

function load_utils ()
    utils = require 'android.utils'
end

async = require 'android.async'

function open ()
    c,e = utils.open_socket('146.64.150.144',2220)
    if not e then
        r = utils.buffered_reader(c:getInputStream())
        w = IO.PrintWriter(c:getOutputStream())
    else
        print('error',e)
    end
end

function cmd (msg)
    w:println(msg)
    w:flush()
    return r:readLine()
end

load_utils()
