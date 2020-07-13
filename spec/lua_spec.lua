local client_backend = "socket"

local tango = require 'tango'
local config = { address = os.getenv("TANGO_SERVER") or "localhost" }
local connect = tango.client[client_backend].connect
local client

if config.address == "localhost" then
  os.execute("adb forward tcp:12345 tcp:12345")
end

describe("#BasicTests for lua runtime", function()
  setup(function()
      client = connect(config)
    end)

  it("can bind and use basic std Lua functions",
    function()
      local rev = client.string.reverse("abcDEF")
      assert.is_equal( "FEDcba", rev )
    end)

end)
