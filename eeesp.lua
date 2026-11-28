local PlayerVisualSection = visualsTab:Section({
    Name = "Player Visual",
    Side = "Left"
})

-- Renamed to ESPConfig so it doesn't shadow your top-level Config (which broke WorldVisuals)
local ESPConfig = {
    Enabled = false,
    TeamCheck = false,
    MaxDistance = 1500,
    FontSize = 13,
    Font = Enum.Font.GothamMedium,
    ShowDisplayName = false,

    Box = {
        Style = "Corner", -- "None", "Bounding", "Corner"
        Color = Color3.fromRGB(255, 255, 255),
        FillEnabled = false,
        FillColor = Color3.fromRGB(15, 15, 20),
        FillTransparency = 0.72,
    },
    Name = {
        Enabled = false,
        Color = Color3.fromRGB(255, 255, 255),
        FriendColor = Color3.fromRGB(110, 231, 183),
    },
    Healthbar = {
        Enabled = false,
        HealthText = false,
        Gradient = true,
        LowColor = Color3.fromRGB(239, 68, 68),
        MidColor = Color3.fromRGB(250, 204, 21),
        HighColor = Color3.fromRGB(52, 211, 153),
        FlatColor = Color3.fromRGB(52, 211, 153),
    },
    Weapon = {
        Enabled = false,
        Color = Color3.fromRGB(220, 220, 235),
    },
    Distance = {
        Enabled = false,
        Color = Color3.fromRGB(175, 175, 190),
    },
    Chams = {
        Enabled = false,
        Thermal = false,
        VisibleCheck = false,
        FillColor = Color3.fromRGB(235, 35, 55),
        FillTransparency = 0.65,
        OutlineColor = Color3.fromRGB(255, 255, 255),
        OutlineTransparency = 0.15,
    },
}

do
    local CoreGui = game:GetService("CoreGui")
    local LocalPlr = Players.LocalPlayer

    local function GetGuiRoot()
        if gethui then
            local ok, res = pcall(gethui)
            if ok and res then return res end
        end
        return CoreGui
    end

    local GuiRoot = GetGuiRoot()
    local oldHolder = GuiRoot:FindFirstChild("ESPHolder") or CoreGui:FindFirstChild("ESPHolder")
    if oldHolder then
        pcall(function() oldHolder:Destroy() end)
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "ESPHolder"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = GuiRoot

    local PlayerEntries = {}

    local function MakeFrame(parent, zIndex, bgColor, bgTrans)
        local f = Instance.new("Frame")
        f.BorderSizePixel = 0
        f.ZIndex = zIndex
        f.BackgroundColor3 = bgColor or Color3.new(1, 1, 1)
        f.BackgroundTransparency = bgTrans or 0
        f.Visible = false
        f.Parent = parent
        return f
    end

    local function MakeText(parent, zIndex)
        local lbl = Instance.new("TextLabel")
        lbl.BackgroundTransparency = 1
        lbl.Size = UDim2.fromOffset(220, 18)
        lbl.AnchorPoint = Vector2.new(0.5, 0)
        lbl.Font = ESPConfig.Font
        lbl.TextSize = ESPConfig.FontSize
        lbl.TextColor3 = Color3.new(1, 1, 1)
        lbl.TextStrokeTransparency = 1
        lbl.RichText = true
        lbl.ZIndex = zIndex
        lbl.Visible = false
        lbl.Parent = parent

        local stroke = Instance.new("UIStroke")
        stroke.Color = Color3.new(0, 0, 0)
        stroke.Thickness = 1
        stroke.Transparency = 0.15
        stroke.Parent = lbl

        return lbl
    end

    local function GetHealthColor(ratio)
        if not ESPConfig.Healthbar.Gradient then
            return ESPConfig.Healthbar.FlatColor
        end
        if ratio > 0.5 then
            return ESPConfig.Healthbar.MidColor:Lerp(ESPConfig.Healthbar.HighColor, (ratio - 0.5) * 2)
        else
            return ESPConfig.Healthbar.LowColor:Lerp(ESPConfig.Healthbar.MidColor, ratio * 2)
        end
    end

    local function SetEntryVisible(entry, state)
        if entry.IsVisible == state then return end
        entry.IsVisible = state

        entry.FillBox.Visible = state and ESPConfig.Box.FillEnabled
        entry.FullBoxOuter.Visible = state and ESPConfig.Box.Style == "Bounding"
        entry.FullBoxInner.Visible = state and ESPConfig.Box.Style == "Bounding"

        local showCorners = state and ESPConfig.Box.Style == "Corner"
        for i = 1, 8 do
            entry.CornerOutlines[i].Visible = showCorners
            entry.CornerLines[i].Visible = showCorners
        end

        entry.HealthBg.Visible = state and ESPConfig.Healthbar.Enabled
        entry.HealthText.Visible = state and ESPConfig.Healthbar.Enabled and ESPConfig.Healthbar.HealthText
        entry.NameLabel.Visible = state and ESPConfig.Name.Enabled
        entry.WeaponLabel.Visible = state and ESPConfig.Weapon.Enabled and entry.WeaponText ~= ""
        entry.DistanceLabel.Visible = state and ESPConfig.Distance.Enabled
        entry.Highlight.Enabled = state and ESPConfig.Chams.Enabled
    end

    local function ApplyEntryStyle(entry)
        local font = ESPConfig.Font
        local size = ESPConfig.FontSize

        entry.NameLabel.Font = font
        entry.NameLabel.TextSize = size
        entry.NameLabel.TextColor3 = ESPConfig.Name.Color

        entry.WeaponLabel.Font = font
        entry.WeaponLabel.TextSize = math.max(10, size - 1)
        entry.WeaponLabel.TextColor3 = ESPConfig.Weapon.Color

        entry.DistanceLabel.Font = font
        entry.DistanceLabel.TextSize = math.max(10, size - 1)
        entry.DistanceLabel.TextColor3 = ESPConfig.Distance.Color

        entry.HealthText.Font = font
        entry.HealthText.TextSize = math.max(9, size - 2)

        entry.FillBox.BackgroundColor3 = ESPConfig.Box.FillColor
        entry.FillBox.BackgroundTransparency = ESPConfig.Box.FillTransparency
        entry.FullBoxStroke.Color = ESPConfig.Box.Color

        for i = 1, 8 do
            entry.CornerLines[i].BackgroundColor3 = ESPConfig.Box.Color
        end

        entry.Highlight.FillColor = ESPConfig.Chams.FillColor
        entry.Highlight.OutlineColor = ESPConfig.Chams.OutlineColor
        entry.Highlight.DepthMode = ESPConfig.Chams.VisibleCheck
            and Enum.HighlightDepthMode.Occluded
            or Enum.HighlightDepthMode.AlwaysOnTop

        if not ESPConfig.Chams.Thermal then
            entry.Highlight.FillTransparency = ESPConfig.Chams.FillTransparency
            entry.Highlight.OutlineTransparency = ESPConfig.Chams.OutlineTransparency
        end
    end

    local function UpdateEquippedWeapon(entry, char)
        if not char then
            entry.WeaponText = ""
            entry.WeaponLabel.Text = ""
            return
        end
        local tool = char:FindFirstChildOfClass("Tool")
        entry.WeaponText = tool and tool.Name or ""
        entry.WeaponLabel.Text = entry.WeaponText
    end

    local function RemovePlayerESP(plr)
        local entry = PlayerEntries[plr]
        if not entry then return end
        for _, conn in ipairs(entry.Conns) do
            pcall(function() conn:Disconnect() end)
        end
        if entry.Folder then
            pcall(function() entry.Folder:Destroy() end)
        end
        PlayerEntries[plr] = nil
    end

    local function CreatePlayerESP(plr)
        if plr == LocalPlr then return end
        RemovePlayerESP(plr)

        local folder = Instance.new("Folder")
        folder.Name = plr.Name
        folder.Parent = ScreenGui

        -- Fill box
        local fillBox = MakeFrame(folder, 1, ESPConfig.Box.FillColor, ESPConfig.Box.FillTransparency)

        -- Bounding box (outer 1px black + inner 1px colored)
        local fullOuter = MakeFrame(folder, 2, Color3.new(0, 0, 0), 1)
        local fullOuterStroke = Instance.new("UIStroke")
        fullOuterStroke.Color = Color3.new(0, 0, 0)
        fullOuterStroke.Thickness = 1
        fullOuterStroke.LineJoinMode = Enum.LineJoinMode.Miter
        fullOuterStroke.Parent = fullOuter

        local fullInner = MakeFrame(folder, 3, Color3.new(1, 1, 1), 1)
        local fullInnerStroke = Instance.new("UIStroke")
        fullInnerStroke.Color = ESPConfig.Box.Color
        fullInnerStroke.Thickness = 1
        fullInnerStroke.LineJoinMode = Enum.LineJoinMode.Miter
        fullInnerStroke.Parent = fullInner

        -- 8 corner brackets (outlines at ZIndex 2, colored lines at ZIndex 3 for seamless corners)
        local cornerOutlines = {}
        local cornerLines = {}
        for i = 1, 8 do
            cornerOutlines[i] = MakeFrame(folder, 2, Color3.new(0, 0, 0), 0)
            cornerLines[i] = MakeFrame(folder, 3, ESPConfig.Box.Color, 0)
        end

        -- Healthbar (1px black container + 2px inner fill)
        local healthBg = MakeFrame(folder, 2, Color3.new(0, 0, 0), 0)
        local healthFill = MakeFrame(healthBg, 3, ESPConfig.Healthbar.HighColor, 0)
        healthFill.Visible = true

        local healthText = MakeText(folder, 4)
        healthText.AnchorPoint = Vector2.new(1, 0.5)
        healthText.Size = UDim2.fromOffset(48, 14)
        healthText.TextXAlignment = Enum.TextXAlignment.Right

        -- Labels
        local nameLabel = MakeText(folder, 4)
        nameLabel.AnchorPoint = Vector2.new(0.5, 1)
        nameLabel.TextYAlignment = Enum.TextYAlignment.Bottom

        local weaponLabel = MakeText(folder, 4)
        weaponLabel.TextYAlignment = Enum.TextYAlignment.Top

        local distanceLabel = MakeText(folder, 4)
        distanceLabel.TextYAlignment = Enum.TextYAlignment.Top

        -- Chams
        local highlight = Instance.new("Highlight")
        highlight.Enabled = false
        highlight.FillColor = ESPConfig.Chams.FillColor
        highlight.OutlineColor = ESPConfig.Chams.OutlineColor
        highlight.FillTransparency = ESPConfig.Chams.FillTransparency
        highlight.OutlineTransparency = ESPConfig.Chams.OutlineTransparency
        highlight.Parent = folder

        local entry = {
            Player = plr,
            Folder = folder,
            Conns = {},
            IsVisible = false,
            WeaponText = "",
            Character = nil,
            Humanoid = nil,
            HRP = nil,

            FillBox = fillBox,
            FullBoxOuter = fullOuter,
            FullBoxInner = fullInner,
            FullBoxStroke = fullInnerStroke,
            CornerOutlines = cornerOutlines,
            CornerLines = cornerLines,
            HealthBg = healthBg,
            HealthFill = healthFill,
            HealthText = healthText,
            NameLabel = nameLabel,
            WeaponLabel = weaponLabel,
            DistanceLabel = distanceLabel,
            Highlight = highlight,
        }

        local function BindCharacter(char)
            entry.Character = char
            entry.Humanoid = char and char:FindFirstChildOfClass("Humanoid")
            entry.HRP = char and char:FindFirstChild("HumanoidRootPart")
            highlight.Adornee = char

            if entry._toolAdded then entry._toolAdded:Disconnect() end
            if entry._toolRemoved then entry._toolRemoved:Disconnect() end

            if char then
                UpdateEquippedWeapon(entry, char)
                entry._toolAdded = char.ChildAdded:Connect(function(child)
                    if child:IsA("Tool") then
                        UpdateEquippedWeapon(entry, char)
                    elseif child:IsA("Humanoid") then
                        entry.Humanoid = child
                    elseif child.Name == "HumanoidRootPart" then
                        entry.HRP = child
                    end
                end)
                entry._toolRemoved = char.ChildRemoved:Connect(function(child)
                    if child:IsA("Tool") then
                        task.defer(UpdateEquippedWeapon, entry, char)
                    end
                end)
                table.insert(entry.Conns, entry._toolAdded)
                table.insert(entry.Conns, entry._toolRemoved)
            end
        end

        if plr.Character then
            BindCharacter(plr.Character)
        end

        table.insert(entry.Conns, plr.CharacterAdded:Connect(function(char)
            task.defer(BindCharacter, char)
        end))

        ApplyEntryStyle(entry)
        PlayerEntries[plr] = entry
    end

    local function RefreshAllESPStyles()
        for _, entry in pairs(PlayerEntries) do
            ApplyEntryStyle(entry)
            if not ESPConfig.Enabled then
                SetEntryVisible(entry, false)
            end
        end
    end

    getgenv().RefreshValleyESP = RefreshAllESPStyles

    for _, p in ipairs(SafeGetPlayers()) do
        if p ~= LocalPlr then
            CreatePlayerESP(p)
        end
    end

    TrackConnection(Players.PlayerAdded:Connect(CreatePlayerESP))
    TrackConnection(Players.PlayerRemoving:Connect(RemovePlayerESP))

    local function SetCornerSegment(entry, idx, x, y, w, h)
        local line = entry.CornerLines[idx]
        local outline = entry.CornerOutlines[idx]
        line.Position = UDim2.fromOffset(x, y)
        line.Size = UDim2.fromOffset(w, h)
        outline.Position = UDim2.fromOffset(x - 1, y - 1)
        outline.Size = UDim2.fromOffset(w + 2, h + 2)
    end

    TrackConnection(RunService.RenderStepped:Connect(LPH_NO_VIRTUALIZE(function()
        if not ESPConfig.Enabled then
            for _, entry in pairs(PlayerEntries) do
                SetEntryVisible(entry, false)
            end
            return
        end

        local cam = Workspace.CurrentCamera
        if not cam then return end

        local viewportY = cam.ViewportSize.Y
        local fovRad = math.tan(math.rad(cam.FieldOfView * 0.5))
        local camPos = cam.CFrame.Position
        local thermalPulse = ESPConfig.Chams.Thermal and ((math.sin(tick() * 3) + 1) * 0.5) or nil

        for plr, entry in pairs(PlayerEntries) do
            local char = plr.Character
            if not char or not char.Parent then
                SetEntryVisible(entry, false)
                continue
            end

            if ESPConfig.TeamCheck and LocalPlr.Team and plr.Team == LocalPlr.Team then
                SetEntryVisible(entry, false)
                continue
            end

            local hrp = entry.HRP
            local hum = entry.Humanoid
            if not hrp or not hrp.Parent then
                hrp = char:FindFirstChild("HumanoidRootPart")
                entry.HRP = hrp
            end
            if not hum or not hum.Parent then
                hum = char:FindFirstChildOfClass("Humanoid")
                entry.Humanoid = hum
            end

            if not hrp or not hum or hum.Health <= 0 then
                SetEntryVisible(entry, false)
                continue
            end

            local dist = (camPos - hrp.Position).Magnitude
            if dist > ESPConfig.MaxDistance then
                SetEntryVisible(entry, false)
                continue
            end

            local pos, onScreen = cam:WorldToViewportPoint(hrp.Position)
            if not onScreen or pos.Z <= 0.5 then
                SetEntryVisible(entry, false)
                continue
            end

            -- Pixel-snapped, FOV-accurate bounding box
            local scale = viewportY / (2 * pos.Z * fovRad)
            local h = math.clamp(math.floor(5.6 * scale), 14, 700)
            local w = math.clamp(math.floor(h * 0.60), 10, 440)
            local left = math.floor(pos.X - w * 0.5)
            local top = math.floor(pos.Y - h * 0.5)
            local centerX = math.floor(left + w * 0.5)

            -- Force visibility update every frame for active toggles
            entry.IsVisible = true

            -- Fill
            if ESPConfig.Box.FillEnabled and ESPConfig.Box.Style ~= "None" then
                entry.FillBox.Visible = true
                entry.FillBox.Position = UDim2.fromOffset(left, top)
                entry.FillBox.Size = UDim2.fromOffset(w, h)
            else
                entry.FillBox.Visible = false
            end

            -- Boxes
            if ESPConfig.Box.Style == "Bounding" then
                entry.FullBoxOuter.Visible = true
                entry.FullBoxOuter.Position = UDim2.fromOffset(left - 1, top - 1)
                entry.FullBoxOuter.Size = UDim2.fromOffset(w + 2, h + 2)

                entry.FullBoxInner.Visible = true
                entry.FullBoxInner.Position = UDim2.fromOffset(left, top)
                entry.FullBoxInner.Size = UDim2.fromOffset(w, h)

                for i = 1, 8 do
                    entry.CornerOutlines[i].Visible = false
                    entry.CornerLines[i].Visible = false
                end
            elseif ESPConfig.Box.Style == "Corner" then
                entry.FullBoxOuter.Visible = false
                entry.FullBoxInner.Visible = false

                local cW = math.max(3, math.floor(w * 0.25))
                local cH = math.max(3, math.floor(h * 0.22))

                SetCornerSegment(entry, 1, left, top, cW, 1)                   -- Top-Left H
                SetCornerSegment(entry, 2, left, top, 1, cH)                   -- Top-Left V
                SetCornerSegment(entry, 3, left + w - cW, top, cW, 1)          -- Top-Right H
                SetCornerSegment(entry, 4, left + w - 1, top, 1, cH)           -- Top-Right V
                SetCornerSegment(entry, 5, left, top + h - 1, cW, 1)           -- Bottom-Left H
                SetCornerSegment(entry, 6, left, top + h - cH, 1, cH)          -- Bottom-Left V
                SetCornerSegment(entry, 7, left + w - cW, top + h - 1, cW, 1)  -- Bottom-Right H
                SetCornerSegment(entry, 8, left + w - 1, top + h - cH, 1, cH)  -- Bottom-Right V

                for i = 1, 8 do
                    entry.CornerOutlines[i].Visible = true
                    entry.CornerLines[i].Visible = true
                end
            else
                entry.FullBoxOuter.Visible = false
                entry.FullBoxInner.Visible = false
                for i = 1, 8 do
                    entry.CornerOutlines[i].Visible = false
                    entry.CornerLines[i].Visible = false
                end
            end

            -- Healthbar
            if ESPConfig.Healthbar.Enabled then
                local maxHp = math.max(1, hum.MaxHealth)
                local hp = math.clamp(hum.Health, 0, maxHp)
                local ratio = hp / maxHp
                local fillH = math.clamp(math.floor(h * ratio + 0.5), 0, h)
                local hpColor = GetHealthColor(ratio)

                entry.HealthBg.Visible = true
                entry.HealthBg.Position = UDim2.fromOffset(left - 6, top - 1)
                entry.HealthBg.Size = UDim2.fromOffset(4, h + 2)

                entry.HealthFill.Position = UDim2.fromOffset(1, 1 + (h - fillH))
                entry.HealthFill.Size = UDim2.fromOffset(2, fillH)
                entry.HealthFill.BackgroundColor3 = hpColor

                if ESPConfig.Healthbar.HealthText and ratio < 0.995 then
                    entry.HealthText.Visible = true
                    entry.HealthText.Text = tostring(math.floor(hp + 0.5))
                    entry.HealthText.TextColor3 = hpColor
                    entry.HealthText.Position = UDim2.fromOffset(left - 9, math.clamp(top + (h - fillH), top, top + h))
                elseif ESPConfig.Healthbar.HealthText then
                    entry.HealthText.Visible = true
                    entry.HealthText.Text = tostring(math.floor(hp + 0.5))
                    entry.HealthText.TextColor3 = hpColor
                    entry.HealthText.Position = UDim2.fromOffset(left - 9, top)
                else
                    entry.HealthText.Visible = false
                end
            else
                entry.HealthBg.Visible = false
                entry.HealthText.Visible = false
            end

            -- Name
            if ESPConfig.Name.Enabled then
                entry.NameLabel.Visible = true
                local displayName = ESPConfig.ShowDisplayName and plr.DisplayName or plr.Name
                if LocalPlr:IsFriendsWith(plr.UserId) then
                    local fc = ESPConfig.Name.FriendColor
                    entry.NameLabel.Text = string.format(
                        '<font color="rgb(%d,%d,%d)">[F]</font> %s',
                        math.floor(fc.R * 255), math.floor(fc.G * 255), math.floor(fc.B * 255),
                        displayName
                    )
                else
                    entry.NameLabel.Text = displayName
                end
                entry.NameLabel.Position = UDim2.fromOffset(centerX, top - 3)
            else
                entry.NameLabel.Visible = false
            end

            -- Bottom labels stacked cleanly without overlap
            local bottomY = top + h + 3
            if ESPConfig.Weapon.Enabled and entry.WeaponText ~= "" then
                entry.WeaponLabel.Visible = true
                entry.WeaponLabel.Position = UDim2.fromOffset(centerX, bottomY)
                bottomY = bottomY + ESPConfig.FontSize + 2
            else
                entry.WeaponLabel.Visible = false
            end

            if ESPConfig.Distance.Enabled then
                entry.DistanceLabel.Visible = true
                entry.DistanceLabel.Text = string.format("%d st", math.floor(dist + 0.5))
                entry.DistanceLabel.Position = UDim2.fromOffset(centerX, bottomY)
            else
                entry.DistanceLabel.Visible = false
            end

            -- Chams
            if ESPConfig.Chams.Enabled then
                entry.Highlight.Adornee = char
                entry.Highlight.Enabled = true
                if thermalPulse then
                    entry.Highlight.FillTransparency = 0.25 + (thermalPulse * 0.55)
                    entry.Highlight.OutlineTransparency = 0.05 + (thermalPulse * 0.45)
                end
            else
                entry.Highlight.Enabled = false
            end
        end
    end)))
end

-- UI Controls
PlayerVisualSection:Toggle({
    Name = "ESP",
    Default = ESPConfig.Enabled,
    Callback = function(state)
        ESPConfig.Enabled = state
        if getgenv().RefreshValleyESP then getgenv().RefreshValleyESP() end
    end
})

PlayerVisualSection:Dropdown({
    Name = "Box Style",
    Options = {"Corner", "Bounding", "None"},
    Default = ESPConfig.Box.Style,
    Callback = function(state)
        ESPConfig.Box.Style = state
        if getgenv().RefreshValleyESP then getgenv().RefreshValleyESP() end
    end
})

PlayerVisualSection:Toggle({
    Name = "Filled Boxes",
    Default = ESPConfig.Box.FillEnabled,
    Callback = function(state)
        ESPConfig.Box.FillEnabled = state
        if getgenv().RefreshValleyESP then getgenv().RefreshValleyESP() end
    end
})

PlayerVisualSection:Colorpicker({
    Name = "Box Color",
    Default = ESPConfig.Box.Color,
    Callback = function(color)
        ESPConfig.Box.Color = color
        if getgenv().RefreshValleyESP then getgenv().RefreshValleyESP() end
    end
})

PlayerVisualSection:Toggle({
    Name = "Names",
    Default = ESPConfig.Name.Enabled,
    Callback = function(state)
        ESPConfig.Name.Enabled = state
        if getgenv().RefreshValleyESP then getgenv().RefreshValleyESP() end
    end
})

PlayerVisualSection:Toggle({
    Name = "Health Bars",
    Default = ESPConfig.Healthbar.Enabled,
    Callback = function(state)
        ESPConfig.Healthbar.Enabled = state
        if getgenv().RefreshValleyESP then getgenv().RefreshValleyESP() end
    end
})

PlayerVisualSection:Toggle({
    Name = "Health Text",
    Default = ESPConfig.Healthbar.HealthText,
    Callback = function(state)
        ESPConfig.Healthbar.HealthText = state
        if getgenv().RefreshValleyESP then getgenv().RefreshValleyESP() end
    end
})

PlayerVisualSection:Toggle({
    Name = "Gradient Health Bar",
    Default = ESPConfig.Healthbar.Gradient,
    Callback = function(state)
        ESPConfig.Healthbar.Gradient = state
    end
})

PlayerVisualSection:Toggle({
    Name = "Weapons",
    Default = ESPConfig.Weapon.Enabled,
    Callback = function(state)
        ESPConfig.Weapon.Enabled = state
        if getgenv().RefreshValleyESP then getgenv().RefreshValleyESP() end
    end
})

PlayerVisualSection:Toggle({
    Name = "Distance",
    Default = ESPConfig.Distance.Enabled,
    Callback = function(state)
        ESPConfig.Distance.Enabled = state
        if getgenv().RefreshValleyESP then getgenv().RefreshValleyESP() end
    end
})

PlayerVisualSection:Toggle({
    Name = "Chams",
    Default = ESPConfig.Chams.Enabled,
    Callback = function(state)
        ESPConfig.Chams.Enabled = state
        if getgenv().RefreshValleyESP then getgenv().RefreshValleyESP() end
    end
})

PlayerVisualSection:Colorpicker({
    Name = "Chams Color",
    Default = ESPConfig.Chams.FillColor,
    Callback = function(color)
        ESPConfig.Chams.FillColor = color
        if getgenv().RefreshValleyESP then getgenv().RefreshValleyESP() end
    end
})

PlayerVisualSection:Toggle({
    Name = "Thermal Chams",
    Default = ESPConfig.Chams.Thermal,
    Callback = function(state)
        ESPConfig.Chams.Thermal = state
        if getgenv().RefreshValleyESP then getgenv().RefreshValleyESP() end
    end
})

PlayerVisualSection:Toggle({
    Name = "Chams Visible Check",
    Default = ESPConfig.Chams.VisibleCheck,
    Callback = function(state)
        ESPConfig.Chams.VisibleCheck = state
        if getgenv().RefreshValleyESP then getgenv().RefreshValleyESP() end
    end
})

PlayerVisualSection:Dropdown({
    Name = "Text Font",
    Options = {"GothamMedium", "Code", "RobotoMono", "SourceSans", "BuilderSans", "Arcade"},
    Default = "GothamMedium",
    Callback = function(state)
        local ok, f = pcall(function() return Enum.Font[state] end)
        ESPConfig.Font = (ok and f) or Enum.Font.GothamMedium
        if getgenv().RefreshValleyESP then getgenv().RefreshValleyESP() end
    end
})

PlayerVisualSection:Slider({
    Name = "Text Size",
    Min = 10,
    Max = 18,
    Default = ESPConfig.FontSize,
    Callback = function(state)
        ESPConfig.FontSize = state
        if getgenv().RefreshValleyESP then getgenv().RefreshValleyESP() end
    end
})

PlayerVisualSection:Slider({
    Name = "Max Render Distance",
    Min = 50,
    Max = 5000,
    Default = ESPConfig.MaxDistance,
    Callback = function(state)
        ESPConfig.MaxDistance = state
    end
})
