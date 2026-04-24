local LocalPlayer = game:GetService("Players").LocalPlayer
local RunService = game:GetService("RunService")
getgenv().tpwalking = true
local speed = 0.0
-- default is 0.0

local chr = LocalPlayer.Character
local hum = chr and chr:FindFirstChildWhichIsA("Humanoid")
while tpwalking and chr and hum and hum.Parent do
    local delta = RunService.Heartbeat:Wait()
    if hum.MoveDirection.Magnitude > 0.0 then
        if speed > 0.0 then
            chr:TranslateBy(hum.MoveDirection * speed * delta * 10)
        else
            chr:TranslateBy(hum.MoveDirection * delta * 10)
        end
    end
end
