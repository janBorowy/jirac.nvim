local ObjectSearchPrompt = require("jirac.ui.object_search_prompt").ObjectSearchPrompt
local M = {}

local PAGE_SIZE = 13

local function issue_label_factory (issue)
    return issue.key .. " " .. issue.summary
end

---@class SearchPromptParams
---@field header string?
---@field initial_query string?
---@field callback function

---@param params SearchPromptParams
function M.create_project(params)
    return ObjectSearchPrompt:new {
            header = params.header or "Search project",
            label_factory = function (v) return v.key .. " " .. v.name end,
            initial_query = params.initial_query or "",
            callback = params.callback,
            search_callback = function (query, callback)
                require("jirac.jira_project_service").search_projects({
                    maxResults = PAGE_SIZE,
                    query = query
                }, function (data) callback(data.values) end)
            end
    }
end

---@param params SearchPromptParams
function M.create_user(params)
    return ObjectSearchPrompt:new {
            header = params.header or "Search assignee",
            label_factory = function (v) return v.displayName end,
            initial_query = params.initial_query or "",
            callback = params.callback,
            search_callback = function (query, callback)
                require("jirac.jira_user_service").search_users({
                    maxResults = PAGE_SIZE,
                    query = query
                }, function (data) callback(data) end)
            end
    }
end

---@class IssueSearchPromptParams : SearchPromptParams
---@field project_key string

---@param params IssueSearchPromptParams
function M.create_issue(params)
    return ObjectSearchPrompt:new {
            header = params.header or "Search issue",
            label_factory = issue_label_factory,
            initial_query = params.initial_query or "",
            callback = params.callback,
            search_callback = function (query, callback)
                require("jirac.jira_issue_service").search_project_issues({
                    max_results = PAGE_SIZE,
                    search_phrase = query,
                    project_key = params.project_key
                }, function (data) callback(data) end)
            end
    }
end

---@class TransitionSearchPromptParams : SearchPromptParams
---@field issue_id string

---@param params TransitionSearchPromptParams
function M.create_transition(params)
    return ObjectSearchPrompt:new {
            header = params.header or "Search transitions",
            label_factory = function (v) return v.name end,
            callback = params.callback,
            disable_search = true,
            search_callback = function (_, callback)
                require("jirac.jira_issue_service").get_transitions(params.issue_id,
                function (data) callback(data) end)
            end
    }
end

---@class JqlSearchPromptParams : SearchPromptParams
---@field next_page_token string?

---@param params JqlSearchPromptParams
function M.create_jql(params)
    return ObjectSearchPrompt:new {
        header = params.header or "Search using JQL",
        label_factory = issue_label_factory,
        initial_query = params.initial_query or "",
        callback = params.callback,
        search_callback = function (jql, callback)
            require("jirac.jira_issue_service").get_issues_by_jql({
                max_results = PAGE_SIZE,
                jql = jql,
                next_page_token = params.next_page_token
            }, function (data) callback(data) end)
        end
    }
end

return M
