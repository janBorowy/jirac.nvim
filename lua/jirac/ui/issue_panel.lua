local nui = require("nui-components")
local issue_service = require("jirac.jira_issue_service")
local TextInputPrompt = require("jirac.ui.text_input_prompt").TextInputPrompt
local ErrorPanel = require("jirac.ui.error_panel").ErrorPanel

local M = {}

M.IssuePanel = {}

function M.IssuePanel:_handle_edit_error(obj)
    self.parent:push(ErrorPanel:new {
        errors = obj.errors,
        parent = self.parent
    })
end

function M.IssuePanel:_handle_edit_description()
    self.parent:push(TextInputPrompt:new {
        renderer = self.renderer,
        parent = self.parent,
        border_label = "Description",
        initial_value = self.issue.description,
        callback = function (new_description)
            self.parent:pop()
            -- try to update issue
            local success, obj = pcall(issue_service.update_description, self.issue.key, new_description)
            if success then
                self.issue.description = obj.description
                self.parent:update_nui()
            else
                self:_handle_edit_error(obj)
            end
        end
    })
end

function M.IssuePanel:_build_left_column()
    return nui.rows(
        nui.paragraph {
            lines = self.issue.summary,
            is_focusable = false
        },
        nui.paragraph {
            lines = "Description",
            is_focusable = false,
            padding = {
                top = 1
            }
        },
        nui.button {
            lines = self.issue.description,
            padding = {
                top = 1,
                left = 2
            },
            autofocus = true,
            on_press = function () self:_handle_edit_description() end
        },
        nui.gap { flex = 1 }
    )
end

function M.IssuePanel:_build_right_column()
    local fields = { self._build_editable_field {
                label = "Status",
                value = self.issue.status.name
            },
            self._build_editable_field {
                label = "Assignee",
                value = self.issue.assignee.displayName
            },
            self._build_editable_field {
                label = "Parent",
                value = self.issue.parent.key
            },
            self._build_editable_field {
                label = "Reporter",
                value = self.issue.reporter.displayName
            } }
    if self.issue.priority then
        fields[#fields + 1] = self._build_editable_field {
            label = "Priority",
            value = self.issue.priority.name
        }
    end

    fields[#fields + 1] = nui.gap { flex = 1 }
    return nui.rows(
        nui.paragraph {
            lines = "Details",
            padding = {
                bottom = 1
            },
            is_focusable = false
        },
        unpack(fields)
    )
end

---@class EditableFieldParams
---@field label string
---@field value string
---@field rendererd boolean?

---@param o EditableFieldParams
function M.IssuePanel._build_editable_field(o)
    return nui.rows(
        { flex = 0 },
        nui.paragraph {
            lines = o.label,
            padding = {
                left = 1
            },
            is_focusable = false
        },
        nui.paragraph {
            lines = o.value,
            padding = {
                left = 3,
                bottom = 1
            }
        })
end

function M.IssuePanel:build_nui_panel()
    return nui.rows (
        nui.paragraph {
            lines = "Issue details for " .. self.issue.key,
            align = "center",
            is_focusable = false
        },
        nui.gap(1),
        nui.columns (
            self:_build_left_column(),
            self:_build_right_column()
        ),
        nui.gap { flex = 1 }
    )
end

---@class IssuePanelParams : Panel
---@field issue_id string

function M.IssuePanel:new(o)
    o = o or {}
    self.__index = self
    setmetatable(o, self)
    self.issue = issue_service.get_issue_detailed(o.issue_id)
    return o
end

return M
