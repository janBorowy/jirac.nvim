local nui = require("nui-components")
local util = require("jirac.util")

local M = {}

---@type ObjectSearchPrompt
M.ObjectSearchPrompt = {
    size = {
        width = 60,
        height = 20
    },
    disable_search = false
}

function M.ObjectSearchPrompt:_get_search_phrase_value()
    local ref = self.parent.renderer:get_component_by_id("search-phrase-field")
    return ref and ref:get_current_value()
end

function M.ObjectSearchPrompt:_handle_search()
    local query = self:_get_search_phrase_value()
    self.initial_query = query
    self.parent:update_nui()
end

function M.ObjectSearchPrompt:_build_selection_rows()
    local rows = {}
    for i, v in ipairs(self.values) do
        rows[#rows + 1] = nui.button {
            -- lines = vim.tbl_map(function (txt)
            --     return nui.line(nui.text(txt))
            -- end, util.wrap_string(self.label_factory(v), self.size.width)),
            lines = self.label_factory(v),
            autofocus = i == 1,
            align = "center",
            on_press = function () self.callback(v) end
        }
    end
    return nui.rows({flex = 0}, unpack(rows))
end

function M.ObjectSearchPrompt:build_nui_panel()

    if self.disable_search then
        return nui.rows(
        nui.paragraph {
            lines = self.header,
            padding = {
                top = 1,
                bottom = 1
            },
            align = "center",
            is_focusable = false
        },
        self:_build_selection_rows(),
        nui.gap { flex = 1 }
        )
    end

    return nui.rows(
    nui.paragraph {
        lines = self.header,
        padding = {
            top = 1
        },
        align = "center",
        is_focusable = false
    },
    nui.columns (
    { flex = 0 },
    nui.text_input {
        id = "search-phrase-field",
        flex = 1,
        border_label = "Search phrase",
        max_lines = 1,
        autofocus = #self.values == 0,
        value = self.initial_query or ""
    },
    nui.button {
        label = "search",
        align = "center",
        on_press = function () self:_handle_search() end,
        padding = { top = 1 }
    }
    ),
    self:_build_selection_rows(),
    nui.gap { flex = 1 }
    )
end

function M.ObjectSearchPrompt:fetch_resources(callback)
    self.search_callback(self.initial_query,
    function(values)
        self.values = values
        callback()
    end)
end

---@class ObjectSearchPrompt : Panel
---@field values Array
---@field label_factory function
---@field header string
---@field initial_query string?
---@field callback function
---@field search_callback function
---@field disable_search boolean?
---@field _build_selection_rows function
---@field _handle_search function
---@field _get_search_phrase_value function

function M.ObjectSearchPrompt:new(o)
    o = o or {}
    self.__index = self
    setmetatable(o, self)
    return o
end

return M
