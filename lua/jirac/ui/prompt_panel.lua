local nui = require("nui-components")
local utils = require("jirac.util")

local M = {}
M.PromptPanel = {
    size = { width = 45, height = 6 }
}

function M.PromptPanel:build_nui_panel()
    return nui.form({
        id = self.form_id,
        on_submit = self.on_submit
    },
    nui.gap(1),
    nui.paragraph {
        lines = self.title,
        align = "center",
        is_focusable = false
    },
    nui.gap(1),
    nui.columns(
        { flex = 0 },
        nui.text_input {
            id = "input-field",
            flex = 1,
            border_label = self.border_label,
            placeholder = self.placeholder,
            autofocus = true,
            max_lines = 1
        },
        nui.button{
            label = self.button_label,
            align = "center",
            on_press = function ()
                local ref = self.renderer:get_component_by_id("input-field")
                self.on_submit(ref:get_current_value())
            end,
            padding = {
                top = 1
            }
        })
    )
end

---@class PromptPanel : Panel
---@field renderer any
---@field title string
---@field form_id string
---@field border_label string
---@field placeholder string
---@field button_label string
---@field on_submit string

function M.PromptPanel:new(o)
    o = o or {}
    self.__index = self
    setmetatable(o, self)
    return o
end

return M
