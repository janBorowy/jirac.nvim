local jira_service = require "jirac.jira_service"
local curl = require "plenary.curl"
local check_for_error = require ("jirac.error").check_for_error

local M = {}

local function get_url(action)
    return jira_service.get_jira_url("user", action)
end

---@class Array<T>: { [integer]: T }

---@class UserDto
---@field accountId string
---@field accountType string
---@field active boolean
---@field displayName string
---@field emailAddress string
---@field expand string
---@field key string
---@field locale string
---@field name string
---@field url string
---@field timeZone string

---@class UserGetQuery
---@field accountId string | nil
---@field username string | nil
---@field key string | nil
---@field expand string | nil

---@param query UserGetQuery?
function M.get_user(query)
    local opts = jira_service.get_base_opts()
    opts.query = query or {}
    local response = curl.get(get_url(), opts)

    check_for_error(response)

    return vim.fn.json_decode(response.body)
end

---@class GetAllUsersQuery
---@field startAt integer
---@field maxResults integer

---@param query GetAllUsersQuery?
---@return Array<UserDto>
function M.get_all_users(query)
    local opts = jira_service.get_base_opts()
    opts.query = query or {}
    local response = curl.get(jira_service.get_jira_url("users", "search"), opts)
    check_for_error(response)
    return vim.fn.json_decode(response.body)
end

---@class FindProjectAssignableQuery
---@field projectKeys string
---@field query string | nil
---@field username string | nil
---@field accountId string | nil
---@field startAt integer | nil
---@field maxResults integer | nil

---@param query FindProjectAssignableQuery
---@return Array<UserDto>
function M.find_users_assignable_to_project(query)
    local opts = jira_service.get_base_opts()
    opts.query = query or {}
    local response = curl.get(get_url("assignable/multiProjectSearch"), opts)

    check_for_error(response)

    return vim.fn.json_decode(response.body)
end

---@class FindUsersAssignableToIssueQuery
---@field query string
---@field project_id_or_key string

---@param query FindUsersAssignableToIssueQuery
---@return Array<UserDto>
function M.find_users_assignable_to_issue(query)
    local opts = jira_service.get_base_opts()
    opts.query = {
        query = query.query,
        project = query.project_id_or_key
    }
    local response = curl.get(get_url("assignable/search"), opts)

    check_for_error(response)

    return vim.fn.json_decode(response.body)
end

return M
