local nui = require("nui-components")
local util = require("jirac.util")
local ui_utils = require("jirac.ui.ui_utils")

local M = {}

M.ErrorPanel = {
    size = { width = 60, height = 20 }
}

function M.ErrorPanel:_create_error_rows()
    local rows = {}
    local i = 0
    for k, v in pairs(self.errors) do
        i = i + 1
        rows[#rows + 1] = nui.paragraph {
            lines = vim.tbl_map(function (txt)
                return nui.line(nui.text(txt))
            end, util.wrap_string(tostring(i) .. ". " .. k .. ": " .. v, ui_utils.get_content_width(self.size.width))),
            is_focusable = true
        }
    end
    return nui.rows({ flex = 0 }, unpack(rows))
end

function M.ErrorPanel:build_nui_panel()
    return nui.rows(
        nui.paragraph {
            lines = "ERROR",
            align = "center",
            is_focusable = false
        },
        self:_create_error_rows(),
        nui.gap { flex = 1 },
        nui.button {
            label = "Ok",
            autofocus = true,
            on_press = function () self.parent:pop() end
        }
    )
end

---@class ErrorPanelParams
---@field errors table<string, string> 

function M.ErrorPanel:new(o)
    o = o or {}
    self.__index = self
    setmetatable(o, self)
    return o
end

return M
