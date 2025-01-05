local check_for_error = require("jirac.error").check_for_error
local curl = require("plenary.curl")
local M = {}

function M.get_jira_url(resource, suffix)
    local credentials = require("jirac.storage").get_credentails()
    suffix = suffix or ""
    return "https://" .. credentials.jira_domain .. "/rest/api/3/" .. resource .. "/" .. suffix
end

function M.get_jira_browse_url(issue_id_or_key)
    local credentials = require("jirac.storage").get_credentails()
    return "https://" .. credentials.jira_domain .. "/browse/" .. issue_id_or_key
end

function M.get_base_opts()
    local credentials = require("jirac.storage").get_credentails()
    local opts = {
        accept = "application/json"
    }
    opts.auth = vim.trim(credentials.email) .. ":" .. vim.trim(credentials.api_key)
    return opts
end

function M.post_base_opts()
    local credentials = require("jirac.storage").get_credentails()
    local opts = {
        headers = {
            ["Content-Type"] = "application/json; charset=UTF-8"
        }
    }
    opts.auth = vim.trim(credentials.email) .. ":" .. vim.trim(credentials.api_key)
    return opts
end

---@class GetRequestOptions
---@field callback function
---@field response_mapper function
---@field url string
---@field curl_opts table

---@param opts GetRequestOptions
function M.wrap_get_request(opts)
    if opts.callback then
        opts.curl_opts.callback = vim.schedule_wrap(function (response)
            check_for_error(response)
            local result = vim.fn.json_decode(response.body)
            return opts.callback(opts.response_mapper(result))
        end)
        curl.get(opts.url, opts.curl_opts)
        return nil
    else
        local response = curl.get(opts.url, opts.curl_opts)

        check_for_error(response)

        return opts.response_mapper(vim.fn.json_decode(response.body))
    end
end

return M
