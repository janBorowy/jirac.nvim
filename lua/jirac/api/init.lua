local M = {}

---@alias JiracWindowSignal
---| "issue_created"
---| "issue_updated"

---@param signal JiracWindowSignal
function M.send_signal(signal)
    local window = require("jirac.storage").get_window()
    if window then
        window:handle_signal(signal)
    end
end

return M
