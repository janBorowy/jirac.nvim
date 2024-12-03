local M = {}

M.DEFAULT_SIZE = { width = 150, height = 37 }
M.PADDING = { vertical = 1, horizontal = 3 }

function M.window_width()
    return M.DEFAULT_SIZE.width - 2 * M.PADDING.horizontal
end

function M.window_height()
    return M.DEFAULT_SIZE.height - 2 * M.PADDING.vertical
end

return M
