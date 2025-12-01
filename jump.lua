-- Lava Jump Timer
-- Tracks the 2-second lava damage cycle and displays a countdown timer

local LavaJump = CreateFrame("Frame")

-- Configuration
local LAVA_TICK_INTERVAL = 2.2  -- Lava damage occurs every 2 seconds
local WARN_THRESHOLD = 0.5      -- Show warning when < 0.5s until next tick

-- State
local lastLavaDamageTime = nil
local currentLatency = 0

-- Create UI Frame
local timerFrame = CreateFrame("Frame", "LavaJumpTimerFrame", UIParent)
timerFrame:SetWidth(200)
timerFrame:SetHeight(50)
timerFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 200)
timerFrame:EnableMouse(true)
timerFrame:SetMovable(true)
timerFrame:RegisterForDrag("LeftButton")
timerFrame:SetScript("OnDragStart", timerFrame.StartMoving)
timerFrame:SetScript("OnDragStop", timerFrame.StopMovingOrSizing)
timerFrame:Hide()

-- Background
local bg = timerFrame:CreateTexture(nil, "BACKGROUND")
bg:SetAllPoints(timerFrame)
-- bg:SetColorTexture(0, 0, 0, 0.7)

-- Timer Bar
local bar = CreateFrame("StatusBar", nil, timerFrame)
bar:SetPoint("LEFT", timerFrame, "LEFT", 5, 0)
bar:SetPoint("RIGHT", timerFrame, "RIGHT", -5, 0)
bar:SetHeight(20)
bar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
bar:SetMinMaxValues(0, LAVA_TICK_INTERVAL)
bar:SetValue(0)

-- Timer Text
local text = bar:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
text:SetPoint("CENTER", bar, "CENTER", 0, 0)
text:SetText("0.0s")

-- Title
local title = timerFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
title:SetPoint("BOTTOM", bar, "TOP", 0, 5)
title:SetText("Next Lava Tick")

-- Latency indicator
local latencyText = timerFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
latencyText:SetPoint("TOP", bar, "BOTTOM", 0, -2)

-- Update timer display
local function UpdateTimer()
    if not lastLavaDamageTime then
        timerFrame:Hide()
        return
    end


    local now = GetTime()
    local nextTickTime = lastLavaDamageTime + LAVA_TICK_INTERVAL
    for i = 1, 6, 1 do -- Counts from 1 to 5, incrementing by 1
        if(now < nextTickTime) then
            break
        end
        nextTickTime = lastLavaDamageTime + (i * LAVA_TICK_INTERVAL)
        if i == 6 then
            -- End predicting lava damage
            lastLavaDamageTime = nil
            timerFrame:Hide()
            return
        end
    end
    
    -- Get current latency
    local _, _, latency = GetNetStats()
    -- currentLatency = latency or 0
    
    -- Calculate time remaining on server
    local timeLeft = nextTickTime - GetTime() -- - (latency / 1000)
    -- Update bar with actual time (not adjusted)
    bar:SetValue(LAVA_TICK_INTERVAL - timeLeft)
    
    -- Show adjusted time in text
    if timeLeft < 0.8 then
        text:SetText("ACT NOW!")
    else
        text:SetText(string.format("%.1fs", timeLeft))
    end
    
    -- Update latency display
    -- latencyText:SetText(string.format("Ping: %dms", currentLatency))
    
    -- Color based on adjusted time remaining
    if timeLeft < 0 then
        bar:SetStatusBarColor(0.5, 0, 0)  -- Dark red - too late!
    elseif timeLeft < WARN_THRESHOLD then
        bar:SetStatusBarColor(1, 0, 0)  -- Red warning
    elseif timeLeft < 1.0 then
        bar:SetStatusBarColor(1, 0.5, 0)  -- Orange
    else
        bar:SetStatusBarColor(0, 1, 0)  -- Green safe
    end
end

-- OnUpdate handler
timerFrame:SetScript("OnUpdate", function()
    UpdateTimer()
end)

-- Event handler
local function OnEvent(event)
    if event == "CHAT_MSG_COMBAT_SELF_HITS" then
        -- Check if message is about lava damage
        if string.find(arg1, "swimming in lava") then
            -- Sync timer to current tick
            local now = GetTime()
            if lastLavaDamageTime then
                print(now - lastLavaDamageTime)
            end
            local _, _, latency = GetNetStats()
            lastLavaDamageTime = now -- - (latency / 1000)
            timerFrame:Show()
        end
    end
end

-- Register events
LavaJump:RegisterEvent("CHAT_MSG_COMBAT_SELF_HITS")
LavaJump:SetScript("OnEvent", function()
	OnEvent(event, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9)
end)
