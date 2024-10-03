local M = {}

-- Require the db_credentials module
local db_credentials = require("opdb.opdb-validate")

-- Define the main function to load credentials and open DBUI
function M.open_dbui_with_credentials()
	-- Load the credentials via 1Password
	db_credentials.load_credentials(function(success)
		if success then
			-- Open the DBUI once credentials are successfully loaded
			vim.cmd("DBUI")
		else
			print("Failed to load database credentials")
		end
	end)
end

vim.api.nvim_create_user_command("OPDB", function()
	M.open_dbui_with_credentials()
end, {})

return M
