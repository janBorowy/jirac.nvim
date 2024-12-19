local M = {}

function M.format_to_adf(text)
    local paragraphs = {}
    for _, paragraph in ipairs(vim.split(text, "\n\n")) do
        local lines = {}
        for _, line in ipairs(vim.split(paragraph, "\n")) do
            lines[#lines+1] = line
            lines[#lines+1] = "\n"
        end
        lines[#lines] = nil
        paragraphs[#paragraphs+1] = lines
    end
    return {
        version = 1,
        type = "doc",
        content = vim.tbl_map(function (paragraph)
            return {
                type = "paragraph",
                content = vim.tbl_map(function (line)
                    return line ~= "\n" and {
                        type = "text",
                        text = line
                    } or {
                        type = "hardBreak"
                    }
                end, paragraph)
            }
        end, paragraphs)
    }
end

local function map_inline_element(element)
    if element.type == "text" then
        return element.text
    elseif element.type == "hardBreak" then
        return "\n"
    elseif element.type == "media" and element.attrs.alt then
        return "(image)[" .. element.attrs.alt .. "]"
    else return "" end
end

function M.format_to_text(adf)
    return table.concat(
        vim.tbl_map(function (paragraph)
            return table.concat(
                vim.tbl_map(map_inline_element, paragraph.content or {})
            , "")
        end,
        adf.content)
    , "\n\n")
end

return M
