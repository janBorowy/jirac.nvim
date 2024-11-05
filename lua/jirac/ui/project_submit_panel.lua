local nui = require("nui-components")
local proj_service = require("jirac.jira_project_service")
local user_service = require("jirac.jira_user_service")

local M = {}

M.ProjectSubmitPanel = {}

---@param id string
---@return string
function M.ProjectSubmitPanel:_get_field_value(id)
    local ref = self.renderer:get_component_by_id(id)
    if not ref then
        error "ILLEGAL STATE: field value is missing"
    end
    return ref:get_current_value()
end

function M.ProjectSubmitPanel:_fetch_project_type_selection_data()
    return vim.tbl_map(function (t)
        t.id = t.key
        return nui.option(t.formattedKey, t)
    end, proj_service.get_project_types())
end

function M.ProjectSubmitPanel:_fetch_leader_selection_data()
    return vim.tbl_map(function (t)
        t.id = t.accountId
        return nui.option(t.displayName, t)
    end, user_service.get_all_users())
end

function M.ProjectSubmitPanel:_handle_project_submit_error(obj)
end

function M.ProjectSubmitPanel:_handle_form_submit(is_valid)
    ---@type ProjectCreateDto
    local dto = {
        key = self:_get_field_value("key-field"),
        name = self:_get_field_value("name-field"),
        description = self:_get_field_value("description-field"),
        projectTypeKey = self._project_type_signal:get_value().selected.key,
        leadAccountId = self._leader_signal:get_value().selected.id
    }

    local success, obj = proj_service.create_project(dto)
    if success then
        self.parent:close()
    else
        self:handle_project_submit_error(obj)
    end
end

function M.ProjectSubmitPanel:_create_project_panel()
    self._leader_signal = nui.create_signal {
        selected = {}
    }
    self._project_type_signal = nui.create_signal {
        selected = {}
    }
    self._form = nui.form({
            id = "create_project_form",
            on_submit = function() self:_handle_form_submit() end,
        },
        nui.gap(1),
        nui.paragraph {
            lines = "Create Project",
            align = "center",
            is_focusable = false
        },
        nui.gap(1),
        nui.columns(
            { flex = 0 },
            nui.text_input {
                id = "key-field",
                autofocus = true,
                border_label = "Key",
                flex = 1
                -- validate = nui.validator.min_length(3) -- TODO: Validation?
            },
            nui.text_input {
                id = "name-field",
                border_label = "Name",
                flex = 1
                -- validate = nui.validator.min_length(3)
            }
        ),
        nui.columns(
            { flex = 0 },
            nui.select {
                flex = 1,
                size = 5,
                border_label = "Project Type",
                selected = self._project_type_signal.selected,
                data = self:_fetch_project_type_selection_data(),
                multiselect = false,
                on_select = function (node) self._project_type_signal.selected = node end
                },
            nui.select {
                flex = 1,
                size = 5,
                border_label = "Leader",
                selected = self._leader_signal.selected,
                data = self:_fetch_leader_selection_data(),
                multiselect = false,
                on_select = function (node) self._leader_signal.selected = node end
            }
        ),
        nui.text_input {
            id = "description-field",
            flex = 1,
            border_label = "Description",
        },
        nui.button {
            label = "Submit",
            align = "center",
            on_press = function () self._form:submit() end
        })
    return self._form
end

---@class ProjectPanelParams
---@field renderer any
---@field parent any

---@param o ProjectPanelParams
function M.ProjectSubmitPanel:new(o)
    o = o or {}
    self.__index = self
    self.renderer = o.renderer
    self.parent = o.parent
    self.panel = self:_create_project_panel()
    setmetatable(o, self)
    return o
end

return M
