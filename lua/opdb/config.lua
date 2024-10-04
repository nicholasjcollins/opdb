local M = {}
M.options = {
	db_names = { "database1" },
}

function M.setup(user_opts)
	M.options = vim.tbl_deep_extend("force", M.options, user_opts or {})
end

return M
