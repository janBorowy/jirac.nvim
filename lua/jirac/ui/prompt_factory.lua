local ObjectSearchPrompt = require("jirac.ui.object_search_prompt").ObjectSearchPrompt
local M = {}

---@class SearchPromptParams
---@field parent any
---@field header string?
---@field initial_query string?
---@field callback function

---@param params SearchPromptParams
function M.create_project(params)
    return ObjectSearchPrompt:new {
            parent = params.parent,
            header = params.header or "Search project",
            label_factory = function (v) return v.key .. " " .. v.name end,
            initial_query = params.initial_query or "",
            callback = params.callback,
            search_callback = function (query)
                return require("jirac.jira_project_service").search_projects {
                    maxResults = 10,
                    query = query
                }.values
            end
    }
end

---@param params SearchPromptParams
function M.create_user(params)
    return ObjectSearchPrompt:new {
            parent = params.parent,
            header = params.header or "Search assignee",
            label_factory = function (v) return v.displayName end,
            initial_query = params.initial_query or "",
            callback = params.callback,
            search_callback = function (query)
                return require("jirac.jira_user_service").search_users {
                    maxResults = 10,
                    query = query
                }
            end
    }
end

---@class IssueSearchPromptParams : SearchPromptParams
---@field project_key string

---@param params IssueSearchPromptParams
function M.create_issue(params)
    return ObjectSearchPrompt:new {
            parent = params.parent,
            header = params.header or "Search issue",
            label_factory = function (v) return v.key .. " " .. v.summary end,
            initial_query = params.initial_query or "",
            callback = params.callback,
            search_callback = function (query)
                return require("jirac.jira_issue_service").search_project_issues {
                    max_results = 10,
                    search_phrase = query,
                    project_key = params.project_key
                }
            end
    }
end

---@class TransitionSearchPromptParams : SearchPromptParams
---@field issue_id string

---@param params TransitionSearchPromptParams
function M.create_transition(params)
    return ObjectSearchPrompt:new {
            parent = params.parent,
            header = params.header or "Search transitions",
            label_factory = function (v) return v.name end,
            callback = params.callback,
            disable_search = true,
            search_callback = function ()
                return require("jirac.jira_issue_service").get_transitions(params.issue_id)
            end
    }
end

return M
