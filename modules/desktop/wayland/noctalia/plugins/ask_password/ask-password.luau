local query = ""
local status = nil
local targetCmd = nil

local function writePin(pin)
	local cmd = "printf %s '" .. pin:gsub("'", "'\\''") .. "' > /run/user/1000/noctalia_password"
	noctalia.runAsync(cmd)
end

local authMsg = "Authenticating..."

local function render()
	local children = {
		ui.row({ gap = 16, align = "center" }, {
			ui.glyph({ name = "shield-lock", size = 32, color = "on_surface_variant" }),
			ui.column({ flexGrow = 1, gap = 4 }, {
				ui.label({ text = "Authentication Required", color = "secondary", fontWeight = "bold", fontSize = 14 }),
				ui.label({
					text = targetCmd ~= nil and ("Authentication is needed to run `" .. targetCmd .. "`")
						or "Authentication is needed to unlock the encrypted secret.",
					color = "on_surface",
					fontSize = 12,
				}),
			}),
		}),
	}

	table.insert(
		children,
		ui.input({
			key = "pin-input",
			password = true,
			focus = true,
			placeholder = "Enter PIN...",
			onChange = "onType",
			onSubmit = "onSubmit",
		})
	)

	local actionRowChildren = {}

	if status then
		table.insert(
			actionRowChildren,
			ui.label({
				text = status,
				color = status == authMsg and "on_surface_variant" or "error",
				fontSize = 12,
			})
		)
	end

	table.insert(
		actionRowChildren,
		ui.row({ gap = 12 }, {
			ui.button({ text = "Cancel", variant = "outline", onClick = "onCancel" }),
			ui.button({ text = "Unlock", variant = "primary", onClick = "onSubmit" }),
		})
	)

	table.insert(
		children,
		ui.row({ align = "center", justify = status and "space_between" or "end" }, actionRowChildren)
	)

	panel.render(ui.column({ flexGrow = 1, gap = 16, padding = 20, align = "stretch", justify = "start" }, children))
end

function onType(text)
	if status then
		status = nil
		render()
	end
	query = text
end

function onSubmit()
	if query ~= "" then
		status = authMsg
		render()
		writePin(query)
	end
end

function onCancel()
	status = nil
	writePin("")
	panel.close()
end

function onClose()
	status = nil
	writePin("")
end

function onOpen(context)
	query = ""

	if context and context ~= "" then
		local isRetry, cmd = context:match("^(%d+)::(.+)$")
		status = (isRetry == "1") and "Wrong PIN, or touch timed out." or nil
		targetCmd = cmd
	else
		status = nil
		targetCmd = nil
	end

	render()
end
