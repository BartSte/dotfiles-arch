-- Lazy can report task failures without setting Neovim's exit status.
local ok, err = xpcall(function()
    require("lazy").update({ wait = true, show = false })
    local failures = {}
    for name, plugin in pairs(require("lazy.core.config").plugins) do
        for _, task in ipairs(plugin._.tasks or {}) do
            if task:has_errors() then failures[#failures + 1] = name end
        end
    end
    assert(#failures == 0, "Plugin updates failed: " .. table.concat(failures, ", "))
end, debug.traceback)
if not ok then
    io.stderr:write(tostring(err) .. "\n")
    vim.cmd("cquit 1")
else
    vim.cmd("qa!")
end
