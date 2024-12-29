local M = {}

M.array_to_key_val_tbl = function (arr, key_function)
    local tbl = {}
    for _, v in ipairs(arr) do
        tbl[key_function(v)] = v
    end
    return tbl
end

M.wrap_string = function (str, line_len)
    local result = {}
    local buffer = ""
    local function append(word)
        if string.len(buffer) > 0 then
            buffer = buffer .. " " .. word
        else
            buffer = word
        end
    end
    local function dump()
        if string.len(buffer) > 0 then
            result[#result + 1] = buffer
        end
        buffer = ""
    end

    for word in string.gmatch(str, "%S+") do
        if string.len(buffer) + string.len(word) + 1 <= line_len then
            append(word)
        else
            dump()
            append(word)
        end
    end
    dump()
    return result
end

function M.flatmap_nil(o)
    return o and o ~= vim.NIL or nil
end

return M

