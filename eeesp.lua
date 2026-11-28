-- // amklan sex esp by havez on the beat ayyy

local ESP_VERSION = "4.0.0"

do
    local cloneref = (typeof(cloneref) == "function" and cloneref) or function(obj) return obj end
    local PlayersSvc = cloneref(game:GetService("Players"))
    local RunService = cloneref(game:GetService("RunService"))
    local Workspace = cloneref(game:GetService("Workspace"))
    local UserInputService = cloneref(game:GetService("UserInputService"))
    local CoreGui = nil
    pcall(function() CoreGui = cloneref(game:GetService("CoreGui")) end)

    local genv = (typeof(getgenv) == "function" and getgenv()) or _G
    local LocalPlayer = PlayersSvc.LocalPlayer
    if not LocalPlayer then
        local t0 = os.clock()
        while not PlayersSvc.LocalPlayer and (os.clock() - t0) < 10 do
            task.wait(0.1)
        end
        LocalPlayer = PlayersSvc.LocalPlayer
    end

    local prevDestroy = rawget(genv, "ESP_Destroy")
    genv.ESP_Destroy = nil
    if type(prevDestroy) == "function" then
        pcall(prevDestroy)
    end
    local prevBind = rawget(genv, "ESP_RenderBindName")
    if type(prevBind) == "string" and prevBind ~= "" then
        pcall(function() RunService:UnbindFromRenderStep(prevBind) end)
    end
    genv.ESP_RenderBindName = nil
    genv.__ExternalESPStandalone = true

    local function GetSafeContainerRoot()
        if typeof(gethui) == "function" then
            local ok, res = pcall(gethui)
            if ok and typeof(res) == "Instance" then return res end
        end
        if typeof(CoreGui) == "Instance" then
            local ok = pcall(function()
                local f = Instance.new("Folder")
                f.Parent = CoreGui
                f:Destroy()
            end)
            if ok then return CoreGui end
        end
        if LocalPlayer then
            return LocalPlayer:FindFirstChildOfClass("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui", 10)
        end
        return nil
    end

    local SafeRoot = GetSafeContainerRoot()
    pcall(function()
        local roots = { SafeRoot, CoreGui, LocalPlayer and LocalPlayer:FindFirstChildOfClass("PlayerGui"), Workspace }
        for _, r in ipairs(roots) do
            if typeof(r) == "Instance" then
                for _, child in ipairs(r:GetChildren()) do
                    local n = child.Name
                    if string.sub(n, 1, 8) == "EXT_ESP_" or string.sub(n, 1, 10) == "EXT_Chams_" or string.sub(n, 1, 7) == "ESP_HL_" then
                        pcall(function() child:Destroy() end)
                    end
                end
            end
        end
    end)

    local function DeepCopy(tbl)
        if type(tbl) ~= "table" then return tbl end
        local out = {}
        for k, v in pairs(tbl) do
            out[k] = type(v) == "table" and DeepCopy(v) or v
        end
        return out
    end

    local function FillDefaults(target, defaults)
        if type(target) ~= "table" or type(defaults) ~= "table" then return end
        for k, v in pairs(defaults) do
            if target[k] == nil then
                target[k] = type(v) == "table" and DeepCopy(v) or v
            elseif type(v) == "table" and type(target[k]) == "table" then
                FillDefaults(target[k], v)
            end
        end
    end

    local DEFAULT_CONFIG = {
        Enabled = false,
        TeamCheck = false,
        MaxDistance = 600,
        RefreshRate = 60,
        FontSize = 13,
        FadeOut = {
            OnDistance = false,
            OnDeath = true,
            OnLeave = false,
        },
        Options = {
            Teamcheck = true,
            TeamcheckRGB = Color3.fromRGB(70, 225, 145),
            Friendcheck = true,
            FriendcheckRGB = Color3.fromRGB(95, 190, 255),
            Highlight = false,
            HighlightRGB = Color3.fromRGB(255, 65, 85),
        },
        Drawing = {
            Chams = {
                Enabled = false,
                Mode = "Highlight",
                Thermal = false,
                VisibleCheck = false,
                FillRGB = Color3.fromRGB(139, 92, 246),
                VisibleRGB = Color3.fromRGB(52, 255, 140),
                OutlineRGB = Color3.fromRGB(255, 255, 255),
                Fill_Transparency = 50,
                Outline_Transparency = 10,
                PulseSpeed = 2.5,
            },
            Boxes = {
                Thickness = 1,
                Animate = false,
                RotationSpeed = 180,
                Gradient = false,
                GradientRGB1 = Color3.fromRGB(139, 92, 246),
                GradientRGB2 = Color3.fromRGB(45, 212, 191),
                Filled = {
                    Enabled = false,
                    Transparency = 0.78,
                    RGB = Color3.fromRGB(14, 14, 22),
                },
                Full = {
                    Enabled = false,
                    Transparency = 0,
                    RGB = Color3.fromRGB(255, 255, 255),
                },
                Bounding = {
                    Enabled = false,
                    Transparency = 0,
                    RGB = Color3.fromRGB(255, 255, 255),
                },
                Corner = {
                    Enabled = false,
                    Transparency = 0,
                    RGB = Color3.fromRGB(255, 255, 255),
                },
            },
            Healthbar = {
                Enabled = false,
                HealthText = false,
                Lerp = true,
                Width = 3,
                Transparency = 0,
                HealthTextTransparency = 0,
                HealthTextRGB = Color3.fromRGB(255, 255, 255),
                Gradient = true,
                GradientRGB1 = Color3.fromRGB(255, 55, 75),
                GradientRGB2 = Color3.fromRGB(55, 245, 135),
            },
            Names = {
                Enabled = false,
                Transparency = 0,
                RGB = Color3.fromRGB(255, 255, 255),
            },
            Distances = {
                Enabled = false,
                Position = "Bottom",
                Transparency = 0,
                RGB = Color3.fromRGB(192, 202, 220),
            },
            Weapons = {
                Enabled = false,
                WeaponTextRGB = Color3.fromRGB(172, 142, 255),
                RGB = Color3.fromRGB(172, 142, 255),
                Transparency = 0,
            },
            Flags = {
                Enabled = false,
                RGB = Color3.fromRGB(224, 228, 242),
            },
            HeadDot = {
                Enabled = false,
                RGB = Color3.fromRGB(255, 90, 110),
                Radius = 3,
                Transparency = 0,
            },
            Tracers = {
                Enabled = false,
                RGB = Color3.fromRGB(255, 255, 255),
                Thickness = 1.5,
                Transparency = 0,
                Origin = "Bottom",
            },
            Skeleton = {
                Enabled = false,
                RGB = Color3.fromRGB(255, 255, 255),
                Thickness = 1.4,
                Transparency = 0,
            },
            Arrows = {
                Enabled = false,
                RGB = Color3.fromRGB(255, 75, 95),
                Size = 16,
                Distance = 140,
                Transparency = 0,
                Outlined = true,
            },
        },
    }

    local LocalConfig = DeepCopy(DEFAULT_CONFIG)

    local function ResolveHubConfig()
        local getter = rawget(genv, "ESP_ConfigGetter")
        if type(getter) == "function" then
            local ok, tbl = pcall(getter)
            if ok and type(tbl) == "table" then
                FillDefaults(tbl, DEFAULT_CONFIG)
                return tbl
            end
        end
        local c = rawget(genv, "Config")
        if type(c) == "table" and type(c.ESP) == "table" then
            FillDefaults(c.ESP, DEFAULT_CONFIG)
            return c.ESP
        end
        return nil
    end

    local ActiveConfig = ResolveHubConfig() or LocalConfig
    local ConfigProxy = setmetatable({}, {
        __index = function(_, key)
            local live = ResolveHubConfig() or ActiveConfig
            return live[key]
        end,
        __newindex = function(_, key, value)
            local live = ResolveHubConfig() or ActiveConfig
            live[key] = value
        end,
    })

    local function GetCfg()
        return ResolveHubConfig() or ActiveConfig
    end

    local Connections = {}
    local Destroyed = false
    local Registry = {}

    local function Track(conn)
        if typeof(conn) == "RBXScriptConnection" then
            table.insert(Connections, conn)
        end
        return conn
    end

    local function Clamp01(v)
        local n = tonumber(v) or 0
        if n < 0 then return 0 elseif n > 1 then return 1 end
        return n
    end

    local function ToTransparency(val)
        local n = tonumber(val) or 0
        if n > 1 then n = n / 100 end
        return Clamp01(n)
    end

    local function Make(className, props, parent)
        local inst = Instance.new(className)
        if props then
            for k, v in pairs(props) do
                inst[k] = v
            end
        end
        if parent then inst.Parent = parent end
        return inst
    end

    local ChamsFolder = Make("Folder", {
        Name = "EXT_Chams_" .. tostring(math.random(100000, 999999)),
    })
    if not pcall(function() ChamsFolder.Parent = CoreGui or SafeRoot end) or not ChamsFolder.Parent then
        pcall(function() ChamsFolder.Parent = Workspace end)
    end

    local IsTouchOnly = false
    pcall(function() IsTouchOnly = UserInputService.TouchEnabled == true and UserInputService.KeyboardEnabled ~= true end)

    local function ProbeDrawing()
        if IsTouchOnly then return false end
        if type(Drawing) ~= "table" or type(Drawing.new) ~= "function" then return false end
        local ok, probe = pcall(Drawing.new, "Square")
        if not ok or not probe then return false end
        local okProp = pcall(function() probe.Visible = false end)
        pcall(function()
            if probe.Remove then probe:Remove() elseif probe.Destroy then probe:Destroy() end
        end)
        return okProp
    end

    local HasDrawing = ProbeDrawing()
    local DrawingFont = (typeof(Drawing) == "table" and Drawing.Fonts and (Drawing.Fonts.UI or Drawing.Fonts.System or Drawing.Fonts.Plex)) or 0
    local FallbackGui
    if not HasDrawing then
        FallbackGui = Make("ScreenGui", {
            Name = "EXT_ESP_2D",
            IgnoreGuiInset = true,
            ResetOnSpawn = false,
            ZIndexBehavior = Enum.ZIndexBehavior.Global,
        })
        local parent = SafeRoot
        if typeof(gethui) == "function" then
            local ok, hui = pcall(gethui)
            if ok and typeof(hui) == "Instance" then parent = hui end
        end
        if not parent and LocalPlayer then parent = LocalPlayer:FindFirstChildOfClass("PlayerGui") end
        if parent then pcall(function() FallbackGui.Parent = parent end) end
        if not FallbackGui.Parent then pcall(function() FallbackGui.Parent = Workspace end) end
    end

    local FrameDrawing = {}
    FrameDrawing.__index = FrameDrawing

    local function SyncLine(obj)
        local root = obj._root
        if not root then return end
        local props = obj._props
        local from = props.From or Vector2.zero
        local to = props.To or Vector2.zero
        local dx, dy = to.X - from.X, to.Y - from.Y
        local len = math.sqrt(dx * dx + dy * dy)
        root.AnchorPoint = Vector2.new(0.5, 0.5)
        root.Position = UDim2.fromOffset((from.X + to.X) * 0.5, (from.Y + to.Y) * 0.5)
        root.Size = UDim2.fromOffset(math.max(len, 0.1), math.max(tonumber(props.Thickness) or 1, 1))
        root.Rotation = math.deg(math.atan2(dy, dx))
    end

    local function SyncTriangle(obj)
        local root = obj._root
        if not root then return end
        local props = obj._props
        local a, b, c = props.PointA, props.PointB, props.PointC
        if not (a and b and c) then return end
        local minX = math.min(a.X, b.X, c.X)
        local maxX = math.max(a.X, b.X, c.X)
        local minY = math.min(a.Y, b.Y, c.Y)
        local maxY = math.max(a.Y, b.Y, c.Y)
        root.Position = UDim2.fromOffset((minX + maxX) * 0.5, (minY + maxY) * 0.5)
        root.Size = UDim2.fromOffset(math.max(maxX - minX, 1), math.max(maxY - minY, 1))
        local baseX, baseY = (b.X + c.X) * 0.5, (b.Y + c.Y) * 0.5
        root.Rotation = math.deg(math.atan2(a.Y - baseY, a.X - baseX)) + 90
    end

    function FrameDrawing:_apply(key, value)
        local root, stroke, props = self._root, self._stroke, self._props
        if not root then return end
        if key == "Visible" then
            root.Visible = value == true
            return
        end
        if key == "ZIndex" then
            root.ZIndex = tonumber(value) or 1
            return
        end
        if self._kind == "Line" then
            if key == "From" or key == "To" or key == "Thickness" then
                SyncLine(self)
            elseif key == "Color" then
                root.BackgroundColor3 = value
            elseif key == "Transparency" then
                root.BackgroundTransparency = Clamp01(value)
            end
            return
        end
        if self._kind == "Triangle" then
            if key == "PointA" or key == "PointB" or key == "PointC" then
                SyncTriangle(self)
            elseif key == "Color" then
                root.TextColor3 = value
            elseif key == "Transparency" then
                root.TextTransparency = Clamp01(value)
            end
            return
        end
        if self._kind == "Text" then
            if key == "Text" then
                root.Text = tostring(value)
            elseif key == "Size" then
                root.TextSize = math.max(1, math.floor(tonumber(value) or 13))
            elseif key == "Color" then
                root.TextColor3 = value
            elseif key == "Transparency" then
                local tr = Clamp01(value)
                root.TextTransparency = tr
                if stroke and stroke.Enabled then stroke.Transparency = tr end
            elseif key == "Center" then
                root.AnchorPoint = value and Vector2.new(0.5, 0) or Vector2.new(0, 0)
                root.TextXAlignment = value and Enum.TextXAlignment.Center or Enum.TextXAlignment.Left
            elseif key == "Outline" then
                if stroke then stroke.Enabled = value == true end
            elseif key == "OutlineColor" then
                if stroke then stroke.Color = value end
            elseif key == "Position" then
                root.Position = UDim2.fromOffset(value.X, value.Y)
            end
            return
        end
        if key == "Position" then
            root.Position = UDim2.fromOffset(value.X, value.Y)
        elseif key == "Size" then
            root.Size = UDim2.fromOffset(math.max(value.X, 0.1), math.max(value.Y, 0.1))
        elseif key == "Radius" then
            local r = math.max(tonumber(value) or 1, 0.5)
            root.Size = UDim2.fromOffset(r * 2, r * 2)
        elseif key == "Color" then
            root.BackgroundColor3 = value
            if stroke then stroke.Color = value end
        elseif key == "Transparency" then
            local tr = Clamp01(value)
            root.BackgroundTransparency = props.Filled and tr or 1
            if stroke then stroke.Transparency = props.Filled and 1 or tr end
        elseif key == "Thickness" then
            if stroke then stroke.Thickness = math.max(tonumber(value) or 1, 1) end
        elseif key == "Filled" then
            local tr = Clamp01(props.Transparency or 0)
            root.BackgroundTransparency = value and tr or 1
            if stroke then stroke.Transparency = value and 1 or tr end
        end
    end

    function FrameDrawing.__newindex(self, key, value)
        local props = rawget(self, "_props")
        if not props then return end
        props[key] = value
        self:_apply(key, value)
    end

    function FrameDrawing:Remove()
        if self._root then self._root:Destroy() end
        self._root = nil
        self._stroke = nil
    end

    local function NewFrameDrawing(kind)
        local obj = { _isDrawing = true, _kind = kind, _props = {} }
        local root, stroke

        if kind == "Text" or kind == "Triangle" then
            root = Instance.new("TextLabel")
            root.BackgroundTransparency = 1
            root.BorderSizePixel = 0
            root.Font = Enum.Font.GothamMedium
            root.TextColor3 = Color3.new(1, 1, 1)
            root.TextSize = 13
            root.TextYAlignment = Enum.TextYAlignment.Top
            if kind == "Triangle" then
                root.Text = utf8.char(0x25B2)
                root.TextScaled = true
                root.TextXAlignment = Enum.TextXAlignment.Center
                root.TextYAlignment = Enum.TextYAlignment.Center
                root.AnchorPoint = Vector2.new(0.5, 0.5)
            else
                root.Text = ""
                root.TextXAlignment = Enum.TextXAlignment.Left
                root.AutomaticSize = Enum.AutomaticSize.XY
                root.AnchorPoint = Vector2.new(0, 0)
            end
            stroke = Instance.new("UIStroke")
            stroke.Color = Color3.new(0, 0, 0)
            stroke.Enabled = false
            stroke.Parent = root
        else
            root = Instance.new("Frame")
            root.BackgroundTransparency = 1
            root.BorderSizePixel = 0
            if kind == "Circle" then
                root.AnchorPoint = Vector2.new(0.5, 0.5)
                local corner = Instance.new("UICorner")
                corner.CornerRadius = UDim.new(1, 0)
                corner.Parent = root
            end
            if kind ~= "Line" then
                stroke = Instance.new("UIStroke")
                stroke.Color = Color3.new(0, 0, 0)
                stroke.Thickness = 1
                stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                stroke.Parent = root
            end
        end

        root.Visible = false
        root.ZIndex = 1
        if FallbackGui then root.Parent = FallbackGui end
        obj._root = root
        obj._stroke = stroke
        return setmetatable(obj, FrameDrawing)
    end

    local function NewDrawing(kind, props)
        if HasDrawing then
            local ok, obj = pcall(Drawing.new, kind)
            if not ok or not obj then return nil end
            if props then
                for k, v in pairs(props) do
                    pcall(function() obj[k] = v end)
                end
            end
            return obj
        end
        local obj = NewFrameDrawing(kind)
        if props then
            for k, v in pairs(props) do obj[k] = v end
        end
        return obj
    end

    local function SafeRemoveDrawing(obj)
        if not obj then return end
        pcall(function() obj.Visible = false end)
        pcall(function()
            if obj.Remove then
                obj:Remove()
            elseif obj.Destroy then
                obj:Destroy()
            end
        end)
    end

    local LosParams = RaycastParams.new()
    LosParams.FilterType = Enum.RaycastFilterType.Exclude
    LosParams.IgnoreWater = true

    local function IsCharacterVisible(camPos, targetChar, targetPart)
        if not targetPart or not targetChar then return false end
        local filter = {}
        if LocalPlayer and LocalPlayer.Character then
            table.insert(filter, LocalPlayer.Character)
        end
        table.insert(filter, targetChar)
        LosParams.FilterDescendantsInstances = filter
        local delta = targetPart.Position - camPos
        if delta.Magnitude < 0.1 then return true end
        return Workspace:Raycast(camPos, delta, LosParams) == nil
    end

    local MAX_HIGHLIGHTS = 28
    local R15_CHAM_PARTS = {
        "Head", "UpperTorso", "LowerTorso",
        "LeftUpperArm", "LeftLowerArm", "LeftHand",
        "RightUpperArm", "RightLowerArm", "RightHand",
        "LeftUpperLeg", "LeftLowerLeg", "LeftFoot",
        "RightUpperLeg", "RightLowerLeg", "RightFoot",
    }
    local R6_CHAM_PARTS = { "Head", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg" }

    local THERMAL_COLD = Color3.fromRGB(48, 65, 245)
    local THERMAL_COOL = Color3.fromRGB(195, 45, 225)
    local THERMAL_WARM = Color3.fromRGB(255, 55, 85)
    local THERMAL_HOT = Color3.fromRGB(255, 225, 75)

    local function ComputeThermalColor(healthFrac, clockTime)
        local wave = 0.5 + 0.5 * math.sin(clockTime * 2.6)
        local t = Clamp01((1 - healthFrac) * 0.62 + wave * 0.38)
        if t < 0.33 then
            return THERMAL_COLD:Lerp(THERMAL_COOL, t / 0.33)
        elseif t < 0.66 then
            return THERMAL_COOL:Lerp(THERMAL_WARM, (t - 0.33) / 0.33)
        else
            return THERMAL_WARM:Lerp(THERMAL_HOT, (t - 0.66) / 0.34)
        end
    end

    local ChamsManager = {}

    function ChamsManager.CreateState(player)
        return {
            Player = player,
            Highlight = nil,
            AdornFolder = nil,
            AdornMap = {},
            LastFill = nil,
            LastOutline = nil,
            LastFillTr = nil,
            LastOutlineTr = nil,
            LastDepth = nil,
            LastAdornee = nil,
            LastVisible = false,
            NextLosClock = 0,
        }
    end

    function ChamsManager.ClearAdornments(state)
        if state.AdornFolder then
            pcall(function() state.AdornFolder:Destroy() end)
            state.AdornFolder = nil
        end
        table.clear(state.AdornMap)
    end

    function ChamsManager.ReleaseHighlight(state)
        if state.Highlight then
            local hl = state.Highlight
            if state.LastAdornee ~= nil then
                pcall(function() hl.Adornee = nil end)
                state.LastAdornee = nil
            end
            pcall(function() hl.Enabled = false end)
        end
    end

    function ChamsManager.Hide(state)
        ChamsManager.ReleaseHighlight(state)
        if next(state.AdornMap) ~= nil then
            for _, adorn in pairs(state.AdornMap) do
                if adorn and adorn.Parent then adorn.Visible = false end
            end
        end
    end

    function ChamsManager.Destroy(state)
        if state.Highlight then
            pcall(function()
                state.Highlight.Adornee = nil
                state.Highlight:Destroy()
            end)
            state.Highlight = nil
        end
        ChamsManager.ClearAdornments(state)
        state.LastAdornee = nil
    end

    function ChamsManager.ApplyAdornments(state, char, fillColor, fillTr, alwaysOnTop)
        if not state.AdornFolder or not state.AdornFolder.Parent then
            state.AdornFolder = Make("Folder", { Name = "Adorn_" .. state.Player.Name }, ChamsFolder)
        end
        local partNames = char:FindFirstChild("UpperTorso") and R15_CHAM_PARTS or R6_CHAM_PARTS
        local activeSet = {}
        for _, pName in ipairs(partNames) do
            local part = char:FindFirstChild(pName)
            if part and part:IsA("BasePart") then
                activeSet[part] = true
                local adorn = state.AdornMap[part]
                if not adorn or not adorn.Parent then
                    adorn = Make("BoxHandleAdornment", {
                        Name = pName,
                        Adornee = part,
                        Size = part.Size + Vector3.new(0.05, 0.05, 0.05),
                        ZIndex = 5,
                        AlwaysOnTop = alwaysOnTop,
                        Color3 = fillColor,
                        Transparency = fillTr,
                        Visible = true,
                    }, state.AdornFolder)
                    state.AdornMap[part] = adorn
                else
                    adorn.Size = part.Size + Vector3.new(0.05, 0.05, 0.05)
                    adorn.AlwaysOnTop = alwaysOnTop
                    adorn.Color3 = fillColor
                    adorn.Transparency = fillTr
                    adorn.Visible = true
                end
            end
        end
        for part, adorn in pairs(state.AdornMap) do
            if not activeSet[part] or not part.Parent then
                pcall(function() adorn:Destroy() end)
                state.AdornMap[part] = nil
            end
        end
    end

    function ChamsManager.ApplyHighlight(state, char, fillColor, outlineColor, fillTr, outlineTr, depthMode)
        local hl = state.Highlight
        if not hl or not hl.Parent then
            hl = Make("Highlight", {
                Name = "HL_" .. state.Player.Name,
                Enabled = false,
                FillTransparency = 1,
                OutlineTransparency = 1,
                DepthMode = depthMode,
            }, ChamsFolder)
            state.Highlight = hl
            state.LastAdornee = nil
            state.LastFill = nil
            state.LastOutline = nil
            state.LastFillTr = nil
            state.LastOutlineTr = nil
            state.LastDepth = nil
        end
        if state.LastAdornee ~= char then hl.Adornee = char; state.LastAdornee = char end
        if state.LastFill ~= fillColor then hl.FillColor = fillColor; state.LastFill = fillColor end
        if state.LastOutline ~= outlineColor then hl.OutlineColor = outlineColor; state.LastOutline = outlineColor end
        if state.LastFillTr ~= fillTr then hl.FillTransparency = fillTr; state.LastFillTr = fillTr end
        if state.LastOutlineTr ~= outlineTr then hl.OutlineTransparency = outlineTr; state.LastOutlineTr = outlineTr end
        if state.LastDepth ~= depthMode then hl.DepthMode = depthMode; state.LastDepth = depthMode end
        if not hl.Enabled then hl.Enabled = true end
    end

    function ChamsManager.Update(state, entry, chamsCfg, camPos, now, healthFrac, allowHighlight)
        if not chamsCfg or not chamsCfg.Enabled or not entry.Char then
            ChamsManager.Hide(state)
            return false
        end

        local mode = chamsCfg.Mode or "Highlight"
        if chamsCfg.Thermal == true and mode == "Highlight" then
            mode = "Thermal"
        end

        local fillColor = chamsCfg.FillRGB or Color3.fromRGB(139, 92, 246)
        local outlineColor = chamsCfg.OutlineRGB or Color3.fromRGB(255, 255, 255)
        local fillTr = ToTransparency(chamsCfg.Fill_Transparency)
        local outlineTr = ToTransparency(chamsCfg.Outline_Transparency)
        local depthMode = chamsCfg.VisibleCheck and Enum.HighlightDepthMode.Occluded or Enum.HighlightDepthMode.AlwaysOnTop

        if mode == "Thermal" then
            fillColor = ComputeThermalColor(healthFrac, now)
            outlineColor = Color3.fromRGB(255, 244, 195)
            fillTr = math.min(fillTr, 0.34)
            outlineTr = math.min(outlineTr, 0.12)
        elseif mode == "Pulse" then
            local spd = tonumber(chamsCfg.PulseSpeed) or 2.5
            local wave = 0.5 + 0.5 * math.sin(now * spd * math.pi)
            local smoothWave = wave * wave * (3 - 2 * wave)
            fillTr = Clamp01(fillTr + (1 - fillTr) * smoothWave * 0.52)
            outlineTr = Clamp01(outlineTr * (0.35 + 0.65 * smoothWave))
        elseif mode == "Dual" then
            if now >= state.NextLosClock then
                state.NextLosClock = now + 0.14
                local checkPart = entry.Head or entry.Root
                state.LastVisible = IsCharacterVisible(camPos, entry.Char, checkPart)
            end
            if state.LastVisible then
                fillColor = chamsCfg.VisibleRGB or Color3.fromRGB(52, 255, 140)
            end
            depthMode = Enum.HighlightDepthMode.AlwaysOnTop
        end

        if mode == "Adornment" or not allowHighlight then
            ChamsManager.ReleaseHighlight(state)
            ChamsManager.ApplyAdornments(state, entry.Char, fillColor, fillTr, not chamsCfg.VisibleCheck)
            return false
        else
            if next(state.AdornMap) ~= nil then
                for _, adorn in pairs(state.AdornMap) do
                    if adorn and adorn.Parent then adorn.Visible = false end
                end
            end
            ChamsManager.ApplyHighlight(state, entry.Char, fillColor, outlineColor, fillTr, outlineTr, depthMode)
            return true
        end
    end

    local R15_BONES = {
        { "Head", "UpperTorso" },
        { "UpperTorso", "LowerTorso" },
        { "UpperTorso", "LeftUpperArm" }, { "LeftUpperArm", "LeftLowerArm" }, { "LeftLowerArm", "LeftHand" },
        { "UpperTorso", "RightUpperArm" }, { "RightUpperArm", "RightLowerArm" }, { "RightLowerArm", "RightHand" },
        { "LowerTorso", "LeftUpperLeg" }, { "LeftUpperLeg", "LeftLowerLeg" }, { "LeftLowerLeg", "LeftFoot" },
        { "LowerTorso", "RightUpperLeg" }, { "RightUpperLeg", "RightLowerLeg" }, { "RightLowerLeg", "RightFoot" },
    }
    local R6_BONES = {
        { "Head", "Torso" },
        { "Torso", "Left Arm" }, { "Torso", "Right Arm" },
        { "Torso", "Left Leg" }, { "Torso", "Right Leg" },
    }

    local function ProjectBounds(cam, root, head, hum)
        local rootPos = root.Position
        local centerVP = cam:WorldToViewportPoint(rootPos)
        if centerVP.Z <= 0.5 then
            return nil, false
        end

        local topYWorld = head and (head.Position.Y + head.Size.Y * 0.55) or (rootPos.Y + 2.6)
        local topWorld = Vector3.new(rootPos.X, math.max(topYWorld, rootPos.Y + 1.5), rootPos.Z)
        local hipOffset = (hum and hum.HipHeight > 0 and (hum.HipHeight + root.Size.Y * 0.5)) or 3.0
        local botWorld = Vector3.new(rootPos.X, rootPos.Y - hipOffset - 0.15, rootPos.Z)

        local topVP = cam:WorldToViewportPoint(topWorld)
        local botVP = cam:WorldToViewportPoint(botWorld)
        if topVP.Z <= 0.5 or botVP.Z <= 0.5 then
            return nil, false
        end

        local vpSize = cam.ViewportSize
        local fovScale = vpSize.Y / (2 * centerVP.Z * math.tan(math.rad(cam.FieldOfView * 0.5)))
        local rawTopY = math.min(topVP.Y, botVP.Y)
        local rawBotY = math.max(topVP.Y, botVP.Y)
        local projH = rawBotY - rawTopY
        local midY = (rawTopY + rawBotY) * 0.5
        local height = math.clamp(projH > 1 and projH or (5.4 * fovScale), 4, vpSize.Y * 1.35)
        local width = math.clamp(height * 0.56, 3, vpSize.X * 0.85)
        local cx = centerVP.X
        local topY = midY - height * 0.5
        local botY = midY + height * 0.5
        local left = cx - width * 0.5
        local right = cx + width * 0.5

        local visible = right >= 0 and left <= vpSize.X and botY >= 0 and topY <= vpSize.Y

        return {
            Left = left,
            Right = right,
            Top = topY,
            Bottom = botY,
            HeadTopY = topY,
            Width = width,
            Height = height,
            CenterX = cx,
            CenterY = midY,
            Depth = centerVP.Z,
        }, visible
    end

    local function CreateDrawings(entity)
        if entity.Drawings then return entity.Drawings end
        local d = {}
        d.BoxFill = NewDrawing("Square", { Filled = true, Thickness = 1, ZIndex = 1, Visible = false })
        d.BoxOutline = NewDrawing("Square", { Filled = false, Color = Color3.new(0, 0, 0), Thickness = 3, ZIndex = 2, Visible = false })
        d.Box = NewDrawing("Square", { Filled = false, Thickness = 1, ZIndex = 3, Visible = false })

        d.CornerOutlines = {}
        d.Corners = {}
        for i = 1, 8 do
            d.CornerOutlines[i] = NewDrawing("Line", { Color = Color3.new(0, 0, 0), ZIndex = 2, Visible = false })
            d.Corners[i] = NewDrawing("Line", { ZIndex = 3, Visible = false })
        end

        d.HealthOutline = NewDrawing("Square", { Filled = true, Color = Color3.new(0, 0, 0), Thickness = 1, ZIndex = 2, Visible = false })
        d.HealthBg = NewDrawing("Square", { Filled = true, Color = Color3.fromRGB(12, 12, 18), Thickness = 1, ZIndex = 3, Visible = false })
        d.HealthTrail = NewDrawing("Square", { Filled = true, Color = Color3.fromRGB(255, 240, 210), Thickness = 1, ZIndex = 4, Visible = false })
        d.HealthFill = NewDrawing("Square", { Filled = true, Thickness = 1, ZIndex = 5, Visible = false })
        d.HealthText = NewDrawing("Text", { Center = false, Outline = true, OutlineColor = Color3.new(0, 0, 0), Font = DrawingFont, ZIndex = 6, Visible = false })

        d.Name = NewDrawing("Text", { Center = true, Outline = true, OutlineColor = Color3.new(0, 0, 0), Font = DrawingFont, ZIndex = 6, Visible = false })
        d.Dist = NewDrawing("Text", { Center = true, Outline = true, OutlineColor = Color3.new(0, 0, 0), Font = DrawingFont, ZIndex = 6, Visible = false })
        d.Weapon = NewDrawing("Text", { Center = true, Outline = true, OutlineColor = Color3.new(0, 0, 0), Font = DrawingFont, ZIndex = 6, Visible = false })
        d.Flags = NewDrawing("Text", { Center = false, Outline = true, OutlineColor = Color3.new(0, 0, 0), Font = DrawingFont, ZIndex = 6, Visible = false })

        d.HeadDotOutline = NewDrawing("Circle", { Filled = true, NumSides = 20, Thickness = 1, Color = Color3.new(0, 0, 0), ZIndex = 4, Visible = false })
        d.HeadDot = NewDrawing("Circle", { Filled = true, NumSides = 20, Thickness = 1, ZIndex = 5, Visible = false })

        d.TracerOutline = NewDrawing("Line", { Color = Color3.new(0, 0, 0), ZIndex = 1, Visible = false })
        d.Tracer = NewDrawing("Line", { ZIndex = 2, Visible = false })

        d.Skel = {}
        for i = 1, 14 do
            d.Skel[i] = NewDrawing("Line", { ZIndex = 2, Visible = false })
        end

        d.ArrowOutline = NewDrawing("Triangle", { Filled = false, Color = Color3.new(0, 0, 0), Thickness = 1.8, ZIndex = 4, Visible = false })
        d.Arrow = NewDrawing("Triangle", { Filled = true, Thickness = 1, ZIndex = 5, Visible = false })

        entity.Drawings = d
        return d
    end

    local function Hide2DDrawings(d, keepArrow, keepName)
        if not d then return end
        if d.BoxFill then d.BoxFill.Visible = false end
        if d.BoxOutline then d.BoxOutline.Visible = false end
        if d.Box then d.Box.Visible = false end
        if d.CornerOutlines then
            for _, l in ipairs(d.CornerOutlines) do if l then l.Visible = false end end
        end
        if d.Corners then
            for _, l in ipairs(d.Corners) do if l then l.Visible = false end end
        end
        if d.HealthOutline then d.HealthOutline.Visible = false end
        if d.HealthBg then d.HealthBg.Visible = false end
        if d.HealthTrail then d.HealthTrail.Visible = false end
        if d.HealthFill then d.HealthFill.Visible = false end
        if d.HealthText then d.HealthText.Visible = false end
        if not keepName and d.Name then d.Name.Visible = false end
        if d.Dist then d.Dist.Visible = false end
        if d.Weapon then d.Weapon.Visible = false end
        if d.Flags then d.Flags.Visible = false end
        if d.HeadDotOutline then d.HeadDotOutline.Visible = false end
        if d.HeadDot then d.HeadDot.Visible = false end
        if d.TracerOutline then d.TracerOutline.Visible = false end
        if d.Tracer then d.Tracer.Visible = false end
        if d.Skel then
            for _, l in ipairs(d.Skel) do if l then l.Visible = false end end
        end
        if not keepArrow then
            if d.Arrow then d.Arrow.Visible = false end
            if d.ArrowOutline then d.ArrowOutline.Visible = false end
        end
    end

    local function HideEntity(entity, keepArrow)
        Hide2DDrawings(entity.Drawings, keepArrow, false)
        ChamsManager.Hide(entity.Chams)
    end

    local function DestroyDrawings(entity)
        local d = entity.Drawings
        if not d then return end
        for _, obj in pairs(d) do
            if type(obj) == "table" and not obj._isDrawing then
                for _, item in ipairs(obj) do SafeRemoveDrawing(item) end
            else
                SafeRemoveDrawing(obj)
            end
        end
        entity.Drawings = nil
    end

    local function RebuildBoneCache(entity, char)
        table.clear(entity.BonePairs)
        if not char then return end
        local tmpl = char:FindFirstChild("UpperTorso") and R15_BONES or R6_BONES
        for _, pair in ipairs(tmpl) do
            local p1 = char:FindFirstChild(pair[1])
            local p2 = char:FindFirstChild(pair[2])
            if p1 and p2 and p1:IsA("BasePart") and p2:IsA("BasePart") then
                table.insert(entity.BonePairs, { p1, p2 })
            end
        end
    end

    local function UpdateEquippedWeapon(entity, char)
        if not char then
            entity.WeaponName = "None"
            return
        end
        local tool = char:FindFirstChildOfClass("Tool")
        entity.WeaponName = tool and tool.Name or "None"
    end

    local function BindCharacter(entity, char)
        for _, c in ipairs(entity.Conns) do
            pcall(function() c:Disconnect() end)
        end
        table.clear(entity.Conns)
        ChamsManager.Hide(entity.Chams)
        ChamsManager.ClearAdornments(entity.Chams)
        entity.Char = char
        entity.Humanoid = nil
        entity.Root = nil
        entity.Head = nil
        entity.WeaponName = "None"
        table.clear(entity.BonePairs)
        if not char then return end

        local function sync()
            if entity.Char ~= char then return end
            entity.Humanoid = char:FindFirstChildOfClass("Humanoid")
            entity.Root = char:FindFirstChild("HumanoidRootPart")
                or char:FindFirstChild("UpperTorso")
                or char:FindFirstChild("Torso")
                or char.PrimaryPart
                or char:FindFirstChild("Head")
            entity.Head = char:FindFirstChild("Head")
            if entity.Humanoid and entity.Humanoid.MaxHealth > 0 then
                local f = Clamp01(entity.Humanoid.Health / entity.Humanoid.MaxHealth)
                entity.DisplayHealthFrac = f
                entity.TrailHealthFrac = f
            end
            RebuildBoneCache(entity, char)
            UpdateEquippedWeapon(entity, char)
        end

        sync()
        task.delay(0.25, sync)

        table.insert(entity.Conns, char.ChildAdded:Connect(function(obj)
            if obj:IsA("Tool") then
                entity.WeaponName = obj.Name
            elseif obj:IsA("Humanoid") then
                entity.Humanoid = obj
            elseif obj:IsA("BasePart") then
                if obj.Name == "HumanoidRootPart" then
                    entity.Root = obj
                elseif obj.Name == "Head" then
                    entity.Head = obj
                end
                RebuildBoneCache(entity, char)
            end
        end))

        table.insert(entity.Conns, char.ChildRemoved:Connect(function(obj)
            if obj:IsA("Tool") then
                UpdateEquippedWeapon(entity, char)
            elseif obj:IsA("BasePart") then
                RebuildBoneCache(entity, char)
            end
        end))
    end

    local function CreateEntity(player)
        if Registry[player] then return Registry[player] end
        local entity = {
            Player = player,
            Char = nil,
            Humanoid = nil,
            Root = nil,
            Head = nil,
            BonePairs = {},
            WeaponName = "None",
            Conns = {},
            Drawings = nil,
            Chams = ChamsManager.CreateState(player),
            IsFriend = false,
            DisplayHealthFrac = 1,
            TrailHealthFrac = 1,
        }
        entity.BindCharacter = function(c) BindCharacter(entity, c) end
        entity.Hide = function(_, keepArrow) HideEntity(entity, keepArrow) end

        task.spawn(function()
            if Destroyed then return end
            local ok, res = pcall(function() return LocalPlayer and LocalPlayer:IsFriendsWith(player.UserId) end)
            if ok and res == true then entity.IsFriend = true end
        end)

        if player.Character then
            BindCharacter(entity, player.Character)
        end
        entity.CharAddedConn = Track(player.CharacterAdded:Connect(function(c)
            BindCharacter(entity, c)
        end))
        entity.CharRemovingConn = Track(player.CharacterRemoving:Connect(function(oldChar)
            if oldChar == entity.Char then
                BindCharacter(entity, nil)
            end
        end))

        Registry[player] = entity
        return entity
    end

    local function RemoveEntity(player)
        local entity = Registry[player]
        if not entity then return end
        Registry[player] = nil
        if entity.CharAddedConn then pcall(function() entity.CharAddedConn:Disconnect() end) end
        if entity.CharRemovingConn then pcall(function() entity.CharRemovingConn:Disconnect() end) end
        for _, c in ipairs(entity.Conns) do pcall(function() c:Disconnect() end) end
        table.clear(entity.Conns)
        ChamsManager.Destroy(entity.Chams)
        DestroyDrawings(entity)
    end

    local function SyncAllPlayers()
        local lp = PlayersSvc.LocalPlayer
        if not lp then return end
        LocalPlayer = lp
        for _, plr in ipairs(PlayersSvc:GetPlayers()) do
            if plr ~= lp and not Registry[plr] then
                pcall(CreateEntity, plr)
            end
        end
    end

    Track(PlayersSvc.PlayerAdded:Connect(function(plr)
        if plr ~= PlayersSvc.LocalPlayer then pcall(CreateEntity, plr) end
    end))
    Track(PlayersSvc.PlayerRemoving:Connect(RemoveEntity))
    SyncAllPlayers()

    local function IsWhitelistedFriend(player, entity)
        if entity.IsFriend then return true end
        local fr = rawget(genv, "ESP_Friends")
        if type(fr) == "table" and fr[player.Name] then return true end
        local lib = rawget(genv, "library")
        if type(lib) == "table" and type(lib.whitelist) == "table" then
            for _, v in ipairs(lib.whitelist) do
                if v == player.Name then return true end
            end
        end
        return false
    end

    local function DrawArrow(d, arrowCfg, cam, rootPos, viewport, center, dist, now)
        if not d or not d.Arrow then return end
        local vp = cam:WorldToViewportPoint(rootPos)
        local dx, dy = vp.X - center.X, vp.Y - center.Y
        if vp.Z < 0 then dx, dy = -dx, -dy end
        local mag = math.sqrt(dx * dx + dy * dy)
        if mag < 1 then dx, dy, mag = 0, -1, 1 end
        local ux, uy = dx / mag, dy / mag

        local maxRad = math.min(viewport.X, viewport.Y) * 0.5 - 32
        local distFromCenter = math.clamp(tonumber(arrowCfg.Distance) or 140, 40, math.max(40, maxRad))
        local tipX = center.X + ux * distFromCenter
        local tipY = center.Y + uy * distFromCenter
        local size = tonumber(arrowCfg.Size) or 16
        local angle = math.atan2(uy, ux)
        local spread = math.rad(148)

        local pA = Vector2.new(tipX + math.cos(angle) * size * 0.65, tipY + math.sin(angle) * size * 0.65)
        local pB = Vector2.new(tipX + math.cos(angle + spread) * size, tipY + math.sin(angle + spread) * size)
        local pC = Vector2.new(tipX + math.cos(angle - spread) * size, tipY + math.sin(angle - spread) * size)

        local baseAlpha = 1 - ToTransparency(arrowCfg.Transparency or 0)
        local pulse = (dist < 100) and (0.72 + 0.28 * (0.5 + 0.5 * math.sin(now * 6))) or 1
        local alpha = Clamp01(baseAlpha * pulse)

        d.Arrow.PointA = pA
        d.Arrow.PointB = pB
        d.Arrow.PointC = pC
        d.Arrow.Color = arrowCfg.RGB or Color3.fromRGB(255, 75, 95)
        d.Arrow.Transparency = alpha
        d.Arrow.Visible = true

        if d.ArrowOutline then
            if arrowCfg.Outlined ~= false then
                d.ArrowOutline.PointA = pA
                d.ArrowOutline.PointB = pB
                d.ArrowOutline.PointC = pC
                d.ArrowOutline.Transparency = alpha * 0.9
                d.ArrowOutline.Visible = true
            else
                d.ArrowOutline.Visible = false
            end
        end
    end

    local nextSyncClock = 0
    local activeList = table.create(32)

    local function StepESP(dt, updateChams)
        if Destroyed then return end
        local cfg = GetCfg()
        local enabled = cfg and cfg.Enabled == true
        local cam = Workspace.CurrentCamera
        if not enabled or not cam then
            for _, entity in pairs(Registry) do HideEntity(entity, false) end
            return
        end

        local now = os.clock()
        if now >= nextSyncClock then
            nextSyncClock = now + 0.25
            SyncAllPlayers()
        end

        local camPos = cam.CFrame.Position
        local viewport = cam.ViewportSize
        local center = Vector2.new(viewport.X * 0.5, viewport.Y * 0.5)
        local maxDist = tonumber(cfg.MaxDistance) or 600
        local baseFontSize = math.clamp(tonumber(cfg.FontSize) or 13, 9, 26)
        local fontSize = math.max(13, baseFontSize + 2)
        local localTeam = LocalPlayer and LocalPlayer.Team

        local drawCfg = cfg.Drawing or DEFAULT_CONFIG.Drawing
        local boxesCfg = drawCfg.Boxes or DEFAULT_CONFIG.Drawing.Boxes
        local chamsCfg = drawCfg.Chams or DEFAULT_CONFIG.Drawing.Chams
        local healthCfg = drawCfg.Healthbar or DEFAULT_CONFIG.Drawing.Healthbar
        local namesCfg = drawCfg.Names or DEFAULT_CONFIG.Drawing.Names
        local distCfg = drawCfg.Distances or DEFAULT_CONFIG.Drawing.Distances
        local weapCfg = drawCfg.Weapons or DEFAULT_CONFIG.Drawing.Weapons
        local flagsCfg = drawCfg.Flags or DEFAULT_CONFIG.Drawing.Flags
        local headDotCfg = drawCfg.HeadDot or DEFAULT_CONFIG.Drawing.HeadDot
        local tracerCfg = drawCfg.Tracers or DEFAULT_CONFIG.Drawing.Tracers
        local skelCfg = drawCfg.Skeleton or DEFAULT_CONFIG.Drawing.Skeleton
        local arrowCfg = drawCfg.Arrows or DEFAULT_CONFIG.Drawing.Arrows
        local optCfg = cfg.Options or DEFAULT_CONFIG.Options
        local fadeDist = cfg.FadeOut and cfg.FadeOut.OnDistance == true

        table.clear(activeList)
        for player, entity in pairs(Registry) do
            if not player or not player.Parent then
                RemoveEntity(player)
                continue
            end
            local char = player.Character
            if not char or not char:IsDescendantOf(Workspace) then
                HideEntity(entity, false)
                continue
            end
            if entity.Char ~= char then
                entity.BindCharacter(char)
            end
            local hum = entity.Humanoid
            if not hum or hum.Parent ~= char then
                hum = char:FindFirstChildOfClass("Humanoid")
                entity.Humanoid = hum
            end
            local root = entity.Root
            if not root or root.Parent ~= char then
                root = char:FindFirstChild("HumanoidRootPart")
                    or char:FindFirstChild("UpperTorso")
                    or char:FindFirstChild("Torso")
                    or char.PrimaryPart
                    or char:FindFirstChild("Head")
                entity.Root = root
            end
            if not entity.Head or entity.Head.Parent ~= char then
                entity.Head = char:FindFirstChild("Head")
            end
            if #entity.BonePairs == 0 then
                RebuildBoneCache(entity, char)
            end
            if not root or (hum and hum.Health <= 0) then
                HideEntity(entity, false)
                continue
            end
            if cfg.TeamCheck and localTeam ~= nil and player.Team == localTeam then
                HideEntity(entity, false)
                continue
            end
            local dist = (camPos - root.Position).Magnitude
            if dist > maxDist then
                HideEntity(entity, false)
                continue
            end
            local item = entity.ActiveItem
            if not item then
                item = {}
                entity.ActiveItem = item
            end
            item.Entity = entity
            item.Player = player
            item.Dist = dist
            activeList[#activeList + 1] = item
        end

        if updateChams and chamsCfg.Enabled and #activeList > MAX_HIGHLIGHTS then
            table.sort(activeList, function(a, b) return a.Dist < b.Dist end)
        end

        local highlightsUsed = 0
        local healthLerpAlpha = math.clamp((dt or 0.016) * 16, 0, 1)
        local trailLerpAlpha = math.clamp((dt or 0.016) * 4.5, 0, 1)

        for _, item in ipairs(activeList) do
            local ok = pcall(function()
                local entity = item.Entity
                local player = item.Player
                local dist = item.Dist
                local hum = entity.Humanoid
                local root = entity.Root
                local maxHP = hum and math.max(1, hum.MaxHealth) or 100
                local curHP = hum and hum.Health or maxHP
                local rawFrac = Clamp01(curHP / maxHP)

                if updateChams then
                    if healthCfg.Lerp then
                        entity.DisplayHealthFrac = entity.DisplayHealthFrac + (rawFrac - entity.DisplayHealthFrac) * healthLerpAlpha
                        if rawFrac > entity.TrailHealthFrac then
                            entity.TrailHealthFrac = entity.DisplayHealthFrac
                        else
                            entity.TrailHealthFrac = entity.TrailHealthFrac + (rawFrac - entity.TrailHealthFrac) * trailLerpAlpha
                        end
                    else
                        entity.DisplayHealthFrac = rawFrac
                        entity.TrailHealthFrac = rawFrac
                    end
                    local canHL = highlightsUsed < MAX_HIGHLIGHTS
                    if ChamsManager.Update(entity.Chams, entity, chamsCfg, camPos, now, rawFrac, canHL) then
                        highlightsUsed += 1
                    end
                end

                local d = CreateDrawings(entity)
                if not d then return end

                local bounds, onScreen = ProjectBounds(cam, root, entity.Head, hum)
                if not bounds or not onScreen then
                    Hide2DDrawings(d, arrowCfg.Enabled, false)
                    if arrowCfg.Enabled then
                        DrawArrow(d, arrowCfg, cam, root.Position, viewport, center, dist, now)
                    end
                    return
                end

                if d.Arrow then d.Arrow.Visible = false end
                if d.ArrowOutline then d.ArrowOutline.Visible = false end

                local isTeam = localTeam ~= nil and player.Team == localTeam
                local isFriend = IsWhitelistedFriend(player, entity)
                local distTop = distCfg.Enabled and distCfg.Position == "Top"

                local nameColor = namesCfg.RGB or Color3.fromRGB(255, 255, 255)
                local namePrefix = ""
                if optCfg.Friendcheck and isFriend then
                    namePrefix ..= "[F] "
                    nameColor = optCfg.FriendcheckRGB or nameColor
                elseif optCfg.Teamcheck and isTeam then
                    namePrefix ..= "[T] "
                end

                local cx = bounds.CenterX
                local headTopY = bounds.HeadTopY
                local distScale = math.clamp(1 - (dist / math.max(maxDist, 1)) * 0.2, 0.82, 1)
                local nameSize = math.max(11, math.floor(fontSize * distScale + 0.5))

                local fadeTr = fadeDist and (1 - math.clamp(1 - (dist / maxDist), 0.18, 1)) or 0
                local fadeAlpha = Clamp01(1 - fadeTr)
                local lx = bounds.Left
                local ty = bounds.Top
                local bw = bounds.Width
                local bh = bounds.Height
                local rx = bounds.Right
                local by = bounds.Bottom

                local fullOn = (boxesCfg.Full and boxesCfg.Full.Enabled) or (boxesCfg.Bounding and boxesCfg.Bounding.Enabled)
                if fullOn then
                    local boxColor = (boxesCfg.Full and boxesCfg.Full.Enabled and boxesCfg.Full.RGB)
                        or (boxesCfg.Bounding and boxesCfg.Bounding.RGB)
                        or Color3.new(1, 1, 1)
                    if boxesCfg.Gradient then
                        local tCol = boxesCfg.Animate and (0.5 + 0.5 * math.sin(now * 2.5)) or 0.5
                        boxColor = (boxesCfg.GradientRGB1 or Color3.fromRGB(139, 92, 246)):Lerp(
                            boxesCfg.GradientRGB2 or Color3.fromRGB(45, 212, 191),
                            tCol
                        )
                    end
                    local boxThick = math.clamp(tonumber(boxesCfg.Thickness) or 1, 1, 4)

                    if d.BoxOutline then
                        d.BoxOutline.Position = Vector2.new(lx, ty)
                        d.BoxOutline.Size = Vector2.new(bw, bh)
                        d.BoxOutline.Thickness = boxThick + 2
                        d.BoxOutline.Transparency = fadeAlpha * 0.85
                        d.BoxOutline.Visible = true
                    end
                    if d.Box then
                        d.Box.Position = Vector2.new(lx, ty)
                        d.Box.Size = Vector2.new(bw, bh)
                        d.Box.Color = boxColor
                        d.Box.Thickness = boxThick
                        d.Box.Transparency = fadeAlpha
                        d.Box.Visible = true
                    end
                    if boxesCfg.Filled and boxesCfg.Filled.Enabled and d.BoxFill then
                        d.BoxFill.Position = Vector2.new(lx, ty)
                        d.BoxFill.Size = Vector2.new(bw, bh)
                        d.BoxFill.Color = boxesCfg.Filled.RGB or Color3.fromRGB(14, 14, 22)
                        d.BoxFill.Transparency = Clamp01((1 - ToTransparency(boxesCfg.Filled.Transparency)) * fadeAlpha)
                        d.BoxFill.Visible = true
                    elseif d.BoxFill then
                        d.BoxFill.Visible = false
                    end
                else
                    if d.BoxOutline then d.BoxOutline.Visible = false end
                    if d.Box then d.Box.Visible = false end
                    if d.BoxFill then d.BoxFill.Visible = false end
                end

                local cornerOn = boxesCfg.Corner and boxesCfg.Corner.Enabled
                if cornerOn then
                    local cCol = boxesCfg.Corner.RGB or Color3.new(1, 1, 1)
                    if boxesCfg.Gradient then
                        local tCol = boxesCfg.Animate and (0.5 + 0.5 * math.sin(now * 2.5)) or 0.5
                        cCol = (boxesCfg.GradientRGB1 or Color3.fromRGB(139, 92, 246)):Lerp(
                            boxesCfg.GradientRGB2 or Color3.fromRGB(45, 212, 191),
                            tCol
                        )
                    end
                    local thick = math.clamp(tonumber(boxesCfg.Thickness) or 1, 1, 3)
                    local legW = math.max(2, math.min(math.floor(bw * 0.25), math.floor(bw * 0.45)))
                    local legH = math.max(2, math.min(math.floor(bh * 0.22), math.floor(bh * 0.45)))
                    local cAlpha = Clamp01((1 - ToTransparency(boxesCfg.Corner.Transparency)) * fadeAlpha)

                    local segs = {
                        { Vector2.new(lx, ty), Vector2.new(lx + legW, ty) },
                        { Vector2.new(lx, ty), Vector2.new(lx, ty + legH) },
                        { Vector2.new(rx - legW, ty), Vector2.new(rx, ty) },
                        { Vector2.new(rx, ty), Vector2.new(rx, ty + legH) },
                        { Vector2.new(lx, by - legH), Vector2.new(lx, by) },
                        { Vector2.new(lx, by), Vector2.new(lx + legW, by) },
                        { Vector2.new(rx - legW, by), Vector2.new(rx, by) },
                        { Vector2.new(rx, by - legH), Vector2.new(rx, by) },
                    }
                    for i = 1, 8 do
                        local s = segs[i]
                        local ol = d.CornerOutlines[i]
                        local cl = d.Corners[i]
                        if ol then
                            ol.From = s[1]
                            ol.To = s[2]
                            ol.Thickness = thick + 2
                            ol.Transparency = cAlpha * 0.85
                            ol.Visible = true
                        end
                        if cl then
                            cl.From = s[1]
                            cl.To = s[2]
                            cl.Color = cCol
                            cl.Thickness = thick
                            cl.Transparency = cAlpha
                            cl.Visible = true
                        end
                    end
                else
                    for i = 1, 8 do
                        if d.CornerOutlines[i] then d.CornerOutlines[i].Visible = false end
                        if d.Corners[i] then d.Corners[i].Visible = false end
                    end
                end

                local hpFrac = Clamp01(entity.DisplayHealthFrac)
                local trailFrac = Clamp01(math.max(hpFrac, entity.TrailHealthFrac))
                if healthCfg.Enabled then
                    local barW = math.clamp(math.floor((tonumber(healthCfg.Width) or 3) + 0.5), 2, 6)
                    local barX = lx - barW - 5
                    local barY = ty
                    local barH = math.max(6, bh)
                    local fillH = math.max(1, math.floor(barH * hpFrac + 0.5))
                    local trailH = math.max(fillH, math.floor(barH * trailFrac + 0.5))

                    local lowCol = healthCfg.GradientRGB1 or Color3.fromRGB(255, 55, 75)
                    local highCol = healthCfg.GradientRGB2 or Color3.fromRGB(55, 245, 135)
                    local hpCol = healthCfg.Gradient and lowCol:Lerp(highCol, hpFrac) or highCol
                    local hpAlpha = Clamp01((1 - ToTransparency(healthCfg.Transparency)) * fadeAlpha)

                    if d.HealthOutline then
                        d.HealthOutline.Position = Vector2.new(barX - 1, barY - 1)
                        d.HealthOutline.Size = Vector2.new(barW + 2, barH + 2)
                        d.HealthOutline.Transparency = hpAlpha * 0.9
                        d.HealthOutline.Visible = true
                    end
                    if d.HealthBg then
                        d.HealthBg.Position = Vector2.new(barX, barY)
                        d.HealthBg.Size = Vector2.new(barW, barH)
                        d.HealthBg.Transparency = hpAlpha * 0.8
                        d.HealthBg.Visible = true
                    end
                    if d.HealthTrail then
                        if trailH > fillH then
                            d.HealthTrail.Position = Vector2.new(barX, barY + (barH - trailH))
                            d.HealthTrail.Size = Vector2.new(barW, trailH)
                            d.HealthTrail.Transparency = hpAlpha * 0.7
                            d.HealthTrail.Visible = true
                        else
                            d.HealthTrail.Visible = false
                        end
                    end
                    if d.HealthFill then
                        d.HealthFill.Position = Vector2.new(barX, barY + (barH - fillH))
                        d.HealthFill.Size = Vector2.new(barW, fillH)
                        d.HealthFill.Color = hpCol
                        d.HealthFill.Transparency = hpAlpha
                        d.HealthFill.Visible = true
                    end
                    if healthCfg.HealthText and bh >= 12 and d.HealthText then
                        local hpStr = tostring(math.floor(curHP + 0.5))
                        local txtSize = math.max(10, nameSize - 2)
                        local estW = #hpStr * (txtSize * 0.58)
                        local textY = math.clamp(barY + (barH - fillH) - txtSize * 0.5, barY - 2, barY + barH - txtSize)
                        d.HealthText.Text = hpStr
                        d.HealthText.Font = DrawingFont
                        d.HealthText.Size = txtSize
                        d.HealthText.Color = healthCfg.Gradient and hpCol or (healthCfg.HealthTextRGB or Color3.new(1, 1, 1))
                        d.HealthText.Position = Vector2.new(math.floor(barX - estW - 5), math.floor(textY))
                        d.HealthText.Transparency = Clamp01((1 - ToTransparency(healthCfg.HealthTextTransparency)) * fadeAlpha)
                        d.HealthText.Visible = true
                    elseif d.HealthText then
                        d.HealthText.Visible = false
                    end
                else
                    if d.HealthOutline then d.HealthOutline.Visible = false end
                    if d.HealthBg then d.HealthBg.Visible = false end
                    if d.HealthTrail then d.HealthTrail.Visible = false end
                    if d.HealthFill then d.HealthFill.Visible = false end
                    if d.HealthText then d.HealthText.Visible = false end
                end

                if namesCfg.Enabled and d.Name then
                    local txt = namePrefix .. player.Name
                    if distTop then
                        txt ..= string.format(" [%dm]", math.floor(dist + 0.5))
                    end
                    d.Name.Text = txt
                    d.Name.Font = DrawingFont
                    d.Name.Size = nameSize
                    d.Name.Color = nameColor
                    d.Name.Transparency = fadeAlpha
                    d.Name.Position = Vector2.new(cx, headTopY - nameSize - 4)
                    d.Name.Visible = true
                elseif d.Name then
                    d.Name.Visible = false
                end

                local bottomY = by + 3
                local subSize = math.max(10, nameSize - 1)

                if distCfg.Enabled and not distTop and d.Dist then
                    d.Dist.Text = string.format("%dm", math.floor(dist + 0.5))
                    d.Dist.Font = DrawingFont
                    d.Dist.Size = subSize
                    d.Dist.Color = distCfg.RGB or Color3.fromRGB(255, 255, 255)
                    d.Dist.Transparency = fadeAlpha
                    d.Dist.Position = Vector2.new(cx, bottomY)
                    d.Dist.Visible = true
                    bottomY += subSize + 2
                elseif d.Dist then
                    d.Dist.Visible = false
                end

                if weapCfg.Enabled and d.Weapon then
                    local wName = entity.WeaponName or "None"
                    local armed = wName ~= "None" and wName ~= ""
                    d.Weapon.Text = armed and wName or "Unarmed"
                    d.Weapon.Font = DrawingFont
                    d.Weapon.Size = subSize
                    d.Weapon.Color = armed
                        and (weapCfg.WeaponTextRGB or weapCfg.RGB or Color3.fromRGB(172, 142, 255))
                        or Color3.fromRGB(185, 192, 210)
                    d.Weapon.Transparency = fadeAlpha
                    d.Weapon.Position = Vector2.new(cx, bottomY)
                    d.Weapon.Visible = true
                elseif d.Weapon then
                    d.Weapon.Visible = false
                end

                if flagsCfg.Enabled and d.Flags then
                    local lines = {}
                    if isFriend then table.insert(lines, "FRIEND") end
                    if isTeam then table.insert(lines, "TEAM") end
                    if rawFrac <= 0.3 then table.insert(lines, "LOW HP") end
                    if entity.WeaponName and entity.WeaponName ~= "None" then table.insert(lines, "ARMED") end
                    if hum and hum.Sit then
                        table.insert(lines, "SIT")
                    elseif hum and hum.FloorMaterial == Enum.Material.Air then
                        table.insert(lines, "AIR")
                    end
                    if #lines > 0 then
                        d.Flags.Text = table.concat(lines, "\n")
                        d.Flags.Size = math.max(8, fontSize - 2)
                        d.Flags.Color = flagsCfg.RGB or Color3.fromRGB(224, 228, 242)
                        d.Flags.Transparency = fadeAlpha
                        d.Flags.Position = Vector2.new(rx + 6, ty)
                        d.Flags.Visible = true
                    else
                        d.Flags.Visible = false
                    end
                elseif d.Flags then
                    d.Flags.Visible = false
                end

                if headDotCfg.Enabled and entity.Head and entity.Head.Parent and d.HeadDot then
                    local hvp = cam:WorldToViewportPoint(entity.Head.Position)
                    if hvp.Z > 0.1 then
                        local rad = math.clamp(tonumber(headDotCfg.Radius) or 3, 2, 10)
                        local alpha = Clamp01((1 - ToTransparency(headDotCfg.Transparency)) * fadeAlpha)
                        local pos = Vector2.new(hvp.X, hvp.Y)
                        if d.HeadDotOutline then
                            d.HeadDotOutline.Position = pos
                            d.HeadDotOutline.Radius = rad + 1.2
                            d.HeadDotOutline.Transparency = alpha * 0.85
                            d.HeadDotOutline.Visible = true
                        end
                        d.HeadDot.Position = pos
                        d.HeadDot.Radius = rad
                        d.HeadDot.Color = headDotCfg.RGB or Color3.fromRGB(255, 90, 110)
                        d.HeadDot.Transparency = alpha
                        d.HeadDot.Visible = true
                    else
                        d.HeadDot.Visible = false
                        if d.HeadDotOutline then d.HeadDotOutline.Visible = false end
                    end
                else
                    if d.HeadDot then d.HeadDot.Visible = false end
                    if d.HeadDotOutline then d.HeadDotOutline.Visible = false end
                end

                if tracerCfg.Enabled and d.Tracer then
                    local origin = tracerCfg.Origin or "Bottom"
                    local fromVec
                    if origin == "Center" then
                        fromVec = center
                    elseif origin == "Top" then
                        fromVec = Vector2.new(viewport.X * 0.5, 2)
                    elseif origin == "Mouse" then
                        fromVec = UserInputService:GetMouseLocation()
                    else
                        fromVec = Vector2.new(viewport.X * 0.5, viewport.Y - 2)
                    end
                    local toVec = Vector2.new(cx, by)
                    local thick = tonumber(tracerCfg.Thickness) or 1.5
                    local alpha = Clamp01((1 - ToTransparency(tracerCfg.Transparency)) * fadeAlpha)
                    if d.TracerOutline then
                        d.TracerOutline.From = fromVec
                        d.TracerOutline.To = toVec
                        d.TracerOutline.Thickness = thick + 1.8
                        d.TracerOutline.Transparency = alpha * 0.55
                        d.TracerOutline.Visible = true
                    end
                    d.Tracer.From = fromVec
                    d.Tracer.To = toVec
                    d.Tracer.Color = tracerCfg.RGB or Color3.new(1, 1, 1)
                    d.Tracer.Thickness = thick
                    d.Tracer.Transparency = alpha
                    d.Tracer.Visible = true
                else
                    if d.Tracer then d.Tracer.Visible = false end
                    if d.TracerOutline then d.TracerOutline.Visible = false end
                end

                if skelCfg.Enabled and bh >= 14 and d.Skel then
                    local sAlpha = Clamp01((1 - ToTransparency(skelCfg.Transparency)) * fadeAlpha)
                    local sThick = tonumber(skelCfg.Thickness) or 1.4
                    local sCol = skelCfg.RGB or Color3.new(1, 1, 1)
                    local lines = d.Skel
                    local idx = 1
                    for _, pair in ipairs(entity.BonePairs) do
                        local p1, p2 = pair[1], pair[2]
                        if p1 and p2 and p1.Parent and p2.Parent then
                            local a = cam:WorldToViewportPoint(p1.Position)
                            local b = cam:WorldToViewportPoint(p2.Position)
                            if a.Z > 0.5 and b.Z > 0.5 then
                                local line = lines[idx]
                                if not line then
                                    line = NewDrawing("Line", { ZIndex = 2, Visible = false })
                                    lines[idx] = line
                                end
                                if line then
                                    line.From = Vector2.new(a.X, a.Y)
                                    line.To = Vector2.new(b.X, b.Y)
                                    line.Color = sCol
                                    line.Thickness = sThick
                                    line.Transparency = sAlpha
                                    line.Visible = true
                                end
                                idx += 1
                            end
                        end
                    end
                    for i = idx, #lines do
                        if lines[i] then lines[i].Visible = false end
                    end
                elseif d.Skel then
                    for _, l in ipairs(d.Skel) do if l then l.Visible = false end end
                end
            end)
            if not ok then
                HideEntity(item.Entity, false)
            end
        end
    end

    local RenderBindName = "EXT_ESP_Step_" .. tostring(math.random(100000, 999999))
    genv.ESP_RenderBindName = RenderBindName
    local pendingDt = 0
    RunService:BindToRenderStep(RenderBindName, Enum.RenderPriority.Last.Value + 100, function(dt)
        pendingDt += (dt or 0.016)
        local interval = 1 / 30
        local perf = genv.EXT_PERF
        if type(perf) == "table" and type(perf.ESPInterval) == "number" and perf.ESPInterval >= 0 then
            interval = perf.ESPInterval
        end
        if interval > 0 and pendingDt < interval then return end
        local stepDt = pendingDt
        pendingDt = 0
        StepESP(stepDt, true)
    end)

    local function RefreshESP()
        if Destroyed then return end
        local cfg = GetCfg()
        if cfg and cfg.Enabled then
            SyncAllPlayers()
        else
            for _, entity in pairs(Registry) do HideEntity(entity, false) end
        end
    end

    local function DestroyESP()
        if Destroyed then return end
        Destroyed = true
        pcall(function() RunService:UnbindFromRenderStep(RenderBindName) end)
        for _, c in ipairs(Connections) do pcall(function() c:Disconnect() end) end
        table.clear(Connections)
        for plr, _ in pairs(Registry) do
            RemoveEntity(plr)
        end
        pcall(function() ChamsFolder:Destroy() end)
        if FallbackGui then pcall(function() FallbackGui:Destroy() end) end
        genv.ESP_Config = nil
        genv.ESP_Refresh = nil
        genv.RefreshESP = nil
        genv.ESP_Set = nil
        genv.ESP_Destroy = nil
        genv.ESP_Registry = nil
        genv.ESP_BuildUI = nil
        genv.ESP_BuildTab = nil
        genv.ESP_VERSION = nil
        genv.ESP_RenderBindName = nil
        genv.__ExternalESPStandalone = nil
    end

    local function BuildControls(secCore, secBoxes, secInfo, secChams, secExtras)
        local E = GetCfg()
        local D = E.Drawing

        local function AddToggle(sec, name, flag, tbl, key, def)
            return sec:Toggle({
                Name = name,
                Flag = "ESP_" .. flag,
                Default = tbl[key] ~= nil and tbl[key] or (def == true),
                Value = tbl[key] ~= nil and tbl[key] or (def == true),
                Callback = function(v)
                    tbl[key] = v
                    RefreshESP()
                end,
            })
        end

        local function AddColor(anchor, sec, name, flag, tbl, key, def)
            local colDef = tbl[key] or def
            if anchor and type(anchor.Colorpicker) == "function" then
                return anchor:Colorpicker({
                    Name = name,
                    Flag = "ESP_" .. flag,
                    Default = colDef,
                    Callback = function(v)
                        tbl[key] = v
                        RefreshESP()
                    end,
                })
            elseif sec and type(sec.Colorpicker) == "function" then
                return sec:Colorpicker({
                    Name = name,
                    Flag = "ESP_" .. flag,
                    Default = colDef,
                    Callback = function(v)
                        tbl[key] = v
                        RefreshESP()
                    end,
                })
            end
            return nil
        end

        local function AddSlider(sec, name, flag, tbl, key, minV, maxV, defV, dec, suffix)
            local cur = tbl[key] ~= nil and tbl[key] or defV
            return sec:Slider({
                Name = name,
                Flag = "ESP_" .. flag,
                Min = minV,
                Max = maxV,
                Default = cur,
                Value = cur,
                Decimals = dec or 1,
                Suffix = suffix or "",
                Callback = function(v)
                    tbl[key] = v
                    RefreshESP()
                end,
            })
        end

        local function AddDropdown(sec, name, flag, tbl, key, items, def)
            local cur = tbl[key] or def
            return sec:Dropdown({
                Name = name,
                Flag = "ESP_" .. flag,
                Items = items,
                Options = items,
                Default = cur,
                Value = cur,
                Callback = function(v)
                    tbl[key] = v
                    RefreshESP()
                end,
            })
        end

        AddToggle(secCore, "Enable ESP", "Enabled", E, "Enabled", false)
        AddToggle(secCore, "Team Check (Hide Team)", "TeamCheck", E, "TeamCheck", false)
        AddToggle(secCore, "Fade On Distance", "FadeDist", E.FadeOut, "OnDistance", false)
        AddSlider(secCore, "Max Distance", "MaxDist", E, "MaxDistance", 50, 5000, 600, 1, "m")
        AddSlider(secCore, "Font Size", "FontSize", E, "FontSize", 9, 26, 13, 1, "px")
        local fFlag = AddToggle(secCore, "Friend Tag [F]", "FriendFlag", E.Options, "Friendcheck", true)
        AddColor(fFlag, secCore, "Friend Color", "FriendCol", E.Options, "FriendcheckRGB", Color3.fromRGB(95, 190, 255))
        local tFlag = AddToggle(secCore, "Team Tag [T]", "TeamFlag", E.Options, "Teamcheck", true)
        AddColor(tFlag, secCore, "Team Color", "TeamCol", E.Options, "TeamcheckRGB", Color3.fromRGB(70, 225, 145))

        local fullBox = secBoxes:Toggle({
            Name = "Bounding Box",
            Flag = "ESP_BoxFull",
            Default = (D.Boxes.Full.Enabled == true) or (D.Boxes.Bounding and D.Boxes.Bounding.Enabled == true),
            Value = (D.Boxes.Full.Enabled == true) or (D.Boxes.Bounding and D.Boxes.Bounding.Enabled == true),
            Callback = function(v)
                D.Boxes.Full.Enabled = v
                if D.Boxes.Bounding then D.Boxes.Bounding.Enabled = v end
                RefreshESP()
            end,
        })
        AddColor(fullBox, secBoxes, "Box Color", "BoxFullCol", D.Boxes.Full, "RGB", Color3.fromRGB(255, 255, 255))
        local cornerBox = AddToggle(secBoxes, "Corner Box", "BoxCorner", D.Boxes.Corner, "Enabled", false)
        AddColor(cornerBox, secBoxes, "Corner Color", "BoxCornerCol", D.Boxes.Corner, "RGB", Color3.fromRGB(255, 255, 255))
        local filledBox = AddToggle(secBoxes, "Filled Box", "BoxFilled", D.Boxes.Filled, "Enabled", false)
        AddColor(filledBox, secBoxes, "Fill Color", "BoxFilledCol", D.Boxes.Filled, "RGB", Color3.fromRGB(14, 14, 22))
        AddSlider(secBoxes, "Box Thickness", "BoxThick", D.Boxes, "Thickness", 1, 4, 1, 0.5, "px")
        local gradBox = AddToggle(secBoxes, "Box Gradient", "BoxGrad", D.Boxes, "Gradient", false)
        AddColor(gradBox, secBoxes, "Gradient Start", "BoxGrad1", D.Boxes, "GradientRGB1", Color3.fromRGB(139, 92, 246))
        AddToggle(secBoxes, "Animate Box Gradient", "BoxAnim", D.Boxes, "Animate", false)

        local nameTog = AddToggle(secInfo, "Player Names", "Names", D.Names, "Enabled", false)
        AddColor(nameTog, secInfo, "Name Color", "NameCol", D.Names, "RGB", Color3.fromRGB(246, 247, 255))
        local distTog = AddToggle(secInfo, "Distances", "Distances", D.Distances, "Enabled", false)
        AddColor(distTog, secInfo, "Distance Color", "DistCol", D.Distances, "RGB", Color3.fromRGB(192, 202, 220))
        local weapTog = AddToggle(secInfo, "Equipped Weapon", "Weapons", D.Weapons, "Enabled", false)
        AddColor(weapTog, secInfo, "Weapon Color", "WeapCol", D.Weapons, "WeaponTextRGB", Color3.fromRGB(172, 142, 255))
        AddToggle(secInfo, "Status Flags", "Flags", D.Flags, "Enabled", false)
        AddToggle(secInfo, "Health Bar", "HealthBar", D.Healthbar, "Enabled", false)
        AddToggle(secInfo, "Health Text", "HealthText", D.Healthbar, "HealthText", false)
        AddToggle(secInfo, "Smooth Health Lerp", "HealthLerp", D.Healthbar, "Lerp", true)
        local hpGrad = AddToggle(secInfo, "Gradient Health", "HealthGrad", D.Healthbar, "Gradient", true)
        AddColor(hpGrad, secInfo, "Low HP Color", "HPLow", D.Healthbar, "GradientRGB1", Color3.fromRGB(255, 55, 75))
        AddColor(hpGrad, secInfo, "Full HP Color", "HPHigh", D.Healthbar, "GradientRGB2", Color3.fromRGB(55, 245, 135))

        local chamTog = AddToggle(secChams, "Enable Chams", "ChamsEnabled", D.Chams, "Enabled", false)
        AddColor(chamTog, secChams, "Fill Color", "ChamsFill", D.Chams, "FillRGB", Color3.fromRGB(139, 92, 246))
        AddColor(chamTog, secChams, "Outline Color", "ChamsOutline", D.Chams, "OutlineRGB", Color3.fromRGB(255, 255, 255))
        secChams:Dropdown({
            Name = "Chams Mode",
            Flag = "ESP_ChamsMode",
            Items = { "Highlight", "Thermal", "Pulse", "Dual", "Adornment" },
            Options = { "Highlight", "Thermal", "Pulse", "Dual", "Adornment" },
            Default = D.Chams.Mode or "Highlight",
            Value = D.Chams.Mode or "Highlight",
            Callback = function(v)
                D.Chams.Mode = v
                D.Chams.Thermal = (v == "Thermal")
                RefreshESP()
            end,
        })
        local visTog = AddToggle(secChams, "Visible Only (Occluded)", "ChamsVisOnly", D.Chams, "VisibleCheck", false)
        AddColor(visTog, secChams, "Dual Visible Color", "ChamsVisCol", D.Chams, "VisibleRGB", Color3.fromRGB(52, 255, 140))
        AddSlider(secChams, "Fill Transparency", "ChamsFillTr", D.Chams, "Fill_Transparency", 0, 100, 50, 1, "%")
        AddSlider(secChams, "Outline Transparency", "ChamsOutTr", D.Chams, "Outline_Transparency", 0, 100, 10, 1, "%")
        AddSlider(secChams, "Pulse Speed", "ChamsPulse", D.Chams, "PulseSpeed", 0.5, 8, 2.5, 0.1, "x")

        local trTog = AddToggle(secExtras, "Tracers", "Tracers", D.Tracers, "Enabled", false)
        AddColor(trTog, secExtras, "Tracer Color", "TracerCol", D.Tracers, "RGB", Color3.fromRGB(255, 255, 255))
        AddDropdown(secExtras, "Tracer Origin", "TracerOrigin", D.Tracers, "Origin", { "Bottom", "Center", "Top", "Mouse" }, "Bottom")
        AddSlider(secExtras, "Tracer Thickness", "TracerThick", D.Tracers, "Thickness", 1, 5, 1.5, 0.1, "px")
        local skTog = AddToggle(secExtras, "Skeleton", "Skeleton", D.Skeleton, "Enabled", false)
        AddColor(skTog, secExtras, "Skeleton Color", "SkelCol", D.Skeleton, "RGB", Color3.fromRGB(255, 255, 255))
        AddSlider(secExtras, "Skeleton Thickness", "SkelThick", D.Skeleton, "Thickness", 1, 5, 1.4, 0.1, "px")
        local hdTog = AddToggle(secExtras, "Head Dot", "HeadDot", D.HeadDot, "Enabled", false)
        AddColor(hdTog, secExtras, "Head Dot Color", "HeadDotCol", D.HeadDot, "RGB", Color3.fromRGB(255, 90, 110))
        local arTog = AddToggle(secExtras, "Offscreen Arrows", "Arrows", D.Arrows, "Enabled", false)
        AddColor(arTog, secExtras, "Arrow Color", "ArrowCol", D.Arrows, "RGB", Color3.fromRGB(255, 75, 95))
        AddSlider(secExtras, "Arrow Size", "ArrowSize", D.Arrows, "Size", 8, 36, 16, 1, "px")
        AddSlider(secExtras, "Arrow Radius", "ArrowDist", D.Arrows, "Distance", 50, 320, 140, 1, "px")
        AddToggle(secExtras, "Arrow Outline", "ArrowOutline", D.Arrows, "Outlined", true)
    end

    local function BuildESPTab(target)
        if type(target) ~= "table" and type(target) ~= "userdata" then return false end
        local ok = pcall(function()
            local page = target
            if type(target.Page) == "function" and type(target.Section) ~= "function" then
                page = target:Page({ Name = "ESP", Icon = "rbxthumb://type=Asset&id=104303136903310&w=150&h=150" })
            elseif type(target.Tab) == "function" and type(target.Section) ~= "function" then
                page = target:Tab({ Name = "ESP", Icon = "rbxthumb://type=Asset&id=104303136903310&w=150&h=150" })
            end
            if type(page.Section) == "function" then
                local function mkSec(name, sideIdx)
                    local sideVal = (type(page.ColumnsData) == "table") and sideIdx or (sideIdx == 2 and "Right" or "Left")
                    return page:Section({ Name = name, Side = sideVal })
                end
                BuildControls(
                    mkSec("ESP Core", 1),
                    mkSec("Boxes", 1),
                    mkSec("Health & Labels", 1),
                    mkSec("Chams", 2),
                    mkSec("Tracers / Skeleton / Arrows", 2)
                )
            else
                BuildControls(target, target, target, target, target)
            end
        end)
        return ok
    end

    genv.ESP_VERSION = ESP_VERSION
    genv.ESP_Config = ConfigProxy
    genv.ESP_Registry = Registry
    genv.RefreshESP = RefreshESP
    genv.ESP_Refresh = RefreshESP
    genv.ESP_Destroy = DestroyESP
    genv.ESP_BuildTab = BuildESPTab
    genv.ESP_BuildUI = BuildESPTab
    genv.ESP_Set = function(path, value)
        local node = GetCfg()
        local parts = {}
        for chunk in string.gmatch(tostring(path), "[^%.]+") do
            table.insert(parts, chunk)
        end
        for i = 1, #parts - 1 do
            if type(node[parts[i]]) ~= "table" then node[parts[i]] = {} end
            node = node[parts[i]]
        end
        if #parts > 0 then
            node[parts[#parts]] = value
        end
        RefreshESP()
    end
end
