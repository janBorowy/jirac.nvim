local nui = require("nui-components")
local util = require("jirac.util")
local ui_utils = require("jirac.ui.ui_utils")

local M = {}

M.RequestErrorPanel = {
    size = { width = 60, height = 20 }
}

function M.RequestErrorPanel:build_nui_panel()
    return nui.rows(
        nui.paragraph {
            lines = "REQUEST ERROR " .. self.error.status,
            align = "center"
        },
        nui.gap(1),
        nui.paragraph {
            lines = vim.iter(vim.tbl_map(function (msg)
                return ui_utils.create_nui_lines(msg,
                ui_utils.get_content_width(self.size.width))
            end,
            self.error.errorMessages)):flatten():totable()
        },
        nui.gap { flex = 1 },
        nui.button {
            label = "Ok",
            autofocus = true,
            on_press = function () self.parent:pop() end
        }
    )
end

---@class RequestErrorPanel
---@field error Error

---@param o RequestErrorPanel
function M.RequestErrorPanel:new(o)
    o = o or {}
    self.__index = self
    setmetatable(o, self)
    return o
end

return M
