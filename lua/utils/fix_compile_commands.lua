local M = {}

local compile_commands_path = vim.fn.expand("~/workspace/malevich/compile_commands.json")

local original_path = "/workspace_vol/host/malevich"
local replacement_path = vim.fn.expand("~/workspace/malevich")

function M.fix_compile_commands()
    if vim.fn.filereadable(compile_commands_path) == 0 then
        print("compile_commands.json not found")
        return
    end

    local lines = vim.fn.readfile(compile_commands_path)
    local text = table.concat(lines, "\n")

    text = text:gsub("%-march=native", "")
    text = text:gsub(original_path, replacement_path)

    vim.fn.writefile({text}, compile_commands_path)
    print("compile_commands.json fixed")
end

function M.setup_autocmd()
    vim.api.nvim_create_autocmd({"BufWritePost"}, {
        pattern = compile_commands_path,
        callback = function()
            M.fix_compile_commands()
        end,
        desc = "Fix compile_commands.json on save"
    })
end

M.setup_autocmd()

return M
