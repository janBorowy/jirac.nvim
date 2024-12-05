local M = {}

---@alias ERROR_TYPE
---| "bad_request"
---| "not_authorized"
---| "not_found"
---| "unprocessable_entity"

---@class Error
---@field type ERROR_TYPE
---@field errorMessages Array<string>
---@field errors table<string, string>

---@return Error
local function create_error(body, status)
    return vim.tbl_extend("error", body and vim.fn.json_decode(body) or {}, {
        status = status
    })
end

function M.check_for_error(response)
    if math.floor(response.status / 100) == 4 or
        math.floor(response.status / 100) == 5 then
        error (create_error(response.body, response.status))
    end
end

return M
