local nui = require("nui-components")
local get_field_label = require("jirac.ui.ui_utils").get_field_label

local M = {}

---@class ValueFieldParams
---@field button_id string?
---@field mapping_key string?
---@field label string
---@field value string?
---@field press_callback function?
---@field is_editable boolean?

---@param o ValueFieldParams
function M.build_value_field(o)
    return nui.rows(
        { flex = 0 },
        nui.paragraph {
            lines = get_field_label(o.label, o.mapping_key),
            padding = {
                left = 1
            },
            is_focusable = false
        },
        nui.button {
            lines = o.value or "Unspecified",
            padding = {
                left = 3,
                bottom = 1
            },
            on_press = o.press_callback or function () end,
            is_focusable = o.is_editable == nil or o.is_editable,
            id = o.button_id
        })
end

return M

