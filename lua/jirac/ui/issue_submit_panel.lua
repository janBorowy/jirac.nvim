local nui = require("nui-components")
local issue_service = require("jirac.jira_issue_service")
local user_service = require("jirac.jira_user_service")
local ErrorPanel = require("jirac.ui.error_panel").ErrorPanel
local IssueSearchPanel = require("jirac.ui.issue_search_panel").IssueSearchPanel

local M = {}

M.IssueSubmitPanel = {
    size = { width = 90, height = 30 },
    project = nil
}

---@param id string
---@return string
function M.IssueSubmitPanel:_get_field_value(id)
    local ref = self.parent.renderer:get_component_by_id(id)
    if not ref then
        error "ILLEGAL STATE: field value is missing"
    end
    return ref:get_current_value()
end

function M.IssueSubmitPanel:_fetch_assignee_selection_data()
    return vim.tbl_map(function (t)
        t.id = t.accountId
        return nui.option(t.displayName, t)
    end, user_service.find_users_assignable_to_issue
        {
            query = "",
            project_id_or_key = self.project.id
        })
end

function M.IssueSubmitPanel:_fetch_issue_type_data()
    return vim.tbl_map(function (t)
        return nui.option(t.name .. " - " .. t.description, t)
    end, issue_service.get_issue_types())
end

function M.IssueSubmitPanel:_handle_project_submit_error(obj)
    local panel = ErrorPanel:new({
        errors = obj.errors,
        parent = self.parent
    })
    self.parent:push(panel)
end

function M.IssueSubmitPanel:_handle_pick_parent_issue()
    self.parent:push(IssueSearchPanel:new {
        parent = self.parent,
        project = self.project,
        search_phrase = "",
        callback = function (issue)
            self.form_data.parent_issue = issue
        end
    })
end

function M.IssueSubmitPanel:_handle_clear_parent_issue()
    self.form_data.parent_issue = nil
    self.parent:update_nui()
end

function M.IssueSubmitPanel:_get_parent_issue_selection_component()
    if not self.form_data.parent_issue then
        return nui.rows (
        { flex = 1 },
        nui.gap { flex = 1 },
        nui.button {
            flex = 1,
            label = "Select subtask",
            on_press = function ()
                self:_handle_pick_parent_issue()
            end,
            align = "center"
        },
        nui.gap { flex = 1 },
        nui.gap(1)
        )
    end

    return nui.rows (
        { flex = 1 },
        nui.gap { flex = 1 },
        nui.paragraph {
            lines = {nui.line("Parent task: " .. self.form_data.parent_issue.key),
                     nui.line(self.form_data.parent_issue.summary)},
            align = "center",
            is_focusable = false
        },
        nui.button {
            flex = 1,
            label = "Change parent issue",
            on_press = function ()
                self:_handle_pick_parent_issue()
            end,
            align = "center"
        },
        nui.button {
            flex = 1,
            label = "Clear parent issue",
            on_press = function ()
                self:_handle_clear_parent_issue()
            end,
            align = "center"
        },
        nui.gap { flex = 1 }
    )
end

function M.IssueSubmitPanel:_handle_form_submit()
    ---@type IssueCreateDto
    local dto = {
        project_id = self.project.id,
        summary = self.form_data.summary,
        description = self.form_data.description,
        assignee_id = self.form_data.assignee_id,
        issue_type_id = self.form_data.issue_type_id,
    }

    if self.form_data.parent_issue then
        dto.parent_key = self.form_data.parent_issue.key
    end

    local success, obj = pcall(issue_service.create_issue, dto)
    if success then
        self.parent:pop()
    else
        self:_handle_project_submit_error(obj)
    end
end

function M.IssueSubmitPanel:build_nui_panel()
    self._issue_type_signal = nui.create_signal {
        selected = {}
    }
    self._assignee_signal = nui.create_signal {
        selected = {}
    }
    self._form = nui.form(
        {
            id = "create-issue-form",
            on_submit = function() self:_handle_form_submit() end
        },
        nui.paragraph {
            lines = "Create issue for " .. self.project.key,
            align = "center",
            is_focusable = false
        },
        nui.gap(1),
        nui.text_input {
            border_label = "Summary",
            max_lines = 2,
            autofocus = true,
            value = self.form_data.summary,
            on_change = function (v) self.form_data.summary = v end
        },
        nui.columns(
            { flex = 0 },
            nui.select {
                flex = 1,
                size = 5,
                border_label = "Assignee",
                selected = { id = self.form_data.assignee_id },
                data = self.assignee_selection_data,
                multiselect = false,
                on_select = function (node)
                    self._assignee_signal.selected = node
                    self.form_data.assignee_id = node.id
                end
            },
            self:_get_parent_issue_selection_component()
        ),
        nui.select {
                flex = 1,
                size = 5,
                border_label = "Issue Type",
                selected = { id = self.form_data.issue_type_id },
                data = self.issue_type_data,
                multiselect = false,
                on_select = function (node)
                    self._issue_type_signal.selected = node
                    self.form_data.issue_type_id = node.id
                end
        },
        nui.text_input {
            id = "description-field",
            flex = 1,
            border_label = "Description",
            value = self.form_data.description,
            on_change = function (v) self.form_data.description = v end
        },
        nui.button {
            label = "Submit",
            align = "center",
            on_press = function () self._form:submit() end
        }
    )
    return self._form
end

---@class IssueSubmitPanelParams : Panel
---@field project Project

function M.IssueSubmitPanel:new(o)
    o = o or {}
    self.__index = self
    setmetatable(o, self)
    o.assignee_selection_data = o.assignee_selection_data or o:_fetch_assignee_selection_data()
    o.issue_type_data = o.issue_type_data or o:_fetch_issue_type_data()
    o.form_data = o.form_data or {
        summary = "",
        issue_type_id = "",
        assignee_id = "",
        description = "",
        parent_issue = nil
    }
    return o
end


return M
