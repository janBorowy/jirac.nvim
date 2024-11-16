local nui = require("nui-components")
local project_service = require("jirac.jira_project_service")
local util = require("jirac.util")
local ProjectPanel = require("jirac.ui.project_panel").ProjectPanel

local M = {}
local maxProjectSearchResults = 10

M.ProjectSearchPanel = {
    size = { width = 60, height = 20 },
    maxResults = 10,
    current_page = 1
}

function M.put_project_search_panel(panel, query_string)
    panel.parent:pop()
    panel.parent:push(M.ProjectSearchPanel:new {
        renderer = panel.renderer,
        parent = panel.parent,
        query_string = query_string,
        apiResponse = project_service.search_projects({
            query = query_string,
            maxResults = maxProjectSearchResults,
            startAt = panel.current_page and (panel.current_page - 1) * maxProjectSearchResults
        }),
        current_page = panel.current_page or 1
    })
end

function M.ProjectSearchPanel:build_search_result_rows()
    local rows = {}
    for i, proj in ipairs(self.apiResponse.values) do
        rows[#rows + 1] = nui.button {
            lines = vim.tbl_map( function (txt)
                return nui.line(nui.text(txt))
            end, util.wrap_string(proj.key .. " " .. proj.name, self.size.width)),
            autofocus = i == 1,
            align = "center",
            on_press = function ()
                self.parent:push(ProjectPanel:new({
                    renderer = self.renderer,
                    parent = self.parent,
                    project = proj
                }))
            end
        }
    end
    return nui.rows({flex = 0}, unpack(rows))
end

function M.ProjectSearchPanel:_get_total_pages_count()
    return math.ceil(self.apiResponse.total / maxProjectSearchResults)
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
                autofocus = #self.apiResponse.values == 0,
                value = self.query_string or ""
            },
            nui.button {
                label = "search",
                align = "center",
                on_press = function ()
                    local v = self.renderer:get_component_by_id("search-phrase-field").value
                    M.put_project_search_panel(self, v)
                end,
                padding = {
                    top = 1
                }
            }
        ),
        self:build_search_result_rows(),
        nui.gap { flex = 1 },
        nui.columns (
            { flex = 0 },
            nui.button {
                id = "prev-page-button",
                flex = 1,
                label = "<",
                align = "right",
                on_press = function ()
                    if self.current_page ~= 1 then
                        self.current_page = self.current_page - 1
                        local v = self.renderer:get_component_by_id("search-phrase-field").value
                        M.put_project_search_panel(self, v)
                    end
                end
            },
            nui.paragraph {
                flex = 1,
                lines = tostring(self.current_page) .. " / " .. self:_get_total_pages_count(),
                is_focusable = false,
                align = "center"
            },
            nui.button {
                id = "next-page-button",
                flex = 1,
                label = ">",
                on_press = function ()
                    if self.current_page < self:_get_total_pages_count() then
                        self.current_page = self.current_page + 1
                        local v = self.renderer:get_component_by_id("search-phrase-field").value
                        M.put_project_search_panel(self, v)
                        -- TODO: focus next page button
                        -- self.renderer:get_component_by_id("next-page-button"):focus()
                    end
                end
            }
        )
    )
end

---@class ProjectSearchPanel : Panel
---@field apiResponse SearchProjectsDto

function M.ProjectSearchPanel:new(o)
    o = o or {}
    self.__index = self
    setmetatable(o, self)
    return o
end

return M

