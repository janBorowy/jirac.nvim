local jira_service = require("jirac.jira_service")
local curl = require("plenary.curl")
local util = require("jirac.util")

local check_for_error = require("jirac.error").check_for_error

local M = {}

---@class Project
---@field url string
---@field id string
---@field key string
---@field name string
---@field project_type_key string

---@class SearchProjectsDto
---@field values Array<Project>
---@field maxResults integer
---@field total integer
---@field isLast boolean

local function get_url(action)
    return jira_service.get_jira_url("project", action)
end

---@return Project
function M.transform_project(body)
    return {
        url = body.self,
        id = body.id,
        key = body.key,
        name = body.name,
        project_type_key = body.projectTypeKey
    }
end

---@return SearchProjectsDto
local function serialize_project_response(body)
    return {
        values = vim.tbl_map(M.transform_project, body.values),
        maxResults = body.maxResults,
        total = body.total,
        isLast = body.isLast
    }
end

---@class SearchProjectsQuery
---@field startAt integer?
---@field maxResults integer?
---@field orderBy string?
---@field query string

---@param query SearchProjectsQuery
---@return SearchProjectsDto
function M.search_projects(query)
    local opts = jira_service.get_base_opts()
    opts.query = query or {}
    local response = curl.get(get_url("search"), opts)

    return serialize_project_response(vim.fn.json_decode(response.body))
end

---@class ProjectCreateDto
---@field key string
---@field name string
---@field projectTypeKey string
---@field leadAccountId string
---@field description string | nil
---@field categoryId string | nil
---@field avatarId string | nil
---@field url string | nil A link to information about this project
--[[
---@field asigneeIype string | nil
---@field filedConfigurationScheme integer | nil
---@field issueSecurityScheme integer | nil
---@field issueTypeScheme integer | nil
---@field issueTypeScreenScheme integer | nil
---@field notificationScheme integer | nil
---@field permissionScheme integer | nil
---@field projectTemplateKey integer | nil
---@field workfloweScheme integer | nil
--]]

---@class ProjectCreateResponse
---@field id string
---@field key string
---@field url string

---@param dto ProjectCreateDto
---@return ProjectCreateResponse
function M.create_project(dto)
    local opts = jira_service.post_base_opts()
    opts.body = vim.fn.json_encode(dto)
    local response = curl.post(get_url(), opts)

    check_for_error(response)

    return vim.fn.json_decode(response.body)
end

---@param projectIdOrKey string
function M.delete_project(projectIdOrKey)
    local response = curl.delete(get_url(projectIdOrKey), jira_service.get_base_opts())
    check_for_error(response)
end

---@param projectIdOrKey string
function M.archive_project(projectIdOrKey)
    local response = curl.post(get_url(projectIdOrKey .. "/archive"), jira_service.post_base_opts())
    check_for_error(response)
end

---@class ProjectType
---@field color string
---@field descriptionI18nKey string
---@field formattedKey string
---@field icon string
---@field key string

---@return table<string, ProjectType>
function M.get_project_types()
    local response = curl.get(get_url("type"), jira_service.get_base_opts())
    check_for_error(response)
    return vim.fn.json_decode(response.body)
end

---@return table<string, ProjectType>
function M.get_project_types_key_val()
    return util.array_to_key_val_tbl(M.get_project_types(),
        function (p)
            return p.key
        end)
end

---@class ProjectCategory
---@field id string
---@field name string
---@field url string
---@field description string

---@return Array<ProjectCategory>
function M.get_project_categories()
    local response = curl.get(jira_service.get_jira_url("projectCategory"),
                              jira_service.get_base_opts())
    check_for_error(response)
    return vim.tbl_map(function (c)
        c.url = c.self
        c.self = nil
    end, vim.fn.json_decode(response.body))
end

---@class ProjectPutDto
---@field assigneeType string | nil
---@field categoryId integer | nil
---@field description string | nil
---@field issueSecurityScheme integer | nil
---@field key string | nil
---@field lead string | nil
---@field leadAccountId string | nil
---@field name string | nil
---@field notificationScheme integer | nil
---@field permissionScheme integer | nil
---@field releasedProjectKeys Array<string> | nil
---@field url string | nil
---@field avatarId integer

---@param project_id_or_key string
---@param dto ProjectPutDto
function M.update_project(project_id_or_key, dto)
    local opts = jira_service.post_base_opts()
    opts.body = vim.fn.json_encode(dto)
    local response = curl.put(get_url(project_id_or_key), opts)
    check_for_error(response)
    return M.transform_project(response.body)
end

---@param project_id_or_key string
---@return Project
function M.get_project(project_id_or_key)
    local opts = jira_service.get_base_opts()
    local response = curl.get(get_url(project_id_or_key), opts)
    check_for_error(response)
    return M.transform_project(vim.fn.json_decode(response.body))
end

return M
