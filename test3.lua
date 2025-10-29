local player = game.Players.LocalPlayer
local living = game.Workspace:WaitForChild('Living')
local tweenService = game:GetService('TweenService')
local inputService = game:GetService('UserInputService')
local mainNPCname = ""
local buyList = {
	["Dio's Diary"] = "1x DIO's Diary",
	["Rokakaka"] = "1x Rokakaka",
	["Lucky Arrow"] = "1x Lucky Arrow",
	["Mysterious Arrow"] = "1x Mysterious Arrow",	
}
local npcList = {
	["Pucci"] = "Pucci [Lvl. 40+]"
}
local function rejoinServer()
	game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, player)
end
local function propertyForTween(newCFrame)
	local property = {
		CFrame = newCFrame
	}
	return property
end
local function tpToCFrame(newCFrame, character)
	local property = {
		CFrame = newCFrame
	}
	local tweenInfo = TweenInfo.new(5,Enum.EasingStyle.Linear)
	local tween = tweenService:Create(character.PrimaryPart, tweenInfo, property)
	tween:Play()
	return tween
end
local function getCharacter()
	local character = living:FindFirstChild(player.Name)
	if character then
		return character
	end
end
local function attachToNpc(npc, character, offset)
	local npcCFrame = npc.PrimaryPart.CFrame
	if character then
		character.PrimaryPart.CFrame = npcCFrame * offset
	end
end
local function checkForItem(itemToSearch)
	local backpack = player.Backpack
	local item = backpack:FindFirstChild(itemToSearch)
	if item then
		return item
	end
end
local function buyItem(itemToSearch)
	if buyList[itemToSearch] then
		local args = {
			"PurchaseShopItem",
			{
				ItemName = buyList[itemToSearch]
			}
		}
		game:GetService("Players").LocalPlayer.Character:WaitForChild("RemoteEvent"):FireServer(unpack(args))
	end
end
local function checkCash()
	local money = player.PlayerStats:FindFirstChild('Money')
	if money and money:IsA('NumberValue') then
		return money.Value
	end
end
local function getSlots()
	local slots = {}
	local playerStats = player.PlayerStats
	table.insert(slots, playerStats.Stand)
	for i,value in pairs(playerStats) do
		if string.sub(value.Name,1, 4) == "Slot" then
			table.insert(slots, value)
		end
	end
	return slots
end
local function checkForStand(standName)
	local standSlots = getSlots()
	local hasStand = false
	for i,v in pairs(standSlots) do
		if v.Value == standName then
			hasStand = true
		end
	end
	return hasStand
end
local function poseForHeal()
	local character = getCharacter()
	if character then
		local args = {
			"StartPosing"
		}
		character:WaitForChild("RemoteEvent"):FireServer(unpack(args))
	end
end
local function m1()
	local character = getCharacter()
	if character then
		local args = {
			"Attack",
			"m1"
		}
		character:WaitForChild("RemoteEvent"):FireServer(unpack(args))
	end
end
local function checkHealth()
	local character = getCharacter()
	if character and character.Humanoid then
		return character.Humanoid.Health
	end
end
local function checkEquipped(standName)
	local playerStats = player.PlayerStats
	local equipped = playerStats.Stand
	if equipped.Value == standName then
		return true, equipped
	end
end
local function switchToStand()
	-- to be continued
end
local function getQuestNpc(npcToSearch)
	local dialogues = game.Workspace.Dialogues
	if npcList[npcToSearch] then
		local npc = dialogues:FindFirstChild(npcList[npcToSearch])
		if npc then
			return npc
		end
	end
end
local function getQuest()
	local playerStats = player.PlayerStats
	local quest = playerStats:FindFirstChild('Quest')
	if quest then
		return quest.Value
	end
end
local function getQuestProgress()
	local playerStats = player.PlayerStats
	local maxProgress = playerStats:FindFirstChild('QuestMaxProgress')
	local progress = playerStats:FindFirstChild('QuestProgress')
	return progress.Value, maxProgress.Value
end
local function getLivingNpc(npcToSearch)
	local npc = living:FindFirstChild(npcToSearch)
	if npc then
		return npc
	end
end
local function fight(opponent)
	local character = getCharacter()
	local lastHit = os.clock()
	repeat
		local health = character.Humanoid.Health
		local maxHealth = character.Humanoid.MaxHealth
		if health <= maxHealth * .4 then
			local healingOffset = CFrame.new(0,0,10)
			poseForHeal()
			repeat
				attachToNpc(opponent, character, healingOffset)
				task.wait()
			until health >= maxHealth * .8
			poseForHeal()
		else
			local offset = CFrame.new(0,0,4)
			attachToNpc(opponent, character, offset)
			
			if (os.clock() - lastHit) >= .25 then
				lastHit = os.clock()
				m1()
			end
		end
		task.wait()
	until opponent.Humanoid.Health <= 0
end
local function killNpc(nameToFind)
	local npc
	local character = getCharacter()
	repeat npc = getLivingNpc(nameToFind) task.wait() until npc.Humanoid and npc.Humanoid.Health > 0
	local distance = (npc.PrimaryPart.CFrame.Position  - character.PrimaryPart.CFrame.Position).Magnitude
	
	if distance > 10 then
		local tween = tpToCFrame(npc.PrimaryPart.CFrame, character)
		tween.Completed:Connect(function()
			fight(npc)
		end)
	else
		fight(npc)
	end
end
local function quest1()
	local progress, goal = getQuestProgress()
	repeat
		killNpc("Thug")
		progress, goal = getQuestProgress()
	until progress == goal
end
local function startQuest1()
	local pucci = getQuestNpc('Pucci')
	local character = getCharacter()
	if pucci and character then
		local distance = (pucci.PrimaryPart.CFrame.Position  - character.PrimaryPart.CFrame.Position).Magnitude
		if distance > 10 then
			local tween = tpToCFrame(pucci.PrimaryPart.CFrame, character)
			tween.Completed:Connect(function()
				local args = {
					"DialogueInteracted",
					{
						DialogueName = "Pucci",
						Speaker = "Pucci [Lvl. 40+]"
					}
				}
				game:GetService("Players").LocalPlayer.Character:WaitForChild("RemoteEvent"):FireServer(unpack(args))
			end)
		else
			local args = {
				"DialogueInteracted",
				{
					DialogueName = "Pucci",
					Speaker = "Pucci [Lvl. 40+]"
				}
			}
			game:GetService("Players").LocalPlayer.Character:WaitForChild("RemoteEvent"):FireServer(unpack(args))
		end
		quest1()
	end
end
local questList = {
	["Defeat 30 Thugs (Dio's Plan)"] = quest1()
}
local function initialize()
	local diary = checkForItem("Dio's Diary")
	if not diary then
		local cash = checkCash()
		if cash >= 20000 then
			buyItem("Dio's Diary")
		else
			rejoinServer()
		end
	end
	local quest = getQuest()
	if questList[quest] then
		questList[quest]()
	else
		startQuest1()
	end
end
