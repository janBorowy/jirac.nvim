local nui = require("nui-components")
local issue_service = require("jirac.jira_issue_service")

local M = {}
local maxIssueSearchResults = 25

M.ProjectPanel = {
    current_page = 1
}

function M.ProjectPanel:_get_total_pages_count()
    return math.ceil(#self.api_response.issues / maxIssueSearchResults)
end

function M.ProjectPanel:init()
    self.parent:add_mappings ({
        {
            key = "h",
            handler = function ()
                self:_handle_previous_page()
            end
        },
        {
            key = "l",
            handler = function ()
                self:_handle_next_page()
            end
        }
    })
end

function M.ProjectPanel:deinit()
    self.parent:clear_mappings ({"l", "h"})
end

function M.ProjectPanel:_handle_previous_page()
    if self.current_page ~= 1 then
        self.current_page = self.current_page - 1
        local v = self.renderer:get_component_by_id("search-phrase-field").value
        -- M.put_project_search_panel(self, v)
    end
end

function M.ProjectPanel:_handle_next_page()
    if self.current_page < self:_get_total_pages_count() then
        self.current_page = self.current_page + 1
        local v = self.renderer:get_component_by_id("search-phrase-field").value
        -- M.put_project_search_panel(self, v)
    end
end

function M.ProjectPanel:_build_issues_column()
    if #self.api_response.issues == 0 then
        return nui.paragraph {
            flex = 2,
            lines = "No issues",
            max_lines = 1,
            padding = {
                bottom = 1
            },
            align = "center"
        }
    end

    local key_column = {}
    local summary_column = {}
    local status_column = {}
    for _, k in pairs(self.api_response.issues) do
        key_column[#key_column + 1] = nui.button {
            label = k.key,
        }
        summary_column[#summary_column + 1] = nui.paragraph {
            lines = k.summary,
            max_lines = 1,
            is_focusable = false,
        }
        status_column[#status_column + 1] = nui.paragraph {
            lines = k.status_name,
            is_focusable = false
        }
    end
    return nui.rows({ flex = 2 },
    nui.paragraph {
        lines = "Issues",
        max_lines = 1,
        is_focusable = false,
        padding = {
            bottom = 1
        },
        align = "center"
    },
    nui.button {
        label = "Create issue",
        padding = {
            bottom = 1,
        },
        on_press = function () end,
        autofocus = true
    },
    nui.columns(
    { flex = 0 },
    nui.rows(unpack(key_column)),
    nui.rows(unpack(summary_column)),
    nui.rows(unpack(status_column)),
    nui.gap(1)
    ),
    nui.gap({flex = 1}),
    nui.columns (
    { flex = 0 },
    nui.paragraph {
        id = "prev-page-button",
        flex = 1,
        lines = "<",
        align = "right",
        is_focusable = false
    },
    nui.paragraph {
        flex = 1,
        lines = tostring(self.current_page) .. " / " .. self:_get_total_pages_count(),
        is_focusable = false,
        align = "center"
    },
    nui.paragraph {
        id = "next-page-button",
        flex = 1,
        lines = ">",
        is_focusable = false
    }))
end

function M.ProjectPanel:_create_field(name, value)
    return nui.rows({flex = 0},
    nui.paragraph {
        flex = 1,
        is_focusable = false,
        lines = name .. ":"
    },
    nui.paragraph {
        flex = 1,
        is_focusable = false,
        lines = value,
        padding = {
            left = 2,
            bottom = 1
        }
    }
    )
end

function M.ProjectPanel:_build_details_column()
    return nui.rows(unpack {
        self:_create_field("Key", self.project.key),
        self:_create_field("Name", self.project.name),
        nui.gap({flex = 1})
    })
end

function M.ProjectPanel:build_nui_panel()
    return nui.rows(
    nui.paragraph {
        lines = self.project.key .. " " .. self.project.name,
        align = "center",
        is_focusable = false
    },
    nui.gap(1),
    nui.columns( {flex = 1},
    self:_build_issues_column(),
    self:_build_details_column()
    )
    )
end

---@class ProjectPanel : Panel
---@field project Project

---@param o ProjectPanel
function M.ProjectPanel:new(o)
    o = o or {}
    self.__index = self
    setmetatable(o, self)
    self.api_response = issue_service.get_project_issues {
        maxResults = maxIssueSearchResults,
        projectKey = o.project.key
    }
    return o
end

return M
