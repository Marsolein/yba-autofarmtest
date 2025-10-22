local player = game.Players.LocalPlayer
local living = game.Workspace:WaitForChild('Living')
local character = living:WaitForChild(player.Name)
local itemSpawns = game.Workspace:WaitForChild('Item_Spawns')
local items = itemSpawns:WaitForChild('Items')
local tweenService = game:GetService('TweenService')
local inputService = game:GetService('UserInputService')
local claimDelay = .5
local teleporting = false
local claimingItems = false
local itemsToCollect = {
	
}
local cframesToCheck = {
	
}

local function propertyForTween(newCFrame)
	local property = {
		CFrame = newCFrame
	}
	return property
end
local function tweenToCFrame(newCFrame)
	local property = {
		CFrame = newCFrame
	}
	local tweenInfo = TweenInfo.new(1,Enum.EasingStyle.Linear)
	local tween = tweenService:Create(character.PrimaryPart, tweenInfo, property)
	tween:Play()
	return tween
end

local function getProximityPrompt(item)
	local prompt = nil
	for i,v in pairs(item) do
		if v:IsA('ProximityPrompt') then
			if v.Enabled == false then
				v.Name = "FalsePrompt"
			else
				prompt = v
			end
		end
	end
	if prompt then
		return prompt
	end
end
local function getNearestItem(itemCFrame)
	local nearest = nil
	for i,v in pairs(items:GetChildren()) do
		if nearest then
			local nearestPrimary = nearest.PrimaryPart
			local nearestDistance = (nearestPrimary.CFrame.Position - itemCFrame.Position).Magnitude
			local newDistance = (v.PrimaryPart.CFrame.Position - itemCFrame.Position).Magnitude

			if newDistance < nearestDistance then
				nearest = v
			end
		else
			nearest = v
		end

		if (nearest.PrimaryPart.CFrame.Position - itemCFrame.Position).Magnitude < 5 then
			return nearest
		end
	end
end
local function claimNearest()
	local nearestItem = getNearestItem(character.PrimaryPart.CFrame)
	if nearestItem then
		local prompt = getProximityPrompt(nearestItem)
		if prompt then
			prompt.MaxActivationDistance = 20
			prompt.HoldDuration = 0
			prompt:InputHoldBegin()
		end
	end
end
local function claimAllItems()
	for i,v in pairs(items:GetChildren()) do
		local tween = tweenToCFrame(v.PrimaryPart.CFrame)
		tween.Completed:Connect(function()
			claimNearest()
			task.wait(claimDelay)
		end)
	end
	claimingItems = false
end
game:GetService("ReplicatedStorage").ItemSpawn.OnClientInvoke = function(arg1,...)
	local args = (...)
	if teleporting or claimingItems then
		table.insert(cframesToCheck, args['CFrame'])
	else
		teleporting = true
		local tween = tweenToCFrame()
		tween.Completed:Wait()
	end
end
items.ChildAdded:Connect(function(child)
	if claimingItems then return end
	claimingItems = true
	claimAllItems()
end)

inputService.InputBegan:Connect(function(input, isTyping)
	if not isTyping then
		if input.KeyCode == Enum.KeyCode.R then
			game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, player)
		end
	end
end)



