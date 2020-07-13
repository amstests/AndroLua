local client_backend = "socket"

local tango = require 'tango'
local config = { address = os.getenv("TANGO_SERVER") or "localhost" }
local connect = tango.client[client_backend].connect
local client

if config.address == "localhost" then
  os.execute("adb forward tcp:12345 tcp:12345")
end

describe("#BasicTests : luajava", function()
  setup(function()
      client = connect(config)
    end)

  it("can bind classes and use Java runtime functions",
    function()
      local System = client.luajava.bindClass 'java.lang.System'
      local time = System:currentTimeMillis()
      assert.is_equal( "number", type(time) )
      assert.truthy( time>1593542269845 )
    end)

  it("can bind and use basic Java classes",
    function()
      local Math = client.luajava.bindClass 'java.lang.Math'
      local val = Math:sin(1.2)
      assert.is_equal( "number", type(val) )
      assert.truthy( val>0.932 )
      assert.truthy( val<0.933 )
    end)

  it("can instantiate an object of a class",
    function()
      local ArrayList = client.luajava.bindClass 'java.util.ArrayList'
      local a = client.luajava.new(ArrayList)
      a:add(10)
      a:add('one')
      assert.is_equal( 2, a:size() )
      assert.is_equal( 10, a:get(0) )
      assert.is_equal( "one", a:get(1) )
    end)

  it("can handle special case with Java string",
    function()
      local String = client.luajava.bindClass 'java.lang.String'
      local s = client.luajava.new(String,'hello dolly')
      assert.is_equal( 'hello dolly', s:toString() )
      assert.truthy ( s:startsWith 'hello' )
    end)
  
  it("can autobind with `luajava.package`",
    function()
      local L = client.luajava.package 'java.lang'
      assert.is_equal( 10, type(L.String) )
      assert.is_equal( 10, L.String )
      assert.is_equal( 10, type(L.Boolean) )
      assert.is_equal( 10, L.Boolean )
    end)

end)

describe("#BasicTests : `android` module", function()
  setup(function()
      client = connect(config)
    end)

  it("can bind classes through `android.import`s `bind`",
    function()
      client.require 'android.import'
      local HashMap = client.bind 'java.util.HashMap'
      local h = HashMap()
      h:put('hello',10)
      h:put(42,'bonzo')
      assert.is_equal( "bonzo", h:get(42) )
      assert.is_equal( 10, h:get('hello') )
    end)

  it("can generate Java arrays",
    function()
      client.require 'android.import'
      local String = client.bind 'java.lang.String'
      local ss = String{'one','two','three'}
      assert.is_equal( 10, type(ss) )
      local Integer = client.bind 'java.lang.Integer'
      local ii = Integer{10,20,30}
      assert.is_equal( 10, type(ii) )
    end)

end)
