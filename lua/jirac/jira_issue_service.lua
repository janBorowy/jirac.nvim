local jira_service = require("jirac.jira_service")
local project_service = require("jirac.jira_project_service")
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
---@field status Status?
---@field description string?

---@class Priority
---@field id string
---@field name string
---@field self string

---@class GetProjectIssuesParams
---@field project_key string
---@field max_results integer?
---@field next_page_token string?

---@class SearchProjectIssuesParams : GetProjectIssuesParams
---@field search_phrase string

local function serialize_project_issue(data)
    return {
        id = data.id,
        key = data.key,
        self = data.self,
        summary = data.fields and data.fields.summary,
        status = data.fields and
            data.fields.status,
        description = data.fields
            and data.fields.description ~= nil
            and #data.fields.description.content ~= 0
            and data.fields.description.content[1]
            and data.fields.description.content[1].content
            and #data.fields.description.content[1].content ~= 0
            and data.fields.description.content[1].content[1].text
            or nil,
        priority = data.fields
            and data.fields.priority
    }
end

---@return Array<Issue>
local function serialize_project_issues(data)
    return vim.tbl_map(function (i)
        serialize_project_issue(i)
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
---@field parent_key string?

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
            },
            parent = dto.parent_key and {
                key = dto.parent_key
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

---@class IssueDetailed : Issue
---@field parent ParentIssue?
---@field assignee User?
---@field reporter User?
---@field priority Priority?
---@field project Project?

---@class ParentIssue
---@field key string
---@field id string
---@field status Status
---@field type IssueType
---@field priority Priority

---@return IssueDetailed
local function serialize_project_issue_detailed(data)
    local serialized = serialize_project_issue(data)
    return vim.tbl_extend('error', serialized,
        {
            parent = data.fields and
                data.fields.parent and
                serialize_project_issue(data.fields.parent),
            assignee = data.fields and
                data.fields.assignee,
            reporter = data.fields and
                data.fields.reporter,
            project = data.fields and
                data.fields.project and
                project_service.transform_project(data.fields.project)
        }
    )
end

---@param issue_id_or_key string
---@return IssueDetailed
function M.get_issue_detailed(issue_id_or_key)
    local url = get_url(issue_id_or_key)
    local opts = jira_service.get_base_opts()
    opts.query = {
        fields = "{id, self, key, description, status, summary, \
        parent, assignee, reporter, priority, project,}"
    }
    local response = curl.get(url, opts)

    check_for_error(response)

    return serialize_project_issue_detailed(vim.fn.json_decode(response.body))
end

local function edit_issue(issue_id_or_key, fields_obj)
    local url = get_url(issue_id_or_key)
    local opts = jira_service.post_base_opts()
    opts.query = { returnIssue = 'true' }
    opts.body = vim.fn.json_encode( { fields = fields_obj } )
    local response = curl.put(url, opts)

    check_for_error(response)

    return serialize_project_issue(vim.fn.json_decode(response.body))
end

---@return Issue
function M.update_description(issue_id_or_key, new_description)
    return edit_issue(issue_id_or_key, {
        description = {
                type = "doc",
                version = 1,
                content = {
                    {
                        type = "paragraph",
                        content = {
                            {
                                type = "text",
                                text = new_description
                            }
                        }
                    }
                }
        }
    })
end

---@return Issue
function M.update_parent(issue_id_or_key, new_parent_id)
    return edit_issue(issue_id_or_key, {
        parent = {
            id = new_parent_id
        }
    })
end

---@return Issue
function M.update_reporter(issue_id_or_key, new_reporter_id)
    return edit_issue(issue_id_or_key, {
        reporter = {
            id = new_reporter_id
        }
    })
end

function M.assign_issue(issue_id_or_key, new_assignee_id)
    local url = get_url(issue_id_or_key .. "/assignee")
    local opts = jira_service.post_base_opts()
    opts.body = vim.fn.json_encode( { accountId = new_assignee_id } )
    local response = curl.put(url, opts)

    check_for_error(response)
end

return M
