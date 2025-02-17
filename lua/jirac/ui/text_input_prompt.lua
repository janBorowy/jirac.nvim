local nui = require("nui-components")

local M = {}

M.TextInputPrompt = {
    button_label = "submit",
    initial_value = ""
}

function M.TextInputPrompt:build_nui_panel()
    return nui.rows(
        nui.text_input {
            id = "input-field",
            flex = 1,
            border_label = self.border_label,
            autofocus = true,
            value = self.initial_value
        },
        nui.button {
            label = self.button_label,
            align = "center",
            on_press = function()
                local ref = self.parent.renderer:get_component_by_id("input-field")
                self.callback(ref and ref:get_current_value())
            end,
            global_press_key = "<CR>"
        }
    )
end

---@class TextInputPrompt : Panel
---@field border_label string
---@field button_label string?
---@field initial_value string
---@field callback function

---@param o TextInputPrompt
function M.TextInputPrompt:new(o)
    o = o or {}
    self.__index = self
    setmetatable(o, self)
    return o
end

return M

