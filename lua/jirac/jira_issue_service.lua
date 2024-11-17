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
---@field maxResults integer
---@field projectKey string
---@field next_page_token string?

---@class GetProjectIssuesResponse
---@field issues Array<Issue>
---@field next_page_token string

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

---@param params GetProjectIssuesParams
---@return GetProjectIssuesResponse
function M.get_project_issues(params)
    local url = jira_service.get_jira_url("search", "jql")
    local opts = jira_service.get_base_opts()
    opts.query = {
        jql = "project = " .. params.projectKey,
        maxResults = params.maxResults,
        fields = "{id, self, key, description, status, summary,}",
        next_page_token = params.next_page_token
    }
    local response = curl.get(url, opts)

    check_for_error(response)

    local data = vim.fn.json_decode(response.body)
    return {
        issues = serialize_project_issues(data),
        next_page_token = data.nextPageToken
    }
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
