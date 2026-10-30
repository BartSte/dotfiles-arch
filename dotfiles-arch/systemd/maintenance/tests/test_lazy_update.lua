-- Run with nvim --headless -u NONE -l this-file.lua.
local source = debug.getinfo(1, "S").source:sub(2)
local directory = vim.fs.dirname(vim.fs.dirname(source))
local real_cmd = vim.cmd
local exit_command
vim.cmd = function(command) exit_command = command end
package.loaded.lazy = { update = function(options) assert(options.wait and not options.show) end }
local config = { plugins = { example = { _ = { tasks = { { has_errors = function() return false end } } } } } }
package.loaded["lazy.core.config"] = config
dofile(directory .. "/libexec/lazy-update.lua")
assert(exit_command == "qa!", "Successful updates did not exit cleanly")
config.plugins.example._.tasks[1].has_errors = function() return true end
dofile(directory .. "/libexec/lazy-update.lua")
assert(exit_command == "cquit 1", "Lazy task failures did not fail the service")
package.loaded.lazy.update = function() error("Connection failed") end
dofile(directory .. "/libexec/lazy-update.lua")
assert(exit_command == "cquit 1", "Lazy exceptions did not fail the service")
vim.cmd = real_cmd
print("PASS: Lazy success, task failures, and exceptions")
