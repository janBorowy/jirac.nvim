local check_for_error = require("jirac.error").check_for_error
local curl = require("plenary.curl")

local M = {}

---@class GetRequestOptions
---@field callback function
---@field response_mapper function?
---@field url string
---@field curl_opts table

--- Based on existence of callback, either do curl on main
--- thread or create new job
---@param opts GetRequestOptions
function M.wrap_get_request(opts)
    if opts.callback then
        opts.curl_opts.callback = vim.schedule_wrap(function (response)
            check_for_error(response)
            local result = vim.fn.json_decode(response.body)
            if opts.response_mapper then
                return opts.callback(opts.response_mapper(result))
            end
            return opts.callback(result)
        end)
        curl.get(opts.url, opts.curl_opts)
        return nil
    else
        local response = curl.get(opts.url, opts.curl_opts)

        check_for_error(response)

        if opts.response_mapper then
            return opts.response_mapper(vim.fn.json_decode(response.body))
        end
        return vim.fn.json_decode(response.body)
    end
end

return M
