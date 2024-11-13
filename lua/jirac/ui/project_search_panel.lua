local nui = require("nui-components")
local project_service = require("jirac.jira_project_service")
local util = require("jirac.util")

local M = {}

M.ProjectSearchPanel = {
    size = { width = 90, height = 30 }
}

function M.ProjectSearchPanel:build_search_result_rows()
    local rows = {}
    for i, proj in ipairs(self.apiResponse.values) do
        rows[#rows + 1] = nui.button {
            lines = vim.tbl_map( function (txt)
                return nui.line(nui.text(txt))
            end, util.wrap_string(proj.key .. " " .. proj.name, self.size.width)),
            autofocus = i == 1
        }
    end
    return nui.rows({ flex = 0 }, unpack(rows))
end

function M.ProjectSearchPanel:build_nui_panel()
    return nui.rows(
        nui.gap(1),
        nui.paragraph {
            lines = "Project Search",
            is_focusable = false
        },
        nui.gap(1),
        self:build_search_result_rows()
    )
end

---@class ProjectSearchPanel
---@field apiResponse SearchProjectsDto

function M.ProjectSearchPanel:new(o)
    o = o or {}
    self.__index = self
    setmetatable(o, self)
    self.apiResponse = o.apiResponse
    return o
end

return M

