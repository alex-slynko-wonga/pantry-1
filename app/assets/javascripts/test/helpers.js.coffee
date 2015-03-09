oldTimeout = window.setTimeout
window.timeoutStacks = []
window.setTimeout = (func, time) ->
  if time > 100
    window.timeoutStacks.push func
  else
    oldTimeout(func, time)

window.runTimeouts = ->
  arr = window.timeoutStacks
  window.timeoutStacks = []
  func() for func in arr when func?


