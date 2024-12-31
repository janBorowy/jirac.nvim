local nui = require("nui-components")
local issue_service = require("jirac.jira_issue_service")
local TextInputPrompt = require("jirac.ui.text_input_prompt").TextInputPrompt
local PromptFactory = require("jirac.ui.prompt_factory")
local ErrorPanel = require("jirac.ui.error_panel").ErrorPanel
local IssueCommentPanel = require("jirac.ui.issue_comment_panel").IssueCommentPanel
local ui_utils = require("jirac.ui.ui_utils")
local ui_defaults = require("jirac.ui.ui_defaults")

local flatmap_nil = require("jirac.util").flatmap_nil
local build_value_field = require("jirac.ui.value_field").build_value_field

local M = {}

M.IssuePanel = {}

function M.IssuePanel:_handle_edit_error(obj)
    self.parent:push(ErrorPanel:new {
        errors = obj.errors,
        parent = self.parent
    })
end

function M.IssuePanel:_handle_transition_issue()
    self.parent:push(PromptFactory.create_transition {
        parent = self.parent,
        header = "Transition issue " .. self.issue.key,
        issue_id = self.issue.id,
        callback = function (transition)
            local success, obj = pcall(issue_service.transition_issue, self.issue.key, transition.id)
            if success then
                self.issue = issue_service.get_issue_detailed(self.issue.id)
                self.parent:pop()
            else
                self:_handle_edit_error(obj)
            end
        end
    })
end

function M.IssuePanel:_handle_edit_summary()
    self.parent:push(TextInputPrompt:new {
        parent = self.parent,
        border_label = "Summary",
        initial_value = self.issue.summary,
        callback = function (new_summary)
            if flatmap_nil(self.issue.summary) and self.issue.summary == new_summary then
                self.parent:pop()
                return
            end
            local success, obj = pcall(issue_service.update_summary, self.issue.key, new_summary)
            if success then
                self.issue.summary = obj.summary
                self.parent:pop()
            else
                self:_handle_edit_error(obj)
            end
        end
    })
end

function M.IssuePanel:_handle_edit_reporter()
    self.parent:push(PromptFactory.create_user {
        parent = self.parent,
        header = "Pick reporter for " .. self.issue.key,
        callback = function (new_reporter)
            if flatmap_nil(self.issue.reporter) and self.issue.reporter.accountId == new_reporter.accountId then
                self.parent:pop()
                return
            end
            local success, obj = pcall(issue_service.update_reporter, self.issue.key, new_reporter.accountId)
            if success then
                self.issue.reporter = new_reporter
                self.parent:pop()
            else
                self:_handle_edit_error(obj)
            end
        end
    })
end

function M.IssuePanel:_handle_edit_parent()
    self.parent:push(PromptFactory.create_issue {
        parent = self.parent,
        header = "Pick parent for " .. self.issue.key,
        project_key = self.issue.project.key,
        callback = function (new_parent)
            if flatmap_nil(self.issue.parent) and self.issue.parent.id == new_parent.id then
                self.parent:pop()
                return
            end
            local success, obj = pcall(issue_service.update_parent, self.issue.key, new_parent.id)
            if success then
                self.issue.parent = new_parent
                self.parent:pop()
            else
                self:_handle_edit_error(obj)
            end
        end
    })
end

function M.IssuePanel:_handle_edit_assignee()
    self.parent:push(PromptFactory.create_user {
        parent = self.parent,
        header = "Pick assignee for " .. self.issue.key,
        callback = function (new_assignee)
            if flatmap_nil(self.issue.assignee) and self.issue.assignee.accountId == new_assignee.accountId then
                self.parent:pop()
                return
            end
            local success, obj = pcall(issue_service.assign_issue, self.issue.key, new_assignee.accountId)
            if success then
                self.issue.assignee = new_assignee
                self.parent:pop()
            else
                self:_handle_edit_error(obj)
            end
        end
    })
end

function M.IssuePanel:_handle_edit_description()
    self.parent:push(TextInputPrompt:new {
        parent = self.parent,
        border_label = "Description",
        initial_value = self.issue.description,
        callback = function (new_description)
            if flatmap_nil(self.issue.description) and self.issue.description == new_description then
                self.parent:pop()
                return
            end
            local success, obj = pcall(issue_service.update_description, self.issue.key, new_description)
            if success then
                self.issue.description = obj.description
                self.parent:pop()
            else
                self:_handle_edit_error(obj)
            end
        end
    })
end

function M.IssuePanel:_get_column_width()
    return (require("jirac.storage").get_config().window_width - 2 * ui_defaults.PADDING.horizontal) * 3 / 4
end

function M.IssuePanel:_handle_open_issue_comment_panel()
    self.parent:push(IssueCommentPanel:new {
        parent = self.parent,
        issue = self.issue,
        page = 1
    })
end

function M.IssuePanel:_build_left_column()
    return nui.rows(
        { flex = 3 },
        nui.button {
            lines = self.issue.summary,
            on_press = function () self:_handle_edit_summary() end,
            autofocus = true
        },
        nui.paragraph {
            lines = ui_utils.get_field_label("Description", "focus-description"),
            is_focusable = false,
            padding = {
                top = 1
            }
        },
        nui.button {
            id = "description-field",
            flex = 1,
            lines = ui_utils.create_nui_lines(self.issue.description, self:_get_column_width()),
            on_press = function () self:_handle_edit_description() end
        },
        nui.gap(1),
        nui.columns(
            { flex = 0 },
            nui.button {
                id = "comments-button",
                lines = ui_utils.get_field_label("Comments", "focus-comments"),
                on_press = function () self:_handle_open_issue_comment_panel() end,
                padding = {
                    right = 4,
                }
            },
            nui.gap { flex = 1 },
            nui.paragraph {
                lines = ui_utils.get_label_with_shortcut("press", "yank-issue-key", " to yank key"),
                is_focusable = false
            }
        )
    )
end

function M.IssuePanel:_build_right_column()
    local fields = {}
    local function add_field(f)
        fields[#fields+1] = f
    end

    add_field(build_value_field({
        button_id = "status-field",
        mapping_key = "focus-status",
        label = "Status",
        value = flatmap_nil(self.issue.status) and self.issue.status.name,
        press_callback = function () self:_handle_transition_issue() end
    }))
    add_field(build_value_field({
        label = "Issue type",
        value = flatmap_nil(self.issue.issue_type) and self.issue.issue_type.name,
        is_editable = false
    }))
    add_field(build_value_field({
        button_id = "assignee-field",
        mapping_key = "focus-assignee",
        label = "Assignee",
        value = flatmap_nil(self.issue.assignee) and self.issue.assignee.displayName,
        press_callback = function () self:_handle_edit_assignee() end
    }))
    add_field(build_value_field({
        button_id = "parent-field",
        mapping_key = "focus-parent",
        label = "Parent",
        value = flatmap_nil(self.issue.parent) and self.issue.parent.key,
        press_callback = function () self:_handle_edit_parent() end
    }))
    add_field(build_value_field({
        button_id = "reporter-field",
        mapping_key = "focus-reporter",
        label = "Reporter",
        value = flatmap_nil(self.issue.reporter) and self.issue.reporter.displayName,
        press_callback = function () self:_handle_edit_reporter() end
    }))
    add_field(build_value_field({
        label = "Priority",
        value = flatmap_nil(self.issue.priority) and self.issue.priority.name,
        is_editable = false
    }))

    fields[#fields + 1] = nui.gap { flex = 1 }
    return nui.rows(
        { flex = 1 },
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
        )
    )
end

local _signal_handlers = {
    ["issue_updated"] = function (self)
        self.parent:update_nui()
    end
}

---@param signal JiracWindowSignal
function M.IssuePanel:handle_signal(signal)
    if _signal_handlers[signal] then
        _signal_handlers[signal](self)
    end
end

function M.IssuePanel:_focus_if_exists(component_id)
    local ref = self.parent:get_component_by_id(component_id)
    if ref then
        ref:focus()
    end
end

function M.IssuePanel:get_mapping_definitions()
    return {
        ["focus-description"] = function () self:_focus_if_exists("description-field") end,
        ["focus-status"] = function () self:_focus_if_exists("status-field") end,
        ["focus-assignee"] = function () self:_focus_if_exists("assignee-field") end,
        ["focus-parent"] = function () self:_focus_if_exists("parent-field") end,
        ["focus-reporter"] = function () self:_focus_if_exists("reporter-field") end,
        ["focus-comments"] = function () self:_focus_if_exists("comments-button") end,
        ["yank-issue-key"] = function ()
            vim.cmd ("call setreg(\"+\",\"" .. self.issue.key .. "\", \"v\")")
            vim.cmd ("echo \"" .. "Yanked " .. self.issue.key .. "!" .. "\"")
        end
    }
end

---@class IssuePanelParams : Panel
---@field issue_id_or_key string

---@param o IssuePanelParams
function M.IssuePanel:new(o)
    o = o or {}
    self.__index = self
    setmetatable(o, self)
    o.issue = issue_service.get_issue_detailed(o.issue_id_or_key)
    return o
end

return M
