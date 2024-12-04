local M = {}

---@class BadRequestError
---@field errorMessages Array<string>
---@field errors table<string, string>

local bad_request_mt = {
    __tostring = function (o)
        return vim.fn.json_decode(o)
    end
}
local function create_bad_request_error(body)
    local error = vim.fn.json_decode(body)
    setmetatable(bad_request_mt, error)
    return error
end

function M.check_for_error(response)
    if response.status == 400 then
        P(response)
        error (create_bad_request_error(response.body))
    elseif response.status == 401 then
        error ("Not authorized: " .. vim.inspect(response))
    elseif response.status == 404 then
        error ("Not found: " .. vim.inspect(response))
    elseif tostring(response.status)[1] == 4 or
        tostring(response.status)[1] == 5 then
        error (tostring(response.status) .. ": " .. vim.inspect(response))
    end
end

return M
