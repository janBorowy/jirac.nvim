local nui = require("nui-components")

local M = {}

M.ErrorPanel = {}

function M.ErrorPanel:_create_error_rows()
    local rows = {}
    for i, v in ipairs(self.errors) do
        rows[#rows + 1] = nui.paragraph {
            lines = tostring(i) .. ". " .. v.field_name .. ": " .. v.message,
            is_focusable = true
    }
    end
    return nui.rows(unpack(rows))
end

function M.ErrorPanel:_create_error_panel()
    return nui.rows(
        nui.paragraph {
            lines = "ERROR",
            align = "center",
            is_focusable = false
        },
        self:_create_error_rows(),
        nui.button {
            label = "Ok",
            autofocus = true
        }
    )
end

---@class ErrorPanelParams
---@field errors Array<FieldError> 

function M.ErrorPanel:new(o)
    o = o or {}
    self.__index = self
    setmetatable(o, self)
    self.renderer = o.renderer
    self.parent = o.parent
    self.errors = o.errors
    self.panel = self:_create_error_panel()
    return o
end



return M
