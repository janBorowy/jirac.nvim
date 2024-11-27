local curl = require("plenary.curl")
local credentials = require("jirac.storage")._credentials
local M = {}

---@alias resource
---| '"project"'
---| '"issue"'
function M.get_jira_url(resource, suffix)
    suffix = suffix or ""
    return "https://" .. credentials.domain .. "/rest/api/3/" .. resource .. "/" .. suffix
end

function M.get_base_opts()
    local opts = {
        accept = "application/json"
    }
    opts.auth = credentials.email .. ":" .. credentials.key
    return opts
end

function M.post_base_opts()
    local opts = {
        headers = {
            ["Content-Type"] = "application/json; charset=UTF-8"
        }
    }
    opts.auth = credentials.email .. ":" .. credentials.key
    return opts
end

-- TODO: needs better ADF support
-- https://developer.atlassian.com/cloud/jira/platform/apis/document/structure/
---@param text string
function M.text_to_adf(text)
    return {
        type = "doc",
        version = 1,
        content = {{
            type = "paragraph",
            content = {{
                text = text,
                type = "text"
            }}
        }}
    }
end

---@param adf table
function M.adf_to_text(adf)
    return vim.tbl_map(
    function (c1)
        return table.concat(vim.tbl_map(
        function (c2)
            return table.concat(vim.tbl_map(function (v) return v.text end, c2), "\n")
        end
        , c1.content), "\n\n")
    end, adf.content)
end

return M
