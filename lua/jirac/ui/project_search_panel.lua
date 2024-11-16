local nui = require("nui-components")
local project_service = require("jirac.jira_project_service")
local util = require("jirac.util")
local PromptPanel = require("jirac.ui.prompt_panel").PromptPanel

local M = {}

M.ProjectSearchPanel = {
    size = { width = 60, height = 20 }
}

function M.ProjectSearchPanel:build_search_result_rows()
    local rows = {}
    for i, proj in ipairs(self.apiResponse.values) do
        rows[#rows + 1] = nui.button {
            lines = vim.tbl_map( function (txt)
                return nui.line(nui.text(txt))
            end, util.wrap_string(proj.key .. " " .. proj.name, self.size.width)),
            autofocus = i == 1,
            align = "center"
        }
    end
    return nui.rows({flex = 1}, unpack(rows))
end

function M.ProjectSearchPanel:init()
    self.prev_focus_down = self.renderer._private.keymap.focus_next
    self.prev_focus_up = self.renderer._private.keymap.focus_prev

    self.renderer._private.keymap.focus_prev = { "<S-Tab>", "k" }
    self.renderer._private.keymap.focus_next = { "<Tab>", "j" }
end

function M.ProjectSearchPanel:build_nui_panel()
    return nui.rows(
        nui.gap(1),
        nui.paragraph {
            lines = "Project Search",
            is_focusable = false,
            align = "center"
        },
        nui.columns (
            {flex = 0},
            nui.text_input {
                id = "search-phrase-field",
                flex = 1,
                border_label = "Search phrase",
                max_lines = 1,
                autofocus = #self.apiResponse.values == 0
            },
            nui.button {
                label = "search",
                align = "center",
                on_press = function ()
                end,
                padding = {
                    top = 1
                }
            }
        ),
        self:build_search_result_rows()
    )
end

function M.ProjectSearchPanel:deinit()
    self.renderer._private.keymap.focus_down = self.prev_focus_down
    self.renderer._private.keymap.focus_up = self.prev_focus_up
end

---@class ProjectSearchPanel : Panel
---@field apiResponse SearchProjectsDto

function M.ProjectSearchPanel:new(o)
    o = o or {}
    self.__index = self
    setmetatable(o, self)
    o.apiResponse = o.apiResponse
    return o
end

return M

