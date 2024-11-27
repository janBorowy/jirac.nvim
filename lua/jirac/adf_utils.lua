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

function M.format_to_text(adf)
    return table.concat(
        vim.tbl_map(function (paragraph)
            return table.concat(
                vim.tbl_map(function (inline_element)
                    if inline_element.type == "text" then
                        return inline_element.text
                    elseif inline_element.type == "hardBreak" then
                        return "\n"
                    end
                end, paragraph.content)
            , "")
        end,
        adf.content)
    , "\n\n")
end

return M
