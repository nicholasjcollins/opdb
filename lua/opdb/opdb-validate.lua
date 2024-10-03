local M = {}

-- Function to load credentials from 1Password
function M.load_credentials(callback)
	-- Prompt for the 1Password master password
	local master_password = vim.fn.inputsecret("Enter 1Password Master Password: ")

	-- Authenticate with 1Password and fetch session token
	local handle = io.popen("echo " .. master_password .. " | op signin my.1password.com --raw")
	local session_token = handle:read("*a"):gsub("%s+", "")
	handle:close()

	-- If we fail to get a session token, stop the process
	if session_token == "" then
		print("Failed to authenticate with 1Password")
		callback(false)
		return
	end

	-- List of database names to fetch from 1Password (adjust as needed)
	local db_names = {
		"my_database_1",
		"my_database_2",
	}

	-- Table to store the database connection strings
	local dbs = {}

	-- Fetch credentials for each database and populate vim.g.dbs
	for _, db_name in ipairs(db_names) do
		local handle = io.popen(
			"op item get "
				.. db_name
				.. " --fields username,password,host,dbname,servertype --session="
				.. session_token
		)
		local result = handle:read("*a")
		handle:close()

		-- Extract fields from the result
		local username = result:match("username: ([^\n]+)")
		local password = result:match("password: ([^\n]+)")
		local host = result:match("host: ([^\n]+)")
		local dbname = result:match("dbname: ([^\n]+)")
		local servertype = result:match("servertype: ([^\n]+)")

		if username and password and host and dbname and servertype then
			local connection_string = string.format("%s://%s:%s@%s/%s", servertype, username, password, host, dbname)
			dbs[db_name] = connection_string
		else
			print("Error: Missing credentials for " .. db_name)
		end
	end

	-- Assign the credentials to vim.g.dbs
	vim.g.dbs = dbs

	-- Callback to notify success
	callback(true)
end

return M
