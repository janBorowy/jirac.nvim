local nui = require("nui-components")
local issue_service = require("jirac.jira_issue_service")
local user_service = require("jirac.jira_user_service")
local ErrorPanel = require("jirac.ui.error_panel").ErrorPanel

local M = {}

M.IssueSubmitPanel = {
    size = { width = 90, height = 30 }
}

---@param id string
---@return string
function M.IssueSubmitPanel:_get_field_value(id)
    local ref = self.renderer:get_component_by_id(id)
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
        return nui.option(t.name, t)
    end, issue_service.get_issue_types())
end

function M.IssueSubmitPanel:_handle_project_submit_error(obj)
    local panel = ErrorPanel:new({
        errors = obj.errors,
        parent = self.parent
    })
    self.parent:push(panel)
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
            on_change = function (v) self.form_data.summary = v end
        },
        nui.columns(
            { flex = 0 },
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
            nui.select {
                flex = 1,
                size = 5,
                border_label = "Assignee",
                selected = { id = self.form_data.assignee_selection_data },
                data = self.assignee_selection_data,
                multiselect = false,
                on_select = function (node)
                    self._assignee_signal.selected = node
                    self.form_data.assignee_id = node.id
                end
            }
        ),
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
    self.project = o.project
    self.assignee_selection_data = self:_fetch_assignee_selection_data()
    self.issue_type_data = self:_fetch_issue_type_data()
    self.form_data = {
        summary = "",
        issue_type_id = "",
        assignee_id = "",
        description = ""
    }
    return o
end


return M
