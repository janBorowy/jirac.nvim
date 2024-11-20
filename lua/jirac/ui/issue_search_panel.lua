local nui = require("nui-components")
local util = require("jirac.util")
local issue_service = require("jirac.jira_issue_service")

local M = {}
local MAX_ISSUE_SEARCH_RESULTS = 10

M.IssueSearchPanel = {
    size = { width = 60, height = 20 },
    max_results = 10,
    current_page = 1
}

function M.put_issue_search_panel(panel)
    panel.parent:pop()

    panel.parent:push(M.IssueSearchPanel:new {
        renderer = panel.renderer,
        parent = panel.parent,
        search_phrase = panel.search_phrase,
        project = panel.project,
        callback = panel.callback
    })
end

function M.IssueSearchPanel:build_search_result_rows()
    local rows = {}
    for i, issue in ipairs(self.issues) do
        if i > 10 then
            break
        end
        rows[#rows + 1] = nui.button {
            lines = vim.tbl_map( function (txt)
                return nui.line(nui.text(txt))
            end, util.wrap_string(issue.key .. " " .. issue.summary, self.size.width)),
            autofocus = i == 1,
            align = "center",
            on_press = function ()
                self.callback(issue)
                self.parent:pop()
            end
        }
    end
    return nui.rows({flex = 0}, unpack(rows))
end

function M.IssueSearchPanel:build_nui_panel()
    return nui.rows(
        nui.gap(1),
        nui.paragraph {
            lines = "Issue Search for " .. self.project.key,
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
                value = self.search_phrase,
                on_change = function (v)
                    self.search_phrase = v
                end
            },
            nui.button {
                label = "search",
                align = "center",
                on_press = function ()
                    M.put_issue_search_panel(self)
                end,
                padding = {
                    top = 1
                }
            }
        ),
        self:build_search_result_rows(),
        nui.gap { flex = 1 }
    )
end

---@class IssueSearchPanel : Panel
---@field search_phrase string
---@field project Project
---@field callback function

---@param o IssueSearchPanel
function M.IssueSearchPanel:new(o)
    o = o or {}
    self.__index = self
    setmetatable(o, self)
    self.issues = issue_service.search_project_issues {
        project_key = o.project.key,
        search_phrase = o.search_phrase
    }
    return o
end

return M
