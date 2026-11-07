script_name("ResHelper")
script_authors("Ryder")
script_description("Helper for Farm & Mine Resources")
script_version("1.4.0.1")
script_properties("work-in-progress")
setver = 1
local RESOURCE_VERSION = "1.0.0" 
require "lib.sampfuncs"
require "lib.moonloader"
local mem = require "memory"
local vkeys = require "vkeys"
local requests = require("lib.requests")
local effil = require("effil")
local encoding = require "encoding"
local wm = require 'lib.windows.message'
encoding.default = "CP1251"
local u8 = encoding.UTF8
local dlstatus = require("moonloader").download_status
local SCRIPT_COLOR = 0xFF1AE591
local COLOR_MAIN = "{1AE591}"
local COLOR_WHITE = "{FFFFFF}"
local SCRIPT_PREFIX = COLOR_WHITE.."["..COLOR_MAIN.."ResHelper"..COLOR_WHITE.."]: "
local newversion = ""
local newdate = ""
cachedTodayStats = nil
cachedTodayTime = 0
cachedWeekStats = nil
cachedWeekTime = 0
ignoreInventoryUntil = 0
talonBaselineReady = false 
talonRescanPending = false 
ignoreCaseDropUntil = 0
scanSlots = {}
tgMessageQueue = {}
lbRowsLimit = 9999
farmExpandIncome = false
sawExpandIncome = false
farmExpandToday = false
farmExpandWeek = false
sawExpandToday = false
sawExpandWeek = false
lbShowAllServers = nil
tgQueueProcessing = false
tgQueueProcessingStartTime = 0
function processTgQueue() end
achievementUpdateTime = 0
logoArz = nil 
serverIcons = {}
achievementNotifications = {}
devNotifications = {}
devImportantQueue = {}
devImportantCurrent = nil
lastAnnouncementCheck = 0
announcementHistory = {}
notifHistoryPopupOpen = false
notifBellHoveredGlobal = false 
editingBindIdx = nil
currentTab = 1
paydayAccessoryReceived = false
paydayLog = {}
paydayActive = false
paydaySalary = 0
paydayDeposit = 0
paydayAZ = 0
paydayAccBonus = 0
paydayRub = 0
showRubColumn = true
cachedIMWeekTime = 0
oilLog = {}
taxiLog = {}
incassLog = {}
stockLog = {}
stockPendingTime = {}
stockScannedThisSession = false
pendingStockScan = false
incassSelectedDateStr = nil
incassCalendarYear = nil
incassCalendarMonth = nil
incassSectionTab = nil
incassWorkActive = false 
STOCKS = {
    [1080]  = {name = "Акция Arizona (AARRP)", ticker = "AARRP"},
    [10235] = {name = "Акция S&P 500 (SPX)", ticker = "SPX"},
    [10236] = {name = "Акция Apple (AAPL)", ticker = "AAPL"},
    [10237] = {name = "Акция Microsoft (MSFT)", ticker = "MSFT"},
    [10238] = {name = "Акция Amazon (AMZN)", ticker = "AMZN"},
    [10239] = {name = "Акция Alphabet (GOOGL)", ticker = "GOOGL"},
    [10240] = {name = "Акция Tesla (TSLA)", ticker = "TSLA"},
    [10241] = {name = "Акция Volkswagen ST (VOWG)", ticker = "VOWG"},
    [10242] = {name = "Акция Mercedes-Benz Group (MBG)", ticker = "MBG"},
    [10243] = {name = "Акция BMW (BMWKY)", ticker = "BMWKY"},
    [10244] = {name = "Акция Toyota (TM)", ticker = "TM"},
    [10245] = {name = "Акция SpaceX (SPACEX)", ticker = "SPACEX"},
    [10246] = {name = "Акция Nvidia (NVDA)", ticker = "NVDA"},
}
STOCK_ORDER = {1080, 10235, 10236, 10237, 10238, 10239, 10240, 10241, 10242, 10243, 10244, 10245, 10246}
CRYPTO_BASE_IDS = {1811, 5996}
for _, sid in ipairs(STOCK_ORDER) do table.insert(CRYPTO_BASE_IDS, sid) end
oilBonusPercent = 0
oilWorkActive = false
oilConfig = {
    barrelCost = 40000, 
    azBarrelCost = 12,
    groundOilMoney = 270000, 
    groundBarrelAZBonus = 15, 
    groundBarrelCompanyBonus = 40000, 
    stampsToday = 0,
    stampsAll = 0,
}
caseConfig = {}
local ALL_CASES = {
    [569] = "Сундук рулетки", [1637] = "Rare Box Yellow", [1638] = "Rare Box Red",
    [1639] = "Rare Box Blue", [1766] = "Ящик Marvel", [1767] = "Ящик Джентельменов",
    [1768] = "Ящик Minecraft", [1769] = "Супер мото-ящик", [1770] = "Супер авто-ящик",
    [1852] = "Super Car Box", [1853] = "Ларец с премией", [1939] = "Ностальгический ящик",
    [2002] = "Одежда из секонд-хенда", [2149] = "Ларец Олигарха", [2187] = "Ларец кастомных аксессуаров",
    [3559] = "Ларец организации", [3565] = "Ларец крафтера", [3623] = "Ларец дальнобойщика",
    [3920] = "Concept Car Luxury", [3991] = "Ларец Mortal Combat", [3992] = "Ларец Водителя Автобуса",
    [4242] = "Ларец рыболова", [4584] = "Рандомный Ларец", [4792] = "Ларец пилота",
    [4793] = "Ларец развозчика продуктов", [4794] = "Ларец кладоискателя", [5323] = "Ларец Vice City",
    [5479] = "Ларец Tidex", [6199] = "Ларец семейных охранников", [6234] = "Ларец петуха",
    [7350] = "Ларец инкассатора", [7418] = "Ящик рыболова", [7480] = "Ларец Fortnite",
    [7759] = "Ларец Arizona", [8095] = "Голубой Ларец Миража", [8096] = "Золотой Ларец Миража",
    [8552] = "Ларец мусорщика", [8949] = "Рулетка тьмы", [8965] = "Рулетка гетто",
    [9538] = "Кейс Глента", [9764] = "Кейс Нового Сезона",
    [555] = "Бронзовая рулетка", [556] = "Серебренная рулетка", [557] = "Золотая рулетка",
    [1425] = "Платиновая рулетка", [5810] = "Ларец хэллоуина 2022", [7698] = "Пасхальный ларец 2024",
    [9904] = "Ларец Death Match", [9905] = "Ларец Triple War",
    [10251] = "Кейс Frame", [10252] = "Case Capture",
    [10754] = "Case Anarchy", [10755] = "Case Dead West",
}
function caseKey(itemId)
    return "case_" .. tostring(itemId)
end
oilLastSoldLiters = 0
oilSessionData = {money = 0, az = 0}
investmentLog = {}
investmentConfig = {}
cryptoLog = {}
cryptoConfig = {}
local ALL_CRYPTO = {
    [1811] = "Bitcoin (BTC)",
    [5996] = "Arizona Stable Coin (ASC)",
}
local tgConfig = {
    enabled = false,
    botToken = "",
    chatId = "",
    itemMarketEnabled = true,
    shardEnabled = true,
    dailyReportEnabled = false,
    weeklyReportEnabled = false,
    useReserveServer = true,
    paydayEnabled = true,
}
AUTO_AD_CHATS = {"/vr", "/ad", "/s", "/al", "/fam", "/r", "/rb", "/f", "/fb", "/g"}
autoAdConfig = {
    saveDelay = false,
    ads = {},
}
chatFilterConfig = {
    enabled = true,
    filters = {},
}
autoAdVrDialogState = { pending = false, withAd = false, pendingTime = 0 }
cryptoPriceDialogState = { pending = false, pendingTime = 0 }
autoAdAdDialogState = { pending = false, pendingTime = 0, radioIdx = 0, vip = false }
AD_RADIO_STATIONS = {[1] = "Los Santos", [2] = "Las Venturas", [3] = "San Fierro"}
local sampfuncsNot = [[
 Не обнаружен файл SAMPFUNCS.asi в папке игры, вследствие чего
скрипту не удалось запуститься.
		Для решения проблемы:
1. Закройте игру;
2. Зайдите во вкладку "Моды" в лаунчере Аризоны.
Найдите во вкладке "Моды" установщик "Moonloader" и нажмите кнопку "Установить".
После завершения установки вновь запустите игру. Проблема исчезнет.
По проблемам заводите issue на GitHub. Ссылка есть на вкладке: О скрипте
Игра была свернута, поэтому можете продолжить играть. 
]]
local errorText = [[
		  Внимание! 
Не обнаружены некоторые важные файлы для работы скрипта.ё
В следствии чего, скрипт перестал работать.
	Список необнаруженных файлов:
		%s
		Для решения проблемы:
1. Закройте игру;
2. Зайдите во вкладку "Моды" в лаунчере Аризоны.
Найдите во вкладке "Моды" установщик "Moonloader" и нажмите кнопку "Установить".
После завершения установки вновь запустите игру. Проблема исчезнет.
По проблемам заводите issue на GitHub. Ссылка есть на вкладке: О скрипте
Игра была свернута, поэтому можете продолжить играть. 
]]
local files = {
"/lib/imgui.lua",
"/lib/samp/events.lua",
"/lib/rkeysFD.lua",
"/lib/faIcons.lua",
"/lib/crc32ffi.lua",
"/lib/bitex.lua",
"/lib/MoonImGui.dll",
"/lib/matrix3x3.lua"
}
if doesFileExist(getWorkingDirectory().."/lib/rkeysFD.lua") then
	print("{82E28C}Чтение библиотеки rkeysFD...")
	local f = io.open(getWorkingDirectory().."/lib/rkeysFD.lua")
	f:close()
else
	print("{F54A4A}Ошибка. Отсутствует библиотека rkeysFD {82E28C}Создание библиотеки rkeysFD...")
	local textrkeys = [[
local vkeys = require 'vkeys'
vkeys.key_names[vkeys.VK_LMENU] = "LAlt"
vkeys.key_names[vkeys.VK_RMENU] = "RAlt"
vkeys.key_names[vkeys.VK_LSHIFT] = "LShift"
vkeys.key_names[vkeys.VK_RSHIFT] = "RShift"
vkeys.key_names[vkeys.VK_LCONTROL] = "LCtrl"
vkeys.key_names[vkeys.VK_RCONTROL] = "RCtrl"
local tHotKey = {}
local tKeyList = {}
local tKeysCheck = {}
local iCountCheck = 0
local tBlockKeys = {[vkeys.VK_LMENU] = true, [vkeys.VK_RMENU] = true, [vkeys.VK_RSHIFT] = true, [vkeys.VK_LSHIFT] = true, [vkeys.VK_LCONTROL] = true, [vkeys.VK_RCONTROL] = true}
local tModKeys = {[vkeys.VK_MENU] = true, [vkeys.VK_SHIFT] = true, [vkeys.VK_CONTROL] = true}
local tBlockNext = {}
local module = {}
module._VERSION = "1.0.7"
module._MODKEYS = tModKeys
module._LOCKKEYS = false
local function getKeyNum(id)
   for k, v in pairs(tKeyList) do
      if v == id then
         return k
      end
   end
   return 0
end
function module.blockNextHotKey(keys)
   local bool = false
   if not module.isBlockedHotKey(keys) then
      tBlockNext[#tBlockNext + 1] = keys
      bool = true
   end
   return bool
end
function module.isHotKeyHotKey(keys, keys2)
   local bool
   for k, v in pairs(keys) do
      local lBool = true
      for i = 1, #keys2 do
         if v ~= keys2[i] then
            lBool = false
            break
         end
      end
      if lBool then
         bool = true
         break
      end
   end
   return bool
end
function module.isBlockedHotKey(keys)
   local bool, hkId = false, -1
   for k, v in pairs(tBlockNext) do
      if module.isHotKeyHotKey(keys, v) then
         bool = true
         hkId = k
         break
      end
   end
   return bool, hkId
end
function module.unBlockNextHotKey(keys)
   local result = false
   local count = 0
   while module.isBlockedHotKey(keys) do
      local _, id = module.isBlockedHotKey(keys)
      tHotKey[id] = nil
      result = true
      count = count + 1
   end
   local id = 1
   for k, v in pairs(tBlockNext) do
      tBlockNext[id] = v
      id = id + 1
   end
   return result, count
end
function module.isKeyModified(id)
   return (tModKeys[id] or false) or (tBlockKeys[id] or false)
end
function module.isModifiedDown()
   local bool = false
   for k, v in pairs(tModKeys) do
      if isKeyDown(k) then
         bool = true
         break
      end
   end
   return bool
end
lua_thread.create(function ()
   while true do
      wait(0)
      local tDownKeys = module.getCurrentHotKey()
      for k, v in pairs(tHotKey) do
         if #v.keys > 0 then
            local bool = true
            for i = 1, #v.keys do
               if i ~= #v.keys and (getKeyNum(v.keys[i]) > getKeyNum(v.keys[i + 1]) or getKeyNum(v.keys[i]) == 0) then
                  bool = false
                  break
               elseif i == #v.keys and (v.pressed and not wasKeyPressed(v.keys[i]) or not v.pressed and not isKeyDown(v.keys[i])) or (#v.keys == 1 and module.isModifiedDown()) then
                  bool = false
                  break
               end
            end
            if bool and ((module.onHotKey and module.onHotKey(k, v.keys) ~= false) or module.onHotKey == nil) then
               local result, id = module.isBlockedHotKey(v.keys)
               if not result then
                  v.callback(k, v.keys)
               else
                  tBlockNext[id] = nil
               end
            end
         end
      end
   end
end)
function module.registerHotKey(keys, pressed, callback)
   tHotKey[#tHotKey + 1] = {keys = keys, pressed = pressed, callback = callback}
   return true, #tHotKey
end
function module.getAllHotKey()
   return tHotKey
end
function module.unRegisterHotKey(keys)
   local result = false
   local count = 0
   while module.isHotKeyDefined(keys) do
      local _, id = module.isHotKeyDefined(keys)
      tHotKey[id] = nil
      result = true
      count = count + 1
   end
   local id = 1
   local tNewHotKey = {}
   for k, v in pairs(tHotKey) do
      tNewHotKey[id] = v
      id = id + 1
   end
   tHotKey = tNewHotKey
   return result, count
end
function module.isHotKeyDefined(keys)
   local bool, hkId = false, -1
   for k, v in pairs(tHotKey) do
      if module.isHotKeyHotKey(keys, v.keys) then
         bool = true
         hkId = k
         break
      end
   end
   return bool, hkId
end
function module.getKeysName(keys)
   local tKeysName = {}
   for k, v in ipairs(keys) do
      tKeysName[k] = vkeys.id_to_name(v)
   end
   return tKeysName
end
function module.getCurrentHotKey(type)
   local type = type or 0
   local tCurKeys = {}
   for k, v in pairs(vkeys) do
      if tBlockKeys[v] == nil then
         local num, down = getKeyNum(v), isKeyDown(v)
         if down and num == 0 then
            tKeyList[#tKeyList + 1] = v
         elseif num > 0 and not down then
            tKeyList[num] = nil
         end
      end
   end
   local i = 1
   for k, v in pairs(tKeyList) do
      tCurKeys[i] = type == 0 and v or vkeys.id_to_name(v)
      i = i + 1
   end
   return tCurKeys
end
return module
]]
	local f = io.open(getWorkingDirectory().."/lib/rkeysFD.lua", "w")
	f:write(textrkeys)
	f:close()			
end
local nofiles = {}
for i,v in ipairs(files) do
	if not doesFileExist(getWorkingDirectory()..v) then
		table.insert(nofiles, v)
	end
end
local ffi = require 'ffi'
ffi.cdef [[
		typedef int BOOL;
		typedef unsigned long HANDLE;
		typedef HANDLE HWND;
		typedef const char* LPCSTR;
		typedef unsigned UINT;
		
        void* __stdcall ShellExecuteA(void* hwnd, const char* op, const char* file, const char* params, const char* dir, int show_cmd);
        uint32_t __stdcall CoInitializeEx(void*, uint32_t);
		
		BOOL ShowWindow(HWND hWnd, int  nCmdShow);
		HWND GetActiveWindow();
		
		int MessageBoxA(
		  HWND   hWnd,
		  LPCSTR lpText,
		  LPCSTR lpCaption,
		  UINT   uType
		);
		
		short GetKeyState(int nVirtKey);
		bool GetKeyboardLayoutNameA(char* pwszKLID);
		int GetLocaleInfoA(int Locale, int LCType, char* lpLCData, int cchData);
  ]]
local shell32 = ffi.load 'Shell32'
local ole32 = ffi.load 'Ole32'
ole32.CoInitializeEx(nil, 2 + 4)
if not doesFileExist(getGameDirectory().."/SAMPFUNCS.asi") then
	ffi.C.ShowWindow(ffi.C.GetActiveWindow(), 6)
	ffi.C.MessageBoxA(0, sampfuncsNot, "ResHelper", 0x00000030 + 0x00010000) 
end
if #nofiles > 0 then
	ffi.C.ShowWindow(ffi.C.GetActiveWindow(), 6)
	ffi.C.MessageBoxA(0, errorText:format(table.concat(nofiles, "\n\t\t")), "ResHelper", 0x00000030 + 0x00010000) 
end
local res, hook = pcall(require, 'lib.samp.events')
assert(res, "Библиотека SAMP Event не найдена")
local res, imgui = pcall(require, "imgui")
assert(res, "Библиотека Imgui не найдена")
local tgTokenInput = imgui.ImBuffer(100)
local tgChatIdInput = imgui.ImBuffer(50)
cb_chatFilterEnabled = imgui.ImBool(true)
local res, fa = pcall(require, 'faIcons')
assert(res, "Библиотека faIcons не найдена")
local res, rkeys = pcall(require, 'rkeysFD')
assert(res, "Библиотека Rkeys не найдена")
local imadd = nil
if doesFileExist(getWorkingDirectory() .. "/lib/imgui_addons.lua") then
    imadd = require "imgui_addons"
else
    imadd = {}
    function imadd.HotKey(label, bindTable, lastKeys, width)
        imgui.Text(u8("Клавиша: Н/Д (нет imgui_addons)"))
        return false
    end
end
vkeys.key_names[vkeys.VK_RBUTTON] = "RBut"
vkeys.key_names[vkeys.VK_XBUTTON1] = "XBut1"
vkeys.key_names[vkeys.VK_XBUTTON2] = 'XBut2'
vkeys.key_names[vkeys.VK_NUMPAD1] = 'Num 1'
vkeys.key_names[vkeys.VK_NUMPAD2] = 'Num 2'
vkeys.key_names[vkeys.VK_NUMPAD3] = 'Num 3'
vkeys.key_names[vkeys.VK_NUMPAD4] = 'Num 4'
vkeys.key_names[vkeys.VK_NUMPAD5] = 'Num 5'
vkeys.key_names[vkeys.VK_NUMPAD6] = 'Num 6'
vkeys.key_names[vkeys.VK_NUMPAD7] = 'Num 7'
vkeys.key_names[vkeys.VK_NUMPAD8] = 'Num 8'
vkeys.key_names[vkeys.VK_NUMPAD9] = 'Num 9'
vkeys.key_names[vkeys.VK_MULTIPLY] = 'Num *'
vkeys.key_names[vkeys.VK_ADD] = 'Num +'
vkeys.key_names[vkeys.VK_SEPARATOR] = 'Separator'
vkeys.key_names[vkeys.VK_SUBTRACT] = 'Num -'
vkeys.key_names[vkeys.VK_DECIMAL] = 'Num .Del'
vkeys.key_names[vkeys.VK_DIVIDE] = 'Num /'
vkeys.key_names[vkeys.VK_LEFT] = 'Ar.Left'
vkeys.key_names[vkeys.VK_UP] = 'Ar.Up'
vkeys.key_names[vkeys.VK_RIGHT] = 'Ar.Right'
vkeys.key_names[vkeys.VK_DOWN] = 'Ar.Down'
--- Файловая система
local dirml = getWorkingDirectory()
local dirGame = getGameDirectory()
local scr = thisScript()
local mainWin = imgui.ImBool(false)
local workTypeSelected = false
mainWinPos = { x = 0, y = 0 }
mainWinPosInitialized = false
dragStartPos = nil
WINDOW_ANIM_DURATION = 0.18
windowAnimAlpha = 0
windowAnimLastState = false
windowAnimStartTime = os.clock()
MENU_HIGHLIGHT_ANIM_DURATION = 0.24
menuHighlightY = nil
menuHighlightFromY = nil
menuHighlightTargetY = nil
menuHighlightAnimStart = os.clock()
-- ====== КОНФИГУРАЦИЯ БИНДЕРА ======
local binderDir = dirml .. "/ResHelper/binder/"
if not doesDirectoryExist(binderDir) then
    createDirectory(binderDir)
end
local binderDbPath = binderDir .. "binds.json"
local bindDatabase = { binds = {} }
if doesFileExist(binderDbPath) then
    local f = io.open(binderDbPath, "r")
    if f then
        bindDatabase = decodeJson(f:read("*a")) or { binds = {} }
        f:close()
    end
end
-- ImGui элементы для биндера
local editBindName = imgui.ImBuffer(30)
local editBindMultiline = imgui.ImBuffer(17000)
local addBindName = imgui.ImBuffer(30)
local addBindMultiline = imgui.ImBuffer(17000)
local lastKeys = {}
-- ====== Свой виджет записи клавиш (поддержка боковых кнопок мыши) ======
customBindEdit = nil
customBindKeys = {}
customBindSave = {}
customBindTick = os.clock()
customBindTickState = false
customBindModKeys = {[vkeys.VK_MENU] = true, [vkeys.VK_SHIFT] = true, [vkeys.VK_CONTROL] = true, [vkeys.VK_LMENU] = true, [vkeys.VK_RMENU] = true, [vkeys.VK_LSHIFT] = true, [vkeys.VK_RSHIFT] = true, [vkeys.VK_LCONTROL] = true, [vkeys.VK_RCONTROL] = true}
WM_XBUTTONDOWN = wm.WM_XBUTTONDOWN or 0x020B
function customBindKeyNum(id)
    for k, v in ipairs(customBindKeys) do
        if v == id then return k end
    end
    return -1
end
function customBindGetNames(keys)
    local names = {}
    for k, v in ipairs(keys) do
        names[k] = vkeys.id_to_name(v)
    end
    return names
end
function customHotKeyWidget(name, bindTable, width)
    local width = width or 90
    local bool = false
    local sKeys = table.concat(customBindGetNames(bindTable.v or {}), " + ")
    if #customBindSave > 0 and customBindSave[1] == name then
        bindTable.v = customBindSave[2]
        sKeys = table.concat(customBindGetNames(bindTable.v), " + ")
        customBindSave = {}
        bool = true
    elseif customBindEdit == name then
        if #customBindKeys == 0 then
            if os.clock() - customBindTick > 0.5 then
                customBindTick = os.clock()
                customBindTickState = not customBindTickState
            end
            sKeys = customBindTickState and u8("Нет") or " "
        else
            sKeys = table.concat(customBindGetNames(customBindKeys), " + ")
        end
    end
    imgui.PushStyleColor(imgui.Col.Button, imgui.GetStyle().Colors[imgui.Col.FrameBg])
    imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.GetStyle().Colors[imgui.Col.FrameBgHovered])
    imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.GetStyle().Colors[imgui.Col.FrameBgActive])
    if imgui.Button((tostring(sKeys):len() == 0 and u8("Нет") or sKeys) .. name, imgui.ImVec2(width, 0)) then
        customBindEdit = name
        customBindKeys = {}
    end
    imgui.PopStyleColor(3)
    return bool
end
addEventHandler('onWindowMessage', function(msg, wparam, lparam)
    if customBindEdit == nil then return end
    if msg == wm.WM_KEYDOWN or msg == wm.WM_SYSKEYDOWN then
        if wparam == vkeys.VK_ESCAPE then
            customBindKeys = {}
            customBindEdit = nil
            consumeWindowMessage(true, true)
            return
        end
        if wparam == vkeys.VK_BACK then
            customBindSave = {customBindEdit, {}}
            customBindEdit = nil
            consumeWindowMessage(true, true)
            return
        end
        if customBindKeyNum(wparam) == -1 then
            customBindKeys[#customBindKeys + 1] = wparam
            if not customBindModKeys[wparam] then
                customBindSave = {customBindEdit, customBindKeys}
                customBindEdit = nil
                customBindKeys = {}
            end
        end
        consumeWindowMessage(true, true)
    elseif msg == wm.WM_KEYUP or msg == wm.WM_SYSKEYUP then
        local num = customBindKeyNum(wparam)
        if num > -1 then table.remove(customBindKeys, num) end
        consumeWindowMessage(true, true)
    elseif msg == WM_XBUTTONDOWN then
        local xId = math.floor(wparam / 65536) % 65536
        local vk = xId == 1 and vkeys.VK_XBUTTON1 or (xId == 2 and vkeys.VK_XBUTTON2 or nil)
        if vk and customBindKeyNum(vk) == -1 then
            customBindKeys[#customBindKeys + 1] = vk
            customBindSave = {customBindEdit, customBindKeys}
            customBindEdit = nil
            customBindKeys = {}
            consumeWindowMessage(true, true)
        end
    end
end)
function saveBinderDatabase()
    local f = io.open(binderDbPath, "w")
    if f then
        f:write(encodeJson(bindDatabase))
        f:close()
    end
end
-- ====== Функция биндера ======
function binderStart()
    for key, val in pairs(bindDatabase.binds) do
        if val.v and #val.v > 0 then
            if isKeysDown(val.v) then
                for _, valText in ipairs(val.text) do
                    if tostring(valText):len() > 0 then
                        if valText:find("%{WAIT%-.*%}") or valText:find("%{wait%-.*%}") then
                            local timer = valText:match("%{WAIT%-(.*)%}") or valText:match("%{wait%-(.*)%}")
                            wait(timer * 1000)
                        else
                            local input = valText:match("(.)%{INPUT%}$") or valText:match("(.)%{input%}$")
                            if input then
                                sampSetChatInputText(replaceText(valText))
                                sampSetChatInputEnabled(true)
                            else
                                local scriptCmd = valText:match("(.)%{CMD%}$") or valText:match("(.)%{cmd%}$")
                                if scriptCmd then
                                    sampProcessChatInput(replaceText(valText))
                                else
                                    sampSendChat(replaceText(valText))
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end
function replaceText(text)
    if text ~= nil then
        text = text:gsub("%{INPUT%}$", "")
        text = text:gsub("%{input%}$", "")
        text = text:gsub("%{CMD%}$", "")
        text = text:gsub("%{cmd%}$", "")
        local result, id = sampGetPlayerIdByCharHandle(PLAYER_PED)
        if result then
            text = text:gsub("%{MY_NAME%}", sampGetPlayerNickname(id))
            text = text:gsub("%{my_name%}", sampGetPlayerNickname(id))
            text = text:gsub("%{MY_ID%}", tostring(id))
            text = text:gsub("%{my_id%}", tostring(id))
        end
    end
    return text
end
function isKeysDown(keylist)
    local tKeys = keylist
    local bool = false
    local key = #tKeys < 2 and tonumber(tKeys[1]) or tonumber(tKeys[#tKeys])
    if #tKeys < 2 then
        if not isKeyDown(VK_RMENU) and not isKeyDown(VK_LMENU) and not isKeyDown(VK_LSHIFT) and not isKeyDown(VK_RSHIFT) and not isKeyDown(VK_LCONTROL) and not isKeyDown(VK_RCONTROL) then
            if wasKeyPressed(key) then
                bool = true
            end
        end
    else
        if isKeyDown(tKeys[1])  then
            if isKeyDown(tKeys[2]) then
                if tKeys[3] ~= nil then
                    if isKeyDown(tKeys[3]) then
                        if tKeys[4] ~= nil then
                            if isKeyDown(tKeys[4]) then
                                if tKeys[5] ~= nil then
                                    if isKeyDown(tKeys[5]) then
                                        if wasKeyPressed(key) then
                                            bool = true
                                        end
                                    end
                                else
                                    if wasKeyPressed(key) then
                                        bool = true
                                    end
                                end
                            end
                        else
                            if wasKeyPressed(key) then
                                bool = true
                            end
                        end
                    end
                else
                    if wasKeyPressed(key) then
                        bool = true
                    end
                end
            end
        end
    end
    return bool
end
-- ====== КОНФИГУРАЦИЯ РЕСУРСОВ ======
local configDir = getWorkingDirectory() .. "\\config\\"
local configPath = configDir .. "united_resources.ini"
local mineGoalsProgressPath = configDir .. "mine_goals_progress.json"
local soundsDir = getWorkingDirectory() .. "\\resource\\farm\\"
local farmPricesPath = configDir .. "farm_price.ini"
local minePricesPath = configDir .. "mine_price.ini"                              
local sawmillPricesPath = configDir .. "sawmill_price.ini"
local sawmillGoalsProgressPath = configDir .. "sawmill_goals_progress.json"
local sawmillGoalsConfigPath = configDir .. "sawmill_goals.json" 
local totalIncomeGoalPath = configDir .. "total_income_goal.json"  
local tgReportStatePath = configDir .. "tg_report_state.json"
lbStatePath = configDir .. "lb_state.json"
sessionStatePath = configDir .. "session_state.json"
pricesStatePath = configDir .. "prices_state.json"
leaderboardConfigPath = configDir .. "leaderboard_config.json"
LEADERBOARD_URL = "https://script.google.com/macros/s/AKfycbymtP5e8lhxgIGviOX0W2nZ3fSmFYWCceD4m5k1wqQkvrE8srrO3eQx9jL53EeO3ORO/exec"
leaderboardCache = {
    Income = {Daily = {}, Weekly = {}, Total = {}},
    Farm = {Daily = {}, Weekly = {}, Total = {}},
    Mine = {Daily = {}, Weekly = {}, Total = {}},
    Sawmill = {Daily = {}, Weekly = {}, Total = {}},
    Oil = {Daily = {}, Weekly = {}, Total = {}},
    Taxi = {Daily = {}, Weekly = {}, Total = {}},
    Incass = {Daily = {}, Weekly = {}, Total = {}},
    IM = {Daily = {}, Weekly = {}, Total = {}}
}
myOverallRank = nil
myOverallAmount = nil
myOverallRankRequested = false
pricesLoading = false
local farmGoalsConfigPath = configDir .. "farm_goals.json"
local mineGoalsConfigPath = configDir .. "mine_goals.json"
local themeConfigPath = configDir .. "theme_config.json"
local achievementsPath = configDir .. "achievements.json"
local itemMarketStatsPath = configDir .. "itemmarket_stats.json"
shardStatsPath = configDir .. "shard_stats.json"
paydayLog = {}
paydayStatsPath = configDir .. "payday_stats.json"
paydayUiConfigPath = configDir .. "payday_ui_config.json"
oilStatsPath = configDir .. "oil_stats.json"
local taxiStatsPath = configDir .. "taxi_stats.json"
incassStatsPath = configDir .. "incass_stats.json"
stockStatsPath = configDir .. "stock_stats.json"
oilConfigPath = configDir .. "oil_config.json"
caseConfigPath = configDir .. "case_config.json"
investmentConfigPath = configDir .. "investment_config.json"
investmentStatsPath = configDir .. "investment_stats.json"
cryptoConfigPath = configDir .. "crypto_config.json"
cryptoStatsPath = configDir .. "crypto_stats.json"
if not doesDirectoryExist(configDir) then createDirectory(configDir) end
if not doesDirectoryExist(soundsDir) then createDirectory(soundsDir) end
local WORK_TYPES = { FARM = 1, MINE = 2, SAWMILL = 3 }
overlaySessionResources = {
    [WORK_TYPES.FARM] = {},
    [WORK_TYPES.MINE] = {},
    [WORK_TYPES.SAWMILL] = {},
}
overlaySessionActive = {
    [WORK_TYPES.FARM] = false,
    [WORK_TYPES.MINE] = false,
    [WORK_TYPES.SAWMILL] = false,
}
local pendingScan = nil
local scannedThisSession = {
    [WORK_TYPES.FARM] = false,
    [WORK_TYPES.MINE] = false,
    [WORK_TYPES.SAWMILL] = false,
}
local FARM_ITEM_TO_RES = {
    [809] = "dye",
    [1692] = "rare_tkan",
    [3561] = "coal",
    [7795] = "water"
}
local FARM_RES_TO_ITEM = {}
for itemId, resKey in pairs(FARM_ITEM_TO_RES) do
    FARM_RES_TO_ITEM[resKey] = itemId
end
local MINE_ITEM_TO_RES = {
    [596] = "stone", [597] = "metal", [598] = "bronze", [599] = "silver", [600] = "gold",
    [7425] = "diamond", [7424] = "tkan", [7423] = "splav", [7281] = "materia", [7426] = "azbox"
}
local MINE_RES_TO_ITEM = {}
for itemId, resKey in pairs(MINE_ITEM_TO_RES) do
    MINE_RES_TO_ITEM[resKey] = itemId
end
local SAWMILL_ITEM_TO_RES = {
    [566] = "firewood",
    [4032] = "quality_wood"
}
local SAWMILL_RES_TO_ITEM = {}
for itemId, resKey in pairs(SAWMILL_ITEM_TO_RES) do
    SAWMILL_RES_TO_ITEM[resKey] = itemId
end
-- Предметы пейдея 
local PAYDAY_ITEMS = {
    [731] = "talon_az" 
}
-- ====== ТЕМЫ ОФОРМЛЕНИЯ ======
local THEMES = {
    DEFAULT = 0,
    RED = 1,
    BLUE = 2,
    PURPLE = 3,
    ORANGE = 4,
    CYAN = 5,
    VICE = 6,
}
local THEME_CONFIGS = {
    [THEMES.DEFAULT] = {
        name = "Стандартная",
        accent = 0xFF91E51A,
        accentHover = 0xFF66CC22,
        leftPanelBg = 0xFF0E0E0E,
        rightPanelBg = 0xFF141414,
        rightPanelHeader = 0xFF141414,
        buttonNormal = 0x00000000,
        buttonActive = 0xFF1E3D1E,
        buttonHover = 0xFF2A2A2A,
        borderColor = 0xFF333333,
        borderActive = 0xFF91E51A,
        borderHover = 0xFF555555,
        textNormal = 0xFF999999,
        textActive = 0xFF91E51A,
        textHover = 0xFFFFFFFF,
        headerTitle = 0xFF91E51A,
        titleBg = 0xFF0E0E0E,
        rightTitleBg = 0xFF141414,
        windowBg = 0xFF141414,
        childBg = 0xFF141414,
    },
    [THEMES.RED] = {
        name = "Красная",
        accent = 0xFFE53935,
        accentHover = 0xFF5053EF,
        leftPanelBg = 0xFF08081A,
        rightPanelBg = 0xFF12122D,
        rightPanelHeader = 0xFF12122D,
        buttonNormal = 0x00000000,
        buttonActive = 0xFF1A1A3D,
        buttonHover = 0xFF20203A,
        borderColor = 0xFF2A2A4A,
        borderActive = 0xFF3539E5,
        borderHover = 0xFF3A3A6A,
        textNormal = 0xFF9999CC,
        textActive = 0xFF3539E5,
        textHover = 0xFFFFFFFF,
        headerTitle = 0xFFE53935,
        titleBg = 0xFF08081A,
        rightTitleBg = 0xFF12122D,
        windowBg = 0xFF12122D,
        childBg = 0xFF12122D,
    },
    [THEMES.BLUE] = {
        name = "Синяя",
        accent = 0xFF3539E5,
        accentHover = 0xFFF5A542,
        leftPanelBg = 0xFF1A0A08,
        rightPanelBg = 0xFF251212,
        rightPanelHeader = 0xFF251212,
        buttonNormal = 0x00000000,
        buttonActive = 0xFF3D1A1A,
        buttonHover = 0xFF3A2020,
        borderColor = 0xFF4A2A2A,
        borderActive = 0xFFF39621,
        borderHover = 0xFF6A3A3A,
        textNormal = 0xFFCC9999,
        textActive = 0xFFF39621,
        textHover = 0xFFFFFFFF,
        headerTitle = 0xFF3539E5,
        titleBg = 0xFF1A0A08,
        rightTitleBg = 0xFF251212,
        windowBg = 0xFF251212,
        childBg = 0xFF251212,
    },
    [THEMES.PURPLE] = {
        name = "Фиолетовая",
        accent = 0xFFB0279C,
        accentHover = 0xFFBC47AB,
        leftPanelBg = 0xFF1A0A12,
        rightPanelBg = 0xFF25121F,
        rightPanelHeader = 0xFF25121F,
        buttonNormal = 0x00000000,
        buttonActive = 0xFF3D1E2E,
        buttonHover = 0xFF3A2A2D,
        borderColor = 0xFF4A333D,
        borderActive = 0xFFB0279C,
        borderHover = 0xFF6A4455,
        textNormal = 0xFFCC99BB,
        textActive = 0xFFB0279C,
        textHover = 0xFFFFFFFF,
        headerTitle = 0xFFB0279C,
        titleBg = 0xFF1A0A12,
        rightTitleBg = 0xFF25121F,
        windowBg = 0xFF25121F,
        childBg = 0xFF25121F,
    },
    [THEMES.ORANGE] = {
        name = "Оранжевая",
        accent = 0xFFF39621,
        accentHover = 0xFF26A7FF,
        leftPanelBg = 0xFF0A0E1A,
        rightPanelBg = 0xFF151825,
        rightPanelHeader = 0xFF151825,
        buttonNormal = 0x00000000,
        buttonActive = 0xFF1E2A3D,
        buttonHover = 0xFF202A3A,
        borderColor = 0xFF2A354A,
        borderActive = 0xFF0098FF,
        borderHover = 0xFF3A4A6A,
        textNormal = 0xFF9999BB,
        textActive = 0xFF0098FF,
        textHover = 0xFFFFFFFF,
        headerTitle = 0xFFF39621,
        titleBg = 0xFF0A0E1A,
        rightTitleBg = 0xFF151825,
        windowBg = 0xFF151825,
        childBg = 0xFF151825,
    },
    [THEMES.CYAN] = {
        name = "Бирюзовая",
        accent = 0xFF00BCD4,
        accentHover = 0xFFDAC626,
        leftPanelBg = 0xFF1A1A08,
        rightPanelBg = 0xFF252512,
        rightPanelHeader = 0xFF252512,
        buttonNormal = 0x00000000,
        buttonActive = 0xFF3D3D1A,
        buttonHover = 0xFF3A3A20,
        borderColor = 0xFF4A4A2A,
        borderActive = 0xFFD4BC00,
        borderHover = 0xFF6A6A3A,
        textNormal = 0xFFCCCC99,
        textActive = 0xFFD4BC00,
        textHover = 0xFFFFFFFF,
        headerTitle = 0xFF00BCD4,
        titleBg = 0xFF1A1A08,
        rightTitleBg = 0xFF252512,
        windowBg = 0xFF252512,
        childBg = 0xFF252512,
    },
}
THEME_CONFIGS[THEMES.VICE] = {
    name = "Vice City",
    accent = 0xFFC78FFF,
    accentHover = 0xFFEBED6F,
    leftPanelBg = 0xFF91603C,
    rightPanelBg = 0xFFA8744A,
    rightPanelHeader = 0xFFA8744A,
    buttonNormal = 0x00000000,
    buttonActive = 0xFFA86FA6,
    buttonHover = 0xFFBD885C,
    borderColor = 0xFFEEC39C,
    borderActive = 0xFFC78FFF,
    borderHover = 0xFFEBED6F,
    textNormal = 0xFFFFF4E8,
    textActive = 0xFFDAB3FF,
    textHover = 0xFFFFFFFF,
    headerTitle = 0xFFC78FFF,
    titleBg = 0xFF865835,
    rightTitleBg = 0xFF9E6A3F,
    windowBg = 0xFFA8744A,
    childBg = 0xFFA8744A,
}
for _, t in pairs(THEME_CONFIGS) do
    t.accent = t.borderActive
    t.headerTitle = t.borderActive
end
local THEME_ORDER = {
    THEMES.DEFAULT,
    THEMES.RED,
    THEMES.BLUE,
    THEMES.PURPLE,
    THEMES.ORANGE,
    THEMES.CYAN,
}
-- ====== НАСТРОЙКА ТЕМЫ ======
local currentTheme = THEMES.DEFAULT 
local selectedThemeIdx = imgui.ImInt(0)  
local themeComboItems = ""  
local useCustomTheme = false
local cb_useCustomTheme = imgui.ImBool(false)
local CUSTOM_THEME = {
    accent = imgui.ImVec4(0.26, 0.98, 0.26, 1.0),
    leftPanelBg = imgui.ImVec4(0.055, 0.055, 0.055, 1.0),
    rightPanelBg = imgui.ImVec4(0.078, 0.078, 0.078, 1.0),
    buttonActive = imgui.ImVec4(0.118, 0.239, 0.118, 1.0),
    buttonHover = imgui.ImVec4(0.165, 0.165, 0.165, 1.0),
    borderActive = imgui.ImVec4(0.26, 0.98, 0.26, 1.0),
    textNormal = imgui.ImVec4(0.6, 0.6, 0.6, 1.0),
    textActive = imgui.ImVec4(0.26, 0.98, 0.26, 1.0),
    textHover = imgui.ImVec4(1.0, 1.0, 1.0, 1.0),
    headerTitle = imgui.ImVec4(0.26, 0.98, 0.26, 1.0),
    titleBg = imgui.ImVec4(0.055, 0.055, 0.055, 1.0),
    rightTitleBg = imgui.ImVec4(0.078, 0.078, 0.078, 1.0),
    windowBg = imgui.ImVec4(0.078, 0.078, 0.078, 1.0),
    childBg = imgui.ImVec4(0.078, 0.078, 0.078, 1.0),
    borderColor = imgui.ImVec4(0.165, 0.165, 0.165, 1.0),
 -- Текст в правой панели
    contentText = imgui.ImVec4(0.9, 0.9, 0.9, 1.0),
    contentTextHighlight = imgui.ImVec4(1.0, 0.8, 0.2, 1.0),
    contentTextGreen = imgui.ImVec4(0.26, 0.98, 0.26, 1.0),
	    -- Карточки в правой панели
    cardBg = imgui.ImVec4(0.1, 0.1, 0.1, 1.0),
    cardBgHovered = imgui.ImVec4(0.133, 0.133, 0.133, 1.0),
    cardBorder = imgui.ImVec4(0.2, 0.2, 0.2, 1.0),
    cardText = imgui.ImVec4(1.0, 1.0, 1.0, 1.0),
    cardIcon = imgui.ImVec4(0.26, 0.98, 0.26, 1.0),
    cardTitle = imgui.ImVec4(0.26, 0.98, 0.26, 1.0),
	    -- Кнопки внутри карточек (биндер)
    cardBtnBg = imgui.ImVec4(0.15, 0.15, 0.15, 1.0),
    cardBtnBgHovered = imgui.ImVec4(0.22, 0.22, 0.22, 1.0),
    cardBtnText = imgui.ImVec4(1.0, 1.0, 1.0, 1.0),
	    -- Карточки статистики (сторонний доход)
    statCardBg = imgui.ImVec4(0.1, 0.1, 0.1, 1.0),
    statCardBorder = imgui.ImVec4(0.2, 0.2, 0.2, 1.0),
    statCardLabel = imgui.ImVec4(0.533, 0.533, 0.533, 1.0),
    statCardValue = imgui.ImVec4(0.26, 0.98, 0.26, 1.0),
    statCardValueToday = imgui.ImVec4(1.0, 0.8, 0.0, 1.0),
    statCardValueWeek = imgui.ImVec4(0.2, 0.8, 1.0, 1.0),
    statCardAZ = imgui.ImVec4(0.0, 0.8, 1.0, 1.0),
	tableHeaderBg = imgui.ImVec4(0.133, 0.133, 0.133, 1.0),
    tableHeaderText = imgui.ImVec4(0.533, 0.533, 0.533, 1.0),
    
    -- Кнопки ImGui (обычные кнопки в правой панели)
    imguiButton = imgui.ImVec4(0.2, 0.2, 0.2, 0.6),
    imguiButtonHovered = imgui.ImVec4(0.26, 0.98, 0.26, 0.4),
    imguiButtonActive = imgui.ImVec4(0.26, 0.98, 0.26, 0.6),
    
    -- CollapsingHeader
    collapsingHeader = imgui.ImVec4(0.22, 0.22, 0.22, 0.5),
    collapsingHeaderHovered = imgui.ImVec4(0.26, 0.98, 0.26, 0.4),
    collapsingHeaderActive = imgui.ImVec4(0.26, 0.98, 0.26, 0.6),
    
    -- Separator
    separatorColor = imgui.ImVec4(0.2, 0.2, 0.2, 1.0),
    
    -- Прогресс-бар
    progressBar = imgui.ImVec4(0.26, 0.98, 0.26, 0.6),
    
    -- Чекбокс (галочка)
    checkMark = imgui.ImVec4(0.26, 0.98, 0.26, 1.0),
    
    -- Слайдер
    sliderGrab = imgui.ImVec4(0.26, 0.98, 0.26, 1.0),
    sliderGrabActive = imgui.ImVec4(0.26, 0.98, 0.26, 1.0),
    
    -- Фреймы (поля ввода)
    frameBg = imgui.ImVec4(0.2, 0.2, 0.2, 0.54),
    frameBgHovered = imgui.ImVec4(0.3, 0.3, 0.3, 0.4),
    frameBgActive = imgui.ImVec4(0.26, 0.98, 0.26, 0.3),
    
    -- Заголовки окон
    titleBgActive = imgui.ImVec4(0.1, 0.1, 0.1, 1.0),
    titleBgCollapsed = imgui.ImVec4(0.0, 0.0, 0.0, 0.51),
}
local customThemePath = configDir .. "custom_theme.json"
local configs = {
    [WORK_TYPES.FARM] = {
        name = "Ферма", prefix = "[ResHelherFarm]",
        resourceOrder = {"flax", "cotton", "rare_tkan", "water", "dye", "coal"},
        resourceNames = { flax = "Лён", cotton = "Хлопок", rare_tkan = "Кусок редкой ткани", water = "Вода для личных грядок", dye = "Краситель", coal = "Уголь" },
        defaultPrices = { flax = 15000, cotton = 20000, rare_tkan = 100000, water = 30000, dye = 50000, coal = 10000 },
        defaultGoals = { flax = 100, cotton = 100, rare_tkan = 50, water = 50, dye = 50, coal = 50 },
        rareResources = {"rare_tkan", "coal"},
        statsPath = configDir .. "farm_stats.json",
        scanNames = {
            ["Лён"] = "flax",
            ["Хлопок"] = "cotton",
            ["Кусок редкой ткани"] = "rare_tkan", ["Краситель"] = "dye",
            ["Уголь"] = "coal", ["Вода для личных грядок"] = "water"
        }
    },
    [WORK_TYPES.MINE] = {
        name = "Шахта", prefix = "[ResHelherMine]",
        resourceOrder = {"stone", "metal", "bronze", "silver", "gold", "diamond", "tkan", "splav", "materia", "azbox"},
        leftColumnOrder = {"stone", "tkan", "metal", "splav", "gold"},
        rightColumnOrder = {"diamond", "bronze", "materia", "silver", "azbox"},
        resourceNames = { stone = "Камень", metal = "Металл", bronze = "Бронза", silver = "Серебро", gold = "Золото", diamond = "Алмазный камень", tkan = "Прочная ткань", splav = "Шахтерский сплав", materia = "Темная материя", azbox = "Ларец с AZ-Монетами" },
        defaultPrices = { stone = 100000, metal = 320000, bronze = 11000, silver = 11000, gold = 45000, diamond = 1000000, tkan = 19000000, splav = 11000000, materia = 8000000, azbox = 1000000 },
        defaultGoals = { stone = 100, metal = 50, bronze = 50, silver = 30, gold = 20, diamond = 10, tkan = 5, splav = 5, materia = 3, azbox = 3 },
        rareResources = {"diamond", "tkan", "splav", "materia"},
        statsPath = configDir .. "mining_stats.json",
        scanNames = {
            ["Прочная ткань"] = "tkan", ["Шахтерский сплав"] = "splav", ["Алмазный камень"] = "diamond",
            ["Темная материя"] = "materia", ["Ларец с AZ-Монетами"] = "azbox",
            ["Камень"] = "stone", ["Металл"] = "metal", ["Золото"] = "gold",
            ["Бронза"] = "bronze", ["Серебро"] = "silver"
        }
    },
    [WORK_TYPES.SAWMILL] = {
        name = "Лесопилка", prefix = "[ResHelperSaw]",
        resourceOrder = {"firewood", "quality_wood"},
        resourceNames = { firewood = "Дрова", quality_wood = "Древесина высшего качества" },
        defaultPrices = { firewood = 150, quality_wood = 200000 },
        defaultGoals = { firewood = 200, quality_wood = 20 },
        rareResources = {"quality_wood"},
        statsPath = configDir .. "sawmill_stats.json",
        scanNames = {
            ["Дрова"] = "firewood",
            ["Древесина высшего качества"] = "quality_wood"
        }
    }
}	
-- Единый список серверов: IP и домены.
RH_SERVER_MAP = {
    -- IP-адреса
    ["80.66.82.132"] = "Holiday", ["185.169.134.166"] = "Prescott", ["80.66.82.82"] = "Faraway",
    ["80.66.82.54"] = "Christmas", ["80.66.82.200"] = "Queen-Creek", ["80.66.82.191"] = "Gilbert",
    ["80.66.82.168"] = "Page", ["80.66.82.113"] = "Yava", ["185.169.134.109"] = "Surprise",
    ["80.66.82.128"] = "Wednesday", ["185.169.134.44"] = "Chandler", ["185.169.134.171"] = "Glendale",
    ["80.66.82.190"] = "Show Low", ["80.66.82.144"] = "Sedona", ["185.169.134.174"] = "Payson",
    ["185.169.134.5"] = "Saint-Rose", ["80.66.82.159"] = "Sun-City", ["185.169.134.172"] = "Kingman",
    ["185.169.134.173"] = "Winslow", ["185.169.134.43"] = "Scottdale", ["185.169.134.61"] = "Red-Rock",
    ["185.169.134.45"] = "Brainburg", ["80.66.82.39"] = "Mirage", ["185.169.134.3"] = "Phoenix",
    ["185.169.134.59"] = "Mesa", ["185.169.134.4"] = "Tucson", ["185.169.134.107"] = "Yuma",
    ["80.66.82.188"] = "Casa-Grande", ["80.66.82.87"] = "Bumble Bee", ["80.66.82.33"] = "Love",
    ["80.66.82.22"] = "Drake", ["80.66.82.199"] = "Space", ["80.66.82.147"] = "Vice City",
    -- домены
    ["gilbert.arizona-rp.com"] = "Gilbert", ["christmas.arizona-rp.com"] = "Christmas", ["faraway.arizona-rp.com"] = "Faraway",
    ["queencreek.arizona-rp.com"] = "Queen-Creek", ["showlow.arizona-rp.com"] = "Show Low", ["prescott.arizona-rp.com"] = "Prescott",
    ["surprise.arizona-rp.com"] = "Surprise", ["holiday.arizona-rp.com"] = "Holiday", ["yava.arizona-rp.com"] = "Yava",
    ["kingman.arizona-rp.com"] = "Kingman", ["page.arizona-rp.com"] = "Page", ["glendale.arizona-rp.com"] = "Glendale",
    ["chandler.arizona-rp.com"] = "Chandler", ["saintrose.arizona-rp.com"] = "Saint-Rose", ["wednesday.arizona-rp.com"] = "Wednesday",
    ["scottdale.arizona-rp.com"] = "Scottdale", ["payson.arizona-rp.com"] = "Payson", ["winslow.arizona-rp.com"] = "Winslow",
    ["suncity.arizona-rp.com"] = "Sun-City", ["brainburg.arizona-rp.com"] = "Brainburg", ["mirage.arizona-rp.com"] = "Mirage",
    ["sedona.arizona-rp.com"] = "Sedona", ["redrock.arizona-rp.com"] = "Red-Rock", ["phoenix.arizona-rp.com"] = "Phoenix",
    ["mesa.arizona-rp.com"] = "Mesa", ["bumblebee.arizona-rp.com"] = "Bumble Bee", ["yuma.arizona-rp.com"] = "Yuma",
    ["love.arizona-rp.com"] = "Love", ["drake.arizona-rp.com"] = "Drake", ["casagrande.arizona-rp.com"] = "Casa-Grande",
    ["tucson.arizona-rp.com"] = "Tucson", ["space.arizona-rp.com"] = "Space",
    ["home.arizona-rp.com"] = "Home",
}
RH_SERVER_NAMES = {}
for _, nm in pairs(RH_SERVER_MAP) do RH_SERVER_NAMES[nm] = true end

RH_SERVER_CANON = {}
for nm in pairs(RH_SERVER_NAMES) do
    RH_SERVER_CANON[(nm:lower():gsub("[%s%-]", ""))] = nm
end
function rhCanonServer(name)
    if type(name) ~= "string" then return name end
    return RH_SERVER_CANON[(name:lower():gsub("[%s%-]", ""))] or name
end
function rhFixLb(data)
    if type(data) == "table" then
        for _, e in ipairs(data) do
            if type(e) == "table" and type(e.server) == "string" then
                e.server = rhCanonServer(e.server)
            end
        end
    end
    return data
end

function getCurrentServer(hostOverride)
    if not hostOverride and RH_DATA_SERVER then return RH_DATA_SERVER end
    return getRealServer(hostOverride)
end
function getRealServer(hostOverride)
    local host = hostOverride
    if not host then
        host = sampGetCurrentServerAddress()
        if not host or host == "" then host = sampGetServerAddress() end
    end
    if host and host:find(":") then host = host:match("([^:]+)") end
    return RH_SERVER_MAP[host or ""] or host or "Unknown"
end
function getServerStatsPath(workType)
    local server = getCurrentServer()
    
    local baseName
    if workType == WORK_TYPES.FARM then
        baseName = "farm_stats"
    elseif workType == WORK_TYPES.MINE then
        baseName = "mining_stats"
    elseif workType == WORK_TYPES.SAWMILL then
        baseName = "sawmill_stats"
    else
        return nil
    end
    
    if server and server ~= "Unknown" then
        return configDir .. baseName .. "_" .. server .. ".json"
    else
        return configDir .. baseName .. ".json"
    end
end
function getServerStatsPathCustom(workType)
    local server = getCurrentServer()
    local baseName
    if workType == WORK_TYPES.FARM then baseName = "farm_stats"
    elseif workType == WORK_TYPES.MINE then baseName = "mining_stats"
    elseif workType == WORK_TYPES.SAWMILL then baseName = "sawmill_stats"
    else return nil end
    if server and server ~= "Unknown" then
        return configDir .. baseName .. "_" .. server .. "_custom.json"
    else
        return configDir .. baseName .. "_custom.json"
    end
end
function loadCustomPricesConfig()
    local file = io.open(customPricesConfigPath, "r")
    if not file then return end
    local data = decodeJson(file:read("*all"))
    file:close()
    if data then
        useCustomFarmPrices = data.useCustomFarmPrices or false
        useCustomMinePrices = data.useCustomMinePrices or false
        useCustomSawmillPrices = data.useCustomSawmillPrices or false
        useCustomCasePrices = data.useCustomCasePrices or false
        if data.customPricesFarm then
            for k, v in pairs(data.customPricesFarm) do
                customPriceEditFarm[k] = imgui.ImInt(v)
            end
        end
        if data.customPricesMine then
            for k, v in pairs(data.customPricesMine) do
                customPriceEditMine[k] = imgui.ImInt(v)
            end
        end
        if data.customPricesSaw then
            for k, v in pairs(data.customPricesSaw) do
                customPriceEditSaw[k] = imgui.ImInt(v)
            end
        end
    end
    cb_useCustomFarmPrices.v = useCustomFarmPrices
    cb_useCustomMinePrices.v = useCustomMinePrices
    cb_useCustomSawmillPrices.v = useCustomSawmillPrices
    cb_useCustomCasePrices.v = useCustomCasePrices
end
function saveCustomPricesConfig()
    local data = {
        useCustomFarmPrices = useCustomFarmPrices,
        useCustomMinePrices = useCustomMinePrices,
        useCustomSawmillPrices = useCustomSawmillPrices,
        useCustomCasePrices = useCustomCasePrices,
        customPricesFarm = {},
        customPricesMine = {},
        customPricesSaw = {},
    }
    for k, v in pairs(customPriceEditFarm) do
        data.customPricesFarm[k] = v.v
    end
    for k, v in pairs(customPriceEditMine) do
        data.customPricesMine[k] = v.v
    end
    for k, v in pairs(customPriceEditSaw) do
        data.customPricesSaw[k] = v.v
    end
    local file = io.open(customPricesConfigPath, "w")
    if file then file:write(encodeJson(data)); file:close() end
end
function getCurrentCustomPriceEdit()
    if currentWork == WORK_TYPES.FARM then return customPriceEditFarm
    elseif currentWork == WORK_TYPES.MINE then return customPriceEditMine
    elseif currentWork == WORK_TYPES.SAWMILL then return customPriceEditSaw
    end
    return {}
end
function isMouseOverOverlay(cfg)
    local mx, my = getCursorPos()
    if not mx then return false end
    return (mx >= cfg.x and mx <= cfg.x + cfg.w and my >= cfg.y and my <= cfg.y + cfg.h)
end
-- Миграция данных между custom и обычным файлом
function getServerBasePath(workType)
    local server = getCurrentServer()
    
    local baseName
    if workType == WORK_TYPES.FARM then
        baseName = "farm_base"
    elseif workType == WORK_TYPES.MINE then
        baseName = "mine_base"
    elseif workType == WORK_TYPES.SAWMILL then
        baseName = "sawmill_base"
    else
        return nil
    end
    
    if server and server ~= "Unknown" then
        return configDir .. baseName .. "_" .. server .. ".json"
    else
        return configDir .. baseName .. ".json"
    end
end
function getServerGoalsProgressPath(workType)
    local server = getCurrentServer()
    
    local baseName
    if workType == WORK_TYPES.FARM then
        baseName = "farm_goals_progress"
    elseif workType == WORK_TYPES.MINE then
        baseName = "mine_goals_progress"
    elseif workType == WORK_TYPES.SAWMILL then
        baseName = "sawmill_goals_progress"
    else
        return nil
    end
    
    if server and server ~= "Unknown" then
        return configDir .. baseName .. "_" .. server .. ".json"
    else
        return configDir .. baseName .. ".json"
    end
end
local currentWork = nil
local config = nil
local resources = {}
local resourcePrices = {}
local goals = {}
local goalsReached = {}
local sessionResources = {}
local dailyResources = {}
local dailyTotal = 0
local totalDailyIncome = 0
local totalIncomeGoalReached = false
local totalIncomeCacheTime = 0
local sessionTotal = 0
local sessionStartTime = os.time()  
local gameSessionStartTime = os.time()
local sessionAccumulatedSec = 0
aboutChangelogExpanded = false
settingsExpandedCustomTheme = false
settingsExpandedTelegram = false
local resourceLog = {}
local loadedLogs = false
local settings = {
    chatNotifyEnabled = false, goalSoundEnabled = true, pickupSoundEnabled = true, devNotifPopupEnabled = true,
    goalSoundVolume = 80, pickupSoundVolume = 80, rareSoundVolume = 80, coalSoundVolume = 80,
	pickupSoundFile = "pickup.wav",
    rareSoundFile = "rare.wav",
    coalSoundFile = "ugol.wav",
    achivSoundFile = "achiv.wav",
    farmOverlayEnabled = false, mineOverlayEnabled = false, sawmillOverlayEnabled = false, oilOverlayEnabled = false, taxiOverlayEnabled = false, incassOverlayEnabled = false,
    taxiEnabled = false,
    incassEnabled = false,
    oilEnabled = true,
    undermineEnabled = false, underminelavkaEnabled = false, regularmineEnabled = false, farmEnabled = false, sawmillEnabled = false,
    overlayTimerEnabled = false, mineSpawnTimerEnabled = false, overlayStyle = 1, overlayColumns = 2, totalIncomeGoal = 1000000, talonAutoScanEnabled = true,
    cryptoAutoScanEnabled = true, notifyOnlyImportant = false, notifyHideStartup = false,
    cryptoPricesLastFetch = 0,
    overlayHideOnHover = false, overlayAutoTimer = false,
    smoothMenuEnabled = true, smoothWindowEnabled = true,
    menuKey = {17, 75},
    hiddenHomeTiles = {},
    homeShowLogo = false, homeShowSummary = true, homeShowTiles = true,
    homeShowGoals = true, homeShowWork = true, homeShowHotkey = true
}
local originalSampAddChatMessage = sampAddChatMessage
local NOTIF_ALWAYS_ALLOWED = {
    "ResHelper загружен",
    "актуальная версия",
    "Доступна версия",
    "Откройте /rh",
    "Цены обновлены из Google таблицы",
}
local NOTIF_HIDE_ON_STARTUP_TOGGLE = {
    "База предметов обновлена",
    "Крипта в инвентаре",
    "Авто-сканирование завершено",
}
function sampAddChatMessage(text, color)
    if settings.notifyOnlyImportant and text then
        local allowed = false
        for _, marker in ipairs(NOTIF_ALWAYS_ALLOWED) do
            if text:find(marker, 1, true) then
                allowed = true
                break
            end
        end
        if not allowed then return end
    elseif settings.notifyHideStartup and text then
        for _, marker in ipairs(NOTIF_HIDE_ON_STARTUP_TOGGLE) do
            if text:find(marker, 1, true) then
                return
            end
        end
    end
    return originalSampAddChatMessage(text, color)
end
local inventoryCache = {}
local scanState = {
    active = false,
    scanning = false,
    foundResources = {},
    statusText = "",
    waitForInventory = false,
    scanned = false,
    isTalonScan = false
}
local inventoryBase = {}
local scanSummary = { itemsDBCount = 0, btc = 0, asc = 0, azTalon = 0, baseWorkType = nil, baseItems = {}, baseTime = 0 }
local pendingResources = {}
local pendingResourcesBuffer = {}  
local changelogShown = false
changelogPath = configDir .. "changelog_shown.txt"
local changelogData = nil
local mineItemAmounts = { stone = 6, metal = 3, bronze = 3, silver = 2, gold = 2, diamond = 1, tkan = 1, splav = 1, materia = 1, azbox = 1 }
local needSave = false
local needSaveColor = imgui.ImColor(250, 66, 66, 102):GetVec4()
local overlayConfigs = {
    [WORK_TYPES.FARM] = { x = 15, y = 300, w = 220, h = 160 },
    [WORK_TYPES.MINE] = { x = 15, y = 300, w = 280, h = 200 },
    [WORK_TYPES.SAWMILL] = { x = 15, y = 300, w = 220, h = 120 }
}
oilOverlayConfig = { x = 15, y = 300, w = 200, h = 170 }
taxiOverlayConfig = { x = 15, y = 300, w = 200, h = 140 }
incassOverlayConfig = { x = 15, y = 300, w = 235, h = 200 }
-- Таймер для оверлея
local overlayTimer = {
    enabled = false,
    running = false,
    startTime = 0,
    elapsed = 0,
    displayedTime = "00:00:00",
}
cb_overlay_timer = imgui.ImBool(false)  
cb_mineSpawnTimer = imgui.ImBool(false)
cb_overlayStyle = imgui.ImInt(0)
local totalGoalEdit = imgui.ImInt(0)
local editingMenuKey = false
local menuKeyBuffer = {}
-- Настройки для GUI
cb_farm = imgui.ImBool(false)
cb_undermine = imgui.ImBool(false)
cb_lavka = imgui.ImBool(false)
cb_regular = imgui.ImBool(false)
cb_chatNotify = imgui.ImBool(false)
cb_devNotifPopup = imgui.ImBool(true)
cb_goalSound = imgui.ImBool(false)
cb_pickupSound = imgui.ImBool(false)
cb_farm_overlay = imgui.ImBool(false)
cb_mine_overlay = imgui.ImBool(false)
cb_sawmill_overlay = imgui.ImBool(false)
cb_oil_overlay = imgui.ImBool(false)
cb_oil = imgui.ImBool(true)
cb_taxi = imgui.ImBool(false)
cb_taxi_overlay = imgui.ImBool(false)
cb_incass_overlay = imgui.ImBool(false)
cb_incass = imgui.ImBool(false)
cb_sawmill = imgui.ImBool(false)
goal_vol_slider = imgui.ImInt(80)
pickup_vol_slider = imgui.ImInt(80)
imStatCalendarFarmDate = nil
imStatCalendarFarmYear = nil
imStatCalendarFarmMonth = nil
imStatCalendarSawDate = nil
imStatCalendarSawYear = nil
imStatCalendarSawMonth = nil
achCategoryFilter = imgui.ImInt(0)
local shardNames = {
    ["Ведьмы"] = "oskolok_vedmy",
    ["Лича"] = "oskolok_licha",
    ["Медведя"] = "oskolok_medvedya",
    ["Сердючки"] = "oskolok_serduchki",
    ["Фрирен"] = "oskolok_friren",
    ["NFT контейнера"] = "oskolok_nft",
}
local SHARD_ITEM_TO_NAME = {
    [9516] = "Ведьмы",
    [9517] = "Лича",
    [9680] = "Медведя",
    [9681] = "Сердючки",
    [9762] = "Фрирен",
}
local NFT_SHARD_ITEM_ID = 8089
overlayColumnsNames = {u8("1 столбец"), u8("2 столбца")}
cb_overlayColumns = imgui.ImInt(1)
cb_talonAutoScan = imgui.ImBool(true)
cb_cryptoAutoScan = imgui.ImBool(true)
cb_notifyOnlyImportant = imgui.ImBool(false)
cb_notifyHideStartup = imgui.ImBool(false)
cb_overlayHideOnHover = imgui.ImBool(false)
cb_overlayAutoTimer = imgui.ImBool(false)
cb_smoothMenu = imgui.ImBool(true)
cb_smoothWindow = imgui.ImBool(true)
cb_homeShowLogo = imgui.ImBool(false)
cb_homeShowSummary = imgui.ImBool(true)
cb_homeShowTiles = imgui.ImBool(true)
cb_homeShowGoals = imgui.ImBool(true)
cb_homeShowWork = imgui.ImBool(true)
cb_homeShowHotkey = imgui.ImBool(true)
-- Кастомные цены
useCustomFarmPrices = false
useCustomMinePrices = false
useCustomSawmillPrices = false
useCustomCasePrices = false
cb_useCustomFarmPrices = imgui.ImBool(false)
cb_useCustomMinePrices = imgui.ImBool(false)
cb_useCustomSawmillPrices = imgui.ImBool(false)
cb_useCustomCasePrices = imgui.ImBool(false)
customPriceEditFarm = {}
customPriceEditMine = {}
customPriceEditSaw = {}
customPricesConfigPath = configDir .. "custom_prices_config.json"
local lbTab = imgui.ImInt(0)
lbModeTab = imgui.ImInt(0)
lbServerFilter = imgui.ImInt(0)
local priceEdit = {}
local goalEdit = {}
local farmGoalEditCache = {}
local mineGoalEditCache = {}
local sawmillGoalEditCache = {}
-- ====== СИСТЕМА ДОСТИЖЕНИЙ ======
local ACHIEVEMENTS = {}
-- Переменная для отслеживания выполненных целей (всех)
local totalCompletedGoals = 0
-- ====== ФУНКЦИИ ДЛЯ РАБОТЫ С РЕСУРСАМИ ======
local function formatNumber(num)
    if not num then return "0" end
    return tostring(math.floor(num)):reverse():gsub("(%d%d%d)", "%1."):reverse():gsub("^%.", "")
end
local function formatTime(seconds)
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local secs = math.floor(seconds % 60)
    return string.format("%02d:%02d:%02d", hours, minutes, secs)
end
local tgConfigPath = configDir .. "telegram_config.json"
local function saveTgConfig()
    local file = io.open(tgConfigPath, "w")
    if file then
        file:write(encodeJson(tgConfig))
        file:close()
    end
end
local function loadTgConfig()
    local file = io.open(tgConfigPath, "r")
    if not file then return end
    local content = file:read("*all")
    file:close()
    local data = decodeJson(content)
    if data then
        tgConfig.enabled = data.enabled or false
        tgConfig.botToken = data.botToken or ""
        tgConfig.chatId = data.chatId or ""
        tgConfig.itemMarketEnabled = data.itemMarketEnabled or true
        tgConfig.shardEnabled = data.shardEnabled
        if tgConfig.shardEnabled == nil then tgConfig.shardEnabled = true end
        tgConfig.dailyReportEnabled = data.dailyReportEnabled or false
        tgConfig.weeklyReportEnabled = data.weeklyReportEnabled or false
        tgConfig.paydayEnabled = data.paydayEnabled
        if tgConfig.paydayEnabled == nil then tgConfig.paydayEnabled = true end
        tgConfig.useReserveServer = data.useReserveServer
        if tgConfig.useReserveServer == nil then tgConfig.useReserveServer = true end
    end
    tgTokenInput.v = u8(tgConfig.botToken)
    tgChatIdInput.v = u8(tgConfig.chatId)
end
local autoAdConfigPath = configDir .. "auto_ad_config.json"
function saveAutoAdConfig()
    local _, playerId = sampGetPlayerIdByCharHandle(PLAYER_PED)
    local data = {
        saveDelay = autoAdConfig.saveDelay,
        serverHost = getCurrentServer() or "",
        serverNick = sampGetPlayerNickname(playerId) or "",
        ads = {}
    }
    for i, ad in ipairs(autoAdConfig.ads) do
        local multiLinesData = {}
        for j, line in ipairs(ad.multiLines or {}) do
            multiLinesData[j] = { text = u8:decode(line.textBuf.v), delay = line.delayBuf.v }
        end
        data.ads[i] = {
            text = u8:decode(ad.textBuf.v),
            interval = ad.intervalBuf.v,
            chatIdx = ad.chatIdx,
            active = ad.active,
            vrWithAd = ad.vrWithAd,
            adRadioIdx = ad.adRadioIdx,
            adVip = ad.adVip,
            adResendEnabled = ad.adResendEnabled,
            adResendSeconds = ad.adResendSecBuf and ad.adResendSecBuf.v,
            nextSend = autoAdConfig.saveDelay and ad.nextSend or nil,
            multiEnabled = ad.multiEnabled or false,
            multiIdx = ad.multiIdx or 1,
            multiLines = multiLinesData,
        }
    end
    local file = io.open(autoAdConfigPath, "w")
    if file then
        file:write(encodeJson(data))
        file:close()
    end
end
function loadAutoAdConfig()
    autoAdConfig.ads = {}
    local file = io.open(autoAdConfigPath, "r")
    if not file then return end
    local content = file:read("*all")
    file:close()
    local data = decodeJson(content)
    if not data then return end
    autoAdConfig.saveDelay = data.saveDelay or false
    autoAdConfig.savedHost = data.serverHost or ""
    autoAdConfig.savedNick = data.serverNick or ""
    for i, ad in ipairs(data.ads or {}) do
        local interval = ad.interval or 300
        local nextSend
        if autoAdConfig.saveDelay and ad.nextSend then
            nextSend = ad.nextSend
        else
            nextSend = os.time() + interval
        end
        local newAd = {
            chatIdx = ad.chatIdx or 0,
            active = ad.active or false,
            vrWithAd = ad.vrWithAd or false,
            adRadioIdx = ad.adRadioIdx or 0,
            adVip = ad.adVip or false,
            adResendEnabled = ad.adResendEnabled or false,
            nextSend = nextSend,
            lastSend = nextSend - interval,
            textBuf = imgui.ImBuffer(500),
            intervalBuf = imgui.ImInt(interval),
            adResendSecBuf = imgui.ImInt(ad.adResendSeconds or 35),
        }
        newAd.textBuf.v = u8(ad.text or "")
        newAd.multiEnabled = ad.multiEnabled or false
        newAd.multiIdx = ad.multiIdx or 1
        newAd.multiLines = {}
        for j, line in ipairs(ad.multiLines or {}) do
            local newLine = { textBuf = imgui.ImBuffer(500), delayBuf = imgui.ImInt(line.delay or 30) }
            newLine.textBuf.v = u8(line.text or "")
            newAd.multiLines[j] = newLine
        end
        autoAdConfig.ads[i] = newAd
    end
end
local chatFilterConfigPath = configDir .. "chat_filter_config.json"
function saveChatFilterConfig()
    local data = {enabled = chatFilterConfig.enabled, filters = {}}
    for i, entry in ipairs(chatFilterConfig.filters) do
        data.filters[i] = {
            text = entry.text or "",
            mode = entry.mode or "strict",
            enabled = entry.enabled ~= false,
        }
    end
    local file = io.open(chatFilterConfigPath, "w")
    if file then
        file:write(encodeJson(data))
        file:close()
    end
end
function loadChatFilterConfig()
    chatFilterConfig.filters = {}
    local file = io.open(chatFilterConfigPath, "r")
    if not file then return end
    local content = file:read("*all")
    file:close()
    local data = decodeJson(content)
    if not data then return end
    if data.enabled ~= nil then chatFilterConfig.enabled = data.enabled end
    for i, item in ipairs(data.filters or {}) do
        local textBuf = imgui.ImBuffer(300)
        textBuf.v = u8(item.text or "")
        local mode = item.mode
        if mode ~= "strict" and mode ~= "standard" and mode ~= "nick" then
            mode = (item.strict == false) and "standard" or "strict"
        end
        chatFilterConfig.filters[i] = {
            text = item.text or "",
            mode = mode,
            enabled = (item.enabled == nil) and true or item.enabled,
            textBuf = textBuf,
        }
    end
end
playingSounds = {}
local function playSoundFile(fn, vol)
    local sf = soundsDir .. fn
    if doesFileExist(sf) then 
        local a = loadAudioStream(sf)
        if a then 
            setAudioStreamVolume(a, vol / 100)
            setAudioStreamState(a, 1)
            table.insert(playingSounds, a)
            lua_thread.create(function()
                wait(5000)
                for i, s in ipairs(playingSounds) do
                    if s == a then table.remove(playingSounds, i); break end
                end
            end)
        end
    end
end
local function playGoalSound() 
    if settings.goalSoundEnabled and settings.goalSoundVolume > 0 then 
        playSoundFile(settings.achivSoundFile, settings.goalSoundVolume) 
    end 
end
local cachedWavFiles = nil
function getWavFiles()
    if cachedWavFiles then return cachedWavFiles end
    
    local files = {}
    local dir = soundsDir
    
    local defaults = {"pickup.wav", "rare.wav", "ugol.wav", "achiv.wav"}
    for _, f in ipairs(defaults) do
        if doesFileExist(dir .. f) then
            table.insert(files, f)
        end
    end
    
    local hasLfs, lfs = pcall(require, "lfs")
    if hasLfs and lfs then
        for file in lfs.dir(dir) do
            if file:match("%.wav$") then
                local alreadyExists = false
                for _, existing in ipairs(files) do
                    if existing == file then alreadyExists = true; break end
                end
                if not alreadyExists then
                    table.insert(files, file)
                end
            end
        end
    end
    
    table.sort(files)
    cachedWavFiles = files
    return files
end
local function playPickupSound(rn)
    if not settings.pickupSoundEnabled then return end
    if rn == "coal" or rn == "tkan" or rn == "splav" or rn == "materia" then
        if settings.coalSoundVolume > 0 then
            playSoundFile(settings.coalSoundFile, settings.coalSoundVolume)
        end
        return
    end
    if config.rareResources then 
        for _, r in ipairs(config.rareResources) do 
            if rn == r then 
                if settings.rareSoundVolume > 0 then
                    playSoundFile(settings.rareSoundFile, settings.rareSoundVolume)
                end
                return 
            end 
        end 
    end
    if settings.pickupSoundVolume > 0 then
        playSoundFile(settings.pickupSoundFile, settings.pickupSoundVolume)
    end
end
local function checkGoalReached(rn)
    local ca = dailyResources[rn] or 0
    local g = goals[rn] or 1
    if ca >= g and not goalsReached[rn] then 
        goalsReached[rn] = true
        totalCompletedGoals = totalCompletedGoals + 1
        saveAchievements()
        playGoalSound()
        checkAchievements()
        if settings.chatNotifyEnabled then 
            sampAddChatMessage("{00FF00}" .. config.prefix .. " {FFFFFF}Цель достигнута! " .. config.resourceNames[rn] .. ": " .. formatNumber(ca) .. " / " .. formatNumber(g), -1) 
        end
    end
end
function getMoscowTime(timestamp)
    local utcTime
    if timestamp then
        utcTime = timestamp
    else
        utcTime = os.time(os.date("!*t"))
    end
    return utcTime + 10800
end
local gameDateCache = {}
local function getGameDate(timestamp)
    local t = timestamp or os.time()
    local msk = t + 10800
    -- Игровой день начинается в 05:00 МСК
    local dayStart = 5 * 3600
    local secondsSinceMidnight = msk % 86400
    if secondsSinceMidnight < dayStart then
        msk = msk - 86400
    end
    -- Получаем Y-m-d через деление
    local days = math.floor(msk / 86400)
    local cachedDate = gameDateCache[days]
    if cachedDate then return cachedDate end
    -- Переводим дни в дату
    local y = 1970
    local remaining = days
    while true do
        local daysInYear = (y % 4 == 0 and (y % 100 ~= 0 or y % 400 == 0)) and 366 or 365
        if remaining < daysInYear then break end
        remaining = remaining - daysInYear
        y = y + 1
    end
    local monthDays = {31, (y % 4 == 0 and (y % 100 ~= 0 or y % 400 == 0)) and 29 or 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31}
    local m = 1
    while remaining >= monthDays[m] do
        remaining = remaining - monthDays[m]
        m = m + 1
    end
    local d = remaining + 1
    local resDate = string.format("%04d-%02d-%02d", y, m, d)
    gameDateCache[days] = resDate
    return resDate
end
local function getDayStats(dateStr)
    if not config then return {total = 0} end
    local result = {total = 0}
    for _, k in ipairs(config.resourceOrder) do result[k] = 0 end
    for _, log in ipairs(resourceLog) do
        if getGameDate(log.time) == dateStr then
            result[log.resource] = (result[log.resource] or 0) + log.amount
        end
    end
    result.total = 0
    for _, k in ipairs(config.resourceOrder) do
        local price = getPriceForResource(k, currentWork)
        result.total = result.total + (result[k] * price)
    end
    return result
end
local function getTodayStats()
    if cachedTodayStats and os.time() - cachedTodayTime < 1 then
        return cachedTodayStats
    end
    cachedTodayStats = getDayStats(getGameDate())
    cachedTodayTime = os.time()
    return cachedTodayStats
end
local function checkTotalIncomeGoal()
    if settings.totalIncomeGoal > 0 and totalDailyIncome >= settings.totalIncomeGoal and not totalIncomeGoalReached then
        totalIncomeGoalReached = true
        saveTotalIncomeGoal()
        if settings.goalSoundEnabled then playGoalSound() end
        if settings.chatNotifyEnabled then
            sampAddChatMessage(SCRIPT_PREFIX .. "Цель общего дохода достигнута! " .. formatNumber(totalDailyIncome) .. "$ / " .. formatNumber(settings.totalIncomeGoal) .. "$", SCRIPT_COLOR)
        end
    end
end
local function addToStats(resourceName, amount, skipSound)
    if not config then return end
    if not sessionResources[resourceName] then return end
    
    local price
    if (currentWork == WORK_TYPES.FARM and useCustomFarmPrices) or (currentWork == WORK_TYPES.MINE and useCustomMinePrices) or (currentWork == WORK_TYPES.SAWMILL and useCustomSawmillPrices) then
        local customEdit = getCurrentCustomPriceEdit()
        price = customEdit[resourceName] and customEdit[resourceName].v or resourcePrices[resourceName] or config.defaultPrices[resourceName] or 0
    else
        price = resourcePrices[resourceName] or config.defaultPrices[resourceName] or 0
    end
    
    local value = amount * price
    sessionResources[resourceName] = sessionResources[resourceName] + amount
    sessionTotal = sessionTotal + value
    dailyResources[resourceName] = (dailyResources[resourceName] or 0) + amount
	    if overlaySessionActive[currentWork] then
        overlaySessionResources[currentWork][resourceName] = (overlaySessionResources[currentWork][resourceName] or 0) + amount
    end
    dailyTotal = dailyTotal + value
    
    -- Оптимизированное логирование
    local now = os.time()
    
    -- Интервал агрегации: для обычных ресурсов дольше, для редких короче
    local isRare = false
    if config.rareResources then
        for _, r in ipairs(config.rareResources) do
            if r == resourceName then isRare = true; break end
        end
    end
    local aggregationInterval = isRare and 600 or 600 
    
    local lastLog = nil
    for i = #resourceLog, 1, -1 do
        if resourceLog[i].resource == resourceName then
            lastLog = resourceLog[i]
            break
        end
    end
    
    if lastLog and (now - lastLog.time) <= aggregationInterval then
        if overlayTimer.running and lastLog.time < overlayTimer.startTime then
            table.insert(resourceLog, {
                time = now, 
                resource = resourceName, 
                amount = amount, 
                value = value
            })
        else
            lastLog.amount = lastLog.amount + amount
            lastLog.value = lastLog.value + value
            lastLog.time = now
        end
    else
        table.insert(resourceLog, {
            time = now, 
            resource = resourceName, 
            amount = amount, 
            value = value
        })
    end
    
    saveStats()
    if not skipSound then
        playPickupSound(resourceName)
    end
    checkGoalReached(resourceName)
    saveGoalsProgress()
    totalDailyIncome = totalDailyIncome + value
    saveTotalIncomeGoal()
    checkTotalIncomeGoal()
end
local function addResource(resourceName, amount, skipSound)
    if not config then return false end
    if not resources[resourceName] then return false end
    resources[resourceName] = resources[resourceName] + amount
    addToStats(resourceName, amount, skipSound)
    return true
end
local function removeResource(resourceName, amount)
    if resources[resourceName] then 
        resources[resourceName] = math.max(0, resources[resourceName] - amount)
        local price = resourcePrices[resourceName] or config.defaultPrices[resourceName] or 0
        totalDailyIncome = math.max(0, totalDailyIncome - (amount * price))
        saveTotalIncomeGoal()
        return true 
    end
    return false
end
-- Сохранение/загрузка состояния отправки отчётов
local function saveTgReportState(dailyDate, weeklyKey)
    local data = {
        lastDailyDate = dailyDate or "",
        lastWeeklyKey = weeklyKey or ""
    }
    local file = io.open(tgReportStatePath, "w")
    if file then
        file:write(encodeJson(data))
        file:close()
    end
end
local function loadTgReportState()
    local file = io.open(tgReportStatePath, "r")
    if not file then return "", "" end
    local content = file:read("*all")
    file:close()
    local data = decodeJson(content)
    if data then
        return data.lastDailyDate or "", data.lastWeeklyKey or ""
    end
    return "", ""
end
function saveLbState(dailyDate, weeklyKey)
    local data = {
        lastDailyDate = dailyDate or "",
        lastWeeklyKey = weeklyKey or ""
    }
    local file = io.open(lbStatePath, "w")
    if file then file:write(encodeJson(data)); file:close() end
end
function loadLbState()
    local file = io.open(lbStatePath, "r")
    if not file then return "", "" end
    local data = decodeJson(file:read("*all"))
    file:close()
    if data then return data.lastDailyDate or "", data.lastWeeklyKey or "" end
    return "", ""
end
function saveSessionState()
    local accumulated = (sessionAccumulatedSec or 0) + (os.time() - (gameSessionStartTime or os.time()))
    local data = { date = getGameDate(), accumulated = accumulated }
    local file = io.open(sessionStatePath, "w")
    if file then file:write(encodeJson(data)); file:close() end
end
function loadSessionState()
    local file = io.open(sessionStatePath, "r")
    if not file then return nil, nil end
    local data = decodeJson(file:read("*all"))
    file:close()
    if data then return data.date, data.accumulated end
    return nil, nil
end
-- Сбор статистики для любого типа работ за период
local function getStatsForWorkType(workType, period)
    local cfg = configs[workType]
    local prices = {}
    local pricesPath = workType == WORK_TYPES.FARM and farmPricesPath or 
                       workType == WORK_TYPES.MINE and minePricesPath or sawmillPricesPath
    
    local pf = io.open(pricesPath, "r")
    if pf then
        for line in pf:lines() do
            local k, v = line:match("^(.-)=(.*)$")
            if k and v then prices[k] = tonumber(v) end
        end
        pf:close()
    end
    
    local result = {total = 0}
    for _, k in ipairs(cfg.resourceOrder) do result[k] = 0 end
    
    local sf = io.open(getServerStatsPath(workType), "r")
    if not sf then return result end
    local content = sf:read("*all")
    sf:close()
    
    if period == "daily" then
        local yesterdayDate = getGameDate(os.time() - 86400)
        for time, resource, amount in content:gmatch('"time":(%d+),"resource":"([^"]+)","amount":(%d+)') do
            if getGameDate(tonumber(time)) == yesterdayDate then
                result[resource] = (result[resource] or 0) + tonumber(amount)
            end
        end
    elseif period == "week" then
        local mskTime = getMoscowTime()
        local mskWday = tonumber(os.date("%w", mskTime))
        if mskWday == 0 then mskWday = 7 end
        local lastSundayTime = os.time() - (mskWday * 86400)
        local lastSunday = getGameDate(lastSundayTime)
        local lastMondayTime = lastSundayTime - (6 * 86400)
        local lastMonday = getGameDate(lastMondayTime)
        
        for time, resource, amount in content:gmatch('"time":(%d+),"resource":"([^"]+)","amount":(%d+)') do
            local logDate = getGameDate(tonumber(time))
            if logDate >= lastMonday and logDate <= lastSunday then
                result[resource] = (result[resource] or 0) + tonumber(amount)
            end
        end
    end
    
    for _, k in ipairs(cfg.resourceOrder) do
        local price = prices[k] or cfg.defaultPrices[k] or 0
        result.total = result.total + (result[k] * price)
    end
    
    return result
end
-- Генерация отчёта
local function generateReport(period)
    local mskTime = getMoscowTime()
    local timeStr = os.date("%H:%M", mskTime)
    local currentDateStr = os.date("%d.%m.%Y", mskTime)
    
    local report
    local farmData = getStatsForWorkType(WORK_TYPES.FARM, period)
    local mineData = getStatsForWorkType(WORK_TYPES.MINE, period)
    local sawmillData = getStatsForWorkType(WORK_TYPES.SAWMILL, period)
    
    local periodStart, periodEnd
    if period == "daily" then
        periodStart = getGameDate(os.time() - 86400)
        periodEnd = periodStart
    else
        local mskWday = tonumber(os.date("%w", mskTime))
        if mskWday == 0 then mskWday = 7 end
        local lastSundayTime = os.time() - (mskWday * 86400)
        local lastMondayTime = lastSundayTime - (6 * 86400)
        periodStart = getGameDate(lastMondayTime)
        periodEnd = getGameDate(lastSundayTime)
    end
    
    local function sumLog(log, valueFn)
        local total = 0
        if not log then return 0 end
        for _, entry in ipairs(log) do
            local logDate = getGameDate(entry.time)
            if logDate >= periodStart and logDate <= periodEnd then
                total = total + valueFn(entry)
            end
        end
        return total
    end
    
    local function sectionHeader(icon, title, total)
        return icon .. " <b>" .. title .. "</b> &#8212; <b>" .. formatNumber(total) .. "$</b>\n"
    end
    
    local function resourceList(order, names, data, suffix)
        local lines = ""
        for _, k in ipairs(order) do
            local amount = data[k] or 0
            if amount ~= 0 then
                lines = lines .. "    &#8226; " .. names[k] .. ": <b>" .. formatNumber(amount) .. (suffix or "") .. "</b>\n"
            end
        end
        return lines
    end
    
    local divider = string.rep("&#9644;", 18) .. "\n"
    
    if period == "daily" then
        local yesterdayTime = os.time() - 86400
        local yesterdayDate = os.date("%d.%m.%Y", yesterdayTime)
        report = "&#128197; <b>Ежедневный отчёт ResHelper</b>\n"
        report = report .. "&#128338; " .. yesterdayDate .. "\n"
        report = report .. "&#128338; Отправлено: " .. currentDateStr .. " | " .. timeStr .. " (МСК)\n"
    else
        local mskWday = tonumber(os.date("%w", mskTime))
        if mskWday == 0 then mskWday = 7 end
        local lastSundayTime = os.time() - (mskWday * 86400)
        local lastMondayTime = lastSundayTime - (6 * 86400)
        local lastMonday = os.date("%d.%m.%Y", lastMondayTime)
        local lastSunday = os.date("%d.%m.%Y", lastSundayTime)
        report = "&#128197; <b>Недельный отчёт ResHelper</b>\n"
        report = report .. "&#128338; Период: " .. lastMonday .. " - " .. lastSunday .. "\n"
        report = report .. "&#128338; Отправлено: " .. currentDateStr .. " | " .. timeStr .. " (МСК)\n"
    end
    report = report .. divider .. "\n"
    
    local totalAll = 0
    
    -- Пейдеи (всегда первым блоком)
    local paydayMoney = sumLog(paydayLog, function(e) return e.total or 0 end)
    local paydayAZ = sumLog(paydayLog, function(e) return e.az or 0 end)
    if paydayMoney ~= 0 or paydayAZ ~= 0 then
        report = report .. "&#128181; <b>Пейдеи</b> &#8212; <b>" .. formatNumber(paydayMoney) .. "$</b>"
        if paydayAZ ~= 0 then
            report = report .. " | AZ: <b>" .. formatNumber(paydayAZ) .. "</b>"
        end
        report = report .. "\n\n"
    end
    totalAll = totalAll + paydayMoney
    
    -- Ферма
    if farmData.total ~= 0 then
        report = report .. sectionHeader("&#127793;", "Ферма", farmData.total)
        report = report .. resourceList(configs[WORK_TYPES.FARM].resourceOrder, configs[WORK_TYPES.FARM].resourceNames, farmData, " шт.")
        report = report .. "\n"
    end
    totalAll = totalAll + farmData.total
    
    -- Шахта
    if mineData.total ~= 0 then
        report = report .. sectionHeader("&#9939;", "Шахта", mineData.total)
        report = report .. resourceList(configs[WORK_TYPES.MINE].resourceOrder, configs[WORK_TYPES.MINE].resourceNames, mineData, " шт.")
        report = report .. "\n"
    end
    totalAll = totalAll + mineData.total
    
    -- Лесопилка
    if sawmillData.total ~= 0 then
        report = report .. sectionHeader("&#127795;", "Лесопилка", sawmillData.total)
        report = report .. resourceList(configs[WORK_TYPES.SAWMILL].resourceOrder, configs[WORK_TYPES.SAWMILL].resourceNames, sawmillData, " шт.")
        report = report .. "\n"
    end
    totalAll = totalAll + sawmillData.total
    
    -- Нефтевышки
    local oilMoney = sumLog(oilLog, function(e) return e.money or 0 end)
    local oilAZ = sumLog(oilLog, function(e) return e.az or 0 end)
    if oilMoney ~= 0 or oilAZ ~= 0 then
        report = report .. sectionHeader("&#128738;", "Нефтевышки", oilMoney)
        if oilAZ ~= 0 then
            report = report .. "    &#128142; AZ: <b>" .. formatNumber(oilAZ) .. "</b>\n"
        end
        report = report .. "\n"
    end
    totalAll = totalAll + oilMoney
    
    -- Сторонний доход (вместо Item Market): Аренда / Осколки / Кейсы / Криптовалюта
    local rentMoney = 0
    for _, log in ipairs(itemMarketLog) do
        local logDate = getGameDate(log.time)
        if logDate >= periodStart and logDate <= periodEnd then
            rentMoney = rentMoney + (log.amount or 0)
        end
    end
    local shardMoney = sumLog(shardLog, function(e) return e.amount or 0 end)
    local caseMoney = sumLog(investmentLog, function(e)
        return (investmentConfig[e.itemId] and investmentConfig[e.itemId].cost) or 0
    end)
    local cryptoMoney = sumLog(cryptoLog, function(e)
        local cost = (cryptoConfig[e.itemId] and cryptoConfig[e.itemId].cost) or 0
        return cost * (e.amount or 0)
    end)
    local otherIncome = rentMoney + shardMoney + caseMoney + cryptoMoney
    
    if otherIncome ~= 0 then
        report = report .. sectionHeader("&#128188;", "Сторонний доход", otherIncome)
        if rentMoney ~= 0 then
            report = report .. "    &#127968; Аренда: <b>" .. formatNumber(rentMoney) .. "$</b>\n"
        end
        if shardMoney ~= 0 then
            report = report .. "    &#128142; Осколки: <b>" .. formatNumber(shardMoney) .. "$</b>\n"
        end
        if caseMoney ~= 0 then
            report = report .. "    &#128230; Кейсы: <b>" .. formatNumber(caseMoney) .. "$</b>\n"
        end
        if cryptoMoney ~= 0 then
            report = report .. "    &#8383; Криптовалюта: <b>" .. formatNumber(cryptoMoney) .. "$</b>\n"
        end
        report = report .. "\n"
    end
    totalAll = totalAll + otherIncome
    
    report = report .. divider
    report = report .. "&#128200; <b>Общий доход: " .. formatNumber(totalAll) .. "$</b>"
    
    return report
end
local function processInventoryLine(line)
    if not line then return end
    local cleanLine = line:gsub("{[%a%d]+}", "")
    local slot, name, count = cleanLine:match("%[слот (%d+)%]%s*(.-)%s*%[(%d+) шт%]")
    if not slot then
        name, count = cleanLine:match("(%S.+)%s*%[(%d+) шт%]")
    end
    if name and count then
        count = tonumber(count)
        name = name:gsub("^%s+", ""):gsub("%s+$", "")
        
        -- Поиск талона AZ (всегда, независимо от режима)
        if name:find("Талон") and name:find("AZ") then
            if not scanSlots["talon_az"] then scanSlots["talon_az"] = {} end
            table.insert(scanSlots["talon_az"], count)
            scanState.foundResources["talon_az"] = (scanState.foundResources["talon_az"] or 0) + count
            return true
        end
        
        -- Поиск Bitcoin и ASC (всегда, независимо от режима)
        if name:find("Bitcoin", 1, true) or name:find("BTC", 1, true) then
            if not scanSlots["crypto_btc"] then scanSlots["crypto_btc"] = {} end
            table.insert(scanSlots["crypto_btc"], count)
            scanState.foundResources["crypto_btc"] = (scanState.foundResources["crypto_btc"] or 0) + count
            return true
        end
        if name:find("Stable Coin", 1, true) or name:find("ASC", 1, true) then
            if not scanSlots["crypto_asc"] then scanSlots["crypto_asc"] = {} end
            table.insert(scanSlots["crypto_asc"], count)
            scanState.foundResources["crypto_asc"] = (scanState.foundResources["crypto_asc"] or 0) + count
            return true
        end
        
        -- Акции инкассатора (всегда, независимо от режима)
        local stockScanId = getStockIdByName(name)
        if stockScanId then
            local stockScanKey = "stock_" .. stockScanId
            if not scanSlots[stockScanKey] then scanSlots[stockScanKey] = {} end
            table.insert(scanSlots[stockScanKey], count)
            scanState.foundResources[stockScanKey] = (scanState.foundResources[stockScanKey] or 0) + count
            return true
        end
        -- Пропускаем Золотой VIN номер (название содержит "VIN")
        if name:find("VIN", 1, true) or name:find("vin", 1, true) then
            return false
        end
        
        if config and config.scanNames then
            for scanName, resKey in pairs(config.scanNames) do
                if name:find(scanName, 1, true) then
                    if not scanSlots[resKey] then scanSlots[resKey] = {} end
                    table.insert(scanSlots[resKey], count)
                    scanState.foundResources[resKey] = (scanState.foundResources[resKey] or 0) + count
                    return true
                end
            end
        end
    end
    return false
end
local function getMaxStack(resKey)
    if resKey and resKey:sub(1, 6) == "stock_" then return 1000000 end
    local maxStacks = {
        flax = 6000, cotton = 6000, rare_tkan = 5000, water = 1000, dye = 100, coal = 5000,
        stone = 6000, metal = 6000, bronze = 6000, silver = 6000, gold = 6000,
        diamond = 200, tkan = 200, splav = 200, materia = 50, azbox = 100,
        firewood = 200000, quality_wood = 500,
        talon_az = 10000, crypto_btc = 1000000, crypto_asc = 1000000
    }
    return maxStacks[resKey] or 100
end
function startStockScan()
    if scanState.active then return end
    stockScanToken = (stockScanToken or 0) + 1
    local myToken = stockScanToken
    scanState.active = true
    scanState.scanning = true
    scanState.foundResources = {}
    scanState.statusText = "Сканирование акций..."
    scanState.waitForInventory = false
    scanState.isTalonScan = true
    scanState.isStockScan = true
    lua_thread.create(function()
        wait(15000)
        if myToken == stockScanToken and scanState.active and scanState.scanning and scanState.isStockScan then
            scanState.active = false
            scanState.scanning = false
            scanState.waitForInventory = false
            scanState.isTalonScan = false
            scanState.isStockScan = false
            scanState.statusText = "Ошибка: таймаут"
            sampAddChatMessage(SCRIPT_PREFIX .. "Сканирование акций прервано по таймауту.", SCRIPT_COLOR)
        end
    end)
    sampSendChat("/stats")
end
local function startInventoryScan()
    if scanState.active then
        sampAddChatMessage("{FFA500}[ResHelher] Сканирование уже выполняется...", -1)
        return
    end
    if not config.scanNames then
        sampAddChatMessage("{FFA500}[ResHelher] Для текущего типа работы нет настроек сканирования.", -1)
        return
    end
scanState.active = true
scanState.scanning = true
scannedThisSession[currentWork] = true
scanState.isTalonScan = false
scanState.isStockScan = false
scanState.foundResources = {}
scanState.statusText = "Открываю статистику..."
scanState.waitForInventory = false
pendingResources = {}
pendingResourcesBuffer = {} 
    sampAddChatMessage("{00FF00}[ResHelher] Запущено сканирование инвентаря...", -1)
    lua_thread.create(function()
        wait(15000)
        if scanState.active and scanState.scanning then
            sampAddChatMessage("{FFA500}[ResHelher] Сканирование прервано по таймауту.", -1)
            scanState.active = false
            scanState.scanning = false
            scanState.statusText = "Ошибка: таймаут"
        end
    end)
    sampSendChat("/stats")
end
local function finishScan()
    inventoryBase = {}
    for resKey, amount in pairs(scanState.foundResources) do
        inventoryBase[resKey] = amount
    end
    for resKey, slots in pairs(scanSlots) do
        local itemId
        if currentWork == WORK_TYPES.FARM then
            itemId = FARM_RES_TO_ITEM[resKey]
        elseif currentWork == WORK_TYPES.MINE then
            itemId = MINE_RES_TO_ITEM[resKey]
        elseif currentWork == WORK_TYPES.SAWMILL then
            itemId = SAWMILL_RES_TO_ITEM[resKey]
        end
        if itemId then
            inventoryCache[itemId] = {}
            for _, v in ipairs(slots) do
                table.insert(inventoryCache[itemId], v)
            end
        end
    end
    -- Сохраняем талон AZ в кэш
    if scanSlots["talon_az"] then
        inventoryCache[731] = {}
        for _, v in ipairs(scanSlots["talon_az"]) do
            table.insert(inventoryCache[731], v)
        end
    end
    if not inventoryCache[731] or #inventoryCache[731] == 0 then
        inventoryCache[731] = {0}
    end
    talonBaselineReady = true 
    if scanState.isStockScan then
        for _, sid in ipairs(STOCK_ORDER) do
            local sk = "stock_" .. sid
            if scanSlots[sk] then
                inventoryCache[sid] = {}
                for _, v in ipairs(scanSlots[sk]) do table.insert(inventoryCache[sid], v) end
            else
                inventoryCache[sid] = {0}
            end
        end
        stockScannedThisSession = true
    end
    pcall(saveCryptoBase)
    -- Сохраняем BTC/ASC в кэш (база для корректного учёта крипты)
    if scanSlots["crypto_btc"] then
        inventoryCache[1811] = {}
        for _, v in ipairs(scanSlots["crypto_btc"]) do
            table.insert(inventoryCache[1811], v)
        end
    end
    if not inventoryCache[1811] or #inventoryCache[1811] == 0 then
        inventoryCache[1811] = {0}
    end
    if scanSlots["crypto_asc"] then
        inventoryCache[5996] = {}
        for _, v in ipairs(scanSlots["crypto_asc"]) do
            table.insert(inventoryCache[5996], v)
        end
    end
    if not inventoryCache[5996] or #inventoryCache[5996] == 0 then
        inventoryCache[5996] = {0}
    end
    if config then
        for _, resKey in ipairs(config.resourceOrder) do
            if not inventoryBase[resKey] then
                inventoryBase[resKey] = 0
            end
            local itemId
            if currentWork == WORK_TYPES.FARM then
                itemId = FARM_RES_TO_ITEM[resKey]
            elseif currentWork == WORK_TYPES.MINE then
                itemId = MINE_RES_TO_ITEM[resKey]
            elseif currentWork == WORK_TYPES.SAWMILL then
                itemId = SAWMILL_RES_TO_ITEM[resKey]
            end
            if itemId and not scanSlots[resKey] then
                inventoryCache[itemId] = {0}
            end
        end
    end
    scanSlots = {}
    scanState.scanned = true
    local foundItems = {}
    if config then
        for _, resKey in ipairs(config.resourceOrder) do
            if resKey ~= "rare_box" then
                local amount = inventoryBase[resKey] or 0
                table.insert(foundItems, config.resourceNames[resKey] .. ": " .. amount .. " шт.")
            end
        end
    end
    if not scanState.isTalonScan then
        scanSummary.baseWorkType = currentWork
        scanSummary.baseItems = foundItems
        scanSummary.baseTime = os.time()
        sampAddChatMessage("{00FF00}[ResHelher] Сканирование завершено! Найдено в инвентаре:", -1)
        for _, msg in ipairs(foundItems) do
            sampAddChatMessage("{FFFFFF}  " .. msg, -1)
        end
        sampAddChatMessage("{FFA500}[ResHelher] База установлена. Учитывается только новая добыча.", -1)
    end
    do
        local btcAmount = 0
        if inventoryCache[1811] then
            for _, v in ipairs(inventoryCache[1811]) do btcAmount = btcAmount + v end
        end
        local ascAmount = 0
        if inventoryCache[5996] then
            for _, v in ipairs(inventoryCache[5996]) do ascAmount = ascAmount + v end
        end
        scanSummary.btc = btcAmount
        scanSummary.asc = ascAmount
        if settings.cryptoAutoScanEnabled then
            sampAddChatMessage(SCRIPT_PREFIX .. "Крипта в инвентаре: BTC " .. btcAmount .. " шт., ASC " .. ascAmount .. " шт.", SCRIPT_COLOR)
        end
    end
    scanState.active = false
    scanState.scanning = false
    scanState.statusText = "Готово"
    ignoreInventoryUntil = os.time() + 3
    if not scanState.isTalonScan then
        saveInventoryBase()
    end
    if scanState.isTalonScan then
        local talonAmount = 0
        if inventoryCache[731] then
            for _, v in ipairs(inventoryCache[731]) do
                talonAmount = talonAmount + v
            end
        end
        scanSummary.azTalon = talonAmount
        if settings.talonAutoScanEnabled then
            if not scanState.isStockScan then sampAddChatMessage(SCRIPT_PREFIX .. "Авто-сканирование завершено! Найдено талонов AZ: " .. talonAmount .. " шт. Учёт AZ в пейдеях активирован.", SCRIPT_COLOR) end
        end
    end
    if scanState.isStockScan then
        local stockParts = {}
        for _, sid in ipairs(STOCK_ORDER) do
            local total = 0
            for _, v in ipairs(inventoryCache[sid] or {}) do total = total + v end
            if total > 0 then
                table.insert(stockParts, (STOCKS[sid].name:gsub("^Акция ", "")) .. " x" .. total)
            end
        end
        sampAddChatMessage(SCRIPT_PREFIX .. "Акции в инвентаре: " .. (#stockParts > 0 and table.concat(stockParts, ", ") or "не найдено"), SCRIPT_COLOR)
    end
    scanState.isStockScan = false
    scanState.isTalonScan = false
    sampCloseCurrentDialogWithButton(0)
end
-- ====== ФУНКЦИИ ДОСТИЖЕНИЙ ======
achSaved = achSaved or {}
function saveAchievements()
    local data = {}
    for _, ach in ipairs(ACHIEVEMENTS) do
        achSaved[ach.id] = { progress = ach.progress, completed = ach.completed }
    end
    for id, s in pairs(achSaved) do
        table.insert(data, { id = id, progress = s.progress, completed = s.completed })
    end
    local saveData = {
        achievements = data,
        totalCompletedGoals = totalCompletedGoals,
    }
    local file = io.open(achievementsPath, "w")
    if file then
        file:write(encodeJson(saveData))
        file:close()
    end
end
function loadAchievements()
    local file = io.open(achievementsPath, "r")
    if not file then rhAchStartup(); return end
    local content = file:read("*all")
    file:close()
    local data = decodeJson(content)
    if not data then rhAchStartup(); return end
    
    if data.totalCompletedGoals then
        totalCompletedGoals = data.totalCompletedGoals
    end
    
    if data.achievements then
        for _, saved in ipairs(data.achievements) do
            if saved.id then
                achSaved[saved.id] = { progress = saved.progress or 0, completed = saved.completed or false }
            end
        end
    end
    rhAchStartup()
end
achSaved = achSaved or {}
RH_ACH_KINDS = { goal_count = true, resource_total = true, income_work = true, income_total = true, im_income = true, goals_total = true,
    oil_money = true, oil_az = true, taxi_rides = true, taxi_money = true,
    incass_money = true, incass_payouts = true, incass_stocks = true, incass_total = true }
RH_ACH_COUNT = { resource_total = true, oil_az = true, taxi_rides = true, incass_payouts = true, incass_stocks = true }
RH_ACH_UNITS = { income_work = "$", income_total = "$", im_income = "$", resource_total = " шт.",
    oil_money = "$", oil_az = " AZ", taxi_rides = " поездок", taxi_money = "$",
    incass_money = "$", incass_payouts = " выплат", incass_stocks = " акций", incass_total = "$" }
function rhSumLog(log, field)
    local s = 0
    for _, e in ipairs(log) do s = s + (e[field] or 0) end
    return s
end
achDefsPath = configDir .. "achievements_defs.json"
achDefsLoading = false
function rhApplyAchievementDefs(list)
    for _, ach in ipairs(ACHIEVEMENTS) do
        achSaved[ach.id] = { progress = ach.progress, completed = ach.completed }
    end
    for i = #ACHIEVEMENTS, 1, -1 do ACHIEVEMENTS[i] = nil end
    for _, d in ipairs(list) do
        local id = d.id and tostring(d.id) or ""
        local kind = tostring(d.kind or "")
        local target = tonumber(d.target) or 0
        if id ~= "" and RH_ACH_KINDS[kind] and target > 0 then
            local ach = {
                id = id,
                name = u8:decode(tostring(d.name or id)),
                desc = u8:decode(tostring(d.desc or "")),
                icon = fa[tostring(d.icon or "")] or fa.ICON_STAR,
                category = u8:decode(tostring(d.category or "")),
                target = target,
                kind = kind,
                param = tostring(d.param or ""),
                progress = 0,
                completed = false,
            }
            local s = achSaved[id]
            if s then
                ach.progress = s.progress or 0
                ach.completed = s.completed or false
                if ach.completed and ach.progress < target then
                    ach.completed = false
                end
            end
            if kind == "goal_count" then
                local p = ach.param
                ach.check = function() return goalsReached[p] end
            end
            table.insert(ACHIEVEMENTS, ach)
        end
    end
end
function rhLoadAchievementDefsFromCache()
    local f = io.open(achDefsPath, "r")
    if not f then return end
    local text = f:read("*a")
    f:close()
    local ok, parsed = pcall(decodeJson, text)
    if ok and type(parsed) == "table" and rhCountValidAchDefs(parsed) > 0 then rhApplyAchievementDefs(parsed) end
end
achDefsStartedAt = 0
function rhCountValidAchDefs(list)
    local n = 0
    for _, d in ipairs(list) do
        if d.id and RH_ACH_KINDS[tostring(d.kind or "")] and (tonumber(d.target) or 0) > 0 then n = n + 1 end
    end
    return n
end
function downloadAchievementDefs()
    if achDefsLoading and os.time() - achDefsStartedAt < 30 then return end
    achDefsLoading = true
    achDefsStartedAt = os.time()
    local tempFile = dirml .. "/achievements_temp.json"
    print("[ResHelper:ACH] загрузка списка достижений...")
    downloadUrlToFile(LEADERBOARD_URL .. "?action=achievements&t=" .. os.time(), tempFile, function(id, status)
        if status ~= dlstatus.STATUS_ENDDOWNLOADDATA then return end
        achDefsLoading = false
        local f = io.open(tempFile, "r")
        if not f then print("[ResHelper:ACH] файл ответа не найден"); return end
        local text = f:read("*a")
        f:close()
        os.remove(tempFile)
        local ok, parsed = pcall(decodeJson, text)
        if not (ok and type(parsed) == "table") then
            print("[ResHelper:ACH] ответ не JSON: " .. tostring(text):sub(1, 120))
            return
        end
        local valid = rhCountValidAchDefs(parsed)
        if valid == 0 then
            print("[ResHelper:ACH] в ответе нет подходящих достижений (" .. #parsed .. " записей): " .. tostring(text):sub(1, 120))
            return
        end
        local cf = io.open(achDefsPath, "w")
        if cf then cf:write(text); cf:close() end
        rhApplyAchievementDefs(parsed)
        updateProgressAchievements()
        print("[ResHelper:ACH] загружено достижений: " .. #ACHIEVEMENTS)
    end)
end
function rhAchStartup()
    rhLoadAchievementDefsFromCache()
    downloadAchievementDefs()
end
local processedGoalAchievements = {}
function checkAchievements()
    local earned = false
    for _, ach in ipairs(ACHIEVEMENTS) do
        if not ach.completed then
            local shouldProgress = false
            if ach.check then
                
                if ach.kind == "goal_count" then
                    local goalName = ach.param
                    if ach.check() and not processedGoalAchievements[goalName] then
                        shouldProgress = true
                        processedGoalAchievements[goalName] = true
                    end
                else
                    
                    if ach.check() then
                        shouldProgress = true
                    end
                end
            end
            if shouldProgress then
                ach.progress = ach.progress + 1
                if ach.progress >= ach.target then
                    ach.completed = true
                    earned = true
                    if settings.goalSoundEnabled then
                        playSoundFile(
                            "achiv.wav",
                            settings.goalSoundVolume
                        )
                    end
                    if settings.chatNotifyEnabled then
                        sampAddChatMessage(
                            SCRIPT_PREFIX ..
                            "Достижение \"" ..
                            ach.name ..
                            "\" выполнено!",
                            SCRIPT_COLOR
                        )
                    end
					    local achDesc = ach.name .. " - выполнено " .. ach.progress .. "/" .. ach.target .. " раз"
							showAchievementNotification(u8("Достижение выполнено!"), achDesc, ach.icon)
                end
                saveAchievements()
            end
        end
    end
    return earned
end
function showAchievementNotification(title, text, icon)
    table.insert(achievementNotifications, {
        title = title,
        text = text,
        icon = icon,
        time = os.time(),
    })
end
function getTotalResource(resourceName)
    local total = 0
local paths = {
    getServerStatsPath(WORK_TYPES.FARM),
    getServerStatsPath(WORK_TYPES.MINE),
    getServerStatsPath(WORK_TYPES.SAWMILL),
}
    for _, path in ipairs(paths) do
        local file = io.open(path, "r")
        if file then
            local content = file:read("*all")
            file:close()
            for amount in content:gmatch('"resource":"' .. resourceName .. '","amount":(%d+)') do
                total = total + tonumber(amount)
            end
        end
    end
    return total
end
function rhWorkIncomeFromStats(workType, pricesPath)
    local sf = io.open(getServerStatsPath(workType), "r")
    if not sf then return 0 end
    local content = sf:read("*all")
    sf:close()
    local prices = {}
    local pf = io.open(pricesPath, "r")
    if pf then
        for line in pf:lines() do
            local k, v = line:match("^(.-)=(.*)$")
            if k and v then prices[k] = tonumber(v) end
        end
        pf:close()
    end
    local total = 0
    for resource, amount in content:gmatch('"resource":"([^"]+)","amount":(%d+)') do
        local price = prices[resource] or configs[workType].defaultPrices[resource] or 0
        total = total + tonumber(amount) * price
    end
    return total
end
function updateProgressAchievements()
    local resCache, incCache = {}, {}
    local function totalRes(name)
        if resCache[name] == nil then resCache[name] = getTotalResource(name) end
        return resCache[name]
    end
    local function workIncome(w)
        if incCache[w] == nil then
            if w == "farm" then incCache[w] = rhWorkIncomeFromStats(WORK_TYPES.FARM, farmPricesPath)
            elseif w == "mine" then incCache[w] = rhWorkIncomeFromStats(WORK_TYPES.MINE, minePricesPath)
            elseif w == "sawmill" then incCache[w] = rhWorkIncomeFromStats(WORK_TYPES.SAWMILL, sawmillPricesPath)
            else incCache[w] = 0 end
        end
        return incCache[w]
    end
    for _, ach in ipairs(ACHIEVEMENTS) do
        if not ach.completed and ach.kind ~= "goal_count" then
            local kind = ach.kind
            local newProgress = ach.progress or 0
            if kind == "resource_total" then
                newProgress = totalRes(ach.param)
            elseif kind == "income_work" then
                newProgress = workIncome(ach.param)
            elseif kind == "income_total" then
                newProgress = workIncome("farm") + workIncome("mine") + workIncome("sawmill")
                for _, log in ipairs(itemMarketLog) do newProgress = newProgress + log.amount end
            elseif kind == "im_income" then
                newProgress = getTotalItemMarketIncome()
            elseif kind == "oil_money" then
                newProgress = rhSumLog(oilLog, "money")
            elseif kind == "oil_az" then
                newProgress = rhSumLog(oilLog, "az")
            elseif kind == "taxi_rides" then
                newProgress = #taxiLog
            elseif kind == "taxi_money" then
                newProgress = rhSumLog(taxiLog, "money")
            elseif kind == "incass_money" then
                newProgress = getIncassSummary().all.money
            elseif kind == "incass_payouts" then
                newProgress = getIncassSummary().all.payouts
            elseif kind == "incass_stocks" then
                newProgress = getIncassSummary().all.stocks
            elseif kind == "incass_total" then
                newProgress = getIncassSummary().all.total
            elseif kind == "goals_total" then
                newProgress = totalCompletedGoals
            end
            ach.progress = newProgress
            if ach.progress >= ach.target and ach.target > 0 then
                ach.completed = true
                if settings.goalSoundEnabled then playSoundFile("achiv.wav", settings.goalSoundVolume) end
                if settings.chatNotifyEnabled then
                    sampAddChatMessage(SCRIPT_PREFIX .. "Достижение \"" .. ach.name .. "\" выполнено!", SCRIPT_COLOR)
                end
                local achDesc = ach.name
                local unit = RH_ACH_UNITS[kind]
                if unit then achDesc = ach.name .. " - " .. formatNumber(ach.target) .. unit end
                showAchievementNotification(u8("Достижение выполнено!"), achDesc, ach.icon)
            end
        end
    end
    saveAchievements()
end
-- ====== СОХРАНЕНИЕ/ЗАГРУЗКА БАЗЫ ИНВЕНТАРЯ ======
function getCryptoBasePath()
    local server = getCurrentServer()
    if server and server ~= "Unknown" then
        return configDir .. "crypto_base_" .. server .. ".json"
    else
        return configDir .. "crypto_base.json"
    end
end
function saveCryptoBase()
    local path = getCryptoBasePath()
    local file = io.open(path, "w")
    if not file then return end
    file:write("{\n")
    local first = true
    for _, itemId in ipairs({1811, 5996}) do
        local slots = inventoryCache[itemId]
        if slots and #slots > 0 then
            if not first then file:write(",\n") end
            first = false
            file:write('  "' .. itemId .. '": [')
            for i, amount in ipairs(slots) do
                if i > 1 then file:write(", ") end
                file:write(amount)
            end
            file:write(']')
        end
    end
    file:write('\n}')
    file:close()
end
function loadCryptoBase()
    local path = getCryptoBasePath()
    local file = io.open(path, "r")
    if not file then return end
    local content = file:read("*all")
    file:close()
    for itemId, amounts in content:gmatch('"(%d+)":%s*%[([^%]]+)%]') do
        local slots = {}
        for amount in amounts:gmatch("%d+") do
            table.insert(slots, tonumber(amount))
        end
        if #slots > 0 then
            inventoryCache[tonumber(itemId)] = slots
        end
    end
end
function saveInventoryBase()
    if not currentWork then return end
    local path = getServerBasePath(currentWork)
    if not path then return end
    local file = io.open(path, "w")
    if not file then return end
    file:write("{\n")
    local first = true
    for itemId, slots in pairs(inventoryCache) do
        if #slots > 0 then
            if not first then file:write(",\n") end
            first = false
            file:write('  "' .. itemId .. '": [')
            for i, amount in ipairs(slots) do
                if i > 1 then file:write(", ") end
                file:write(amount)
            end
            file:write(']')
        end
    end
    file:write('\n}')
    file:close()
    pcall(saveCryptoBase)
end
function loadInventoryBase()
    if not currentWork then return end
    local path = getServerBasePath(currentWork)
    if not path then return end
    local file = io.open(path, "r")
    if not file then return end
    local content = file:read("*all")
    file:close()
    for itemId, amounts in content:gmatch('"(%d+)":%s*%[([^%]]+)%]') do
        local slots = {}
        for amount in amounts:gmatch("%d+") do
            table.insert(slots, tonumber(amount))
        end
        if #slots > 0 then
            inventoryCache[tonumber(itemId)] = slots
        end
    end
    scanState.scanned = true
    ignoreInventoryUntil = os.time() + 3
    pcall(loadCryptoBase)
end
function saveThemeConfig()
    local data = { 
        theme = (rhVcThemeActive and rhThemeBackup.theme or currentTheme),
        useCustom = (rhVcThemeActive and rhThemeBackup.custom or useCustomTheme),
        vcTheme = rhVcThemeEnabled
    }
    local file = io.open(themeConfigPath, "w")
    if file then
        file:write(encodeJson(data))
        file:close()
    end
end
function loadThemeConfig()
    local file = io.open(themeConfigPath, "r")
    if not file then return end
    local content = file:read("*all")
    file:close()
    local data = decodeJson(content)
    if data then
        if data.theme then currentTheme = data.theme end
        if data.useCustom ~= nil then useCustomTheme = data.useCustom end
    end
end
function saveCustomTheme()
    local data = {}
    for k, v in pairs(CUSTOM_THEME) do
        data[k] = {v.x, v.y, v.z, v.w}
    end
    local file = io.open(customThemePath, "w")
    if file then
        file:write(encodeJson(data))
        file:close()
    end
end
function loadCustomTheme()
    local file = io.open(customThemePath, "r")
    if not file then return end
    local content = file:read("*all")
    file:close()
    local data = decodeJson(content)
    if not data then return end
    for k, v in pairs(data) do
        if type(v) == "table" and #v == 4 then
            CUSTOM_THEME[k] = imgui.ImVec4(v[1], v[2], v[3], v[4])
        end
    end
end
function resetCustomTheme()
    CUSTOM_THEME.accent = imgui.ImVec4(0.26, 0.98, 0.26, 1.0)
    CUSTOM_THEME.leftPanelBg = imgui.ImVec4(0.055, 0.055, 0.055, 1.0)
    CUSTOM_THEME.rightPanelBg = imgui.ImVec4(0.078, 0.078, 0.078, 1.0)
    CUSTOM_THEME.buttonActive = imgui.ImVec4(0.118, 0.239, 0.118, 1.0)
    CUSTOM_THEME.buttonHover = imgui.ImVec4(0.165, 0.165, 0.165, 1.0)
    CUSTOM_THEME.borderActive = imgui.ImVec4(0.26, 0.98, 0.26, 1.0)
    CUSTOM_THEME.textNormal = imgui.ImVec4(0.6, 0.6, 0.6, 1.0)
    CUSTOM_THEME.textActive = imgui.ImVec4(0.26, 0.98, 0.26, 1.0)
    CUSTOM_THEME.textHover = imgui.ImVec4(1.0, 1.0, 1.0, 1.0)
    CUSTOM_THEME.headerTitle = imgui.ImVec4(0.26, 0.98, 0.26, 1.0)
    CUSTOM_THEME.titleBg = imgui.ImVec4(0.055, 0.055, 0.055, 1.0)
	CUSTOM_THEME.tableHeaderBg = imgui.ImVec4(0.133, 0.133, 0.133, 1.0)
    CUSTOM_THEME.tableHeaderText = imgui.ImVec4(0.533, 0.533, 0.533, 1.0)
    CUSTOM_THEME.rightTitleBg = imgui.ImVec4(0.078, 0.078, 0.078, 1.0)
    CUSTOM_THEME.windowBg = imgui.ImVec4(0.078, 0.078, 0.078, 1.0)
	CUSTOM_THEME.statCardBg = imgui.ImVec4(0.1, 0.1, 0.1, 1.0)
    CUSTOM_THEME.statCardBorder = imgui.ImVec4(0.2, 0.2, 0.2, 1.0)
    CUSTOM_THEME.statCardLabel = imgui.ImVec4(0.533, 0.533, 0.533, 1.0)
    CUSTOM_THEME.statCardValue = imgui.ImVec4(0.26, 0.98, 0.26, 1.0)
    CUSTOM_THEME.statCardValueToday = imgui.ImVec4(1.0, 0.8, 0.0, 1.0)
    CUSTOM_THEME.statCardValueWeek = imgui.ImVec4(0.2, 0.8, 1.0, 1.0)
    CUSTOM_THEME.statCardAZ = imgui.ImVec4(0.0, 0.8, 1.0, 1.0)
    CUSTOM_THEME.childBg = imgui.ImVec4(0.078, 0.078, 0.078, 1.0)
	CUSTOM_THEME.cardBtnBg = imgui.ImVec4(0.15, 0.15, 0.15, 1.0)
    CUSTOM_THEME.cardBtnBgHovered = imgui.ImVec4(0.22, 0.22, 0.22, 1.0)
    CUSTOM_THEME.cardBtnText = imgui.ImVec4(1.0, 1.0, 1.0, 1.0)
    CUSTOM_THEME.borderColor = imgui.ImVec4(0.165, 0.165, 0.165, 1.0)
	CUSTOM_THEME.cardBg = imgui.ImVec4(0.1, 0.1, 0.1, 1.0)
    CUSTOM_THEME.cardBgHovered = imgui.ImVec4(0.133, 0.133, 0.133, 1.0)
    CUSTOM_THEME.cardBorder = imgui.ImVec4(0.2, 0.2, 0.2, 1.0)
    CUSTOM_THEME.cardText = imgui.ImVec4(1.0, 1.0, 1.0, 1.0)
    CUSTOM_THEME.cardIcon = imgui.ImVec4(0.26, 0.98, 0.26, 1.0)
    CUSTOM_THEME.cardTitle = imgui.ImVec4(0.26, 0.98, 0.26, 1.0)
	CUSTOM_THEME.contentText = imgui.ImVec4(0.9, 0.9, 0.9, 1.0)
    CUSTOM_THEME.imguiButton = imgui.ImVec4(0.2, 0.2, 0.2, 0.6)
    CUSTOM_THEME.imguiButtonHovered = imgui.ImVec4(0.26, 0.98, 0.26, 0.4)
    CUSTOM_THEME.imguiButtonActive = imgui.ImVec4(0.26, 0.98, 0.26, 0.6)
    CUSTOM_THEME.collapsingHeader = imgui.ImVec4(0.22, 0.22, 0.22, 0.5)
    CUSTOM_THEME.collapsingHeaderHovered = imgui.ImVec4(0.26, 0.98, 0.26, 0.4)
    CUSTOM_THEME.collapsingHeaderActive = imgui.ImVec4(0.26, 0.98, 0.26, 0.6)
    CUSTOM_THEME.separatorColor = imgui.ImVec4(0.2, 0.2, 0.2, 1.0)
    CUSTOM_THEME.progressBar = imgui.ImVec4(0.26, 0.98, 0.26, 0.6)
    CUSTOM_THEME.checkMark = imgui.ImVec4(0.26, 0.98, 0.26, 1.0)
    CUSTOM_THEME.sliderGrab = imgui.ImVec4(0.26, 0.98, 0.26, 1.0)
    CUSTOM_THEME.sliderGrabActive = imgui.ImVec4(0.26, 0.98, 0.26, 1.0)
    CUSTOM_THEME.frameBg = imgui.ImVec4(0.2, 0.2, 0.2, 0.54)
    CUSTOM_THEME.frameBgHovered = imgui.ImVec4(0.3, 0.3, 0.3, 0.4)
    CUSTOM_THEME.frameBgActive = imgui.ImVec4(0.26, 0.98, 0.26, 0.3)
    CUSTOM_THEME.titleBgActive = imgui.ImVec4(0.1, 0.1, 0.1, 1.0)
    CUSTOM_THEME.titleBgCollapsed = imgui.ImVec4(0.0, 0.0, 0.0, 0.51)
end
-- Конвертация ImVec4 в HEX для drawList
local function imVec4ToHex(v)
    if type(v) == "number" then
        return v 
    end
    local a = math.floor(v.w * 255)
    local r = math.floor(v.x * 255)
    local g = math.floor(v.y * 255)
    local b = math.floor(v.z * 255)
    return (a * 0x1000000) + (b * 0x10000) + (g * 0x100) + r
end
function applyAlpha(color, alpha)
    if type(color) ~= "number" then return color end
    alpha = math.max(0, math.min(alpha, 1))
    local a = math.floor(math.floor(color / 0x1000000) * alpha)
    return (color % 0x1000000) + (a * 0x1000000)
end
function saveItemMarketStats()
    local file = io.open(itemMarketStatsPath, "w")
    if not file then return end
    file:write('{\n  "logs": [\n')
    for i, log in ipairs(itemMarketLog) do
        file:write('    {"time":' .. log.time .. ',"nick":"' .. log.nick .. '","amount":' .. log.amount .. ',"rentType":"' .. (log.rentType or "im") .. '"}')
        if i < #itemMarketLog then file:write(',\n') else file:write('\n') end
    end
    file:write('  ]\n}')
    file:close()
end
function loadItemMarketStats()
    itemMarketLog = {}
    local f = io.open(itemMarketStatsPath, "r")
    if not f then return end
    local content = f:read("*all")
    f:close()
    
    local cleaned = content:gsub("%s+", "")
    
    for time, nick, amount, rentType in cleaned:gmatch('{"time":(%d+),"nick":"([^"]+)","amount":(%d+),"rentType":"([^"]+)"}') do
        table.insert(itemMarketLog, {time = tonumber(time), nick = nick, amount = tonumber(amount), rentType = rentType})
    end
    
    for time, nick, amount in cleaned:gmatch('{"time":(%d+),"nick":"([^"]+)","amount":(%d+)}') do
        table.insert(itemMarketLog, {time = tonumber(time), nick = nick, amount = tonumber(amount)})
    end
    
    table.sort(itemMarketLog, function(a, b) return a.time > b.time end)
    
    itemMarketTodayIncome = 0
    local gameDate = getGameDate()
    for _, log in ipairs(itemMarketLog) do
        if getGameDate(log.time) == gameDate then
            itemMarketTodayIncome = itemMarketTodayIncome + log.amount
        end
    end
end
function saveShardStats()
    local file = io.open(shardStatsPath, "w")
    if not file then return end
    file:write(encodeJson(shardLog))
    file:close()
end
function loadShardStats()
    shardLog = shardLog or {}
    local f = io.open(shardStatsPath, "r")
    if not f then return end
    local content = f:read("*all")
    f:close()
    local data = decodeJson(content)
    if data then shardLog = data end
end
function saveInvestmentStats()
    local file = io.open(investmentStatsPath, "w")
    if not file then return end
    file:write(encodeJson(investmentLog))
    file:close()
end
function loadInvestmentStats()
    local f = io.open(investmentStatsPath, "r")
    if not f then return end
    local content = f:read("*all")
    f:close()
    local data = decodeJson(content)
    if data then investmentLog = data end
end
function saveInvestmentConfig()
    local ok, err = pcall(function()
        local file = io.open(investmentConfigPath, "w")
        if not file then return end
        local saveData = {}
        for itemId, data in pairs(investmentConfig) do
            saveData[tostring(itemId)] = {
                name = data.name,
                cost = data.cost,
                count = data.count,
            }
        end
        file:write(encodeJson(saveData))
        file:close()
    end)
    if not ok then
        print("ResHelper: Ошибка сохранения investment_config.json - " .. tostring(err))
    end
end
function saveCryptoStats()
    local file = io.open(cryptoStatsPath, "w")
    if not file then return end
    file:write(encodeJson(cryptoLog))
    file:close()
end
function loadCryptoStats()
    local f = io.open(cryptoStatsPath, "r")
    if not f then return end
    local content = f:read("*all")
    f:close()
    local data = decodeJson(content)
    if data then cryptoLog = data end
end
function saveCryptoConfig()
    local ok, err = pcall(function()
        local file = io.open(cryptoConfigPath, "w")
        if not file then return end
        local saveData = {}
        for itemId, data in pairs(cryptoConfig) do
            saveData[tostring(itemId)] = {
                name = data.name,
                cost = data.cost,
                count = data.count,
            }
        end
        file:write(encodeJson(saveData))
        file:close()
    end)
    if not ok then
        print("ResHelper: Ошибка сохранения crypto_config.json - " .. tostring(err))
    end
end
function loadCryptoConfig()
    local f = io.open(cryptoConfigPath, "r")
    if not f then return end
    local content = f:read("*all")
    f:close()
    local data = decodeJson(content)
    if data then
        for itemId, coinData in pairs(data) do
            local id = tonumber(itemId)
            if id then
                cryptoConfig[id] = {
                    name = coinData.name or ALL_CRYPTO[id] or "Неизвестная монета",
                    cost = coinData.cost or 0,
                    count = coinData.count or 0,
                }
            end
        end
    end
end
function fetchCryptoPrices(force)
    if cryptoPriceDialogState.pending then
        if force then
            sampAddChatMessage(SCRIPT_PREFIX .. "Уже идёт обновление курса, подожди...", SCRIPT_COLOR)
        end
        return
    end
    if not force and os.time() - (settings.cryptoPricesLastFetch or 0) < 86400 then
        return
    end
    cryptoPriceDialogState.pending = true
    cryptoPriceDialogState.pendingTime = os.time()
    sampProcessChatInput("/call 8828")
    if force then
        sampAddChatMessage(SCRIPT_PREFIX .. "Обновляю курс крипты...", SCRIPT_COLOR)
    end
    lua_thread.create(function()
        wait(8000)
        if cryptoPriceDialogState.pending and os.time() - cryptoPriceDialogState.pendingTime >= 8 then
            cryptoPriceDialogState.pending = false
            if force then
                sampAddChatMessage(SCRIPT_PREFIX .. "Не удалось получить курс (нет ответа от банка).", SCRIPT_COLOR)
            end
            sampProcessChatInput("/phone")
        end
    end)
end
function loadInvestmentConfig()
    local f = io.open(investmentConfigPath, "r")
    if not f then return end
    local content = f:read("*all")
    f:close()
    local data = decodeJson(content)
    if data then
        for itemId, caseData in pairs(data) do
            local id = tonumber(itemId)
            if id then
                investmentConfig[id] = {
                    name = caseData.name or ALL_CASES[id] or "Неизвестный ларец",
                    cost = caseData.cost or 0,
                    count = caseData.count or 0,
                }
            end
        end
    end
end
function savePaydayStats()
    local ok, err = pcall(function()
        local file = io.open(paydayStatsPath, "w")
        if not file then return end
        file:write(encodeJson(paydayLog))
        file:close()
    end)
    if not ok then
        print("ResHelper: Ошибка сохранения payday_stats.json - " .. tostring(err))
    end
end
function loadPaydayStats()
    local f = io.open(paydayStatsPath, "r")
    if not f then return end
    local content = f:read("*all")
    f:close()
    local data = decodeJson(content)
    if data then paydayLog = data end
end
function savePaydayUiConfig()
    local ok, err = pcall(function()
        local file = io.open(paydayUiConfigPath, "w")
        if not file then return end
        file:write(encodeJson({showRubColumn = showRubColumn}))
        file:close()
    end)
    if not ok then
        print("ResHelper: Ошибка сохранения payday_ui_config.json - " .. tostring(err))
    end
end
function loadPaydayUiConfig()
    local f = io.open(paydayUiConfigPath, "r")
    if not f then return end
    local content = f:read("*all")
    f:close()
    local data = decodeJson(content)
    if data and data.showRubColumn ~= nil then
        showRubColumn = data.showRubColumn
    end
end
function saveOilStats()
    local ok, err = pcall(function()
        local file = io.open(oilStatsPath, "w")
        if not file then return end
        file:write(encodeJson(oilLog))
        file:close()
    end)
    if not ok then
        print("ResHelper: Ошибка сохранения oil_stats.json - " .. tostring(err))
    end
end
function addOilLog(kind, money, az, caseType)
    table.insert(oilLog, 1, {time = os.time(), kind = kind, money = money, az = az, caseType = caseType, caseCount = (kind == "case_drop" and 1 or 0)})
    if #oilLog > 10000 then oilLog[#oilLog] = nil end
    saveOilStats()
    oilSessionData.money = oilSessionData.money + money
    oilSessionData.az = oilSessionData.az + az
end
function resetOilSession()
    oilSessionData.money = 0
    oilSessionData.az = 0
end
function loadOilStats()
    local f = io.open(oilStatsPath, "r")
    if not f then return end
    local content = f:read("*all")
    f:close()
    local data = decodeJson(content)
    if data then oilLog = data end
end
function saveTaxiStats()
    local ok, err = pcall(function()
        local file = io.open(taxiStatsPath, "w")
        if not file then return end
        file:write(encodeJson(taxiLog))
        file:close()
    end)
    if not ok then
        print("ResHelper: error saving taxi_stats.json - " .. tostring(err))
    end
end
function addTaxiLog(money)
    table.insert(taxiLog, 1, {time = os.time(), money = money})
    if #taxiLog > 10000 then taxiLog[#taxiLog] = nil end
    saveTaxiStats()
end
function loadTaxiStats()
    local f = io.open(taxiStatsPath, "r")
    if not f then return end
    local content = f:read("*all")
    f:close()
    local data = decodeJson(content)
    if data then taxiLog = data end
end
function saveIncassStats()
    local ok, err = pcall(function()
        local file = io.open(incassStatsPath, "w")
        if not file then return end
        file:write(encodeJson(incassLog))
        file:close()
    end)
    if not ok then
        print("ResHelper: Ошибка сохранения incass_stats.json - " .. tostring(err))
    end
end
function addIncassLog(money)
    table.insert(incassLog, 1, {time = os.time(), money = money})
    if #incassLog > 10000 then incassLog[#incassLog] = nil end
    saveIncassStats()
end
function loadIncassStats()
    local f = io.open(incassStatsPath, "r")
    if not f then return end
    local content = f:read("*all")
    f:close()
    local data = decodeJson(content)
    if data then incassLog = data end
end
function saveStockStats()
    local ok, err = pcall(function()
        local file = io.open(stockStatsPath, "w")
        if not file then return end
        file:write(encodeJson(stockLog))
        file:close()
    end)
    if not ok then
        print("ResHelper: Ошибка сохранения stock_stats.json - " .. tostring(err))
    end
end
function loadStockStats()
    local f = io.open(stockStatsPath, "r")
    if not f then return end
    local content = f:read("*all")
    f:close()
    local data = decodeJson(content)
    if data then stockLog = data end
end
function getStockPrice(itemId)
    local gp = globalPrices
    if not gp then return 0, false end
    local info = STOCKS[itemId]
    local function pick(suffix)
        local v = tonumber(gp["stock_" .. itemId .. suffix])
        if not v and info then v = tonumber(gp["stock_" .. info.ticker .. suffix]) end
        if v and v > 0 then return v end
        return nil
    end
    local p = pick("")
    if p then return p, true end
    local w = pick("_week")
    if w then return w, true end
    return 0, false
end
incassOvCache = nil
function getIncassOverlayStats()
    local c = incassOvCache
    if c and os.clock() - c.t < 1.0 then return c end
    c = {t = os.clock(), payouts = 0, money = 0, stocks = 0, stockIncome = 0, anyAvg = false, total = 0}
    local today = getGameDate()
    for _, log in ipairs(incassLog) do
        if getGameDate(log.time) ~= today then break end
        c.payouts = c.payouts + 1
        c.money = c.money + (log.money or 0)
    end
    local byItem = {}
    for _, log in ipairs(stockLog) do
        if getGameDate(log.time) ~= today then break end
        byItem[log.itemId] = (byItem[log.itemId] or 0) + (log.amount or 0)
        c.stocks = c.stocks + (log.amount or 0)
    end
    for id, amt in pairs(byItem) do
        local price, isAvg = getStockPrice(id)
        c.stockIncome = c.stockIncome + amt * price
        if isAvg and price > 0 then c.anyAvg = true end
    end
    c.total = c.money + c.stockIncome
    incassOvCache = c
    return c
end
incassHintTime = 0
function incassHintOnce()
    if os.time() - incassHintTime < 120 then return end
    incassHintTime = os.time()
    sampAddChatMessage(SCRIPT_PREFIX .. "Учёт инкассатора не начат. Откройте в меню скрипта раздел {E5911A}Инкассатор", SCRIPT_COLOR)
end
oilHintTime = 0
function oilHintOnce()
    if os.time() - oilHintTime < 120 then return end
    oilHintTime = os.time()
    sampAddChatMessage(SCRIPT_PREFIX .. "Учёт нефтевышек не начат. Откройте в меню скрипта раздел {E5911A}Нефтевышки", SCRIPT_COLOR)
end
incassSumCache = nil
function getIncassSummary()
    local c = incassSumCache
    if c and os.clock() - c.t < 1.0 then return c end
    c = {t = os.clock(), missing = false, anyPriced = false}
    c.today = {money = 0, payouts = 0, stocks = 0, stockIncome = 0, total = 0}
    c.week = {money = 0, payouts = 0, stocks = 0, stockIncome = 0, total = 0}
    c.all = {money = 0, payouts = 0, stocks = 0, stockIncome = 0, total = 0}
    local function addTo(b, money, payouts, stocks, income)
        b.money = b.money + money; b.payouts = b.payouts + payouts
        b.stocks = b.stocks + stocks; b.stockIncome = b.stockIncome + income
    end
    local priceCache = {}
    local function priceOf(id)
        local p = priceCache[id]
        if p == nil then p = getStockPrice(id); priceCache[id] = p end
        return p
    end
    local today = getGameDate()
    local weekAgo = os.time() - 7 * 86400
    local todayDone = false
    for _, log in ipairs(incassLog) do
        local m = log.money or 0
        addTo(c.all, m, 1, 0, 0)
        if (log.time or 0) >= weekAgo then addTo(c.week, m, 1, 0, 0) end
        if not todayDone then
            if getGameDate(log.time) == today then addTo(c.today, m, 1, 0, 0) else todayDone = true end
        end
    end
    todayDone = false
    for _, log in ipairs(stockLog) do
        local a = log.amount or 0
        local price = priceOf(log.itemId)
        if price > 0 then c.anyPriced = true else c.missing = true end
        local inc = a * price
        addTo(c.all, 0, 0, a, inc)
        if (log.time or 0) >= weekAgo then addTo(c.week, 0, 0, a, inc) end
        if not todayDone then
            if getGameDate(log.time) == today then addTo(c.today, 0, 0, a, inc) else todayDone = true end
        end
    end
    for _, b in ipairs({c.today, c.week, c.all}) do b.total = b.money + b.stockIncome end
    incassSumCache = c
    return c
end
function addStockLog(itemId, amount)
    if not STOCKS[itemId] or not amount or amount <= 0 then return end
    table.insert(stockLog, 1, {time = os.time(), itemId = itemId, amount = amount})
    if #stockLog > 10000 then stockLog[#stockLog] = nil end
    saveStockStats()
    if settings.chatNotifyEnabled then
        sampAddChatMessage(SCRIPT_PREFIX .. "Акции: " .. STOCKS[itemId].name .. " x" .. amount, SCRIPT_COLOR)
    end
end
function getStockIdByName(name)
    if not name or not name:find("Акци", 1, true) then return nil end
    for _, sid in ipairs(STOCK_ORDER) do
        if name:find("(" .. STOCKS[sid].ticker .. ")", 1, true) then return sid end
    end
    return nil
end
function saveOilConfig()
    local ok, err = pcall(function()
        local file = io.open(oilConfigPath, "w")
        if not file then return end
        file:write(encodeJson(oilConfig))
        file:close()
    end)
    if not ok then
        print("ResHelper: Ошибка сохранения oil_config.json - " .. tostring(err))
    end
end
function loadOilConfig()
    local f = io.open(oilConfigPath, "r")
    if not f then return end
    local content = f:read("*all")
    f:close()
    local data = decodeJson(content)
    if data then
        for k, v in pairs(data) do
            oilConfig[k] = v
        end
    end
end
function saveCaseConfig()
    local ok, err = pcall(function()
        local file = io.open(caseConfigPath, "w")
        if not file then return end
        local saveData = {}
        for itemId, caseData in pairs(caseConfig) do
            saveData[tostring(itemId)] = {
                name = caseData.name,
                cost = caseData.cost,
                count = caseData.count,
            }
        end
        file:write(encodeJson(saveData))
        file:close()
    end)
    if not ok then
        print("ResHelper: Ошибка сохранения case_config.json - " .. tostring(err))
    end
end
function loadCaseConfig()
    local f = io.open(caseConfigPath, "r")
    if not f then return end
    local content = f:read("*all")
    f:close()
    local data = decodeJson(content)
    if data then
        for itemId, caseData in pairs(data) do
            local id = tonumber(itemId)
            if id then
                caseConfig[id] = {
                    name = caseData.name or ALL_CASES[id] or "Неизвестный кейс",
                    cost = caseData.cost or 0,
                    count = caseData.count or 0,
                }
            end
        end
    end
end
function saveLbRowsLimit()
    local file = io.open(configDir .. "lb_rows_limit.json", "w")
    if file then file:write(encodeJson({limit = lbRowsLimit})); file:close() end
end
function loadLbRowsLimit()
    local file = io.open(configDir .. "lb_rows_limit.json", "r")
    if not file then return end
    local data = decodeJson(file:read("*all"))
    file:close()
    if data and data.limit then lbRowsLimit = data.limit end
end
function getTotalItemMarketIncome()
    local total = 0
    for _, log in ipairs(itemMarketLog) do
        total = total + log.amount
    end
    return total
end
-- ====== СОХРАНЕНИЕ/ЗАГРУЗКА ======
function saveStats()
    if not config then return end
    local path
    local usingCustom = (currentWork == WORK_TYPES.FARM and useCustomFarmPrices) or (currentWork == WORK_TYPES.MINE and useCustomMinePrices) or (currentWork == WORK_TYPES.SAWMILL and useCustomSawmillPrices)
    if usingCustom then
        path = getServerStatsPathCustom(currentWork)
    else
        path = getServerStatsPath(currentWork)
    end
    local file = io.open(path, "w")
    if not file then return end
    file:write("{\n  \"logs\": [\n")
    for i, log in ipairs(resourceLog) do
        file:write('    {"time":' .. log.time .. ',"resource":"' .. log.resource .. '","amount":' .. log.amount .. ',"value":' .. log.value .. '}')
        if i < #resourceLog then file:write(',\n') else file:write('\n') end
    end
    file:write('  ]\n}')
    file:close()
end
function loadStats()
    if not config then loadedLogs = true; return end
    
    local path
    if (currentWork == WORK_TYPES.FARM and useCustomFarmPrices) or (currentWork == WORK_TYPES.MINE and useCustomMinePrices) or (currentWork == WORK_TYPES.SAWMILL and useCustomSawmillPrices) then
        path = getServerStatsPathCustom(currentWork)
    else
        path = getServerStatsPath(currentWork)
    end
    
    if loadedLogs then return end
    
    local file = io.open(path, "r")
    if not file then loadedLogs = true; return end
    local content = file:read("*all")
    file:close()
    
    resourceLog = {}
    for time, resource, amount, value in content:gmatch('"time":(%d+),"resource":"([^"]+)","amount":(%d+),"value":(%d+)') do
        table.insert(resourceLog, {time = tonumber(time), resource = resource, amount = tonumber(amount), value = tonumber(value)})
    end
    loadedLogs = true
end
function saveGoals(workType)
    if not config then return end
    local cfg = configs[workType or currentWork]
    local path
    if workType == WORK_TYPES.FARM then
        path = farmGoalsConfigPath
    elseif workType == WORK_TYPES.MINE then
        path = mineGoalsConfigPath
    elseif workType == WORK_TYPES.SAWMILL then
        path = sawmillGoalsConfigPath
    else
        path = (currentWork == WORK_TYPES.FARM) and farmGoalsConfigPath or (currentWork == WORK_TYPES.MINE) and mineGoalsConfigPath or sawmillGoalsConfigPath
    end
    
    local data = {}
    for _, k in ipairs(cfg.resourceOrder) do
        data[k] = goalEdit[k] and goalEdit[k].v or cfg.defaultGoals[k]
    end
    
    local file = io.open(path, "w")
    if file then
        file:write(encodeJson(data))
        file:close()
    end
end
function loadGoals()
    if not config then return end
    local path
    if currentWork == WORK_TYPES.FARM then
        path = farmGoalsConfigPath
    elseif currentWork == WORK_TYPES.MINE then
        path = mineGoalsConfigPath
    else
        path = sawmillGoalsConfigPath
    end
    local cfg = config
    local file = io.open(path, "r")
    if not file then
        for _, k in ipairs(cfg.resourceOrder) do goals[k] = cfg.defaultGoals[k] end
        saveGoals()
        for _, k in ipairs(cfg.resourceOrder) do if goalEdit[k] then goalEdit[k].v = goals[k] end end
        return
    end
    local content = file:read("*all")
    file:close()
    local data = decodeJson(content)
    if not data then
        for _, k in ipairs(cfg.resourceOrder) do goals[k] = cfg.defaultGoals[k] end
    else
        for _, k in ipairs(cfg.resourceOrder) do
            goals[k] = data[k] or cfg.defaultGoals[k]
            if goalEdit[k] then goalEdit[k].v = goals[k] end
        end
    end
end
-- ====== СОХРАНЕНИЕ/ЗАГРУЗКА ПРОГРЕССА ЦЕЛЕЙ ======
function saveGoalsProgress()
    if not config then return end
    local path
	local path = getServerGoalsProgressPath(currentWork)
    local data = {}
    for _, k in ipairs(config.resourceOrder) do
        data[k] = {
            reached = goalsReached[k] or false,
            amount = dailyResources[k] or 0
        }
    end
    data.dailyTotal = dailyTotal or 0
    local file = io.open(path, "w")
    if file then
        file:write(encodeJson(data))
        file:close()
    end
end
function loadGoalsProgress()
    if not config then return end
    local path
	local path = getServerGoalsProgressPath(currentWork)
    local file = io.open(path, "r")
    if not file then return end
    local content = file:read("*all")
    file:close()
    local data = decodeJson(content)
    if not data then return end
    for _, k in ipairs(config.resourceOrder) do
        if data[k] then
            goalsReached[k] = data[k].reached or false
            dailyResources[k] = data[k].amount or 0
        end
    end
    dailyTotal = data.dailyTotal or 0
end
function checkChangelog()
    local shownVersion = ""
    if doesFileExist(changelogPath) then
        local f = io.open(changelogPath, "r")
        if f then
            shownVersion = f:read("*line") or ""
            f:close()
        end
    end
    if shownVersion ~= scr.version then
        changelogShown = false
    else
        changelogShown = true
    end
end
function markChangelogAsShown()
    local f = io.open(changelogPath, "w")
    if f then
        f:write(scr.version)
        f:close()
    end
    changelogShown = true
end
local changelogMessageShown = false  
function downloadChangelog()
    changelogMessageShown = false
    
    local asyncReq = effil.thread(function(u)
        local req = require("requests")
        local ok, result = pcall(req.get, u)
        if ok and result then
            return result.text
        end
        return nil
    end)("https://raw.githubusercontent.com/Ryder8471/ArzResHelper/refs/heads/main/changelog.json")
    
    lua_thread.create(function()
        local startTime = os.time()
        while true do
            local status = asyncReq:status()
            if status == "completed" then
                local text = asyncReq:get()
                if text then
                    local converted = encoding.UTF8:decode(text)
                    changelogData = decodeJson(converted)
                    if changelogData then
                        if not changelogMessageShown then
                            changelogMessageShown = true
                            sampAddChatMessage(SCRIPT_PREFIX .. "Список изменений успешно загружен!", SCRIPT_COLOR)
                        end
                    end
                end
                return
            elseif status == "canceled" or (os.time() - startTime > 10) then
                return
            end
            wait(0)
        end
    end)
end
-- ====== База предметов (:itemN:) ======
local itemsDBPath = dirml .. "/ResHelper/files/items_db.json"
itemsDB = {}      
itemsDBList = {}  
itemsDBLoading = false
itemPickerSearchBuf = imgui.ImBuffer(64)
itemPickerTargetAd = nil
itemPickerOpen = false
itemPickerAnchor = imgui.ImVec2(0, 0)
local cp1251LowerMap = {}
for b = 0xC0, 0xDF do cp1251LowerMap[string.char(b)] = string.char(b + 0x20) end
cp1251LowerMap[string.char(0xA8)] = string.char(0xB8)
for b = 0x41, 0x5A do cp1251LowerMap[string.char(b)] = string.char(b + 0x20) end
function cp1251Lower(str)
    return (str:gsub("[\65-\90\168\192-\223]", cp1251LowerMap))
end
function rebuildItemsDBList(yieldEvery)
    local list, cnt = {}, 0
    for id, name in pairs(itemsDB) do
        cnt = cnt + 1
        list[cnt] = { id = id, n = tonumber(id) or 0, name = name, nameLower = cp1251Lower(name) }
        if yieldEvery and cnt % yieldEvery == 0 then wait(0) end
    end
    table.sort(list, function(a, b) return a.n < b.n end)
    itemsDBList = list
end
function loadItemsDBFromDisk()
    local f = io.open(itemsDBPath, "r")
    if f then
        local content = f:read("*a")
        f:close()
        local ok, data = pcall(decodeJson, content)
        if ok and data then
            itemsDB = data
            rebuildItemsDBList()
            return true
        end
    end
    return false
end
function saveItemsDBToDisk()
    local dir = dirml .. "/ResHelper/files"
    if not doesDirectoryExist(dir) then
        createDirectory(dir)
    end
    local f = io.open(itemsDBPath, "w")
    if f then
        f:write(encodeJson(itemsDB))
        f:close()
    end
end
function downloadItemsDB()
    if itemsDBLoading then return end
    itemsDBLoading = true
    local asyncReq = effil.thread(function(u)
        local req = require("requests")
        local ok, result = pcall(req.get, u)
        if ok and result then
            return result.text
        end
        return nil
    end)("https://items.shinoa.tech/items.php")
    lua_thread.create(function()
        local startTime = os.time()
        while true do
            local status = asyncReq:status()
            if status == "completed" then
                local text = asyncReq:get()
                itemsDBLoading = false
                if text then
                    local ok, parsed = pcall(decodeJson, text)
                    if ok and parsed then
                        wait(0)
                        local newDB, newCount = {}, 0
                        for i, item in ipairs(parsed) do
                            if item.id and item.item_name then
                                newDB[tostring(item.id)] = u8:decode(tostring(item.item_name))
                                newCount = newCount + 1
                            end
                            if i % 500 == 0 then wait(0) end
                        end
                        local changed = newCount ~= #itemsDBList
                        if not changed then
                            for id, name in pairs(newDB) do
                                if itemsDB[id] ~= name then changed = true; break end
                            end
                        end
                        if changed then
                            itemsDB = newDB
                            rebuildItemsDBList(1500)
                            wait(0)
                            saveItemsDBToDisk()
                        end
                        scanSummary.itemsDBCount = #itemsDBList
                        sampAddChatMessage(SCRIPT_PREFIX .. "База предметов обновлена (" .. #itemsDBList .. " шт.)", SCRIPT_COLOR)
                    else
                        sampAddChatMessage(SCRIPT_PREFIX .. "Не удалось разобрать базу предметов.", SCRIPT_COLOR)
                    end
                else
                    sampAddChatMessage(SCRIPT_PREFIX .. "Не удалось скачать базу предметов.", SCRIPT_COLOR)
                end
                return
            elseif status == "canceled" or (os.time() - startTime > 15) then
                itemsDBLoading = false
                return
            end
            wait(0)
        end
    end)
end
-- Загружаем кэш с диска при старте, и в фоне обновляем с сервера
loadItemsDBFromDisk()
downloadItemsDB()
seenAnnouncementsPath = configDir .. "seen_announcements.txt"
seenAnnouncements = {}
function loadSeenAnnouncements()
    seenAnnouncements = {}
    local f = io.open(seenAnnouncementsPath, "r")
    if f then
        for line in f:lines() do
            if line ~= "" then seenAnnouncements[line] = true end
        end
        f:close()
    end
end
function markAnnouncementSeen(id)
    seenAnnouncements[id] = true
    local f = io.open(seenAnnouncementsPath, "a")
    if f then f:write(id .. "\n"); f:close() end
end
announcementHistoryPath = configDir .. "announcement_history.json"
function loadAnnouncementHistory()
    announcementHistory = {}
    local f = io.open(announcementHistoryPath, "r")
    if f then
        local content = f:read("*a")
        f:close()
        local data = decodeJson(content)
        if data then announcementHistory = data end
    end
end
function saveAnnouncementHistory()
    local f = io.open(announcementHistoryPath, "w")
    if f then
        f:write(encodeJson(announcementHistory))
        f:close()
    end
end
function addAnnouncementToHistory(item)
    table.insert(announcementHistory, 1, {
        text = item.text,
        important = item.important and true or false,
        time = os.time(),
        read = false
    })
    if #announcementHistory > 50 then
        table.remove(announcementHistory, #announcementHistory)
    end
    saveAnnouncementHistory()
end
function getUnreadAnnouncementCount()
    local count = 0
    for _, item in ipairs(announcementHistory) do
        if not item.read then count = count + 1 end
    end
    return count
end
function markAllAnnouncementsRead()
    local changed = false
    for _, item in ipairs(announcementHistory) do
        if not item.read then item.read = true; changed = true end
    end
    if changed then saveAnnouncementHistory() end
end
announcementsRequestActive = false
function downloadAnnouncements()
    if announcementsRequestActive then return end
    local created, asyncReq = pcall(function()
        return effil.thread(function(u)
            local req = require("requests")
            local ok, result = pcall(req.get, u)
            if ok and result then return result.text end
            return nil
        end)("https://raw.githubusercontent.com/Ryder8471/ArzResHelper/refs/heads/main/announcements.json")
    end)
    if not created or not asyncReq then
        print("ResHelper: downloadAnnouncements thread error: " .. tostring(asyncReq))
        return
    end
    announcementsRequestActive = true
    lua_thread.create(function()
        local startTime = os.time()
        while true do
            local okStatus, status = pcall(function() return asyncReq:status() end)
            if not okStatus then announcementsRequestActive = false; return end
            if status == "completed" then
                local okProc, errProc = pcall(function()
                    local text = asyncReq:get()
                    if text then
                        local converted = encoding.UTF8:decode(text)
                        local data = decodeJson(converted)
                        if data then
                            for _, item in ipairs(data) do
                                if item.id and not seenAnnouncements[item.id] then
                                    markAnnouncementSeen(item.id)
                                    addAnnouncementToHistory(item)
                                    if settings.devNotifPopupEnabled ~= false then
                                        if item.important then
                                            table.insert(devImportantQueue, item)
                                        else
                                            table.insert(devNotifications, {time = os.time(), text = item.text})
                                        end
                                    end
                                end
                            end
                        end
                    end
                end)
                if not okProc then print("ResHelper: announcements parse error: " .. tostring(errProc)) end
                announcementsRequestActive = false
                return
            elseif status == "canceled" or status == "failed" or (os.time() - startTime > 10) then
                pcall(function() asyncReq:cancel() end)
                announcementsRequestActive = false
                return
            end
            wait(0)
        end
    end)
end
-- ====== СБРОС ЦЕЛЕЙ ======
function checkAndResetDaily()
    local mskTime = getMoscowTime()
local gameDate = getGameDate()
local mskHour = tonumber(os.date("%H", mskTime))
    
    local resetFile = configDir .. "last_reset_date.txt"
    local savedDate = ""
    if doesFileExist(resetFile) then
        local f = io.open(resetFile, "r")
        if f then
            savedDate = f:read("*line") or ""
            f:close()
        end
    end
    
    -- Сбрасываем только если игровая дата изменилась и время >= 05:00 МСК
    if savedDate ~= gameDate and mskHour >= 5 then
	 processedGoalAchievements = {}
        local f = io.open(resetFile, "w")
        if f then
            f:write(gameDate)
            f:close()
        end
        
        -- Сбрасываем цели для ВСЕХ типов работ
        -- Ферма
        local farmProgressPath = getServerGoalsProgressPath(WORK_TYPES.FARM)
        local farmData = {}
        for _, k in ipairs(configs[WORK_TYPES.FARM].resourceOrder) do
            farmData[k] = {reached = false, amount = 0}
        end
        farmData.dailyTotal = 0
        local farmFile = io.open(farmProgressPath, "w")
        if farmFile then
            farmFile:write(encodeJson(farmData))
            farmFile:close()
        end
        
        -- Шахта
        local mineProgressPath = getServerGoalsProgressPath(WORK_TYPES.MINE)
        local mineData = {}
        for _, k in ipairs(configs[WORK_TYPES.MINE].resourceOrder) do
            mineData[k] = {reached = false, amount = 0}
        end
        mineData.dailyTotal = 0
        local mineFile = io.open(mineProgressPath, "w")
        if mineFile then
            mineFile:write(encodeJson(mineData))
            mineFile:close()
        end
        
        -- Лесопилка
        local sawmillProgressPath = getServerGoalsProgressPath(WORK_TYPES.SAWMILL)
        local sawmillData = {}
        for _, k in ipairs(configs[WORK_TYPES.SAWMILL].resourceOrder) do
            sawmillData[k] = {reached = false, amount = 0}
        end
        sawmillData.dailyTotal = 0
        local sawmillFile = io.open(sawmillProgressPath, "w")
        if sawmillFile then
            sawmillFile:write(encodeJson(sawmillData))
            sawmillFile:close()
        end
        
        -- Сбрасываем текущие значения в памяти для текущего типа работы
        if config then
            for _, k in ipairs(config.resourceOrder) do
                goalsReached[k] = false
                sessionResources[k] = 0
                dailyResources[k] = 0
            end
        end
        sessionTotal = 0
        dailyTotal = 0
        sessionStartTime = os.time()
        gameSessionStartTime = os.time()
        sessionAccumulatedSec = 0
        saveSessionState()
        
        -- Сбрасываем общую цель дохода
        totalIncomeGoalReached = false
        totalDailyIncome = 0
        totalIncomeCacheTime = 0
        saveTotalIncomeGoal()
        
        -- Сбрасываем кэш статистики
        cachedTodayStats = nil
        cachedTodayTime = 0
        cachedWeekStats = nil
        cachedWeekTime = 0
        
		itemMarketTodayIncome = 0
        cachedIMWeekTime = 0
		
        saveGoalsProgress()
        sampAddChatMessage(SCRIPT_PREFIX .. "Новый день! Статистика и цели всех работ сброшены. (05:00 МСК)", SCRIPT_COLOR)
    end
    
    -- Если файла нет, создаем его с текущей игровой датой
    if not doesFileExist(resetFile) then
        local f = io.open(resetFile, "w")
        if f then
            f:write(gameDate)
            f:close()
        end
    end
end
function saveConfig()
    local file = io.open(configPath, "w")
    if not file then return end
    file:write("[Settings]\n")
    file:write("chatNotifyEnabled=" .. (settings.chatNotifyEnabled and "1" or "0") .. "\n")
    file:write("devNotifPopupEnabled=" .. (settings.devNotifPopupEnabled and "1" or "0") .. "\n")
    file:write("goalSoundEnabled=" .. (settings.goalSoundEnabled and "1" or "0") .. "\n")
    file:write("pickupSoundEnabled=" .. (settings.pickupSoundEnabled and "1" or "0") .. "\n")
    file:write("goalSoundVolume=" .. settings.goalSoundVolume .. "\n")
    file:write("pickupSoundVolume=" .. settings.pickupSoundVolume .. "\n")
    file:write("farmOverlayEnabled=" .. (settings.farmOverlayEnabled and "1" or "0") .. "\n")
    file:write("mineOverlayEnabled=" .. (settings.mineOverlayEnabled and "1" or "0") .. "\n")
    file:write("farmEnabled=" .. (settings.farmEnabled and "1" or "0") .. "\n")
    file:write("undermineEnabled=" .. (settings.undermineEnabled and "1" or "0") .. "\n")
    file:write("underminelavkaEnabled=" .. (settings.underminelavkaEnabled and "1" or "0") .. "\n")
    file:write("regularmineEnabled=" .. (settings.regularmineEnabled and "1" or "0") .. "\n")
	file:write("overlayTimerEnabled=" .. (settings.overlayTimerEnabled and "1" or "0") .. "\n")
	file:write("totalIncomeGoal=" .. settings.totalIncomeGoal .. "\n")
	file:write("sawmillOverlayEnabled=" .. (settings.sawmillOverlayEnabled and "1" or "0") .. "\n")
	file:write("oilOverlayEnabled=" .. (settings.oilOverlayEnabled and "1" or "0") .. "\n")
	file:write("taxiOverlayEnabled=" .. (settings.taxiOverlayEnabled and "1" or "0") .. "\n")
	file:write("incassOverlayEnabled=" .. (settings.incassOverlayEnabled and "1" or "0") .. "\n")
	file:write("taxiEnabled=" .. (settings.taxiEnabled and "1" or "0") .. "\n")
	file:write("incassEnabled=" .. (settings.incassEnabled and "1" or "0") .. "\n")
	file:write("oilEnabled=" .. (settings.oilEnabled and "1" or "0") .. "\n")
    file:write("sawmillEnabled=" .. (settings.sawmillEnabled and "1" or "0") .. "\n")
	file:write("useCustomTheme=" .. (useCustomTheme and "1" or "0") .. "\n")
	file:write("pickupSoundFile=" .. (settings.pickupSoundFile or "pickup.wav") .. "\n")
	file:write("rareSoundFile=" .. (settings.rareSoundFile or "rare.wav") .. "\n")
	file:write("coalSoundFile=" .. (settings.coalSoundFile or "ugol.wav") .. "\n")
	file:write("achivSoundFile=" .. (settings.achivSoundFile or "achiv.wav") .. "\n")
	file:write("rareSoundVolume=" .. (settings.rareSoundVolume or 80) .. "\n")
	file:write("coalSoundVolume=" .. (settings.coalSoundVolume or 80) .. "\n")
	file:write("mineSpawnTimerEnabled=" .. (settings.mineSpawnTimerEnabled and "1" or "0") .. "\n")
	file:write("overlayColumns=" .. (settings.overlayColumns or 2) .. "\n")
	file:write("overlayStyle=" .. (settings.overlayStyle or 1) .. "\n")
	file:write("talonAutoScanEnabled=" .. (settings.talonAutoScanEnabled and "1" or "0") .. "\n")
	file:write("cryptoAutoScanEnabled=" .. (settings.cryptoAutoScanEnabled and "1" or "0") .. "\n")
	file:write("notifyOnlyImportant=" .. (settings.notifyOnlyImportant and "1" or "0") .. "\n")
	file:write("notifyHideStartup=" .. (settings.notifyHideStartup and "1" or "0") .. "\n")
	file:write("cryptoPricesLastFetch=" .. (settings.cryptoPricesLastFetch or 0) .. "\n")
	file:write("overlayHideOnHover=" .. (settings.overlayHideOnHover and "1" or "0") .. "\n")
	file:write("overlayAutoTimer=" .. (settings.overlayAutoTimer and "1" or "0") .. "\n")
	file:write("smoothMenuEnabled=" .. (settings.smoothMenuEnabled and "1" or "0") .. "\n")
	file:write("smoothWindowEnabled=" .. (settings.smoothWindowEnabled and "1" or "0") .. "\n")
	file:write("homeShowLogo=" .. (settings.homeShowLogo and "1" or "0") .. "\n")
	file:write("homeShowSummary=" .. ((settings.homeShowSummary ~= false) and "1" or "0") .. "\n")
	file:write("homeShowTiles=" .. ((settings.homeShowTiles ~= false) and "1" or "0") .. "\n")
	file:write("homeShowGoals=" .. ((settings.homeShowGoals ~= false) and "1" or "0") .. "\n")
	file:write("homeShowWork=" .. ((settings.homeShowWork ~= false) and "1" or "0") .. "\n")
	file:write("homeShowHotkey=" .. ((settings.homeShowHotkey ~= false) and "1" or "0") .. "\n")
	file:write("menuKey=" .. table.concat(settings.menuKey, ",") .. "\n")
    do
        local hiddenList = {}
        for k, v in pairs(settings.hiddenHomeTiles or {}) do
            if v then table.insert(hiddenList, k) end
        end
        file:write("hiddenHomeTiles=" .. table.concat(hiddenList, ",") .. "\n")
    end
    file:close()
end
function loadConfig()
    local file = io.open(configPath, "r")
    if not file then
        if config then
            for k, v in pairs(config.defaultPrices) do resourcePrices[k] = v; if not priceEdit[k] then priceEdit[k] = imgui.ImInt(v) else priceEdit[k].v = v end end
        end
        saveConfig()
        return
    end
    local section = ""
    for line in file:lines() do
        local sec = line:match("^%[(.*)%]$")
        if sec then section = sec
        else
            local k, v = line:match("^(.-)=(.*)$")
            if k and v then
                if section == "Settings" then
                    if k == "chatNotifyEnabled" then settings.chatNotifyEnabled = (v == "1")
                    elseif k == "devNotifPopupEnabled" then settings.devNotifPopupEnabled = (v == "1")
                    elseif k == "goalSoundEnabled" then settings.goalSoundEnabled = (v == "1")
                    elseif k == "pickupSoundEnabled" then settings.pickupSoundEnabled = (v == "1")
                    elseif k == "goalSoundVolume" then settings.goalSoundVolume = tonumber(v) or 80
                    elseif k == "pickupSoundVolume" then settings.pickupSoundVolume = tonumber(v) or 80
                    elseif k == "farmOverlayEnabled" then settings.farmOverlayEnabled = (v == "1")
                    elseif k == "mineOverlayEnabled" then settings.mineOverlayEnabled = (v == "1")
                    elseif k == "farmEnabled" then settings.farmEnabled = (v == "1")
                    elseif k == "pickupSoundFile" then settings.pickupSoundFile = v or "pickup.wav"
                    elseif k == "rareSoundFile" then settings.rareSoundFile = v or "rare.wav"
                    elseif k == "coalSoundFile" then settings.coalSoundFile = v or "ugol.wav"
                    elseif k == "achivSoundFile" then settings.achivSoundFile = v or "achiv.wav"
                    elseif k == "rareSoundVolume" then settings.rareSoundVolume = tonumber(v) or 80
                    elseif k == "coalSoundVolume" then settings.coalSoundVolume = tonumber(v) or 80
                    elseif k == "undermineEnabled" then settings.undermineEnabled = (v == "1")
                    elseif k == "underminelavkaEnabled" then settings.underminelavkaEnabled = (v == "1")
                    elseif k == "regularmineEnabled" then settings.regularmineEnabled = (v == "1") 
                    elseif k == "overlayTimerEnabled" then settings.overlayTimerEnabled = (v == "1") 
                    elseif k == "totalIncomeGoal" then settings.totalIncomeGoal = tonumber(v) or 1000000 
                    elseif k == "sawmillOverlayEnabled" then settings.sawmillOverlayEnabled = (v == "1")
                    elseif k == "oilOverlayEnabled" then settings.oilOverlayEnabled = (v == "1")
                    elseif k == "taxiOverlayEnabled" then settings.taxiOverlayEnabled = (v == "1")
                    elseif k == "incassOverlayEnabled" then settings.incassOverlayEnabled = (v == "1")
                    elseif k == "taxiEnabled" then settings.taxiEnabled = (v == "1")
                    elseif k == "incassEnabled" then settings.incassEnabled = (v == "1")
                    elseif k == "oilEnabled" then settings.oilEnabled = (v == "1")
                    elseif k == "sawmillEnabled" then settings.sawmillEnabled = (v == "1") 
                    elseif k == "mineSpawnTimerEnabled" then settings.mineSpawnTimerEnabled = (v == "1")
                    elseif k == "overlayStyle" then settings.overlayStyle = tonumber(v) or 1
					elseif k == "talonAutoScanEnabled" then settings.talonAutoScanEnabled = (v == "1")
					elseif k == "cryptoAutoScanEnabled" then settings.cryptoAutoScanEnabled = (v == "1")
					elseif k == "notifyOnlyImportant" then settings.notifyOnlyImportant = (v == "1")
					elseif k == "notifyHideStartup" then settings.notifyHideStartup = (v == "1")
                    elseif k == "cryptoPricesLastFetch" then settings.cryptoPricesLastFetch = tonumber(v) or 0
                    elseif k == "overlayHideOnHover" then settings.overlayHideOnHover = (v == "1")
					elseif k == "overlayAutoTimer" then settings.overlayAutoTimer = (v == "1")
					elseif k == "smoothMenuEnabled" then settings.smoothMenuEnabled = (v == "1")
					elseif k == "smoothWindowEnabled" then settings.smoothWindowEnabled = (v == "1")
					elseif k == "homeShowLogo" then settings.homeShowLogo = (v == "1")
					elseif k == "homeShowSummary" then settings.homeShowSummary = (v == "1")
					elseif k == "homeShowTiles" then settings.homeShowTiles = (v == "1")
					elseif k == "homeShowGoals" then settings.homeShowGoals = (v == "1")
					elseif k == "homeShowWork" then settings.homeShowWork = (v == "1")
					elseif k == "homeShowHotkey" then settings.homeShowHotkey = (v == "1")
					                    elseif k == "menuKey" then
                        local keys = {}
                        for key in v:gmatch("([^,]+)") do
                            table.insert(keys, tonumber(key))
                        end
                        if #keys > 0 then settings.menuKey = keys end
                    elseif k == "overlayColumns" then settings.overlayColumns = tonumber(v) or 2
                    elseif k == "hiddenHomeTiles" then
                        settings.hiddenHomeTiles = {}
                        for key in v:gmatch("[^,]+") do settings.hiddenHomeTiles[key] = true end
                    elseif k == "useCustomTheme" then useCustomTheme = (v == "1") end
                end
            end
        end
    end
    file:close()
    if currentWork and configs[currentWork] then
        switchWorkType(currentWork, true)
    end
end
-- ====== НОВАЯ СИСТЕМА ЦЕН ======
function savePrices()
    if currentWork == WORK_TYPES.FARM then
        local file = io.open(farmPricesPath, "w")
        if file then
            for _, k in ipairs(configs[WORK_TYPES.FARM].resourceOrder) do
                file:write(k .. "=" .. (resourcePrices[k] or configs[WORK_TYPES.FARM].defaultPrices[k]) .. "\n")
            end
            file:close()
        end
    elseif currentWork == WORK_TYPES.MINE then
        local file = io.open(minePricesPath, "w")
        if file then
            for _, k in ipairs(configs[WORK_TYPES.MINE].resourceOrder) do
                file:write(k .. "=" .. (resourcePrices[k] or configs[WORK_TYPES.MINE].defaultPrices[k]) .. "\n")
            end
            file:close()
        end
    else
        local file = io.open(sawmillPricesPath, "w")
        if file then
            for _, k in ipairs(configs[WORK_TYPES.SAWMILL].resourceOrder) do
                file:write(k .. "=" .. (resourcePrices[k] or configs[WORK_TYPES.SAWMILL].defaultPrices[k]) .. "\n")
            end
            file:close()
        end
    end
end
function loadConfigForCurrentWork()
    resourcePrices = {}
    for _, k in ipairs(config.resourceOrder) do
        resourcePrices[k] = config.defaultPrices[k]
    end
    local priceFile
    if currentWork == WORK_TYPES.FARM then priceFile = farmPricesPath
    elseif currentWork == WORK_TYPES.MINE then priceFile = minePricesPath
    else priceFile = sawmillPricesPath end
    local file = io.open(priceFile, "r")
    if not file then 
        for k, v in pairs(resourcePrices) do
            if priceEdit[k] then priceEdit[k].v = v end
        end
        return 
    end
    for line in file:lines() do
        local k, v = line:match("^(.-)=(.*)$")
        if k and v then
            local numValue = tonumber(v)
            if numValue and resourcePrices[k] ~= nil then
                resourcePrices[k] = numValue
            end
        end
    end
    file:close()
    for k, v in pairs(resourcePrices) do
        if priceEdit[k] then priceEdit[k].v = v end
    end
end
function initPricesFile()
    if not doesFileExist(farmPricesPath) then
        local file = io.open(farmPricesPath, "w")
        if file then
            for _, k in ipairs(configs[WORK_TYPES.FARM].resourceOrder) do
                file:write(k .. "=" .. configs[WORK_TYPES.FARM].defaultPrices[k] .. "\n")
            end
            file:close()
        end
    end
    if not doesFileExist(minePricesPath) then
        local file = io.open(minePricesPath, "w")
        if file then
            for _, k in ipairs(configs[WORK_TYPES.MINE].resourceOrder) do
                file:write(k .. "=" .. configs[WORK_TYPES.MINE].defaultPrices[k] .. "\n")
            end
            file:close()
        end
    end
    if not doesFileExist(sawmillPricesPath) then
        local file = io.open(sawmillPricesPath, "w")
        if file then
            for _, k in ipairs(configs[WORK_TYPES.SAWMILL].resourceOrder) do
                file:write(k .. "=" .. configs[WORK_TYPES.SAWMILL].defaultPrices[k] .. "\n")
            end
            file:close()
        end
    end
end
function initGoalsFiles()
    if not doesFileExist(farmGoalsConfigPath) then
        local file = io.open(farmGoalsConfigPath, "w")
        if file then
            local data = {}
            for _, k in ipairs(configs[WORK_TYPES.FARM].resourceOrder) do
                data[k] = configs[WORK_TYPES.FARM].defaultGoals[k]
            end
            file:write(encodeJson(data))
            file:close()
        end
    end
    if not doesFileExist(mineGoalsConfigPath) then
        local file = io.open(mineGoalsConfigPath, "w")
        if file then
            local data = {}
            for _, k in ipairs(configs[WORK_TYPES.MINE].resourceOrder) do
                data[k] = configs[WORK_TYPES.MINE].defaultGoals[k]
            end
            file:write(encodeJson(data))
            file:close()
        end
    end
    if not doesFileExist(sawmillGoalsConfigPath) then
        local file = io.open(sawmillGoalsConfigPath, "w")
        if file then
            local data = {}
            for _, k in ipairs(configs[WORK_TYPES.SAWMILL].resourceOrder) do
                data[k] = configs[WORK_TYPES.SAWMILL].defaultGoals[k]
            end
            file:write(encodeJson(data))
            file:close()
        end
    end
end
function switchWorkType(newWorkType, initialLoad)
if not configs[newWorkType] then return end
incassWorkActive = false
oilWorkActive = false
    -- Блокируем смену режима во время автосканирования
if not initialLoad and scanState.active then
    sampAddChatMessage(SCRIPT_PREFIX .. "Дождитесь завершения сканирования!", SCRIPT_COLOR)
    return
end
    if currentWork == newWorkType and not initialLoad then return end
    if not initialLoad then 
        saveInventoryBase()
        saveStats()
        saveGoalsProgress()
    end
    currentWork = newWorkType
    config = configs[currentWork]
    resources = {}
    resourcePrices = {}
    goals = {}
    goalsReached = {}
    sessionResources = {}
    dailyResources = {}
    sessionTotal = 0
	sessionStartTime = os.time()  
    dailyTotal = 0
    resourceLog = {}
    loadedLogs = false
    inventoryCache = {}
    scanState.active = false
    scanState.scanning = false
    scanState.scanned = false
    inventoryBase = {}
    loadInventoryBase()
    for _, k in ipairs(config.resourceOrder) do
        resources[k] = 0
        resourcePrices[k] = config.defaultPrices[k]
        goals[k] = config.defaultGoals[k]
        goalsReached[k] = false
        sessionResources[k] = 0
        dailyResources[k] = 0
        if not priceEdit[k] then priceEdit[k] = imgui.ImInt(resourcePrices[k]) else priceEdit[k].v = resourcePrices[k] end
        if not goalEdit[k] then goalEdit[k] = imgui.ImInt(goals[k]) else goalEdit[k].v = goals[k] end
    end
	
    loadConfigForCurrentWork()
    
    -- Перезаписываем глобальными ценами, если они уже загружены
    if globalPrices and next(globalPrices) then
        for k, v in pairs(globalPrices) do
            resourcePrices[k] = v
            if priceEdit[k] then priceEdit[k].v = v end
        end
    end
	
    loadGoals()
    loadStats()
    loadGoalsProgress()
	sessionStartTime = os.time()  
	cb_sawmill.v = settings.sawmillEnabled
    cb_farm.v = settings.farmEnabled
    cb_undermine.v = settings.undermineEnabled
    cb_lavka.v = settings.underminelavkaEnabled
    cb_regular.v = settings.regularmineEnabled
    if not initialLoad then 
        sampAddChatMessage("{00FF00}"..config.prefix.." {FFFFFF}Режим работы изменен на: " .. config.name, -1) 
    end
end
-- === ПЕРЕХВАТ ПАКЕТОВ ===
function onReceivePacket(id, bs)
    local ok, err = pcall(function()
        if id == 220 then
            local origPos = raknetBitStreamGetReadOffset(bs)
            raknetBitStreamReadInt8(bs)
            if raknetBitStreamReadInt8(bs) == 17 then
                raknetBitStreamReadInt32(bs)
                local length = raknetBitStreamReadInt16(bs)
                local encoded = raknetBitStreamReadInt8(bs)
                if length > 0 then
                    local text = (encoded ~= 0)
                        and raknetBitStreamDecodeString(bs, length + encoded)
                        or raknetBitStreamReadString(bs, length)
                    if text then pcall(rhNftOnCef, text) end
                    if text and text:find("event.inventory.playerInventory") then
                        -- Пропускаем обработку на 3 секунды после сканирования
                        if os.time() < ignoreInventoryUntil then
                            for itemIdStr, newAmountStr in text:gmatch('"item":(%d+),"amount":(%d+)') do
                                local itemId = tonumber(itemIdStr)
                                local newAmount = tonumber(newAmountStr)
                                if itemId and newAmount and inventoryCache[itemId] then
                                    local slots = inventoryCache[itemId]
                                    local found = false
                                    for i, slotAmount in ipairs(slots) do
                                        if newAmount == slotAmount then 
                                            found = true
                                            break
                                        elseif math.abs(newAmount - slotAmount) <= 10 then 
                                            slots[i] = newAmount
                                            found = true
                                            break 
                                        end
                                    end
                                    if not found then 
                                        table.insert(slots, newAmount) 
                                    end
                                end
                            end
                            pcall(saveInventoryBase)
                            raknetBitStreamSetReadOffset(bs, origPos)
                            return
                        end
                        
                        -- Основная логика: засчитываем только ПРИРОСТ (по сумме всех слотов)
                        for itemIdStr, newAmountStr in text:gmatch('"item":(%d+),"amount":(%d+)') do
                            local itemId = tonumber(itemIdStr)
                            local newAmount = tonumber(newAmountStr)
                            
                            if not itemId or not newAmount then
                                break
                            end
                            
                            -- Определяем тип ресурса
                            local resKey = nil
                            local maxStack = nil
                            if currentWork == WORK_TYPES.FARM then
                                resKey = FARM_ITEM_TO_RES[itemId]
                                if resKey then maxStack = getMaxStack(resKey) end
                            elseif currentWork == WORK_TYPES.MINE then
                                if settings.undermineEnabled or settings.underminelavkaEnabled then
                                    resKey = MINE_ITEM_TO_RES[itemId]
                                    if resKey then maxStack = getMaxStack(resKey) end
                                end
                            elseif currentWork == WORK_TYPES.SAWMILL then
                                resKey = SAWMILL_ITEM_TO_RES[itemId]
                                if resKey then maxStack = getMaxStack(resKey) end
                            end
                            
                            -- Предметы пейдея
                            if not resKey and PAYDAY_ITEMS[itemId] then
                                resKey = PAYDAY_ITEMS[itemId]
                                maxStack = getMaxStack(resKey)
                            end
                            
                            -- Акции инкассатора - считаем реальный прирост по пакету инвентаря
                            if not resKey and STOCKS[itemId] then
                                resKey = "stock_" .. itemId
                                maxStack = getMaxStack(resKey)
                            end
                            -- Криптовалюта (BTC/ASC) - считаем реальный прирост, а не +1 по чату
                            if not resKey and ALL_CRYPTO[itemId] and settings.cryptoAutoScanEnabled then
                                resKey = (itemId == 1811) and "crypto_btc" or "crypto_asc"
                                maxStack = getMaxStack(resKey)
                            end
                            
                            if resKey and maxStack then
                                -- Игнорируем аномально большие значения (баги/лаги)
                                if newAmount > maxStack * 2 then 
                                    break 
                                end
                                
                                -- Инициализируем кэш если нужно
                                if not inventoryCache[itemId] then 
                                    inventoryCache[itemId] = {} 
                                end
                                
                                local slots = inventoryCache[itemId]
                                
                                -- МУЛЬТИСТАК: ищем ближайший слот по разнице
							local bestSlot = nil
							local bestDiff = math.huge
								for i, slotAmount in ipairs(slots) do
							local diff = math.abs(newAmount - slotAmount)
								if diff < bestDiff or (diff == bestDiff and newAmount > slotAmount) then
								bestDiff = diff
								bestSlot = i
							end
						end
                                
                                if bestSlot and (resKey == "firewood" or resKey == "quality_wood") and bestDiff > math.max(50, math.floor(maxStack * 0.05)) then
    bestSlot = nil
end
if bestSlot then
                                    local oldAmount = slots[bestSlot]
                                    
                                    if newAmount > oldAmount then
                                        local added = newAmount - oldAmount
								if added > 0 and added <= maxStack then
									slots[bestSlot] = newAmount
									pcall(saveInventoryBase)
										if resKey == "talon_az" then
											if settings.talonAutoScanEnabled and talonBaselineReady then
    addTalonAZ(added)
end
										elseif STOCKS[itemId] and not incassWorkActive then
    -- учёт инкассатора не начат: акцию не засчитываем (база инвентаря уже обновлена выше)
elseif STOCKS[itemId] then
    if settings.incassEnabled then
        if pendingResourcesBuffer[resKey] then
            pendingResourcesBuffer[resKey] = nil
            addStockLog(itemId, added)
        else
            pendingResources[resKey] = (pendingResources[resKey] or 0) + added
            stockPendingTime[resKey] = os.time()
        end
    end
elseif pendingResourcesBuffer[resKey] then
											addResource(resKey, added)
											pendingResourcesBuffer[resKey] = nil
										else
											pendingResources[resKey] = (pendingResources[resKey] or 0) + added
										end
							elseif added > maxStack then
                                            pendingResources[resKey] = nil
                                            slots[bestSlot] = newAmount
                                            pcall(saveInventoryBase)
                                        end
                                    elseif newAmount < oldAmount then
                                        local totalInSlots = 0
                                        for _, sl in ipairs(slots) do totalInSlots = totalInSlots + sl end
                                        
                                        if math.abs(totalInSlots - newAmount) > maxStack then
                                            inventoryCache[itemId] = {newAmount}
                                        else
                                            slots[bestSlot] = newAmount
                                        end
                                        pcall(saveInventoryBase)
                                        pendingResources[resKey] = nil
                                    end
                                else
                                    table.insert(slots, newAmount)
                                    pcall(saveInventoryBase)
                                end
                            end
                        end
                    end
                end
            end
            raknetBitStreamSetReadOffset(bs, origPos)
        end
    end)
    
    if not ok then
        print("ResHelper: onReceivePacket error: " .. tostring(err))
    end
end
-- ====== LEADERBOARD FUNCTIONS ======
function saveLbConfig(name, enabled)
    local data = {enabled = enabled or false}
    local file = io.open(leaderboardConfigPath, "w")
    if file then file:write(encodeJson(data)); file:close() end
end
function getLbEnabled()
    local file = io.open(leaderboardConfigPath, "r")
    if not file then return false end
    local data = decodeJson(file:read("*all"))
    file:close()
    if data then return data.enabled or false end
    return false
end
function lbInPeriod(t, period)
    if period == "Total" then return true end
    local d = getGameDate(t)
    if period == "Daily" then
        return d == getGameDate(os.time() - 86400)
    elseif period == "Weekly" then
        local mskWday = tonumber(os.date("%w", getMoscowTime()))
        if mskWday == 0 then mskWday = 7 end
        local lastSunday = os.time() - (mskWday * 86400)
        local lastMonday = lastSunday - (6 * 86400)
        return d >= getGameDate(lastMonday) and d <= getGameDate(lastSunday)
    end
    return false
end
function sendToLeaderboard(period, mode)
    local _, playerId = sampGetPlayerIdByCharHandle(PLAYER_PED)
    local name = sampGetPlayerNickname(playerId)
    if not name or name == "" or not rhNickValid(name) then return end
    if not getLbEnabled() then return end
	-- Блокируем отправку если используются кастомные цены
if useCustomFarmPrices or useCustomMinePrices or useCustomSawmillPrices then return end
    if mode == "Income" then return end
    
    local amount = 0
    local resources = {}
    
    if mode == "Farm" or mode == "Mine" or mode == "Sawmill" then
        local workType = WORK_TYPES.FARM
        if mode == "Mine" then workType = WORK_TYPES.MINE
        elseif mode == "Sawmill" then workType = WORK_TYPES.SAWMILL end
        local wc = configs[workType]
        local prices = loadPricesForWorkType(wc)
        local data = getResourcesForPeriod(getServerStatsPath(workType), period)
        
        for resKey, resAmount in pairs(data) do
            local price = prices[resKey] or wc.defaultPrices[resKey] or 0
            amount = amount + (resAmount * price)
            resources[resKey] = resAmount
        end
    elseif mode == "Oil" then
        local oilMoney, oilAZ = 0, 0
        for _, log in ipairs(oilLog) do
            if lbInPeriod(log.time, period) then
                oilMoney = oilMoney + (log.money or 0)
                oilAZ = oilAZ + (log.az or 0)
            end
        end
        amount = math.floor(oilMoney)
        resources = {az = math.floor(oilAZ)}
    elseif mode == "Taxi" then
        local taxiMoney, rides = 0, 0
        for _, log in ipairs(taxiLog) do
            if lbInPeriod(log.time, period) then
                taxiMoney = taxiMoney + (log.money or 0)
                rides = rides + 1
            end
        end
        amount = math.floor(taxiMoney)
        resources = {rides = rides}
    elseif mode == "Incass" then
        local atm = 0
        for _, log in ipairs(incassLog) do
            if lbInPeriod(log.time, period) then atm = atm + (log.money or 0) end
        end
        local byItem = {}
        for _, log in ipairs(stockLog) do
            if lbInPeriod(log.time, period) then
                byItem[log.itemId] = (byItem[log.itemId] or 0) + (log.amount or 0)
            end
        end
        local stockIncome = 0
        for id, amt in pairs(byItem) do
            stockIncome = stockIncome + amt * (getStockPrice(id) or 0)
        end
        amount = math.floor(atm + stockIncome)
        resources = {atm = math.floor(atm), stocks = math.floor(stockIncome)}
    elseif mode == "IM" then
        local imAmount = 0
        local shardAmount = 0
        
        if period == "Daily" then
            local td = getGameDate(os.time() - 86400)
            for _, log in ipairs(itemMarketLog) do
                if getGameDate(log.time) == td then imAmount = imAmount + log.amount end
            end
            for _, log in ipairs(shardLog) do
                if getGameDate(log.time) == td then shardAmount = shardAmount + log.amount end
            end
        elseif period == "Weekly" then
            local mskTime = getMoscowTime()
            local mskWday = tonumber(os.date("%w", mskTime))
            if mskWday == 0 then mskWday = 7 end
            local lastSunday = os.time() - (mskWday * 86400)
            local lastMonday = lastSunday - (6 * 86400)
            for _, log in ipairs(itemMarketLog) do
                local logDate = getGameDate(log.time)
                if logDate >= getGameDate(lastMonday) and logDate <= getGameDate(lastSunday) then
                    imAmount = imAmount + log.amount
                end
            end
            for _, log in ipairs(shardLog) do
                local logDate = getGameDate(log.time)
                if logDate >= getGameDate(lastMonday) and logDate <= getGameDate(lastSunday) then
                    shardAmount = shardAmount + log.amount
                end
            end
        elseif period == "Total" then
            for _, log in ipairs(itemMarketLog) do imAmount = imAmount + log.amount end
            for _, log in ipairs(shardLog) do shardAmount = shardAmount + log.amount end
        end
        
        amount = imAmount + shardAmount
        resources = {im = imAmount, shards = shardAmount}
    end
    
    if amount <= 0 then return end
    
    local serverName = getCurrentServer()
    if not serverName or serverName == "" then serverName = "Unknown" end
    if serverName == "Vice City" then return end 
    
    local rawName = u8:encode(name)
    local encodedName = ""
    for i = 1, #rawName do
        local c = rawName:sub(i, i)
        if c:match("[%w%-%.%_%~]") then encodedName = encodedName .. c
        elseif c == " " then encodedName = encodedName .. "+"
        else encodedName = encodedName .. string.format("%%%02X", string.byte(c)) end
    end
    
    local encodedServer = urlEncode(serverName)
    local url = LEADERBOARD_URL .. "?name=" .. encodedName .. "&amount=" .. amount .. "&period=" .. period .. "&mode=" .. mode .. "&server=" .. encodedServer
    
    if next(resources) then
        local resJson = encodeJson(resources)
        url = url .. "&resources=" .. urlEncode(resJson)
    end
    
    lbSendQueue = lbSendQueue or {}
    table.insert(lbSendQueue, {url = url, tries = 0})
    startLbSendWorker()
end
lbSendQueue = lbSendQueue or {}
lbWorkerRunning = lbWorkerRunning or false
function startLbSendWorker()
    if lbWorkerRunning then return end
    lbWorkerRunning = true
    lua_thread.create(function()
        while #lbSendQueue > 0 do
            local item = table.remove(lbSendQueue, 1)
            item.tries = item.tries + 1
            local ok, result = pcall(function()
                local th = effil.thread(function(u)
                    local req = require("requests")
                    local r = req.get(u)
                    return (r and r.text) or ""
                end)(item.url)
                local t0 = os.clock()
                while th:status() == "running" do
                    wait(100)
                    if os.clock() - t0 > 30 then
                        pcall(function() th:cancel(0) end)
                        return "TIMEOUT"
                    end
                end
                return th:get()
            end)
            local retry = (not ok) or result == "BUSY_RETRY" or result == "TIMEOUT" or result == ""
            if retry and item.tries < 4 then
                table.insert(lbSendQueue, item)
                wait(3000 * item.tries)
            else
                wait(1500)
            end
        end
        lbWorkerRunning = false
    end)
end
pricesRetryCount = pricesRetryCount or 0
pricesRetryPending = pricesRetryPending or false
pricesRetryAt = pricesRetryAt or 0
pricesRequestActive = pricesRequestActive or false
pricesRequestStartedAt = pricesRequestStartedAt or 0
local pricesMaxRetries = 5
local pricesRetryDelays = {3, 5, 10, 15, 30} -- в секундах
local function logPricesError(msg) end
local function pricesScheduleRetryOrFail()
    pricesRequestActive = false
    pricesRetryCount = pricesRetryCount + 1
    if pricesRetryCount <= pricesMaxRetries then
        pricesRetryPending = true
        pricesRetryAt = os.time() + (pricesRetryDelays[pricesRetryCount] or 30)
    else
        pricesLoading = false
        pricesRetryPending = false
        sampAddChatMessage(SCRIPT_PREFIX .. "{FF6347}Не удалось загрузить цены после нескольких попыток. Нажмите \"Обновить цены\" на вкладке вручную.", SCRIPT_COLOR)
    end
end
function loadGlobalPrices()
    if not pricesLoading then
        pricesRetryCount = 0
    end
    pricesLoading = true
    pricesRetryPending = false
    pricesRequestActive = true
    pricesRequestStartedAt = os.time()
    
    local tempFile = dirml .. "/prices_temp.json"
    local myStartTime = pricesRequestStartedAt
    
    downloadUrlToFile(
        LEADERBOARD_URL .. "?action=prices",
        tempFile,
        function(id, status)
            if not pricesRequestActive or pricesRequestStartedAt ~= myStartTime then return end
            
            if status == dlstatus.STATUS_ENDDOWNLOADDATA then
                pricesRequestActive = false
                local file = io.open(tempFile, "r")
                if file then
                    local content = file:read("*all")
                    file:close()
                    os.remove(tempFile)
                    
                    local data = decodeJson(content)
                    if data and next(data) then
                        if rhIsVice() then
                            for k, v in pairs(data) do
                                if type(v) == "number" then
                                    data[k] = (v > 0) and math.max(1, math.floor(v / 100 + 0.5)) or 0
                                end
                            end
                        end
                        globalPrices = data
                        for k, v in pairs(globalPrices) do
                            if priceEdit[k] then priceEdit[k].v = v end
                            resourcePrices[k] = v
                        end
                        syncCasePrices()
                        local today = getGameDate()
                        local pf = io.open(pricesStatePath, "w")
                        if pf then pf:write(today .. rhPriceTag()); pf:close() end
                        pricesRetryCount = 0
                        pricesLoading = false
                        pricesRetryPending = false
                        if not pricesLoadedMsg then
                            pricesLoadedMsg = true
                            sampAddChatMessage(SCRIPT_PREFIX .. "Цены обновлены из Google таблицы!", SCRIPT_COLOR)
                        end
                    else
                        logPricesError("raw: " .. tostring(content):sub(1, 300))
                        pricesScheduleRetryOrFail()
                    end
                else
                    logPricesError("temp file missing after ENDDOWNLOADDATA")
                    pricesScheduleRetryOrFail()
                end
            elseif status == dlstatus.STATUSEX_ENDDOWNLOAD then
                pricesRequestActive = false
                if doesFileExist(tempFile) then os.remove(tempFile) end
                pricesScheduleRetryOrFail()
            end
        end
    )
end
function loadPricesForWorkType(wc)
    -- Сначала пробуем глобальные цены из Google таблицы
    if globalPrices and next(globalPrices) then
        return globalPrices
    end
    -- Иначе загружаем из локального файла
    local prices = {}
    local pricePath
    if wc.name == "Ферма" then pricePath = farmPricesPath
    elseif wc.name == "Шахта" then pricePath = minePricesPath
    else pricePath = sawmillPricesPath end
    local pf = io.open(pricePath, "r")
    if pf then
        for line in pf:lines() do
            local k, v = line:match("^(.-)=(.*)$")
            if k and v then prices[k] = tonumber(v) end
        end
        pf:close()
    end
    return prices
end
function getResourcesForPeriod(statsPath, period)
    local result = {}
    local sf = io.open(statsPath, "r")
    if not sf then return result end
    local c = sf:read("*all")
    sf:close()
    
    if period == "Daily" then
        local mskTime = getMoscowTime()
        local mskHour = tonumber(os.date("%H", mskTime))
        local td
        if mskHour >= 5 then
            td = getGameDate(os.time() - 86400)  
        else
            td = getGameDate(os.time() - 172800) 
        end
        for t, r, a in c:gmatch('"time":(%d+),"resource":"([^"]+)","amount":(%d+)') do
            if getGameDate(tonumber(t)) == td then
                result[r] = (result[r] or 0) + tonumber(a)
            end
        end
    elseif period == "Weekly" then
        local mskTime = getMoscowTime()
        local mskWday = tonumber(os.date("%w", mskTime))
        if mskWday == 0 then mskWday = 7 end
        local lastSunday = os.time() - (mskWday * 86400)
        local lastMonday = lastSunday - (6 * 86400)
        for t, r, a in c:gmatch('"time":(%d+),"resource":"([^"]+)","amount":(%d+)') do
            local logDate = getGameDate(tonumber(t))
            if logDate >= getGameDate(lastMonday) and logDate <= getGameDate(lastSunday) then
                result[r] = (result[r] or 0) + tonumber(a)
            end
        end
    elseif period == "Total" then
        for t, r, a in c:gmatch('"time":(%d+),"resource":"([^"]+)","amount":(%d+)') do
            result[r] = (result[r] or 0) + tonumber(a)
        end
    end
    return result
end
function loadLeaderboard(period, mode, silent)
    mode = mode or "Income"
    if not leaderboardCache[mode] then leaderboardCache[mode] = {} end
    
    local tempFile = configDir .. "lb_cache_" .. mode .. "_" .. period .. ".json"
    local url = LEADERBOARD_URL .. "?period=" .. period .. "&mode=" .. mode
    local alreadyDone = false
    
    downloadUrlToFile(url, tempFile, function(id, status)
        if alreadyDone then return end
        if status == dlstatus.STATUS_ENDDOWNLOADDATA then
            alreadyDone = true
            local file = io.open(tempFile, "r")
            if file then
                local content = file:read("*all")
                file:close()
                os.remove(tempFile)
                
			local decoded = u8:decode(content)
                local data = decodeJson(decoded)
                if data then
                    leaderboardCache[mode][period] = rhFixLb(data)
                    -- сохраняем в файл для офлайн-кэша
                    local cacheFile = io.open(tempFile:gsub(".json", "_cache.json"), "w")
                    if cacheFile then
                        cacheFile:write(content)
                        cacheFile:close()
                    end
                    if not silent then
                        sampAddChatMessage(SCRIPT_PREFIX .. "Рейтинг обновлён!", SCRIPT_COLOR)
                    end
                end
            end
        elseif status == dlstatus.STATUSEX_ENDDOWNLOAD then
            alreadyDone = true
            if doesFileExist(tempFile) then os.remove(tempFile) end
            -- Пробуем загрузить из кэша
            local cacheFile = io.open(tempFile:gsub(".json", "_cache.json"), "r")
            if cacheFile then
                local content = cacheFile:read("*all")
                cacheFile:close()
                local decoded = u8:decode(content)
                local data = decodeJson(decoded)
                if data then
                    leaderboardCache[mode][period] = data
                end
            end
        end
    end)
end
function refreshMyOverallRank()
    if not getLbEnabled() then myOverallRank = nil; return end
    local cache = leaderboardCache.Income and leaderboardCache.Income.Total
    if (not cache or #cache == 0) and not myOverallRankRequested then
        myOverallRankRequested = true
        local cacheFile = io.open(configDir .. "lb_cache_Income_Total_cache.json", "r")
        if cacheFile then
            local content = cacheFile:read("*all"); cacheFile:close()
            local data = decodeJson(u8:decode(content))
            if data then leaderboardCache.Income.Total = rhFixLb(data) end
        end
        loadLeaderboard("Total", "Income", true)
    end
    cache = leaderboardCache.Income and leaderboardCache.Income.Total
    if cache and #cache > 0 then
        local _, myId = sampGetPlayerIdByCharHandle(PLAYER_PED)
        local myName = sampGetPlayerNickname(myId)
        local mySrv = LBX.mySrv()
        for i, entry in ipairs(cache) do
            if LBX.isMine(entry, myName, mySrv) then myOverallRank = i; myOverallAmount = entry.amount; return end
        end
        myOverallRank = -1
        myOverallAmount = nil
    end
end
function initCustomPrices()
    loadCustomPricesConfig()
end
RH_DATA_SERVER = nil
rhSrvCheckAt = 0

function rhApplyServerPaths(server)
    local suf = (server == "Vice City") and "_Vice City" or ""
    paydayStatsPath = configDir .. "payday_stats" .. suf .. ".json"
    oilStatsPath = configDir .. "oil_stats" .. suf .. ".json"
    taxiStatsPath = configDir .. "taxi_stats" .. suf .. ".json"
    incassStatsPath = configDir .. "incass_stats" .. suf .. ".json"
    stockStatsPath = configDir .. "stock_stats" .. suf .. ".json"
    itemMarketStatsPath = configDir .. "itemmarket_stats" .. suf .. ".json"
    investmentStatsPath = configDir .. "investment_stats" .. suf .. ".json"
    cryptoStatsPath = configDir .. "crypto_stats" .. suf .. ".json"
    shardStatsPath = configDir .. "shard_stats" .. suf .. ".json"
    nftStatsPath = configDir .. "ResHelperNft" .. suf .. ".json"
    nftOldStatsPath = configDir .. "nft_stats" .. suf .. ".json"
end

rhVcThemeActive = false
rhVcThemeEnabled = true -- включать тему Vice City при перелёте на VC
rhThemeBackup = {theme = 0, custom = false}

function rhApplyServerTheme(server)
    if server == "Vice City" and rhVcThemeEnabled then
        if not rhVcThemeActive then
            rhThemeBackup.theme = currentTheme
            rhThemeBackup.custom = useCustomTheme
            rhVcThemeActive = true
        end
        currentTheme = THEMES.VICE
        useCustomTheme = false
        cb_useCustomTheme.v = false
    elseif rhVcThemeActive then
        rhVcThemeActive = false
        currentTheme = rhThemeBackup.theme
        useCustomTheme = rhThemeBackup.custom
        cb_useCustomTheme.v = useCustomTheme
    end
    for i, tid in ipairs(THEME_ORDER) do
        if tid == currentTheme then selectedThemeIdx.v = i - 1; break end
    end
end

function rhCheckServerSwitch()
    if os.clock() < rhSrvCheckAt then return end
    rhSrvCheckAt = os.clock() + 1
    if sampGetGamestate() ~= 3 then return end
    local real = getRealServer()
    if not real or real == "" or real == "Unknown" then return end
    if not RH_DATA_SERVER then
        RH_DATA_SERVER = real
        rhApplyServerPaths(real)
        return
    end
    if real == RH_DATA_SERVER then return end

    pcall(saveStats); pcall(saveGoalsProgress); pcall(saveInventoryBase)
    pcall(savePaydayStats); pcall(saveOilStats); pcall(saveTaxiStats)
    pcall(saveIncassStats); pcall(saveStockStats); pcall(saveItemMarketStats)
    pcall(saveInvestmentStats); pcall(saveCryptoStats); pcall(saveShardStats)
    pcall(nftCloseSession); pcall(nftSave)

    local old = RH_DATA_SERVER
    pcall(rhApplyServerTheme, real)
    RH_DATA_SERVER = real
    RH_REAL_NICK = nil; RH_NICK_TRIES = 0; RH_NICK_LAST_ASK = 0
    rhApplyServerPaths(real)
    paydayLog = {}; oilLog = {}; taxiLog = {}; incassLog = {}; stockLog = {}
    investmentLog = {}; cryptoLog = {}; shardLog = {}
    nftData = nil; nftSession = nil; nftStatsCache = nil
    pcall(loadPaydayStats); pcall(loadOilStats); pcall(loadTaxiStats)
    pcall(loadIncassStats); pcall(loadStockStats); pcall(loadItemMarketStats)
    pcall(loadInvestmentStats); pcall(loadCryptoStats); pcall(loadShardStats)
    if (old == "Vice City") ~= (real == "Vice City") then pcall(loadGlobalPrices) end

    if currentWork then
        pcall(function() switchWorkType(currentWork, true) end)
    end
    cachedTodayStats = nil; cachedTodayTime = 0; cachedWeekStats = nil; cachedWeekTime = 0
    pcall(loadAllStatsForTodayIncome)
    pcall(refreshHomeDashboard)
    sampAddChatMessage(SCRIPT_PREFIX .. "Сервер сменился: " .. tostring(old) .. " -> " .. tostring(real) .. ". Статистика переключена.", SCRIPT_COLOR)
end

function initStatsMigration()
    if getCurrentServer() == "Vice City" then return end
    local server = getCurrentServer()
    if server and server ~= "Unknown" then
        local migrations = {
            {old = configDir .. "farm_stats.json", new = getServerStatsPath(WORK_TYPES.FARM)},
            {old = configDir .. "mining_stats.json", new = getServerStatsPath(WORK_TYPES.MINE)},
            {old = configDir .. "sawmill_stats.json", new = getServerStatsPath(WORK_TYPES.SAWMILL)},
            {old = configDir .. "farm_base.json", new = getServerBasePath(WORK_TYPES.FARM)},
            {old = configDir .. "mine_base.json", new = getServerBasePath(WORK_TYPES.MINE)},
            {old = configDir .. "sawmill_base.json", new = getServerBasePath(WORK_TYPES.SAWMILL)},
            {old = configDir .. "farm_goals_progress.json", new = getServerGoalsProgressPath(WORK_TYPES.FARM)},
            {old = configDir .. "mine_goals_progress.json", new = getServerGoalsProgressPath(WORK_TYPES.MINE)},
            {old = configDir .. "sawmill_goals_progress.json", new = getServerGoalsProgressPath(WORK_TYPES.SAWMILL)},
        }
        for _, m in ipairs(migrations) do
            if doesFileExist(m.old) and not doesFileExist(m.new) then
                local ok = os.rename(m.old, m.new)
                if ok then
                    sampAddChatMessage(SCRIPT_PREFIX .. "Статистика перенесена на сервер " .. server .. ": " .. m.new, SCRIPT_COLOR)
                end
            end
        end
    end
end
function loadAllStatsForTodayIncome()
    local gameDate = getGameDate()
    totalDailyIncome = 0
    
    local farmPrices = {}
    local farmPriceFile = io.open(farmPricesPath, "r")
    if farmPriceFile then
        for line in farmPriceFile:lines() do
            local k, v = line:match("^(.-)=(.*)$")
            if k and v then farmPrices[k] = tonumber(v) end
        end
        farmPriceFile:close()
    end
    
    local minePrices = {}
    local minePriceFile = io.open(minePricesPath, "r")
    if minePriceFile then
        for line in minePriceFile:lines() do
            local k, v = line:match("^(.-)=(.*)$")
            if k and v then minePrices[k] = tonumber(v) end
        end
        minePriceFile:close()
    end
    
    local sawmillPrices = {}
    local sawmillPriceFile = io.open(sawmillPricesPath, "r")
    if sawmillPriceFile then
        for line in sawmillPriceFile:lines() do
            local k, v = line:match("^(.-)=(.*)$")
            if k and v then sawmillPrices[k] = tonumber(v) end
        end
        sawmillPriceFile:close()
    end
    
    local farmLogPath = getServerStatsPath(WORK_TYPES.FARM)
    local farmFile = io.open(farmLogPath, "r")
    if farmFile then
        local content = farmFile:read("*all")
        farmFile:close()
        for time, resource, amount in content:gmatch('"time":(%d+),"resource":"([^"]+)","amount":(%d+)') do
            if getGameDate(tonumber(time)) == gameDate then
                local price = farmPrices[resource] or configs[WORK_TYPES.FARM].defaultPrices[resource] or 0
                totalDailyIncome = totalDailyIncome + (tonumber(amount) * price)
            end
        end
    end
    
    local mineLogPath = getServerStatsPath(WORK_TYPES.MINE)
    local mineFile = io.open(mineLogPath, "r")
    if mineFile then
        local content = mineFile:read("*all")
        mineFile:close()
        for time, resource, amount in content:gmatch('"time":(%d+),"resource":"([^"]+)","amount":(%d+)') do
            if getGameDate(tonumber(time)) == gameDate then
                local price = minePrices[resource] or configs[WORK_TYPES.MINE].defaultPrices[resource] or 0
                totalDailyIncome = totalDailyIncome + (tonumber(amount) * price)
            end
        end
    end
    
    local sawmillLogPath = getServerStatsPath(WORK_TYPES.SAWMILL)
    local sawmillFile = io.open(sawmillLogPath, "r")
    if sawmillFile then
        local content = sawmillFile:read("*all")
        sawmillFile:close()
        for time, resource, amount in content:gmatch('"time":(%d+),"resource":"([^"]+)","amount":(%d+)') do
            if getGameDate(tonumber(time)) == gameDate then
                local price = sawmillPrices[resource] or configs[WORK_TYPES.SAWMILL].defaultPrices[resource] or 0
                totalDailyIncome = totalDailyIncome + (tonumber(amount) * price)
            end
        end
    end
    
    for _, log in ipairs(itemMarketLog) do
        if getGameDate(log.time) == gameDate then
            totalDailyIncome = totalDailyIncome + log.amount
        end
    end
    
    saveTotalIncomeGoal()
end
function loadServerIcons()
end
function getServerIcon(name)
    if not name then return nil end
    name = rhCanonServer(name)
    if serverIcons[name] == nil then
        local iconPath = dirml.."/ResHelper/files/server_icons/"..name..".png"
        if doesFileExist(iconPath) then
            serverIcons[name] = imgui.CreateTextureFromFile(iconPath)
        else
            serverIcons[name] = false
        end
    end
    return serverIcons[name] or nil
end
function initSyncCheckboxes()
    cb_farm.v = settings.farmEnabled
    cb_undermine.v = settings.undermineEnabled
    cb_lavka.v = settings.underminelavkaEnabled
    cb_regular.v = settings.regularmineEnabled
    cb_chatNotify.v = settings.chatNotifyEnabled
    cb_devNotifPopup.v = (settings.devNotifPopupEnabled ~= false)
    cb_goalSound.v = settings.goalSoundEnabled
    cb_pickupSound.v = settings.pickupSoundEnabled
    cb_farm_overlay.v = settings.farmOverlayEnabled
    cb_mine_overlay.v = settings.mineOverlayEnabled
    cb_overlay_timer.v = settings.overlayTimerEnabled
    totalGoalEdit.v = settings.totalIncomeGoal
    cb_sawmill_overlay.v = settings.sawmillOverlayEnabled
    cb_oil_overlay.v = settings.oilOverlayEnabled
    cb_oil.v = settings.oilEnabled
    cb_sawmill.v = settings.sawmillEnabled
    cb_taxi.v = settings.taxiEnabled
    cb_taxi_overlay.v = settings.taxiOverlayEnabled
    cb_incass_overlay.v = settings.incassOverlayEnabled
    cb_incass.v = settings.incassEnabled
    goal_vol_slider.v = settings.goalSoundVolume
    cb_mineSpawnTimer.v = settings.mineSpawnTimerEnabled
    cb_overlayStyle.v = (settings.overlayStyle or 1) - 1
    cb_overlayColumns.v = (settings.overlayColumns or 2) - 1
    cb_talonAutoScan.v = settings.talonAutoScanEnabled
    cb_cryptoAutoScan.v = (settings.cryptoAutoScanEnabled ~= false)
    cb_notifyOnlyImportant.v = settings.notifyOnlyImportant
    cb_notifyHideStartup.v = settings.notifyHideStartup
	cb_overlayHideOnHover.v = settings.overlayHideOnHover
	cb_overlayAutoTimer.v = settings.overlayAutoTimer
	cb_smoothMenu.v = (settings.smoothMenuEnabled ~= false)
	cb_smoothWindow.v = (settings.smoothWindowEnabled ~= false)
	cb_homeShowLogo.v = (settings.homeShowLogo == true)
	cb_homeShowSummary.v = (settings.homeShowSummary ~= false)
	cb_homeShowTiles.v = (settings.homeShowTiles ~= false)
	cb_homeShowGoals.v = (settings.homeShowGoals ~= false)
	cb_homeShowWork.v = (settings.homeShowWork ~= false)
	cb_homeShowHotkey.v = (settings.homeShowHotkey ~= false)
    pickup_vol_slider.v = settings.pickupSoundVolume
end
function updateWindowAnim()
    if mainWin.v ~= windowAnimLastState then
        windowAnimLastState = mainWin.v
        windowAnimStartTime = os.clock()
    end
    if not settings.smoothWindowEnabled then
        windowAnimAlpha = mainWin.v and 1.0 or 0.0
        return
    end
    local t = math.min((os.clock() - windowAnimStartTime) / WINDOW_ANIM_DURATION, 1.0)
    windowAnimAlpha = mainWin.v and t or (1.0 - t)
end
function isWindowAnimating()
    return (not mainWin.v) and windowAnimAlpha > 0
end
function registerChatCommands()
    sampRegisterChatCommand("rh", function() 
        mainWin.v = not mainWin.v
        imgui.ShowCursor = mainWin.v
    end)
    sampRegisterChatCommand("rhrl", function() scr:reload() end)
    sampRegisterChatCommand("rhreset", function()
        cachedTodayStats = nil; cachedTodayTime = 0; cachedWeekStats = nil; cachedWeekTime = 0
        sampAddChatMessage(SCRIPT_PREFIX .. "Кэш статистики сброшен! Данные пересчитаны по новым правилам (05:00 МСК).", SCRIPT_COLOR)
    end)
    sampRegisterChatCommand("rhtest", function()
        changelogShown = false
        sampAddChatMessage(SCRIPT_PREFIX .. "Окно изменений будет показано при следующем открытии /rh", SCRIPT_COLOR)
    end)
end
function initAfterSpawn()
    local curHost, curNick = "", ""
    for _ = 1, 20 do
        local okId, myId = sampGetPlayerIdByCharHandle(PLAYER_PED)
        curHost = getCurrentServer() or ""
        curNick = okId and sampGetPlayerNickname(myId) or ""
        if curHost ~= "" and curNick ~= "" then break end
        wait(250)
    end
    local savedHost = autoAdConfig.savedHost or ""
    if savedHost ~= "" then savedHost = getCurrentServer(savedHost) end
    local savedNick = autoAdConfig.savedNick or ""
    local hostChanged = curHost ~= "" and savedHost ~= "" and savedHost ~= curHost
    local nickChanged = curNick ~= "" and savedNick ~= "" and savedNick ~= curNick
    if hostChanged or nickChanged then
        for _, ad in ipairs(autoAdConfig.ads) do ad.active = false end
        saveAutoAdConfig()
        sampAddChatMessage(string.format(SCRIPT_PREFIX .. "Автопиар остановлен: сервер %s -> %s, ник %s -> %s",
            savedHost, curHost, savedNick, curNick), SCRIPT_COLOR)
    end
    if not inventoryCache[731] then
        inventoryCache[731] = {}
    end
    if not inventoryCache[1811] then
        inventoryCache[1811] = {}
    end
    if not inventoryCache[5996] then
        inventoryCache[5996] = {}
    end
    sampAddChatMessage(string.format(SCRIPT_PREFIX.."ResHelper загружен! /rh - меню. Версия: %s", scr.version), SCRIPT_COLOR)
    if settings.talonAutoScanEnabled or settings.cryptoAutoScanEnabled then
        lua_thread.create(function()
            wait(500)
            scanState.active = true
            scanState.scanning = true
            scanState.foundResources = {}
            scanState.statusText = "Авто-сканирование талона AZ..."
            scanState.waitForInventory = false
            scanState.isTalonScan = true
            sampSendChat("/stats")
        end)
    end
    imgui.ShowCursor = false
    globalPrices = {}
    loadGlobalPrices()
    updateCheck()
    updateProgressAchievements()
end
function processTelegramReports(lastDailyReportDate, lastWeeklyReportKey)
    if tgConfig.enabled and tgConfig.dailyReportEnabled then
        local mskTime = getMoscowTime()
        local mskHour = tonumber(os.date("%H", mskTime))
        local yesterdayDate = getGameDate(os.time() - 86400)
        if mskHour >= 5 and tostring(lastDailyReportDate) ~= yesterdayDate then
            lastDailyReportDate = yesterdayDate
            saveTgReportState(lastDailyReportDate, lastWeeklyReportKey)
            sampAddChatMessage(SCRIPT_PREFIX .. "Ежедневный отчёт отправлен в Telegram!", SCRIPT_COLOR)
            queueTelegramMessage(generateReport("daily"))
        end
    end
    if tgConfig.enabled and tgConfig.weeklyReportEnabled then
        local mskTime = getMoscowTime()
        local mskHour = tonumber(os.date("%H", mskTime))
        local mskWday = tonumber(os.date("%w", mskTime))
        if mskWday == 1 and mskHour >= 5 then
            local weekKey = os.date("%Y-%W", mskTime)
            if tostring(lastWeeklyReportKey) ~= weekKey then
                lastWeeklyReportKey = weekKey
                saveTgReportState(lastDailyReportDate, lastWeeklyReportKey)
                sampAddChatMessage(SCRIPT_PREFIX .. "Недельный отчёт отправлен в Telegram!", SCRIPT_COLOR)
                queueTelegramMessage(generateReport("week"))
            end
        end
    end
    return lastDailyReportDate, lastWeeklyReportKey
end
function sendDailyLeaderboard(lastLbDailyDate, lastLbWeeklyDate)
    local mskTime = getMoscowTime()
    local mskHour = tonumber(os.date("%H", mskTime))
    local yesterdayDate = getGameDate(os.time() - 86400)
    local allModes = {"Farm", "Mine", "Sawmill", "Oil", "Taxi", "Incass", "IM"}
    if mskHour >= 5 and tostring(lastLbDailyDate) ~= yesterdayDate then
        lastLbDailyDate = yesterdayDate
        saveLbState(lastLbDailyDate, lastLbWeeklyDate)
        for _, mode in ipairs(allModes) do
            sendToLeaderboard("Daily", mode)
            sendToLeaderboard("Total", mode)
        end
        sampAddChatMessage(SCRIPT_PREFIX .. "Данные отправлены в рейтинг!", SCRIPT_COLOR)
    end
    return lastLbDailyDate
end
function sendWeeklyLeaderboard(lastLbDailyDate, lastLbWeeklyDate)
    local mskTime = getMoscowTime()
    local mskHour = tonumber(os.date("%H", mskTime))
    if mskHour >= 5 then
        local mskWday = tonumber(os.date("%w", mskTime))
        if mskWday == 0 then mskWday = 7 end
        local lastMonday = os.time() - (mskWday + 6) * 86400
        local weekKey = os.date("%Y-%W", lastMonday)
        if tostring(lastLbWeeklyDate) ~= weekKey then
            lastLbWeeklyDate = weekKey
            saveLbState(lastLbDailyDate, lastLbWeeklyDate)
            local allModes = {"Farm", "Mine", "Sawmill", "Oil", "Taxi", "Incass", "IM"}
            for _, mode in ipairs(allModes) do
                sendToLeaderboard("Weekly", mode)
            end
            sampAddChatMessage(SCRIPT_PREFIX .. "Недельный рейтинг отправлен!", SCRIPT_COLOR)
        end
    end
    return lastLbWeeklyDate
end
function processLeaderboard(lastLbDailyDate, lastLbWeeklyDate)
    if not getLbEnabled() or useCustomFarmPrices or useCustomMinePrices or useCustomSawmillPrices then
        return lastLbDailyDate, lastLbWeeklyDate
    end
    lastLbDailyDate = sendDailyLeaderboard(lastLbDailyDate, lastLbWeeklyDate)
    lastLbWeeklyDate = sendWeeklyLeaderboard(lastLbDailyDate, lastLbWeeklyDate)
    return lastLbDailyDate, lastLbWeeklyDate
end
function processMenuToggle()
    local menuActive = false
    if settings.menuKey and #settings.menuKey > 0 then
        menuActive = true
        for i = 1, #settings.menuKey - 1 do
            if not isKeyDown(settings.menuKey[i]) then menuActive = false; break end
        end
        if menuActive and not isKeyJustPressed(settings.menuKey[#settings.menuKey]) then
            menuActive = false
        end
    end
    if menuActive and not sampIsChatInputActive() and not sampIsDialogActive() then 
        mainWin.v = not mainWin.v
        imgui.ShowCursor = mainWin.v
    end
end
function processTimer()
    if overlayTimer.running and os.time() ~= (overlayTimer.lastUpdate or 0) then
        overlayTimer.elapsed = os.time() - overlayTimer.startTime
        overlayTimer.displayedTime = formatTime(overlayTimer.elapsed)
        overlayTimer.lastUpdate = os.time()
    end
end
function processTgQueueIfNeeded(lastTgQueueProcess)
    if os.time() - lastTgQueueProcess >= 2 then
        processTgQueue()
        return os.time()
    end
    return lastTgQueueProcess
end
function sendAutoAdMessage(ad)
    local text
    local nextInterval = ad.intervalBuf.v > 0 and ad.intervalBuf.v or 300
    if ad.multiEnabled and ad.multiLines and #ad.multiLines > 0 then
        if not ad.multiIdx or ad.multiIdx < 1 or ad.multiIdx > #ad.multiLines then
            ad.multiIdx = 1
        end
        local line = ad.multiLines[ad.multiIdx]
        text = u8:decode(line.textBuf.v)
        local isLastLine = (ad.multiIdx == #ad.multiLines)
        if isLastLine then
            nextInterval = ad.intervalBuf.v > 0 and ad.intervalBuf.v or 300
            ad.multiIdx = 1
        else
            nextInterval = line.delayBuf.v >= 2 and line.delayBuf.v or 2
            ad.multiIdx = ad.multiIdx + 1
        end
    else
        text = u8:decode(ad.textBuf.v)
    end
    if text == "" then return nextInterval end
    local cmd = AUTO_AD_CHATS[ad.chatIdx + 1] or "/vr"
    if cmd == "/vr" then
        autoAdVrDialogState.pending = true
        autoAdVrDialogState.withAd = ad.vrWithAd
        autoAdVrDialogState.pendingTime = os.time()
    elseif cmd == "/ad" then
        autoAdAdDialogState.pending = true
        autoAdAdDialogState.pendingTime = os.time()
        autoAdAdDialogState.radioIdx = ad.adRadioIdx or 0
        autoAdAdDialogState.vip = ad.adVip or false
    end
    sampProcessChatInput(cmd .. " " .. text)
    return nextInterval
end
function toggleAutoAd(ad)
    ad.active = not ad.active
    if ad.active then
        local now = os.time()
        if not ad.nextSend or ad.nextSend <= now then
            local interval = sendAutoAdMessage(ad)
            ad.lastSend = now
            ad.nextSend = now + interval
        end
    end
    saveAutoAdConfig()
end
function processAutoAd()
    if sampIsChatInputActive() then return end
    if autoAdVrDialogState.pending or autoAdAdDialogState.pending then return end
    local now = os.time()
    local changed = false
    for _, ad in ipairs(autoAdConfig.ads) do
        if ad.active and ad.nextSend and now >= ad.nextSend then
            local interval = sendAutoAdMessage(ad)
            ad.lastSend = now
            ad.nextSend = now + interval
            changed = true
        end
    end
    if changed then saveAutoAdConfig() end
end
function runMainLoop()
    local lastTgQueueProcess = 0
    local lastSessionSave = os.time()
    local lastReportsCheck = 0
    local lastIncomeGoalSync = 0
    local reportsBackoffUntil = 0
    local lastMemErrorNotify = 0
    local lastDailyReportDate, lastWeeklyReportKey = loadTgReportState()
    local lastLbDailyDate, lastLbWeeklyDate = loadLbState()
    
    local lastMemLog = os.time()
    local wasConnected = true
    while true do
        wait(0)
        local connNow = (sampGetGamestate() == 3)
        if wasConnected and not connNow then
            stockScannedThisSession = false
            talonBaselineReady = false
            pendingPaydayAZ = {}
            pendingPaydayRub = {}
            talonRescanPending = true
        end
        if talonRescanPending and connNow and not scanState.active and sampIsLocalPlayerSpawned() then
            talonRescanPending = false
            if settings.talonAutoScanEnabled or settings.cryptoAutoScanEnabled then
                lua_thread.create(function()
                    wait(500)
                    scanState.active = true
                    scanState.scanning = true
                    scanState.foundResources = {}
                    scanState.statusText = "Авто-сканирование талона AZ..."
                    scanState.waitForInventory = false
                    scanState.isTalonScan = true
                    sampSendChat("/stats")
                end)
            end
        end
        wasConnected = connNow
        pcall(rhCheckServerSwitch)
        if os.time() - lastIncomeGoalSync >= 15 then
            lastIncomeGoalSync = os.time()
            local ok, err = pcall(refreshHomeDashboard)
            if not ok then print("ResHelper: refreshHomeDashboard error: " .. tostring(err)) end
        end
		if pricesRetryPending and os.time() >= pricesRetryAt then
            pricesRetryPending = false
            loadGlobalPrices()
        elseif pricesRequestActive and os.time() - pricesRequestStartedAt > 15 then
            logPricesError("timeout: downloadUrlToFile callback did not fire")
            pricesScheduleRetryOrFail()
        end
        lastTgQueueProcess = processTgQueueIfNeeded(lastTgQueueProcess)
        if pendingStockScan and not scanState.active then
            pendingStockScan = false
            startStockScan()
        end
        if tgQueueProcessing and os.time() - tgQueueProcessingStartTime > 35 then
            tgQueueProcessing = false
        end
		if os.time() - lastSessionSave >= 30 then
            lastSessionSave = os.time()
            saveSessionState()
        end
        if pendingScan and not scanState.active then
            local workToScan = pendingScan
            pendingScan = nil
            if currentWork == workToScan then startInventoryScan() end
        end
        if os.time() - lastReportsCheck >= 5 and os.time() >= reportsBackoffUntil then
            lastReportsCheck = os.time()
            local ok1, r1, r2 = pcall(processTelegramReports, lastDailyReportDate, lastWeeklyReportKey)
            if ok1 then
                lastDailyReportDate, lastWeeklyReportKey = r1, r2
            else
                print("ResHelper: processTelegramReports error: " .. tostring(r1))
                if tostring(r1):find("not enough memory") then
                    reportsBackoffUntil = os.time() + 60
                    if os.time() - lastMemErrorNotify > 60 then
                        lastMemErrorNotify = os.time()
                        sampAddChatMessage(SCRIPT_PREFIX .. "Нехватка памяти игры, повтор отправки отчёта через 60 сек.", SCRIPT_COLOR)
                    end
                else
                    sampAddChatMessage(SCRIPT_PREFIX .. "Ошибка отправки отчёта: " .. tostring(r1), SCRIPT_COLOR)
                end
            end
            local ok2, r3, r4 = pcall(processLeaderboard, lastLbDailyDate, lastLbWeeklyDate)
            if ok2 then
                lastLbDailyDate, lastLbWeeklyDate = r3, r4
            else
                print("ResHelper: processLeaderboard error: " .. tostring(r3))
            end
        end
if not achievementUpdateTime or os.time() - achievementUpdateTime >= 60 then
            achievementUpdateTime = os.time()
            updateProgressAchievements()
        end
        if os.time() - lastAnnouncementCheck >= 600 then
            lastAnnouncementCheck = os.time()
            local okAnn, errAnn = pcall(downloadAnnouncements)
            if not okAnn then print("ResHelper: downloadAnnouncements error: " .. tostring(errAnn)) end
        end
        processMenuToggle()
        if not mainWin.v and not devImportantCurrent and not notifHistoryPopupOpen and imgui.ShowCursor then imgui.ShowCursor = false end
        if not sampIsChatInputActive() and not sampIsDialogActive() then binderStart() end
        local now = os.time()
        for resKey, data in pairs(pendingResourcesBuffer) do
            if data and now - data.time > 3 then
                pendingResourcesBuffer[resKey] = nil
            end
        end
        processTimer()
        processAutoAd()
        updateWindowAnim()
        local needRender = mainWin.v or isWindowAnimating() or settings.farmOverlayEnabled or settings.mineOverlayEnabled or settings.sawmillOverlayEnabled or settings.oilOverlayEnabled or settings.taxiOverlayEnabled or settings.incassOverlayEnabled or (#achievementNotifications > 0) or (#devNotifications > 0) or (#devImportantQueue > 0) or devImportantCurrent or notifHistoryPopupOpen
        if imgui.Process ~= needRender then imgui.Process = needRender end
    end
end
-- ====== TELEGRAM FUNCTIONS ======
local function urlencode(str)
    if str then
        str = string.gsub(str, "\n", "\r\n")
        str = string.gsub(str, "([^%w ])", function(c)
            return string.format("%%%02X", string.byte(c))
        end)
        str = string.gsub(str, " ", "+")
    end
    return str
end
local function encodeToUrl(str)
    return (urlencode(u8:encode(str, "CP1251")))
end
-- Добавление сообщения в очередь
function queueTelegramMessage(text)
    if not tgConfig.enabled or tgConfig.botToken == "" or tgConfig.chatId == "" then
        return
    end
    table.insert(tgMessageQueue, {text = text, time = os.time()})
    -- Ограничиваем очередь 50 сообщениями
    while #tgMessageQueue > 50 do
        table.remove(tgMessageQueue, 1)
    end
end
-- Отправка из очереди (вызывается из main loop)
function processTgQueue()
    if tgQueueProcessing then return end
    if #tgMessageQueue == 0 then return end
    
    tgQueueProcessing = true
    tgQueueProcessingStartTime = os.time()
    local msg = table.remove(tgMessageQueue, 1)
    
    local botToken = tgConfig.botToken
    local chatId = tgConfig.chatId
    
    local params = {
        text = msg.text,
        chat_id = chatId,
        parse_mode = "HTML",
        disable_web_page_preview = "true"
    }
    
    local queryString = ""
    for k, v in pairs(params) do
        queryString = queryString .. k .. "=" .. encodeToUrl(v) .. "&"
    end
    queryString = queryString:gsub("&$", "")
    
    local url
    local headers = {}
    
    if tgConfig.useReserveServer then
        url = "https://149.154.167.220/bot" .. botToken .. "/sendMessage?" .. queryString
        headers = {["Host"] = "api.telegram.org"}
    else
        url = "https://api.telegram.org/bot" .. botToken .. "/sendMessage?" .. queryString
    end
    
    local asyncReq = effil.thread(function(reqUrl, reqHeaders)
        local req = require("requests")
        local ok, result = pcall(req.get, reqUrl, { headers = reqHeaders })
        if ok and result then
            return result.text
        else
            return nil
        end
    end)(url, headers)
    
    lua_thread.create(function()
        local startTime = os.time()
        while true do
            if os.time() - startTime > 30 then
                tgQueueProcessing = false
                msg.retries = (msg.retries or 0) + 1
                if msg.retries <= 3 then
                    table.insert(tgMessageQueue, 1, msg)
                else
                    print("ResHelper TG: сообщение потеряно после 3 попыток (таймаут)")
                end
                return
            end
            local status, err = asyncReq:status()
            if not err then
                if status == "completed" then
                    tgQueueProcessing = false
                    local resultText = asyncReq:get()
                    local respOk = resultText and resultText:match('"ok":(%a+)')
                    if respOk ~= "true" then
                        print("ResHelper TG: ошибка ответа Telegram: " .. tostring(resultText))
                        msg.retries = (msg.retries or 0) + 1
                        if msg.retries <= 3 then
                            table.insert(tgMessageQueue, 1, msg)
                        else
                            print("ResHelper TG: сообщение потеряно после 3 попыток (ответ ошибки)")
                        end
                    end
                    return
                elseif status == "canceled" then
                    tgQueueProcessing = false
                    msg.retries = (msg.retries or 0) + 1
                    if msg.retries <= 3 then
                        table.insert(tgMessageQueue, 1, msg)
                    else
                        print("ResHelper TG: сообщение потеряно после 3 попыток (canceled)")
                    end
                    return
                end
            else
                tgQueueProcessing = false
                msg.retries = (msg.retries or 0) + 1
                if msg.retries <= 3 then
                    table.insert(tgMessageQueue, 1, msg)
                else
                    print("ResHelper TG: сообщение потеряно после 3 попыток (ошибка потока: " .. tostring(err) .. ")")
                end
                return
            end
            wait(0)
        end
    end)
end
local function parsePaydayLine(text)
    if not text then return end
    if extractChatSenderNick(text) then return end
    
    -- Зарплата
    if text:find("сумма в банке") then
        local n = text:match("%(([^%)]+)%)")
        if n then
            n = n:gsub("%D", "")
            if #n > 0 then 
                paydaySalary = paydaySalary + tonumber(n)
            end
        end
        return
    end
    
    -- Зарплата (Vice City)
    if text:find("Общая заработная плата") and getCurrentServer() == "Vice City" then
        paydayLinesSeen = true
        local n = text:match("заработная плата[^%d]*([%d%.,]+)")
        if n then
            n = n:gsub("%D", "")
            if #n > 0 then paydaySalary = paydaySalary + tonumber(n) end
        end
        return
    end

    -- Депозит
    if text:find("сумма на депозите") then
        paydayLinesSeen = true
        local n = text:match("%(([^%)]+)%)")
        if n then
            n = n:gsub("%D", "")
            if #n > 0 then 
                paydayDeposit = tonumber(n)
            end
        end
        return
    end
    
    -- AZ со счета донат
    if text:find("Баланс на донат") then
        local azBal = text:match("%+(%d+) AZ")
        if azBal then
            paydayAZ = paydayAZ + tonumber(azBal)
            addAzBreakdownEntry(paydayAzBreakdown, u8("Баланс доната"), tonumber(azBal))
        end
        return
    end
    
    -- Семейные выплаты
    if text:find("Семейные выплаты") then
        local f = text:match("Семейные выплаты[^%d]*([%d%.]+)")
        if f then
            f = f:gsub("%D", "")
            if #f > 0 then 
                paydayAccBonus = paydayAccBonus + tonumber(f)
				paydayAccBreakdown.family = paydayAccBreakdown.family + tonumber(f)
            end
        end
        return
    end
end
paydayAccBreakdown = {dividend = 0, accessory = 0, family = 0}
paydayAzBreakdown = {}
pendingPaydayAZ = {}
pendingPaydayRub = {}
lastPaydayEntry = nil
lastPaydayEntryTime = 0
function addAzBreakdownEntry(tbl, label, amount)
    if not tbl or not amount or amount <= 0 or not label then return end
    for _, e in ipairs(tbl) do
        if e.label == label then e.amount = e.amount + amount; return end
    end
    table.insert(tbl, {label = label, amount = amount})
end
TALON_MAX_SINGLE = 1000 -- максимум талонов AZ за один раз; больше считаем сбоем учёта
function addTalonAZ(amount)
    if not amount or amount <= 0 then return end
    if amount > TALON_MAX_SINGLE then
        print("ResHelper: отброшен аномальный прирост талонов AZ: " .. tostring(amount))
        return
    end
    if paydayActive then
        paydayAZ = paydayAZ + amount
        addAzBreakdownEntry(paydayAzBreakdown, u8("Талон AZ"), amount)
    elseif lastPaydayEntry and (os.time() - lastPaydayEntryTime) <= 15 then
        lastPaydayEntry.az = (lastPaydayEntry.az or 0) + amount
        lastPaydayEntry.azBreakdown = lastPaydayEntry.azBreakdown or {}
        addAzBreakdownEntry(lastPaydayEntry.azBreakdown, u8("Талон AZ"), amount)
        pcall(savePaydayStats)
    else
        local now = os.time()
        table.insert(pendingPaydayAZ, {amount = amount, time = now, label = u8("Талон AZ")})
    end
end
function addPaydayCoinBonus(azAmount, rubAmount, label)
    azAmount = azAmount or 0
    rubAmount = rubAmount or 0
    if azAmount <= 0 and rubAmount <= 0 then return end
    if paydayActive then
        paydayAZ = paydayAZ + azAmount
        paydayRub = (paydayRub or 0) + rubAmount
        if azAmount > 0 and label then addAzBreakdownEntry(paydayAzBreakdown, label, azAmount) end
    elseif lastPaydayEntry and (os.time() - lastPaydayEntryTime) <= 15 then
        lastPaydayEntry.az = (lastPaydayEntry.az or 0) + azAmount
        lastPaydayEntry.rub = (lastPaydayEntry.rub or 0) + rubAmount
        if azAmount > 0 and label then
            lastPaydayEntry.azBreakdown = lastPaydayEntry.azBreakdown or {}
            addAzBreakdownEntry(lastPaydayEntry.azBreakdown, label, azAmount)
        end
        pcall(savePaydayStats)
    else
        local now = os.time()
        if azAmount > 0 then table.insert(pendingPaydayAZ, {amount = azAmount, time = now, label = label}) end
        if rubAmount > 0 then table.insert(pendingPaydayRub, {amount = rubAmount, time = now}) end
    end
end
-- Функция для безопасного создания потоков
function safeThreadCreate(func)
    local ok, err = pcall(function()
        lua_thread.create(function()
            local success, error_msg = pcall(func)
            if not success then
                print("ResHelper: Thread error: " .. tostring(error_msg))
            end
        end)
    end)
    if not ok then
        print("ResHelper: Failed to create thread: " .. tostring(err))
    end
end
function extractChatMessageBody(text)
    if not text then return nil end
    local t = text:gsub("{%x%x%x%x%x%x}", "")
    local body = t:match("^.-%[%d+%]%s*:%s*(.+)$")
    if not body then
        body = t:match("^.-%[%d+%]%s+[^:]-:%s*(.+)$")
    end
    if not body then
        body = t
    end
    body = body:gsub("^%s+", ""):gsub("%s+$", "")
    return body
end
function extractChatSenderNick(text)
    if not text then return nil end
    local t = text:gsub("{%x%x%x%x%x%x}", "")
    local nick = t:match("(%S+)%[%d+%]")
    return nick
end
function isChatMessageFiltered(text)
    if not chatFilterConfig.enabled or not text then return false end
    local body = extractChatMessageBody(text)
    local nick = extractChatSenderNick(text)
    for _, entry in ipairs(chatFilterConfig.filters) do
        if entry.enabled ~= false then
            local pattern = entry.text
            if pattern and pattern ~= "" then
                if entry.mode == "nick" then
                    if nick and nick == pattern then return true end
                elseif entry.mode == "standard" then
                    if body == pattern then return true end
                else
                    if text:find(pattern, 1, true) then return true end
                end
            end
        end
    end
    return false
end
RH_REAL_NICK = RH_REAL_NICK or nil
RH_NICK_LAST_ASK = RH_NICK_LAST_ASK or 0
RH_NICK_TRIES = RH_NICK_TRIES or 0
RH_NICK_WAIT_ID = nil
RH_NICK_WAIT_UNTIL = 0
RH_NICK_OK = RH_NICK_OK or {}
function rhNickValid(n)
    if type(n) ~= "string" then return false end
    if RH_NICK_OK[n] then return true end
    local s = n:gsub("^%[%d+%]", "")
    if s:match("^%a") ~= nil and s:find("_", 2, true) ~= nil then
        RH_NICK_OK[n] = true
        return true
    end
    return false
end
function rhAskNick()
    if os.time() - RH_NICK_LAST_ASK < 10 or RH_NICK_TRIES >= 3 then return end
    if not sampIsLocalPlayerSpawned() then return end
    local ok, myId = sampGetPlayerIdByCharHandle(PLAYER_PED)
    if not ok then return end
    RH_NICK_LAST_ASK = os.time()
    RH_NICK_TRIES = RH_NICK_TRIES + 1
    RH_NICK_WAIT_ID = myId
    RH_NICK_WAIT_UNTIL = os.time() + 6
    lua_thread.create(function()
        wait(300)
        sampSendChat("/id " .. myId)
    end)
end
function rhNickOnMessage(text)
    if not text or not RH_NICK_WAIT_ID or os.time() > RH_NICK_WAIT_UNTIL then return false end
    local clean = text:gsub("{%x%x%x%x%x%x}", "")
    local id, nick = clean:match("^%s*%[(%d+)%]%s+(%[%d+%][%w_%.]+)%s*|.-packetloss")
    if not id then id, nick = clean:match("^%s*%[(%d+)%]%s+([%w_%.]+)%s*|.-packetloss") end
    if id and tonumber(id) == RH_NICK_WAIT_ID and rhNickValid(nick) then
        RH_REAL_NICK = nick
        RH_NICK_WAIT_ID = nil
        return true
    end
    return false
end
if not RH_NICK_HOOKED then
    RH_NICK_HOOKED = true
    RH_ORIG_GETNICK = sampGetPlayerNickname
    sampGetPlayerNickname = function(id)
        local n = RH_ORIG_GETNICK(id)
        if rhNickValid(n) then return n end
        local ok, myId = sampGetPlayerIdByCharHandle(PLAYER_PED)
        if ok and myId == id then
            if RH_REAL_NICK then return RH_REAL_NICK end
            rhAskNick()
            if RH_NICK_WAIT_ID and os.time() <= RH_NICK_WAIT_UNTIL then return "" end
        end
        return n
    end
end
function hook.onServerMessage(color, text)
    if rhNickOnMessage(text) then return false end
    if isChatMessageFiltered(text) then return false end
    local ok, err = pcall(function()
        if not text then return end
        -- Сброс КД /vr после успешной отправки объявления в /ad (СМИ)
        local _, myPlayerIdForAdCd = sampGetPlayerIdByCharHandle(PLAYER_PED)
        local myNickForAdCd = sampGetPlayerNickname(myPlayerIdForAdCd) or ""
        if myNickForAdCd ~= "" and text:find(myNickForAdCd .. " [" .. tostring(myPlayerIdForAdCd) .. "]", 1, true) and text:find("Тел: :call", 1, true) then
            for _, adEntry in ipairs(autoAdConfig.ads) do
                if AUTO_AD_CHATS[adEntry.chatIdx + 1] == "/vr" then
                    adEntry.nextSend = os.time()
                end
            end
        end
        local cleanText = text:gsub("{%x%x%x%x%x%x}", "")
local azVip = cleanText:match("Вы получили (%d+) AZ")
if azVip and not cleanText:find("донат") and not extractChatSenderNick(text) then
            local vipLabel = cleanText:match("^%[([^%]]+)%]")
            vipLabel = vipLabel and u8(vipLabel) or u8("Прочее")
            local now = os.time()
            for i = #pendingPaydayAZ, 1, -1 do
                if now - pendingPaydayAZ[i].time > 60 then
                    table.remove(pendingPaydayAZ, i)
                end
            end
            table.insert(pendingPaydayAZ, {amount = tonumber(azVip), time = now, label = vipLabel})
            return
        end
        
        -- Пенсия бывшего администратора (AZ)
        if cleanText:find("пенсию бывшего администратора") and not extractChatSenderNick(text) then
            local n = cleanText:match("размере (%d+) AZ")
            if n then addPaydayCoinBonus(tonumber(n), 0, u8("Пенсия бывшего администратора")) end
            return
        end
        
        -- Монеты Контейнера / таксиста (AZ COINS на баланс аккаунта)
        if cleanText:find("AZ COINS на баланс аккаунта") and not extractChatSenderNick(text) then
            local n = cleanText:match("%+(%d+) AZ COINS")
            local coinLabel = u8("Монеты (AZ COINS)")
            if cleanText:find("Монет Контейнера") then coinLabel = u8("Монеты Контейнера")
            elseif cleanText:find("Монет таксиста") then coinLabel = u8("Монеты таксиста") end
            if n then addPaydayCoinBonus(tonumber(n), 0, coinLabel) end
            return
        end
        
        -- Монета Новой Мафии (AZ)
        if cleanText:find("Монету Новой Мафии") and not extractChatSenderNick(text) then
            local n = cleanText:match("%+(%d+) AZ")
            if n then addPaydayCoinBonus(tonumber(n), 0, u8("Монета Новой Мафии")) end
            return
        end
        
        -- Монета Доната (игровые рубли)
        if cleanText:find("игровых рублей на баланс") and not extractChatSenderNick(text) then
            local n = cleanText:match("%+(%d+) игровых рублей")
            if n then addPaydayCoinBonus(0, tonumber(n)) end
            return
        end
       
        -- АКСЕССУАР (Космическое сердце) - с защитой от повторов
        if text:find("аксессуара Космическое сердце") and text:find("Вы получили") and not extractChatSenderNick(text) then
            if not paydayAccessoryReceived then
                local amount = text:match("(%d+%.?%d*)")
                if amount then
                    amount = amount:gsub("%.", "")
                    local numAmount = tonumber(amount)
                    if numAmount and numAmount > 0 then
                        paydayAccBonus = paydayAccBonus + numAmount
                        paydayAccBreakdown.accessory = paydayAccBreakdown.accessory + numAmount
                        paydayAccessoryReceived = true
                    end
                end
            end
            return
        end
        
        -- ДИВИДЕНТНЫЙ ДОГОВОР (игнорируем чужие сообщения в чате с таким же текстом)
        if text:find("Дивидентный договор") and not extractChatSenderNick(text) then
            paydayHasDividend = true
            
            local a = text:match("%+[^%s]+")
            if a then
                a = a:gsub("%D", "")
                if #a > 0 then 
                    paydayAccBonus = paydayAccBonus + tonumber(a) 
                    paydayAccBreakdown.dividend = tonumber(a)
                end
            end
            
            if paydayActive then
                paydayActive = false
                paydayProcessing = true
                local totalAmount = paydaySalary + paydayDeposit + paydayAccBonus 
                if totalAmount > 0 or paydayAZ > 0 or (paydayRub or 0) > 0 then
                    -- Безопасная вставка в paydayLog
                    if not paydayLog then paydayLog = {} end
                    local newEntry = {
                        time = os.time(),
                        salary = paydaySalary,
                        deposit = paydayDeposit,
                        accesories = paydayAccBonus,
                        accBreakdown = {  
                            dividend = paydayAccBreakdown.dividend or 0,
                            accessory = paydayAccBreakdown.accessory or 0,
                            family = paydayAccBreakdown.family or 0
                        },
                        az = paydayAZ,
                        azBreakdown = paydayAzBreakdown,
                        rub = paydayRub or 0,
                        total = totalAmount
                    }
                    pcall(function()
                        table.insert(paydayLog, 1, newEntry)
                        while #paydayLog > 10000 do 
                            table.remove(paydayLog, #paydayLog) 
                        end
                        savePaydayStats()
                        lastPaydayEntry = newEntry
                        lastPaydayEntryTime = os.time()
                    end)
                    
                    -- Telegram уведомление через очередь (с задержкой — чтобы успели прийти AZ COINS/рубли отдельными строками)
                    if tgConfig.enabled and tgConfig.paydayEnabled then
                        local savedSalary = paydaySalary
                        local savedDeposit = paydayDeposit
                        local savedAcc = paydayAccBonus
                        local savedTotal = totalAmount
                        safeThreadCreate(function()
                            wait(5000)
                            pcall(function()
                                local savedAZ = newEntry.az or 0
                                local savedRub = newEntry.rub or 0
                                local paydayTodayTotal = 0
                                local todayDate = getGameDate()
                                for _, plog in ipairs(paydayLog) do
                                    if getGameDate(plog.time) == todayDate then
                                        paydayTodayTotal = paydayTodayTotal + (plog.total or 0)
                                    end
                                end
                                local paydayTodayAZ = 0
                                local paydayTodayRub = 0
                                for _, plog in ipairs(paydayLog) do
                                    if getGameDate(plog.time) == todayDate then
                                        paydayTodayAZ = paydayTodayAZ + (plog.az or 0)
                                        paydayTodayRub = paydayTodayRub + (plog.rub or 0)
                                    end
                                end
                                local savedTime = os.time()
                                local mskTimestamp = savedTime + 10800
                                local mskDate = os.date("!*t", mskTimestamp)
                                local timeStr = string.format("%02d:%02d", mskDate.hour, mskDate.min)
                                local dateStr = string.format("%02d.%02d.%04d", mskDate.day, mskDate.month, mskDate.year)
                                local azRubLine = formatNumber(savedAZ) .. " AZ"
                                if savedRub > 0 then azRubLine = azRubLine .. " | " .. formatNumber(savedRub) .. " RUB" end
                                local todayAzRubLine = formatNumber(paydayTodayAZ) .. " AZ"
                                if paydayTodayRub > 0 then todayAzRubLine = todayAzRubLine .. " | " .. formatNumber(paydayTodayRub) .. " RUB" end
                                local azLine = "&#128142; Получено AZ: <b>" .. formatNumber(savedAZ) .. "</b>"
                                if savedRub > 0 then azLine = azLine .. " | Получено рублей: <b>" .. formatNumber(savedRub) .. "</b>" end
                                local msg = "&#128176; <b>Вы получили пейдей!</b>\n\n" ..
                                            "<b>Вот статистика:</b>\n\n" ..
                                            "&#128178; Получено с зарплаты: <b>" .. formatNumber(savedSalary) .. "$</b>\n" ..
                                            "&#128179; Получено с депозита: <b>" .. formatNumber(savedDeposit) .. "$</b>\n" ..
                                            "&#128085; Получено с аксессуаров/предметов: <b>" .. formatNumber(savedAcc) .. "$</b>\n\n" ..
                                            azLine .. "\n\n" ..
                                            "&#128200; Ваш доход за пейдей: <b>" .. formatNumber(savedTotal) .. "$ | " .. azRubLine .. "</b>\n" ..
                                            "&#127758; Ваш доход с пейдеев за день: <b>" .. formatNumber(paydayTodayTotal) .. "$ | " .. todayAzRubLine .. "</b>\n\n" ..
                                            "&#128338; Время: " .. timeStr .. " (МСК)\n" ..
                                            "&#128197; Дата: " .. dateStr
                                queueTelegramMessage(msg)
                            end)
                        end)
                    end
                end
                paydayAccBonus = 0
                paydayAZ = 0
                paydayRub = 0
                paydayAccBreakdown = {dividend = 0, accessory = 0, family = 0}
                paydayAzBreakdown = {}
                paydayProcessing = false
            end
            return
        end
        
        -- PayDay 
        if text:find("БАНКОВСКИЙ ЧЕК") then
            paydayActive = true
            paydaySalary = 0
            paydayDeposit = 0
            local savedAccessory = paydayAccBreakdown.accessory or 0
			paydayAccessoryReceived = false
            paydayAccBreakdown = {dividend = 0, accessory = savedAccessory, family = 0}
            paydayAzBreakdown = {}
            local windowAZ = 0
            local nowChk = os.time()
            for i = 1, #pendingPaydayAZ do
                -- берём только записи не старше 60 секунд, старые не относятся к этому пейдею
                if nowChk - pendingPaydayAZ[i].time <= 60 then
                    windowAZ = windowAZ + pendingPaydayAZ[i].amount
                    addAzBreakdownEntry(paydayAzBreakdown, pendingPaydayAZ[i].label or u8("Прочее"), pendingPaydayAZ[i].amount)
                end
            end
            pendingPaydayAZ = {}
            paydayAZ = windowAZ
            
            local windowRub = 0
            for i = 1, #pendingPaydayRub do
                if nowChk - pendingPaydayRub[i].time <= 60 then
                    windowRub = windowRub + pendingPaydayRub[i].amount
                end
            end
            pendingPaydayRub = {}
            paydayRub = windowRub
            
            paydayHasDividend = false
            paydayLinesSeen = false
            paydayCheckTime = os.time()
            return
        end
        
        -- PayDay завершение
        if paydayActive and text:find("=====================", 1, true) then
            if paydaySalary == 0 and paydayDeposit == 0 and not paydayLinesSeen then
                return
            end
            
            paydayProcessing = true
            
            safeThreadCreate(function()
                wait(3000)
                if paydayHasDividend or not paydayActive then
                    paydayProcessing = false
                    return
                end
                
                paydayActive = false
                local totalAmount = paydaySalary + paydayDeposit + paydayAccBonus  
                if totalAmount > 0 or paydayAZ > 0 or (paydayRub or 0) > 0 then
                    -- Безопасная вставка в paydayLog
                    if not paydayLog then paydayLog = {} end
                    local newEntry = {
                        time = os.time(),
                        salary = paydaySalary,
                        deposit = paydayDeposit,
                        accesories = paydayAccBonus, 
                        accBreakdown = {  
                            dividend = paydayAccBreakdown.dividend or 0,
                            accessory = paydayAccBreakdown.accessory or 0,
                            family = paydayAccBreakdown.family or 0
                        },
                        az = paydayAZ,
                        azBreakdown = paydayAzBreakdown,
                        rub = paydayRub or 0,
                        total = totalAmount
                    }
                    pcall(function()
                        table.insert(paydayLog, 1, newEntry)
                        while #paydayLog > 10000 do 
                            table.remove(paydayLog, #paydayLog) 
                        end
                        savePaydayStats()
                        lastPaydayEntry = newEntry
                        lastPaydayEntryTime = os.time()
                    end)
                    
                    -- Telegram уведомление через очередь
                    if tgConfig.enabled and tgConfig.paydayEnabled then
                        pcall(function()
                            local savedSalary = paydaySalary
                            local savedDeposit = paydayDeposit
                            local savedAcc = paydayAccBonus
                            local savedAZ = paydayAZ
                            local savedRub = paydayRub or 0
                            local savedTotal = totalAmount
                            local paydayTodayTotal = 0
                            local todayDate = getGameDate()
                            for _, plog in ipairs(paydayLog) do
                                if getGameDate(plog.time) == todayDate then
                                    paydayTodayTotal = paydayTodayTotal + (plog.total or 0)
                                end
                            end
                            local paydayTodayAZ = 0
                            local paydayTodayRub = 0
                            for _, plog in ipairs(paydayLog) do
                                if getGameDate(plog.time) == todayDate then
                                    paydayTodayAZ = paydayTodayAZ + (plog.az or 0)
                                    paydayTodayRub = paydayTodayRub + (plog.rub or 0)
                                end
                            end
                            local savedTime = os.time()
                            local mskTimestamp = savedTime + 10800
                            local mskDate = os.date("!*t", mskTimestamp)
                            local timeStr = string.format("%02d:%02d", mskDate.hour, mskDate.min)
                            local dateStr = string.format("%02d.%02d.%04d", mskDate.day, mskDate.month, mskDate.year)
                            local azRubLine = formatNumber(savedAZ) .. " AZ"
                            if savedRub > 0 then azRubLine = azRubLine .. " | " .. formatNumber(savedRub) .. " RUB" end
                            local todayAzRubLine = formatNumber(paydayTodayAZ) .. " AZ"
                            if paydayTodayRub > 0 then todayAzRubLine = todayAzRubLine .. " | " .. formatNumber(paydayTodayRub) .. " RUB" end
                            local azLine = "&#128142; Получено AZ: <b>" .. formatNumber(savedAZ) .. "</b>"
                            if savedRub > 0 then azLine = azLine .. " | Получено рублей: <b>" .. formatNumber(savedRub) .. "</b>" end
                            local msg = "&#128176; <b>Вы получили пейдей!</b>\n\n" ..
                                        "<b>Вот статистика:</b>\n\n" ..
                                        "&#128178; Получено с зарплаты: <b>" .. formatNumber(savedSalary) .. "$</b>\n" ..
                                        "&#128179; Получено с депозита: <b>" .. formatNumber(savedDeposit) .. "$</b>\n" ..
                                        "&#128085; Получено с аксессуаров/предметов: <b>" .. formatNumber(savedAcc) .. "$</b>\n\n" ..
                                        azLine .. "\n\n" ..
                                        "&#128200; Ваш доход за пейдей: <b>" .. formatNumber(savedTotal) .. "$ | " .. azRubLine .. "</b>\n" ..
                                        "&#127758; Ваш доход с пейдеев за день: <b>" .. formatNumber(paydayTodayTotal) .. "$ | " .. todayAzRubLine .. "</b>\n\n" ..
                                        "&#128338; Время: " .. timeStr .. " (МСК)\n" ..
                                        "&#128197; Дата: " .. dateStr
                            queueTelegramMessage(msg)
                        end)
                    end
                end
                paydayAccBonus = 0
                paydayAZ = 0
                paydayRub = 0
                paydayAccBreakdown = {dividend = 0, accessory = 0, family = 0}
                paydayAzBreakdown = {}
                paydayProcessing = false
            end)
            return
        end
        
-- Парсинг строк пейдея (внутри чека)
local looksLikeOilMsg = text:find("получили нефти") or text:find("успешно продали бочку") or text:find("доплату от электрокомпании")
if paydayActive and not looksLikeOilMsg then
    parsePaydayLine(text)
    return
end
        
        if text:match("^%[%d+%]") or text:match("^[%w_%[%]]+:%s") or text:match("^.*сказал") or text:match("^.*говорит") then return end
		        local cleanText = text:gsub("{......}", "")
        
        -- Осколки тайников и NFT
        local newShardItemId = nil
if not cleanText:match("%[%d+%]%s*:%s") then
    newShardItemId = tonumber(cleanText:match("В пункт выдачи пришла посылка :item(%d+):"))
end
        if cleanText:match("^%[Хранилище предметов%] Добавлен новый предмет 'Осколок Тайника") or (newShardItemId and SHARD_ITEM_TO_NAME[newShardItemId]) then
            local shardName = cleanText:match("Осколок Тайника (.+)%(%d+ шт")
            if shardName then
                shardName = shardName:gsub("%s+$", "")
            end
            if not shardName and newShardItemId then
                shardName = SHARD_ITEM_TO_NAME[newShardItemId]
            end
            if shardName and shardNames[shardName] then
                local shardKey = shardNames[shardName]
                local price = resourcePrices[shardKey] or (globalPrices and globalPrices[shardKey]) or 0
                table.insert(shardLog, 1, {time = os.time(), name = shardName, amount = price})
                if #shardLog > 10000 then shardLog[#shardLog] = nil end
                saveShardStats()
                
                if tgConfig.enabled and tgConfig.shardEnabled then
                    pcall(function()
                        local mskTimestamp = os.time() + 10800
                        local mskDate = os.date("!*t", mskTimestamp)
                        local timeStr = string.format("%02d:%02d", mskDate.hour, mskDate.min)
                        local dateStr = string.format("%02d.%02d.%04d", mskDate.day, mskDate.month, mskDate.year)
                        local msg = "&#128142; <b>Выпадение осколка!</b>\n\n" ..
                                    "&#128142; Осколок Тайника " .. shardName .. "\n" ..
                                    "&#128176; Стоимость: <b>" .. formatNumber(price) .. "$</b>\n" ..
                                    "&#128338; Время: " .. timeStr .. " (МСК)\n" ..
                                    "&#128197; Дата: " .. dateStr
                        queueTelegramMessage(msg)
                    end)
                end
            end
            return
        end
        
        if cleanText:match("^%[Хранилище предметов%] Добавлен новый предмет 'Осколок NFT контейнера") or newShardItemId == NFT_SHARD_ITEM_ID then
            local price = resourcePrices["oskolok_nft"] or (globalPrices and globalPrices["oskolok_nft"]) or 0
            table.insert(shardLog, 1, {time = os.time(), name = "NFT контейнера", amount = price})
            if #shardLog > 200 then shardLog[#shardLog] = nil end
            saveShardStats()
            
            if tgConfig.enabled and tgConfig.shardEnabled then
                pcall(function()
                    local mskTimestamp = os.time() + 10800
                    local mskDate = os.date("!*t", mskTimestamp)
                    local timeStr = string.format("%02d:%02d", mskDate.hour, mskDate.min)
                    local dateStr = string.format("%02d.%02d.%04d", mskDate.day, mskDate.month, mskDate.year)
                    local msg = "&#128142; <b>Выпадение осколка!</b>\n\n" ..
                                "&#128142; Осколок NFT контейнера\n" ..
                                "&#128176; Стоимость: <b>" .. formatNumber(price) .. "$</b>\n" ..
                                "&#128338; Время: " .. timeStr .. " (МСК)\n" ..
                                "&#128197; Дата: " .. dateStr
                    queueTelegramMessage(msg)
                end)
            end
            return
        end
        
		-- Аренда комнаты дома (Arizona Rent)
        if text:find("Arizona Rent") then
            local cleanText = text:gsub("{......}", "")
            local hasSdali = cleanText:find("сдали комнату") ~= nil
            local hasArendu = cleanText:find("аренду игроку") ~= nil
            if hasSdali and hasArendu then
                local nick = cleanText:match("аренду игроку ([%w_]+)")
                local amountRaw = cleanText:match("([%d%.]+)%s*!")
                local amount = 0
                if amountRaw then
                    amount = tonumber((amountRaw:gsub("%D", ""))) or 0
                end
                
                if nick and amount > 0 then
                    table.insert(itemMarketLog, 1, {time = os.time(), nick = nick, amount = amount, rentType = "room"})
                    if #itemMarketLog > 10000 then
                        itemMarketLog[#itemMarketLog] = nil
                    end
                    saveItemMarketStats()
                    itemMarketTodayIncome = itemMarketTodayIncome + amount
                    
                    if tgConfig.itemMarketEnabled and amount >= 0 then
                        pcall(function()
                            local mskTimestamp = os.time() + 10800
                            local mskDate = os.date("!*t", mskTimestamp)
                            local timeStr = string.format("%02d:%02d", mskDate.hour, mskDate.min)
                            local dateStr = string.format("%02d.%02d.%04d", mskDate.day, mskDate.month, mskDate.year)
                            local msg = "&#127968; <b>Аренда комнаты - Дом</b>\n\n" ..
                                        "&#128100; Игрок: <b>" .. nick .. "</b>\n" ..
                                        "&#128176; Заработано: <b>" .. formatNumber(amount) .. "$</b>\n" ..
                                        "&#128338; Время: " .. timeStr .. " (МСК)\n" ..
                                        "&#128197; Дата: " .. dateStr .. "\n\n" ..
                                        "&#128200; Общий заработок за сегодня: <b>" .. formatNumber(itemMarketTodayIncome) .. "$</b>"
                            queueTelegramMessage(msg)
                        end)
                    end
                    
                    if settings.chatNotifyEnabled then
                        sampAddChatMessage("{00FF00}[ResHelperIM] {FFFFFF}Аренда комнаты от " .. nick .. ": +" .. formatNumber(amount) .. "$", -1)
                    end
                end
                return
            end
        end
        
        -- Item Market 
        if text:match("^%[Item Market%]") then
            local cleanText = text:gsub("{......}", "")
            local nick = cleanText:match("^%[Item Market%] (.+) арендовал")
            local amount = 0
            
            local afterNachisleno = cleanText:match("начислено (.+)$")
            if afterNachisleno then
                local digits = ""
                for d in afterNachisleno:gmatch("%d") do
                    digits = digits .. d
                end
                amount = tonumber(digits) or 0
                
                if afterNachisleno:find(":KK:") and not afterNachisleno:find(":KK:.*:K:") then
                    amount = amount * 1000000
                end
            end
            
            if nick and amount > 0 then
                table.insert(itemMarketLog, 1, {time = os.time(), nick = nick, amount = amount, rentType = "im"})
                if #itemMarketLog > 10000 then
                    itemMarketLog[#itemMarketLog] = nil
                end
                saveItemMarketStats()
                itemMarketTodayIncome = itemMarketTodayIncome + amount
                
                if tgConfig.itemMarketEnabled and amount >= 0 then
                    pcall(function()
                        local mskTimestamp = os.time() + 10800
                        local mskDate = os.date("!*t", mskTimestamp)
                        local timeStr = string.format("%02d:%02d", mskDate.hour, mskDate.min)
                        local dateStr = string.format("%02d.%02d.%04d", mskDate.day, mskDate.month, mskDate.year)
                        local msg = "&#128717; <b>Item Market - Аренда</b>\n\n" ..
                                    "&#128100; Игрок: <b>" .. nick .. "</b>\n" ..
                                    "&#128176; Заработано: <b>" .. formatNumber(amount) .. "$</b>\n" ..
                                    "&#128338; Время: " .. timeStr .. " (МСК)\n" ..
                                    "&#128197; Дата: " .. dateStr .. "\n\n" ..
                                    "&#128200; Общий заработок за сегодня: <b>" .. formatNumber(itemMarketTodayIncome) .. "$</b>"
                        queueTelegramMessage(msg)
                    end)
                end
                
                if settings.chatNotifyEnabled then
                    sampAddChatMessage("{00FF00}[ResHelperIM] {FFFFFF}Аренда от " .. nick .. ": +" .. formatNumber(amount) .. "$", -1)
                end
            end
            return
        end
        
        -- Покупка ларца/кейса у другого игрока - не считаем это выпадением
        if text:match("^Вы успешно купили") and text:match(" у [%w_]+ за ") then
            ignoreCaseDropUntil = os.time() + 3
        end
        -- Криптовалюта - глобальный учёт (только системные сообщения, не чат)
        if not text:match("%[[%w_]+%]") and not text:match("говорит") then
            local cryptoItemId = tonumber(text:match("Вам был добавлен предмет :item(%d+)[:.]")) or tonumber(text:match("В инвентарь добавлен предмет:%s*:item(%d+)[:.]"))
            if cryptoItemId and ALL_CRYPTO[cryptoItemId] then
                if os.time() < ignoreCaseDropUntil then
                    ignoreCaseDropUntil = 0
                else
                    local resKey = (cryptoItemId == 1811) and "crypto_btc" or "crypto_asc"
                    local amount = pendingResources[resKey] or 1
                    pendingResources[resKey] = nil
                    local coinName = ALL_CRYPTO[cryptoItemId]
                    if not cryptoConfig[cryptoItemId] then
                        cryptoConfig[cryptoItemId] = { name = coinName, cost = 0, count = 0 }
                    end
                    local realTotal = 0
                    if inventoryCache[cryptoItemId] then
                        for _, v in ipairs(inventoryCache[cryptoItemId]) do realTotal = realTotal + v end
                    end
                    cryptoConfig[cryptoItemId].count = realTotal > 0 and realTotal or (cryptoConfig[cryptoItemId].count + amount)
                    table.insert(cryptoLog, 1, {time = os.time(), itemId = cryptoItemId, name = coinName, amount = amount})
                    if #cryptoLog > 10000 then cryptoLog[#cryptoLog] = nil end
                    saveCryptoStats()
                    saveCryptoConfig()
                    if settings.chatNotifyEnabled then
                        sampAddChatMessage(SCRIPT_PREFIX .. "Получено: " .. coinName .. " x" .. amount .. " (всего: " .. cryptoConfig[cryptoItemId].count .. " шт.)", SCRIPT_COLOR)
                    end
                end
            end
        end
        -- Акции инкассатора - название и количество предмета, попавшего в инвентарь
        if not text:match("%[[%w_]+%]") and not text:match("говорит") then
            local stockItemId = tonumber(text:match("добавлен предмет:?%s*:item(%d+)[:.]"))
            if stockItemId and STOCKS[stockItemId] then
                local stockKey = "stock_" .. stockItemId
                if os.time() < ignoreCaseDropUntil then
                    ignoreCaseDropUntil = 0
                    pendingResources[stockKey] = nil
                elseif settings.incassEnabled and not incassWorkActive then
                    incassHintOnce()
                elseif settings.incassEnabled then
                    local stockAmount = pendingResources[stockKey]
                    pendingResources[stockKey] = nil
                    if stockAmount and stockAmount > 0 and os.time() - (stockPendingTime[stockKey] or 0) <= 5 then
                        addStockLog(stockItemId, stockAmount)
                    else
                        -- пакет инвентаря ещё не пришёл: ждём его, иначе записываем 1 шт.
                        pendingResourcesBuffer[stockKey] = {amount = 0, time = os.time()}
                        lua_thread.create(function()
                            wait(1000)
                            if pendingResourcesBuffer[stockKey] then
                                pendingResourcesBuffer[stockKey] = nil
                                addStockLog(stockItemId, 1)
                            end
                        end)
                    end
                end
            end
        end
        -- Инвестиции (ларцы) - глобальный учёт (только системные сообщения, не чат)
        if not text:match("%[[%w_]+%]") and not text:match("говорит") then
            local investItemId = tonumber(text:match("Вам был добавлен предмет :item(%d+)[:.]")) or tonumber(text:match("В инвентарь добавлен предмет:%s*:item(%d+)[:.]"))
            if investItemId and ALL_CASES[investItemId] then
                if os.time() < ignoreCaseDropUntil then
                    ignoreCaseDropUntil = 0
                else
                    local caseName = ALL_CASES[investItemId]
                    if not investmentConfig[investItemId] then
                        investmentConfig[investItemId] = { name = caseName, cost = getCasePrice(investItemId), count = 0 }
                    end
                    investmentConfig[investItemId].count = investmentConfig[investItemId].count + 1
                    local logEntry = {time = os.time(), itemId = investItemId, name = caseName}
                    table.insert(investmentLog, 1, logEntry)
                    if #investmentLog > 10000 then investmentLog[#investmentLog] = nil end
                    saveInvestmentStats()
                    saveInvestmentConfig()
                    if settings.chatNotifyEnabled then
                        lua_thread.create(function()
                            wait(400)
                            if not logEntry.cancelled then
                                sampAddChatMessage(SCRIPT_PREFIX .. "Выпал ларец: " .. caseName .. " (всего: " .. investmentConfig[investItemId].count .. " шт.)", SCRIPT_COLOR)
                            end
                        end)
                    end
                end
            end
        end
		
		        -- Кейсы для нефтевышек (привязываем к последней продаже бочки если она была недавно)
        local storageCaseName = nil
        if not text:match("%[[%w_]+%]") and not text:match("говорит") then
            local cleanStorageText = text:gsub("{......}", "")
            storageCaseName = cleanStorageText:match("%[Хранилище предметов%] Добавлен новый предмет '(.+)%(%d+ шт%.%)'")
            if not storageCaseName and not cleanStorageText:match("%[%d+%]%s*:%s") then
                local newFormatItemId = tonumber(cleanStorageText:match("В пункт выдачи пришла посылка :item(%d+):"))
                if newFormatItemId then storageCaseName = ALL_CASES[newFormatItemId] end
            end
        end
        if false and storageCaseName then
            local foundCaseId = nil
            for itemId, caseName in pairs(ALL_CASES) do
                if caseName == storageCaseName then
                    foundCaseId = itemId
                    break
                end
            end
            if foundCaseId then
                local caseName = ALL_CASES[foundCaseId]
                if not caseConfig[foundCaseId] then
                    caseConfig[foundCaseId] = { name = caseName, cost = 0, count = 0 }
                end
                caseConfig[foundCaseId].count = caseConfig[foundCaseId].count + 1
                local caseIncome = caseConfig[foundCaseId].cost
                -- Ищем последнюю продажу бочки в течение 60 секунд
                local lastSellIdx = nil
                local now = os.time()
                for i = 1, math.min(#oilLog, 20) do
                    if (oilLog[i].kind == "ground_money" or oilLog[i].kind == "water" or oilLog[i].kind == "ground_az") 
                        and (now - oilLog[i].time) <= 60 then
                        lastSellIdx = i
                        break
                    end
                end
                if lastSellIdx then
                    if oilLog[lastSellIdx].caseType == nil then
                        oilLog[lastSellIdx].caseType = foundCaseId
                        oilLog[lastSellIdx].caseCount = 1
                    else
                        oilLog[lastSellIdx].caseCount = (oilLog[lastSellIdx].caseCount or 0) + 1
                    end
                    oilLog[lastSellIdx].money = oilLog[lastSellIdx].money + caseIncome
                end
                saveCaseConfig()
                saveOilStats()
            end
        end
        
        -- Инвестиции (ларцы) - через /storage
        local storageInvName = nil
        if not text:match("%[[%w_]+%]") and not text:match("говорит") then
            storageInvName = text:match("%[Хранилище предметов%] Добавлен новый предмет '(.+)%(%d+ шт%.%)'")
            if not storageInvName and not text:match("%[%d+%]%s*:%s") then
                local newFormatInvItemId = tonumber(text:match("В пункт выдачи пришла посылка :item(%d+):"))
                if newFormatInvItemId then storageInvName = ALL_CASES[newFormatInvItemId] end
            end
        end
        if storageInvName then
            local foundInvId = nil
            for itemId, caseName in pairs(ALL_CASES) do
                if caseName == storageInvName then
                    foundInvId = itemId
                    break
                end
            end
            if foundInvId then
                local caseName = ALL_CASES[foundInvId]
                if not investmentConfig[foundInvId] then
                    investmentConfig[foundInvId] = { name = caseName, cost = getCasePrice(foundInvId), count = 0 }
                end
                investmentConfig[foundInvId].count = investmentConfig[foundInvId].count + 1
                table.insert(investmentLog, 1, {time = os.time(), itemId = foundInvId, name = caseName})
                if #investmentLog > 10000 then investmentLog[#investmentLog] = nil end
                saveInvestmentStats()
                saveInvestmentConfig()
                if settings.chatNotifyEnabled then
                    sampAddChatMessage(SCRIPT_PREFIX .. "Выпал ларец: " .. caseName .. " (всего: " .. investmentConfig[foundInvId].count .. " шт.)", SCRIPT_COLOR)
                end
            end
        end
		
        -- Изъятие ларца/рулетки из хранилища - откатываем счётчик, чтобы не было двойного учёта
        local cleanTakenText = text:gsub("{......}", "")
        local takenFromStorageName = cleanTakenText:match("Вы забрали предмет '(.+)%(%d+ шт%.%)', из хранилища%.")
        if takenFromStorageName then
            local foundTakenId = nil
            for itemId, caseName in pairs(ALL_CASES) do
                if caseName == takenFromStorageName then
                    foundTakenId = itemId
                    break
                end
            end
            if foundTakenId and investmentConfig[foundTakenId] and investmentConfig[foundTakenId].count > 0 then
                investmentConfig[foundTakenId].count = investmentConfig[foundTakenId].count - 1
                for i = 1, #investmentLog do
                    if investmentLog[i].itemId == foundTakenId then
                        investmentLog[i].cancelled = true
                        table.remove(investmentLog, i)
                        break
                    end
                end
                saveInvestmentStats()
                saveInvestmentConfig()
            end
        end
        -- Ферма и Шахта
        if text:match("^Вам был добавлен предмет") or text:match("В инвентарь добавлен предмет:") then
            local itemId = text:match(":item(%d+):")
            if itemId then
                local id = tonumber(itemId)
                
                -- Пропускаем кейсы (они обрабатываются в блоке нефтевышек)
                if ALL_CASES and ALL_CASES[id] then
                    return
                end
                -- Пропускаем крипту (обрабатывается отдельным блоком выше)
                if ALL_CRYPTO and ALL_CRYPTO[id] then
                    return
                end
                if id == 731 then
                    return
                end
                
                -- Покупка ресурса у другого игрока - не считаем это добычей
                if os.time() < ignoreCaseDropUntil then
                    ignoreCaseDropUntil = 0
                    return
                end
                
                -- Ферма
                if currentWork == WORK_TYPES.FARM then
                    local resKey = FARM_ITEM_TO_RES[id]
                    if resKey then
                        -- Кладём в буфер, пакетный обработчик сам засчитает когда подтвердит прирост
                        pendingResourcesBuffer[resKey] = {amount = 0, time = os.time()}
                        -- Попробуем засчитать сразу (если пакет уже пришёл)
                        local amount = pendingResources[resKey]
                        if amount and amount > 0 then
                            addResource(resKey, amount)
                            pendingResources[resKey] = nil
                            pendingResourcesBuffer[resKey] = nil
                        end
                    end
                end
                
                -- Шахта (подземная/лавка)
                if currentWork == WORK_TYPES.MINE then
                    if settings.undermineEnabled or settings.underminelavkaEnabled then
                        if text:find("Вы купили") then
                            if settings.underminelavkaEnabled then
                                local resKey = MINE_ITEM_TO_RES[id]
                                if resKey then
                                    local amount = text:match("%((%d+) шт%.%)")
                                    local removeAmount = tonumber(amount) or mineItemAmounts[resKey] or 1
                                    pcall(removeResource, resKey, removeAmount)
                                end
                            end
                        else
                            local resKey = MINE_ITEM_TO_RES[id]
                            if resKey then
                                -- Кладём в буфер, пакетный обработчик сам засчитает когда подтвердит прирост
                                pendingResourcesBuffer[resKey] = {amount = 0, time = os.time()}
                                -- Попробуем засчитать сразу (если пакет уже пришёл)
                                local amount = pendingResources[resKey]
                                if amount and amount > 0 then
                                    addResource(resKey, amount)
                                    pendingResources[resKey] = nil
                                    pendingResourcesBuffer[resKey] = nil
                                end
                            end
                        end
                    end
                end
                
                -- Лесопилка
                if currentWork == WORK_TYPES.SAWMILL then
                    local resKey = SAWMILL_ITEM_TO_RES[id]
                    if resKey then
                        -- Кладём в буфер, пакетный обработчик сам засчитает когда подтвердит прирост
                        pendingResourcesBuffer[resKey] = {amount = 0, time = os.time()}
                        -- Попробуем засчитать сразу (если пакет уже пришёл)
                        local amount = pendingResources[resKey]
                        if amount and amount > 0 then
                            addResource(resKey, amount)
                            pendingResources[resKey] = nil
                            pendingResourcesBuffer[resKey] = nil
                        end
                    end
                end
            end
            return
        end
        
        -- ================= Нефтевышки: учёт дохода с бочек =================
        if settings.oilEnabled and not oilWorkActive and (text:find("Вы успешно продали бочку", 1, true) or text:find("доплату от электрокомпании за бочку", 1, true)) then
            oilHintOnce()
        end
        if settings.oilEnabled and oilWorkActive then
            local oilText = text:gsub("{......}", "")
            if not oilPendingBonusAZ then oilPendingBonusAZ = 0 end
            -- Бонус зарплаты в %, применяется к следующей продаже бочки
            local oilBonusMoneyPct = oilText:match("%[Бонус зарплаты%].+, %+(%d+)")
            if oilBonusMoneyPct then
                oilBonusPercent = oilBonusPercent + tonumber(oilBonusMoneyPct)
            end
            -- Бонус AZ за задание/активность
            local oilBonusAZ = oilText:match("%[Бонус.+%] Вы получаете дополнительно (%d+) AZ.+")
            local oilBonusAZObl = oilText:match("%[Бонус.+%].+%+(%d+) AZ coins за активный.+")
            if oilBonusAZ or oilBonusAZObl then
                local azAmt = tonumber(oilBonusAZ or oilBonusAZObl)
                oilPendingBonusAZ = (oilPendingBonusAZ or 0) + azAmt
            end
            -- Продажа водной бочки
            local oilSoldLiters = oilText:match("Вы успешно продали бочку с ([%d%.]+) литров нефти")
            if oilSoldLiters then
                oilLastSoldLiters = tonumber(oilSoldLiters) or 0
            end
            local oilWaterSellRaw = nil
            if oilText:find("Вы успешно продали бочку") and not oilText:find("AZ%-Coins") then
                oilWaterSellRaw = oilText:match("получили .-([%d%.]+)")
            end
            -- Доплата от электрокомпании (за наземную бочку, деньгами)
            local oilGroundDollarsRaw = oilText:match("Вы получили доплату от электрокомпании за бочку в размере .-([%d%.]+)")
            if oilGroundDollarsRaw then
                local bonusMoney = tonumber((oilGroundDollarsRaw:gsub("[^%d]", "")))
                local lastSale = nil
                for i = 1, math.min(#oilLog, 3) do
                    local e = oilLog[i]
                    if e.kind == "water" and not e.companyMoney and os.time() - e.time <= 10 then
                        lastSale = e
                        break
                    end
                end
                if bonusMoney and lastSale then
                    lastSale.companyMoney = bonusMoney
                    lastSale.money = (lastSale.money or 0) + bonusMoney
                    oilSessionData.money = oilSessionData.money + bonusMoney
                    saveOilStats()
                    return
                end
                local az = 0
                if oilLastSoldLiters > 150 then az = 13 end
                addOilLog("ground_money", bonusMoney, az)
                oilLog[1].companyOnly = true
                saveOilStats()
                return
            end
            -- Продажа наземной бочки за AZ-Coins
            local oilGroundAZRaw = oilText:match("Вы успешно продали бочку с .+ литров нефти и получили (%d+) AZ%-Coins")
            if oilWaterSellRaw then
                local newMoney = tonumber((oilWaterSellRaw:gsub("[^%d]", "")))
                if newMoney then
                    local bonusSummarno = newMoney / (100 + oilBonusPercent) * oilBonusPercent
                    local isGroundBarrel = oilLastSoldLiters > 150
                    local kind = isGroundBarrel and "ground_money" or "water"
                    local az = isGroundBarrel and (oilConfig.groundBarrelAZBonus or 15) or 0
                    local companyBonus = oilConfig.groundBarrelCompanyBonus or 0
                    local totalMoney = isGroundBarrel and (newMoney + companyBonus) or newMoney
                    local finalAZ = az + (oilPendingBonusAZ or 0)
                    addOilLog(kind, totalMoney, finalAZ)
                    if not isGroundBarrel then
                        oilLog[1].saleMoney = newMoney
                        oilLog[1].bonusPct = oilBonusPercent
                        oilLog[1].bonusMoney = math.floor(bonusSummarno + 0.5)
                        saveOilStats()
                    end
                    if (oilPendingBonusAZ or 0) > 0 then
                        oilLog[1].isBonusAZ = true
                    end
                    oilPendingBonusAZ = 0
                    if settings.chatNotifyEnabled and oilBonusPercent > 0 then
                        sampAddChatMessage(SCRIPT_PREFIX .. "Ваша надбавка: " .. oilBonusPercent .. "% (" .. formatNumber(bonusSummarno) .. "$)", SCRIPT_COLOR)
                    end
                    oilBonusPercent = 0
                end
            elseif oilGroundAZRaw then
                local az = tonumber(oilGroundAZRaw)
                local realMoney = math.floor(oilConfig.groundOilMoney * (100 + oilBonusPercent) / 100)
                local bonusMoney = realMoney - oilConfig.groundOilMoney
                local finalAZ = az + (oilPendingBonusAZ or 0)
                addOilLog("ground_az", realMoney, finalAZ)
                if (oilPendingBonusAZ or 0) > 0 then
                    oilLog[1].isBonusAZ = true
                end
                oilPendingBonusAZ = 0
                if settings.chatNotifyEnabled and oilBonusPercent > 0 then
                    sampAddChatMessage(SCRIPT_PREFIX .. "Ваша надбавка: " .. oilBonusPercent .. "% (" .. formatNumber(bonusMoney) .. "$)", SCRIPT_COLOR)
                end
                oilBonusPercent = 0
            elseif oilText:find("Вы успешно купили бочку. Погрузите её в лодку или дирижабль!") then
                addOilLog("buy_water", -(oilConfig.barrelCost or 0), 0)
            elseif oilText:find("Вы успешно купили бочку. Погрузите её в автомобиль!") then
                addOilLog("buy_ground", 0, -(oilConfig.azBarrelCost or 0))
            end
        end
        do
            local incText = text:gsub("{......}", "")
            local incRaw = incText:match("^%[Инкассатор%] Получено за обслуживание банкомата:.-(%d[%d%.]*)")
            if incRaw and not extractChatSenderNick(text) then
                local incPaid = tonumber((incRaw:gsub("%.", "")))
                if incPaid and incPaid > 0 and settings.incassEnabled and not incassWorkActive then
                    incassHintOnce()
                elseif incPaid and incPaid > 0 and settings.incassEnabled then
                    addIncassLog(incPaid)
                    if settings.chatNotifyEnabled then
                        sampAddChatMessage(SCRIPT_PREFIX .. " Инкассатор: +" .. formatNumber(incPaid) .. "$", SCRIPT_COLOR)
                    end
                end
            end
        end
        do
            local taxiText = text:gsub("{......}", "")
            local taxiPaidRaw = taxiText:match("^%[Такси%] Клиент оплатил:%s*%S-([%d%.]+)")
            if taxiPaidRaw and not extractChatSenderNick(text) then
                local paid = tonumber((taxiPaidRaw:gsub("%.", "")))
                if paid and paid > 0 and settings.taxiEnabled then
                    addTaxiLog(paid)
                    if settings.chatNotifyEnabled then
                        sampAddChatMessage(SCRIPT_PREFIX .. " Такси: +" .. formatNumber(paid) .. "$", SCRIPT_COLOR)
                    end
                end
            end
        end
        return
    end)
    
    if not ok then
        print("ResHelper: onServerMessage error: " .. tostring(err))
    end
end
function hook.onCreate3DText(id, color, position, distance, testLOS, attachedPlayerId, attachedVehicleId, text)
    local ok, err = pcall(function()
        if not text or not text:find("бочк", 1, true) then return end
        local t3d = text:gsub("{......}", "")
        local dollNef = t3d:match("AZ%-Coins %+ :CASH:([%d%.,]+) за 1 бочку с нефтевышек Лас%-Вентурас")
        if dollNef then
            local price = tonumber((dollNef:gsub("%p", "")))
            if price and price ~= oilConfig.groundOilMoney then
                oilConfig.groundOilMoney = price
                saveOilConfig()
            end
        end
        if t3d:find("Водная нефтевышка", 1, true) then
            local waterRaw = t3d:match("Стоимость за [%d%.,]+ литров %(бочка%):[^%d]-([%d%.,]+)")
            if waterRaw then
                local waterPrice = tonumber((waterRaw:gsub("%p", "")))
                if waterPrice and waterPrice >= 1000 and waterPrice ~= oilConfig.barrelCost then
                    oilConfig.barrelCost = waterPrice
                    saveOilConfig()
                end
            end
        end
        local azRaw = t3d:match("Стоимость за [%d%.,]+ литров %(бочка%):%s*([%d%.,]+)%s*AZ%-Coins")
        if azRaw then
            local azPrice = tonumber((azRaw:gsub("%p", "")))
            if azPrice and azPrice >= 1 and azPrice <= 100000 and azPrice ~= oilConfig.azBarrelCost then
                oilConfig.azBarrelCost = azPrice
                saveOilConfig()
            end
        end
    end)
    if not ok then
        print("ResHelper: onCreate3DText error: " .. tostring(err))
    end
end
function hook.onDisplayGameText(style, tm, text)
    local ok, err = pcall(function()
        if not text then return end
        if currentWork == WORK_TYPES.FARM then 
            if not settings.farmEnabled then return end
            local resType, amount = text:match("^(%a+) %+(%d+)$")
            if resType and amount then 
                amount = tonumber(amount) or 1
                resType = resType:lower()
                if resType == "linen" then 
                    pcall(addResource, "flax", amount)
                elseif resType == "cotton" then 
                    pcall(addResource, "cotton", amount)
                end 
            end
        else 
            if not settings.regularmineEnabled then return end
            if type(text) ~= "string" then return end
            local resType, amount = text:match("^(%w+)%s%+%s?(%d+)$")
            if resType and amount then 
                amount = tonumber(amount)
                if not amount or amount <= 0 then return end
                local mapping = { stone = "stone", metal = "metal", gold = "gold", silver = "silver", bronze = "bronze" }
                if mapping[resType] then 
                    local success, addErr = pcall(addResource, mapping[resType], amount)
                    if not success then 
                        sampAddChatMessage("{FF0000}[ResHelherMine] Ошибка при добавлении ресурса: " .. tostring(addErr), -1) 
                    end 
                end
            end
        end
    end)
    
    if not ok then
        print("ResHelper: onDisplayGameText error: " .. tostring(err))
    end
end
function hook.onShowDialog(id, style, title, button1, button2, text)
    local ok, err = pcall(function()
        if id == 0 and text and text:find("Удача!") and (button1 == "Понял" or button2 == "Понял") then
            sampSendDialogResponse(id, 1, 0, -1)
            return true
        end
        if style == 5 and title and title:find("Выбор компании") and text then
            local lines = {}
            for line in text:gmatch("[^\r\n]+") do table.insert(lines, line) end
            local bestIdx, bestPayment = nil, -1
            for i = 2, #lines do
                local line = lines[i]
                if not line:find("Недоступно") and line:find("Доступно") then
                    local paymentRaw = line:match(":CASH:([%d%.]+)")
                    local payment = paymentRaw and tonumber((paymentRaw:gsub("%.", ""))) or nil
                    if payment and payment > bestPayment then
                        bestPayment = payment
                        bestIdx = i - 2
                    end
                end
            end
            if bestIdx then
                oilConfig.groundBarrelCompanyBonus = bestPayment
                saveOilConfig()
                sampAddChatMessage(SCRIPT_PREFIX .. "Выбрана компания с доплатой " .. formatNumber(bestPayment) .. "$ (авто)", SCRIPT_COLOR)
                sampSendDialogResponse(id, 1, bestIdx, "")
                return true
            end
        end
        if cryptoPriceDialogState.pending and text and text:find("центрального банка") then
            cryptoPriceDialogState.pending = false
            -- Разбиваем текст на строки для простого поиска
            local lines = {}
            for line in (text or ""):gmatch("[^\r\n]+") do
                table.insert(lines, line)
            end
            local btcPrice = 0
            local ascPrice = 0
            for _, line in ipairs(lines) do
                if line:find("Курс BTC") or line:find("Курс BТС") then
                    local raw = line:match(":CASH:([%d%.]+)")
                    if raw then
                        btcPrice = tonumber((raw:gsub("[^%d]", ""))) or 0
                    end
                end
                if line:find("Курс ASC") then
                    local raw = line:match(":CASH:([%d%.]+)")
                    if raw then
                        ascPrice = tonumber((raw:gsub("[^%d]", ""))) or 0
                    end
                end
            end
            local gotAny = false
            if btcPrice > 0 then
                if not cryptoConfig[1811] then cryptoConfig[1811] = { name = ALL_CRYPTO[1811], cost = 0, count = 0 } end
                cryptoConfig[1811].cost = btcPrice
                gotAny = true
            end
            if ascPrice > 0 then
                if not cryptoConfig[5996] then cryptoConfig[5996] = { name = ALL_CRYPTO[5996], cost = 0, count = 0 } end
                cryptoConfig[5996].cost = ascPrice
                gotAny = true
            end
            if gotAny then
                saveCryptoConfig()
                settings.cryptoPricesLastFetch = os.time()
                saveConfig()
                if settings.chatNotifyEnabled then
                    sampAddChatMessage(SCRIPT_PREFIX .. "Курсы крипты обновлены: BTC $" .. (cryptoConfig[1811] and cryptoConfig[1811].cost or 0) .. ", ASC $" .. (cryptoConfig[5996] and cryptoConfig[5996].cost or 0), SCRIPT_COLOR)
                end
            else
                sampAddChatMessage(SCRIPT_PREFIX .. "Не удалось распознать курс в ответе банка.", SCRIPT_COLOR)
            end
            sampSendDialogResponse(id, 1)
            lua_thread.create(function()
                wait(400)
                sampProcessChatInput("/phone")
            end)
            return true
        end
        if autoAdVrDialogState.pending then
            autoAdVrDialogState.pending = false
            if os.time() - autoAdVrDialogState.pendingTime <= 5 then
                local respIdx = autoAdVrDialogState.withAd and 1 or 0
                sampSendDialogResponse(id, respIdx)
                return true
            end
        end
        if autoAdAdDialogState.pending then
            if os.time() - autoAdAdDialogState.pendingTime > 8 then
                autoAdAdDialogState.pending = false
            elseif title and title:find("Выберите радиостанцию") and text and text:find("Радиостанция") then
                local lines = {}
                for line in (text or ""):gmatch("[^\r\n]+") do table.insert(lines, line) end
                local function elapsedSeconds(line)
                    local h = tonumber(line:match("(%d+)%s*час"))
                    local m = tonumber(line:match("(%d+)%s*мин"))
                    local s = tonumber(line:match("(%d+)%s*сек"))
                    if not (h or m or s) then return math.huge end -- нет времени = нет активности вообще
                    return (h or 0) * 3600 + (m or 0) * 60 + (s or 0)
                end
                local chosenIdx, bestElapsed = 0, math.huge
                for i = 2, #lines do
                    local line = lines[i]
                    if autoAdAdDialogState.radioIdx > 0 then
                        local stationName = AD_RADIO_STATIONS[autoAdAdDialogState.radioIdx]
                        if stationName and line:find(stationName) then
                            chosenIdx = i - 2
                            break
                        end
                    else
                        local elapsed = elapsedSeconds(line)
                        if elapsed < bestElapsed then
                            bestElapsed = elapsed
                            chosenIdx = i - 2
                        end
                    end
                end
                autoAdAdDialogState.pendingTime = os.time()
                sampSendDialogResponse(id, 1, chosenIdx, "")
                return true
            elseif title and title:find("тип объявления") then
                local typeIdx = autoAdAdDialogState.vip and 1 or 0
                autoAdAdDialogState.pendingTime = os.time()
                sampSendDialogResponse(id, 1, typeIdx, "")
                return true
            elseif title and title:find("Подача объявления") and title:find("Подтверждение") then
                autoAdAdDialogState.pending = false
                sampSendDialogResponse(id, 1, 65535, "")
                return true
            end
        end
        if not scanState.active or not scanState.scanning then return end
        
        if title and title:find("Основная статистика") then
            scanState.statusText = "Статистика открыта, ищу кнопку инвентаря..."
            local inventoryButtonIndex = nil
            if button1 and button1:find("Инвентарь") then inventoryButtonIndex = 1
            elseif button2 and button2:find("Инвентарь") then inventoryButtonIndex = 0 end
            if inventoryButtonIndex then
                scanState.statusText = "Открываю инвентарь..."
                scanState.waitForInventory = true
                sampSendDialogResponse(id, inventoryButtonIndex)
            else
                scanState.statusText = "Пробую открыть инвентарь (кнопка 1)..."
                scanState.waitForInventory = true
                sampSendDialogResponse(id, 1)
            end
            return true
        end
        
        if scanState.waitForInventory then
            if title and title:find("%[ID:%d+%]") then
                scanState.waitForInventory = false
                scanState.statusText = "Сканирую страницу инвентаря..."
                
                local nextPageListItem = nil
                local nextPageText = ""
                local currentItemIndex = 0
                local isHeaderSkipped = false
                
                if text then
                    for line in text:gmatch("[^\r\n]+") do 
                        if style == 5 and not isHeaderSkipped then
                            isHeaderSkipped = true
                        else
                            pcall(processInventoryLine, line)
                            if line:find(">> Следующая страница") then
                                nextPageListItem = currentItemIndex
                                nextPageText = line 
                            end
                            currentItemIndex = currentItemIndex + 1
                        end
                    end
                end
                
			if nextPageListItem then
                    scanState.statusText = "Переход на следующую страницу..."
                    scanState.waitForInventory = true
                    local dialogId, dialogItem, dialogText = id, nextPageListItem, nextPageText
                    lua_thread.create(function()
                        wait(150)
                        sampSendDialogResponse(dialogId, 1, dialogItem, dialogText)
                    end)
                    return true
                else
                    scanState.statusText = "Завершаю сканирование..."
                    sampSendDialogResponse(id, 0)
                    lua_thread.create(function() 
                        wait(500)
                        pcall(finishScan)
                    end)
                    return true
                end
            end
        end
    end)
    
if not ok then
        print("ResHelper: onShowDialog error: " .. tostring(err))
        if scanState.active then
            scanState.active = false
            scanState.scanning = false
            scanState.waitForInventory = false
            scanState.statusText = "Ошибка сканирования"
            sampAddChatMessage("{FF0000}[ResHelper] Ошибка при сканировании инвентаря. Попробуйте ещё раз.", -1)
        end
    elseif err == true then
        return false
    end
end
-- ====== GUI STYLE ======
function styleWin()
    imgui.SwitchContext()
    local style = imgui.GetStyle()
    local colors = style.Colors
    local clr = imgui.Col
    local ImVec4 = imgui.ImVec4
    style.WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
    style.ScrollbarSize = 15.0
    style.WindowRounding = 2.0
    style.ChildWindowRounding = 2.0
    style.FrameRounding = 3.0
    style.FramePadding = imgui.ImVec2(5, 3)
    style.ItemSpacing = imgui.ImVec2(5.0, 4.0)
    style.ScrollbarRounding = 0
    style.GrabMinSize = 8.0
    style.GrabRounding = 1.0
    style.ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
    colors[clr.FrameBg]                = ImVec4(0.20, 0.20, 0.20, 0.54)
    colors[clr.FrameBgHovered]         = ImVec4(0.30, 0.30, 0.30, 0.40)
    colors[clr.FrameBgActive]          = ImVec4(0.26, 0.98, 0.26, 0.30)
    colors[clr.TitleBg]                = ImVec4(0.04, 0.04, 0.04, 1.00)
    colors[clr.TitleBgActive]          = ImVec4(0.10, 0.10, 0.10, 1.00)
    colors[clr.TitleBgCollapsed]       = ImVec4(0.00, 0.00, 0.00, 0.51)
    colors[clr.CheckMark]              = ImVec4(0.26, 0.98, 0.26, 1.00)
    colors[clr.SliderGrab]             = ImVec4(0.26, 0.98, 0.26, 1.00)
    colors[clr.SliderGrabActive]       = ImVec4(0.26, 0.98, 0.26, 1.00)
    colors[clr.Button]                 = ImVec4(0.20, 0.20, 0.20, 0.60)
    colors[clr.ButtonHovered]          = ImVec4(0.26, 0.98, 0.26, 0.40)
    colors[clr.ButtonActive]           = ImVec4(0.26, 0.98, 0.26, 0.60)
    colors[clr.Header]                 = ImVec4(0.22, 0.22, 0.22, 0.50)
    colors[clr.HeaderHovered]          = ImVec4(0.26, 0.98, 0.26, 0.40)
    colors[clr.HeaderActive]           = ImVec4(0.26, 0.98, 0.26, 0.60)
    colors[clr.Separator]              = ImVec4(0.20, 0.20, 0.20, 1.00)
    colors[clr.SeparatorHovered]       = ImVec4(0.26, 0.98, 0.26, 0.40)
    colors[clr.SeparatorActive]        = ImVec4(0.26, 0.98, 0.26, 0.60)
    colors[clr.ResizeGrip]             = ImVec4(0.26, 0.98, 0.26, 0.25)
    colors[clr.ResizeGripHovered]      = ImVec4(0.26, 0.98, 0.26, 0.67)
    colors[clr.ResizeGripActive]       = ImVec4(0.26, 0.98, 0.26, 0.95)
    colors[clr.TextSelectedBg]         = ImVec4(0.26, 0.98, 0.26, 0.35)
    colors[clr.Text]                   = ImVec4(1.00, 1.00, 1.00, 1.00)
    colors[clr.TextDisabled]           = ImVec4(0.50, 0.50, 0.50, 1.00)
    colors[clr.WindowBg]               = ImVec4(0.08, 0.08, 0.08, 0.94)
    colors[clr.ChildWindowBg]          = ImVec4(0.09, 0.09, 0.09, 0.00)
    colors[clr.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 0.94)
    colors[clr.Border]                 = ImVec4(0.20, 0.20, 0.20, 0.50)
    colors[clr.BorderShadow]           = ImVec4(0.00, 0.00, 0.00, 0.00)
    colors[clr.MenuBarBg]              = ImVec4(0.10, 0.10, 0.10, 1.00)
    colors[clr.ScrollbarBg]            = ImVec4(0.02, 0.02, 0.02, 0.53)
    colors[clr.ScrollbarGrab]          = ImVec4(0.20, 0.20, 0.20, 1.00)
    colors[clr.ScrollbarGrabHovered]   = ImVec4(0.30, 0.30, 0.30, 1.00)
    colors[clr.ScrollbarGrabActive]    = ImVec4(0.26, 0.98, 0.26, 1.00)
    colors[clr.CloseButton]            = ImVec4(0.30, 0.30, 0.30, 0.50)
end
styleWin()
function ShowHelpMarker(stext)
    imgui.TextDisabled(u8("(?)"))
    if imgui.IsItemHovered() then
        rhTip(stext)
    end
end
local fa_font = nil
local fa_font_awesome = nil
local fa_glyph_ranges = imgui.ImGlyphRanges({ fa.min_range, fa.max_range })
function rhBeforeDrawFramePart1()
  if fa_font == nil then
    local font_config = imgui.ImFontConfig()
    font_config.MergeMode = true
    if doesFileExist(getWorkingDirectory().."/ResHelper/files/font-icon.ttf") then
    fa_font = imgui.GetIO().Fonts:AddFontFromFileTTF('moonloader/ResHelper/files/font-icon.ttf', 15.0, font_config, fa_glyph_ranges)
end
  end
  if fa_font_awesome == nil then
    local faPath = getWorkingDirectory() .. "/ResHelper/files/fAwesome6.ttf"
    if doesFileExist(faPath) then
      local font_config = imgui.ImFontConfig()
      font_config.MergeMode = true
      fa_font_awesome = imgui.GetIO().Fonts:AddFontFromFileTTF(faPath, 15.0, font_config, fa_glyph_ranges)
    end
  end
end
rhBigFont = nil
rhBigFontTried = false
function imgui.BeforeDrawFrame()
    RT.active = false
    rhBeforeDrawFramePart1()
    if not rhBigFontTried then
        rhBigFontTried = true
        pcall(function()
            local fontsDir = getFolderPath(0x14)
            local candidates = {fontsDir .. "\\segoeuib.ttf", fontsDir .. "\\arialbd.ttf", fontsDir .. "\\arial.ttf"}
            for _, path in ipairs(candidates) do
                if doesFileExist(path) then
                    local fio = imgui.GetIO()
                    rhBigFont = fio.Fonts:AddFontFromFileTTF(path, 28.0, imgui.ImFontConfig(), fio.Fonts:GetGlyphRangesCyrillic())
                    break
                end
            end
        end)
    end
end
function binderIconBtn(dl, id, bx, by, size, icon, col, tip)
    local P = imgui.ImVec2
    imgui.SetCursorScreenPos(P(bx, by))
    local clicked = imgui.InvisibleButton(id, P(size, size))
    local hv = imgui.IsItemHovered()
    local a = rhAnim(id, hv and 1 or 0)
    dl:AddRectFilled(P(bx, by), P(bx + size, by + size), rhAlpha(col, 0.06 + 0.18 * a), 10)
    dl:AddRect(P(bx, by), P(bx + size, by + size), rhAlpha(col, 0.25 + 0.55 * a), 10, 15, 1.0)
    local sz = imgui.CalcTextSize(icon)
    dl:AddText(P(bx + (size - sz.x) / 2, by + (size - sz.y) / 2), rhLerpColor(PD.C.mute, col, 0.35 + 0.65 * a), icon)
    if hv then rhTip(tip) end
    return clicked
end
function imgui.BindCard(key, val, x, y, w)
    local dl = imgui.GetWindowDrawList()
    local P = imgui.ImVec2
    local C = PD.C
    local bg, brd = homeCardColors()
    local h = 58
    local a = rhAnim("bind_row_" .. key, PD.hov(x, y, w, h) and 1 or 0)
    rhCardBox(dl, x, y, w, h, rhLerpColor(bg, rhLerpColor(bg, 0xFFFFFFFF, 0.04), a), rhLerpColor(brd, C.green, 0.5 * a), 12)
    local bs = 34
    local bx, by = x + 14, y + (h - bs) / 2
    dl:AddRectFilled(P(bx, by), P(bx + bs, by + bs), rhAlpha(C.green, 0.12 + 0.08 * a), 10)
    dl:AddRect(P(bx, by), P(bx + bs, by + bs), rhAlpha(C.green, 0.40 + 0.30 * a), 10, 15, 1.0)
    local ns = tostring(key)
    local nsz = imgui.CalcTextSize(ns)
    dl:AddText(P(bx + (bs - nsz.x) / 2, by + (bs - nsz.y) / 2), C.green, ns)
    local keyNames = {}
    for _, vk in ipairs(val.v or {}) do table.insert(keyNames, vkeys.id_to_name(vk)) end
    local hasKey = #keyNames > 0
    local keyStr = hasKey and u8(table.concat(keyNames, " + ")) or u8("Не назначена")
    local pillW = imgui.CalcTextSize(keyStr).x + 20
    local btn, gap = 34, 8
    local btnY = y + (h - btn) / 2
    local delX = x + w - 14 - btn
    local editX = delX - gap - btn
    local pillX = editX - 16 - pillW
    rhPill(dl, pillX, y + (h - 22) / 2, keyStr, hasKey and C.sal or C.mute)
    local tx = x + 62
    dl:PushClipRect(P(tx, y), P(pillX - 12, y + h), true)
    local nm = (val.name and val.name ~= "") and u8(val.name) or u8("Без названия")
    dl:AddText(P(tx, y + 10), 0xFFFFFFFF, nm)
    local lines = #(val.text or {})
    local preview = u8(tostring((val.text and val.text[1]) or ""))
    dl:AddText(P(tx, y + 31), C.mute, u8("Строк: ") .. lines .. (preview ~= "" and (" | " .. preview) or ""))
    dl:PopClipRect()
    local act
    if binderIconBtn(dl, "##bind_edit_" .. key, editX, btnY, btn, fa.ICON_PENCIL_SQUARE_O, C.sal, u8("Редактировать")) then act = "edit" end
    if binderIconBtn(dl, "##bind_del_" .. key, delX, btnY, btn, fa.ICON_TRASH, 0xFF4646EB, u8("Удалить")) then act = "delete" end
    return act
end
function SegmentedTabs(id, names, current, width, icons, tips)
    local drawList = imgui.GetWindowDrawList()
    local pos = imgui.GetCursorScreenPos()
    local totalW = width or (imgui.GetWindowWidth() - 25)
    local h = 32
    local segW = totalW / #names
    local trackBg, trackBorder, actBg, actBorder, actText, hovBg, hovText, normText
    if useCustomTheme then
        trackBg = imVec4ToHex(CUSTOM_THEME.cardBg)
        trackBorder = imVec4ToHex(CUSTOM_THEME.cardBorder)
        actBg = imVec4ToHex(CUSTOM_THEME.buttonActive)
        actBorder = imVec4ToHex(CUSTOM_THEME.borderActive)
        actText = imVec4ToHex(CUSTOM_THEME.textActive)
        hovBg = imVec4ToHex(CUSTOM_THEME.buttonHover)
        hovText = imVec4ToHex(CUSTOM_THEME.textHover)
        normText = imVec4ToHex(CUSTOM_THEME.textNormal)
    else
        local th = THEME_CONFIGS[currentTheme] or THEME_CONFIGS[THEMES.DEFAULT]
        trackBg = rhLerpColor(th.rightPanelBg, 0xFF000000, 0.25)
        trackBorder = th.borderColor
        actBg, actBorder, actText = th.buttonActive, th.borderActive, th.textActive
        hovBg, hovText, normText = th.buttonHover, 0xFFCCCCCC, th.textNormal
    end
    drawList:AddRectFilled(pos, imgui.ImVec2(pos.x + totalW, pos.y + h), trackBg, 8)
    drawList:AddRect(pos, imgui.ImVec2(pos.x + totalW, pos.y + h), trackBorder, 8, 15, 1.0)
    local clicked = nil
    for i, name in ipairs(names) do
        local px = pos.x + (i - 1) * segW
        imgui.SetCursorScreenPos(imgui.ImVec2(px, pos.y))
        if imgui.InvisibleButton("##seg" .. id .. i, imgui.ImVec2(segW, h)) then clicked = i - 1 end
        local hov = imgui.IsItemHovered()
        if hov and tips and tips[i] then
            rhTipBegin()
            imgui.Text(tips[i])
            rhTipEnd()
        end
        local active = (current == i - 1)
        local a, b = imgui.ImVec2(px + 3, pos.y + 3), imgui.ImVec2(px + segW - 3, pos.y + h - 3)
        if active then
            drawList:AddRectFilled(a, b, actBg, 6)
            drawList:AddRect(a, b, actBorder, 6, 15, 1.0)
        elseif hov then
            drawList:AddRectFilled(a, b, hovBg, 6)
        end
        local label = (icons and icons[i]) and (icons[i] .. "  " .. name) or name
        local tw = imgui.CalcTextSize(label).x
        drawList:AddText(imgui.ImVec2(px + (segW - tw) / 2, pos.y + 9), active and actText or (hov and hovText or normText), label)
    end
    imgui.SetCursorScreenPos(imgui.ImVec2(pos.x, pos.y + h + 1))
    imgui.Dummy(imgui.ImVec2(totalW, 0))
    return clicked
end
function StyleButton(label, icon, width, isActive)
    local drawList = imgui.GetWindowDrawList()
    local pos = imgui.GetCursorScreenPos()
    local btnW = width or (imgui.GetWindowWidth() - 25)
    local btnH = 28
    
    local hovered = (imgui.GetMousePos().x >= pos.x and imgui.GetMousePos().x <= pos.x + btnW and 
                    imgui.GetMousePos().y >= pos.y and imgui.GetMousePos().y <= pos.y + btnH)
    
    local bg, border, col
    if useCustomTheme then
        if isActive then
            bg = imVec4ToHex(CUSTOM_THEME.buttonActive)
            border = imVec4ToHex(CUSTOM_THEME.borderActive)
            col = imVec4ToHex(CUSTOM_THEME.textActive)
        elseif hovered then
            bg = imVec4ToHex(CUSTOM_THEME.buttonHover)
            border = imVec4ToHex(CUSTOM_THEME.borderHover or CUSTOM_THEME.borderColor)
            col = imVec4ToHex(CUSTOM_THEME.textHover)
        else
            bg = imVec4ToHex(CUSTOM_THEME.cardBg)
            border = imVec4ToHex(CUSTOM_THEME.cardBorder)
            col = imVec4ToHex(CUSTOM_THEME.textNormal)
        end
    else
        if isActive then
            bg = 0xFF1E3D1E
            border = 0xFF1AE591
            col = 0xFF1AE591
        elseif hovered then
            bg = 0xFF222222
            border = 0xFF555555
            col = 0xFF1AE591
        else
            bg = 0xFF1A1A1A
            border = 0xFF333333
            col = 0xFF1AE591
        end
    end
    
    drawList:AddRectFilled(pos, imgui.ImVec2(pos.x + btnW, pos.y + btnH), bg, 4)
    drawList:AddRect(pos, imgui.ImVec2(pos.x + btnW, pos.y + btnH), border, 4, 15, 1.0)
    
    local textW = imgui.CalcTextSize(label).x
    local iconW = icon and 18 or 0
    local gap = icon and 4 or 0
    local totalW = iconW + gap + textW
    local startX = pos.x + (btnW - totalW) / 2
    
    local textH = imgui.CalcTextSize(label).y
    local iconH = icon and 14 or 0
    if icon then
        drawList:AddText(imgui.ImVec2(startX, pos.y + (btnH - iconH) / 2), col, icon)
        drawList:AddText(imgui.ImVec2(startX + iconW + gap, pos.y + (btnH - textH) / 2), col, label)
    else
        drawList:AddText(imgui.ImVec2(startX, pos.y + (btnH - textH) / 2), col, label)
    end
    
    imgui.SetCursorScreenPos(pos)
    local clicked = imgui.InvisibleButton("##stylebtn_" .. label:gsub(" ", "_"), imgui.ImVec2(btnW, btnH))
    imgui.SetCursorScreenPos(imgui.ImVec2(pos.x, pos.y + btnH + 3))
    
    return clicked
end
local function ToggleSwitch(label, boolVar, helpText)
    local drawList = imgui.GetWindowDrawList()
    local pos = imgui.GetCursorScreenPos()
    local switchWidth = 36
    local switchHeight = 20
    local circleRadius = 8
    local totalWidth = switchWidth + 10 + imgui.CalcTextSize(label).x
    
    -- Фон переключателя
    local bgColor = boolVar.v and 0xFF1AE591 or 0xFF444444
    drawList:AddRectFilled(pos, imgui.ImVec2(pos.x + switchWidth, pos.y + switchHeight), bgColor, 10)
    
    -- Кружок
    local circleX = boolVar.v and (pos.x + switchWidth - circleRadius - 3) or (pos.x + circleRadius + 3)
    drawList:AddCircleFilled(imgui.ImVec2(circleX, pos.y + switchHeight / 2), circleRadius, 0xFFFFFFFF)
    
    -- Текст (выровнен по центру переключателя)
    local textH = imgui.CalcTextSize(label).y
    local textColor = boolVar.v and 0xFF1AE591 or 0xFF888888
    drawList:AddText(imgui.ImVec2(pos.x + switchWidth + 10, pos.y + (switchHeight - textH) / 2), textColor, label)
    
    -- Невидимая кнопка для клика
    imgui.SetCursorScreenPos(pos)
    local clicked = imgui.InvisibleButton("##toggle_" .. label:gsub(" ", "_"), imgui.ImVec2(totalWidth, switchHeight))
    
    if clicked then
        boolVar.v = not boolVar.v
        return true
    end
    
    -- Подсказка
    if helpText then
        imgui.SameLine()
        ShowHelpMarker(helpText)
    end
    
    return false
end
function resetOverlayData(workType)
    local cfg = configs[workType]
    overlaySessionResources[workType] = {}
    for _, k in ipairs(cfg.resourceOrder) do
        overlaySessionResources[workType][k] = 0
    end
    overlaySessionActive[workType] = true
end
function drawSectionHeaderCard(drawList, cardX, cardY, listW, cardH, icon, title, bgCol, borderCol, accentCol, titleCol, expanded)
    local mp = imgui.GetMousePos()
    local hovered = (mp.x >= cardX and mp.x <= cardX + listW and mp.y >= cardY and mp.y <= cardY + cardH)
    local a = rhAnim("sec_" .. title, hovered and 1 or 0)
    local open = expanded and 1 or 0
    local baseBg, hoverBg, brd, ttl
    if useCustomTheme then
        baseBg = imVec4ToHex(CUSTOM_THEME.cardBg)
        hoverBg = imVec4ToHex(CUSTOM_THEME.cardBgHovered)
        brd, ttl = borderCol, titleCol
    else
        baseBg, hoverBg, brd, ttl = 0xFF181818, 0xFF1F1F1F, 0xFF2C2C2C, 0xFFFFFFFF
    end
    local bg = rhLerpColor(baseBg, hoverBg, a)
    local p0 = imgui.ImVec2(cardX, cardY)
    local p1 = imgui.ImVec2(cardX + listW, cardY + cardH)
    drawList:AddRectFilled(p0, p1, bg, 12)
    drawList:AddLine(imgui.ImVec2(cardX + 14, cardY + 1), imgui.ImVec2(cardX + listW - 14, cardY + 1), rhAlpha(0xFFFFFFFF, 0.05 + 0.05 * a), 1.0)
    drawList:AddRect(p0, p1, rhLerpColor(brd, accentCol, math.max(0.55 * a, 0.45 * open)), 12, 15, 1.0)
    local r = math.min(16, cardH / 2 - 7)
    local ic = imgui.ImVec2(cardX + 16 + r, cardY + cardH / 2)
    drawList:AddCircleFilled(ic, r + 6, rhAlpha(accentCol, 0.03 + 0.04 * a), 32)
    drawList:AddCircleFilled(ic, r, rhLerpColor(bg, accentCol, 0.16 + 0.12 * a), 32)
    drawList:AddCircle(ic, r, rhAlpha(accentCol, 0.35 + 0.5 * a), 32, 1.0)
    local iconSz = imgui.CalcTextSize(icon)
    drawList:AddText(imgui.ImVec2(ic.x - iconSz.x / 2, ic.y - iconSz.y / 2), accentCol, icon)
    drawList:AddText(imgui.ImVec2(ic.x + r + 14, cardY + (cardH - 14) / 2), ttl, title)
    local chip = imgui.ImVec2(cardX + listW - 24, cardY + cardH / 2)
    local ct = math.max(a, 0.6 * open)
    drawList:AddCircleFilled(chip, 12, rhLerpColor(rhLerpColor(bg, 0xFFFFFFFF, 0.06), accentCol, ct), 24)
    local chevron = expanded and fa.ICON_ANGLE_UP or fa.ICON_ANGLE_DOWN
    local chevSz = imgui.CalcTextSize(chevron)
    drawList:AddText(imgui.ImVec2(chip.x - chevSz.x / 2, chip.y - chevSz.y / 2), rhLerpColor(0xFF8A8A8A, 0xFF101010, ct), chevron)
end
RH_THEME_GROUPS = {
    {id = "menu", icon = "ICON_DESKTOP", title = "Цвета меню", items = {
        {"Акцентный цвет", "accent"}, {"Левая панель", "leftPanelBg"}, {"Правая панель", "rightPanelBg"},
        {"Цвет заголовка", "headerTitle"}, {"Текст в правой панели", "contentText"}, {"Фон активной кнопки", "buttonActive"},
        {"Фон кнопки (наведение)", "buttonHover"}, {"Обводка активной кнопки", "borderActive"}, {"Цвет разделителей", "borderColor"},
    }},
    {id = "text", icon = "ICON_FONT", title = "Цвета текста", items = {
        {"Текст (обычный)", "textNormal"}, {"Текст (активный)", "textActive"}, {"Текст (наведение)", "textHover"},
    }},
    {id = "elem", icon = "ICON_KEYBOARD_O", title = "Кнопки и поля", items = {
        {"Кнопки", "imguiButton"}, {"Кнопки (наведение)", "imguiButtonHovered"}, {"Кнопки (активные)", "imguiButtonActive"},
        {"Заголовки разделов", "collapsingHeader"}, {"Заголовки (наведение)", "collapsingHeaderHovered"}, {"Заголовки (активные)", "collapsingHeaderActive"},
        {"Прогресс-бар", "progressBar"}, {"Поля ввода", "frameBg"}, {"Поля ввода (наведение)", "frameBgHovered"}, {"Поля ввода (активные)", "frameBgActive"},
    }},
    {id = "cards", icon = "ICON_LIST", title = "Карточки", items = {
        {"Фон карточки", "cardBg"}, {"Фон при наведении", "cardBgHovered"}, {"Обводка карточки", "cardBorder"},
        {"Иконка в карточке", "cardIcon"}, {"Заголовок карточки", "cardTitle"},
        {"Фон кнопки (биндер)", "cardBtnBg"}, {"Кнопка при наведении", "cardBtnBgHovered"}, {"Текст/иконка кнопки", "cardBtnText"},
    }},
    {id = "stat", icon = "ICON_MONEY", title = "Статистика и таблицы", items = {
        {"Фон карточки", "statCardBg"}, {"Обводка карточки", "statCardBorder"}, {"Текст заголовка", "statCardLabel"},
        {"Значение (общее)", "statCardValue"}, {"Значение (сегодня)", "statCardValueToday"}, {"Значение (неделя)", "statCardValueWeek"},
        {"Текст AZ", "statCardAZ"}, {"Фон заголовка таблицы", "tableHeaderBg"}, {"Текст заголовка таблицы", "tableHeaderText"},
    }},
}
function rhSetPal()
    local p = {sub = 0xFF808080}
    if useCustomTheme then
        p.bg = imVec4ToHex(CUSTOM_THEME.cardBg)
        p.bgHov = imVec4ToHex(CUSTOM_THEME.cardBgHovered)
        p.brd = imVec4ToHex(CUSTOM_THEME.cardBorder)
        p.accent = imVec4ToHex(CUSTOM_THEME.cardIcon)
        p.title = imVec4ToHex(CUSTOM_THEME.cardTitle)
    else
        local th = THEME_CONFIGS[currentTheme] or THEME_CONFIGS[THEMES.DEFAULT]
        p.bg, p.bgHov, p.brd = 0xFF181818, 0xFF1F1F1F, 0xFF2C2C2C
        p.title = 0xFFFFFFFF
        if rhVc() then
            p.bg, p.bgHov, p.brd = 0xFF8C5E3B, 0xFF9A6C47, 0xFFEEC39C
        end
        p.accent = th.borderActive
        p.sub = th.textNormal
    end
    return p
end
function rhSetIcon(dl, cx, cy, r, icon, accent, bg, a)
    local c = imgui.ImVec2(cx, cy)
    dl:AddCircleFilled(c, r + 5, rhAlpha(accent, 0.03 + 0.04 * a), 32)
    dl:AddCircleFilled(c, r, rhLerpColor(bg, accent, 0.16 + 0.12 * a), 32)
    dl:AddCircle(c, r, rhAlpha(accent, 0.35 + 0.5 * a), 32, 1.0)
    local sz = imgui.CalcTextSize(icon)
    dl:AddText(imgui.ImVec2(cx - sz.x / 2, cy - sz.y / 2), accent, icon)
end
function rhSetFrame(pos, w, h, pal, a)
    local dl = imgui.GetWindowDrawList()
    local bg = rhLerpColor(pal.bg, pal.bgHov, a)
    local p0, p1 = imgui.ImVec2(pos.x, pos.y), imgui.ImVec2(pos.x + w, pos.y + h)
    dl:AddRectFilled(p0, p1, bg, 12)
    dl:AddLine(imgui.ImVec2(pos.x + 14, pos.y + 1), imgui.ImVec2(pos.x + w - 14, pos.y + 1), rhAlpha(0xFFFFFFFF, 0.05 + 0.05 * a), 1.0)
    dl:AddRect(p0, p1, rhLerpColor(pal.brd, pal.accent, 0.5 * a), 12, 15, 1.0)
    return bg
end
function rhSetHead(pos, w, pal, icon, title, desc, a, bg, rightPad, dim)
    local dl = imgui.GetWindowDrawList()
    local acc = dim and pal.sub or pal.accent
    rhSetIcon(dl, pos.x + 32, pos.y + 27, 16, icon, acc, bg, a)
    local tx = pos.x + 62
    dl:PushClipRect(imgui.ImVec2(tx, pos.y), imgui.ImVec2(pos.x + w - (rightPad or 16), pos.y + 54), true)
    local tcol = dim and pal.sub or pal.title
    if desc and desc ~= "" then
        dl:AddText(imgui.ImVec2(tx, pos.y + 10), tcol, title)
        dl:AddText(imgui.ImVec2(tx, pos.y + 29), rhLerpColor(pal.sub, 0xFFB0B0B0, a), desc)
    else
        local sz = imgui.CalcTextSize(title)
        dl:AddText(imgui.ImVec2(tx, pos.y + 27 - sz.y / 2), tcol, title)
    end
    dl:PopClipRect()
end
function rhSetCaption(text)
    local pal = rhSetPal()
    local pos = imgui.GetCursorScreenPos()
    imgui.GetWindowDrawList():AddText(imgui.ImVec2(pos.x + 6, pos.y + 8), rhAlpha(pal.accent, 0.95), text)
    imgui.SetCursorScreenPos(imgui.ImVec2(pos.x, pos.y + 30))
    imgui.Dummy(imgui.ImVec2(1, 0))
end
function rhSetToggle(id, icon, title, desc, on, tip, locked)
    local dl = imgui.GetWindowDrawList()
    local pal = rhSetPal()
    local w = imgui.GetWindowWidth() - 25
    local h = 54
    local pos = imgui.GetCursorScreenPos()
    local clicked = imgui.InvisibleButton("##st_" .. id, imgui.ImVec2(w, h))
    local hov = imgui.IsItemHovered()
    if locked then clicked = false end
    local a = rhAnim("stH_" .. id, (hov and not locked) and 1 or 0)
    local t = rhAnim("stT_" .. id, on and 1 or 0, 16)
    local bg = rhSetFrame(pos, w, h, pal, a)
    rhSetHead(pos, w, pal, icon, title, desc, a, bg, 82, locked)
    local x0, y0 = pos.x + w - 62, pos.y + h / 2 - 12
    local track = rhLerpColor(0xFF3C3C3C, locked and 0xFF555555 or pal.accent, t)
    dl:AddRectFilled(imgui.ImVec2(x0, y0), imgui.ImVec2(x0 + 44, y0 + 24), track, 12)
    dl:AddCircleFilled(imgui.ImVec2(x0 + 12 + 20 * t, y0 + 12), 9, locked and 0xFFAAAAAA or 0xFFFFFFFF, 20)
    if hov and tip then rhTip(tip) end
    imgui.SetCursorScreenPos(imgui.ImVec2(pos.x, pos.y + h + 6))
    imgui.Dummy(imgui.ImVec2(w, 0))
    return clicked
end
function rhSetFold(id, icon, title, desc, open)
    local dl = imgui.GetWindowDrawList()
    local pal = rhSetPal()
    local w = imgui.GetWindowWidth() - 25
    local h = 54
    local pos = imgui.GetCursorScreenPos()
    local clicked = imgui.InvisibleButton("##sf_" .. id, imgui.ImVec2(w, h))
    local hov = imgui.IsItemHovered()
    local a = rhAnim("sfH_" .. id, hov and 1 or 0)
    local o = rhAnim("sfO_" .. id, open and 1 or 0)
    local bg = rhSetFrame(pos, w, h, pal, math.max(a, 0.6 * o))
    rhSetHead(pos, w, pal, icon, title, desc, a, bg, 56)
    local chip = imgui.ImVec2(pos.x + w - 28, pos.y + h / 2)
    local ct = math.max(a, 0.6 * o)
    dl:AddCircleFilled(chip, 13, rhLerpColor(rhLerpColor(bg, 0xFFFFFFFF, 0.06), pal.accent, ct), 24)
    local chev = open and fa.ICON_ANGLE_UP or fa.ICON_ANGLE_DOWN
    local cs = imgui.CalcTextSize(chev)
    dl:AddText(imgui.ImVec2(chip.x - cs.x / 2, chip.y - cs.y / 2), rhLerpColor(0xFF8A8A8A, 0xFF101010, ct), chev)
    imgui.SetCursorScreenPos(imgui.ImVec2(pos.x, pos.y + h + 6))
    imgui.Dummy(imgui.ImVec2(w, 0))
    return clicked
end
function rhSetCardBegin(id, h, icon, title, desc, chipText, chipCol)
    local pal = rhSetPal()
    local w = imgui.GetWindowWidth() - 25
    local pos = imgui.GetCursorScreenPos()
    local bg = rhSetFrame(pos, w, h, pal, 0)
    local pad = 16
    if chipText then
        local dl = imgui.GetWindowDrawList()
        local tw = imgui.CalcTextSize(chipText).x
        local x1 = pos.x + w - 16
        local x0 = x1 - tw - 22
        local y0 = pos.y + 17
        dl:AddRectFilled(imgui.ImVec2(x0, y0), imgui.ImVec2(x1, y0 + 22), rhAlpha(chipCol, 0.16), 11)
        dl:AddRect(imgui.ImVec2(x0, y0), imgui.ImVec2(x1, y0 + 22), rhAlpha(chipCol, 0.5), 11, 15, 1.0)
        dl:AddText(imgui.ImVec2(x0 + 11, y0 + 3), chipCol, chipText)
        pad = tw + 46
    end
    rhSetHead(pos, w, pal, icon, title, desc, 0, bg, pad)
    return pos, w, pal
end
function rhSetCardEnd(pos, w, h)
    imgui.SetCursorScreenPos(imgui.ImVec2(pos.x, pos.y + h + 6))
    imgui.Dummy(imgui.ImVec2(w, 0))
end
function rhSetBtn(id, icon, label, x, y, w, kind, h)
    local dl = imgui.GetWindowDrawList()
    local pal = rhSetPal()
    h = h or 34
    imgui.SetCursorScreenPos(imgui.ImVec2(x, y))
    local clicked = imgui.InvisibleButton("##sb_" .. id, imgui.ImVec2(w, h))
    local hov = imgui.IsItemHovered()
    local act = imgui.IsItemActive()
    local a = rhAnim("sbH_" .. id, hov and 1 or 0)
    local col = pal.accent
    if kind == "danger" then col = 0xFF5050F0 elseif kind == "warn" then col = 0xFF32BEFF end
    local bg = rhLerpColor(rhLerpColor(pal.bg, col, 0.10), rhLerpColor(pal.bg, col, 0.30), a)
    if act then bg = rhLerpColor(bg, 0xFF000000, 0.2) end
    local p0, p1 = imgui.ImVec2(x, y), imgui.ImVec2(x + w, y + h)
    dl:AddRectFilled(p0, p1, bg, 9)
    dl:AddRect(p0, p1, rhAlpha(col, 0.35 + 0.5 * a), 9, 15, 1.0)
    local text = icon and (label ~= "" and (icon .. "  " .. label) or icon) or label
    local sz = imgui.CalcTextSize(text)
    dl:PushClipRect(p0, p1, true)
    dl:AddText(imgui.ImVec2(x + (w - sz.x) / 2, y + (h - sz.y) / 2), col, text)
    dl:PopClipRect()
    return clicked
end
function rhSetBtnRow(id, list)
    local w = imgui.GetWindowWidth() - 25
    local pos = imgui.GetCursorScreenPos()
    local gap = 8
    local bw = (w - gap * (#list - 1)) / #list
    local res = nil
    for i, b in ipairs(list) do
        if rhSetBtn(id .. i, b[1], b[2], pos.x + (i - 1) * (bw + gap), pos.y, bw, b[3]) then res = i end
    end
    imgui.SetCursorScreenPos(imgui.ImVec2(pos.x, pos.y + 42))
    imgui.Dummy(imgui.ImVec2(w, 0))
    return res
end
function rhSetSound(id, title, desc, fileKey, defFile, volKey, volVar)
    local wav = getWavFiles()
    local st = rhSetSnd[id]
    if not st then st = {idx = imgui.ImInt(0), vol = imgui.ImInt(80)}; rhSetSnd[id] = st end
    if st.idx.v < 0 or st.idx.v >= #wav then st.idx.v = 0 end
    local cur = settings[fileKey] or defFile
    for i, f in ipairs(wav) do if f == cur then st.idx.v = i - 1; break end end
    local h = 100
    local pos, w, pal = rhSetCardBegin("snd_" .. id, h, fa.ICON_MUSIC, title, desc)
    local dl = imgui.GetWindowDrawList()
    local cw = math.max(120, math.floor((w - 32) * 0.40))
    local y = pos.y + 58
    imgui.SetCursorScreenPos(imgui.ImVec2(pos.x + 16, y))
    imgui.PushItemWidth(cw)
    if imgui.Combo("##sndf_" .. id, st.idx, table.concat(wav, "\0") .. "\0") then
        settings[fileKey] = wav[st.idx.v + 1]
        saveConfig()
    end
    imgui.PopItemWidth()
    local px = pos.x + 16 + cw + 8
    if rhSetBtn("sndp_" .. id, fa.ICON_PLAY, "", px, y - 2, 34, nil, 28) then
        playSoundFile(settings[fileKey] or defFile, settings[volKey] or 80)
    end
    local lbl = u8("Громкость")
    local lx = px + 34 + 14
    dl:AddText(imgui.ImVec2(lx, y + 3), pal.sub, lbl)
    local sx = lx + imgui.CalcTextSize(lbl).x + 10
    local sw = pos.x + w - 16 - sx
    local vol = volVar or st.vol
    vol.v = settings[volKey] or 80
    imgui.SetCursorScreenPos(imgui.ImVec2(sx, y))
    imgui.PushItemWidth(math.max(60, sw))
    if imgui.SliderInt("##sndv_" .. id, vol, 0, 100) then settings[volKey] = vol.v; saveConfig() end
    imgui.PopItemWidth()
    rhSetCardEnd(pos, w, h)
end
function rhSetColorGrid(items)
    local dl = imgui.GetWindowDrawList()
    local pal = rhSetPal()
    local w = imgui.GetWindowWidth() - 25
    local pos = imgui.GetCursorScreenPos()
    local cols = (w >= 460) and 2 or 1
    local gap = 8
    local cellW = (w - gap * (cols - 1)) / cols
    local rowH = 40
    local n = 0
    for _, it in ipairs(items) do
        local key = it[2]
        local val = CUSTOM_THEME[key]
        if val then
            local c = n % cols
            local r = math.floor(n / cols)
            n = n + 1
            local x = pos.x + c * (cellW + gap)
            local y = pos.y + r * (rowH + 6)
            imgui.SetCursorScreenPos(imgui.ImVec2(x, y))
            local clicked = imgui.InvisibleButton("##col_" .. key, imgui.ImVec2(cellW, rowH))
            local a = rhAnim("colH_" .. key, imgui.IsItemHovered() and 1 or 0)
            rhSetFrame(imgui.ImVec2(x, y), cellW, rowH, pal, a)
            local s0, s1 = imgui.ImVec2(x + 10, y + 8), imgui.ImVec2(x + 34, y + 32)
            dl:AddRectFilled(s0, s1, imVec4ToHex(val), 6)
            dl:AddRect(s0, s1, rhAlpha(0xFFFFFFFF, 0.35), 6, 15, 1.0)
            local label = u8(it[1])
            local sz = imgui.CalcTextSize(label)
            dl:PushClipRect(imgui.ImVec2(x + 44, y), imgui.ImVec2(x + cellW - 8, y + rowH), true)
            dl:AddText(imgui.ImVec2(x + 44, y + (rowH - sz.y) / 2), pal.title, label)
            dl:PopClipRect()
            if clicked then imgui.OpenPopup("ColorPicker##" .. key) end
            if imgui.BeginPopup("ColorPicker##" .. key) then
                local col = imgui.ImFloat4(val.x, val.y, val.z, val.w)
                if imgui.ColorPicker4("##picker" .. key, col, imgui.ColorEditFlags.NoSidePreview) then
                    local nv = imgui.ImVec4(col.v[1], col.v[2], col.v[3], col.v[4])
                    CUSTOM_THEME[key] = nv
                    if key == "leftPanelBg" then
                        CUSTOM_THEME.titleBg = imgui.ImVec4(col.v[1], col.v[2], col.v[3], col.v[4])
                    elseif key == "rightPanelBg" then
                        CUSTOM_THEME.windowBg = imgui.ImVec4(col.v[1], col.v[2], col.v[3], col.v[4])
                        CUSTOM_THEME.childBg = imgui.ImVec4(col.v[1], col.v[2], col.v[3], col.v[4])
                        CUSTOM_THEME.rightTitleBg = imgui.ImVec4(col.v[1], col.v[2], col.v[3], col.v[4])
                    end
                    saveCustomTheme()
                end
                imgui.EndPopup()
            end
        end
    end
    local rows = math.ceil(n / cols)
    imgui.SetCursorScreenPos(imgui.ImVec2(pos.x, pos.y + rows * (rowH + 6) + 2))
    imgui.Dummy(imgui.ImVec2(w, 0))
end
function rhSetPageLook()
    rhSetCaption(u8("Тема"))
    if rhSetToggle("customTheme", fa.ICON_PAINT_BRUSH, u8("Своя цветовая тема"), u8("Полная настройка цветов интерфейса"), cb_useCustomTheme.v, nil, rhVcThemeActive) then
        cb_useCustomTheme.v = not cb_useCustomTheme.v
        useCustomTheme = cb_useCustomTheme.v; saveThemeConfig(); needSave = true
    end
    if not useCustomTheme then
        local h = 92
        local pos, w = rhSetCardBegin("themes", h, fa.ICON_STAR, u8("Цветовая схема"), u8("Акцентный цвет главного меню"))
        local dl = imgui.GetWindowDrawList()
        for i, tid in ipairs(THEME_ORDER) do
            local cx, cy = pos.x + 32 + (i - 1) * 42, pos.y + 70
            imgui.SetCursorScreenPos(imgui.ImVec2(cx - 16, cy - 16))
            if imgui.InvisibleButton("##theme_sw" .. i, imgui.ImVec2(32, 32)) and not rhVcThemeActive then
                selectedThemeIdx.v = i - 1; currentTheme = tid; saveThemeConfig(); needSave = true
            end
            local hov = imgui.IsItemHovered()
            local a = rhAnim("thsw" .. i, hov and 1 or 0)
            dl:AddCircleFilled(imgui.ImVec2(cx, cy), 11 + 2 * a, THEME_CONFIGS[tid].borderActive, 24)
            if currentTheme == tid then dl:AddCircle(imgui.ImVec2(cx, cy), 16, 0xFFFFFFFF, 28, 2.0) end
            if hov then rhTip(u8(THEME_CONFIGS[tid].name)) end
        end
        rhSetCardEnd(pos, w, h)
    else
        if rhSetFold("themeEditor", fa.ICON_COG, u8("Редактор цветов"), u8("Каждый цвет интерфейса отдельно"), settingsExpandedCustomTheme) then
            settingsExpandedCustomTheme = not settingsExpandedCustomTheme
        end
        if settingsExpandedCustomTheme then
            for _, g in ipairs(RH_THEME_GROUPS) do
                if rhSetFold("thg_" .. g.id, fa[g.icon], u8(g.title), u8(#g.items .. " цв."), rhSetOpen[g.id]) then
                    rhSetOpen[g.id] = not rhSetOpen[g.id]
                end
                if rhSetOpen[g.id] then rhSetColorGrid(g.items) end
            end
            if rhSetBtnRow("resetTheme", {{fa.ICON_REPEAT, u8("Сбросить тему на стандартную"), "danger"}}) then
                resetCustomTheme(); saveCustomTheme()
            end
        end
    end
    -- Тема Vice City: включается автоматически при перелёте на VC
    local vcDesc = rhVcThemeActive and "Сейчас активна, ваши темы временно недоступны" or "Включать тему Vice City при перелёте на VC"
    if rhSetToggle("vcTheme", fa.ICON_STAR, u8("Тема Vice City"), u8(vcDesc), rhVcThemeEnabled,
        u8("Если выключить, на сервере Vice City останется ваша обычная тема.")) then
        rhVcThemeEnabled = not rhVcThemeEnabled
        pcall(rhApplyServerTheme, RH_DATA_SERVER)
        saveThemeConfig(); needSave = true
    end
    rhSetCaption(u8("Анимации"))
    if rhSetToggle("smoothMenu", fa.ICON_LIST, u8("Плавное меню слева"), u8("Выделение раздела плавно едет к новому пункту"), cb_smoothMenu.v,
        u8("Выделение текущего раздела будет плавно ехать к новому пункту меню, а не переключаться мгновенно.")) then
        cb_smoothMenu.v = not cb_smoothMenu.v
        settings.smoothMenuEnabled = cb_smoothMenu.v; saveConfig(); needSave = true
    end
    if rhSetToggle("smoothWindow", fa.ICON_DESKTOP, u8("Плавное открытие /rh"), u8("Окно и вкладки плавно появляются и исчезают"), cb_smoothWindow.v,
        u8("Окно /rh и переключение вкладок будут плавно появляться и исчезать, а не мгновенно.")) then
        cb_smoothWindow.v = not cb_smoothWindow.v
        settings.smoothWindowEnabled = cb_smoothWindow.v; saveConfig(); needSave = true
    end
    rhSetCaption(u8("Главный экран"))
    local items = {
        {"homeLogo", fa.ICON_STAR, "Логотип сверху", "Баннер ResHelper над сводкой", cb_homeShowLogo, "homeShowLogo", "Картинка-баннер ResHelper над сводкой, как в прошлых версиях."},
        {"homeSummary", fa.ICON_MONEY, "Сводка дохода за сегодня", "Большая карточка и полоса структуры дохода", cb_homeShowSummary, "homeShowSummary", "Большая карточка с доходом за сегодня и полосой структуры дохода."},
        {"homeTiles", fa.ICON_LIST, "Плитки источников дохода", "Пейдей, Ферма, Шахта, Лесопилка и другие", cb_homeShowTiles, "homeShowTiles", "Плитки Пейдей, Ферма, Шахта, Лесопилка и т.д."},
        {"homeGoals", fa.ICON_BULLSEYE, "Цели", "Цели на сегодня и кольцо «Цель дня»", cb_homeShowGoals, "homeShowGoals", "Карточка \"Цели на сегодня\" и кольцо \"Цель дня\" в сводке."},
        {"homeWork", fa.ICON_WRENCH, "Режим работы", "Выбор и продолжение текущей работы", cb_homeShowWork, "homeShowWork", "Карточка выбора и продолжения текущей работы."},
        {"homeHotkey", fa.ICON_KEYBOARD_O, "Клавиша активации меню", "Нижняя строка смены клавиши открытия", cb_homeShowHotkey, "homeShowHotkey", "Нижняя строка для смены клавиши открытия меню."},
    }
    for _, it in ipairs(items) do
        if rhSetToggle(it[1], it[2], u8(it[3]), u8(it[4]), it[5].v, u8(it[7])) then
            it[5].v = not it[5].v
            settings[it[6]] = it[5].v; saveConfig(); needSave = true
        end
    end
end
function rhSetPageSound()
    rhSetCaption(u8("Сообщения в чат"))
    if rhSetToggle("onlyImportant", fa.ICON_BELL, u8("Только важные уведомления"), u8("Запуск, проверка версии и обновление цен"), cb_notifyOnlyImportant.v,
        u8("Оставит только: запуск скрипта, проверку версии и обновление цен. Остальные сообщения скрипта в чат будут скрыты")) then
        cb_notifyOnlyImportant.v = not cb_notifyOnlyImportant.v
        settings.notifyOnlyImportant = cb_notifyOnlyImportant.v
        if settings.notifyOnlyImportant and settings.notifyHideStartup then
            settings.notifyHideStartup = false
            cb_notifyHideStartup.v = false
        end
        saveConfig(); needSave = true
    end
    if rhSetToggle("hideStartup", fa.ICON_TIMES, u8("Скрыть сообщения при запуске"), u8("Убирает сообщения сканирований при старте"), cb_notifyHideStartup.v,
        u8("Скроет только лишние сообщения сканирований при запуске скрипта. Остальные сообщения скрипта в чат останутся видны")) then
        cb_notifyHideStartup.v = not cb_notifyHideStartup.v
        settings.notifyHideStartup = cb_notifyHideStartup.v
        if settings.notifyHideStartup and settings.notifyOnlyImportant then
            settings.notifyOnlyImportant = false
            cb_notifyOnlyImportant.v = false
        end
        saveConfig(); needSave = true
    end
    if rhSetToggle("chatNotify", fa.ICON_BULLSEYE, u8("Уведомления о целях"), u8("Сообщение в чат при выполнении цели"), cb_chatNotify.v) then
        cb_chatNotify.v = not cb_chatNotify.v
        settings.chatNotifyEnabled = cb_chatNotify.v; saveConfig(); needSave = true
    end
    if rhSetToggle("devPopup", fa.ICON_BULLHORN, u8("Всплывающее окно новостей"), u8("Новости и изменения скрипта при запуске"), cb_devNotifPopup.v) then
        cb_devNotifPopup.v = not cb_devNotifPopup.v
        settings.devNotifPopupEnabled = cb_devNotifPopup.v; saveConfig(); needSave = true
    end
    rhSetCaption(u8("Звуки"))
    if rhSetToggle("goalSound", fa.ICON_TROPHY, u8("Звук при выполнении цели"), u8("Проигрывается, когда цель достигнута"), cb_goalSound.v) then
        cb_goalSound.v = not cb_goalSound.v
        settings.goalSoundEnabled = cb_goalSound.v; saveConfig(); needSave = true
    end
    if cb_goalSound.v then
        rhSetSound("goal", u8("Звук достижения"), u8("Файл и громкость звука цели"), "achivSoundFile", "achiv.wav", "goalSoundVolume", goal_vol_slider)
    end
    if rhSetToggle("pickupSound", fa.ICON_MUSIC, u8("Звуки при добыче ресурсов"), u8("Отдельный звук для редкости дропа"), cb_pickupSound.v) then
        cb_pickupSound.v = not cb_pickupSound.v
        settings.pickupSoundEnabled = cb_pickupSound.v; saveConfig(); needSave = true
    end
    if cb_pickupSound.v then
        rhSetSound("pickup", u8("Обычный дроп"), u8("Лён, Хлопок, Вода, Камень, Металл, Золото, Дрова..."), "pickupSoundFile", "pickup.wav", "pickupSoundVolume", pickup_vol_slider)
        rhSetSound("rare", u8("Редкий дроп"), u8("Алмаз, Редкая ткань, Древесина высшего качества"), "rareSoundFile", "rare.wav", "rareSoundVolume", nil)
        rhSetSound("coal", u8("Очень редкий дроп"), u8("Уголь, Прочная ткань, Шахтёрский сплав, Тёмная материя"), "coalSoundFile", "ugol.wav", "coalSoundVolume", nil)
    end
    imgui.Dummy(imgui.ImVec2(1, 4))
    local b = rhSetBtnRow("sndBtns", {
        {fa.ICON_REPEAT, u8("Обновить список звуков")},
        {fa.ICON_FOLDER_OPEN, u8("Открыть папку со звуками")},
    })
    if b == 1 then
        cachedWavFiles = nil
        achivFileIdx = nil; pickupFileIdx = nil; rareFileIdx = nil; coalFileIdx = nil
        rhSetSnd = {}
    elseif b == 2 then
        shell32.ShellExecuteA(nil, "open", soundsDir, nil, nil, 1)
    end
end
function rhSetPageTelegram()
    if rhSetToggle("tgEnabled", fa.ICON_PAPER_PLANE, u8("Telegram-уведомления"), u8("Главный переключатель отправки в Telegram"), tgConfig.enabled or false) then
        tgConfig.enabled = not tgConfig.enabled
        saveTgConfig(); needSave = true
    end
    rhSetCaption(u8("Подключение бота"))
    local ready = ((tgConfig.botToken or "") ~= "") and ((tgConfig.chatId or "") ~= "")
    local h = 168
    local pos, w, pal = rhSetCardBegin("tgConn", h, fa.ICON_COG, u8("Бот и чат"), u8("Токен и Chat ID сохраняются автоматически"),
        ready and u8("Готово") or u8("Не настроено"), ready and 0xFF50DC78 or 0xFF32BEFF)
    local dl = imgui.GetWindowDrawList()
    dl:AddText(imgui.ImVec2(pos.x + 16, pos.y + 60), pal.sub, u8("Токен бота (получить у @BotFather, команда /newbot)"))
    imgui.SetCursorScreenPos(imgui.ImVec2(pos.x + 16, pos.y + 78))
    imgui.PushItemWidth(w - 32)
    if imgui.InputText("##tg_token", tgTokenInput) then
        tgConfig.botToken = u8:decode(tgTokenInput.v)
        saveTgConfig()
    end
    imgui.PopItemWidth()
    dl:AddText(imgui.ImVec2(pos.x + 16, pos.y + 112), pal.sub, u8("Chat ID (получить у @chatIDrobot)"))
    imgui.SetCursorScreenPos(imgui.ImVec2(pos.x + 16, pos.y + 130))
    imgui.PushItemWidth(w - 32)
    if imgui.InputText("##tg_chatid", tgChatIdInput) then
        tgConfig.chatId = u8:decode(tgChatIdInput.v)
        saveTgConfig()
    end
    imgui.PopItemWidth()
    rhSetCardEnd(pos, w, h)
    if rhSetToggle("tgReserve", fa.ICON_REFRESH, u8("Резервный сервер (для России)"), u8("Включите, если Telegram заблокирован в регионе"), tgConfig.useReserveServer or false,
        u8("Включите если Telegram заблокирован в вашем регионе")) then
        tgConfig.useReserveServer = not tgConfig.useReserveServer
        saveTgConfig(); needSave = true
    end
    rhSetCaption(u8("Что присылать"))
    local list = {
        {"tgDaily", fa.ICON_CALENDAR, "Ежедневный отчёт", "За прошедший игровой день", "dailyReportEnabled",
            "Отправляет отчёт за прошедший игровой день, на следующий день когда вы зайдете первый раз в игру"},
        {"tgWeekly", fa.ICON_CALENDAR, "Еженедельный отчёт", "За прошедшую игровую неделю", "weeklyReportEnabled",
            "Отправляет отчёт за прошедшую игровую неделю, в понедельник когда вызайдете первый раз в игру"},
        {"tgPayday", fa.ICON_USD, "Уведомления о пейдее", "Зарплата, депозит, аксессуары, AZ и общий доход", "paydayEnabled",
            "Отправляет статистику пейдея в Telegram: зарплата, депозит, аксессуары, AZ и общий доход"},
        {"tgMarket", fa.ICON_SHOPPING_CART, "Уведомления об аренде", "Аренда в Item Market", "itemMarketEnabled", nil},
        {"tgShard", fa.ICON_STAR, "Выпадение осколков", "Осколки тайников и NFT", "shardEnabled",
            "Отправляет уведомление в Telegram при выпадении осколков тайников и NFT"},
    }
    for _, it in ipairs(list) do
        if rhSetToggle(it[1], it[2], u8(it[3]), u8(it[4]), tgConfig[it[5]] or false, it[6] and u8(it[6]) or nil) then
            tgConfig[it[5]] = not tgConfig[it[5]]
            saveTgConfig(); needSave = true
        end
    end
    imgui.Dummy(imgui.ImVec2(1, 4))
    local b = rhSetBtnRow("tgBtns", {
        {fa.ICON_TELEVISION, u8("Видео-обучение")},
        {fa.ICON_CHECK, u8("Проверить подключение")},
    })
    if b == 1 then
        shell32.ShellExecuteA(nil, "open", "https://youtu.be/WdWKGkxLNdU", nil, nil, 0)
    elseif b == 2 then
        if tgConfig.botToken ~= "" and tgConfig.chatId ~= "" then
            local now = os.time() + 10800
            local timeStr = string.format("%02d:%02d", math.floor((now % 86400) / 3600), math.floor((now % 3600) / 60))
            local dateStr = getGameDate()
            local msg = string.format(
                "<b>ResHelper подключен!</b>\n" ..
                "Уведомления в тг включены.\n" ..
                "Время: %s (МСК)\n" ..
                "Дата: %s",
                timeStr, dateStr
            )
            queueTelegramMessage(msg)
            sampAddChatMessage(SCRIPT_PREFIX .. "Тестовое сообщение отправлено в Telegram!", SCRIPT_COLOR)
        else
            sampAddChatMessage(SCRIPT_PREFIX .. "Укажите токен и Chat ID!", SCRIPT_COLOR)
        end
    end
end
function rhSetPageOverlay()
    rhSetCaption(u8("Отображение"))
    if not settings.regularmineEnabled then
        local h = 100
        local pos, w = rhSetCardBegin("ovCols", h, fa.ICON_GAVEL, u8("Столбцы в оверлее шахты"), u8("Сколько колонок с ресурсами показывать"))
        imgui.SetCursorScreenPos(imgui.ImVec2(pos.x + 16, pos.y + 60))
        imgui.PushItemWidth(math.min(240, w - 32))
        if imgui.Combo("##overlay_cols", cb_overlayColumns, table.concat(overlayColumnsNames, "\0") .. "\0") then
            settings.overlayColumns = cb_overlayColumns.v + 1
            saveConfig(); needSave = true
        end
        imgui.PopItemWidth()
        rhSetCardEnd(pos, w, h)
    else
        local pos, w = rhSetCardBegin("ovColsInfo", 54, fa.ICON_GAVEL, u8("Столбцы: 1 (обычная шахта)"), u8("Для обычной шахты число колонок фиксировано"))
        rhSetCardEnd(pos, w, 54)
    end
    rhSetCaption(u8("Внешний вид оверлея"))
    drawOverlayCustomization()
    rhSetCaption(u8("Поведение"))
    if rhSetToggle("ovHover", fa.ICON_DESKTOP, u8("Скрывать при наведении мыши"), u8("Оверлей прячется, когда курсор над ним"), cb_overlayHideOnHover.v,
        u8("После того как вы выбрали удобную позицию для оверлея, включите эту настройку. При наведении мыши окно оверлея будет полностью скрываться.")) then
        cb_overlayHideOnHover.v = not cb_overlayHideOnHover.v
        settings.overlayHideOnHover = cb_overlayHideOnHover.v
        saveConfig(); needSave = true
    end
    rhSetCaption(u8("Таймер"))
    if rhSetToggle("ovTimer", fa.ICON_CALENDAR, u8("Таймер в оверлее"), u8("Показывает время работы в оверлее"), cb_overlay_timer.v) then
        cb_overlay_timer.v = not cb_overlay_timer.v
        settings.overlayTimerEnabled = cb_overlay_timer.v
        if not cb_overlay_timer.v then
            overlayTimer.running = false
            overlayTimer.elapsed = 0
            overlayTimer.displayedTime = "00:00:00"
        end
        saveConfig(); needSave = true
    end
    if settings.overlayTimerEnabled then
        if rhSetToggle("ovAutoTimer", fa.ICON_PLAY, u8("Автозапуск при включении оверлея"), u8("Таймер стартует вместе с оверлеем"), cb_overlayAutoTimer.v) then
            cb_overlayAutoTimer.v = not cb_overlayAutoTimer.v
            settings.overlayAutoTimer = cb_overlayAutoTimer.v
            saveConfig(); needSave = true
        end
        local running = overlayTimer.running
        local h = 54
        local pos, w = rhSetCardBegin("ovTimerCtl", h, fa.ICON_CALENDAR, u8("Таймер работы"),
            running and u8("Идёт: " .. overlayTimer.displayedTime) or u8("Остановлен"), nil, nil)
        local bw = 170
        if rhSetBtn("ovTimerBtn", running and fa.ICON_TIMES or fa.ICON_PLAY, running and u8("Остановить") or u8("Запустить"),
            pos.x + w - 16 - bw, pos.y + 10, bw, running and "danger" or nil, 34) then
            if not running then
                overlayTimer.running = true
                overlayTimer.startTime = os.time()
                overlayTimer.elapsed = 0
                overlayTimer.displayedTime = "00:00:00"
            else
                overlayTimer.running = false
                overlayTimer.elapsed = os.time() - overlayTimer.startTime
                overlayTimer.displayedTime = formatTime(overlayTimer.elapsed)
                sampAddChatMessage(SCRIPT_PREFIX .. "Таймер остановлен. Время работы: " .. overlayTimer.displayedTime, SCRIPT_COLOR)
            end
        end
        rhSetCardEnd(pos, w, h)
    end
    rhSetCaption(u8("Сброс отображаемых данных"))
    local b = rhSetBtnRow("ovReset", {
        {fa.ICON_LEAF, u8("Ферма"), "danger"},
        {fa.ICON_GAVEL, u8("Шахта"), "danger"},
        {fa.ICON_TREE, u8("Лесопилка"), "danger"},
    })
    if b == 1 then
        resetOverlayData(WORK_TYPES.FARM)
        sampAddChatMessage(SCRIPT_PREFIX .. "Данные оверлея фермы сброшены!", SCRIPT_COLOR)
    elseif b == 2 then
        resetOverlayData(WORK_TYPES.MINE)
        sampAddChatMessage(SCRIPT_PREFIX .. "Данные оверлея шахты сброшены!", SCRIPT_COLOR)
    elseif b == 3 then
        resetOverlayData(WORK_TYPES.SAWMILL)
        sampAddChatMessage(SCRIPT_PREFIX .. "Данные оверлея лесопилки сброшены!", SCRIPT_COLOR)
    end
end
function rhSetPageData()
    rhSetCaption(u8("Учёт дохода"))
    if rhSetToggle("talonScan", fa.ICON_MONEY, u8("Авто-сканирование талона AZ"), u8("Учёт AZ из сообщений о добавленных предметах"), cb_talonAutoScan.v,
        u8("При отключении, в пейдей не будут учитываться AZ из сообщений «Вам был добавлен предмет...»")) then
        cb_talonAutoScan.v = not cb_talonAutoScan.v
        settings.talonAutoScanEnabled = cb_talonAutoScan.v
        saveConfig(); needSave = true
    end
    if rhSetToggle("cryptoScan", fa.ICON_USD, u8("Авто-сканирование крипты (BTC/ASC)"), u8("Учёт криптовалюты в доходе"), cb_cryptoAutoScan.v,
        u8("При отключении крипта не будет учитываться")) then
        cb_cryptoAutoScan.v = not cb_cryptoAutoScan.v
        settings.cryptoAutoScanEnabled = cb_cryptoAutoScan.v
        saveConfig(); needSave = true
    end
    rhSetCaption(u8("Рейтинг (лидерборд)"))
    local blocked = (useCustomFarmPrices or useCustomMinePrices or useCustomSawmillPrices) and true or false
    local lbOn = (not blocked) and (getLbEnabled() and true or false) or false
    local tip = blocked and u8("Отключите собственные цены на всех работах чтобы участвовать в рейтинге") or nil
    local desc = blocked and u8("Недоступно: включены собственные цены") or u8("Ваш результат попадёт в общий рейтинг")
    if rhSetToggle("lbEnabled", fa.ICON_TROPHY, u8("Участвовать в рейтинге"), desc, lbOn, tip, blocked) then
        saveLbConfig("", not lbOn)
    end
    local okId, pid = sampGetPlayerIdByCharHandle(PLAYER_PED)
    local serverNick = (okId and sampGetPlayerNickname(pid)) or ""
    local serverDisplay = getCurrentServer() or ""
    if not RH_SERVER_NAMES[serverDisplay] then serverDisplay = "" end
    local title = (serverNick ~= "") and serverNick or u8("Ник не определён")
    local sub
    if serverNick == "" then sub = u8("Зайдите на сервер, чтобы участвовать в рейтинге")
    elseif serverDisplay ~= "" then sub = u8("Сервер: ") .. serverDisplay
    else sub = u8("Сервер не определён") end
    local pos, w = rhSetCardBegin("lbProfile", 54, fa.ICON_USER, title, sub)
    if serverDisplay ~= "" then
        local icon = getServerIcon(serverDisplay)
        if icon then
            imgui.SetCursorScreenPos(imgui.ImVec2(pos.x + w - 16 - 22, pos.y + 16))
            imgui.Image(icon, imgui.ImVec2(22, 22))
        end
    end
    rhSetCardEnd(pos, w, 54)
end
function rhSetHero()
    local pal = rhSetPal()
    local w = imgui.GetWindowWidth() - 25
    local h = 64
    local pos = imgui.GetCursorScreenPos()
    local bg = rhSetFrame(pos, w, h, pal, 0)
    local dl = imgui.GetWindowDrawList()
    rhSetIcon(dl, pos.x + 36, pos.y + h / 2, 18, fa.ICON_COG, pal.accent, bg, 0)
    dl:PushClipRect(imgui.ImVec2(pos.x + 68, pos.y), imgui.ImVec2(pos.x + w - 160, pos.y + h), true)
    dl:AddText(imgui.ImVec2(pos.x + 68, pos.y + 14), pal.title, u8("Настройки ResHelper"))
    dl:AddText(imgui.ImVec2(pos.x + 68, pos.y + 35), pal.sub, needSave and u8("Есть несохранённые изменения") or u8("Изменения применяются сразу"))
    dl:PopClipRect()
    if rhSetBtn("saveAll", fa.ICON_FLOPPY_O, needSave and u8("Сохранить") or u8("Сохранено"), pos.x + w - 146, pos.y + 15, 130, needSave and "warn" or nil, 34) then
        saveConfig(); savePrices(); saveOverlayConfig(); saveGoals(); saveStats(); saveThemeConfig(); saveCustomTheme()
        sampAddChatMessage(SCRIPT_PREFIX .. "Настройки сохранены!", SCRIPT_COLOR)
        needSave = false
    end
    imgui.SetCursorScreenPos(imgui.ImVec2(pos.x, pos.y + h + 10))
    imgui.Dummy(imgui.ImVec2(w, 0))
end
function drawSettingsTab()
    if not settingsPage then settingsPage = 0 end
    if not rhSetOpen then rhSetOpen = {} end
    if not rhSetSnd then rhSetSnd = {} end
    rhSetHero()
    local w = imgui.GetWindowWidth() - 25
    local names = {u8("Вид"), u8("Звук и чат"), u8("Telegram"), u8("Оверлей"), u8("Данные")}
    local icons = {fa.ICON_DESKTOP, fa.ICON_MUSIC, fa.ICON_PAPER_PLANE, fa.ICON_PAINT_BRUSH, fa.ICON_MONEY}
    local c = SegmentedTabs("settings_pages", names, settingsPage, nil, (w >= 560) and icons or nil)
    if c then settingsPage = c end
    imgui.Dummy(imgui.ImVec2(1, 2))
    if settingsPage == 0 then rhSetPageLook()
    elseif settingsPage == 1 then rhSetPageSound()
    elseif settingsPage == 2 then rhSetPageTelegram()
    elseif settingsPage == 3 then rhSetPageOverlay()
    else rhSetPageData() end
    imgui.Dummy(imgui.ImVec2(1, 8))
end
function getSpawnTimers()
    local msk = getMoscowTime()
    local h = tonumber(os.date("%H", msk))
    local m = tonumber(os.date("%M", msk))
    local s = tonumber(os.date("%S", msk))
    local currentSeconds = h * 3600 + m * 60 + s
    
    local mineStart = 18 * 3600 + 30 * 60  -- 18:30 (начало шахты)
    local mineEnd = 20 * 3600 + 5 * 60     -- 20:05 (конец шахты)
    
    local stoneTimer = nil
    local golemTimer = nil
    
    if currentSeconds >= mineStart and currentSeconds < mineEnd then
        -- Спавн камней: 
        local stoneInterval = 372
        local stoneStart = 18 * 3600 + 36 * 60 + 25 
        local elapsedStone = (currentSeconds - stoneStart) % stoneInterval
        stoneTimer = stoneInterval - elapsedStone
        
        -- Спавн големов: 
        local golemStart = 18 * 3600 + 40 * 60 
        if currentSeconds >= golemStart then
            local elapsedGolem = (currentSeconds - golemStart) % 60
            golemTimer = 60 - elapsedGolem
        else
            golemTimer = golemStart - currentSeconds
        end
    end
    
    return stoneTimer, golemTimer
end
function saveTotalIncomeGoal()
    local data = {
        goal = settings.totalIncomeGoal,
        reached = totalIncomeGoalReached,
        income = totalDailyIncome
    }
    local file = io.open(totalIncomeGoalPath, "w")
    if file then
        file:write(encodeJson(data))
        file:close()
    end
end
function loadTotalIncomeGoal()
    local file = io.open(totalIncomeGoalPath, "r")
    if not file then return end
    local content = file:read("*all")
    file:close()
    local data = decodeJson(content)
    if not data then return end
    settings.totalIncomeGoal = data.goal or 1000000
    totalIncomeGoalReached = data.reached or false
    totalDailyIncome = data.income or 0
    if totalGoalEdit then totalGoalEdit.v = settings.totalIncomeGoal end
end
local rhGoalFileCache = {}
function rhReadGoalJson(path)
    local c = rhGoalFileCache[path]
    if c and os.clock() - c.t < 1.0 then return c.exists, c.data end
    local exists, data = false, nil
    local f = io.open(path, "r")
    if f then
        exists = true
        local okRead, txt = pcall(f.read, f, "*a")
        f:close()
        if okRead and txt then
            local okJson, res = pcall(decodeJson, txt)
            if okJson then data = res end
        end
    end
    rhGoalFileCache[path] = {t = os.clock(), exists = exists, data = data}
    return exists, data
end
function drawFarmGoals()
    local farmGoals = {}
    local farmDailyRes = {}
    
    local fgExists, fgData = rhReadGoalJson(farmGoalsConfigPath)
    if fgExists then
        local data = fgData
        if data then
            for _, k in ipairs(configs[WORK_TYPES.FARM].resourceOrder) do
                farmGoals[k] = data[k] or configs[WORK_TYPES.FARM].defaultGoals[k]
            end
        end
    else
        for _, k in ipairs(configs[WORK_TYPES.FARM].resourceOrder) do
            farmGoals[k] = configs[WORK_TYPES.FARM].defaultGoals[k]
        end
    end
    
    local fpExists, fpData = rhReadGoalJson(getServerGoalsProgressPath(WORK_TYPES.FARM))
    if fpExists then
        local data = fpData
        if data then
            for _, k in ipairs(configs[WORK_TYPES.FARM].resourceOrder) do
                if data[k] then
                    farmDailyRes[k] = data[k].amount or 0
                else
                    farmDailyRes[k] = 0
                end
            end
        end
    else
        for _, k in ipairs(configs[WORK_TYPES.FARM].resourceOrder) do
            farmDailyRes[k] = 0
        end
    end
    
    if currentWork == WORK_TYPES.FARM then
        for _, k in ipairs(configs[WORK_TYPES.FARM].resourceOrder) do
        farmGoals[k] = farmGoals[k] or goals[k]
            farmDailyRes[k] = dailyResources[k] or 0
        end
    end
    
    for _, k in ipairs(configs[WORK_TYPES.FARM].resourceOrder) do
        if not farmGoalEditCache[k] then
            farmGoalEditCache[k] = imgui.ImInt(farmGoals[k])
        end
    end
    
    local farmOrder = configs[WORK_TYPES.FARM].resourceOrder
    rhGoalGrid("farm", farmOrder, configs[WORK_TYPES.FARM].resourceNames, farmDailyRes, farmGoalEditCache, 0xFF1AE591, function() rhSaveResourceGoals(WORK_TYPES.FARM, farmOrder, farmGoalEditCache, farmGoalsConfigPath) end)
    imgui.Spacing()
    local btnWidth = imgui.GetWindowWidth() - 25
    if rhGoalButton(u8("Сбросить прогресс"), fa.ICON_REFRESH, btnWidth, 0xFF4646EB, false, "farm_reset") then
        local saveData = {}
        for _, k in ipairs(farmOrder) do
            saveData[k] = {reached = false, amount = 0}
        end
        saveData.dailyTotal = 0
        local f = io.open(getServerGoalsProgressPath(WORK_TYPES.FARM), "w")
        if f then f:write(encodeJson(saveData)); f:close() end
        if currentWork == WORK_TYPES.FARM then
            for _, k in ipairs(farmOrder) do
                goalsReached[k] = false; dailyResources[k] = 0
            end
            dailyTotal = 0
        end
        sampAddChatMessage(SCRIPT_PREFIX.."Прогресс целей фермы сброшен!", SCRIPT_COLOR)
    end
end
function drawMineGoals()
    local mineGoals = {}
    local mineDailyRes = {}
    
    local mgExists, mgData = rhReadGoalJson(mineGoalsConfigPath)
    if mgExists then
        local data = mgData
        if data then
            for _, k in ipairs(configs[WORK_TYPES.MINE].resourceOrder) do
                mineGoals[k] = data[k] or configs[WORK_TYPES.MINE].defaultGoals[k]
            end
        end
    else
        for _, k in ipairs(configs[WORK_TYPES.MINE].resourceOrder) do
            mineGoals[k] = configs[WORK_TYPES.MINE].defaultGoals[k]
        end
    end
    
    local mpExists, mpData = rhReadGoalJson(getServerGoalsProgressPath(WORK_TYPES.MINE))
    if mpExists then
        local data = mpData
        if data then
            for _, k in ipairs(configs[WORK_TYPES.MINE].resourceOrder) do
                if data[k] then
                    mineDailyRes[k] = data[k].amount or 0
                else
                    mineDailyRes[k] = 0
                end
            end
        end
    else
        for _, k in ipairs(configs[WORK_TYPES.MINE].resourceOrder) do
            mineDailyRes[k] = 0
        end
    end
    
    if currentWork == WORK_TYPES.MINE then
        for _, k in ipairs(configs[WORK_TYPES.MINE].resourceOrder) do
            mineGoals[k] = mineGoals[k] or goals[k]
            mineDailyRes[k] = dailyResources[k] or 0
        end
    end
    
    for _, k in ipairs(configs[WORK_TYPES.MINE].resourceOrder) do
        if not mineGoalEditCache[k] then
            mineGoalEditCache[k] = imgui.ImInt(mineGoals[k])
        end
    end
    
    local mineOrder = configs[WORK_TYPES.MINE].resourceOrder
    rhGoalGrid("mine", mineOrder, configs[WORK_TYPES.MINE].resourceNames, mineDailyRes, mineGoalEditCache, 0xFF28AAFF, function() rhSaveResourceGoals(WORK_TYPES.MINE, mineOrder, mineGoalEditCache, mineGoalsConfigPath) end)
    imgui.Spacing()
    local btnWidth = imgui.GetWindowWidth() - 25
    if rhGoalButton(u8("Сбросить прогресс"), fa.ICON_REFRESH, btnWidth, 0xFF4646EB, false, "mine_reset") then
        local saveData = {}
        for _, k in ipairs(mineOrder) do
            saveData[k] = {reached = false, amount = 0}
        end
        saveData.dailyTotal = 0
        local f = io.open(mineGoalsProgressPath, "w")
        if f then f:write(encodeJson(saveData)); f:close() end
        if currentWork == WORK_TYPES.MINE then
            for _, k in ipairs(mineOrder) do
                goalsReached[k] = false; dailyResources[k] = 0
            end
            dailyTotal = 0
        end
        sampAddChatMessage(SCRIPT_PREFIX.."Прогресс целей шахты сброшен!", SCRIPT_COLOR)
    end
end
function drawSawmillGoals()
    local sawGoals = {}
    local sawDailyRes = {}
    
    local sgExists, sgData = rhReadGoalJson(sawmillGoalsConfigPath)
    if sgExists then
        local data = sgData
        if data then
            for _, k in ipairs(configs[WORK_TYPES.SAWMILL].resourceOrder) do
                sawGoals[k] = data[k] or configs[WORK_TYPES.SAWMILL].defaultGoals[k]
            end
        end
    else
        for _, k in ipairs(configs[WORK_TYPES.SAWMILL].resourceOrder) do
            sawGoals[k] = configs[WORK_TYPES.SAWMILL].defaultGoals[k]
        end
    end
    
    local spExists, spData = rhReadGoalJson(getServerGoalsProgressPath(WORK_TYPES.SAWMILL))
    if spExists then
        local data = spData
        if data then
            for _, k in ipairs(configs[WORK_TYPES.SAWMILL].resourceOrder) do
                if data[k] then
                    sawDailyRes[k] = data[k].amount or 0
                else
                    sawDailyRes[k] = 0
                end
            end
        end
    else
        for _, k in ipairs(configs[WORK_TYPES.SAWMILL].resourceOrder) do
            sawDailyRes[k] = 0
        end
    end
    
    if currentWork == WORK_TYPES.SAWMILL then
        for _, k in ipairs(configs[WORK_TYPES.SAWMILL].resourceOrder) do
            sawGoals[k] = sawGoals[k] or goals[k]
            sawDailyRes[k] = dailyResources[k] or 0
        end
    end
    
    for _, k in ipairs(configs[WORK_TYPES.SAWMILL].resourceOrder) do
        if not sawmillGoalEditCache[k] then
            sawmillGoalEditCache[k] = imgui.ImInt(sawGoals[k])
        end
    end
    
    local sawOrder = configs[WORK_TYPES.SAWMILL].resourceOrder
    rhGoalGrid("saw", sawOrder, configs[WORK_TYPES.SAWMILL].resourceNames, sawDailyRes, sawmillGoalEditCache, 0xFF99D334, function() rhSaveResourceGoals(WORK_TYPES.SAWMILL, sawOrder, sawmillGoalEditCache, sawmillGoalsConfigPath) end)
    imgui.Spacing()
    local btnWidth = imgui.GetWindowWidth() - 25
    if rhGoalButton(u8("Сбросить прогресс"), fa.ICON_REFRESH, btnWidth, 0xFF4646EB, false, "saw_reset") then
        local saveData = {}
        for _, k in ipairs(sawOrder) do
            saveData[k] = {reached = false, amount = 0}
        end
        saveData.dailyTotal = 0
        local f = io.open(sawmillGoalsProgressPath, "w")
        if f then f:write(encodeJson(saveData)); f:close() end
        if currentWork == WORK_TYPES.SAWMILL then
            for _, k in ipairs(sawOrder) do
                goalsReached[k] = false; dailyResources[k] = 0
            end
            dailyTotal = 0
        end
        sampAddChatMessage(SCRIPT_PREFIX.."Прогресс целей лесопилки сброшен!", SCRIPT_COLOR)
    end
end
function drawInvestmentTab()
    if not invSectionTab then invSectionTab = imgui.ImInt(0) end
    local invSectionNames = {u8("Статистика"), u8("Цены")}
    local invClicked = SegmentedTabs("inv", invSectionNames, invSectionTab.v)
    if invClicked then invSectionTab.v = invClicked end
    imgui.Spacing(); imgui.Separator(); imgui.Spacing()
    if invSectionTab.v == 0 then RI.draw("case"); return end
    local drawList = imgui.GetWindowDrawList()
    local listW = imgui.GetWindowWidth() - 25
    
    --  ЦЕНЫ
    
    if invSectionTab.v == 1 then
        if ToggleSwitch(u8("Использовать собственные цены"), cb_useCustomCasePrices, u8("Отключит автоматическую синхронизацию цен ларцов из Google таблицы.")) then
            useCustomCasePrices = cb_useCustomCasePrices.v
            if useCustomCasePrices then
                for itemId, data in pairs(investmentConfig) do
                    if not invEditCache then invEditCache = {} end
                    if not invEditCache[itemId] then
                        invEditCache[itemId] = imgui.ImInt(data.cost or 0)
                    end
                end
            else
                syncCasePrices()
            end
            saveCustomPricesConfig()
        end
        imgui.Spacing()
        if not useCustomCasePrices then
            imgui.TextColored(imgui.ImVec4(0.6, 0.6, 0.6, 1), u8("Цены подтягиваются из общей таблицы цен. Авто-обновление раз в сутки."))
            imgui.Spacing()
        end
        if next(investmentConfig) == nil then
            imgui.TextColored(imgui.ImVec4(0.6, 0.6, 0.6, 1), u8("Нет ларцов. Они появятся здесь при выпадении."))
        else
            if not invEditCache then invEditCache = {} end
            local caseIds = {}
            for itemId in pairs(investmentConfig) do table.insert(caseIds, itemId) end
            table.sort(caseIds, function(a, b) return (investmentConfig[a].name or "") < (investmentConfig[b].name or "") end)
            local pos = imgui.GetCursorScreenPos()
            local col1W = listW * 0.55
            local col2W = listW * 0.25
            local headerHeight = 28; local rowHeight = 26; local rows = #caseIds
            drawList:AddRectFilled(pos, imgui.ImVec2(pos.x + listW, pos.y + headerHeight + rows * rowHeight), 0xFF141414, 6)
            drawList:AddRect(pos, imgui.ImVec2(pos.x + listW, pos.y + headerHeight + rows * rowHeight), 0xFF2A2A2A, 6, 15, 1.5)
            drawList:AddText(imgui.ImVec2(pos.x + 10, pos.y + 6), 0xFF1AE591, u8("Ларец"))
            drawList:AddText(imgui.ImVec2(pos.x + col1W + 10, pos.y + 6), 0xFF1AE591, u8("Цена"))
            drawList:AddText(imgui.ImVec2(pos.x + col1W + col2W + 10, pos.y + 6), 0xFF1AE591, u8("Кол-во"))
            drawList:AddLine(imgui.ImVec2(pos.x + 6, pos.y + headerHeight), imgui.ImVec2(pos.x + listW - 6, pos.y + headerHeight), 0xFF2A2A2A, 1.5)
            drawList:AddLine(imgui.ImVec2(pos.x + col1W, pos.y + 8), imgui.ImVec2(pos.x + col1W, pos.y + headerHeight + rows * rowHeight - 4), 0xFF2A2A2A, 1.0)
            drawList:AddLine(imgui.ImVec2(pos.x + col1W + col2W, pos.y + 8), imgui.ImVec2(pos.x + col1W + col2W, pos.y + headerHeight + rows * rowHeight - 4), 0xFF2A2A2A, 1.0)
            for i, itemId in ipairs(caseIds) do
                local data = investmentConfig[itemId]
                if not invEditCache[itemId] then
                    invEditCache[itemId] = imgui.ImInt(data.cost or 0)
                end
                local y = pos.y + headerHeight + (i - 1) * rowHeight
                local rowBgColor = (i % 2 == 0) and 0xFF1E1E1E or 0xFF181818
                drawList:AddRectFilled(imgui.ImVec2(pos.x + 2, y + 1), imgui.ImVec2(pos.x + listW - 2, y + rowHeight - 1), rowBgColor)
                if i > 1 then drawList:AddLine(imgui.ImVec2(pos.x + 6, y), imgui.ImVec2(pos.x + listW - 6, y), 0xFF222222, 0.5) end
                drawList:AddLine(imgui.ImVec2(pos.x + col1W, y + 2), imgui.ImVec2(pos.x + col1W, y + rowHeight - 2), 0xFF252525, 0.5)
                drawList:AddLine(imgui.ImVec2(pos.x + col1W + col2W, y + 2), imgui.ImVec2(pos.x + col1W + col2W, y + rowHeight - 2), 0xFF252525, 0.5)
                drawList:AddText(imgui.ImVec2(pos.x + 10, y + 5), 0xFFFFFFFF, u8(data.name or ""))
                if useCustomCasePrices then
                    local editPos = imgui.ImVec2(pos.x + col1W + 10, y + 2)
                    imgui.SetCursorScreenPos(editPos); imgui.PushItemWidth(col2W - 20)
                    if imgui.InputInt("##custom_price_case_" .. itemId, invEditCache[itemId], 1000, 10000) then
                        investmentConfig[itemId].cost = invEditCache[itemId].v
                        saveInvestmentConfig()
                    end
                    imgui.PopItemWidth()
                else
                    drawList:AddText(imgui.ImVec2(pos.x + col1W + 10, y + 5), 0xFF33CC33, formatNumber(getCasePrice(itemId)) .. "$")
                end
                drawList:AddText(imgui.ImVec2(pos.x + col1W + col2W + 10, y + 5), 0xFFCCCCCC, tostring(data.count) .. u8(" шт."))
            end
            imgui.SetCursorScreenPos(imgui.ImVec2(pos.x, pos.y + headerHeight + rows * rowHeight + 8))
            imgui.Dummy(imgui.ImVec2(listW, 0))
        end
        imgui.Spacing()
        if useCustomCasePrices then
            if StyleButton(u8("Сохранить цены"), fa.ICON_FLOPPY_O, 220) then
                saveInvestmentConfig()
                sampAddChatMessage(SCRIPT_PREFIX .. "Цены ларцов сохранены!", SCRIPT_COLOR)
            end
        else
            if StyleButton(u8("Обновить цены на актуальные"), fa.ICON_REPEAT, 220) then loadGlobalPrices() end
        end
    end
end
function drawCryptoTab()
    if not cryptoSectionTab then cryptoSectionTab = imgui.ImInt(0) end
    local cryptoSectionNames = {u8("Статистика"), u8("Цены")}
    local cryptoClicked = SegmentedTabs("crypto", cryptoSectionNames, cryptoSectionTab.v)
    if cryptoClicked then cryptoSectionTab.v = cryptoClicked end
    imgui.Spacing(); imgui.Separator(); imgui.Spacing()
    if cryptoSectionTab.v == 0 then RI.draw("crypto"); return end
    local drawList = imgui.GetWindowDrawList()
    local listW = imgui.GetWindowWidth() - 25
	
    --  ЦЕНЫ
    
    if cryptoSectionTab.v == 1 then
        local cryptoMeta = {
            [1811] = { accent = 0xFF3C73B4, accentBg = 0xFF142335, ticker = "BTC" },
            [5996] = { accent = 0xFF3539E5, accentBg = 0xFF14143D, ticker = "ASC" },
        }
        if next(cryptoConfig) == nil then
            imgui.TextColored(imgui.ImVec4(0.6, 0.6, 0.6, 1), u8("Нет монет. Они появятся здесь при получении."))
        else
            local cryptoOrder = {1811, 5996}
            for _, itemId in ipairs(cryptoOrder) do
                local data = cryptoConfig[itemId]
                if data then
                local meta = cryptoMeta[itemId] or { accent = 0xFF1AE591, accentBg = 0xFF1E3D1E, ticker = "?" }
                local cardX2 = imgui.GetCursorScreenPos().x
                local cardY2 = imgui.GetCursorScreenPos().y
                local coinCardH = 64
                drawList:AddRectFilled(imgui.ImVec2(cardX2, cardY2), imgui.ImVec2(cardX2 + listW, cardY2 + coinCardH), 0xFF161616, 8)
                drawList:AddRect(imgui.ImVec2(cardX2, cardY2), imgui.ImVec2(cardX2 + listW, cardY2 + coinCardH), 0xFF333333, 8, 15, 1.0)
                drawList:PushClipRect(imgui.ImVec2(cardX2, cardY2), imgui.ImVec2(cardX2 + 5, cardY2 + coinCardH), true)
                drawList:AddRectFilled(imgui.ImVec2(cardX2, cardY2), imgui.ImVec2(cardX2 + listW, cardY2 + coinCardH), meta.accent, 8)
                drawList:PopClipRect()
                local badgeSize = 40
                local badgeX, badgeY = cardX2 + 14, cardY2 + (coinCardH - badgeSize) / 2
                drawList:AddRectFilled(imgui.ImVec2(badgeX, badgeY), imgui.ImVec2(badgeX + badgeSize, badgeY + badgeSize), meta.accentBg, 8)
                local coinIcon = meta.ticker
                local iconSz = imgui.CalcTextSize(coinIcon)
                drawList:AddText(imgui.ImVec2(badgeX + (badgeSize - iconSz.x) / 2, badgeY + (badgeSize - iconSz.y) / 2), meta.accent, coinIcon)
                local nameX = badgeX + badgeSize + 12
                drawList:AddText(imgui.ImVec2(nameX, cardY2 + 10), 0xFFFFFFFF, u8(data.name))
                drawList:AddText(imgui.ImVec2(nameX, cardY2 + 30), 0xFF888888, u8("Кол-во: ") .. data.count .. u8(" шт."))
                local priceStr = formatNumber(data.cost) .. "$"
                local priceW = imgui.CalcTextSize(priceStr).x
                local priceX = cardX2 + listW - priceW - 14
                drawList:AddText(imgui.ImVec2(priceX + 1, cardY2 + 10), meta.accent, priceStr)
                drawList:AddText(imgui.ImVec2(priceX, cardY2 + 10), meta.accent, priceStr)
                local totalStr = u8("На сумму: ") .. formatNumber(data.cost * data.count) .. "$"
                local totalW = imgui.CalcTextSize(totalStr).x
                drawList:AddText(imgui.ImVec2(cardX2 + listW - totalW - 14, cardY2 + 30), 0xFF33CC66, totalStr)
                imgui.SetCursorScreenPos(imgui.ImVec2(cardX2, cardY2 + coinCardH))
                imgui.Dummy(imgui.ImVec2(listW, 8))
                end
            end
        end
        imgui.Spacing()
        if cryptoPriceDialogState.pending then
            imgui.TextColored(imgui.ImVec4(1, 0.8, 0, 1), u8("Обновляю курс..."))
        elseif settings.cryptoPricesLastFetch and settings.cryptoPricesLastFetch > 0 then
            imgui.TextColored(imgui.ImVec4(0.5, 0.5, 0.5, 1), u8("Курс обновлён: ") .. os.date("%d.%m.%Y %H:%M", settings.cryptoPricesLastFetch))
        else
            imgui.TextColored(imgui.ImVec4(0.5, 0.5, 0.5, 1), u8("Курс ещё не проверялся — нажми «Обновить курс»."))
        end
        imgui.Spacing()
        if StyleButton(u8("Обновить курс"), fa.ICON_REFRESH, listW) then
            fetchCryptoPrices(true)
        end
    end
end
NFT_MONEY_ID = 9296
NFT_CONTAINERS = {
    [5787] = "НФТ контейнер (обычный)",
    [5788] = "НФТ контейнер (средний)",
    [5789] = "НФТ контейнер (премиум)",
    [7375] = "Гоблинский НФТ контейнер",
    [7435] = "НФТ Каменного Человека",
    [9176] = "Космический NFT Контейнер",
    [9333] = "Супер НФТ контейнер",
}
NFT_AVATAR_COLORS = {0xFF3A7D2E, 0xFF8A5A2B, 0xFF2B6B9E, 0xFF7A3B8A, 0xFF3B8A8A, 0xFF3B3BA8}
nftStatsPath = configDir .. "ResHelperNft.json"
nftOldStatsPath = configDir .. "nft_stats.json"
nftData = nil
nftSession = nil
nftLastContainer = nil
nftStatsCache = nil
nftPeriod = 1
nftContainerFilter = ""
nftPriceInts = {}
nftPriceDirtyAt = nil
nftSearchBuf = imgui.ImBuffer(60)
function nftLoad()
    if nftData then return end
    nftData = {sessions = {}, prices = {}}
    local f = io.open(nftStatsPath, "r") or io.open(nftOldStatsPath, "r")
    if not f then return end
    local c = f:read("*all")
    f:close()
    local ok, d = pcall(decodeJson, c)
    if ok and type(d) == "table" then
        nftData.sessions = d.sessions or {}
        nftData.prices = d.prices or {}
    end
end
function nftSave()
    pcall(function()
        local f = io.open(nftStatsPath, "w")
        if not f then return end
        f:write(encodeJson(nftData))
        f:close()
    end)
end
function nftLower(s)
    s = tostring(s):gsub("[\192-\223]", function(ch) return string.char(ch:byte() + 32) end)
    return s:lower()
end
function nftParseEvent(text)
    local ev = text:match("window%.executeEvent%('%s*([^']-)%s*'")
    if not ev then return nil end
    local payload = text:match("`(.-)`") or text:match("window%.executeEvent%([^,]+,%s*'([^']*)'")
    return ev, payload
end
function nftParseContainer(payload)
    local items = {}
    local ok, d = pcall(decodeJson, payload)
    if ok and type(d) == "table" then
        local obj = d[1] or d
        if type(obj) == "table" and type(obj.items) == "table" then
            for _, it in ipairs(obj.items) do
                if type(it) == "table" then
                    items[#items + 1] = {id = tonumber(it.sysName) or 0, base = tonumber(it.count) or 0, name = tostring(it.title or "")}
                end
            end
            if #items > 0 then return items end
        end
    end
    items = {}
    for obj in payload:gmatch("{[^{}]*}") do
        local sys = obj:match('"sysName"%s*:%s*"?(%d+)"?')
        if sys then
            items[#items + 1] = {
                id = tonumber(sys) or 0,
                base = tonumber(obj:match('"count"%s*:%s*"?(%d+)"?')) or 0,
                name = obj:match('"title"%s*:%s*"(.-)"') or ""
            }
        end
    end
    return items
end
function nftCloseSession()
    local s = nftSession
    if not s then return end
    nftSession = nil
    local rec = {time = s.time, container = s.container or "NFT контейнер", containerId = s.containerId or 0, items = {}}
    for _, it in ipairs(s.items) do
        local nm = it.name
        if not nm or nm == "" then nm = "Предмет #" .. tostring(it.id) end
        rec.items[#rec.items + 1] = {id = it.id, name = nm, base = it.base, actual = it.actual or it.base}
    end
    nftData.sessions[#nftData.sessions + 1] = rec
    if #nftData.sessions > 3000 then table.remove(nftData.sessions, 1) end
    nftSave()
    nftStatsCache = nil
    sampAddChatMessage(SCRIPT_PREFIX .. "NFT контейнер записан: позиций " .. #rec.items, SCRIPT_COLOR)
end
function nftScheduleClose()
    local s = nftSession
    if not s or s.closing then return end
    s.closing = true
    lua_thread.create(function()
        wait(1500)
        if nftSession == s then nftCloseSession() end
    end)
end
function nftConfirm(id, amount)
    local s = nftSession
    if not s then return end
    local best, bestDiff = nil, nil
    for _, it in ipairs(s.items) do
        if it.id == id and not it.confirmed then
            local diff = math.abs(it.base - amount)
            if not best or diff < bestDiff then best, bestDiff = it, diff end
        end
    end
    if not best then return end
    best.actual = amount
    best.confirmed = true
    for _, it in ipairs(s.items) do
        if not it.confirmed then return end
    end
    nftCloseSession()
end
function rhNftOnCef(text)
    if not text:find("window.executeEvent", 1, true) then return end
    if not (text:find("containerContent", 1, true) or text:find("damageInformer.initializeDamageInfo", 1, true)
        or text:find("event.player.addMoney", 1, true) or text:find("event.setActiveView", 1, true)
        or text:find("event.inventory.playerInventory", 1, true)) then return end
    nftLoad()
    if nftSession and os.clock() - nftSession.clock > 180 then nftCloseSession() end
    local ev, payload = nftParseEvent(text)
    if not ev then return end
    if ev == "event.inventory.playerInventory" then
        local ids = {}
        for id in text:gmatch('"item"%s*:%s*(%d+)') do ids[#ids + 1] = tonumber(id) end
        if #ids > 0 and #ids <= 6 then
            for _, n in ipairs(ids) do
                if NFT_CONTAINERS[n] then
                    nftLastContainer = {id = n, clock = os.clock()}
                    if nftSession and not nftSession.containerId then
                        nftSession.containerId = n
                        nftSession.container = NFT_CONTAINERS[n]
                    end
                end
            end
        end
        return
    end
    if ev == "containerContent.initialize" then
        local items = nftParseContainer(payload or "")
        if #items == 0 then return end
        local parts = {}
        for _, it in ipairs(items) do parts[#parts + 1] = it.id .. ":" .. it.base .. ":" .. it.name end
        local hash = table.concat(parts, "|")
        if nftSession and nftSession.hash == hash and not nftSession.closing then return end
        if nftSession then nftCloseSession() end
        local cid = nil
        if nftLastContainer and os.clock() - nftLastContainer.clock < 15 then cid = nftLastContainer.id end
        nftSession = {time = os.time(), clock = os.clock(), hash = hash, items = items,
            containerId = cid, container = cid and NFT_CONTAINERS[cid] or nil}
        return
    end
    if ev == "event.damageInformer.initializeDamageInfo" then
        if not nftSession then return end
        local ok, d = pcall(decodeJson, payload or "")
        if not ok or type(d) ~= "table" then return end
        local entries = d
        if d.type ~= nil then entries = {d} end
        for _, e in ipairs(entries) do
            if type(e) == "table" and e.type == "outgoing" then
                local id = tonumber(e.imageId) or 0
                local num = tostring(e.tag or ""):match("%+%s*([%d%s%.]+)")
                if num then num = tonumber((num:gsub("[%s%.]", ""))) end
                if id > 0 and num and num > 0 then nftConfirm(id, num) end
            end
        end
        return
    end
    if ev == "event.player.addMoney" then
        if not nftSession then return end
        local ok, d = pcall(decodeJson, payload or "")
        if ok and type(d) == "table" then
            local amount = tonumber(d[1])
            if amount and amount > 0 then nftConfirm(NFT_MONEY_ID, amount) end
        end
        return
    end
    if ev == "event.setActiveView" then
        local view = (payload or ""):match('%["([^"]*)"%]')
        if view ~= "ContainerContent" then nftScheduleClose() end
        return
    end
end
function nftBuildStats()
    nftLoad()
    local q = u8:decode(nftSearchBuf.v or "")
    local c = nftStatsCache
    if c and os.clock() - c.t < 1.0 and c.period == nftPeriod and c.cf == nftContainerFilter and c.q == q then return c end
    c = {t = os.clock(), period = nftPeriod, cf = nftContainerFilter, q = q, rows = {}, opened = 0, profit = 0,
        totalActual = 0, totalBonus = 0, containerNames = {}}
    local today = getGameDate()
    local yest = getGameDate(os.time() - 86400)
    local weekAgo = os.time() - 7 * 86400
    local qn = nftLower(q)
    local byId, nameSeen = {}, {}
    for _, s in ipairs(nftData.sessions) do
        local cn = s.container or "NFT контейнер"
        if not nameSeen[cn] then nameSeen[cn] = true; c.containerNames[#c.containerNames + 1] = cn end
        local inPeriod
        if nftPeriod == 1 then inPeriod = (getGameDate(s.time) == today)
        elseif nftPeriod == 2 then inPeriod = (getGameDate(s.time) == yest)
        elseif nftPeriod == 3 then inPeriod = (s.time >= weekAgo)
        else inPeriod = true end
        if inPeriod and (nftContainerFilter == "" or cn == nftContainerFilter) then
            c.opened = c.opened + 1
            for _, it in ipairs(s.items or {}) do
                if qn == "" or nftLower(it.name or ""):find(qn, 1, true) then
                    local r = byId[it.id]
                    if not r then
                        r = {id = it.id, name = it.name, times = 0, base = 0, actual = 0}
                        byId[it.id] = r
                        c.rows[#c.rows + 1] = r
                    end
                    r.times = r.times + 1
                    r.base = r.base + (it.base or 0)
                    r.actual = r.actual + (it.actual or it.base or 0)
                end
            end
        end
    end
    for _, r in ipairs(c.rows) do
        local price = nftData.prices[tostring(r.id)]
        if price == nil and r.id == NFT_MONEY_ID then price = 1 end
        r.price = price or 0
        r.bonus = r.actual - r.base
        r.profit = r.actual * r.price
        c.profit = c.profit + r.profit
        if r.id ~= NFT_MONEY_ID then
            c.totalActual = c.totalActual + r.actual
            c.totalBonus = c.totalBonus + r.bonus
        end
    end
    table.sort(c.rows, function(a, b)
        if a.profit ~= b.profit then return a.profit > b.profit end
        return a.actual > b.actual
    end)
    table.sort(c.containerNames)
    nftStatsCache = c
    return c
end
function drawNftTab()
    local drawList = imgui.GetWindowDrawList()
    local listW = imgui.GetWindowWidth() - 25
    local st = nftBuildStats()
    if nftPriceDirtyAt and os.clock() - nftPriceDirtyAt > 1.5 then
        nftPriceDirtyAt = nil
        nftSave()
    end
    local x0 = imgui.GetCursorScreenPos().x
    local y0 = imgui.GetCursorScreenPos().y
    local gap, cardH = 8, 76
    local cardW = (listW - gap * 2) / 3
    local avgPer = (st.opened > 0) and math.floor(st.profit / st.opened) or 0
    local cards = {
        {u8("Прибыль"), formatNumber(st.profit) .. " $", 0xFF1AE591, u8("за выбранный период")},
        {u8("Контейнеров"), tostring(st.opened), 0xFF33CCFF, u8("в среднем ") .. formatNumber(avgPer) .. " $"},
        {u8("Предметов"), formatNumber(st.totalActual), 0xFFFFA64D, u8("бонус +") .. formatNumber(st.totalBonus) .. u8(" | видов: ") .. #st.rows},
    }
    for i, c in ipairs(cards) do
        local cx = x0 + (i - 1) * (cardW + gap)
        drawList:AddRectFilled(imgui.ImVec2(cx, y0), imgui.ImVec2(cx + cardW, y0 + cardH), 0xFF141414, 10)
        drawList:AddRect(imgui.ImVec2(cx, y0), imgui.ImVec2(cx + cardW, y0 + cardH), 0xFF2A2A2A, 10, 15, 1.0)
        drawList:AddRectFilled(imgui.ImVec2(cx, y0 + 12), imgui.ImVec2(cx + 3, y0 + cardH - 12), c[3], 2)
        drawList:AddText(imgui.ImVec2(cx + 16, y0 + 11), 0xFF888888, c[1])
        drawList:AddText(imgui.ImVec2(cx + 16, y0 + 31), c[3], c[2])
        drawList:AddText(imgui.ImVec2(cx + 16, y0 + 53), 0xFF666666, c[4])
    end
    local sy = y0 + cardH + 12
    local segH = 32
    local segW = listW / 4
    local labels = {u8("Сегодня"), u8("Вчера"), u8("Неделя"), u8("Всё время")}
    drawList:AddRectFilled(imgui.ImVec2(x0, sy), imgui.ImVec2(x0 + listW, sy + segH), 0xFF141414, 8)
    drawList:AddRect(imgui.ImVec2(x0, sy), imgui.ImVec2(x0 + listW, sy + segH), 0xFF2A2A2A, 8, 15, 1.0)
    for i, lb in ipairs(labels) do
        local px = x0 + (i - 1) * segW
        imgui.SetCursorScreenPos(imgui.ImVec2(px, sy))
        local clicked = imgui.InvisibleButton("##nftseg" .. i, imgui.ImVec2(segW, segH))
        local hov = imgui.IsItemHovered()
        local active = (nftPeriod == i)
        if active then
            drawList:AddRectFilled(imgui.ImVec2(px + 3, sy + 3), imgui.ImVec2(px + segW - 3, sy + segH - 3), 0xFF1E3D1E, 6)
            drawList:AddRect(imgui.ImVec2(px + 3, sy + 3), imgui.ImVec2(px + segW - 3, sy + segH - 3), 0xFF1AE591, 6, 15, 1.0)
        elseif hov then
            drawList:AddRectFilled(imgui.ImVec2(px + 3, sy + 3), imgui.ImVec2(px + segW - 3, sy + segH - 3), 0xFF1E1E1E, 6)
        end
        local tw = imgui.CalcTextSize(lb).x
        local tcol = active and 0xFF1AE591 or (hov and 0xFFCCCCCC or 0xFF888888)
        drawList:AddText(imgui.ImVec2(px + (segW - tw) / 2, sy + 9), tcol, lb)
        if clicked then nftPeriod = i; nftStatsCache = nil end
    end
    imgui.SetCursorScreenPos(imgui.ImVec2(x0, sy + segH + 10))
    local wC = listW * 0.26
    local wS = listW - wC - 8
    local cfName = (nftContainerFilter == "") and u8("Все NFT") or u8(nftContainerFilter)
    if StyleButton(cfName, nil, wC, nftContainerFilter ~= "") then
        local names = st.containerNames
        local nextName = ""
        if nftContainerFilter == "" then
            nextName = names[1] or ""
        else
            for i, n in ipairs(names) do
                if n == nftContainerFilter then nextName = names[i + 1] or ""; break end
            end
        end
        nftContainerFilter = nextName
        nftStatsCache = nil
    end
    imgui.SameLine(0, 8)
    imgui.PushItemWidth(wS)
    imgui.InputText("##nftsearch", nftSearchBuf)
    imgui.PopItemWidth()
    if nftSearchBuf.v == "" then
        local ip = imgui.GetItemRectMin()
        drawList:AddText(imgui.ImVec2(ip.x + 6, ip.y + 3), 0xFF666666, u8("Поиск по названию"))
    end
    imgui.Spacing()
    local tx = imgui.GetCursorScreenPos().x
    local ty = imgui.GetCursorScreenPos().y
    if #st.rows == 0 then
        local eh = 110
        drawList:AddRectFilled(imgui.ImVec2(tx, ty), imgui.ImVec2(tx + listW, ty + eh), 0xFF141414, 10)
        drawList:AddRect(imgui.ImVec2(tx, ty), imgui.ImVec2(tx + listW, ty + eh), 0xFF2A2A2A, 10, 15, 1.0)
        local t1 = u8("Нет данных за выбранный период")
        local t2 = u8("Откройте NFT контейнер, и дроп появится здесь")
        drawList:AddText(imgui.ImVec2(tx + (listW - imgui.CalcTextSize(t1).x) / 2, ty + 38), 0xFFAAAAAA, t1)
        drawList:AddText(imgui.ImVec2(tx + (listW - imgui.CalcTextSize(t2).x) / 2, ty + 62), 0xFF666666, t2)
        imgui.SetCursorScreenPos(imgui.ImVec2(tx, ty + eh + 8))
        imgui.Dummy(imgui.ImVec2(listW, 0))
        return
    end
    local hdrH, rowH, footH = 30, 44, 38
    local colPill, colQty, colPrice = 0.34, 0.43, 0.63
    local priceW = listW * 0.16
    local mp = imgui.GetMousePos()
    drawList:AddRectFilled(imgui.ImVec2(tx, ty), imgui.ImVec2(tx + listW, ty + hdrH), 0xFF1A1A1A, 10, 3)
    drawList:AddText(imgui.ImVec2(tx + 16, ty + 8), 0xFF777777, u8("Предмет"))
    drawList:AddText(imgui.ImVec2(tx + listW * colPill + 6, ty + 8), 0xFF777777, u8("Раз"))
    drawList:AddText(imgui.ImVec2(tx + listW * colQty, ty + 8), 0xFF777777, u8("Количество (база + бонус)"))
    drawList:AddText(imgui.ImVec2(tx + listW * colPrice + 6, ty + 8), 0xFF777777, u8("Цена за шт"))
    local hp = u8("Прибыль")
    drawList:AddText(imgui.ImVec2(tx + listW - 14 - imgui.CalcTextSize(hp).x, ty + 8), 0xFF777777, hp)
    local nameMaxW = listW * colPill - 62
    for idx, r in ipairs(st.rows) do
        local rowY = ty + hdrH + (idx - 1) * rowH
        local midY = rowY + rowH / 2
        local textY = rowY + (rowH - 14) / 2
        local hovered = (mp.x >= tx and mp.x <= tx + listW and mp.y >= rowY and mp.y <= rowY + rowH)
        local bg = hovered and 0xFF1C1C1C or ((idx % 2 == 0) and 0xFF161616 or 0xFF121212)
        drawList:AddRectFilled(imgui.ImVec2(tx + 1, rowY), imgui.ImVec2(tx + listW - 1, rowY + rowH), bg)
        drawList:AddLine(imgui.ImVec2(tx + 8, rowY + rowH), imgui.ImVec2(tx + listW - 8, rowY + rowH), 0xFF1F1F1F, 1.0)
        drawList:AddRectFilled(imgui.ImVec2(tx + 1, rowY + 10), imgui.ImVec2(tx + 4, rowY + rowH - 10), (r.profit > 0) and 0xFF1AE591 or 0xFF3A3A3A, 2)
        local fullName = r.name or ""
        if fullName == "" then fullName = "Предмет #" .. tostring(r.id) end
        local ac = imgui.ImVec2(tx + 30, midY)
        drawList:AddCircleFilled(ac, 14, NFT_AVATAR_COLORS[(r.id % 6) + 1])
        local letter = u8(fullName:sub(1, 1))
        drawList:AddText(imgui.ImVec2(ac.x - imgui.CalcTextSize(letter).x / 2, ac.y - 7), 0xFFFFFFFF, letter)
        local nm, shown, guard = fullName, fullName, 0
        while imgui.CalcTextSize(u8(shown)).x > nameMaxW and #nm > 3 and guard < 60 do
            nm = nm:sub(1, #nm - 1)
            shown = nm .. ".."
            guard = guard + 1
        end
        drawList:AddText(imgui.ImVec2(tx + 52, textY), 0xFFE6E6E6, u8(shown))
        local ptxt = "x" .. tostring(r.times)
        local pw = imgui.CalcTextSize(ptxt).x + 16
        local ppx = tx + listW * colPill + 2
        drawList:AddRectFilled(imgui.ImVec2(ppx, midY - 11), imgui.ImVec2(ppx + pw, midY + 11), 0xFF222222, 11)
        drawList:AddText(imgui.ImVec2(ppx + 8, textY), 0xFFAAAAAA, ptxt)
        local qx = tx + listW * colQty
        local totTxt = formatNumber(r.actual)
        drawList:AddText(imgui.ImVec2(qx, textY), 0xFFFFFFFF, totTxt)
        local off = imgui.CalcTextSize(totTxt).x + 10
        local baseTxt = "(" .. formatNumber(r.base) .. " "
        drawList:AddText(imgui.ImVec2(qx + off, textY), 0xFF777777, baseTxt)
        off = off + imgui.CalcTextSize(baseTxt).x
        local bonusTxt = ((r.bonus >= 0) and "+" or "") .. formatNumber(r.bonus) .. ")"
        drawList:AddText(imgui.ImVec2(qx + off, textY), (r.bonus > 0) and 0xFF33CCFF or 0xFF777777, bonusTxt)
        local key = tostring(r.id)
        local buf = nftPriceInts[r.id]
        if not buf then
            buf = imgui.ImInt(r.price or 0)
            nftPriceInts[r.id] = buf
        end
        imgui.SetCursorScreenPos(imgui.ImVec2(tx + listW * colPrice + 6, rowY + (rowH - 22) / 2))
        imgui.PushItemWidth(priceW)
        if imgui.InputInt("##nftp" .. key, buf, 0, 0) then
            if buf.v < 0 then buf.v = 0 end
            nftData.prices[key] = buf.v
            nftPriceDirtyAt = os.clock()
            nftStatsCache = nil
        end
        imgui.PopItemWidth()
        local pt = formatNumber(r.profit) .. " $"
        drawList:AddText(imgui.ImVec2(tx + listW - 14 - imgui.CalcTextSize(pt).x, rowY + 8), (r.profit > 0) and 0xFF33CC66 or 0xFF666666, pt)
        local barW = listW * 0.16
        local bx = tx + listW - 14 - barW
        local by = rowY + rowH - 13
        drawList:AddRectFilled(imgui.ImVec2(bx, by), imgui.ImVec2(bx + barW, by + 3), 0xFF262626, 2)
        local share = (st.profit > 0) and (r.profit / st.profit) or 0
        if share > 0 then
            drawList:AddRectFilled(imgui.ImVec2(bx, by), imgui.ImVec2(bx + math.max(3, barW * share), by + 3), 0xFF1AE591, 2)
        end
    end
    local fy = ty + hdrH + #st.rows * rowH
    drawList:AddRectFilled(imgui.ImVec2(tx + 1, fy), imgui.ImVec2(tx + listW - 1, fy + footH), 0xFF1A1A1A, 10, 12)
    drawList:AddText(imgui.ImVec2(tx + 16, fy + 12), 0xFF999999, u8("Итого"))
    drawList:AddText(imgui.ImVec2(tx + listW * colQty, fy + 12), 0xFFFFFFFF, formatNumber(st.totalActual) .. u8(" шт"))
    local tp = formatNumber(st.profit) .. " $"
    drawList:AddText(imgui.ImVec2(tx + listW - 14 - imgui.CalcTextSize(tp).x, fy + 12), 0xFF1AE591, tp)
    local totalH = hdrH + #st.rows * rowH + footH
    drawList:AddRect(imgui.ImVec2(tx, ty), imgui.ImVec2(tx + listW, ty + totalH), 0xFF2A2A2A, 10, 15, 1.2)
    imgui.SetCursorScreenPos(imgui.ImVec2(tx, ty + totalH + 8))
    imgui.Dummy(imgui.ImVec2(listW, 0))
end
function drawSideIncomeHubTab()
    drawHubTiles("side", {
        {title = u8("Пейдеи"), desc = u8("Доход с зарплаты, депозита и аксов"), icon = fa.ICON_MONEY, accent = 0xFF1AE591, tab = 16},
        {title = u8("Аренда"), desc = u8("Доход с аренды через Item Market и Arizona Rent"), icon = fa.ICON_SHOPPING_CART, accent = 0xFFF8BD38, tab = 17},
        {title = u8("Осколки"), desc = u8("Доход с осколков тайников и NFT"), icon = fa.ICON_STAR, accent = 0xFFFA8BA7, tab = 18},
        {title = u8("Кейсы"), desc = u8("Учёт выпавших ларцов и прибыль с них"), icon = fa.ICON_BRIEFCASE, accent = 0xFF28AAFF, tab = 19},
        {title = u8("Криптовалюта"), desc = u8("Доход с BTC и ASC"), icon = fa.ICON_USD, accent = 0xFF15CCFA, tab = 20},
        {title = u8("NFT контейнеры"), desc = u8("Учёт дропа с NFT контейнеров и прибыль"), icon = fa.ICON_BRIEFCASE, accent = 0xFFB672F4, tab = 24},
    })
end
hubTileAnim = {}
hubTileLastT = nil
rhAnimT = {}
function rhVisRows(top, rowH, n)
    if n <= 0 then return 1, 0 end
    local wp = imgui.GetWindowPos()
    local wh = imgui.GetWindowHeight()
    local visMin = wp.y - rowH * 2
    local visMax = wp.y + wh + rowH * 2
    local first = math.floor((visMin - top) / rowH) + 1
    local last = math.floor((visMax - top) / rowH) + 1
    if first < 1 then first = 1 end
    if last > n then last = n end
    if last - first > 150 then last = first + 150 end
    return first, last
end
addEventHandler('onWindowMessage', function(msg, wparam, lparam)
    if msg == (wm.WM_MOUSEWHEEL or 0x020A) and RI and RI.tableHover then
        local hi = math.floor((wparam % 4294967296) / 65536)
        if hi >= 32768 then hi = hi - 65536 end
        RI.wheelAcc = (RI.wheelAcc or 0) + hi / 120
    end
end)
function rhAnim(key, target, speed)
    local now = os.clock()
    local s = rhAnimT[key]
    if not s then s = {v = target, t = now}; rhAnimT[key] = s end
    local dt = math.min(now - s.t, 0.05)
    s.t = now
    s.v = s.v + (target - s.v) * math.min(1, dt * (speed or 14))
    if math.abs(target - s.v) < 0.002 then s.v = target end
    return s.v
end
function rhLerpColor(a, b, t)
    local r = 0
    for i = 0, 3 do
        local sh = 256 ^ i
        local ca = math.floor(a / sh) % 256
        local cb = math.floor(b / sh) % 256
        r = r + math.floor(ca + (cb - ca) * t + 0.5) * sh
    end
    return r
end
function rhAlpha(c, al)
    return (c % 16777216) + math.floor(al * 255 + 0.5) * 16777216
end
function rhTipFrame(dl, key, show, w, h, accent, x, y, altY)
    local a = rhAnim(key, show and 1 or 0)
    if a < 0.02 then return nil end
    local P = imgui.ImVec2
    local winTop, winH = imgui.GetWindowPos().y, imgui.GetWindowHeight()
    local py = y
    if py + h > winTop + winH - 6 then
        py = altY or math.max(winTop + 6, winTop + winH - h - 6)
    end
    py = py + (1 - a) * 6
    dl:AddRectFilled(P(x - 1, py + 3), P(x + w + 1, py + h + 6), rhAlpha(0xFF000000, 0.35 * a), 14)
    dl:AddRectFilled(P(x, py), P(x + w, py + h), rhAlpha(0xFF141414, 0.98 * a), 12)
    dl:AddRect(P(x, py), P(x + w, py + h), rhAlpha(accent, 0.45 * a), 12, 15, 1.0)
    return a, x, py
end
-- Тултипы в стиле достижений: карточка у курсора, рисуется через оверлей.
-- rhTipBegin/rhTipEnd заменяют BeginTooltip/EndTooltip: пока tip активен, вызовы
-- imgui.Text / TextColored / Separator / SameLine записываются в rows, а rhTipEnd рисует их карточкой.
-- rhTip(text) заменяет SetTooltip(text).
RT = RT or {}
RT.active = false
RT.rows = nil
RT.join = false
RT.last = -10
RT.orig = {
    Text = imgui.Text,
    TextColored = imgui.TextColored,
    Separator = imgui.Separator,
    SameLine = imgui.SameLine,
}
function rhTipVecToU32(v)
    if type(v) == "number" then return v end
    local function ch(x) return math.floor(math.max(0, math.min(1, x)) * 255 + 0.5) end
    return ch(v.w) * 16777216 + ch(v.z) * 65536 + ch(v.y) * 256 + ch(v.x)
end
function rhTipAdd(text, col)
    local first = true
    for line in (tostring(text) .. "\n"):gmatch("(.-)\n") do
        local last = RT.rows[#RT.rows]
        if RT.join and first and last and not last.sep then
            last[#last + 1] = {t = line, c = col}
        else
            RT.rows[#RT.rows + 1] = {{t = line, c = col}}
        end
        first = false
    end
    RT.join = false
end
function imgui.Text(text, ...)
    if RT.active then return rhTipAdd(text, 0xFFE6E6E6) end
    return RT.orig.Text(text, ...)
end
function imgui.TextColored(col, text, ...)
    if RT.active then return rhTipAdd(text, rhTipVecToU32(col)) end
    return RT.orig.TextColored(col, text, ...)
end
function imgui.Separator()
    if RT.active then RT.rows[#RT.rows + 1] = {sep = true}; return end
    return RT.orig.Separator()
end
function imgui.SameLine(...)
    if RT.active then RT.join = true; return end
    return RT.orig.SameLine(...)
end
function rhTipBegin()
    RT.active = true
    RT.rows = {}
    RT.join = false
end
function rhTipEnd()
    RT.active = false
    local rows = RT.rows or {}
    RT.rows = nil
    if #rows == 0 then return end
    RT.pending = {rows = rows, t = os.clock()}
end
function rhTipFlush()
    local pd = RT.pending
    RT.pending = nil
    if not pd or os.clock() - pd.t > 0.15 then return end
    local rows = pd.rows
    local P = imgui.ImVec2
    local dl = imgui.GetWindowDrawList()
    local now = os.clock()
    if now - RT.last > 0.12 then rhAnimT["tipc"] = {v = 0, t = now} end
    RT.last = now
    local a = rhAnim("tipc", 1)
    local accent = (PD.C and PD.C.green) or 0xFF91E51A

    local lh = imgui.CalcTextSize("A").y
    local padX, padY, rowGap, sepH, joinGap = 14, 11, 4, 9, 6
    local w, h = 0, padY * 2 - rowGap
    for _, r in ipairs(rows) do
        if r.sep then
            h = h + sepH
        else
            local rw = 0
            for j, s in ipairs(r) do
                s.w = imgui.CalcTextSize(s.t).x
                rw = rw + s.w + (j > 1 and joinGap or 0)
            end
            w = math.max(w, rw)
            h = h + lh + rowGap
        end
    end
    w = w + padX * 2
    h = math.max(h, padY * 2 + lh)

    local mp = imgui.GetMousePos()
    local sw, sh = getScreenResolution()
    local x, y = mp.x + 18, mp.y + 22
    if x + w > sw - 6 then x = mp.x - w - 12 end
    if y + h > sh - 6 then y = mp.y - h - 12 end
    x, y = math.max(6, x), math.max(6, y)
    y = y + (1 - a) * 6

    dl:PushClipRect(P(0, 0), P(sw, sh), false)
    dl:AddRectFilled(P(x - 1, y + 3), P(x + w + 1, y + h + 6), rhAlpha(0xFF000000, 0.35 * a), 14)
    dl:AddRectFilled(P(x, y), P(x + w, y + h), rhAlpha(0xFF141414, 0.98 * a), 12)
    dl:AddRect(P(x, y), P(x + w, y + h), rhAlpha(accent, 0.45 * a), 12, 15, 1.0)
    local cy = y + padY
    for _, r in ipairs(rows) do
        if r.sep then
            local ly = cy + sepH / 2 - 2
            dl:AddLine(P(x + 12, ly), P(x + w - 12, ly), rhAlpha(0xFF2A2A2A, a), 1.0)
            cy = cy + sepH
        else
            local cx = x + padX
            for _, s in ipairs(r) do
                dl:AddText(P(cx, cy), rhAlpha(s.c or 0xFFE6E6E6, a), s.t)
                cx = cx + s.w + joinGap
            end
            cy = cy + lh + rowGap
        end
    end
    dl:PopClipRect()
end
function rhTip(text)
    rhTipBegin()
    imgui.Text(text)
    rhTipEnd()
end
function drawHubTiles(idPrefix, cards)
    local drawList = imgui.GetWindowDrawList()
    local listW = imgui.GetWindowWidth() - 25
    local gap = 12
    local cols = ((listW - gap) / 2 >= 250) and 2 or 1
    local tileW = (listW - gap * (cols - 1)) / cols
    local tileH = 84
    local now = os.clock()
    local dt = math.min(now - (hubTileLastT or now), 0.05)
    hubTileLastT = now
    imgui.Dummy(imgui.ImVec2(1, 4))
    local pos = imgui.GetCursorScreenPos()
    for i, card in ipairs(cards) do
        local col = (i - 1) % cols
        local row = math.floor((i - 1) / cols)
        local tx = pos.x + col * (tileW + gap)
        local ty = pos.y + row * (tileH + gap)
        imgui.SetCursorScreenPos(imgui.ImVec2(tx, ty))
        local clicked = imgui.InvisibleButton("##hubtile_" .. idPrefix .. "_" .. i, imgui.ImVec2(tileW, tileH))
        local hovered = imgui.IsItemHovered()
        local pressed = imgui.IsItemActive()
        local target = hovered and 1 or 0
        local animKey = idPrefix .. "_" .. i
        local a = hubTileAnim[animKey] or 0
        a = a + (target - a) * math.min(1, dt * 14)
        if math.abs(target - a) < 0.002 then a = target end
        hubTileAnim[animKey] = a
        local bgCol, bgHov, brdCol, accent, titleCol
        if useCustomTheme then
            bgCol = imVec4ToHex(CUSTOM_THEME.cardBg)
            bgHov = imVec4ToHex(CUSTOM_THEME.cardBgHovered)
            brdCol = imVec4ToHex(CUSTOM_THEME.cardBorder)
            accent = imVec4ToHex(CUSTOM_THEME.cardIcon)
            titleCol = imVec4ToHex(CUSTOM_THEME.cardTitle)
        else
            bgCol, bgHov, brdCol, accent, titleCol = rhCB(0xFF181818), rhCBH(0xFF1F1F1F), rhCBR(0xFF2C2C2C), card.accent, 0xFFFFFFFF
        end
        local lift = -2 * a + (pressed and 2 or 0)
        local x0, y0 = tx, ty + lift
        local x1, y1 = tx + tileW, ty + tileH + lift
        local p0, p1 = imgui.ImVec2(x0, y0), imgui.ImVec2(x1, y1)
        if a > 0.01 then
            drawList:AddRectFilled(imgui.ImVec2(x0 + 3, y0 + 6), imgui.ImVec2(x1 - 3, y1 + 6), rhAlpha(0xFF000000, 0.35 * a), 14)
        end
        local bg = rhLerpColor(bgCol, bgHov, a)
        if pressed then bg = rhLerpColor(bg, 0xFF000000, 0.2) end
        drawList:AddRectFilled(p0, p1, bg, 12)
        drawList:AddLine(imgui.ImVec2(x0 + 14, y0 + 1), imgui.ImVec2(x1 - 14, y0 + 1), rhAlpha(0xFFFFFFFF, 0.05 + 0.05 * a), 1.0)
        drawList:AddRect(p0, p1, rhLerpColor(brdCol, accent, 0.55 * a), 12, 15, 1.0)
        local ic = imgui.ImVec2(x0 + 38, y0 + tileH / 2)
        local halo = 0.03 + 0.05 * a
        drawList:AddCircleFilled(ic, 34, rhAlpha(accent, halo), 32)
        drawList:AddCircleFilled(ic, 29, rhAlpha(accent, halo), 32)
        drawList:AddCircleFilled(ic, 25, rhAlpha(accent, halo), 32)
        drawList:AddCircleFilled(ic, 22, rhLerpColor(bg, accent, 0.16 + 0.14 * a), 32)
        drawList:AddCircle(ic, 22, rhAlpha(accent, 0.35 + 0.5 * a), 32, 1.0)
        local iconSz = imgui.CalcTextSize(card.icon)
        drawList:AddText(imgui.ImVec2(ic.x - iconSz.x / 2, ic.y - iconSz.y / 2), accent, card.icon)
        local chip = imgui.ImVec2(x1 - 28, y0 + tileH / 2)
        drawList:AddCircleFilled(chip, 14, rhLerpColor(rhLerpColor(bg, 0xFFFFFFFF, 0.06), accent, a), 24)
        local chevron = fa.ICON_ANGLE_RIGHT
        local chevSz = imgui.CalcTextSize(chevron)
        drawList:AddText(imgui.ImVec2(chip.x - chevSz.x / 2 + a, chip.y - chevSz.y / 2), rhLerpColor(rhDim(0xFF8A8A8A), 0xFF101010, a), chevron)
        local textX = x0 + 76
        local midY = y0 + tileH / 2
        drawList:PushClipRect(imgui.ImVec2(textX, y0), imgui.ImVec2(x1 - 46, y1), true)
        drawList:AddText(imgui.ImVec2(textX, midY - 19), titleCol, card.title)
        drawList:AddText(imgui.ImVec2(textX, midY + 3), rhLerpColor(rhDim(0xFF808080), rhVc() and 0xFFFFFFFF or 0xFFA8A8A8, a), card.desc)
        drawList:PopClipRect()
        local lineW = (tileW - 76 - 18) * a
        if lineW > 1 then
            drawList:AddRectFilled(imgui.ImVec2(textX, y1 - 9), imgui.ImVec2(textX + lineW, y1 - 7), rhAlpha(accent, 0.9), 1)
        end
        if clicked then
            currentTab = card.tab
            if card.isIncass and not stockScannedThisSession then pendingStockScan = true end
            if card.workType and (not scanState.active or scanState.isTalonScan) then
                switchWorkType(card.workType); workTypeSelected = true
                if not scannedThisSession[card.workType] then pendingScan = card.workType end
            end
        end
    end
    local rows = math.ceil(#cards / cols)
    imgui.SetCursorScreenPos(imgui.ImVec2(pos.x, pos.y + rows * (tileH + gap)))
    imgui.Dummy(imgui.ImVec2(listW, 0))
end
function drawJobsHubTab()
    drawHubTiles("jobs", {
        {title = u8("Ферма"), desc = u8("Доход и статистика с работы на ферме"), icon = fa.ICON_LEAF, accent = 0xFF1AE591, tab = 2, workType = WORK_TYPES.FARM},
        {title = u8("Шахта"), desc = u8("Доход и статистика с работы в шахте"), icon = fa.ICON_GAVEL, accent = 0xFF28AAFF, tab = 3, workType = WORK_TYPES.MINE},
        {title = u8("Лесопилка"), desc = u8("Доход и статистика с работы на лесопилке"), icon = fa.ICON_TREE, accent = 0xFF99D334, tab = 4, workType = WORK_TYPES.SAWMILL},
        {title = u8("Нефтевышки"), desc = u8("Доход и статистика с нефтевышек"), icon = fa.ICON_FIRE, accent = 0xFFFA8BA7, tab = 12},
        {title = u8("Такси"), desc = u8("Доход и статистика с работы на такси"), icon = fa.ICON_TAXI, accent = 0xFF15CCFA, tab = 21},
        {title = u8("Инкассатор"), desc = u8("Доход с банкоматов и акции"), icon = fa.ICON_MONEY, accent = 0xFFF8BD38, tab = 23, isIncass = true},
    })
end
PD = PD or {}
PD.EMPTY = {total = 0, salary = 0, deposit = 0, acc = 0, az = 0, rub = 0, count = 0, best = 0, logs = {}}
PD.C_BASE = {
    green = 0xFF33DD77, az = 0xFF00CCFF, rub = 0xFF4CAF50,
    sal = 0xFFF8BD38, dep = 0xFFFA8BA7, acc = 0xFF28AAFF,
    mute = 0xFF8A8A8A, dim = 0xFF555555, text = 0xFFE6E6E6, gold = 0xFF00D7FF,
}
PD.C_VC = {mute = 0xFFF5DDC9, dim = 0xFF754C2F, text = 0xFFFFFFFF}
PD.C = setmetatable({}, {__index = function(_, k)
    if rhVc() then
        local v = PD.C_VC[k]
        if v then return v end
    end
    return PD.C_BASE[k]
end})
function PD.str()
    if PD.S then return PD.S end
    PD.S = {
        cap = u8("Доход с пейдеев за сегодня"),
        last7 = u8("Последние 7 дней"),
        yest = u8("Вчера"), week = u8("Неделя"), allTime = u8("Всё время"),
        today = u8("Сегодня"), todayL = u8("сегодня"), yestL = u8("вчера"),
        sal = u8("Зарплата"), dep = u8("Депозит"), salShort = u8("Зарп."), depShort = u8("Деп."), accs = u8("Аксы/предметы"), accShort = u8("Аксы"),
        total = u8("Общий доход"), itogo = u8("Итого"), time = u8("Время"), rubs = u8("Рубли"),
        listTitle = u8("Выплаты за день"),
        noToday = u8("Пока нет выплат за сегодня"),
        empty = u8("Пейдеев пока нет"),
        emptySub = u8("Запись появится автоматически после первой выплаты"),
        noRec = u8("Нет записей"),
        emptyDay = u8("В этот день выплат не было"),
        best = u8("Лучший пейдей дня"),
        avg = u8("Средний пейдей: "),
        days = u8("дн."),
        month = u8("За месяц: "),
        less = u8("меньше"), more = u8("больше"),
        hint = u8("Нажмите, чтобы выбрать дату"),
        divid = u8("Дивидендный договор: "), heart = u8("Космическое сердце: "), fam = u8("Семейные выплаты: "),
        mln = u8(" млн"), mlrd = u8(" млрд"), ths = u8(" тыс"),
        pl = {u8("пейдей"), u8("пейдея"), u8("пейдеев")},
        wd = {u8("Пн"), u8("Вт"), u8("Ср"), u8("Чт"), u8("Пт"), u8("Сб"), u8("Вс")},
        wdFull = {u8("Понедельник"), u8("Вторник"), u8("Среда"), u8("Четверг"), u8("Пятница"), u8("Суббота"), u8("Воскресенье")},
        monN = {u8("Январь"), u8("Февраль"), u8("Март"), u8("Апрель"), u8("Май"), u8("Июнь"), u8("Июль"), u8("Август"), u8("Сентябрь"), u8("Октябрь"), u8("Ноябрь"), u8("Декабрь")},
        monG = {u8("января"), u8("февраля"), u8("марта"), u8("апреля"), u8("мая"), u8("июня"), u8("июля"), u8("августа"), u8("сентября"), u8("октября"), u8("ноября"), u8("декабря")},
    }
    return PD.S
end
function PD.vec4(c, a)
    local r = c % 256
    local g = math.floor(c / 256) % 256
    local b = math.floor(c / 65536) % 256
    return imgui.ImVec4(r / 255, g / 255, b / 255, a or 1)
end
function PD.short(n)
    local S = PD.str()
    n = n or 0
    local a = math.abs(n)
    local v, suf
    if a >= 1e9 then v, suf = n / 1e9, S.mlrd
    elseif a >= 1e6 then v, suf = n / 1e6, S.mln
    elseif a >= 1e3 then v, suf = n / 1e3, S.ths
    else return formatNumber(n) end
    local t = string.format("%.1f", v)
    t = t:gsub("%.0$", "")
    return t .. suf
end
function PD.plural(n, f)
    n = math.floor(math.abs(n or 0))
    local n10, n100 = n % 10, n % 100
    if n10 == 1 and n100 ~= 11 then return f[1]
    elseif n10 >= 2 and n10 <= 4 and (n100 < 12 or n100 > 14) then return f[2] end
    return f[3]
end
function PD.parse(d)
    local y, m, dd = tostring(d):match("(%d+)-(%d+)-(%d+)")
    return tonumber(y) or 1970, tonumber(m) or 1, tonumber(dd) or 1
end
function PD.weekday(d)
    local y, m, dd = PD.parse(d)
    local w = tonumber(os.date("%w", os.time({year = y, month = m, day = dd, hour = 12}))) or 1
    if w == 0 then w = 7 end
    return w
end
function PD.dim(y, m)
    if m == 2 and (y % 4 == 0 and (y % 100 ~= 0 or y % 400 == 0)) then return 29 end
    local t = {31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31}
    return t[m] or 30
end
function PD.fmtDate(d, short)
    local S = PD.str()
    local y, m, dd = PD.parse(d)
    if short then return S.wd[PD.weekday(d)] .. ", " .. dd .. " " .. S.monG[m] end
    return dd .. " " .. S.monG[m] .. " " .. y
end
function PD.hov(x, y, w, h)
    local mp = imgui.GetMousePos()
    return mp.x >= x and mp.x <= x + w and mp.y >= y and mp.y <= y + h
end
function PD.select(date)
    PD.sel = date
    local y, m = PD.parse(date)
    PD.calY, PD.calM = y, m
end
function PD.build()
    local log = paydayLog or {}
    local todayKey = getGameDate()
    local e1 = log[1]
    local sig = #log .. "|" .. todayKey
    if e1 then
        sig = sig .. "|" .. (e1.time or 0) .. "|" .. (e1.total or 0) .. "|" .. (e1.az or 0) .. "|" .. (e1.rub or 0)
    end
    if PD.cache and PD.cache.sig == sig then return PD.cache end
    local byDate, dates = {}, {}
    local all = {total = 0, az = 0, rub = 0, count = 0}
    for _, e in ipairs(log) do
        local d = getGameDate(e.time)
        local ds = byDate[d]
        if not ds then
            ds = {total = 0, salary = 0, deposit = 0, acc = 0, az = 0, rub = 0, count = 0, best = 0, logs = {}}
            byDate[d] = ds
            dates[#dates + 1] = d
        end
        local t = e.total or e.amount or 0
        ds.total = ds.total + t
        ds.salary = ds.salary + (e.salary or 0)
        ds.deposit = ds.deposit + (e.deposit or 0)
        ds.acc = ds.acc + (e.accesories or 0)
        ds.az = ds.az + (e.az or 0)
        ds.rub = ds.rub + (e.rub or 0)
        ds.count = ds.count + 1
        if t > ds.best then ds.best = t end
        ds.logs[#ds.logs + 1] = e
        all.total = all.total + t
        all.az = all.az + (e.az or 0)
        all.rub = all.rub + (e.rub or 0)
        all.count = all.count + 1
    end
    table.sort(dates, function(a, b) return a > b end)
    local mskWday = tonumber(os.date("!%w", getMoscowTime())) or 1
    if mskWday == 0 then mskWday = 7 end
    local week = {total = 0, az = 0, rub = 0, count = 0}
    for i = 0, mskWday - 1 do
        local ds = byDate[getGameDate(os.time() - i * 86400)]
        if ds then
            week.total = week.total + ds.total
            week.az = week.az + ds.az
            week.rub = week.rub + ds.rub
            week.count = week.count + ds.count
        end
    end
    local last7 = {}
    for i = 6, 0, -1 do
        local d = getGameDate(os.time() - i * 86400)
        local ds = byDate[d]
        last7[#last7 + 1] = {date = d, wd = PD.weekday(d), total = ds and ds.total or 0, az = ds and ds.az or 0, count = ds and ds.count or 0}
    end
    local yestKey = getGameDate(os.time() - 86400)
    PD.cache = {
        sig = sig, byDate = byDate, dates = dates, all = all, week = week, last7 = last7,
        todayKey = todayKey, yestKey = yestKey,
        today = byDate[todayKey] or PD.EMPTY, yest = byDate[yestKey] or PD.EMPTY,
    }
    return PD.cache
end
function PD.ensureSel(c)
    if not PD.sel then
        PD.select(c.byDate[c.todayKey] and c.todayKey or c.dates[1] or c.todayKey)
    end
    if not PD.calY then
        local y, m = PD.parse(PD.sel)
        PD.calY, PD.calM = y, m
    end
end
function PD.dayTip(date, ds)
    local S, C = PD.str(), PD.C
    imgui.TextColored(PD.vec4(0xFFFFFFFF), PD.fmtDate(date, true))
    if ds and ds.count > 0 then
        imgui.TextColored(PD.vec4(C.green), formatNumber(ds.total) .. "$")
        if ds.az > 0 then imgui.TextColored(PD.vec4(C.az), formatNumber(ds.az) .. " AZ") end
        if showRubColumn and ds.rub > 0 then imgui.TextColored(PD.vec4(C.rub), formatNumber(ds.rub) .. " RUB") end
        imgui.TextColored(PD.vec4(C.mute), ds.count .. " " .. PD.plural(ds.count, ds.pl or S.pl))
    else
        imgui.TextColored(PD.vec4(C.mute), S.noRec)
    end
end
function PD.hero(dl, c, x, y, w, h, ACC, bg, brd)
    local S, C = PD.str(), PD.C
    local P = imgui.ImVec2
    local td = c.today
    local lw = math.floor(w * 0.56)
    rhCardBox(dl, x, y, w, h, bg, brd, 14)
    dl:AddLine(P(x + lw, y + 18), P(x + lw, y + h - 18), rhAlpha(0xFFFFFFFF, 0.06), 1.0)
    dl:AddText(P(x + 22, y + 14), C.mute, S.cap)
    local big = formatNumber(td.total) .. "$"
    if rhBigFont then
        imgui.PushFont(rhBigFont)
        imgui.SetCursorScreenPos(P(x + 22, y + 32))
        imgui.TextColored(PD.vec4(C.green), big)
        imgui.PopFont()
    else
        dl:AddText(P(x + 22, y + 38), C.green, big)
        dl:AddText(P(x + 23, y + 38), C.green, big)
    end
    local px, py = x + 22, y + 76
    local function pill(text, col)
        px = px + rhPill(dl, px, py, text, col) + 6
    end
    if td.count > 0 then pill(td.count .. " " .. PD.plural(td.count, S.pl), C.sal) end
    if td.az > 0 then pill(formatNumber(td.az) .. " AZ", C.az) end
    if showRubColumn and td.rub > 0 then pill(formatNumber(td.rub) .. " RUB", C.rub) end
    local bx0, bx1, by = x + 22, x + lw - 20, y + h - 40
    dl:AddRectFilled(P(bx0, by), P(bx1, by + 8), rhAlpha(0xFFFFFFFF, 0.07), 4)
    if td.total > 0 then
        local parts = {
            {td.salary, C.sal, S.sal, S.salShort}, {td.deposit, C.dep, S.dep, S.depShort}, {td.acc, C.acc, S.accShort, S.accShort},
        }
        local sum = 0
        for _, p in ipairs(parts) do sum = sum + math.max(p[1], 0) end
        if sum <= 0 then sum = td.total end
        local present = {}
        for _, p in ipairs(parts) do if p[1] > 0 then present[#present + 1] = p end end
        local gap = 2
        local usable = (bx1 - bx0) - gap * math.max(#present - 1, 0)
        local cx = bx0
        for _, p in ipairs(present) do
            local pw = math.max(usable * (p[1] / sum), 3)
            dl:AddRectFilled(P(cx, by), P(cx + pw, by + 8), p[2], 4)
            cx = cx + pw + gap
        end
        local items, totalW = {}, 0
        for k, p in ipairs(parts) do
            if p[1] > 0 then
                local pct = math.floor(p[1] / sum * 100 + 0.5)
                items[#items + 1] = {col = p[2], full = p[3] .. " " .. pct .. "%", short = p[4] .. " " .. pct .. "%"}
                totalW = totalW + 22 + imgui.CalcTextSize(p[3] .. " " .. pct .. "%").x
            end
        end
        local useShort = totalW > (bx1 - bx0) + 10
        local lx = bx0
        for _, it in ipairs(items) do
            local txt = useShort and it.short or it.full
            dl:AddCircleFilled(P(lx + 4, by + 22), 3, it.col, 12)
            dl:AddText(P(lx + 12, by + 14), 0xFFB8B8B8, txt)
            lx = lx + 22 + imgui.CalcTextSize(txt).x
        end
    else
        dl:AddText(P(bx0, by + 14), C.dim, S.noToday)
    end
    local rx0, rx1 = x + lw + 20, x + w - 20
    local rw = rx1 - rx0
    dl:AddText(P(rx0, y + 14), C.mute, S.last7)
    local cy0, cy1 = y + 44, y + h - 36
    local chH = cy1 - cy0
    local slot = rw / 7
    local bw = math.max(8, slot - 10)
    local maxV = 1
    for _, d in ipairs(c.last7) do if d.total > maxV then maxV = d.total end end
    for i, d in ipairs(c.last7) do
        local sx = rx0 + (i - 1) * slot
        local bxx = sx + (slot - bw) / 2
        imgui.SetCursorScreenPos(P(sx, cy0 - 6))
        local clicked = imgui.InvisibleButton("##pd_bar_" .. i, imgui.ImVec2(slot, chH + 6 + 28))
        local hv = imgui.IsItemHovered()
        local a = rhAnim("pd_bar_" .. i, hv and 1 or 0)
        local isToday = (d.date == c.todayKey)
        local isSel = (d.date == PD.sel)
        local bh = d.total > 0 and math.max(4, chH * d.total / maxV) or 2
        local col
        if d.total <= 0 then
            col = rhAlpha(0xFFFFFFFF, 0.07 + 0.06 * a)
        else
            local base = rhLerpColor(bg, ACC, isToday and 1 or 0.5)
            col = rhLerpColor(base, 0xFFFFFFFF, 0.22 * a)
        end
        dl:AddRectFilled(P(bxx, cy1 - bh), P(bxx + bw, cy1), col, 4, 3)
        if isSel then
            dl:AddRect(P(bxx - 2, cy1 - bh - 2), P(bxx + bw + 2, cy1 + 2), rhAlpha(0xFFFFFFFF, 0.7), 5, 15, 1.2)
        end
        local lbl = S.wd[d.wd]
        local lsz = imgui.CalcTextSize(lbl)
        dl:AddText(P(sx + (slot - lsz.x) / 2, cy1 + 8), isToday and ACC or (isSel and 0xFFFFFFFF or C.mute), lbl)
        if hv then
            rhTipBegin()
            PD.dayTip(d.date, c.byDate[d.date])
            rhTipEnd()
        end
        if clicked then PD.select(d.date) end
    end
end
function PD.tiles(dl, c, x, y, w, h, ACC, bg, brd)
    local S, C = PD.str(), PD.C
    local P = imgui.ImVec2
    local gap = 8
    local tw = (w - gap * 2) / 3
    local items = {
        {key = "y", label = S.yest, icon = fa.ICON_CALENDAR, col = C.sal, d = c.yest},
        {key = "w", label = S.week, icon = fa.ICON_LIST, col = C.dep, d = c.week},
        {key = "a", label = S.allTime, icon = fa.ICON_TROPHY, col = C.acc, d = c.all},
    }
    for i, it in ipairs(items) do
        local tx = x + (i - 1) * (tw + gap)
        imgui.SetCursorScreenPos(P(tx, y))
        imgui.InvisibleButton("##pd_tile_" .. it.key, imgui.ImVec2(tw, h))
        local hv = imgui.IsItemHovered()
        local a = rhAnim("pd_tile_" .. it.key, hv and 1 or 0)
        local bgT = rhLerpColor(bg, rhLerpColor(bg, 0xFFFFFFFF, 0.04), a)
        rhCardBox(dl, tx, y, tw, h, bgT, rhLerpColor(brd, it.col, 0.55 * a), 12)
        rhIconBadge(dl, tx + 28, y + h / 2, 17, it.icon, it.col, bgT, a)
        local d = it.d
        local cnt = "x" .. (d.count or 0)
        dl:PushClipRect(P(tx + 52, y), P(tx + tw - 8, y + h), true)
        dl:AddText(P(tx + 54, y + 10), C.mute, it.label)
        dl:AddText(P(tx + tw - 14 - imgui.CalcTextSize(cnt).x, y + 10), rhLerpColor(0xFF606060, it.col, 0.4 + 0.6 * a), cnt)
        dl:AddText(P(tx + 54, y + 28), 0xFFFFFFFF, formatNumber(d.total) .. "$")
        local sub, subCol = "AZ: 0", C.dim
        if (d.az or 0) > 0 then sub, subCol = formatNumber(d.az) .. " AZ", C.az end
        if showRubColumn and (d.rub or 0) > 0 then sub = sub .. "  " .. formatNumber(d.rub) .. " RUB" end
        dl:AddText(P(tx + 54, y + 48), subCol, sub)
        dl:PopClipRect()
        if hv and (d.count or 0) > 0 then
            rhTipBegin()
            imgui.TextColored(PD.vec4(0xFFFFFFFF), it.label)
            imgui.TextColored(PD.vec4(C.green), formatNumber(d.total) .. "$")
            imgui.TextColored(PD.vec4(C.mute), S.avg .. formatNumber(d.total / d.count) .. "$")
            rhTipEnd()
        end
    end
end
function PD.nav(dl, c, x, y, w, h, ACC, bg, brd)
    local S, C = PD.str(), PD.C
    local P = imgui.ImVec2
    local sel = PD.sel
    local ds = c.byDate[sel] or PD.EMPTY
    local older, newer
    for _, d in ipairs(c.dates) do
        if d < sel then older = older or d
        elseif d > sel then newer = d end
    end
    local btnW, todayW, gap = 40, 96, 8
    local centerW = w - btnW * 2 - todayW - gap * 3
    local function sq(id, ix, icon, target)
        imgui.SetCursorScreenPos(P(ix, y))
        local clicked = imgui.InvisibleButton(id, imgui.ImVec2(btnW, h))
        local hv = imgui.IsItemHovered() and target ~= nil
        local a = rhAnim(id, hv and 1 or 0)
        rhCardBox(dl, ix, y, btnW, h, rhLerpColor(bg, rhLerpColor(bg, 0xFFFFFFFF, 0.05), a), rhLerpColor(brd, ACC, 0.55 * a), 12)
        local sz = imgui.CalcTextSize(icon)
        dl:AddText(P(ix + (btnW - sz.x) / 2, y + (h - sz.y) / 2), target and rhLerpColor(0xFF9A9A9A, ACC, a) or 0xFF3E3E3E, icon)
        if clicked and target then PD.select(target) end
    end
    sq("##pd_prev", x, fa.ICON_ANGLE_LEFT, older)
    local cx = x + btnW + gap
    imgui.SetCursorScreenPos(P(cx, y))
    local openCal = imgui.InvisibleButton("##pd_date_btn", imgui.ImVec2(centerW, h))
    local hv = imgui.IsItemHovered()
    local a = rhAnim("pd_date_btn", hv and 1 or 0)
    local bgC = rhLerpColor(bg, rhLerpColor(bg, 0xFFFFFFFF, 0.04), a)
    rhCardBox(dl, cx, y, centerW, h, bgC, rhLerpColor(brd, ACC, 0.55 * a), 12)
    rhIconBadge(dl, cx + 28, y + h / 2, 14, fa.ICON_CALENDAR, ACC, bgC, a)
    local sub = S.wdFull[PD.weekday(sel)]
    if sel == c.todayKey then sub = sub .. ", " .. S.todayL
    elseif sel == c.yestKey then sub = sub .. ", " .. S.yestL end
    local chev = fa.ICON_ANGLE_DOWN
    local chevSz = imgui.CalcTextSize(chev)
    dl:AddText(P(cx + centerW - 22 - chevSz.x / 2, y + (h - chevSz.y) / 2 + a * 1.5), rhLerpColor(0xFF6A6A6A, ACC, a), chev)
    local rightEdge = cx + centerW - 40
    local sumStr = formatNumber(ds.total) .. "$"
    local infoStr = ds.count .. " " .. PD.plural(ds.count, c.pl or S.pl)
    if ds.az > 0 then infoStr = infoStr .. ", " .. formatNumber(ds.az) .. " AZ" end
    local sumW, infoW = imgui.CalcTextSize(sumStr).x, imgui.CalcTextSize(infoStr).x
    dl:PushClipRect(P(cx + 52, y), P(cx + centerW - 36, y + h), true)
    dl:AddText(P(cx + 54, y + 7), 0xFFFFFFFF, PD.fmtDate(sel))
    dl:AddText(P(cx + 54, y + 25), C.mute, sub)
    if cx + 54 + imgui.CalcTextSize(PD.fmtDate(sel)).x + sumW + 24 < rightEdge then
        dl:AddText(P(rightEdge - sumW, y + 7), ds.count > 0 and C.green or C.dim, sumStr)
        dl:AddText(P(rightEdge - infoW, y + 25), C.mute, infoStr)
    end
    dl:PopClipRect()
    if openCal then
        local yy, mm = PD.parse(sel)
        PD.calY, PD.calM = yy, mm
        imgui.OpenPopup("##pd_cal")
    end
    local calOpen = imgui.BeginPopup("##pd_cal")
    if calOpen then
        PD.calendar(c, ACC)
        rhTipFlush()
        imgui.EndPopup()
    end
    if hv and not calOpen then
        rhTipBegin()
        imgui.TextColored(PD.vec4(C.mute), S.hint)
        rhTipEnd()
    end
    sq("##pd_next", cx + centerW + gap, fa.ICON_ANGLE_RIGHT, newer)
    local tx = cx + centerW + gap + btnW + gap
    imgui.SetCursorScreenPos(P(tx, y))
    local clickedT = imgui.InvisibleButton("##pd_today", imgui.ImVec2(todayW, h))
    local isToday = (sel == c.todayKey)
    local hvT = imgui.IsItemHovered() and not isToday
    local aT = rhAnim("pd_today", hvT and 1 or 0)
    rhCardBox(dl, tx, y, todayW, h, rhLerpColor(bg, ACC, (isToday and 0.0 or 0.10) + 0.10 * aT), rhLerpColor(brd, ACC, isToday and 0.0 or (0.45 + 0.4 * aT)), 12)
    local tsz = imgui.CalcTextSize(S.today)
    dl:AddText(P(tx + (todayW - tsz.x) / 2, y + (h - tsz.y) / 2), isToday and 0xFF4A4A4A or ACC, S.today)
    if clickedT and not isToday then PD.select(c.todayKey) end
end
function PD.calendar(c, ACC)
    local S, C = PD.str(), PD.C
    local P = imgui.ImVec2
    local dl = imgui.GetWindowDrawList()
    local cell, gap = 38, 4
    local step = cell + gap
    local cw = step * 7 - gap
    local mp = imgui.GetMousePos()
    local pos = imgui.GetCursorScreenPos()
    local y, m = PD.calY, PD.calM
    local function arrow(id, ax, icon, dm)
        local hv = mp.x >= ax and mp.x <= ax + 28 and mp.y >= pos.y + 3 and mp.y <= pos.y + 31
        dl:AddCircleFilled(P(ax + 14, pos.y + 17), 14, hv and 0xFF303030 or 0xFF1E1E1E, 20)
        local sz = imgui.CalcTextSize(icon)
        dl:AddText(P(ax + 14 - sz.x / 2, pos.y + 17 - sz.y / 2), hv and 0xFFFFFFFF or 0xFF9A9A9A, icon)
        imgui.SetCursorScreenPos(P(ax, pos.y + 3))
        if imgui.InvisibleButton(id, imgui.ImVec2(28, 28)) then
            m = m + dm
            if m < 1 then m = 12; y = y - 1 elseif m > 12 then m = 1; y = y + 1 end
            PD.calY, PD.calM = y, m
        end
    end
    arrow("##pd_cal_l", pos.x, fa.ICON_ANGLE_LEFT, -1)
    arrow("##pd_cal_r", pos.x + cw - 28, fa.ICON_ANGLE_RIGHT, 1)
    local mName, yName = S.monN[m], tostring(y)
    local mw, yw = imgui.CalcTextSize(mName).x, imgui.CalcTextSize(yName).x
    local tx = pos.x + (cw - mw - yw - 6) / 2
    dl:AddText(P(tx, pos.y + 10), 0xFFFFFFFF, mName)
    dl:AddText(P(tx + mw + 6, pos.y + 10), C.mute, yName)
    local wy = pos.y + 42
    local wdY = wy
    for i, wd in ipairs(S.wd) do
        local sz = imgui.CalcTextSize(wd)
        dl:AddText(P(pos.x + (i - 1) * step + (cell - sz.x) / 2, wdY), (i >= 6) and ACC or C.dim, wd)
    end
    local dim = PD.dim(y, m)
    local maxV, monthTotal, monthCount = 1, 0, 0
    for d = 1, dim do
        local dsx = c.byDate[string.format("%04d-%02d-%02d", y, m, d)]
        if dsx then
            if dsx.total > maxV then maxV = dsx.total end
            monthTotal = monthTotal + dsx.total
            monthCount = monthCount + dsx.count
        end
    end
    local startWd = PD.weekday(string.format("%04d-%02d-01", y, m))
    local gx, gy = pos.x, wy + 24
    local row, col = 0, startWd - 1
    local hoverTip
    for d = 1, dim do
        local dateStr = string.format("%04d-%02d-%02d", y, m, d)
        local px, py = gx + col * step, gy + row * step
        local dsx = c.byDate[dateStr]
        local isSel = (dateStr == PD.sel)
        local isToday = (dateStr == c.todayKey)
        imgui.SetCursorScreenPos(P(px, py))
        local clicked = imgui.InvisibleButton("##pd_cal_" .. d, imgui.ImVec2(cell, cell))
        local hv = imgui.IsItemHovered()
        local p0, p1 = P(px, py), P(px + cell, py + cell)
        if isSel then
            dl:AddRectFilled(p0, p1, ACC, 10)
        elseif dsx then
            local lvl = dsx.total / maxV
            dl:AddRectFilled(p0, p1, rhAlpha(ACC, 0.14 + 0.50 * lvl), 10)
        elseif hv then
            dl:AddRectFilled(p0, p1, rhAlpha(0xFFFFFFFF, 0.05), 10)
        end
        if isToday then dl:AddRect(p0, p1, rhAlpha(0xFFFFFFFF, 0.85), 10, 15, 1.5)
        elseif hv then dl:AddRect(p0, p1, rhAlpha(ACC, 0.9), 10, 15, 1.0) end
        local ds = tostring(d)
        local sz = imgui.CalcTextSize(ds)
        local tcol = isSel and 0xFF101010 or (dsx and 0xFFFFFFFF or ((col >= 5) and rhAlpha(ACC, 0.7) or 0xFF9A9A9A))
        dl:AddText(P(px + (cell - sz.x) / 2, py + (cell - sz.y) / 2), tcol, ds)
        if hv then hoverTip = {dateStr, dsx} end
        if clicked then
            PD.select(dateStr)
            imgui.CloseCurrentPopup()
        end
        col = col + 1
        if col > 6 then col = 0; row = row + 1 end
    end
    if hoverTip then
        rhTipBegin()
        PD.dayTip(hoverTip[1], hoverTip[2])
        rhTipEnd()
    end
    local totalRows = row + (col > 0 and 1 or 0)
    local fy = gy + totalRows * step + 4
    dl:AddLine(P(pos.x, fy), P(pos.x + cw, fy), rhAlpha(0xFFFFFFFF, 0.08), 1.0)
    dl:AddText(P(pos.x, fy + 8), C.mute, S.month .. formatNumber(monthTotal) .. "$")
    local cntStr = monthCount .. " " .. PD.plural(monthCount, c.pl or S.pl)
    dl:AddText(P(pos.x + cw - imgui.CalcTextSize(cntStr).x, fy + 8), C.mute, cntStr)
    local ly = fy + 30
    local lessW, moreW = imgui.CalcTextSize(S.less).x, imgui.CalcTextSize(S.more).x
    local lx = pos.x + (cw - (lessW + moreW + 5 * 14 + 16)) / 2
    dl:AddText(P(lx, ly), C.dim, S.less)
    lx = lx + lessW + 8
    for i = 0, 4 do
        dl:AddRectFilled(P(lx + i * 14, ly + 2), P(lx + i * 14 + 11, ly + 13), rhAlpha(ACC, 0.14 + 0.50 * (i / 4)), 3)
    end
    dl:AddText(P(lx + 5 * 14 + 4, ly), C.dim, S.more)
    imgui.SetCursorScreenPos(P(pos.x, ly + 22))
    imgui.Dummy(imgui.ImVec2(cw, 1))
end
function PD.list(dl, c, x, y, w, ACC, bg, brd)
    local S, C = PD.str(), PD.C
    local P = imgui.ImVec2
    local ds = c.byDate[PD.sel] or PD.EMPTY
    local th = imgui.CalcTextSize("A").y
    dl:AddText(P(x + 4, y + 5), 0xFFFFFFFF, S.listTitle)
    local rubW = imgui.CalcTextSize(S.rubs).x + 52
    local rx = x + w - rubW
    imgui.SetCursorScreenPos(P(rx, y))
    if imgui.InvisibleButton("##pd_rub_toggle", imgui.ImVec2(rubW, 26)) then
        showRubColumn = not showRubColumn
        pcall(savePaydayUiConfig)
    end
    local rhv = imgui.IsItemHovered()
    local ra = rhAnim("pd_rub_toggle", rhv and 1 or 0)
    local on = showRubColumn and true or false
    dl:AddRectFilled(P(rx, y), P(rx + rubW, y + 26), on and rhAlpha(C.rub, 0.12 + 0.06 * ra) or rhAlpha(0xFFFFFFFF, 0.04 + 0.03 * ra), 13)
    dl:AddRect(P(rx, y), P(rx + rubW, y + 26), on and rhAlpha(C.rub, 0.5) or brd, 13, 15, 1.0)
    dl:AddRectFilled(P(rx + 11, y + 7), P(rx + 33, y + 19), on and C.rub or 0xFF3A3A3A, 6)
    dl:AddCircleFilled(P(on and (rx + 27) or (rx + 17), y + 13), 4, 0xFFFFFFFF, 12)
    dl:AddText(P(rx + 40, y + 13 - th / 2), on and 0xFFE0E0E0 or C.mute, S.rubs)
    y = y + 34
    if ds.count == 0 then
        local eh = 92
        rhCardBox(dl, x, y, w, eh, bg, brd, 12)
        rhIconBadge(dl, x + w / 2, y + 32, 16, fa.ICON_CALENDAR, C.mute, bg, 0)
        local sz = imgui.CalcTextSize(S.emptyDay)
        dl:AddText(P(x + (w - sz.x) / 2, y + 60), C.mute, S.emptyDay)
        return y + eh + 8
    end
    local pad = 16
    local hh, rowH, fh = 36, 44, 50
    local nMid = showRubColumn and 5 or 4
    local weights = {1.25, 1.25, 1.35, 0.75, 0.75}
    local timeW, totW = 96, 132
    local avail = w - pad * 2 - timeW - totW
    local wsum = 0
    for i = 1, nMid do wsum = wsum + weights[i] end
    local colX, colW = {}, {}
    local cxp = x + pad + timeW
    for i = 1, nMid do
        colW[i] = avail * weights[i] / wsum
        colX[i] = cxp
        cxp = cxp + colW[i]
    end
    local rightEdge = x + w - pad
    local totX = rightEdge - totW
    local totCX = totX + totW / 2
    local n = #ds.logs
    local maxRows = 10
    local scrollMode = n > maxRows
    local visH = (scrollMode and maxRows or n) * rowH
    local tableH = hh + visH + fh
    local top = y + hh
    local fy = top + visH
    rhCardBox(dl, x, y, w, tableH, bg, brd, 14)
    dl:AddRectFilled(P(x + 1, y + 1), P(x + w - 1, y + hh), rhAlpha(0xFFFFFFFF, 0.025), 13, 3)
    dl:AddLine(P(x + 1, y + hh), P(x + w - 1, y + hh), rhAlpha(0xFFFFFFFF, 0.06), 1.0)
    local hty = y + (hh - th) / 2
    local chipW, chipH = imgui.CalcTextSize("00:00").x + 16, 24
    local chipX = x + pad + 18
    local hTime = imgui.CalcTextSize(S.time).x
    dl:AddText(P(chipX + (chipW - hTime) / 2, hty), C.mute, S.time)
    local labels = {S.sal, S.dep, S.accShort, "AZ", S.rubs}
    local lcols = {C.sal, C.dep, C.acc, C.az, C.rub}
    for i = 1, nMid do
        local lw = imgui.CalcTextSize(labels[i]).x
        local gw = 6 + 6 + lw
        local gx = colX[i] + (colW[i] - gw) / 2
        dl:AddCircleFilled(P(gx + 3, y + hh / 2), 3, lcols[i], 12)
        dl:AddText(P(gx + 12, hty), rhLerpColor(C.mute, lcols[i], 0.35), labels[i])
    end
    local tl = S.total
    dl:AddText(P(totCX - imgui.CalcTextSize(tl).x / 2, hty), C.green, tl)
    local iconW = imgui.CalcTextSize(fa.ICON_INFO_CIRCLE).x
    local function cell(i, ry, rh, text, col, withIcon, iconCol)
        local tw = imgui.CalcTextSize(text).x
        local gw = tw + (withIcon and (6 + iconW) or 0)
        local tx = colX[i] + (colW[i] - gw) / 2
        local ty = ry + (rh - th) / 2
        dl:AddText(P(tx, ty), col, text)
        if withIcon then dl:AddText(P(tx + tw + 6, ty + 1), iconCol or 0xFF555555, fa.ICON_INFO_CIRCLE) end
    end
    local function num(v, i, dollar, reserve)
        if not v or v <= 0 then return "-" end
        local t = formatNumber(v) .. (dollar and "$" or "")
        if imgui.CalcTextSize(t).x > colW[i] - 16 - (reserve or 0) then
            t = PD.short(v) .. (dollar and "$" or "")
        end
        return t
    end
    local mp = imgui.GetMousePos()
    local inTable, dragging, scrollOff = false, false, 0
    local maxOff = math.max(0, n * rowH - visH)
    local trackTop, trackH, thumbH, thumbY = top + 6, visH - 12, 0, 0
    local sKey = "payday|" .. tostring(PD.sel)
    RI = RI or {}
    RI.scroll = RI.scroll or {}
    if scrollMode then
        scrollOff = RI.scroll[sKey] or 0
        inTable = PD.hov(x, top, w, visH)
        local wheel = RI.wheelAcc or 0
        RI.wheelAcc = 0
        if inTable and wheel ~= 0 then
            local want = scrollOff - wheel * rowH * 3
            local clamped = math.max(0, math.min(maxOff, want))
            local overflow = want - clamped
            scrollOff = clamped
            if overflow ~= 0 and imgui.GetScrollY and imgui.SetScrollY then
                imgui.SetScrollY(imgui.GetScrollY() + overflow)
            end
        end
        RI.tableHover = inTable
        thumbH = math.max(34, trackH * visH / (n * rowH))
        local range = math.max(1, trackH - thumbH)
        thumbY = trackTop + range * (scrollOff / math.max(1, maxOff))
        imgui.SetCursorScreenPos(P(x + w - 20, trackTop))
        imgui.InvisibleButton("##pd_sb_" .. sKey, imgui.ImVec2(20, trackH))
        if imgui.IsItemActive() then
            dragging = true
            if not RI.sbGrab then
                RI.sbGrab = (mp.y >= thumbY and mp.y <= thumbY + thumbH) and (mp.y - thumbY) or (thumbH / 2)
            end
            scrollOff = (mp.y - RI.sbGrab - trackTop) / range * maxOff
        else
            RI.sbGrab = nil
        end
        scrollOff = math.max(0, math.min(maxOff, scrollOff))
        RI.scroll[sKey] = scrollOff
        thumbY = trackTop + range * (scrollOff / math.max(1, maxOff))
        dl:PushClipRect(P(x, top), P(x + w, top + visH), true)
    end
    local visFirst, visLast = 1, n
    if scrollMode then
        visFirst = math.max(1, math.floor(scrollOff / rowH) + 1)
        visLast = math.min(n, math.floor((scrollOff + visH) / rowH) + 1)
    end
    local rowsTop = top - scrollOff
    for i = visFirst, visLast do
        local e = ds.logs[i]
        local ry = rowsTop + (i - 1) * rowH
        local hv
        if scrollMode then
            hv = inTable and not dragging and mp.y >= ry and mp.y < ry + rowH
        else
            imgui.SetCursorScreenPos(P(x, ry))
            imgui.InvisibleButton("##pd_row_" .. i, imgui.ImVec2(w, rowH))
            hv = imgui.IsItemHovered()
        end
        local a = rhAnim("pd_row_" .. i, hv and 1 or 0)
        local ty = ry + (rowH - th) / 2
        local tot = e.total or e.amount or 0
        local isBest = ds.count > 1 and tot >= ds.best and ds.best > 0
        if isBest then dl:AddRectFilled(P(x + 6, ry + 3), P(x + w - 6, ry + rowH - 3), rhAlpha(C.gold, 0.05), 9) end
        if a > 0.01 then
            dl:AddRectFilled(P(x + 6, ry + 3), P(x + w - 6, ry + rowH - 3), rhAlpha(ACC, 0.07 * a), 9)
            dl:AddRectFilled(P(x + 6, ry + 12), P(x + 9, ry + rowH - 12), rhAlpha(ACC, 0.9 * a), 2)
        end
        if i < n then
            dl:AddLine(P(x + pad, ry + rowH), P(x + w - pad, ry + rowH), rhAlpha(0xFFFFFFFF, 0.045), 1.0)
        end
        if isBest then dl:AddText(P(x + pad, ty), C.gold, fa.ICON_STAR) end
        local tm = os.date("!%H:%M", (e.time or 0) + 10800)
        local tsz = imgui.CalcTextSize(tm)
        local cy0 = ry + (rowH - chipH) / 2
        local chipCol = isBest and C.gold or 0xFFFFFFFF
        dl:AddRectFilled(P(chipX, cy0), P(chipX + chipW, cy0 + chipH), rhAlpha(chipCol, 0.06 + 0.05 * a), 8)
        dl:AddRect(P(chipX, cy0), P(chipX + chipW, cy0 + chipH), rhAlpha(chipCol, 0.12 + 0.2 * a), 8, 15, 1.0)
        dl:AddText(P(chipX + (chipW - tsz.x) / 2, cy0 + (chipH - tsz.y) / 2), isBest and C.gold or 0xFFE0E0E0, tm)
        local sal, dep, acc = e.salary or 0, e.deposit or 0, e.accesories or 0
        cell(1, ry, rowH, num(sal, 1, true), sal > 0 and C.text or C.dim)
        cell(2, ry, rowH, num(dep, 2, true), dep > 0 and C.text or C.dim)
        local icoCol = rhLerpColor(0xFF555555, ACC, a)
        local bd = e.accBreakdown
        local hasBd = bd and ((bd.dividend or 0) > 0 or (bd.accessory or 0) > 0 or (bd.family or 0) > 0)
        cell(3, ry, rowH, num(acc, 3, true, hasBd and (6 + iconW) or 0), acc > 0 and C.text or C.dim, hasBd, icoCol)
        local az = e.az or 0
        local hasAz = e.azBreakdown and #e.azBreakdown > 0
        cell(4, ry, rowH, num(az, 4, false, hasAz and (6 + iconW) or 0), az > 0 and C.az or C.dim, hasAz, icoCol)
        if nMid == 5 then
            local rub = e.rub or 0
            cell(5, ry, rowH, num(rub, 5, false), rub > 0 and C.rub or C.dim)
        end
        local totTxt = formatNumber(tot) .. "$"
        if imgui.CalcTextSize(totTxt).x > totW - 16 then totTxt = PD.short(tot) .. "$" end
        local tw = imgui.CalcTextSize(totTxt).x
        local ttY = ds.best > 0 and (ty - 4) or ty
        dl:AddText(P(totCX - tw / 2, ttY), C.green, totTxt)
        if ds.best > 0 then
            local bw = totW - 28
            local bx0, by0 = totCX - bw / 2, ry + rowH - 14
            dl:AddRectFilled(P(bx0, by0), P(bx0 + bw, by0 + 3), rhAlpha(0xFFFFFFFF, 0.07), 2)
            dl:AddRectFilled(P(bx0, by0), P(bx0 + math.max(3, bw * (tot / ds.best)), by0 + 3), rhAlpha(C.green, 0.8), 2)
        end
        if hv then
            if hasBd and PD.hov(colX[3], ry, colW[3], rowH) then
                rhTipBegin()
                if (bd.dividend or 0) > 0 then imgui.Text(S.divid .. formatNumber(bd.dividend) .. "$") end
                if (bd.accessory or 0) > 0 then imgui.Text(S.heart .. formatNumber(bd.accessory) .. "$") end
                if (bd.family or 0) > 0 then imgui.Text(S.fam .. formatNumber(bd.family) .. "$") end
                rhTipEnd()
            elseif hasAz and PD.hov(colX[4], ry, colW[4], rowH) then
                rhTipBegin()
                for _, b in ipairs(e.azBreakdown) do imgui.Text(b.label .. ": " .. formatNumber(b.amount) .. " AZ") end
                rhTipEnd()
            elseif isBest and PD.hov(x, ry, pad + 70, rowH) then
                rhTipBegin()
                imgui.TextColored(PD.vec4(C.gold), S.best)
                rhTipEnd()
            end
        end
    end
    if scrollMode then
        dl:PopClipRect()
        local sbx = x + w - 14
        dl:AddRectFilled(P(sbx, trackTop), P(sbx + 8, trackTop + trackH), rhAlpha(0xFFFFFFFF, 0.07), 4)
        local sbHot = dragging or PD.hov(x + w - 20, thumbY, 20, thumbH)
        dl:AddRectFilled(P(sbx, thumbY), P(sbx + 8, thumbY + thumbH), rhAlpha(ACC, sbHot and 0.95 or 0.6), 4)
    end
    local vcol = rhAlpha(0xFFFFFFFF, 0.05)
    local vx = { x + pad + timeW }
    for i = 2, nMid do vx[#vx + 1] = colX[i] end
    vx[#vx + 1] = totX
    for _, lx in ipairs(vx) do
        dl:AddLine(P(lx, y + 8), P(lx, fy - 8), vcol, 1.0)
    end
    dl:AddRectFilled(P(x + 1, fy), P(x + w - 1, y + tableH - 1), rhAlpha(ACC, 0.08), 13, 12)
    dl:AddLine(P(x + 1, fy), P(x + w - 1, fy), rhAlpha(ACC, 0.35), 1.0)
    local fty = fy + (fh - th) / 2
    dl:AddText(P(x + pad + 18, fty), ACC, S.itogo)
    dl:AddText(P(x + pad + 19, fty), ACC, S.itogo)
    dl:AddText(P(x + pad + 18 + imgui.CalcTextSize(S.itogo).x + 8, fty), C.dim, "x" .. ds.count)
    cell(1, fy, fh, num(ds.salary, 1, true), ds.salary > 0 and C.sal or C.dim)
    cell(2, fy, fh, num(ds.deposit, 2, true), ds.deposit > 0 and C.dep or C.dim)
    cell(3, fy, fh, num(ds.acc, 3, true), ds.acc > 0 and C.acc or C.dim)
    cell(4, fy, fh, num(ds.az, 4, false), ds.az > 0 and C.az or C.dim)
    if nMid == 5 then cell(5, fy, fh, num(ds.rub, 5, false), ds.rub > 0 and C.rub or C.dim) end
    local fTot = formatNumber(ds.total) .. "$"
    if imgui.CalcTextSize(fTot).x > totW - 16 then fTot = PD.short(ds.total) .. "$" end
    local fw = imgui.CalcTextSize(fTot).x
    dl:AddText(P(totCX - fw / 2, fty), C.green, fTot)
    dl:AddText(P(totCX - fw / 2 + 1, fty), C.green, fTot)
    return y + tableH + 12
end
function drawPaydayTab()
    local dl = imgui.GetWindowDrawList()
    local P = imgui.ImVec2
    local S, C = PD.str(), PD.C
    local c = PD.build()
    PD.ensureSel(c)
    local bg, brd, iconCol = homeCardColors()
    local ACC = useCustomTheme and iconCol or 0xFF1AE591
    local cur = imgui.GetCursorScreenPos()
    local x, y = cur.x, cur.y + 4
    local w = imgui.GetWindowWidth() - 25
    PD.hero(dl, c, x, y, w, 152, ACC, bg, brd)
    y = y + 152 + 10
    PD.tiles(dl, c, x, y, w, 74, ACC, bg, brd)
    y = y + 74 + 12
    if #c.dates == 0 then
        local eh = 130
        rhCardBox(dl, x, y, w, eh, bg, brd, 14)
        rhIconBadge(dl, x + w / 2, y + 40, 20, fa.ICON_MONEY, ACC, bg, 0)
        local s1, s2 = imgui.CalcTextSize(S.empty), imgui.CalcTextSize(S.emptySub)
        dl:AddText(P(x + (w - s1.x) / 2, y + 74), 0xFFFFFFFF, S.empty)
        dl:AddText(P(x + (w - s2.x) / 2, y + 96), C.mute, S.emptySub)
        y = y + eh + 10
    else
        PD.nav(dl, c, x, y, w, 46, ACC, bg, brd)
        y = y + 46 + 12
        y = PD.list(dl, c, x, y, w, ACC, bg, brd)
    end
    imgui.SetCursorScreenPos(P(x, y))
    imgui.Dummy(imgui.ImVec2(w, 6))
end
RI = RI or {}
RI.state = RI.state or {rent = {}, shard = {}}
RI.cache = RI.cache or {}
RI.PAL = {0xFFF8BD38, 0xFFFA8BA7, 0xFF28AAFF, 0xFF33DD77, 0xFF00CCFF, 0xFFB672F4}
function RI.K(kind)
    RI.KK = RI.KK or {}
    if RI.KK[kind] then return RI.KK[kind] end
    local K
    if kind == "rent" then
        K = {
            kind = "rent", col = 0xFFF8BD38, icon = fa.ICON_SHOPPING_CART,
            cap = u8("Доход с аренды за сегодня"),
            listTitle = u8("Платежи за день"),
            pl = {u8("платёж"), u8("платежа"), u8("платежей")},
            empty = u8("Аренды пока нет"),
            emptySub = u8("Запись появится автоматически после первой аренды"),
            noToday = u8("Пока нет аренды за сегодня"),
            emptyDay = u8("В этот день платежей не было"),
            best = u8("Самый крупный платёж дня"),
            avg = u8("Средний платёж: "), avgShort = u8("ср. "),
            other = u8("Прочее"),
            cols = {u8("Ник"), u8("Тип")}, weights = {1.4, 1.0},
        }
    else
        K = {
            kind = "shard", col = 0xFFFA8BA7, icon = fa.ICON_STAR,
            cap = u8("Доход с осколков за сегодня"),
            listTitle = u8("Осколки за день"),
            pl = {u8("осколок"), u8("осколка"), u8("осколков")},
            empty = u8("Осколков пока нет"),
            emptySub = u8("Запись появится автоматически после первого выпавшего осколка"),
            noToday = u8("Сегодня осколков не выпадало"),
            emptyDay = u8("В этот день осколков не выпадало"),
            best = u8("Самый ценный осколок дня"),
            avg = u8("Средняя цена: "), avgShort = u8("ср. "),
            other = u8("Прочее"),
            cols = {u8("Название")}, weights = {1},
        }
    end
    if kind == "case" then
        K = {
            kind = "case", col = 0xFF28AAFF, icon = fa.ICON_BRIEFCASE,
            cap = u8("Доход с ларцов за сегодня"),
            listTitle = u8("Ларцы за день"),
            pl = {u8("ларец"), u8("ларца"), u8("ларцов")},
            empty = u8("Ларцов пока нет"),
            emptySub = u8("Запись появится автоматически после первого выпавшего ларца"),
            noToday = u8("Сегодня ларцы не выпадали"),
            emptyDay = u8("В этот день ларцы не выпадали"),
            best = u8("Самый ценный ларец дня"),
            avg = u8("Средняя цена: "), avgShort = u8("ср. "),
            other = u8("Прочее"),
            cols = {u8("Название")}, weights = {1},
        }
    elseif kind == "crypto" then
        K = {
            kind = "crypto", col = 0xFF15CCFA, icon = fa.ICON_USD,
            cap = u8("Доход с крипты за сегодня"),
            listTitle = u8("Крипта за день"),
            pl = {u8("монета"), u8("монеты"), u8("монет")},
            empty = u8("Крипты пока нет"),
            emptySub = u8("Запись появится автоматически после первого получения монет"),
            noToday = u8("Сегодня монет не поступало"),
            emptyDay = u8("В этот день монет не поступало"),
            best = u8("Самая крупная выдача дня"),
            avg = u8("Средний курс: "), avgShort = u8("ср. "),
            other = u8("Прочее"),
            cols = {u8("Монета"), u8("Кол-во")}, weights = {1.2, 0.8},
        }
    end
    RI.KK[kind] = K
    return K
end
function RI.log(kind)
    if kind == "rent" then return itemMarketLog or {} end
    if kind == "case" then return investmentLog or {} end
    if kind == "crypto" then return cryptoLog or {} end
    return shardLog or {}
end
function RI.val(kind, e)
    if kind == "case" then
        return (investmentConfig[e.itemId] and investmentConfig[e.itemId].cost) or 0
    elseif kind == "crypto" then
        return ((cryptoConfig[e.itemId] and cryptoConfig[e.itemId].cost) or 0) * (e.amount or 1)
    end
    return e.amount or 0
end
function RI.qty(kind, e)
    if kind == "crypto" then return e.amount or 1 end
    return 1
end
function RI.priceSig(kind)
    local s = 0
    local src = (kind == "case") and investmentConfig or ((kind == "crypto") and cryptoConfig or nil)
    if src then
        for id, d in pairs(src) do s = s + (d.cost or 0) * ((tonumber(id) or 1) % 13 + 1) end
    end
    return s
end
function RI.cat(kind, e)
    if kind == "rent" then
        if e.rentType == "room" then return "room", u8("Дом"), 0xFFF8BD38 end
        return "im", u8("Item Market"), 0xFF28AAFF
    end
    if kind == "crypto" then
        if tonumber(e.itemId) == 1811 then return "btc", "BTC", 0xFF1A93F7 end
        return "asc", "ASC", 0xFF3539E5
    end
    local nm = e.name or "?"
    local h = 0
    for i = 1, #nm do h = (h * 31 + nm:byte(i)) % 997 end
    return nm, u8(nm), RI.PAL[h % #RI.PAL + 1]
end
function RI.build(kind)
    local K = RI.K(kind)
    local log = RI.log(kind)
    local todayKey = getGameDate()
    local e1 = log[1]
    local sig = #log .. "|" .. todayKey .. "|" .. RI.priceSig(kind)
    if e1 then sig = sig .. "|" .. (e1.time or 0) .. "|" .. (e1.amount or 0) .. "|" .. (e1.itemId or 0) end
    local cc = RI.cache[kind]
    if cc and cc.sig == sig then return cc end
    local byDate, dates = {}, {}
    local all = {total = 0, az = 0, rub = 0, count = 0}
    for _, e in ipairs(log) do
        local d = getGameDate(e.time)
        local ds = byDate[d]
        if not ds then
            ds = {total = 0, salary = 0, deposit = 0, acc = 0, az = 0, rub = 0, count = 0, best = 0, logs = {}, cats = {}, pl = K.pl}
            byDate[d] = ds
            dates[#dates + 1] = d
        end
        local t = RI.val(kind, e)
        local q = RI.qty(kind, e)
        ds.total = ds.total + t
        ds.count = ds.count + q
        if t > ds.best then ds.best = t end
        ds.logs[#ds.logs + 1] = e
        local ck, cl, ccol = RI.cat(kind, e)
        local ce = ds.cats[ck]
        if not ce then
            ce = {key = ck, label = cl, col = ccol, amount = 0, count = 0}
            ds.cats[ck] = ce
        end
        ce.amount = ce.amount + t
        ce.count = ce.count + q
        all.total = all.total + t
        all.count = all.count + q
    end
    table.sort(dates, function(a, b) return a > b end)
    local mskWday = tonumber(os.date("!%w", getMoscowTime())) or 1
    if mskWday == 0 then mskWday = 7 end
    local week = {total = 0, az = 0, rub = 0, count = 0}
    for i = 0, mskWday - 1 do
        local ds = byDate[getGameDate(os.time() - i * 86400)]
        if ds then
            week.total = week.total + ds.total
            week.count = week.count + ds.count
        end
    end
    local last7 = {}
    for i = 6, 0, -1 do
        local d = getGameDate(os.time() - i * 86400)
        local ds = byDate[d]
        last7[#last7 + 1] = {date = d, wd = PD.weekday(d), total = ds and ds.total or 0, az = 0, count = ds and ds.count or 0}
    end
    local yestKey = getGameDate(os.time() - 86400)
    local out = {
        sig = sig, byDate = byDate, dates = dates, all = all, week = week, last7 = last7,
        todayKey = todayKey, yestKey = yestKey, pl = K.pl,
        today = byDate[todayKey] or PD.EMPTY, yest = byDate[yestKey] or PD.EMPTY,
    }
    RI.cache[kind] = out
    return out
end
function RI.hero(dl, c, x, y, w, h, ACC, bg, brd, K)
    local C = PD.C
    local P = imgui.ImVec2
    local td = c.today
    local lw = math.floor(w * 0.56)
    rhCardBox(dl, x, y, w, h, bg, brd, 14)
    dl:AddLine(P(x + lw, y + 18), P(x + lw, y + h - 18), rhAlpha(0xFFFFFFFF, 0.06), 1.0)
    dl:AddText(P(x + 22, y + 14), C.mute, K.cap)
    local big = formatNumber(td.total) .. "$"
    if rhBigFont then
        imgui.PushFont(rhBigFont)
        imgui.SetCursorScreenPos(P(x + 22, y + 32))
        imgui.TextColored(PD.vec4(C.green), big)
        imgui.PopFont()
    else
        dl:AddText(P(x + 22, y + 38), C.green, big)
        dl:AddText(P(x + 23, y + 38), C.green, big)
    end
    local px, py = x + 22, y + 76
    local function pill(text, col)
        px = px + rhPill(dl, px, py, text, col) + 6
    end
    if td.count > 0 then
        pill(td.count .. " " .. PD.plural(td.count, K.pl), K.col)
        pill(K.avgShort .. PD.short(td.total / td.count) .. "$", C.mute)
    end
    local bx0, bx1, by = x + 22, x + lw - 20, y + h - 40
    dl:AddRectFilled(P(bx0, by), P(bx1, by + 8), rhAlpha(0xFFFFFFFF, 0.07), 4)
    local arr = {}
    for _, ce in pairs(td.cats or {}) do arr[#arr + 1] = ce end
    table.sort(arr, function(a, b) return a.amount > b.amount end)
    if td.count > 0 and #arr > 0 then
        local sumAmt = 0
        for _, ce in ipairs(arr) do sumAmt = sumAmt + ce.amount end
        local useCnt = (sumAmt <= 0)
        local function wt(ce) return useCnt and ce.count or ce.amount end
        local parts = {}
        local limit = (#arr > 4) and 3 or #arr
        for i = 1, limit do parts[#parts + 1] = {wt(arr[i]), arr[i].col, arr[i].label} end
        if #arr > limit then
            local rest = 0
            for i = limit + 1, #arr do rest = rest + wt(arr[i]) end
            parts[#parts + 1] = {rest, C.dim, K.other}
        end
        local sum = 0
        for _, p in ipairs(parts) do sum = sum + p[1] end
        if sum <= 0 then sum = 1 end
        local present = {}
        for _, p in ipairs(parts) do if p[1] > 0 then present[#present + 1] = p end end
        local gap = 2
        local usable = (bx1 - bx0) - gap * math.max(#present - 1, 0)
        local cx = bx0
        for _, p in ipairs(present) do
            local pw = math.max(usable * (p[1] / sum), 3)
            dl:AddRectFilled(P(cx, by), P(cx + pw, by + 8), p[2], 4)
            cx = cx + pw + gap
        end
        local items, totalW = {}, 0
        for _, p in ipairs(present) do
            local pct = math.floor(p[1] / sum * 100 + 0.5)
            local txt = p[3] .. " " .. pct .. "%"
            items[#items + 1] = {col = p[2], txt = txt}
            totalW = totalW + 22 + imgui.CalcTextSize(txt).x
        end
        while #items > 1 and totalW > (bx1 - bx0) + 10 do
            totalW = totalW - 22 - imgui.CalcTextSize(items[#items].txt).x
            items[#items] = nil
        end
        local lx = bx0
        for _, it in ipairs(items) do
            dl:AddCircleFilled(P(lx + 4, by + 22), 3, it.col, 12)
            dl:AddText(P(lx + 12, by + 14), 0xFFB8B8B8, it.txt)
            lx = lx + 22 + imgui.CalcTextSize(it.txt).x
        end
    else
        dl:AddText(P(bx0, by + 14), C.dim, K.noToday)
    end
    local S = PD.str()
    local rx0, rx1 = x + lw + 20, x + w - 20
    local rw = rx1 - rx0
    dl:AddText(P(rx0, y + 14), C.mute, S.last7)
    local cy0, cy1 = y + 44, y + h - 36
    local chH = cy1 - cy0
    local slot = rw / 7
    local bw = math.max(8, slot - 10)
    local maxV = 1
    for _, d in ipairs(c.last7) do if d.total > maxV then maxV = d.total end end
    for i, d in ipairs(c.last7) do
        local sx = rx0 + (i - 1) * slot
        local bxx = sx + (slot - bw) / 2
        imgui.SetCursorScreenPos(P(sx, cy0 - 6))
        local clicked = imgui.InvisibleButton("##ri_bar_" .. i, imgui.ImVec2(slot, chH + 6 + 28))
        local hv = imgui.IsItemHovered()
        local a = rhAnim("ri_bar_" .. i, hv and 1 or 0)
        local isToday = (d.date == c.todayKey)
        local isSel = (d.date == PD.sel)
        local bh = d.total > 0 and math.max(4, chH * d.total / maxV) or 2
        local col
        if d.total <= 0 then
            col = rhAlpha(0xFFFFFFFF, 0.07 + 0.06 * a)
        else
            local base = rhLerpColor(bg, ACC, isToday and 1 or 0.5)
            col = rhLerpColor(base, 0xFFFFFFFF, 0.22 * a)
        end
        dl:AddRectFilled(P(bxx, cy1 - bh), P(bxx + bw, cy1), col, 4, 3)
        if isSel then
            dl:AddRect(P(bxx - 2, cy1 - bh - 2), P(bxx + bw + 2, cy1 + 2), rhAlpha(0xFFFFFFFF, 0.7), 5, 15, 1.2)
        end
        local lbl = S.wd[d.wd]
        local lsz = imgui.CalcTextSize(lbl)
        dl:AddText(P(sx + (slot - lsz.x) / 2, cy1 + 8), isToday and ACC or (isSel and 0xFFFFFFFF or C.mute), lbl)
        if hv then
            rhTipBegin()
            PD.dayTip(d.date, c.byDate[d.date])
            rhTipEnd()
        end
        if clicked then PD.select(d.date) end
    end
end
function RI.tiles(dl, c, x, y, w, h, ACC, bg, brd, K)
    local S, C = PD.str(), PD.C
    local P = imgui.ImVec2
    local gap = 8
    local tw = (w - gap * 2) / 3
    local items = {
        {key = "y", label = S.yest, icon = fa.ICON_CALENDAR, col = C.sal, d = c.yest},
        {key = "w", label = S.week, icon = fa.ICON_LIST, col = C.dep, d = c.week},
        {key = "a", label = S.allTime, icon = fa.ICON_TROPHY, col = C.acc, d = c.all},
    }
    for i, it in ipairs(items) do
        local tx = x + (i - 1) * (tw + gap)
        imgui.SetCursorScreenPos(P(tx, y))
        imgui.InvisibleButton("##ri_tile_" .. it.key, imgui.ImVec2(tw, h))
        local hv = imgui.IsItemHovered()
        local a = rhAnim("ri_tile_" .. it.key, hv and 1 or 0)
        local bgT = rhLerpColor(bg, rhLerpColor(bg, 0xFFFFFFFF, 0.04), a)
        rhCardBox(dl, tx, y, tw, h, bgT, rhLerpColor(brd, it.col, 0.55 * a), 12)
        rhIconBadge(dl, tx + 28, y + h / 2, 17, it.icon, it.col, bgT, a)
        local d = it.d
        local cnt = d.count or 0
        local cntTxt = "x" .. cnt
        dl:PushClipRect(P(tx + 52, y), P(tx + tw - 8, y + h), true)
        dl:AddText(P(tx + 54, y + 10), C.mute, it.label)
        dl:AddText(P(tx + tw - 14 - imgui.CalcTextSize(cntTxt).x, y + 10), rhLerpColor(0xFF606060, it.col, 0.4 + 0.6 * a), cntTxt)
        dl:AddText(P(tx + 54, y + 28), 0xFFFFFFFF, formatNumber(d.total or 0) .. "$")
        dl:AddText(P(tx + 54, y + 48), cnt > 0 and it.col or C.dim, cnt .. " " .. PD.plural(cnt, K.pl))
        dl:PopClipRect()
        if hv and cnt > 0 then
            rhTipBegin()
            imgui.TextColored(PD.vec4(0xFFFFFFFF), it.label)
            imgui.TextColored(PD.vec4(C.green), formatNumber(d.total) .. "$")
            imgui.TextColored(PD.vec4(C.mute), K.avg .. formatNumber(math.floor(d.total / cnt)) .. "$")
            rhTipEnd()
        end
    end
end
function RI.list(dl, c, x, y, w, ACC, bg, brd, K)
    local S, C = PD.str(), PD.C
    local P = imgui.ImVec2
    local ds = c.byDate[PD.sel] or PD.EMPTY
    local th = imgui.CalcTextSize("A").y
    dl:AddText(P(x + 4, y + 5), 0xFFFFFFFF, K.listTitle)
    y = y + 34
    if ds.count == 0 then
        local eh = 92
        rhCardBox(dl, x, y, w, eh, bg, brd, 12)
        rhIconBadge(dl, x + w / 2, y + 32, 16, fa.ICON_CALENDAR, C.mute, bg, 0)
        local sz = imgui.CalcTextSize(K.emptyDay)
        dl:AddText(P(x + (w - sz.x) / 2, y + 60), C.mute, K.emptyDay)
        return y + eh + 8
    end
    local pad = 16
    local hh, rowH, fh = 36, 44, 50
    local nMid = #K.cols
    local weights = K.weights
    local timeW, totW = 96, 132
    local avail = w - pad * 2 - timeW - totW
    local wsum = 0
    for i = 1, nMid do wsum = wsum + weights[i] end
    local colX, colW = {}, {}
    local cxp = x + pad + timeW
    for i = 1, nMid do
        colW[i] = avail * weights[i] / wsum
        colX[i] = cxp
        cxp = cxp + colW[i]
    end
    local rightEdge = x + w - pad
    local totX = rightEdge - totW
    local totCX = totX + totW / 2
    local n = #ds.logs
    local maxRows = 10
    local scrollMode = n > maxRows
    local visH = (scrollMode and maxRows or n) * rowH
    local tableH = hh + visH + fh
    local top = y + hh
    local fy = top + visH
    rhCardBox(dl, x, y, w, tableH, bg, brd, 14)
    dl:AddRectFilled(P(x + 1, y + 1), P(x + w - 1, y + hh), rhAlpha(0xFFFFFFFF, 0.025), 13, 3)
    dl:AddLine(P(x + 1, y + hh), P(x + w - 1, y + hh), rhAlpha(0xFFFFFFFF, 0.06), 1.0)
    local hty = y + (hh - th) / 2
    local chipW, chipH = imgui.CalcTextSize("00:00").x + 16, 24
    local chipX = x + pad + 18
    dl:AddText(P(chipX + (chipW - imgui.CalcTextSize(S.time).x) / 2, hty), C.mute, S.time)
    for i = 1, nMid do
        local lw = imgui.CalcTextSize(K.cols[i]).x
        dl:AddText(P(colX[i] + (colW[i] - lw) / 2, hty), C.mute, K.cols[i])
    end
    dl:AddText(P(totCX - imgui.CalcTextSize(S.total).x / 2, hty), C.green, S.total)
    local function ctext(i, ry, rh, text, col, dotCol)
        local tw = imgui.CalcTextSize(text).x
        local gw = tw + (dotCol and 12 or 0)
        local tx = colX[i] + math.max(8, (colW[i] - gw) / 2)
        dl:PushClipRect(P(colX[i] + 2, ry), P(colX[i] + colW[i] - 2, ry + rh), true)
        if dotCol then
            dl:AddCircleFilled(P(tx + 3, ry + rh / 2), 3, dotCol, 12)
            tx = tx + 12
        end
        dl:AddText(P(tx, ry + (rh - th) / 2), col, text)
        dl:PopClipRect()
    end
    local mp = imgui.GetMousePos()
    local inTable, dragging, scrollOff = false, false, 0
    local maxOff = math.max(0, n * rowH - visH)
    local trackTop, trackH, thumbH, thumbY = top + 6, visH - 12, 0, 0
    local sKey = K.kind .. "|" .. tostring(PD.sel)
    RI.scroll = RI.scroll or {}
    if scrollMode then
        scrollOff = RI.scroll[sKey] or 0
        inTable = PD.hov(x, top, w, visH)
        local wheel = RI.wheelAcc or 0
        RI.wheelAcc = 0
        if inTable and wheel ~= 0 then
            local want = scrollOff - wheel * rowH * 3
            local clamped = math.max(0, math.min(maxOff, want))
            local overflow = want - clamped
            scrollOff = clamped
            if overflow ~= 0 and imgui.GetScrollY and imgui.SetScrollY then
                imgui.SetScrollY(imgui.GetScrollY() + overflow)
            end
        end
        RI.tableHover = inTable
        thumbH = math.max(34, trackH * visH / (n * rowH))
        local range = math.max(1, trackH - thumbH)
        thumbY = trackTop + range * (scrollOff / math.max(1, maxOff))
        imgui.SetCursorScreenPos(P(x + w - 20, trackTop))
        imgui.InvisibleButton("##ri_sb_" .. sKey, imgui.ImVec2(20, trackH))
        if imgui.IsItemActive() then
            dragging = true
            if not RI.sbGrab then
                RI.sbGrab = (mp.y >= thumbY and mp.y <= thumbY + thumbH) and (mp.y - thumbY) or (thumbH / 2)
            end
            scrollOff = (mp.y - RI.sbGrab - trackTop) / range * maxOff
        else
            RI.sbGrab = nil
        end
        scrollOff = math.max(0, math.min(maxOff, scrollOff))
        RI.scroll[sKey] = scrollOff
        thumbY = trackTop + range * (scrollOff / math.max(1, maxOff))
        dl:PushClipRect(P(x, top), P(x + w, top + visH), true)
    end
    local visFirst, visLast = 1, n
    if scrollMode then
        visFirst = math.max(1, math.floor(scrollOff / rowH) + 1)
        visLast = math.min(n, math.floor((scrollOff + visH) / rowH) + 1)
    end
    local rowsTop = top - scrollOff
    for i = visFirst, visLast do
        local e = ds.logs[i]
        local ry = rowsTop + (i - 1) * rowH
        local hv
        if scrollMode then
            hv = inTable and not dragging and mp.y >= ry and mp.y < ry + rowH
        else
            imgui.SetCursorScreenPos(P(x, ry))
            imgui.InvisibleButton("##ri_row_" .. i, imgui.ImVec2(w, rowH))
            hv = imgui.IsItemHovered()
        end
        local a = rhAnim("ri_row_" .. i, hv and 1 or 0)
        local ty = ry + (rowH - th) / 2
        local tot = RI.val(K.kind, e)
        local isBest = #ds.logs > 1 and tot >= ds.best and ds.best > 0
        if isBest then dl:AddRectFilled(P(x + 6, ry + 3), P(x + w - 6, ry + rowH - 3), rhAlpha(C.gold, 0.05), 9) end
        if a > 0.01 then
            dl:AddRectFilled(P(x + 6, ry + 3), P(x + w - 6, ry + rowH - 3), rhAlpha(ACC, 0.07 * a), 9)
            dl:AddRectFilled(P(x + 6, ry + 12), P(x + 9, ry + rowH - 12), rhAlpha(ACC, 0.9 * a), 2)
        end
        if i < n then
            dl:AddLine(P(x + pad, ry + rowH), P(x + w - pad, ry + rowH), rhAlpha(0xFFFFFFFF, 0.045), 1.0)
        end
        if isBest then dl:AddText(P(x + pad, ty), C.gold, fa.ICON_STAR) end
        local tm = os.date("!%H:%M", (e.time or 0) + 10800)
        local tsz = imgui.CalcTextSize(tm)
        local cy0 = ry + (rowH - chipH) / 2
        local chipCol = isBest and C.gold or 0xFFFFFFFF
        dl:AddRectFilled(P(chipX, cy0), P(chipX + chipW, cy0 + chipH), rhAlpha(chipCol, 0.06 + 0.05 * a), 8)
        dl:AddRect(P(chipX, cy0), P(chipX + chipW, cy0 + chipH), rhAlpha(chipCol, 0.12 + 0.2 * a), 8, 15, 1.0)
        dl:AddText(P(chipX + (chipW - tsz.x) / 2, cy0 + (chipH - tsz.y) / 2), isBest and C.gold or 0xFFE0E0E0, tm)
        local _, cl, ccol = RI.cat(K.kind, e)
        if K.kind == "rent" then
            ctext(1, ry, rowH, e.nick or "", C.text)
            local pw = imgui.CalcTextSize(cl).x + 20
            rhPill(dl, colX[2] + (colW[2] - pw) / 2, ry + (rowH - 22) / 2, cl, ccol)
        elseif K.kind == "case" then
            ctext(1, ry, rowH, cl, C.text, ccol)
        elseif K.kind == "crypto" then
            ctext(1, ry, rowH, cl, C.text, ccol)
            ctext(2, ry, rowH, "x" .. (e.amount or 1), C.mute)
        else
            local nm = (e.name == "NFT контейнера") and (u8("Осколок ") .. cl) or (u8("Осколок Тайника ") .. cl)
            ctext(1, ry, rowH, nm, C.text, ccol)
        end
        local totTxt = formatNumber(tot) .. "$"
        if imgui.CalcTextSize(totTxt).x > totW - 16 then totTxt = PD.short(tot) .. "$" end
        local tw = imgui.CalcTextSize(totTxt).x
        local ttY = ds.best > 0 and (ty - 4) or ty
        dl:AddText(P(totCX - tw / 2, ttY), C.green, totTxt)
        if ds.best > 0 then
            local bw = totW - 28
            local bx0, by0 = totCX - bw / 2, ry + rowH - 14
            dl:AddRectFilled(P(bx0, by0), P(bx0 + bw, by0 + 3), rhAlpha(0xFFFFFFFF, 0.07), 2)
            dl:AddRectFilled(P(bx0, by0), P(bx0 + math.max(3, bw * (tot / ds.best)), by0 + 3), rhAlpha(C.green, 0.8), 2)
        end
        if hv and isBest and PD.hov(x, ry, pad + 70, rowH) then
            rhTipBegin()
            imgui.TextColored(PD.vec4(C.gold), K.best)
            rhTipEnd()
        end
    end
    if scrollMode then
        dl:PopClipRect()
        local sbx = x + w - 14
        dl:AddRectFilled(P(sbx, trackTop), P(sbx + 8, trackTop + trackH), rhAlpha(0xFFFFFFFF, 0.07), 4)
        local sbHot = dragging or PD.hov(x + w - 20, thumbY, 20, thumbH)
        dl:AddRectFilled(P(sbx, thumbY), P(sbx + 8, thumbY + thumbH), rhAlpha(ACC, sbHot and 0.95 or 0.6), 4)
    end
    local vcol = rhAlpha(0xFFFFFFFF, 0.05)
    local vx = {x + pad + timeW}
    for i = 2, nMid do vx[#vx + 1] = colX[i] end
    vx[#vx + 1] = totX
    for _, lx in ipairs(vx) do
        dl:AddLine(P(lx, y + 8), P(lx, fy - 8), vcol, 1.0)
    end
    dl:AddRectFilled(P(x + 1, fy), P(x + w - 1, y + tableH - 1), rhAlpha(ACC, 0.08), 13, 12)
    dl:AddLine(P(x + 1, fy), P(x + w - 1, fy), rhAlpha(ACC, 0.35), 1.0)
    local fty = fy + (fh - th) / 2
    dl:AddText(P(x + pad + 18, fty), ACC, S.itogo)
    dl:AddText(P(x + pad + 19, fty), ACC, S.itogo)
    dl:AddText(P(x + pad + 18 + imgui.CalcTextSize(S.itogo).x + 8, fty), C.dim, "x" .. ds.count)
    if K.kind == "rent" then
        local r = ds.cats.room and ds.cats.room.amount or 0
        local m = ds.cats.im and ds.cats.im.amount or 0
        ctext(1, fy, fh, u8("Дом: ") .. (r > 0 and (PD.short(r) .. "$") or "-"), r > 0 and 0xFFF8BD38 or C.dim)
        ctext(2, fy, fh, u8("Item Market: ") .. (m > 0 and (PD.short(m) .. "$") or "-"), m > 0 and 0xFF28AAFF or C.dim)
    elseif K.kind == "crypto" then
        local b = ds.cats.btc and ds.cats.btc.count or 0
        local a = ds.cats.asc and ds.cats.asc.count or 0
        ctext(1, fy, fh, "BTC: " .. (b > 0 and ("x" .. b) or "-"), b > 0 and 0xFF1A93F7 or C.dim)
        ctext(2, fy, fh, "ASC: " .. (a > 0 and ("x" .. a) or "-"), a > 0 and 0xFF3539E5 or C.dim)
    else
        ctext(1, fy, fh, K.avg .. PD.short(math.floor(ds.total / ds.count)) .. "$", C.dep)
    end
    local fTot = formatNumber(ds.total) .. "$"
    if imgui.CalcTextSize(fTot).x > totW - 16 then fTot = PD.short(ds.total) .. "$" end
    local fw = imgui.CalcTextSize(fTot).x
    dl:AddText(P(totCX - fw / 2, fty), C.green, fTot)
    dl:AddText(P(totCX - fw / 2 + 1, fty), C.green, fTot)
    return y + tableH + 12
end
function RI.drawInner(kind, K)
    local dl = imgui.GetWindowDrawList()
    local P = imgui.ImVec2
    local S, C = PD.str(), PD.C
    local c = RI.build(kind)
    PD.ensureSel(c)
    local bg, brd, iconCol = homeCardColors()
    local ACC = useCustomTheme and iconCol or 0xFF1AE591
    local cur = imgui.GetCursorScreenPos()
    local x, y = cur.x, cur.y + 4
    local w = imgui.GetWindowWidth() - 25
    RI.hero(dl, c, x, y, w, 152, ACC, bg, brd, K)
    y = y + 152 + 10
    RI.tiles(dl, c, x, y, w, 74, ACC, bg, brd, K)
    y = y + 74 + 12
    if #c.dates == 0 then
        local eh = 130
        rhCardBox(dl, x, y, w, eh, bg, brd, 14)
        rhIconBadge(dl, x + w / 2, y + 40, 20, K.icon, ACC, bg, 0)
        local s1, s2 = imgui.CalcTextSize(K.empty), imgui.CalcTextSize(K.emptySub)
        dl:AddText(P(x + (w - s1.x) / 2, y + 74), 0xFFFFFFFF, K.empty)
        dl:AddText(P(x + (w - s2.x) / 2, y + 96), C.mute, K.emptySub)
        y = y + eh + 10
    else
        PD.nav(dl, c, x, y, w, 46, ACC, bg, brd)
        y = y + 46 + 12
        y = RI.list(dl, c, x, y, w, ACC, bg, brd, K)
    end
    imgui.SetCursorScreenPos(P(x, y))
    imgui.Dummy(imgui.ImVec2(w, 6))
end
function RI.draw(kind)
    local K = RI.K(kind)
    RI.state[kind] = RI.state[kind] or {}
    local st = RI.state[kind]
    local s0, y0, m0 = PD.sel, PD.calY, PD.calM
    PD.sel, PD.calY, PD.calM = st.sel, st.calY, st.calM
    local ok, err = pcall(RI.drawInner, kind, K)
    st.sel, st.calY, st.calM = PD.sel, PD.calY, PD.calM
    PD.sel, PD.calY, PD.calM = s0, y0, m0
    if not ok then error(err, 0) end
end
function drawRentTab() RI.draw("rent") end
function drawShardTab() RI.draw("shard") end
OIL = OIL or {}
OIL.COL = 0xFF3D8AFF
OIL.RED = 0xFF5A5AF0
function OIL.K()
    if OIL.KC then return OIL.KC end
    local K = {}
    for k, v in pairs(WK.K(WORK_TYPES.MINE)) do K[k] = v end
    K.col = OIL.COL
    K.icon = fa.ICON_FIRE
    K.cap = u8("Доход с нефтевышек за сегодня")
    K.listTitle = u8("Операции за день")
    K.empty = u8("Данных по нефтевышкам пока нет")
    K.emptySub = u8("Статистика появится автоматически после первой операции")
    K.noToday = u8("Сегодня операций не было")
    K.emptyDay = u8("В этот день операций не было")
    K.pl = {u8("операция"), u8("операции"), u8("операций")}
    OIL.KC = K
    return K
end
function OIL.kinds()
    if OIL.KK then return OIL.KK end
    OIL.KK = {
        water        = {u8("Водная вышка"), 0xFFFFA040, false},
        ground_money = {u8("Вышки (электрокомпании)"), 0xFF33DD77, false},
        ground_az    = {u8("Наземные вышки (AZ)"), 0xFF00CCFF, false},
        bonus_az     = {u8("Бонус AZ"), 0xFFB672F4, false},
        case_drop    = {u8("Кейс"), 0xFF00D7FF, false},
        buy_water    = {u8("Закупка (вода)"), OIL.RED, true},
        buy_ground   = {u8("Закупка (наземные вышки)"), OIL.RED, true},
        other        = {u8("Прочее"), 0xFF8A8A8A, false},
    }
    return OIL.KK
end
function OIL.build()
    local log = oilLog or {}
    local todayKey = getGameDate()
    local last = log[1]
    local sig = #log .. "|" .. todayKey .. "|" .. (last and (last.time or 0) or 0) .. "|" .. (last and (last.money or 0) or 0)
    local cc = OIL.cache
    if cc and cc.sig == sig then return cc end
    local K, KK = OIL.K(), OIL.kinds()
    local byDate, dates = {}, {}
    local all = {total = 0, az = 0, rub = 0, count = 0}
    for _, e in ipairs(log) do
        local money, az = e.money or 0, e.az or 0
        local d = getGameDate(e.time)
        local ds = byDate[d]
        if not ds then
            ds = {total = 0, az = 0, rub = 0, count = 0, best = 0, earn = 0, cats = {}, buys = {}, hours = {}, logs = {}, pl = K.pl}
            byDate[d] = ds
            dates[#dates + 1] = d
        end
        ds.total = ds.total + money
        ds.az = ds.az + az
        ds.count = ds.count + 1
        ds.logs[#ds.logs + 1] = e
        local kind = KK[e.kind or "other"] and (e.kind or "other") or "other"
        local kd = KK[kind]
        local bucket = kd[3] and ds.buys or ds.cats
        local ce = bucket[kind]
        if not ce then
            ce = {key = kind, label = kd[1], col = kd[2], amount = 0, count = 0, az = 0, cases = 0, buy = kd[3]}
            bucket[kind] = ce
        end
        ce.amount = ce.amount + money
        ce.count = ce.count + 1
        ce.az = ce.az + az
        ce.cases = ce.cases + (e.caseCount or 0)
        if not kd[3] then
            ds.earn = ds.earn + money
            if ce.amount > ds.best then ds.best = ce.amount end
        end
        local hi = math.floor((((e.time or 0) + 10800 - 18000) % 86400) / 3600)
        local hb = ds.hours[hi]
        if not hb then hb = {total = 0, count = 0}; ds.hours[hi] = hb end
        hb.total = hb.total + money
        hb.count = hb.count + 1
        all.total = all.total + money
        all.az = all.az + az
        all.count = all.count + 1
    end
    table.sort(dates, function(a, b) return a > b end)
    local mskWday = tonumber(os.date("!%w", getMoscowTime())) or 1
    if mskWday == 0 then mskWday = 7 end
    local week = {total = 0, az = 0, rub = 0, count = 0}
    for i = 0, mskWday - 1 do
        local ds = byDate[getGameDate(os.time() - i * 86400)]
        if ds then
            week.total = week.total + ds.total
            week.az = week.az + ds.az
            week.count = week.count + ds.count
        end
    end
    local last7 = {}
    for i = 6, 0, -1 do
        local d = getGameDate(os.time() - i * 86400)
        local ds = byDate[d]
        last7[#last7 + 1] = {date = d, wd = PD.weekday(d), total = ds and ds.total or 0, az = ds and ds.az or 0, count = ds and ds.count or 0}
    end
    local yestKey = getGameDate(os.time() - 86400)
    local out = {
        sig = sig, t = os.clock(), price = {},
        byDate = byDate, dates = dates, all = all, week = week, last7 = last7,
        todayKey = todayKey, yestKey = yestKey, pl = K.pl,
        today = byDate[todayKey] or PD.EMPTY, yest = byDate[yestKey] or PD.EMPTY,
    }
    OIL.cache = out
    return out
end
function OIL.actOverlay()
    cb_oil_overlay.v = not cb_oil_overlay.v
    if cb_oil_overlay.v then
        settings.incassOverlayEnabled = false; cb_incass_overlay.v = false
        settings.farmOverlayEnabled = false; cb_farm_overlay.v = false
        settings.mineOverlayEnabled = false; cb_mine_overlay.v = false
        settings.sawmillOverlayEnabled = false; cb_sawmill_overlay.v = false
        settings.taxiOverlayEnabled = false; cb_taxi_overlay.v = false
        settings.oilOverlayEnabled = true
        if settings.overlayAutoTimer and not overlayTimer.running then
            overlayTimer.running = true; overlayTimer.startTime = os.time()
            overlayTimer.elapsed = 0; overlayTimer.displayedTime = "00:00:00"
        end
    else
        settings.oilOverlayEnabled = false
    end
    saveConfig()
end
function OIL.overlayItem()
    if OIL.OV then return OIL.OV end
    OIL.OV = {
        icon = WK.ic("ICON_DESKTOP"), col = OIL.COL, title = u8("Оверлей на экране"),
        desc = u8("Статистика нефтевышек поверх игры"),
        get = function() return cb_oil_overlay.v end, act = OIL.actOverlay,
    }
    return OIL.OV
end
function OIL.countItem()
    if OIL.CNT then return OIL.CNT end
    OIL.CNT = {
        icon = WK.ic("ICON_MONEY"), col = OIL.COL, title = u8("Учитывать доход нефтевышек"),
        desc = u8("Записывать продажу бочек в статистику"),
        get = function() return cb_oil.v end,
        act = function()
            cb_oil.v = not cb_oil.v
            settings.oilEnabled = cb_oil.v
            saveConfig(); needSave = true
        end,
    }
    return OIL.CNT
end
function OIL.input(id, edit, iw, step, stepFast)
    imgui.PushItemWidth(iw)
    imgui.PushStyleVar(imgui.StyleVar.FrameRounding, 6)
    imgui.PushStyleColor(imgui.Col.FrameBg, imgui.ImVec4(0.09, 0.09, 0.09, 1))
    imgui.PushStyleColor(imgui.Col.FrameBgHovered, imgui.ImVec4(0.13, 0.13, 0.13, 1))
    imgui.PushStyleColor(imgui.Col.FrameBgActive, imgui.ImVec4(0.15, 0.15, 0.15, 1))
    imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(1.0, 0.54, 0.24, 0.18))
    imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(1.0, 0.54, 0.24, 0.35))
    imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(1.0, 0.54, 0.24, 0.5))
    imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.95, 0.95, 0.95, 1))
    local changed = imgui.InputInt(id, edit, step, stepFast)
    imgui.PopStyleColor(7)
    imgui.PopStyleVar(1)
    imgui.PopItemWidth()
    return changed
end
function OIL.menu()
    local K = OIL.K()
    local dl = imgui.GetWindowDrawList()
    local P = imgui.ImVec2
    local C = PD.C
    local bg, brd = homeCardColors()
    local cur = imgui.GetCursorScreenPos()
    local x, y = cur.x, cur.y + 4
    local w = imgui.GetWindowWidth() - 25
    local c = OIL.build()
    local s = oilSessionData or {money = 0, az = 0}
    local sh, btnW = 96, 200
    rhCardBox(dl, x, y, w, sh, bg, brd, 14)
    rhIconBadge(dl, x + 38, y + 36, 18, K.icon, K.col, bg, 0)
    dl:PushClipRect(P(x + 72, y), P(x + w - btnW - 28, y + sh), true)
    dl:AddText(P(x + 72, y + 16), C.mute, u8("Доход за сессию"))
    local tot = formatNumber(s.money) .. "$"
    local totCol = (s.money >= 0) and C.green or OIL.RED
    dl:AddText(P(x + 72, y + 40), totCol, tot)
    dl:AddText(P(x + 73, y + 40), totCol, tot)
    rhPill(dl, x + 72 + imgui.CalcTextSize(tot).x + 14, y + 39, formatNumber(s.az) .. " AZ", C.az)
    dl:AddText(P(x + 72, y + 68), C.dim, u8("Считается с момента последнего сброса"))
    dl:PopClipRect()
    if WK.button(dl, "##oil_new_session", x + w - btnW - 16, y + (sh - 40) / 2, btnW, 40,
                 u8("Новая сессия"), WK.ic("ICON_REFRESH"), K.col, true, false) then
        resetOilSession()
    end
    y = y + sh + 12
    local gap = 8
    local tw = (w - gap * 2) / 3
    local th = 74
    local items = {
        {key = "all",   label = u8("Всего заработано"), icon = fa.ICON_TROPHY,   col = C.acc, d = c.all},
        {key = "today", label = u8("За сегодня"),       icon = fa.ICON_CALENDAR, col = C.sal, d = c.today},
        {key = "week",  label = u8("За неделю"),        icon = fa.ICON_LIST,     col = C.dep, d = c.week},
    }
    for i, it in ipairs(items) do
        local tx = x + (i - 1) * (tw + gap)
        imgui.SetCursorScreenPos(P(tx, y))
        if imgui.InvisibleButton("##oil_tile_" .. it.key, imgui.ImVec2(tw, th)) then
            if OIL.sec then OIL.sec.v = 3 end
        end
        local hv = imgui.IsItemHovered()
        local a = rhAnim("oil_tile_" .. it.key, hv and 1 or 0)
        local bgT = rhLerpColor(bg, rhLerpColor(bg, 0xFFFFFFFF, 0.04), a)
        rhCardBox(dl, tx, y, tw, th, bgT, rhLerpColor(brd, it.col, 0.55 * a), 12)
        rhIconBadge(dl, tx + 28, y + th / 2, 17, it.icon, it.col, bgT, a)
        local d = it.d
        dl:PushClipRect(P(tx + 52, y), P(tx + tw - 8, y + th), true)
        dl:AddText(P(tx + 54, y + 10), C.mute, it.label)
        dl:AddText(P(tx + 54, y + 28), 0xFFFFFFFF, formatNumber(d.total or 0) .. "$")
        dl:AddText(P(tx + 54, y + 48), (d.az or 0) > 0 and C.az or C.dim, formatNumber(d.az or 0) .. " AZ")
        dl:PopClipRect()
    end
    y = y + th + 14
    dl:AddText(P(x + 4, y + 5), 0xFFFFFFFF, u8("Настройки"))
    y = y + 34
    local cnt = OIL.countItem()
    if WK.row(dl, "oil_cnt", x, y, w, 56, bg, brd, cnt, nil) then cnt.act() end
    y = y + 56 + 8
    local ov = OIL.overlayItem()
    if WK.row(dl, "oil_ovl", x, y, w, 56, bg, brd, ov, nil) then ov.act() end
    y = y + 56 + 12
    imgui.SetCursorScreenPos(P(x, y))
    imgui.Dummy(imgui.ImVec2(w, 6))
end
function OIL.prices()
    local K = OIL.K()
    local dl = imgui.GetWindowDrawList()
    local P = imgui.ImVec2
    local C = PD.C
    local bg, brd = homeCardColors()
    local cur = imgui.GetCursorScreenPos()
    local x, y = cur.x, cur.y + 4
    local w = imgui.GetWindowWidth() - 25
    local th = imgui.CalcTextSize("A").y
    if not oilConfig.groundBarrelCompanyBonus then oilConfig.groundBarrelCompanyBonus = 0 end
    local function infoCard(icon, col, title, value, valueCol, hint)
        local ch = 98
        rhCardBox(dl, x, y, w, ch, bg, brd, 14)
        rhIconBadge(dl, x + 34, y + 28, 15, icon, col, bg, 0)
        dl:AddText(P(x + 62, y + 20), 0xFFFFFFFF, title)
        dl:AddText(P(x + 22, y + 46), valueCol, value)
        dl:AddText(P(x + 23, y + 46), valueCol, value)
        dl:PushClipRect(P(x + 22, y), P(x + w - 16, y + ch), true)
        dl:AddText(P(x + 22, y + 70), C.dim, hint)
        dl:PopClipRect()
        y = y + ch + 10
    end
    infoCard(WK.ic("ICON_SHOPPING_CART"), 0xFF3399FF, u8("Авто-цена закупки воды (бочка)"),
             formatNumber(oilConfig.barrelCost or 0) .. "$", 0xFF4646EB,
             u8("Обновляется автоматически при подходе к водной нефтевышке"))
    infoCard(WK.ic("ICON_SHOPPING_CART"), 0xFF28AAFF, u8("Авто-цена закупки грунтовой бочки"),
             formatNumber(oilConfig.azBarrelCost or 0) .. " AZ", 0xFF4646EB,
             u8("Обновляется автоматически при подходе к наземной нефтевышке"))
    infoCard(WK.ic("ICON_MONEY"), 0xFF33CC88, u8("Авто-цена продажи бочки"),
             formatNumber(oilConfig.groundOilMoney or 0) .. "$", C.green,
             u8("Обновляется автоматически при подходе к вышке / точке приёма"))
    local bonus = oilConfig.groundBarrelCompanyBonus
    infoCard(WK.ic("ICON_PLUS"), 0xFFFFB020, u8("Доплата электрокомпании за бочку"),
             bonus == 0 and u8("0$ (нет доплаты)") or (formatNumber(bonus) .. "$"), 0xFF28AAFF,
             u8("Определяется автоматически при выборе компании в игре"))
    imgui.SetCursorScreenPos(P(x, y))
    imgui.Dummy(imgui.ImVec2(w, 6))
end
function OIL.cases()
    local K = OIL.K()
    local dl = imgui.GetWindowDrawList()
    local P = imgui.ImVec2
    local C = PD.C
    local bg, brd = homeCardColors()
    local cur = imgui.GetCursorScreenPos()
    local x, y = cur.x, cur.y + 4
    local w = imgui.GetWindowWidth() - 25
    local totalValue, totalCount = 0, 0
    for _, cd in pairs(caseConfig) do
        totalValue = totalValue + (cd.cost or 0) * (cd.count or 0)
        totalCount = totalCount + (cd.count or 0)
    end
    local gap = 8
    local tw = (w - gap) / 2
    local th = 74
    local tiles = {
        {label = u8("Всего за кейсы"), icon = WK.ic("ICON_MONEY"), col = C.green, val = formatNumber(totalValue) .. "$"},
        {label = u8("Кейсов всего"), icon = WK.ic("ICON_BRIEFCASE"), col = C.gold, val = formatNumber(totalCount) .. u8(" шт.")},
    }
    for i, it in ipairs(tiles) do
        local tx = x + (i - 1) * (tw + gap)
        rhCardBox(dl, tx, y, tw, th, bg, brd, 12)
        rhIconBadge(dl, tx + 28, y + th / 2, 17, it.icon, it.col, bg, 0)
        dl:AddText(P(tx + 54, y + 16), C.mute, it.label)
        dl:AddText(P(tx + 54, y + 40), 0xFFFFFFFF, it.val)
    end
    y = y + th + 12
    if next(caseConfig) == nil then
        local eh = 92
        rhCardBox(dl, x, y, w, eh, bg, brd, 12)
        rhIconBadge(dl, x + w / 2, y + 32, 16, WK.ic("ICON_BRIEFCASE"), C.mute, bg, 0)
        local msg = u8("Нет кейсов. Они появятся здесь при выпадении.")
        local sz = imgui.CalcTextSize(msg)
        dl:AddText(P(x + (w - sz.x) / 2, y + 60), C.mute, msg)
        y = y + eh + 12
    else
        local ids = {}
        for itemId in pairs(caseConfig) do ids[#ids + 1] = itemId end
        table.sort(ids, function(a, b) return tostring(a) < tostring(b) end)
        if not caseEditCache then caseEditCache = {} end
        local ch = 68
        local th2 = imgui.CalcTextSize("A").y
        for _, itemId in ipairs(ids) do
            local cd = caseConfig[itemId]
            if not caseEditCache[itemId] then
                caseEditCache[itemId] = imgui.ImInt(cd.cost or 0)
            end
            rhCardBox(dl, x, y, w, ch, bg, brd, 12)
            rhIconBadge(dl, x + 34, y + ch / 2, 16, WK.ic("ICON_BRIEFCASE"), K.col, bg, 0)
            local resetSz = 28
            local iw = 130
            local resetX = x + w - 14 - resetSz
            local inputX = resetX - 10 - iw
            local tx = x + 66
            dl:PushClipRect(P(tx, y), P(inputX - 10, y + ch), true)
            dl:AddText(P(tx, y + 14), 0xFFFFFFFF, u8(cd.name or tostring(itemId)))
            local countStr = u8("Кол-во: ") .. (cd.count or 0)
            dl:AddText(P(tx, y + 38), C.mute, countStr)
            dl:AddText(P(tx + imgui.CalcTextSize(countStr).x + 14, y + 38), C.green, formatNumber((cd.cost or 0) * (cd.count or 0)) .. "$")
            dl:PopClipRect()
            imgui.SetCursorScreenPos(P(inputX, y + (ch - 26) / 2))
            imgui.PushItemWidth(iw)
            imgui.PushStyleVar(imgui.StyleVar.FrameRounding, 6)
            imgui.PushStyleColor(imgui.Col.FrameBg, imgui.ImVec4(0.09, 0.09, 0.09, 1))
            imgui.PushStyleColor(imgui.Col.FrameBgHovered, imgui.ImVec4(0.13, 0.13, 0.13, 1))
            imgui.PushStyleColor(imgui.Col.FrameBgActive, imgui.ImVec4(0.15, 0.15, 0.15, 1))
            imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.95, 0.95, 0.95, 1))
            if imgui.InputInt("##case_cost_" .. itemId, caseEditCache[itemId], 0, 0) then
                caseConfig[itemId].cost = caseEditCache[itemId].v
                saveCaseConfig()
            end
            imgui.PopStyleColor(4)
            imgui.PopStyleVar(1)
            imgui.PopItemWidth()
            local ry = y + (ch - resetSz) / 2
            imgui.SetCursorScreenPos(P(resetX, ry))
            local rc = imgui.InvisibleButton("##reset_case_" .. itemId, imgui.ImVec2(resetSz, resetSz))
            local rhv = imgui.IsItemHovered()
            local ra = rhAnim("oil_reset_" .. tostring(itemId), rhv and 1 or 0)
            dl:AddCircleFilled(P(resetX + resetSz / 2, ry + resetSz / 2), resetSz / 2, rhLerpColor(0xFF1C1C1C, 0xFF353535, ra), 20)
            local ic = WK.ic("ICON_REPEAT")
            local isz = imgui.CalcTextSize(ic)
            dl:AddText(P(resetX + (resetSz - isz.x) / 2, ry + (resetSz - isz.y) / 2), rhv and 0xFFFFFFFF or C.mute, ic)
            if rhv then
                rhTipBegin()
                imgui.Text(u8("Сбросить счётчик кейсов"))
                rhTipEnd()
            end
            if rc then
                caseConfig[itemId].count = 0
                saveCaseConfig()
            end
            y = y + ch + 8
        end
        y = y + 4
        if WK.button(dl, "##oil_save_cases", x, y, w, 44, u8("Сохранить цены кейсов"), WK.ic("ICON_FLOPPY_O"), K.col, true, false) then
            saveCaseConfig()
            sampAddChatMessage(SCRIPT_PREFIX .. "Цены кейсов сохранены!", SCRIPT_COLOR)
        end
        y = y + 44 + 12
    end
    imgui.SetCursorScreenPos(P(x, y))
    imgui.Dummy(imgui.ImVec2(w, 6))
end
function OIL.entryTip(log)
    local base = oilConfig.groundOilMoney or 270000
    local caseCost = 0
    if log.caseType and caseConfig[log.caseType] then
        caseCost = caseConfig[log.caseType].cost or 0
    end
    local kind = log.kind
    if kind == "water" then
        local companyMoney = log.companyMoney or 0
        local saleMoney = log.saleMoney or ((log.money or 0) - caseCost - companyMoney)
        imgui.Text(u8("Продажа бочки: ") .. formatNumber(saleMoney) .. "$")
        if (log.bonusMoney or 0) > 0 then
            imgui.Text(u8("  из них надбавка +") .. (log.bonusPct or 0) .. "%: " .. formatNumber(log.bonusMoney) .. "$")
        end
        if companyMoney > 0 then
            imgui.Text(u8("Доплата электрокомпании: ") .. formatNumber(companyMoney) .. "$")
        end
        if log.isBonusAZ and (log.az or 0) > 0 then
            imgui.Text(u8("Бонус AZ: ") .. formatNumber(log.az) .. " AZ")
        end
        if caseCost > 0 then
            imgui.Text(u8("Доход с кейса: ") .. formatNumber(caseCost) .. "$")
        end
    elseif kind == "ground_money" and log.companyOnly then
        imgui.Text(u8("Доплата электрокомпании: ") .. formatNumber((log.money or 0) - caseCost) .. "$")
        if (log.az or 0) > 0 then
            imgui.Text(u8("AZ за бочку: ") .. formatNumber(log.az) .. " AZ")
        end
        if caseCost > 0 then
            imgui.Text(u8("Доход с кейса: ") .. formatNumber(caseCost) .. "$")
        end
    elseif kind == "ground_money" then
        local companyBonus = oilConfig.groundBarrelCompanyBonus or 0
        imgui.Text(u8("Доход с бочки: ") .. formatNumber(base) .. "$")
        imgui.Text(u8("Надбавки с электрокомпании: ") .. formatNumber(companyBonus) .. "$")
        local actualNoCase = (log.money or 0) - caseCost
        if actualNoCase > base + companyBonus then
            imgui.Text(u8("Надбавки с бонусов: ") .. formatNumber(actualNoCase - base - companyBonus) .. "$")
        end
        if caseCost > 0 then
            imgui.Text(u8("Доход с кейса: ") .. formatNumber(caseCost) .. "$")
        end
    elseif kind == "ground_az" then
        local actualNoCase = (log.money or 0) - caseCost
        imgui.Text(u8("Доход с бочки: ") .. formatNumber(base) .. "$")
        if actualNoCase > base then
            imgui.Text(u8("Надбавки с бонусов: ") .. formatNumber(actualNoCase - base) .. "$")
        end
        if caseCost > 0 then
            imgui.Text(u8("Доход с кейса: ") .. formatNumber(caseCost) .. "$")
        end
    elseif kind == "case_drop" then
        local caseName = (caseConfig[log.caseType] and caseConfig[log.caseType].name) or "Неизвестный кейс"
        imgui.Text(u8("Кейс: ") .. u8(caseName))
        imgui.Text(u8("Цена за шт: ") .. formatNumber(log.money or 0) .. "$")
        imgui.Text(u8("Кол-во: ") .. (log.caseCount or 1))
    elseif kind == "bonus_az" then
        imgui.Text(u8("Бонус AZ: ") .. formatNumber(log.az or 0))
    else
        local kd = OIL.kinds()[kind or "other"] or OIL.kinds().other
        imgui.Text(kd[1])
        imgui.Text(formatNumber(log.money or 0) .. "$")
    end
end
function OIL.group(logs)
    local GAP, SPAN = 600, 1800
    local rows, open = {}, {}
    for _, e in ipairs(logs) do
        local t = e.time or 0
        local kind = e.kind or "other"
        local g = open[kind]
        if g and (g.tOld - t) <= GAP and (g.tNew - t) <= SPAN then
            g.count = g.count + 1
            g.money = g.money + (e.money or 0)
            g.az = g.az + (e.az or 0)
            g.caseCount = g.caseCount + (e.caseCount or 0)
            g.entries[#g.entries + 1] = e
            if t < g.tOld then g.tOld = t end
        else
            g = {kind = kind, count = 1, money = e.money or 0, az = e.az or 0,
                 caseCount = e.caseCount or 0, tNew = t, tOld = t, first = e, entries = {e}}
            open[kind] = g
            rows[#rows + 1] = g
        end
    end
    for _, g in ipairs(rows) do g.key = g.kind .. "|" .. g.tOld end
    return rows
end
function OIL.list(dl, c, x, y, w, ACC, bg, brd, K)
    local S, C = PD.str(), PD.C
    local P = imgui.ImVec2
    local ds = c.byDate[PD.sel] or PD.EMPTY
    local th = imgui.CalcTextSize("A").y
    dl:AddText(P(x + 4, y + 5), 0xFFFFFFFF, K.listTitle)
    y = y + 34
    if ds.count == 0 then
        local eh = 92
        rhCardBox(dl, x, y, w, eh, bg, brd, 12)
        rhIconBadge(dl, x + w / 2, y + 32, 16, fa.ICON_CALENDAR, C.mute, bg, 0)
        local sz = imgui.CalcTextSize(K.emptyDay)
        dl:AddText(P(x + (w - sz.x) / 2, y + 60), C.mute, K.emptyDay)
        return y + eh + 8
    end
    local arr = {}
    for _, ce in pairs(ds.cats or {}) do if ce.count > 0 then arr[#arr + 1] = ce end end
    table.sort(arr, function(a, b)
        if a.amount ~= b.amount then return a.amount > b.amount end
        return a.count > b.count
    end)
    local buys = {}
    for _, ce in pairs(ds.buys or {}) do if ce.count > 0 then buys[#buys + 1] = ce end end
    table.sort(buys, function(a, b) return a.count > b.count end)
    for _, ce in ipairs(buys) do arr[#arr + 1] = ce end
    local gap = 8
    local ncols = (w >= 520) and 2 or 1
    local cw = (w - gap * (ncols - 1)) / ncols
    local ch = 64
    local earn = (ds.earn and ds.earn > 0) and ds.earn or 1
    for i, ce in ipairs(arr) do
        local colI = (i - 1) % ncols
        local rowI = math.floor((i - 1) / ncols)
        local cx = x + colI * (cw + gap)
        local cy = y + rowI * (ch + gap)
        imgui.SetCursorScreenPos(P(cx, cy))
        imgui.InvisibleButton("##oil_cat_" .. i, imgui.ImVec2(cw, ch))
        local hv = imgui.IsItemHovered()
        local a = rhAnim("oil_cat_" .. i, hv and 1 or 0)
        local bgC = rhLerpColor(bg, rhLerpColor(bg, 0xFFFFFFFF, 0.04), a)
        rhCardBox(dl, cx, cy, cw, ch, bgC, rhLerpColor(brd, ce.col, 0.55 * a), 12)
        local chip = 36
        local chx, chy = cx + 14, cy + (ch - chip) / 2 - 4
        dl:AddRectFilled(P(chx, chy), P(chx + chip, chy + chip), rhAlpha(ce.col, 0.14 + 0.08 * a), 10)
        dl:AddRect(P(chx, chy), P(chx + chip, chy + chip), rhAlpha(ce.col, 0.45 + 0.3 * a), 10, 15, 1.0)
        local letter = ce.label:match("^[\1-\127\192-\255][\128-\191]*") or "?"
        local lsz = imgui.CalcTextSize(letter)
        dl:AddText(P(chx + (chip - lsz.x) / 2, chy + (chip - lsz.y) / 2), ce.col, letter)
        local tx = cx + 14 + chip + 12
        local incTxt = ((ce.amount >= 0) and "+" or "") .. formatNumber(ce.amount) .. "$"
        if imgui.CalcTextSize(incTxt).x > cw * 0.45 then incTxt = PD.short(ce.amount) .. "$" end
        local incW = imgui.CalcTextSize(incTxt).x
        local incCol = ce.buy and OIL.RED or C.green
        local pct = (not ce.buy and ds.earn and ds.earn > 0) and math.floor(ce.amount / earn * 100 + 0.5) or 0
        dl:PushClipRect(P(tx, cy), P(cx + cw - 14 - incW - 8, cy + ch), true)
        dl:AddText(P(tx, cy + 9), 0xFFFFFFFF, ce.label)
        dl:PopClipRect()
        dl:AddText(P(cx + cw - 14 - incW, cy + 9), incCol, incTxt)
        local sub = "x" .. formatNumber(ce.count)
        dl:AddText(P(tx, cy + 28), ce.col, sub)
        local px = tx + imgui.CalcTextSize(sub).x + 12
        if (ce.az or 0) > 0 then
            local s1 = formatNumber(ce.az) .. " AZ"
            dl:AddText(P(px, cy + 28), C.az, s1)
            px = px + imgui.CalcTextSize(s1).x + 12
        end
        if (ce.cases or 0) > 0 then
            dl:AddText(P(px, cy + 28), C.gold, formatNumber(ce.cases) .. u8(" кейс."))
        end
        if not ce.buy then
            local pctTxt = pct .. "%"
            dl:AddText(P(cx + cw - 14 - imgui.CalcTextSize(pctTxt).x, cy + 28), C.mute, pctTxt)
            local bx0, bx1, by = tx, cx + cw - 14, cy + ch - 14
            dl:AddRectFilled(P(bx0, by), P(bx1, by + 4), rhAlpha(0xFFFFFFFF, 0.07), 2)
            if ds.earn and ds.earn > 0 and ce.amount > 0 then
                dl:AddRectFilled(P(bx0, by), P(bx0 + math.max(3, (bx1 - bx0) * (ce.amount / earn)), by + 4), rhAlpha(ce.col, 0.9), 2)
            end
        end
        if hv then
            rhTipBegin()
            imgui.TextColored(PD.vec4(ce.col), ce.label)
            imgui.TextColored(PD.vec4(C.mute), K.qtyL .. formatNumber(ce.count))
            imgui.TextColored(PD.vec4(incCol), K.incomeL .. formatNumber(ce.amount) .. "$")
            if (ce.az or 0) > 0 then imgui.TextColored(PD.vec4(C.az), "AZ: " .. formatNumber(ce.az)) end
            if (ce.cases or 0) > 0 then imgui.TextColored(PD.vec4(C.gold), u8("Кейсов: ") .. formatNumber(ce.cases)) end
            if not ce.buy and ds.earn > 0 then imgui.TextColored(PD.vec4(C.mute), K.shareL .. pct .. "%") end
            rhTipEnd()
        end
    end
    local rows = math.ceil(#arr / ncols)
    y = y + rows * (ch + gap)
    local fh = 50
    dl:AddRectFilled(P(x, y), P(x + w, y + fh), rhAlpha(ACC, 0.08), 12)
    dl:AddRect(P(x, y), P(x + w, y + fh), rhAlpha(ACC, 0.35), 12, 15, 1.0)
    local fty = y + (fh - th) / 2
    dl:AddText(P(x + 18, fty), ACC, S.itogo)
    dl:AddText(P(x + 19, fty), ACC, S.itogo)
    dl:AddText(P(x + 18 + imgui.CalcTextSize(S.itogo).x + 8, fty), C.dim, "x" .. formatNumber(ds.count))
    local fTot = formatNumber(ds.total) .. "$"
    local fw = imgui.CalcTextSize(fTot).x
    local fCol = (ds.total >= 0) and C.green or OIL.RED
    dl:AddText(P(x + w - 18 - fw, fty), fCol, fTot)
    dl:AddText(P(x + w - 17 - fw, fty), fCol, fTot)
    if (ds.az or 0) > 0 then
        local azs = formatNumber(ds.az) .. " AZ"
        dl:AddText(P(x + w - 18 - fw - 16 - imgui.CalcTextSize(azs).x, fty), C.az, azs)
    end
    y = y + fh + 14
    dl:AddText(P(x + 4, y + 5), 0xFFFFFFFF, u8("Журнал за день"))
    y = y + 34
    local logs = ds.logs or {}
    if not OIL.grpCache or OIL.grpCache.ds ~= ds then
        OIL.grpCache = {ds = ds, rows = OIL.group(logs)}
    end
    OIL.exp = OIL.exp or {}
    local rows = {}
    for _, g in ipairs(OIL.grpCache.rows) do
        rows[#rows + 1] = {g = g}
        if g.count > 1 and OIL.exp[g.key] then
            for _, e in ipairs(g.entries) do rows[#rows + 1] = {g = g, e = e} end
        end
    end
    local n = #rows
    local rowH = 36
    local maxRows = 10
    local scrollMode = n > maxRows
    local visH = (scrollMode and maxRows or n) * rowH
    local KK = OIL.kinds()
    local top = y + 4
    rhCardBox(dl, x, y, w, visH + 8, bg, brd, 12)
    local mp = imgui.GetMousePos()
    local inTable, dragging, scrollOff = false, false, 0
    local maxOff = math.max(0, n * rowH - visH)
    local trackTop, trackH, thumbH, thumbY = top + 6, visH - 12, 0, 0
    local sKey = "oil|" .. tostring(PD.sel)
    RI.scroll = RI.scroll or {}
    if scrollMode then
        scrollOff = RI.scroll[sKey] or 0
        inTable = PD.hov(x, top, w, visH)
        local wheel = RI.wheelAcc or 0
        RI.wheelAcc = 0
        if inTable and wheel ~= 0 then
            local want = scrollOff - wheel * rowH * 3
            local clamped = math.max(0, math.min(maxOff, want))
            local overflow = want - clamped
            scrollOff = clamped
            if overflow ~= 0 and imgui.GetScrollY and imgui.SetScrollY then
                imgui.SetScrollY(imgui.GetScrollY() + overflow)
            end
        end
        RI.tableHover = inTable
        thumbH = math.max(34, trackH * visH / (n * rowH))
        local range = math.max(1, trackH - thumbH)
        thumbY = trackTop + range * (scrollOff / math.max(1, maxOff))
        imgui.SetCursorScreenPos(P(x + w - 20, trackTop))
        imgui.InvisibleButton("##oil_sb_" .. sKey, imgui.ImVec2(20, trackH))
        if imgui.IsItemActive() then
            dragging = true
            if not RI.sbGrab then
                RI.sbGrab = (mp.y >= thumbY and mp.y <= thumbY + thumbH) and (mp.y - thumbY) or (thumbH / 2)
            end
            scrollOff = (mp.y - RI.sbGrab - trackTop) / range * maxOff
        else
            RI.sbGrab = nil
        end
        scrollOff = math.max(0, math.min(maxOff, scrollOff))
        RI.scroll[sKey] = scrollOff
        thumbY = trackTop + range * (scrollOff / math.max(1, maxOff))
        dl:PushClipRect(P(x, top), P(x + w, top + visH), true)
    end
    local visFirst, visLast = 1, n
    if scrollMode then
        visFirst = math.max(1, math.floor(scrollOff / rowH) + 1)
        visLast = math.min(n, math.floor((scrollOff + visH) / rowH) + 1)
    end
    local rowsTop = top - scrollOff
    local rpad = scrollMode and 28 or 16
    for i = visFirst, visLast do
        local rw = rows[i]
        local g = rw.e and {kind = rw.e.kind or "other", money = rw.e.money or 0, az = rw.e.az or 0,
                            caseCount = rw.e.caseCount or 0, tNew = rw.e.time or 0, count = 1, first = rw.e} or rw.g
        local ry = rowsTop + (i - 1) * rowH
        local hv
        if scrollMode then
            hv = inTable and not dragging and mp.y >= ry and mp.y < ry + rowH
        else
            imgui.SetCursorScreenPos(P(x, ry))
            imgui.InvisibleButton("##oil_j_" .. i, imgui.ImVec2(w, rowH))
            hv = imgui.IsItemHovered()
        end
        if rw.e then dl:AddRectFilled(P(x + 4, ry), P(x + w - 4, ry + rowH), rhAlpha(0xFFFFFFFF, 0.03), 8) end
        if hv then dl:AddRectFilled(P(x + 4, ry), P(x + w - 4, ry + rowH), rhAlpha(0xFFFFFFFF, 0.04), 8) end
        if hv and not rw.e and g.count > 1 then
            local clk
            if scrollMode then clk = imgui.IsMouseClicked(0) and mp.x < x + w - 22
            else clk = imgui.IsItemClicked() end
            if clk then OIL.exp[g.key] = not OIL.exp[g.key] or nil end
        end
        local kd = KK[g.kind] or KK.other
        local ty = ry + (rowH - th) / 2
        dl:AddText(P(x + 16, ty), C.mute, os.date("!%H:%M", g.tNew + 10800))
        dl:AddCircleFilled(P(x + 74, ry + rowH / 2), 4, kd[2], 12)
        local money = g.money
        local totalStr = ((money >= 0) and "+" or "") .. formatNumber(money) .. "$"
        local ax = x + w - rpad - imgui.CalcTextSize(totalStr).x
        dl:AddText(P(ax, ty), (money < 0) and OIL.RED or C.green, totalStr)
        local rx = ax - 16
        if g.az > 0 then
            local s1 = formatNumber(g.az) .. " AZ"
            rx = rx - imgui.CalcTextSize(s1).x
            dl:AddText(P(rx, ty), C.az, s1)
            rx = rx - 14
        end
        if g.caseCount > 0 then
            local s2 = formatNumber(g.caseCount) .. u8(" кейс")
            rx = rx - imgui.CalcTextSize(s2).x
            dl:AddText(P(rx, ty), C.gold, s2)
            rx = rx - 14
        end
        local lx = x + 88 + (rw.e and 14 or 0)
        dl:PushClipRect(P(lx, ry), P(rx, ry + rowH), true)
        dl:AddText(P(lx, ty), kd[3] and OIL.RED or 0xFFE0E0E0, kd[1])
        if g.count > 1 then
            local mark = OIL.exp[g.key] and "  [-]" or "  [+]"
            dl:AddText(P(lx + imgui.CalcTextSize(kd[1]).x + 8, ty), C.dim, "x" .. formatNumber(g.count) .. mark)
        end
        dl:PopClipRect()
        if i < n then
            dl:AddLine(P(x + 14, ry + rowH), P(x + w - 14, ry + rowH), rhAlpha(0xFFFFFFFF, 0.05), 1.0)
        end
        if hv then
            rhTipBegin()
            if g.count == 1 then
                OIL.entryTip(g.first)
            else
                imgui.TextColored(PD.vec4(kd[2]), kd[1])
                imgui.Text(u8("Записей: ") .. formatNumber(g.count))
                imgui.Text(u8("Период: ") .. os.date("!%H:%M", g.tOld + 10800) .. " - " .. os.date("!%H:%M", g.tNew + 10800))
                imgui.Text(u8("Сумма: ") .. formatNumber(g.money) .. "$")
                imgui.Text(u8("В среднем: ") .. formatNumber(math.floor(g.money / g.count)) .. "$")
                if g.az ~= 0 then imgui.Text("AZ: " .. formatNumber(g.az)) end
                if g.caseCount > 0 then imgui.Text(u8("Кейсов: ") .. formatNumber(g.caseCount)) end
            end
            rhTipEnd()
        end
    end
    if scrollMode then
        dl:PopClipRect()
        local sbx = x + w - 14
        dl:AddRectFilled(P(sbx, trackTop), P(sbx + 8, trackTop + trackH), rhAlpha(0xFFFFFFFF, 0.07), 4)
        local sbHot = dragging or PD.hov(x + w - 20, thumbY, 20, thumbH)
        dl:AddRectFilled(P(sbx, thumbY), P(sbx + 8, thumbY + thumbH), rhAlpha(ACC, sbHot and 0.95 or 0.6), 4)
    end
    y = y + visH + 8
    if #logs > #OIL.grpCache.rows then
        dl:AddText(P(x + 8, y + 6), C.dim, u8("Сгруппировано: ") .. #logs .. u8(" записей в ") .. #OIL.grpCache.rows .. u8(" строк (клик по строке с x - раскрыть)"))
        y = y + 28
    end
    return y + 12
end
function OIL.drawInner()
    local K = OIL.K()
    local dl = imgui.GetWindowDrawList()
    local P = imgui.ImVec2
    local C = PD.C
    local c = OIL.build()
    PD.ensureSel(c)
    local bg, brd, iconCol = homeCardColors()
    local ACC = useCustomTheme and iconCol or 0xFF1AE591
    local cur = imgui.GetCursorScreenPos()
    local x, y = cur.x, cur.y + 4
    local w = imgui.GetWindowWidth() - 25
    WK.hero(dl, c, x, y, w, 152, ACC, bg, brd, K)
    y = y + 152 + 10
    WK.tiles(dl, c, x, y, w, 74, ACC, bg, brd, K)
    y = y + 74 + 12
    if #c.dates == 0 then
        local eh = 130
        rhCardBox(dl, x, y, w, eh, bg, brd, 14)
        rhIconBadge(dl, x + w / 2, y + 40, 20, K.icon, K.col, bg, 0)
        local s1, s2 = imgui.CalcTextSize(K.empty), imgui.CalcTextSize(K.emptySub)
        dl:AddText(P(x + (w - s1.x) / 2, y + 74), 0xFFFFFFFF, K.empty)
        dl:AddText(P(x + (w - s2.x) / 2, y + 96), C.mute, K.emptySub)
        y = y + eh + 10
    else
        PD.nav(dl, c, x, y, w, 46, ACC, bg, brd)
        y = y + 46 + 12
        local ds = c.byDate[PD.sel] or PD.EMPTY
        if ds.count > 0 then
            WK.hours(dl, c, x, y, w, 108, ACC, bg, brd, K)
            y = y + 108 + 12
        end
        y = OIL.list(dl, c, x, y, w, ACC, bg, brd, K)
    end
    imgui.SetCursorScreenPos(P(x, y))
    imgui.Dummy(imgui.ImVec2(w, 6))
end
function OIL.draw()
    OIL.st = OIL.st or {}
    local st = OIL.st
    local s0, y0, m0 = PD.sel, PD.calY, PD.calM
    PD.sel, PD.calY, PD.calM = st.sel, st.calY, st.calM
    local ok, err = pcall(OIL.drawInner)
    st.sel, st.calY, st.calM = PD.sel, PD.calY, PD.calM
    PD.sel, PD.calY, PD.calM = s0, y0, m0
    if not ok then error(err, 0) end
end
function drawOilTab()
    oilWorkActive = true
    incassWorkActive = false
    OIL.sec = OIL.sec or {v = 0, last = 0}
    local sec = OIL.sec
    if os.clock() - sec.last > 0.4 then sec.v = 0 end
    sec.last = os.clock()
    local names = {u8("Меню"), u8("Обзор"), u8("Цены")}
    local map = {0, 3, 1}
    local curPos = 0
    for p, s in ipairs(map) do
        if s == sec.v then curPos = p - 1 end
    end
    local clicked = SegmentedTabs("oil", names, curPos)
    if clicked then sec.v = map[clicked + 1] end
    imgui.Spacing(); imgui.Separator(); imgui.Spacing()
    if sec.v == 0 then OIL.menu()
    elseif sec.v == 1 then OIL.prices()
    else OIL.draw() end
end
incomeGoalsPath = configDir .. "income_goals.json"
INCOME_GOAL_JOBS = {
    {key = "oil", icon = fa.ICON_FIRE, name = "нефтевышки"},
    {key = "taxi", icon = fa.ICON_TAXI, name = "такси"},
    {key = "incass", icon = fa.ICON_MONEY, name = "инкассатор"},
}
incomeGoals = {}
incomeGoalEdit = {}
function saveIncomeGoals()
    local data = {}
    for _, j in ipairs(INCOME_GOAL_JOBS) do
        local g = incomeGoals[j.key]
        if g then data[j.key] = {goal = g.goal, reachedDate = g.reachedDate or ""} end
    end
    local f = io.open(incomeGoalsPath, "w")
    if f then f:write(encodeJson(data)); f:close() end
end
function loadIncomeGoals()
    local data = {}
    local f = io.open(incomeGoalsPath, "r")
    if f then
        local content = f:read("*all")
        f:close()
        local ok, decoded = pcall(decodeJson, content)
        if ok and type(decoded) == "table" then data = decoded end
    end
    for _, j in ipairs(INCOME_GOAL_JOBS) do
        local d = data[j.key] or {}
        incomeGoals[j.key] = {goal = tonumber(d.goal) or 1000000, reachedDate = d.reachedDate or ""}
        incomeGoalEdit[j.key] = imgui.ImInt(incomeGoals[j.key].goal)
    end
end
function isIncomeGoalReached(key)
    local g = incomeGoals[key]
    return g ~= nil and g.reachedDate == getGameDate()
end
function checkIncomeGoals(dash)
    if not dash then return end
    local today = getGameDate()
    local changed = false
    for _, j in ipairs(INCOME_GOAL_JOBS) do
        local g = incomeGoals[j.key]
        local income = dash[j.key] or 0
        if g and g.goal > 0 and income >= g.goal and g.reachedDate ~= today then
            g.reachedDate = today
            changed = true
            playGoalSound()
            if settings.chatNotifyEnabled then
                sampAddChatMessage(SCRIPT_PREFIX .. "Цель по доходу (" .. j.name .. ") достигнута! " .. formatNumber(income) .. "$ / " .. formatNumber(g.goal) .. "$", SCRIPT_COLOR)
            end
        end
    end
    if changed then saveIncomeGoals() end
end
function rhHexToVec4(c, al)
    local r = c % 256
    local g = math.floor(c / 256) % 256
    local b = math.floor(c / 65536) % 256
    return imgui.ImVec4(r / 255, g / 255, b / 255, al or 1)
end
function rhDrawGoalBar(drawList, x, y, w, h, p, key, col)
    local function P(a, b) return imgui.ImVec2(a, b) end
    local ap = rhAnim(key, p, 8)
    local r = h / 2
    drawList:AddRectFilled(P(x, y), P(x + w, y + h), 0xFF101010, r)
    drawList:AddRect(P(x, y), P(x + w, y + h), 0xFF2A2A2A, r, 15, 1.0)
    if ap > 0.002 then
        local fw = math.max(h, w * ap)
        drawList:AddRectFilled(P(x - 1, y - 2), P(x + fw + 1, y + h + 2), rhAlpha(col, 0.12), r + 2)
        drawList:AddRectFilled(P(x, y), P(x + fw, y + h), col, r)
        drawList:PushClipRect(P(x, y), P(x + fw, y + h * 0.45), true)
        drawList:AddRectFilled(P(x, y), P(x + fw, y + h), rhAlpha(0xFFFFFFFF, 0.22), r)
        drawList:PopClipRect()
    end
    if h >= 8 then
        for i = 1, 3 do
            local tx = x + w * i / 4
            drawList:AddLine(P(tx, y + 2), P(tx, y + h - 2), rhAlpha(0xFF000000, 0.45), 1.0)
        end
    end
end
function rhStyledInput(id, var, step, stepFast, accentVec)
    local okBorder = pcall(function() imgui.PushStyleVar(imgui.StyleVar.FrameBorderSize, 1) end)
    imgui.PushStyleVar(imgui.StyleVar.FrameRounding, 8)
    imgui.PushStyleVar(imgui.StyleVar.FramePadding, imgui.ImVec2(10, 5))
    imgui.PushStyleColor(imgui.Col.FrameBg, imgui.ImVec4(0.115, 0.115, 0.12, 1))
    imgui.PushStyleColor(imgui.Col.FrameBgHovered, imgui.ImVec4(0.14, 0.14, 0.145, 1))
    imgui.PushStyleColor(imgui.Col.FrameBgActive, imgui.ImVec4(0.13 + accentVec.x * 0.07, 0.13 + accentVec.y * 0.07, 0.13 + accentVec.z * 0.07, 1))
    imgui.PushStyleColor(imgui.Col.Border, imgui.ImVec4(1, 1, 1, 0.07))
    imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(1, 1, 1, 0.06))
    imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(accentVec.x, accentVec.y, accentVec.z, 0.30))
    imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(accentVec.x, accentVec.y, accentVec.z, 0.50))
    imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.86, 0.86, 0.86, 1))
    local changed = imgui.InputInt(id, var, step, stepFast)
    imgui.PopStyleColor(8)
    imgui.PopStyleVar(okBorder and 3 or 2)
    return changed
end
function rhGoalButton(label, icon, width, accent, primary, uid)
    local key = uid or label
    local function P(a, b) return imgui.ImVec2(a, b) end
    local dl = imgui.GetWindowDrawList()
    local pos = imgui.GetCursorScreenPos()
    local w, h = width, 36
    imgui.InvisibleButton("##rhgb_" .. key, P(w, h))
    local clicked = imgui.IsItemClicked()
    local hov = imgui.IsItemHovered()
    local held = imgui.IsItemActive()
    local a = rhAnim("rhgb_" .. key, hov and 1 or 0)
    local baseBg = primary and rhAlpha(accent, 0.14) or 0xFF181818
    local hotBg = primary and rhAlpha(accent, 0.30) or 0xFF222222
    local bg = rhLerpColor(baseBg, hotBg, held and 1 or a)
    local border = rhLerpColor(primary and rhAlpha(accent, 0.60) or 0xFF2C2C2C, accent, a)
    local txtCol = primary and accent or rhLerpColor(0xFFB0B0B0, 0xFFFFFFFF, a)
    dl:AddRectFilled(pos, P(pos.x + w, pos.y + h), bg, 10)
    dl:AddRect(pos, P(pos.x + w, pos.y + h), border, 10, 15, 1.0)
    if primary then
        dl:AddLine(P(pos.x + 14, pos.y + 1), P(pos.x + w - 14, pos.y + 1), rhAlpha(0xFFFFFFFF, 0.10), 1.0)
    end
    local tsz = imgui.CalcTextSize(label)
    local isz = icon and imgui.CalcTextSize(icon) or P(0, 0)
    local gap = icon and 8 or 0
    local sx = pos.x + (w - (isz.x + gap + tsz.x)) / 2
    if icon then
        dl:AddText(P(sx, pos.y + (h - isz.y) / 2), txtCol, icon)
    end
    dl:AddText(P(sx + isz.x + gap, pos.y + (h - tsz.y) / 2), txtCol, label)
    return clicked
end
function rhGoalLabel(text)
    local dl = imgui.GetWindowDrawList()
    local pos = imgui.GetCursorScreenPos()
    local listW = imgui.GetWindowWidth() - 25
    local tsz = imgui.CalcTextSize(text)
    dl:AddText(imgui.ImVec2(pos.x + 4, pos.y + 4), rhDim(0xFF8A8A8A), text)
    dl:AddLine(imgui.ImVec2(pos.x + tsz.x + 16, pos.y + 4 + tsz.y / 2), imgui.ImVec2(pos.x + listW, pos.y + 4 + tsz.y / 2), rhTrack(0xFF262626), 1.0)
    imgui.Dummy(imgui.ImVec2(listW, tsz.y + 10))
end
function rhDrawHeroGoal(drawList, listW)
    local function P(a, b) return imgui.ImVec2(a, b) end
    local pos = imgui.GetCursorScreenPos()
    local x, y = pos.x, pos.y
    local cardH = 132
    local income = totalDailyIncome or 0
    local goal = settings.totalIncomeGoal or 0
    local p = goal > 0 and math.min(income / goal, 1.0) or 0
    local ap = rhAnim("hero_total", p, 8)
    local th = useCustomTheme and CUSTOM_THEME or (THEME_CONFIGS[currentTheme] or THEME_CONFIGS[THEMES.DEFAULT])
    local col = getColorHex(th.accent)
    local reached = totalIncomeGoalReached or (goal > 0 and income >= goal)
    drawList:AddRectFilled(P(x, y), P(x + listW, y + cardH), rhCB(0xFF151515), 14)
    drawList:AddRectFilled(P(x, y), P(x + listW, y + cardH), rhAlpha(col, 0.07), 14)
    drawList:AddLine(P(x + 16, y + 1), P(x + listW - 16, y + 1), rhAlpha(0xFFFFFFFF, 0.08), 1.0)
    drawList:AddRect(P(x, y), P(x + listW, y + cardH), rhLerpColor(rhCBR(0xFF2C2C2C), col, 0.45), 14, 15, 1.0)
    local ic = P(x + 42, y + 35)
    drawList:AddCircleFilled(ic, 27, rhAlpha(col, 0.06), 40)
    drawList:AddCircleFilled(ic, 22, rhAlpha(col, 0.18), 40)
    drawList:AddCircle(ic, 22, rhAlpha(col, 0.85), 40, 1.5)
    local isz = imgui.CalcTextSize(fa.ICON_BULLSEYE)
    drawList:AddText(P(ic.x - isz.x / 2, ic.y - isz.y / 2), col, fa.ICON_BULLSEYE)
    drawList:AddText(P(x + 82, y + 16), rhDim(0xFF8A8A8A), u8("Общая цель на сегодня"))
    local incStr = formatNumber(income) .. "$"
    drawList:AddText(P(x + 82, y + 38), 0xFFFFFFFF, incStr)
    local goalStr = "/ " .. formatNumber(goal) .. "$"
    local gx, gy = x + 82 + imgui.CalcTextSize(incStr).x + 8, y + 38
    local gsz = imgui.CalcTextSize(goalStr)
    local penIcon = fa.ICON_PENCIL_SQUARE_O
    local penW = imgui.CalcTextSize(penIcon).x
    imgui.SetCursorScreenPos(P(gx - 4, gy - 3))
    imgui.InvisibleButton("##hero_goal_edit", P(gsz.x + penW + 16, gsz.y + 6))
    local gHov = imgui.IsItemHovered()
    if imgui.IsItemClicked() then
        totalGoalEdit.v = settings.totalIncomeGoal
        imgui.OpenPopup("##hero_goal_popup")
    end
    local gAnim = rhAnim("hero_goal_hover", gHov and 1 or 0)
    drawList:AddText(P(gx, gy), rhLerpColor(0xFF71CC2E, 0xFFB0E68C, gAnim), goalStr)
    drawList:AddText(P(gx + gsz.x + 8, gy), rhAlpha(0xFF71CC2E, 0.35 + 0.65 * gAnim), penIcon)
    if gHov then
        drawList:AddLine(P(gx, gy + gsz.y + 1), P(gx + gsz.x, gy + gsz.y + 1), 0xFF71CC2E, 1.0)
        rhTip(u8("Нажмите, чтобы изменить цель"))
    end
    if imgui.BeginPopup("##hero_goal_popup") then
        imgui.TextColored(imgui.ImVec4(0.54, 0.54, 0.54, 1), u8("Цель общего дохода, $"))
        imgui.PushItemWidth(260)
        if rhStyledInput("##total_income_goal", totalGoalEdit, 100000, 1000000, rhHexToVec4(col)) then
            if totalGoalEdit.v >= 0 then settings.totalIncomeGoal = totalGoalEdit.v; totalIncomeGoalReached = false; saveTotalIncomeGoal() end
        end
        imgui.PopItemWidth()
        imgui.EndPopup()
    end
    local pctStr = goal > 0 and (math.floor(ap * 100 + 0.0001) .. "%") or "--"
    if rhBigFont then
        imgui.PushFont(rhBigFont)
        local psz = imgui.CalcTextSize(pctStr)
        imgui.SetCursorScreenPos(P(x + listW - psz.x - 22, y + 14))
        imgui.TextColored(rhHexToVec4(col), pctStr)
        imgui.PopFont()
    else
        imgui.SetWindowFontScale(2.0)
        local psz = imgui.CalcTextSize(pctStr)
        imgui.SetCursorScreenPos(P(x + listW - psz.x - 22, y + 14))
        imgui.TextColored(rhHexToVec4(col), pctStr)
        imgui.SetWindowFontScale(1.0)
    end
    rhDrawGoalBar(drawList, x + 18, y + 80, listW - 36, 14, p, "hero_total_bar", col)
    if goal <= 0 then
        drawList:AddText(P(x + 18, y + 106), 0xFF7A7A7A, u8("Цель выключена (значение 0)"))
    elseif reached then
        local ci = fa.ICON_CHECK_CIRCLE
        drawList:AddText(P(x + 18, y + 106), 0xFF71CC2E, ci)
        drawList:AddText(P(x + 18 + imgui.CalcTextSize(ci).x + 6, y + 106), 0xFF71CC2E, u8("Цель достигнута!"))
    else
        local lbl = u8("Осталось: ")
        drawList:AddText(P(x + 18, y + 106), rhDim(0xFF8A8A8A), lbl)
        drawList:AddText(P(x + 18 + imgui.CalcTextSize(lbl).x, y + 106), 0xFF20B0FF, formatNumber(goal - income) .. "$")
    end
    imgui.SetCursorScreenPos(P(x, y + cardH))
    imgui.Dummy(P(listW, 8))
end
RH_GOAL_JOB_STYLE = {
    oil = {title = "Нефтевышки", accent = 0xFFFA8BA7},
    taxi = {title = "Такси", accent = 0xFF15CCFA},
    incass = {title = "Инкассатор", accent = 0xFFF8BD38},
}
function rhDrawIncomeGoalCard(drawList, j, x, y, w, h)
    local function P(a, b) return imgui.ImVec2(a, b) end
    local st = RH_GOAL_JOB_STYLE[j.key] or {title = j.name, accent = 0xFF71CC2E}
    local g = incomeGoals[j.key]
    local income = (homeDashCache and homeDashCache[j.key]) or 0
    local p = g.goal > 0 and math.min(income / g.goal, 1.0) or 0
    local reached = isIncomeGoalReached(j.key) or (g.goal > 0 and income >= g.goal)
    local accent = st.accent
    local barCol = reached and 0xFF71CC2E or accent
    local mp = imgui.GetMousePos()
    local hov = mp.x >= x and mp.x <= x + w and mp.y >= y and mp.y <= y + h
    local a = rhAnim("gjob_" .. j.key, hov and 1 or 0)
    drawList:AddRectFilled(P(x, y), P(x + w, y + h), rhLerpColor(rhCB(0xFF181818), rhCBH(0xFF1F1F1F), a), 12)
    drawList:AddRect(P(x, y), P(x + w, y + h), rhLerpColor(rhCBR(0xFF2C2C2C), barCol, math.min(1, 0.25 + 0.5 * a + (reached and 0.25 or 0))), 12, 15, 1.0)
    local ic = P(x + 30, y + 30)
    drawList:AddCircleFilled(ic, 22, rhAlpha(accent, 0.05), 32)
    drawList:AddCircleFilled(ic, 16, rhAlpha(accent, 0.16), 32)
    drawList:AddCircle(ic, 16, rhAlpha(accent, 0.5 + 0.4 * a), 32, 1.0)
    local isz = imgui.CalcTextSize(j.icon)
    drawList:AddText(P(ic.x - isz.x / 2, ic.y - isz.y / 2), accent, j.icon)
    drawList:AddText(P(x + 56, y + 13), 0xFFFFFFFF, u8(st.title))
    if reached then
        drawList:AddText(P(x + 56, y + 30), 0xFF71CC2E, u8("Цель достигнута"))
    else
        drawList:AddText(P(x + 56, y + 30), 0xFF7A7A7A, u8("За сегодня"))
    end
    local pct = math.floor(p * 100) .. "%"
    drawList:AddText(P(x + w - imgui.CalcTextSize(pct).x - 14, y + 13), barCol, pct)
    local incStr = formatNumber(income) .. "$"
    local goalStr, gx, gCol
    if g.goal > 0 then
        drawList:AddText(P(x + 14, y + 52), 0xFFFFFFFF, incStr)
        goalStr = "/ " .. formatNumber(g.goal) .. "$"
        gx = x + 14 + imgui.CalcTextSize(incStr).x + 6
        gCol = accent
    else
        goalStr = u8("Цель выключена")
        gx = x + 14
        gCol = 0xFF7A7A7A
    end
    local gy = y + 52
    local gsz = imgui.CalcTextSize(goalStr)
    local penIcon = fa.ICON_PENCIL_SQUARE_O
    local penW = imgui.CalcTextSize(penIcon).x
    imgui.SetCursorScreenPos(P(gx - 4, gy - 3))
    imgui.InvisibleButton("##income_goal_btn_" .. j.key, P(gsz.x + penW + 16, gsz.y + 6))
    local gHov = imgui.IsItemHovered()
    if imgui.IsItemClicked() then
        incomeGoalEdit[j.key].v = g.goal
        imgui.OpenPopup("##income_goal_popup_" .. j.key)
    end
    local gAnim = rhAnim("gjobgoal_" .. j.key, gHov and 1 or 0)
    drawList:AddText(P(gx, gy), rhLerpColor(gCol, 0xFFFFFFFF, 0.45 * gAnim), goalStr)
    drawList:AddText(P(gx + gsz.x + 8, gy), rhAlpha(gCol, 0.35 + 0.65 * gAnim), penIcon)
    if gHov then
        drawList:AddLine(P(gx, gy + gsz.y + 1), P(gx + gsz.x, gy + gsz.y + 1), gCol, 1.0)
        rhTip(u8("Нажмите, чтобы изменить цель"))
    end
    if imgui.BeginPopup("##income_goal_popup_" .. j.key) then
        imgui.TextColored(imgui.ImVec4(0.54, 0.54, 0.54, 1), u8("Цель дохода: " .. st.title))
        imgui.PushItemWidth(260)
        if rhStyledInput("##income_goal_" .. j.key, incomeGoalEdit[j.key], 100000, 1000000, rhHexToVec4(accent)) then
            if incomeGoalEdit[j.key].v >= 0 then
                g.goal = incomeGoalEdit[j.key].v
                g.reachedDate = ""
                saveIncomeGoals()
            end
        end
        imgui.PopItemWidth()
        imgui.EndPopup()
    end
    rhDrawGoalBar(drawList, x + 14, y + 72, w - 28, 8, p, "gjobbar_" .. j.key, barCol)
end
function rhSaveResourceGoals(workType, order, editTbl, path)
    local saveData = {}
    for _, k in ipairs(order) do saveData[k] = editTbl[k].v end
    local f = io.open(path, "w")
    if f then f:write(encodeJson(saveData)); f:close() end
    if currentWork == workType then
        for _, k in ipairs(order) do
            goals[k] = editTbl[k].v
            if goalEdit[k] then goalEdit[k].v = editTbl[k].v end
        end
    end
end
function rhGoalGrid(idPrefix, order, names, curTbl, editTbl, accent, onChange)
    local function P(a, b) return imgui.ImVec2(a, b) end
    local drawList = imgui.GetWindowDrawList()
    local listW = imgui.GetWindowWidth() - 25
    local gap, cardH = 10, 98
    local cols = (listW >= 520) and 2 or 1
    local cardW = (listW - gap * (cols - 1)) / cols
    local start = imgui.GetCursorScreenPos()
    local accentVec = rhHexToVec4(accent)
    local mp = imgui.GetMousePos()
    for i, k in ipairs(order) do
        local x = start.x + ((i - 1) % cols) * (cardW + gap)
        local y = start.y + math.floor((i - 1) / cols) * (cardH + gap)
        local cur = curTbl[k] or 0
        local g = editTbl[k].v
        local p = g > 0 and math.min(cur / g, 1.0) or 0
        local done = g > 0 and cur >= g
        local barCol = done and 0xFF71CC2E or accent
        local hov = mp.x >= x and mp.x <= x + cardW and mp.y >= y and mp.y <= y + cardH
        local a = rhAnim("gres_" .. idPrefix .. k, hov and 1 or 0)
        drawList:AddRectFilled(P(x, y), P(x + cardW, y + cardH), rhLerpColor(rhCB(0xFF181818), rhCBH(0xFF1F1F1F), a), 12)
        drawList:AddRect(P(x, y), P(x + cardW, y + cardH), rhLerpColor(rhCBR(0xFF2C2C2C), barCol, math.min(1, (done and 0.55 or 0.15) + 0.4 * a)), 12, 15, 1.0)
        drawList:AddCircleFilled(P(x + 16, y + 20), 4, barCol, 12)
        drawList:AddText(P(x + 28, y + 12), 0xFFEDEDED, u8(names[k] or k))
        local pct = math.floor(p * 100) .. "%"
        local rx = x + cardW - 14
        if done then
            local ci = fa.ICON_CHECK_CIRCLE
            local cs = imgui.CalcTextSize(ci)
            drawList:AddText(P(rx - cs.x, y + 12), 0xFF71CC2E, ci)
            rx = rx - cs.x - 6
        end
        drawList:AddText(P(rx - imgui.CalcTextSize(pct).x, y + 12), barCol, pct)
        local curStr = formatNumber(cur)
        drawList:AddText(P(x + 14, y + 32), 0xFFFFFFFF, curStr)
        drawList:AddText(P(x + 14 + imgui.CalcTextSize(curStr).x + 6, y + 32), 0xFF7A7A7A, "/ " .. formatNumber(g))
        rhDrawGoalBar(drawList, x + 14, y + 52, cardW - 28, 8, p, "gresbar_" .. idPrefix .. k, barCol)
        imgui.SetCursorScreenPos(P(x + 14, y + 68))
        imgui.PushItemWidth(cardW - 28 - 66)
        if rhStyledInput("##goal_" .. idPrefix .. "_global_" .. k, editTbl[k], 10, 100, accentVec) then
            if editTbl[k].v > 0 and onChange then onChange() end
        end
        imgui.PopItemWidth()
    end
    local rows = math.ceil(#order / cols)
    imgui.SetCursorScreenPos(P(start.x, start.y + rows * (cardH + gap)))
    imgui.Dummy(P(listW, 1))
end
function drawGoalsTab()
    local drawList = imgui.GetWindowDrawList()
    local listW = imgui.GetWindowWidth() - 25
    local cardH = 46
    if not incomeGoals.oil then loadIncomeGoals() end
    if not homeDashCache then refreshHomeDashboard() end
    local function getCardColors()
        if useCustomTheme then
            return imVec4ToHex(CUSTOM_THEME.cardBg), imVec4ToHex(CUSTOM_THEME.cardBorder),
                   imVec4ToHex(CUSTOM_THEME.cardIcon), imVec4ToHex(CUSTOM_THEME.cardTitle)
        else
            return 0xFF1A1A1A, 0xFF333333, 0xFF1AE591, 0xFF1AE591
        end
    end
    -- Общая цель
    rhDrawHeroGoal(drawList, listW)
    if rhGoalButton(u8("Сбросить прогресс"), fa.ICON_REFRESH, listW, 0xFF4646EB, false) then totalIncomeGoalReached = false; totalDailyIncome = 0; totalIncomeCacheTime = 0; saveTotalIncomeGoal(); sampAddChatMessage(SCRIPT_PREFIX .. "Прогресс общей цели сброшен!", SCRIPT_COLOR) end
    imgui.Spacing()
    -- Цели по доходу: нефтевышки, такси, инкассатор
    rhGoalLabel(u8("Доход по работам"))
    local pos = imgui.GetCursorScreenPos()
    local jobH, gap = 96, 10
    local cols = (listW >= 600) and 3 or 1
    local cw = (listW - gap * (cols - 1)) / cols
    for i, j in ipairs(INCOME_GOAL_JOBS) do
        local ci = (i - 1) % cols
        local ri = math.floor((i - 1) / cols)
        rhDrawIncomeGoalCard(drawList, j, pos.x + ci * (cw + gap), pos.y + ri * (jobH + gap), cw, jobH)
    end
    local rows = math.ceil(#INCOME_GOAL_JOBS / cols)
    imgui.SetCursorScreenPos(imgui.ImVec2(pos.x, pos.y + rows * (jobH + gap)))
    imgui.Dummy(imgui.ImVec2(listW, 1))
    -- Цели по ресурсам: ферма, шахта, лесопилка
    rhGoalLabel(u8("Ресурсы по работам"))
    if not goalsExpandedRes then goalsExpandedRes = {} end
    local function resSection(id, icon, title, accent, bodyFn)
        local cardX, cardY = imgui.GetCursorScreenPos().x, imgui.GetCursorScreenPos().y
        local bgCol, borderCol, _, titleCol = getCardColors()
        drawSectionHeaderCard(drawList, cardX, cardY, listW, cardH, icon, title, bgCol, borderCol, accent, titleCol, goalsExpandedRes[id])
        imgui.SetCursorScreenPos(imgui.ImVec2(cardX, cardY))
        if imgui.InvisibleButton("##goals_res_" .. id, imgui.ImVec2(listW, cardH)) then goalsExpandedRes[id] = not goalsExpandedRes[id] end
        if goalsExpandedRes[id] then imgui.Spacing(); bodyFn(); imgui.Spacing() end
        imgui.Dummy(imgui.ImVec2(1, 2))
    end
    resSection("farm", fa.ICON_LEAF, u8("Ферма: ресурсы"), 0xFF1AE591, drawFarmGoals)
    resSection("mine", fa.ICON_GAVEL, u8("Шахта: ресурсы"), 0xFF28AAFF, drawMineGoals)
    resSection("saw", fa.ICON_TREE, u8("Лесопилка: ресурсы"), 0xFF99D334, drawSawmillGoals)
end
RH_ACH_CATS = {
    {key = "Ферма",       icon = fa.ICON_LEAF,          color = 0xFF1AE591},
    {key = "Шахта",       icon = fa.ICON_GAVEL,         color = 0xFF28AAFF},
    {key = "Лесопилка",   icon = fa.ICON_TREE,          color = 0xFF99D334},
    {key = "Нефть",       icon = fa.ICON_FIRE,          color = 0xFFFA8BA7},
    {key = "Такси",       icon = fa.ICON_TAXI,          color = 0xFF15CCFA},
    {key = "Инкассатор",  icon = fa.ICON_MONEY,         color = 0xFFF8BD38},
    {key = "Item Market", icon = fa.ICON_SHOPPING_CART, color = 0xFF6A5AF0},
    {key = "Общие",       icon = fa.ICON_BULLSEYE,      color = 0xFFD0D0D0},
}
rhAchWrapCache = rhAchWrapCache or {}
rhAchWrapCacheSize = rhAchWrapCacheSize or 0
function rhAchWrap(text, maxW, maxLines)
    local key = text .. "|" .. math.floor(maxW) .. "|" .. maxLines
    local cached = rhAchWrapCache[key]
    if cached then return cached end
    local lines, cur = {}, ""
    for word in text:gmatch("%S+") do
        local try = (cur == "") and word or (cur .. " " .. word)
        if cur == "" or imgui.CalcTextSize(try).x <= maxW then
            cur = try
        else
            table.insert(lines, cur)
            cur = word
        end
    end
    if cur ~= "" then table.insert(lines, cur) end
    if #lines > maxLines then
        local last = lines[maxLines]
        while imgui.CalcTextSize(last .. "...").x > maxW do
            local trimmed = last:match("^(.*)%s+%S+$")
            if not trimmed then break end
            last = trimmed
        end
        lines[maxLines] = last .. "..."
        for i = #lines, maxLines + 1, -1 do lines[i] = nil end
    end
    if rhAchWrapCacheSize > 300 then rhAchWrapCache = {}; rhAchWrapCacheSize = 0 end
    rhAchWrapCache[key] = lines
    rhAchWrapCacheSize = rhAchWrapCacheSize + 1
    return lines
end
function rhCompactNum(n)
    n = tonumber(n) or 0
    local a = math.abs(n)
    local function fmt(v, suffix)
        local s = string.format("%.2f", v)
        s = s:gsub("0+$", ""):gsub("%.$", "")
        return s .. suffix
    end
    if a >= 1e9 then return fmt(n / 1e9, u8(" млрд"))
    elseif a >= 1e6 then return fmt(n / 1e6, u8(" млн"))
    elseif a >= 1e4 then return fmt(n / 1e3, u8(" тыс."))
    end
    return formatNumber(math.floor(n))
end
-- ====== ВКЛАДКА ДОСТИЖЕНИЙ v2 ======
RH_ACH_RANKS = {
    {0.00, "Новичок"},
    {0.10, "Работяга"},
    {0.25, "Профи"},
    {0.45, "Мастер"},
    {0.70, "Легенда"},
    {1.00, "Абсолют"},
}
achStatusFilter = achStatusFilter or 0
function rhAchRank(frac)
    local cur, nxt = RH_ACH_RANKS[1], RH_ACH_RANKS[2]
    for i, r in ipairs(RH_ACH_RANKS) do
        if frac + 1e-9 >= r[1] then cur = r; nxt = RH_ACH_RANKS[i + 1] end
    end
    return cur, nxt
end
function rhAchPlural(n, a, b, c)
    local m10, m100 = n % 10, n % 100
    if m10 == 1 and m100 ~= 11 then return a end
    if m10 >= 2 and m10 <= 4 and (m100 < 12 or m100 > 14) then return b end
    return c
end
function drawAchievementsTab()
    local drawList = imgui.GetWindowDrawList()
    local listW = imgui.GetWindowWidth() - 25
    local mp = imgui.GetMousePos()
    local cp = imgui.GetCursorScreenPos()
    local x0, y = cp.x, cp.y
    local lineH = imgui.CalcTextSize("A").y
    local cats = RH_ACH_CATS
    local GREEN, ORANGE, GREY = 0xFF1AE591, 0xFF28AAFF, 0xFF808080

    local function P(a, b) return imgui.ImVec2(a, b) end
    local function inRect(rx, ry, rw, rh) return mp.x >= rx and mp.x <= rx + rw and mp.y >= ry and mp.y <= ry + rh end
    local function textW(t) return imgui.CalcTextSize(t).x end
    local function bold(tx, ty, col, t)
        drawList:AddText(P(tx, ty), col, t)
    end
    local function hit(id, bx, by, bw, bh)
        imgui.SetCursorScreenPos(P(bx, by))
        return imgui.InvisibleButton(id, imgui.ImVec2(bw, bh))
    end
    local function clipText(tx, ty, x1, col, t)
        drawList:PushClipRect(P(tx, ty - 2), P(x1, ty + lineH + 2), true)
        drawList:AddText(P(tx, ty), col, t)
        drawList:PopClipRect()
    end
    local function ring(cx, cy, r, th, frac, col)
        drawList:AddCircle(P(cx, cy), r, 0xFF2A2A2A, 64, th)
        if frac > 0 then
            local n = 96
            local filled = math.max(1, math.floor(frac * n + 0.5))
            local sa = -math.pi / 2
            for i = 0, filled - 1 do
                local a1 = sa + (i / n) * 2 * math.pi
                local a2 = sa + ((i + 1) / n) * 2 * math.pi
                drawList:AddLine(P(cx + math.cos(a1) * r, cy + math.sin(a1) * r),
                                 P(cx + math.cos(a2) * r, cy + math.sin(a2) * r), col, th)
            end
        end
    end
    local function surface(sx, sy, sw, sh, bg, border, rounding)
        drawList:AddRectFilled(P(sx, sy), P(sx + sw, sy + sh), bg, rounding)
        drawList:AddLine(P(sx + 14, sy + 1), P(sx + sw - 14, sy + 1), rhAlpha(0xFFFFFFFF, 0.05), 1.0)
        drawList:AddRect(P(sx, sy), P(sx + sw, sy + sh), border, rounding, 15, 1.0)
    end
    local function bar(bx, by, bw, bh, frac, col)
        drawList:AddRectFilled(P(bx, by), P(bx + bw, by + bh), 0xFF222222, bh / 2)
        if frac > 0 then
            drawList:AddRectFilled(P(bx, by), P(bx + math.max(bh, bw * frac), by + bh), col, bh / 2)
        end
    end
    local function pill(id, label, px, py, sel, accent)
        local w = textW(label) + 24
        local hov = inRect(px, py, w, 24)
        local ha = rhAnim("ach2p_" .. id, (hov or sel) and 1 or 0)
        local bg = sel and rhLerpColor(0xFF1A1A1A, accent, 0.18) or rhLerpColor(0xFF1A1A1A, 0xFF242424, ha)
        drawList:AddRectFilled(P(px, py), P(px + w, py + 24), bg, 12)
        drawList:AddRect(P(px, py), P(px + w, py + 24), sel and rhAlpha(accent, 0.7) or rhLerpColor(0xFF2C2C2C, 0xFF444444, ha), 12, 15, 1.0)
        drawList:AddText(P(px + 12, py + (24 - lineH) / 2), sel and accent or rhLerpColor(0xFF909090, 0xFFD0D0D0, ha), label)
        return hit("##ach2p_" .. id, px, py, w, 24)
    end
    local function sectionTitle(text, sy, accent)
        drawList:AddRectFilled(P(x0, sy + 2), P(x0 + 3, sy + lineH + 2), accent, 2)
        bold(x0 + 11, sy + 2, 0xFFFFFFFF, text)
    end
    local function unitOf(kind)
        local u = RH_ACH_UNITS[kind]
        return u and u8(u) or ""
    end

    local catDone, catTot = {}, {}
    local allDone, allTot, allStarted = 0, 0, 0
    local nearList = {}
    for _, a in ipairs(ACHIEVEMENTS) do
        local k = a.category
        catTot[k] = (catTot[k] or 0) + 1
        allTot = allTot + 1
        if a.completed then
            catDone[k] = (catDone[k] or 0) + 1
            allDone = allDone + 1
        else
            if (a.progress or 0) > 0 then allStarted = allStarted + 1 end
            if a.target > 0 then
                table.insert(nearList, { ach = a, p = math.min((a.progress or 0) / a.target, 1.0) })
            end
        end
    end
    table.sort(nearList, function(a, b) return a.p > b.p end)
    local accentOf, catByKey = {}, {}
    for i, c in ipairs(cats) do accentOf[c.key] = c.color; catByKey[c.key] = i end

    if allTot == 0 then
        drawList:AddText(P(x0 + 4, y + 10), 0xFF808080, u8("Список достижений загружается..."))
        imgui.SetCursorScreenPos(P(x0, y + 40))
        imgui.Dummy(imgui.ImVec2(listW, 4))
        return
    end

    local function drawCard(ach, cx, cy, cw, ch)
        local done = ach.completed
        local cur = ach.progress or 0
        local frac = done and 1.0 or math.min(cur / ach.target, 1.0)
        local accent = accentOf[ach.category] or GREEN
        local hov = inRect(cx, cy, cw, ch)
        local ha = rhAnim("ach2_" .. ach.id, hov and 1 or 0)
        local bg = rhLerpColor(0xFF181818, 0xFF1F1F1F, ha)
        if done then bg = rhLerpColor(bg, accent, 0.07) end
        surface(cx, cy, cw, ch, bg, rhLerpColor(0xFF2C2C2C, accent, done and (0.45 + 0.3 * ha) or (0.5 * ha)), 12)
        local ic = P(cx + 34, cy + 32)
        drawList:AddCircleFilled(ic, 18, rhLerpColor(bg, accent, done and 0.2 or 0.08), 32)
        drawList:AddCircle(ic, 18, rhAlpha(accent, done and 0.8 or 0.25), 32, 1.0)
        local isz = imgui.CalcTextSize(ach.icon)
        drawList:AddText(P(ic.x - isz.x / 2, ic.y - isz.y / 2), done and accent or rhLerpColor(0xFF555555, accent, 0.25), ach.icon)
        local tx = cx + 66
        clipText(tx, cy + 12, cx + cw - 14, done and 0xFFFFFFFF or 0xFFD8D8D8, u8(ach.name))
        local lines = rhAchWrap(u8(ach.desc), cw - 66 - 14, 2)
        drawList:PushClipRect(P(tx, cy), P(cx + cw - 14, cy + ch), true)
        for li, line in ipairs(lines) do
            drawList:AddText(P(tx, cy + 12 + lineH + 4 + (li - 1) * (lineH + 1)), 0xFF808080, line)
        end
        drawList:PopClipRect()
        local pct = math.floor(frac * 100)
        local leftText
        if done then leftText = u8("Выполнено")
        elseif pct == 0 and frac > 0 then leftText = "<1%"
        else leftText = pct .. "%" end
        local unit = unitOf(ach.kind)
        local rightText = (done and "" or (rhCompactNum(cur) .. " / ")) .. rhCompactNum(ach.target) .. unit
        local bx0, bx1 = cx + 14, cx + cw - 14
        local by = cy + ch - 18
        local rowY = by - lineH - 4
        drawList:AddText(P(bx0, rowY), done and accent or 0xFF8A8A8A, leftText)
        drawList:AddText(P(bx1 - textW(rightText), rowY), done and accent or 0xFFB0B0B0, rightText)
        bar(bx0, by, bx1 - bx0, 6, frac, accent)
    end

    local focusTipOn = false
    local function drawFocus(e, fx, fy, fw, fh)
        local ach = e.ach
        local accent = accentOf[ach.category] or GREEN
        local hov = inRect(fx, fy, fw, fh)
        local ha = rhAnim("ach2f_" .. ach.id, hov and 1 or 0)
        local bg = rhLerpColor(0xFF181818, 0xFF202020, ha)
        surface(fx, fy, fw, fh, bg, rhLerpColor(0xFF2C2C2C, accent, 0.6 * ha), 12)
        local ic = P(fx + 30, fy + 30)
        drawList:AddCircleFilled(ic, 17, rhLerpColor(bg, accent, 0.12), 32)
        drawList:AddCircle(ic, 17, rhAlpha(accent, 0.5), 32, 1.0)
        local isz = imgui.CalcTextSize(ach.icon)
        drawList:AddText(P(ic.x - isz.x / 2, ic.y - isz.y / 2), accent, ach.icon)
        local pc = math.floor(e.p * 100)
        local ptxt = (pc == 0 and e.p > 0) and "<1%" or (pc .. "%")
        local pw = textW(ptxt)
        bold(fx + fw - 12 - pw, fy + 12, accent, ptxt)
        clipText(fx + 58, fy + 12, fx + fw - 22 - pw, 0xFFE0E0E0, u8(ach.name))
        drawList:AddText(P(fx + 58, fy + 12 + lineH + 3), 0xFF808080,
            rhCompactNum(ach.progress or 0) .. " / " .. rhCompactNum(ach.target) .. unitOf(ach.kind))
        bar(fx + 58, fy + fh - 16, fw - 58 - 12, 5, e.p, accent)
        if hit("##ach2focus_" .. ach.id, fx, fy, fw, fh) then achView = catByKey[ach.category] or 0 end
        if hov then
            achTipLast = { ach = ach, x = fx, y = fy, w = fh and fw, h = fh }
            focusTipOn = true
        end
    end

    local function drawTile(i, tx, ty, tw, th)
        local c = cats[i]
        local dn, tt = catDone[c.key] or 0, catTot[c.key] or 0
        local frac = tt > 0 and (dn / tt) or 0
        local full = tt > 0 and dn == tt
        local hov = inRect(tx, ty, tw, th)
        local ha = rhAnim("ach2t_" .. i, hov and 1 or 0)
        local bg = rhLerpColor(0xFF181818, 0xFF202020, ha)
        if full then bg = rhLerpColor(bg, c.color, 0.08) end
        surface(tx, ty, tw, th, bg, rhLerpColor(0xFF2C2C2C, c.color, full and 0.55 or 0.6 * ha), 12)
        local ic = P(tx + 32, ty + 32)
        drawList:AddCircleFilled(ic, 18, rhLerpColor(bg, c.color, full and 0.22 or 0.1), 32)
        drawList:AddCircle(ic, 18, rhAlpha(c.color, full and 0.8 or 0.35), 32, 1.0)
        local isz = imgui.CalcTextSize(c.icon)
        drawList:AddText(P(ic.x - isz.x / 2, ic.y - isz.y / 2), c.color, c.icon)
        clipText(tx + 60, ty + 14, tx + tw - 10, 0xFFFFFFFF, u8(c.key))
        drawList:AddText(P(tx + 60, ty + 14 + lineH + 3), full and c.color or 0xFF808080, dn .. " / " .. tt)
        bar(tx + 14, ty + th - 20, tw - 28, 6, frac, c.color)
        if hit("##ach2tile_" .. i, tx, ty, tw, th) then achView = i end
    end

    local function drawFocusTip()
        local t = achTipLast
        if not t then return end
        local ach = t.ach
        local accent = accentOf[ach.category] or GREEN
        local cur = ach.progress or 0
        local frac = math.min(cur / ach.target, 1.0)
        local unit = unitOf(ach.kind)
        local pw = math.min(330, listW - 16)
        local pad = 16
        local descLines = rhAchWrap(u8(ach.desc), pw - pad * 2, 3)
        local headH = 56
        local rowH = lineH + 6
        local ph = headH + 6 + #descLines * (lineH + 2) + 10 + 6 + 14 + rowH * 3 + 12
        local tx = math.max(x0 + 4, math.min(t.x, x0 + listW - pw))
        local a, px, py = rhTipFrame(drawList, "ach2ftip", focusTipOn, pw, ph, accent, tx, t.y + t.h + 8, t.y - ph - 8)
        if not a then return end

        local ic = P(px + pad + 16, py + 30)
        drawList:AddCircleFilled(ic, 17, rhAlpha(rhLerpColor(0xFF141414, accent, 0.15), a), 32)
        drawList:AddCircle(ic, 17, rhAlpha(accent, 0.6 * a), 32, 1.0)
        local isz = imgui.CalcTextSize(ach.icon)
        drawList:AddText(P(ic.x - isz.x / 2, ic.y - isz.y / 2), rhAlpha(accent, a), ach.icon)

        local pc = math.floor(frac * 100)
        local ptxt = (pc == 0 and frac > 0) and "<1%" or (pc .. "%")
        local ptw = textW(ptxt)
        drawList:AddText(P(px + pw - pad - ptw, py + 14), rhAlpha(accent, a), ptxt)
        drawList:PushClipRect(P(px + 58, py), P(px + pw - pad - ptw - 8, py + headH), true)
        drawList:AddText(P(px + 58, py + 14), rhAlpha(0xFFFFFFFF, a), u8(ach.name))
        drawList:PopClipRect()
        drawList:AddText(P(px + 58, py + 14 + lineH + 2), rhAlpha(accent, 0.8 * a), u8(ach.category))
        drawList:AddLine(P(px + 14, py + headH - 2), P(px + pw - 14, py + headH - 2), rhAlpha(0xFF2A2A2A, a), 1.0)

        local cy = py + headH + 6
        for _, line in ipairs(descLines) do
            drawList:AddText(P(px + pad, cy), rhAlpha(0xFF9A9A9A, a), line)
            cy = cy + lineH + 2
        end
        cy = cy + 10
        drawList:AddRectFilled(P(px + pad, cy), P(px + pw - pad, cy + 6), rhAlpha(0xFF222222, a), 3)
        if frac > 0 then
            drawList:AddRectFilled(P(px + pad, cy), P(px + pad + math.max(6, (pw - pad * 2) * frac), cy + 6), rhAlpha(accent, a), 3)
        end
        cy = cy + 6 + 14
        local rows = {
            { u8("Сейчас"), formatNumber(cur) .. unit, 0xFFE0E0E0 },
            { u8("Цель"), formatNumber(ach.target) .. unit, 0xFFE0E0E0 },
            { u8("Осталось"), formatNumber(math.max(0, ach.target - cur)) .. unit, accent },
        }
        for _, r in ipairs(rows) do
            drawList:AddText(P(px + pad, cy), rhAlpha(0xFF808080, a), r[1])
            drawList:AddText(P(px + pw - pad - textW(r[2]), cy), rhAlpha(r[3], a), r[2])
            cy = cy + rowH
        end
    end

    local rankTip, rankAnchorY = false, 0
    local function drawRankTip()
        local frac = allDone / allTot
        local curRank = rhAchRank(frac)
        local pw = math.min(310, listW - 16)
        local rowH, headH, footH = 30, 56, 36
        local ph = headH + #RH_ACH_RANKS * rowH + footH
        local a, px, py = rhTipFrame(drawList, "ach2rank", rankTip, pw, ph, GREEN, x0 + 12, rankAnchorY)
        if not a then return end
        drawList:AddText(P(px + 16, py + 12), rhAlpha(0xFFFFFFFF, a), u8("Звания"))
        drawList:AddText(P(px + 16, py + 12 + lineH + 2), rhAlpha(0xFF808080, a), u8("зависят от доли выполненных достижений"))
        drawList:AddLine(P(px + 14, py + headH - 6), P(px + pw - 14, py + headH - 6), rhAlpha(0xFF2A2A2A, a), 1.0)

        for i, r in ipairs(RH_ACH_RANKS) do
            local ry = py + headH + (i - 1) * rowH
            local isCur = (r == curRank)
            local reached = frac + 1e-9 >= r[1]
            if isCur then
                drawList:AddRectFilled(P(px + 8, ry + 1), P(px + pw - 8, ry + rowH - 1), rhAlpha(GREEN, 0.12 * a), 8)
            end
            local dx, dy = px + 24, ry + rowH / 2
            if reached then
                drawList:AddCircleFilled(P(dx, dy), 5, rhAlpha(GREEN, a), 16)
                if isCur then drawList:AddCircle(P(dx, dy), 8, rhAlpha(GREEN, 0.6 * a), 20, 1.0) end
            else
                drawList:AddCircle(P(dx, dy), 5, rhAlpha(0xFF555555, a), 16, 1.5)
            end
            local nameCol = isCur and 0xFFFFFFFF or (reached and 0xFFC0C0C0 or 0xFF707070)
            drawList:AddText(P(px + 42, dy - lineH / 2), rhAlpha(nameCol, a), u8(r[2]))
            local req
            if r[1] <= 0 then
                req = u8("старт")
            else
                local need = math.ceil(r[1] * allTot - 1e-9)
                req = u8(need .. " " .. rhAchPlural(need, "достижение", "достижения", "достижений"))
            end
            local reqCol = isCur and GREEN or (reached and 0xFF808080 or 0xFF606060)
            drawList:AddText(P(px + pw - 16 - textW(req), dy - lineH / 2), rhAlpha(reqCol, a), req)
        end

        local fy = py + ph - footH
        drawList:AddLine(P(px + 14, fy + 2), P(px + pw - 14, fy + 2), rhAlpha(0xFF2A2A2A, a), 1.0)
        drawList:AddText(P(px + 16, fy + 11), rhAlpha(0xFF808080, a),
            u8("Выполнено ") .. allDone .. " / " .. allTot .. " (" .. math.floor(frac * 100) .. "%)")
    end

    local function drawOverview()
        local frac = allDone / allTot
        local rank, nextRank = rhAchRank(frac)
        local heroH = 120
        surface(x0, y, listW, heroH, rhLerpColor(0xFF181818, GREEN, 0.04), 0xFF2C2C2C, 14)
        ring(x0 + 66, y + heroH / 2, 40, 8, frac, GREEN)
        local pt = math.floor(frac * 100) .. "%"
        bold(x0 + 66 - textW(pt) / 2, y + heroH / 2 - lineH / 2, GREEN, pt)
        local tx = x0 + 136
        drawList:AddText(P(tx, y + 18), 0xFF707070, u8("Ваше звание"))
        local rankName = u8(rank[2])
        bold(tx, y + 18 + lineH + 3, GREEN, rankName)
        rankTip = inRect(x0, y, 380, heroH)
        rankAnchorY = y + heroH + 8
        local qx, qy = tx + textW(rankName) + 14, y + 18 + lineH + 3 + lineH / 2
        local qa = rankTip and 1 or 0.45
        drawList:AddCircle(P(qx, qy), 7, rhAlpha(GREEN, qa * 0.8), 20, 1.0)
        drawList:AddText(P(qx - textW("?") / 2, qy - lineH / 2), rhAlpha(GREEN, qa), "?")
        local hintY = y + 18 + (lineH + 3) * 2 + 4
        if nextRank then
            local need = math.max(1, math.ceil(nextRank[1] * allTot - 1e-9) - allDone)
            local rf = (frac - rank[1]) / (nextRank[1] - rank[1])
            drawList:AddText(P(tx, hintY), 0xFF808080,
                u8("До «" .. nextRank[2] .. "»: ещё " .. need .. " " .. rhAchPlural(need, "достижение", "достижения", "достижений")))
            bar(tx, y + heroH - 30, 230, 6, math.max(0, math.min(rf, 1)), GREEN)
        else
            drawList:AddText(P(tx, hintY), 0xFF808080, u8("Максимальное звание"))
            bar(tx, y + heroH - 30, 230, 6, 1, GREEN)
        end
        if listW >= 640 then
            local items = {
                { allDone, u8("Выполнено"), GREEN },
                { allStarted, u8("В процессе"), ORANGE },
                { allTot - allDone - allStarted, u8("Не начато"), GREY },
            }
            local colW = 96
            local sx = x0 + listW - colW * 3 - 12
            for j, it in ipairs(items) do
                local bx = sx + (j - 1) * colW
                if j > 1 then drawList:AddLine(P(bx - 8, y + 30), P(bx - 8, y + heroH - 30), 0xFF2A2A2A, 1.0) end
                bold(bx, y + 36, it[3], tostring(it[1]))
                drawList:AddText(P(bx, y + 36 + lineH + 4), 0xFF808080, it[2])
            end
        end
        y = y + heroH + 18

        if #nearList > 0 then
            local ft = u8("В фокусе")
            sectionTitle(ft, y, GREEN)
            drawList:AddText(P(x0 + 11 + textW(ft) + 12, y + 2), 0xFF606060, u8("ближе всего к выполнению"))
            y = y + lineH + 14
            local fcols = math.min(#nearList, listW >= 640 and 3 or (listW >= 420 and 2 or 1))
            local fgap = 10
            local fw = (listW - fgap * (fcols - 1)) / fcols
            local fh = 74
            for i = 1, fcols do
                drawFocus(nearList[i], x0 + (i - 1) * (fw + fgap), y, fw, fh)
            end
            y = y + fh + 22
        end

        sectionTitle(u8("Категории"), y, GREEN)
        local allLabel = u8("Все достижения")
        local pw = textW(allLabel) + 24
        if pill("all", allLabel, x0 + listW - pw, y - 3, false, GREEN) then achView = 0 end
        y = y + lineH + 16
        local tcols = listW >= 700 and 4 or (listW >= 460 and 3 or 2)
        local tgap = 10
        local tw = (listW - tgap * (tcols - 1)) / tcols
        local th = 92
        for i = 1, #cats do
            local col = (i - 1) % tcols
            local row = math.floor((i - 1) / tcols)
            drawTile(i, x0 + col * (tw + tgap), y + row * (th + tgap), tw, th)
        end
        y = y + math.ceil(#cats / tcols) * (th + tgap)
    end

    local function drawDetail()
        local isAll = (achView == 0)
        local c = (not isAll) and cats[achView] or nil
        local accent = isAll and GREEN or c.color
        local title = isAll and "Все достижения" or c.key
        local dn = isAll and allDone or (catDone[c.key] or 0)
        local tt = isAll and allTot or (catTot[c.key] or 0)

        if pill("back", "<  " .. u8("Назад"), x0, y, false, accent) then achView = nil end
        local labels = {
            u8("Все") .. "  " .. tt,
            u8("Осталось") .. "  " .. (tt - dn),
            u8("Готово") .. "  " .. dn,
        }
        local ws, total = {}, 0
        for i, l in ipairs(labels) do
            ws[i] = textW(l) + 24
            total = total + ws[i] + (i > 1 and 6 or 0)
        end
        local px = x0 + listW - total
        for i, l in ipairs(labels) do
            if pill("st" .. i, l, px, y, achStatusFilter == i - 1, accent) then achStatusFilter = i - 1 end
            px = px + ws[i] + 6
        end
        y = y + 24 + 10

        local hh = 62
        surface(x0, y, listW, hh, rhLerpColor(0xFF181818, accent, 0.05), rhAlpha(accent, 0.35), 14)
        local icx, icy = x0 + 34, y + hh / 2 - 4
        drawList:AddCircleFilled(P(icx, icy), 18, rhLerpColor(0xFF181818, accent, 0.18), 32)
        drawList:AddCircle(P(icx, icy), 18, rhAlpha(accent, 0.8), 32, 1.0)
        local gi = isAll and fa.ICON_STAR or c.icon
        local gsz = imgui.CalcTextSize(gi)
        drawList:AddText(P(icx - gsz.x / 2, icy - gsz.y / 2), accent, gi)
        bold(x0 + 64, y + 10, 0xFFFFFFFF, u8(title))
        drawList:AddText(P(x0 + 64, y + 10 + lineH + 3), 0xFF808080, dn .. u8(" из ") .. tt .. u8(" выполнено"))
        local pc = (tt > 0 and math.floor(dn / tt * 100) or 0) .. "%"
        bold(x0 + listW - 16 - textW(pc), y + 10, accent, pc)
        bar(x0 + 64, y + hh - 14, listW - 64 - 16, 6, tt > 0 and (dn / tt) or 0, accent)
        y = y + hh + 14

        local gcols = listW >= 620 and 2 or 1
        local ggap = 10
        local cw = (listW - ggap * (gcols - 1)) / gcols
        local ch = 108
        local function pick(catKey)
            local out = {}
            for _, a in ipairs(ACHIEVEMENTS) do
                if catKey == nil or a.category == catKey then
                    local ok = achStatusFilter == 0 or (achStatusFilter == 1 and not a.completed) or (achStatusFilter == 2 and a.completed)
                    if ok then table.insert(out, a) end
                end
            end
            table.sort(out, function(a, b)
                if a.completed ~= b.completed then return not a.completed end
                return (a.progress or 0) / a.target > (b.progress or 0) / b.target
            end)
            return out
        end
        local function grid(list)
            local col, row = 0, 0
            for _, a in ipairs(list) do
                drawCard(a, x0 + col * (cw + ggap), y + row * (ch + ggap), cw, ch)
                col = col + 1
                if col >= gcols then col = 0; row = row + 1 end
            end
            y = y + (row + (col > 0 and 1 or 0)) * (ch + ggap)
        end

        local shown = 0
        if isAll then
            for _, cc in ipairs(cats) do
                local list = pick(cc.key)
                if #list > 0 then
                    shown = shown + #list
                    drawList:AddText(P(x0 + 2, y + 1), cc.color, cc.icon)
                    bold(x0 + 28, y + 1, 0xFFFFFFFF, u8(cc.key))
                    drawList:AddText(P(x0 + 28 + textW(u8(cc.key)) + 12, y + 1), 0xFF606060, (catDone[cc.key] or 0) .. " / " .. (catTot[cc.key] or 0))
                    y = y + lineH + 12
                    grid(list)
                    y = y + 6
                end
            end
        else
            local list = pick(c.key)
            shown = #list
            grid(list)
        end
        if shown == 0 then
            local msg = u8("Здесь пока ничего нет")
            drawList:AddText(P(x0 + (listW - textW(msg)) / 2, y + 24), 0xFF606060, msg)
            y = y + 70
        end
    end

    if achView ~= nil and achView ~= 0 and not cats[achView] then achView = nil end
    if achView ~= achViewPrev then
        achViewPrev = achView
        pcall(function() imgui.SetScrollY(0) end)
    end
    if achView == nil then
        drawOverview()
        drawRankTip()
        drawFocusTip()
    else
        drawDetail()
    end
    imgui.SetCursorScreenPos(P(x0, y))
    imgui.Dummy(imgui.ImVec2(listW, 8))
end
ABOUT = ABOUT or {}
ABOUT.reqAt = ABOUT.reqAt or -100
ABOUT.checkAt = ABOUT.checkAt or -100
ABOUT.open = ABOUT.open or {}
ABOUT.enc = ABOUT.enc or {}
ABOUT.list = ABOUT.list or {}
ABOUT.inited = ABOUT.inited or false
function ABOUT.url(link)
    shell32.ShellExecuteA(nil, "open", link, nil, nil, 0)
end
function ABOUT.tip(text)
    rhTipBegin()
    imgui.Text(text)
    rhTipEnd()
end
function ABOUT.hit(id, x, y, w, h)
    imgui.SetCursorScreenPos(imgui.ImVec2(x, y))
    local clicked = imgui.InvisibleButton(id, imgui.ImVec2(w, h))
    local hov = imgui.IsItemHovered()
    return clicked, rhAnim(id, hov and 1 or 0), hov
end
function ABOUT.verKey(v)
    local t = {}
    for n in tostring(v):gmatch("%d+") do t[#t + 1] = tonumber(n) end
    return t
end
function ABOUT.verCmp(a, b)
    local x, y = ABOUT.verKey(a), ABOUT.verKey(b)
    for i = 1, math.max(#x, #y) do
        local p, q = x[i] or 0, y[i] or 0
        if p ~= q then return p > q end
    end
    return tostring(a) > tostring(b)
end
function ABOUT.versions()
    if ABOUT.srcRef ~= changelogData then
        ABOUT.srcRef = changelogData
        local list = {}
        if changelogData then
            for ver, items in pairs(changelogData) do
                if type(items) == "table" then list[#list + 1] = ver end
            end
            table.sort(list, ABOUT.verCmp)
        end
        ABOUT.list = list
    end
    return ABOUT.list
end
function ABOUT.linkList()
    if not ABOUT.L then
        ABOUT.L = {
            {icon = fa.ICON_PAPER_PLANE, title = "Telegram", desc = u8("Связь и идеи"), col = 0xFFEEAB2A,
             url = "https://t.me/RyderNakata", tip = u8("Связь в случае возникновения проблем или для предложений.")},
            {icon = fa.ICON_COMMENT, title = "VK", desc = u8("Запасная связь"), col = 0xFFA3754C,
             url = "https://vk.com/ryder.nakata", tip = u8("Альтернативная связь в случае возникновения проблем или для предложений.")},
            {icon = fa.ICON_COMMENT, title = "BlastHack", desc = u8("Тема со всем функционалом"), col = 0xFF4D8CFF,
             url = "https://www.blast.hk/threads/254420/post-1678762", tip = u8("Основная тема со всем функционалом. Буду рад лайку и коменту в теме для продвижения.")},
            {icon = fa.ICON_COMMENT, title = "GitHub", desc = u8("Файлы и версии"), col = 0xFFE6E6E6,
             url = "https://github.com/Ryder8471/ArzResHelper", tip = u8("Основные файлы и все новые версии.")},
        }
    end
    return ABOUT.L
end
function ABOUT.hero(dl, x, y, w)
    local P, C = imgui.ImVec2, PD.C
    local bg, brd, acc = homeCardColors()
    local h = 112
    local hasUpd = (newversion ~= "" and newversion ~= scr.version)
    local nd = newdate and tostring(newdate) or ""
    local cx, cy = x + 56, y + h / 2
    rhCardBox(dl, x, y, w, h, bg, brd, 14)
    dl:AddRectFilled(P(x + 4, y + 3), P(x + w - 4, y + h - 3), rhAlpha(hasUpd and C.gold or acc, 0.04), 11)
    dl:PushClipRect(P(x, y), P(x + w, y + h), true)
    dl:AddCircle(P(cx, cy), 44, rhAlpha(acc, 0.10), 48, 1.0)
    dl:AddCircle(P(cx, cy), 64, rhAlpha(acc, 0.05), 48, 1.0)
    dl:PopClipRect()
    rhIconBadge(dl, cx, cy, 28, fa.ICON_WRENCH, acc, bg, 0)
    local tx = x + 106
    local bw, bh = 210, 40
    local bx, by = x + w - 16 - bw, y + (h - bh) / 2
    dl:PushClipRect(P(tx, y), P(bx - 12, y + h), true)
    local title = u8("Resource Helper")
    dl:AddText(P(tx, y + 16), 0xFFFFFFFF, title)
    dl:AddText(P(tx + 1, y + 16), 0xFFFFFFFF, title)
    local sub = u8("Помощник по работам и доходу • Arizona RP")
    if hasUpd then
        sub = u8("Вышла новая версия" .. (nd ~= "" and (" • " .. nd) or ""))
    end
    dl:AddText(P(tx, y + 41), C.mute, sub)
    local px, py = tx, y + 72
    px = px + rhPill(dl, px, py, u8("v" .. scr.version), acc) + 8
    local stTxt, stCol
    if newversion == "" then
        stTxt, stCol = u8("Обновления не проверялись"), C.mute
    elseif hasUpd then
        stTxt, stCol = u8("Доступна v" .. newversion), C.gold
    else
        stTxt, stCol = u8("Актуальная версия"), C.green
    end
    px = px + rhPill(dl, px, py, stTxt, stCol) + 8
    if w >= 640 then rhPill(dl, px, py, u8("Ресурсы " .. RESOURCE_VERSION), C.mute) end
    dl:PopClipRect()
    if hasUpd then
        if WK.button(dl, "##about_upd", bx, by, bw, bh, u8("Обновить до v" .. newversion), fa.ICON_DOWNLOAD, C.gold, true) then
            updateScript()
        end
    else
        local checking = (os.clock() - ABOUT.checkAt) < 4
        if WK.button(dl, "##about_chk", bx, by, bw, bh, checking and u8("Проверяю...") or u8("Проверить обновления"), fa.ICON_REFRESH, acc, false, checking) then
            ABOUT.checkAt = os.clock()
            updateCheck()
        end
    end
    return h
end
function ABOUT.dev(dl, x, y, w)
    local P, C = imgui.ImVec2, PD.C
    local bg, brd, acc = homeCardColors()
    local h = 72
    local clicked, a, hov = ABOUT.hit("##about_dev", x, y, w, h)
    rhCardBox(dl, x, y, w, h, rhLerpColor(bg, 0xFFFFFFFF, 0.03 * a), rhLerpColor(brd, acc, 0.6 * a), 12)
    rhIconBadge(dl, x + 38, y + h / 2, 21, fa.ICON_USER, acc, bg, a)
    local tx = x + 76
    local name = u8("Ryder_Nakata")
    local nw = imgui.CalcTextSize(name).x
    dl:AddText(P(tx, y + 15), 0xFFFFFFFF, name)
    local srv = "Drake"
    local icon = getServerIcon(srv)
    local sw = imgui.CalcTextSize(srv).x
    local badgeW = 10 + (icon and 22 or 0) + sw + 10
    local bx = tx + nw + 10
    dl:AddRectFilled(P(bx, y + 14), P(bx + badgeW, y + 32), 0xFF262626, 5)
    local ix = bx + 10
    if icon then
        dl:AddImage(icon, P(ix, y + 15), P(ix + 16, y + 31))
        ix = ix + 22
    end
    dl:AddText(P(ix, y + 16), 0xFF999999, srv)
    dl:AddText(P(tx, y + 41), C.mute, u8("Разработчик скрипта"))
    if w >= 520 then
        local t = fa.ICON_PAPER_PLANE .. "  " .. u8("Канал с новостями")
        local pw = imgui.CalcTextSize(t).x + 20
        rhPill(dl, x + w - pw - 16, y + (h - 22) / 2, t, acc)
    end
    if hov then ABOUT.tip(u8("Открыть Telegram-канал разработчика с новостями")) end
    if clicked then ABOUT.url("https://t.me/palatkaryder") end
    return h
end
function ABOUT.links(dl, x, y, w)
    local P, C = imgui.ImVec2, PD.C
    local bg, brd = homeCardColors()
    local L = ABOUT.linkList()
    local cols = (w >= 640) and 4 or 2
    local gap, th = 10, 66
    local tw = (w - gap * (cols - 1)) / cols
    local rows = math.ceil(#L / cols)
    for i, it in ipairs(L) do
        local cx = x + ((i - 1) % cols) * (tw + gap)
        local cy = y + math.floor((i - 1) / cols) * (th + gap)
        local clicked, a, hov = ABOUT.hit("##about_link" .. i, cx, cy, tw, th)
        rhCardBox(dl, cx, cy, tw, th, rhLerpColor(bg, 0xFFFFFFFF, 0.04 * a), rhLerpColor(brd, it.col, 0.7 * a), 12)
        rhIconBadge(dl, cx + 30, cy + th / 2, 16, it.icon, it.col, bg, a)
        dl:PushClipRect(P(cx + 54, cy), P(cx + tw - 8, cy + th), true)
        dl:AddText(P(cx + 54, cy + th / 2 - 18), 0xFFFFFFFF, it.title)
        dl:AddText(P(cx + 54, cy + th / 2 + 2), C.mute, it.desc)
        dl:PopClipRect()
        if hov then ABOUT.tip(it.tip) end
        if clicked then ABOUT.url(it.url) end
    end
    return rows * th + (rows - 1) * gap
end
function ABOUT.changelog(dl, x, y, w)
    local P, C = imgui.ImVec2, PD.C
    local bg, brd, acc = homeCardColors()
    local list = ABOUT.versions()
    local cy = y
    local hh = 52
    rhCardBox(dl, x, cy, w, hh, bg, brd, 12)
    rhIconBadge(dl, x + 30, cy + hh / 2, 15, fa.ICON_LIST, acc, bg, 0)
    dl:AddText(P(x + 60, cy + 9), 0xFFFFFFFF, u8("История версий"))
    dl:AddText(P(x + 60, cy + 29), C.mute, u8("Что менялось от релиза к релизу"))
    if #list > 0 then
        local t = u8(#list .. " " .. PD.plural(#list, {"версия", "версии", "версий"}))
        rhPill(dl, x + w - (imgui.CalcTextSize(t).x + 20) - 14, cy + (hh - 22) / 2, t, acc)
    end
    cy = cy + hh + 10
    if #list == 0 then
        local bh = 76
        rhCardBox(dl, x, cy, w, bh, bg, brd, 12)
        if (os.clock() - ABOUT.reqAt) <= 12 then
            local dots = string.rep(".", math.floor(os.clock() * 2) % 4)
            dl:AddText(P(x + 20, cy + bh / 2 - 8), C.mute, u8("Загружаю историю версий") .. dots)
        else
            dl:AddText(P(x + 20, cy + bh / 2 - 8), C.mute, u8("Не удалось загрузить список изменений"))
            if WK.button(dl, "##about_retry", x + w - 150 - 14, cy + (bh - 34) / 2, 150, 34, u8("Повторить"), fa.ICON_REFRESH, acc, false) then
                ABOUT.reqAt = -100
            end
        end
        return (cy + bh) - y
    end
    local gut = 40
    local rx, rw = x + gut, w - gut
    local lineH = imgui.CalcTextSize("Ag").y + 3
    local tsz = imgui.CalcTextSize("Ag").y
    local textW = rw - 52
    local hdrH = 44
    local bodies, heights = {}, {}
    local total = 0
    for i, ver in ipairs(list) do
        local hgt = hdrH
        if ABOUT.open[ver] then
            local lines, bh = {}, 0
            for _, ch in ipairs(changelogData[ver]) do
                local s = ABOUT.enc[ch]
                if not s then
                    s = u8(tostring(ch))
                    ABOUT.enc[ch] = s
                end
                local ls = rhWrapLines(s, textW)
                lines[#lines + 1] = ls
                bh = bh + #ls * lineH + 6
            end
            bodies[i] = lines
            hgt = hdrH + bh + 14
        end
        heights[i] = hgt
        total = total + hgt + (i < #list and 8 or 0)
    end
    local lx = x + 16
    local lastTop = cy + total - heights[#list]
    dl:AddLine(P(lx, cy + hdrH / 2), P(lx, lastTop + hdrH / 2), rhAlpha(acc, 0.22), 2.0)
    local ry = cy
    for i, ver in ipairs(list) do
        local isCur = (ver == scr.version)
        local isNew = (not isCur) and ABOUT.verCmp(ver, scr.version)
        local col = isCur and acc or (isNew and C.gold or C.mute)
        local open = ABOUT.open[ver]
        local clicked, a = ABOUT.hit("##about_ver_" .. ver, rx, ry, rw, hdrH)
        local bAmt = math.max(open and 0.45 or 0, 0.6 * a)
        rhCardBox(dl, rx, ry, rw, heights[i], rhLerpColor(bg, 0xFFFFFFFF, 0.03 * a), rhLerpColor(brd, col, bAmt), 12)
        local dy = ry + hdrH / 2
        dl:AddCircleFilled(P(lx, dy), 9, bg, 20)
        if isCur then dl:AddCircleFilled(P(lx, dy), 9, rhAlpha(col, 0.25), 20) end
        dl:AddCircle(P(lx, dy), 9, rhAlpha(col, 0.55), 20, 1.5)
        dl:AddCircleFilled(P(lx, dy), 4, col, 16)
        local vt = u8("v" .. ver)
        local vx = rx + 16
        dl:AddText(P(vx, dy - tsz / 2), (isCur or isNew) and 0xFFFFFFFF or 0xFFCCCCCC, vt)
        local px = vx + imgui.CalcTextSize(vt).x + 10
        if isCur then rhPill(dl, px, dy - 11, u8("ТЕКУЩАЯ"), acc)
        elseif isNew then rhPill(dl, px, dy - 11, u8("НОВАЯ"), C.gold) end
        local chev = open and fa.ICON_ANGLE_UP or fa.ICON_ANGLE_DOWN
        local csz = imgui.CalcTextSize(chev)
        dl:AddText(P(rx + rw - 16 - csz.x, dy - csz.y / 2), C.mute, chev)
        local cnt = u8(#changelogData[ver] .. " изм.")
        local cntW = imgui.CalcTextSize(cnt).x
        dl:AddText(P(rx + rw - 16 - csz.x - 14 - cntW, dy - tsz / 2), C.dim, cnt)
        if open then
            dl:AddLine(P(rx + 14, ry + hdrH), P(rx + rw - 14, ry + hdrH), rhAlpha(0xFFFFFFFF, 0.06), 1.0)
            local ly = ry + hdrH + 12
            for _, ls in ipairs(bodies[i]) do
                dl:AddCircleFilled(P(rx + 22, ly + lineH / 2 - 1), 3, rhAlpha(col, 0.9), 12)
                for k, line in ipairs(ls) do
                    dl:AddText(P(rx + 38, ly + (k - 1) * lineH), 0xFFDDDDDD, line)
                end
                ly = ly + #ls * lineH + 6
            end
        end
        if clicked then ABOUT.open[ver] = not open end
        ry = ry + heights[i] + 8
    end
    return (cy + total) - y
end
function drawAboutTab()
    local dl = imgui.GetWindowDrawList()
    local w = imgui.GetWindowWidth() - 25
    if not changelogData and ABOUT.reqAt < 0 then
        ABOUT.reqAt = os.clock()
        downloadChangelog()
    end
    if changelogData and not ABOUT.inited then
        local list = ABOUT.versions()
        if #list > 0 then
            ABOUT.open[changelogData[scr.version] and scr.version or list[1]] = true
            ABOUT.inited = true
        end
    end
    imgui.Dummy(imgui.ImVec2(1, 2))
    local pos = imgui.GetCursorScreenPos()
    local x, cy = pos.x, pos.y
    cy = cy + ABOUT.hero(dl, x, cy, w) + 12
    cy = cy + ABOUT.dev(dl, x, cy, w) + 12
    cy = cy + ABOUT.links(dl, x, cy, w) + 16
    cy = cy + ABOUT.changelog(dl, x, cy, w)
    imgui.SetCursorScreenPos(imgui.ImVec2(x, cy))
    imgui.Dummy(imgui.ImVec2(w, 10))
end
function getPriceForResource(resKey, workType)
    if workType == WORK_TYPES.FARM and useCustomFarmPrices == true and customPriceEditFarm[resKey] then
        return customPriceEditFarm[resKey].v
    elseif workType == WORK_TYPES.MINE and useCustomMinePrices and customPriceEditMine[resKey] then
        return customPriceEditMine[resKey].v
    elseif workType == WORK_TYPES.SAWMILL and useCustomSawmillPrices and customPriceEditSaw[resKey] then
        return customPriceEditSaw[resKey].v
    else
        local cfg = configs[workType]
        return resourcePrices[resKey] or cfg.defaultPrices[resKey] or 0
    end
end
function getCasePrice(itemId)
    if useCustomCasePrices then
        if invEditCache and invEditCache[itemId] then
            return invEditCache[itemId].v
        end
        return (investmentConfig[itemId] and investmentConfig[itemId].cost) or 0
    else
        return (globalPrices and globalPrices[caseKey(itemId)]) or 0
    end
end
function syncCasePrices()
    if useCustomCasePrices then return end
    for itemId, data in pairs(investmentConfig) do
        data.cost = getCasePrice(itemId)
    end
    saveInvestmentConfig()
end
OV_THEMES = nil
OV_UI = { }
function ovDefaults(style)
    local t = {
        bg = {0.08, 0.08, 0.08}, bgAlpha = 0.94,
        border = {0.12, 0.12, 0.12}, borderSize = 1.0,
        headerBg = {0.055, 0.055, 0.055},
        title = {0.569, 0.898, 0.102},
        separator = {0.165, 0.165, 0.165},
        text = {1.0, 1.0, 1.0},
        value = {1.0, 0.8, 0.2},
        income = {0.3, 1.0, 0.3},
        timer = {0.3, 1.0, 1.0},
        muted = {0.6, 0.6, 0.6},
        az = {0.0, 0.8, 1.0},
        rounding = 8, padding = 8, fontScale = 1.0, alpha = 1.0,
        showTitle = false,
    }
    if style == 1 then
        t.bg = {0.078, 0.078, 0.078}; t.bgAlpha = 1.0
        t.borderSize = 0; t.rounding = 0; t.showTitle = true
    end
    return t
end
function ovLoadThemes()
    OV_THEMES = { ovDefaults(1), ovDefaults(2) }
    local f = io.open(configDir .. "overlay_theme.json", "r")
    if not f then return end
    local content = f:read("*all"); f:close()
    local ok, data = pcall(decodeJson, content)
    if not ok or type(data) ~= "table" then return end
    for i = 1, 2 do
        local saved = data["style" .. i]
        if type(saved) == "table" then
            for k, def in pairs(OV_THEMES[i]) do
                local v = saved[k]
                if type(def) == "table" then
                    if type(v) == "table" and tonumber(v[1]) and tonumber(v[2]) and tonumber(v[3]) then
                        OV_THEMES[i][k] = {tonumber(v[1]), tonumber(v[2]), tonumber(v[3])}
                    end
                elseif type(def) == "number" then
                    if tonumber(v) then OV_THEMES[i][k] = tonumber(v) end
                elseif type(def) == "boolean" then
                    if type(v) == "boolean" then OV_THEMES[i][k] = v end
                end
            end
        end
    end
end
function ovSaveThemes()
    if not OV_THEMES then return end
    local f = io.open(configDir .. "overlay_theme.json", "w")
    if f then
        f:write(encodeJson({ style1 = OV_THEMES[1], style2 = OV_THEMES[2] }))
        f:close()
    end
end
function ovThemes()
    if not OV_THEMES then ovLoadThemes() end
    return OV_THEMES
end
function ovStyleIdx()
    return (settings.overlayStyle == 2) and 2 or 1
end
function ovTheme()
    return ovThemes()[ovStyleIdx()]
end
function ovU32(c, a)
    local function ch(v) return math.floor(math.max(0, math.min(1, v)) * 255 + 0.5) end
    return ch(a or 1) * 16777216 + ch(c[3]) * 65536 + ch(c[2]) * 256 + ch(c[1])
end
function ovVec4(c, a)
    return imgui.ImVec4(c[1], c[2], c[3], a or 1)
end
OV_IMGUI = setmetatable({}, { __index = imgui })
OV_IMGUI.TextColored = function(col, text)
    local t = ovTheme()
    local r, g, b = col.x, col.y, col.z
    local function eq(a, b2) return math.abs(a - b2) < 0.01 end
    local use = nil
    if eq(r, 1.0) and eq(g, 0.8) and eq(b, 0.2) then use = t.value
    elseif eq(r, 0.3) and eq(g, 1.0) and eq(b, 0.3) then use = t.income
    elseif eq(r, 0.3) and eq(g, 1.0) and eq(b, 1.0) then use = t.timer
    elseif eq(r, 0.0) and eq(g, 0.8) and eq(b, 1.0) then use = t.az
    elseif eq(r, g) and eq(g, b) and (eq(r, 0.6) or eq(r, 0.5)) then use = t.muted
    end
    if use then col = imgui.ImVec4(use[1], use[2], use[3], col.w) end
    imgui.TextColored(col, text)
end
function ovBegin(cfg, winName, title, isPreview)
    local t = ovTheme()
    local hovered = (not isPreview) and settings.overlayHideOnHover and isMouseOverOverlay(cfg)
    local st = { t = t, hovered = hovered and true or false, alpha = t.alpha, title = title, preview = isPreview and true or false }
    if not isPreview then
        imgui.SetNextWindowPos(imgui.ImVec2(cfg.x, cfg.y), imgui.Cond.FirstUseEver)
        imgui.SetNextWindowSize(imgui.ImVec2(cfg.w, cfg.h), imgui.Cond.FirstUseEver)
    end
    local roundVar = imgui.StyleVar.WindowRounding
    local bgCol = imgui.Col.WindowBg
    if isPreview then
        roundVar = imgui.StyleVar.ChildWindowRounding or imgui.StyleVar.ChildRounding or roundVar
        bgCol = imgui.Col.ChildWindowBg or imgui.Col.ChildBg or bgCol
    end
    imgui.PushStyleVar(roundVar, t.rounding)
    imgui.PushStyleVar(imgui.StyleVar.WindowPadding, imgui.ImVec2(t.padding, t.padding * 0.75))
    imgui.PushStyleVar(imgui.StyleVar.Alpha, hovered and 0.0 or t.alpha)
    imgui.PushStyleColor(imgui.Col.Border, imgui.ImVec4(0, 0, 0, 0))
    imgui.PushStyleColor(bgCol, ovVec4(t.bg, t.bgAlpha))
    imgui.PushStyleColor(imgui.Col.ResizeGrip, imgui.ImVec4(0, 0, 0, 0))
    imgui.PushStyleColor(imgui.Col.ResizeGripHovered, imgui.ImVec4(0, 0, 0, 0))
    imgui.PushStyleColor(imgui.Col.ResizeGripActive, imgui.ImVec4(0, 0, 0, 0))
    imgui.PushStyleColor(imgui.Col.Text, ovVec4(t.text))
    if isPreview then
        imgui.BeginChild(winName, imgui.ImVec2(cfg.w, cfg.h), true, imgui.WindowFlags.NoScrollbar + (imgui.WindowFlags.NoScrollWithMouse or 0) + (imgui.WindowFlags.AlwaysUseWindowPadding or 0))
    else
        imgui.Begin(winName, true, imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoTitleBar)
    end
    imgui.SetWindowFontScale(t.fontScale)
    local hdr = 0
    if t.showTitle then
        hdr = 22 * t.fontScale
        if not st.hovered then
            local wp, ws = imgui.GetWindowPos(), imgui.GetWindowSize()
            local dl = imgui.GetWindowDrawList()
            local tw = imgui.CalcTextSize(title).x * t.fontScale
            dl:AddText(imgui.ImVec2(wp.x + (ws.x - tw) / 2, wp.y + 3 * t.fontScale), ovU32(t.title, t.alpha), title)
            dl:AddLine(imgui.ImVec2(wp.x + t.padding, wp.y + hdr), imgui.ImVec2(wp.x + ws.x - t.padding, wp.y + hdr), ovU32(t.separator, t.bgAlpha * t.alpha), 1.0)
        end
        imgui.SetCursorPos(imgui.ImVec2(t.padding, hdr + 6))
    else
        imgui.SetCursorPos(imgui.ImVec2(t.padding, t.padding))
    end
    return st
end
function ovSeparator(st)
    local t = st.t
    local cy = imgui.GetCursorPosY()
    if not st.hovered then
        local wp, ws = imgui.GetWindowPos(), imgui.GetWindowSize()
        local dl = imgui.GetWindowDrawList()
        dl:AddLine(imgui.ImVec2(wp.x + t.padding, wp.y + cy + 2), imgui.ImVec2(wp.x + ws.x - t.padding, wp.y + cy + 2), ovU32(t.separator, t.alpha), 1.0)
    end
    imgui.SetCursorPos(imgui.ImVec2(t.padding, cy + 8))
end
function ovTimerRow(label)
    local imgui = OV_IMGUI
    if settings.overlayTimerEnabled then
        imgui.SetCursorPosY(imgui.GetCursorPosY() + 4)
        imgui.Text(label); imgui.SameLine()
        if overlayTimer.running then
            imgui.TextColored(imgui.ImVec4(0.3, 1.0, 1.0, 1), overlayTimer.displayedTime)
        else
            imgui.TextColored(imgui.ImVec4(0.6, 0.6, 0.6, 1), u8("00:00:00"))
        end
    end
end
function ovEnd(st, cfg)
    local t = st.t
    local pos, size = imgui.GetWindowPos(), imgui.GetWindowSize()
    if t.borderSize > 0 and not st.hovered then
        local h = t.borderSize / 2
        imgui.GetWindowDrawList():AddRect(imgui.ImVec2(pos.x + h, pos.y + h), imgui.ImVec2(pos.x + size.x - h, pos.y + size.y - h), ovU32(t.border, t.alpha), t.rounding, 15, t.borderSize)
    end
    if not st.preview and pos and pos.x > 0 and pos.y > 0 and (cfg.x ~= pos.x or cfg.y ~= pos.y or cfg.w ~= size.x or cfg.h ~= size.y) then
        cfg.x, cfg.y, cfg.w, cfg.h = pos.x, pos.y, size.x, size.y; saveOverlayConfig()
    end
    if st.preview then imgui.EndChild() else imgui.End() end
    imgui.PopStyleColor(6)
    imgui.PopStyleVar(3)
end
function drawTaxiOverlay()
    local imgui = OV_IMGUI
    local cfg = taxiOverlayConfig
    local st = ovBegin(cfg, u8("Такси (оверлей)"), u8("Такси"))
    local tc = taxiOvCache
    if not tc or os.clock() - tc.t >= 1.0 then
        tc = {t = os.clock(), total = 0, trips = 0}
        local gameDate = getGameDate()
        if taxiLog then
            for _, log in ipairs(taxiLog) do
                if getGameDate(log.time) == gameDate then
                    tc.total = tc.total + (log.money or 0)
                    tc.trips = tc.trips + 1
                end
            end
        end
        taxiOvCache = tc
    end
    local todayTotal, tripsCount = tc.total, tc.trips
    imgui.Text(u8("Поездок сегодня: ")); imgui.SameLine()
    imgui.TextColored(imgui.ImVec4(1.0, 0.8, 0.2, 1), tostring(tripsCount))
    imgui.Spacing()
    ovSeparator(st)
    imgui.Text(u8("Доход: ")); imgui.SameLine()
    imgui.TextColored(imgui.ImVec4(0.3, 1.0, 0.3, 1), formatNumber(todayTotal) .. "$")
    ovTimerRow(u8("Время: "))
    ovEnd(st, cfg)
end
function drawFarmOverlay()
    local imgui = OV_IMGUI
    local cfg = overlayConfigs[WORK_TYPES.FARM]
    local st = ovBegin(cfg, u8("Добыча за сегодня (Ферма)"), u8("Ферма"))
    if currentWork == WORK_TYPES.FARM then
        local useSession = overlaySessionActive[WORK_TYPES.FARM]
        local displayData = useSession and overlaySessionResources[WORK_TYPES.FARM] or getTodayStats()
        local todayTotal = 0
        for _, k in ipairs(config.resourceOrder) do
            local price = getPriceForResource(k, WORK_TYPES.FARM)
            todayTotal = todayTotal + ((displayData[k] or 0) * price)
        end
        for _, k in ipairs(config.resourceOrder) do
            imgui.Text(u8(config.resourceNames[k] .. ": ")); imgui.SameLine()
            imgui.TextColored(imgui.ImVec4(1.0, 0.8, 0.2, 1), formatNumber(displayData[k] or 0))
        end
        imgui.Spacing()
        ovSeparator(st)
        imgui.Text(u8("Доход: ")); imgui.SameLine()
        imgui.TextColored(imgui.ImVec4(0.3, 1.0, 0.3, 1), formatNumber(todayTotal) .. "$")
        ovTimerRow(u8("Время работы: "))
    else
        imgui.TextColored(imgui.ImVec4(0.6, 0.6, 0.6, 1), u8("Переключитесь на ферму"))
    end
    ovEnd(st, cfg)
end
function drawMineOverlay()
    local imgui = OV_IMGUI
    local cfg = overlayConfigs[WORK_TYPES.MINE]
    local st = ovBegin(cfg, u8("Добыча за сегодня (Шахта)"), u8("Шахта"))
    if currentWork == WORK_TYPES.MINE then
        local useSession = overlaySessionActive[WORK_TYPES.MINE]
        local displayData = useSession and overlaySessionResources[WORK_TYPES.MINE] or getTodayStats()
        local todayTotal = 0
        for _, k in ipairs(config.resourceOrder) do
            local price = getPriceForResource(k, WORK_TYPES.MINE)
            todayTotal = todayTotal + ((displayData[k] or 0) * price)
        end
        if settings.overlayColumns == 1 or settings.regularmineEnabled then
            local resList = settings.regularmineEnabled and {"stone", "metal", "bronze", "silver", "gold"} or config.resourceOrder
            for _, k in ipairs(resList) do
                imgui.Text(u8(config.resourceNames[k] .. ": ")); imgui.SameLine()
                imgui.TextColored(imgui.ImVec4(1.0, 0.8, 0.2, 1), formatNumber(displayData[k] or 0))
            end
        else
            local contentWidth = imgui.GetWindowSize().x - 2 * st.t.padding; local colWidth = contentWidth / 2
            imgui.Columns(2, "overlay_mine_cols", false); imgui.SetColumnWidth(0, colWidth - 24)
            for _, k in ipairs(config.leftColumnOrder) do
                imgui.Text(u8(config.resourceNames[k] .. ": ")); imgui.SameLine()
                imgui.TextColored(imgui.ImVec4(1.0, 0.8, 0.2, 1), formatNumber(displayData[k] or 0)); imgui.NextColumn()
            end
            imgui.SetColumnWidth(1, colWidth + 20)
            for _, k in ipairs(config.rightColumnOrder) do
                imgui.Text(u8(config.resourceNames[k] .. ": ")); imgui.SameLine()
                imgui.TextColored(imgui.ImVec4(1.0, 0.8, 0.2, 1), formatNumber(displayData[k] or 0)); imgui.NextColumn()
            end
            imgui.Columns(1)
        end
        imgui.Spacing()
        ovSeparator(st)
        imgui.Text(u8("Доход: ")); imgui.SameLine()
        imgui.TextColored(imgui.ImVec4(0.3, 1.0, 0.3, 1), formatNumber(todayTotal) .. "$")
        ovTimerRow(u8("Время работы: "))
        if settings.mineSpawnTimerEnabled then
            ovSeparator(st)
            local stoneTimer, golemTimer = getSpawnTimers()
            if stoneTimer then
                local stoneMin = math.floor(stoneTimer / 60); local stoneSec = stoneTimer % 60
                imgui.Text(u8("До спавна камней: ")); imgui.SameLine()
                imgui.TextColored(imgui.ImVec4(1.0, 0.8, 0.2, 1), string.format("%02d:%02d", stoneMin, stoneSec))
            else
                imgui.TextColored(imgui.ImVec4(0.6, 0.6, 0.6, 1), u8("Шахта закрыта"))
            end
            if golemTimer then
                local golemMin = math.floor(golemTimer / 60); local golemSec = golemTimer % 60
                imgui.Text(u8("До спавна големов: ")); imgui.SameLine()
                imgui.TextColored(imgui.ImVec4(1.0, 0.8, 0.2, 1), string.format("%02d:%02d", golemMin, golemSec))
            end
        end
    else
        imgui.TextColored(imgui.ImVec4(0.6, 0.6, 0.6, 1), u8("Переключитесь на шахту"))
    end
    ovEnd(st, cfg)
end
function drawSawmillOverlay()
    local imgui = OV_IMGUI
    local cfg = overlayConfigs[WORK_TYPES.SAWMILL]
    local st = ovBegin(cfg, u8("Добыча за сегодня (Лесопилка)"), u8("Лесопилка"))
    if currentWork == WORK_TYPES.SAWMILL then
        local useSession = overlaySessionActive[WORK_TYPES.SAWMILL]
        local displayData = useSession and overlaySessionResources[WORK_TYPES.SAWMILL] or getTodayStats()
        local todayTotal = 0
        for _, k in ipairs(config.resourceOrder) do
            local price = getPriceForResource(k, WORK_TYPES.SAWMILL)
            todayTotal = todayTotal + ((displayData[k] or 0) * price)
        end
        for _, k in ipairs(config.resourceOrder) do
            imgui.Text(u8(config.resourceNames[k] .. ": ")); imgui.SameLine()
            imgui.TextColored(imgui.ImVec4(1.0, 0.8, 0.2, 1), formatNumber(displayData[k] or 0))
        end
        imgui.Spacing()
        ovSeparator(st)
        imgui.Text(u8("Доход: ")); imgui.SameLine()
        imgui.TextColored(imgui.ImVec4(0.3, 1.0, 0.3, 1), formatNumber(todayTotal) .. "$")
        ovTimerRow(u8("Время работы: "))
    else
        imgui.TextColored(imgui.ImVec4(0.6, 0.6, 0.6, 1), u8("Переключитесь на лесопилку"))
    end
    ovEnd(st, cfg)
end
function drawOilOverlay()
    local imgui = OV_IMGUI
    local cfg = oilOverlayConfig
    local st = ovBegin(cfg, u8("Доход за сегодня (Нефтевышки)"), u8("Нефтевышки"))
    if not oilWorkActive then
        imgui.TextColored(imgui.ImVec4(0.6, 0.6, 0.6, 1), u8("Переключитесь на нефтевышки"))
        ovEnd(st, cfg)
        return
    end
    local oc = oilOvCache
    if not oc or os.clock() - oc.t >= 1.0 then
        oc = {t = os.clock(), all = 0, az = 0}
        local todayDate = getGameDate()
        for _, log in ipairs(oilLog) do
            if getGameDate(log.time) == todayDate then
                oc.all = oc.all + (log.money or 0)
                oc.az = oc.az + (log.az or 0)
            end
        end
        oilOvCache = oc
    end
    local todayAll, todayAZ = oc.all, oc.az
    imgui.TextColored(imgui.ImVec4(0.5, 0.5, 0.5, 1), u8("Доход за день"))
    imgui.Text(u8("Доход: ")); imgui.SameLine()
    imgui.TextColored(imgui.ImVec4(0.3, 1.0, 0.3, 1), formatNumber(todayAll) .. "$")
    imgui.Text(u8("AZ: ")); imgui.SameLine()
    imgui.TextColored(imgui.ImVec4(0.0, 0.8, 1.0, 1), formatNumber(todayAZ))
    imgui.Spacing()
    ovSeparator(st)
    imgui.Spacing()
    imgui.TextColored(imgui.ImVec4(0.5, 0.5, 0.5, 1), u8("Доход за сессию"))
    imgui.Text(u8("Доход: ")); imgui.SameLine()
    imgui.TextColored(imgui.ImVec4(0.3, 1.0, 0.3, 1), formatNumber(oilSessionData.money) .. "$")
    imgui.Text(u8("AZ: ")); imgui.SameLine()
    imgui.TextColored(imgui.ImVec4(0.0, 0.8, 1.0, 1), formatNumber(oilSessionData.az))
    ovTimerRow(u8("Время работы: "))
    ovEnd(st, cfg)
end
function ovResetTheme()
    ovThemes()[ovStyleIdx()] = ovDefaults(ovStyleIdx())
    ovSaveThemes()
end
function ovColorRow(label, key)
    local t = ovTheme()
    local c = t[key]
    local dl = imgui.GetWindowDrawList()
    local pos = imgui.GetCursorScreenPos()
    dl:AddRectFilled(pos, imgui.ImVec2(pos.x + 28, pos.y + 18), ovU32(c, 1), 4)
    dl:AddRect(pos, imgui.ImVec2(pos.x + 28, pos.y + 18), 0xFFFFFFFF, 4, 15, 1.2)
    imgui.InvisibleButton("##ov_sw_" .. key, imgui.ImVec2(28, 18))
    if imgui.IsItemClicked(0) then imgui.OpenPopup("ov_picker##" .. key) end
    imgui.SameLine()
    imgui.Text(label)
    if imgui.BeginPopup("ov_picker##" .. key) then
        local col = imgui.ImFloat4(c[1], c[2], c[3], 1.0)
        if imgui.ColorPicker4("##ov_pick_" .. key, col, imgui.ColorEditFlags.NoSidePreview + imgui.ColorEditFlags.NoAlpha) then
            t[key] = {col.v[1], col.v[2], col.v[3]}
            ovSaveThemes()
        end
        imgui.EndPopup()
    end
end
function ovSliderRow(label, key, minv, maxv, fmt)
    local t = ovTheme()
    imgui.Text(label)
    imgui.PushItemWidth(220)
    local v = imgui.ImFloat(t[key])
    if imgui.SliderFloat("##ov_sl_" .. key, v, minv, maxv, fmt or "%.2f") then
        t[key] = v.v
        ovSaveThemes()
    end
    imgui.PopItemWidth()
end
function ovCheckRow(label, key)
    local t = ovTheme()
    local b = imgui.ImBool(t[key])
    if imgui.Checkbox(label, b) then
        t[key] = b.v
        ovSaveThemes()
    end
end
OV_PREVIEW_NAMES = {"Ферма", "Шахта", "Лесопилка", "Нефтевышки", "Такси", "Инкассатор"}
function drawIncassOverlay()
    local imgui = OV_IMGUI
    local cfg = incassOverlayConfig
    local st = ovBegin(cfg, u8("Инкассатор (оверлей)"), u8("Инкассатор"))
    if not incassWorkActive then
        imgui.TextColored(imgui.ImVec4(0.6, 0.6, 0.6, 1), u8("Переключитесь на инкассатора"))
        ovEnd(st, cfg)
        return
    end
    local s = getIncassOverlayStats()
    imgui.Text(u8("Выплат сегодня: ")); imgui.SameLine()
    imgui.TextColored(imgui.ImVec4(1.0, 0.8, 0.2, 1), tostring(s.payouts))
    imgui.Text(u8("Доход с банкоматов: ")); imgui.SameLine()
    imgui.TextColored(imgui.ImVec4(0.3, 1.0, 0.3, 1), formatNumber(s.money) .. "$")
    imgui.Spacing()
    ovSeparator(st)
    imgui.Text(u8("Акций получено: ")); imgui.SameLine()
    imgui.TextColored(imgui.ImVec4(1.0, 0.8, 0.2, 1), tostring(s.stocks) .. u8(" шт."))
    imgui.Text(u8("Доход с акций: ")); imgui.SameLine()
    imgui.TextColored(imgui.ImVec4(0.3, 1.0, 0.3, 1), formatNumber(s.stockIncome) .. "$" .. (s.anyAvg and "*" or ""))
    if s.anyAvg then
        imgui.TextColored(imgui.ImVec4(0.6, 0.6, 0.6, 1), u8("* средняя цена за 7 дней"))
    end
    imgui.Spacing()
    ovSeparator(st)
    imgui.Text(u8("Всего: ")); imgui.SameLine()
    imgui.TextColored(imgui.ImVec4(0.3, 1.0, 0.3, 1), formatNumber(s.total) .. "$")
    ovTimerRow(u8("Время: "))
    ovEnd(st, cfg)
end
function ovPreviewIncass(st)
    local imgui = OV_IMGUI
    local VAL = imgui.ImVec4(1.0, 0.8, 0.2, 1)
    local INC = imgui.ImVec4(0.3, 1.0, 0.3, 1)
    local MUT = imgui.ImVec4(0.5, 0.5, 0.5, 1)
    local function pair(lbl, val, col)
        imgui.Text(u8(lbl)); imgui.SameLine(); imgui.TextColored(col, val)
    end
    pair("Выплат сегодня: ", "23", VAL)
    pair("Доход с банкоматов: ", "1.840.000$", INC)
    imgui.Spacing(); ovSeparator(st)
    pair("Акций получено: ", "5 шт.", VAL)
    pair("Доход с акций: ", "2.350.000$*", INC)
    imgui.TextColored(MUT, u8("* средняя цена за 7 дней"))
    imgui.Spacing(); ovSeparator(st)
    pair("Всего: ", "4.190.000$", INC)
    if settings.overlayTimerEnabled then
        imgui.SetCursorPosY(imgui.GetCursorPosY() + 4)
        imgui.Text(u8("Время: ")); imgui.SameLine()
        imgui.TextColored(imgui.ImVec4(0.3, 1.0, 1.0, 1), "01:12:30")
    end
end
function ovPreviewBody(kind, st)
    if kind == 6 then return ovPreviewIncass(st) end
    local imgui = OV_IMGUI
    local VAL = imgui.ImVec4(1.0, 0.8, 0.2, 1)
    local INC = imgui.ImVec4(0.3, 1.0, 0.3, 1)
    local AZC = imgui.ImVec4(0.0, 0.8, 1.0, 1)
    local MUT = imgui.ImVec4(0.5, 0.5, 0.5, 1)
    local function pair(lbl, val, col)
        imgui.Text(u8(lbl)); imgui.SameLine(); imgui.TextColored(col, val)
    end
    local function timerRow()
        if settings.overlayTimerEnabled then
            imgui.SetCursorPosY(imgui.GetCursorPosY() + 4)
            imgui.Text(u8("Время работы: ")); imgui.SameLine()
            imgui.TextColored(imgui.ImVec4(0.3, 1.0, 1.0, 1), "01:12:30")
        end
    end
    if kind == 1 then
        pair("Лён: ", "124", VAL); pair("Хлопок: ", "58", VAL); pair("Кусок редкой ткани: ", "7", VAL)
        pair("Вода для личных грядок: ", "312", VAL); pair("Краситель: ", "21", VAL); pair("Уголь: ", "45", VAL)
        imgui.Spacing(); ovSeparator(st)
        pair("Доход: ", "2.480.000$", INC); timerRow()
    elseif kind == 2 then
        if settings.overlayColumns == 1 or settings.regularmineEnabled then
            pair("Камень: ", "540", VAL); pair("Металл: ", "212", VAL); pair("Бронза: ", "96", VAL)
            pair("Серебро: ", "48", VAL); pair("Золото: ", "19", VAL)
        else
            local colWidth = (imgui.GetWindowSize().x - 2 * st.t.padding) / 2
            imgui.Columns(2, "overlay_preview_cols", false); imgui.SetColumnWidth(0, colWidth - 24)
            local left = {{"Камень: ", "540"}, {"Металл: ", "212"}, {"Бронза: ", "96"}, {"Серебро: ", "48"}, {"Золото: ", "19"}}
            local right = {{"Алмазный камень: ", "6"}, {"Прочная ткань: ", "33"}, {"Шахтерский сплав: ", "12"}, {"Темная материя: ", "4"}}
            for _, r in ipairs(left) do pair(r[1], r[2], VAL); imgui.NextColumn() end
            imgui.SetColumnWidth(1, colWidth + 20)
            for _, r in ipairs(right) do pair(r[1], r[2], VAL); imgui.NextColumn() end
            imgui.Columns(1)
        end
        imgui.Spacing(); ovSeparator(st)
        pair("Доход: ", "5.120.000$", INC); timerRow()
        if settings.mineSpawnTimerEnabled then
            ovSeparator(st)
            pair("До спавна камней: ", "03:25", VAL)
            pair("До спавна големов: ", "11:40", VAL)
        end
    elseif kind == 3 then
        pair("Дрова: ", "240", VAL); pair("Древесина высшего качества: ", "18", VAL)
        imgui.Spacing(); ovSeparator(st)
        pair("Доход: ", "1.350.000$", INC); timerRow()
    elseif kind == 4 then
        imgui.TextColored(MUT, u8("Доход за день"))
        pair("Доход: ", "3.900.000$", INC); pair("AZ: ", "120", AZC)
        imgui.Spacing(); ovSeparator(st); imgui.Spacing()
        imgui.TextColored(MUT, u8("Доход за сессию"))
        pair("Доход: ", "1.200.000$", INC); pair("AZ: ", "40", AZC)
        timerRow()
    else
        pair("Поездок сегодня: ", "14", VAL)
        imgui.Spacing(); ovSeparator(st)
        pair("Доход: ", "860.000$", INC)
        if settings.overlayTimerEnabled then
            imgui.SetCursorPosY(imgui.GetCursorPosY() + 4)
            imgui.Text(u8("Время: ")); imgui.SameLine()
            imgui.TextColored(imgui.ImVec4(0.3, 1.0, 1.0, 1), "01:12:30")
        end
    end
end
function ovDrawPreview()
    local kind = (OV_UI.previewSel and OV_UI.previewSel.v or 0) + 1
    local real
    if kind == 1 then real = overlayConfigs[WORK_TYPES.FARM]
    elseif kind == 2 then real = overlayConfigs[WORK_TYPES.MINE]
    elseif kind == 3 then real = overlayConfigs[WORK_TYPES.SAWMILL]
    elseif kind == 4 then real = oilOverlayConfig
    elseif kind == 5 then real = taxiOverlayConfig
    else real = incassOverlayConfig end
    local W, H = (real and real.w) or 200, math.min((real and real.h) or 170, 380)
    local m = 12
    local dl = imgui.GetWindowDrawList()
    local pos = imgui.GetCursorScreenPos()
    dl:AddRectFilled(pos, imgui.ImVec2(pos.x + W + 2 * m, pos.y + H + 2 * m), 0xFF5A5A5A, 4)
    dl:AddRectFilled(imgui.ImVec2(pos.x + (W + 2 * m) / 2, pos.y), imgui.ImVec2(pos.x + W + 2 * m, pos.y + H + 2 * m), 0xFF8C8C8C, 4)
    imgui.SetCursorScreenPos(imgui.ImVec2(pos.x + m, pos.y + m))
    local cfg = { w = W, h = H }
    local st = ovBegin(cfg, "##ov_preview_child", u8(OV_PREVIEW_NAMES[kind]), true)
    ovPreviewBody(kind, st)
    ovEnd(st, cfg)
    imgui.SetCursorScreenPos(pos)
    imgui.Dummy(imgui.ImVec2(W + 2 * m, H + 2 * m))
end
function drawOverlayCustomization()
    imgui.Spacing(); imgui.Separator(); imgui.Spacing()
    imgui.TextColored(imgui.ImVec4(1.0, 0.8, 0.2, 1), u8("Кастомизация оверлея"))
    imgui.Spacing()
    imgui.Text(u8("Предпросмотр оверлея:"))
    if not OV_UI.previewSel then OV_UI.previewSel = imgui.ImInt(0) end
    local names = {}
    for i, n in ipairs(OV_PREVIEW_NAMES) do names[i] = u8(n) end
    imgui.PushItemWidth(200)
    imgui.Combo("##ov_preview_sel", OV_UI.previewSel, table.concat(names, "\0") .. "\0")
    imgui.PopItemWidth()
    imgui.Spacing()
    ovDrawPreview()
    imgui.Spacing()
    if imgui.Button(u8("Сбросить настройки") .. "##ov_reset") then ovResetTheme() end
    imgui.Spacing()
    if imgui.CollapsingHeader(u8("Окно") .. "##ov_h_win") then
        ovSliderRow(u8("Прозрачность фона"), "bgAlpha", 0.0, 1.0, "%.2f")
        ovSliderRow(u8("Общая прозрачность (вместе с текстом)"), "alpha", 0.2, 1.0, "%.2f")
        ovSliderRow(u8("Скругление углов"), "rounding", 0.0, 20.0, "%.0f")
        ovSliderRow(u8("Толщина рамки (0 = без рамки)"), "borderSize", 0.0, 4.0, "%.1f")
        ovSliderRow(u8("Внутренние отступы"), "padding", 2.0, 20.0, "%.0f")
        ovSliderRow(u8("Размер текста"), "fontScale", 0.7, 1.6, "%.2f")
        ovCheckRow(u8("Показывать заголовок"), "showTitle")
        imgui.Spacing()
    end
    if imgui.CollapsingHeader(u8("Цвета") .. "##ov_h_col") then
        ovColorRow(u8("Фон окна"), "bg")
        ovColorRow(u8("Рамка"), "border")
        ovColorRow(u8("Текст заголовка"), "title")
        ovColorRow(u8("Разделители"), "separator")
        ovColorRow(u8("Обычный текст"), "text")
        ovColorRow(u8("Значения (ресурсы)"), "value")
        ovColorRow(u8("Доход"), "income")
        ovColorRow(u8("Таймер"), "timer")
        ovColorRow(u8("AZ (нефтевышки)"), "az")
        ovColorRow(u8("Приглушённый текст"), "muted")
        imgui.Spacing()
    end
    imgui.TextColored(imgui.ImVec4(0.6, 0.6, 0.6, 1), u8("Изменения видны сразу и сохраняются автоматически. Размер оверлея в предпросмотре такой же, как у настоящего."))
    imgui.Spacing()
end
function drawAchievementNotifications()
    if #achievementNotifications == 0 then return end
    local sw, sh = getScreenResolution()
    if not sw then sw, sh = 1920, 1080 end
    local currentTime = os.time()
    for i = #achievementNotifications, 1, -1 do
        local notif = achievementNotifications[i]
        local elapsed = currentTime - notif.time
        if elapsed >= 8 then table.remove(achievementNotifications, i)
        else
            local animProgress
            if elapsed < 0.3 then animProgress = elapsed / 0.3
            elseif elapsed > 7 then animProgress = 1 - (elapsed - 7) / 1.0
            else animProgress = 1 end
            local notifX = sw / 2 - 150 + (400 * (1 - animProgress))
            local notifY = sh - 120 - (i - 1) * 85
            imgui.SetNextWindowPos(imgui.ImVec2(notifX, notifY), imgui.Cond.Always)
            imgui.SetNextWindowSize(imgui.ImVec2(300, 70), imgui.Cond.Always)
            imgui.PushStyleVar(imgui.StyleVar.WindowRounding, 6)
            imgui.PushStyleVar(imgui.StyleVar.WindowPadding, imgui.ImVec2(10, 10))
            imgui.PushStyleColor(imgui.Col.WindowBg, imgui.ImVec4(0.1, 0.1, 0.1, 0.92 * animProgress))
            imgui.PushStyleColor(imgui.Col.Border, imgui.ImVec4(0.16, 0.98, 0.16, 0.8 * animProgress))
            imgui.Begin(u8("Достижение##notif"..i), nil, imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoBringToFrontOnFocus + imgui.WindowFlags.NoFocusOnAppearing)
            imgui.SetCursorPos(imgui.ImVec2(10, 10))
            imgui.TextColored(imgui.ImVec4(0.16, 0.98, 0.16, animProgress), notif.icon .. " " .. notif.title)
            imgui.SetCursorPos(imgui.ImVec2(10, 35))
            imgui.TextColored(imgui.ImVec4(1, 1, 1, animProgress), u8(notif.text))
            imgui.End(); imgui.PopStyleColor(2); imgui.PopStyleVar(2)
        end
    end
end
function rhPopupBegin(title)
    imgui.PushStyleVar(imgui.StyleVar.WindowRounding, 14)
    imgui.PushStyleVar(imgui.StyleVar.WindowPadding, imgui.ImVec2(20, 18))
    local open = imgui.BeginPopupModal(title, nil, imgui.WindowFlags.AlwaysAutoResize)
    if not open then imgui.PopStyleVar(2) end
    return open
end
function rhPopupEnd()
    imgui.EndPopup()
    imgui.PopStyleVar(2)
end
function rhPopupHeader(dl, W, icon, accent, title, sub, tag)
    local P = imgui.ImVec2
    local bg, brd = homeCardColors()
    local cp = imgui.GetCursorScreenPos()
    local hh = 64
    rhCardBox(dl, cp.x, cp.y, W, hh, bg, brd, 12)
    rhIconBadge(dl, cp.x + 34, cp.y + hh / 2, 18, icon, accent, bg, 0)
    local tagW = tag and (imgui.CalcTextSize(tag).x + 34) or 14
    dl:PushClipRect(P(cp.x + 62, cp.y), P(cp.x + W - tagW, cp.y + hh), true)
    dl:AddText(P(cp.x + 66, cp.y + 14), 0xFFFFFFFF, title)
    dl:AddText(P(cp.x + 66, cp.y + 36), PD.C.mute, sub)
    dl:PopClipRect()
    if tag then
        rhPill(dl, cp.x + W - (imgui.CalcTextSize(tag).x + 20) - 14, cp.y + (hh - 22) / 2, tag, accent)
    end
    imgui.SetCursorScreenPos(P(cp.x, cp.y + hh + 12))
    imgui.Dummy(P(W, 1))
end
function drawDevNotifications()
    if #devNotifications == 0 then return end
    local sw, sh = getScreenResolution()
    if not sw then sw, sh = 1920, 1080 end
    local P = imgui.ImVec2
    local C = PD.C
    local W, H = 340, 88
    local currentTime = os.time()
    for i = #devNotifications, 1, -1 do
        local notif = devNotifications[i]
        local elapsed = currentTime - notif.time
        if elapsed >= 8 then table.remove(devNotifications, i)
        else
            local a
            if elapsed < 0.3 then a = elapsed / 0.3
            elseif elapsed > 7 then a = 1 - (elapsed - 7) / 1.0
            else a = 1 end
            local nx = sw / 2 - W / 2 + (400 * (1 - a))
            local ny = sh - 130 - (#achievementNotifications) * 85 - (i - 1) * (H + 10)
            imgui.SetNextWindowPos(P(nx, ny), imgui.Cond.Always)
            imgui.SetNextWindowSize(P(W, H), imgui.Cond.Always)
            imgui.PushStyleVar(imgui.StyleVar.WindowRounding, 14)
            imgui.PushStyleVar(imgui.StyleVar.WindowPadding, P(0, 0))
            imgui.PushStyleColor(imgui.Col.WindowBg, imgui.ImVec4(0, 0, 0, 0))
            imgui.PushStyleColor(imgui.Col.Border, imgui.ImVec4(0, 0, 0, 0))
            imgui.Begin(u8("Новость##devnotif" .. i), nil, imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoBringToFrontOnFocus + imgui.WindowFlags.NoFocusOnAppearing)
            local wp = imgui.GetWindowPos()
            local dl = imgui.GetWindowDrawList()
            rhCardBox(dl, wp.x, wp.y, W, H, rhAlpha(0xFF181818, 0.96 * a), rhAlpha(0xFF2C2C2C, a), 14)
            rhIconBadge(dl, wp.x + 34, wp.y + 28, 16, fa.ICON_COMMENT, rhAlpha(C.green, a), rhAlpha(0xFF181818, a), 0)
            dl:AddText(P(wp.x + 62, wp.y + 12), rhAlpha(C.green, a), u8("Новость от разработчика"))
            local lines = rhWrapLines(u8(notif.text or ""), W - 80)
            local lineH = imgui.CalcTextSize("Ag").y + 2
            dl:PushClipRect(P(wp.x + 62, wp.y + 32), P(wp.x + W - 12, wp.y + H - 6), true)
            for k = 1, math.min(#lines, 3) do
                local line = lines[k]
                if k == 3 and #lines > 3 then line = line .. "..." end
                dl:AddText(P(wp.x + 62, wp.y + 34 + (k - 1) * lineH), rhAlpha(0xFFFFFFFF, a), line)
            end
            dl:PopClipRect()
            imgui.End(); imgui.PopStyleColor(2); imgui.PopStyleVar(2)
        end
    end
end
rhWrapCache = {}
function rhWrapLines(text, maxW)
    local key = math.floor(maxW) .. "|" .. text
    local cached = rhWrapCache[key]
    if cached then return cached end
    local lines = {}
    for paragraph in (text .. "\n"):gmatch("(.-)\n") do
        local line = ""
        for word in paragraph:gmatch("%S+") do
            local try = (line == "") and word or (line .. " " .. word)
            if line ~= "" and imgui.CalcTextSize(try).x > maxW then
                table.insert(lines, line)
                line = word
            else
                line = try
            end
        end
        table.insert(lines, line)
    end
    rhWrapCache[key] = lines
    return lines
end
notifCardHoveredGlobal = false
function drawNotificationHistoryPopup()
    if not notifHistoryPopupOpen then notifCardHoveredGlobal = false; return end
    if not mainWinPos then return end
    local function P(x, y) return imgui.ImVec2(x, y) end
    local theme
    if useCustomTheme then
        theme = CUSTOM_THEME
    else
        theme = THEME_CONFIGS[currentTheme] or THEME_CONFIGS[THEMES.DEFAULT]
    end
    if not theme then theme = THEME_CONFIGS[THEMES.DEFAULT] end
    local accentHex = getColorHex(theme.accent)
    local cardW, cardH = 280, 272
    local cardX = mainWinPos.x + 1020 + 5
    local cardY = mainWinPos.y + 348
    imgui.SetNextWindowPos(imgui.ImVec2(cardX, cardY), imgui.Cond.Always)
    imgui.SetNextWindowSize(imgui.ImVec2(cardW, cardH), imgui.Cond.Always)
    imgui.PushStyleVar(imgui.StyleVar.WindowPadding, imgui.ImVec2(0, 0))
    imgui.PushStyleVar(imgui.StyleVar.WindowRounding, 14)
    imgui.PushStyleColor(imgui.Col.WindowBg, imgui.ImVec4(0, 0, 0, 0))
    imgui.PushStyleColor(imgui.Col.Border, imgui.ImVec4(0, 0, 0, 0))
    imgui.Begin(u8("##notif_history_card"), nil, imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar)
    local winPos = imgui.GetWindowPos()
    local drawList = imgui.GetWindowDrawList()
    local mp = imgui.GetMousePos()
    local cX, cY = winPos.x, winPos.y
    local function inRect(x, y, w, h) return mp.x >= x and mp.x <= x + w and mp.y >= y and mp.y <= y + h end
    local cardHovered = imgui.IsMouseHoveringRect(winPos, imgui.ImVec2(winPos.x + cardW, winPos.y + cardH), false)
    notifCardHoveredGlobal = cardHovered
    if imgui.IsMouseClicked(0) and not notifBellHoveredGlobal and not cardHovered then
        notifHistoryPopupOpen = false
    end
    rhCardBox(drawList, cX, cY, cardW, cardH, 0xFF181818, 0xFF2E2E2E, 14)
    local headH = 48
    drawList:AddRectFilled(P(cX + 1, cY + 1), P(cX + cardW - 1, cY + headH), rhAlpha(accentHex, 0.10), 13, 3)
    drawList:AddLine(P(cX, cY + headH), P(cX + cardW, cY + headH), 0xFF2A2A2A, 1.0)
    rhIconBadge(drawList, cX + 28, cY + headH / 2, 13, fa.ICON_BELL, accentHex, 0xFF181818, 0)
    local titleStr = u8("Уведомления")
    drawList:AddText(P(cX + 52, cY + (headH - 14) / 2), 0xFFFFFFFF, titleStr)
    if #announcementHistory > 0 then
        rhPill(drawList, cX + 52 + imgui.CalcTextSize(titleStr).x + 8, cY + (headH - 22) / 2, tostring(#announcementHistory), 0xFF999999)
    end
    local closeR = 12
    local closeC = P(cX + cardW - 16 - closeR, cY + headH / 2)
    local closeHov = inRect(closeC.x - closeR, closeC.y - closeR, closeR * 2, closeR * 2)
    local closeA = rhAnim("notif_close", closeHov and 1 or 0)
    drawList:AddCircleFilled(closeC, closeR, rhLerpColor(0xFF202020, 0xFF3A2424, closeA), 24)
    local xSz = imgui.CalcTextSize(fa.ICON_TIMES)
    drawList:AddText(P(closeC.x - xSz.x / 2, closeC.y - xSz.y / 2), rhLerpColor(0xFF999999, 0xFF5A5AF0, closeA), fa.ICON_TIMES)
    imgui.SetCursorScreenPos(P(closeC.x - closeR, closeC.y - closeR))
    if imgui.InvisibleButton("##notifhistory_close", imgui.ImVec2(closeR * 2, closeR * 2)) then
        notifHistoryPopupOpen = false
    end
    local chipsY = cY + headH + 10
    local chipW = (cardW - 24 - 12) / 3
    local chips = {
        {label = u8("Предметы"), value = tostring(scanSummary.itemsDBCount or 0), col = 0xFFEEEEEE},
        {label = "BTC / ASC", value = (scanSummary.btc or 0) .. " / " .. (scanSummary.asc or 0), col = 0xFF38C8F8},
        {label = u8("Талоны"), value = tostring(scanSummary.azTalon or 0), col = 0xFF00D7FF},
    }
    for i, ch in ipairs(chips) do
        local x = cX + 12 + (i - 1) * (chipW + 6)
        rhCardBox(drawList, x, chipsY, chipW, 40, 0xFF1C1C1C, 0xFF2C2C2C, 10)
        drawList:PushClipRect(P(x + 2, chipsY), P(x + chipW - 2, chipsY + 40), true)
        drawList:AddText(P(x + 10, chipsY + 5), 0xFF777777, ch.label)
        drawList:AddText(P(x + 10, chipsY + 21), ch.col, ch.value)
        drawList:PopClipRect()
    end
    local baseWorkName = "-"
    if scanSummary.baseWorkType == WORK_TYPES.FARM then baseWorkName = u8("Ферма")
    elseif scanSummary.baseWorkType == WORK_TYPES.MINE then baseWorkName = u8("Шахта")
    elseif scanSummary.baseWorkType == WORK_TYPES.SAWMILL then baseWorkName = u8("Лесопилка") end
    if inRect(cX + 12, chipsY, cardW - 24, 40) and ((#scanSummary.baseItems > 0) or baseWorkName ~= "-") then
        rhTipBegin()
        imgui.Text(u8("База: ") .. baseWorkName)
        for _, msg in ipairs(scanSummary.baseItems) do
            imgui.Text(u8(msg))
        end
        rhTipEnd()
    end
    local listY = chipsY + 40 + 10
    imgui.SetCursorScreenPos(P(cX + 12, listY))
    imgui.PushStyleColor(imgui.Col.ScrollbarBg, imgui.ImVec4(0, 0, 0, 0))
    imgui.PushStyleColor(imgui.Col.ScrollbarGrab, imgui.ImVec4(0.22, 0.22, 0.22, 1))
    imgui.BeginChild("##notifhistory_scroll", imgui.ImVec2(cardW - 24, cY + cardH - 10 - listY), false)
    local cd = imgui.GetWindowDrawList()
    local itemW = imgui.GetWindowWidth() - 12
    local lineH = imgui.CalcTextSize("Ag").y + 2
    if #announcementHistory == 0 then
        local sp = imgui.GetCursorScreenPos()
        local ew = imgui.GetWindowWidth()
        local c = P(sp.x + ew / 2, sp.y + 40)
        cd:AddCircleFilled(c, 22, rhAlpha(0xFF888888, 0.10), 32)
        local bs = imgui.CalcTextSize(fa.ICON_BELL)
        cd:AddText(P(c.x - bs.x / 2, c.y - bs.y / 2), 0xFF777777, fa.ICON_BELL)
        local es = u8("Уведомлений пока не было")
        cd:AddText(P(sp.x + (ew - imgui.CalcTextSize(es).x) / 2, c.y + 32), 0xFF777777, es)
        imgui.Dummy(imgui.ImVec2(ew, 90))
    else
        for i, item in ipairs(announcementHistory) do
            local sp = imgui.GetCursorScreenPos()
            local imp = item.important
            local col = imp and 0xFF3399E6 or accentHex
            local lines = rhWrapLines(u8(item.text or ""), itemW - 30)
            local h = 34 + #lines * lineH + 8
            cd:AddRectFilled(sp, P(sp.x + itemW, sp.y + h), 0xFF1C1C1C, 10)
            cd:AddRect(sp, P(sp.x + itemW, sp.y + h), 0xFF2C2C2C, 10, 15, 1.0)
            cd:AddRectFilled(P(sp.x + 8, sp.y + 10), P(sp.x + 11, sp.y + h - 10), rhAlpha(col, 0.9), 2)
            cd:AddText(P(sp.x + 20, sp.y + 9), col, imp and fa.ICON_EXCLAMATION_TRIANGLE or fa.ICON_COMMENT)
            cd:AddText(P(sp.x + 40, sp.y + 9), imp and 0xFF3399E6 or 0xFFBBBBBB, imp and u8("Важное") or u8("Новость"))
            local dateStr = os.date("%d.%m %H:%M", item.time or os.time())
            cd:AddText(P(sp.x + itemW - 12 - imgui.CalcTextSize(dateStr).x, sp.y + 9), 0xFF777777, dateStr)
            for k, line in ipairs(lines) do
                cd:AddText(P(sp.x + 20, sp.y + 30 + (k - 1) * lineH), 0xFFDDDDDD, line)
            end
            imgui.Dummy(imgui.ImVec2(itemW, h + 8))
        end
    end
    rhTipFlush()
    imgui.EndChild()
    imgui.PopStyleColor(2)
    imgui.End()
    imgui.PopStyleVar(2)
    imgui.PopStyleColor(2)
end
function drawDevImportantPopup()
    if not devImportantCurrent and #devImportantQueue > 0 then
        devImportantCurrent = table.remove(devImportantQueue, 1)
        imgui.OpenPopup(u8("Важная новость##devimportant"))
        imgui.ShowCursor = true
    end
    if devImportantCurrent then
        if rhPopupBegin(u8("Важная новость##devimportant")) then
            local P = imgui.ImVec2
            local C = PD.C
            local W = 440
            local warn = 0xFF3399E6
            local dl = imgui.GetWindowDrawList()
            rhPopupHeader(dl, W, fa.ICON_EXCLAMATION_TRIANGLE, warn, u8("Важная новость"), u8("Сообщение от разработчика"), nil)
            local bg, brd = homeCardColors()
            local lines = rhWrapLines(u8(devImportantCurrent.text or ""), W - 40)
            local lineH = imgui.CalcTextSize("Ag").y + 3
            local th = #lines * lineH + 24
            local cp = imgui.GetCursorScreenPos()
            rhCardBox(dl, cp.x, cp.y, W, th, bg, brd, 10)
            dl:AddRectFilled(P(cp.x + 8, cp.y + 10), P(cp.x + 11, cp.y + th - 10), rhAlpha(warn, 0.9), 2)
            for k, line in ipairs(lines) do
                dl:AddText(P(cp.x + 22, cp.y + 12 + (k - 1) * lineH), 0xFFDDDDDD, line)
            end
            imgui.SetCursorScreenPos(P(cp.x, cp.y + th + 8))
            imgui.Dummy(P(W, 1))
            imgui.Spacing()
            local bp = imgui.GetCursorScreenPos()
            local by = bp.y + 6
            if WK.button(dl, "##devimp_ok", bp.x, by, W, 38, u8("Понятно"), fa.ICON_CHECK, C.green, true) then
                imgui.CloseCurrentPopup()
                devImportantCurrent = nil
                if not mainWin.v then imgui.ShowCursor = false end
            end
            imgui.SetCursorScreenPos(P(bp.x, by + 38))
            imgui.Dummy(P(W, 2))
            rhPopupEnd()
        end
    end
end
function drawMainMenu()
    local theme
    if useCustomTheme then
        theme = CUSTOM_THEME
    else
        theme = THEME_CONFIGS[currentTheme] or THEME_CONFIGS[THEMES.DEFAULT]
    end
    if not theme then theme = THEME_CONFIGS[THEMES.DEFAULT] end
    
    function getColorHex(colorValue)
        if useCustomTheme then
            return imVec4ToHex(colorValue)
        else
            if type(colorValue) == "number" then
                return colorValue
            else
                return imVec4ToHex(colorValue)
            end
        end
    end
     
    local sw, sh = getScreenResolution()
    imgui.SetNextWindowSize(imgui.ImVec2(1020, 620), imgui.Cond.Always)
    if not mainWinPosInitialized then
        mainWinPos.x = sw / 2 - 510
        mainWinPos.y = sh / 2 - 310
        mainWinPosInitialized = true
    end
    imgui.SetNextWindowPos(imgui.ImVec2(mainWinPos.x, mainWinPos.y), imgui.Cond.Always)
    
    imgui.PushStyleVar(imgui.StyleVar.WindowPadding, imgui.ImVec2(4, 4))
    imgui.PushStyleColor(imgui.Col.Border, imgui.ImVec4(0, 0, 0, 0))
    imgui.PushStyleColor(imgui.Col.WindowBg, imgui.ImVec4(0, 0, 0, 0))
    
    local title = u8("Resource Helper v" .. scr.version)
    if newversion ~= scr.version then
        title = title .. u8(" (обновление!)")
    end
    
    imgui.Begin(title, mainWin, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoBringToFrontOnFocus)
    
    if not changelogShown then
        if changelogData then
            imgui.OpenPopup(u8("Что нового?##changelog"))
        else
            downloadChangelog()
        end
    end
    if rhPopupBegin(u8("Что нового?##changelog")) then
        local P = imgui.ImVec2
        local C = PD.C
        local W = 480
        local dl = imgui.GetWindowDrawList()
        rhPopupHeader(dl, W, fa.ICON_STAR, C.green, u8("Обновление до версии " .. scr.version), u8("Что изменилось в этой версии"), u8("v" .. scr.version))
        local bg, brd = homeCardColors()
        local sp = imgui.GetCursorScreenPos()
        local listH = 260
        rhCardBox(dl, sp.x, sp.y, W, listH, bg, brd, 10)
        imgui.PushStyleColor(imgui.Col.ScrollbarBg, imgui.ImVec4(0, 0, 0, 0))
        imgui.PushStyleColor(imgui.Col.ScrollbarGrab, imgui.ImVec4(0.22, 0.22, 0.22, 1))
        imgui.BeginChild("##changelog_scroll", P(W, listH), false)
        local cd = imgui.GetWindowDrawList()
        local lineH = imgui.CalcTextSize("Ag").y + 3
        local textW = W - 62
        imgui.Dummy(P(1, 6))
        if changelogData and changelogData[scr.version] then
            for _, change in ipairs(changelogData[scr.version]) do
                local lines = rhWrapLines(u8(change), textW)
                local p = imgui.GetCursorScreenPos()
                cd:AddCircleFilled(P(p.x + 16, p.y + lineH / 2), 3, C.green, 12)
                for k, line in ipairs(lines) do
                    cd:AddText(P(p.x + 30, p.y + (k - 1) * lineH), 0xFFDDDDDD, line)
                end
                imgui.Dummy(P(1, #lines * lineH + 8))
            end
        else
            local p = imgui.GetCursorScreenPos()
            cd:AddText(P(p.x + 16, p.y), C.mute, u8("Список изменений загружается..."))
            imgui.Dummy(P(1, lineH))
        end
        imgui.EndChild()
        imgui.PopStyleColor(2)
        imgui.Spacing()
        local bp = imgui.GetCursorScreenPos()
        local by = bp.y + 6
        if WK.button(dl, "##changelog_ok", bp.x, by, W, 38, u8("Понятно"), fa.ICON_CHECK, C.green, true) then
            markChangelogAsShown()
            imgui.CloseCurrentPopup()
        end
        imgui.SetCursorScreenPos(P(bp.x, by + 38))
        imgui.Dummy(P(W, 2))
        rhPopupEnd()
    end
    
    local winPos = imgui.GetWindowPos()
    local winSize = imgui.GetWindowSize()
    local drawList = imgui.GetWindowDrawList()
    headerWinPos = winPos
    headerWinSize = winSize
    
    local titleBarHeight = 45
    if imgui.IsMouseHoveringRect(winPos, imgui.ImVec2(winPos.x + winSize.x, winPos.y + titleBarHeight), false) then
        if imgui.IsMouseDown(0) then
            local mousePos = imgui.GetMousePos()
            if not dragStartPos then
                dragStartPos = { x = mousePos.x - winPos.x, y = mousePos.y - winPos.y }
            end
            mainWinPos.x = mousePos.x - dragStartPos.x
            mainWinPos.y = mousePos.y - dragStartPos.y
        else
            dragStartPos = nil
        end
    else
        dragStartPos = nil
    end
    
    local leftPanelWidth = 190
    local R = 14
    local mouse = imgui.GetMousePos()
    local function P(x, y) return imgui.ImVec2(x, y) end
    local accent = getColorHex(theme.accent)
    local borderCol = getColorHex(theme.borderColor)
    drawList:AddRectFilled(winPos, P(winPos.x + winSize.x, winPos.y + winSize.y), getColorHex(theme.windowBg), R)
    drawList:AddRectFilled(winPos, P(winPos.x + leftPanelWidth, winPos.y + winSize.y), getColorHex(theme.leftPanelBg), R, 9)
    drawList:AddLine(P(winPos.x + leftPanelWidth, winPos.y + 16), P(winPos.x + leftPanelWidth, winPos.y + winSize.y - 16), borderCol, 1.0)
    drawList:AddLine(P(winPos.x + leftPanelWidth + 16, winPos.y + 45), P(winPos.x + winSize.x - 16, winPos.y + 45), borderCol, 1.0)
    drawList:AddRect(winPos, P(winPos.x + winSize.x, winPos.y + winSize.y), borderCol, R, 15, 1.0)
    do
        local lx, ly = winPos.x + 14, winPos.y + 9
        drawList:AddRectFilled(P(lx, ly), P(lx + 28, ly + 28), rhAlpha(accent, 0.16), 9)
        drawList:AddRect(P(lx, ly), P(lx + 28, ly + 28), rhAlpha(accent, 0.45), 9, 15, 1.0)
        local wrSz = imgui.CalcTextSize(fa.ICON_WRENCH)
        drawList:AddText(P(lx + 14 - wrSz.x / 2, ly + 14 - wrSz.y / 2), accent, fa.ICON_WRENCH)
        drawList:AddText(P(lx + 38, ly + 7), accent, "Resource Helper")
    end
    local function headerButton(id, cx, cy, icon, hoverCol, onClick)
        local r = 13
        local hov = mouse.x >= cx - r and mouse.x <= cx + r and mouse.y >= cy - r and mouse.y <= cy + r
        local a = rhAnim("hdr_" .. id, hov and 1 or 0)
        drawList:AddCircleFilled(P(cx, cy), r, rhLerpColor(0xFF222222, rhLerpColor(0xFF222222, hoverCol, 0.35), a), 24)
        drawList:AddCircle(P(cx, cy), r, rhLerpColor(0xFF333333, hoverCol, 0.7 * a), 24, 1.0)
        local sz = imgui.CalcTextSize(icon)
        drawList:AddText(P(cx - sz.x / 2, cy - sz.y / 2), rhLerpColor(0xFF999999, 0xFFFFFFFF, a), icon)
        imgui.SetCursorScreenPos(P(cx - r, cy - r))
        if imgui.InvisibleButton("##" .. id, imgui.ImVec2(r * 2, r * 2)) then onClick() end
    end
    headerButton("reload_btn", winPos.x + winSize.x - 58, winPos.y + 22, fa.ICON_REPEAT, accent,
        function() consumeWindowMessage(true, false); showCursor(false); scr:reload() end)
    headerButton("close_btn", winPos.x + winSize.x - 24, winPos.y + 22, fa.ICON_TIMES, 0xFF4A4AE0,
        function() mainWin.v = false; imgui.ShowCursor = false end)
    
    local _t0 = os.clock()
    drawMenuButtons(winPos, winSize, leftPanelWidth, theme)
    local _t1 = os.clock()
    drawRightPanelContent(winPos, leftPanelWidth, winSize, theme)
    local _t2 = os.clock()
    RH_PERF = RH_PERF or {n = 0, menu = 0, panel = 0}
    RH_PERF.n = RH_PERF.n + 1
    RH_PERF.menu = RH_PERF.menu + (_t1 - _t0)
    RH_PERF.panel = RH_PERF.panel + (_t2 - _t1)
    if RH_PERF.n >= 240 then
        print(string.format("[ResHelper PERF] tab=%s sidebar=%.2fms panel=%.2fms",
            tostring(currentTab), RH_PERF.menu / RH_PERF.n * 1000, RH_PERF.panel / RH_PERF.n * 1000))
        RH_PERF.n, RH_PERF.menu, RH_PERF.panel = 0, 0, 0
    end
    
    local menuTitles = {
        [1] = u8("Главная"),
        [2] = u8("Ферма"),
        [3] = u8("Шахта"),
        [4] = u8("Лесопилка"),
        [5] = u8("Сторонний доход"),
        [6] = u8("Рейтинг"),
        [7] = u8("Цели"),
        [8] = u8("Достижения"),
        [9] = u8("Биндер"),
        [10] = u8("Настройки"),
        [11] = u8("О скрипте"),
        [12] = u8("Нефтевышки"),
        [13] = u8("Полезные функции"),
        [14] = u8("Автопиар"),
		[15] = u8("Фильтр чата"),
        [16] = u8("Пейдеи"),
        [17] = u8("Аренда (IM)"),
        [18] = u8("Осколки"),
        [19] = u8("Кейсы"),
        [20] = u8("Криптовалюта"),
        [21] = u8("Такси"),
        [23] = u8("Инкассатор"),
        [24] = u8("NFT контейнеры"),
        [22] = u8("Работы"),
    }
    local menuIcons = {
        [1] = fa.ICON_HOME,
        [2] = fa.ICON_LEAF,
        [3] = fa.ICON_GAVEL,
        [4] = fa.ICON_TREE,
        [5] = fa.ICON_SHOPPING_CART,
        [6] = fa.ICON_TROPHY,
        [7] = fa.ICON_BULLSEYE,
        [8] = fa.ICON_STAR,
        [9] = fa.ICON_KEYBOARD_O,
        [10] = fa.ICON_WRENCH,
        [11] = fa.ICON_INFO_CIRCLE,
        [12] = fa.ICON_FIRE,
        [13] = fa.ICON_BRIEFCASE,
        [14] = fa.ICON_BULLHORN,
        [15] = fa.ICON_FILTER,
        [16] = fa.ICON_MONEY,
        [17] = fa.ICON_SHOPPING_CART,
        [18] = fa.ICON_STAR,
        [19] = fa.ICON_BRIEFCASE,
        [20] = fa.ICON_USD,
        [21] = fa.ICON_TAXI,
        [23] = fa.ICON_MONEY,
        [24] = fa.ICON_BRIEFCASE,
        [22] = fa.ICON_BRIEFCASE,
    }
    local headerText = menuTitles[currentTab] or ""
    local headerIcon = menuIcons[currentTab] or fa.ICON_HOME
    local titleCol = useCustomTheme and imVec4ToHex(CUSTOM_THEME.contentText) or 0xFFFFFFFF
    local tx0 = winPos.x + leftPanelWidth + 20
    local hcy = winPos.y + 22
    drawList:AddCircleFilled(P(tx0 + 13, hcy), 13, rhAlpha(accent, 0.16), 24)
    drawList:AddCircle(P(tx0 + 13, hcy), 13, rhAlpha(accent, 0.5), 24, 1.0)
    local hiSz = imgui.CalcTextSize(headerIcon)
    drawList:AddText(P(tx0 + 13 - hiSz.x / 2, hcy - hiSz.y / 2), accent, headerIcon)
    local htSz = imgui.CalcTextSize(headerText)
    drawList:AddText(P(tx0 + 34, hcy - htSz.y / 2), titleCol, headerText)
    if currentTab == 9 or currentTab == 14 or currentTab == 15 or currentTab == 16 or currentTab == 17 or currentTab == 18 or currentTab == 19 or currentTab == 20
       or currentTab == 2 or currentTab == 3 or currentTab == 4 or currentTab == 12 or currentTab == 21 or currentTab == 23 or currentTab == 24 then
        local backTarget
        if currentTab == 9 or currentTab == 14 or currentTab == 15 then backTarget = 13
        elseif currentTab == 2 or currentTab == 3 or currentTab == 4 or currentTab == 12 or currentTab == 21 or currentTab == 23 then backTarget = 22
        else backTarget = 5 end
        local bw, bh = 86, 26
        local bx = tx0 + 34 + htSz.x + 18
        local by = hcy - bh / 2
        local bHov = (mouse.x >= bx and mouse.x <= bx + bw and mouse.y >= by and mouse.y <= by + bh)
        local ba = rhAnim("hdr_back", bHov and 1 or 0)
        drawList:AddRectFilled(P(bx, by), P(bx + bw, by + bh), rhLerpColor(0xFF1E1E1E, rhLerpColor(0xFF1E1E1E, accent, 0.18), ba), bh / 2)
        drawList:AddRect(P(bx, by), P(bx + bw, by + bh), rhLerpColor(0xFF333333, accent, 0.7 * ba), bh / 2, 15, 1.0)
        local backLabel = fa.ICON_ANGLE_LEFT .. u8("  Назад")
        local backSz = imgui.CalcTextSize(backLabel)
        drawList:AddText(P(bx + (bw - backSz.x) / 2, by + (bh - backSz.y) / 2), rhLerpColor(0xFFAAAAAA, accent, ba), backLabel)
        imgui.SetCursorScreenPos(P(bx, by))
        if imgui.InvisibleButton("##funchub_back", imgui.ImVec2(bw, bh)) then
            currentTab = backTarget
        end
    end
    
    if not homeDashCache or os.clock() - homeDashCacheTime > 15 then
        refreshHomeDashboard()
    end
    if not lbEnabledCacheTime or os.clock() - lbEnabledCacheTime > 15 then
        lbEnabledCache = getLbEnabled()
        lbEnabledCacheTime = os.clock()
    end
    
    local tgOk = tgConfig.enabled and tgConfig.botToken ~= "" and tgConfig.chatId ~= ""
    local lbOk = lbEnabledCache
    
    local avatarCX = winPos.x + winSize.x - 92
    local avatarCY = winPos.y + 22
    local avatarR = 14
    local avatarHovered = imgui.IsMouseHoveringRect(P(avatarCX - avatarR, avatarCY - avatarR), P(avatarCX + avatarR, avatarCY + avatarR), false)
    avatarHoveredGlobal = avatarHovered
    local aa = rhAnim("hdr_avatar", (avatarHovered or profilePopupOpen) and 1 or 0)
    drawList:AddCircleFilled(P(avatarCX, avatarCY), avatarR, rhLerpColor(0xFF222222, accent, aa), 24)
    drawList:AddCircle(P(avatarCX, avatarCY), avatarR + 3, rhAlpha(accent, 0.12 + 0.5 * aa), 28, 1.5)
    local userIconSz = imgui.CalcTextSize(fa.ICON_USER)
    drawList:AddText(P(avatarCX - userIconSz.x / 2, avatarCY - userIconSz.y / 2), rhLerpColor(0xFFCCCCCC, 0xFF0A0A0A, aa), fa.ICON_USER)
    local statusDotColor = (tgOk or lbOk) and 0xFF33CC66 or 0xFF666666
    if getUnreadAnnouncementCount() > 0 then
        local blinkOn = math.floor(os.clock() * 2) % 2 == 0
        if blinkOn then statusDotColor = 0xFF4A4AE0 end
    end
    drawList:AddCircleFilled(P(avatarCX + avatarR - 3, avatarCY + avatarR - 3), 4, 0xFF141414, 12)
    drawList:AddCircleFilled(P(avatarCX + avatarR - 3, avatarCY + avatarR - 3), 3, statusDotColor, 12)
    imgui.SetCursorScreenPos(P(avatarCX - avatarR, avatarCY - avatarR))
    if imgui.InvisibleButton("##profile_chip", imgui.ImVec2(avatarR * 2, avatarR * 2)) then
        profilePopupOpen = not profilePopupOpen
    end
    
    if windowAnimAlpha < 1.0 then
        local maskColor = applyAlpha(getColorHex(theme.windowBg), 1.0 - windowAnimAlpha)
        drawList:AddRectFilled(winPos, imgui.ImVec2(winPos.x + winSize.x, winPos.y + winSize.y), maskColor, 14)
    end
    
    rhTipFlush()
    imgui.End()
    imgui.PopStyleColor(2)
    imgui.PopStyleVar(1)
end
function drawMenuButtons(winPos, winSize, leftPanelWidth, theme)
    local menuItems = {
        {header = u8("Основное:")},
        {title = u8("Главная"), icon = fa.ICON_HOME, id = 1},
        {title = u8("Рейтинг"), icon = fa.ICON_TROPHY, id = 6},
        {title = u8("Достижения"), icon = fa.ICON_STAR, id = 8},
        {title = u8("О скрипте"), icon = fa.ICON_INFO_CIRCLE, id = 11},
        {header = u8("Работы/доход:")},
        {title = u8("Работы"), icon = fa.ICON_BRIEFCASE, id = 22},
        {title = u8("Сторонний доход"), icon = fa.ICON_SHOPPING_CART, id = 5},
        {header = u8("Функции:")},
        {title = u8("Полезные функции"), icon = fa.ICON_BRIEFCASE, id = 13},
        {title = u8("Настройки"), icon = fa.ICON_WRENCH, id = 10},
        {title = u8("Цели"), icon = fa.ICON_BULLSEYE, id = 7},
    }
    local drawList = imgui.GetWindowDrawList()
    local mouse = imgui.GetMousePos()
    local function P(x, y) return imgui.ImVec2(x, y) end
    local accent = getColorHex(theme.accent)
    local topAreaEnd = winPos.y + 43
    local footerHeight = 40
    local headerHeight = 16; local spacing = 1
    local totalButtons, totalHeaders = 0, 0
    for _, item in ipairs(menuItems) do
        if item.header then totalHeaders = totalHeaders + 1 else totalButtons = totalButtons + 1 end
    end
    local availableHeight = winSize.y - 43 - footerHeight
    local btnHeight = (availableHeight - totalHeaders * (headerHeight + 6)) / totalButtons - spacing
    btnHeight = math.max(30, math.min(38, btnHeight))
    local function isTabActive(id)
        if id == currentTab then return true end
        if id == 13 and (currentTab == 9 or currentTab == 14 or currentTab == 15) then return true end
        if id == 22 and (currentTab == 2 or currentTab == 3 or currentTab == 4 or currentTab == 12 or currentTab == 21 or currentTab == 23) then return true end
        if id == 5 and (currentTab == 16 or currentTab == 17 or currentTab == 18 or currentTab == 19 or currentTab == 20 or currentTab == 24) then return true end
        return false
    end
    local actualBtnIdx = 0; local headerOffset = 0
    local targetHighlightY = nil
    for idx, item in ipairs(menuItems) do
        if item.header then
            headerOffset = headerOffset + headerHeight + 6
        else
            local btnPosY = topAreaEnd + actualBtnIdx * (btnHeight + spacing) + headerOffset
            if isTabActive(item.id) then targetHighlightY = btnPosY - winPos.y end
            actualBtnIdx = actualBtnIdx + 1
        end
    end
    menuHighlightY = menuHighlightY or targetHighlightY
    menuHighlightTargetY = menuHighlightTargetY or targetHighlightY
    if targetHighlightY and math.abs(targetHighlightY - menuHighlightTargetY) > 0.01 then
        menuHighlightFromY = menuHighlightY
        menuHighlightTargetY = targetHighlightY
        menuHighlightAnimStart = os.clock()
    end
    if menuHighlightTargetY then
        if settings.smoothMenuEnabled then
            local t = math.min((os.clock() - menuHighlightAnimStart) / MENU_HIGHLIGHT_ANIM_DURATION, 1.0)
            t = t < 0.5 and (4 * t * t * t) or (1 - ((-2 * t + 2) ^ 3) / 2)
            local fromY = menuHighlightFromY or menuHighlightTargetY
            menuHighlightY = fromY + (menuHighlightTargetY - fromY) * t
        else
            menuHighlightY = menuHighlightTargetY
        end
    end
    if menuHighlightY then
        local hlX = winPos.x + 7
        local hlY = winPos.y + menuHighlightY
        local borderAct = imVec4ToHex(theme.borderActive)
        drawList:AddRectFilled(P(hlX, hlY), P(hlX + 178, hlY + btnHeight), imVec4ToHex(theme.buttonActive), 10)
        drawList:AddRect(P(hlX, hlY), P(hlX + 178, hlY + btnHeight), rhAlpha(borderAct, 0.55), 10, 15, 1.0)
        drawList:AddRectFilled(P(hlX + 3, hlY + 9), P(hlX + 6, hlY + btnHeight - 9), borderAct, 2)
    end
    actualBtnIdx = 0; headerOffset = 0
    for idx, item in ipairs(menuItems) do
        if item.header then
            local headerPosY = topAreaEnd + actualBtnIdx * (btnHeight + spacing) + headerOffset + 5
            drawList:AddText(P(winPos.x + 16, headerPosY), 0x66FFFFFF, item.header)
            local hw = imgui.CalcTextSize(item.header).x
            drawList:AddLine(P(winPos.x + 16 + hw + 8, headerPosY + 7), P(winPos.x + leftPanelWidth - 14, headerPosY + 7), 0x1AFFFFFF, 1.0)
            headerOffset = headerOffset + headerHeight + 6
        else
            local isActive = isTabActive(item.id)
            local btnPosX = winPos.x + 7
            local btnPosY = topAreaEnd + actualBtnIdx * (btnHeight + spacing) + headerOffset
            local btnHovered = (mouse.x >= btnPosX and mouse.x <= btnPosX + 178 and mouse.y >= btnPosY and mouse.y <= btnPosY + btnHeight)
            local hTarget = (btnHovered and not isActive) and 1 or 0
            local ha = settings.smoothMenuEnabled and rhAnim("nav_" .. item.id, hTarget, 16) or hTarget
            if ha > 0.01 then
                local hb = imVec4ToHex(theme.buttonHover)
                local hbA = (math.floor(hb / 16777216) % 256) / 255
                drawList:AddRectFilled(P(btnPosX, btnPosY), P(btnPosX + 178, btnPosY + btnHeight), rhAlpha(hb, hbA * ha), 10)
                local barH = (btnHeight - 18) * ha
                local barY = btnPosY + (btnHeight - barH) / 2
                drawList:AddRectFilled(P(btnPosX + 3, barY), P(btnPosX + 6, barY + barH), rhAlpha(imVec4ToHex(theme.borderActive), ha), 2)
            end
            local colN, colH, colA = imVec4ToHex(theme.textNormal), imVec4ToHex(theme.textHover), imVec4ToHex(theme.textActive)
            local textColHex = isActive and colA or rhLerpColor(colN, colH, ha)
            local iconColHex = isActive and colA or rhLerpColor(textColHex, imVec4ToHex(theme.borderActive), 0.8 * ha)
            local iconH = 14
            local textH = imgui.CalcTextSize(item.title).y
            local sTarget = (btnHovered and not isActive) and 1 or 0
            local sa = settings.smoothMenuEnabled and rhAnim("navs_" .. item.id, sTarget, 7) or sTarget
            sa = sa * sa * (3 - 2 * sa)
            local iconX = math.floor(btnPosX + 14 + 3 * sa + 0.5)
            local textX = math.floor(btnPosX + 46 + 4 * sa + 0.5)
            drawList:AddText(P(iconX, btnPosY + (btnHeight - iconH) / 2), iconColHex, item.icon)
            drawList:AddText(P(textX, btnPosY + (btnHeight - textH) / 2), textColHex, item.title)
            if btnHovered and imgui.IsMouseClicked(0) then
                if not scanState.active or scanState.isTalonScan then
                    currentTab = item.id
                    if item.id == 2 then
                        switchWorkType(WORK_TYPES.FARM); workTypeSelected = true
                        if not scannedThisSession[WORK_TYPES.FARM] then pendingScan = WORK_TYPES.FARM end
                    elseif item.id == 3 then
                        switchWorkType(WORK_TYPES.MINE); workTypeSelected = true
                        if not scannedThisSession[WORK_TYPES.MINE] then pendingScan = WORK_TYPES.MINE end
                    elseif item.id == 4 then
                        switchWorkType(WORK_TYPES.SAWMILL); workTypeSelected = true
                        if not scannedThisSession[WORK_TYPES.SAWMILL] then pendingScan = WORK_TYPES.SAWMILL end
                    end
                end
            end
            actualBtnIdx = actualBtnIdx + 1
        end
    end
    if newversion ~= "" and newversion ~= scr.version then
        local ux, uy, uw, uh = winPos.x + 10, winPos.y + winSize.y - 36, leftPanelWidth - 20, 26
        local uHov = (mouse.x >= ux and mouse.x <= ux + uw and mouse.y >= uy and mouse.y <= uy + uh)
        local ua = rhAnim("nav_update", uHov and 1 or 0)
        drawList:AddRectFilled(P(ux, uy), P(ux + uw, uy + uh), rhAlpha(accent, 0.12 + 0.10 * ua), 13)
        drawList:AddRect(P(ux, uy), P(ux + uw, uy + uh), rhAlpha(accent, 0.45 + 0.4 * ua), 13, 15, 1.0)
        local ut = u8("Обновление v") .. newversion
        local usz = imgui.CalcTextSize(ut)
        drawList:AddText(P(ux + (uw - usz.x) / 2, uy + (uh - usz.y) / 2), accent, ut)
        if uHov and imgui.IsMouseClicked(0) then currentTab = 11 end
    else
        rhPill(drawList, winPos.x + 14, winPos.y + winSize.y - 34, "v" .. scr.version, 0xFF888888)
    end
end
function drawRightPanelContent(winPos, leftPanelWidth, winSize, theme)
    imgui.SetCursorPos(imgui.ImVec2(leftPanelWidth + 15, 55))
    local childX = winPos.x + leftPanelWidth + 15; local childY = winPos.y + 55
    local childW = winSize.x - leftPanelWidth - 30; local childH = winSize.y - 65
    imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(childX, childY), imgui.ImVec2(childX + childW, childY + childH), imVec4ToHex(theme.childBg), 4)
    local rpFlags = imgui.WindowFlags.NoScrollbar
    if RI and RI.tableHover then rpFlags = rpFlags + (imgui.WindowFlags.NoScrollWithMouse or 0) end
    if RI then RI.tableHover = false end
    imgui.BeginChild("right_panel", imgui.ImVec2(childW, childH), false, rpFlags)
    
    if useCustomTheme then
        local style = imgui.GetStyle(); local colors = style.Colors; local clr = imgui.Col
        colors[clr.Text] = CUSTOM_THEME.contentText; colors[clr.Button] = CUSTOM_THEME.imguiButton
        colors[clr.ButtonHovered] = CUSTOM_THEME.imguiButtonHovered; colors[clr.ButtonActive] = CUSTOM_THEME.imguiButtonActive
        colors[clr.Header] = CUSTOM_THEME.collapsingHeader; colors[clr.HeaderHovered] = CUSTOM_THEME.collapsingHeaderHovered
        colors[clr.HeaderActive] = CUSTOM_THEME.collapsingHeaderActive; colors[clr.Separator] = CUSTOM_THEME.separatorColor
        colors[clr.CheckMark] = CUSTOM_THEME.checkMark; colors[clr.SliderGrab] = CUSTOM_THEME.sliderGrab
        colors[clr.SliderGrabActive] = CUSTOM_THEME.sliderGrabActive; colors[clr.FrameBg] = CUSTOM_THEME.frameBg
        colors[clr.FrameBgHovered] = CUSTOM_THEME.frameBgHovered; colors[clr.FrameBgActive] = CUSTOM_THEME.frameBgActive
        colors[clr.TitleBgActive] = CUSTOM_THEME.titleBgActive; colors[clr.TitleBgCollapsed] = CUSTOM_THEME.titleBgCollapsed
        colors[clr.PopupBg] = CUSTOM_THEME.childBg
    end
    if rhVc() then
        local colors = imgui.GetStyle().Colors; local clr = imgui.Col
        colors[clr.FrameBg] = imgui.ImVec4(0.31, 0.49, 0.71, 1.0)
        colors[clr.FrameBgHovered] = imgui.ImVec4(0.38, 0.57, 0.80, 1.0)
        colors[clr.FrameBgActive] = imgui.ImVec4(0.66, 0.44, 0.65, 0.90)
        colors[clr.CheckMark] = imgui.ImVec4(1.0, 0.56, 0.78, 1.0)
        colors[clr.SliderGrab] = imgui.ImVec4(1.0, 0.56, 0.78, 1.0)
        colors[clr.SliderGrabActive] = imgui.ImVec4(1.0, 0.70, 0.85, 1.0)
        colors[clr.PopupBg] = imgui.ImVec4(0.20, 0.36, 0.56, 0.98)
        colors[clr.Border] = imgui.ImVec4(0.61, 0.77, 0.93, 0.60)
        colors[clr.Button] = imgui.ImVec4(0.40, 0.58, 0.82, 0.85)
        colors[clr.ButtonHovered] = imgui.ImVec4(1.0, 0.56, 0.78, 0.40)
        colors[clr.ButtonActive] = imgui.ImVec4(1.0, 0.56, 0.78, 0.60)
        colors[clr.Header] = imgui.ImVec4(0.31, 0.49, 0.71, 0.50)
        colors[clr.HeaderHovered] = imgui.ImVec4(1.0, 0.56, 0.78, 0.40)
        colors[clr.HeaderActive] = imgui.ImVec4(1.0, 0.56, 0.78, 0.60)
        RH_VC_STYLE = true
    elseif RH_VC_STYLE then
        RH_VC_STYLE = false
        pcall(styleWin)
    end
    
    lastTabValue = lastTabValue or currentTab
    tabSwitchTime = tabSwitchTime or os.clock()
    if currentTab ~= lastTabValue then
        lastTabValue = currentTab
        tabSwitchTime = os.clock()
    end
    local tabFadeAlpha = settings.smoothWindowEnabled and math.min((os.clock() - tabSwitchTime) / 0.18, 1.0) or 1.0
    local rightPanelAlpha = math.min(tabFadeAlpha, windowAnimAlpha)
    
    if currentTab == 1 then drawHomeTab()
    elseif currentTab == 2 then drawFarmTab()
    elseif currentTab == 3 then drawMineTab()
    elseif currentTab == 4 then drawSawmillTab()
    elseif currentTab == 5 then drawSideIncomeHubTab()
    elseif currentTab == 6 then drawLeaderboardTab()
    elseif currentTab == 7 then drawGoalsTab()
    elseif currentTab == 8 then drawAchievementsTab()
    elseif currentTab == 9 then drawBinderTab()
    elseif currentTab == 10 then drawSettingsTab()
    elseif currentTab == 11 then drawAboutTab()
    elseif currentTab == 12 then drawOilTab()
    elseif currentTab == 13 then drawFuncHubTab()
    elseif currentTab == 14 then drawAutoAdTab()
    elseif currentTab == 15 then drawChatFilterTab()
    elseif currentTab == 16 then drawPaydayTab()
    elseif currentTab == 17 then drawRentTab()
    elseif currentTab == 18 then drawShardTab()
    elseif currentTab == 19 then drawInvestmentTab()
    elseif currentTab == 20 then drawCryptoTab()
    elseif currentTab == 24 then drawNftTab()
    elseif currentTab == 21 then drawTaxiTab()
    elseif currentTab == 23 then drawIncassTab()
    elseif currentTab == 22 then drawJobsHubTab() end
    
    if rightPanelAlpha < 1.0 then
        local maskColor = applyAlpha(imVec4ToHex(theme.childBg), 1.0 - rightPanelAlpha)
        imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(childX, childY), imgui.ImVec2(childX + childW, childY + childH), maskColor, 4)
    end
    
    rhTipFlush()
    imgui.EndChild()
end
homeDashCache = nil
homeDashCacheTime = 0
profilePopupOpen = false
avatarHoveredGlobal = false
headerWinPos = nil
headerWinSize = nil
lbEnabledCache = false
lbEnabledCacheTime = 0
function getTodayResourceIncome(workType)
    local total = 0
    local gameDate = getGameDate()
    local logPath = getServerStatsPath(workType)
    local file = io.open(logPath, "r")
    if file then
        local content = file:read("*all")
        file:close()
        for time, resource, amount in content:gmatch('"time":(%d+),"resource":"([^"]+)","amount":(%d+)') do
            if getGameDate(tonumber(time)) == gameDate then
                local price = getPriceForResource(resource, workType)
                total = total + (tonumber(amount) * price)
            end
        end
    end
    return total
end
function refreshHomeDashboard()
    local gameDate = getGameDate()
    
    local paydayToday, paydayAZToday = 0, 0
    if paydayLog then
        for _, log in ipairs(paydayLog) do
            if getGameDate(log.time) == gameDate then
                paydayToday = paydayToday + (log.total or 0)
                paydayAZToday = paydayAZToday + (log.az or 0)
            end
        end
    end
    
    local shardsToday = 0
    if shardLog then
        for _, log in ipairs(shardLog) do
            if getGameDate(log.time) == gameDate then
                shardsToday = shardsToday + (log.amount or 0)
            end
        end
    end
    
    local farmToday = getTodayResourceIncome(WORK_TYPES.FARM)
    local mineToday = getTodayResourceIncome(WORK_TYPES.MINE)
    local sawmillToday = getTodayResourceIncome(WORK_TYPES.SAWMILL)
    local rentToday = itemMarketTodayIncome or 0
	    local investToday = 0
    if investmentLog then
        for _, log in ipairs(investmentLog) do
            if getGameDate(log.time) == gameDate then
                local cost = (investmentConfig[log.itemId] and investmentConfig[log.itemId].cost) or 0
                investToday = investToday + cost
            end
        end
    end
    
    local oilToday, oilAZToday = 0, 0
    if oilLog then
        for _, log in ipairs(oilLog) do
            if getGameDate(log.time) == gameDate then
                oilToday = oilToday + (log.money or 0)
                oilAZToday = oilAZToday + (log.az or 0)
            end
        end
    end
    
    local incassToday = getIncassSummary().today.stockIncome
    if incassLog then
        for _, log in ipairs(incassLog) do
            if getGameDate(log.time) == gameDate then
                incassToday = incassToday + (log.money or 0)
            end
        end
    end
    local taxiToday = 0
    if taxiLog then
        for _, log in ipairs(taxiLog) do
            if getGameDate(log.time) == gameDate then
                taxiToday = taxiToday + (log.money or 0)
            end
        end
    end
    
    local achCompleted, achTotal = 0, #ACHIEVEMENTS
    for _, ach in ipairs(ACHIEVEMENTS) do
        if ach.completed then achCompleted = achCompleted + 1 end
    end
    
    homeDashCache = {
        payday = paydayToday, paydayAZ = paydayAZToday,
        farm = farmToday, mine = mineToday, sawmill = sawmillToday, oil = oilToday, oilAZ = oilAZToday,
        taxi = taxiToday, incass = incassToday,
        other = rentToday + shardsToday + investToday,
        total = paydayToday + farmToday + mineToday + sawmillToday + oilToday + taxiToday + incassToday + rentToday + shardsToday + investToday,
        totalAZ = paydayAZToday + oilAZToday,
        achCompleted = achCompleted, achTotal = achTotal,
    }
    homeDashCacheTime = os.clock()
    totalDailyIncome = homeDashCache.total
    saveTotalIncomeGoal()
    checkTotalIncomeGoal()
    pcall(checkIncomeGoals, homeDashCache)
end
function rhCardBox(drawList, x, y, w, h, bg, border, radius)
    drawList:AddRectFilled(imgui.ImVec2(x, y), imgui.ImVec2(x + w, y + h), bg, radius)
    drawList:AddLine(imgui.ImVec2(x + radius, y + 1), imgui.ImVec2(x + w - radius, y + 1), rhAlpha(0xFFFFFFFF, 0.05), 1.0)
    drawList:AddRect(imgui.ImVec2(x, y), imgui.ImVec2(x + w, y + h), border, radius, 15, 1.0)
end
function rhIconBadge(drawList, cx, cy, r, icon, accent, bg, ha)
    ha = ha or 0
    drawList:AddCircleFilled(imgui.ImVec2(cx, cy), r + 5, rhAlpha(accent, 0.03 + 0.04 * ha), 32)
    drawList:AddCircleFilled(imgui.ImVec2(cx, cy), r, rhLerpColor(bg, accent, 0.16 + 0.14 * ha), 32)
    drawList:AddCircle(imgui.ImVec2(cx, cy), r, rhAlpha(accent, 0.35 + 0.5 * ha), 32, 1.0)
    local sz = imgui.CalcTextSize(icon)
    drawList:AddText(imgui.ImVec2(cx - sz.x / 2, cy - sz.y / 2), accent, icon)
end
function rhPill(drawList, x, y, text, col)
    local sz = imgui.CalcTextSize(text)
    local w, h = sz.x + 20, 22
    drawList:AddRectFilled(imgui.ImVec2(x, y), imgui.ImVec2(x + w, y + h), rhAlpha(col, 0.14), 11)
    drawList:AddRect(imgui.ImVec2(x, y), imgui.ImVec2(x + w, y + h), rhAlpha(col, 0.45), 11, 15, 1.0)
    drawList:AddText(imgui.ImVec2(x + 10, y + (h - sz.y) / 2), col, text)
    return w
end
function rhRing(drawList, cx, cy, r, th, progress, col, trackCol)
    drawList:AddCircle(imgui.ImVec2(cx, cy), r, trackCol, 64, th)
    if progress > 0 then
        local n = 96
        local filled = math.max(1, math.floor(math.min(progress, 1) * n))
        local start = -math.pi / 2
        for i = 0, filled - 1 do
            local a1 = start + (i / n) * 2 * math.pi
            local a2 = start + ((i + 1) / n) * 2 * math.pi
            drawList:AddLine(imgui.ImVec2(cx + math.cos(a1) * r, cy + math.sin(a1) * r),
                             imgui.ImVec2(cx + math.cos(a2) * r, cy + math.sin(a2) * r), col, th)
        end
    end
end
function rhVc()
    return (not useCustomTheme) and currentTheme == THEMES.VICE
end
function rhDim(c)
    if rhVc() then return 0xFFF5DDC9 end
    return c
end
function rhTrack(c)
    if rhVc() then return 0xFF754C2F end
    return c
end
function rhCB(c)
    if rhVc() then return 0xFF8C5E3B end
    return c
end
function rhCBH(c)
    if rhVc() then return 0xFF9A6C47 end
    return c
end
function rhCBR(c)
    if rhVc() then return 0xFFEEC39C end
    return c
end
function homeCardColors()
    if useCustomTheme then
        return imVec4ToHex(CUSTOM_THEME.cardBg), imVec4ToHex(CUSTOM_THEME.cardBorder),
               imVec4ToHex(CUSTOM_THEME.cardIcon), imVec4ToHex(CUSTOM_THEME.cardTitle)
    end
    if rhVc() then
        return 0xFF8C5E3B, 0xFFEEC39C, 0xFFC78FFF, 0xFFC78FFF
    end
    return 0xFF181818, 0xFF2C2C2C, 0xFF1AE591, 0xFF1AE591
end
function drawHomeHotkeyBar(drawList, x, y, w, bgCol, borderCol, iconCol)
    local h = editingMenuKey and 64 or 46
    rhCardBox(drawList, x, y, w, h, bgCol, editingMenuKey and 0xFF1AE591 or borderCol, 12)
    local cy = y + 23
    rhIconBadge(drawList, x + 28, cy, 14, fa.ICON_KEYBOARD_O, iconCol, bgCol, 0)
    drawList:AddText(imgui.ImVec2(x + 54, cy - 8), 0xFFCCCCCC, u8("Клавиша активации меню"))
    local keyNames = {}
    local currentKeys = editingMenuKey and menuKeyBuffer or settings.menuKey
    if currentKeys and #currentKeys > 0 then
        for _, key in ipairs(currentKeys) do table.insert(keyNames, vkeys.id_to_name(key)) end
    end
    local keyStr = #keyNames > 0 and table.concat(keyNames, " + ") or u8("Не назначено")
    local btnW = imgui.CalcTextSize(keyStr).x + 24
    local btnH = 26
    local btnX = x + w - btnW - 12
    local btnY = cy - btnH / 2
    local mp = imgui.GetMousePos()
    local btnHovered = (mp.x >= btnX and mp.x <= btnX + btnW and mp.y >= btnY and mp.y <= btnY + btnH)
    local btnBg = editingMenuKey and 0xFF1E3D1E or (btnHovered and 0xFF2A2A2A or 0xFF252525)
    local btnBorder = editingMenuKey and 0xFF1AE591 or (btnHovered and 0xFF555555 or 0xFF3A3A3A)
    local btnTextCol = editingMenuKey and 0xFF1AE591 or (btnHovered and 0xFFFFFFFF or 0xFFCCCCCC)
    drawList:AddRectFilled(imgui.ImVec2(btnX, btnY), imgui.ImVec2(btnX + btnW, btnY + btnH), btnBg, 8)
    drawList:AddRect(imgui.ImVec2(btnX, btnY), imgui.ImVec2(btnX + btnW, btnY + btnH), btnBorder, 8, 15, 1.0)
    local keyTextSz = imgui.CalcTextSize(keyStr)
    drawList:AddText(imgui.ImVec2(btnX + (btnW - keyTextSz.x) / 2, btnY + (btnH - keyTextSz.y) / 2), btnTextCol, keyStr)
    imgui.SetCursorScreenPos(imgui.ImVec2(btnX, btnY))
    if imgui.InvisibleButton("##menu_key_btn", imgui.ImVec2(btnW, btnH)) then
        if not editingMenuKey then
            editingMenuKey = true
            menuKeyBuffer = {}
        end
    end
    if editingMenuKey then
        local altVariants = {18, 164, 165}
        local ctrlVariants = {17, 162, 163}
        local shiftVariants = {16, 160, 161}
        local function inList(list, v)
            for _, item in ipairs(list) do if item == v then return true end end
            return false
        end
        for vk, name in pairs(vkeys.key_names) do
            if type(vk) == "number" and wasKeyPressed(vk) then
                local alreadyExists = false
                for _, existing in ipairs(menuKeyBuffer) do
                    if (inList(altVariants, vk) and inList(altVariants, existing))
                       or (inList(ctrlVariants, vk) and inList(ctrlVariants, existing))
                       or (inList(shiftVariants, vk) and inList(shiftVariants, existing))
                       or vk == existing then
                        alreadyExists = true; break
                    end
                end
                if not alreadyExists then table.insert(menuKeyBuffer, vk) end
            end
        end
        local sorted = {}
        for _, vk in ipairs(menuKeyBuffer) do if inList(ctrlVariants, vk) then table.insert(sorted, 17) end end
        for _, vk in ipairs(menuKeyBuffer) do if inList(altVariants, vk) then table.insert(sorted, 18) end end
        for _, vk in ipairs(menuKeyBuffer) do if inList(shiftVariants, vk) then table.insert(sorted, 16) end end
        for _, vk in ipairs(menuKeyBuffer) do
            if not (inList(ctrlVariants, vk) or inList(altVariants, vk) or inList(shiftVariants, vk)) then
                table.insert(sorted, vk)
            end
        end
        menuKeyBuffer = sorted
        if imgui.IsMouseClicked(0) and not btnHovered then
            if #menuKeyBuffer > 0 then
                settings.menuKey = {table.unpack(menuKeyBuffer)}
                saveConfig()
                sampAddChatMessage(SCRIPT_PREFIX .. "Клавиша сохранена! Перезагрузите скрипт (/rhrl) для применения.", SCRIPT_COLOR)
            end
            editingMenuKey = false
        end
        if wasKeyPressed(27) then
            editingMenuKey = false
            menuKeyBuffer = {}
        end
        drawList:AddText(imgui.ImVec2(x + 15, y + h - 20), 0xFF888888, u8("Нажимайте клавиши, кликните вне поля для сохранения. Esc - отмена"))
    end
    return h
end
function drawHomeTab()
    local drawList = imgui.GetWindowDrawList()
    local cw = imgui.GetWindowWidth() - 10
    local mp = imgui.GetMousePos()
    local function P(x, y) return imgui.ImVec2(x, y) end
    local bgCol, borderCol, iconCol, titleCol = homeCardColors()
    if not homeDashCache or os.clock() - homeDashCacheTime > 15 then refreshHomeDashboard() end
    local dash = homeDashCache
    if not settings.hiddenHomeTiles then settings.hiddenHomeTiles = {} end
    local accentOf = {payday = 0xFF33DD77, farm = 0xFF1AE591, mine = 0xFF28AAFF, sawmill = 0xFF99D334,
                      oil = 0xFFFA8BA7, taxi = 0xFF15CCFA, incass = 0xFFF8BD38, other = 0xFF9A6AF0}
    local valueOf = {payday = dash.payday, farm = dash.farm, mine = dash.mine, sawmill = dash.sawmill,
                     oil = dash.oil, taxi = dash.taxi, incass = dash.incass or 0, other = dash.other}
    local barOrder = {"payday", "mine", "farm", "sawmill", "oil", "taxi", "incass", "other"}
    local total = dash.total
    if settings.homeShowLogo and logoArz then
        local imgHeight = cw * (195 / 750)
        imgui.SetCursorPosX(0)
        imgui.Image(logoArz, imgui.ImVec2(cw, imgHeight))
        imgui.Spacing()
    end
    local hx, hy = imgui.GetCursorScreenPos().x, imgui.GetCursorScreenPos().y
    local hh = 134
    local goal = (settings.homeShowGoals ~= false) and (settings.totalIncomeGoal or 0) or 0
    local goalDone = goal > 0 and total >= goal
    if settings.homeShowSummary ~= false then
    rhCardBox(drawList, hx, hy, cw, hh, bgCol, goalDone and rhLerpColor(borderCol, 0xFF33DD77, 0.45) or borderCol, 14)
    drawList:AddText(P(hx + 22, hy + 14), rhDim(0xFF8A8A8A), u8("Доход за сегодня"))
    local bigStr = formatNumber(total) .. "$"
    if rhBigFont then
        imgui.PushFont(rhBigFont)
        imgui.SetCursorScreenPos(P(hx + 22, hy + 32))
        if rhVc() then
            imgui.TextColored(imgui.ImVec4(0.44, 0.93, 0.92, 1), bigStr)
        else
            imgui.TextColored(imgui.ImVec4(0.47, 0.87, 0.2, 1), bigStr)
        end
        imgui.PopFont()
    else
        drawList:AddText(P(hx + 22, hy + 38), 0xFF33DD77, bigStr)
        drawList:AddText(P(hx + 23, hy + 38), 0xFF33DD77, bigStr)
    end
    if dash.totalAZ > 0 then
        rhPill(drawList, hx + 22, hy + 76, formatNumber(dash.totalAZ) .. " AZ", 0xFF00CCFF)
    end
    if settings.homeShowGoals ~= false then
    local ringX, ringY = hx + cw - 56, hy + 56
    local pct = goal > 0 and math.min(total / goal, 1) or 0
    rhRing(drawList, ringX, ringY, 30, 6, pct, goalDone and 0xFF33DD77 or 0xFF38C8F8, rhTrack(0xFF262626))
    local pctStr = goal > 0 and (math.floor(pct * 100) .. "%") or "--"
    local pctSz = imgui.CalcTextSize(pctStr)
    drawList:AddText(P(ringX - pctSz.x / 2, ringY - pctSz.y / 2), goalDone and 0xFF33DD77 or 0xFFFFFFFF, pctStr)
    local gHov = (mp.x >= hx + cw - 330 and mp.x <= hx + cw - 10 and mp.y >= hy + 16 and mp.y <= hy + 96)
    local tx = ringX - 30 - 18
    local l1 = u8("Цель дня")
    drawList:AddText(P(tx - imgui.CalcTextSize(l1).x, hy + 32), gHov and 0xFFFFFFFF or rhDim(0xFF8A8A8A), l1)
    local l2 = goal > 0 and (formatNumber(goal) .. "$") or u8("не задана")
    drawList:AddText(P(tx - imgui.CalcTextSize(l2).x, hy + 50), 0xFFFFFFFF, l2)
    local l3, c3
    if goal <= 0 then l3, c3 = u8("Задать цель"), 0xFF38C8F8
    elseif goalDone then l3, c3 = u8("Цель выполнена"), 0xFF33DD77
    else l3, c3 = u8("Осталось ") .. formatNumber(goal - total) .. "$", rhDim(0xFF8A8A8A) end
    drawList:AddText(P(tx - imgui.CalcTextSize(l3).x, hy + 68), c3, l3)
    imgui.SetCursorScreenPos(P(hx + cw - 330, hy + 16))
    if imgui.InvisibleButton("##home_goal_zone", imgui.ImVec2(320, 80)) then currentTab = 7 end
    end
    local bx0, bx1, by = hx + 22, hx + cw - 22, hy + hh - 26
    drawList:AddRectFilled(P(bx0, by), P(bx1, by + 8), rhTrack(0xFF222222), 4)
    if total > 0 then
        local present = {}
        for _, k in ipairs(barOrder) do if (valueOf[k] or 0) > 0 then table.insert(present, k) end end
        local gap = 2
        local usable = (bx1 - bx0) - gap * (#present - 1)
        local x = bx0
        for _, k in ipairs(present) do
            local w = usable * (valueOf[k] / total)
            drawList:AddRectFilled(P(x, by), P(x + math.max(w, 3), by + 8), accentOf[k], 4)
            x = x + w + gap
        end
    end
    imgui.SetCursorScreenPos(P(hx, hy + hh))
    imgui.Dummy(imgui.ImVec2(cw, 10))
    end
    if settings.homeShowTiles ~= false then
    local sources = {
        {key = "payday", label = u8("Пейдей"), value = dash.payday, az = dash.paydayAZ, icon = fa.ICON_MONEY, tab = 16},
        {key = "farm", label = u8("Ферма"), value = dash.farm, icon = fa.ICON_LEAF, tab = 2, workType = WORK_TYPES.FARM},
        {key = "mine", label = u8("Шахта"), value = dash.mine, icon = fa.ICON_GAVEL, tab = 3, workType = WORK_TYPES.MINE},
        {key = "sawmill", label = u8("Лесопилка"), value = dash.sawmill, icon = fa.ICON_TREE, tab = 4, workType = WORK_TYPES.SAWMILL},
        {key = "oil", label = u8("Нефтевышка"), value = dash.oil, az = dash.oilAZ, icon = fa.ICON_FIRE, tab = 12},
        {key = "taxi", label = u8("Такси"), value = dash.taxi, icon = fa.ICON_TAXI, tab = 21},
        {key = "incass", label = u8("Инкассатор"), value = dash.incass or 0, icon = fa.ICON_MONEY, tab = 23},
        {key = "other", label = u8("Сторонний доход"), value = dash.other, icon = fa.ICON_SHOPPING_CART, tab = 5},
    }
    local visibleTiles = {}
    for _, t in ipairs(sources) do
        if not settings.hiddenHomeTiles[t.key] then table.insert(visibleTiles, t) end
    end
    local cols, gap, tileH = 3, 8, 62
    local tileW = (cw - gap * (cols - 1)) / cols
    local rows = math.ceil(#visibleTiles / cols)
    local gx, gy = imgui.GetCursorScreenPos().x, imgui.GetCursorScreenPos().y
    for i, tile in ipairs(visibleTiles) do
        local col = (i - 1) % cols
        local row = math.floor((i - 1) / cols)
        local tx2 = gx + col * (tileW + gap)
        local ty = gy + row * (tileH + gap)
        local hovered = (mp.x >= tx2 and mp.x <= tx2 + tileW and mp.y >= ty and mp.y <= ty + tileH)
        local ha = rhAnim("home_" .. tile.key, hovered and 1 or 0)
        local accent = useCustomTheme and iconCol or accentOf[tile.key]
        local bgT = rhLerpColor(bgCol, rhLerpColor(bgCol, 0xFFFFFFFF, 0.04), ha)
        rhCardBox(drawList, tx2, ty, tileW, tileH, bgT, rhLerpColor(borderCol, accent, 0.55 * ha), 12)
        rhIconBadge(drawList, tx2 + 28, ty + tileH / 2, 17, tile.icon, accent, bgT, ha)
        local share = total > 0 and ((tile.value or 0) / total) or 0
        local valueStr = formatNumber(tile.value) .. "$"
        if tile.az and tile.az > 0 then valueStr = valueStr .. " | " .. formatNumber(tile.az) .. " AZ" end
        local shareStr = math.floor(share * 100 + 0.5) .. "%"
        drawList:PushClipRect(P(tx2 + 52, ty), P(tx2 + tileW - 8, ty + tileH), true)
        drawList:AddText(P(tx2 + 54, ty + 10), rhDim(0xFF888888), tile.label)
        drawList:AddText(P(tx2 + tileW - 14 - imgui.CalcTextSize(shareStr).x, ty + 10), rhLerpColor(0xFF606060, accent, 0.4 + 0.6 * ha), shareStr)
        drawList:AddText(P(tx2 + 54, ty + 28), 0xFFFFFFFF, valueStr)
        drawList:PopClipRect()
        local mx0, mx1 = tx2 + 54, tx2 + tileW - 14
        drawList:AddRectFilled(P(mx0, ty + tileH - 12), P(mx1, ty + tileH - 9), rhTrack(0xFF242424), 2)
        if share > 0 then
            drawList:AddRectFilled(P(mx0, ty + tileH - 12), P(mx0 + math.max(3, (mx1 - mx0) * share), ty + tileH - 9), accent, 2)
        end
        imgui.SetCursorScreenPos(P(tx2, ty))
        if imgui.InvisibleButton("##dash_tile_" .. tile.key, imgui.ImVec2(tileW, tileH)) then
            if tile.tab and not scanState.active then
                currentTab = tile.tab
                if tile.tab == 23 and not stockScannedThisSession then pendingStockScan = true end
                if tile.workType then
                    switchWorkType(tile.workType); workTypeSelected = true
                    if not scannedThisSession[tile.workType] then pendingScan = tile.workType end
                end
            end
        end
        if hovered and imgui.IsMouseClicked(1) then imgui.OpenPopup("##dash_tile_ctx_" .. tile.key) end
        if imgui.BeginPopup("##dash_tile_ctx_" .. tile.key) then
            if imgui.Button(fa.ICON_TIMES .. u8("  Скрыть с главной"), imgui.ImVec2(170, 25)) then
                settings.hiddenHomeTiles[tile.key] = true
                saveConfig()
                imgui.CloseCurrentPopup()
            end
            imgui.EndPopup()
        end
    end
    local gridH = rows * tileH + math.max(0, rows - 1) * gap
    imgui.SetCursorScreenPos(P(gx, gy + gridH))
    imgui.Dummy(imgui.ImVec2(cw, 10))
    end
    local rx, ry = imgui.GetCursorScreenPos().x, imgui.GetCursorScreenPos().y
    local leftW = math.floor((cw - 8) * 0.62)
    local rightW = cw - 8 - leftW
    local showGoals = settings.homeShowGoals ~= false
    local showWork = settings.homeShowWork ~= false
    if not showWork then leftW = cw end
    if not showGoals then rightW = cw end
    local jobLabels = {oil = u8("Нефтевышки"), taxi = u8("Такси"), incass = u8("Инкассатор")}
    local goalRows = {}
    if goal > 0 then
        table.insert(goalRows, {name = u8("Общий доход"), cur = total, goal = goal, col = 0xFF38C8F8})
    end
    if INCOME_GOAL_JOBS and incomeGoals then
        for _, j in ipairs(INCOME_GOAL_JOBS) do
            local g = incomeGoals[j.key]
            if g and (g.goal or 0) > 0 then
                table.insert(goalRows, {name = jobLabels[j.key] or u8(j.name), cur = dash[j.key] or 0, goal = g.goal, col = accentOf[j.key] or 0xFF1AE591})
            end
        end
    end
    local shown = showGoals and math.min(#goalRows, 4) or 0
    local bottomH = (showGoals or showWork) and math.max(122, 44 + math.max(shown, 1) * 26 + 10) or 0
    local accent = useCustomTheme and iconCol or 0xFF1AE591
    if showGoals then
        local hov = (mp.x >= rx and mp.x <= rx + leftW and mp.y >= ry and mp.y <= ry + bottomH)
        local ga = rhAnim("home_goals", hov and 1 or 0)
        rhCardBox(drawList, rx, ry, leftW, bottomH, rhLerpColor(bgCol, rhLerpColor(bgCol, 0xFFFFFFFF, 0.04), ga), rhLerpColor(borderCol, 0xFF38C8F8, 0.5 * ga), 12)
        rhIconBadge(drawList, rx + 28, ry + 26, 13, fa.ICON_BULLSEYE, 0xFF38C8F8, bgCol, ga)
        drawList:AddText(P(rx + 52, ry + 18), 0xFFFFFFFF, u8("Цели на сегодня"))
        local allStr = u8("Все цели >")
        drawList:AddText(P(rx + leftW - 16 - imgui.CalcTextSize(allStr).x, ry + 18), rhLerpColor(0xFF707070, 0xFF38C8F8, ga), allStr)
        if shown == 0 then
            drawList:AddText(P(rx + 16, ry + 60), rhDim(0xFF808080), u8("Цели не заданы. Нажмите, чтобы настроить."))
        else
            for i = 1, shown do
                local r = goalRows[i]
                local y = ry + 50 + (i - 1) * 26
                local p = r.goal > 0 and math.min(r.cur / r.goal, 1) or 0
                local done = r.cur >= r.goal
                local barCol = done and 0xFF33DD77 or r.col
                drawList:AddText(P(rx + 16, y), 0xFFBBBBBB, r.name)
                local barX0, barX1 = rx + 130, rx + leftW - 78
                drawList:AddRectFilled(P(barX0, y + 5), P(barX1, y + 11), rhTrack(0xFF222222), 3)
                if p > 0 then drawList:AddRectFilled(P(barX0, y + 5), P(barX0 + (barX1 - barX0) * p, y + 11), barCol, 3) end
                local vStr = done and u8("Готово") or (math.floor(p * 100) .. "%")
                drawList:AddText(P(rx + leftW - 16 - imgui.CalcTextSize(vStr).x, y), done and 0xFF33DD77 or rhDim(0xFF8A8A8A), vStr)
            end
        end
        imgui.SetCursorScreenPos(P(rx, ry))
        if imgui.InvisibleButton("##home_goals_card", imgui.ImVec2(leftW, bottomH)) then currentTab = 7 end
    end
    if showWork then
        local wx = showGoals and (rx + leftW + 8) or rx
        local workTab
        if config and currentWork then
            if currentWork == WORK_TYPES.FARM then workTab = 2
            elseif currentWork == WORK_TYPES.MINE then workTab = 3
            elseif currentWork == WORK_TYPES.SAWMILL then workTab = 4 end
        end
        local hov = (mp.x >= wx and mp.x <= wx + rightW and mp.y >= ry and mp.y <= ry + bottomH)
        local wa = rhAnim("home_work", hov and 1 or 0)
        rhCardBox(drawList, wx, ry, rightW, bottomH, rhLerpColor(bgCol, rhLerpColor(bgCol, 0xFFFFFFFF, 0.04), wa), rhLerpColor(borderCol, accent, 0.5 * wa), 12)
        rhIconBadge(drawList, wx + 28, ry + 26, 13, fa.ICON_BRIEFCASE, accent, bgCol, wa)
        drawList:AddText(P(wx + 52, ry + 18), 0xFFFFFFFF, u8("Режим работы"))
        drawList:PushClipRect(P(wx + 8, ry), P(wx + rightW - 8, ry + bottomH), true)
        if workTab then
            drawList:AddText(P(wx + 16, ry + 42), 0xFFFFFFFF, u8(config.name))
            drawList:AddText(P(wx + 16, ry + 60), 0xFF33DD77, u8("За сессию: ") .. formatNumber(sessionTotal) .. "$")
        else
            drawList:AddText(P(wx + 16, ry + 42), rhDim(0xFF8A8A8A), u8("Работа не выбрана"))
            drawList:AddText(P(wx + 16, ry + 60), rhDim(0xFF666666), u8("Откройте раздел Работы"))
        end
        drawList:PopClipRect()
        local btnX, btnY, btnW, btnH = wx + 16, ry + bottomH - 38, rightW - 32, 26
        drawList:AddRectFilled(P(btnX, btnY), P(btnX + btnW, btnY + btnH), rhAlpha(accent, 0.12 + 0.12 * wa), 8)
        drawList:AddRect(P(btnX, btnY), P(btnX + btnW, btnY + btnH), rhAlpha(accent, 0.45 + 0.4 * wa), 8, 15, 1.0)
        local btnText = workTab and u8("Продолжить") or u8("Выбрать работу")
        local btnSz = imgui.CalcTextSize(btnText)
        drawList:AddText(P(btnX + (btnW - btnSz.x) / 2, btnY + (btnH - btnSz.y) / 2), accent, btnText)
        imgui.SetCursorScreenPos(P(wx, ry))
        if imgui.InvisibleButton("##home_work_card", imgui.ImVec2(rightW, bottomH)) then
            if workTab then
                if not scanState.active then
                    currentTab = workTab; workTypeSelected = true
                    if not scannedThisSession[currentWork] then pendingScan = currentWork end
                end
            else
                currentTab = 22
            end
        end
    end
    imgui.SetCursorScreenPos(P(rx, ry + bottomH))
    imgui.Dummy(imgui.ImVec2(cw, 10))
    if settings.homeShowHotkey ~= false then
        local fx, fy = imgui.GetCursorScreenPos().x, imgui.GetCursorScreenPos().y
        local fh = drawHomeHotkeyBar(drawList, fx, fy, cw, bgCol, borderCol, iconCol)
        imgui.SetCursorScreenPos(P(fx, fy + fh))
        imgui.Dummy(imgui.ImVec2(cw, 8))
    end
    local hasHiddenTiles = false
    for k, v in pairs(settings.hiddenHomeTiles or {}) do
        if v then hasHiddenTiles = true; break end
    end
    if hasHiddenTiles and settings.homeShowTiles ~= false then
        local restoreText = fa.ICON_REFRESH .. u8("  Показать скрытые плитки")
        local restoreW = imgui.CalcTextSize(restoreText).x
        local restorePos = imgui.GetCursorScreenPos()
        local restoreHovered = (mp.x >= restorePos.x and mp.x <= restorePos.x + restoreW and mp.y >= restorePos.y and mp.y <= restorePos.y + 16)
        drawList:AddText(P(restorePos.x, restorePos.y), restoreHovered and 0xFFFFFFFF or rhDim(0xFF888888), restoreText)
        imgui.SetCursorScreenPos(restorePos)
        if imgui.InvisibleButton("##dash_tiles_restore", imgui.ImVec2(restoreW, 16)) then
            settings.hiddenHomeTiles = {}
            saveConfig()
        end
        imgui.Dummy(imgui.ImVec2(cw, 20))
    end
end
JB = JB or {}
JB.RED = 0xFF5A5AF0
function JB.actOverlay(d)
    local own = d.ovCb()
    own.v = not own.v
    if own.v then
        local all = {
            {cb_farm_overlay, "farmOverlayEnabled"}, {cb_mine_overlay, "mineOverlayEnabled"},
            {cb_sawmill_overlay, "sawmillOverlayEnabled"}, {cb_oil_overlay, "oilOverlayEnabled"},
            {cb_taxi_overlay, "taxiOverlayEnabled"}, {cb_incass_overlay, "incassOverlayEnabled"},
        }
        for _, p in ipairs(all) do p[1].v = false; settings[p[2]] = false end
        own.v = true
        settings[d.ovKey] = true
        if settings.overlayAutoTimer and not overlayTimer.running then
            overlayTimer.running = true; overlayTimer.startTime = os.time()
            overlayTimer.elapsed = 0; overlayTimer.displayedTime = "00:00:00"
        end
    else
        settings[d.ovKey] = false
    end
    saveConfig()
end
function JB.def(id)
    JB.DF = JB.DF or {}
    if JB.DF[id] then return JB.DF[id] end
    local K = {}
    for k, v in pairs(WK.K(WORK_TYPES.MINE)) do K[k] = v end
    local d
    if id == "taxi" then
        K.col = 0xFF1CC8FF
        K.icon = fa.ICON_TAXI
        K.cap = u8("Доход с такси за сегодня")
        K.listTitle = u8("Поездки за день")
        K.empty = u8("Данных по такси пока нет")
        K.emptySub = u8("Статистика появится автоматически после первой поездки")
        K.noToday = u8("Сегодня поездок не было")
        K.emptyDay = u8("В этот день поездок не было")
        K.pl = {u8("поездка"), u8("поездки"), u8("поездок")}
        d = {
            id = "taxi", K = K,
            log = function() return taxiLog end,
            itemLabel = u8("Поездки"),
            noItems = u8("Пока нет поездок"),
            ovKey = "taxiOverlayEnabled",
            ovCb = function() return cb_taxi_overlay end,
        }
        d.rowCount = {
            icon = WK.ic("ICON_TAXI"), col = K.col, title = u8("Учитывать доход такси"),
            desc = u8("Записывать поездки в статистику"),
            get = function() return cb_taxi.v end,
            act = function()
                cb_taxi.v = not cb_taxi.v
                settings.taxiEnabled = cb_taxi.v
                saveConfig(); needSave = true
            end,
        }
        d.rowOverlay = {
            icon = WK.ic("ICON_DESKTOP"), col = K.col, title = u8("Оверлей на экране"),
            desc = u8("Статистика такси поверх игры"),
            get = function() return cb_taxi_overlay.v end,
            act = function() JB.actOverlay(d) end,
        }
    end
    JB.DF[id] = d
    return d
end
function JB.build(d)
    local log = d.log() or {}
    local K = d.K
    local todayKey = getGameDate()
    local last = log[1]
    local sig = #log .. "|" .. todayKey .. "|" .. (last and (last.time or 0) or 0) .. "|" .. (last and (last.money or 0) or 0)
    JB.cache = JB.cache or {}
    local cc = JB.cache[d.id]
    if cc and cc.sig == sig then return cc end
    local byDate, dates = {}, {}
    local all = {total = 0, az = 0, rub = 0, count = 0, max = 0}
    for _, e in ipairs(log) do
        local money = e.money or 0
        local dt = getGameDate(e.time)
        local ds = byDate[dt]
        if not ds then
            ds = {total = 0, az = 0, rub = 0, count = 0, best = 0, max = 0, cats = {}, hours = {}, logs = {}, pl = K.pl}
            byDate[dt] = ds
            dates[#dates + 1] = dt
        end
        ds.total = ds.total + money
        ds.count = ds.count + 1
        ds.logs[#ds.logs + 1] = e
        if money > ds.max then ds.max = money end
        local ckey, clabel, ccol = "trips", d.itemLabel, K.col
        if d.catOf then ckey, clabel, ccol = d.catOf(e) end
        local ce = ds.cats[ckey]
        if not ce then
            ce = {key = ckey, label = clabel, col = ccol, amount = 0, count = 0, qty = 0}
            ds.cats[ckey] = ce
        end
        ce.qty = (ce.qty or 0) + (e.amount or 0)
        ce.amount = ce.amount + money
        ce.count = ce.count + 1
        if ce.amount > ds.best then ds.best = ce.amount end
        local hi = math.floor((((e.time or 0) + 10800 - 18000) % 86400) / 3600)
        local hb = ds.hours[hi]
        if not hb then hb = {total = 0, count = 0}; ds.hours[hi] = hb end
        hb.total = hb.total + money
        hb.count = hb.count + 1
        all.total = all.total + money
        all.count = all.count + 1
        if money > all.max then all.max = money end
    end
    table.sort(dates, function(a, b) return a > b end)
    local mskWday = tonumber(os.date("!%w", getMoscowTime())) or 1
    if mskWday == 0 then mskWday = 7 end
    local week = {total = 0, az = 0, rub = 0, count = 0}
    for i = 0, mskWday - 1 do
        local ds = byDate[getGameDate(os.time() - i * 86400)]
        if ds then
            week.total = week.total + ds.total
            week.count = week.count + ds.count
        end
    end
    local last7 = {}
    for i = 6, 0, -1 do
        local dt = getGameDate(os.time() - i * 86400)
        local ds = byDate[dt]
        last7[#last7 + 1] = {date = dt, wd = PD.weekday(dt), total = ds and ds.total or 0, az = 0, count = ds and ds.count or 0}
    end
    local yestKey = getGameDate(os.time() - 86400)
    local out = {
        sig = sig, t = os.clock(), price = {},
        byDate = byDate, dates = dates, all = all, week = week, last7 = last7,
        todayKey = todayKey, yestKey = yestKey, pl = K.pl,
        today = byDate[todayKey] or PD.EMPTY, yest = byDate[yestKey] or PD.EMPTY,
    }
    JB.cache[d.id] = out
    return out
end
function JB.menu(d)
    local K = d.K
    local dl = imgui.GetWindowDrawList()
    local P = imgui.ImVec2
    local C = PD.C
    local bg, brd = homeCardColors()
    local cur = imgui.GetCursorScreenPos()
    local x, y = cur.x, cur.y + 4
    local w = imgui.GetWindowWidth() - 25
    local c = JB.build(d)
    dl:AddText(P(x + 4, y + 5), 0xFFFFFFFF, u8("Режим счёта"))
    y = y + 34
    if WK.row(dl, "jb_count_" .. d.id, x, y, w, 62, bg, brd, d.rowCount, nil) then d.rowCount.act() end
    y = y + 62 + 14
    dl:AddText(P(x + 4, y + 5), 0xFFFFFFFF, u8("Оверлей"))
    y = y + 34
    if WK.row(dl, "jb_ovl_" .. d.id, x, y, w, 56, bg, brd, d.rowOverlay, nil) then d.rowOverlay.act() end
    y = y + 56 + 14
    local gap = 8
    local tw = (w - gap * 2) / 3
    local th = 74
    local items = {
        {key = "today", label = u8("За сегодня"),       icon = fa.ICON_CALENDAR, col = C.sal, dd = c.today},
        {key = "week",  label = u8("За неделю"),        icon = fa.ICON_LIST,     col = C.dep, dd = c.week},
        {key = "all",   label = u8("Всего заработано"), icon = fa.ICON_TROPHY,   col = C.acc, dd = c.all},
    }
    for i, it in ipairs(items) do
        local tx = x + (i - 1) * (tw + gap)
        imgui.SetCursorScreenPos(P(tx, y))
        if imgui.InvisibleButton("##jb_tile_" .. d.id .. it.key, imgui.ImVec2(tw, th)) then
            if JB.sec and JB.sec[d.id] then JB.sec[d.id].v = 1 end
        end
        local hv = imgui.IsItemHovered()
        local a = rhAnim("jb_tile_" .. d.id .. it.key, hv and 1 or 0)
        local bgT = rhLerpColor(bg, rhLerpColor(bg, 0xFFFFFFFF, 0.04), a)
        rhCardBox(dl, tx, y, tw, th, bgT, rhLerpColor(brd, it.col, 0.55 * a), 12)
        rhIconBadge(dl, tx + 28, y + th / 2, 17, it.icon, it.col, bgT, a)
        local cnt = it.dd.count or 0
        dl:PushClipRect(P(tx + 52, y), P(tx + tw - 8, y + th), true)
        dl:AddText(P(tx + 54, y + 10), C.mute, it.label)
        dl:AddText(P(tx + 54, y + 28), 0xFFFFFFFF, formatNumber(it.dd.total or 0) .. "$")
        dl:AddText(P(tx + 54, y + 48), cnt > 0 and it.col or C.dim, formatNumber(cnt) .. " " .. PD.plural(cnt, K.pl))
        dl:PopClipRect()
    end
    y = y + th + 12
    imgui.SetCursorScreenPos(P(x, y))
    imgui.Dummy(imgui.ImVec2(w, 6))
end
function JB.list(d, dl, c, x, y, w, ACC, bg, brd)
    local K = d.K
    local S, C = PD.str(), PD.C
    local P = imgui.ImVec2
    local ds = c.byDate[PD.sel] or PD.EMPTY
    local th = imgui.CalcTextSize("A").y
    dl:AddText(P(x + 4, y + 5), 0xFFFFFFFF, K.listTitle)
    y = y + 34
    if ds.count == 0 then
        local eh = 92
        rhCardBox(dl, x, y, w, eh, bg, brd, 12)
        rhIconBadge(dl, x + w / 2, y + 32, 16, fa.ICON_CALENDAR, C.mute, bg, 0)
        local sz = imgui.CalcTextSize(K.emptyDay)
        dl:AddText(P(x + (w - sz.x) / 2, y + 60), C.mute, K.emptyDay)
        return y + eh + 8
    end
    local gap = 8
    local tw = (w - gap * 2) / 3
    local mh = 60
    local avg = (ds.count > 0) and math.floor(ds.total / ds.count + 0.5) or 0
    local mini = {
        {label = u8("Всего"),   val = formatNumber(ds.count) .. " " .. PD.plural(ds.count, K.pl), icon = K.icon,   col = K.col},
        {label = u8("Средняя"), val = formatNumber(avg) .. "$",                                   icon = fa.ICON_LIST,   col = C.sal},
        {label = u8("Лучшая"),  val = formatNumber(ds.max or 0) .. "$",                           icon = fa.ICON_TROPHY, col = C.gold},
    }
    for i, it in ipairs(mini) do
        local tx = x + (i - 1) * (tw + gap)
        rhCardBox(dl, tx, y, tw, mh, bg, brd, 12)
        rhIconBadge(dl, tx + 26, y + mh / 2, 15, it.icon, it.col, bg, 0)
        dl:PushClipRect(P(tx + 48, y), P(tx + tw - 8, y + mh), true)
        dl:AddText(P(tx + 50, y + 10), C.mute, it.label)
        dl:AddText(P(tx + 50, y + 30), 0xFFFFFFFF, it.val)
        dl:PopClipRect()
    end
    y = y + mh + 14
    local logs = ds.logs or {}
    local n = math.min(#logs, 60)
    local rowH = 36
    rhCardBox(dl, x, y, w, n * rowH + 8, bg, brd, 12)
    local maxV = (ds.max and ds.max > 0) and ds.max or 1
    for i = 1, n do
        local e = logs[i]
        local ry = y + 4 + (i - 1) * rowH
        imgui.SetCursorScreenPos(P(x, ry))
        imgui.InvisibleButton("##jb_j_" .. d.id .. i, imgui.ImVec2(w, rowH))
        local hv = imgui.IsItemHovered()
        if hv then dl:AddRectFilled(P(x + 4, ry), P(x + w - 4, ry + rowH), rhAlpha(0xFFFFFFFF, 0.04), 8) end
        local ty = ry + (rowH - th) / 2
        dl:AddText(P(x + 16, ty), C.mute, os.date("!%H:%M", (e.time or 0) + 10800))
        local money = e.money or 0
        local totalStr = "+" .. formatNumber(money) .. "$"
        local tw2 = imgui.CalcTextSize(totalStr).x
        dl:AddText(P(x + w - 16 - tw2, ty), C.green, totalStr)
        local bx0, bx1 = x + 80, x + w - 16 - tw2 - 18
        if bx1 - bx0 > 30 then
            local by = ry + rowH / 2 - 2
            dl:AddRectFilled(P(bx0, by), P(bx1, by + 4), rhAlpha(0xFFFFFFFF, 0.06), 2)
            dl:AddRectFilled(P(bx0, by), P(bx0 + math.max(3, (bx1 - bx0) * (money / maxV)), by + 4), rhAlpha(K.col, 0.85), 2)
        end
        if i < n then
            dl:AddLine(P(x + 14, ry + rowH), P(x + w - 14, ry + rowH), rhAlpha(0xFFFFFFFF, 0.05), 1.0)
        end
    end
    y = y + n * rowH + 8
    if #logs > n then
        dl:AddText(P(x + 8, y + 6), C.dim, u8("... и ещё записей: ") .. (#logs - n))
        y = y + 28
    end
    y = y + 8
    local fh = 50
    dl:AddRectFilled(P(x, y), P(x + w, y + fh), rhAlpha(ACC, 0.08), 12)
    dl:AddRect(P(x, y), P(x + w, y + fh), rhAlpha(ACC, 0.35), 12, 15, 1.0)
    local fty = y + (fh - th) / 2
    dl:AddText(P(x + 18, fty), ACC, S.itogo)
    dl:AddText(P(x + 19, fty), ACC, S.itogo)
    dl:AddText(P(x + 18 + imgui.CalcTextSize(S.itogo).x + 8, fty), C.dim, "x" .. formatNumber(ds.count))
    local fTot = formatNumber(ds.total) .. "$"
    local fw = imgui.CalcTextSize(fTot).x
    dl:AddText(P(x + w - 18 - fw, fty), C.green, fTot)
    dl:AddText(P(x + w - 17 - fw, fty), C.green, fTot)
    return y + fh + 12
end
function JB.drawInner(d)
    local K = d.K
    local dl = imgui.GetWindowDrawList()
    local P = imgui.ImVec2
    local C = PD.C
    local c = JB.build(d)
    PD.ensureSel(c)
    local bg, brd, iconCol = homeCardColors()
    local ACC = useCustomTheme and iconCol or 0xFF1AE591
    local cur = imgui.GetCursorScreenPos()
    local x, y = cur.x, cur.y + 4
    local w = imgui.GetWindowWidth() - 25
    WK.hero(dl, c, x, y, w, 152, ACC, bg, brd, K)
    y = y + 152 + 10
    WK.tiles(dl, c, x, y, w, 74, ACC, bg, brd, K)
    y = y + 74 + 12
    if #c.dates == 0 then
        local eh = 130
        rhCardBox(dl, x, y, w, eh, bg, brd, 14)
        rhIconBadge(dl, x + w / 2, y + 40, 20, K.icon, K.col, bg, 0)
        local s1, s2 = imgui.CalcTextSize(K.empty), imgui.CalcTextSize(K.emptySub)
        dl:AddText(P(x + (w - s1.x) / 2, y + 74), 0xFFFFFFFF, K.empty)
        dl:AddText(P(x + (w - s2.x) / 2, y + 96), C.mute, K.emptySub)
        y = y + eh + 10
    else
        PD.nav(dl, c, x, y, w, 46, ACC, bg, brd)
        y = y + 46 + 12
        local ds = c.byDate[PD.sel] or PD.EMPTY
        if ds.count > 0 then
            WK.hours(dl, c, x, y, w, 108, ACC, bg, brd, K)
            y = y + 108 + 12
        end
        y = (d.list or JB.list)(d, dl, c, x, y, w, ACC, bg, brd)
    end
    imgui.SetCursorScreenPos(P(x, y))
    imgui.Dummy(imgui.ImVec2(w, 6))
end
function JB.draw(d)
    JB.st = JB.st or {}
    JB.st[d.id] = JB.st[d.id] or {}
    local st = JB.st[d.id]
    local s0, y0, m0 = PD.sel, PD.calY, PD.calM
    PD.sel, PD.calY, PD.calM = st.sel, st.calY, st.calM
    local ok, err = pcall(JB.drawInner, d)
    st.sel, st.calY, st.calM = PD.sel, PD.calY, PD.calM
    PD.sel, PD.calY, PD.calM = s0, y0, m0
    if not ok then error(err, 0) end
end
function JB.tab(id, sid)
    local d = JB.def(id)
    JB.sec = JB.sec or {}
    local sec = JB.sec[id]
    if not sec then sec = {v = 0, last = 0}; JB.sec[id] = sec end
    if os.clock() - sec.last > 0.4 then sec.v = 0 end
    sec.last = os.clock()
    local names = {u8("Меню"), u8("Обзор")}
    local clicked = SegmentedTabs(sid, names, sec.v)
    if clicked then sec.v = clicked end
    imgui.Spacing(); imgui.Separator(); imgui.Spacing()
    if sec.v == 0 then JB.menu(d) else JB.draw(d) end
end
function drawTaxiTab()
    oilWorkActive = false
    JB.tab("taxi", "taxi")
end
incassUiCache = nil
function JB.stockLogDerived()
    local last = stockLog[1]
    local key = #stockLog .. "|" .. (last and (last.time or 0) or 0)
    local cc = JB.stkCache
    if cc and cc.key == key and os.clock() - cc.t < 5 then return cc.list end
    local list, pc = {}, {}
    for i, e in ipairs(stockLog) do
        local p = pc[e.itemId]
        if p == nil then p = getStockPrice(e.itemId) or 0; pc[e.itemId] = p end
        list[i] = {time = e.time, money = (e.amount or 0) * p, itemId = e.itemId, amount = e.amount or 0}
    end
    JB.stkCache = {key = key, t = os.clock(), list = list}
    return list
end
function JB.stockColor(id)
    if not JB.stkCol then
        JB.stkCol = {}
        for i, sid in ipairs(STOCK_ORDER) do JB.stkCol[sid] = WK.PAL[(i - 1) % #WK.PAL + 1] end
    end
    return JB.stkCol[id] or WK.PAL[1]
end
function JB.incassDef()
    JB.DF = JB.DF or {}
    if JB.DF.incass then return JB.DF.incass end
    local K = {}
    for k, v in pairs(WK.K(WORK_TYPES.MINE)) do K[k] = v end
    K.col = 0xFF33CC66
    K.icon = fa.ICON_MONEY
    K.cap = u8("Выплаты за банкоматы за сегодня")
    K.listTitle = u8("Выплаты за день")
    K.empty = u8("Данных по инкассации пока нет")
    K.emptySub = u8("Статистика появится автоматически после первой выплаты")
    K.noToday = u8("Сегодня выплат не было")
    K.emptyDay = u8("В этот день выплат не было")
    K.pl = {u8("выплата"), u8("выплаты"), u8("выплат")}
    local d = {
        id = "incass", K = K,
        log = function() return incassLog end,
        itemLabel = u8("Выплаты"),
        ovKey = "incassOverlayEnabled",
        ovCb = function() return cb_incass_overlay end,
    }
    d.rowCount = {
        icon = WK.ic("ICON_MONEY"), col = K.col, title = u8("Учитывать доход инкассатора"),
        desc = u8("Выплаты за банкоматы и полученные акции"),
        get = function() return cb_incass.v end,
        act = function()
            cb_incass.v = not cb_incass.v
            settings.incassEnabled = cb_incass.v
            saveConfig(); needSave = true
        end,
    }
    d.rowOverlay = {
        icon = WK.ic("ICON_DESKTOP"), col = K.col, title = u8("Оверлей на экране"),
        desc = u8("Выплаты и доход с акций за сегодня поверх игры"),
        get = function() return cb_incass_overlay.v end,
        act = function() JB.actOverlay(d) end,
    }
    JB.DF.incass = d
    return d
end
function JB.stockDef()
    JB.DF = JB.DF or {}
    if JB.DF.stock then return JB.DF.stock end
    local K = {}
    for k, v in pairs(WK.K(WORK_TYPES.MINE)) do K[k] = v end
    K.col = 0xFF33CCFF
    K.icon = fa.ICON_BRIEFCASE
    K.cap = u8("Доход с акций за сегодня")
    K.listTitle = u8("Акции за день")
    K.empty = u8("Полученных акций пока нет")
    K.emptySub = u8("Статистика появится автоматически после получения акции")
    K.noToday = u8("Сегодня акций не получено")
    K.emptyDay = u8("В этот день акций не получали")
    K.pl = {u8("получение"), u8("получения"), u8("получений")}
    local d = {
        id = "stock", K = K,
        log = JB.stockLogDerived,
        itemLabel = u8("Акции"),
        catOf = function(e)
            local info = STOCKS[e.itemId]
            return tostring(e.itemId), u8(info and info.ticker or ("item" .. tostring(e.itemId))), JB.stockColor(e.itemId)
        end,
        list = JB.stockList,
    }
    JB.DF.stock = d
    return d
end
function JB.stockList(d, dl, c, x, y, w, ACC, bg, brd)
    local K = d.K
    local S, C = PD.str(), PD.C
    local P = imgui.ImVec2
    local ds = c.byDate[PD.sel] or PD.EMPTY
    local th = imgui.CalcTextSize("A").y
    dl:AddText(P(x + 4, y + 5), 0xFFFFFFFF, K.listTitle)
    y = y + 34
    if ds.count == 0 then
        local eh = 92
        rhCardBox(dl, x, y, w, eh, bg, brd, 12)
        rhIconBadge(dl, x + w / 2, y + 32, 16, fa.ICON_CALENDAR, C.mute, bg, 0)
        local sz = imgui.CalcTextSize(K.emptyDay)
        dl:AddText(P(x + (w - sz.x) / 2, y + 60), C.mute, K.emptyDay)
        return y + eh + 8
    end
    local arr, qtyTotal, anyAvg, anyNoPrice = {}, 0, false, false
    for _, ce in pairs(ds.cats or {}) do
        arr[#arr + 1] = ce
        qtyTotal = qtyTotal + (ce.qty or 0)
    end
    table.sort(arr, function(a, b)
        if (a.qty or 0) ~= (b.qty or 0) then return (a.qty or 0) > (b.qty or 0) end
        return a.key < b.key
    end)
    local gap = 8
    local tw = (w - gap * 2) / 3
    local mh = 60
    local avgP = (qtyTotal > 0) and math.floor(ds.total / qtyTotal + 0.5) or 0
    local mini = {
        {label = u8("Получено"),     val = formatNumber(qtyTotal) .. u8(" шт."), icon = fa.ICON_BRIEFCASE, col = K.col},
        {label = u8("Видов акций"),  val = formatNumber(#arr),                   icon = fa.ICON_LIST,      col = C.sal},
        {label = u8("Средняя цена"), val = formatNumber(avgP) .. "$",            icon = fa.ICON_MONEY,     col = C.green},
    }
    for i, it in ipairs(mini) do
        local tx = x + (i - 1) * (tw + gap)
        rhCardBox(dl, tx, y, tw, mh, bg, brd, 12)
        rhIconBadge(dl, tx + 26, y + mh / 2, 15, it.icon, it.col, bg, 0)
        dl:PushClipRect(P(tx + 48, y), P(tx + tw - 8, y + mh), true)
        dl:AddText(P(tx + 50, y + 10), C.mute, it.label)
        dl:AddText(P(tx + 50, y + 30), 0xFFFFFFFF, it.val)
        dl:PopClipRect()
    end
    y = y + mh + 14
    local ncols = (w >= 520) and 2 or 1
    local cw = (w - gap * (ncols - 1)) / ncols
    local ch = 64
    for i, ce in ipairs(arr) do
        local id = tonumber(ce.key)
        local info = STOCKS[id]
        local price, isAvg = getStockPrice(id)
        if isAvg and price > 0 then anyAvg = true end
        if price <= 0 then anyNoPrice = true end
        local colI = (i - 1) % ncols
        local rowI = math.floor((i - 1) / ncols)
        local cx = x + colI * (cw + gap)
        local cy = y + rowI * (ch + gap)
        imgui.SetCursorScreenPos(P(cx, cy))
        imgui.InvisibleButton("##stk_card_" .. i, imgui.ImVec2(cw, ch))
        local hv = imgui.IsItemHovered()
        local a = rhAnim("stk_card_" .. i, hv and 1 or 0)
        local bgC = rhLerpColor(bg, rhLerpColor(bg, 0xFFFFFFFF, 0.04), a)
        rhCardBox(dl, cx, cy, cw, ch, bgC, rhLerpColor(brd, ce.col, 0.55 * a), 12)
        local chip = 36
        local chx, chy = cx + 14, cy + (ch - chip) / 2 - 4
        dl:AddRectFilled(P(chx, chy), P(chx + chip, chy + chip), rhAlpha(ce.col, 0.14 + 0.08 * a), 10)
        dl:AddRect(P(chx, chy), P(chx + chip, chy + chip), rhAlpha(ce.col, 0.45 + 0.3 * a), 10, 15, 1.0)
        local letter = ce.label:match("^[\1-\127\192-\255][\128-\191]*") or "?"
        local lsz = imgui.CalcTextSize(letter)
        dl:AddText(P(chx + (chip - lsz.x) / 2, chy + (chip - lsz.y) / 2), ce.col, letter)
        local tx = cx + 14 + chip + 12
        local incTxt = (price > 0) and ("+" .. formatNumber(ce.amount) .. "$") or "-"
        if imgui.CalcTextSize(incTxt).x > cw * 0.4 then incTxt = (price > 0) and ("+" .. PD.short(ce.amount) .. "$") or "-" end
        local incW = imgui.CalcTextSize(incTxt).x
        local name = info and u8(info.name) or ce.label
        dl:PushClipRect(P(tx, cy), P(cx + cw - 14 - incW - 8, cy + ch), true)
        local nameShow = name
        if imgui.CalcTextSize(nameShow).x > (cw - 14 - 36 - 12 - 14 - incW - 8 - 14) then nameShow = ce.label end
        dl:AddText(P(tx, cy + 9), 0xFFFFFFFF, nameShow)
        dl:PopClipRect()
        dl:AddText(P(cx + cw - 14 - incW, cy + 9), (price > 0) and C.green or C.dim, incTxt)
        local qtyTxt = formatNumber(ce.qty or 0) .. u8(" шт.")
        dl:AddText(P(tx, cy + 28), ce.col, qtyTxt)
        local priceTxt = (price > 0) and (formatNumber(price) .. "$" .. (isAvg and "*" or "") .. u8(" за шт.")) or u8("нет цены")
        local pw = imgui.CalcTextSize(priceTxt).x
        dl:AddText(P(cx + cw - 14 - pw, cy + 28), (isAvg and price > 0) and K.col or C.mute, priceTxt)
        local bx0, bx1, by = tx, cx + cw - 14, cy + ch - 14
        dl:AddRectFilled(P(bx0, by), P(bx1, by + 4), rhAlpha(0xFFFFFFFF, 0.07), 2)
        if qtyTotal > 0 then
            dl:AddRectFilled(P(bx0, by), P(bx0 + math.max(3, (bx1 - bx0) * ((ce.qty or 0) / qtyTotal)), by + 4), rhAlpha(ce.col, 0.9), 2)
        end
        if hv then
            rhTipBegin()
            imgui.TextColored(PD.vec4(ce.col), name)
            imgui.TextColored(PD.vec4(C.mute), u8("Получено: ") .. qtyTxt)
            imgui.TextColored(PD.vec4(C.mute), u8("Цена за шт.: ") .. ((price > 0) and (formatNumber(price) .. "$") or "-"))
            if price > 0 then imgui.TextColored(PD.vec4(C.green), u8("Доход: ") .. formatNumber(ce.amount) .. "$") end
            rhTipEnd()
        end
    end
    y = y + math.ceil(#arr / ncols) * (ch + gap)
    local fh = 50
    dl:AddRectFilled(P(x, y), P(x + w, y + fh), rhAlpha(ACC, 0.08), 12)
    dl:AddRect(P(x, y), P(x + w, y + fh), rhAlpha(ACC, 0.35), 12, 15, 1.0)
    local fty = y + (fh - th) / 2
    dl:AddText(P(x + 18, fty), ACC, S.itogo)
    dl:AddText(P(x + 19, fty), ACC, S.itogo)
    dl:AddText(P(x + 18 + imgui.CalcTextSize(S.itogo).x + 8, fty), C.dim, formatNumber(qtyTotal) .. u8(" шт."))
    local fTot = "+" .. formatNumber(ds.total) .. "$"
    local fw = imgui.CalcTextSize(fTot).x
    dl:AddText(P(x + w - 18 - fw, fty), C.green, fTot)
    dl:AddText(P(x + w - 17 - fw, fty), C.green, fTot)
    y = y + fh + 8
    dl:AddText(P(x + 6, y), C.dim, u8("Цены из Google таблицы, доход считается по ним"))
    y = y + 20
    if anyAvg then
        dl:AddText(P(x + 6, y), 0xFF33CCFF, u8("* для этой акции взята средняя стоимость за последнюю неделю"))
        y = y + 20
    end
    if anyNoPrice then
        dl:AddText(P(x + 6, y), C.dim, u8("Для части акций в таблице нет цены, они не учтены в доходе"))
        y = y + 20
    end
    return y + 8
end
function JB.incassMenu()
    local d = JB.incassDef()
    local K = d.K
    local dl = imgui.GetWindowDrawList()
    local P = imgui.ImVec2
    local C = PD.C
    local bg, brd = homeCardColors()
    local cur = imgui.GetCursorScreenPos()
    local x, y = cur.x, cur.y + 4
    local w = imgui.GetWindowWidth() - 25
    local WARN = 0xFF2896FF
    local scanCol, scanIcon, scanText
    local scanned = stockScannedThisSession
    if scanState.active then
        scanCol = C.gold; scanIcon = WK.ic("ICON_REFRESH"); scanText = u8("Сканирование: ") .. u8(scanState.statusText or "")
    elseif scanned then
        scanCol = C.green; scanIcon = WK.ic("ICON_CHECK"); scanText = u8("Инвентарь отсканирован")
    else
        scanCol = WARN; scanIcon = WK.ic("ICON_EXCLAMATION_TRIANGLE"); scanText = u8("Инвентарь не отсканирован")
    end
    local sh, btnW = 84, 220
    rhCardBox(dl, x, y, w, sh, bg, scanned and brd or rhAlpha(scanCol, 0.55), 14)
    rhIconBadge(dl, x + 38, y + sh / 2, 20, scanIcon, scanCol, bg, 0)
    dl:PushClipRect(P(x + 72, y), P(x + w - btnW - 28, y + sh), true)
    dl:AddText(P(x + 72, y + 20), scanCol, scanText)
    dl:AddText(P(x + 72, y + 46), C.mute, u8("Сканирование нужно для точного учёта акций"))
    dl:PopClipRect()
    local btnText = scanState.active and u8("Сканирование...") or (scanned and u8("Пересканировать инвентарь") or u8("Сканировать инвентарь"))
    if WK.button(dl, "##jb_stock_scan", x + w - btnW - 16, y + (sh - 40) / 2, btnW, 40, btnText, WK.ic("ICON_SEARCH"),
                 scanned and C.mute or scanCol, not scanned, scanState.active) then
        startStockScan()
    end
    y = y + sh + 14
    dl:AddText(P(x + 4, y + 5), 0xFFFFFFFF, u8("Режим счёта"))
    y = y + 34
    if WK.row(dl, "jb_count_incass", x, y, w, 62, bg, brd, d.rowCount, nil) then d.rowCount.act() end
    y = y + 62 + 14
    dl:AddText(P(x + 4, y + 5), 0xFFFFFFFF, u8("Оверлей"))
    y = y + 34
    if WK.row(dl, "jb_ovl_incass", x, y, w, 56, bg, brd, d.rowOverlay, nil) then d.rowOverlay.act() end
    y = y + 56 + 14
    local s = getIncassSummary()
    local star = s.anyPriced and "*" or ""
    local COL_ATM, COL_STK = 0xFF33CC66, 0xFF33CCFF
    local gap = 8
    local cw = (w - gap * 2) / 3
    local chh = 104
    local periods = {
        {key = "all",   label = u8("Общий заработок"), b = s.all,   col = C.acc},
        {key = "today", label = u8("За сегодня"),      b = s.today, col = C.sal},
        {key = "week",  label = u8("За неделю"),       b = s.week,  col = C.dep},
    }
    for i, p in ipairs(periods) do
        local cx = x + (i - 1) * (cw + gap)
        local b = p.b
        rhCardBox(dl, cx, y, cw, chh, bg, brd, 12)
        dl:PushClipRect(P(cx + 4, y), P(cx + cw - 4, y + chh), true)
        dl:AddText(P(cx + 14, y + 10), C.mute, p.label)
        local tot = formatNumber(b.total) .. "$" .. star
        dl:AddText(P(cx + 14, y + 30), p.col, tot)
        dl:AddLine(P(cx + 14, y + 54), P(cx + cw - 14, y + 54), rhAlpha(0xFFFFFFFF, 0.07), 1.0)
        local rowsD = {
            {u8("Банкоматы"), formatNumber(b.money) .. "$", COL_ATM},
            {u8("Акции"), formatNumber(b.stockIncome) .. "$" .. star, COL_STK},
        }
        for r, row in ipairs(rowsD) do
            local ry = y + 62 + (r - 1) * 18
            dl:AddText(P(cx + 14, ry), C.dim, row[1])
            local vw = imgui.CalcTextSize(row[2]).x
            dl:AddText(P(cx + cw - 14 - vw, ry), row[3], row[2])
        end
        dl:PopClipRect()
    end
    y = y + chh + 12
    local td = s.today
    local tw2 = (w - gap) / 2
    local th2 = 74
    local avg = (td.payouts > 0) and math.floor(td.money / td.payouts + 0.5) or 0
    local det = {
        {label = u8("Банкоматы сегодня"), icon = fa.ICON_MONEY, col = COL_ATM,
         val = formatNumber(td.money) .. "$", sub = u8("Выплат: ") .. td.payouts .. u8(", в среднем ") .. formatNumber(avg) .. "$"},
        {label = u8("Акции сегодня"), icon = fa.ICON_BRIEFCASE, col = COL_STK,
         val = formatNumber(td.stockIncome) .. "$" .. star, sub = u8("Получено: ") .. td.stocks .. u8(" шт.")},
    }
    for i, it in ipairs(det) do
        local tx = x + (i - 1) * (tw2 + gap)
        rhCardBox(dl, tx, y, tw2, th2, bg, brd, 12)
        rhIconBadge(dl, tx + 28, y + th2 / 2, 17, it.icon, it.col, bg, 0)
        dl:PushClipRect(P(tx + 52, y), P(tx + tw2 - 8, y + th2), true)
        dl:AddText(P(tx + 54, y + 10), C.mute, it.label)
        dl:AddText(P(tx + 54, y + 28), it.col, it.val)
        dl:AddText(P(tx + 54, y + 48), C.dim, it.sub)
        dl:PopClipRect()
    end
    y = y + th2 + 10
    if s.anyPriced then
        dl:AddText(P(x + 6, y), 0xFF33CCFF, u8("* доход с акций считается по средней цене за последнюю неделю, а не по цене на сегодня"))
        y = y + 20
    end
    if s.missing then
        dl:AddText(P(x + 6, y), C.dim, u8("Для части акций в таблице нет цены, они не учтены в доходе"))
        y = y + 20
    end
    imgui.SetCursorScreenPos(P(x, y + 4))
    imgui.Dummy(imgui.ImVec2(w, 6))
end
function drawIncassTab()
    incassWorkActive = true
    oilWorkActive = false
    JB.sec = JB.sec or {}
    local sec = JB.sec.incass
    if not sec then sec = {v = 0, last = 0}; JB.sec.incass = sec end
    if os.clock() - sec.last > 0.4 then sec.v = 0 end
    sec.last = os.clock()
    local names = {u8("Меню"), u8("Выплаты"), u8("Акции")}
    local clicked = SegmentedTabs("incass", names, sec.v)
    if clicked then sec.v = clicked end
    imgui.Spacing(); imgui.Separator(); imgui.Spacing()
    if sec.v == 0 then JB.incassMenu()
    elseif sec.v == 1 then JB.draw(JB.incassDef())
    else JB.draw(JB.stockDef()) end
end
function drawFarmTab()
    WK.workTab(WORK_TYPES.FARM, "farm", u8("Ферма"))
end
WK = WK or {}
WK.state = WK.state or {}
WK.cache = WK.cache or {}
WK.PAL = {0xFFF8BD38, 0xFFFA8BA7, 0xFF28AAFF, 0xFF33DD77, 0xFF00CCFF, 0xFFB672F4, 0xFF3D8AFF, 0xFFFFE040}
WK.RES_COL = {
    stone = 0xFFB4B4B4, metal = 0xFFC8A47A, bronze = 0xFF3C82CD, silver = 0xFFE6DCD2, gold = 0xFF38C8F8,
    diamond = 0xFFFFE040, tkan = 0xFFF472B6, splav = 0xFF3D8AFF, materia = 0xFFFF4D7C, azbox = 0xFF00CCFF,
    flax = 0xFF5AC878, cotton = 0xFFF0F0F0, rare_tkan = 0xFFF472B6, water = 0xFFFFA040, dye = 0xFFA78BFA, coal = 0xFF8A8A8A,
    firewood = 0xFF4682BE, quality_wood = 0xFF5AC8FF,
}
function WK.K(wt)
    WK.KK = WK.KK or {}
    if WK.KK[wt] then return WK.KK[wt] end
    local K
    if wt == WORK_TYPES.MINE then
        K = {
            col = 0xFF28AAFF, icon = fa.ICON_GAVEL,
            cap = u8("Доход с шахты за сегодня"),
            listTitle = u8("Добыча за день"),
            empty = u8("Данных по шахте пока нет"),
            emptySub = u8("Статистика появится автоматически после первого добытого ресурса"),
            noToday = u8("Сегодня в шахте ничего не добыто"),
            emptyDay = u8("В этот день ничего не добывалось"),
        }
    elseif wt == WORK_TYPES.FARM then
        K = {
            col = 0xFF1AE591, icon = fa.ICON_LEAF,
            cap = u8("Доход с фермы за сегодня"),
            listTitle = u8("Сбор за день"),
            empty = u8("Данных по ферме пока нет"),
            emptySub = u8("Статистика появится автоматически после первого собранного ресурса"),
            noToday = u8("Сегодня на ферме ничего не собрано"),
            emptyDay = u8("В этот день ничего не собиралось"),
        }
    else
        K = {
            col = 0xFF99D334, icon = fa.ICON_TREE,
            cap = u8("Доход с лесопилки за сегодня"),
            listTitle = u8("Заготовка за день"),
            empty = u8("Данных по лесопилке пока нет"),
            emptySub = u8("Статистика появится автоматически после первого полученного ресурса"),
            noToday = u8("Сегодня на лесопилке ничего не получено"),
            emptyDay = u8("В этот день ресурсы не получались"),
        }
    end
    K.pl = {u8("ресурс"), u8("ресурса"), u8("ресурсов")}
    K.hoursTitle = u8("Активность по часам")
    K.peak = u8("Пик: ")
    K.avgH = u8("ср. ")
    K.hourSuffix = u8("ч")
    K.other = u8("Прочее")
    K.priceL = u8("Цена: ")
    K.incomeL = u8("Доход: ")
    K.qtyL = u8("Количество: ")
    K.shareL = u8("Доля дохода: ")
    K.rare = u8("Редкий ресурс")
    K.noAct = u8("Нет активности")
    WK.KK[wt] = K
    return K
end
function WK.col(cfg, k)
    if WK.RES_COL[k] then return WK.RES_COL[k] end
    for i, kk in ipairs(cfg.resourceOrder) do
        if kk == k then return WK.PAL[(i - 1) % #WK.PAL + 1] end
    end
    return WK.PAL[1]
end
function WK.isRare(cfg, k)
    for _, r in ipairs(cfg.rareResources or {}) do
        if r == k then return true end
    end
    return false
end
function WK.build(wt)
    local K = WK.K(wt)
    local cfg = configs[wt]
    local log = resourceLog or {}
    local todayKey = getGameDate()
    local price, psig = {}, 0
    for i, k in ipairs(cfg.resourceOrder) do
        price[k] = getPriceForResource(k, wt) or 0
        psig = psig + price[k] * i
    end
    local last = log[#log]
    local sig = wt .. "|" .. #log .. "|" .. todayKey .. "|" .. psig
    if last then sig = sig .. "|" .. (last.time or 0) .. "|" .. (last.amount or 0) end
    local cc = WK.cache[wt]
    if cc and cc.sig == sig and os.clock() - cc.t < 1.5 then return cc end
    local lbl, col = {}, {}
    for _, k in ipairs(cfg.resourceOrder) do
        lbl[k] = u8(cfg.resourceNames[k] or k)
        col[k] = WK.col(cfg, k)
    end
    local byDate, dates = {}, {}
    local all = {total = 0, az = 0, rub = 0, count = 0}
    for _, e in ipairs(log) do
        local k = e.resource
        local amt = e.amount or 0
        local val = amt * (price[k] or 0)
        local d = getGameDate(e.time)
        local ds = byDate[d]
        if not ds then
            ds = {total = 0, az = 0, rub = 0, count = 0, best = 0, cats = {}, hours = {}, pl = K.pl}
            byDate[d] = ds
            dates[#dates + 1] = d
        end
        ds.total = ds.total + val
        ds.count = ds.count + amt
        local ce = ds.cats[k]
        if not ce then
            ce = {key = k, label = lbl[k] or tostring(k), col = col[k] or WK.PAL[1], amount = 0, count = 0}
            ds.cats[k] = ce
        end
        ce.amount = ce.amount + val
        ce.count = ce.count + amt
        if ce.amount > ds.best then ds.best = ce.amount end
        local hi = math.floor((((e.time or 0) + 10800 - 18000) % 86400) / 3600)
        local hb = ds.hours[hi]
        if not hb then hb = {total = 0, count = 0}; ds.hours[hi] = hb end
        hb.total = hb.total + val
        hb.count = hb.count + amt
        all.total = all.total + val
        all.count = all.count + amt
    end
    table.sort(dates, function(a, b) return a > b end)
    local mskWday = tonumber(os.date("!%w", getMoscowTime())) or 1
    if mskWday == 0 then mskWday = 7 end
    local week = {total = 0, az = 0, rub = 0, count = 0}
    for i = 0, mskWday - 1 do
        local ds = byDate[getGameDate(os.time() - i * 86400)]
        if ds then
            week.total = week.total + ds.total
            week.count = week.count + ds.count
        end
    end
    local last7 = {}
    for i = 6, 0, -1 do
        local d = getGameDate(os.time() - i * 86400)
        local ds = byDate[d]
        last7[#last7 + 1] = {date = d, wd = PD.weekday(d), total = ds and ds.total or 0, az = 0, count = ds and ds.count or 0}
    end
    local yestKey = getGameDate(os.time() - 86400)
    local out = {
        sig = sig, t = os.clock(), price = price,
        byDate = byDate, dates = dates, all = all, week = week, last7 = last7,
        todayKey = todayKey, yestKey = yestKey, pl = K.pl,
        today = byDate[todayKey] or PD.EMPTY, yest = byDate[yestKey] or PD.EMPTY,
    }
    WK.cache[wt] = out
    return out
end
function WK.hero(dl, c, x, y, w, h, ACC, bg, brd, K)
    local C, S = PD.C, PD.str()
    local P = imgui.ImVec2
    local td = c.today
    local lw = math.floor(w * 0.56)
    rhCardBox(dl, x, y, w, h, bg, brd, 14)
    dl:AddLine(P(x + lw, y + 18), P(x + lw, y + h - 18), rhAlpha(0xFFFFFFFF, 0.06), 1.0)
    rhIconBadge(dl, x + 34, y + 27, 11, K.icon, K.col, bg, 0)
    dl:AddText(P(x + 54, y + 19), C.mute, K.cap)
    local big = formatNumber(td.total) .. "$"
    if rhBigFont then imgui.PushFont(rhBigFont) end
    local bsz = imgui.CalcTextSize(big)
    if rhBigFont then imgui.PopFont() end
    if bsz.x > lw - 44 then big = PD.short(td.total) .. "$" end
    if rhBigFont then
        imgui.PushFont(rhBigFont)
        imgui.SetCursorScreenPos(P(x + 22, y + 40))
        imgui.TextColored(PD.vec4(C.green), big)
        imgui.PopFont()
    else
        dl:AddText(P(x + 22, y + 44), C.green, big)
        dl:AddText(P(x + 23, y + 44), C.green, big)
    end
    local px, py = x + 22, y + 82
    local function pill(text, pc)
        px = px + rhPill(dl, px, py, text, pc) + 6
    end
    if td.count > 0 then
        pill(formatNumber(td.count) .. " " .. PD.plural(td.count, K.pl), K.col)
        local ah = 0
        for _, hb in pairs(td.hours or {}) do
            if hb.count > 0 then ah = ah + 1 end
        end
        if ah > 0 and td.total > 0 then
            pill(K.avgH .. PD.short(td.total / ah) .. "$/" .. K.hourSuffix, C.mute)
        end
    end
    local bx0, bx1, by = x + 22, x + lw - 20, y + h - 40
    dl:AddRectFilled(P(bx0, by), P(bx1, by + 8), rhAlpha(0xFFFFFFFF, 0.07), 4)
    local arr = {}
    for _, ce in pairs(td.cats or {}) do arr[#arr + 1] = ce end
    table.sort(arr, function(a, b)
        if a.amount ~= b.amount then return a.amount > b.amount end
        return a.count > b.count
    end)
    if td.count > 0 and #arr > 0 then
        local sumAmt = 0
        for _, ce in ipairs(arr) do sumAmt = sumAmt + ce.amount end
        local useCnt = (sumAmt <= 0)
        local function wt(ce) return useCnt and ce.count or ce.amount end
        local parts = {}
        local limit = (#arr > 4) and 3 or #arr
        for i = 1, limit do parts[#parts + 1] = {wt(arr[i]), arr[i].col, arr[i].label} end
        if #arr > limit then
            local rest = 0
            for i = limit + 1, #arr do rest = rest + wt(arr[i]) end
            parts[#parts + 1] = {rest, C.dim, K.other}
        end
        local sum = 0
        for _, p in ipairs(parts) do sum = sum + p[1] end
        if sum <= 0 then sum = 1 end
        local present = {}
        for _, p in ipairs(parts) do if p[1] > 0 then present[#present + 1] = p end end
        local gap = 2
        local usable = (bx1 - bx0) - gap * math.max(#present - 1, 0)
        local cx = bx0
        for _, p in ipairs(present) do
            local pw = math.max(usable * (p[1] / sum), 3)
            dl:AddRectFilled(P(cx, by), P(cx + pw, by + 8), p[2], 4)
            cx = cx + pw + gap
        end
        local items, totalW = {}, 0
        for _, p in ipairs(present) do
            local pct = math.floor(p[1] / sum * 100 + 0.5)
            local txt = p[3] .. " " .. pct .. "%"
            items[#items + 1] = {col = p[2], txt = txt}
            totalW = totalW + 22 + imgui.CalcTextSize(txt).x
        end
        while #items > 1 and totalW > (bx1 - bx0) + 10 do
            totalW = totalW - 22 - imgui.CalcTextSize(items[#items].txt).x
            items[#items] = nil
        end
        local lx = bx0
        for _, it in ipairs(items) do
            dl:AddCircleFilled(P(lx + 4, by + 22), 3, it.col, 12)
            dl:AddText(P(lx + 12, by + 14), 0xFFB8B8B8, it.txt)
            lx = lx + 22 + imgui.CalcTextSize(it.txt).x
        end
    else
        dl:AddText(P(bx0, by + 14), C.dim, K.noToday)
    end
    local rx0, rx1 = x + lw + 20, x + w - 20
    local rw = rx1 - rx0
    dl:AddText(P(rx0, y + 14), C.mute, S.last7)
    local cy0, cy1 = y + 44, y + h - 36
    local chH = cy1 - cy0
    local slot = rw / 7
    local bw = math.max(8, slot - 10)
    local maxV = 1
    for _, d in ipairs(c.last7) do if d.total > maxV then maxV = d.total end end
    for i, d in ipairs(c.last7) do
        local sx = rx0 + (i - 1) * slot
        local bxx = sx + (slot - bw) / 2
        imgui.SetCursorScreenPos(P(sx, cy0 - 6))
        local clicked = imgui.InvisibleButton("##wk_bar_" .. i, imgui.ImVec2(slot, chH + 6 + 28))
        local hv = imgui.IsItemHovered()
        local a = rhAnim("wk_bar_" .. i, hv and 1 or 0)
        local isToday = (d.date == c.todayKey)
        local isSel = (d.date == PD.sel)
        local bh = d.total > 0 and math.max(4, chH * d.total / maxV) or 2
        local bcol
        if d.total <= 0 then
            bcol = rhAlpha(0xFFFFFFFF, 0.07 + 0.06 * a)
        else
            local base = rhLerpColor(bg, ACC, isToday and 1 or 0.5)
            bcol = rhLerpColor(base, 0xFFFFFFFF, 0.22 * a)
        end
        dl:AddRectFilled(P(bxx, cy1 - bh), P(bxx + bw, cy1), bcol, 4, 3)
        if isSel then
            dl:AddRect(P(bxx - 2, cy1 - bh - 2), P(bxx + bw + 2, cy1 + 2), rhAlpha(0xFFFFFFFF, 0.7), 5, 15, 1.2)
        end
        local lb = S.wd[d.wd]
        local lsz = imgui.CalcTextSize(lb)
        dl:AddText(P(sx + (slot - lsz.x) / 2, cy1 + 8), isToday and ACC or (isSel and 0xFFFFFFFF or C.mute), lb)
        if hv then
            rhTipBegin()
            PD.dayTip(d.date, c.byDate[d.date])
            rhTipEnd()
        end
        if clicked then PD.select(d.date) end
    end
end
function WK.tiles(dl, c, x, y, w, h, ACC, bg, brd, K)
    local S, C = PD.str(), PD.C
    local P = imgui.ImVec2
    local gap = 8
    local tw = (w - gap * 2) / 3
    local items = {
        {key = "y", label = S.yest, icon = fa.ICON_CALENDAR, col = C.sal, d = c.yest},
        {key = "w", label = S.week, icon = fa.ICON_LIST, col = C.dep, d = c.week},
        {key = "a", label = S.allTime, icon = fa.ICON_TROPHY, col = C.acc, d = c.all},
    }
    for i, it in ipairs(items) do
        local tx = x + (i - 1) * (tw + gap)
        imgui.SetCursorScreenPos(P(tx, y))
        imgui.InvisibleButton("##wk_tile_" .. it.key, imgui.ImVec2(tw, h))
        local hv = imgui.IsItemHovered()
        local a = rhAnim("wk_tile_" .. it.key, hv and 1 or 0)
        local bgT = rhLerpColor(bg, rhLerpColor(bg, 0xFFFFFFFF, 0.04), a)
        rhCardBox(dl, tx, y, tw, h, bgT, rhLerpColor(brd, it.col, 0.55 * a), 12)
        rhIconBadge(dl, tx + 28, y + h / 2, 17, it.icon, it.col, bgT, a)
        local d = it.d
        local cnt = d.count or 0
        dl:PushClipRect(P(tx + 52, y), P(tx + tw - 8, y + h), true)
        dl:AddText(P(tx + 54, y + 10), C.mute, it.label)
        dl:AddText(P(tx + 54, y + 28), 0xFFFFFFFF, formatNumber(d.total or 0) .. "$")
        dl:AddText(P(tx + 54, y + 48), cnt > 0 and it.col or C.dim, formatNumber(cnt) .. " " .. PD.plural(cnt, K.pl))
        dl:PopClipRect()
        if hv and cnt > 0 then
            rhTipBegin()
            imgui.TextColored(PD.vec4(0xFFFFFFFF), it.label)
            imgui.TextColored(PD.vec4(C.green), formatNumber(d.total) .. "$")
            imgui.TextColored(PD.vec4(C.mute), formatNumber(cnt) .. " " .. PD.plural(cnt, K.pl))
            rhTipEnd()
        end
    end
end
function WK.hours(dl, c, x, y, w, h, ACC, bg, brd, K)
    local C = PD.C
    local P = imgui.ImVec2
    local ds = c.byDate[PD.sel] or PD.EMPTY
    local hrs = ds.hours or {}
    local useCnt = (ds.total <= 0)
    local function mval(hb)
        if not hb then return 0 end
        return useCnt and hb.count or hb.total
    end
    rhCardBox(dl, x, y, w, h, bg, brd, 14)
    dl:AddText(P(x + 18, y + 12), 0xFFFFFFFF, K.hoursTitle)
    local maxV, peakI = 0, nil
    for i = 0, 23 do
        local v = mval(hrs[i])
        if v > maxV then maxV = v; peakI = i end
    end
    if peakI then
        local pt = K.peak .. string.format("%02d:00", (5 + peakI) % 24)
        dl:AddText(P(x + w - 18 - imgui.CalcTextSize(pt).x, y + 12), K.col, pt)
    end
    local x0, x1 = x + 18, x + w - 18
    local slot = (x1 - x0) / 24
    local bw = math.max(4, slot - 4)
    local cy0, cy1 = y + 40, y + h - 26
    local chH = cy1 - cy0
    local nowIdx = math.floor(((os.time() + 10800 - 18000) % 86400) / 3600)
    local isTodaySel = (PD.sel == c.todayKey)
    for i = 0, 23 do
        local sx = x0 + i * slot
        local bxx = sx + (slot - bw) / 2
        local hb = hrs[i]
        local v = mval(hb)
        imgui.SetCursorScreenPos(P(sx, cy0 - 4))
        imgui.InvisibleButton("##wk_h_" .. i, imgui.ImVec2(slot, chH + 4 + 22))
        local hv = imgui.IsItemHovered()
        local a = rhAnim("wk_h_" .. i, hv and 1 or 0)
        local bh = (v > 0 and maxV > 0) and math.max(3, chH * v / maxV) or 2
        local bcol
        if v <= 0 then
            bcol = rhAlpha(0xFFFFFFFF, 0.06 + 0.05 * a)
        else
            local base = rhLerpColor(bg, K.col, (i == peakI) and 1 or 0.55)
            bcol = rhLerpColor(base, 0xFFFFFFFF, 0.22 * a)
        end
        dl:AddRectFilled(P(bxx, cy1 - bh), P(bxx + bw, cy1), bcol, 3, 3)
        if isTodaySel and i == nowIdx then
            dl:AddRect(P(bxx - 2, cy1 - bh - 2), P(bxx + bw + 2, cy1 + 2), rhAlpha(0xFFFFFFFF, 0.6), 4, 15, 1.0)
        end
        if i % 3 == 0 then
            local lb = string.format("%02d", (5 + i) % 24)
            local lsz = imgui.CalcTextSize(lb)
            dl:AddText(P(sx + (slot - lsz.x) / 2, cy1 + 7), hv and 0xFFFFFFFF or C.mute, lb)
        end
        if hv then
            rhTipBegin()
            imgui.TextColored(PD.vec4(0xFFFFFFFF), string.format("%02d:00 - %02d:00", (5 + i) % 24, (6 + i) % 24))
            if hb and hb.count > 0 then
                imgui.TextColored(PD.vec4(C.green), formatNumber(hb.total) .. "$")
                imgui.TextColored(PD.vec4(C.mute), formatNumber(hb.count) .. " " .. PD.plural(hb.count, K.pl))
            else
                imgui.TextColored(PD.vec4(C.mute), K.noAct)
            end
            rhTipEnd()
        end
    end
end
function WK.list(dl, c, x, y, w, ACC, bg, brd, K, wt)
    local S, C = PD.str(), PD.C
    local P = imgui.ImVec2
    local cfg = configs[wt]
    local ds = c.byDate[PD.sel] or PD.EMPTY
    local th = imgui.CalcTextSize("A").y
    dl:AddText(P(x + 4, y + 5), 0xFFFFFFFF, K.listTitle)
    y = y + 34
    if ds.count == 0 then
        local eh = 92
        rhCardBox(dl, x, y, w, eh, bg, brd, 12)
        rhIconBadge(dl, x + w / 2, y + 32, 16, fa.ICON_CALENDAR, C.mute, bg, 0)
        local sz = imgui.CalcTextSize(K.emptyDay)
        dl:AddText(P(x + (w - sz.x) / 2, y + 60), C.mute, K.emptyDay)
        return y + eh + 8
    end
    local arr = {}
    for _, ce in pairs(ds.cats or {}) do
        if ce.count > 0 then arr[#arr + 1] = ce end
    end
    table.sort(arr, function(a, b)
        if a.amount ~= b.amount then return a.amount > b.amount end
        return a.count > b.count
    end)
    local gap = 8
    local ncols = (w >= 520) and 2 or 1
    local cw = (w - gap * (ncols - 1)) / ncols
    local ch = 64
    local sumAmt = ds.total > 0 and ds.total or 1
    local topAmt = arr[1] and arr[1].amount or 0
    for i, ce in ipairs(arr) do
        local colI = (i - 1) % ncols
        local rowI = math.floor((i - 1) / ncols)
        local cx = x + colI * (cw + gap)
        local cy = y + rowI * (ch + gap)
        imgui.SetCursorScreenPos(P(cx, cy))
        imgui.InvisibleButton("##wk_res_" .. i, imgui.ImVec2(cw, ch))
        local hv = imgui.IsItemHovered()
        local a = rhAnim("wk_res_" .. i, hv and 1 or 0)
        local bgC = rhLerpColor(bg, rhLerpColor(bg, 0xFFFFFFFF, 0.04), a)
        local isTop = (#arr > 1 and i == 1 and topAmt > 0)
        rhCardBox(dl, cx, cy, cw, ch, bgC, rhLerpColor(brd, ce.col, 0.55 * a), 12)
        if isTop then dl:AddRectFilled(P(cx + 6, cy + 3), P(cx + cw - 6, cy + ch - 3), rhAlpha(C.gold, 0.04), 9) end
        local chip = 36
        local chx, chy = cx + 14, cy + (ch - chip) / 2 - 4
        dl:AddRectFilled(P(chx, chy), P(chx + chip, chy + chip), rhAlpha(ce.col, 0.14 + 0.08 * a), 10)
        dl:AddRect(P(chx, chy), P(chx + chip, chy + chip), rhAlpha(ce.col, 0.45 + 0.3 * a), 10, 15, 1.0)
        local letter = ce.label:match("^[\1-\127\192-\255][\128-\191]*") or "?"
        local lsz = imgui.CalcTextSize(letter)
        dl:AddText(P(chx + (chip - lsz.x) / 2, chy + (chip - lsz.y) / 2), ce.col, letter)
        local rare = WK.isRare(cfg, ce.key)
        if rare then
            local ssz = imgui.CalcTextSize(fa.ICON_STAR)
            dl:AddText(P(chx + chip - ssz.x + 3, chy - 5), C.gold, fa.ICON_STAR)
        end
        local tx = cx + 14 + chip + 12
        local incTxt = formatNumber(ce.amount) .. "$"
        if imgui.CalcTextSize(incTxt).x > cw * 0.45 then incTxt = PD.short(ce.amount) .. "$" end
        local incW = imgui.CalcTextSize(incTxt).x
        local pct = math.floor(ce.amount / sumAmt * 100 + 0.5)
        if ds.total <= 0 then pct = 0 end
        local pctTxt = pct .. "%"
        dl:PushClipRect(P(tx, cy), P(cx + cw - 14 - incW - 8, cy + ch), true)
        dl:AddText(P(tx, cy + 9), 0xFFFFFFFF, ce.label)
        dl:PopClipRect()
        dl:AddText(P(cx + cw - 14 - incW, cy + 9), C.green, incTxt)
        dl:AddText(P(tx, cy + 28), ce.col, "x" .. formatNumber(ce.count))
        dl:AddText(P(cx + cw - 14 - imgui.CalcTextSize(pctTxt).x, cy + 28), C.mute, pctTxt)
        local bx0, bx1, by = tx, cx + cw - 14, cy + ch - 14
        dl:AddRectFilled(P(bx0, by), P(bx1, by + 4), rhAlpha(0xFFFFFFFF, 0.07), 2)
        if ds.total > 0 then
            dl:AddRectFilled(P(bx0, by), P(bx0 + math.max(3, (bx1 - bx0) * (ce.amount / ds.total)), by + 4), rhAlpha(ce.col, 0.9), 2)
        end
        if hv then
            rhTipBegin()
            imgui.TextColored(PD.vec4(ce.col), ce.label)
            if rare then imgui.TextColored(PD.vec4(C.gold), K.rare) end
            imgui.TextColored(PD.vec4(C.mute), K.qtyL .. formatNumber(ce.count))
            imgui.TextColored(PD.vec4(C.mute), K.priceL .. formatNumber(c.price[ce.key] or 0) .. "$")
            imgui.TextColored(PD.vec4(C.green), K.incomeL .. formatNumber(ce.amount) .. "$")
            if ds.total > 0 then imgui.TextColored(PD.vec4(C.mute), K.shareL .. pct .. "%") end
            rhTipEnd()
        end
    end
    local rows = math.ceil(#arr / ncols)
    y = y + rows * (ch + gap)
    local fh = 50
    dl:AddRectFilled(P(x, y), P(x + w, y + fh), rhAlpha(ACC, 0.08), 12)
    dl:AddRect(P(x, y), P(x + w, y + fh), rhAlpha(ACC, 0.35), 12, 15, 1.0)
    local fty = y + (fh - th) / 2
    dl:AddText(P(x + 18, fty), ACC, S.itogo)
    dl:AddText(P(x + 19, fty), ACC, S.itogo)
    dl:AddText(P(x + 18 + imgui.CalcTextSize(S.itogo).x + 8, fty), C.dim, "x" .. formatNumber(ds.count))
    local fTot = formatNumber(ds.total) .. "$"
    local fw = imgui.CalcTextSize(fTot).x
    dl:AddText(P(x + w - 18 - fw, fty), C.green, fTot)
    dl:AddText(P(x + w - 17 - fw, fty), C.green, fTot)
    return y + fh + 12
end
function WK.drawInner(wt, K)
    local dl = imgui.GetWindowDrawList()
    local P = imgui.ImVec2
    local C = PD.C
    local c = WK.build(wt)
    PD.ensureSel(c)
    local bg, brd, iconCol = homeCardColors()
    local ACC = useCustomTheme and iconCol or 0xFF1AE591
    local cur = imgui.GetCursorScreenPos()
    local x, y = cur.x, cur.y + 4
    local w = imgui.GetWindowWidth() - 25
    WK.hero(dl, c, x, y, w, 152, ACC, bg, brd, K)
    y = y + 152 + 10
    WK.tiles(dl, c, x, y, w, 74, ACC, bg, brd, K)
    y = y + 74 + 12
    if #c.dates == 0 then
        local eh = 130
        rhCardBox(dl, x, y, w, eh, bg, brd, 14)
        rhIconBadge(dl, x + w / 2, y + 40, 20, K.icon, K.col, bg, 0)
        local s1, s2 = imgui.CalcTextSize(K.empty), imgui.CalcTextSize(K.emptySub)
        dl:AddText(P(x + (w - s1.x) / 2, y + 74), 0xFFFFFFFF, K.empty)
        dl:AddText(P(x + (w - s2.x) / 2, y + 96), C.mute, K.emptySub)
        y = y + eh + 10
    else
        PD.nav(dl, c, x, y, w, 46, ACC, bg, brd)
        y = y + 46 + 12
        local ds = c.byDate[PD.sel] or PD.EMPTY
        if ds.count > 0 then
            WK.hours(dl, c, x, y, w, 108, ACC, bg, brd, K)
            y = y + 108 + 12
        end
        y = WK.list(dl, c, x, y, w, ACC, bg, brd, K, wt)
    end
    imgui.SetCursorScreenPos(P(x, y))
    imgui.Dummy(imgui.ImVec2(w, 6))
end
function WK.draw(wt)
    if currentWork ~= wt or not configs[wt] then return end
    local K = WK.K(wt)
    WK.state[wt] = WK.state[wt] or {}
    local st = WK.state[wt]
    local s0, y0, m0 = PD.sel, PD.calY, PD.calM
    PD.sel, PD.calY, PD.calM = st.sel, st.calY, st.calM
    local ok, err = pcall(WK.drawInner, wt, K)
    st.sel, st.calY, st.calM = PD.sel, PD.calY, PD.calM
    PD.sel, PD.calY, PD.calM = s0, y0, m0
    if not ok then error(err, 0) end
end
WK.gotoTab = WK.gotoTab or {}
function WK.ic(name, fb)
    return fa[name] or fa[fb or "ICON_LIST"] or "?"
end
function WK.T()
    if WK.TT then return WK.TT end
    WK.TT = {
        scanActive = u8("Сканирование: "),
        scanDone = u8("Инвентарь отсканирован"),
        scanNone = u8("Инвентарь не отсканирован"),
        scanHint = u8("Сканируй инвентарь перед началом сбора ресурсов"),
        scanBtnActive = u8("Сканирование..."),
        scanBtnAgain = u8("Пересканировать инвентарь"),
        scanBtn = u8("Сканировать инвентарь"),
        modesTitle = u8("Режимы счёта"),
        overlayTitle = u8("Оверлей"),
        todayCap = u8("Доход за сегодня"),
        more = u8("Подробнее"),
        pricesTitle = u8("Цены ресурсов"),
        customLbl = u8("Свои цены"),
        hintAuto1 = u8("Цены средние по Vice City под SA"),
        hintAuto2 = u8("Авто-обновление раз в сутки"),
        hintCustom1 = u8("Свои цены включены"),
        hintCustom2 = u8("Участие в рейтинге отключено"),
        updating = u8("Цены обновляются..."),
        loading = u8("Цены загружаются..."),
        refreshBtn = u8("Обновить цены на актуальные"),
        refreshing = u8("Обновление..."),
    }
    return WK.TT
end
function WK.actUnder()
    cb_undermine.v = not cb_undermine.v
    settings.undermineEnabled = cb_undermine.v
    if cb_undermine.v then cb_regular.v = false; settings.regularmineEnabled = false end
    saveConfig(); needSave = true
end
function WK.actLavka()
    cb_lavka.v = not cb_lavka.v
    settings.underminelavkaEnabled = cb_lavka.v
    if cb_lavka.v then cb_undermine.v = true; settings.undermineEnabled = true end
    saveConfig(); needSave = true
end
function WK.actRegular()
    cb_regular.v = not cb_regular.v
    settings.regularmineEnabled = cb_regular.v
    if cb_regular.v then cb_undermine.v = false; settings.undermineEnabled = false end
    saveConfig(); needSave = true
end
function WK.actOverlay()
    cb_mine_overlay.v = not cb_mine_overlay.v
    if cb_mine_overlay.v then
        settings.mineOverlayEnabled = true; settings.incassOverlayEnabled = false; cb_incass_overlay.v = false
        settings.farmOverlayEnabled = false
        settings.sawmillOverlayEnabled = false
        settings.oilOverlayEnabled = false
        cb_farm_overlay.v = false
        cb_sawmill_overlay.v = false
        cb_oil_overlay.v = false
        if settings.overlayAutoTimer and not overlayTimer.running then
            overlayTimer.running = true; overlayTimer.startTime = os.time()
            overlayTimer.elapsed = 0; overlayTimer.displayedTime = "00:00:00"
        end
    else
        settings.mineOverlayEnabled = false
    end
    saveConfig()
end
function WK.actSpawn()
    cb_mineSpawnTimer.v = not cb_mineSpawnTimer.v
    settings.mineSpawnTimerEnabled = cb_mineSpawnTimer.v
    saveConfig()
end
function WK.actCustomPrices(wt)
    if wt and wt ~= WORK_TYPES.MINE then return WK.actCustomPricesOther(wt) end
    cb_useCustomMinePrices.v = not cb_useCustomMinePrices.v
    useCustomMinePrices = cb_useCustomMinePrices.v
    if useCustomMinePrices then
        saveLbConfig("", false)
        for _, k in ipairs(configs[WORK_TYPES.MINE].resourceOrder) do
            if not customPriceEditMine[k] then
                customPriceEditMine[k] = imgui.ImInt(resourcePrices[k] or configs[WORK_TYPES.MINE].defaultPrices[k])
            end
        end
    end
    if currentWork == WORK_TYPES.MINE then
        loadedLogs = false; loadStats(); cachedTodayStats = nil; cachedWeekStats = nil
    end
    saveCustomPricesConfig()
end
function WK.mineDefs()
    if WK.MD then return WK.MD end
    WK.MD = {
        modes = {
            {icon = WK.ic("ICON_ARROW_DOWN"), col = 0xFF28AAFF, title = u8("Подземная шахта"),
             desc = u8("Ресурсы подземной шахты"), hint = u8("Выключает обычную шахту"),
             get = function() return cb_undermine.v end, act = WK.actUnder},
            {icon = WK.ic("ICON_SHOPPING_CART"), col = 0xFF33DD77, title = u8("Лавка"),
             desc = u8("Вычитает проданные ресурсы"), hint = u8("Включает подземную шахту"),
             get = function() return cb_lavka.v end, act = WK.actLavka},
            {icon = WK.ic("ICON_GAVEL"), col = 0xFFF8BD38, title = u8("Обычная шахта"),
             desc = u8("Ресурсы обычной шахты"), hint = u8("Выключает подземную шахту"),
             get = function() return cb_regular.v end, act = WK.actRegular},
        },
        overlay = {
            {icon = WK.ic("ICON_DESKTOP"), col = 0xFF28AAFF, title = u8("Оверлей на экране"),
             desc = u8("Статистика добычи поверх игры"),
             get = function() return cb_mine_overlay.v end, act = WK.actOverlay},
            {icon = WK.ic("ICON_REFRESH"), col = 0xFFB672F4, title = u8("Таймер спавна в оверлее"),
             desc = u8("Показывать таймер спавна ресурсов"),
             get = function() return cb_mineSpawnTimer.v end, act = WK.actSpawn},
        },
    }
    return WK.MD
end
function WK.isCustom(wt)
    if wt == WORK_TYPES.MINE then return useCustomMinePrices and true or false
    elseif wt == WORK_TYPES.FARM then return useCustomFarmPrices and true or false end
    return useCustomSawmillPrices and true or false
end
function WK.editTbl(wt)
    if wt == WORK_TYPES.MINE then return customPriceEditMine
    elseif wt == WORK_TYPES.FARM then return customPriceEditFarm end
    return customPriceEditSaw
end
function WK.actCustomPricesOther(wt)
    local cfg = configs[wt]
    local on, tbl
    if wt == WORK_TYPES.FARM then
        cb_useCustomFarmPrices.v = not cb_useCustomFarmPrices.v
        useCustomFarmPrices = cb_useCustomFarmPrices.v
        on, tbl = useCustomFarmPrices, customPriceEditFarm
    else
        cb_useCustomSawmillPrices.v = not cb_useCustomSawmillPrices.v
        useCustomSawmillPrices = cb_useCustomSawmillPrices.v
        on, tbl = useCustomSawmillPrices, customPriceEditSaw
    end
    if on then
        saveLbConfig("", false)
        for _, k in ipairs(cfg.resourceOrder) do
            if not tbl[k] then
                tbl[k] = imgui.ImInt(resourcePrices[k] or cfg.defaultPrices[k])
            end
        end
    end
    if currentWork == wt then
        loadedLogs = false; loadStats(); cachedTodayStats = nil; cachedWeekStats = nil
    end
    saveCustomPricesConfig()
end
function WK.actCount(wt)
    if wt == WORK_TYPES.FARM then
        cb_farm.v = not cb_farm.v
        settings.farmEnabled = cb_farm.v
    else
        cb_sawmill.v = not cb_sawmill.v
        settings.sawmillEnabled = cb_sawmill.v
    end
    saveConfig(); needSave = true
end
function WK.actOverlayFor(wt)
    local cb, key
    if wt == WORK_TYPES.FARM then cb, key = cb_farm_overlay, "farmOverlayEnabled"
    else cb, key = cb_sawmill_overlay, "sawmillOverlayEnabled" end
    local turnOn = not cb.v
    if turnOn then
        settings.incassOverlayEnabled = false; cb_incass_overlay.v = false
        settings.mineOverlayEnabled = false; cb_mine_overlay.v = false
        settings.farmOverlayEnabled = false; cb_farm_overlay.v = false
        settings.sawmillOverlayEnabled = false; cb_sawmill_overlay.v = false
        settings.oilOverlayEnabled = false; cb_oil_overlay.v = false
        settings.taxiOverlayEnabled = false; cb_taxi_overlay.v = false
        cb.v = true
        settings[key] = true
        if settings.overlayAutoTimer and not overlayTimer.running then
            overlayTimer.running = true; overlayTimer.startTime = os.time()
            overlayTimer.elapsed = 0; overlayTimer.displayedTime = "00:00:00"
        end
    else
        cb.v = false
        settings[key] = false
    end
    saveConfig()
end
function WK.defs(wt)
    if wt == WORK_TYPES.MINE then return WK.mineDefs() end
    WK.DD = WK.DD or {}
    if WK.DD[wt] then return WK.DD[wt] end
    local D
    if wt == WORK_TYPES.FARM then
        D = {
            modes = {
                {icon = WK.ic("ICON_LEAF"), col = 0xFF1AE591, title = u8("Считать ресурсы с фермы"),
                 desc = u8("Учитывать собранное в статистике"),
                 get = function() return cb_farm.v end, act = function() WK.actCount(WORK_TYPES.FARM) end},
            },
            overlay = {
                {icon = WK.ic("ICON_DESKTOP"), col = 0xFF1AE591, title = u8("Оверлей на экране"),
                 desc = u8("Статистика сбора поверх игры"),
                 get = function() return cb_farm_overlay.v end, act = function() WK.actOverlayFor(WORK_TYPES.FARM) end},
            },
        }
    else
        D = {
            modes = {
                {icon = WK.ic("ICON_TREE"), col = 0xFF99D334, title = u8("Считать ресурсы с лесопилки"),
                 desc = u8("Учитывать полученное в статистике"),
                 get = function() return cb_sawmill.v end, act = function() WK.actCount(WORK_TYPES.SAWMILL) end},
            },
            overlay = {
                {icon = WK.ic("ICON_DESKTOP"), col = 0xFF99D334, title = u8("Оверлей на экране"),
                 desc = u8("Статистика заготовки поверх игры"),
                 get = function() return cb_sawmill_overlay.v end, act = function() WK.actOverlayFor(WORK_TYPES.SAWMILL) end},
            },
        }
    end
    WK.DD[wt] = D
    return D
end
function WK.workTab(wt, sid, label)
    incassWorkActive = false
    oilWorkActive = false
    if not config or currentWork ~= wt then
        switchWorkType(wt, true)
    end
    if not config then
        imgui.Text(u8("Сначала выберите режим работы (нажмите ") .. label .. u8(" в меню слева)"))
        return
    end
    WK.sec = WK.sec or {}
    local sec = WK.sec[wt]
    if not sec then sec = {v = 0, last = 0}; WK.sec[wt] = sec end
    if os.clock() - sec.last > 0.4 then sec.v = 0 end
    sec.last = os.clock()
    if WK.gotoTab[wt] then sec.v = WK.gotoTab[wt]; WK.gotoTab[wt] = nil end
    local names = {u8("Меню"), u8("Обзор"), u8("Цены")}
    local map = {0, 2, 1}
    local curPos = 0
    for p, s in ipairs(map) do
        if s == sec.v then curPos = p - 1 end
    end
    local clicked = SegmentedTabs(sid, names, curPos)
    if clicked then
        local prev = sec.v
        sec.v = map[clicked + 1]
        if sec.v == 1 and prev ~= 1 and not pricesLoading then loadGlobalPrices() end
    end
    imgui.Spacing(); imgui.Separator(); imgui.Spacing()
    if sec.v == 0 then WK.menu(wt)
    elseif sec.v == 1 then WK.prices(wt)
    else WK.draw(wt) end
end
function WK.switch(dl, key, x, y, on, col)
    local P = imgui.ImVec2
    local a = rhAnim("wk_sw_" .. key, on and 1 or 0)
    local sw, sh = 40, 22
    dl:AddRectFilled(P(x, y), P(x + sw, y + sh), rhLerpColor(0xFF444444, col, a), 11)
    dl:AddCircleFilled(P(x + 11 + (sw - 22) * a, y + sh / 2), 8, 0xFFFFFFFF, 16)
end
function WK.button(dl, id, x, y, w, h, text, icon, col, filled, disabled)
    local P = imgui.ImVec2
    imgui.SetCursorScreenPos(P(x, y))
    local clicked = imgui.InvisibleButton(id, imgui.ImVec2(w, h))
    local hv = imgui.IsItemHovered() and not disabled
    local a = rhAnim(id, hv and 1 or 0)
    local base = disabled and 0xFF6A6A6A or col
    local fillA = (filled and 0.22 or 0.06) + 0.14 * a
    dl:AddRectFilled(P(x, y), P(x + w, y + h), rhAlpha(base, fillA), 10)
    dl:AddRect(P(x, y), P(x + w, y + h), rhAlpha(base, 0.55 + 0.35 * a), 10, 15, 1.2)
    local label = icon .. "  " .. text
    local sz = imgui.CalcTextSize(label)
    dl:AddText(P(x + (w - sz.x) / 2, y + (h - sz.y) / 2), base, label)
    return clicked and not disabled
end
function WK.chip(dl, x, y, size, col, label, rare, a)
    local P = imgui.ImVec2
    dl:AddRectFilled(P(x, y), P(x + size, y + size), rhAlpha(col, 0.14 + 0.08 * a), 10)
    dl:AddRect(P(x, y), P(x + size, y + size), rhAlpha(col, 0.45 + 0.3 * a), 10, 15, 1.0)
    local letter = label:match("^[\1-\127\192-\255][\128-\191]*") or "?"
    local lsz = imgui.CalcTextSize(letter)
    dl:AddText(P(x + (size - lsz.x) / 2, y + (size - lsz.y) / 2), col, letter)
    if rare then
        local ssz = imgui.CalcTextSize(fa.ICON_STAR)
        dl:AddText(P(x + size - ssz.x + 3, y - 5), PD.C.gold, fa.ICON_STAR)
    end
end
function WK.row(dl, id, x, y, w, h, bg, brd, it, hint)
    local P = imgui.ImVec2
    imgui.SetCursorScreenPos(P(x, y))
    local clicked = imgui.InvisibleButton("##wk_row_" .. id, imgui.ImVec2(w, h))
    local hv = imgui.IsItemHovered()
    local a = rhAnim("wk_row_" .. id, hv and 1 or 0)
    local on = it.get() and true or false
    local bgC = rhLerpColor(bg, rhLerpColor(bg, 0xFFFFFFFF, 0.04), a)
    local brC = on and rhAlpha(it.col, 0.65) or rhLerpColor(brd, it.col, 0.5 * a)
    rhCardBox(dl, x, y, w, h, bgC, brC, 12)
    if on then dl:AddRectFilled(P(x + 4, y + 3), P(x + w - 4, y + h - 3), rhAlpha(it.col, 0.05), 9) end
    rhIconBadge(dl, x + 34, y + h / 2, 16, it.icon, on and it.col or PD.C.mute, bgC, a)
    local tx = x + 66
    WK.switch(dl, id, x + w - 16 - 40, y + (h - 22) / 2, on, it.col)
    dl:PushClipRect(P(tx, y), P(x + w - 16 - 40 - 12, y + h), true)
    local lines = hint and 3 or 2
    local ty = y + (h - (lines == 3 and 52 or 36)) / 2
    dl:AddText(P(tx, ty), on and 0xFFFFFFFF or 0xFFDDDDDD, it.title)
    dl:AddText(P(tx, ty + 18), PD.C.mute, it.desc)
    if hint then dl:AddText(P(tx, ty + 36), PD.C.dim, hint) end
    dl:PopClipRect()
    return clicked
end
function WK.menu(wt)
    local K, T, D = WK.K(wt), WK.T(), WK.defs(wt)
    local dl = imgui.GetWindowDrawList()
    local P = imgui.ImVec2
    local C = PD.C
    local bg, brd, iconCol = homeCardColors()
    local ACC = useCustomTheme and iconCol or 0xFF1AE591
    local cur = imgui.GetCursorScreenPos()
    local x, y = cur.x, cur.y + 4
    local w = imgui.GetWindowWidth() - 25
    local WARN = 0xFF2896FF
    local scanCol, scanIcon, scanText
    local scanned = scannedThisSession[currentWork]
    if scanState.active then
        scanCol = C.gold; scanIcon = WK.ic("ICON_REFRESH"); scanText = T.scanActive .. u8(scanState.statusText or "")
    elseif scanned then
        scanCol = C.green; scanIcon = WK.ic("ICON_CHECK"); scanText = T.scanDone
    else
        scanCol = WARN; scanIcon = WK.ic("ICON_EXCLAMATION_TRIANGLE"); scanText = T.scanNone
    end
    local sh = 84
    local btnW = 220
    rhCardBox(dl, x, y, w, sh, bg, scanned and brd or rhAlpha(scanCol, 0.55), 14)
    rhIconBadge(dl, x + 38, y + sh / 2, 20, scanIcon, scanCol, bg, 0)
    dl:PushClipRect(P(x + 72, y), P(x + w - btnW - 28, y + sh), true)
    dl:AddText(P(x + 72, y + 20), scanCol, scanText)
    dl:AddText(P(x + 72, y + 46), C.mute, T.scanHint)
    dl:PopClipRect()
    local btnText = scanState.active and T.scanBtnActive or (scanned and T.scanBtnAgain or T.scanBtn)
    if WK.button(dl, "##wk_scan_btn", x + w - btnW - 16, y + (sh - 40) / 2, btnW, 40, btnText, WK.ic("ICON_SEARCH"),
                 scanned and C.mute or scanCol, not scanned, scanState.active) then
        startInventoryScan()
    end
    y = y + sh + 14
    dl:AddText(P(x + 4, y + 5), 0xFFFFFFFF, T.modesTitle)
    y = y + 34
    for i, it in ipairs(D.modes) do
        if WK.row(dl, "mode" .. i, x, y, w, 70, bg, brd, it, it.hint) then it.act() end
        y = y + 70 + 8
    end
    y = y + 6
    dl:AddText(P(x + 4, y + 5), 0xFFFFFFFF, T.overlayTitle)
    y = y + 34
    for i, it in ipairs(D.overlay) do
        if WK.row(dl, "ovl" .. i, x, y, w, 56, bg, brd, it, nil) then it.act() end
        y = y + 56 + 8
    end
    y = y + 6
    local c = WK.build(wt)
    local td = c.today
    local th = 74
    imgui.SetCursorScreenPos(P(x, y))
    local go = imgui.InvisibleButton("##wk_today_strip", imgui.ImVec2(w, th))
    local hv = imgui.IsItemHovered()
    local a = rhAnim("wk_today_strip", hv and 1 or 0)
    local bgT = rhLerpColor(bg, rhLerpColor(bg, 0xFFFFFFFF, 0.04), a)
    rhCardBox(dl, x, y, w, th, bgT, rhLerpColor(brd, K.col, 0.55 * a), 14)
    rhIconBadge(dl, x + 34, y + 30, 14, K.icon, K.col, bgT, a)
    dl:AddText(P(x + 62, y + 12), C.mute, T.todayCap)
    local tot = formatNumber(td.total) .. "$"
    dl:AddText(P(x + 62, y + 32), C.green, tot)
    dl:AddText(P(x + 63, y + 32), C.green, tot)
    if td.count > 0 then
        rhPill(dl, x + 62 + imgui.CalcTextSize(tot).x + 14, y + 31, formatNumber(td.count) .. " " .. PD.plural(td.count, K.pl), K.col)
    end
    local mt = T.more
    local mw = imgui.CalcTextSize(mt).x
    local arrow = WK.ic("ICON_ANGLE_RIGHT")
    local aw = imgui.CalcTextSize(arrow).x
    dl:AddText(P(x + w - 18 - aw, y + 22), K.col, arrow)
    dl:AddText(P(x + w - 18 - aw - 8 - mw, y + 22), K.col, mt)
    local arr = {}
    for _, ce in pairs(td.cats or {}) do arr[#arr + 1] = ce end
    table.sort(arr, function(p, q) return p.amount > q.amount end)
    local bx0, bx1, by = x + 62, x + w - 18, y + th - 14
    dl:AddRectFilled(P(bx0, by), P(bx1, by + 5), rhAlpha(0xFFFFFFFF, 0.07), 3)
    if td.total > 0 then
        local cx = bx0
        for _, ce in ipairs(arr) do
            local pw = (bx1 - bx0) * (ce.amount / td.total)
            if pw >= 1 then
                dl:AddRectFilled(P(cx, by), P(math.min(cx + pw, bx1), by + 5), ce.col, 3)
                cx = cx + pw
            end
        end
    end
    if go then WK.gotoTab[wt] = 2 end
    y = y + th + 12
    imgui.SetCursorScreenPos(P(x, y))
    imgui.Dummy(imgui.ImVec2(w, 6))
end
function WK.prices(wt)
    local K, T = WK.K(wt), WK.T()
    local cfg = configs[wt]
    local dl = imgui.GetWindowDrawList()
    local P = imgui.ImVec2
    local C = PD.C
    local bg, brd, iconCol = homeCardColors()
    local ACC = useCustomTheme and iconCol or 0xFF1AE591
    local cur = imgui.GetCursorScreenPos()
    local x, y = cur.x, cur.y + 4
    local w = imgui.GetWindowWidth() - 25
    local WARN = 0xFF2896FF
    local custom = WK.isCustom(wt)
    local hasPrices = (globalPrices and next(globalPrices)) and true or false
    local hh = 106
    local rightW = 190
    rhCardBox(dl, x, y, w, hh, bg, custom and rhAlpha(WARN, 0.5) or brd, 14)
    rhIconBadge(dl, x + 38, y + 38, 20, WK.ic("ICON_MONEY"), custom and WARN or K.col, bg, 0)
    dl:PushClipRect(P(x + 72, y), P(x + w - rightW - 12, y + hh), true)
    dl:AddText(P(x + 72, y + 12), 0xFFFFFFFF, T.pricesTitle)
    dl:AddText(P(x + 72, y + 34), custom and WARN or C.mute, custom and T.hintCustom1 or T.hintAuto1)
    dl:AddText(P(x + 72, y + 52), C.dim, custom and T.hintCustom2 or T.hintAuto2)
    dl:PopClipRect()
    if pricesLoading then
        rhPill(dl, x + 72, y + 74, T.updating, C.gold)
    elseif not hasPrices and not custom then
        rhPill(dl, x + 72, y + 74, T.loading, C.gold)
    end
    local tgX, tgY = x + w - rightW, y + hh / 2 - 22
    imgui.SetCursorScreenPos(P(tgX, tgY))
    local tgClick = imgui.InvisibleButton("##wk_custom_prices", imgui.ImVec2(rightW - 8, 44))
    local lblW = imgui.CalcTextSize(T.customLbl).x
    dl:AddText(P(x + w - 16 - 40 - 10 - lblW, y + hh / 2 - imgui.CalcTextSize("A").y / 2), custom and WARN or 0xFFDDDDDD, T.customLbl)
    WK.switch(dl, "custom_prices", x + w - 16 - 40, y + hh / 2 - 11, custom, WARN)
    if tgClick then WK.actCustomPrices(wt) end
    y = y + hh + 12
    if not hasPrices and not custom then
        local eh = 92
        rhCardBox(dl, x, y, w, eh, bg, brd, 12)
        rhIconBadge(dl, x + w / 2, y + 32, 16, WK.ic("ICON_REFRESH"), C.mute, bg, 0)
        local sz = imgui.CalcTextSize(T.loading)
        dl:AddText(P(x + (w - sz.x) / 2, y + 60), C.mute, T.loading)
        y = y + eh + 12
    else
        local gap = 8
        local ncols = (w >= 520) and 2 or 1
        local cw = (w - gap * (ncols - 1)) / ncols
        local ch = 60
        local left, right = {}, {}
        for _, kk in ipairs(cfg.resourceOrder) do
            if WK.isRare(cfg, kk) or kk == "azbox" then right[#right + 1] = kk else left[#left + 1] = kk end
        end
        local function byPrice(a, b)
            local pa = (priceEdit[a] and priceEdit[a].v) or resourcePrices[a] or 0
            local pb = (priceEdit[b] and priceEdit[b].v) or resourcePrices[b] or 0
            if pa ~= pb then return pa > pb end
            return a < b
        end
        table.sort(left, byPrice)
        table.sort(right, byPrice)
        local ordered = {}
        if ncols == 2 then
            for r = 1, math.max(#left, #right) do
                if left[r] then ordered[#ordered + 1] = {left[r], 0, r - 1} end
                if right[r] then ordered[#ordered + 1] = {right[r], 1, r - 1} end
            end
        else
            for r, kk in ipairs(left) do ordered[#ordered + 1] = {kk, 0, r - 1} end
            for r, kk in ipairs(right) do ordered[#ordered + 1] = {kk, 0, #left + r - 1} end
        end
        for _, ent in ipairs(ordered) do
            local k, colI, rowI = ent[1], ent[2], ent[3]
            local cx = x + colI * (cw + gap)
            local cy = y + rowI * (ch + gap)
            local col = WK.col(cfg, k)
            local label = u8(cfg.resourceNames[k] or k)
            rhCardBox(dl, cx, cy, cw, ch, bg, brd, 12)
            WK.chip(dl, cx + 14, cy + (ch - 36) / 2, 36, col, label, WK.isRare(cfg, k), 0)
            local edit = custom and WK.editTbl(wt)[k]
            local rightX = cx + cw - 14
            if edit then
                local iw = 140
                dl:PushClipRect(P(cx + 62, cy), P(rightX - iw - 10, cy + ch), true)
                dl:AddText(P(cx + 62, cy + (ch - imgui.CalcTextSize("A").y) / 2), 0xFFFFFFFF, label)
                dl:PopClipRect()
                imgui.SetCursorScreenPos(P(rightX - iw, cy + (ch - 26) / 2))
                imgui.PushItemWidth(iw)
                imgui.PushStyleVar(imgui.StyleVar.FrameRounding, 6)
                imgui.PushStyleColor(imgui.Col.FrameBg, imgui.ImVec4(0.09, 0.09, 0.09, 1))
                imgui.PushStyleColor(imgui.Col.FrameBgHovered, imgui.ImVec4(0.13, 0.13, 0.13, 1))
                imgui.PushStyleColor(imgui.Col.FrameBgActive, imgui.ImVec4(0.15, 0.15, 0.15, 1))
                imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.95, 0.95, 0.95, 1))
                if imgui.InputInt("##custom_price_mine_" .. k, edit, 1000, 10000) then
                    saveCustomPricesConfig(); needSave = true
                end
                imgui.PopStyleColor(4)
                imgui.PopStyleVar(1)
                imgui.PopItemWidth()
            else
                local pv = (priceEdit[k] and priceEdit[k].v) or resourcePrices[k] or 0
                local ptxt = formatNumber(pv) .. "$"
                local pw = imgui.CalcTextSize(ptxt).x
                dl:PushClipRect(P(cx + 62, cy), P(rightX - pw - 10, cy + ch), true)
                dl:AddText(P(cx + 62, cy + (ch - imgui.CalcTextSize("A").y) / 2), 0xFFFFFFFF, label)
                dl:PopClipRect()
                local ty = cy + (ch - imgui.CalcTextSize("A").y) / 2
                dl:AddText(P(rightX - pw, ty), C.green, ptxt)
                dl:AddText(P(rightX - pw + 1, ty), C.green, ptxt)
            end
        end
        y = y + (ncols == 2 and math.max(#left, #right) or #ordered) * (ch + gap) + 4
    end
    if not custom then
        local label = pricesLoading and T.refreshing or T.refreshBtn
        if WK.button(dl, "##wk_price_refresh", x, y, w, 44, label, WK.ic("ICON_REPEAT"), K.col, true, pricesLoading) then
            loadGlobalPrices()
        end
        y = y + 44 + 12
    end
    imgui.SetCursorScreenPos(P(x, y))
    imgui.Dummy(imgui.ImVec2(w, 6))
end
function drawMineTab()
    incassWorkActive = false
    oilWorkActive = false
    if not config or currentWork ~= WORK_TYPES.MINE then
        switchWorkType(WORK_TYPES.MINE, true)
    end
    if not config then
        imgui.Text(u8("Сначала выберите режим работы (нажмите Шахта в меню слева)"))
        return
    end
    
    if not mineSectionTab then mineSectionTab = imgui.ImInt(0) end
    if os.clock() - (mineLastDraw or 0) > 0.4 then mineSectionTab.v = 0 end
    mineLastDraw = os.clock()
    if WK.gotoTab[WORK_TYPES.MINE] then
        mineSectionTab.v = WK.gotoTab[WORK_TYPES.MINE]; WK.gotoTab[WORK_TYPES.MINE] = nil
    end
    local mineSectionNames = {u8("Меню"), u8("Обзор"), u8("Цены")}
    local mineSectionMap = {0, 2, 1}
    local mineCurPos = 0
    for p, s in ipairs(mineSectionMap) do
        if s == mineSectionTab.v then mineCurPos = p - 1 end
    end
    local mineClicked = SegmentedTabs("mine", mineSectionNames, mineCurPos)
    if mineClicked then
        local prev = mineSectionTab.v
        mineSectionTab.v = mineSectionMap[mineClicked + 1]
        if mineSectionTab.v == 1 and prev ~= 1 and not pricesLoading then loadGlobalPrices() end
    end
    imgui.Spacing(); imgui.Separator(); imgui.Spacing()
    
    if mineSectionTab.v == 0 then
        WK.menu(WORK_TYPES.MINE)
    end
    
    if mineSectionTab.v == 1 then
        WK.prices(WORK_TYPES.MINE)
    end
    
    if mineSectionTab.v == 2 then
        WK.draw(WORK_TYPES.MINE)
    end
end
function drawSawmillTab()
    WK.workTab(WORK_TYPES.SAWMILL, "saw", u8("Лесопилка"))
end
-- РЕЙТИНГ
lbRowsLimit = lbRowsLimit or 9999
LBX = LBX or {}
LBX.DEV = "Ryder_Nakata"
LBX.DEV_SERVER = "Drake"
LBX.PERIODS = {"Daily", "Weekly", "Total"}
LBX.MODES = {"Income", "Farm", "Mine", "Sawmill", "Oil", "Taxi", "Incass", "IM"}
LBX.SUBS = {"Farm", "Mine", "Sawmill", "Oil", "Taxi", "Incass", "IM"}
LBX.MCOL = {0xFFF8BD38, 0xFF1AE591, 0xFF28AAFF, 0xFF99D334, 0xFFFA8BA7, 0xFF15CCFA, 0xFFE5911A, 0xFFB672F4}
LBX.GOLD, LBX.SILVER, LBX.BRONZE = 0xFF00D7FF, 0xFFC7C7C7, 0xFF327FCD
LBX.RIV, LBX.WARN = 0xFFFA8BA7, 0xFF32BEFF
LBX.ROW_H, LBX.ROW_GAP = 46, 6
LBX.pIdx = LBX.pIdx or 3
LBX.mIdx = LBX.mIdx or 1
LBX.search = LBX.search or imgui.ImBuffer(32)
LBX.SERVER_ORDER = {
    "Phoenix", "Tucson", "Scottdale", "Chandler", "Brainburg", "Saint-Rose", "Mesa", "Red-Rock",
    "Yuma", "Surprise", "Prescott", "Glendale", "Kingman", "Winslow", "Payson", "Gilbert",
    "Show Low", "Casa-Grande", "Page", "Sun-City", "Queen-Creek", "Sedona", "Holiday", "Wednesday",
    "Yava", "Faraway", "Bumble Bee", "Christmas", "Mirage", "Love", "Drake", "Space", "Home"
}
LBX.SRV_COL = {
    ["Gilbert"] = 0xFF5A2314, ["Glendale"] = 0xFF441F0A, ["Holiday"] = 0xFFA83F5B, ["Kingman"] = 0xFF521F0F,
    ["Love"] = 0xFF8C2DE6, ["Mesa"] = 0xFF4D1F0E, ["Mirage"] = 0xFF1F3A1B, ["Page"] = 0xFF451A0D,
    ["Payson"] = 0xFF281EC8, ["Phoenix"] = 0xFF2B59E0, ["Prescott"] = 0xFF6B3A1B, ["Brainburg"] = 0xFF3A1EC4,
    ["Bumble Bee"] = 0xFF05B7F2, ["Casa-Grande"] = 0xFF29774A, ["Chandler"] = 0xFF451A0D, ["Christmas"] = 0xFF3D2114,
    ["Drake"] = 0xFF3D6B1F, ["Faraway"] = 0xFF20401B, ["Surprise"] = 0xFF2C1EC4, ["Tucson"] = 0xFF6B2B14,
    ["Wednesday"] = 0xFF8C2A5A, ["Winslow"] = 0xFF2B5A8B, ["Yava"] = 0xFFA0A84F, ["Yuma"] = 0xFF5E2314,
    ["Queen-Creek"] = 0xFFB26F1F, ["Red-Rock"] = 0xFF50230F, ["Saint-Rose"] = 0xFF883C1F, ["Scottdale"] = 0xFF2E20B5,
    ["Sedona"] = 0xFF30B8E8, ["Show Low"] = 0xFF2A18A3, ["Space"] = 0xFF5E1B2A, ["Sun-City"] = 0xFF5C2212,
    ["Home"] = 0xFF3C7A2E,
}

function LBX.S()
    if LBX._S then return LBX._S end
    LBX._S = {
        title = u8("Таблица лидеров"),
        sub = u8("Соревнуйтесь с игроками всех серверов"),
        periods = {u8("День"), u8("Неделя"), u8("Всё время")},
        periodsFull = {u8("за день"), u8("за неделю"), u8("за всё время")},
        modes = {u8("Общий"), u8("Ферма"), u8("Шахта"), u8("Лесопилка"), u8("Нефть"), u8("Такси"), u8("Инкассация"), u8("Сторонний")},
        modesFull = {u8("Общий доход"), u8("Ферма"), u8("Шахта"), u8("Лесопилка"), u8("Нефтевышки"), u8("Такси"), u8("Инкассация"), u8("Сторонний доход")},
        pl = {u8("игрок"), u8("игрока"), u8("игроков")},
        offTitle = u8("Рейтинг выключен"),
        offSub = u8("Включите участие в настройках, чтобы увидеть своё место среди игроков"),
        offBtn = u8("Открыть настройки"),
        heroCap = u8("Ваше место"),
        outOf = u8("из "),
        top = u8("Топ "),
        notIn = u8("Вас пока нет в рейтинге"),
        notInSub = u8("Результаты отправляются раз в сутки, после 05:00 МСК"),
        fight = u8("Борьба за место"),
        leading = u8("Вы лидируете"),
        rivalWord = u8("Соперник"),
        rivalHint = u8("Отметьте звездой соперника"),
        rivalOn = u8("Следить за игроком"),
        rivalOff = u8("Перестать следить"),
        search = u8("Поиск игрока по нику"),
        allSrv = u8("Все сервера"),
        srvTitle = u8("Фильтр по серверу"),
        srvTip = u8("Нажмите, чтобы показать только этот сервер"),
        players = u8("Игроков: "),
        found = u8("Найдено: "),
        of = u8(" из "),
        show = u8("Показать: "),
        all = u8("Все"),
        limTitle = u8("Сколько строк показывать"),
        me = u8("Вы"),
        dev = u8("Разработчик"),
        none = u8("Нет игроков по заданному фильтру"),
        noneSearch = u8("Игрок не найден"),
        fail = u8("Не удалось загрузить рейтинг"),
        failSub = u8("Проверьте подключение и повторите попытку"),
        retry = u8("Повторить"),
        jump = u8("К моему месту"),
        more = u8("Показать ещё "),
        res = u8("Ресурсы"),
        fromLeader = u8("% от лидера"),
        upd = u8("Обновление..."),
        updated = u8("Обновлено "),
        justNow = u8("только что"),
        saved = u8("Сохранённые данные"),
        offline = u8("Нет связи, показаны сохранённые данные"),
        sec = u8(" с назад"), min = u8(" мин назад"), hr = u8(" ч назад"),
        refresh = u8("Обновить рейтинг"),
        allDone = u8("Все данные загружены!"),
        partFail = u8("Часть данных загрузить не удалось"),
        loadingPfx = u8("Загрузка: "),
        devTag = u8("(Разработчик)"),
        loadingDet = u8("Загружаем детали..."),
        shards = u8("Осколки тайников"),
    }
    return LBX._S
end

function LBX.icons()
    if LBX._I then return LBX._I end
    LBX._I = {fa.ICON_USD, fa.ICON_LEAF, fa.ICON_GAVEL, fa.ICON_TREE, fa.ICON_FIRE, fa.ICON_TAXI, fa.ICON_MONEY, fa.ICON_SHOPPING_CART}
    return LBX._I
end

function LBX.medal(rank)
    if rank == 1 then return LBX.GOLD elseif rank == 2 then return LBX.SILVER elseif rank == 3 then return LBX.BRONZE end
    return nil
end

function LBX.srvColor(name)
    if not name or name == "" then return 0xFFBBBBBB end
    local c = LBX.SRV_COL[name]
    if not c then
        local hash = 7
        for i = 1, #name do hash = (hash * 33 + string.byte(name, i)) % 16777216 end
        local r = 70 + (hash % 130)
        local g = 70 + (math.floor(hash / 7) % 130)
        local b = 100 + (math.floor(hash / 13) % 140)
        c = 0xFF000000 + b * 65536 + g * 256 + r
        LBX.SRV_COL[name] = c
    end
    return rhLerpColor(c, 0xFFFFFFFF, 0.5)
end

function LBX.me()
    local now = os.clock()
    if LBX._me and LBX._meT and now - LBX._meT < 2 then return LBX._me end
    LBX._meT = now
    local name
    pcall(function()
        local ok, id = sampGetPlayerIdByCharHandle(PLAYER_PED)
        if ok then name = sampGetPlayerNickname(id) end
    end)
    if name and name ~= "" then LBX._me = name end
    return LBX._me
end

function LBX.mySrv()
    local now = os.clock()
    if LBX._srvT and now - LBX._srvT < 2 then return LBX._srv end
    LBX._srvT = now
    local s
    pcall(function() s = getCurrentServer() end)
    LBX._srv = nil
    for _, n in ipairs(LBX.SERVER_ORDER) do
        if n == s then
            LBX._srv = s
            break
        end
    end
    return LBX._srv
end

function LBX.isDevEntry(e)
    return e.name == LBX.DEV and e.server == LBX.DEV_SERVER
end

function LBX.isMine(e, me, srv)
    if not me or e.name ~= me then return false end
    if not srv or not e.server or e.server == "" then return true end
    return e.server == srv
end

function LBX.enabled()
    local now = os.clock()
    if not LBX._enT or now - LBX._enT > 1.5 then
        LBX._en = getLbEnabled() and true or false
        LBX._enT = now
    end
    return LBX._en
end

function LBX.cacheGet(m, p)
    local t = leaderboardCache[m]
    return t and t[p] or nil
end

function LBX.has(c)
    return c ~= nil and #c > 0
end

function LBX.diskLoad(m, p)
    local key = m .. "|" .. p
    LBX.miss = LBX.miss or {}
    if LBX.miss[key] then return end
    LBX.miss[key] = true
    local f = io.open(configDir .. "lb_cache_" .. m .. "_" .. p .. "_cache.json", "r")
    if not f then return end
    local content = f:read("*all")
    f:close()
    local data = decodeJson(u8:decode(content))
    if data and #data > 0 then
        leaderboardCache[m] = leaderboardCache[m] or {}
        leaderboardCache[m][p] = rhFixLb(data)
    end
end

function LBX.request(m, p, force)
    LBX.req = LBX.req or {}
    local key = m .. "|" .. p
    local r = LBX.req[key]
    local now = os.clock()
    if r then
        if force and now - r.t < 30 then return end
        if not force then return end
    end
    LBX.req[key] = {t = now, prev = LBX.cacheGet(m, p)}
    loadLeaderboard(p, m, true)
    return true
end

function LBX.status(m, p)
    local r = LBX.req and LBX.req[m .. "|" .. p]
    if not r then return "saved", 0 end
    if LBX.cacheGet(m, p) ~= r.prev then return "fresh", os.clock() - r.t end
    if os.clock() - r.t > 20 then return "failed", 0 end
    return "loading", 0
end

function LBX.needSubs(p)
    for _, m in ipairs(LBX.SUBS) do
        if not LBX.has(LBX.cacheGet(m, p)) then LBX.diskLoad(m, p) end
        LBX.request(m, p, false)
    end
end

function LBX.modeLabel(m)
    local S = LBX.S()
    for i, v in ipairs(LBX.MODES) do
        if v == m then return S.modesFull[i] end
    end
    return m
end

function LBX.startSession(mode, period)
    local list = {mode}
    if mode == "Income" then list = {"Income", "Farm", "Mine", "Sawmill", "Oil", "Taxi", "Incass", "IM"} end
    LBX.sess = {mode = mode, period = period, list = list, t0 = os.clock()}
end

function LBX.sessInfo()
    local ss = LBX.sess
    if not ss or ss.mode ~= LBX.MODES[LBX.mIdx] or ss.period ~= LBX.PERIODS[LBX.pIdx] then return nil end
    local done, failed, loading = 0, 0, {}
    for _, m in ipairs(ss.list) do
        local st = LBX.status(m, ss.period)
        if st == "loading" then
            loading[#loading + 1] = m
        else
            done = done + 1
            if st == "failed" then failed = failed + 1 end
        end
    end
    local finished = (#loading == 0)
    if not finished then
        ss.doneAt = nil
    elseif not ss.doneAt then
        ss.doneAt = os.clock()
    end
    if finished and os.clock() - ss.doneAt > 3.5 then return nil end
    return {done = done, total = #ss.list, loading = loading, failed = failed, finished = finished, key = "lbx_prog" .. tostring(ss.t0)}
end

function LBX.progressCard(dl, c, x, y, w, inf)
    local S, C = LBX.S(), PD.C
    local P = imgui.ImVec2
    local h = 56
    rhCardBox(dl, x, y, w, h, c.bg, c.brd, 12)
    local col = inf.finished and (inf.failed > 0 and LBX.WARN or C.green) or LBX.WARN
    if inf.finished then
        rhIconBadge(dl, x + 28, y + 24, 12, inf.failed > 0 and fa.ICON_EXCLAMATION_TRIANGLE or fa.ICON_CHECK, col, c.bg, 0)
    else
        LBX.spinner(dl, x + 28, y + 24, 9, col)
    end
    local txt
    if inf.finished then
        txt = (inf.failed > 0) and S.partFail or S.allDone
    else
        local names = {}
        for _, m in ipairs(inf.loading) do names[#names + 1] = LBX.modeLabel(m) end
        txt = S.loadingPfx .. table.concat(names, ", ") .. "..."
    end
    local cnt = inf.done .. "/" .. inf.total
    local cw = imgui.CalcTextSize(cnt).x
    dl:AddText(P(x + w - 16 - cw, y + 14), C.mute, cnt)
    LBX.clip(dl, x + 52, y + 14, w - 52 - cw - 28, 0xFFE6E6E6, txt, false)
    local bx0, bx1, by = x + 16, x + w - 16, y + h - 14
    dl:AddRectFilled(P(bx0, by), P(bx1, by + 4), rhAlpha(0xFFFFFFFF, 0.07), 2)
    local f = rhAnim(inf.key, inf.total > 0 and inf.done / inf.total or 0, 8)
    if f > 0.01 then dl:AddRectFilled(P(bx0, by), P(bx0 + (bx1 - bx0) * f, by + 4), col, 2) end
end

function LBX.nameMap(m, p)
    local c = LBX.cacheGet(m, p)
    if not LBX.has(c) then return nil end
    LBX.nm = LBX.nm or {}
    local key = m .. "|" .. p
    local s = LBX.nm[key]
    if s and s.ref == c then return s.map end
    local map = {}
    for _, e in ipairs(c) do
        if e.name then
            local k = e.name .. "|" .. (e.server or "")
            if map[k] == nil then map[k] = e.amount or 0 end
        end
    end
    LBX.nm[key] = {ref = c, map = map}
    return map
end

function LBX.prepare(cache, me, srv)
    local pr = LBX.prep
    if pr and pr.cache == cache and pr.me == me and pr.srv == srv then return pr end
    local list, counts, names, byName = {}, {}, {}, {}
    local dev, top = nil, 0
    local myIdx, mySrv, mySrvRank
    for _, e in ipairs(cache) do
        if LBX.isDevEntry(e) then
            dev = e
        else
            list[#list + 1] = e
            local s = e.server
            if s and s ~= "" then
                if not counts[s] then counts[s] = 0; names[#names + 1] = s end
                counts[s] = counts[s] + 1
            end
            if (e.amount or 0) > top then top = e.amount end
            if e.name and byName[e.name] == nil then byName[e.name] = #list end
            if not myIdx and LBX.isMine(e, me, srv) then
                myIdx = #list
                mySrv = s
                mySrvRank = (s and s ~= "") and counts[s] or nil
            end
        end
    end
    local ord = {}
    for i, n in ipairs(LBX.SERVER_ORDER) do ord[n] = i end
    table.sort(names, function(a, b)
        local ia, ib = ord[a] or 999, ord[b] or 999
        if ia ~= ib then return ia < ib end
        return a < b
    end)
    local devRank
    if dev and me == LBX.DEV and srv == LBX.DEV_SERVER then
        local da = dev.amount or 0
        devRank, mySrv, mySrvRank = 1, dev.server, 1
        for _, e in ipairs(list) do
            if (e.amount or 0) > da then
                devRank = devRank + 1
                if dev.server and e.server == dev.server then mySrvRank = mySrvRank + 1 end
            end
        end
        if not mySrv or mySrv == "" then mySrvRank = nil end
    end
    pr = {cache = cache, me = me, srv = srv, list = list, counts = counts, servers = names, byName = byName,
          dev = dev, top = top, total = #list, myIdx = myIdx, mySrv = mySrv, mySrvRank = mySrvRank, devRank = devRank}
    LBX.prep = pr
    return pr
end

function LBX.view(pr, server, q)
    local v = LBX.vw
    if v and v.pr == pr and v.server == server and v.q == q then return v end
    local items, rank = {}, 0
    local myPos
    local me = pr.me
    for i, e in ipairs(pr.list) do
        if not server or e.server == server then
            rank = rank + 1
            if q == "" or (e.name or ""):lower():find(q, 1, true) then
                items[#items + 1] = {e = e, rank = rank, gi = i}
                if LBX.isMine(e, me, pr.srv) then myPos = #items end
            end
        end
    end
    v = {pr = pr, server = server, q = q, items = items, total = rank, myPos = myPos}
    LBX.vw = v
    return v
end

function LBX.rivalLoad()
    if LBX._rivalLoaded then return end
    LBX._rivalLoaded = true
    local f = io.open(configDir .. "lb_rival.json", "r")
    if f then
        local d = decodeJson(f:read("*all"))
        f:close()
        if d and type(d.name) == "string" and d.name ~= "" then LBX.rival = d.name end
    end
end

function LBX.rivalToggle(name)
    if LBX.rival == name then LBX.rival = nil else LBX.rival = name end
    local f = io.open(configDir .. "lb_rival.json", "w")
    if f then
        f:write(encodeJson({name = LBX.rival or ""}))
        f:close()
    end
end

function LBX.ago(sec)
    local S = LBX.S()
    if sec < 10 then return S.justNow end
    if sec < 60 then return math.floor(sec) .. S.sec end
    if sec < 3600 then return math.floor(sec / 60) .. S.min end
    return math.floor(sec / 3600) .. S.hr
end

function LBX.hov(x, y, w, h)
    if LBX.modal or LBX.drag then return false end
    local mp = imgui.GetMousePos()
    if mp.x < x or mp.x > x + w or mp.y < y or mp.y > y + h then return false end
    local wp, ws = imgui.GetWindowPos(), imgui.GetWindowSize()
    return mp.x >= wp.x and mp.x <= wp.x + ws.x and mp.y >= wp.y and mp.y <= wp.y + ws.y
end

function LBX.txt(dl, x, y, col, s, bold)
    local P = imgui.ImVec2
    dl:AddText(P(x, y), col, s)
    if bold then dl:AddText(P(x + 1, y), col, s) end
end

function LBX.clip(dl, x, y, maxW, col, s, bold)
    if maxW <= 4 then return end
    local P = imgui.ImVec2
    dl:PushClipRect(P(x, y - 3), P(x + maxW, y + 24), true)
    LBX.txt(dl, x, y, col, s, bold)
    dl:PopClipRect()
end

function LBX.money(n, maxW)
    local s = formatNumber(n or 0) .. "$"
    if maxW and imgui.CalcTextSize(s).x > maxW then s = PD.short(n or 0) .. "$" end
    return s
end

function LBX.big(dl, x, y, s, col)
    local P = imgui.ImVec2
    if rhBigFont then
        imgui.PushFont(rhBigFont)
        imgui.SetCursorScreenPos(P(x, y))
        imgui.TextColored(PD.vec4(col), s)
        imgui.PopFont()
    else
        dl:AddText(P(x, y + 4), col, s)
        dl:AddText(P(x + 1, y + 4), col, s)
    end
end

function LBX.bigW(s)
    if rhBigFont then
        imgui.PushFont(rhBigFont)
        local w = imgui.CalcTextSize(s).x
        imgui.PopFont()
        return w
    end
    return imgui.CalcTextSize(s).x + 1
end

function LBX.pill(dl, x, cy, text, col)
    local P = imgui.ImVec2
    local sz = imgui.CalcTextSize(text)
    local w, h = sz.x + 14, 18
    local y0 = cy - h / 2
    dl:AddRectFilled(P(x, y0), P(x + w, y0 + h), rhAlpha(col, 0.18), 9)
    dl:AddRect(P(x, y0), P(x + w, y0 + h), rhAlpha(col, 0.5), 9, 15, 1.0)
    dl:AddText(P(x + 7, y0 + (h - sz.y) / 2), col, text)
    return w
end

function LBX.spinner(dl, cx, cy, r, col)
    local P = imgui.ImVec2
    local t = os.clock() * 5
    local n = 10
    for i = 0, n - 1 do
        local a1 = t + (i / n) * 1.6 * math.pi
        local a2 = t + ((i + 1) / n) * 1.6 * math.pi
        dl:AddLine(P(cx + math.cos(a1) * r, cy + math.sin(a1) * r), P(cx + math.cos(a2) * r, cy + math.sin(a2) * r),
            rhAlpha(col, 0.15 + 0.85 * (i / n)), 2.0)
    end
end

function LBX.segment(dl, id, x, y, w, h, names, cur, col, bg, brd)
    local P = imgui.ImVec2
    local n, pad = #names, 4
    local sw = (w - pad * 2) / n
    rhCardBox(dl, x, y, w, h, bg, brd, 12)
    local pos = rhAnim(id, cur - 1, 16)
    local hx = x + pad + pos * sw
    dl:AddRectFilled(P(hx, y + pad), P(hx + sw, y + h - pad), rhAlpha(col, 0.16), 9)
    dl:AddRect(P(hx, y + pad), P(hx + sw, y + h - pad), rhAlpha(col, 0.75), 9, 15, 1.0)
    local clicked
    for i = 1, n do
        local sx = x + pad + (i - 1) * sw
        imgui.SetCursorScreenPos(P(sx, y))
        if imgui.InvisibleButton(id .. i, imgui.ImVec2(sw, h)) then clicked = i end
        local hv = imgui.IsItemHovered()
        local a = rhAnim(id .. "h" .. i, hv and 1 or 0)
        local act = 1 - math.min(1, math.abs(pos - (i - 1)))
        if a > 0.01 and act < 1 then
            dl:AddRectFilled(P(sx + 1, y + pad), P(sx + sw - 1, y + h - pad), rhAlpha(0xFFFFFFFF, 0.05 * a * (1 - act)), 9)
        end
        local tc = rhLerpColor(rhLerpColor(0xFF9A9A9A, 0xFFFFFFFF, a), col, act)
        local sz = imgui.CalcTextSize(names[i])
        dl:AddText(P(sx + (sw - sz.x) / 2, y + (h - sz.y) / 2), tc, names[i])
    end
    return clicked
end

function LBX.scrollbar(dl, bottom, ACC)
    if not (imgui.GetScrollY and imgui.SetScrollY) then return end
    local P = imgui.ImVec2
    local wp, ws = imgui.GetWindowPos(), imgui.GetWindowSize()
    local sy = imgui.GetScrollY()
    local maxS = math.max(0, bottom - wp.y + sy - ws.y + 8)
    if maxS <= 1 then LBX.drag = nil; return end
    local tx, ty0, trH = wp.x + ws.x - 12, wp.y + 6, ws.y - 12
    local thumbH = math.max(34, trH * ws.y / (ws.y + maxS))
    local travel = math.max(1, trH - thumbH)
    local thumbY = ty0 + travel * math.min(1, sy / maxS)
    local mp = imgui.GetMousePos()
    local inTrack = mp.x >= tx - 8 and mp.x <= tx + 14 and mp.y >= ty0 and mp.y <= ty0 + trH
    local onThumb = inTrack and mp.y >= thumbY and mp.y <= thumbY + thumbH
    if LBX.drag then
        if imgui.IsMouseDown(0) then
            local ns = LBX.drag.s0 + (mp.y - LBX.drag.y0) * (maxS / travel)
            imgui.SetScrollY(math.max(0, math.min(maxS, ns)))
        else
            LBX.drag = nil
        end
    elseif inTrack and not LBX.modal and imgui.IsMouseClicked(0) then
        local ns = sy
        if not onThumb then ns = math.max(0, math.min(maxS, (mp.y - ty0 - thumbH / 2) / travel * maxS)) end
        imgui.SetScrollY(ns)
        LBX.drag = {y0 = mp.y, s0 = ns}
    end
    local active = (LBX.drag ~= nil)
    local a = rhAnim("lbx_sb", (inTrack or active) and 1 or 0)
    local bw = 4 + 3 * a
    local bx = tx + 6 - bw / 2
    dl:AddRectFilled(P(bx, ty0), P(bx + bw, ty0 + trH), rhAlpha(0xFFFFFFFF, 0.04 + 0.04 * a), bw / 2)
    local tc = active and ACC or rhLerpColor(0xFF6A6A6A, 0xFFDDDDDD, a)
    dl:AddRectFilled(P(bx, thumbY), P(bx + bw, thumbY + thumbH), rhAlpha(tc, 0.45 + 0.4 * a), bw / 2)
end

function LBX.chip(dl, id, x, y, w, h, icon, label, col, active, bg, brd)
    local P = imgui.ImVec2
    imgui.SetCursorScreenPos(P(x, y))
    local clicked = imgui.InvisibleButton(id, imgui.ImVec2(w, h))
    local hv = imgui.IsItemHovered()
    local a = rhAnim(id, hv and 1 or 0)
    dl:AddRectFilled(P(x, y), P(x + w, y + h), rhLerpColor(bg, rhLerpColor(bg, 0xFFFFFFFF, 0.06), a), 12)
    if active then dl:AddRectFilled(P(x, y), P(x + w, y + h), rhAlpha(col, 0.14), 12) end
    dl:AddRect(P(x, y), P(x + w, y + h), active and rhAlpha(col, 0.8) or rhLerpColor(brd, col, 0.5 * a), 12, 15, 1.0)
    local text = icon and (icon .. "  " .. label) or label
    local sz = imgui.CalcTextSize(text)
    local tc = active and col or rhLerpColor(0xFF9A9A9A, 0xFFFFFFFF, a)
    dl:PushClipRect(P(x + 6, y), P(x + w - 6, y + h), true)
    dl:AddText(P(x + math.max(8, (w - sz.x) / 2), y + (h - sz.y) / 2), tc, text)
    dl:PopClipRect()
    return clicked
end

function LBX.star(dl, id, cx, cy, active, rowHover, live)
    local P = imgui.ImVec2
    local S = LBX.S()
    local clicked, hv = false, false
    if live then
        imgui.SetCursorScreenPos(P(cx - 13, cy - 13))
        clicked = imgui.InvisibleButton(id, imgui.ImVec2(26, 26))
        hv = imgui.IsItemHovered()
    end
    local a = rhAnim(id, hv and 1 or 0)
    local alpha = active and 1 or (0.18 + 0.7 * math.max(a, rowHover and 0.35 or 0))
    local col = active and LBX.RIV or rhLerpColor(0xFF777777, LBX.RIV, a)
    local sz = imgui.CalcTextSize(fa.ICON_STAR)
    dl:AddText(P(cx - sz.x / 2, cy - sz.y / 2), rhAlpha(col, alpha), fa.ICON_STAR)
    if hv then rhTip(active and S.rivalOff or S.rivalOn) end
    return clicked, hv
end

function LBX.srvTag(dl, id, x, cy, server, maxW, live, center)
    local P = imgui.ImVec2
    local S = LBX.S()
    local col = LBX.srvColor(server)
    local icon = getServerIcon(server)
    local sz = imgui.CalcTextSize(server)
    local iw = icon and 18 or 0
    local w = sz.x + 20 + iw
    if maxW and w > maxW then w = maxW end
    if center then x = x - w / 2 end
    local h = 22
    local y0 = cy - h / 2
    local clicked, hv = false, false
    if live then
        imgui.SetCursorScreenPos(P(x, y0))
        clicked = imgui.InvisibleButton(id, imgui.ImVec2(w, h))
        hv = imgui.IsItemHovered()
    end
    local a = rhAnim(id, hv and 1 or 0)
    dl:AddRectFilled(P(x, y0), P(x + w, y0 + h), rhAlpha(col, 0.12 + 0.1 * a), 11)
    dl:AddRect(P(x, y0), P(x + w, y0 + h), rhAlpha(col, 0.4 + 0.45 * a), 11, 15, 1.0)
    local tx = x + 10
    if icon then
        dl:AddImage(icon, P(x + 7, y0 + 3), P(x + 23, y0 + 19))
        tx = x + 10 + iw
    end
    dl:PushClipRect(P(x, y0), P(x + w - 5, y0 + h), true)
    dl:AddText(P(tx, y0 + (h - sz.y) / 2), 0xFFEAEAEA, server)
    dl:PopClipRect()
    if hv then rhTip(S.srvTip) end
    return w, clicked, hv
end

function LBX.tip(c, it)
    local S, C = LBX.S(), PD.C
    local e = it.e
    rhTipBegin()
    imgui.TextColored(PD.vec4(0xFFFFFFFF), e.name or "?")
    local sub = "#" .. it.rank
    if e.server and e.server ~= "" then sub = sub .. "  /  " .. e.server end
    imgui.TextColored(PD.vec4(C.mute), sub)
    imgui.TextColored(PD.vec4(C.green), formatNumber(e.amount) .. "$")
    if c.top > 0 and it.rank > 1 then
        imgui.TextColored(PD.vec4(C.mute), math.floor((e.amount or 0) / c.top * 100 + 0.5) .. S.fromLeader)
    end
    local mode, period = c.mode, c.period
    if (mode == "Farm" or mode == "Mine" or mode == "Sawmill") and type(e.resources) == "table" then
        local keys = {}
        for k in pairs(e.resources) do keys[#keys + 1] = k end
        table.sort(keys)
        if #keys > 0 then
            imgui.Separator()
            imgui.TextColored(PD.vec4(C.mute), S.res)
            for _, k in ipairs(keys) do
                imgui.TextColored(PD.vec4(0xFFE0E0E0), u8(tostring(k) .. ": ") .. formatNumber(e.resources[k] or 0))
            end
        end
    elseif mode == "Oil" or mode == "Taxi" or mode == "Incass" then
        local r = type(e.resources) == "table" and e.resources or {}
        local mcol = LBX.MCOL[LBX.mIdx]
        local rows
        if mode == "Oil" then
            rows = {{u8("AZ"), formatNumber(r["AZ"] or 0)}}
        elseif mode == "Taxi" then
            rows = {{u8("Поездки"), formatNumber(r["Поездки"] or 0)}}
        else
            rows = {{u8("Банкоматы"), formatNumber(r["Банкоматы"] or 0) .. "$"},
                    {u8("Акции"), formatNumber(r["Акции"] or 0) .. "$"}}
        end
        imgui.Separator()
        for _, rw in ipairs(rows) do
            imgui.TextColored(PD.vec4(mcol), rw[1] .. ": ")
            imgui.SameLine()
            imgui.TextColored(PD.vec4(0xFFE0E0E0), rw[2])
        end
    elseif mode == "IM" then
        local r = type(e.resources) == "table" and e.resources or {}
        imgui.Separator()
        imgui.TextColored(PD.vec4(LBX.MCOL[8]), "Item Market: ")
        imgui.SameLine()
        imgui.TextColored(PD.vec4(0xFFE0E0E0), formatNumber(r["im"] or 0) .. "$")
        imgui.TextColored(PD.vec4(LBX.MCOL[8]), S.shards .. ": ")
        imgui.SameLine()
        imgui.TextColored(PD.vec4(0xFFE0E0E0), formatNumber(r["shards"] or 0) .. "$")
    elseif mode == "Income" then
        imgui.Separator()
        local loaded = false
        for i, m in ipairs(LBX.SUBS) do
            local map = LBX.nameMap(m, period)
            if map then loaded = true end
            imgui.TextColored(PD.vec4(LBX.MCOL[i + 1]), S.modesFull[i + 1] .. ": ")
            imgui.SameLine()
            imgui.TextColored(PD.vec4(0xFFE0E0E0), formatNumber(map and map[tostring(e.name) .. "|" .. (e.server or "")] or 0) .. "$")
        end
        if not loaded then LBX.needSubs(period) end
    end
    rhTipEnd()
end

function LBX.hero(dl, c, x, y, w, h)
    local S, C = LBX.S(), PD.C
    local P = imgui.ImVec2
    local pr, ACC = c.pr, c.ACC
    rhCardBox(dl, x, y, w, h, c.bg, c.brd, 14)
    local split = (w >= 520)
    local lw = split and math.floor(w * 0.5) or w
    if split then dl:AddLine(P(x + lw, y + 18), P(x + lw, y + h - 18), rhAlpha(0xFFFFFFFF, 0.06), 1.0) end

    rhIconBadge(dl, x + 34, y + 27, 11, fa.ICON_TROPHY, ACC, c.bg, 0)
    LBX.clip(dl, x + 54, y + 19, lw - 70, C.mute, S.heroCap .. " - " .. S.modesFull[LBX.mIdx] .. ", " .. S.periodsFull[LBX.pIdx], false)

    local list = pr.list
    local myIdx, meE, total = pr.myIdx, nil, pr.total
    if myIdx then meE = list[myIdx] end
    local isDev = (pr.devRank ~= nil)
    if isDev then myIdx, meE, total = pr.devRank, pr.dev, pr.total + 1 end
    local function nbr(d)
        local i = myIdx + d
        if isDev and d == 1 then i = myIdx end
        return list[i]
    end
    if meE then
        local mc = LBX.medal(myIdx)
        local big = "#" .. myIdx
        LBX.big(dl, x + 22, y + 40, big, mc or ACC)
        local ofTxt = S.outOf .. formatNumber(total)
        local ofX = x + 22 + LBX.bigW(big) + 10
        dl:AddText(P(ofX, y + 56), C.mute, ofTxt)
        if isDev then dl:AddText(P(ofX + imgui.CalcTextSize(ofTxt).x + 8, y + 56), LBX.RIV, S.devTag) end
        LBX.txt(dl, x + 22, y + 82, C.green, LBX.money(meE.amount, lw - 44), false)
        local pxx = x + 22
        local topPct = math.max(1, math.ceil(myIdx / math.max(1, total) * 100))
        pxx = pxx + rhPill(dl, pxx, y + 112, S.top .. topPct .. "%", mc or ACC) + 6
        if pr.mySrv and pr.mySrv ~= "" and pr.mySrvRank then
            local sp = pr.mySrv .. "  #" .. pr.mySrvRank
            local scol = LBX.srvColor(pr.mySrv)
            local sicon = getServerIcon(pr.mySrv)
            local siw = sicon and 18 or 0
            local ssz = imgui.CalcTextSize(sp)
            local spw = ssz.x + 20 + siw
            if pxx + spw < x + lw - 10 then
                local sph = 22
                dl:AddRectFilled(P(pxx, y + 112), P(pxx + spw, y + 112 + sph), rhAlpha(scol, 0.14), 11)
                dl:AddRect(P(pxx, y + 112), P(pxx + spw, y + 112 + sph), rhAlpha(scol, 0.45), 11, 15, 1.0)
                local stx = pxx + 10
                if sicon then
                    dl:AddImage(sicon, P(pxx + 7, y + 112 + 3), P(pxx + 23, y + 112 + 19))
                    stx = pxx + 10 + siw
                end
                dl:AddText(P(stx, y + 112 + (sph - ssz.y) / 2), scol, sp)
            end
        end
    else
        LBX.big(dl, x + 22, y + 40, "--", C.dim)
        LBX.txt(dl, x + 22, y + 82, 0xFFFFFFFF, S.notIn, true)
        local lines = rhWrapLines(S.notInSub, lw - 44)
        for i, ln in ipairs(lines) do
            if i <= 2 then dl:AddText(P(x + 22, y + 104 + (i - 1) * 17), C.mute, ln) end
        end
    end

    if isDev and meE and LBX.hov(x, y, lw, h) then
        LBX.tip(c, {e = meE, rank = myIdx})
    end

    if not split then return end
    local rx0, rx1 = x + lw + 22, x + w - 22
    local rw = rx1 - rx0
    dl:AddText(P(rx0, y + 19), C.mute, S.fight)
    if not meE then return end

    local ry = y + 46
    local function line(icon, icol, label, name, val, vcol)
        dl:AddText(P(rx0, ry), icol, icon)
        local lx = rx0 + 20
        dl:AddText(P(lx, ry), C.mute, label)
        lx = lx + imgui.CalcTextSize(label).x + 8
        local vw = imgui.CalcTextSize(val).x
        LBX.clip(dl, lx, ry, rx1 - vw - 10 - lx, 0xFFE6E6E6, name, false)
        LBX.txt(dl, rx1 - vw, ry, vcol, val, false)
        ry = ry + 26
    end
    if myIdx > 1 then
        local up = list[myIdx - 1]
        local diff = math.max(0, (up.amount or 0) - (meE.amount or 0))
        line(fa.ICON_ANGLE_UP, LBX.WARN, "#" .. (myIdx - 1), up.name or "?", "-" .. LBX.money(diff, 110), LBX.WARN)
    else
        dl:AddText(P(rx0, ry), LBX.GOLD, fa.ICON_TROPHY)
        LBX.txt(dl, rx0 + 20, ry, LBX.GOLD, S.leading, true)
        ry = ry + 26
    end
    local dn = nbr(1)
    if dn then
        local diff = math.max(0, (meE.amount or 0) - (dn.amount or 0))
        line(fa.ICON_ANGLE_DOWN, C.green, "#" .. (myIdx + 1), dn.name or "?", "+" .. LBX.money(diff, 110), C.green)
    end
    if LBX.rival and LBX.rival ~= c.me then
        local ri = pr.byName[LBX.rival]
        if ri then
            local re = list[ri]
            local rr = (isDev and ri >= myIdx) and (ri + 1) or ri
            local diff = (meE.amount or 0) - (re.amount or 0)
            local ahead = diff >= 0
            line(fa.ICON_STAR, LBX.RIV, "#" .. rr, re.name or "?", (ahead and "+" or "-") .. LBX.money(math.abs(diff), 110), ahead and C.green or LBX.WARN)
        else
            line(fa.ICON_STAR, LBX.RIV, S.rivalWord, LBX.rival, "--", C.dim)
        end
    else
        dl:AddText(P(rx0, ry), LBX.RIV, fa.ICON_STAR)
        LBX.clip(dl, rx0 + 20, ry, rw - 20, C.dim, S.rivalHint, false)
    end
    if myIdx > 1 then
        local up = list[myIdx - 1]
        local frac = ((up.amount or 0) > 0) and math.min(1, (meE.amount or 0) / up.amount) or 0
        local by = y + h - 26
        dl:AddRectFilled(P(rx0, by), P(rx1, by + 6), rhAlpha(0xFFFFFFFF, 0.07), 3)
        dl:AddRectFilled(P(rx0, by), P(rx0 + math.max(4, rw * frac), by + 6), ACC, 3)
    end
end

function LBX.podium(dl, c, x, y, w, items)
    local S, C = LBX.S(), PD.C
    local P = imgui.ImVec2
    local gap = 10
    local cw = (w - gap * 2) / 3
    local H = 150
    local order = {2, 1, 3}
    for slot = 1, 3 do
        local r = order[slot]
        local it = items[r]
        local ch = (r == 1) and 150 or 132
        local cx0 = x + (slot - 1) * (cw + gap)
        local cy0 = y + (H - ch)
        local mc = LBX.medal(r)
        if not it then
            rhCardBox(dl, cx0, cy0, cw, ch, c.bg, c.brd, 14)
            local sz = imgui.CalcTextSize("-")
            dl:AddText(P(cx0 + (cw - sz.x) / 2, cy0 + (ch - sz.y) / 2), C.dim, "-")
        else
            local e = it.e
            local isMe = LBX.isMine(e, c.me, c.srv)
            local isRiv = (LBX.rival ~= nil and e.name == LBX.rival)
            local live = not LBX.inPin(c, cy0, cy0 + ch)
            local hv = live and LBX.hov(cx0, cy0, cw, ch)
            local a = rhAnim("lbx_pod" .. r, hv and 1 or 0)
            rhCardBox(dl, cx0, cy0, cw, ch, rhLerpColor(c.bg, rhLerpColor(c.bg, 0xFFFFFFFF, 0.05), a), c.brd, 14)
            dl:AddRectFilled(P(cx0 + 2, cy0 + 2), P(cx0 + cw - 2, cy0 + ch - 2), rhAlpha(mc, (r == 1 and 0.08 or 0.05) + 0.04 * a), 12)
            dl:AddRect(P(cx0, cy0), P(cx0 + cw, cy0 + ch), rhAlpha(mc, 0.6 + 0.4 * a), 14, 15, 1.6)
            if isMe then
                dl:AddRect(P(cx0 + 4, cy0 + 4), P(cx0 + cw - 4, cy0 + ch - 4), rhAlpha(c.ACC, 0.8), 11, 15, 1.0)
            elseif isRiv then
                dl:AddRect(P(cx0 + 4, cy0 + 4), P(cx0 + cw - 4, cy0 + ch - 4), rhAlpha(LBX.RIV, 0.7), 11, 15, 1.0)
            end

            local mid = cx0 + cw / 2
            local br = (r == 1) and 18 or 15
            local by = cy0 + 14 + br
            dl:AddCircleFilled(P(mid, by), br + 6, rhAlpha(mc, 0.06 + 0.04 * a), 32)
            dl:AddCircleFilled(P(mid, by), br, rhAlpha(mc, 0.18), 32)
            dl:AddCircle(P(mid, by), br, rhAlpha(mc, 0.7), 32, 1.2)
            local isz = imgui.CalcTextSize(fa.ICON_TROPHY)
            dl:AddText(P(mid - isz.x / 2, by - isz.y / 2), mc, fa.ICON_TROPHY)

            local ny = by + br + 10
            local nm = e.name or "?"
            local tw = math.min(imgui.CalcTextSize(nm).x, cw - 24)
            LBX.clip(dl, mid - tw / 2, ny, tw, isMe and c.ACC or 0xFFFFFFFF, nm, false)

            local tagHv = false
            if e.server and e.server ~= "" then
                local _, tClicked, th2 = LBX.srvTag(dl, "##lbx_pt" .. r, mid, ny + 28, e.server, cw - 20, live, true)
                tagHv = th2
                if tClicked then LBX.server = (LBX.server == e.server) and nil or e.server end
            end
            local amt = LBX.money(e.amount, cw - 24)
            local asz = imgui.CalcTextSize(amt)
            LBX.txt(dl, mid - asz.x / 2, ny + 46, C.green, amt, false)

            local frac = (c.top > 0) and math.min(1, (e.amount or 0) / c.top) or 0
            dl:AddRectFilled(P(cx0 + 16, cy0 + ch - 12), P(cx0 + cw - 16, cy0 + ch - 9), rhAlpha(0xFFFFFFFF, 0.06), 1)
            if frac > 0 then
                dl:AddRectFilled(P(cx0 + 16, cy0 + ch - 12), P(cx0 + 16 + math.max(3, (cw - 32) * frac), cy0 + ch - 9), rhAlpha(mc, 0.9), 1)
            end

            local sClicked, sHv = LBX.star(dl, "##lbx_ps" .. r, cx0 + cw - 20, cy0 + 22, isRiv, hv, live)
            if sClicked then LBX.rivalToggle(e.name) end
            if hv and not sHv and not tagHv then LBX.tip(c, it) end
        end
    end
end

function LBX.inPin(c, y0, y1)
    local pn = c.pin
    if not pn then return false end
    return y1 > pn.y - 4 and y0 < pn.y + pn.h + 4
end

function LBX.row(dl, c, x, y, w, it)
    local P = imgui.ImVec2
    local S, C = LBX.S(), PD.C
    local h = LBX.ROW_H
    local e, rank = it.e, it.rank
    local isMe = (c.me ~= nil and e.name == c.me)
    local isRiv = (LBX.rival ~= nil and e.name == LBX.rival)
    local live = not LBX.inPin(c, y, y + h)
    local hv = live and LBX.hov(x, y, w, h)
    local a = rhAnim("lbx_r" .. it.gi, hv and 1 or 0)

    local brC = rhLerpColor(c.brd, c.ACC, 0.5 * a)
    if isMe then brC = rhAlpha(c.ACC, 0.8) elseif isRiv then brC = rhAlpha(LBX.RIV, 0.7) end
    rhCardBox(dl, x, y, w, h, rhLerpColor(c.bg, rhLerpColor(c.bg, 0xFFFFFFFF, 0.05), a), brC, 12)
    if isMe then
        dl:AddRectFilled(P(x + 4, y + 3), P(x + w - 4, y + h - 3), rhAlpha(c.ACC, 0.07), 9)
    elseif isRiv then
        dl:AddRectFilled(P(x + 4, y + 3), P(x + w - 4, y + h - 3), rhAlpha(LBX.RIV, 0.05), 9)
    end

    local mc = LBX.medal(rank)
    local frac = (c.top > 0) and math.min(1, (e.amount or 0) / c.top) or 0
    local barCol = mc or (isMe and c.ACC or rhLerpColor(c.bg, c.ACC, 0.55))
    local bx0, bx1 = x + 14, x + w - 14
    dl:AddRectFilled(P(bx0, y + h - 7), P(bx1, y + h - 5), rhAlpha(0xFFFFFFFF, 0.05), 1)
    if frac > 0 then
        dl:AddRectFilled(P(bx0, y + h - 7), P(bx0 + math.max(3, (bx1 - bx0) * frac), y + h - 5), rhAlpha(barCol, 0.9), 1)
    end

    local cy = y + (h - 4) / 2
    local bw = c.bw
    local bbx, bby = x + 12, cy - 15
    dl:AddRectFilled(P(bbx, bby), P(bbx + bw, bby + 30), rhAlpha(mc or 0xFFFFFFFF, mc and 0.16 or 0.06), 9)
    dl:AddRect(P(bbx, bby), P(bbx + bw, bby + 30), rhAlpha(mc or 0xFFFFFFFF, mc and 0.55 or 0.10), 9, 15, 1.0)
    local rl = mc and fa.ICON_TROPHY or tostring(rank)
    local rsz = imgui.CalcTextSize(rl)
    dl:AddText(P(bbx + (bw - rsz.x) / 2, cy - rsz.y / 2), mc or C.mute, rl)

    local ax1 = x + w - 40
    local amtW = 130
    local amt = LBX.money(e.amount, amtW)
    local asz = imgui.CalcTextSize(amt)
    LBX.txt(dl, ax1 - asz.x, cy - asz.y / 2, C.green, amt, false)

    local nx = bbx + bw + 12
    local tagHv = false
    local nameMax = ax1 - amtW - 12 - nx
    if c.showSrv then
        local srvX = ax1 - amtW - 14 - 150
        nameMax = srvX - nx - 10
        if e.server and e.server ~= "" then
            local _, tClicked, th2 = LBX.srvTag(dl, "##lbx_t" .. it.gi, srvX, cy, e.server, 150, live, false)
            tagHv = th2
            if tClicked then LBX.server = (LBX.server == e.server) and nil or e.server end
        end
    end
    local nm = e.name or "?"
    local nsz = imgui.CalcTextSize(nm)
    local pillW = isMe and (imgui.CalcTextSize(S.me).x + 14 + 8) or 0
    LBX.clip(dl, nx, cy - nsz.y / 2, nameMax - pillW, isMe and 0xFFFFFFFF or 0xFFE6E6E6, nm, false)
    if isMe then LBX.pill(dl, nx + math.min(nsz.x, nameMax - pillW) + 8, cy, S.me, c.ACC) end

    local sClicked, sHv = LBX.star(dl, "##lbx_s" .. it.gi, x + w - 22, cy, isRiv, hv, live)
    if sClicked then LBX.rivalToggle(e.name) end
    if hv and not sHv and not tagHv then LBX.tip(c, it) end
end

function LBX.toolbar(dl, c, x, y, w)
    local S, C = LBX.S(), PD.C
    local P = imgui.ImVec2
    local pr, th = c.pr, c.th
    local wide = (w >= 560)
    local srvW, limW, gap, h = 170, 112, 8, 36
    local sw = wide and (w - srvW - limW - gap * 2) or w

    local focused = LBX.searchActive
    rhCardBox(dl, x, y, sw, h, c.bg, focused and rhAlpha(c.ACC, 0.8) or c.brd, 12)
    dl:AddText(P(x + 13, y + (h - th) / 2), focused and c.ACC or C.mute, fa.ICON_SEARCH)
    imgui.SetCursorScreenPos(P(x + 34, y + 2))
    imgui.PushItemWidth(sw - 34 - 36)
    imgui.PushStyleColor(imgui.Col.FrameBg, imgui.ImVec4(0, 0, 0, 0))
    imgui.PushStyleColor(imgui.Col.FrameBgHovered, imgui.ImVec4(0, 0, 0, 0))
    imgui.PushStyleColor(imgui.Col.FrameBgActive, imgui.ImVec4(0, 0, 0, 0))
    imgui.PushStyleColor(imgui.Col.Border, imgui.ImVec4(0, 0, 0, 0))
    imgui.PushStyleVar(imgui.StyleVar.FramePadding, imgui.ImVec2(2, 8))
    imgui.InputText("##lbx_search", LBX.search)
    LBX.searchActive = imgui.IsItemActive()
    imgui.PopStyleVar(1)
    imgui.PopStyleColor(4)
    imgui.PopItemWidth()
    local txt = LBX.search.v or ""
    if txt == "" and not LBX.searchActive then
        dl:AddText(P(x + 38, y + (h - th) / 2), C.dim, S.search)
    end
    if txt ~= "" then
        local cx0 = x + sw - 30
        imgui.SetCursorScreenPos(P(cx0, y + 6))
        if imgui.InvisibleButton("##lbx_search_clear", imgui.ImVec2(24, 24)) then LBX.search.v = "" end
        local hv = imgui.IsItemHovered()
        local isz = imgui.CalcTextSize(fa.ICON_TIMES)
        dl:AddText(P(cx0 + 12 - isz.x / 2, y + 18 - isz.y / 2), hv and 0xFFFFFFFF or C.mute, fa.ICON_TIMES)
    end

    local cx1, cy1, chipSrvW, chipLimW
    if wide then
        cx1, cy1, chipSrvW, chipLimW = x + sw + gap, y, srvW, limW
    else
        chipSrvW = math.floor((w - gap) * 0.6)
        cx1, cy1, chipLimW = x, y + h + gap, (w - gap) - chipSrvW
    end
    local srvLabel = LBX.server or S.allSrv
    if LBX.chip(dl, "##lbx_srv_btn", cx1, cy1, chipSrvW, h, fa.ICON_FILTER, srvLabel, c.ACC, LBX.server ~= nil, c.bg, c.brd) then
        imgui.OpenPopup("##lbx_srv")
    end
    local lim = lbRowsLimit or 9999
    local limLabel = S.show .. (lim == 9999 and S.all or tostring(lim))
    if LBX.chip(dl, "##lbx_lim_btn", cx1 + chipSrvW + gap, cy1, chipLimW, h, nil, limLabel, c.ACC, false, c.bg, c.brd) then
        imgui.OpenPopup("##lbx_lim")
    end

    if imgui.BeginPopup("##lbx_srv") then
        LBX.modalNext = true
        imgui.TextColored(PD.vec4(C.mute), S.srvTitle)
        imgui.Spacing()
        local servers = pr.servers
        local total = #servers + 1
        local cols, tw, tg, th2 = 3, 150, 6, 34
        local rows = math.ceil(total / cols)
        local chh = math.min(rows * (th2 + tg) + 4, 340)
        imgui.BeginChild("##lbx_srv_sc", imgui.ImVec2(cols * (tw + tg) + 6, chh), false)
        local pdl = imgui.GetWindowDrawList()
        local base = imgui.GetCursorScreenPos()
        for i = 0, #servers do
            local name = nil
            if i > 0 then name = servers[i] end
            local colI, rowI = i % cols, math.floor(i / cols)
            local tx, ty = base.x + colI * (tw + tg), base.y + rowI * (th2 + tg)
            local sel = (LBX.server == name)
            imgui.SetCursorScreenPos(P(tx, ty))
            local clicked = imgui.InvisibleButton("##lbx_sp" .. i, imgui.ImVec2(tw, th2))
            local hv = imgui.IsItemHovered()
            local a = rhAnim("lbx_sp" .. i, hv and 1 or 0)
            local sc = name and LBX.srvColor(name) or c.ACC
            pdl:AddRectFilled(P(tx, ty), P(tx + tw, ty + th2), sel and rhAlpha(sc, 0.2) or rhLerpColor(0xFF181818, 0xFF262626, a), 8)
            pdl:AddRect(P(tx, ty), P(tx + tw, ty + th2), sel and rhAlpha(sc, 0.9) or rhLerpColor(0xFF2A2A2A, sc, 0.7 * a), 8, 15, 1.0)
            local ix = tx + 10
            local icon = name and getServerIcon(name) or nil
            if icon then
                pdl:AddImage(icon, P(tx + 8, ty + 9), P(tx + 24, ty + 25))
                ix = tx + 30
            end
            local cs = formatNumber(name and pr.counts[name] or pr.total)
            local csw = imgui.CalcTextSize(cs).x
            pdl:PushClipRect(P(tx, ty), P(tx + tw - csw - 16, ty + th2), true)
            pdl:AddText(P(ix, ty + (th2 - th) / 2), sel and 0xFFFFFFFF or 0xFFCCCCCC, name or S.allSrv)
            pdl:PopClipRect()
            pdl:AddText(P(tx + tw - 10 - csw, ty + (th2 - th) / 2), C.mute, cs)
            if clicked then
                LBX.server = name
                imgui.CloseCurrentPopup()
            end
        end
        imgui.SetCursorScreenPos(P(base.x, base.y + rows * (th2 + tg)))
        imgui.Dummy(imgui.ImVec2(1, 1))
        imgui.EndChild()
        imgui.EndPopup()
    end
    if imgui.BeginPopup("##lbx_lim") then
        LBX.modalNext = true
        imgui.TextColored(PD.vec4(C.mute), S.limTitle)
        imgui.Separator()
        for _, o in ipairs({10, 25, 50, 100, 200, 9999}) do
            if imgui.Selectable((o == 9999) and S.all or tostring(o), lim == o) then
                lbRowsLimit = o
                saveLbRowsLimit()
                imgui.CloseCurrentPopup()
            end
        end
        imgui.EndPopup()
    end
    return y + (wide and h or (h * 2 + gap)) + 12
end

function LBX.skeleton(dl, c, x, y, w)
    local P = imgui.ImVec2
    local sk = 0.035 + 0.04 * (0.5 + 0.5 * math.sin(os.clock() * 3))
    rhCardBox(dl, x, y, w, 150, c.bg, c.brd, 14)
    dl:AddRectFilled(P(x + 22, y + 22), P(x + 170, y + 38), rhAlpha(0xFFFFFFFF, sk), 8)
    dl:AddRectFilled(P(x + 22, y + 52), P(x + 130, y + 92), rhAlpha(0xFFFFFFFF, sk), 10)
    dl:AddRectFilled(P(x + 22, y + 108), P(x + 210, y + 126), rhAlpha(0xFFFFFFFF, sk), 9)
    y = y + 150 + 12
    for i = 1, 6 do
        rhCardBox(dl, x, y, w, LBX.ROW_H, c.bg, c.brd, 12)
        dl:AddRectFilled(P(x + 12, y + 8), P(x + 42, y + 38), rhAlpha(0xFFFFFFFF, sk), 9)
        dl:AddRectFilled(P(x + 56, y + 16), P(x + 56 + 90 + (i * 23) % 70, y + 30), rhAlpha(0xFFFFFFFF, sk), 7)
        dl:AddRectFilled(P(x + w - 130, y + 16), P(x + w - 16, y + 30), rhAlpha(0xFFFFFFFF, sk), 7)
        y = y + LBX.ROW_H + LBX.ROW_GAP
    end
    return y
end

function LBX.list(dl, c, x, y, w, view)
    local S, C = LBX.S(), PD.C
    local P = imgui.ImVec2
    local items = view.items
    local n = #items
    if n == 0 then
        local eh = 100
        rhCardBox(dl, x, y, w, eh, c.bg, c.brd, 14)
        rhIconBadge(dl, x + w / 2, y + 34, 18, fa.ICON_USERS, C.mute, c.bg, 0)
        local t = (view.q ~= "") and S.noneSearch or S.none
        local sz = imgui.CalcTextSize(t)
        dl:AddText(P(x + (w - sz.x) / 2, y + 62), C.mute, t)
        return y + eh + 10
    end
    local podium = (view.q == "")
    local startIdx = podium and 4 or 1
    local limit = lbRowsLimit or 9999
    local lastAllowed = math.min(n, limit)
    local nRows = math.max(0, lastAllowed - startIdx + 1)
    local pitch = LBX.ROW_H + LBX.ROW_GAP
    local rowsTop = y
    local endY = rowsTop + nRows * pitch

    c.bw = math.max(30, imgui.CalcTextSize(tostring(items[lastAllowed].rank)).x + 16)
    c.showSrv = (w >= 540)

    local myPos = view.myPos
    local myY, pinned
    if myPos then
        if podium and myPos <= 3 then
            myY = c.podY
        elseif myPos <= lastAllowed then
            myY = rowsTop + (myPos - startIdx) * pitch
        else
            pinned = true
            myY = endY + 20
        end
    end
    c.pin = nil
    if myY then
        local wp, ws = imgui.GetWindowPos(), imgui.GetWindowSize()
        local top, bot = wp.y, wp.y + ws.y
        if myY + LBX.ROW_H < top + 8 or myY > bot - 8 then
            local bh = 40
            local up = (myY < top)
            c.pin = {x = x, y = up and (top + 8) or (bot - bh - 8), w = w, h = bh, up = up, item = items[myPos]}
        end
        if LBX.jumpTo and imgui.GetScrollY and imgui.SetScrollY then
            imgui.SetScrollY(math.max(0, imgui.GetScrollY() + (myY - (top + 150))))
        end
    end
    LBX.jumpTo = false

    if podium then LBX.podium(dl, c, x, c.podY, w, items) end

    local first, last = rhVisRows(rowsTop, pitch, nRows)
    for k = first, last do
        LBX.row(dl, c, x, rowsTop + (k - 1) * pitch, w, items[startIdx + k - 1])
    end

    if pinned then
        for d = -1, 1 do dl:AddCircleFilled(P(x + w / 2 + d * 10, endY + 8), 2.5, C.dim, 8) end
        LBX.row(dl, c, x, endY + 20, w, items[myPos])
        endY = endY + 20 + pitch
    end

    if lastAllowed < n and limit < 9999 then
        local nxt = 9999
        for _, o in ipairs({10, 25, 50, 100, 200, 9999}) do
            if o > limit then nxt = o; break end
        end
        local bwid = 230
        if WK.button(dl, "##lbx_more", x + (w - bwid) / 2, endY + 4, bwid, 38,
            S.more .. formatNumber(math.min(nxt, n) - lastAllowed), fa.ICON_ANGLE_DOWN, c.ACC, false, false) then
            lbRowsLimit = nxt
            saveLbRowsLimit()
        end
        endY = endY + 4 + 38 + 8
    end

    if c.pin then
        local pn = c.pin
        local it = pn.item
        local hv = PD.hov(pn.x, pn.y, pn.w, pn.h) and not LBX.modal
        local a = rhAnim("lbx_pin", hv and 1 or 0)
        dl:AddRectFilled(P(pn.x, pn.y), P(pn.x + pn.w, pn.y + pn.h), rhLerpColor(c.bg, 0xFF000000, 0.35), 12)
        dl:AddRectFilled(P(pn.x, pn.y), P(pn.x + pn.w, pn.y + pn.h), rhAlpha(c.ACC, 0.10 + 0.08 * a), 12)
        dl:AddRect(P(pn.x, pn.y), P(pn.x + pn.w, pn.y + pn.h), rhAlpha(c.ACC, 0.7 + 0.3 * a), 12, 15, 1.2)
        local ty = pn.y + (pn.h - c.th) / 2
        local rk = "#" .. it.rank
        LBX.txt(dl, pn.x + 16, ty, c.ACC, rk, false)
        local nx = pn.x + 16 + imgui.CalcTextSize(rk).x + 12
        local arrow = pn.up and fa.ICON_ANGLE_UP or fa.ICON_ANGLE_DOWN
        local asz = imgui.CalcTextSize(arrow)
        dl:AddText(P(pn.x + pn.w - 20 - asz.x / 2, pn.y + (pn.h - asz.y) / 2), c.ACC, arrow)
        local amt = LBX.money(it.e.amount, 130)
        local amw = imgui.CalcTextSize(amt).x
        LBX.txt(dl, pn.x + pn.w - 40 - amw, ty, C.green, amt, false)
        LBX.clip(dl, nx, ty, pn.x + pn.w - 40 - amw - 12 - nx, 0xFFFFFFFF, (it.e.name or "?") .. "  (" .. S.me .. ")", false)
        if hv and imgui.IsMouseClicked(0) then LBX.jumpTo = true end
    end
    return endY + 6
end

function LBX.draw()
    local S, C = LBX.S(), PD.C
    local P = imgui.ImVec2
    local dl = imgui.GetWindowDrawList()
    LBX.modal = LBX.modalNext
    LBX.modalNext = false
    LBX.rivalLoad()
    local bg, brd, iconCol = homeCardColors()
    local ACC = useCustomTheme and iconCol or 0xFF1AE591
    local cur = imgui.GetCursorScreenPos()
    local x, y = cur.x, cur.y + 4
    local w = imgui.GetWindowWidth() - 25
    local th = imgui.CalcTextSize("A").y
    local c = {bg = bg, brd = brd, ACC = ACC, th = th}
    local function finish(yy)
        imgui.SetCursorScreenPos(P(x, yy))
        imgui.Dummy(imgui.ImVec2(w, 8))
        LBX.scrollbar(dl, yy + 8, ACC)
    end

    if not LBX.enabled() then
        local eh = 200
        rhCardBox(dl, x, y, w, eh, bg, brd, 14)
        rhIconBadge(dl, x + w / 2, y + 52, 24, fa.ICON_TROPHY, ACC, bg, 0)
        local t1 = imgui.CalcTextSize(S.offTitle)
        LBX.txt(dl, x + (w - t1.x) / 2, y + 90, 0xFFFFFFFF, S.offTitle, true)
        local ly = y + 114
        for i, ln in ipairs(rhWrapLines(S.offSub, w - 60)) do
            local lsz = imgui.CalcTextSize(ln)
            dl:AddText(P(x + (w - lsz.x) / 2, ly), C.mute, ln)
            ly = ly + 18
        end
        if WK.button(dl, "##lbx_open_settings", x + (w - 240) / 2, y + eh - 56, 240, 40, S.offBtn, fa.ICON_COG, ACC, true, false) then
            settingsPage = 4
            currentTab = 10
        end
        finish(y + eh + 8)
        return
    end

    local me = LBX.me()
    local mode, period = LBX.MODES[LBX.mIdx], LBX.PERIODS[LBX.pIdx]
    local key = mode .. "|" .. period
    local now = os.clock()
    local reopened = (now - (LBX.lastDraw or 0)) > 1.0
    LBX.lastDraw = now
    if reopened or LBX.lastKey ~= key then
        LBX.lastKey = key
        if not LBX.has(LBX.cacheGet(mode, period)) then LBX.diskLoad(mode, period) end
        local fired = LBX.request(mode, period, false)
        if mode == "Income" then
            for _, m in ipairs(LBX.SUBS) do
                if not LBX.has(LBX.cacheGet(m, period)) then LBX.diskLoad(m, period) end
                if LBX.request(m, period, false) then fired = true end
            end
        end
        if fired then LBX.startSession(mode, period) end
    end
    local st, age = LBX.status(mode, period)
    local cache = LBX.cacheGet(mode, period)
    local hasData = LBX.has(cache)
    rhIconBadge(dl, x + 22, y + 22, 16, fa.ICON_TROPHY, LBX.GOLD, bg, 0)
    LBX.txt(dl, x + 50, y + 4, 0xFFFFFFFF, S.title, true)
    dl:AddText(P(x + 50, y + 24), C.mute, S.sub)
    local stText, stCol
    if st == "loading" then stText, stCol = S.upd, LBX.WARN
    elseif st == "fresh" then stText, stCol = S.updated .. LBX.ago(age), C.green
    elseif st == "failed" then stText, stCol = (hasData and S.offline or S.fail), LBX.WARN
    else stText, stCol = S.saved, C.mute end
    local stW = imgui.CalcTextSize(stText).x
    local stX = x + w - 48 - stW
    if stX > x + 330 then
        dl:AddCircleFilled(P(stX - 12, y + 22), 3.5, stCol, 12)
        dl:AddText(P(stX, y + 22 - th / 2), stCol, stText)
    end
    if LBX.refreshBtn(dl, x + w - 40, y + 4, 36, st == "loading", ACC, bg, brd) then
        local fired = LBX.request(mode, period, true)
        if mode == "Income" then
            for _, m in ipairs(LBX.SUBS) do
                if LBX.request(m, period, true) then fired = true end
            end
        end
        if fired then LBX.startSession(mode, period) end
    end
    y = y + 52
    local pc = LBX.segment(dl, "##lbx_period", x, y, w, 38, S.periods, LBX.pIdx, ACC, bg, brd)
    if pc then LBX.pIdx = pc; LBX.server = nil end
    y = y + 38 + 10
    local gap, perRow = 8, 4
    local chipW = (w - gap * (perRow - 1)) / perRow
    local icons = LBX.icons()
    for i = 1, #LBX.MODES do
        local col, row = (i - 1) % perRow, math.floor((i - 1) / perRow)
        if LBX.chip(dl, "##lbx_mode" .. i, x + col * (chipW + gap), y + row * (38 + 8), chipW, 38, icons[i], S.modes[i], LBX.MCOL[i], LBX.mIdx == i, bg, brd) then
            LBX.mIdx = i
            LBX.server = nil
        end
    end
    y = y + 38 * 2 + 8 + 12

    local inf = LBX.sessInfo()
    if inf then
        LBX.progressCard(dl, c, x, y, w, inf)
        y = y + 56 + 12
    end
    if not hasData then
        if st == "loading" then
            finish(LBX.skeleton(dl, c, x, y, w))
        else
            local eh = 130
            local failed = (st == "failed")
            rhCardBox(dl, x, y, w, eh, bg, brd, 14)
            rhIconBadge(dl, x + w / 2, y + 36, 20, failed and fa.ICON_EXCLAMATION_TRIANGLE or fa.ICON_USERS, failed and LBX.WARN or C.mute, bg, 0)
            local tt = failed and S.fail or S.none
            local tsz = imgui.CalcTextSize(tt)
            dl:AddText(P(x + (w - tsz.x) / 2, y + 68), 0xFFFFFFFF, tt)
            if failed then
                local s2 = imgui.CalcTextSize(S.failSub)
                dl:AddText(P(x + (w - s2.x) / 2, y + 88), C.mute, S.failSub)
                if WK.button(dl, "##lbx_retry", x + w - 140 - 16, y + eh - 46, 140, 34, S.retry, fa.ICON_REFRESH, ACC, true, false) then
                    LBX.request(mode, period, true)
                end
            end
            finish(y + eh + 10)
        end
        return
    end

    local pr = LBX.prepare(cache, me, LBX.mySrv())
    if LBX.server and not pr.counts[LBX.server] then LBX.server = nil end
    c.pr, c.me, c.mode, c.period, c.top = pr, me, mode, period, pr.top
    c.srv = pr.srv

    LBX.hero(dl, c, x, y, w, 150)
    y = y + 150 + 12

    y = LBX.toolbar(dl, c, x, y, w)
    local q = ((LBX.search.v or ""):lower():gsub("^%s+", ""):gsub("%s+$", ""))
    local view = LBX.view(pr, LBX.server, q)
    local cap
    if q ~= "" or LBX.server then
        cap = S.found .. formatNumber(#view.items) .. S.of .. formatNumber(view.total)
    else
        cap = S.players .. formatNumber(pr.total)
    end
    dl:AddText(P(x + 4, y + 5), C.mute, cap)
    if view.myPos then
        local lbl = fa.ICON_USER .. "  " .. S.jump
        local pw = imgui.CalcTextSize(lbl).x + 24
        local px0 = x + w - pw
        imgui.SetCursorScreenPos(P(px0, y))
        local clicked = imgui.InvisibleButton("##lbx_jump", imgui.ImVec2(pw, 26))
        local hv = imgui.IsItemHovered()
        local a = rhAnim("lbx_jump", hv and 1 or 0)
        dl:AddRectFilled(P(px0, y), P(px0 + pw, y + 26), rhAlpha(ACC, 0.10 + 0.10 * a), 13)
        dl:AddRect(P(px0, y), P(px0 + pw, y + 26), rhAlpha(ACC, 0.45 + 0.4 * a), 13, 15, 1.0)
        dl:AddText(P(px0 + 12, y + (26 - th) / 2), ACC, lbl)
        if clicked then LBX.jumpTo = true end
    end
    y = y + 34

    if view.q == "" and #view.items > 0 then
        c.podY = y
        y = y + 150 + 12
    end
    finish(LBX.list(dl, c, x, y, w, view))
end

function LBX.refreshBtn(dl, x, y, s, loading, col, bg, brd)
    local P = imgui.ImVec2
    imgui.SetCursorScreenPos(P(x, y))
    local clicked = imgui.InvisibleButton("##lbx_refresh", imgui.ImVec2(s, s))
    local hv = imgui.IsItemHovered()
    local a = rhAnim("lbx_refresh", hv and 1 or 0)
    rhCardBox(dl, x, y, s, s, rhLerpColor(bg, rhLerpColor(bg, 0xFFFFFFFF, 0.06), a), rhLerpColor(brd, col, 0.6 * a), 12)
    if loading then
        LBX.spinner(dl, x + s / 2, y + s / 2, 8, col)
    else
        local sz = imgui.CalcTextSize(fa.ICON_REFRESH)
        dl:AddText(P(x + (s - sz.x) / 2, y + (s - sz.y) / 2), rhLerpColor(0xFF9A9A9A, col, a), fa.ICON_REFRESH)
    end
    if hv then rhTip(LBX.S().refresh) end
    return clicked and not loading
end

function drawLeaderboardTab()
    local ok, err = pcall(LBX.draw)
    if not ok then
        print("ResHelper: ошибка в разделе рейтинга: " .. tostring(err))
        imgui.TextColored(imgui.ImVec4(1.0, 0.5, 0.2, 1), u8("Ошибка в разделе рейтинга, подробности в moonloader.log"))
    end
end

function imgui.AutoAdCard(idx, ad, winW)
    local width = imgui.GetWindowWidth() - 30
    local isAdCmd = (AUTO_AD_CHATS[ad.chatIdx + 1] == "/ad")
    local baseHeight = 108
    local multiLineRowH = 84
    local multiExtraHeight = 0
    if ad.multiEnabled then
        multiExtraHeight = 80
        for j = 1, #ad.multiLines do
            if j == #ad.multiLines then
                multiExtraHeight = multiExtraHeight + 50 
            else
                multiExtraHeight = multiExtraHeight + multiLineRowH
            end
        end
    end
    local height = baseHeight + multiExtraHeight
    local drawList = imgui.GetWindowDrawList()
    local pos = imgui.GetCursorScreenPos()
    local cardBg, cardBorder, cardIcon
    if useCustomTheme then
        cardBg = imVec4ToHex(CUSTOM_THEME.cardBg)
        cardBorder = imVec4ToHex(CUSTOM_THEME.cardBorder)
        cardIcon = imVec4ToHex(CUSTOM_THEME.cardBtnText)
    else
        cardBg = 0xFF1A1A1A
        cardBorder = 0xFF333333
        cardIcon = 0xFFFFFFFF
    end
    imgui.PushStyleVar(imgui.StyleVar.FrameRounding, 6)
    imgui.PushStyleVar(imgui.StyleVar.FramePadding, imgui.ImVec2(10, 6))
    local vcIn = rhVc()
    imgui.PushStyleColor(imgui.Col.FrameBg, vcIn and imgui.ImVec4(0.31, 0.49, 0.71, 1) or imgui.ImVec4(0.17, 0.17, 0.17, 1))
    imgui.PushStyleColor(imgui.Col.FrameBgHovered, vcIn and imgui.ImVec4(0.38, 0.57, 0.80, 1) or imgui.ImVec4(0.22, 0.22, 0.22, 1))
    imgui.PushStyleColor(imgui.Col.FrameBgActive, vcIn and imgui.ImVec4(0.66, 0.44, 0.65, 0.9) or imgui.ImVec4(0.10, 0.32, 0.20, 0.7))
    imgui.PushStyleColor(imgui.Col.Border, vcIn and imgui.ImVec4(0.61, 0.77, 0.93, 0.9) or imgui.ImVec4(0.32, 0.32, 0.32, 0.9))
    imgui.PushStyleColor(imgui.Col.PopupBg, vcIn and imgui.ImVec4(0.20, 0.36, 0.56, 0.98) or imgui.ImVec4(0.09, 0.09, 0.09, 0.98))
    local accentColor = ad.active and 0xFF33CC66 or 0xFF555555
    drawList:AddRectFilled(imgui.ImVec2(pos.x, pos.y), imgui.ImVec2(pos.x + width, pos.y + height), cardBg, 10)
    drawList:AddRect(imgui.ImVec2(pos.x, pos.y), imgui.ImVec2(pos.x + width, pos.y + height), cardBorder, 10, 15, 1.0)
    drawList:PushClipRect(imgui.ImVec2(pos.x, pos.y), imgui.ImVec2(pos.x + 5, pos.y + height), true)
    drawList:AddRectFilled(imgui.ImVec2(pos.x, pos.y), imgui.ImVec2(pos.x + width, pos.y + height), accentColor, 10)
    drawList:PopClipRect()
    local remaining = math.max(0, math.floor((ad.nextSend or 0) - os.time()))
    local statusStr = ad.active and u8("Активно") or u8("Неактивно")
    local statusColor = ad.active and 0xFF33CC66 or 0xFF888888
    local statusTextW = imgui.CalcTextSize(statusStr).x
    local pillW = statusTextW + 26
    local pillBg = ad.active and 0x2833CC66 or 0x20FFFFFF
    drawList:AddRectFilled(imgui.ImVec2(pos.x + 14, pos.y + 10), imgui.ImVec2(pos.x + 14 + pillW, pos.y + 30), pillBg, 10)
    drawList:AddCircleFilled(imgui.ImVec2(pos.x + 26, pos.y + 20), 3.5, statusColor)
    drawList:AddText(imgui.ImVec2(pos.x + 34, pos.y + 13), statusColor, statusStr)
    imgui.SetCursorScreenPos(imgui.ImVec2(pos.x + 14, pos.y + 10))
    if imgui.InvisibleButton("##autoad_toggle_" .. idx, imgui.ImVec2(pillW, 20)) then
        toggleAutoAd(ad)
    end
    if imgui.IsItemHovered() then rhTip(u8("Нажмите, чтобы запустить/остановить")) end
    local countStr = u8("Через " .. remaining .. " сек.")
    drawList:AddText(imgui.ImVec2(pos.x + 24 + pillW, pos.y + 13), 0xFF888888, countStr)
    local resetBtnW, resetBtnH = 20, 20
    local resetBtnPos = imgui.ImVec2(pos.x + width - 30, pos.y + 8)
    local resetHovered = imgui.IsMouseHoveringRect(resetBtnPos, imgui.ImVec2(resetBtnPos.x + resetBtnW, resetBtnPos.y + resetBtnH), false)
    drawList:AddText(imgui.ImVec2(resetBtnPos.x + 2, resetBtnPos.y + 1), resetHovered and 0xFF4A4AE0 or 0xFF888888, fa.ICON_REFRESH)
    imgui.SetCursorScreenPos(resetBtnPos)
    if imgui.InvisibleButton("##autoad_resetcd_" .. idx, imgui.ImVec2(resetBtnW, resetBtnH)) then
        ad.nextSend = os.time()
        ad.active = false
        saveAutoAdConfig()
    end
    if imgui.IsItemHovered() then rhTip(u8("Сбросить КД (отправка на следующем тике)")) end
    local multiBtnW, multiBtnH = 20, 20
    local multiBtnPos = imgui.ImVec2(pos.x + width - 56, pos.y + 8)
    local multiHovered = imgui.IsMouseHoveringRect(multiBtnPos, imgui.ImVec2(multiBtnPos.x + multiBtnW, multiBtnPos.y + multiBtnH), false)
    local multiColor = ad.multiEnabled and 0xFF33CC66 or (multiHovered and 0xFF4A4AE0 or 0xFF888888)
    drawList:AddText(imgui.ImVec2(multiBtnPos.x + 1, multiBtnPos.y + 1), multiColor, fa.ICON_LIST)
    imgui.SetCursorScreenPos(multiBtnPos)
    if imgui.InvisibleButton("##autoad_multiline_" .. idx, imgui.ImVec2(multiBtnW, multiBtnH)) then
        ad.multiEnabled = not ad.multiEnabled
        if ad.multiEnabled and #ad.multiLines == 0 then
            local seedLine = { textBuf = imgui.ImBuffer(500), delayBuf = imgui.ImInt(ad.intervalBuf.v or 30) }
            seedLine.textBuf.v = ad.textBuf.v
            table.insert(ad.multiLines, seedLine)
        end
        saveAutoAdConfig()
    end
    if imgui.IsItemHovered() then rhTip(u8("Отправка в несколько строк")) end
    drawList:AddLine(imgui.ImVec2(pos.x + 12, pos.y + 34), imgui.ImVec2(pos.x + width - 12, pos.y + 34), 0x14FFFFFF, 1.0)
    imgui.SetCursorScreenPos(imgui.ImVec2(pos.x + 10, pos.y + 42))
    if ad.multiEnabled then
        imgui.PushItemWidth(width - 140)
        if imgui.InputText("##autoad_text_" .. idx, ad.textBuf) then saveAutoAdConfig() end
        imgui.PopItemWidth()
        if imgui.IsItemHovered() then rhTip(u8("Название бинда (в чат не отправляется, только для удобства)")) end
    else
        imgui.PushItemWidth(width - 140 - 34)
        if imgui.InputText("##autoad_text_" .. idx, ad.textBuf) then saveAutoAdConfig() end
        imgui.PopItemWidth()
        imgui.SameLine()
        local addBtnPos = imgui.GetCursorScreenPos()
        local addBtnW, addBtnH = 30, 22
        local addHovered = imgui.IsMouseHoveringRect(addBtnPos, imgui.ImVec2(addBtnPos.x + addBtnW, addBtnPos.y + addBtnH), false)
        local addBg = addHovered and 0xFF22223A or (useCustomTheme and imVec4ToHex(CUSTOM_THEME.cardBtnBg) or 0xFF202020)
        local addIconCol = addHovered and 0xFF4A4AE0 or cardIcon
        drawList:AddRectFilled(addBtnPos, imgui.ImVec2(addBtnPos.x + addBtnW, addBtnPos.y + addBtnH), addBg, 6)
        local addIconSz = imgui.CalcTextSize(fa.ICON_SEARCH)
        drawList:AddText(imgui.ImVec2(addBtnPos.x + (addBtnW - addIconSz.x) / 2, addBtnPos.y + (addBtnH - addIconSz.y) / 2), addIconCol, fa.ICON_SEARCH)
        imgui.SetCursorScreenPos(addBtnPos)
        if imgui.InvisibleButton("##autoad_item_" .. idx, imgui.ImVec2(addBtnW, addBtnH)) then
            itemPickerTargetAd = ad
            itemPickerSearchBuf.v = ""
            itemPickerOpen = true
            itemPickerAnchor = imgui.ImVec2(addBtnPos.x, addBtnPos.y + addBtnH + 4)
        end
        if imgui.IsItemHovered() then rhTip(u8("Вставить предмет :itemN:")) end
    end
    imgui.SetCursorScreenPos(imgui.ImVec2(pos.x + width - 110, pos.y + 42))
    imgui.PushItemWidth(50)
    if imgui.InputInt("##autoad_interval_" .. idx, ad.intervalBuf, 0, 0) then
        if ad.intervalBuf.v < 5 then ad.intervalBuf.v = 5 end
        if ad.active then
            if autoAdConfig.saveDelay then
                ad.nextSend = (ad.lastSend or os.time()) + ad.intervalBuf.v
            else
                ad.lastSend = os.time()
                ad.nextSend = os.time() + ad.intervalBuf.v
            end
        end
        saveAutoAdConfig()
    end
    imgui.PopItemWidth()
    imgui.SameLine()
    imgui.Text(u8("сек."))
    local commandRowY = pos.y + 72
    if ad.multiEnabled then
        local mY = pos.y + 72
        drawList:AddLine(imgui.ImVec2(pos.x + 12, mY), imgui.ImVec2(pos.x + width - 12, mY), 0x14FFFFFF, 1.0)
        imgui.SetCursorScreenPos(imgui.ImVec2(pos.x + 10, mY + 10))
        imgui.Text(u8("Отправка в несколько строк"))
        local rowY = mY + 34
        local toDeleteLine = nil
        for j, line in ipairs(ad.multiLines) do
            local isLastLine = (j == #ad.multiLines)
            imgui.SetCursorScreenPos(imgui.ImVec2(pos.x + 10, rowY))
            imgui.Text(u8("Строка " .. j .. ":"))
            rowY = rowY + 20
            imgui.SetCursorScreenPos(imgui.ImVec2(pos.x + 10, rowY))
            imgui.PushItemWidth(width - 70)
            if imgui.InputText("##autoad_multi_text_" .. idx .. "_" .. j, line.textBuf) then saveAutoAdConfig() end
            imgui.PopItemWidth()
            imgui.SameLine()
            imgui.PushID("multiline_trash_" .. idx .. "_" .. j)
            if StyleButton(fa.ICON_TRASH, nil, 26) then toDeleteLine = j end
            imgui.PopID()
            rowY = rowY + 30
            if not isLastLine then
                imgui.SetCursorScreenPos(imgui.ImVec2(pos.x + 10, rowY))
                imgui.PushItemWidth(70)
                if imgui.InputInt("##autoad_multi_delay_" .. idx .. "_" .. j, line.delayBuf, 0, 0) then
                    if line.delayBuf.v < 2 then line.delayBuf.v = 2 end
                    saveAutoAdConfig()
                end
                imgui.PopItemWidth()
                imgui.SameLine()
                imgui.Text(u8("сек. до след. строки"))
                rowY = rowY + 34
            end
        end
        if toDeleteLine then
            table.remove(ad.multiLines, toDeleteLine)
            if ad.multiIdx > #ad.multiLines then ad.multiIdx = 1 end
            saveAutoAdConfig()
        end
        imgui.SetCursorScreenPos(imgui.ImVec2(pos.x + 10, rowY))
        if StyleButton(fa.ICON_PLUS .. u8("  Добавить строку"), nil, width - 20) then
            table.insert(ad.multiLines, {textBuf = imgui.ImBuffer(500), delayBuf = imgui.ImInt(ad.intervalBuf.v or 30)})
            saveAutoAdConfig()
        end
        rowY = rowY + 34
        drawList:AddLine(imgui.ImVec2(pos.x + 12, rowY), imgui.ImVec2(pos.x + width - 12, rowY), 0x14FFFFFF, 1.0)
        commandRowY = rowY + 12
    end
    imgui.SetCursorScreenPos(imgui.ImVec2(pos.x + 10, commandRowY))
    imgui.PushItemWidth(90)
    local chatItems = table.concat(AUTO_AD_CHATS, "\0") .. "\0"
    local chatIdxBuf = imgui.ImInt(ad.chatIdx)
    if imgui.Combo("##autoad_chat_" .. idx, chatIdxBuf, chatItems) then
        ad.chatIdx = chatIdxBuf.v
        saveAutoAdConfig()
    end
    imgui.PopItemWidth()
    if AUTO_AD_CHATS[ad.chatIdx + 1] == "/vr" then
        imgui.SameLine()
        local vrAdBool = imgui.ImBool(ad.vrWithAd)
        if imgui.Checkbox(u8("Отправлять с рекламой##autoad_vrad_" .. idx), vrAdBool) then
            ad.vrWithAd = vrAdBool.v
            saveAutoAdConfig()
        end
        if imgui.IsItemHovered() then rhTip(u8("В диалоге /vr автоматически нажмётся \"Да\", окно не покажется")) end
    end
    if isAdCmd then
        imgui.SameLine()
        imgui.PushItemWidth(145)
        local radioItems = u8("Автоматически\0Los Santos\0Las Venturas\0San Fierro\0")
        local radioIdxBuf = imgui.ImInt(ad.adRadioIdx or 0)
        if imgui.Combo("##autoad_radio_" .. idx, radioIdxBuf, radioItems) then
            ad.adRadioIdx = radioIdxBuf.v
            saveAutoAdConfig()
        end
        imgui.PopItemWidth()
        if imgui.IsItemHovered() then rhTip(u8("Выберите радио-станцию куда будет отправляться авто-реклама.\nЕсли выбрано \"Автоматически\", сообщения будут попадать в радио-станцию где больший актив.")) end
        imgui.SameLine()
        local vipBool = imgui.ImBool(ad.adVip or false)
        if imgui.Checkbox(u8("VIP##autoad_vip_" .. idx), vipBool) then
            ad.adVip = vipBool.v
            saveAutoAdConfig()
        end
        if imgui.IsItemHovered() then rhTip(u8("VIP объявление")) end
        imgui.SameLine()
        local resendBool = imgui.ImBool(ad.adResendEnabled or false)
        if imgui.Checkbox(u8("Повтор##autoad_resend_" .. idx), resendBool) then
            ad.adResendEnabled = resendBool.v
            saveAutoAdConfig()
        end
        if imgui.IsItemHovered() then rhTip(u8("Повторная отправка")) end
        if ad.adResendEnabled then
            imgui.SameLine()
            imgui.PushItemWidth(32)
            if imgui.InputInt("##autoad_resend_sec_" .. idx, ad.adResendSecBuf, 0, 0) then
                if ad.adResendSecBuf.v < 5 then ad.adResendSecBuf.v = 5 end
                saveAutoAdConfig()
            end
            imgui.PopItemWidth()
            imgui.SameLine()
            imgui.Text(u8("сек."))
        end
    end
    local delX = pos.x + width - 40
    local delY = commandRowY - 2
    local delHovered = (imgui.GetMousePos().x >= delX and imgui.GetMousePos().x <= delX + 30 and
                        imgui.GetMousePos().y >= delY and imgui.GetMousePos().y <= delY + 28)
    local delBg = delHovered and 0xFF22223A or (useCustomTheme and imVec4ToHex(CUSTOM_THEME.cardBtnBg) or 0xFF202020)
    local delIconCol = delHovered and 0xFF4A4AE0 or cardIcon
    drawList:AddRectFilled(imgui.ImVec2(delX, delY), imgui.ImVec2(delX + 30, delY + 28), delBg, 8)
    local delIconW = imgui.CalcTextSize(fa.ICON_TRASH).x
    local delIconH = imgui.CalcTextSize(fa.ICON_TRASH).y
    drawList:AddText(imgui.ImVec2(delX + (30 - delIconW) / 2, delY + (28 - delIconH) / 2), delIconCol, fa.ICON_TRASH)
    imgui.SetCursorScreenPos(imgui.ImVec2(delX, delY))
    local deleted = false
    if imgui.InvisibleButton("##autoad_del_" .. idx, imgui.ImVec2(30, 28)) then
        deleted = true
    end
    imgui.PopStyleColor(5)
    imgui.PopStyleVar(2)
    imgui.SetCursorScreenPos(imgui.ImVec2(pos.x, pos.y + height + 8))
    imgui.Dummy(imgui.ImVec2(width, 0))
    return deleted
end
function drawFuncHubTab()
    drawHubTiles("func", {
        {title = u8("Биндер"), desc = u8("Горячие клавиши для быстрых действий"), icon = fa.ICON_KEYBOARD_O, accent = 0xFF1AE591, tab = 9},
        {title = u8("Автопиар"), desc = u8("Автоматическая отправка объявлений в чат"), icon = fa.ICON_BULLHORN, accent = 0xFF28AAFF, tab = 14},
        {title = u8("Фильтр чата"), desc = u8("Скрыть сообщения по словам или никам"), icon = fa.ICON_FILTER, accent = 0xFFFA8BA7, tab = 15},
    })
end
function drawAutoAdTab()
    local drawList = imgui.GetWindowDrawList()
    local listW = imgui.GetWindowWidth() - 25
    if StyleButton(fa.ICON_PLUS .. u8("  Новое объявление"), nil, nil, true) then
        local newAd = {
            chatIdx = 0, active = false, vrWithAd = false,
            adRadioIdx = 0, adVip = false, adResendEnabled = false,
            nextSend = 0,
            lastSend = os.time(),
            textBuf = imgui.ImBuffer(500),
            intervalBuf = imgui.ImInt(300),
            adResendSecBuf = imgui.ImInt(35),
            multiEnabled = false,
            multiIdx = 1,
            multiLines = {},
        }
        table.insert(autoAdConfig.ads, newAd)
        saveAutoAdConfig()
    end
    imgui.Spacing(); imgui.Spacing()
    local activeCount = 0
    for _, ad in ipairs(autoAdConfig.ads) do if ad.active then activeCount = activeCount + 1 end end
    local statPos = imgui.GetCursorScreenPos()
    local statW = listW
    local statH = 52
    drawList:AddRectFilled(statPos, imgui.ImVec2(statPos.x + statW, statPos.y + statH), 0xFF1A1A1A, 8)
    drawList:AddRect(statPos, imgui.ImVec2(statPos.x + statW, statPos.y + statH), 0xFF333333, 8, 15, 1.0)
    drawList:PushClipRect(statPos, imgui.ImVec2(statPos.x + 5, statPos.y + statH), true)
    drawList:AddRectFilled(statPos, imgui.ImVec2(statPos.x + statW, statPos.y + statH), 0xFF1AE591, 8)
    drawList:PopClipRect()
    local badgeSize = 30
    local badgeX, badgeY = statPos.x + 14, statPos.y + (statH - badgeSize) / 2
    drawList:AddRectFilled(imgui.ImVec2(badgeX, badgeY), imgui.ImVec2(badgeX + badgeSize, badgeY + badgeSize), 0xFF1E3D1E, 7)
    local statIconSz = imgui.CalcTextSize(fa.ICON_BELL)
    drawList:AddText(imgui.ImVec2(badgeX + (badgeSize - statIconSz.x) / 2, badgeY + (badgeSize - statIconSz.y) / 2), 0xFF1AE591, fa.ICON_BELL)
    local statTitleX = badgeX + badgeSize + 12
    drawList:AddText(imgui.ImVec2(statTitleX, statPos.y + 10), 0xFFFFFFFF, u8("Работает прямо сейчас"))
    drawList:AddText(imgui.ImVec2(statTitleX, statPos.y + 30), 0xFF888888, u8("Запущено объявлений из общего числа"))
    local countText = u8(activeCount .. " / " .. #autoAdConfig.ads)
    local countSz = imgui.CalcTextSize(countText)
    local pillW = countSz.x + 24
    local pillX = statPos.x + statW - pillW - 14
    local pillY = statPos.y + (statH - 26) / 2
    drawList:AddRectFilled(imgui.ImVec2(pillX, pillY), imgui.ImVec2(pillX + pillW, pillY + 26), 0xFF1E3D1E, 13)
    drawList:AddText(imgui.ImVec2(pillX + (pillW - countSz.x) / 2, pillY + (26 - countSz.y) / 2), 0xFF33CC66, countText)
    imgui.SetCursorScreenPos(imgui.ImVec2(statPos.x, statPos.y + statH + 10))
    imgui.Dummy(imgui.ImVec2(statW, 0))
    local togglePos = imgui.GetCursorScreenPos()
    local toggleW = statW
    local toggleH = 40
    drawList:AddRectFilled(togglePos, imgui.ImVec2(togglePos.x + toggleW, togglePos.y + toggleH), 0xFF1A1A1A, 8)
    drawList:AddRect(togglePos, imgui.ImVec2(togglePos.x + toggleW, togglePos.y + toggleH), 0xFF333333, 8, 15, 1.0)
    drawList:AddText(imgui.ImVec2(togglePos.x + 14, togglePos.y + 12), 0xFFCCCCCC, u8("Не сбрасывать таймер при перезаходе"))
    local switchW, switchH = 38, 20
    local switchX = togglePos.x + toggleW - switchW - 14
    local switchY = togglePos.y + (toggleH - switchH) / 2
    local switchOn = autoAdConfig.saveDelay
    local switchBg = switchOn and 0xFF1AE591 or 0xFF3A3A3A
    drawList:AddRectFilled(imgui.ImVec2(switchX, switchY), imgui.ImVec2(switchX + switchW, switchY + switchH), switchBg, switchH / 2)
    local knobR = switchH / 2 - 2
    local knobX = switchOn and (switchX + switchW - knobR - 2) or (switchX + knobR + 2)
    drawList:AddCircleFilled(imgui.ImVec2(knobX, switchY + switchH / 2), knobR, 0xFFFFFFFF, 16)
    imgui.SetCursorScreenPos(togglePos)
    if imgui.InvisibleButton("##autoad_savedelay_toggle", imgui.ImVec2(toggleW, toggleH)) then
        autoAdConfig.saveDelay = not autoAdConfig.saveDelay
        saveAutoAdConfig()
    end
    imgui.SetCursorScreenPos(imgui.ImVec2(togglePos.x, togglePos.y + toggleH + 14))
    imgui.Dummy(imgui.ImVec2(toggleW, 0))
    imgui.Text(fa.ICON_LIST .. u8("  Твои объявления"))
    imgui.Spacing()
    if #autoAdConfig.ads == 0 then
        imgui.Text(u8("Список пуст. Добавьте авто-рекламу!"))
    end
    local toDelete = nil
    local winW = imgui.GetWindowWidth()
    for i, ad in ipairs(autoAdConfig.ads) do
        imgui.PushID("autoad_card_" .. i)
        if imgui.AutoAdCard(i, ad, winW) then toDelete = i end
        imgui.PopID()
    end
    if toDelete then
        table.remove(autoAdConfig.ads, toDelete)
        saveAutoAdConfig()
    end
end
function drawItemPickerCard()
    if not itemPickerOpen then return end
    local cardW, cardH = 280, 300
    local cardX, cardY = itemPickerAnchor.x, itemPickerAnchor.y
    imgui.SetNextWindowPos(imgui.ImVec2(cardX, cardY), imgui.Cond.Always)
    imgui.SetNextWindowSize(imgui.ImVec2(cardW, cardH), imgui.Cond.Always)
    imgui.PushStyleVar(imgui.StyleVar.WindowPadding, imgui.ImVec2(12, 12))
    imgui.PushStyleVar(imgui.StyleVar.WindowRounding, 10)
    imgui.Begin(u8("##item_picker_card"), nil, imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar)
    local winPos = imgui.GetWindowPos()
    local drawList = imgui.GetWindowDrawList()
    if imgui.IsMouseClicked(0) and not imgui.IsMouseHoveringRect(winPos, imgui.ImVec2(winPos.x + cardW, winPos.y + cardH), false) then
        itemPickerOpen = false
    end
    local cX, cY = winPos.x, winPos.y
    drawList:AddRectFilled(imgui.ImVec2(cX + 3, cY + 3), imgui.ImVec2(cX + cardW + 3, cY + cardH + 3), 0x55000000, 10)
    drawList:AddRectFilled(imgui.ImVec2(cX, cY), imgui.ImVec2(cX + cardW, cY + cardH), 0xFF181818, 10)
    drawList:AddRect(imgui.ImVec2(cX, cY), imgui.ImVec2(cX + cardW, cY + cardH), 0xFF2E2E2E, 10, 15, 1.0)
    imgui.Text(u8("Поиск предмета:"))
    imgui.PushItemWidth(cardW - 24)
    if imgui.IsWindowAppearing() then imgui.SetKeyboardFocusHere() end
    imgui.InputText("##itemPickerSearch", itemPickerSearchBuf)
    imgui.PopItemWidth()
    imgui.Separator()
    imgui.BeginChild("##itemPickerList", imgui.ImVec2(cardW - 24, cardH - 70))
    local query = cp1251Lower(encoding.UTF8:decode(itemPickerSearchBuf.v))
    if query == "" then
        imgui.TextDisabled(u8("Введите название предмета для поиска."))
    else
        local shown = 0
        for _, item in ipairs(itemsDBList) do
            if shown >= 300 then break end
            if item.nameLower:find(query, 1, true) then
                if imgui.Selectable(u8(item.name .. " (" .. item.id .. ")") .. "##item_" .. item.id) then
                    if itemPickerTargetAd then
                        local sep = (#itemPickerTargetAd.textBuf.v > 0) and " " or ""
                        itemPickerTargetAd.textBuf.v = itemPickerTargetAd.textBuf.v .. sep .. ":item" .. item.id .. ":"
                        saveAutoAdConfig()
                    end
                    itemPickerOpen = false
                end
                shown = shown + 1
            end
        end
        if shown == 0 then
            imgui.TextDisabled(u8("Ничего не найдено"))
        end
    end
    imgui.EndChild()
    imgui.End()
    imgui.PopStyleVar(2)
end
function imgui.ChatFilterCard(idx, entry, winW)
    local width = imgui.GetWindowWidth() - 30
    local height = 84
    local drawList = imgui.GetWindowDrawList()
    local pos = imgui.GetCursorScreenPos()
    local cardBg, cardBorder, cardIcon
    if useCustomTheme then
        cardBg = imVec4ToHex(CUSTOM_THEME.cardBg)
        cardBorder = imVec4ToHex(CUSTOM_THEME.cardBorder)
        cardIcon = imVec4ToHex(CUSTOM_THEME.cardBtnText)
    else
        cardBg = 0xFF1A1A1A
        cardBorder = 0xFF333333
        cardIcon = 0xFFFFFFFF
    end
    local modeLabels = {strict = u8("Жёсткий"), standard = u8("Стандартный"), nick = u8("Ник")}
    local modeColors = {strict = 0xFFE55A5A, standard = 0xFF3399FF, nick = 0xFFFFB84D}
    local modePillBg = {strict = 0x28E55A5A, standard = 0x283399FF, nick = 0x28FFB84D}
    local modeOrder = {"strict", "standard", "nick"}
    local mode = entry.mode or "strict"
    local isOn = entry.enabled ~= false
    imgui.PushStyleVar(imgui.StyleVar.FrameRounding, 6)
    imgui.PushStyleVar(imgui.StyleVar.FramePadding, imgui.ImVec2(10, 6))
    local vcIn = rhIsVice() and not useCustomTheme
    imgui.PushStyleColor(imgui.Col.FrameBg, vcIn and imgui.ImVec4(0.31, 0.49, 0.71, 1) or imgui.ImVec4(0.17, 0.17, 0.17, 1))
    imgui.PushStyleColor(imgui.Col.FrameBgHovered, vcIn and imgui.ImVec4(0.38, 0.57, 0.80, 1) or imgui.ImVec4(0.22, 0.22, 0.22, 1))
    imgui.PushStyleColor(imgui.Col.FrameBgActive, vcIn and imgui.ImVec4(0.66, 0.44, 0.65, 0.9) or imgui.ImVec4(0.10, 0.32, 0.20, 0.7))
    imgui.PushStyleColor(imgui.Col.Border, vcIn and imgui.ImVec4(0.61, 0.77, 0.93, 0.9) or imgui.ImVec4(0.32, 0.32, 0.32, 0.9))
    imgui.PushStyleColor(imgui.Col.PopupBg, vcIn and imgui.ImVec4(0.20, 0.36, 0.56, 0.98) or imgui.ImVec4(0.09, 0.09, 0.09, 0.98))
    local accentColor = isOn and modeColors[mode] or 0xFF555555
    drawList:AddRectFilled(imgui.ImVec2(pos.x, pos.y), imgui.ImVec2(pos.x + width, pos.y + height), cardBg, 10)
    drawList:AddRect(imgui.ImVec2(pos.x, pos.y), imgui.ImVec2(pos.x + width, pos.y + height), cardBorder, 10, 15, 1.0)
    drawList:PushClipRect(imgui.ImVec2(pos.x, pos.y), imgui.ImVec2(pos.x + 5, pos.y + height), true)
    drawList:AddRectFilled(imgui.ImVec2(pos.x, pos.y), imgui.ImVec2(pos.x + width, pos.y + height), accentColor, 10)
    drawList:PopClipRect()
    local modeStr = modeLabels[mode]
    local modeColor = isOn and modeColors[mode] or 0xFF888888
    local modeTextW = imgui.CalcTextSize(modeStr).x
    local pillW = modeTextW + 26
    local pillBg = isOn and modePillBg[mode] or 0x20FFFFFF
    drawList:AddRectFilled(imgui.ImVec2(pos.x + 14, pos.y + 10), imgui.ImVec2(pos.x + 14 + pillW, pos.y + 30), pillBg, 10)
    drawList:AddCircleFilled(imgui.ImVec2(pos.x + 26, pos.y + 20), 3.5, modeColor)
    drawList:AddText(imgui.ImVec2(pos.x + 34, pos.y + 13), modeColor, modeStr)
    imgui.SetCursorScreenPos(imgui.ImVec2(pos.x + 14, pos.y + 10))
    if imgui.InvisibleButton("##chatfilter_mode_" .. idx, imgui.ImVec2(pillW, 20)) then
        local curIdx = 1
        for k, v in ipairs(modeOrder) do if v == mode then curIdx = k end end
        entry.mode = modeOrder[curIdx % #modeOrder + 1]
        saveChatFilterConfig()
    end
    if imgui.IsItemHovered() then
        rhTip(u8("Нажми, чтобы переключить режим.\nЖёсткий: убирает сообщение, если текст встречается в любом месте строки.\nСтандартный: убирает сообщение, только если оно совпадает с текстом полностью.\nНик: убирает все сообщения от игрока с указанным ником."))
    end
    local switchW, switchH = 34, 18
    local switchX = pos.x + width - switchW - 44
    local switchY = pos.y + 11
    local switchBg = isOn and 0xFF1AE591 or 0xFF3A3A3A
    drawList:AddRectFilled(imgui.ImVec2(switchX, switchY), imgui.ImVec2(switchX + switchW, switchY + switchH), switchBg, switchH / 2)
    local knobR = switchH / 2 - 2
    local knobX = isOn and (switchX + switchW - knobR - 2) or (switchX + knobR + 2)
    drawList:AddCircleFilled(imgui.ImVec2(knobX, switchY + switchH / 2), knobR, 0xFFFFFFFF, 16)
    imgui.SetCursorScreenPos(imgui.ImVec2(switchX, switchY))
    if imgui.InvisibleButton("##chatfilter_toggle_" .. idx, imgui.ImVec2(switchW, switchH)) then
        entry.enabled = not isOn
        saveChatFilterConfig()
    end
    if imgui.IsItemHovered() then rhTip(u8("Включить/выключить этот фильтр")) end
    imgui.SetCursorScreenPos(imgui.ImVec2(pos.x + 10, pos.y + 44))
    imgui.PushItemWidth(width - 60)
    if imgui.InputText("##chatfilter_text_" .. idx, entry.textBuf) then
        entry.text = u8:decode(entry.textBuf.v)
        saveChatFilterConfig()
    end
    imgui.PopItemWidth()
    local delX = pos.x + width - 40
    local delY = pos.y + 8
    local delHovered = (imgui.GetMousePos().x >= delX and imgui.GetMousePos().x <= delX + 30 and
                        imgui.GetMousePos().y >= delY and imgui.GetMousePos().y <= delY + 28)
    local delBg = delHovered and 0xFF22223A or (useCustomTheme and imVec4ToHex(CUSTOM_THEME.cardBtnBg) or 0xFF202020)
    local delIconCol = delHovered and 0xFF4A4AE0 or cardIcon
    drawList:AddRectFilled(imgui.ImVec2(delX, delY), imgui.ImVec2(delX + 30, delY + 28), delBg, 8)
    local delIconW = imgui.CalcTextSize(fa.ICON_TRASH).x
    local delIconH = imgui.CalcTextSize(fa.ICON_TRASH).y
    drawList:AddText(imgui.ImVec2(delX + (30 - delIconW) / 2, delY + (28 - delIconH) / 2), delIconCol, fa.ICON_TRASH)
    imgui.SetCursorScreenPos(imgui.ImVec2(delX, delY))
    local deleted = false
    if imgui.InvisibleButton("##chatfilter_del_" .. idx, imgui.ImVec2(30, 28)) then
        deleted = true
    end
    imgui.PopStyleColor(5)
    imgui.PopStyleVar(2)
    imgui.SetCursorScreenPos(imgui.ImVec2(pos.x, pos.y + height + 8))
    imgui.Dummy(imgui.ImVec2(width, 0))
    return deleted
end
function drawChatFilterTab()
    local drawList = imgui.GetWindowDrawList()
    local listW = imgui.GetWindowWidth() - 25
    if StyleButton(fa.ICON_PLUS .. u8("  Добавить фильтр"), nil, nil, true) then
        table.insert(chatFilterConfig.filters, {
            text = "",
            mode = "strict",
            enabled = true,
            textBuf = imgui.ImBuffer(300),
        })
        saveChatFilterConfig()
    end
    imgui.Spacing(); imgui.Spacing()
    local statPos = imgui.GetCursorScreenPos()
    local statW = listW
    local statH = 52
    local statAccent = chatFilterConfig.enabled and 0xFF1AE591 or 0xFF555555
    drawList:AddRectFilled(statPos, imgui.ImVec2(statPos.x + statW, statPos.y + statH), 0xFF1A1A1A, 8)
    drawList:AddRect(statPos, imgui.ImVec2(statPos.x + statW, statPos.y + statH), 0xFF333333, 8, 15, 1.0)
    drawList:PushClipRect(statPos, imgui.ImVec2(statPos.x + 5, statPos.y + statH), true)
    drawList:AddRectFilled(statPos, imgui.ImVec2(statPos.x + statW, statPos.y + statH), statAccent, 8)
    drawList:PopClipRect()
    local badgeSize = 30
    local badgeX, badgeY = statPos.x + 14, statPos.y + (statH - badgeSize) / 2
    local badgeBg = chatFilterConfig.enabled and 0xFF1E3D1E or 0xFF2A2A2A
    drawList:AddRectFilled(imgui.ImVec2(badgeX, badgeY), imgui.ImVec2(badgeX + badgeSize, badgeY + badgeSize), badgeBg, 7)
    local statIconSz = imgui.CalcTextSize(fa.ICON_FILTER)
    drawList:AddText(imgui.ImVec2(badgeX + (badgeSize - statIconSz.x) / 2, badgeY + (badgeSize - statIconSz.y) / 2), statAccent, fa.ICON_FILTER)
    local statTitleX = badgeX + badgeSize + 12
    drawList:AddText(imgui.ImVec2(statTitleX, statPos.y + 10), 0xFFFFFFFF, u8("Фильтр чата"))
    local statSub = chatFilterConfig.enabled and u8("Активен, скрывает сообщения по списку") or u8("Выключен")
    drawList:AddText(imgui.ImVec2(statTitleX, statPos.y + 30), 0xFF888888, statSub)
    local activeFilterCount = 0
    for _, entry in ipairs(chatFilterConfig.filters) do
        if entry.enabled ~= false then activeFilterCount = activeFilterCount + 1 end
    end
    local countText = u8(activeFilterCount .. " / " .. #chatFilterConfig.filters)
    local countSz = imgui.CalcTextSize(countText)
    local pillW = countSz.x + 24
    local pillX = statPos.x + statW - pillW - 14
    local pillY = statPos.y + (statH - 26) / 2
    local pillBg = chatFilterConfig.enabled and 0xFF1E3D1E or 0xFF2A2A2A
    local pillCol = chatFilterConfig.enabled and 0xFF33CC66 or 0xFF888888
    drawList:AddRectFilled(imgui.ImVec2(pillX, pillY), imgui.ImVec2(pillX + pillW, pillY + 26), pillBg, 13)
    drawList:AddText(imgui.ImVec2(pillX + (pillW - countSz.x) / 2, pillY + (26 - countSz.y) / 2), pillCol, countText)
    imgui.SetCursorScreenPos(imgui.ImVec2(statPos.x, statPos.y + statH + 10))
    imgui.Dummy(imgui.ImVec2(statW, 0))
    local togglePos = imgui.GetCursorScreenPos()
    local toggleW = statW
    local toggleH = 40
    drawList:AddRectFilled(togglePos, imgui.ImVec2(togglePos.x + toggleW, togglePos.y + toggleH), 0xFF1A1A1A, 8)
    drawList:AddRect(togglePos, imgui.ImVec2(togglePos.x + toggleW, togglePos.y + toggleH), 0xFF333333, 8, 15, 1.0)
    drawList:AddText(imgui.ImVec2(togglePos.x + 14, togglePos.y + 12), 0xFFCCCCCC, u8("Скрывать сообщения по фильтру"))
    local switchW, switchH = 38, 20
    local switchX = togglePos.x + toggleW - switchW - 14
    local switchY = togglePos.y + (toggleH - switchH) / 2
    local switchOn = chatFilterConfig.enabled
    local switchBg = switchOn and 0xFF1AE591 or 0xFF3A3A3A
    drawList:AddRectFilled(imgui.ImVec2(switchX, switchY), imgui.ImVec2(switchX + switchW, switchY + switchH), switchBg, switchH / 2)
    local knobR = switchH / 2 - 2
    local knobX = switchOn and (switchX + switchW - knobR - 2) or (switchX + knobR + 2)
    drawList:AddCircleFilled(imgui.ImVec2(knobX, switchY + switchH / 2), knobR, 0xFFFFFFFF, 16)
    imgui.SetCursorScreenPos(togglePos)
    if imgui.InvisibleButton("##chatfilter_enabled_toggle", imgui.ImVec2(toggleW, toggleH)) then
        chatFilterConfig.enabled = not chatFilterConfig.enabled
        cb_chatFilterEnabled.v = chatFilterConfig.enabled
        saveChatFilterConfig()
    end
    imgui.SetCursorScreenPos(imgui.ImVec2(togglePos.x, togglePos.y + toggleH + 14))
    imgui.Dummy(imgui.ImVec2(toggleW, 0))
    imgui.Text(fa.ICON_LIST .. u8("  Список фильтров"))
    imgui.Spacing()
    if #chatFilterConfig.filters == 0 then
        imgui.Text(u8("Список пуст. Добавьте первый фильтр."))
    end
    local toDeleteCF = nil
    local winW = imgui.GetWindowWidth()
    for i, entry in ipairs(chatFilterConfig.filters) do
        imgui.PushID("chatfilter_card_" .. i)
        if imgui.ChatFilterCard(i, entry, winW) then toDeleteCF = i end
        imgui.PopID()
    end
    if toDeleteCF then
        table.remove(chatFilterConfig.filters, toDeleteCF)
        saveChatFilterConfig()
    end
end
BND = BND or {}
function binderPushInput()
    BND.okB = pcall(function() imgui.PushStyleVar(imgui.StyleVar.FrameBorderSize, 1) end)
    imgui.PushStyleVar(imgui.StyleVar.FrameRounding, 8)
    imgui.PushStyleVar(imgui.StyleVar.FramePadding, imgui.ImVec2(10, 6))
    local vcIn = rhIsVice() and not useCustomTheme
    imgui.PushStyleColor(imgui.Col.FrameBg, vcIn and imgui.ImVec4(0.31, 0.49, 0.71, 1) or imgui.ImVec4(0.115, 0.115, 0.12, 1))
    imgui.PushStyleColor(imgui.Col.FrameBgHovered, vcIn and imgui.ImVec4(0.38, 0.57, 0.80, 1) or imgui.ImVec4(0.14, 0.14, 0.145, 1))
    imgui.PushStyleColor(imgui.Col.FrameBgActive, vcIn and imgui.ImVec4(0.66, 0.44, 0.65, 0.9) or imgui.ImVec4(0.14, 0.17, 0.15, 1))
    imgui.PushStyleColor(imgui.Col.Border, vcIn and imgui.ImVec4(0.61, 0.77, 0.93, 0.6) or imgui.ImVec4(1, 1, 1, 0.07))
end
function binderPopInput()
    imgui.PopStyleColor(4)
    imgui.PopStyleVar(BND.okB and 3 or 2)
end
function binderEditor(title, uid, nameBuf, textBuf, bindRef, okText, onOk)
    local P = imgui.ImVec2
    local C = PD.C
    imgui.PushStyleVar(imgui.StyleVar.WindowRounding, 14)
    imgui.PushStyleVar(imgui.StyleVar.WindowPadding, P(20, 18))
    local open = imgui.BeginPopupModal(title, nil, imgui.WindowFlags.AlwaysAutoResize)
    if not open then
        imgui.PopStyleVar(2)
        return false
    end
    local W = 440
    local dl = imgui.GetWindowDrawList()
    local mute = imgui.ImVec4(0.54, 0.54, 0.54, 1)
    imgui.TextColored(mute, u8("Название"))
    binderPushInput()
    imgui.PushItemWidth(W)
    imgui.InputText("##" .. uid .. "name", nameBuf)
    imgui.PopItemWidth()
    binderPopInput()
    imgui.Spacing()
    imgui.TextColored(mute, u8("Клавиши"))
    binderPushInput()
    local keyChanged = customHotKeyWidget("##" .. uid .. "hotkey", bindRef, 180)
    binderPopInput()
    imgui.Spacing()
    local bg, brd = homeCardColors()
    local cp = imgui.GetCursorScreenPos()
    local hh = 88
    rhCardBox(dl, cp.x, cp.y, W, hh, bg, brd, 10)
    local hints = {
        {"{WAIT-5}", u8(" - задержка 5 сек.")},
        {"{INPUT}", u8(" в конце - ввод без отправки")},
        {"{CMD}", u8(" в конце - команда скрипта")},
        {"{MY_NAME} {MY_ID}", u8(" - ваш ник и ID")},
    }
    for i, hnt in ipairs(hints) do
        local ty = cp.y + 10 + (i - 1) * 18
        dl:AddText(P(cp.x + 14, ty), C.green, hnt[1])
        dl:AddText(P(cp.x + 14 + imgui.CalcTextSize(hnt[1]).x, ty), C.mute, hnt[2])
    end
    imgui.SetCursorScreenPos(P(cp.x, cp.y + hh + 8))
    imgui.Dummy(P(W, 1))
    imgui.TextColored(mute, u8("Текст бинда (каждая строка - отдельное сообщение)"))
    binderPushInput()
    imgui.InputTextMultiline("##" .. uid .. "text", textBuf, P(W, 150))
    binderPopInput()
    imgui.Spacing()
    local bp = imgui.GetCursorScreenPos()
    local gap = 10
    local bw, bh = (W - gap) / 2, 38
    local by = bp.y + 6
    local cancelHot = rhAnim("bnd_cancel_" .. uid, PD.hov(bp.x, by, bw, bh) and 1 or 0)
    local cancel = WK.button(dl, "##" .. uid .. "_cancel", bp.x, by, bw, bh, u8("Отмена"), fa.ICON_TIMES, rhLerpColor(C.mute, 0xFF4646EB, cancelHot), false)
    local ok = WK.button(dl, "##" .. uid .. "_ok", bp.x + bw + gap, by, bw, bh, okText, fa.ICON_CHECK, C.green, true)
    imgui.SetCursorScreenPos(P(bp.x, by + bh))
    imgui.Dummy(P(W, 2))
    if ok then
        if nameBuf.v ~= "" and textBuf.v ~= "" then
            onOk()
            imgui.CloseCurrentPopup()
        else
            sampAddChatMessage(SCRIPT_PREFIX .. "Заполните все поля!", SCRIPT_COLOR)
        end
    end
    if cancel then imgui.CloseCurrentPopup() end
    imgui.EndPopup()
    imgui.PopStyleVar(2)
    return keyChanged
end
function binderParseLines(buf)
    local out = {}
    for line in (u8:decode(buf.v) .. "\n"):gmatch("(.-)\r?\n") do
        if line ~= "" then table.insert(out, line) end
    end
    return out
end
function drawBinderTab()
    local dl = imgui.GetWindowDrawList()
    local P = imgui.ImVec2
    local C = PD.C
    local bg, brd = homeCardColors()
    local cur = imgui.GetCursorScreenPos()
    local x, y = cur.x, cur.y + 4
    local w = imgui.GetWindowWidth() - 25
    local binds = bindDatabase.binds
    local total = #binds
    local sh, btnW = 76, 200
    rhCardBox(dl, x, y, w, sh, bg, brd, 14)
    rhIconBadge(dl, x + 38, y + sh / 2, 20, fa.ICON_KEYBOARD_O, C.green, bg, 0)
    dl:PushClipRect(P(x + 72, y), P(x + w - btnW - 28, y + sh), true)
    dl:AddText(P(x + 72, y + 18), 0xFFFFFFFF, u8("Мои бинды"))
    dl:AddText(P(x + 72, y + 42), C.mute, total > 0 and (u8("Всего: ") .. total .. u8(", по клавише отправляют сообщения в чат")) or u8("Бинд отправляет сообщения в чат по нажатию клавиши"))
    dl:PopClipRect()
    if WK.button(dl, "##bind_add", x + w - btnW - 16, y + (sh - 40) / 2, btnW, 40, u8("Добавить бинд"), fa.ICON_PLUS, C.green, true) then
        BND.draft = {name = "", text = {}, v = {}}
        addBindName.v = ""; addBindMultiline.v = ""
        imgui.OpenPopup(u8("Добавление бинда##add_popup"))
    end
    y = y + sh + 14
    local toDelete
    if total == 0 then
        local eh = 112
        rhCardBox(dl, x, y, w, eh, bg, brd, 14)
        rhIconBadge(dl, x + w / 2, y + 36, 20, fa.ICON_KEYBOARD_O, C.mute, bg, 0)
        local t1 = u8("Биндов пока нет")
        local t2 = u8("Нажмите кнопку Добавить бинд, чтобы создать первый")
        dl:AddText(P(x + (w - imgui.CalcTextSize(t1).x) / 2, y + 66), 0xFFDDDDDD, t1)
        dl:AddText(P(x + (w - imgui.CalcTextSize(t2).x) / 2, y + 86), C.mute, t2)
        y = y + eh + 10
    else
        for key, val in ipairs(binds) do
            local act = imgui.BindCard(key, val, x, y, w)
            if act == "edit" then
                editingBindIdx = key
                editBindMultiline.v = u8(table.concat(val.text or {}, "\n"))
                editBindName.v = u8(val.name or "")
                imgui.OpenPopup(u8("Редактирование бинда"))
            elseif act == "delete" then
                toDelete = key
            end
            y = y + 58 + 8
        end
        y = y + 2
    end
    if toDelete then
        sampAddChatMessage(SCRIPT_PREFIX .. "Бинд \"" .. tostring(binds[toDelete].name) .. "\" удалён.", SCRIPT_COLOR)
        table.remove(binds, toDelete)
        saveBinderDatabase()
    end
    imgui.SetCursorScreenPos(P(x, y + 4))
    imgui.Dummy(P(w, 6))
    local editVal = editingBindIdx and binds[editingBindIdx]
    local keyChanged = binderEditor(u8("Редактирование бинда"), "edit", editBindName, editBindMultiline,
        editVal or {v = {}}, u8("Сохранить"), function()
            if not editVal then return end
            editVal.name = u8:decode(editBindName.v)
            editVal.text = binderParseLines(editBindMultiline)
            saveBinderDatabase()
        end)
    if keyChanged and editVal then saveBinderDatabase() end
    BND.draft = BND.draft or {name = "", text = {}, v = {}}
    binderEditor(u8("Добавление бинда##add_popup"), "add", addBindName, addBindMultiline,
        BND.draft, u8("Добавить"), function()
            local nb = BND.draft
            nb.name = u8:decode(addBindName.v)
            nb.text = binderParseLines(addBindMultiline)
            table.insert(binds, nb)
            BND.draft = {name = "", text = {}, v = {}}
            addBindName.v = ""; addBindMultiline.v = ""
            saveBinderDatabase()
        end)
end
function drawProfileCard()
    if not profilePopupOpen then return end
    if not headerWinPos or not headerWinSize then return end
    refreshMyOverallRank()
    local function P(x, y) return imgui.ImVec2(x, y) end
    local theme
    if useCustomTheme then
        theme = CUSTOM_THEME
    else
        theme = THEME_CONFIGS[currentTheme] or THEME_CONFIGS[THEMES.DEFAULT]
    end
    if not theme then theme = THEME_CONFIGS[THEMES.DEFAULT] end
    local accentHex = getColorHex(theme.accent)
    local cardW, cardH = 280, 340
    local cardX = mainWinPos.x + 1020 + 5
    local cardY = mainWinPos.y
    imgui.SetNextWindowPos(imgui.ImVec2(cardX, cardY), imgui.Cond.Always)
    imgui.SetNextWindowSize(imgui.ImVec2(cardW, cardH), imgui.Cond.Always)
    imgui.PushStyleVar(imgui.StyleVar.WindowPadding, imgui.ImVec2(0, 0))
    imgui.PushStyleVar(imgui.StyleVar.WindowRounding, 14)
    imgui.PushStyleColor(imgui.Col.WindowBg, imgui.ImVec4(0, 0, 0, 0))
    imgui.PushStyleColor(imgui.Col.Border, imgui.ImVec4(0, 0, 0, 0))
    imgui.Begin(u8("##profile_card"), nil, imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar)
    local winPos = imgui.GetWindowPos()
    local drawList = imgui.GetWindowDrawList()
    local mp = imgui.GetMousePos()
    if imgui.IsMouseClicked(0) and not avatarHoveredGlobal and not notifCardHoveredGlobal
        and not imgui.IsMouseHoveringRect(winPos, imgui.ImVec2(winPos.x + cardW, winPos.y + cardH), false) then
        profilePopupOpen = false
    end
    local cX, cY = winPos.x, winPos.y
    local px, innerW = cX + 16, cardW - 32
    local function inRect(x, y, w, h) return mp.x >= x and mp.x <= x + w and mp.y >= y and mp.y <= y + h end
    local _, ppid = sampGetPlayerIdByCharHandle(PLAYER_PED)
    local nick = sampGetPlayerNickname(ppid) or "?"
    local tgOk = tgConfig.enabled and tgConfig.botToken ~= "" and tgConfig.chatId ~= ""
    local lbOk = lbEnabledCache
    local dash = homeDashCache or {}
    rhCardBox(drawList, cX, cY, cardW, cardH, 0xFF181818, 0xFF2E2E2E, 14)
    local av = P(cX + 42, cY + 42)
    drawList:AddCircle(av, 27, rhAlpha(accentHex, 0.45), 40, 1.5)
    drawList:AddCircleFilled(av, 22, accentHex, 32)
    local userSz = imgui.CalcTextSize(fa.ICON_USER)
    drawList:AddText(P(av.x - userSz.x / 2, av.y - userSz.y / 2), 0xFF0A0A0A, fa.ICON_USER)
    drawList:AddCircleFilled(P(av.x + 18, av.y + 18), 7, 0xFF181818, 16)
    drawList:AddCircleFilled(P(av.x + 18, av.y + 18), 5, 0xFF33DD77, 16)
    local bellR = 14
    local bellC = P(cX + cardW - 16 - bellR, cY + 28)
    local bellHovered = inRect(bellC.x - bellR, bellC.y - bellR, bellR * 2, bellR * 2)
    notifBellHoveredGlobal = bellHovered
    local bellA = rhAnim("prof_bell", bellHovered and 1 or 0)
    drawList:AddCircleFilled(bellC, bellR, rhLerpColor(0xFF202020, rhAlpha(accentHex, 0.3), bellA), 24)
    drawList:AddCircle(bellC, bellR, rhLerpColor(0xFF2C2C2C, accentHex, 0.7 * bellA), 24, 1.0)
    local bellSz = imgui.CalcTextSize(fa.ICON_BELL)
    drawList:AddText(P(bellC.x - bellSz.x / 2, bellC.y - bellSz.y / 2), rhLerpColor(0xFFAAAAAA, 0xFFFFFFFF, bellA), fa.ICON_BELL)
    if getUnreadAnnouncementCount() > 0 then
        drawList:AddCircleFilled(P(bellC.x + 10, bellC.y - 10), 4, 0xFF4A4AE0, 12)
    end
    imgui.SetCursorScreenPos(P(bellC.x - bellR, bellC.y - bellR))
    if imgui.InvisibleButton("##profile_notif_bell", imgui.ImVec2(bellR * 2, bellR * 2)) then
        notifHistoryPopupOpen = not notifHistoryPopupOpen
        if notifHistoryPopupOpen then
            imgui.ShowCursor = true
            markAllAnnouncementsRead()
        end
    end
    local RANK_GOLD, RANK_SILVER, RANK_BRONZE = 0xFF00D7FF, 0xFFC7C7C7, 0xFF327FCD
    local rankText, rankCol
    if not lbOk then rankText, rankCol = u8("Рейтинг выкл"), 0xFF777777
    elseif myOverallRank == nil then rankText, rankCol = "...", 0xFF888888
    elseif myOverallRank == -1 then rankText, rankCol = u8("Вне рейтинга"), 0xFF888888
    else
        rankText = "#" .. myOverallRank
        if myOverallRank == 1 then rankCol = RANK_GOLD
        elseif myOverallRank == 2 then rankCol = RANK_SILVER
        elseif myOverallRank == 3 then rankCol = RANK_BRONZE
        else rankCol = accentHex end
    end
    local curServerName = getCurrentServer()
    local srvIcon = getServerIcon(curServerName)
    local srvW = (srvIcon and 18 or 0) + imgui.CalcTextSize(u8(curServerName)).x
    local rIconSz = imgui.CalcTextSize(fa.ICON_TROPHY)
    local chipH = 24
    local maxChipW = cardW - 16 - 78 - srvW - 8
    local rankShort = {[u8("Вне рейтинга")] = u8("Вне"), [u8("Рейтинг выкл")] = u8("Выкл")}
    local rTextSz = imgui.CalcTextSize(rankText)
    local chipW = rIconSz.x + 6 + rTextSz.x + 22
    if chipW > maxChipW and rankShort[rankText] then
        rankText = rankShort[rankText]
        rTextSz = imgui.CalcTextSize(rankText)
        chipW = rIconSz.x + 6 + rTextSz.x + 22
    end
    if chipW > maxChipW then
        rankText = ""
        rTextSz = imgui.ImVec2(0, rTextSz.y)
        chipW = rIconSz.x + 22
    end
    local chipX = cX + cardW - 16 - chipW
    local chipY = cY + 48
    local chipHov = inRect(chipX, chipY, chipW, chipH)
    local ca = rhAnim("prof_rank", chipHov and 1 or 0)
    drawList:AddRectFilled(P(chipX, chipY), P(chipX + chipW, chipY + chipH), rhAlpha(rankCol, 0.14 + 0.10 * ca), chipH / 2)
    drawList:AddRect(P(chipX, chipY), P(chipX + chipW, chipY + chipH), rhAlpha(rankCol, 0.45 + 0.4 * ca), chipH / 2, 15, 1.0)
    drawList:AddText(P(chipX + 11, chipY + (chipH - rIconSz.y) / 2), rankCol, fa.ICON_TROPHY)
    drawList:AddText(P(chipX + 11 + rIconSz.x + 6, chipY + (chipH - rTextSz.y) / 2), rankCol, rankText)
    imgui.SetCursorScreenPos(P(chipX, chipY))
    if imgui.InvisibleButton("##profile_rank_chip", imgui.ImVec2(chipW, chipH)) then
        currentTab = 6
        profilePopupOpen = false
    end
    drawList:PushClipRect(P(cX + 78, cY + 14), P(bellC.x - bellR - 8, cY + 46), true)
    drawList:AddText(P(cX + 78, cY + 24), 0xFFFFFFFF, nick)
    drawList:PopClipRect()
    drawList:PushClipRect(P(cX + 78, cY + 44), P(chipX - 8, cY + 74), true)
    if srvIcon then
        drawList:AddImage(srvIcon, P(cX + 78, cY + 52), P(cX + 92, cY + 66))
        drawList:AddText(P(cX + 96, cY + 52), 0xFF999999, u8(curServerName))
    else
        drawList:AddText(P(cX + 78, cY + 52), 0xFF999999, u8(curServerName))
    end
    drawList:PopClipRect()
    drawList:AddLine(P(px, cY + 84), P(px + innerW, cY + 84), 0xFF262626, 1.0)
    local y0 = cY + 94
    drawList:AddText(P(px, y0), 0xFF888888, u8("Доход за сегодня"))
    if (dash.totalAZ or 0) > 0 then
        local azStr = formatNumber(dash.totalAZ) .. " AZ"
        drawList:AddText(P(px + innerW - imgui.CalcTextSize(azStr).x, y0), 0xFF00D7FF, azStr)
    end
    local bigStr = formatNumber(dash.total or 0) .. "$"
    if rhBigFont then
        imgui.PushFont(rhBigFont)
        imgui.SetCursorScreenPos(P(px, y0 + 16))
        imgui.TextColored(imgui.ImVec4(0.47, 0.87, 0.2, 1), bigStr)
        imgui.PopFont()
    else
        drawList:AddText(P(px, y0 + 22), 0xFF33DD77, bigStr)
        drawList:AddText(P(px + 1, y0 + 22), 0xFF33DD77, bigStr)
    end
    local goal = settings.totalIncomeGoal or 0
    if goal > 0 then
        local pct = math.min((dash.total or 0) / goal, 1)
        local done = pct >= 1
        local pStr = math.floor(pct * 100) .. "%"
        local pW = imgui.CalcTextSize(pStr).x
        drawList:AddRectFilled(P(px, y0 + 62), P(px + innerW - pW - 10, y0 + 67), 0xFF262626, 3)
        if pct > 0 then
            drawList:AddRectFilled(P(px, y0 + 62), P(px + (innerW - pW - 10) * pct, y0 + 67), done and 0xFF33DD77 or 0xFF38C8F8, 3)
        end
        drawList:AddText(P(px + innerW - pW, y0 + 55), done and 0xFF33DD77 or 0xFF999999, pStr)
    else
        drawList:AddText(P(px, y0 + 58), 0xFF666666, u8("Цель дня не задана"))
    end
    local lifeLabel = u8("Всего за всё время")
    local lifeStr = (lbOk and myOverallAmount) and (formatNumber(myOverallAmount) .. "$") or "--"
    drawList:AddText(P(px, y0 + 78), 0xFF777777, lifeLabel)
    drawList:AddText(P(px + innerW - imgui.CalcTextSize(lifeStr).x, y0 + 78), 0xFFDDDDDD, lifeStr)
    local sessionSec = (sessionAccumulatedSec or 0) + (os.time() - (gameSessionStartTime or os.time()))
    local timeStr = string.format("%d:%02d:%02d", math.floor(sessionSec / 3600), math.floor((sessionSec % 3600) / 60), sessionSec % 60)
    local achDone, achTotal = 0, 0
    local nextAch, nextRatio = nil, -1
    for _, ach in ipairs(ACHIEVEMENTS) do
        achTotal = achTotal + 1
        if ach.completed then achDone = achDone + 1 end
        if not ach.completed and ach.target and ach.target > 0 then
            local ratio = (ach.progress or 0) / ach.target
            if ratio > nextRatio then nextRatio = ratio; nextAch = ach end
        end
    end
    local y1 = cY + 204
    local t1 = u8("В игре ") .. timeStr
    local c1W = imgui.CalcTextSize(t1).x + 24
    drawList:AddRectFilled(P(px, y1), P(px + c1W, y1 + 26), 0xFF202020, 13)
    drawList:AddRect(P(px, y1), P(px + c1W, y1 + 26), 0xFF2C2C2C, 13, 15, 1.0)
    drawList:AddText(P(px + 12, y1 + 6), 0xFFCCCCCC, t1)
    local t2 = fa.ICON_STAR .. "  " .. achDone .. " / " .. achTotal
    local c2W = imgui.CalcTextSize(t2).x + 24
    local c2X = px + c1W + 8
    local c2Hov = inRect(c2X, y1, c2W, 26)
    local c2A = rhAnim("prof_chip_ach", c2Hov and 1 or 0)
    drawList:AddRectFilled(P(c2X, y1), P(c2X + c2W, y1 + 26), rhLerpColor(0xFF202020, rhAlpha(accentHex, 0.18), c2A), 13)
    drawList:AddRect(P(c2X, y1), P(c2X + c2W, y1 + 26), rhLerpColor(0xFF2C2C2C, accentHex, 0.6 * c2A), 13, 15, 1.0)
    drawList:AddText(P(c2X + 12, y1 + 6), rhLerpColor(0xFFCCCCCC, accentHex, c2A), t2)
    imgui.SetCursorScreenPos(P(c2X, y1))
    if imgui.InvisibleButton("##profile_chip_ach", imgui.ImVec2(c2W, 26)) then
        currentTab = 8
        profilePopupOpen = false
    end
    local y2 = cY + 238
    local ah = 40
    local aHov = inRect(px, y2, innerW, ah)
    local aA = rhAnim("prof_next_ach", aHov and 1 or 0)
    if aA > 0.01 then
        drawList:AddRectFilled(P(px, y2), P(px + innerW, y2 + ah), rhAlpha(0xFFFFFFFF, 0.04 * aA), 10)
    end
    if nextAch then
        rhIconBadge(drawList, px + 22, y2 + ah / 2, 14, nextAch.icon or fa.ICON_STAR, accentHex, 0xFF181818, aA)
        local progLabel = (nextAch.progress or 0) .. "/" .. nextAch.target
        local pw = imgui.CalcTextSize(progLabel).x
        drawList:PushClipRect(P(px + 44, y2), P(px + innerW - 8 - pw - 8, y2 + ah), true)
        drawList:AddText(P(px + 46, y2 + 5), 0xFFEEEEEE, u8(nextAch.name))
        drawList:PopClipRect()
        drawList:AddText(P(px + innerW - 8 - pw, y2 + 5), 0xFF999999, progLabel)
        local ratio = math.min(math.max(nextRatio, 0), 1)
        drawList:AddRectFilled(P(px + 46, y2 + 27), P(px + innerW - 8, y2 + 31), 0xFF2A2A2A, 2)
        if ratio > 0 then
            drawList:AddRectFilled(P(px + 46, y2 + 27), P(px + 46 + (innerW - 54) * ratio, y2 + 31), accentHex, 2)
        end
    else
        drawList:AddText(P(px + 8, y2 + ah / 2 - 7), 0xFF888888, u8("Все достижения выполнены!"))
    end
    imgui.SetCursorScreenPos(P(px, y2))
    if imgui.InvisibleButton("##profile_goal", imgui.ImVec2(innerW, ah)) then
        currentTab = 8
        profilePopupOpen = false
    end
    drawList:AddLine(P(px, cY + 288), P(px + innerW, cY + 288), 0xFF262626, 1.0)
    local y4 = cY + 296
    local barH = 34
    local segW = innerW / 3
    rhCardBox(drawList, px, y4, innerW, barH, 0xFF1C1C1C, 0xFF2C2C2C, 17)
    local segs = {
        {icon = fa.ICON_PAPER_PLANE, text = u8("Telegram"), fg = tgOk and 0xFF4CD973 or 0xFF888888, col = tgOk and 0xFF4CD973 or accentHex,
         tip = tgOk and u8("Telegram подключен") or u8("Telegram не настроен"),
         click = function() currentTab = 10; settingsExpandedTelegram = true; profilePopupOpen = false end},
        {icon = fa.ICON_TROPHY, text = u8("Рейтинг"), fg = lbOk and 0xFF4CD973 or 0xFF888888, col = lbOk and 0xFF4CD973 or accentHex,
         tip = lbOk and u8("Участие в рейтинге включено") or u8("Вы не участвуете в рейтинге"),
         click = function() currentTab = 6; profilePopupOpen = false end},
        {icon = fa.ICON_BULLSEYE, text = u8("Цели"), fg = 0xFFCCCCCC, col = accentHex,
         tip = u8("Цели на сегодня"),
         click = function() currentTab = 7; profilePopupOpen = false end},
    }
    for i, seg in ipairs(segs) do
        local sx = px + (i - 1) * segW
        local hov = inRect(sx, y4, segW, barH)
        local ha = rhAnim("prof_seg_" .. i, hov and 1 or 0)
        if ha > 0.01 then
            drawList:AddRectFilled(P(sx + 3, y4 + 3), P(sx + segW - 3, y4 + barH - 3), rhAlpha(seg.col, 0.16 * ha), 14)
        end
        local iSz = imgui.CalcTextSize(seg.icon)
        local tSz = imgui.CalcTextSize(seg.text)
        local gw = iSz.x + 6 + tSz.x
        local gx = sx + (segW - gw) / 2
        local fg = rhLerpColor(seg.fg, 0xFFFFFFFF, 0.5 * ha)
        drawList:AddText(P(gx, y4 + (barH - iSz.y) / 2), fg, seg.icon)
        drawList:AddText(P(gx + iSz.x + 6, y4 + (barH - tSz.y) / 2), fg, seg.text)
        if i < #segs then
            drawList:AddLine(P(sx + segW, y4 + 9), P(sx + segW, y4 + barH - 9), 0xFF2A2A2A, 1.0)
        end
        imgui.SetCursorScreenPos(P(sx, y4))
        if imgui.InvisibleButton("##profile_seg_" .. i, imgui.ImVec2(segW, barH)) then seg.click() end
        if hov then rhTip(seg.tip) end
    end
    imgui.End()
    imgui.PopStyleVar(2)
    imgui.PopStyleColor(2)
end
RH_VS = " VC$"
function rhIsVice()
    return getCurrentServer() == "Vice City"
end
function rhVsText(s)
    if rhIsVice() then return (s:gsub("(%d)%$", "%1" .. RH_VS)) end
    return s
end
function rhPriceTag()
    return rhIsVice() and "_vc" or ""
end
if not RH_TXT_HOOKED then
    RH_TXT_HOOKED = true
    local oText, oColored, oWrapped, oDisabled, oCalc = imgui.Text, imgui.TextColored, imgui.TextWrapped, imgui.TextDisabled, imgui.CalcTextSize
    imgui.Text = function(s, ...)
        if type(s) == "string" then s = rhVsText(s) end
        return oText(s, ...)
    end
    imgui.TextColored = function(col, s, ...)
        if type(s) == "string" then s = rhVsText(s) end
        return oColored(col, s, ...)
    end
    if oWrapped then
        imgui.TextWrapped = function(s, ...)
            if type(s) == "string" then s = rhVsText(s) end
            return oWrapped(s, ...)
        end
    end
    if oDisabled then
        imgui.TextDisabled = function(s, ...)
            if type(s) == "string" then s = rhVsText(s) end
            return oDisabled(s, ...)
        end
    end
    imgui.CalcTextSize = function(s, ...)
        if type(s) == "string" then s = rhVsText(s) end
        return oCalc(s, ...)
    end
end
rhTintOn = false
if not RH_DL_ORIG then
    RH_DL_ORIG = imgui.GetWindowDrawList
    do
        local COLIDX = {
            AddRectFilled = 3, AddRect = 3, AddLine = 3, AddCircleFilled = 3, AddCircle = 3,
            AddText = 2, AddTriangleFilled = 4, AddTriangle = 4, AddQuadFilled = 5, AddQuad = 5,
        }
        local VC_MAP = {[0x1AE591] = 0xC78FFF, [0x33CC66] = 0xC78FFF, [0x1E3D1E] = 0xA86FA6, [0x555555] = 0xEEC39C}
        local function tint(c, isText)
            if type(c) ~= "number" or c < 0 then return c end
            local r = c % 256
            local g = math.floor(c / 256) % 256
            local b = math.floor(c / 65536) % 256
            local th = THEME_CONFIGS[currentTheme]
            if not th then return c end
            local bg = th.rightPanelBg
            local al = c - c % 16777216
            if currentTheme == THEMES.VICE then
                local m = VC_MAP[c % 16777216]
                if m then return al + m end
                if r ~= g or g ~= b then return c end
                if isText and r >= 0x50 and r <= 0xB8 then return al + 0xF5DDC9 end
                if r < 10 or r > 60 then return c end
                local d = (r - 20) * 1.6 - 30
                local nr = math.max(0, math.min(255, math.floor(bg % 256 + d + 0.5)))
                local ng = math.max(0, math.min(255, math.floor(math.floor(bg / 256) % 256 + d + 0.5)))
                local nb = math.max(0, math.min(255, math.floor(math.floor(bg / 65536) % 256 + d + 0.5)))
                return al + nb * 65536 + ng * 256 + nr
            end
            if r ~= g or g ~= b or r < 10 or r > 60 then return c end
            local d = r - 20
            local nr = math.max(0, math.min(255, bg % 256 + d))
            local ng = math.max(0, math.min(255, math.floor(bg / 256) % 256 + d))
            local nb = math.max(0, math.min(255, math.floor(bg / 65536) % 256 + d))
            return al + nb * 65536 + ng * 256 + nr
        end
        local function fwd(r, k, n, a, b, c, d, e, f, g, h)
            local m = r[k]
            if n == 3 then return m(r, a, b, c)
            elseif n == 4 then return m(r, a, b, c, d)
            elseif n == 5 then return m(r, a, b, c, d, e)
            elseif n == 6 then return m(r, a, b, c, d, e, f)
            elseif n == 7 then return m(r, a, b, c, d, e, f, g)
            else return m(r, a, b, c, d, e, f, g, h) end
        end
        local cache = {}
        local MT = {__index = function(t, k)
            local f = cache[k]
            if not f then
                local ci = COLIDX[k]
                if ci then
                    f = function(self, ...)
                        local r = rawget(self, "__r")
                        local n = select("#", ...)
                        local a, b, c, d, e, f2, g, h = ...
                        if ci == 2 and type(c) == "string" then c = rhVsText(c) end
                        if not rhTintOn or useCustomTheme or currentTheme == THEMES.DEFAULT then
                            if ci == 2 and n >= 3 and n <= 8 then return fwd(r, k, n, a, b, c, d, e, f2, g, h) end
                            return r[k](r, ...)
                        end
                        if ci == 2 then b = tint(b, true) elseif ci == 3 then c = tint(c) elseif ci == 4 then d = tint(d) else e = tint(e) end
                        if n < 3 or n > 8 then return r[k](r, ...) end
                        return fwd(r, k, n, a, b, c, d, e, f2, g, h)
                    end
                else
                    f = function(self, ...)
                        local r = rawget(self, "__r")
                        return r[k](r, ...)
                    end
                end
                cache[k] = f
            end
            return f
        end}
        imgui.GetWindowDrawList = function()
            return setmetatable({__r = RH_DL_ORIG()}, MT)
        end
    end
end
function imgui.OnDrawFrame()
    if not mainWin.v and not isWindowAnimating() and not settings.farmOverlayEnabled and not settings.mineOverlayEnabled and not settings.sawmillOverlayEnabled and not settings.oilOverlayEnabled and not settings.taxiOverlayEnabled and not settings.incassOverlayEnabled and #achievementNotifications == 0 and #devNotifications == 0 and #devImportantQueue == 0 and not devImportantCurrent and not notifHistoryPopupOpen then return end
    
    if settings.farmOverlayEnabled then drawFarmOverlay() end
    if settings.mineOverlayEnabled then drawMineOverlay() end
    if settings.sawmillOverlayEnabled then drawSawmillOverlay() end
    if settings.oilOverlayEnabled then drawOilOverlay() end
    if settings.taxiOverlayEnabled then drawTaxiOverlay() end
    if settings.incassOverlayEnabled then drawIncassOverlay() end
    rhTintOn = true
    if mainWin.v or isWindowAnimating() then drawMainMenu() end
    if not mainWin.v then profilePopupOpen = false; itemPickerOpen = false end
    drawProfileCard()
    drawItemPickerCard()
    rhTintOn = false
    drawAchievementNotifications()
    drawDevNotifications()
    drawDevImportantPopup()
    drawNotificationHistoryPopup()
end
function updateScript()
    sampAddChatMessage(SCRIPT_PREFIX .. "Скачиваю обновление...", SCRIPT_COLOR)
    local dir = getWorkingDirectory() .. "/#ArzResHelper.lua"
    local url = "https://raw.githubusercontent.com/Ryder8471/ArzResHelper/main/%23ArzResHelper.lua?t=" .. os.time()
    
    local asyncReq = effil.thread(function(u, d)
        local req = require("requests")
        local ok, result = pcall(req.get, u)
        if ok and result and result.text then
            local cleaned = result.text:gsub("\r\n\r\n", "\n"):gsub("\r\n", "\n"):gsub("\r", "\n")
            cleaned = cleaned:gsub("\n\n\n+", "\n\n")
            local file = io.open(d, "w")
            if file then
                file:write(cleaned)
                file:close()
                return true
            end
        end
        return false
    end)(url, dir)
    
    lua_thread.create(function()
        local startTime = os.time()
        while true do
            local status = asyncReq:status()
            if status == "completed" then
                local success = asyncReq:get()
                if success then
                    if doesFileExist(changelogPath) then os.remove(changelogPath) end
                    sampAddChatMessage(SCRIPT_PREFIX .. "Обновление скачано! Перезагружаю скрипт...", SCRIPT_COLOR)
                    wait(500)
                    showCursor(false)
                    scr:reload()
                else
                    sampAddChatMessage(SCRIPT_PREFIX .. "Ошибка при скачивании обновления.", SCRIPT_COLOR)
                end
                return
            elseif status == "canceled" or (os.time() - startTime > 30) then
                sampAddChatMessage(SCRIPT_PREFIX .. "Таймаут скачивания.", SCRIPT_COLOR)
                return
            end
            wait(100)
        end
    end)
end
function checkAndInstallResources()
    local versionFile = dirml .. "/.reshelper_version"
    local currentVersion = ""
    
    if doesFileExist(versionFile) then
        local f = io.open(versionFile, "r")
        if f then
            currentVersion = f:read("*line") or ""
            f:close()
        end
    end
    
    if currentVersion == RESOURCE_VERSION and doesDirectoryExist(dirml.."/ResHelper/files/server_icons/") then return end
    
    createDirectory(dirml .. "/ResHelper/files")
    createDirectory(dirml .. "/resource/farm")
    
    sampAddChatMessage(SCRIPT_PREFIX .. "Обновление ресурсов до v" .. RESOURCE_VERSION .. "...", SCRIPT_COLOR)
    local zipPath = dirml .. "\\moonloader_res.zip"
    
    local asyncReq = effil.thread(function(u, z)
        local req = require("requests")
        local ok, result = pcall(req.get, u)
        if ok and result then
            local body = result.body or result.text or ""
            if #body > 1000 then
                local file = io.open(z, "wb")
                if file then
                    file:write(body)
                    file:close()
                    return true
                end
            end
        end
        return false
    end)("https://raw.githubusercontent.com/Ryder8471/ArzResHelper/main/moonloader.zip", zipPath)
    
    lua_thread.create(function()
        local startTime = os.time()
        while true do
            local status = asyncReq:status()
            if status == "completed" then
                local success = asyncReq:get()
                if success and doesFileExist(zipPath) then
                    sampAddChatMessage(SCRIPT_PREFIX .. "Архив скачан. Распаковываю...", SCRIPT_COLOR)
                    
                    local cmd = 'tar -xf "' .. zipPath .. '" -C "' .. dirml .. '"'
                    local extractReq = effil.thread(function(c)
                        local ok = os.execute(c)
                        return ok and true or false
                    end)(cmd)
                    lua_thread.create(function()
                        local exStart = os.time()
                        local extractOk = false
                        while true do
                            local exStatus = extractReq:status()
                            if exStatus == "completed" then
                                local ok = extractReq:get()
                                extractOk = ok and true or false
                                break
                            elseif exStatus == "canceled" then
                                break
                            elseif os.time() - exStart > 20 then
                                pcall(function() extractReq:cancel() end)
                                break
                            end
                            wait(0)
                        end
                        if doesFileExist(zipPath) then os.remove(zipPath) end
                        if extractOk and doesDirectoryExist(dirml.."/ResHelper/files/server_icons/") then
                            local f = io.open(versionFile, "w")
                            if f then f:write(RESOURCE_VERSION); f:close() end
                            sampAddChatMessage(SCRIPT_PREFIX .. "Ресурсы обновлены! Перезагружаю скрипт...", SCRIPT_COLOR)
                            wait(500)
                            thisScript():reload()
                        else
                            local failFile = versionFile .. ".fails"
                            local fails = 0
                            local ff = io.open(failFile, "r")
                            if ff then fails = tonumber(ff:read("*line")) or 0; ff:close() end
                            fails = fails + 1
                            local fw = io.open(failFile, "w")
                            if fw then fw:write(tostring(fails)); fw:close() end
                            if fails >= 3 then
                                local f = io.open(versionFile, "w")
                                if f then f:write(RESOURCE_VERSION); f:close() end
                                sampAddChatMessage(SCRIPT_PREFIX .. "Не удалось распаковать ресурсы после нескольких попыток. Автоустановка отключена, скрипт продолжит работу без иконок серверов. Напишите разработчику.", SCRIPT_COLOR)
                            else
                                sampAddChatMessage(SCRIPT_PREFIX .. "Не удалось распаковать ресурсы (попытка " .. fails .. "/3). Проверьте интернет и антивирус.", SCRIPT_COLOR)
                            end
                        end
                    end)
                else
                    sampAddChatMessage(SCRIPT_PREFIX .. "Ошибка при скачивании ресурсов. Проверьте интернет.", SCRIPT_COLOR)
                end
                return
            elseif status == "canceled" or (os.time() - startTime > 30) then
                sampAddChatMessage(SCRIPT_PREFIX .. "Таймаут скачивания ресурсов.", SCRIPT_COLOR)
                return
            end
            wait(100)
        end
    end)
end
function updateCheck()
    local url = "https://raw.githubusercontent.com/Ryder8471/ArzResHelper/refs/heads/main/info.upd?t=" .. os.time()
    
    local asyncReq = effil.thread(function(u)
        local req = require("requests")
        local ok, result = pcall(req.get, u)
        if ok and result then
            return result.text
        end
        return nil
    end)(url)
    
    lua_thread.create(function()
        local startTime = os.time()
        while true do
            local status, err = asyncReq:status()
            if status == "completed" then
                local text = asyncReq:get()
                if text then
                    local upd = decodeJson(text)
                    if upd and upd.version then
                        newversion = upd.version; newdate = upd.release_date
                        if upd.version ~= scr.version then
                            sampAddChatMessage(SCRIPT_PREFIX .."Доступна версия v"..newversion.."!", SCRIPT_COLOR)
                            sampAddChatMessage(SCRIPT_PREFIX .."Откройте /rh -> О скрипте -> Обновить до v"..newversion, SCRIPT_COLOR)
                        else
                            sampAddChatMessage(SCRIPT_PREFIX .."У вас актуальная версия v"..scr.version, SCRIPT_COLOR)
                        end
                    end
                end
                return
            elseif status == "canceled" or (os.time() - startTime > 10) then
                return
            end
            wait(0)
        end
    end)
end
function saveOverlayConfig()
    local file = io.open(configDir .. "overlay_config.ini", "w")
    if file then
        file:write("[Farm]\nx=" .. overlayConfigs[WORK_TYPES.FARM].x .. "\ny=" .. overlayConfigs[WORK_TYPES.FARM].y .. "\nw=" .. overlayConfigs[WORK_TYPES.FARM].w .. "\nh=" .. overlayConfigs[WORK_TYPES.FARM].h .. "\n")
        file:write("[Mine]\nx=" .. overlayConfigs[WORK_TYPES.MINE].x .. "\ny=" .. overlayConfigs[WORK_TYPES.MINE].y .. "\nw=" .. overlayConfigs[WORK_TYPES.MINE].w .. "\nh=" .. overlayConfigs[WORK_TYPES.MINE].h .. "\n")
        file:write("[Sawmill]\nx=" .. overlayConfigs[WORK_TYPES.SAWMILL].x .. "\ny=" .. overlayConfigs[WORK_TYPES.SAWMILL].y .. "\nw=" .. overlayConfigs[WORK_TYPES.SAWMILL].w .. "\nh=" .. overlayConfigs[WORK_TYPES.SAWMILL].h .. "\n")
        file:write("[Oil]\nx=" .. oilOverlayConfig.x .. "\ny=" .. oilOverlayConfig.y .. "\nw=" .. oilOverlayConfig.w .. "\nh=" .. oilOverlayConfig.h .. "\n")
        file:write("[Taxi]\nx=" .. taxiOverlayConfig.x .. "\ny=" .. taxiOverlayConfig.y .. "\nw=" .. taxiOverlayConfig.w .. "\nh=" .. taxiOverlayConfig.h .. "\n")
        file:write("[Incass]\nx=" .. incassOverlayConfig.x .. "\ny=" .. incassOverlayConfig.y .. "\nw=" .. incassOverlayConfig.w .. "\nh=" .. incassOverlayConfig.h .. "\n")
        file:close()
    end
end
function loadOverlayConfig()
    local file = io.open(configDir .. "overlay_config.ini", "r")
    if not file then return end
    local section = ""
    for line in file:lines() do
        local sec = line:match("^%[(.*)%]$")
        if sec then section = sec
        else
            local k, v = line:match("^(.-)=(.*)$")
            if k and v then
                local num = tonumber(v)
                if num then
                    if section == "Farm" then
                        if k == "x" then overlayConfigs[WORK_TYPES.FARM].x = num
                        elseif k == "y" then overlayConfigs[WORK_TYPES.FARM].y = num
                        elseif k == "w" then overlayConfigs[WORK_TYPES.FARM].w = num
                        elseif k == "h" then overlayConfigs[WORK_TYPES.FARM].h = num end
                    elseif section == "Mine" then
                        if k == "x" then overlayConfigs[WORK_TYPES.MINE].x = num
                        elseif k == "y" then overlayConfigs[WORK_TYPES.MINE].y = num
                        elseif k == "w" then overlayConfigs[WORK_TYPES.MINE].w = num
                        elseif k == "h" then overlayConfigs[WORK_TYPES.MINE].h = num end
                    elseif section == "Sawmill" then
                        if k == "x" then overlayConfigs[WORK_TYPES.SAWMILL].x = num
                        elseif k == "y" then overlayConfigs[WORK_TYPES.SAWMILL].y = num
                        elseif k == "w" then overlayConfigs[WORK_TYPES.SAWMILL].w = num
                        elseif k == "h" then overlayConfigs[WORK_TYPES.SAWMILL].h = num end
                    elseif section == "Oil" then
                        if k == "x" then oilOverlayConfig.x = num
                        elseif k == "y" then oilOverlayConfig.y = num
                        elseif k == "w" then oilOverlayConfig.w = num
                        elseif k == "h" then oilOverlayConfig.h = num end
                    elseif section == "Taxi" then
                        if k == "x" then taxiOverlayConfig.x = num
                        elseif k == "y" then taxiOverlayConfig.y = num
                        elseif k == "w" then taxiOverlayConfig.w = num
                        elseif k == "h" then taxiOverlayConfig.h = num end
                    elseif section == "Incass" then
                        if k == "x" then incassOverlayConfig.x = num
                        elseif k == "y" then incassOverlayConfig.y = num
                        elseif k == "w" then incassOverlayConfig.w = num
                        elseif k == "h" then incassOverlayConfig.h = num end
                    end
                end
            end
        end
    end
    file:close()
end
addEventHandler('onWindowMessage', function(msg, wparam, lparam)
    if wparam == 27 then
        if mainWin.v then
            if msg == wm.WM_KEYDOWN then consumeWindowMessage(true, false) end
            if msg == wm.WM_KEYUP then 
                mainWin.v = not mainWin.v
                if not mainWin.v then notifHistoryPopupOpen = false end
                imgui.ShowCursor = false 
                consumeWindowMessage(true, false)
            end
        end
    end
end)
function urlEncode(str)
    local result = ""
    for i = 1, #str do
        local c = str:sub(i, i)
        local byte = string.byte(c)
        if c:match("[%w%.%-%_%~]") then
            result = result .. c
        elseif c == " " then
            result = result .. "+"
        else
            result = result .. string.format("%%%02X", byte)
        end
    end
    return result
end
function main()
    local sampLoaded = false
    for attempt = 1, 5 do
        if isSampAvailable() then sampLoaded = true; break end
        wait(500)
    end
    if not sampLoaded then
        lua_thread.create(function() wait(3000); thisScript():reload() end)
        return
    end
    local base = getModuleHandle("samp.dll")
    local sampVer = mem.tohex(base + 0xBABE, 10, true)
    if sampVer == "E86D9A0A0083C41C85C0" then
        sampIsLocalPlayerSpawned = function()
            local res, id = sampGetPlayerIdByCharHandle(PLAYER_PED)
            return sampGetGamestate() == 3 and res and sampGetPlayerAnimationId(id) ~= 0
        end
    end
    if script.this.filename:find("%.luac") then os.rename(getWorkingDirectory().."\\ResHelper.luac", getWorkingDirectory().."\\ResHelper.lua") end
    if not doesDirectoryExist(dirml.."/ResHelper/files/") then createDirectory(dirml.."/ResHelper/files/") end
    do
        local rs = getRealServer()
        if rs and rs ~= "" and rs ~= "Unknown" then
            RH_DATA_SERVER = rs
            rhApplyServerPaths(rs)
        end
    end
    checkAndInstallResources()
    if doesFileExist(dirml.."/ResHelper/files/logo-ArzResHelper.png") then
        logoArz = imgui.CreateTextureFromFile(dirml.."/ResHelper/files/logo-ArzResHelper.png")
    end
    loadServerIcons()
    loadConfig()
    loadTgConfig()
    loadAutoAdConfig()
    loadChatFilterConfig()
    cb_chatFilterEnabled.v = chatFilterConfig.enabled
    tgTokenInput.v = u8(tgConfig.botToken)
    tgChatIdInput.v = u8(tgConfig.chatId)
    loadThemeConfig()
    loadCustomTheme()
    cb_useCustomTheme.v = useCustomTheme
    pcall(rhApplyServerTheme, RH_DATA_SERVER)
    initStatsMigration()
    loadOverlayConfig()
    initPricesFile()
    initGoalsFiles()
    loadGoalsProgress()
    loadAchievements()
    loadSeenAnnouncements()
    loadAnnouncementHistory()
    lastAnnouncementCheck = os.time()
    downloadAnnouncements()
    loadItemMarketStats()
    loadShardStats()
	loadInvestmentStats()
    loadInvestmentConfig()
    loadCryptoStats()
    loadCryptoConfig()
    loadPaydayStats()
    loadPaydayUiConfig()
    loadOilStats()
    loadOilConfig()
    loadTaxiStats()
    loadIncassStats()
    loadStockStats()
    loadCaseConfig()
	loadLbRowsLimit()
    local today = getGameDate()
    local lastPricesDate = ""
    local pf = io.open(pricesStatePath, "r")
    if pf then lastPricesDate = pf:read("*line") or ""; pf:close() end
    if lastPricesDate ~= today .. rhPriceTag() then loadGlobalPrices() end
    loadTotalIncomeGoal()
    loadIncomeGoals()
    initCustomPrices()
    themeComboItems = ""
    for i, tid in ipairs(THEME_ORDER) do
        if i > 1 then themeComboItems = themeComboItems .. "\0" end
        themeComboItems = themeComboItems .. u8(THEME_CONFIGS[tid].name)
    end
    themeComboItems = themeComboItems .. "\0"
    for i, tid in ipairs(THEME_ORDER) do
        if tid == currentTheme then selectedThemeIdx.v = i - 1; break end
    end
    loadAllStatsForTodayIncome()
    sessionStartTime = os.time()
    checkChangelog()
    initSyncCheckboxes()
    registerChatCommands()
    checkAndResetDaily()
    local savedSessDate, savedAccumulated = loadSessionState()
    if savedSessDate == getGameDate() and savedAccumulated then
        sessionAccumulatedSec = savedAccumulated
    else
        sessionAccumulatedSec = 0
    end
    gameSessionStartTime = os.time()
    saveSessionState()
    repeat wait(100) until sampIsLocalPlayerSpawned()
    initAfterSpawn()
    local currentVersion = scr.version
    local versionFile = io.open(lbStatePath .. ".version", "r")
    local savedVersion = ""
    if versionFile then savedVersion = versionFile:read("*line") or ""; versionFile:close() end
    if savedVersion ~= currentVersion then
        saveLbState("", "")
        local vf = io.open(lbStatePath .. ".version", "w")
        if vf then vf:write(currentVersion); vf:close() end
    end
    if not pendingResourcesBuffer then pendingResourcesBuffer = {} end
    runMainLoop()
end