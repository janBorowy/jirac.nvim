local M = {}

M.array_to_key_val_tbl = function (arr, key_function)
    local tbl = {}
    for _, v in ipairs(arr) do
        tbl[key_function(v)] = v
    end
    return tbl
end

M.lin_search = function (tbl, find_function)
    for k, v in pairs(tbl) do
        if find_function(v) then
            return k
        end
    end
    return nil
end

M.to_array = function (tbl)
    local result = {}
    for _, v in pairs(tbl) do
        result[#result + 1] = v
    end
    return result
end

M.wrap_string = function (str, line_len)
    local result = {}
    local cur_line = ""
    for word in string.gmatch(str, "%S+") do
        if string.len(word) >= line_len then
            if string.len(cur_line) > 0 then
                table.insert(result, cur_line)
                cur_line = ""
            end
            table.insert(result, word)
        elseif string.len(cur_line) + string.len(word) + 1 > line_len then
            table.insert(result, cur_line)
            cur_line = ""
        else
            cur_line = cur_line .. word .. (string.len(cur_line) + string.len(word) == line_len and "" or " ")
        end
    end
    if string.len(cur_line) > 0 then
        table.insert(result, cur_line)
    end
    return result
end

function M.flatmap_nil(o)
    return o and o ~= vim.NIL or nil
end

return M

