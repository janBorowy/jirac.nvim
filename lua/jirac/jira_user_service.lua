local jira_service = require "jirac.jira_service"
local curl = require "plenary.curl"
local check_for_error = require ("jirac.error").check_for_error
local request_executor = require("jirac.request_executor")

local M = {}

local function get_url(action)
    return jira_service.get_jira_url("user", action)
end

---@class User
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
---@return Array<User>
function M.get_all_users(query)
    local opts = jira_service.get_base_opts()
    opts.query = query or {}
    local response = curl.get(jira_service.get_jira_url("users", "search"), opts)
    check_for_error(response)
    return vim.fn.json_decode(response.body)
end

---@class SearchUsersQuery
---@field maxResults integer
---@field query string

---@param query SearchUsersQuery
---@return Array<User>
function M.search_users(query, callback)
    local opts = jira_service.get_base_opts()
    opts.query = query or {}
    return request_executor.wrap_get_request {
        callback = callback,
        curl_opts = opts,
        url = jira_service.get_jira_url("user", "search")
    }
end

---@param project_id_or_key string
---@return Array<User> | nil
function M.find_users_assignable_to_issue(project_id_or_key, callback)
    local opts = jira_service.get_base_opts()
    opts.query = {
        query = "",
        project = project_id_or_key
    }

    return request_executor.wrap_get_request {
        curl_opts = opts,
        url = get_url("assignable/search"),
        callback = callback
    }
end

return M
