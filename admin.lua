-- Game loaded check
if not game:IsLoaded() then
	game.Loaded:Wait()
end

-- Locals
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local tps = game:GetService("TeleportService")
local Player = Players.LocalPlayer
local character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = character:WaitForChild("Humanoid")
local rp = character:WaitForChild("HumanoidRootPart")
local User = Player.Name
local runservice = game:GetService("RunService")
local plugins_directory = "situation_plugins"
local chatPrefix = "!"
local executiontext = [[
Welcome to Situation Admin (Beta)!

Type '!help' for a list of commands.
]]

-- Chat feedback
local function sendChatFeedback(message)
	game:GetService("StarterGui"):SetCore("ChatMakeSystemMessage", {
		Text = "[Situation Admin]: " .. message,
		Color = Color3.new(1, 1, 1),
		Font = Enum.Font.SourceSansBold,
		FontSize = Enum.FontSize.Size18,
	})
end

sendChatFeedback(executiontext)

-- Utilities
local function split(str, sep)
	if str == nil then
		return {}
	end

	if #sep > 1 then
		return {}
	end

	local tokens = {}

	for v in str:gmatch("([^" .. sep .. "]+)") do
		table.insert(tokens, v)
	end

	return tokens
end

local function getroot(char)
	return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
end

local function load_plugins()
	if isfolder(plugins_directory) == false then
		makefolder(plugins_directory)
	end

	local files = listfiles(plugins_directory)

	for key, value in pairs(files) do
		local file = value:match("[^\\^/]+%.lua$") or value:match("[^\\^/]+%.txt$")

		if file ~= nil then
			local filename = file:sub(0, #file - 4)

			local call = loadstring(readfile(value))

			commands[filename] = call
		end
	end
end

-- Commands Table
--[[ 
EXAMPLE

COMMAND_NAME = function(...)
			--code for command goes here
		end,
]]--
commands = {
	help = function()
		local i = 0
		local helpMessage = "Available Commands:\n"

		for key, _ in pairs(commands) do
			i = i + 1
			helpMessage = helpMessage .. i .. ".) " .. key .. "\n"
		end

		sendChatFeedback(helpMessage)
	end,
}

-- Chat listener
local function processChatMessage(msg)
	if msg:sub(1, #chatPrefix) == chatPrefix then
		local args = split(msg:sub(#chatPrefix + 1), " ")
		local command = string.lower(args[1])
		table.remove(args, 1)

		if commands[command] then
			local success, err = pcall(function()
				commands[command](table.unpack(args))
			end)

			if success then
				sendChatFeedback("Executed '" .. command .. "' successfully!")
			else
				sendChatFeedback("Error executing '" .. command .. "': " .. tostring(err))
			end
		else
			sendChatFeedback("Unknown command: " .. command)
		end
	end
end

Player.Chatted:Connect(processChatMessage)

while task.wait(5) do
	load_plugins()
end
