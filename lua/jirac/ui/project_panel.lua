local nui = require("nui-components")
local issue_service = require("jirac.jira_issue_service")

local pad_component = require("jirac.ui.ui_utils").pad_component

local M = {}

M.ProjectPanel = {
    size = { width = 120, height = 20 }
}

function M.ProjectPanel:_build_issues_column()
    local key_column = {}
    local summary_column = {}
    local status_column = {}
    local first = true
    for _, k in pairs(self.issues) do
        key_column[#key_column + 1] = nui.button {
            label = k.key,
            autofocus = first,
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
        first = false
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
    nui.columns(
        { flex = 0 },
        nui.rows(unpack(key_column)),
        nui.rows(unpack(summary_column)),
        nui.rows(unpack(status_column)),
        nui.gap(1)
    ),
    nui.gap({flex = 1}))
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
    return pad_component(nui.rows(
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
    ), 1, 3)
end

---@class ProjectPanel : Panel
---@field project Project

---@param o ProjectPanel
function M.ProjectPanel:new(o)
    o = o or {}
    self.__index = self
    setmetatable(o, self)
    self.issues = issue_service.get_project_issues {
        maxResults = 10,
        projectKey = o.project.key
    }
    return o
end

return M
