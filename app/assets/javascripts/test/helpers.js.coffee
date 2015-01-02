oldTimeout = window.setTimeout
window.setTimeout = (func, time) -> oldTimeout(func, Math.min(time, 100))

