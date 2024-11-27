local nui = require("nui-components")
local util = require("jirac.util")

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

function M.create_nui_lines(text, wrap_len)
    wrap_len = wrap_len or 9999999
    return vim.iter(vim.tbl_map(function (v)
        if v == "" then
            return {nui.line()}
        end
        return vim.tbl_map(function (txt)
            return nui.line(nui.text(txt))
        end, util.wrap_string(v, wrap_len))
    end, vim.split(text, "\n"))):flatten():totable()
end

return M
