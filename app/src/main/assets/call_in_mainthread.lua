-- Helper module for changing call context from a coroutine to the main thread

local mainthread_stash = {}
local yield

local function mainthread_call(f, ...)
  yield = yield or (package.loaded["copas"] and package.loaded["copas"].sleep) or coroutine.yield
  local thread = coroutine.running()
  assert(thread, "cannot call from the main thread")
  mainthread_stash[thread] = mainthread_stash[thread] or {}
  mainthread_stash[thread].status = nil
  mainthread_stash[thread].f = f
  mainthread_stash[thread].args = {...}
  while mainthread_stash[thread].status == nil do
    yield()
  end
  return mainthread_stash[thread].status, mainthread_stash[thread].res
end

local function mainthread_process()
  local co, main = coroutine.running()
  assert( main or co == nil, "cannot call from a coroutine")
  for thread,_ in pairs(mainthread_stash) do
    if mainthread_stash[thread].status == nil then
      mainthread_stash[thread].status, mainthread_stash[thread].res = 
        pcall( mainthread_stash[thread].f, unpack(mainthread_stash[thread].args) )
    end
  end
end

return {
  mainthread_call = mainthread_call,
  mainthread_process = mainthread_process,
}
