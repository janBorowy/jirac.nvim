local jira_service = require("jirac.jira_service")
local curl = require("plenary.curl")

local M = {}

---@class Array<T>: { [integer]: T }

---@class Project
---@field url string
---@field id number
---@field key string
---@field name string
---@field project_type_key string

---@class GetProjectsDto
---@field values Array<Project>
---@field maxResults integer
---@field total integer
---@field isLast boolean

---@class Error
---@field reason string

---@return table
local function json_decode(body)
    return vim.fn.json_decode(body)
end

local function get_url(action)
    return jira_service.get_jira_url("project", action)
end

---@return Project
local function transform_project(body)
    return {
        url = body.self,
        id = body.id,
        key = body.key,
        name = body.name,
        project_type_key = body.projectTypeKey
    }
end

---@return GetProjectsDto
local function serialize_project_response(body)
    return {
        values = vim.tbl_map(transform_project, body.values),
        maxResults = body.maxResults,
        total = body.total,
        isLast = body.isLast
    }
end

---@return GetProjectsDto
function M.get_projects(query)
    local opts = jira_service.get_base_opts()
    opts.query = query
    local response = curl.get(get_url("search"), opts)

    if response.status == 400 then
        error "Bad request"
    elseif response.status == 401 then
        error "Not authorized"
    elseif response.status == 404 then
        error "Not found"
    end

    return serialize_project_response(json_decode(response.body))
end


return M
