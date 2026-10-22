-- The addon loads, declares its defaults, and publishes its namespace.
local Mock = dofile("tests/wow_mock.lua")

Mock.Reset()
local harness = Mock.Harness()
local ns = harness.ns

assert(type(ns) == "table", "the addon did not publish its namespace")
assert(type(ns.DEFAULTS) == "table", "ns.DEFAULTS must be declared (WFA-14)")
assert(type(ns.DEFAULTS.window) == "table", "ns.DEFAULTS.window is missing")

print("core_spec: ok")
