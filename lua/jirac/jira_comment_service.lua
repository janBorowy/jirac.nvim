local curl = require("plenary.curl")
local jira_service = require("jirac.jira_service")

local check_for_error = require("jirac.error").check_for_error

local M = {}

---@param issue_id_or_key string
---@param comment_id string?
---@return string
local function get_url(issue_id_or_key, comment_id)
    return jira_service.get_jira_url("issue", issue_id_or_key .. "/comment" .. (comment_id and "/" .. comment_id or ""))
end

---@class Comment
---@field id string
---@field author User
---@field update_author User
---@field text string
---@field created string
---@field self string

---@class GetCommentsParams
---@field issue_id_or_key string
---@field start_at integer?
---@field max_results integer?

---@class GetCommentsResponse
---@field values Array<Comment>
---@field max_results integer
---@field start_at integer
---@field total integer

local function transform_comment_data(data)
    return {
        id = data.id,
        author = data.author,
        update_author = data.updateAuthor,
        text = data.body and
        #data.body.content ~= 0
        and #data.body.content[1].content ~= 0
        and data.body.content[1].content[1].text,
        created = data.created,
        self = data.self
    }
end

---@param params GetCommentsParams
---@return GetCommentsResponse
function M.get_comments(params)
    local url = get_url(params.issue_id_or_key)
    local opts = jira_service.get_base_opts()
    opts.query = {
        startAt = params.start_at,
        maxResults = params.max_results
    }
    local response = curl.get(url, opts)

    check_for_error(response)

    local data = vim.json.decode(response.body)
    return {
        values = vim.tbl_map(transform_comment_data, data.comments),
        max_results = data.maxResults,
        start_at = data.startAt,
        total = data.total
    }
end

---@class PostCommentParams
---@field issue_id_or_key string
---@field text string

---@param params PostCommentParams
---@return Comment
function M.post_comment(params)
    local url = get_url(params.issue_id_or_key)
    local opts = jira_service.post_base_opts()
    opts.body = vim.fn.json_encode({
        body = jira_service.text_to_adf(params.text)
    })
    local response = curl.post(url, opts)

    check_for_error(response)

    return transform_comment_data(vim.fn.json_decode(response.body))
end

---@class DeleteCommentParams
---@field issue_id_or_key string
---@field comment_id string

---@param params DeleteCommentParams
function M.delete_comment(params)
    local url = get_url(params.issue_id_or_key, params.comment_id)
    local opts = jira_service.get_base_opts()
    local response = curl.delete(url, opts)

    check_for_error(response)
end

---@class UpdateCommentParams
---@field issue_id_or_key string
---@field comment_id string
---@field text string

---@param params UpdateCommentParams
function M.edit_comment(params)
    local url = get_url(params.issue_id_or_key, params.comment_id)
    local opts = jira_service.post_base_opts()
    opts.body = vim.fn.json_encode {
        body = jira_service.text_to_adf(params.text)
    }
    local response = curl.put(url, opts)

    check_for_error(response)
end

return M

