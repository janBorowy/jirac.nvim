local nui = require("nui-components")
local PromptPanel = require("jirac.ui.prompt_panel").PromptPanel
local ProjectSubmitPanel = require("jirac.ui.project_submit_panel").ProjectSubmitPanel
local ProjectSearchPanel = require("jirac.ui.project_search_panel").ProjectSearchPanel
local project_service = require("jirac.jira_project_service")

local M = {}

M.NavigationPanel = {
    size = { width = 30, height = 10}
}

function M.NavigationPanel:put_project_search_panel(query_string)
    self.parent:pop()
    self.parent:push(ProjectSearchPanel:new {
        renderer = self.renderer,
        parent = self.parent,
        apiResponse = project_service.search_projects({ query = query_string })
    })
end

function M.NavigationPanel:handle_search_project()
    self.parent:push(PromptPanel:new {
        renderer = self.renderer,
        parent = self.parent,
        title = "Search project",
        form_id = "search-form-id",
        border_label = "Search phrase",
        placeholder = "Enter search phrase...",
        button_label = "search",
        on_submit = function (v) self:put_project_search_panel(v) end
    })
end

function M.NavigationPanel:handle_create_project()
    self.parent:push(ProjectSubmitPanel:new {
        renderer = self.renderer,
        parent = self.parent
    })
end

function M.NavigationPanel:build_nui_panel()
    return nui.rows(
        nui.paragraph {
            lines = "JiraC Menu",
            align = "center",
            is_focusable = false
        },
        nui.gap(1),
        nui.button {
            label = "Search for project",
            align = "center",
            on_press = function () self:handle_search_project() end,
            autofocus = true
        },
        nui.gap(1),
        nui.button {
            label = "Create project",
            align = "center",
            on_press = function () self:handle_create_project() end
        }
    )
end

---@class NavigationPanel : Panel

---@param o NavigationPanel
function M.NavigationPanel:new(o)
    o = o or {}
    self.__index = self
    setmetatable(o, self)
    return o
end

return M

