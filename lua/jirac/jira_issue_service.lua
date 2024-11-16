local jira_service = require("jirac.jira_service")
local curl = require("plenary.curl")

local check_for_error = require("jirac.error").check_for_error

local M = {}

---@class Issue
---@field id string
---@field key string
---@field self string
---@field summary string
---@field status_name string
---@field description string

---@class GetProjectIssuesParams
---@field maxResults integer
---@field projectKey string

---@return Array<Issue>
local function serialize_project_issues(body)
    return vim.tbl_map(function (i)
        return {
            id = i.id,
            key = i.key,
            self = i.self,
            summary = i.fields and i.fields.summary,
            status_name = i.fields and
                i.fields.status and
                i.fields.status.statusCategory.name,
            description = i.fields
                and i.fields.description ~= vim.NIL
                and #i.fields.description.content ~= 0
                and i.fields.description.content[1]
                and i.fields.description.content[1].content
                and #i.fields.description.content[1].content ~= 0
                and i.fields.description.content[1].content[1].text
                or nil
        }
    end, vim.fn.json_decode(body).issues)
end

---@param params GetProjectIssuesParams
---@return Array<Issue>
function M.get_project_issues(params)
    local url = jira_service.get_jira_url("search", "jql")
    local opts = jira_service.get_base_opts()
    opts.query = {
        jql = "project = " .. params.projectKey,
        maxResults = params.maxResults,
        fields = "{id, self, key, description, status, summary,}"
    }
    local response = curl.get(url, opts)

    check_for_error(response)

    return serialize_project_issues(response.body)
end

return M
