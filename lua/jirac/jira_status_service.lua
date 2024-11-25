local jira_service = require("jirac.jira_service")
local curl = require("plenary.curl")
local check_for_error = require("jirac.error").check_for_error

local M = {}

---@enum StatusCategory
M.STATUS_CATEGORY = {
    "DONE",
    "TO DO",
    "IN PROGRESS"
}

---@class Status
---@field id string
---@field description string
---@field name string
---@field statusCategory StatusCategory

local function get_url(action)
    return jira_service.get_jira_url("statuses", action)
end

---@class SearchStatusesQuery
---@field project_id integer
---@field start_at integer?
---@field max_results integer
---@field search_string string?

---@class SearchStatusesResponse
---@field is_last boolean
---@field max_results integer
---@field start_at integer
---@field total integer
---@field values Array<Status>

---@return SearchStatusesResponse
local function serialize_search_statuses_response(data)
    local obj = vim.fn.json_decode(data)
    return {
        is_last = obj.isLast,
        max_results = obj.maxResults,
        start_at = obj.startAt,
        total = obj.total,
        values = obj.values
    }
end

---@param query SearchStatusesQuery
---@return SearchStatusesResponse
function M.search_statuses(query)
    local opts = jira_service.get_base_opts()
    opts.query = {
        projectId = query.project_id,
        startAt = query.start_at or 0,
        maxResults = query.max_results,
        searchString = query.search_string or ""
    }
    local response = curl.get(get_url("search"), opts)

    check_for_error(response)

    return serialize_search_statuses_response(response.body)
end

P(M.search_statuses {
    project_id = "10000",
    start_at = 0,
    max_results = 10
})

return M
