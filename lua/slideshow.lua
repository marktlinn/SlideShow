local M = {}

M.setup = function()
	-- TODO: complete
end

---@class present.Slides
---@fields slides string[]: The slides of the file

---@param lines string[]: The lines in the buffer
---@return present.Slides
local parse_slides = function(lines, separator)
	local slides = { slides = {} }
	local current_slide = {}

	for _, line in ipairs(lines) do
		if line:find(separator) then
			if #current_slide > 0 then
				table.insert(slides.slides, current_slide)
			end

			current_slide = {}
		end

		table.insert(current_slide, line)
	end

	table.insert(slides.slides, current_slide)

	return slides
end

M.start_slideshow = function(opts)
	opts = opts or {}
	opts.bufnr = opts.bufnr or 0

	local separator = "^#"
	local lines = vim.api.nvim_buf_get_lines(opts.bufnr, 0, -1, false)
	local parsed = parse_slides(lines, separator)

	local float = require("./lua.floating_term").create_floating_window()

	local current_slide = 1

	-- next slide
	vim.keymap.set("n", "n", function()
		current_slide = math.min(current_slide + 1, #parsed.slides)
		vim.api.nvim_buf_set_lines(float.buf, 0, -1, false, parsed.slides[current_slide])
	end, {
		buffer = float.buf,
	})

	-- previous slide
	vim.keymap.set("n", "p", function()
		current_slide = math.max(current_slide - 1, 1)
		vim.api.nvim_buf_set_lines(float.buf, 0, -1, false, parsed.slides[current_slide])
	end, {
		buffer = float.buf,
	})

	-- close buffer
	vim.keymap.set("n", "q", function()
		vim.api.nvim_win_close(float.win, true)
	end, {
		buffer = float.buf,
	})

	vim.api.nvim_buf_set_lines(float.buf, 0, -1, false, parsed.slides[1])
end

-- TODO: get bufnr dynamically.
M.start_slideshow({ bufnr = 15 })

return M
