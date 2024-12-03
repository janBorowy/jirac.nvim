local nui = require("nui-components")
local ui_utils = require("jirac.ui.ui_utils")
local ui_defaults = require("jirac.ui.ui_defaults")

local M = {}

M.ConfirmationPanel = {
    size = {
        width = 50,
        height = 10,
    }
}

function M.ConfirmationPanel:build_nui_panel()
    return nui.rows(
        nui.paragraph {
            lines = self.title_paragraph,
            align = "center",
            is_focusable = false
        },
        nui.gap { flex = 1 },
        nui.paragraph {
            flex = 1,
            lines = ui_utils.create_nui_lines(self.message, self.size.width - 2 * ui_defaults.PADDING.horizontal),
            align = "center"
        },
        nui.columns (
            nui.gap { flex = 1 },
            nui.button {
                label = self.yes_label,
                autofocus = true,
                on_press = function ()
                    self.parent:pop()
                    self.callback()
                end
            },
            nui.gap(4),
            nui.button {
                label = self.no_label,
                on_press = function ()
                    self.parent:pop()
                end
            },
            nui.gap { flex = 1 }
        ),
        nui.gap(1)
    )
end

---@class ConfirmationPanelParams : Panel
---@field title_paragraph string
---@field message string
---@field yes_label string?
---@field no_label string?
---@field callback function

---@param o ConfirmationPanelParams
function M.ConfirmationPanel:new(o)
    o = o or {}
    self.__index = self
    setmetatable(o, self)
    return o
end

return M
