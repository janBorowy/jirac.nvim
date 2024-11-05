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
return M
