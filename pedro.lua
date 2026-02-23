local addonName, ns = ...

local pedro_spells = {
    [2825]   = 40,  -- Bloodlust
    -- [6673]   = 120, -- Battle Shout (Rank 1)
}

local pedro_width  = 192  
local pedro_height = 192  
local big_pedro_width   = 1024 
local big_pedro_height  = 2048 

local pedro_columns_to_use = 4   
local pedro_frames   = 32  
local pedro_fps            = 8

local pedro_sound = "Interface\\AddOns\\SpellSoundCast\\Media\\pedro.mp3"
local pedro_texture = "Interface\\AddOns\\SpellSoundCast\\Media\\pedro"

local pedro_overlay = CreateFrame("Frame", "SpellSoundMinimapOverlay", Minimap)
pedro_overlay:SetAllPoints(Minimap)
pedro_overlay:SetFrameStrata("MEDIUM")
pedro_overlay:SetFrameLevel(200)
pedro_overlay:Hide()

local texture = pedro_overlay:CreateTexture(nil, "OVERLAY")
texture:SetAllPoints(pedro_overlay)
texture:SetTexture(pedro_texture, "CLAMP", "CLAMP") 
-- texture:SetBlendMode("ADD") 

local elapsedTotal = 0
local currentPedro = 0

local function UpdatePedro(self, elapsed)
    elapsedTotal = elapsedTotal + elapsed
    
    if elapsedTotal >= (1 / pedro_fps) then
        elapsedTotal = 0
        currentPedro = (currentPedro + 1) % pedro_frames
        
        local row = math.floor(currentPedro / pedro_columns_to_use)
        local col = currentPedro % pedro_columns_to_use
        
        local left   = (col * pedro_width) / big_pedro_width
        local right  = ((col + 1) * pedro_width) / big_pedro_width
        local top    = (row * pedro_height) / big_pedro_height
        local bottom = ((row + 1) * pedro_height) / big_pedro_height
        
        texture:SetTexCoord(left, right, top, bottom)
    end
end

local pedroHandle, pedroSoundHandle

local function StopPedro()
    pedro_overlay:Hide()
    pedro_overlay:SetScript("OnUpdate", nil)
    if pedroSoundHandle then StopSound(pedroSoundHandle) pedroSoundHandle = nil end
    if pedroHandle then pedroHandle:Cancel() pedroHandle = nil end
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
frame:SetScript("OnEvent", function(self, event, unit, _, spellID)
    if (unit == "player" or unit == "pet") and pedro_spells[spellID] then
        StopPedro()
        local willPlay, handle = PlaySoundFile(pedro_sound, "Master")
        if willPlay then pedroSoundHandle = handle end
        
        currentPedro = 0
        elapsedTotal = 0
        pedro_overlay:Show()
        pedro_overlay:SetScript("OnUpdate", UpdatePedro)
        pedroHandle = C_Timer.NewTimer(pedro_spells[spellID], StopPedro)
    end
end)
