local jira_service = require("jirac.jira_service")
local curl = require("plenary.curl")

local check_for_error = require("jirac.error").check_for_error

local M = {}

local function get_url(action)
    return jira_service.get_jira_url("issue", action)
end

---@class Issue
---@field id string
---@field key string
---@field self string
---@field summary string
---@field status_name string
---@field description string

---@class GetProjectIssuesParams
---@field project_key string
---@field max_results integer?
---@field next_page_token string?

---@class SearchProjectIssuesParams : GetProjectIssuesParams
---@field search_phrase string

---@return Array<Issue>
local function serialize_project_issues(data)
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
    end, data.issues)
end

local function perform_jql_search(params)
    local url = jira_service.get_jira_url("search", "jql")
    local opts = jira_service.get_base_opts()
    opts.query = {
        jql = params.jql,
        maxResults = params.max_results,
        fields = "{id, self, key, description, status, summary,}",
        nextPageToken = params.next_page_token
    }
    local response = curl.get(url, opts)

    check_for_error(response)

    local data = vim.fn.json_decode(response.body)
    return serialize_project_issues(data)
end

local function perform_jql_count(jql)
    local url = jira_service.get_jira_url("search", "approximate-count")
    local opts = jira_service.post_base_opts()
    opts.body = vim.fn.json_encode(jql)
    local response = curl.post(url, opts)

    check_for_error(response)

    return tonumber(vim.fn.json_decode(response.body).count)
end

---@param params GetProjectIssuesParams
---@return Array<Issue>
function M.get_project_issues(params)
    local p = vim.fn.copy(params)
    p.jql = "project = " .. p.project_key
    return perform_jql_search(p)
end

---@param params SearchProjectIssuesParams
---@return Array<Issue>
function M.search_project_issues(params)
    local p = vim.fn.copy(params)
    p.jql = "project = " .. params.project_key ..
        (params.search_phrase and string.len(params.search_phrase) > 0 and
        " AND (summary ~ ".. params.search_phrase ..
        " OR description ~ " .. params.search_phrase .. ")"
        or "")
    P(p.jql)
    return perform_jql_search(p)
end

---@class IssueCountParams
---@field project_key string
---@field search_phrase string

---@param params IssueCountParams
function M.get_search_project_issues_count(params)
    return perform_jql_count("project = " .. params.project_key ..
        (params.search_phrase and
        " AND (summary ~ ".. params.search_phrase ..
        " OR description ~ " .. params.search_phrase .. ")"
        or ""))
end

---@class IssueSuggestion
---@field id string
---@field key string
---@field summary string
---@field summaryText string

---@class IssueSuggestionSection
---@field id string
---@field label string
---@field msg string
---@field sub string
---@field issues Array<IssueSuggestion>

---@class IssueSuggestionResponse
---@field sections Array<IssueSuggestionSection>

---@class GetIssueSuggestionsParams
---@field project_id string
---@field query string

function M.get_issue_suggestions(params)
    local url = get_url("picker")
    local opts = jira_service.get_base_opts()
    opts.query = {
        query = params.query,
        currentProjectId = params.project_id
    }
    local response = curl.get(url, opts)
    check_for_error(response)
    return vim.fn.json_decode(response.body)
end

---@enum StatusCategory
local STATUS_CATEGORY = {
    "DONE",
    "TO DO",
    "IN PROGRESS"
}

---@class Status
---@field id string
---@field description string
---@field name string
---@field statusCategory StatusCategory

---@param project_id string
function M.get_issue_statuses(project_id)
    local url = jira_service.get_jira_url("statuses", "search")
    local opts = jira_service.get_base_opts()
    opts.query = {
        projectId = project_id
    }
    local response = curl.get(url, opts)

    check_for_error(response)

    return vim.fn.json_decode(response.body).values
end

---@class IssueType
---@field id string
---@field description string
---@field name string

---@return Array<IssueType>
function M.get_issue_types()
    local url = jira_service.get_jira_url("issuetype")
    local opts = jira_service.get_base_opts()
    local response = curl.get(url, opts)
    check_for_error(response)
    return vim.fn.json_decode(response.body)
end

---@class IssueCreateDto
---@field project_id string
---@field summary string?
---@field description string?
---@field assignee_id string?
---@field issue_type_id string?

---@param dto IssueCreateDto
local function dto_to_fields(dto)
    return {
        fields = {
            assignee = {
                id = dto.assignee_id
            },
            project = {
                id = dto.project_id
            },
            summary = dto.summary,
            description = {
                type = "doc",
                version = 1,
                content = {{
                    type = "paragraph",
                    content = {{
                        text = dto.description,
                        type = "text"
                    }}
                }}
            },
            issuetype = {
                id = dto.issue_type_id
            }
        }
    }
end

---@class CreateIssueResponse
---@field id string
---@field key string
---@field url string

---@param dto IssueCreateDto
---@return CreateIssueResponse
function M.create_issue(dto)
    local url = get_url()
    local opts = jira_service.post_base_opts()
    opts.body = vim.fn.json_encode(dto_to_fields(dto))
    local response = curl.post(url, opts)

    check_for_error(response)

    local data = vim.fn.json_decode(response.body)
    return {
        id = data.id,
        key = data.key,
        url = data.self
    }
end

return M
