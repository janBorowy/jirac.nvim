local nui = require("nui-components")

local M = {}

---@param h_pad integer
---@param v_pad integer
function M.pad_component(component, v_pad, h_pad)
    return nui.columns(
        nui.gap(h_pad),
        nui.rows(
            nui.gap(v_pad),
            component,
            nui.gap(v_pad)
        ),
        nui.gap(h_pad)
    )
end

return M
