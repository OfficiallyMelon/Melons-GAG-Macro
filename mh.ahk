#Requires AutoHotkey 2.0+
#Requires AutoHotkey v2.0+

; recall wrench needs to be in slot 1
; zoom in and set cam to follow so behind plr perfectly

; Definitions

Seeds := ["Carrot Seed", "Strawberry Seed", "Blueberry Seed", "Tomato Seed", "Cauliflower Seed", "Watermelon Seed",
    "Green Apple Seed", "Avocado Seed", "Banana Seed", "Pineapple Seed", "Kiwi Seed", "Bell Pepper Seed",
    "Prickly Pear Seed", "Loquat Seed", "Feijoa Seed", "Sugar Apple"]

Gears := ["Watering Can", "Trowel", "Recall Wrench", "Basic Sprinkler", "Advanced Sprinkler", "Godly Sprinkler",
    "Tanning Mirror", "Master Sprinkler", "Cleaning Spray", "Favorite Tool", "Harvest Tool", "Friendship Pot"]

Config := Map(
    "UITheme", "",
    "WebhookURL", ""
)

UINav := Map(
    "Seeds", ["R", "R", "R"],
    "Garden", ["R", "R", "R", "R"],
    "Sell", ["R", "R", "R", "R", "R"],

    "SeedsMenu", ["D", "D"],
    "GearsMenu", ["D", "D"]
)

Binds := Map(
    "ProximityPrompt", ["E"],
    "UIBind", ["\"]
)

DirectionKeys := Map(
    "R", "Right",
    "L", "Left",
    "U", "Up",
    "D", "Down"
)

DetectionColors := Map(
    "KickMessage", "0x393B3D"
)

global FarmEnabled := false
global INIFile := "MelonHubSettings.ini"

; GUI Setup

MelonHubUI := Gui("AlwaysOnTop", "Melon Hub - Grow a Garden")
MelonHubUI.BackColor := "202020"
MelonHubUI.SetFont("s10 cWhite", "Segoe UI")
MelonHubUI.OnEvent("Close", GuiClose)

; Tabs
tab := MelonHubUI.AddTab3("x0 y0 w400 h500", ["Purchase Seeds", "Purchase Gears", "Config"])

; Settings Tab
tab.UseTab(3)

MelonHubUI.AddGroupBox("x15 y50 w370 h370 c90EE90", "Configuration")

; URL
MelonHubUI.Add("Text", "x60 y100", "Discord Webhook URL")
webhookEdit := MelonHubUI.Add("Edit", "x200 y97.5 w120 h25 vWebhookURL", Config["WebhookURL"])

; BUTTON
MacroButton := MelonHubUI.Add("Button", "x120 y450 w140 h25", "Macro Disabled (F8)")

; Seed Selection Tabs
tab.UseTab(1)

MelonHubUI.AddGroupBox("x15 y50 w370 h370 c90EE90", "Seeds Selection")

fruitCheckboxes := []
colCount := 2
spacingX := 150
spacingY := 30
startX := 60
startY := 120

loop Seeds.Length {
    col := Mod(A_Index - 1, colCount)
    row := Floor((A_Index - 1) / colCount)
    x := startX + (col * spacingX)
    y := startY + (row * spacingY)
    cb := MelonHubUI.AddCheckbox(Format("x{} y{} vSeed_{}", x, y, A_Index), Seeds[A_Index])
    fruitCheckboxes.Push(cb)
}

; Gears Selection Tab
tab.UseTab(2)

MelonHubUI.AddGroupBox("x15 y50 w370 h370 c90EE90", "Gears Selection")

gearCheckboxes := []
colCount := 2
spacingX := 150
spacingY := 30
startX := 60
startY := 120

loop Gears.Length {
    col := Mod(A_Index - 1, colCount)
    row := Floor((A_Index - 1) / colCount)
    x := startX + (col * spacingX)
    y := startY + (row * spacingY)
    cb := MelonHubUI.AddCheckbox(Format("x{} y{} vGear_{}", x, y, A_Index), Gears[A_Index])
    gearCheckboxes.Push(cb)
}

tab.UseTab()

; Functions

; Webhook

SendDiscordMessage(WebhookURL, MessageText) {
    if WebhookURL {
        JSON := "{`"content`":`"" MessageText "`"}"
        Http := ComObject("WinHttp.WinHttpRequest.5.1")
        Http.Open("POST", WebhookURL)
        Http.SetRequestHeader("Content-Type", "application/json")

        Http.Send(JSON)
    }
}

; Settings

LoadSettings() {
    global INIFile, Config, webhookEdit
    
    ; ini settings
    if FileExist(INIFile) {
        Config["WebhookURL"] := IniRead(INIFile, "Config", "WebhookURL", "")
        webhookEdit.Value := Config["WebhookURL"]
        
        ; load seedss
        loop Seeds.Length {
            section := "Seeds"
            key := Seeds[A_Index]
            value := IniRead(INIFile, section, key, "0")
            fruitCheckboxes[A_Index].Value := (value = "1")
        }
        
        ; load thao gear selections
        loop Gears.Length {
            section := "Gears"
            key := Gears[A_Index]
            value := IniRead(INIFile, section, key, "0")
            gearCheckboxes[A_Index].Value := (value = "1")
        }
    }
}

SaveSettings() {
    global INIFile, Config, webhookEdit
    
    ; save config settings
    IniWrite(webhookEdit.Value, INIFile, "Config", "WebhookURL")
    
    ; save seeds
    loop Seeds.Length {
        section := "Seeds"
        key := Seeds[A_Index]
        value := fruitCheckboxes[A_Index].Value ? "1" : "0"
        IniWrite(value, INIFile, section, key)
    }
    
    ; save gears
    loop Gears.Length {
        section := "Gears"
        key := Gears[A_Index]
        value := gearCheckboxes[A_Index].Value ? "1" : "0"
        IniWrite(value, INIFile, section, key)
    }
}

GuiClose(*) {
    SaveSettings()
    ExitApp
}

PressDirections(action) {
    global UINav, DirectionKeys

    directions := action

    for dir in directions {
        if DirectionKeys.Has(dir) {
            Send "{" DirectionKeys[dir] "}"
            Sleep 100
        } else {
            MsgBox "Invalid direction: " dir
        }
    }
}

MoveMouseToRobloxCenter() {
    winTitle := "ahk_exe RobloxPlayerBeta.exe"

    if WinExist(winTitle) {
        WinGetPos &winX, &winY, &winW, &winH, winTitle

        centerX := winX + (winW // 2)
        centerY := winY + (winH // 2)

        MouseMove centerX, centerY
    }
}

MoveMouseToRobloxCenter_Offset(X, Y) {
    winTitle := "ahk_exe RobloxPlayerBeta.exe"

    if WinExist(winTitle) {
        WinGetPos &winX, &winY, &winW, &winH, winTitle

        centerX := winX + (winW // 2)
        centerY := winY + (winH // 2)

        MouseMove centerX + X, centerY + Y
        MouseMove centerX + X + 1, centerY + Y
    }
}

GetSelectedSeeds() {
    selected := []
    loop fruitCheckboxes.Length {
        cb := fruitCheckboxes[A_Index]
        if cb.Value
            selected.Push(Seeds[A_Index])
    }
    return selected
}

GetSelectedGears() {
    selected := []
    loop gearCheckboxes.Length {
        cb := gearCheckboxes[A_Index]
        if cb.Value
            selected.Push(Gears[A_Index])
    }
    return selected
}

; ROBLOX Functions

; Teleport
TP_Garden() {
    Send Binds["UIBind"][1]
    PressDirections(UINav["Garden"])
    Send "{Enter}"
    Send Binds["UIBind"][1]
}

TP_Gear() {
    Send "1"
    Sleep 100
    MoveMouseToRobloxCenter()
    MouseClick "Left"
    Sleep 100
    Send "1"
}

TP_Seeds() {
    Send Binds["UIBind"][1]
    PressDirections(UINav["Seeds"])
    Send "{Enter}"
    Send Binds["UIBind"][1]
}

TP_Sell() {
    Send Binds["UIBind"][1]
    PressDirections(UINav["Sell"])
    Send "{Enter}"
    Send Binds["UIBind"][1]
}

; Helpers

ExitShop() {
    Send "{Up}"
    sleep 50
    Send "{Enter}"
}

; Seed Shop

OpenSeeds() {
    TP_Seeds()
    sleep 100
    ActivateProximity()
    sleep 3500
}

SelectSeedShop() {
    Send Binds["UIBind"][1]
    PressDirections(UINav["SeedsMenu"])
}

BuySeed(FruitName) {
    index := 0

    for i, name in Seeds {
        if name = FruitName {
            index := i - 1
            break
        }
    }

    loop index {
        Send "{Down}"
        Sleep 250
    }
    Send "{Enter}"
    send "{Down}"
    Sleep 50
    loop 20 {
        Send "{Enter}"
    }
    sleep 50
    send "{Up}"
    Send "{Enter}"
    Sleep 50
    loop index {
        sleep 250
        Send "{Up}"
    }
}

PurchaseSelectedSeeds() {
    for i, name in GetSelectedSeeds() {
        BuySeed(name)
    }
}

AutofarmSeeds() {
    if GetSelectedSeeds().Length = 0 { ; no selected seeds for autofarm
        return
    }

    OpenSeeds()
    SelectSeedShop()
    PurchaseSelectedSeeds()
    ; Close Menu
    ExitShop()
    ; Unselect UI
    Send Binds["UIBind"][1]
}

; Gear Shop

OpenGears() {
    TP_Gear()
    sleep 750
    ActivateProximity()
    sleep 3000
    MoveMouseToRobloxCenter_Offset(135,15) ; select prompt
    MouseClick "Left"
    Sleep 2000
}

SelectGearShop() {
    Send Binds["UIBind"][1]
    PressDirections(UINav["GearsMenu"])
}

BuyGear(GearName) {
    index := 0

    for i, name in Gears {
        if name = GearName {
            index := i - 1
            break
        }
    }

    loop index {
        Send "{Down}"
        Sleep 250
    }
    Send "{Enter}"
    send "{Down}"
    Sleep 50
    loop 20 {
        Send "{Enter}"
    }
    sleep 50
    send "{Up}"
    Send "{Enter}"
    Sleep 50
    loop index {
        sleep 250
        Send "{Up}"
    }
}

PurchaseSelectedGears() {
    for i, name in GetSelectedGears() {
        BuyGear(name)
    }
}

AutofarmGears() {
    if GetSelectedGears().Length = 0 { ; no selected gears for autofarm
        return
    }

    OpenGears()
    SelectGearShop()
    PurchaseSelectedGears()
    ; Close Menu
    ExitShop()
    ; Unselect UI
    Send Binds["UIBind"][1]
}

; Misc
ActivateProximity(SleepTime := 0) {
    key := Binds["ProximityPrompt"][1]

    if SleepTime > 0 {
        Send "{" key " down}"
        Sleep SleepTime
        Send "{" key " up}"
    } else {
        Send "{" key "}"
    }
}

CheckIfKicked() {
    winTitle := "ahk_exe RobloxPlayerBeta.exe"

    if WinExist(winTitle) {
        WinGetPos &winX, &winY, &winW, &winH, winTitle
        centerX := winX + (winW // 2)
        centerY := winY + (winH // 2)
        CoordMode("Pixel", "Screen")

        pixelColor := PixelGetColor(centerX, centerY) ; color of pixel

        if pixelColor := DetectionColors["KickMessage"] {
            SendDiscordMessage(webhookEdit.Value, "**ERROR:** Disconnected from game, attempting to rejoin.")
            MoveMouseToRobloxCenter_Offset(65,65)
            MouseClick "Left"
            sleep 25000
        }
    }
}

RunFarm() {
    if FarmEnabled {
        AutofarmSeeds()
        sleep 1000
        AutofarmGears()
        sleep 1000
        TP_Garden()
    }
}

MacroToggle() {
    global FarmEnabled
    FarmEnabled := !FarmEnabled
    if FarmEnabled {
        MacroButton.Text := "Macro Enabled (F8)"
    } else {
        MacroButton.Text := "Macro Disabled (F8)"
    }
}

; Activation

MsgBox("This is a test build meant for developers (BUGGY), feel free to use. There WILL be DRAGONS!")
LoadSettings()
MacroButton.OnEvent("Click", (*) => MacroToggle())
MelonHubUI.Show("w400 h500")

; HotKeys

F8::MacroToggle()

; Main Loop
Loop {
    global FarmEnabled
    if FarmEnabled { ; farm is enabled
        RunFarm()
        sleep 300000 ; 5 minutess
        CheckIfKicked() ; rejoin if kicked from game
    }
}