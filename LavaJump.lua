-- Lava Jump Timer
-- Tracks the 2-second lava damage cycle and displays a countdown timer

local LavaJump = CreateFrame("Frame")

-- Configuration
local LAVA_TICK_INTERVAL = 2.0  -- Lava damage occurs every 2 seconds
local WARN_THRESHOLD = 0.5      -- Show warning when < 0.5s until next tick
local LATENCY_BUFFER = 1.5      -- Multiplier for latency (1.5x for safety margin)

-- State
local nextTickTime = nil
local inLava = false
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
bg:SetColorTexture(0, 0, 0, 0.7)

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
latencyText:SetText("Latency: 0ms")

-- Update timer display
local function UpdateTimer()
    if not nextTickTime then
        timerFrame:Hide()
        return
    end
    
    -- Get current latency
    local _, _, latency = GetNetStats()
    currentLatency = latency or 0
    
    -- Calculate time remaining on server
    local timeLeft = nextTickTime - GetTime()
    
    if timeLeft < 0 then
        -- Missed the tick, resync on next damage event
        nextTickTime = nil
        inLava = false
        timerFrame:Hide()
        return
    end
    
    -- Adjust for latency - subtract latency to show when player needs to act
    local latencySeconds = (currentLatency / 1000) * LATENCY_BUFFER
    local adjustedTimeLeft = timeLeft - latencySeconds
    
    -- Update bar with actual time (not adjusted)
    bar:SetValue(LAVA_TICK_INTERVAL - timeLeft)
    
    -- Show adjusted time in text
    if adjustedTimeLeft < 0 then
        text:SetText("ACT NOW!")
    else
        text:SetText(string.format("%.1fs", adjustedTimeLeft))
    end
    
    -- Update latency display
    latencyText:SetText(string.format("Ping: %dms", currentLatency))
    
    -- Color based on adjusted time remaining
    if adjustedTimeLeft < 0 then
        bar:SetStatusBarColor(0.5, 0, 0)  -- Dark red - too late!
    elseif adjustedTimeLeft < WARN_THRESHOLD then
        bar:SetStatusBarColor(1, 0, 0)  -- Red warning
    elseif adjustedTimeLeft < 1.0 then
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
local function OnEvent(self, event, arg1)
    if event == "CHAT_MSG_COMBAT_SELF_HITS" then
        -- Check if message is about lava damage
        if string.find(arg1, "swimming in lava") then
            -- Sync timer to current tick
            nextTickTime = GetTime() + LAVA_TICK_INTERVAL
            inLava = true
            timerFrame:Show()
        end
    end
end

-- Register events
LavaJump:RegisterEvent("CHAT_MSG_COMBAT_SELF_HITS")
LavaJump:SetScript("OnEvent", OnEvent)

-- Slash command for testing/toggling
SLASH_LAVAJUMP1 = "/lavajump"
SLASH_LAVAJUMP2 = "/lj"
SlashCmdList["LAVAJUMP"] = function(msg)
    local cmd, arg = strsplit(" ", msg)
    
    if cmd == "test" then
        -- Simulate lava damage for testing
        nextTickTime = GetTime() + LAVA_TICK_INTERVAL
        inLava = true
        timerFrame:Show()
        DEFAULT_CHAT_FRAME:AddMessage("LavaJump: Test timer started")
    elseif cmd == "reset" then
        nextTickTime = nil
        inLava = false
        timerFrame:Hide()
        DEFAULT_CHAT_FRAME:AddMessage("LavaJump: Timer reset")
    elseif cmd == "buffer" and arg then
        local newBuffer = tonumber(arg)
        if newBuffer and newBuffer >= 0 and newBuffer <= 5 then
            LATENCY_BUFFER = newBuffer
            DEFAULT_CHAT_FRAME:AddMessage(string.format("LavaJump: Latency buffer set to %.1fx", LATENCY_BUFFER))
        else
            DEFAULT_CHAT_FRAME:AddMessage("LavaJump: Buffer must be between 0 and 5")
        end
    else
        DEFAULT_CHAT_FRAME:AddMessage("LavaJump Timer Commands:")
        DEFAULT_CHAT_FRAME:AddMessage("/lj test - Start test timer")
        DEFAULT_CHAT_FRAME:AddMessage("/lj reset - Reset timer")
        DEFAULT_CHAT_FRAME:AddMessage("/lj buffer <number> - Set latency multiplier (default 1.5)")
        DEFAULT_CHAT_FRAME:AddMessage(string.format("Current buffer: %.1fx", LATENCY_BUFFER))
        DEFAULT_CHAT_FRAME:AddMessage("Drag the timer frame to reposition it")
        
        local _, _, latency = GetNetStats()
        if latency then
            DEFAULT_CHAT_FRAME:AddMessage(string.format("Current latency: %dms", latency))
        end
    end
end

DEFAULT_CHAT_FRAME:AddMessage("Lava Jump Timer loaded! Type /lj for commands")
