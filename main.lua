--[[
    AUTOTYPER- ROLEY (INSTANT-RESPONSE)
    - Full indexing for all word lengths.
    - Fixed Killer Mode toggle.
    - Humanized Acceleration & Discord Join.
--]]

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local VirtualInputManager = game:GetService("VirtualInputManager")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local GITHUB_URL = "https://raw.githubusercontent.com/dwyl/english-words/master/words_alpha.txt"
local SCRABBLE_URL = "https://raw.githubusercontent.com/solvenium/scrabble-dictionary/master/words.txt"
local GOOGLE_URL = "https://raw.githubusercontent.com/first20hours/google-10000-english/master/google-10000-english-no-swears.txt"
local DISCORD_INVITE = "https://discord.gg/sys"

local function StartSysTyper()
    if setclipboard then setclipboard(DISCORD_INVITE) end
    
    local UsedWords = {}
    local Index = { [1] = {}, [2] = {}, [3] = {}, [4] = {} }
    local Ready = false
    local CurrentChoice = ""
    local LastPrefix = ""
    local HardMode = true
    local WPM = 125
    local BindMode = nil 
    local CycleKey = {Type = Enum.UserInputType.Keyboard, Code = Enum.KeyCode.RightControl}
    local RetryKey = {Type = Enum.UserInputType.None, Code = nil}

    local CLUSTERS = {
        ["x"] = 5000, ["xq"] = 5500, ["zq"] = 5400, ["zj"] = 5300, ["vy"] = 5200, ["yv"] = 5100, ["xk"] = 5000,
        ["schr"] = 3500, ["sion"] = 3000, ["psy"] = 1500, ["thr"] = 1400, ["sch"] = 1300, 
        ["z"] = 800, ["j"] = 700, ["q"] = 600
    }

    local sg = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
    sg.Name = "obitortyper"
    sg.ResetOnSpawn = false
    local frame = Instance.new("Frame", sg)
    frame.Size = UDim2.new(0, 260, 0, 400)
    frame.Position = UDim2.new(0.8, 0, 0.4, 0)
    frame.BackgroundColor3 = Color3.fromRGB(12, 12, 15)
    frame.BorderSizePixel = 2
    frame.BorderColor3 = Color3.fromRGB(255, 0, 80)
    frame.Active = true frame.Draggable = true
    
    local title = Instance.new("TextLabel", frame)
    title.Size = UDim2.new(1, -30, 0, 35)
    title.Text = "is that you, obito? .gg/sys"
    title.TextColor3 = Color3.new(1, 1, 1)
    title.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    title.TextSize = 16 title.Font = Enum.Font.GothamBold
    
    local closeBtn = Instance.new("TextButton", frame)
    closeBtn.Size = UDim2.new(0, 30, 0, 35)
    closeBtn.Position = UDim2.new(1, -30, 0, 0)
    closeBtn.Text = "X"
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    
    local input = Instance.new("TextBox", frame)
    input.Size = UDim2.new(0.6, -15, 0, 40)
    input.Position = UDim2.new(0, 10, 0, 45)
    input.PlaceholderText = "Letters..."
    input.Text = ""
    input.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    input.TextColor3 = Color3.new(1, 1, 1)
    
    local cycleBtn = Instance.new("TextButton", frame)
    cycleBtn.Size = UDim2.new(0.4, -10, 0, 40)
    cycleBtn.Position = UDim2.new(0.6, 5, 0, 45)
    cycleBtn.Text = "Cycle"
    cycleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    cycleBtn.TextColor3 = Color3.new(1, 1, 1)
    
    local preview = Instance.new("TextLabel", frame)
    preview.Size = UDim2.new(1, -20, 0, 40)
    preview.Position = UDim2.new(0, 10, 0, 95)
    preview.Text = "DICT LOADING..."
    preview.TextColor3 = Color3.new(1, 1, 0)
    preview.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
    preview.TextSize = 18 preview.Font = Enum.Font.GothamBold
    
    local typeBtn = Instance.new("TextButton", frame)
    typeBtn.Size = UDim2.new(1, -20, 0, 40)
    typeBtn.Position = UDim2.new(0, 10, 0, 140)
    typeBtn.Text = "AUTO TYPE (KEY=ENTER)"
    typeBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
    typeBtn.TextColor3 = Color3.new(1, 1, 1)
    
    local retryBtn = Instance.new("TextButton", frame)
    retryBtn.Size = UDim2.new(1, -20, 0, 40)
    retryBtn.Position = UDim2.new(0, 10, 0, 185)
    retryBtn.Text = "RETRY & RESEND"
    retryBtn.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
    retryBtn.TextColor3 = Color3.new(1, 1, 1)

    local divider = Instance.new("Frame", frame)
    divider.Size = UDim2.new(1, -20, 0, 2)
    divider.Position = UDim2.new(0, 10, 0, 235)
    divider.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    
    local cycleKeyBtn = Instance.new("TextButton", frame)
    cycleKeyBtn.Size = UDim2.new(1, -20, 0, 30)
    cycleKeyBtn.Position = UDim2.new(0, 10, 0, 245)
    cycleKeyBtn.Text = "Cycle Key: RightControl"
    cycleKeyBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    cycleKeyBtn.TextColor3 = Color3.new(0, 1, 1)

    local retryKeyBtn = Instance.new("TextButton", frame)
    retryKeyBtn.Size = UDim2.new(1, -20, 0, 30)
    retryKeyBtn.Position = UDim2.new(0, 10, 0, 280)
    retryKeyBtn.Text = "Retry Key: [Bind]"
    retryKeyBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    retryKeyBtn.TextColor3 = Color3.new(1, 0.5, 0.5)

    local hardToggle = Instance.new("TextButton", frame)
    hardToggle.Size = UDim2.new(0.5, -15, 0, 30)
    hardToggle.Position = UDim2.new(0, 10, 0, 320)
    hardToggle.Text = "KILLER: ON"
    hardToggle.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
    hardToggle.TextColor3 = Color3.new(1, 1, 1)
    
    local resetBtn = Instance.new("TextButton", frame)
    resetBtn.Size = UDim2.new(0.5, -15, 0, 30)
    resetBtn.Position = UDim2.new(0.5, 5, 0, 320)
    resetBtn.Text = "RESET"
    resetBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
    resetBtn.TextColor3 = Color3.new(1, 1, 1)

    local wpmIn = Instance.new("TextBox", frame)
    wpmIn.Size = UDim2.new(1, -20, 0, 30)
    wpmIn.Position = UDim2.new(0, 10, 0, 360)
    wpmIn.Text = "WPM: 125"
    wpmIn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    wpmIn.TextColor3 = Color3.new(1, 1, 1)

    local function IndexWord(w)
        w = w:lower():gsub("%s+", "")
        if #w >= 1 then 
            local len = math.min(#w, 4)
            for i = 1, len do
                local p = w:sub(1, i)
                if not Index[i][p] then Index[i][p] = {} end
                table.insert(Index[i][p], w)
            end
        end
    end

    local function GetClusterScore(word)
        if not HardMode then return 0 end
        for i = 4, 1, -1 do local suffix = word:sub(-i) if CLUSTERS[suffix] then return CLUSTERS[suffix] end end
        return 0
    end

    local function UpdatePreview()
        local start = input.Text:lower():gsub("%s+", "")
        if start == "" then CurrentChoice = "" preview.Text = "..." preview.TextColor3 = Color3.new(1,1,1) return end
        if not Ready then preview.Text = "LOADING..." return end
        
        local idxLen = math.min(#start, 4)
        local prefix = start:sub(1, idxLen)
        CurrentChoice = ""
        if Index[idxLen][prefix] then
            local poss = {}
            for _, word in ipairs(Index[idxLen][prefix]) do
                if word:sub(1, #start) == start and not UsedWords[word] then table.insert(poss, word) end
            end
            if #poss > 0 then
                if HardMode then
                    table.sort(poss, function(a, b) return GetClusterScore(a) > GetClusterScore(b) end)
                    local top = {}
                    local ts = GetClusterScore(poss[1])
                    for i = 1, 10 do if poss[i] and GetClusterScore(poss[i]) >= (ts * 0.5) then table.insert(top, poss[i]) end end
                    CurrentChoice = top[math.random(1, #top)]
                else
                    CurrentChoice = poss[1]
                end
            end
        end
        if CurrentChoice ~= "" then
            preview.Text = CurrentChoice:upper()
            preview.TextColor3 = Color3.new(0, 1, 1)
        else
            preview.Text = "NO MATCHES"
            preview.TextColor3 = Color3.new(1, 0, 0)
        end
    end

    task.spawn(function()
        local sources = {GOOGLE_URL, SCRABBLE_URL, GITHUB_URL}
        for _, url in ipairs(sources) do
            local s, c = pcall(function() return game:HttpGet(url) end)
            if s then for _,w in ipairs(string.split(c, "\n")) do IndexWord(w) end end
        end
        Ready = true
        UpdatePreview()
    end)

    local function SimulateType(word, start)
        local suffix = word:sub(#start + 1)
        local baseDelay = 60 / (WPM * 5)
        for i = 1, #suffix do
            local char = suffix:sub(i, i)
            local kc = Enum.KeyCode[char:upper()]
            local speedMult = 0.85 + ((i / #suffix) * 0.35) 
            if kc then
                VirtualInputManager:SendKeyEvent(true, kc, false, game)
                task.wait(baseDelay * (math.random(15, 30)/100))
                VirtualInputManager:SendKeyEvent(false, kc, false, game)
            end
            task.wait((baseDelay / speedMult) * (math.random(75, 125)/100))
        end
        task.wait(0.1)
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
        task.wait(0.02)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
    end

    local function TypeSelected()
        if CurrentChoice == "" then return end
        local start = input.Text:lower():gsub("%s+", "")
        LastPrefix = start
        UsedWords[CurrentChoice] = true
        local w = CurrentChoice
        input.Text = ""
        SimulateType(w, start)
        task.defer(function() input:CaptureFocus() end)
        UpdatePreview()
    end

    local function RetryAndResend()
        if CurrentChoice ~= "" then UsedWords[CurrentChoice] = true end
        for i = 1, 22 do VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Backspace, false, game) task.wait(0.01) VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Backspace, false, game) end
        input.Text = LastPrefix
        UpdatePreview()
        if CurrentChoice ~= "" then TypeSelected() end
    end

    closeBtn.MouseButton1Click:Connect(function() sg:Destroy() end)
    retryBtn.MouseButton1Click:Connect(RetryAndResend)
    cycleKeyBtn.MouseButton1Click:Connect(function() BindMode = "Cycle" cycleKeyBtn.Text = "Press Key..." end)
    retryKeyBtn.MouseButton1Click:Connect(function() BindMode = "Retry" retryKeyBtn.Text = "Press Key..." end)
    
    UserInputService.InputBegan:Connect(function(inputObj)
        if BindMode then
            local t, c = nil, nil
            if inputObj.UserInputType == Enum.UserInputType.Keyboard then t, c = Enum.UserInputType.Keyboard, inputObj.KeyCode
            elseif inputObj.UserInputType.Name:find("MouseButton") then t, c = inputObj.UserInputType, nil end
            if t then
                if BindMode == "Cycle" then CycleKey = {Type = t, Code = c} cycleKeyBtn.Text = "Cycle: " .. (c and c.Name or t.Name)
                else RetryKey = {Type = t, Code = c} retryKeyBtn.Text = "Retry: " .. (c and c.Name or t.Name) end
                BindMode = nil
            end
            return
        end
        local isCycle = (inputObj.UserInputType == CycleKey.Type and (not CycleKey.Code or inputObj.KeyCode == CycleKey.Code))
        local isRetry = (inputObj.UserInputType == RetryKey.Type and (not RetryKey.Code or inputObj.KeyCode == RetryKey.Code))
        if isCycle and CurrentChoice ~= "" then UsedWords[CurrentChoice] = true UpdatePreview() end
        if isRetry then RetryAndResend() end
    end)

    hardToggle.MouseButton1Click:Connect(function() 
        HardMode = not HardMode 
        hardToggle.Text = HardMode and "KILLER: ON" or "KILLER: OFF" 
        hardToggle.BackgroundColor3 = HardMode and Color3.fromRGB(150, 0, 0) or Color3.fromRGB(60, 20, 20) 
        UpdatePreview() 
    end)
    
    wpmIn.FocusLost:Connect(function() local val = tonumber(wpmIn.Text:match("%d+")) if val then WPM = math.clamp(val, 1, 500) wpmIn.Text = "WPM: " .. WPM end end)
    resetBtn.MouseButton1Click:Connect(function() UsedWords = {} UpdatePreview() end)
    input:GetPropertyChangedSignal("Text"):Connect(UpdatePreview)
    cycleBtn.MouseButton1Click:Connect(function() if CurrentChoice ~= "" then UsedWords[CurrentChoice] = true UpdatePreview() end end)
    typeBtn.MouseButton1Click:Connect(TypeSelected)
    input.FocusLost:Connect(function(enter) if enter then TypeSelected() end end)
end

StartSysTyper()
