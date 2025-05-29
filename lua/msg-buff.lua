--- msg-buff.nvim - A Neovim plugin for displaying messages in a floating buffer
--- Provides a convenient way to view Neovim's message history in a popup window
--- with customizable appearance and behavior.
local M = {}

local default_config = {
	width = 0.7,
	height = 0.5,
	border = 'rounded',
	show_number = vim.o.number,
	show_relativenumber = vim.o.relativenumber,
	normal_hl = 'Normal',
	border_hl = 'FloatBorder',
}

M.config = vim.deepcopy(default_config)

--- @param hl_info vim.api.keyset.get_hl_info
--- @return vim.api.keyset.highlight
local function convert_rgb_to_hex(hl_info)
	local hl_output = {}
	for k, v in pairs(hl_info) do
		hl_output[k] = type(v) == 'number' and string.format('#%06x', v) or v
	end
	return hl_output
end

function M.setup(opts)
	M.config = vim.tbl_deep_extend('force', {}, default_config, opts or {})
	-- Copy highlight from 'Normal' to 'MsgBuffNormal'
	local normal_hl = convert_rgb_to_hex(vim.api.nvim_get_hl(0, { name = M.config.normal_hl }))
	vim.api.nvim_set_hl(0, "MsgBuffNormal", normal_hl)
	-- Copy highlight from 'FloatBorder' to 'MsgBuffBorder'
	local border_hl = convert_rgb_to_hex(vim.api.nvim_get_hl(0, { name = M.config.border_hl }))
	vim.api.nvim_set_hl(0, "MsgBuffBorder", border_hl)
end

function M.show_messages()
	local messages = vim.api.nvim_exec2('messages', { output = true }).output
	local lines = vim.split(messages, '\n')
	lines = vim.tbl_filter(function(line)
		return line:match("%S") ~= nil
	end, lines)
	for i = 1, math.floor(#lines / 2) do
		lines[i], lines[#lines - i + 1] = lines[#lines - i + 1], lines[i]
	end
	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
	local width = math.floor(vim.o.columns * (M.config.width or 0.7))
	local height = math.floor(vim.o.lines * (M.config.height or 0.5))
	local row = math.floor((vim.o.lines - height) / 2)
	local col = math.floor((vim.o.columns - width) / 2)
	local win = vim.api.nvim_open_win(buf, true, {
		relative = 'editor',
		width = width,
		height = height,
		row = row,
		col = col,
		style = 'minimal',
		border = M.config.border or 'rounded',
		title = ' Messages ',
		title_pos = 'center',
	})
	vim.api.nvim_set_option_value('number', M.config.show_number, { win = win })
	vim.api.nvim_set_option_value('relativenumber', M.config.show_relativenumber, { win = win })
	vim.api.nvim_set_option_value('winhighlight', 'Normal:MsgBuffNormal,FloatBorder:MsgBuffBorder', { win = win })
	vim.api.nvim_buf_set_keymap(buf, 'n', 'q', '', {
		nowait = true,
		noremap = true,
		silent = true,
		callback = function() vim.api.nvim_win_close(win, true) end,
	})
end

vim.api.nvim_create_user_command('MsgBuff', function()
	require('msg-buff').show_messages()
end, {})

return M
