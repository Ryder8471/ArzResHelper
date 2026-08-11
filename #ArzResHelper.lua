script_name("ResHelper")
script_authors("Ryder")
script_description("Helper for Farm & Mine Resources")
script_version("1.3.5")
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
local COLOR_SECONDARY = "{E5911A}"
local COLOR_WHITE = "{FFFFFF}"
local SCRIPT_PREFIX = COLOR_WHITE.."["..COLOR_MAIN.."ResHelper"..COLOR_WHITE.."]: "
local newversion = ""
local newdate = ""
local cachedTodayStats = nil
local cachedTodayTime = 0
local cachedWeekStats = nil
local cachedWeekTime = 0
local ignoreInventoryUntil = 0
local scanSlotCounts = {}
local scanSlots = {}
tgMessageQueue = {}
lbRowsLimit = 9999
farmExpandIncome = false
mineExpandIncome = false
sawExpandIncome = false
farmExpandToday = false
farmExpandWeek = false
mineExpandToday = false
mineExpandWeek = false
sawExpandToday = false
sawExpandWeek = false
lbShowAllServers = nil
overlayHoverStartTime = nil
tgQueueProcessing = false
function processTgQueue() end
achievementUpdateTime = 0
logoArz = nil
imSelectedDateStr = nil
imCalendarYear = nil
imCalendarMonth = nil
serverIcons = {}
achievementNotifications = {}
achievementNotificationTimer = 0
LOG_AGGREGATION_INTERVAL = 10 
editingBindIdx = nil
investmentCaseLog = {}
investmentCaseConfig = {}
currentTab = 1
paydayAccessoryReceived = false
paydayLog = {}
paydayActive = false
paydaySalary = 0
paydayDeposit = 0
paydayAZ = 0
paydayAccBonus = 0
itemMarketWeekIncome = 0
cachedIMWeekTime = 0
datesExpanded = {}
oilLog = {}
oilBonusPercent = 0
oilConfig = {
    barrelCost = 40000,      -- цена закупки водной бочки 
    azBarrelCost = 12,       -- цена закупки наземной бочки (AZ)
    groundOilMoney = 270000, 
    groundBarrelAZBonus = 15, 
    groundBarrelCompanyBonus = 40000, -- доплата от выбранной электрокомпании за бочку ($), выбирается вручную кнопками в интерфейсе (40000/80000/100000)
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
}
oilLastSoldLiters = 0
oilSellCoords = {x = 0, y = 0, z = 0}
oilSessionData = {money = 0, az = 0}
investmentLog = {}
investmentConfig = {}
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
imTabIdx = imgui.ImInt(0)
local tgChatIdInput = imgui.ImBuffer(50)
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
local deck = getFolderPath(0)
local doc = getFolderPath(5)
local dirml = getWorkingDirectory()
local dirGame = getGameDirectory()
local scr = thisScript()
local mainWin = imgui.ImBool(false)
local select_menu = {true, false, false, false, false, false, false, false, false, false, false}
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
local farmGoalsProgressPath = configDir .. "farm_goals_progress.json"
local mineGoalsProgressPath = configDir .. "mine_goals_progress.json"
local soundsDir = getWorkingDirectory() .. "\\resource\\farm\\"
local farmPricesPath = configDir .. "farm_price.ini"
local minePricesPath = configDir .. "mine_price.ini"
local farmBasePath = configDir .. "farm_base.json"           
local mineBasePath = configDir .. "mine_base.json"        
local sawmillBasePath = configDir .. "sawmill_base.json"           
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
LB_MODE_RESOURCES = {
    Farm = {"flax", "cotton", "rare_tkan", "water", "dye", "coal"},
    Mine = {"stone", "metal", "bronze", "silver", "gold", "diamond", "tkan", "splav", "materia", "azbox"},
    Sawmill = {"firewood", "quality_wood", "rare_box"}
}
leaderboardCache = {
    Income = {Daily = {}, Weekly = {}, Total = {}},
    Farm = {Daily = {}, Weekly = {}, Total = {}},
    Mine = {Daily = {}, Weekly = {}, Total = {}},
    Sawmill = {Daily = {}, Weekly = {}, Total = {}},
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
oilStatsPath = configDir .. "oil_stats.json"
oilConfigPath = configDir .. "oil_config.json"
caseConfigPath = configDir .. "case_config.json"
investmentConfigPath = configDir .. "investment_config.json"
investmentStatsPath = configDir .. "investment_stats.json"
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
function getCurrentServer()
    local host = sampGetCurrentServerAddress()
    if not host or host == "" then host = sampGetServerAddress() end
    if host and host:find(":") then host = host:match("([^:]+)") end
    
    local servers = {
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
        ["80.66.82.22"] = "Drake", ["80.66.82.199"] = "Space",
        ["gilbert.arizona-rp.com"] = "Gilbert", ["christmas.arizona-rp.com"] = "Christmas",
        ["faraway.arizona-rp.com"] = "Faraway", ["queencreek.arizona-rp.com"] = "Queen-Creek",
        ["showlow.arizona-rp.com"] = "Show Low", ["prescott.arizona-rp.com"] = "Prescott",
        ["surprise.arizona-rp.com"] = "Surprise", ["holiday.arizona-rp.com"] = "Holiday",
        ["yava.arizona-rp.com"] = "Yava", ["kingman.arizona-rp.com"] = "Kingman",
        ["page.arizona-rp.com"] = "Page", ["glendale.arizona-rp.com"] = "Glendale",
        ["chandler.arizona-rp.com"] = "Chandler", ["saintrose.arizona-rp.com"] = "Saint-Rose",
        ["wednesday.arizona-rp.com"] = "Wednesday", ["scottdale.arizona-rp.com"] = "Scottdale",
        ["payson.arizona-rp.com"] = "Payson", ["winslow.arizona-rp.com"] = "Winslow",
        ["suncity.arizona-rp.com"] = "Sun-City", ["brainburg.arizona-rp.com"] = "Brainburg",
        ["mirage.arizona-rp.com"] = "Mirage", ["sedona.arizona-rp.com"] = "Sedona",
        ["redrock.arizona-rp.com"] = "Red-Rock", ["phoenix.arizona-rp.com"] = "Phoenix",
        ["mesa.arizona-rp.com"] = "Mesa", ["bumblebee.arizona-rp.com"] = "Bumble Bee",
        ["yuma.arizona-rp.com"] = "Yuma", ["love.arizona-rp.com"] = "Love",
        ["drake.arizona-rp.com"] = "Drake", ["casagrande.arizona-rp.com"] = "Casa-Grande",
        ["tucson.arizona-rp.com"] = "Tucson", ["space.arizona-rp.com"] = "Space"
    }
    
    if host and servers[host] then
        return servers[host]
    end
    return host or "Unknown"
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
end
function saveCustomPricesConfig()
    local data = {
        useCustomFarmPrices = useCustomFarmPrices,
        useCustomMinePrices = useCustomMinePrices,
        useCustomSawmillPrices = useCustomSawmillPrices,
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
function getMouseCoordinates()
    local x, y = getCursorPos()
    if not x then
        x, y = 0, 0
    end
    return x, y
end
-- Миграция данных между custom и обычным файлом
function migrateStatsBetweenModes(workType, fromCustom, toCustom)
    local sourcePath
    local destPath
    if fromCustom then
        sourcePath = getServerStatsPathCustom(workType)
        destPath = getServerStatsPath(workType)
    else
        sourcePath = getServerStatsPath(workType)
        destPath = getServerStatsPathCustom(workType)
    end
    
    if not doesFileExist(sourcePath) then return end
    
    local sf = io.open(sourcePath, "r")
    if not sf then return end
    local content = sf:read("*all")
    sf:close()
    
    local existingLogs = {}
    if doesFileExist(destPath) then
        local df = io.open(destPath, "r")
        if df then
            local destContent = df:read("*all")
            df:close()
            for time, resource, amount, value in destContent:gmatch('"time":(%d+),"resource":"([^"]+)","amount":(%d+),"value":(%d+)') do
                table.insert(existingLogs, {
                    time = tonumber(time),
                    resource = resource,
                    amount = tonumber(amount),
                    value = tonumber(value)
                })
            end
        end
    end
    
    local cfg = configs[workType]
    local prices = {}
    local pricePath = workType == WORK_TYPES.FARM and farmPricesPath or 
                       workType == WORK_TYPES.MINE and minePricesPath or sawmillPricesPath
    local pf = io.open(pricePath, "r")
    if pf then
        for line in pf:lines() do
            local k, v = line:match("^(.-)=(.*)$")
            if k and v then prices[k] = tonumber(v) end
        end
        pf:close()
    end
    
    for time, resource, amount in content:gmatch('"time":(%d+),"resource":"([^"]+)","amount":(%d+)') do
        local price = prices[resource] or cfg.defaultPrices[resource] or 0
        local value = tonumber(amount) * price
        table.insert(existingLogs, {
            time = tonumber(time),
            resource = resource,
            amount = tonumber(amount),
            value = value
        })
    end
    
    table.sort(existingLogs, function(a, b) return a.time < b.time end)
    
    local df = io.open(destPath, "w")
    if df then
        df:write("{\n  \"logs\": [\n")
        for i, log in ipairs(existingLogs) do
            df:write('    {"time":' .. log.time .. ',"resource":"' .. log.resource .. '","amount":' .. log.amount .. ',"value":' .. log.value .. '}')
            if i < #existingLogs then df:write(',\n') else df:write('\n') end
        end
        df:write('  ]\n}')
        df:close()
    end
    
    os.remove(sourcePath)
    
    if currentWork == workType then
        resourceLog = existingLogs
        loadedLogs = true
    end
end
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
goalsExpandedFarm = false
goalsExpandedMine = false
goalsExpandedSaw = false
goalsExpandedGeneral = false
pricesExpandedFarm = false
statsExpandedFarm = false
pricesExpandedMine = false
statsExpandedMine = false
pricesExpandedSaw = false
statsExpandedSaw = false
settingsExpandedTheme = false
settingsExpandedCustomTheme = false
settingsExpandedTelegram = false
settingsExpandedMenuColors = false
settingsExpandedTextColors = false
settingsExpandedElements = false
settingsExpandedNotify = false
settingsExpandedSound = false
settingsExpandedOverlay = false
settingsExpandedTimer = false
settingsExpandedOverlayStyle = false
settingsExpandedIncome = false
settingsExpandedAnim = false
local resourceLog = {}
local loadedLogs = false
local settings = {
    chatNotifyEnabled = false, goalSoundEnabled = true, pickupSoundEnabled = true,
    goalSoundVolume = 80, pickupSoundVolume = 80, rareSoundVolume = 80, coalSoundVolume = 80,
	pickupSoundFile = "pickup.wav",
    rareSoundFile = "rare.wav",
    coalSoundFile = "ugol.wav",
    achivSoundFile = "achiv.wav",
    farmOverlayEnabled = false, mineOverlayEnabled = false, sawmillOverlayEnabled = false, oilOverlayEnabled = false,
    undermineEnabled = false, underminelavkaEnabled = false, regularmineEnabled = false, farmEnabled = false, sawmillEnabled = false,
    overlayTimerEnabled = false, mineSpawnTimerEnabled = false, overlayStyle = 1, overlayColumns = 2, totalIncomeGoal = 1000000, talonAutoScanEnabled = true,
    overlayHideOnHover = false, overlayAutoTimer = false,
    smoothMenuEnabled = true, smoothWindowEnabled = true,
    menuKey = {17, 75} 
}
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
local lastServerMessageTime = {}  
local pendingResources = {}
local pendingResourcesBuffer = {}  
local changelogShown = false
changelogPath = configDir .. "changelog_shown.txt"
local changelogData = nil
changelogUrl = "https://raw.githubusercontent.com/Ryder8471/ArzResHelper/main/changelog.json"
local mineItemMappingByID = { ["596"] = "stone", ["597"] = "metal", ["598"] = "bronze", ["599"] = "silver", ["600"] = "gold", ["7425"] = "diamond", ["7424"] = "tkan", ["7423"] = "splav", ["7281"] = "materia", ["7426"] = "azbox" }
local mineItemAmounts = { stone = 6, metal = 3, bronze = 3, silver = 2, gold = 2, diamond = 1, tkan = 1, splav = 1, materia = 1, azbox = 1 }
local needSave = false
local needSaveColor = imgui.ImColor(250, 66, 66, 102):GetVec4()
local overlayConfigs = {
    [WORK_TYPES.FARM] = { x = 15, y = 300, w = 220, h = 160 },
    [WORK_TYPES.MINE] = { x = 15, y = 300, w = 280, h = 200 },
    [WORK_TYPES.SAWMILL] = { x = 15, y = 300, w = 220, h = 120 }
}
oilOverlayConfig = { x = 15, y = 300, w = 200, h = 170 }
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
local cb_farm = imgui.ImBool(false)
local cb_undermine = imgui.ImBool(false)
local cb_lavka = imgui.ImBool(false)
local cb_regular = imgui.ImBool(false)
local cb_chatNotify = imgui.ImBool(false)
local cb_goalSound = imgui.ImBool(false)
local cb_pickupSound = imgui.ImBool(false)
local cb_farm_overlay = imgui.ImBool(false)
cb_mine_overlay = imgui.ImBool(false)
cb_sawmill_overlay = imgui.ImBool(false)
cb_oil_overlay = imgui.ImBool(false)
cb_sawmill = imgui.ImBool(false)
goal_vol_slider = imgui.ImInt(80)
pickup_vol_slider = imgui.ImInt(80)
selectedDateIndexFarm = imgui.ImInt(0)
selectedDateIndexMine = imgui.ImInt(0)
imStatCalendarFarmDate = nil
imStatCalendarFarmYear = nil
imStatCalendarFarmMonth = nil
imStatCalendarMineDate = nil
imStatCalendarMineYear = nil
imStatCalendarMineMonth = nil
imStatCalendarSawDate = nil
imStatCalendarSawYear = nil
imStatCalendarSawMonth = nil
local farmStatsTab = imgui.ImInt(0)
local mineStatsTab = imgui.ImInt(0)
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
overlayStyleNames = {u8("Стандартный"), u8("Современный")}
overlayColumnsNames = {u8("1 столбец"), u8("2 столбца")}
cb_overlayColumns = imgui.ImInt(1)
cb_talonAutoScan = imgui.ImBool(true)
cb_overlayHideOnHover = imgui.ImBool(false)
cb_overlayAutoTimer = imgui.ImBool(false)
cb_smoothMenu = imgui.ImBool(true)
cb_smoothWindow = imgui.ImBool(true)
-- Кастомные цены
useCustomFarmPrices = false
useCustomMinePrices = false
useCustomSawmillPrices = false
cb_useCustomFarmPrices = imgui.ImBool(false)
cb_useCustomMinePrices = imgui.ImBool(false)
cb_useCustomSawmillPrices = imgui.ImBool(false)
customPriceEditFarm = {}
customPriceEditMine = {}
customPriceEditSaw = {}
customPricesConfigPath = configDir .. "custom_prices_config.json"
local lbTab = imgui.ImInt(0)
lbModeTab = imgui.ImInt(0)
lbServerFilter = imgui.ImInt(0)
imSelectedDate = imgui.ImInt(0)
local priceEdit = {}
local goalEdit = {}
local farmGoalEditCache = {}
local mineGoalEditCache = {}
local sawmillGoalEditCache = {}
-- ====== СИСТЕМА ДОСТИЖЕНИЙ ======
local ACHIEVEMENTS = {
    -- ====== ФЕРМА - ДНЕВНЫЕ ЦЕЛИ ======
    {
        id = "flax_goal",
        name = "Льняной магнат",
        desc = "Выполнить дневную цель по льну 20 раз",
        icon = fa.ICON_LEAF,
        category = "Ферма",
        target = 20,
        progress = 0,
        completed = false,
        check = function() return goalsReached["flax"] end,
    },
    {
        id = "cotton_goal",
        name = "Хлопковый барон",
        desc = "Выполнить дневную цель по хлопку 20 раз",
        icon = fa.ICON_LEAF,
        category = "Ферма",
        target = 20,
        progress = 0,
        completed = false,
        check = function() return goalsReached["cotton"] end,
    },
    {
        id = "water_goal",
        name = "Водяной",
        desc = "Выполнить дневную цель по воде 20 раз",
        icon = fa.ICON_LEAF,
        category = "Ферма",
        target = 20,
        progress = 0,
        completed = false,
        check = function() return goalsReached["water"] end,
    },
    {
        id = "dye_goal",
        name = "Красительщик",
        desc = "Выполнить дневную цель по красителю 20 раз",
        icon = fa.ICON_LEAF,
        category = "Ферма",
        target = 20,
        progress = 0,
        completed = false,
        check = function() return goalsReached["dye"] end,
    },
    {
        id = "rare_tkan_goal",
        name = "Тканевый охотник",
        desc = "Выполнить дневную цель по редкой ткани 20 раз",
        icon = fa.ICON_LEAF,
        category = "Ферма",
        target = 20,
        progress = 0,
        completed = false,
        check = function() return goalsReached["rare_tkan"] end,
    },
    {
        id = "coal_goal",
        name = "Угольный барон",
        desc = "Выполнить дневную цель по углю 20 раз",
        icon = fa.ICON_LEAF,
        category = "Ферма",
        target = 20,
        progress = 0,
        completed = false,
        check = function() return goalsReached["coal"] end,
    },
    
    -- ====== ШАХТА - ДНЕВНЫЕ ЦЕЛИ ======
    {
        id = "stone_goal",
        name = "Каменный человек",
        desc = "Выполнить дневную цель по камню 20 раз",
        icon = fa.ICON_GAVEL,
        category = "Шахта",
        target = 20,
        progress = 0,
        completed = false,
        check = function() return goalsReached["stone"] end,
    },
    {
        id = "metal_goal",
        name = "Металлург",
        desc = "Выполнить дневную цель по металлу 20 раз",
        icon = fa.ICON_GAVEL,
        category = "Шахта",
        target = 20,
        progress = 0,
        completed = false,
        check = function() return goalsReached["metal"] end,
    },
    {
        id = "bronze_goal",
        name = "Бронзовых дел мастер",
        desc = "Выполнить дневную цель по бронзе 20 раз",
        icon = fa.ICON_GAVEL,
        category = "Шахта",
        target = 20,
        progress = 0,
        completed = false,
        check = function() return goalsReached["bronze"] end,
    },
    {
        id = "silver_goal",
        name = "Серебряный стрелок",
        desc = "Выполнить дневную цель по серебру 20 раз",
        icon = fa.ICON_GAVEL,
        category = "Шахта",
        target = 20,
        progress = 0,
        completed = false,
        check = function() return goalsReached["silver"] end,
    },
    {
        id = "gold_goal",
        name = "Золотоискатель",
        desc = "Выполнить дневную цель по золоту 20 раз",
        icon = fa.ICON_GAVEL,
        category = "Шахта",
        target = 20,
        progress = 0,
        completed = false,
        check = function() return goalsReached["gold"] end,
    },
    {
        id = "diamond_goal",
        name = "Алмазный охотник",
        desc = "Выполнить дневную цель по алмазным камням 20 раз",
        icon = fa.ICON_GAVEL,
        category = "Шахта",
        target = 20,
        progress = 0,
        completed = false,
        check = function() return goalsReached["diamond"] end,
    },
    {
        id = "tkan_goal",
        name = "Тканевый шахтёр",
        desc = "Выполнить дневную цель по прочной ткани 20 раз",
        icon = fa.ICON_GAVEL,
        category = "Шахта",
        target = 20,
        progress = 0,
        completed = false,
        check = function() return goalsReached["tkan"] end,
    },
    {
        id = "splav_goal",
        name = "Сплавщик",
        desc = "Выполнить дневную цель по шахтёрскому сплаву 20 раз",
        icon = fa.ICON_GAVEL,
        category = "Шахта",
        target = 20,
        progress = 0,
        completed = false,
        check = function() return goalsReached["splav"] end,
    },
    {
        id = "materia_goal",
        name = "Тёмный маг",
        desc = "Выполнить дневную цель по тёмной материи 10 раз",
        icon = fa.ICON_GAVEL,
        category = "Шахта",
        target = 10,
        progress = 0,
        completed = false,
        check = function() return goalsReached["materia"] end,
    },
    {
        id = "azbox_goal",
        name = "Ларечный охотник",
        desc = "Выполнить дневную цель по ларцам с AZ-монетами 20 раз",
        icon = fa.ICON_GAVEL,
        category = "Шахта",
        target = 20,
        progress = 0,
        completed = false,
        check = function() return goalsReached["azbox"] end,
    },
    
    -- ====== ЛЕСОПИЛКА - ДНЕВНЫЕ ЦЕЛИ ======
    {
        id = "firewood_goal",
        name = "Дровосек",
        desc = "Выполнить дневную цель по дровам 20 раз",
        icon = fa.ICON_TREE,
        category = "Лесопилка",
        target = 20,
        progress = 0,
        completed = false,
        check = function() return goalsReached["firewood"] end,
    },
    {
        id = "quality_wood_goal",
        name = "Краснодеревщик",
        desc = "Выполнить дневную цель по древесине высшего качества 20 раз",
        icon = fa.ICON_TREE,
        category = "Лесопилка",
        target = 20,
        progress = 0,
        completed = false,
        check = function() return goalsReached["quality_wood"] end,
    },
    
    -- ====== КОЛЛЕКЦИОНЕРЫ - ФЕРМА ======
    {
        id = "flax_collector",
        name = "Льняной коллекционер",
        desc = "Добыть 100.000 льна за всё время",
        icon = fa.ICON_LEAF,
        category = "Ферма",
        target = 100000,
        progress = 0,
        completed = false,
        check = nil,
    },
    {
        id = "cotton_collector",
        name = "Хлопковый сборщик",
        desc = "Добыть 100.000 хлопка за всё время",
        icon = fa.ICON_LEAF,
        category = "Ферма",
        target = 100000,
        progress = 0,
        completed = false,
        check = nil,
    },
    {
        id = "rare_tkan_collector",
        name = "Тканевый накопитель",
        desc = "Добыть 10.000 редкой ткани за всё время",
        icon = fa.ICON_LEAF,
        category = "Ферма",
        target = 10000,
        progress = 0,
        completed = false,
        check = nil,
    },
    {
        id = "water_collector",
        name = "Водонос",
        desc = "Добыть 5.000 воды за всё время",
        icon = fa.ICON_LEAF,
        category = "Ферма",
        target = 5000,
        progress = 0,
        completed = false,
        check = nil,
    },
    {
        id = "dye_collector",
        name = "Красильный цех",
        desc = "Добыть 5.000 красителя за всё время",
        icon = fa.ICON_LEAF,
        category = "Ферма",
        target = 5000,
        progress = 0,
        completed = false,
        check = nil,
    },
    {
        id = "coal_collector",
        name = "Угольный король",
        desc = "Добыть 2.500 угля за всё время",
        icon = fa.ICON_LEAF,
        category = "Ферма",
        target = 2500,
        progress = 0,
        completed = false,
        check = nil,
    },
    
    -- ====== КОЛЛЕКЦИОНЕРЫ - ШАХТА ======
    {
        id = "stone_collector",
        name = "Каменный гигант",
        desc = "Добыть 10.000 камня за всё время",
        icon = fa.ICON_GAVEL,
        category = "Шахта",
        target = 10000,
        progress = 0,
        completed = false,
        check = nil,
    },
    {
        id = "metal_collector",
        name = "Металлический запас",
        desc = "Добыть 7.500 металла за всё время",
        icon = fa.ICON_GAVEL,
        category = "Шахта",
        target = 7500,
        progress = 0,
        completed = false,
        check = nil,
    },
    {
        id = "bronze_collector",
        name = "Бронзовая коллекция",
        desc = "Добыть 5.000 бронзы за всё время",
        icon = fa.ICON_GAVEL,
        category = "Шахта",
        target = 5000,
        progress = 0,
        completed = false,
        check = nil,
    },
    {
        id = "silver_collector",
        name = "Серебряный запас",
        desc = "Добыть 3.000 серебра за всё время",
        icon = fa.ICON_GAVEL,
        category = "Шахта",
        target = 3000,
        progress = 0,
        completed = false,
        check = nil,
    },
    {
        id = "gold_collector",
        name = "Золотой запас",
        desc = "Добыть 3.000 золота за всё время",
        icon = fa.ICON_GAVEL,
        category = "Шахта",
        target = 3000,
        progress = 0,
        completed = false,
        check = nil,
    },
    {
        id = "diamond_collector",
        name = "Алмазный фонд",
        desc = "Добыть 1.000 алмазных камней за всё время",
        icon = fa.ICON_GAVEL,
        category = "Шахта",
        target = 1000,
        progress = 0,
        completed = false,
        check = nil,
    },
    {
        id = "tkan_collector",
        name = "Прочная коллекция",
        desc = "Добыть 100 прочной ткани за всё время",
        icon = fa.ICON_GAVEL,
        category = "Шахта",
        target = 100,
        progress = 0,
        completed = false,
        check = nil,
    },
    {
        id = "splav_collector",
        name = "Сплавной запас",
        desc = "Добыть 100 шахтёрского сплава за всё время",
        icon = fa.ICON_GAVEL,
        category = "Шахта",
        target = 100,
        progress = 0,
        completed = false,
        check = nil,
    },
    {
        id = "materia_collector",
        name = "Тёмный резерв",
        desc = "Добыть 60 тёмной материи за всё время",
        icon = fa.ICON_GAVEL,
        category = "Шахта",
        target = 60,
        progress = 0,
        completed = false,
        check = nil,
    },
    {
        id = "azbox_collector",
        name = "Ларечный склад",
        desc = "Добыть 100 ларцов с AZ-монетами за всё время",
        icon = fa.ICON_GAVEL,
        category = "Шахта",
        target = 100,
        progress = 0,
        completed = false,
        check = nil,
    },
    
    -- ====== КОЛЛЕКЦИОНЕРЫ - ЛЕСОПИЛКА ======
    {
        id = "firewood_collector",
        name = "Дровяной склад",
        desc = "Нарубить 200.000.000 дров за всё время",
        icon = fa.ICON_TREE,
        category = "Лесопилка",
        target = 200000000,
        progress = 0,
        completed = false,
        check = nil,
    },
    {
        id = "quality_wood_collector",
        name = "Элитный лесоруб",
        desc = "Добыть 10.000 древесины высшего качества за всё время",
        icon = fa.ICON_TREE,
        category = "Лесопилка",
        target = 10000,
        progress = 0,
        completed = false,
        check = nil,
    },
    
    -- ====== ЗАРАБОТОК ======
    {
        id = "farmer_pro",
        name = "Фермер-профессионал",
        desc = "Заработать 7.500.000.000$ на ферме за всё время",
        icon = fa.ICON_LEAF,
        category = "Ферма",
        target = 7500000000,
        progress = 0,
        completed = false,
        check = nil,
    },
    {
        id = "miner_pro",
        name = "Шахтёр-профессионал",
        desc = "Заработать 10.000.000.000$ в шахте за всё время",
        icon = fa.ICON_GAVEL,
        category = "Шахта",
        target = 10000000000,
        progress = 0,
        completed = false,
        check = nil,
    },
    {
        id = "sawmill_pro",
        name = "Лесопилка-профи",
        desc = "Заработать 5.000.000.000$ на лесопилке за всё время",
        icon = fa.ICON_TREE,
        category = "Лесопилка",
        target = 5000000000,
        progress = 0,
        completed = false,
        check = nil,
    },
    
	    -- ====== ITEM MARKET ======
    {
        id = "im_1b",
        name = "Бизнесмен",
        desc = "Заработать 1.000.000.000$ на аренде предметов",
        icon = fa.ICON_SHOPPING_CART,
        category = "Item Market",
        target = 1000000000,
        progress = 0,
        completed = false,
        check = nil,
    },
    {
        id = "im_2_5b",
        name = "Магнат",
        desc = "Заработать 2.500.000.000$ на аренде предметов",
        icon = fa.ICON_SHOPPING_CART,
        category = "Item Market",
        target = 2500000000,
        progress = 0,
        completed = false,
        check = nil,
    },
    {
        id = "im_5b",
        name = "Олигарх",
        desc = "Заработать 5.000.000.000$ на аренде предметов",
        icon = fa.ICON_SHOPPING_CART,
        category = "Item Market",
        target = 5000000000,
        progress = 0,
        completed = false,
        check = nil,
    },
	
    -- ====== ОБЩИЕ ======
    {
        id = "millionaire",
        name = "Миллиардер",
        desc = "Общий доход 15.000.000.000$",
        icon = fa.ICON_BULLSEYE,
        category = "Общие",
        target = 15000000000,
        progress = 0,
        completed = false,
        check = nil,
    },
    {
        id = "goal_hunter",
        name = "Охотник за целями",
        desc = "Выполнить 100 любых дневных целей",
        icon = fa.ICON_BULLSEYE,
        category = "Общие",
        target = 100,
        progress = 0,
        completed = false,
        check = nil,
    },
}
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
    return string.format("%04d-%02d-%02d", y, m, d)
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
local function getWeekStats()
    if cachedWeekStats and os.time() - cachedWeekTime < 5 then
        return cachedWeekStats
    end
    
    local todayDate = getGameDate()
    local year, month, day = todayDate:match("(%d+)-(%d+)-(%d+)")
    year, month, day = tonumber(year), tonumber(month), tonumber(day)
    
    local mskTime = getMoscowTime()
local mskHour = tonumber(os.date("%H", mskTime))
local currentDay = tonumber(os.date("%w", mskTime))
    if currentDay == 0 then currentDay = 7 end 
    
    if mskHour < 5 then
        currentDay = currentDay - 1
        if currentDay == 0 then currentDay = 7 end
    end
    
    local result = {total = 0}
    for _, k in ipairs(config.resourceOrder) do result[k] = 0 end
    
    for i = 0, currentDay - 1 do
        local date = getGameDate(os.time() - i * 86400)
        local dayData = getDayStats(date)
        for _, k in ipairs(config.resourceOrder) do 
            result[k] = result[k] + (dayData[k] or 0) 
        end
        result.total = result.total + dayData.total
    end
    
    cachedWeekStats = result
    cachedWeekTime = os.time()
    return result
end
local function getAvailableDates()
    if not config then return {} end
    local dates = {}
    local seen = {}
    for _, log in ipairs(resourceLog) do
        local d = getGameDate(log.time)
        if not seen[d] then seen[d] = true; table.insert(dates, d) end
    end
    local today = getGameDate()
    if not seen[today] then table.insert(dates, today) end
    table.sort(dates, function(a, b) return a > b end)
    return dates
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
    local data = { date = getGameDate(), startTime = gameSessionStartTime }
    local file = io.open(sessionStatePath, "w")
    if file then file:write(encodeJson(data)); file:close() end
end
function loadSessionState()
    local file = io.open(sessionStatePath, "r")
    if not file then return nil, nil end
    local data = decodeJson(file:read("*all"))
    file:close()
    if data then return data.date, data.startTime end
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
    
    if period == "daily" then
        local yesterdayTime = os.time() - 86400
        local yesterdayDate = os.date("%d.%m.%Y", yesterdayTime)
        report = "&#128197; <b>Ежедневный отчёт ResHelper</b>\n"
        report = report .. "&#128338; " .. yesterdayDate .. "\n"
        report = report .. "&#128338; Отправлено: " .. currentDateStr .. " | " .. timeStr .. " (МСК)\n\n"
    else
        local mskWday = tonumber(os.date("%w", mskTime))
        if mskWday == 0 then mskWday = 7 end
        local lastSundayTime = os.time() - (mskWday * 86400)
        local lastMondayTime = lastSundayTime - (6 * 86400)
        local lastMonday = os.date("%d.%m.%Y", lastMondayTime)
        local lastSunday = os.date("%d.%m.%Y", lastSundayTime)
        report = "&#128197; <b>Недельный отчёт ResHelper</b>\n"
        report = report .. "&#128338; Период: " .. lastMonday .. " - " .. lastSunday .. "\n"
        report = report .. "&#128338; Отправлено: " .. currentDateStr .. " | " .. timeStr .. " (МСК)\n\n"
    end
    
    local totalAll = 0
    
    report = report .. "&#127793; <b>[Ферма]</b>\n"
    for _, k in ipairs(configs[WORK_TYPES.FARM].resourceOrder) do
        report = report .. "- " .. configs[WORK_TYPES.FARM].resourceNames[k] .. ": <b>" .. formatNumber(farmData[k] or 0) .. " шт.</b>\n"
    end
    report = report .. "&#128176; Доход: <b>" .. formatNumber(farmData.total) .. "$</b>\n\n"
    totalAll = totalAll + farmData.total
    
    report = report .. "&#9939; <b>[Шахта]</b>\n"
    for _, k in ipairs(configs[WORK_TYPES.MINE].resourceOrder) do
        report = report .. "- " .. configs[WORK_TYPES.MINE].resourceNames[k] .. ": <b>" .. formatNumber(mineData[k] or 0) .. " шт.</b>\n"
    end
    report = report .. "&#128176; Доход: <b>" .. formatNumber(mineData.total) .. "$</b>\n\n"
    totalAll = totalAll + mineData.total
    
    report = report .. "&#127795; <b>[Лесопилка]</b>\n"
    for _, k in ipairs(configs[WORK_TYPES.SAWMILL].resourceOrder) do
        report = report .. "- " .. configs[WORK_TYPES.SAWMILL].resourceNames[k] .. ": <b>" .. formatNumber(sawmillData[k] or 0) .. " шт.</b>\n"
    end
    report = report .. "&#128176; Доход: <b>" .. formatNumber(sawmillData.total) .. "$</b>\n\n"
    totalAll = totalAll + sawmillData.total
    
    -- Item Market
    local imAmount = 0
    if period == "daily" then
        local yesterdayDate = getGameDate(os.time() - 86400)
        for _, log in ipairs(itemMarketLog) do
            if getGameDate(log.time) == yesterdayDate then
                imAmount = imAmount + log.amount
            end
        end
    else
        local mskWday = tonumber(os.date("%w", mskTime))
        if mskWday == 0 then mskWday = 7 end
        local lastSundayTime = os.time() - (mskWday * 86400)
        local lastMondayTime = lastSundayTime - (6 * 86400)
        for _, log in ipairs(itemMarketLog) do
            local logDate = getGameDate(log.time)
            if logDate >= getGameDate(lastMondayTime) and logDate <= getGameDate(lastSundayTime) then
                imAmount = imAmount + log.amount
            end
        end
    end
    
    report = report .. "&#128717; <b>[Item Market]</b>\n"
    report = report .. "&#128176; Доход: <b>" .. formatNumber(imAmount) .. "$</b>\n\n"
    totalAll = totalAll + imAmount
    
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
    local maxStacks = {
        flax = 6000, cotton = 6000, rare_tkan = 5000, water = 1000, dye = 100, coal = 5000,
        stone = 6000, metal = 6000, bronze = 6000, silver = 6000, gold = 6000,
        diamond = 200, tkan = 200, splav = 200, materia = 50, azbox = 100,
        firewood = 1000000, quality_wood = 500,
        talon_az = 10000
    }
    return maxStacks[resKey] or 100
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
            local total = 0
            for _, v in ipairs(slots) do total = total + v end
            inventoryCache[itemId] = {total}
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
        sampAddChatMessage("{00FF00}[ResHelher] Сканирование завершено! Найдено в инвентаре:", -1)
        for _, msg in ipairs(foundItems) do
            sampAddChatMessage("{FFFFFF}  " .. msg, -1)
        end
        sampAddChatMessage("{FFA500}[ResHelher] База установлена. Учитывается только новая добыча.", -1)
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
        sampAddChatMessage(SCRIPT_PREFIX .. "Авто-сканирование завершено! Найдено талонов AZ: " .. talonAmount .. " шт. Учёт AZ в пейдеях активирован.", SCRIPT_COLOR)
        sampAddChatMessage(SCRIPT_PREFIX .. "Вы можете отключить авто-сканирование в настройках.", SCRIPT_COLOR)
    end
    scanState.isTalonScan = false
    sampCloseCurrentDialogWithButton(0)
end
-- ====== ФУНКЦИИ ДОСТИЖЕНИЙ ======
function saveAchievements()
    local data = {}
    for _, ach in ipairs(ACHIEVEMENTS) do
        table.insert(data, {
            id = ach.id,
            progress = ach.progress,
            completed = ach.completed,
        })
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
    if not file then return end
    local content = file:read("*all")
    file:close()
    local data = decodeJson(content)
    if not data then return end
    
    if data.totalCompletedGoals then
        totalCompletedGoals = data.totalCompletedGoals
    end
    
    if data.achievements then
        for _, saved in ipairs(data.achievements) do
            for _, ach in ipairs(ACHIEVEMENTS) do
                if ach.id == saved.id then
                    ach.progress = saved.progress or 0
                    ach.completed = saved.completed or false
                    break
                end
            end
        end
    end
end
local processedGoalAchievements = {}
function checkAchievements()
    local earned = false
    for _, ach in ipairs(ACHIEVEMENTS) do
        if not ach.completed then
            local shouldProgress = false
            if ach.check then
                
                if ach.id:find("_goal") then
                    local goalName = ach.id:gsub("_goal","")
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
function updateProgressAchievements()
    for _, ach in ipairs(ACHIEVEMENTS) do
        if not ach.completed and ach.check == nil then
            local newProgress = 0
            
            if ach.id == "farmer_pro" then
                -- Сумма дохода с фермы за всё время (из файла статистики)
                local farmFile = io.open(getServerStatsPath(WORK_TYPES.FARM), "r")
                if farmFile then
                    local content = farmFile:read("*all")
                    farmFile:close()
                    local farmPrices = {}
                    local pf = io.open(farmPricesPath, "r")
                    if pf then
                        for line in pf:lines() do
                            local k, v = line:match("^(.-)=(.*)$")
                            if k and v then farmPrices[k] = tonumber(v) end
                        end
                        pf:close()
                    end
                    for resource, amount in content:gmatch('"resource":"([^"]+)","amount":(%d+)') do
                        local price = farmPrices[resource] or configs[WORK_TYPES.FARM].defaultPrices[resource] or 0
                        newProgress = newProgress + (tonumber(amount) * price)
                    end
                end
            elseif ach.id == "miner_pro" then
                local mineFile = io.open(getServerStatsPath(WORK_TYPES.MINE), "r")
                if mineFile then
                    local content = mineFile:read("*all")
                    mineFile:close()
                    local minePrices = {}
                    local pf = io.open(minePricesPath, "r")
                    if pf then
                        for line in pf:lines() do
                            local k, v = line:match("^(.-)=(.*)$")
                            if k and v then minePrices[k] = tonumber(v) end
                        end
                        pf:close()
                    end
                    for resource, amount in content:gmatch('"resource":"([^"]+)","amount":(%d+)') do
                        local price = minePrices[resource] or configs[WORK_TYPES.MINE].defaultPrices[resource] or 0
                        newProgress = newProgress + (tonumber(amount) * price)
                    end
                end
            elseif ach.id == "sawmill_pro" then
                local sawFile = io.open(getServerStatsPath(WORK_TYPES.SAWMILL), "r")
                if sawFile then
                    local content = sawFile:read("*all")
                    sawFile:close()
                    local sawPrices = {}
                    local pf = io.open(sawmillPricesPath, "r")
                    if pf then
                        for line in pf:lines() do
                            local k, v = line:match("^(.-)=(.*)$")
                            if k and v then sawPrices[k] = tonumber(v) end
                        end
                        pf:close()
                    end
                    for resource, amount in content:gmatch('"resource":"([^"]+)","amount":(%d+)') do
                        local price = sawPrices[resource] or configs[WORK_TYPES.SAWMILL].defaultPrices[resource] or 0
                        newProgress = newProgress + (tonumber(amount) * price)
                    end
                end
                        elseif ach.id == "millionaire" then
                -- Суммируем доход со всех трёх работ
                local totalIncome = 0
                
                -- Ферма
                local farmFile = io.open(getServerStatsPath(WORK_TYPES.FARM), "r")
                if farmFile then
                    local content = farmFile:read("*all")
                    farmFile:close()
                    local farmPrices = {}
                    local pf = io.open(farmPricesPath, "r")
                    if pf then
                        for line in pf:lines() do
                            local k, v = line:match("^(.-)=(.*)$")
                            if k and v then farmPrices[k] = tonumber(v) end
                        end
                        pf:close()
                    end
                    for resource, amount in content:gmatch('"resource":"([^"]+)","amount":(%d+)') do
                        local price = farmPrices[resource] or configs[WORK_TYPES.FARM].defaultPrices[resource] or 0
                        totalIncome = totalIncome + (tonumber(amount) * price)
                    end
                end
                
                -- Шахта
                local mineFile = io.open(getServerStatsPath(WORK_TYPES.MINE), "r")
                if mineFile then
                    local content = mineFile:read("*all")
                    mineFile:close()
                    local minePrices = {}
                    local pf = io.open(minePricesPath, "r")
                    if pf then
                        for line in pf:lines() do
                            local k, v = line:match("^(.-)=(.*)$")
                            if k and v then minePrices[k] = tonumber(v) end
                        end
                        pf:close()
                    end
                    for resource, amount in content:gmatch('"resource":"([^"]+)","amount":(%d+)') do
                        local price = minePrices[resource] or configs[WORK_TYPES.MINE].defaultPrices[resource] or 0
                        totalIncome = totalIncome + (tonumber(amount) * price)
                    end
                end
                
                -- Лесопилка
                local sawFile = io.open(getServerStatsPath(WORK_TYPES.SAWMILL), "r")
                if sawFile then
                    local content = sawFile:read("*all")
                    sawFile:close()
                    local sawPrices = {}
                    local pf = io.open(sawmillPricesPath, "r")
                    if pf then
                        for line in pf:lines() do
                            local k, v = line:match("^(.-)=(.*)$")
                            if k and v then sawPrices[k] = tonumber(v) end
                        end
                        pf:close()
                    end
                    for resource, amount in content:gmatch('"resource":"([^"]+)","amount":(%d+)') do
                        local price = sawPrices[resource] or configs[WORK_TYPES.SAWMILL].defaultPrices[resource] or 0
                        totalIncome = totalIncome + (tonumber(amount) * price)
                    end
                end
				
				-- Item Market
                for _, log in ipairs(itemMarketLog) do
                    totalIncome = totalIncome + log.amount
                end
                
                newProgress = totalIncome
            -- Коллекционеры - Ферма
            elseif ach.id == "flax_collector" then
                newProgress = getTotalResource("flax")
            elseif ach.id == "cotton_collector" then
                newProgress = getTotalResource("cotton")
            elseif ach.id == "rare_tkan_collector" then
                newProgress = getTotalResource("rare_tkan")
            elseif ach.id == "water_collector" then
                newProgress = getTotalResource("water")
            elseif ach.id == "dye_collector" then
                newProgress = getTotalResource("dye")
            elseif ach.id == "coal_collector" then
                newProgress = getTotalResource("coal")
            -- Коллекционеры - Шахта
            elseif ach.id == "stone_collector" then
                newProgress = getTotalResource("stone")
            elseif ach.id == "metal_collector" then
                newProgress = getTotalResource("metal")
            elseif ach.id == "bronze_collector" then
                newProgress = getTotalResource("bronze")
            elseif ach.id == "silver_collector" then
                newProgress = getTotalResource("silver")
            elseif ach.id == "gold_collector" then
                newProgress = getTotalResource("gold")
            elseif ach.id == "diamond_collector" then
                newProgress = getTotalResource("diamond")
            elseif ach.id == "tkan_collector" then
                newProgress = getTotalResource("tkan")
            elseif ach.id == "splav_collector" then
                newProgress = getTotalResource("splav")
            elseif ach.id == "materia_collector" then
                newProgress = getTotalResource("materia")
            elseif ach.id == "azbox_collector" then
                newProgress = getTotalResource("azbox")
            -- Коллекционеры - Лесопилка
            elseif ach.id == "firewood_collector" then
                newProgress = getTotalResource("firewood")
            elseif ach.id == "quality_wood_collector" then
                newProgress = getTotalResource("quality_wood")
			elseif ach.id == "im_1b" then
                newProgress = getTotalItemMarketIncome()
            elseif ach.id == "im_2_5b" then
                newProgress = getTotalItemMarketIncome()
            elseif ach.id == "im_5b" then
                newProgress = getTotalItemMarketIncome()
            elseif ach.id == "goal_hunter" then
                newProgress = totalCompletedGoals
            end
            
            ach.progress = newProgress
            if ach.progress >= ach.target and ach.target > 0 and not ach.completed then
                ach.completed = true
                if settings.goalSoundEnabled then playSoundFile("achiv.wav", settings.goalSoundVolume) end
                if settings.chatNotifyEnabled then
                    sampAddChatMessage(SCRIPT_PREFIX .. "Достижение \"" .. ach.name .. "\" выполнено!", SCRIPT_COLOR)
                end
                local achDesc = ach.name
					if ach.id == "farmer_pro" or ach.id == "miner_pro" or ach.id == "sawmill_pro" or ach.id == "millionaire" or ach.id == "im_1b" or ach.id == "im_2_5b" or ach.id == "im_5b" then
						achDesc = ach.name .. " - " .. formatNumber(ach.target) .. "$"
					elseif ach.id:find("_collector$") then
						achDesc = ach.name .. " - " .. formatNumber(ach.target) .. " шт."
					elseif ach.id:find("_goal$") then
						achDesc = ach.name .. " - выполнено " .. ach.progress .. "/" .. ach.target .. " раз"
				end
					showAchievementNotification(u8("Достижение выполнено!"), achDesc, ach.icon)
            end
            saveAchievements()
        end
    end
end
-- ====== СОХРАНЕНИЕ/ЗАГРУЗКА БАЗЫ ИНВЕНТАРЯ ======
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
        local total = 0
        for amount in amounts:gmatch("%d+") do
            total = total + tonumber(amount)
        end
        inventoryCache[tonumber(itemId)] = {total}
    end
    scanState.scanned = true
    ignoreInventoryUntil = os.time() + 3
end
function saveThemeConfig()
    local data = { 
        theme = currentTheme,
        useCustom = useCustomTheme 
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
local function hexToImVec4(hex)
    local a = math.floor(hex / 0x1000000) / 255
    local r = math.floor((hex % 0x1000000) / 0x10000) / 255
    local g = math.floor((hex % 0x10000) / 0x100) / 255
    local b = math.floor(hex % 0x100) / 255
    return imgui.ImVec4(r, g, b, a)
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
function getItemMarketWeekIncome()
    if cachedIMWeekTime and os.time() - cachedIMWeekTime < 5 then
        return itemMarketWeekIncome
    end
    
    local mskTime = getMoscowTime()
    local mskWday = tonumber(os.date("%w", mskTime))
    if mskWday == 0 then mskWday = 7 end
    
    -- Понедельник текущей недели
    local daysSinceMonday = mskWday - 1
    local mondayTime = os.time() - (daysSinceMonday * 86400)
    local mondayDate = getGameDate(mondayTime)
    
    itemMarketWeekIncome = 0
    
    -- Считаем с понедельника по сегодня
    for i = 0, daysSinceMonday do
        local date = getGameDate(os.time() - i * 86400)
        for _, log in ipairs(itemMarketLog) do
            if getGameDate(log.time) == date then
                itemMarketWeekIncome = itemMarketWeekIncome + log.amount
            end
        end
    end
    
    cachedIMWeekTime = os.time()
    return itemMarketWeekIncome
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
function loadGoalsForWorkType(workType)
    local cfg = configs[workType]
    local path
    if workType == WORK_TYPES.FARM then path = farmGoalsConfigPath
    elseif workType == WORK_TYPES.MINE then path = mineGoalsConfigPath
    else path = sawmillGoalsConfigPath end
    local file = io.open(path, "r")
    if not file then
        for _, k in ipairs(cfg.resourceOrder) do 
            goals[k] = cfg.defaultGoals[k]
            if not goalEdit[k] then goalEdit[k] = imgui.ImInt(cfg.defaultGoals[k]) end
            goalEdit[k].v = cfg.defaultGoals[k]
        end
        return
    end
    local content = file:read("*all")
    file:close()
    local data = decodeJson(content)
    if not data then
        for _, k in ipairs(cfg.resourceOrder) do 
            goals[k] = cfg.defaultGoals[k]
            if not goalEdit[k] then goalEdit[k] = imgui.ImInt(cfg.defaultGoals[k]) end
            goalEdit[k].v = cfg.defaultGoals[k]
        end
    else
        for _, k in ipairs(cfg.resourceOrder) do
            goals[k] = data[k] or cfg.defaultGoals[k]
            if not goalEdit[k] then goalEdit[k] = imgui.ImInt(goals[k]) end
            goalEdit[k].v = goals[k]
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
    local dir = getWorkingDirectory().."/ResHelper/files/changelog.json"
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
	file:write("overlayHideOnHover=" .. (settings.overlayHideOnHover and "1" or "0") .. "\n")
	file:write("overlayAutoTimer=" .. (settings.overlayAutoTimer and "1" or "0") .. "\n")
	file:write("smoothMenuEnabled=" .. (settings.smoothMenuEnabled and "1" or "0") .. "\n")
	file:write("smoothWindowEnabled=" .. (settings.smoothWindowEnabled and "1" or "0") .. "\n")
	file:write("menuKey=" .. table.concat(settings.menuKey, ",") .. "\n")
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
                    elseif k == "sawmillEnabled" then settings.sawmillEnabled = (v == "1") 
                    elseif k == "mineSpawnTimerEnabled" then settings.mineSpawnTimerEnabled = (v == "1")
                    elseif k == "overlayStyle" then settings.overlayStyle = tonumber(v) or 1
					elseif k == "talonAutoScanEnabled" then settings.talonAutoScanEnabled = (v == "1")
                    elseif k == "overlayHideOnHover" then settings.overlayHideOnHover = (v == "1")
					elseif k == "overlayAutoTimer" then settings.overlayAutoTimer = (v == "1")
					elseif k == "smoothMenuEnabled" then settings.smoothMenuEnabled = (v == "1")
					elseif k == "smoothWindowEnabled" then settings.smoothWindowEnabled = (v == "1")
					                    elseif k == "menuKey" then
                        local keys = {}
                        for key in v:gmatch("([^,]+)") do
                            table.insert(keys, tonumber(key))
                        end
                        if #keys > 0 then settings.menuKey = keys end
                    elseif k == "overlayColumns" then settings.overlayColumns = tonumber(v) or 2
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
                            
                            if resKey and maxStack then
                                -- Игнорируем аномально большие значения (баги/лаги)
                                if newAmount > maxStack * 2 then 
                                    break 
                                end
                                
                                -- Инициализируем кэш если нужно
                                if not inventoryCache[itemId] then 
                                    inventoryCache[itemId] = {0}
                                end
                                
                                -- Считаем СУММУ всех слотов в кэше
                                local slots = inventoryCache[itemId]
                                local oldTotal = 0
                                for _, sl in ipairs(slots) do oldTotal = oldTotal + sl end
                                
                                -- Вычисляем прирост
                                local added = newAmount - oldTotal
                                
                                if added > 0 and added <= maxStack then
                                    -- Реалистичный прирост - засчитываем
                                    pendingResources[resKey] = added
                                    -- Обновляем кэш: заменяем все слоты на один с текущим количеством
                                    inventoryCache[itemId] = {newAmount}
                                    pcall(saveInventoryBase)
                                    -- Если буфер уже ждёт - засчитываем сразу
                                    if pendingResourcesBuffer[resKey] then
                                        addResource(resKey, added)
                                        pendingResources[resKey] = nil
                                        pendingResourcesBuffer[resKey] = nil
                                    end
                                elseif added < 0 then
                                    -- Количество уменьшилось (выложил/продал) - просто обновляем кэш
                                    inventoryCache[itemId] = {newAmount}
                                    pcall(saveInventoryBase)
                                    pendingResources[resKey] = nil
                                else
                                    -- Без изменений или аномальный прирост - обновляем кэш без засчитывания
                                    if added > maxStack then
                                        pendingResources[resKey] = nil
                                    end
                                    inventoryCache[itemId] = {newAmount}
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
function sendToLeaderboard(period, mode)
    local _, playerId = sampGetPlayerIdByCharHandle(PLAYER_PED)
    local name = sampGetPlayerNickname(playerId)
    if not name or name == "" then return end
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
    
    -- Определяем сервер
    local serverName = "Unknown"
    local host = sampGetCurrentServerAddress()
    if not host or host == "" then host = sampGetServerAddress() end
    if host and host:find(":") then host = host:match("([^:]+)") end
    if host and host ~= "" then
        local servers = {
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
            ["80.66.82.22"] = "Drake", ["80.66.82.199"] = "Space",
            ["gilbert.arizona-rp.com"] = "Gilbert", ["christmas.arizona-rp.com"] = "Christmas",
            ["faraway.arizona-rp.com"] = "Faraway", ["queencreek.arizona-rp.com"] = "Queen-Creek",
            ["showlow.arizona-rp.com"] = "Show Low", ["prescott.arizona-rp.com"] = "Prescott",
            ["surprise.arizona-rp.com"] = "Surprise", ["holiday.arizona-rp.com"] = "Holiday",
            ["yava.arizona-rp.com"] = "Yava", ["kingman.arizona-rp.com"] = "Kingman",
            ["page.arizona-rp.com"] = "Page", ["glendale.arizona-rp.com"] = "Glendale",
            ["chandler.arizona-rp.com"] = "Chandler", ["saintrose.arizona-rp.com"] = "Saint-Rose",
            ["wednesday.arizona-rp.com"] = "Wednesday", ["scottdale.arizona-rp.com"] = "Scottdale",
            ["payson.arizona-rp.com"] = "Payson", ["winslow.arizona-rp.com"] = "Winslow",
            ["suncity.arizona-rp.com"] = "Sun-City", ["brainburg.arizona-rp.com"] = "Brainburg",
            ["mirage.arizona-rp.com"] = "Mirage", ["sedona.arizona-rp.com"] = "Sedona",
            ["redrock.arizona-rp.com"] = "Red-Rock", ["phoenix.arizona-rp.com"] = "Phoenix",
            ["mesa.arizona-rp.com"] = "Mesa", ["bumblebee.arizona-rp.com"] = "Bumble Bee",
            ["yuma.arizona-rp.com"] = "Yuma", ["love.arizona-rp.com"] = "Love",
            ["drake.arizona-rp.com"] = "Drake", ["casagrande.arizona-rp.com"] = "Casa-Grande",
            ["tucson.arizona-rp.com"] = "Tucson", ["space.arizona-rp.com"] = "Space"
        }
        serverName = servers[host] or host
    end
    
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
    
    local asyncReq = effil.thread(function(u)
        local req = require("requests")
        req.get(u)
    end)(url)
end
pricesRetryCount = pricesRetryCount or 0
pricesRetryPending = pricesRetryPending or false
pricesRetryAt = pricesRetryAt or 0
pricesRequestActive = pricesRequestActive or false
pricesRequestStartedAt = pricesRequestStartedAt or 0
local pricesMaxRetries = 5
local pricesRetryDelays = {3, 5, 10, 15, 30} -- в секундах
local function logPricesError(msg)
    local logFile = io.open(configDir .. "prices_error.log", "a")
    if logFile then
        logFile:write(os.date() .. " | " .. msg .. "\n")
        logFile:close()
    end
end
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
                        globalPrices = data
                        for k, v in pairs(globalPrices) do
                            if priceEdit[k] then priceEdit[k].v = v end
                            resourcePrices[k] = v
                        end
                        local today = getGameDate()
                        local pf = io.open(pricesStatePath, "w")
                        if pf then pf:write(today); pf:close() end
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
                    leaderboardCache[mode][period] = data
                    -- сохраняем в файл для офлайн-кэша
                    local cacheFile = io.open(tempFile:gsub(".json", "_cache.json"), "w")
                    if cacheFile then
                        cacheFile:write(content)
                        cacheFile:close()
                    end
                    if not silent then
                        sampAddChatMessage(SCRIPT_PREFIX .. "Рейтинг обновлён!", SCRIPT_COLOR)
                    end
                else
                    local logFile = io.open(configDir .. "leaderboard_error.log", "a")
                    if logFile then
                        logFile:write(os.date() .. " | mode=" .. mode .. " period=" .. period .. " | raw: " .. tostring(content):sub(1, 300) .. "\n")
                        logFile:close()
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
            if data then leaderboardCache.Income.Total = data end
        end
        loadLeaderboard("Total", "Income", true)
    end
    cache = leaderboardCache.Income and leaderboardCache.Income.Total
    if cache and #cache > 0 then
        local _, myId = sampGetPlayerIdByCharHandle(PLAYER_PED)
        local myName = sampGetPlayerNickname(myId)
        for i, entry in ipairs(cache) do
            if entry.name == myName then myOverallRank = i; myOverallAmount = entry.amount; return end
        end
        myOverallRank = -1
        myOverallAmount = nil
    end
end
function initCustomPrices()
    loadCustomPricesConfig()
end
function initStatsMigration()
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
    local serverNames = {
        "Holiday", "Prescott", "Faraway", "Christmas", "Queen-Creek", "Gilbert",
        "Page", "Yava", "Surprise", "Wednesday", "Chandler", "Glendale",
        "Show Low", "Sedona", "Payson", "Saint-Rose", "Sun-City", "Kingman",
        "Winslow", "Scottdale", "Red-Rock", "Brainburg", "Mirage", "Phoenix",
        "Mesa", "Tucson", "Yuma", "Casa-Grande", "Bumble Bee", "Love",
        "Drake", "Space"
    }
    for _, name in ipairs(serverNames) do
        local iconPath = dirml.."/ResHelper/files/server_icons/"..name..".png"
        if doesFileExist(iconPath) then
            serverIcons[name] = imgui.CreateTextureFromFile(iconPath)
        end
    end
end
function initSyncCheckboxes()
    cb_farm.v = settings.farmEnabled
    cb_undermine.v = settings.undermineEnabled
    cb_lavka.v = settings.underminelavkaEnabled
    cb_regular.v = settings.regularmineEnabled
    cb_chatNotify.v = settings.chatNotifyEnabled
    cb_goalSound.v = settings.goalSoundEnabled
    cb_pickupSound.v = settings.pickupSoundEnabled
    cb_farm_overlay.v = settings.farmOverlayEnabled
    cb_mine_overlay.v = settings.mineOverlayEnabled
    cb_overlay_timer.v = settings.overlayTimerEnabled
    totalGoalEdit.v = settings.totalIncomeGoal
    cb_sawmill_overlay.v = settings.sawmillOverlayEnabled
    cb_oil_overlay.v = settings.oilOverlayEnabled
    cb_sawmill.v = settings.sawmillEnabled
    goal_vol_slider.v = settings.goalSoundVolume
    cb_mineSpawnTimer.v = settings.mineSpawnTimerEnabled
    cb_overlayStyle.v = (settings.overlayStyle or 1) - 1
    cb_overlayColumns.v = (settings.overlayColumns or 2) - 1
    cb_talonAutoScan.v = settings.talonAutoScanEnabled
	cb_overlayHideOnHover.v = settings.overlayHideOnHover
	cb_overlayAutoTimer.v = settings.overlayAutoTimer
	cb_smoothMenu.v = (settings.smoothMenuEnabled ~= false)
	cb_smoothWindow.v = (settings.smoothWindowEnabled ~= false)
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
    if not inventoryCache[731] then
        inventoryCache[731] = {0}
    end
    sampAddChatMessage(string.format(SCRIPT_PREFIX.."ResHelper загружен! /rh - меню. Версия: %s", scr.version), SCRIPT_COLOR)
    if settings.talonAutoScanEnabled then
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
    local allModes = {"Farm", "Mine", "Sawmill", "IM"}
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
            local allModes = {"Farm", "Mine", "Sawmill", "IM"}
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
    if menuActive and not sampIsChatInputActive() then 
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
function runMainLoop()
    local lastTgQueueProcess = 0
    local lastDailyReportDate, lastWeeklyReportKey = loadTgReportState()
    local lastLbDailyDate, lastLbWeeklyDate = loadLbState()
    
    while true do
        wait(0)
		if pricesRetryPending and os.time() >= pricesRetryAt then
            pricesRetryPending = false
            loadGlobalPrices()
        elseif pricesRequestActive and os.time() - pricesRequestStartedAt > 15 then
            logPricesError("timeout: downloadUrlToFile callback did not fire")
            pricesScheduleRetryOrFail()
        end
        lastTgQueueProcess = processTgQueueIfNeeded(lastTgQueueProcess)
        if pendingScan and not scanState.active then
            local workToScan = pendingScan
            pendingScan = nil
            if currentWork == workToScan then startInventoryScan() end
        end
        lastDailyReportDate, lastWeeklyReportKey = processTelegramReports(lastDailyReportDate, lastWeeklyReportKey)
        lastLbDailyDate, lastLbWeeklyDate = processLeaderboard(lastLbDailyDate, lastLbWeeklyDate)
        if not achievementUpdateTime or os.time() - achievementUpdateTime >= 60 then
            achievementUpdateTime = os.time()
            updateProgressAchievements()
        end
        processMenuToggle()
        if not mainWin.v and imgui.ShowCursor then imgui.ShowCursor = false end
        if not sampIsChatInputActive() and not sampIsDialogActive() then binderStart() end
		        -- Очистка устаревшего буфера (старше 3 секунд)
        local now = os.time()
        for resKey, data in pairs(pendingResourcesBuffer) do
            if data and now - data.time > 3 then
                pendingResourcesBuffer[resKey] = nil
            end
        end
        processTimer()
        updateWindowAnim()
        local needRender = mainWin.v or isWindowAnimating() or settings.farmOverlayEnabled or settings.mineOverlayEnabled or settings.sawmillOverlayEnabled or settings.oilOverlayEnabled or (#achievementNotifications > 0)
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
                return
            end
            local status, err = asyncReq:status()
            if not err then
                if status == "completed" then
                    tgQueueProcessing = false
                    return
                elseif status == "canceled" then
                    tgQueueProcessing = false
                    return
                end
            else
                tgQueueProcessing = false
                return
            end
            wait(0)
        end
    end)
end
function sendTelegramMessage(text)
    if not tgConfig.enabled or tgConfig.botToken == "" or tgConfig.chatId == "" then
        return
    end
    
    local botToken = tgConfig.botToken
    local chatId = tgConfig.chatId
    local messageText = text
    
    local params = {
        text = messageText,
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
        headers = {
            ["Host"] = "api.telegram.org"
        }
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
        while true do
            local status, err = asyncReq:status()
            if not err then
                if status == "completed" then
                    local text = asyncReq:get()
                    if text then
                        local respOk = text:match('"ok":(%a+)')
                        if respOk ~= "true" then
                            print("TG: Ошибка отправки")
                        end
                    end
                    return
                elseif status == "canceled" then
                    return
                end
            else
                return
            end
            wait(0)
        end
    end)
end
local function parsePaydayLine(text)
    if not text then return end
    
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
    
    -- Депозит
    if text:find("сумма на депозите") then
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
    if text:find("донат") then
        local azBal = text:match("%+(%d+) AZ")
        if azBal then
            paydayAZ = paydayAZ + tonumber(azBal)
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
pendingPaydayAZ = {}
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
function hook.onServerMessage(color, text)
    local ok, err = pcall(function()
        if not text then return end
        do
            local dbgf2 = io.open(getWorkingDirectory() .. "/ResHelper_oil_early.log", "a")
            if dbgf2 then
                dbgf2:write(os.date("%Y-%m-%d %H:%M:%S") .. " | " .. tostring(text) .. "\n")
                dbgf2:close()
            end
        end
        local azVip = text:match("Вы получили (%d+) AZ")
        if azVip and not text:find("донат") then
            local now = os.time()
            for i = #pendingPaydayAZ, 1, -1 do
                if now - pendingPaydayAZ[i].time > 60 then
                    table.remove(pendingPaydayAZ, i)
                end
            end
            table.insert(pendingPaydayAZ, {amount = tonumber(azVip), time = now})
            return
        end
       
        -- АКСЕССУАР (Космическое сердце) - с защитой от повторов
        if text:find("аксессуара Космическое сердце") and text:find("Вы получили") then
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
        
        -- ДИВИДЕНТНЫЙ ДОГОВОР
        if text:find("Дивидентный договор") then
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
                if totalAmount > 0 or paydayAZ > 0 then
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
                        total = totalAmount
                    }
                    pcall(function()
                        table.insert(paydayLog, 1, newEntry)
                        while #paydayLog > 10000 do 
                            table.remove(paydayLog, #paydayLog) 
                        end
                        savePaydayStats()
                    end)
                    
                    -- Telegram уведомление через очередь
                    if tgConfig.enabled and tgConfig.paydayEnabled then
                        pcall(function()
                            local savedSalary = paydaySalary
                            local savedDeposit = paydayDeposit
                            local savedAcc = paydayAccBonus
                            local savedAZ = paydayAZ
                            local savedTotal = totalAmount
							                            local paydayTodayTotal = 0
                            local todayDate = getGameDate()
                            for _, plog in ipairs(paydayLog) do
                                if getGameDate(plog.time) == todayDate then
                                    paydayTodayTotal = paydayTodayTotal + (plog.total or 0)
                                end
                            end
							                            local paydayTodayAZ = 0
                            for _, plog in ipairs(paydayLog) do
                                if getGameDate(plog.time) == todayDate then
                                    paydayTodayAZ = paydayTodayAZ + (plog.az or 0)
                                end
                            end
                            local savedTime = os.time()
                            local mskTimestamp = savedTime + 10800
                            local mskDate = os.date("!*t", mskTimestamp)
                            local timeStr = string.format("%02d:%02d", mskDate.hour, mskDate.min)
                            local dateStr = string.format("%02d.%02d.%04d", mskDate.day, mskDate.month, mskDate.year)
                            local msg = "&#128176; <b>Вы получили пейдей!</b>\n\n" ..
                                        "<b>Вот статистика:</b>\n\n" ..
                                        "&#128178; Получено с зарплаты: <b>" .. formatNumber(savedSalary) .. "$</b>\n" ..
                                        "&#128179; Получено с депозита: <b>" .. formatNumber(savedDeposit) .. "$</b>\n" ..
                                        "&#128085; Получено с аксессуаров/предметов: <b>" .. formatNumber(savedAcc) .. "$</b>\n\n" ..
                                        "&#128142; Получено AZ: <b>" .. formatNumber(savedAZ) .. "</b>\n\n" ..
                                        "&#128200; Ваш доход за пейдей: <b>" .. formatNumber(savedTotal) .. "$ | " .. formatNumber(savedAZ) .. " AZ</b>\n" ..
                                        "&#127758; Ваш доход с пейдеев за день: <b>" .. formatNumber(paydayTodayTotal) .. "$ | " .. formatNumber(paydayTodayAZ) .. " AZ</b>\n\n" ..
                                        "&#128338; Время: " .. timeStr .. " (МСК)\n" ..
                                        "&#128197; Дата: " .. dateStr
                            queueTelegramMessage(msg)
                        end)
                    end
                end
                paydayAccBonus = 0
                paydayAZ = 0
                paydayAccBreakdown = {dividend = 0, accessory = 0, family = 0}
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
            local now = os.time()
            local windowAZ = 0
            for i = 1, #pendingPaydayAZ do
                if now - pendingPaydayAZ[i].time <= 20 then
                    windowAZ = windowAZ + pendingPaydayAZ[i].amount
                end
            end
            pendingPaydayAZ = {}
            paydayAZ = windowAZ
            
            paydayHasDividend = false
            paydayCheckTime = os.time()
            return
        end
        
        -- PayDay завершение
        if paydayActive and text:find("============================================================") then
            if paydaySalary == 0 and paydayDeposit == 0 then
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
                if totalAmount > 0 or paydayAZ > 0 then
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
                        total = totalAmount
                    }
                    pcall(function()
                        table.insert(paydayLog, 1, newEntry)
                        while #paydayLog > 10000 do 
                            table.remove(paydayLog, #paydayLog) 
                        end
                        savePaydayStats()
                    end)
                    
                    -- Telegram уведомление через очередь
                    if tgConfig.enabled and tgConfig.paydayEnabled then
                        pcall(function()
                            local savedSalary = paydaySalary
                            local savedDeposit = paydayDeposit
                            local savedAcc = paydayAccBonus
                            local savedAZ = paydayAZ
                            local savedTotal = totalAmount
							                            local paydayTodayTotal = 0
                            local todayDate = getGameDate()
                            for _, plog in ipairs(paydayLog) do
                                if getGameDate(plog.time) == todayDate then
                                    paydayTodayTotal = paydayTodayTotal + (plog.total or 0)
                                end
                            end
							                            local paydayTodayAZ = 0
                            for _, plog in ipairs(paydayLog) do
                                if getGameDate(plog.time) == todayDate then
                                    paydayTodayAZ = paydayTodayAZ + (plog.az or 0)
                                end
                            end
                            local savedTime = os.time()
                            local mskTimestamp = savedTime + 10800
                            local mskDate = os.date("!*t", mskTimestamp)
                            local timeStr = string.format("%02d:%02d", mskDate.hour, mskDate.min)
                            local dateStr = string.format("%02d.%02d.%04d", mskDate.day, mskDate.month, mskDate.year)
                            local msg = "&#128176; <b>Вы получили пейдей!</b>\n\n" ..
                                        "<b>Вот статистика:</b>\n\n" ..
                                        "&#128178; Получено с зарплаты: <b>" .. formatNumber(savedSalary) .. "$</b>\n" ..
                                        "&#128179; Получено с депозита: <b>" .. formatNumber(savedDeposit) .. "$</b>\n" ..
                                        "&#128085; Получено с аксессуаров/предметов: <b>" .. formatNumber(savedAcc) .. "$</b>\n\n" ..
                                        "&#128142; Получено AZ: <b>" .. formatNumber(savedAZ) .. "</b>\n\n" ..
                                        "&#128200; Ваш доход за пейдей: <b>" .. formatNumber(savedTotal) .. "$ | " .. formatNumber(savedAZ) .. " AZ</b>\n" ..
                                        "&#127758; Ваш доход с пейдеев за день: <b>" .. formatNumber(paydayTodayTotal) .. "$ | " .. formatNumber(paydayTodayAZ) .. " AZ</b>\n\n" ..
                                        "&#128338; Время: " .. timeStr .. " (МСК)\n" ..
                                        "&#128197; Дата: " .. dateStr
                            queueTelegramMessage(msg)
                        end)
                    end
                end
                paydayAccBonus = 0
                paydayAZ = 0
                paydayAccBreakdown = {dividend = 0, accessory = 0, family = 0}
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
        
        if text:match("^%[%d+%]") or text:match("^[%w_%[%]]+:%s") or text:match("^.*сказал") then return end
		        local cleanText = text:gsub("{......}", "")
        
        -- Осколки тайников и NFT
        local newShardItemId = tonumber(cleanText:match("^?? В пункт выдачи пришла посылка :item(%d+):"))
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
                
                if not (nick and amount > 0) then
                    local logFile = io.open(configDir .. "rent_error.log", "a")
                    if logFile then
                        local hexDump = {}
                        for i = 1, math.min(#text, 300) do
                            hexDump[#hexDump + 1] = string.format("%02X", text:byte(i))
                        end
                        logFile:write(os.date() .. " | nick=" .. tostring(nick) .. " amount=" .. tostring(amount) .. " amountRaw=" .. tostring(amountRaw) .. " raw=" .. tostring(text):sub(1, 300) .. "\n")
                        logFile:write(os.date() .. " | HEX: " .. table.concat(hexDump, " ") .. "\n")
                        logFile:close()
                    end
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
            else
                local logFile = io.open(configDir .. "rent_error.log", "a")
                if logFile then
                    local reasons = {}
                    if not hasSdali then reasons[#reasons + 1] = "'сдали комнату' не найдено" end
                    if not hasArendu then reasons[#reasons + 1] = "'аренду игроку' не найдено" end
                    logFile:write(os.date() .. " | не совпали: " .. table.concat(reasons, "; ") .. " | raw=" .. tostring(text):sub(1, 300) .. "\n")
                    logFile:close()
                end
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
        
        -- Инвестиции (ларцы) - глобальный учёт (только системные сообщения, не чат)
        if not text:match("%[[%w_]+%]") and not text:match("говорит") then
            local investItemId = tonumber(text:match("Вам был добавлен предмет :item(%d+)[:.]")) or tonumber(text:match("В инвентарь добавлен предмет:%s*:item(%d+)[:.]"))
            if investItemId and ALL_CASES[investItemId] then
                local caseName = ALL_CASES[investItemId]
                if not investmentConfig[investItemId] then
                    investmentConfig[investItemId] = { name = caseName, cost = 0, count = 0 }
                end
                investmentConfig[investItemId].count = investmentConfig[investItemId].count + 1
                table.insert(investmentLog, 1, {time = os.time(), itemId = investItemId, name = caseName})
                if #investmentLog > 10000 then investmentLog[#investmentLog] = nil end
                saveInvestmentStats()
                saveInvestmentConfig()
                if settings.chatNotifyEnabled then
                    sampAddChatMessage(SCRIPT_PREFIX .. "Выпал ларец: " .. caseName .. " (всего: " .. investmentConfig[investItemId].count .. " шт.)", SCRIPT_COLOR)
                end
            end
        end
		
		        -- Кейсы для нефтевышек (привязываем к последней продаже бочки если она была недавно)
        local storageCaseName = nil
        if not text:match("%[[%w_]+%]") and not text:match("говорит") then
            local cleanStorageText = text:gsub("{......}", "")
            storageCaseName = cleanStorageText:match("%[Хранилище предметов%] Добавлен новый предмет '(.+)%(%d+ шт%.%)'")
            if not storageCaseName then
                local newFormatItemId = tonumber(cleanStorageText:match("^?? В пункт выдачи пришла посылка :item(%d+):"))
                if newFormatItemId then storageCaseName = ALL_CASES[newFormatItemId] end
            end
        end
        if storageCaseName then
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
        local storageInvName = text:match("%[Хранилище предметов%] Добавлен новый предмет '(.+)%(%d+ шт%.%)'")
        if not storageInvName then
            local newFormatInvItemId = tonumber(text:match("^?? В пункт выдачи пришла посылка :item(%d+):"))
            if newFormatInvItemId then storageInvName = ALL_CASES[newFormatInvItemId] end
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
                    investmentConfig[foundInvId] = { name = caseName, cost = 0, count = 0 }
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
		
        -- Ферма и Шахта
        if text:match("^Вам был добавлен предмет") or text:match("В инвентарь добавлен предмет:") then
            local itemId = text:match(":item(%d+):")
            if itemId then
                local id = tonumber(itemId)
                
                -- Пропускаем кейсы (они обрабатываются в блоке нефтевышек)
                if ALL_CASES and ALL_CASES[id] then
                    return
                end
                
                -- Талон AZ
                if id == 731 and settings.talonAutoScanEnabled then
                    local amount = pendingResources["talon_az"] or 0
                    if amount > 0 then
                        if paydayActive then
                            paydayAZ = paydayAZ + amount
                        else
                            local now = os.time()
                            for i = #pendingPaydayAZ, 1, -1 do
                                if now - pendingPaydayAZ[i].time > 60 then
                                    table.remove(pendingPaydayAZ, i)
                                end
                            end
                            table.insert(pendingPaydayAZ, {amount = amount, time = now})
                        end
                        pendingResources["talon_az"] = nil
                    end
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
        do
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
                local az = 0
                if oilLastSoldLiters > 150 then az = 13 end
                addOilLog("ground_money", bonusMoney, az)
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
                    local totalMoney = newMoney + companyBonus
                    local finalAZ = az + (oilPendingBonusAZ or 0)
                    addOilLog(kind, totalMoney, finalAZ)
                    if (oilPendingBonusAZ or 0) > 0 then
                        oilLog[1].isBonusAZ = true
                    end
                    oilPendingBonusAZ = 0
                    if settings.chatNotifyEnabled and oilBonusPercent > 0 then
                        sampAddChatMessage(SCRIPT_PREFIX .. "Надбавка за бонусы: " .. oilBonusPercent .. "% (" .. formatNumber(bonusSummarno) .. "$)", SCRIPT_COLOR)
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
                    sampAddChatMessage(SCRIPT_PREFIX .. "Надбавка за бонусы: " .. oilBonusPercent .. "% (" .. formatNumber(bonusMoney) .. "$)", SCRIPT_COLOR)
                end
                oilBonusPercent = 0
            elseif oilText:find("Вы успешно купили бочку. Погрузите её в лодку или дирижабль!") then
                addOilLog("buy_water", -(oilConfig.barrelCost or 0), 0)
            elseif oilText:find("Вы успешно купили бочку. Погрузите её в автомобиль!") then
                addOilLog("buy_ground", 0, -(oilConfig.azBarrelCost or 0))
            elseif oilText:find("нефт") or oilText:find("бочк") or oilText:find("AZ%-Coins") or oilText:find("электрокомпан") then
                -- Диагностика: сообщение похоже на нефтяное, но ни один паттерн не подошёл - пишем сырой текст в файл для разбора
                local dbgf = io.open(getWorkingDirectory() .. "/ResHelper_oil_unmatched.log", "a")
                if dbgf then
                    dbgf:write(os.date("%Y-%m-%d %H:%M:%S") .. " | RAW: " .. tostring(text) .. " | CLEAN: " .. tostring(oilText) .. "\n")
                    dbgf:close()
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
        if not text then return end
        local t3d = text:gsub("{......}", "")
        local dollNef = t3d:match("AZ%-Coins %+ :CASH:([%d%.,]+) за 1 бочку с нефтевышек Лас%-Вентурас")
        if dollNef then
            local price = tonumber((dollNef:gsub("%p", "")))
            if price and price ~= oilConfig.groundOilMoney then
                oilConfig.groundOilMoney = price
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
function ButtonMenu(desk, bool)
    local retBool = false
    if bool then
        imgui.PushStyleColor(imgui.Col.Button, imgui.ImColor(45, 230, 73, 220):GetVec4())
        retBool = imgui.Button(desk, imgui.ImVec2(140, 25))
        imgui.PopStyleColor(1)
    elseif not bool then
         retBool = imgui.Button(desk, imgui.ImVec2(140, 25))
    end
    return retBool
end
function ShowHelpMarker(stext)
    imgui.TextDisabled(u8("(?)"))
    if imgui.IsItemHovered() then
        imgui.SetTooltip(stext)
    end
end
local fa_font = nil
local fa_font_awesome = nil
local fa_glyph_ranges = imgui.ImGlyphRanges({ fa.min_range, fa.max_range })
function imgui.BeforeDrawFrame()
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
function imgui.AchievementCard(ach)
    local width = imgui.GetWindowWidth() - 25
    local height = 80
    
    local drawList = imgui.GetWindowDrawList()
    local pos = imgui.GetCursorScreenPos()
    
    -- Тень под карточкой
    drawList:AddRectFilled(
        imgui.ImVec2(pos.x + 2, pos.y + 2),
        imgui.ImVec2(pos.x + width + 2, pos.y + height + 2),
        0xAA000000, 6
    )
    
    -- Основной фон
    local bgColor = ach.completed and 0xFF1A2E1A or 0xFF1A1A1A
    drawList:AddRectFilled(pos, imgui.ImVec2(pos.x + width, pos.y + height), bgColor, 6)
    
    -- Акцентная полоска слева
    local accentColor = ach.completed and 0xFF1AE591 or 0xFF333333
    drawList:AddRectFilled(pos, imgui.ImVec2(pos.x + 4, pos.y + height), accentColor, 6, 1)
    
    -- Первая строка: иконка + название
    drawList:AddText(imgui.ImVec2(pos.x + 15, pos.y + 8), ach.completed and 0xFF1AE591 or 0xFFFFFFFF, ach.icon)
    drawList:AddText(imgui.ImVec2(pos.x + 50, pos.y + 8), ach.completed and 0xFF1AE591 or 0xFFFFFFFF, u8(ach.name))
    
    -- Кнопка сброса (правый верхний угол)
    local resetX = pos.x + width - 30
    local resetY = pos.y + 5
    local resetHovered = (imgui.GetMousePos().x >= resetX and imgui.GetMousePos().x <= resetX + 20 and 
                          imgui.GetMousePos().y >= resetY and imgui.GetMousePos().y <= resetY + 20)
    
    drawList:AddRectFilled(
        imgui.ImVec2(resetX, resetY),
        imgui.ImVec2(resetX + 20, resetY + 20),
        resetHovered and 0xFF3A3A3A or bgColor, 4
    )
    drawList:AddRect(
        imgui.ImVec2(resetX, resetY),
        imgui.ImVec2(resetX + 20, resetY + 20),
        0xFF444444, 4, 15, 1.0
    )
    drawList:AddText(imgui.ImVec2(resetX + 3, resetY + 2), 0xFF999999, fa.ICON_REPEAT)
    
    imgui.SetCursorScreenPos(imgui.ImVec2(resetX, resetY))
    if imgui.InvisibleButton("##reset_ach_" .. ach.id, imgui.ImVec2(20, 20)) then
        ach.progress = 0
        ach.completed = false
        saveAchievements()
        sampAddChatMessage(SCRIPT_PREFIX .. "Достижение \"" .. ach.name .. "\" сброшено!", SCRIPT_COLOR)
    end
    
    -- Вторая строка: категория + описание
    local categoryText = u8(ach.category) .. ": "
    local categoryWidth = imgui.CalcTextSize(categoryText).x
    drawList:AddText(imgui.ImVec2(pos.x + 15, pos.y + 26), 0xFFFFCC00, categoryText)
    drawList:AddText(imgui.ImVec2(pos.x + 15 + categoryWidth, pos.y + 26), 0xFF888888, u8(ach.desc))
    
    -- Прогресс-бар (третья строка)
    local barY = pos.y + 48
    local barWidth = width - 30
    local progress = ach.completed and 1.0 or math.min(ach.progress / ach.target, 1.0)
    
    drawList:AddRectFilled(imgui.ImVec2(pos.x + 15, barY), imgui.ImVec2(pos.x + 15 + barWidth, barY + 6), 0xFF333333, 3)
    
    if progress > 0 then
        drawList:AddRectFilled(imgui.ImVec2(pos.x + 15, barY), imgui.ImVec2(pos.x + 15 + barWidth * progress, barY + 6), ach.completed and 0xFF1AE591 or 0xFF1AE591, 3)
    end
    
    -- Текст прогресса под баром
    local progressText
    if ach.completed then
        progressText = "[OK] " .. u8("Выполнено")
    elseif ach.id == "farmer_pro" or ach.id == "miner_pro" or ach.id == "sawmill_pro" or ach.id == "millionaire" then
        progressText = formatNumber(ach.progress) .. "$ / " .. formatNumber(ach.target) .. "$"
    else
        progressText = formatNumber(ach.progress) .. " / " .. formatNumber(ach.target)
    end
    drawList:AddText(imgui.ImVec2(pos.x + 15, barY + 8), 0xFF999999, progressText)
    
    -- Отступ для следующего элемента
    imgui.SetCursorScreenPos(imgui.ImVec2(pos.x, pos.y + height + 4))
    imgui.Dummy(imgui.ImVec2(width, 0))
end
function imgui.BindCard(key, val, winW, theme)
    local width = imgui.GetWindowWidth() - 30
    local height = 38
    
    local drawList = imgui.GetWindowDrawList()
    local pos = imgui.GetCursorScreenPos()
    
    local cardBg, cardBorder, cardIcon
    if useCustomTheme then
        cardBg = imVec4ToHex(CUSTOM_THEME.cardBg)
        cardBorder = imVec4ToHex(CUSTOM_THEME.cardBorder)
        cardIcon = imVec4ToHex(CUSTOM_THEME.cardIcon)
    else
        cardBg = 0xFF1A1A1A
        cardBorder = 0xFF333333
        cardIcon = 0xFF1AE591
    end
    
    -- Фон карточки
    drawList:AddRectFilled(imgui.ImVec2(pos.x, pos.y), imgui.ImVec2(pos.x + width, pos.y + height), cardBg, 6)
    -- Обводка карточки
    drawList:AddRect(imgui.ImVec2(pos.x, pos.y), imgui.ImVec2(pos.x + width, pos.y + height), cardBorder, 6, 15, 1.0)
    
    -- Номер
    drawList:AddText(imgui.ImVec2(pos.x + 10, pos.y + 10), cardIcon, "#" .. key)
    
    -- Название бинда
    drawList:AddText(imgui.ImVec2(pos.x + 40, pos.y + 10), 0xFFFFFFFF, u8(val.name or "Без названия"))
    
    -- Клавиши (по центру)
    local keyNames = {}
    for _, vk in ipairs(val.v or {}) do table.insert(keyNames, vkeys.id_to_name(vk)) end
    local keyStr = #keyNames > 0 and table.concat(keyNames, " + ") or "НЕТ"
    local keyTextWidth = imgui.CalcTextSize(u8(keyStr)).x
    drawList:AddText(imgui.ImVec2(pos.x + width / 2 - keyTextWidth / 2, pos.y + 10), 0xFFCCCCCC, u8(keyStr))
    
    -- Кнопка редактирования
    local editX = pos.x + width - 95
    local editY = pos.y + 5
    local editHovered = (imgui.GetMousePos().x >= editX and imgui.GetMousePos().x <= editX + 30 and 
                         imgui.GetMousePos().y >= editY and imgui.GetMousePos().y <= editY + 28)
    
    local editBg = useCustomTheme and (editHovered and imVec4ToHex(CUSTOM_THEME.cardBtnBgHovered) or imVec4ToHex(CUSTOM_THEME.cardBtnBg)) or (editHovered and 0xFF3A3A3A or 0xFF252525)
    drawList:AddRectFilled(imgui.ImVec2(editX, editY), imgui.ImVec2(editX + 30, editY + 28), editBg, 4)
    local editIconW = imgui.CalcTextSize(fa.ICON_PENCIL_SQUARE_O).x
    local editIconH = imgui.CalcTextSize(fa.ICON_PENCIL_SQUARE_O).y
    local editIconCol = useCustomTheme and imVec4ToHex(CUSTOM_THEME.cardBtnText) or 0xFFFFFFFF
    drawList:AddText(imgui.ImVec2(editX + (30 - editIconW) / 2, editY + (28 - editIconH) / 2), editIconCol, fa.ICON_PENCIL_SQUARE_O)
    
    imgui.SetCursorScreenPos(imgui.ImVec2(editX, editY))
    if imgui.InvisibleButton("##edit_bind_" .. key, imgui.ImVec2(30, 28)) then
        editingBindIdx = key
        local temp = {}
        for _, v in ipairs(val.text) do table.insert(temp, v) end
        editBindMultiline.v = u8(table.concat(temp, "\n"))
        editBindName.v = u8(val.name)
        imgui.OpenPopup(u8("Редактирование бинда"))
    end
    
    -- Кнопка удаления
    local delX = pos.x + width - 55
    local delY = pos.y + 5
    local delHovered = (imgui.GetMousePos().x >= delX and imgui.GetMousePos().x <= delX + 30 and 
                        imgui.GetMousePos().y >= delY and imgui.GetMousePos().y <= delY + 28)
    
    local delBg = useCustomTheme and (delHovered and imVec4ToHex(CUSTOM_THEME.cardBtnBgHovered) or imVec4ToHex(CUSTOM_THEME.cardBtnBg)) or (delHovered and 0xFF3A3A3A or 0xFF252525)
    drawList:AddRectFilled(imgui.ImVec2(delX, delY), imgui.ImVec2(delX + 30, delY + 28), delBg, 4)
    local delIconW = imgui.CalcTextSize(fa.ICON_TRASH).x
    local delIconH = imgui.CalcTextSize(fa.ICON_TRASH).y
    drawList:AddText(imgui.ImVec2(delX + (30 - delIconW) / 2, delY + (28 - delIconH) / 2), editIconCol, fa.ICON_TRASH)
    
    imgui.SetCursorScreenPos(imgui.ImVec2(delX, delY))
    if imgui.InvisibleButton("##del_bind_" .. key, imgui.ImVec2(30, 28)) then
        sampAddChatMessage(SCRIPT_PREFIX .. "Бинд \"" .. val.name .. "\" удалён.", SCRIPT_COLOR)
        table.remove(bindDatabase.binds, key); saveBinderDatabase()
    end
    
    -- Отступ для следующего элемента
    imgui.SetCursorScreenPos(imgui.ImVec2(pos.x, pos.y + height + 1))
    imgui.Dummy(imgui.ImVec2(width, 0))
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
function drawSettingsTab()
    local drawList = imgui.GetWindowDrawList()
    local listW = imgui.GetWindowWidth() - 25
    local cardH = 38
    
    -- Вспомогательная функция для цветов карточек
    local function getCardColors(hovered)
        if useCustomTheme then
            return imVec4ToHex(hovered and CUSTOM_THEME.cardBgHovered or CUSTOM_THEME.cardBg),
                   imVec4ToHex(CUSTOM_THEME.cardBorder),
                   imVec4ToHex(CUSTOM_THEME.cardIcon),
                   imVec4ToHex(CUSTOM_THEME.cardTitle)
        else
            return (hovered and 0xFF222222 or 0xFF1A1A1A), 0xFF333333, 0xFF1AE591, 0xFF1AE591
        end
    end
    
    -- ====== ОФОРМЛЕНИЕ ======
    local cardY = imgui.GetCursorScreenPos().y
    local cardX = imgui.GetCursorScreenPos().x
    local hovered = (imgui.GetMousePos().x >= cardX and imgui.GetMousePos().x <= cardX + listW and 
                    imgui.GetMousePos().y >= cardY and imgui.GetMousePos().y <= cardY + cardH)
    local bgCol, borderCol, iconCol, titleCol = getCardColors(hovered)
    drawList:AddRectFilled(imgui.ImVec2(cardX, cardY), imgui.ImVec2(cardX + listW, cardY + cardH), bgCol, 6)
    drawList:AddRect(imgui.ImVec2(cardX, cardY), imgui.ImVec2(cardX + listW, cardY + cardH), borderCol, 6, 15, 1.0)
    drawList:AddText(imgui.ImVec2(cardX + 10, cardY + (cardH - 14) / 2), iconCol, fa.ICON_STAR)
    drawList:AddText(imgui.ImVec2(cardX + 35, cardY + (cardH - 14) / 2), titleCol, u8("Оформление"))
    imgui.SetCursorScreenPos(imgui.ImVec2(cardX, cardY))
    if not settingsExpandedTheme then settingsExpandedTheme = false end
    if imgui.InvisibleButton("##settings_theme", imgui.ImVec2(listW, cardH)) then settingsExpandedTheme = not settingsExpandedTheme end
    if settingsExpandedTheme then
        imgui.Spacing()
        if ToggleSwitch(u8("Использовать кастомную тему"), cb_useCustomTheme) then
            useCustomTheme = cb_useCustomTheme.v; saveThemeConfig(); needSave = true
        end
        if useCustomTheme then
            cardY = imgui.GetCursorScreenPos().y; cardX = imgui.GetCursorScreenPos().x
            hovered = (imgui.GetMousePos().x >= cardX and imgui.GetMousePos().x <= cardX + listW and imgui.GetMousePos().y >= cardY and imgui.GetMousePos().y <= cardY + cardH)
            bgCol, borderCol, iconCol, titleCol = getCardColors(hovered)
            drawList:AddRectFilled(imgui.ImVec2(cardX, cardY), imgui.ImVec2(cardX + listW, cardY + cardH), bgCol, 6)
            drawList:AddRect(imgui.ImVec2(cardX, cardY), imgui.ImVec2(cardX + listW, cardY + cardH), borderCol, 6, 15, 1.0)
            drawList:AddText(imgui.ImVec2(cardX + 10, cardY + (cardH - 14) / 2), iconCol, fa.ICON_COG)
            drawList:AddText(imgui.ImVec2(cardX + 35, cardY + (cardH - 14) / 2), titleCol, u8("Редактор кастомной темы"))
            imgui.SetCursorScreenPos(imgui.ImVec2(cardX, cardY))
            if not settingsExpandedCustomTheme then settingsExpandedCustomTheme = false end
            if imgui.InvisibleButton("##settings_custom_theme", imgui.ImVec2(listW, cardH)) then settingsExpandedCustomTheme = not settingsExpandedCustomTheme end
            if settingsExpandedCustomTheme then
                imgui.Spacing()
                local function ColorEdit4Helper(label, tbl, key)
                    imgui.Text(label)
                    local pos = imgui.GetCursorScreenPos()
                    drawList:AddRectFilled(pos, imgui.ImVec2(pos.x + 30, pos.y + 20), imVec4ToHex(tbl[key]))
                    drawList:AddRect(pos, imgui.ImVec2(pos.x + 30, pos.y + 20), 0xFFFFFFFF, 0, 15, 1.5)
                    imgui.SetCursorScreenPos(pos)
                    imgui.InvisibleButton("##colorpreview_" .. key, imgui.ImVec2(30, 20))
                    if imgui.IsItemClicked(0) then imgui.OpenPopup("ColorPicker##" .. key) end
                    imgui.SetCursorScreenPos(imgui.ImVec2(pos.x + 35, pos.y))
                    imgui.Dummy(imgui.ImVec2(0, 20))
                    if imgui.BeginPopup("ColorPicker##" .. key) then
                        local col = imgui.ImFloat4(tbl[key].x, tbl[key].y, tbl[key].z, tbl[key].w)
                        if imgui.ColorPicker4("##picker" .. key, col, imgui.ColorEditFlags.NoSidePreview) then
                            tbl[key] = imgui.ImVec4(col.v[1], col.v[2], col.v[3], col.v[4])
                            if key == "leftPanelBg" then CUSTOM_THEME.titleBg = imgui.ImVec4(col.v[1], col.v[2], col.v[3], col.v[4])
                            elseif key == "rightPanelBg" then CUSTOM_THEME.windowBg = imgui.ImVec4(col.v[1], col.v[2], col.v[3], col.v[4]); CUSTOM_THEME.childBg = imgui.ImVec4(col.v[1], col.v[2], col.v[3], col.v[4]); CUSTOM_THEME.rightTitleBg = imgui.ImVec4(col.v[1], col.v[2], col.v[3], col.v[4]) end
                            saveCustomTheme()
                        end
                        imgui.EndPopup()
                    end
                    imgui.Spacing()
                end
                
                -- Цвета меню
                cardY = imgui.GetCursorScreenPos().y; cardX = imgui.GetCursorScreenPos().x
                hovered = (imgui.GetMousePos().x >= cardX and imgui.GetMousePos().x <= cardX + listW and imgui.GetMousePos().y >= cardY and imgui.GetMousePos().y <= cardY + cardH)
                bgCol, borderCol, iconCol, titleCol = getCardColors(hovered)
                drawList:AddRectFilled(imgui.ImVec2(cardX, cardY), imgui.ImVec2(cardX + listW, cardY + cardH), bgCol, 6)
                drawList:AddRect(imgui.ImVec2(cardX, cardY), imgui.ImVec2(cardX + listW, cardY + cardH), borderCol, 6, 15, 1.0)
                drawList:AddText(imgui.ImVec2(cardX + 10, cardY + (cardH - 14) / 2), iconCol, fa.ICON_DESKTOP)
                drawList:AddText(imgui.ImVec2(cardX + 35, cardY + (cardH - 14) / 2), titleCol, u8("Цвета меню"))
                imgui.SetCursorScreenPos(imgui.ImVec2(cardX, cardY))
                if not settingsExpandedMenuColors then settingsExpandedMenuColors = false end
                if imgui.InvisibleButton("##settings_menu_colors", imgui.ImVec2(listW, cardH)) then settingsExpandedMenuColors = not settingsExpandedMenuColors end
                if settingsExpandedMenuColors then
                    imgui.Spacing()
                    ColorEdit4Helper(u8("Акцентный цвет"), CUSTOM_THEME, "accent"); ColorEdit4Helper(u8("Левая панель"), CUSTOM_THEME, "leftPanelBg")
                    ColorEdit4Helper(u8("Правая панель"), CUSTOM_THEME, "rightPanelBg"); ColorEdit4Helper(u8("Цвет заголовка"), CUSTOM_THEME, "headerTitle")
                    ColorEdit4Helper(u8("Текст в правой панели"), CUSTOM_THEME, "contentText"); ColorEdit4Helper(u8("Фон активной кнопки"), CUSTOM_THEME, "buttonActive")
                    ColorEdit4Helper(u8("Фон кнопки (наведение)"), CUSTOM_THEME, "buttonHover"); ColorEdit4Helper(u8("Обводка активной кнопки"), CUSTOM_THEME, "borderActive")
                    ColorEdit4Helper(u8("Цвет разделителей"), CUSTOM_THEME, "borderColor")
                    imgui.Spacing()
                end
                
                -- Цвета текста
                cardY = imgui.GetCursorScreenPos().y; cardX = imgui.GetCursorScreenPos().x
                hovered = (imgui.GetMousePos().x >= cardX and imgui.GetMousePos().x <= cardX + listW and imgui.GetMousePos().y >= cardY and imgui.GetMousePos().y <= cardY + cardH)
                bgCol, borderCol, iconCol, titleCol = getCardColors(hovered)
                drawList:AddRectFilled(imgui.ImVec2(cardX, cardY), imgui.ImVec2(cardX + listW, cardY + cardH), bgCol, 6)
                drawList:AddRect(imgui.ImVec2(cardX, cardY), imgui.ImVec2(cardX + listW, cardY + cardH), borderCol, 6, 15, 1.0)
                drawList:AddText(imgui.ImVec2(cardX + 10, cardY + (cardH - 14) / 2), iconCol, fa.ICON_FONT)
                drawList:AddText(imgui.ImVec2(cardX + 35, cardY + (cardH - 14) / 2), titleCol, u8("Цвета текста"))
                imgui.SetCursorScreenPos(imgui.ImVec2(cardX, cardY))
                if not settingsExpandedTextColors then settingsExpandedTextColors = false end
                if imgui.InvisibleButton("##settings_text_colors", imgui.ImVec2(listW, cardH)) then settingsExpandedTextColors = not settingsExpandedTextColors end
                if settingsExpandedTextColors then
                    imgui.Spacing()
                    ColorEdit4Helper(u8("Цвет текста (обычный)"), CUSTOM_THEME, "textNormal"); ColorEdit4Helper(u8("Цвет текста (активный)"), CUSTOM_THEME, "textActive")
                    ColorEdit4Helper(u8("Цвет текста (наведение)"), CUSTOM_THEME, "textHover")
                    imgui.Spacing()
                end
                
                -- Кнопки и элементы
                cardY = imgui.GetCursorScreenPos().y; cardX = imgui.GetCursorScreenPos().x
                hovered = (imgui.GetMousePos().x >= cardX and imgui.GetMousePos().x <= cardX + listW and imgui.GetMousePos().y >= cardY and imgui.GetMousePos().y <= cardY + cardH)
                bgCol, borderCol, iconCol, titleCol = getCardColors(hovered)
                drawList:AddRectFilled(imgui.ImVec2(cardX, cardY), imgui.ImVec2(cardX + listW, cardY + cardH), bgCol, 6)
                drawList:AddRect(imgui.ImVec2(cardX, cardY), imgui.ImVec2(cardX + listW, cardY + cardH), borderCol, 6, 15, 1.0)
                drawList:AddText(imgui.ImVec2(cardX + 10, cardY + (cardH - 14) / 2), iconCol, fa.ICON_KEYBOARD_O)
                drawList:AddText(imgui.ImVec2(cardX + 35, cardY + (cardH - 14) / 2), titleCol, u8("Кнопки и элементы"))
                imgui.SetCursorScreenPos(imgui.ImVec2(cardX, cardY))
                if not settingsExpandedElements then settingsExpandedElements = false end
                if imgui.InvisibleButton("##settings_elements", imgui.ImVec2(listW, cardH)) then settingsExpandedElements = not settingsExpandedElements end
                if settingsExpandedElements then
                    imgui.Spacing()
                    ColorEdit4Helper(u8("Кнопки ImGui"), CUSTOM_THEME, "imguiButton"); ColorEdit4Helper(u8("Кнопки (наведение)"), CUSTOM_THEME, "imguiButtonHovered")
                    ColorEdit4Helper(u8("Кнопки (активные)"), CUSTOM_THEME, "imguiButtonActive"); ColorEdit4Helper(u8("Заголовки разделов"), CUSTOM_THEME, "collapsingHeader")
                    ColorEdit4Helper(u8("Заголовки (наведение)"), CUSTOM_THEME, "collapsingHeaderHovered"); ColorEdit4Helper(u8("Заголовки (активные)"), CUSTOM_THEME, "collapsingHeaderActive")
                    ColorEdit4Helper(u8("Прогресс-бар"), CUSTOM_THEME, "progressBar"); ColorEdit4Helper(u8("Поля ввода"), CUSTOM_THEME, "frameBg")
                    ColorEdit4Helper(u8("Поля ввода (наведение)"), CUSTOM_THEME, "frameBgHovered"); ColorEdit4Helper(u8("Поля ввода (активные)"), CUSTOM_THEME, "frameBgActive")
                    imgui.Spacing()
                    imgui.Separator()
                    imgui.Spacing()
                    imgui.TextColored(imgui.ImVec4(1.0, 0.8, 0.2, 1), u8("Карточки правой панели"))
                    imgui.Spacing()
                    ColorEdit4Helper(u8("Фон карточки"), CUSTOM_THEME, "cardBg")
                    ColorEdit4Helper(u8("Фон при наведении"), CUSTOM_THEME, "cardBgHovered")
                    ColorEdit4Helper(u8("Обводка карточки"), CUSTOM_THEME, "cardBorder")
                    ColorEdit4Helper(u8("Иконка в карточке"), CUSTOM_THEME, "cardIcon")
                    ColorEdit4Helper(u8("Заголовок карточки"), CUSTOM_THEME, "cardTitle")
                    imgui.Spacing()
                    imgui.Separator()
                    imgui.Spacing()
                    imgui.TextColored(imgui.ImVec4(1.0, 0.8, 0.2, 1), u8("Кнопки в карточках (биндер)"))
                    imgui.Spacing()
                    ColorEdit4Helper(u8("Фон кнопки"), CUSTOM_THEME, "cardBtnBg")
                    ColorEdit4Helper(u8("Фон кнопки при наведении"), CUSTOM_THEME, "cardBtnBgHovered")
                    ColorEdit4Helper(u8("Текст/иконка кнопки"), CUSTOM_THEME, "cardBtnText")
                    imgui.Spacing()
                    imgui.Separator()
                    imgui.Spacing()
                    imgui.TextColored(imgui.ImVec4(1.0, 0.8, 0.2, 1), u8("Карточки статистики (сторонний доход)"))
                    imgui.Spacing()
                    ColorEdit4Helper(u8("Фон карточки"), CUSTOM_THEME, "statCardBg")
                    ColorEdit4Helper(u8("Обводка карточки"), CUSTOM_THEME, "statCardBorder")
                    ColorEdit4Helper(u8("Текст заголовка"), CUSTOM_THEME, "statCardLabel")
                    ColorEdit4Helper(u8("Значение (общее)"), CUSTOM_THEME, "statCardValue")
                    ColorEdit4Helper(u8("Значение (сегодня)"), CUSTOM_THEME, "statCardValueToday")
                    ColorEdit4Helper(u8("Значение (неделя)"), CUSTOM_THEME, "statCardValueWeek")
                    ColorEdit4Helper(u8("Текст AZ"), CUSTOM_THEME, "statCardAZ")
                    imgui.Spacing()
                    imgui.Separator()
                    imgui.Spacing()
                    imgui.TextColored(imgui.ImVec4(1.0, 0.8, 0.2, 1), u8("Заголовки таблиц (история)"))
                    imgui.Spacing()
                    ColorEdit4Helper(u8("Фон заголовка таблицы"), CUSTOM_THEME, "tableHeaderBg")
                    ColorEdit4Helper(u8("Текст заголовка таблицы"), CUSTOM_THEME, "tableHeaderText")
                end
                imgui.Spacing()
                if imgui.Button(u8("Сбросить тему на стандартную"), imgui.ImVec2(-1, 25)) then resetCustomTheme(); saveCustomTheme() end
                imgui.Spacing()
            end
        else
            imgui.Spacing()
            imgui.Text(u8("Цветовая тема:")); imgui.PushItemWidth(200)
            if imgui.Combo(u8("##theme_select"), selectedThemeIdx, themeComboItems) then currentTheme = THEME_ORDER[selectedThemeIdx.v + 1]; saveThemeConfig(); needSave = true end
            imgui.PopItemWidth(); imgui.SameLine(); ShowHelpMarker(u8("Меняет цветовое оформление главного меню"))
            imgui.Spacing()
        end
        imgui.Spacing()
    end
    -- ====== Плавность интерфейса ======
    cardY = imgui.GetCursorScreenPos().y; cardX = imgui.GetCursorScreenPos().x
    hovered = (imgui.GetMousePos().x >= cardX and imgui.GetMousePos().x <= cardX + listW and imgui.GetMousePos().y >= cardY and imgui.GetMousePos().y <= cardY + cardH)
    bgCol, borderCol, iconCol, titleCol = getCardColors(hovered)
    drawList:AddRectFilled(imgui.ImVec2(cardX, cardY), imgui.ImVec2(cardX + listW, cardY + cardH), bgCol, 6)
    drawList:AddRect(imgui.ImVec2(cardX, cardY), imgui.ImVec2(cardX + listW, cardY + cardH), borderCol, 6, 15, 1.0)
    drawList:AddText(imgui.ImVec2(cardX + 10, cardY + (cardH - 14) / 2), iconCol, fa.ICON_DESKTOP)
    drawList:AddText(imgui.ImVec2(cardX + 35, cardY + (cardH - 14) / 2), titleCol, u8("Плавность интерфейса"))
    imgui.SetCursorScreenPos(imgui.ImVec2(cardX, cardY))
    if not settingsExpandedAnim then settingsExpandedAnim = false end
    if imgui.InvisibleButton("##settings_anim", imgui.ImVec2(listW, cardH)) then settingsExpandedAnim = not settingsExpandedAnim end
    if settingsExpandedAnim then
        imgui.Spacing()
        if ToggleSwitch(u8("Плавное меню слева"), cb_smoothMenu, u8("Выделение текущего раздела будет плавно ехать к новому пункту меню, а не переключаться мгновенно.")) then
            settings.smoothMenuEnabled = cb_smoothMenu.v
            saveConfig()
            needSave = true
        end
        imgui.Spacing()
        if ToggleSwitch(u8("Плавное открытие и закрытие /rh"), cb_smoothWindow, u8("Окно /rh и переключение вкладок будут плавно появляться и исчезать, а не мгновенно.")) then
            settings.smoothWindowEnabled = cb_smoothWindow.v
            saveConfig()
            needSave = true
        end
        imgui.Spacing()
    end
    -- ====== УВЕДОМЛЕНИЯ И ЗВУКИ ======
    cardY = imgui.GetCursorScreenPos().y; cardX = imgui.GetCursorScreenPos().x
    hovered = (imgui.GetMousePos().x >= cardX and imgui.GetMousePos().x <= cardX + listW and imgui.GetMousePos().y >= cardY and imgui.GetMousePos().y <= cardY + cardH)
    bgCol, borderCol, iconCol, titleCol = getCardColors(hovered)
    drawList:AddRectFilled(imgui.ImVec2(cardX, cardY), imgui.ImVec2(cardX + listW, cardY + cardH), bgCol, 6)
    drawList:AddRect(imgui.ImVec2(cardX, cardY), imgui.ImVec2(cardX + listW, cardY + cardH), borderCol, 6, 15, 1.0)
    drawList:AddText(imgui.ImVec2(cardX + 10, cardY + (cardH - 14) / 2), iconCol, fa.ICON_MUSIC)
    drawList:AddText(imgui.ImVec2(cardX + 35, cardY + (cardH - 14) / 2), titleCol, u8("Уведомления и звуки"))
    imgui.SetCursorScreenPos(imgui.ImVec2(cardX, cardY))
    if not settingsExpandedNotify then settingsExpandedNotify = false end
    if imgui.InvisibleButton("##settings_notify", imgui.ImVec2(listW, cardH)) then settingsExpandedNotify = not settingsExpandedNotify end
    if settingsExpandedNotify then
        imgui.Spacing()
        if ToggleSwitch(u8("Уведомления о целях в чат"), cb_chatNotify) then settings.chatNotifyEnabled = cb_chatNotify.v; saveConfig(); needSave = true end
        imgui.Spacing()
        
        -- Звук достижения
        if ToggleSwitch(u8("Звук при выполнении цели"), cb_goalSound) then settings.goalSoundEnabled = cb_goalSound.v; saveConfig(); needSave = true end
        if cb_goalSound.v then
            local wavFiles = getWavFiles()
            if not achivFileIdx then achivFileIdx = imgui.ImInt(0) end
            if achivFileIdx.v < 0 or achivFileIdx.v >= #wavFiles then achivFileIdx.v = 0 end
            for i, f in ipairs(wavFiles) do if f == (settings.achivSoundFile or "achiv.wav") then achivFileIdx.v = i - 1; break end end
            imgui.Text(u8("Достижение:"))
            imgui.SameLine(100)
            imgui.PushItemWidth(140)
            if imgui.Combo("##achiv_file", achivFileIdx, table.concat(wavFiles, "\0") .. "\0") then
                settings.achivSoundFile = wavFiles[achivFileIdx.v + 1]
                saveConfig()
            end
            imgui.PopItemWidth()
            imgui.SameLine(0, 5)
            if imgui.Button(fa.ICON_PLAY .. "##play_achiv", imgui.ImVec2(25, 20)) then
                playSoundFile(settings.achivSoundFile or "achiv.wav", settings.goalSoundVolume)
            end
            imgui.SameLine(0, 10)
            imgui.Text(u8("Громкость:"))
            imgui.SameLine(0, 5)
            imgui.PushItemWidth(80)
            if imgui.SliderInt("##goal_vol", goal_vol_slider, 0, 100) then settings.goalSoundVolume = goal_vol_slider.v; saveConfig() end
            imgui.PopItemWidth()
        end
        imgui.Spacing()
        
        -- Звуки добычи
        if ToggleSwitch(u8("Звуки при добыче ресурсов"), cb_pickupSound) then settings.pickupSoundEnabled = cb_pickupSound.v; saveConfig(); needSave = true end
        if cb_pickupSound.v then
            local wavFiles = getWavFiles()
            
            -- Обычный дроп
            if not pickupFileIdx then pickupFileIdx = imgui.ImInt(0) end
            if pickupFileIdx.v < 0 or pickupFileIdx.v >= #wavFiles then pickupFileIdx.v = 0 end
            for i, f in ipairs(wavFiles) do if f == (settings.pickupSoundFile or "pickup.wav") then pickupFileIdx.v = i - 1; break end end
            imgui.Text(u8("Обычный:"))
            imgui.SameLine(65)
            ShowHelpMarker(u8("Лён, Хлопок, Вода, Краситель, Камень, Металл, Бронза, Серебро, Золото, Дрова"))
            imgui.SameLine(100)
            imgui.PushItemWidth(140)
            if imgui.Combo("##pickup_file", pickupFileIdx, table.concat(wavFiles, "\0") .. "\0") then
                settings.pickupSoundFile = wavFiles[pickupFileIdx.v + 1]
                saveConfig()
            end
            imgui.PopItemWidth()
            imgui.SameLine(0, 5)
            if imgui.Button(fa.ICON_PLAY .. "##play_pickup", imgui.ImVec2(25, 20)) then
                playSoundFile(settings.pickupSoundFile or "pickup.wav", settings.pickupSoundVolume)
            end
            imgui.SameLine(0, 10)
            imgui.Text(u8("Громкость:"))
            imgui.SameLine(0, 5)
            imgui.PushItemWidth(80)
            if imgui.SliderInt("##pickup_vol", pickup_vol_slider, 0, 100) then settings.pickupSoundVolume = pickup_vol_slider.v; saveConfig() end
            imgui.PopItemWidth()
            
            -- Редкий дроп
            if not rareFileIdx then rareFileIdx = imgui.ImInt(0) end
            if rareFileIdx.v < 0 or rareFileIdx.v >= #wavFiles then rareFileIdx.v = 0 end
            for i, f in ipairs(wavFiles) do if f == (settings.rareSoundFile or "rare.wav") then rareFileIdx.v = i - 1; break end end
            imgui.Text(u8("Редкий:"))
            imgui.SameLine(65)
            ShowHelpMarker(u8("Алмаз, Кусок редкой ткани, Древесина высшего качества"))
            imgui.SameLine(100)
            imgui.PushItemWidth(140)
            if imgui.Combo("##rare_file", rareFileIdx, table.concat(wavFiles, "\0") .. "\0") then
                settings.rareSoundFile = wavFiles[rareFileIdx.v + 1]
                saveConfig()
            end
            imgui.PopItemWidth()
            imgui.SameLine(0, 5)
            if imgui.Button(fa.ICON_PLAY .. "##play_rare", imgui.ImVec2(25, 20)) then
                playSoundFile(settings.rareSoundFile or "rare.wav", settings.rareSoundVolume or 80)
            end
            imgui.SameLine(0, 10)
            imgui.Text(u8("Громкость:"))
            imgui.SameLine(0, 5)
            imgui.PushItemWidth(80)
            local rareVol = imgui.ImInt(settings.rareSoundVolume or 80)
            if imgui.SliderInt("##rare_vol", rareVol, 0, 100) then settings.rareSoundVolume = rareVol.v; saveConfig() end
            imgui.PopItemWidth()
            
            -- Очень редкие
            if not coalFileIdx then coalFileIdx = imgui.ImInt(0) end
            if coalFileIdx.v < 0 or coalFileIdx.v >= #wavFiles then coalFileIdx.v = 0 end
            for i, f in ipairs(wavFiles) do if f == (settings.coalSoundFile or "ugol.wav") then coalFileIdx.v = i - 1; break end end
            imgui.Text(u8("Оч.редкие:"))
            imgui.SameLine(65)
            ShowHelpMarker(u8("Уголь, Прочная ткань, Шахтёрский сплав, Тёмная материя"))
            imgui.SameLine(100)
            imgui.PushItemWidth(140)
            if imgui.Combo("##coal_file", coalFileIdx, table.concat(wavFiles, "\0") .. "\0") then
                settings.coalSoundFile = wavFiles[coalFileIdx.v + 1]
                saveConfig()
            end
            imgui.PopItemWidth()
            imgui.SameLine(0, 5)
            if imgui.Button(fa.ICON_PLAY .. "##play_coal", imgui.ImVec2(25, 20)) then
                playSoundFile(settings.coalSoundFile or "ugol.wav", settings.coalSoundVolume or 80)
            end
            imgui.SameLine(0, 10)
            imgui.Text(u8("Громкость:"))
            imgui.SameLine(0, 5)
            imgui.PushItemWidth(80)
            local coalVol = imgui.ImInt(settings.coalSoundVolume or 80)
            if imgui.SliderInt("##coal_vol", coalVol, 0, 100) then settings.coalSoundVolume = coalVol.v; saveConfig() end
            imgui.PopItemWidth()
        end
        
        imgui.Spacing()
        if StyleButton(u8("Обновить список звуков"), fa.ICON_REPEAT, nil) then
            cachedWavFiles = nil
            achivFileIdx = nil; pickupFileIdx = nil; rareFileIdx = nil; coalFileIdx = nil
        end
        imgui.Spacing()
        if StyleButton(u8("Открыть папку со звуками"), fa.ICON_FOLDER_OPEN, nil) then
            shell32.ShellExecuteA(nil, "open", soundsDir, nil, nil, 1)
        end
        imgui.Spacing()
    end
        
    -- ====== TELEGRAM УВЕДОМЛЕНИЯ ======
    cardY = imgui.GetCursorScreenPos().y; cardX = imgui.GetCursorScreenPos().x
    hovered = (imgui.GetMousePos().x >= cardX and imgui.GetMousePos().x <= cardX + listW and imgui.GetMousePos().y >= cardY and imgui.GetMousePos().y <= cardY + cardH)
    bgCol, borderCol, iconCol, titleCol = getCardColors(hovered)
    drawList:AddRectFilled(imgui.ImVec2(cardX, cardY), imgui.ImVec2(cardX + listW, cardY + cardH), bgCol, 6)
    drawList:AddRect(imgui.ImVec2(cardX, cardY), imgui.ImVec2(cardX + listW, cardY + cardH), borderCol, 6, 15, 1.0)
    drawList:AddText(imgui.ImVec2(cardX + 10, cardY + (cardH - 14) / 2), iconCol, fa.ICON_PAPER_PLANE)
    drawList:AddText(imgui.ImVec2(cardX + 35, cardY + (cardH - 14) / 2), titleCol, u8("Telegram уведомления"))
    imgui.SetCursorScreenPos(imgui.ImVec2(cardX, cardY))
    if not settingsExpandedTelegram then settingsExpandedTelegram = false end
    if imgui.InvisibleButton("##settings_telegram", imgui.ImVec2(listW, cardH)) then settingsExpandedTelegram = not settingsExpandedTelegram end
    if settingsExpandedTelegram then
        imgui.Spacing()
        
        if ToggleSwitch(u8("Включить TG уведомления"), imgui.ImBool(tgConfig.enabled or false)) then
            tgConfig.enabled = not tgConfig.enabled
            saveTgConfig()
            needSave = true
        end
        imgui.Spacing()
        
        -- Токен бота
        imgui.Text(u8("Токен бота:"))
        imgui.PushItemWidth(-1)
        if imgui.InputText("##tg_token", tgTokenInput) then
            tgConfig.botToken = u8:decode(tgTokenInput.v)
            saveTgConfig()
        end
        imgui.PopItemWidth()
        imgui.SameLine()
        ShowHelpMarker(u8("Получить у @BotFather в Telegram. Команда /newbot"))
        imgui.Spacing()
        
        -- Chat ID
        imgui.Text(u8("Chat ID:"))
        imgui.PushItemWidth(-1)
        if imgui.InputText("##tg_chatid", tgChatIdInput) then
            tgConfig.chatId = u8:decode(tgChatIdInput.v)
            saveTgConfig()
        end
        imgui.PopItemWidth()
        imgui.SameLine()
        ShowHelpMarker(u8("Получить у @chatIDrobot в Telegram"))
        imgui.Spacing()
        
        imgui.Separator()
        imgui.Spacing()
        
        -- Переключатель резервного сервера
        if ToggleSwitch(u8("Резервный сервер (для России)"), imgui.ImBool(tgConfig.useReserveServer or false)) then
            tgConfig.useReserveServer = not tgConfig.useReserveServer
            saveTgConfig()
            needSave = true
        end
        imgui.SameLine()
        ShowHelpMarker(u8("Включите если Telegram заблокирован в вашем регионе"))
        imgui.Spacing()
        
        imgui.Separator()
        imgui.Spacing()
        
        if ToggleSwitch(u8("Ежедневный отчёт"), imgui.ImBool(tgConfig.dailyReportEnabled or false)) then
            tgConfig.dailyReportEnabled = not tgConfig.dailyReportEnabled
            saveTgConfig()
            needSave = true
        end
        imgui.SameLine()
        ShowHelpMarker(u8("Отправляет отчёт за прошедший игровой день, на следующий день когда вы зайдете первый раз в игру"))
        imgui.Spacing()
        
        if ToggleSwitch(u8("Еженедельный отчёт"), imgui.ImBool(tgConfig.weeklyReportEnabled or false)) then
            tgConfig.weeklyReportEnabled = not tgConfig.weeklyReportEnabled
            saveTgConfig()
            needSave = true
        end
        imgui.SameLine()
        ShowHelpMarker(u8("Отправляет отчёт за прошедшую игровую неделю, в понедельник когда вызайдете первый раз в игру"))
        imgui.Spacing()
        
        if ToggleSwitch(u8("Уведомления о пейдее"), imgui.ImBool(tgConfig.paydayEnabled or false)) then
            tgConfig.paydayEnabled = not tgConfig.paydayEnabled
            saveTgConfig()
            needSave = true
        end
        imgui.SameLine()
        ShowHelpMarker(u8("Отправляет статистику пейдея в Telegram: зарплата, депозит, аксессуары, AZ и общий доход"))
        imgui.Spacing()
        
        if ToggleSwitch(u8("Уведомления об аренде (Item Market)"), imgui.ImBool(tgConfig.itemMarketEnabled or false)) then
            tgConfig.itemMarketEnabled = not tgConfig.itemMarketEnabled
            saveTgConfig()
            needSave = true
        end
        imgui.Spacing()
        
        if ToggleSwitch(u8("Уведомления о выпадении осколков"), imgui.ImBool(tgConfig.shardEnabled or false)) then
            tgConfig.shardEnabled = not tgConfig.shardEnabled
            saveTgConfig()
            needSave = true
        end
        imgui.SameLine()
        ShowHelpMarker(u8("Отправляет уведомление в Telegram при выпадении осколков тайников и NFT"))
        imgui.Spacing()
        
        -- Кнопка видео-обучения
        if StyleButton(u8("Видео-обучение"), fa.ICON_TELEVISION) then
            shell32.ShellExecuteA(nil, "open", "https://youtu.be/WdWKGkxLNdU", nil, nil, 0)
        end
        imgui.Spacing()
        
        -- Кнопка проверки
        if StyleButton(u8("Проверить подключение"), fa.ICON_CHECK) then
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
        imgui.Spacing()
    end
    
    -- ====== РЕЙТИНГ ======
    cardY = imgui.GetCursorScreenPos().y; cardX = imgui.GetCursorScreenPos().x
    hovered = (imgui.GetMousePos().x >= cardX and imgui.GetMousePos().x <= cardX + listW and imgui.GetMousePos().y >= cardY and imgui.GetMousePos().y <= cardY + cardH)
    bgCol, borderCol, iconCol, titleCol = getCardColors(hovered)
    drawList:AddRectFilled(imgui.ImVec2(cardX, cardY), imgui.ImVec2(cardX + listW, cardY + cardH), bgCol, 6)
    drawList:AddRect(imgui.ImVec2(cardX, cardY), imgui.ImVec2(cardX + listW, cardY + cardH), borderCol, 6, 15, 1.0)
    drawList:AddText(imgui.ImVec2(cardX + 10, cardY + (cardH - 14) / 2), iconCol, fa.ICON_TROPHY)
    drawList:AddText(imgui.ImVec2(cardX + 35, cardY + (cardH - 14) / 2), titleCol, u8("Рейтинг (лидерборд)"))
    imgui.SetCursorScreenPos(imgui.ImVec2(cardX, cardY))
    if not settingsExpandedLeaderboard then settingsExpandedLeaderboard = false end
    if imgui.InvisibleButton("##settings_lb", imgui.ImVec2(listW, cardH)) then settingsExpandedLeaderboard = not settingsExpandedLeaderboard end
    if settingsExpandedLeaderboard then
        imgui.Spacing()
        local lbEn = imgui.ImBool(getLbEnabled())
        if useCustomFarmPrices or useCustomMinePrices or useCustomSawmillPrices then
            local drawList = imgui.GetWindowDrawList()
            local pos = imgui.GetCursorScreenPos()
            local switchWidth = 36
            local switchHeight = 20
            local circleRadius = 8
            local label = u8("Участвовать в рейтинге")
            local totalWidth = switchWidth + 10 + imgui.CalcTextSize(label).x
            
            drawList:AddRectFilled(pos, imgui.ImVec2(pos.x + switchWidth, pos.y + switchHeight), 0xFF444444, 10)
            drawList:AddCircleFilled(imgui.ImVec2(pos.x + circleRadius + 3, pos.y + switchHeight / 2), circleRadius, 0xFF888888)
            drawList:AddText(imgui.ImVec2(pos.x + switchWidth + 10, pos.y + 2), 0xFF888888, label)
            imgui.SetCursorScreenPos(pos)
            imgui.InvisibleButton("##toggle_lb_blocked", imgui.ImVec2(totalWidth, switchHeight))
            imgui.SameLine()
            ShowHelpMarker(u8("Отключите собственные цены на всех работах чтобы участвовать в рейтинге"))
        else
            if ToggleSwitch(u8("Участвовать в рейтинге"), lbEn) then
                saveLbConfig("", lbEn.v)
            end
        end
        imgui.Spacing()
        local _, playerId = sampGetPlayerIdByCharHandle(PLAYER_PED)
        local serverNick = sampGetPlayerNickname(playerId) or ""
        local host = sampGetCurrentServerAddress()
        local serverDisplay = ""
        if host and host ~= "" then
            local servers = {
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
                ["80.66.82.22"] = "Drake", ["80.66.82.199"] = "Space"
            }
            serverDisplay = servers[host] or ""
        end
        imgui.Text(u8("Ваш ник: ") .. serverNick)
        if serverDisplay ~= "" then
            if serverIcons[serverDisplay] then
                imgui.Text(u8("Сервер: "))
                imgui.SameLine()
                imgui.Image(serverIcons[serverDisplay], imgui.ImVec2(16, 16))
                imgui.SameLine()
                imgui.Text(serverDisplay)
            else
                imgui.Text(u8("Сервер: ") .. serverDisplay)
            end
        end
        if serverNick == "" then
            imgui.TextColored(imgui.ImVec4(1.0, 0.5, 0.2, 1), u8("Ник не определён. Зайдите на сервер!"))
        end
        imgui.Spacing()
    end
        -- ====== НАСТРОЙКИ ОВЕРЛЕЯ ======
    cardY = imgui.GetCursorScreenPos().y; cardX = imgui.GetCursorScreenPos().x
    hovered = (imgui.GetMousePos().x >= cardX and imgui.GetMousePos().x <= cardX + listW and imgui.GetMousePos().y >= cardY and imgui.GetMousePos().y <= cardY + cardH)
    bgCol, borderCol, iconCol, titleCol = getCardColors(hovered)
    drawList:AddRectFilled(imgui.ImVec2(cardX, cardY), imgui.ImVec2(cardX + listW, cardY + cardH), bgCol, 6)
    drawList:AddRect(imgui.ImVec2(cardX, cardY), imgui.ImVec2(cardX + listW, cardY + cardH), borderCol, 6, 15, 1.0)
    drawList:AddText(imgui.ImVec2(cardX + 10, cardY + (cardH - 14) / 2), iconCol, fa.ICON_PAINT_BRUSH)
    drawList:AddText(imgui.ImVec2(cardX + 35, cardY + (cardH - 14) / 2), titleCol, u8("Настройки оверлея"))
    imgui.SetCursorScreenPos(imgui.ImVec2(cardX, cardY))
    if not settingsExpandedOverlayStyle then settingsExpandedOverlayStyle = false end
    if imgui.InvisibleButton("##settings_overlay_style", imgui.ImVec2(listW, cardH)) then settingsExpandedOverlayStyle = not settingsExpandedOverlayStyle end
    if settingsExpandedOverlayStyle then
        imgui.Spacing()
        
        --ОФОРМЛЕНИЕ
        imgui.TextColored(imgui.ImVec4(1.0, 0.8, 0.2, 1), u8("Оформление"))
        imgui.Spacing()
        imgui.Text(u8("Стиль:"))
        imgui.PushItemWidth(200)
        if imgui.Combo("##overlay_style", cb_overlayStyle, table.concat(overlayStyleNames, "\0") .. "\0") then
            settings.overlayStyle = cb_overlayStyle.v + 1
            saveConfig()
            needSave = true
        end
        imgui.PopItemWidth()
        imgui.Spacing()
        
        if not settings.regularmineEnabled then
            imgui.Text(u8("Столбцы в оверлее шахты:"))
            imgui.PushItemWidth(200)
            if imgui.Combo("##overlay_cols", cb_overlayColumns, table.concat(overlayColumnsNames, "\0") .. "\0") then
                settings.overlayColumns = cb_overlayColumns.v + 1
                saveConfig()
                needSave = true
            end
            imgui.PopItemWidth()
        else
            imgui.TextColored(imgui.ImVec4(0.6, 0.6, 0.6, 1), u8("Столбцы: 1 (обычная шахта)"))
        end
        imgui.Spacing()
        
        --ПОВЕДЕНИЕ
        imgui.Separator()
        imgui.Spacing()
        imgui.TextColored(imgui.ImVec4(1.0, 0.8, 0.2, 1), u8("Поведение"))
        imgui.Spacing()
        
        if ToggleSwitch(u8("Скрывать оверлей при наведении"), cb_overlayHideOnHover, u8("После того как вы выбрали удобную позицию для оверлея, включите эту настройку. При наведении мыши окно оверлея будет полностью скрываться.")) then
            settings.overlayHideOnHover = cb_overlayHideOnHover.v
            saveConfig()
            needSave = true
        end
        imgui.Spacing()
        
        --ТАЙМЕР
        imgui.Separator()
        imgui.Spacing()
        imgui.TextColored(imgui.ImVec4(1.0, 0.8, 0.2, 1), u8("Таймер"))
        imgui.Spacing()
        if ToggleSwitch(u8("Таймер в оверлее"), cb_overlay_timer) then 
            settings.overlayTimerEnabled = cb_overlay_timer.v
            if not cb_overlay_timer.v then 
                overlayTimer.running = false
                overlayTimer.elapsed = 0
                overlayTimer.displayedTime = "00:00:00"
            end
            saveConfig()
            needSave = true
        end
        if settings.overlayTimerEnabled then
            if ToggleSwitch(u8("Автозапуск при включении оверлея"), cb_overlayAutoTimer) then
                settings.overlayAutoTimer = cb_overlayAutoTimer.v
                saveConfig()
                needSave = true
            end
            imgui.Spacing()
            if not overlayTimer.running then
                if imgui.Button(u8("Запустить таймер"), imgui.ImVec2(200, 25)) then 
                    overlayTimer.running = true
                    overlayTimer.startTime = os.time()
                    overlayTimer.elapsed = 0
                    overlayTimer.displayedTime = "00:00:00"
                end
            else
                imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(1.0, 0.3, 0.3, 1.0))
                imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(1.0, 0.2, 0.2, 1.0))
                imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.9, 0.1, 0.1, 1.0))
                if imgui.Button(u8("Остановить таймер"), imgui.ImVec2(200, 25)) then 
                    overlayTimer.running = false
                    overlayTimer.elapsed = os.time() - overlayTimer.startTime
                    overlayTimer.displayedTime = formatTime(overlayTimer.elapsed)
                    sampAddChatMessage(SCRIPT_PREFIX .. "Таймер остановлен. Время работы: " .. overlayTimer.displayedTime, SCRIPT_COLOR)
                end
                imgui.PopStyleColor(3)
                imgui.SameLine()
                imgui.TextColored(imgui.ImVec4(0.3, 1.0, 1.0, 1), u8("Текущее время: " .. overlayTimer.displayedTime))
            end
        end
        imgui.Spacing()
        
        --СБРОС ДАННЫХ
        imgui.Separator()
        imgui.Spacing()
        imgui.TextColored(imgui.ImVec4(1.0, 0.8, 0.2, 1), u8("Сброс отображаемых данных"))
        imgui.Spacing()
        
        local btnW3 = (imgui.GetWindowWidth() - 25 - 16) / 3
        
        if StyleButton(u8("Сбросить ферму"), fa.ICON_LEAF, btnW3) then
            resetOverlayData(WORK_TYPES.FARM)
            sampAddChatMessage(SCRIPT_PREFIX .. "Данные оверлея фермы сброшены!", SCRIPT_COLOR)
        end
        imgui.SameLine()
        
        if StyleButton(u8("Сбросить шахту"), fa.ICON_GAVEL, btnW3) then
            resetOverlayData(WORK_TYPES.MINE)
            sampAddChatMessage(SCRIPT_PREFIX .. "Данные оверлея шахты сброшены!", SCRIPT_COLOR)
        end
        imgui.SameLine()
        
        if StyleButton(u8("Сбросить лесопилку"), fa.ICON_TREE, btnW3) then
            resetOverlayData(WORK_TYPES.SAWMILL)
            sampAddChatMessage(SCRIPT_PREFIX .. "Данные оверлея лесопилки сброшены!", SCRIPT_COLOR)
        end
        imgui.Spacing()
    end
    -- ====== НАСТРОЙКИ ДОХОДА ======
    cardY = imgui.GetCursorScreenPos().y; cardX = imgui.GetCursorScreenPos().x
    hovered = (imgui.GetMousePos().x >= cardX and imgui.GetMousePos().x <= cardX + listW and imgui.GetMousePos().y >= cardY and imgui.GetMousePos().y <= cardY + cardH)
    bgCol, borderCol, iconCol, titleCol = getCardColors(hovered)
    drawList:AddRectFilled(imgui.ImVec2(cardX, cardY), imgui.ImVec2(cardX + listW, cardY + cardH), bgCol, 6)
    drawList:AddRect(imgui.ImVec2(cardX, cardY), imgui.ImVec2(cardX + listW, cardY + cardH), borderCol, 6, 15, 1.0)
    drawList:AddText(imgui.ImVec2(cardX + 10, cardY + (cardH - 14) / 2), iconCol, fa.ICON_MONEY)
    drawList:AddText(imgui.ImVec2(cardX + 35, cardY + (cardH - 14) / 2), titleCol, u8("Настройки дохода"))
    imgui.SetCursorScreenPos(imgui.ImVec2(cardX, cardY))
    if not settingsExpandedIncome then settingsExpandedIncome = false end
    if imgui.InvisibleButton("##settings_income", imgui.ImVec2(listW, cardH)) then settingsExpandedIncome = not settingsExpandedIncome end
    if settingsExpandedIncome then
        imgui.Spacing()
        if ToggleSwitch(u8("Авто-сканирование талона AZ"), cb_talonAutoScan, u8("При отключении не будут учитываться AZ из сообщений «Вам был добавлен предмет...»")) then
            settings.talonAutoScanEnabled = cb_talonAutoScan.v
            saveConfig()
            needSave = true
        end
        imgui.Spacing()
    end
    
    imgui.Spacing(); imgui.Separator(); imgui.Spacing()
    imgui.PushStyleColor(imgui.Col.Button, needSaveColor)
    if StyleButton(u8("Сохранить все настройки"), fa.ICON_FLOPPY_O) then saveConfig(); savePrices(); saveOverlayConfig(); saveGoals(); saveStats(); saveThemeConfig(); saveCustomTheme(); sampAddChatMessage(SCRIPT_PREFIX.."Настройки сохранены!", SCRIPT_COLOR); needSave = false end
    imgui.PopStyleColor(1)
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
function drawFarmGoals()
    local farmGoals = {}
    local farmDailyRes = {}
    
    local fgf = io.open(farmGoalsConfigPath, "r")
    if fgf then
        local data = decodeJson(fgf:read("*a"))
        fgf:close()
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
    
    local fpf = io.open(getServerGoalsProgressPath(WORK_TYPES.FARM), "r")
    if fpf then
        local data = decodeJson(fpf:read("*a"))
        fpf:close()
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
    
    imgui.Columns(2, "goals_farm_cols", false)
    imgui.SetColumnWidth(0, imgui.GetWindowWidth() * 0.5)
    local farmOrder = configs[WORK_TYPES.FARM].resourceOrder
    local halfFarm = math.ceil(#farmOrder / 2)
    for i = 1, halfFarm do
        local k = farmOrder[i]
        local cur = farmDailyRes[k] or 0
        local g = farmGoalEditCache[k].v
        local p = math.min(cur / g, 1.0)
        imgui.Text(u8(configs[WORK_TYPES.FARM].resourceNames[k] .. ": " .. formatNumber(cur) .. " / " .. formatNumber(g)))
        imgui.ProgressBar(p, imgui.ImVec2(-1, 15), u8(math.floor(p * 100) .. "%"))
        imgui.PushItemWidth(imgui.GetColumnWidth() - 10)
        imgui.InputInt("##goal_farm_global_" .. k, farmGoalEditCache[k], 10, 100)
        imgui.PopItemWidth()
        imgui.NextColumn()
    end
    imgui.SetColumnWidth(1, imgui.GetWindowWidth() * 0.5)
    for i = halfFarm + 1, #farmOrder do
        local k = farmOrder[i]
        local cur = farmDailyRes[k] or 0
        local g = farmGoalEditCache[k].v
        local p = math.min(cur / g, 1.0)
        imgui.Text(u8(configs[WORK_TYPES.FARM].resourceNames[k] .. ": " .. formatNumber(cur) .. " / " .. formatNumber(g)))
        imgui.ProgressBar(p, imgui.ImVec2(-1, 15), u8(math.floor(p * 100) .. "%"))
        imgui.PushItemWidth(imgui.GetColumnWidth() - 10)
        imgui.InputInt("##goal_farm_global_" .. k, farmGoalEditCache[k], 10, 100)
        imgui.PopItemWidth()
        if i < #farmOrder then imgui.NextColumn() end
    end
    imgui.Columns(1)
    imgui.Spacing()
    local btnWidth = imgui.GetWindowWidth() / 2 - 10
    if StyleButton(u8("Сохранить цели"), nil, btnWidth) then
        local saveData = {}
        for _, k in ipairs(farmOrder) do
            saveData[k] = farmGoalEditCache[k].v
        end
        local f = io.open(farmGoalsConfigPath, "w")
        if f then f:write(encodeJson(saveData)); f:close() end
        sampAddChatMessage(SCRIPT_PREFIX.."Цели фермы сохранены!", SCRIPT_COLOR)
    end
    imgui.SameLine()
    if StyleButton(u8("Сбросить прогресс"), nil, btnWidth) then
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
    
    local mgf = io.open(mineGoalsConfigPath, "r")
    if mgf then
        local data = decodeJson(mgf:read("*a"))
        mgf:close()
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
    
    local mpf = io.open(getServerGoalsProgressPath(WORK_TYPES.MINE), "r")
    if mpf then
        local data = decodeJson(mpf:read("*a"))
        mpf:close()
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
    
    imgui.Columns(2, "goals_mine_cols", false)
    imgui.SetColumnWidth(0, imgui.GetWindowWidth() * 0.5)
    local mineOrder = configs[WORK_TYPES.MINE].resourceOrder
    local halfMine = math.ceil(#mineOrder / 2)
    for i = 1, halfMine do
        local k = mineOrder[i]
        local cur = mineDailyRes[k] or 0
        local g = mineGoalEditCache[k].v
        local p = math.min(cur / g, 1.0)
        imgui.Text(u8(configs[WORK_TYPES.MINE].resourceNames[k] .. ": " .. formatNumber(cur) .. " / " .. formatNumber(g)))
        imgui.ProgressBar(p, imgui.ImVec2(-1, 15), u8(math.floor(p * 100) .. "%"))
        imgui.PushItemWidth(imgui.GetColumnWidth() - 10)
        imgui.InputInt("##goal_mine_global_" .. k, mineGoalEditCache[k], 10, 100)
        imgui.PopItemWidth()
        imgui.NextColumn()
    end
    imgui.SetColumnWidth(1, imgui.GetWindowWidth() * 0.5)
    for i = halfMine + 1, #mineOrder do
        local k = mineOrder[i]
        local cur = mineDailyRes[k] or 0
        local g = mineGoalEditCache[k].v
        local p = math.min(cur / g, 1.0)
        imgui.Text(u8(configs[WORK_TYPES.MINE].resourceNames[k] .. ": " .. formatNumber(cur) .. " / " .. formatNumber(g)))
        imgui.ProgressBar(p, imgui.ImVec2(-1, 15), u8(math.floor(p * 100) .. "%"))
        imgui.PushItemWidth(imgui.GetColumnWidth() - 10)
        imgui.InputInt("##goal_mine_global_" .. k, mineGoalEditCache[k], 10, 100)
        imgui.PopItemWidth()
        if i < #mineOrder then imgui.NextColumn() end
    end
    imgui.Columns(1)
    imgui.Spacing()
    local btnWidth = imgui.GetWindowWidth() / 2 - 10
    if StyleButton(u8("Сохранить цели"), nil, btnWidth) then
        local saveData = {}
        for _, k in ipairs(mineOrder) do
            saveData[k] = mineGoalEditCache[k].v
        end
        local f = io.open(mineGoalsConfigPath, "w")
        if f then f:write(encodeJson(saveData)); f:close() end
        sampAddChatMessage(SCRIPT_PREFIX.."Цели шахты сохранены!", SCRIPT_COLOR)
    end
    imgui.SameLine()
    if StyleButton(u8("Сбросить прогресс"), nil, btnWidth) then
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
    
    local sgf = io.open(sawmillGoalsConfigPath, "r")
    if sgf then
        local data = decodeJson(sgf:read("*a"))
        sgf:close()
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
    
    local spf = io.open(getServerGoalsProgressPath(WORK_TYPES.SAWMILL), "r")
    if spf then
        local data = decodeJson(spf:read("*a"))
        spf:close()
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
    for _, k in ipairs(sawOrder) do
        local cur = sawDailyRes[k] or 0
        local g = sawmillGoalEditCache[k].v
        local p = math.min(cur / g, 1.0)
        imgui.Text(u8(configs[WORK_TYPES.SAWMILL].resourceNames[k] .. ": " .. formatNumber(cur) .. " / " .. formatNumber(g)))
        imgui.ProgressBar(p, imgui.ImVec2(-1, 15), u8(math.floor(p * 100) .. "%"))
        imgui.PushItemWidth(200)
        imgui.InputInt("##goal_saw_global_" .. k, sawmillGoalEditCache[k], 10, 100)
        imgui.PopItemWidth()
    end
    imgui.Spacing()
    local btnWidth = imgui.GetWindowWidth() / 2 - 10
    if StyleButton(u8("Сохранить цели"), nil, btnWidth) then
        local saveData = {}
        for _, k in ipairs(sawOrder) do
            saveData[k] = sawmillGoalEditCache[k].v
        end
        local f = io.open(sawmillGoalsConfigPath, "w")
        if f then f:write(encodeJson(saveData)); f:close() end
        sampAddChatMessage(SCRIPT_PREFIX.."Цели лесопилки сохранены!", SCRIPT_COLOR)
    end
    imgui.SameLine()
    if StyleButton(u8("Сбросить прогресс"), nil, btnWidth) then
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
    local invSectionBtnW = (imgui.GetWindowWidth() - 25 - 8) / 2
    for i, name in ipairs(invSectionNames) do
        if i > 1 then imgui.SameLine() end
        if StyleButton(name, nil, invSectionBtnW, invSectionTab.v == i - 1) then
            invSectionTab.v = i - 1
        end
    end
    imgui.Spacing(); imgui.Separator(); imgui.Spacing()

    local drawList = imgui.GetWindowDrawList()
    local listW = imgui.GetWindowWidth() - 25
    
    local function getCardColors(hovered)
        if useCustomTheme then
            return imVec4ToHex(hovered and CUSTOM_THEME.cardBgHovered or CUSTOM_THEME.cardBg),
                   imVec4ToHex(CUSTOM_THEME.cardBorder),
                   imVec4ToHex(CUSTOM_THEME.cardIcon),
                   imVec4ToHex(CUSTOM_THEME.cardTitle)
        else
            return (hovered and 0xFF222222 or 0xFF1A1A1A), 0xFF333333, 0xFF1AE591, 0xFF1AE591
        end
    end

    local statBg = useCustomTheme and imVec4ToHex(CUSTOM_THEME.statCardBg) or 0xFF1A1A1A
    local statBorder = useCustomTheme and imVec4ToHex(CUSTOM_THEME.statCardBorder) or 0xFF333333
    local statLabel = useCustomTheme and imVec4ToHex(CUSTOM_THEME.statCardLabel) or 0xFF888888
    local statValue = useCustomTheme and imVec4ToHex(CUSTOM_THEME.statCardValue) or 0xFF1AE591
    local statValueToday = useCustomTheme and imVec4ToHex(CUSTOM_THEME.statCardValueToday) or 0xFFFFCC00
    local statValueWeek = useCustomTheme and imVec4ToHex(CUSTOM_THEME.statCardValueWeek) or 0xFF33CCFF

    
    --  СТАТИСТИКА
    
    if invSectionTab.v == 0 then
        local allDates = {}
        local seenDates = {}
        for _, log in ipairs(investmentLog) do
            local d = getGameDate(log.time)
            if not seenDates[d] then seenDates[d] = true; table.insert(allDates, d) end
        end
        table.sort(allDates, function(a, b) return a > b end)

        if not invSelectedDateStr then
            if allDates[1] then
                invSelectedDateStr = allDates[1]
            else
                local t = os.date("*t")
                invSelectedDateStr = string.format("%04d-%02d-%02d", t.year, t.month, t.day)
            end
            local yy, mm = invSelectedDateStr:match("(%d+)-(%d+)-")
            invCalendarYear = tonumber(yy)
            invCalendarMonth = tonumber(mm)
        end

        local totalAll, todayAll, weekAll = 0, 0, 0
        local todayDate = getGameDate()
        local mskTime = getMoscowTime()
        local mskWday = tonumber(os.date("%w", mskTime))
        if mskWday == 0 then mskWday = 7 end

        for _, log in ipairs(investmentLog) do
            local cost = (investmentConfig[log.itemId] and investmentConfig[log.itemId].cost) or 0
            totalAll = totalAll + cost
            if getGameDate(log.time) == todayDate then
                todayAll = todayAll + cost
            end
        end
        local daysSinceMonday = mskWday - 1
        for i = 0, daysSinceMonday do
            local date = getGameDate(os.time() - i * 86400)
            for _, log in ipairs(investmentLog) do
                if getGameDate(log.time) == date then
                    local cost = (investmentConfig[log.itemId] and investmentConfig[log.itemId].cost) or 0
                    weekAll = weekAll + cost
                end
            end
        end

        local cardSpacing = 8
        local cardWidth = (listW - cardSpacing * 2) / 3
        local cardHeight = 55
        local startPos = imgui.GetCursorScreenPos()

        drawList:AddRectFilled(startPos, imgui.ImVec2(startPos.x + cardWidth, startPos.y + cardHeight), statBg, 6)
        drawList:AddRect(startPos, imgui.ImVec2(startPos.x + cardWidth, startPos.y + cardHeight), statBorder, 6, 15, 1.0)
        drawList:AddText(imgui.ImVec2(startPos.x + 10, startPos.y + 8), statLabel, u8("Всего за ларцы"))
        drawList:AddText(imgui.ImVec2(startPos.x + 10, startPos.y + 28), statValue, formatNumber(totalAll) .. "$")

        local pos2 = imgui.ImVec2(startPos.x + cardWidth + cardSpacing, startPos.y)
        drawList:AddRectFilled(pos2, imgui.ImVec2(pos2.x + cardWidth, pos2.y + cardHeight), statBg, 6)
        drawList:AddRect(pos2, imgui.ImVec2(pos2.x + cardWidth, pos2.y + cardHeight), statBorder, 6, 15, 1.0)
        drawList:AddText(imgui.ImVec2(pos2.x + 10, pos2.y + 8), statLabel, u8("За сегодня"))
        drawList:AddText(imgui.ImVec2(pos2.x + 10, pos2.y + 28), statValueToday, formatNumber(todayAll) .. "$")

        local pos3 = imgui.ImVec2(startPos.x + cardWidth * 2 + cardSpacing * 2, startPos.y)
        drawList:AddRectFilled(pos3, imgui.ImVec2(pos3.x + cardWidth, pos3.y + cardHeight), statBg, 6)
        drawList:AddRect(pos3, imgui.ImVec2(pos3.x + cardWidth, pos3.y + cardHeight), statBorder, 6, 15, 1.0)
        drawList:AddText(imgui.ImVec2(pos3.x + 10, pos3.y + 8), statLabel, u8("За неделю"))
        drawList:AddText(imgui.ImVec2(pos3.x + 10, pos3.y + 28), statValueWeek, formatNumber(weekAll) .. "$")

        imgui.SetCursorScreenPos(imgui.ImVec2(startPos.x, startPos.y + cardHeight))
        imgui.Dummy(imgui.ImVec2(listW, 0))
        imgui.Spacing(); imgui.Separator(); imgui.Spacing()

        if #allDates > 0 then
            local selectedDate = invSelectedDateStr
            local daySum, logCount = 0, 0
            if selectedDate then
                for i = 1, math.min(#investmentLog, 500) do
                    local log = investmentLog[i]
                    if getGameDate(log.time) == selectedDate then
                        local cost = (investmentConfig[log.itemId] and investmentConfig[log.itemId].cost) or 0
                        daySum = daySum + cost
                        logCount = logCount + 1
                    end
                end
            end

            local btnW = listW; local btnH = 38
            local btnPos = imgui.GetCursorScreenPos()
            local hovered = (imgui.GetMousePos().x >= btnPos.x and imgui.GetMousePos().x <= btnPos.x + btnW and imgui.GetMousePos().y >= btnPos.y and imgui.GetMousePos().y <= btnPos.y + btnH)
            local dateBgCol, dateBorderCol, iconCol = getCardColors(hovered)
            drawList:AddRectFilled(btnPos, imgui.ImVec2(btnPos.x + btnW, btnPos.y + btnH), dateBgCol, 6)
            drawList:AddRect(btnPos, imgui.ImVec2(btnPos.x + btnW, btnPos.y + btnH), dateBorderCol, 6, 15, 1.0)

            local y, m, day = selectedDate:match("(%d+)-(%d+)-(%d+)")
            local displaySelected = selectedDate
            if y and m and day then displaySelected = day .. "." .. m .. "." .. y end
            drawList:AddText(imgui.ImVec2(btnPos.x + 12, btnPos.y + 10), iconCol, fa.ICON_CALENDAR .. " " .. displaySelected)

            local sumText = formatNumber(daySum) .. "$"
            local infoText = "  •  " .. logCount .. " " .. u8("ларцов")
            local sumTextW = imgui.CalcTextSize(sumText).x; local infoTextW = imgui.CalcTextSize(infoText).x
            drawList:AddText(imgui.ImVec2(btnPos.x + btnW - sumTextW - infoTextW - 35, btnPos.y + 10), iconCol, sumText)
            drawList:AddText(imgui.ImVec2(btnPos.x + btnW - infoTextW - 35, btnPos.y + 10), 0xFF888888, infoText)
            drawList:AddText(imgui.ImVec2(btnPos.x + btnW - 25, btnPos.y + 10), 0xFF888888, fa.ICON_ARROW_DOWN)
            imgui.SetCursorScreenPos(btnPos)
            if imgui.InvisibleButton("##inv_date_btn", imgui.ImVec2(btnW, btnH)) then
                local cyy, cmm = invSelectedDateStr:match("(%d+)-(%d+)-")
                if cyy and cmm then invCalendarYear = tonumber(cyy); invCalendarMonth = tonumber(cmm) end
                imgui.OpenPopup("##inv_date_popup")
            end

            if imgui.BeginPopup("##inv_date_popup") then
                local monthNamesRu = {u8("Январь"), u8("Февраль"), u8("Март"), u8("Апрель"), u8("Май"), u8("Июнь"), u8("Июль"), u8("Август"), u8("Сентябрь"), u8("Октябрь"), u8("Ноябрь"), u8("Декабрь")}
                local weekdayNamesRu = {u8("Пн"), u8("Вт"), u8("Ср"), u8("Чт"), u8("Пт"), u8("Сб"), u8("Вс")}
                local todayStr = getGameDate()
                local ACCENT = 0xFF6078E0
                local TODAY_RING = 0xFFFFFFFF
                local DOT_GREEN = 0xFFD4BC00

                local function daysInMonth(yy, mm)
                    local dim = {31,28,31,30,31,30,31,31,30,31,30,31}
                    if mm == 2 and (yy % 4 == 0 and (yy % 100 ~= 0 or yy % 400 == 0)) then return 29 end
                    return dim[mm]
                end
                local function firstWeekdayOfMonth(yy, mm)
                    local t = os.time({year = yy, month = mm, day = 1, hour = 12})
                    local w = tonumber(os.date("%w", t))
                    if w == 0 then w = 7 end
                    return w
                end

                local calDrawList = imgui.GetWindowDrawList()
                local cellSize = 34; local cellGap = 2; local step = cellSize + cellGap; local headerW = step * 7
                local headerPos = imgui.GetCursorScreenPos(); local headerH = 30; local btnSz = 24

                local leftBtnX = headerPos.x; local leftBtnY = headerPos.y + (headerH - btnSz) / 2
                local mouseP = imgui.GetMousePos()
                local leftHovered = (mouseP.x >= leftBtnX and mouseP.x <= leftBtnX + btnSz and mouseP.y >= leftBtnY and mouseP.y <= leftBtnY + btnSz)
                local leftCenter = imgui.ImVec2(leftBtnX + btnSz / 2, leftBtnY + btnSz / 2)
                calDrawList:AddCircleFilled(leftCenter, btnSz / 2, leftHovered and 0xFF2E2E2E or 0xFF1C1C1C, 20)
                calDrawList:AddText(imgui.ImVec2(leftCenter.x - imgui.CalcTextSize(fa.ICON_ANGLE_LEFT).x / 2, leftCenter.y - imgui.CalcTextSize(fa.ICON_ANGLE_LEFT).y / 2), leftHovered and 0xFFFFFFFF or 0xFFAAAAAA, fa.ICON_ANGLE_LEFT)
                imgui.SetCursorScreenPos(imgui.ImVec2(leftBtnX, leftBtnY))
                if imgui.InvisibleButton("##invcal_left", imgui.ImVec2(btnSz, btnSz)) then
                    invCalendarMonth = invCalendarMonth - 1
                    if invCalendarMonth < 1 then invCalendarMonth = 12; invCalendarYear = invCalendarYear - 1 end
                end

                local rightBtnX = headerPos.x + headerW - btnSz; local rightBtnY = leftBtnY
                local rightHovered = (mouseP.x >= rightBtnX and mouseP.x <= rightBtnX + btnSz and mouseP.y >= rightBtnY and mouseP.y <= rightBtnY + btnSz)
                local rightCenter = imgui.ImVec2(rightBtnX + btnSz / 2, rightBtnY + btnSz / 2)
                calDrawList:AddCircleFilled(rightCenter, btnSz / 2, rightHovered and 0xFF2E2E2E or 0xFF1C1C1C, 20)
                calDrawList:AddText(imgui.ImVec2(rightCenter.x - imgui.CalcTextSize(fa.ICON_ANGLE_RIGHT).x / 2, rightCenter.y - imgui.CalcTextSize(fa.ICON_ANGLE_RIGHT).y / 2), rightHovered and 0xFFFFFFFF or 0xFFAAAAAA, fa.ICON_ANGLE_RIGHT)
                imgui.SetCursorScreenPos(imgui.ImVec2(rightBtnX, rightBtnY))
                if imgui.InvisibleButton("##invcal_right", imgui.ImVec2(btnSz, btnSz)) then
                    invCalendarMonth = invCalendarMonth + 1
                    if invCalendarMonth > 12 then invCalendarMonth = 1; invCalendarYear = invCalendarYear + 1 end
                end

                local monthName = monthNamesRu[invCalendarMonth]; local yearName = tostring(invCalendarYear)
                local monthNameW = imgui.CalcTextSize(monthName).x; local monthNameH = imgui.CalcTextSize(monthName).y
                local yearNameW = imgui.CalcTextSize(yearName).x; local yearNameH = imgui.CalcTextSize(yearName).y
                local totalH = monthNameH + yearNameH + 2; local textStartY = headerPos.y + (headerH - totalH) / 2
                calDrawList:AddText(imgui.ImVec2(headerPos.x + (headerW - monthNameW) / 2, textStartY), 0xFF6078E0, monthName)
                calDrawList:AddText(imgui.ImVec2(headerPos.x + (headerW - yearNameW) / 2, textStartY + monthNameH + 2), 0xFFAAAAAA, yearName)

                imgui.SetCursorScreenPos(imgui.ImVec2(headerPos.x, headerPos.y + headerH)); imgui.Dummy(imgui.ImVec2(headerW, 4))
                local subSepY = imgui.GetCursorScreenPos().y + 2
                calDrawList:AddLine(imgui.ImVec2(headerPos.x, subSepY), imgui.ImVec2(headerPos.x + headerW, subSepY), 0xFF2A2A2A, 1.0)
                imgui.SetCursorScreenPos(imgui.ImVec2(headerPos.x, subSepY + 8))

                local hdrPos = imgui.GetCursorScreenPos()
                for i, wd in ipairs(weekdayNamesRu) do
                    local isWeekend = (i == 6 or i == 7)
                    calDrawList:AddText(imgui.ImVec2(hdrPos.x + (i - 1) * step + (cellSize - imgui.CalcTextSize(wd).x) / 2, hdrPos.y), isWeekend and 0xFF6078E0 or 0xFF666666, wd)
                end
                imgui.Dummy(imgui.ImVec2(headerW, 18))

                local startWd = firstWeekdayOfMonth(invCalendarYear, invCalendarMonth)
                local totalDays = daysInMonth(invCalendarYear, invCalendarMonth)
                local gridPos = imgui.GetCursorScreenPos()

                local row, col = 0, startWd - 1
                for dnum = 1, totalDays do
                    local cellX = gridPos.x + col * step; local cellY = gridPos.y + row * step
                    local center = imgui.ImVec2(cellX + cellSize / 2, cellY + cellSize / 2)
                    local dateStr = string.format("%04d-%02d-%02d", invCalendarYear, invCalendarMonth, dnum)
                    local hasData = seenDates[dateStr] == true
                    local isSelected = (dateStr == invSelectedDateStr)
                    local isToday = (dateStr == todayStr)
                    local cellHovered = (mouseP.x >= cellX and mouseP.x <= cellX + cellSize and mouseP.y >= cellY and mouseP.y <= cellY + cellSize)

                    if isSelected and isToday then
                        calDrawList:AddCircleFilled(center, cellSize / 2 - 1, ACCENT, 24)
                        calDrawList:AddCircle(center, cellSize / 2 - 1, TODAY_RING, 24, 2.0)
                    elseif isSelected then calDrawList:AddCircleFilled(center, cellSize / 2 - 1, ACCENT, 24)
                    elseif isToday then calDrawList:AddCircle(center, cellSize / 2 - 1, TODAY_RING, 24, 1.5)
                    elseif cellHovered then calDrawList:AddCircle(center, cellSize / 2 - 1, 0xFF444444, 24, 1.0) end

                    local dayStr = tostring(dnum); local dayStrSz = imgui.CalcTextSize(dayStr)
                    local textCol = isSelected and 0xFFFFFFFF or (isToday and 0xFF1AE591 or (hasData and 0xFFCCCCCC or 0xFF666666))
                    calDrawList:AddText(imgui.ImVec2(center.x - dayStrSz.x / 2, center.y - dayStrSz.y / 2 - (hasData and 3 or 0)), textCol, dayStr)

                    if hasData then
                        calDrawList:AddCircleFilled(imgui.ImVec2(center.x, center.y + dayStrSz.y / 2 + 2), 2.0, DOT_GREEN, 12)
                    end

                    imgui.SetCursorScreenPos(imgui.ImVec2(cellX, cellY))
                    if imgui.InvisibleButton("##invcal_" .. dateStr, imgui.ImVec2(cellSize, cellSize)) then
                        invSelectedDateStr = dateStr
                        imgui.CloseCurrentPopup()
                    end

                    col = col + 1; if col > 6 then col = 0; row = row + 1 end
                end

                imgui.SetCursorScreenPos(imgui.ImVec2(gridPos.x, gridPos.y + (row + 1) * step + 4))
                imgui.EndPopup()
            end

            imgui.SetCursorScreenPos(imgui.ImVec2(btnPos.x, btnPos.y + btnH))
            imgui.Dummy(imgui.ImVec2(btnW, 4))

            if selectedDate and logCount > 0 then
                imgui.Spacing()
                local logs = {}
                for i = 1, math.min(#investmentLog, 500) do
                    local log = investmentLog[i]
                    if getGameDate(log.time) == selectedDate then table.insert(logs, log) end
                end

                local hdrX = imgui.GetCursorScreenPos().x
                local tblTopY = imgui.GetCursorScreenPos().y
                local hdrH = 28
                local rowH = 32
                local tblTotalH = hdrH + #logs * rowH

                local colX = {hdrX, hdrX + 70, hdrX + listW - 140, hdrX + listW}
                local headerLabels = {u8("Время"), u8("Название"), u8("Доход")}
                local headerAligns = {"left", "left", "right"}
                
                drawList:AddRectFilled(imgui.ImVec2(hdrX, tblTopY), imgui.ImVec2(hdrX + listW, tblTopY + tblTotalH), 0xFF0C0C0C, 8, 15)
                drawList:AddRectFilled(imgui.ImVec2(hdrX, tblTopY), imgui.ImVec2(hdrX + listW, tblTopY + hdrH), 0xFF222222, 8, 3)

                for i, lbl in ipairs(headerLabels) do
                    local cx0, cx1 = colX[i], colX[i + 1]
                    local tw = imgui.CalcTextSize(lbl).x
                    local tx
                    if headerAligns[i] == "center" then tx = cx0 + (cx1 - cx0 - tw) / 2
                    elseif headerAligns[i] == "right" then tx = cx1 - tw - 12
                    else tx = cx0 + 12 end
                    drawList:AddText(imgui.ImVec2(tx, tblTopY + 7), 0xFF888888, lbl)
                end

                for logIdx, log in ipairs(logs) do
                    local msk = log.time + 10800; local timeStr = os.date("!%H:%M", msk)
                    local rowY = tblTopY + hdrH + (logIdx - 1) * rowH
                    local rowBg = (logIdx % 2 == 0) and 0xFF171717 or 0xFF121212
                    drawList:AddRectFilled(imgui.ImVec2(hdrX + 1, rowY), imgui.ImVec2(hdrX + listW - 1, rowY + rowH), rowBg)
                    
                    drawList:AddText(imgui.ImVec2(colX[1] + 12, rowY + 8), 0xFF999999, timeStr)
                    drawList:AddText(imgui.ImVec2(colX[2] + 12, rowY + 8), 0xFFFFFFFF, u8(log.name or "Неизвестный ларец"))
                    
                    local cost = (investmentConfig[log.itemId] and investmentConfig[log.itemId].cost) or 0
                    local incomeStr = formatNumber(cost) .. "$"
                    local incomeW = imgui.CalcTextSize(incomeStr).x
                    drawList:AddText(imgui.ImVec2(colX[4] - incomeW - 12, rowY + 8), 0xFF33CC66, incomeStr)
                end

                for i = 2, #colX - 1 do
                    drawList:AddLine(imgui.ImVec2(colX[i], tblTopY), imgui.ImVec2(colX[i], tblTopY + tblTotalH), 0xFF3A3A3A, 1.0)
                end
                drawList:AddRect(imgui.ImVec2(hdrX, tblTopY), imgui.ImVec2(hdrX + listW, tblTopY + tblTotalH), 0xFF333333, 8, 15, 1.2)

                imgui.SetCursorScreenPos(imgui.ImVec2(hdrX, tblTopY + tblTotalH + 8))
                imgui.Dummy(imgui.ImVec2(listW, 0))
            end
        else
            imgui.TextColored(imgui.ImVec4(0.6, 0.6, 0.6, 1), u8("Нет записей. Ларцы появятся здесь при выпадении."))
        end
    end

    
    --  ЦЕНЫ
    
    if invSectionTab.v == 1 then
        if next(investmentConfig) == nil then
            imgui.TextColored(imgui.ImVec4(0.6, 0.6, 0.6, 1), u8("Нет ларцов. Они появятся здесь при выпадении."))
        else
            for itemId, data in pairs(investmentConfig) do
                if not invEditCache then invEditCache = {} end
                if not invEditCache[itemId] then
                    invEditCache[itemId] = imgui.ImInt(data.cost or 0)
                end

                local cardX2 = imgui.GetCursorScreenPos().x
                local cardY2 = imgui.GetCursorScreenPos().y
                local caseCardH = 50
                drawList:AddRectFilled(imgui.ImVec2(cardX2, cardY2), imgui.ImVec2(cardX2 + listW, cardY2 + caseCardH), 0xFF1A1A1A, 6)
                drawList:AddRect(imgui.ImVec2(cardX2, cardY2), imgui.ImVec2(cardX2 + listW, cardY2 + caseCardH), 0xFF333333, 6, 15, 1.0)
                drawList:AddText(imgui.ImVec2(cardX2 + 10, cardY2 + 8), 0xFFFFFFFF, u8(data.name))
                drawList:AddText(imgui.ImVec2(cardX2 + 10, cardY2 + 28), 0xFF888888, u8("Кол-во: ") .. data.count .. u8(" | Доход: ") .. formatNumber(data.cost * data.count) .. "$")

                imgui.SetCursorScreenPos(imgui.ImVec2(cardX2 + listW - 200, cardY2 + 8))
                imgui.PushItemWidth(140)
                if imgui.InputInt("##inv_cost_" .. itemId, invEditCache[itemId], 1000, 10000) then
                    investmentConfig[itemId].cost = invEditCache[itemId].v
                    saveInvestmentConfig()
                end
                imgui.PopItemWidth()

                imgui.SetCursorScreenPos(imgui.ImVec2(cardX2 + listW - 50, cardY2 + 28))
                if imgui.Button(fa.ICON_REPEAT .. "##reset_inv_" .. itemId, imgui.ImVec2(20, 18)) then
                    investmentConfig[itemId].count = 0
                    saveInvestmentConfig()
                end

                imgui.SetCursorScreenPos(imgui.ImVec2(cardX2, cardY2 + caseCardH))
                imgui.Dummy(imgui.ImVec2(listW, 2))
            end
        end

        imgui.Spacing()
        if StyleButton(u8("Сохранить цены"), fa.ICON_FLOPPY_O, 220) then
            saveInvestmentConfig()
            sampAddChatMessage(SCRIPT_PREFIX .. "Цены ларцов сохранены!", SCRIPT_COLOR)
        end
    end
end
function drawItemMarketTab()
-- Единый стиль пустого состояния для всех вкладок - иконка + текст по центру
function drawEmptyState(drawList, x, y, w, icon, text)
    local iconSz = imgui.CalcTextSize(icon)
    local textSz = imgui.CalcTextSize(text)
    local cy = y + 20
    drawList:AddText(imgui.ImVec2(x + (w - iconSz.x) / 2, cy), 0xFF3A3A3A, icon)
    drawList:AddText(imgui.ImVec2(x + (w - textSz.x) / 2, cy + iconSz.y + 10), 0xFF666666, text)
    return iconSz.y + 10 + textSz.y + 40
end
    imgui.TextColored(imgui.ImVec4(1.0, 0.8, 0.2, 1), u8("Сторонний доход"))
    imgui.Separator()
    imgui.Spacing()
    
    if not imTabIdx then imTabIdx = imgui.ImInt(0) end
    
    local function getCardColors(hovered)
        if useCustomTheme then
            return imVec4ToHex(hovered and CUSTOM_THEME.cardBgHovered or CUSTOM_THEME.cardBg),
                   imVec4ToHex(CUSTOM_THEME.cardBorder),
                   imVec4ToHex(CUSTOM_THEME.cardIcon),
                   imVec4ToHex(CUSTOM_THEME.cardTitle)
        else
            return (hovered and 0xFF222222 or 0xFF1A1A1A), 0xFF333333, 0xFF1AE591, 0xFF1AE591
        end
    end
    
    local statBg = useCustomTheme and imVec4ToHex(CUSTOM_THEME.statCardBg) or 0xFF1A1A1A
    local statBorder = useCustomTheme and imVec4ToHex(CUSTOM_THEME.statCardBorder) or 0xFF333333
    local statLabel = useCustomTheme and imVec4ToHex(CUSTOM_THEME.statCardLabel) or 0xFF888888
    local statValue = useCustomTheme and imVec4ToHex(CUSTOM_THEME.statCardValue) or 0xFF1AE591
    local statValueToday = useCustomTheme and imVec4ToHex(CUSTOM_THEME.statCardValueToday) or 0xFFFFCC00
    local statValueWeek = useCustomTheme and imVec4ToHex(CUSTOM_THEME.statCardValueWeek) or 0xFF33CCFF
    local statAZ = useCustomTheme and imVec4ToHex(CUSTOM_THEME.statCardAZ) or 0xFF00CCFF
    local tableHdrBg = useCustomTheme and imVec4ToHex(CUSTOM_THEME.tableHeaderBg) or 0xFF222222
    local tableHdrText = useCustomTheme and imVec4ToHex(CUSTOM_THEME.tableHeaderText) or 0xFF888888
    
    local tabNames = {u8("Пейдеи"), u8("Аренда (IM)"), u8("Осколки"), u8("Инвестиции")}
    local btnW4 = (imgui.GetWindowWidth() - 25 - 12) / 4
    if StyleButton(tabNames[1], fa.ICON_MONEY, btnW4, imTabIdx.v == 0) then imTabIdx.v = 0 end
    imgui.SameLine()
    if StyleButton(tabNames[2], fa.ICON_SHOPPING_CART, btnW4, imTabIdx.v == 1) then imTabIdx.v = 1 end
    imgui.SameLine()
    if StyleButton(tabNames[3], fa.ICON_STAR, btnW4, imTabIdx.v == 2) then imTabIdx.v = 2 end
    imgui.SameLine()
    if StyleButton(tabNames[4], fa.ICON_BRIEFCASE, btnW4, imTabIdx.v == 3) then imTabIdx.v = 3 end
    
    imgui.Spacing(); imgui.Separator(); imgui.Spacing()
    
    if imTabIdx.v == 3 then
        drawInvestmentTab()
        return
    end
    
    local currentLog
    if imTabIdx.v == 0 then currentLog = paydayLog
    elseif imTabIdx.v == 1 then currentLog = itemMarketLog
    else currentLog = shardLog end
    
    local isPayday = (imTabIdx.v == 0)
    local logLabel = (imTabIdx.v == 0) and u8("Пейдей") or (imTabIdx.v == 1) and u8("Аренда") or u8("Осколок")
    
    local totalAll = 0; local todayAll = 0; local weekAll = 0
    local totalAZ = 0; local todayAZ = 0; local weekAZ = 0
    local todayDate = getGameDate()
    local mskTime = getMoscowTime()
    local mskWday = tonumber(os.date("%w", mskTime))
    if mskWday == 0 then mskWday = 7 end
    
    for _, log in ipairs(currentLog) do
        local amt = isPayday and (log.total or log.amount) or log.amount
        totalAll = totalAll + amt
        if getGameDate(log.time) == todayDate then todayAll = todayAll + amt end
        if isPayday then
            totalAZ = totalAZ + (log.az or 0)
            if getGameDate(log.time) == todayDate then todayAZ = todayAZ + (log.az or 0) end
        end
    end
    local daysSinceMonday = mskWday - 1
    for i = 0, daysSinceMonday do
        local date = getGameDate(os.time() - i * 86400)
        for _, log in ipairs(currentLog) do
            if getGameDate(log.time) == date then
                local amt = isPayday and (log.total or log.amount) or log.amount
                weekAll = weekAll + amt
                if isPayday then weekAZ = weekAZ + (log.az or 0) end
            end
        end
    end
    
    local drawList = imgui.GetWindowDrawList()
    local spacing = 8
    local cardWidth = (imgui.GetWindowWidth() - 25 - spacing * 2) / 3
    local cardHeight = isPayday and 65 or 55
    local startPos = imgui.GetCursorScreenPos()
    
    local bgCol, borderCol, iconCol, titleCol = getCardColors(false)
    
    -- Карточка 1: Общий заработок
    drawList:AddRectFilled(startPos, imgui.ImVec2(startPos.x + cardWidth, startPos.y + cardHeight), statBg, 6)
    drawList:AddRect(startPos, imgui.ImVec2(startPos.x + cardWidth, startPos.y + cardHeight), statBorder, 6, 15, 1.0)
    if isPayday then
        drawList:AddText(imgui.ImVec2(startPos.x + 10, startPos.y + 8), statLabel, u8("Общий заработок"))
        drawList:AddText(imgui.ImVec2(startPos.x + 10, startPos.y + 26), statValue, formatNumber(totalAll) .. "$")
        drawList:AddText(imgui.ImVec2(startPos.x + 10, startPos.y + 44), statAZ, u8("AZ: ") .. formatNumber(totalAZ))
    else
        drawList:AddText(imgui.ImVec2(startPos.x + 10, startPos.y + 8), statLabel, u8("Общий заработок"))
        drawList:AddText(imgui.ImVec2(startPos.x + 10, startPos.y + 28), statValue, formatNumber(totalAll) .. "$")
    end
    
    -- Карточка 2: За сегодня
    local pos2 = imgui.ImVec2(startPos.x + cardWidth + spacing, startPos.y)
    drawList:AddRectFilled(pos2, imgui.ImVec2(pos2.x + cardWidth, pos2.y + cardHeight), statBg, 6)
    drawList:AddRect(pos2, imgui.ImVec2(pos2.x + cardWidth, pos2.y + cardHeight), statBorder, 6, 15, 1.0)
    if isPayday then
        drawList:AddText(imgui.ImVec2(pos2.x + 10, pos2.y + 8), statLabel, u8("За сегодня"))
        drawList:AddText(imgui.ImVec2(pos2.x + 10, pos2.y + 26), statValueToday, formatNumber(todayAll) .. "$")
        drawList:AddText(imgui.ImVec2(pos2.x + 10, pos2.y + 44), statAZ, u8("AZ: ") .. formatNumber(todayAZ))
    else
        drawList:AddText(imgui.ImVec2(pos2.x + 10, pos2.y + 8), statLabel, u8("За сегодня"))
        drawList:AddText(imgui.ImVec2(pos2.x + 10, pos2.y + 28), statValueToday, formatNumber(todayAll) .. "$")
    end
    
    -- Карточка 3: За неделю
    local pos3 = imgui.ImVec2(startPos.x + cardWidth * 2 + spacing * 2, startPos.y)
    drawList:AddRectFilled(pos3, imgui.ImVec2(pos3.x + cardWidth, pos3.y + cardHeight), statBg, 6)
    drawList:AddRect(pos3, imgui.ImVec2(pos3.x + cardWidth, pos3.y + cardHeight), statBorder, 6, 15, 1.0)
    if isPayday then
        drawList:AddText(imgui.ImVec2(pos3.x + 10, pos3.y + 8), statLabel, u8("За неделю"))
        drawList:AddText(imgui.ImVec2(pos3.x + 10, pos3.y + 26), statValueWeek, formatNumber(weekAll) .. "$")
        drawList:AddText(imgui.ImVec2(pos3.x + 10, pos3.y + 44), statAZ, u8("AZ: ") .. formatNumber(weekAZ))
    else
        drawList:AddText(imgui.ImVec2(pos3.x + 10, pos3.y + 8), statLabel, u8("За неделю"))
        drawList:AddText(imgui.ImVec2(pos3.x + 10, pos3.y + 28), statValueWeek, formatNumber(weekAll) .. "$")
    end
    
    imgui.SetCursorScreenPos(imgui.ImVec2(startPos.x, startPos.y + cardHeight))
    imgui.Dummy(imgui.ImVec2(imgui.GetWindowWidth() - 25, 0))
    imgui.Spacing(); imgui.Separator(); imgui.Spacing()
    
    local allDates = {}
    local seenDates = {}
    for _, log in ipairs(currentLog) do
        local d = getGameDate(log.time)
        if not seenDates[d] then seenDates[d] = true; table.insert(allDates, d) end
    end
    table.sort(allDates, function(a, b) return a > b end)
    
    if not imSelectedDateStr then
        if allDates[1] then
            imSelectedDateStr = allDates[1]
        else
            local t = os.date("*t")
            imSelectedDateStr = string.format("%04d-%02d-%02d", t.year, t.month, t.day)
        end
        local yy, mm = imSelectedDateStr:match("(%d+)-(%d+)-")
        imCalendarYear = tonumber(yy)
        imCalendarMonth = tonumber(mm)
    end
    
    local listW = imgui.GetWindowWidth() - 25
    
    if #allDates > 0 then
        local selectedDate = imSelectedDateStr
        local daySum = 0; local dayAZ = 0; local logCount = 0
        if selectedDate then
            for i = 1, math.min(#currentLog, 500) do
                local log = currentLog[i]
                if getGameDate(log.time) == selectedDate then
                    local amt = isPayday and (log.total or log.amount) or log.amount
                    daySum = daySum + amt; logCount = logCount + 1
                    if isPayday then dayAZ = dayAZ + (log.az or 0) end
                end
            end
        end
        
        local btnW = listW; local btnH = 38
        local btnPos = imgui.GetCursorScreenPos()
        local hovered = (imgui.GetMousePos().x >= btnPos.x and imgui.GetMousePos().x <= btnPos.x + btnW and imgui.GetMousePos().y >= btnPos.y and imgui.GetMousePos().y <= btnPos.y + btnH)
        local dateBgCol, dateBorderCol = getCardColors(hovered)
        drawList:AddRectFilled(btnPos, imgui.ImVec2(btnPos.x + btnW, btnPos.y + btnH), dateBgCol, 6)
        drawList:AddRect(btnPos, imgui.ImVec2(btnPos.x + btnW, btnPos.y + btnH), dateBorderCol, 6, 15, 1.0)
        local y, m, day = selectedDate:match("(%d+)-(%d+)-(%d+)")
        local displaySelected = selectedDate
        if y and m and day then displaySelected = day .. "." .. m .. "." .. y end
        drawList:AddText(imgui.ImVec2(btnPos.x + 12, btnPos.y + 10), iconCol, fa.ICON_CALENDAR .. " " .. displaySelected)
        
        local sumText
        if isPayday then
            sumText = formatNumber(daySum) .. "$ + " .. formatNumber(dayAZ) .. " AZ"
        else
            sumText = formatNumber(daySum) .. "$"
        end
        local infoText = "  •  " .. logCount .. " " .. logLabel
        local sumTextW = imgui.CalcTextSize(sumText).x; local infoTextW = imgui.CalcTextSize(infoText).x
        drawList:AddText(imgui.ImVec2(btnPos.x + btnW - sumTextW - infoTextW - 35, btnPos.y + 10), iconCol, sumText)
        drawList:AddText(imgui.ImVec2(btnPos.x + btnW - infoTextW - 35, btnPos.y + 10), 0xFF888888, infoText)
        drawList:AddText(imgui.ImVec2(btnPos.x + btnW - 25, btnPos.y + 10), 0xFF888888, fa.ICON_ARROW_DOWN)
        imgui.SetCursorScreenPos(btnPos)
        if imgui.InvisibleButton("##im_date_btn", imgui.ImVec2(btnW, btnH)) then
            local cyy, cmm = imSelectedDateStr:match("(%d+)-(%d+)-")
            if cyy and cmm then imCalendarYear = tonumber(cyy); imCalendarMonth = tonumber(cmm) end
            imgui.OpenPopup("##im_date_popup")
        end
        
        if imgui.BeginPopup("##im_date_popup") then
            local monthNamesRu = {u8("Январь"), u8("Февраль"), u8("Март"), u8("Апрель"), u8("Май"), u8("Июнь"), u8("Июль"), u8("Август"), u8("Сентябрь"), u8("Октябрь"), u8("Ноябрь"), u8("Декабрь")}
            local weekdayNamesRu = {u8("Пн"), u8("Вт"), u8("Ср"), u8("Чт"), u8("Пт"), u8("Сб"), u8("Вс")}
            local todayStr = getGameDate()

            local ACCENT = 0xFF6078E0
            local ACCENT_TEXT = 0xFF1AE591
            local TODAY_RING = 0xFFFFFFFF
            local WEEKEND_COL = 0xFF6078E0
            local DOT_GREEN = 0xFFD4BC00

            local function daysInMonth(yy, mm)
                local dim = {31,28,31,30,31,30,31,31,30,31,30,31}
                if mm == 2 and (yy % 4 == 0 and (yy % 100 ~= 0 or yy % 400 == 0)) then return 29 end
                return dim[mm]
            end
            local function firstWeekdayOfMonth(yy, mm)
                local t = os.time({year = yy, month = mm, day = 1, hour = 12})
                local w = tonumber(os.date("%w", t))
                if w == 0 then w = 7 end
                return w
            end

            local function getDateIncome(dateStr)
                local sum = 0
                for _, log in ipairs(currentLog) do
                    if getGameDate(log.time) == dateStr then
                        sum = sum + (log.total or log.amount)
                    end
                end
                return sum
            end

            local calDrawList = imgui.GetWindowDrawList()
            local cellSize = 34
            local cellGap = 2
            local step = cellSize + cellGap
            local headerW = step * 7

            local headerPos = imgui.GetCursorScreenPos()
            local headerH = 30

            local btnSize = 24
            local leftBtnX = headerPos.x
            local leftBtnY = headerPos.y + (headerH - btnSize) / 2
            local mouseP = imgui.GetMousePos()
            local leftHovered = (mouseP.x >= leftBtnX and mouseP.x <= leftBtnX + btnSize and
                                 mouseP.y >= leftBtnY and mouseP.y <= leftBtnY + btnSize)
            local leftCenter = imgui.ImVec2(leftBtnX + btnSize / 2, leftBtnY + btnSize / 2)
            calDrawList:AddCircleFilled(leftCenter, btnSize / 2, leftHovered and 0xFF2E2E2E or 0xFF1C1C1C, 20)
            local leftArrow = fa.ICON_ANGLE_LEFT
            local leftArrowSz = imgui.CalcTextSize(leftArrow)
            calDrawList:AddText(imgui.ImVec2(leftCenter.x - leftArrowSz.x / 2, leftCenter.y - leftArrowSz.y / 2), leftHovered and 0xFFFFFFFF or 0xFFAAAAAA, leftArrow)
            imgui.SetCursorScreenPos(imgui.ImVec2(leftBtnX, leftBtnY))
            if imgui.InvisibleButton("##cal_month_left", imgui.ImVec2(btnSize, btnSize)) then
                imCalendarMonth = imCalendarMonth - 1
                if imCalendarMonth < 1 then imCalendarMonth = 12; imCalendarYear = imCalendarYear - 1 end
            end

            local rightBtnX = headerPos.x + headerW - btnSize
            local rightBtnY = leftBtnY
            local rightHovered = (mouseP.x >= rightBtnX and mouseP.x <= rightBtnX + btnSize and
                                  mouseP.y >= rightBtnY and mouseP.y <= rightBtnY + btnSize)
            local rightCenter = imgui.ImVec2(rightBtnX + btnSize / 2, rightBtnY + btnSize / 2)
            calDrawList:AddCircleFilled(rightCenter, btnSize / 2, rightHovered and 0xFF2E2E2E or 0xFF1C1C1C, 20)
            local rightArrow = fa.ICON_ANGLE_RIGHT
            local rightArrowSz = imgui.CalcTextSize(rightArrow)
            calDrawList:AddText(imgui.ImVec2(rightCenter.x - rightArrowSz.x / 2, rightCenter.y - rightArrowSz.y / 2), rightHovered and 0xFFFFFFFF or 0xFFAAAAAA, rightArrow)
            imgui.SetCursorScreenPos(imgui.ImVec2(rightBtnX, rightBtnY))
            if imgui.InvisibleButton("##cal_month_right", imgui.ImVec2(btnSize, btnSize)) then
                imCalendarMonth = imCalendarMonth + 1
                if imCalendarMonth > 12 then imCalendarMonth = 1; imCalendarYear = imCalendarYear + 1 end
            end

            local monthName = monthNamesRu[imCalendarMonth]
            local yearName = tostring(imCalendarYear)
            local monthNameW = imgui.CalcTextSize(monthName).x
            local monthNameH = imgui.CalcTextSize(monthName).y
            local yearNameW = imgui.CalcTextSize(yearName).x
            local yearNameH = imgui.CalcTextSize(yearName).y
            local totalH = monthNameH + yearNameH + 2
            local textStartY = headerPos.y + (headerH - totalH) / 2
            calDrawList:AddText(imgui.ImVec2(headerPos.x + (headerW - monthNameW) / 2, textStartY), 0xFF6078E0, monthName)
            calDrawList:AddText(imgui.ImVec2(headerPos.x + (headerW - yearNameW) / 2, textStartY + monthNameH + 2), 0xFFAAAAAA, yearName)

            imgui.SetCursorScreenPos(imgui.ImVec2(headerPos.x, headerPos.y + headerH))
            imgui.Dummy(imgui.ImVec2(headerW, 4))

            local subSepY = imgui.GetCursorScreenPos().y + 2
            calDrawList:AddLine(imgui.ImVec2(headerPos.x, subSepY), imgui.ImVec2(headerPos.x + headerW, subSepY), 0xFF2A2A2A, 1.0)
            imgui.SetCursorScreenPos(imgui.ImVec2(headerPos.x, subSepY + 8))

            local hdrPos = imgui.GetCursorScreenPos()
            for i, wd in ipairs(weekdayNamesRu) do
                local isWeekend = (i == 6 or i == 7)
                local wdW = imgui.CalcTextSize(wd).x
                calDrawList:AddText(imgui.ImVec2(hdrPos.x + (i - 1) * step + (cellSize - wdW) / 2, hdrPos.y), isWeekend and WEEKEND_COL or 0xFF666666, wd)
            end
            imgui.Dummy(imgui.ImVec2(headerW, 18))

            local startWd = firstWeekdayOfMonth(imCalendarYear, imCalendarMonth)
            local totalDays = daysInMonth(imCalendarYear, imCalendarMonth)
            local gridPos = imgui.GetCursorScreenPos()

            local row, col = 0, startWd - 1
            for dnum = 1, totalDays do
                local cellX = gridPos.x + col * step
                local cellY = gridPos.y + row * step
                local center = imgui.ImVec2(cellX + cellSize / 2, cellY + cellSize / 2)
                local radius = cellSize / 2 - 1

                local dateStr = string.format("%04d-%02d-%02d", imCalendarYear, imCalendarMonth, dnum)
                local hasIncome = seenDates[dateStr] == true
                local isSelected = (dateStr == imSelectedDateStr)
                local isToday = (dateStr == todayStr)
                local weekdayIdx = ((startWd - 1 + dnum - 1) % 7) + 1
                local isWeekend = (weekdayIdx == 6 or weekdayIdx == 7)

                local cellHovered = (mouseP.x >= cellX and mouseP.x <= cellX + cellSize and
                                     mouseP.y >= cellY and mouseP.y <= cellY + cellSize)

                if isSelected and isToday then
                    calDrawList:AddCircleFilled(center, radius, ACCENT, 24)
                    calDrawList:AddCircle(center, radius, TODAY_RING, 24, 2.0)
                elseif isSelected then
                    calDrawList:AddCircleFilled(center, radius, ACCENT, 24)
                elseif isToday then
                    calDrawList:AddCircle(center, radius, TODAY_RING, 24, 1.5)
                elseif cellHovered then
                    calDrawList:AddCircle(center, radius, 0xFF444444, 24, 1.0)
                end

                local dayStr = tostring(dnum)
                local dayStrSz = imgui.CalcTextSize(dayStr)
                local textCol
                if isSelected then
                    textCol = 0xFFFFFFFF
                elseif isToday then
                    textCol = 0xFF1AE591
                elseif isWeekend then
                    textCol = WEEKEND_COL
                elseif cellHovered then
                    textCol = 0xFFEEEEEE
                else
                    textCol = 0xFFCCCCCC
                end
                calDrawList:AddText(imgui.ImVec2(center.x - dayStrSz.x / 2, center.y - dayStrSz.y / 2 - (hasIncome and 3 or 0)), textCol, dayStr)

                if hasIncome then
                    local dotCol = isSelected and 0xFFFFFFFF or DOT_GREEN
                    calDrawList:AddCircleFilled(imgui.ImVec2(center.x, center.y + dayStrSz.y / 2 + 2), 2.0, dotCol, 12)
                end

                imgui.SetCursorScreenPos(imgui.ImVec2(cellX, cellY))
                if imgui.InvisibleButton("##cal_" .. dateStr, imgui.ImVec2(cellSize, cellSize)) then
                    imSelectedDateStr = dateStr
                    imgui.CloseCurrentPopup()
                end

                if cellHovered then
                    imgui.BeginTooltip()
                    imgui.Text(dayStr .. " " .. monthNamesRu[imCalendarMonth])
                    local dayIncome = getDateIncome(dateStr)
                    local dayAZ = 0
                    if isPayday then
                        for _, log in ipairs(currentLog) do
                            if getGameDate(log.time) == dateStr then
                                dayAZ = dayAZ + (log.az or 0)
                            end
                        end
                    end
                    if dayIncome > 0 or dayAZ > 0 then
                        if isPayday then
                            imgui.Text(u8("Доход: ") .. formatNumber(dayIncome) .. "$  |  AZ: " .. formatNumber(dayAZ))
                        else
                            imgui.Text(u8("Доход: ") .. formatNumber(dayIncome) .. "$")
                        end
                    else
                        imgui.Text(u8("Нет записей"))
                    end
                    imgui.EndTooltip()
                end

                col = col + 1
                if col > 6 then col = 0; row = row + 1 end
            end

            imgui.SetCursorScreenPos(imgui.ImVec2(gridPos.x, gridPos.y + (row + 1) * step + 4))

            local legY = imgui.GetCursorScreenPos().y + 6
            calDrawList:AddLine(imgui.ImVec2(headerPos.x, legY), imgui.ImVec2(headerPos.x + headerW, legY), 0xFF2A2A2A, 1.0)

            local legendY = legY + 8
            calDrawList:AddCircleFilled(imgui.ImVec2(headerPos.x + 6, legendY + 5), 2.0, DOT_GREEN, 12)
            calDrawList:AddText(imgui.ImVec2(headerPos.x + 14, legendY), 0xFF777777, u8("Есть записи"))

            local todayLabel = u8("Сегодня")
            local todayLabelW = imgui.CalcTextSize(todayLabel).x
            calDrawList:AddCircle(imgui.ImVec2(headerPos.x + headerW - todayLabelW - 16, legendY + 5), 4.0, TODAY_RING, 12, 1.2)
            calDrawList:AddText(imgui.ImVec2(headerPos.x + headerW - todayLabelW, legendY), 0xFF777777, todayLabel)

            imgui.SetCursorScreenPos(imgui.ImVec2(headerPos.x, legendY + 20))
            imgui.Dummy(imgui.ImVec2(headerW, 1))

            imgui.EndPopup()
        end
        
        imgui.SetCursorScreenPos(imgui.ImVec2(btnPos.x, btnPos.y + btnH))
        imgui.Dummy(imgui.ImVec2(btnW, 4))
        
        if selectedDate and logCount > 0 then
            imgui.Spacing()
            local logs = {}
            for i = 1, math.min(#currentLog, 500) do
                local log = currentLog[i]
                if getGameDate(log.time) == selectedDate then table.insert(logs, log) end
            end
            
            local hdrX = imgui.GetCursorScreenPos().x
            local tblTopY = imgui.GetCursorScreenPos().y
            local hdrH = 28
            local rowH = 36
            local tblTotalH = hdrH + #logs * rowH
            
            local ACCENT_GREEN = 0xFF33CC66
            local NEUTRAL = 0xFFE0E0E0
            local timeW = 70
            
            
            --  ГРАНИЦЫ КОЛОНОК
            
            local colX, headerLabels, headerAligns, headerColors
            if imTabIdx.v == 0 then
                local totalColW = 150
                local midW = (listW - timeW - totalColW) / 4
                colX = {
                    hdrX,
                    hdrX + timeW,
                    hdrX + timeW + midW,
                    hdrX + timeW + midW * 2,
                    hdrX + timeW + midW * 3,
                    hdrX + timeW + midW * 4,
                    hdrX + listW,
                }
                headerLabels = {u8("Время"), u8("Зарплата"), u8("Депозит"), u8("Аксы/предметы"), u8("AZ"), u8("Общий доход")}
                headerAligns = {"left", "center", "center", "center", "center", "right"}
                headerColors = {tableHdrText, tableHdrText, tableHdrText, tableHdrText, 0xFF00CCFF, ACCENT_GREEN}
            elseif imTabIdx.v == 1 then
                local restW = listW - timeW
                local w1, w2 = 0.45, 0.25
                colX = {
                    hdrX,
                    hdrX + timeW,
                    hdrX + timeW + restW * w1,
                    hdrX + timeW + restW * (w1 + w2),
                    hdrX + listW,
                }
                headerLabels = {u8("Время"), u8("Ник"), u8("Тип"), u8("Стоимость")}
                headerAligns = {"left", "left", "left", "right"}
                headerColors = {tableHdrText, tableHdrText, tableHdrText, tableHdrText}
            else
                local restW = listW - timeW
                local w1 = 0.68
                colX = {
                    hdrX,
                    hdrX + timeW,
                    hdrX + timeW + restW * w1,
                    hdrX + listW,
                }
                headerLabels = {u8("Время"), u8("Название"), u8("Стоимость")}
                headerAligns = {"left", "center", "right"}
                headerColors = {tableHdrText, tableHdrText, tableHdrText}
            end
            local rightEdge = colX[#colX]
            
            -- Фон таблицы и фон шапки - рисуются первыми
            drawList:AddRectFilled(imgui.ImVec2(hdrX, tblTopY), imgui.ImVec2(hdrX + listW, tblTopY + tblTotalH), 0xFF0C0C0C, 8, 15)
            drawList:AddRectFilled(imgui.ImVec2(hdrX, tblTopY), imgui.ImVec2(hdrX + listW, tblTopY + hdrH), tableHdrBg, 8, 3)
            
            -- Заголовки колонок - выравниваются внутри своих границ (как в рейтинге)
            for i, lbl in ipairs(headerLabels) do
                local cx0, cx1 = colX[i], colX[i + 1]
                local tw = imgui.CalcTextSize(lbl).x
                local tx
                if headerAligns[i] == "center" then tx = cx0 + (cx1 - cx0 - tw) / 2
                elseif headerAligns[i] == "right" then tx = cx1 - tw - 12
                else tx = cx0 + 12 end
                drawList:AddText(imgui.ImVec2(tx, tblTopY + 7), headerColors[i], lbl)
            end
            
            local function centeredX(colIdx, text)
                local cx0, cx1 = colX[colIdx], colX[colIdx + 1]
                return cx0 + (cx1 - cx0 - imgui.CalcTextSize(text).x) / 2
            end
            
            for logIdx, log in ipairs(logs) do
                local msk = log.time + 10800; local timeStr = os.date("!%H:%M", msk)
                local rowY = tblTopY + hdrH + (logIdx - 1) * rowH
                local mp = imgui.GetMousePos()
                local rowHovered = (mp.x >= hdrX and mp.x <= hdrX + listW and mp.y >= rowY and mp.y <= rowY + rowH)
                local rowBg = rowHovered and 0xFF1E1E1E or ((logIdx % 2 == 0) and 0xFF171717 or 0xFF121212)
                local isLastRow = (logIdx == #logs)
                drawList:AddRectFilled(imgui.ImVec2(hdrX + 1, rowY), imgui.ImVec2(hdrX + listW - 1, rowY + rowH), rowBg, isLastRow and 8 or 0, isLastRow and 12 or 0)
                drawList:AddText(imgui.ImVec2(colX[1] + 12, rowY + 10), 0xFF999999, timeStr)
                
                if imTabIdx.v == 0 then
                    local salaryStr = formatNumber(log.salary or 0) .. "$"
                    drawList:AddText(imgui.ImVec2(centeredX(2, salaryStr), rowY + 10), NEUTRAL, salaryStr)
                    
                    local depositStr = formatNumber(log.deposit or 0) .. "$"
                    drawList:AddText(imgui.ImVec2(centeredX(3, depositStr), rowY + 10), NEUTRAL, depositStr)
                    
                    local accText = formatNumber(log.accesories or 0) .. "$"
                    local accW = imgui.CalcTextSize(accText).x
                    local hasBreakdown = log.accBreakdown and (
                        (log.accBreakdown.dividend and log.accBreakdown.dividend > 0) or
                        (log.accBreakdown.accessory and log.accBreakdown.accessory > 0) or
                        (log.accBreakdown.family and log.accBreakdown.family > 0)
                    )
                    local iconW = hasBreakdown and (imgui.CalcTextSize(fa.ICON_INFO_CIRCLE).x + 6) or 0
                    local accCx0, accCx1 = colX[4], colX[5]
                    local accX = accCx0 + ((accCx1 - accCx0) - accW - iconW) / 2
                    drawList:AddText(imgui.ImVec2(accX, rowY + 10), NEUTRAL, accText)
                    if hasBreakdown then
                        drawList:AddText(imgui.ImVec2(accX + accW + 6, rowY + 11), 0xFF555555, fa.ICON_INFO_CIRCLE)
                    end
                    
                    imgui.SetCursorScreenPos(imgui.ImVec2(accX - 6, rowY + 6))
                    if imgui.InvisibleButton("##acc_detail_" .. log.time, imgui.ImVec2(accW + iconW + 12, 22)) then end
                    if imgui.IsItemHovered() and log.accBreakdown then
                        imgui.BeginTooltip()
                        local bd = log.accBreakdown
                        if bd.dividend and bd.dividend > 0 then
                            imgui.Text(u8("Дивидендный договор: ") .. formatNumber(bd.dividend) .. "$")
                        end
                        if bd.accessory and bd.accessory > 0 then
                            imgui.Text(u8("Космическое сердце: ") .. formatNumber(bd.accessory) .. "$")
                        end
                        if bd.family and bd.family > 0 then
                            imgui.Text(u8("Семейные выплаты: ") .. formatNumber(bd.family) .. "$")
                        end
                        imgui.EndTooltip()
                    end
                    
                    local azStr = formatNumber(log.az or 0)
                    drawList:AddText(imgui.ImVec2(centeredX(5, azStr), rowY + 10), 0xFF00CCFF, azStr)
                    
                    local totalStr = formatNumber(log.total or 0) .. "$"
                    local totalW = imgui.CalcTextSize(totalStr).x
                    drawList:AddText(imgui.ImVec2(rightEdge - totalW - 12, rowY + 10), ACCENT_GREEN, totalStr)
                elseif imTabIdx.v == 1 then
                    drawList:AddText(imgui.ImVec2(colX[2] + 12, rowY + 10), NEUTRAL, log.nick or "")
                    local typeText = (log.rentType == "room") and u8("Дом") or u8("Item Market")
                    local typeColor = (log.rentType == "room") and 0xFF66CCFF or 0xFFFFAA00
                    drawList:AddText(imgui.ImVec2(colX[3] + 12, rowY + 10), typeColor, typeText)
                    local amtStr = formatNumber(log.amount) .. "$"; local amtW = imgui.CalcTextSize(amtStr).x
                    drawList:AddText(imgui.ImVec2(rightEdge - amtW - 12, rowY + 10), ACCENT_GREEN, amtStr)
                else
                    local nameText = u8("Осколок Тайника ") .. u8(log.name or "")
                    local nameW = imgui.CalcTextSize(nameText).x
                    local cx0, cx1 = colX[2], colX[3]
                    drawList:AddText(imgui.ImVec2(cx0 + (cx1 - cx0 - nameW) / 2, rowY + 10), NEUTRAL, nameText)
                    local amtStr = formatNumber(log.amount) .. "$"; local amtW = imgui.CalcTextSize(amtStr).x
                    drawList:AddText(imgui.ImVec2(rightEdge - amtW - 12, rowY + 10), ACCENT_GREEN, amtStr)
                end
                
                if not isLastRow then
                    drawList:AddLine(imgui.ImVec2(hdrX + 6, rowY + rowH), imgui.ImVec2(hdrX + listW - 6, rowY + rowH), 0xFF232323, 1.0)
                end
            end
            
            -- Вертикальные разделители колонок - поверх всех фонов (шапки и строк), поэтому всегда видны
            for i = 2, #colX - 1 do
                drawList:AddLine(imgui.ImVec2(colX[i], tblTopY), imgui.ImVec2(colX[i], tblTopY + tblTotalH), 0xFF3A3A3A, 1.0)
            end
            
            -- Обводка - последней, поверх фона/шапки/строк, поэтому видна целиком со всех 4 сторон
            drawList:AddRect(imgui.ImVec2(hdrX, tblTopY), imgui.ImVec2(hdrX + listW, tblTopY + tblTotalH), borderCol, 8, 15, 1.2)
            
            imgui.SetCursorScreenPos(imgui.ImVec2(hdrX, tblTopY + tblTotalH + 8))
            imgui.Dummy(imgui.ImVec2(listW, 0))
        end
    else
        local emptyIcon = (imTabIdx.v == 0) and fa.ICON_MONEY or (imTabIdx.v == 1) and fa.ICON_SHOPPING_CART or fa.ICON_STAR
        local emptyPos = imgui.GetCursorScreenPos()
        local blockH = drawEmptyState(drawList, emptyPos.x, emptyPos.y, listW, emptyIcon, u8("Нет записей"))
        imgui.Dummy(imgui.ImVec2(listW, blockH))
    end
end
function drawOilTab()
    imgui.TextColored(imgui.ImVec4(1.0, 0.6, 0.25, 1), u8("Нефтевышки"))
    imgui.Separator()
    imgui.Spacing()

    local function getCardColors(hovered)
        if useCustomTheme then
            return imVec4ToHex(hovered and CUSTOM_THEME.cardBgHovered or CUSTOM_THEME.cardBg),
                   imVec4ToHex(CUSTOM_THEME.cardBorder),
                   imVec4ToHex(CUSTOM_THEME.cardIcon),
                   imVec4ToHex(CUSTOM_THEME.cardTitle)
        else
            return (hovered and 0xFF222222 or 0xFF1A1A1A), 0xFF333333, 0xFF1AE591, 0xFF1AE591
        end
    end

    local statBg = useCustomTheme and imVec4ToHex(CUSTOM_THEME.statCardBg) or 0xFF1A1A1A
    local statBorder = useCustomTheme and imVec4ToHex(CUSTOM_THEME.statCardBorder) or 0xFF333333
    local statLabel = useCustomTheme and imVec4ToHex(CUSTOM_THEME.statCardLabel) or 0xFF888888
    local statValue = useCustomTheme and imVec4ToHex(CUSTOM_THEME.statCardValue) or 0xFF1AE591
    local statValueToday = useCustomTheme and imVec4ToHex(CUSTOM_THEME.statCardValueToday) or 0xFFFFCC00
    local statValueWeek = useCustomTheme and imVec4ToHex(CUSTOM_THEME.statCardValueWeek) or 0xFF33CCFF
    local statAZ = useCustomTheme and imVec4ToHex(CUSTOM_THEME.statCardAZ) or 0xFF00CCFF
    local tableHdrBg = useCustomTheme and imVec4ToHex(CUSTOM_THEME.tableHeaderBg) or 0xFF222222
    local tableHdrText = useCustomTheme and imVec4ToHex(CUSTOM_THEME.tableHeaderText) or 0xFF888888

    local currentLog = oilLog
    local drawList = imgui.GetWindowDrawList()
    local listW = imgui.GetWindowWidth() - 25

    -- Четыре раздела: Меню / Цены / Кейсы / Статистика
    if not oilSectionTab then oilSectionTab = imgui.ImInt(0) end
    local oilSectionNames = {u8("Меню"), u8("Цены"), u8("Кейсы"), u8("Статистика")}
    local oilSectionBtnW = (imgui.GetWindowWidth() - 25 - 8 * 3) / 4
    for i, name in ipairs(oilSectionNames) do
        if i > 1 then imgui.SameLine() end
        if StyleButton(name, nil, oilSectionBtnW, oilSectionTab.v == i - 1) then
            oilSectionTab.v = i - 1
        end
    end
    imgui.Spacing(); imgui.Separator(); imgui.Spacing()

    
    --  МЕНЮ
    
    if oilSectionTab.v == 0 then
        local totalAll, todayAll, weekAll = 0, 0, 0
        local totalAZ, todayAZ, weekAZ = 0, 0, 0
        local todayDate = getGameDate()
        local mskTime = getMoscowTime()
        local mskWday = tonumber(os.date("%w", mskTime))
        if mskWday == 0 then mskWday = 7 end

        for _, log in ipairs(currentLog) do
            local amt = log.money or 0
            totalAll = totalAll + amt
            totalAZ = totalAZ + (log.az or 0)
            if getGameDate(log.time) == todayDate then
                todayAll = todayAll + amt
                todayAZ = todayAZ + (log.az or 0)
            end
        end
        local daysSinceMonday = mskWday - 1
        for i = 0, daysSinceMonday do
            local date = getGameDate(os.time() - i * 86400)
            for _, log in ipairs(currentLog) do
                if getGameDate(log.time) == date then
                    weekAll = weekAll + (log.money or 0)
                    weekAZ = weekAZ + (log.az or 0)
                end
            end
        end

        local cardSpacing = 8
        local cardWidth = (listW - cardSpacing * 2) / 3
        local cardHeight = 65
        local startPos = imgui.GetCursorScreenPos()

        drawList:AddRectFilled(startPos, imgui.ImVec2(startPos.x + cardWidth, startPos.y + cardHeight), statBg, 6)
        drawList:AddRect(startPos, imgui.ImVec2(startPos.x + cardWidth, startPos.y + cardHeight), statBorder, 6, 15, 1.0)
        drawList:AddText(imgui.ImVec2(startPos.x + 10, startPos.y + 8), statLabel, u8("Всего заработано"))
        drawList:AddText(imgui.ImVec2(startPos.x + 10, startPos.y + 26), statValue, formatNumber(totalAll) .. "$")
        drawList:AddText(imgui.ImVec2(startPos.x + 10, startPos.y + 44), statAZ, u8("AZ: ") .. formatNumber(totalAZ))

        local pos2 = imgui.ImVec2(startPos.x + cardWidth + cardSpacing, startPos.y)
        drawList:AddRectFilled(pos2, imgui.ImVec2(pos2.x + cardWidth, pos2.y + cardHeight), statBg, 6)
        drawList:AddRect(pos2, imgui.ImVec2(pos2.x + cardWidth, pos2.y + cardHeight), statBorder, 6, 15, 1.0)
        drawList:AddText(imgui.ImVec2(pos2.x + 10, pos2.y + 8), statLabel, u8("За сегодня"))
        drawList:AddText(imgui.ImVec2(pos2.x + 10, pos2.y + 26), statValueToday, formatNumber(todayAll) .. "$")
        drawList:AddText(imgui.ImVec2(pos2.x + 10, pos2.y + 44), statAZ, u8("AZ: ") .. formatNumber(todayAZ))

        local pos3 = imgui.ImVec2(startPos.x + cardWidth * 2 + cardSpacing * 2, startPos.y)
        drawList:AddRectFilled(pos3, imgui.ImVec2(pos3.x + cardWidth, pos3.y + cardHeight), statBg, 6)
        drawList:AddRect(pos3, imgui.ImVec2(pos3.x + cardWidth, pos3.y + cardHeight), statBorder, 6, 15, 1.0)
        drawList:AddText(imgui.ImVec2(pos3.x + 10, pos3.y + 8), statLabel, u8("За неделю"))
        drawList:AddText(imgui.ImVec2(pos3.x + 10, pos3.y + 26), statValueWeek, formatNumber(weekAll) .. "$")
        drawList:AddText(imgui.ImVec2(pos3.x + 10, pos3.y + 44), statAZ, u8("AZ: ") .. formatNumber(weekAZ))

        imgui.SetCursorScreenPos(imgui.ImVec2(startPos.x, startPos.y + cardHeight))
        imgui.Dummy(imgui.ImVec2(listW, 0))

        imgui.Spacing(); imgui.Separator(); imgui.Spacing()

        imgui.TextColored(imgui.ImVec4(0.6, 0.6, 0.6, 1), u8("Доход за сессию: ") .. formatNumber(oilSessionData.money) .. "$" .. u8(", AZ: ") .. formatNumber(oilSessionData.az))
        imgui.Spacing()
        if StyleButton(u8("Начать новую сессию"), fa.ICON_REFRESH, 220) then
            resetOilSession()
        end
        imgui.Spacing()

        if ToggleSwitch(u8("Показывать оверлей на экране"), cb_oil_overlay) then
            if cb_oil_overlay.v then
                settings.oilOverlayEnabled = true
                settings.farmOverlayEnabled = false
                settings.mineOverlayEnabled = false
                settings.sawmillOverlayEnabled = false
                cb_farm_overlay.v = false
                cb_mine_overlay.v = false
                cb_sawmill_overlay.v = false
                if settings.overlayAutoTimer and not overlayTimer.running then
                    overlayTimer.running = true; overlayTimer.startTime = os.time()
                    overlayTimer.elapsed = 0; overlayTimer.displayedTime = "00:00:00"
                end
            else
                settings.oilOverlayEnabled = false
            end
            saveConfig()
        end
    end

    
    --  ЦЕНЫ
    
    if oilSectionTab.v == 1 then
        if not oilBarrelCostEdit then oilBarrelCostEdit = imgui.ImInt(oilConfig.barrelCost) end
        if not oilAzBarrelCostEdit then oilAzBarrelCostEdit = imgui.ImInt(oilConfig.azBarrelCost) end

        local padX, headerH, padBottom = 16, 36, 14

        local function beginCard()
            drawList:ChannelsSplit(2)
            drawList:ChannelsSetCurrent(1)
            local pos = imgui.GetCursorScreenPos()
            imgui.SetCursorScreenPos(imgui.ImVec2(pos.x, pos.y + headerH))
            imgui.Indent(padX)
            return pos, imgui.GetCursorPosX()
        end

        local function endCard(pos, icon, title, accent, accentDim)
            imgui.Unindent(padX)
            local afterY = imgui.GetCursorScreenPos().y
            local cardH = (afterY - pos.y) + padBottom

            drawList:ChannelsSetCurrent(0)
            drawList:AddRectFilled(pos, imgui.ImVec2(pos.x + listW, pos.y + cardH), statBg, 8)
            drawList:AddRect(pos, imgui.ImVec2(pos.x + listW, pos.y + cardH), statBorder, 8, 15, 1.0)
            drawList:AddRectFilled(imgui.ImVec2(pos.x, pos.y + 2), imgui.ImVec2(pos.x + 3, pos.y + cardH - 2), accent, 2)

            local badgeSize = 26
            local badgeX, badgeY = pos.x + padX, pos.y + 8
            drawList:AddRectFilled(imgui.ImVec2(badgeX, badgeY), imgui.ImVec2(badgeX + badgeSize, badgeY + badgeSize), accentDim, 7)
            local iconSz = imgui.CalcTextSize(icon)
            drawList:AddText(imgui.ImVec2(badgeX + (badgeSize - iconSz.x) / 2, badgeY + (badgeSize - iconSz.y) / 2), accent, icon)

            local titleSz = imgui.CalcTextSize(title)
            drawList:AddText(imgui.ImVec2(badgeX + badgeSize + 10, badgeY + (badgeSize - titleSz.y) / 2), 0xFFFFFFFF, title)

            drawList:ChannelsMerge()

            imgui.SetCursorScreenPos(imgui.ImVec2(pos.x, pos.y + cardH))
            imgui.Dummy(imgui.ImVec2(listW, 0))
            imgui.Spacing(); imgui.Spacing()
        end

        local function drawValueRow(contentX, valueColOffset, label, drawWidget)
            imgui.SetCursorPosX(contentX)
            imgui.Text(label)
            imgui.SameLine()
            imgui.SetCursorPosX(contentX + valueColOffset)
            drawWidget()
        end

        local ACCENT_BLUE  = 0xFF3399FF; local ACCENT_BLUE_DIM  = 0xFF1A3550
        local ACCENT_GREEN = 0xFF33CC88; local ACCENT_GREEN_DIM = 0xFF1A3A2E
        local ACCENT_GOLD  = 0xFFFFB020; local ACCENT_GOLD_DIM  = 0xFF3D3018

        local function styledInputInt(id, imIntVar, step, stepFast, accentVec)
            imgui.PushStyleVar(imgui.StyleVar.FrameRounding, 6)
            imgui.PushStyleColor(imgui.Col.FrameBg, imgui.ImVec4(0.09, 0.09, 0.09, 1))
            imgui.PushStyleColor(imgui.Col.FrameBgHovered, imgui.ImVec4(0.13, 0.13, 0.13, 1))
            imgui.PushStyleColor(imgui.Col.FrameBgActive, imgui.ImVec4(0.15, 0.15, 0.15, 1))
            imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(accentVec.x, accentVec.y, accentVec.z, 0.18))
            imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(accentVec.x, accentVec.y, accentVec.z, 0.35))
            imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(accentVec.x, accentVec.y, accentVec.z, 0.5))
            imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.95, 0.95, 0.95, 1))
            imgui.InputInt(id, imIntVar, step, stepFast)
            imgui.PopStyleColor(7)
            imgui.PopStyleVar(1)
        end
        local ACCENT_BLUE_VEC = imgui.ImVec4(0.2, 0.6, 1.0, 1)

        local pos1, contentX1 = beginCard()
        imgui.PushItemWidth(150)
        drawValueRow(contentX1, 110, u8("Вода, $"), function()
            styledInputInt("##oil_barrelcost", oilBarrelCostEdit, 1000, 10000, ACCENT_BLUE_VEC)
        end)
        drawValueRow(contentX1, 110, u8("Грунт, AZ"), function()
            styledInputInt("##oil_azbarrelcost", oilAzBarrelCostEdit, 1, 5, ACCENT_BLUE_VEC)
        end)
        imgui.PopItemWidth()
        endCard(pos1, fa.ICON_SHOPPING_CART, u8("Цены закупки бочек"), ACCENT_BLUE, ACCENT_BLUE_DIM)

        local pos2, contentX2 = beginCard()
        imgui.SetCursorPosX(contentX2)
        imgui.TextColored(imgui.ImVec4(0.35, 0.85, 0.6, 1), formatNumber(oilConfig.groundOilMoney) .. "$")
        imgui.SetCursorPosX(contentX2)
        imgui.PushTextWrapPos(contentX2 + listW - padX * 2 - 24)
        imgui.TextColored(imgui.ImVec4(0.6, 0.6, 0.6, 1), u8("Обновляется автоматически при подходе к вышке / точке приёма."))
        imgui.PopTextWrapPos()
        endCard(pos2, fa.ICON_MONEY, u8("Авто-цена продажи бочки"), ACCENT_GREEN, ACCENT_GREEN_DIM)

                -- Карточка 3: доплата за бочку для наземных вышек
        if oilConfig.groundBarrelCompanyBonus == nil or (oilConfig.groundBarrelCompanyBonus ~= 0 and oilConfig.groundBarrelCompanyBonus ~= 40000 and oilConfig.groundBarrelCompanyBonus ~= 80000 and oilConfig.groundBarrelCompanyBonus ~= 100000) then
            oilConfig.groundBarrelCompanyBonus = 40000
        end
        if not oilConfig.waterBarrelCompanyBonus then oilConfig.waterBarrelCompanyBonus = 0 end
        
        local pos3, contentX3 = beginCard()

        local companyBonusOptions = {0, 40000, 80000, 100000}
        local chipGap = 8
        local chipW = (listW - padX * 2 - chipGap * 3) / 4
        local chipH = 39
        imgui.SetCursorPosX(contentX3)
        local chipStart = imgui.GetCursorScreenPos()
        for i, amount in ipairs(companyBonusOptions) do
            local chipX = chipStart.x + (i - 1) * (chipW + chipGap)
            local chipY = chipStart.y
            local selected = (oilConfig.groundBarrelCompanyBonus == amount)

            local mp = imgui.GetMousePos()
            local hovered = (mp.x >= chipX and mp.x <= chipX + chipW and mp.y >= chipY and mp.y <= chipY + chipH)

            local chipBg = selected and ACCENT_GOLD_DIM or (hovered and 0xFF222222 or statBg)
            local chipBorder = selected and ACCENT_GOLD or statBorder
            drawList:AddRectFilled(imgui.ImVec2(chipX, chipY), imgui.ImVec2(chipX + chipW, chipY + chipH), chipBg, 7)
            drawList:AddRect(imgui.ImVec2(chipX, chipY), imgui.ImVec2(chipX + chipW, chipY + chipH), chipBorder, 7, 15, selected and 2.0 or 1.0)

            local amountText = amount == 0 and u8("0$") or formatNumber(amount) .. "$"
            local amtSz = imgui.CalcTextSize(amountText)
            local amtCol = selected and ACCENT_GOLD or 0xFFCCCCCC
            drawList:AddText(imgui.ImVec2(chipX + (chipW - amtSz.x) / 2, chipY + chipH / 2 - amtSz.y / 2), amtCol, amountText)

            if selected then
                local checkSz = imgui.CalcTextSize(fa.ICON_CHECK)
                drawList:AddText(imgui.ImVec2(chipX + chipW - checkSz.x - 7, chipY + 5), ACCENT_GOLD, fa.ICON_CHECK)
            end

            imgui.SetCursorScreenPos(imgui.ImVec2(chipX, chipY))
            if imgui.InvisibleButton("##oil_bonus_chip_" .. i, imgui.ImVec2(chipW, chipH)) then
                oilConfig.groundBarrelCompanyBonus = amount
                saveOilConfig()
            end
        end
        imgui.SetCursorScreenPos(imgui.ImVec2(chipStart.x, chipStart.y + chipH))
        imgui.Dummy(imgui.ImVec2(listW - padX * 2, 0))
        imgui.Spacing()

        imgui.SetCursorPosX(contentX3)
        imgui.PushTextWrapPos(contentX3 + listW - padX * 2 - 24)
        imgui.TextColored(imgui.ImVec4(0.6, 0.6, 0.6, 1), u8("Выбери доплату электрокомпании. 0$ - без доплаты (для сдачи на пирсе СФ)."))
        imgui.PopTextWrapPos()
        endCard(pos3, fa.ICON_PLUS, u8("Доплата электрокомпании за бочку"), ACCENT_GOLD, ACCENT_GOLD_DIM)

        if StyleButton(u8("Сохранить настройки"), fa.ICON_FLOPPY_O, 220) then
            oilConfig.barrelCost = oilBarrelCostEdit.v
            oilConfig.azBarrelCost = oilAzBarrelCostEdit.v
            saveOilConfig()
            sampAddChatMessage(SCRIPT_PREFIX .. "Настройки нефтевышек сохранены!", SCRIPT_COLOR)
        end
    end

    
    --  КЕЙСЫ
    
    if oilSectionTab.v == 2 then
        local totalCasesValue = 0
        for itemId, caseData in pairs(caseConfig) do
            totalCasesValue = totalCasesValue + (caseData.cost * caseData.count)
        end

        local totalCasesCount = 0
        for _, caseData in pairs(caseConfig) do
            totalCasesCount = totalCasesCount + caseData.count
        end

        local cardSpacing = 8
        local cardWidth = (listW - cardSpacing) / 2
        local cardHeight = 55
        local startPos = imgui.GetCursorScreenPos()

        drawList:AddRectFilled(startPos, imgui.ImVec2(startPos.x + cardWidth, startPos.y + cardHeight), statBg, 6)
        drawList:AddRect(startPos, imgui.ImVec2(startPos.x + cardWidth, startPos.y + cardHeight), statBorder, 6, 15, 1.0)
        drawList:AddText(imgui.ImVec2(startPos.x + 10, startPos.y + 8), statLabel, u8("Всего за кейсы"))
        drawList:AddText(imgui.ImVec2(startPos.x + 10, startPos.y + 28), statValue, formatNumber(totalCasesValue) .. "$")

        local pos2 = imgui.ImVec2(startPos.x + cardWidth + cardSpacing, startPos.y)
        drawList:AddRectFilled(pos2, imgui.ImVec2(pos2.x + cardWidth, pos2.y + cardHeight), statBg, 6)
        drawList:AddRect(pos2, imgui.ImVec2(pos2.x + cardWidth, pos2.y + cardHeight), statBorder, 6, 15, 1.0)
        drawList:AddText(imgui.ImVec2(pos2.x + 10, pos2.y + 8), statLabel, u8("Кейсов всего"))
        drawList:AddText(imgui.ImVec2(pos2.x + 10, pos2.y + 28), statValueToday, formatNumber(totalCasesCount) .. u8(" шт."))

        imgui.SetCursorScreenPos(imgui.ImVec2(startPos.x, startPos.y + cardHeight))
        imgui.Dummy(imgui.ImVec2(listW, 0))
        imgui.Spacing(); imgui.Separator(); imgui.Spacing()

        if next(caseConfig) == nil then
            imgui.TextColored(imgui.ImVec4(0.6, 0.6, 0.6, 1), u8("Нет кейсов. Они появятся здесь при выпадении."))
        else
            for itemId, caseData in pairs(caseConfig) do
                if not caseEditCache then caseEditCache = {} end
                if not caseEditCache[itemId] then
                    caseEditCache[itemId] = imgui.ImInt(caseData.cost or 0)
                end

                local cardX2 = imgui.GetCursorScreenPos().x
                local cardY2 = imgui.GetCursorScreenPos().y
                local caseCardH = 50
                drawList:AddRectFilled(imgui.ImVec2(cardX2, cardY2), imgui.ImVec2(cardX2 + listW, cardY2 + caseCardH), 0xFF1A1A1A, 6)
                drawList:AddRect(imgui.ImVec2(cardX2, cardY2), imgui.ImVec2(cardX2 + listW, cardY2 + caseCardH), 0xFF333333, 6, 15, 1.0)
                drawList:AddText(imgui.ImVec2(cardX2 + 10, cardY2 + 8), 0xFFFFFFFF, u8(caseData.name))
                drawList:AddText(imgui.ImVec2(cardX2 + 10, cardY2 + 28), 0xFF888888, u8("Кол-во: ") .. caseData.count .. u8(" | Доход: ") .. formatNumber(caseData.cost * caseData.count) .. "$")

                imgui.SetCursorScreenPos(imgui.ImVec2(cardX2 + listW - 200, cardY2 + 8))
                imgui.PushItemWidth(140)
                if imgui.InputInt("##case_cost_" .. itemId, caseEditCache[itemId], 1000, 10000) then
                    caseConfig[itemId].cost = caseEditCache[itemId].v
                    saveCaseConfig()
                end
                imgui.PopItemWidth()

                imgui.SetCursorScreenPos(imgui.ImVec2(cardX2 + listW - 50, cardY2 + 28))
                if imgui.Button(fa.ICON_REPEAT .. "##reset_case_" .. itemId, imgui.ImVec2(20, 18)) then
                    caseConfig[itemId].count = 0
                    saveCaseConfig()
                end

                imgui.SetCursorScreenPos(imgui.ImVec2(cardX2, cardY2 + caseCardH))
                imgui.Dummy(imgui.ImVec2(listW, 2))
            end
        end

        imgui.Spacing()
        if StyleButton(u8("Сохранить цены кейсов"), fa.ICON_FLOPPY_O, 220) then
            saveCaseConfig()
            sampAddChatMessage(SCRIPT_PREFIX .. "Цены кейсов сохранены!", SCRIPT_COLOR)
        end
    end

    
    --  СТАТИСТИКА
    
    if oilSectionTab.v == 3 then
        local allDates = {}
        local seenDates = {}
        for _, log in ipairs(currentLog) do
            local d = getGameDate(log.time)
            if not seenDates[d] then seenDates[d] = true; table.insert(allDates, d) end
        end
        table.sort(allDates, function(a, b) return a > b end)

        if not oilSelectedDateStr then
            if allDates[1] then
                oilSelectedDateStr = allDates[1]
            else
                local t = os.date("*t")
                oilSelectedDateStr = string.format("%04d-%02d-%02d", t.year, t.month, t.day)
            end
            local yy, mm = oilSelectedDateStr:match("(%d+)-(%d+)-")
            oilCalendarYear = tonumber(yy)
            oilCalendarMonth = tonumber(mm)
        end

        if #allDates > 0 then
            local selectedDate = oilSelectedDateStr
            local daySum, dayAZ, dayCases, logCount = 0, 0, 0, 0
            if selectedDate then
                for i = 1, math.min(#currentLog, 500) do
                    local log = currentLog[i]
                    if getGameDate(log.time) == selectedDate then
                        daySum = daySum + (log.money or 0)
                        dayAZ = dayAZ + (log.az or 0)
                        dayCases = dayCases + (log.caseCount or 0)
                        logCount = logCount + 1
                    end
                end
            end

            local btnW = listW; local btnH = 38
            local btnPos = imgui.GetCursorScreenPos()
            local hovered = (imgui.GetMousePos().x >= btnPos.x and imgui.GetMousePos().x <= btnPos.x + btnW and imgui.GetMousePos().y >= btnPos.y and imgui.GetMousePos().y <= btnPos.y + btnH)
            local dateBgCol, dateBorderCol, iconCol = getCardColors(hovered)
            drawList:AddRectFilled(btnPos, imgui.ImVec2(btnPos.x + btnW, btnPos.y + btnH), dateBgCol, 6)
            drawList:AddRect(btnPos, imgui.ImVec2(btnPos.x + btnW, btnPos.y + btnH), dateBorderCol, 6, 15, 1.0)

            local y, m, day = selectedDate:match("(%d+)-(%d+)-(%d+)")
            local displaySelected = selectedDate
            if y and m and day then displaySelected = day .. "." .. m .. "." .. y end
            drawList:AddText(imgui.ImVec2(btnPos.x + 12, btnPos.y + 10), iconCol, fa.ICON_CALENDAR .. " " .. displaySelected)

            local sumText = formatNumber(daySum) .. "$ + " .. formatNumber(dayAZ) .. " AZ"
            if dayCases > 0 then sumText = sumText .. " + " .. dayCases .. u8(" кейс") end
            local infoText = "  •  " .. logCount .. " " .. u8("записей")
            local sumTextW = imgui.CalcTextSize(sumText).x; local infoTextW = imgui.CalcTextSize(infoText).x
            drawList:AddText(imgui.ImVec2(btnPos.x + btnW - sumTextW - infoTextW - 35, btnPos.y + 10), iconCol, sumText)
            drawList:AddText(imgui.ImVec2(btnPos.x + btnW - infoTextW - 35, btnPos.y + 10), 0xFF888888, infoText)
            drawList:AddText(imgui.ImVec2(btnPos.x + btnW - 25, btnPos.y + 10), 0xFF888888, fa.ICON_ARROW_DOWN)
            imgui.SetCursorScreenPos(btnPos)
            if imgui.InvisibleButton("##oil_date_btn", imgui.ImVec2(btnW, btnH)) then
                local cyy, cmm = oilSelectedDateStr:match("(%d+)-(%d+)-")
                if cyy and cmm then oilCalendarYear = tonumber(cyy); oilCalendarMonth = tonumber(cmm) end
                imgui.OpenPopup("##oil_date_popup")
            end

            if imgui.BeginPopup("##oil_date_popup") then
                local monthNamesRu = {u8("Январь"), u8("Февраль"), u8("Март"), u8("Апрель"), u8("Май"), u8("Июнь"), u8("Июль"), u8("Август"), u8("Сентябрь"), u8("Октябрь"), u8("Ноябрь"), u8("Декабрь")}
                local weekdayNamesRu = {u8("Пн"), u8("Вт"), u8("Ср"), u8("Чт"), u8("Пт"), u8("Сб"), u8("Вс")}
                local todayStr = getGameDate()

                local ACCENT = 0xFF6078E0
                local TODAY_RING = 0xFFFFFFFF
                local WEEKEND_COL = 0xFF6078E0
                local DOT_GREEN = 0xFFD4BC00

                local function daysInMonth(yy, mm)
                    local dim = {31,28,31,30,31,30,31,31,30,31,30,31}
                    if mm == 2 and (yy % 4 == 0 and (yy % 100 ~= 0 or yy % 400 == 0)) then return 29 end
                    return dim[mm]
                end
                local function firstWeekdayOfMonth(yy, mm)
                    local t = os.time({year = yy, month = mm, day = 1, hour = 12})
                    local w = tonumber(os.date("%w", t))
                    if w == 0 then w = 7 end
                    return w
                end
                local function getDateIncome(dateStr)
                    local sum = 0
                    for _, log in ipairs(currentLog) do
                        if getGameDate(log.time) == dateStr then sum = sum + (log.money or 0) end
                    end
                    return sum
                end

                local calDrawList = imgui.GetWindowDrawList()
                local cellSize = 34
                local cellGap = 2
                local step = cellSize + cellGap
                local headerW = step * 7

                local headerPos = imgui.GetCursorScreenPos()
                local headerH = 30

                local btnSize = 24
                local leftBtnX = headerPos.x
                local leftBtnY = headerPos.y + (headerH - btnSize) / 2
                local mouseP = imgui.GetMousePos()
                local leftHovered = (mouseP.x >= leftBtnX and mouseP.x <= leftBtnX + btnSize and mouseP.y >= leftBtnY and mouseP.y <= leftBtnY + btnSize)
                local leftCenter = imgui.ImVec2(leftBtnX + btnSize / 2, leftBtnY + btnSize / 2)
                calDrawList:AddCircleFilled(leftCenter, btnSize / 2, leftHovered and 0xFF2E2E2E or 0xFF1C1C1C, 20)
                local leftArrow = fa.ICON_ANGLE_LEFT
                local leftArrowSz = imgui.CalcTextSize(leftArrow)
                calDrawList:AddText(imgui.ImVec2(leftCenter.x - leftArrowSz.x / 2, leftCenter.y - leftArrowSz.y / 2), leftHovered and 0xFFFFFFFF or 0xFFAAAAAA, leftArrow)
                imgui.SetCursorScreenPos(imgui.ImVec2(leftBtnX, leftBtnY))
                if imgui.InvisibleButton("##oilcal_month_left", imgui.ImVec2(btnSize, btnSize)) then
                    oilCalendarMonth = oilCalendarMonth - 1
                    if oilCalendarMonth < 1 then oilCalendarMonth = 12; oilCalendarYear = oilCalendarYear - 1 end
                end

                local rightBtnX = headerPos.x + headerW - btnSize
                local rightBtnY = leftBtnY
                local rightHovered = (mouseP.x >= rightBtnX and mouseP.x <= rightBtnX + btnSize and mouseP.y >= rightBtnY and mouseP.y <= rightBtnY + btnSize)
                local rightCenter = imgui.ImVec2(rightBtnX + btnSize / 2, rightBtnY + btnSize / 2)
                calDrawList:AddCircleFilled(rightCenter, btnSize / 2, rightHovered and 0xFF2E2E2E or 0xFF1C1C1C, 20)
                local rightArrow = fa.ICON_ANGLE_RIGHT
                local rightArrowSz = imgui.CalcTextSize(rightArrow)
                calDrawList:AddText(imgui.ImVec2(rightCenter.x - rightArrowSz.x / 2, rightCenter.y - rightArrowSz.y / 2), rightHovered and 0xFFFFFFFF or 0xFFAAAAAA, rightArrow)
                imgui.SetCursorScreenPos(imgui.ImVec2(rightBtnX, rightBtnY))
                if imgui.InvisibleButton("##oilcal_month_right", imgui.ImVec2(btnSize, btnSize)) then
                    oilCalendarMonth = oilCalendarMonth + 1
                    if oilCalendarMonth > 12 then oilCalendarMonth = 1; oilCalendarYear = oilCalendarYear + 1 end
                end

                local monthName = monthNamesRu[oilCalendarMonth]
                local yearName = tostring(oilCalendarYear)
                local monthNameW = imgui.CalcTextSize(monthName).x
                local monthNameH = imgui.CalcTextSize(monthName).y
                local yearNameW = imgui.CalcTextSize(yearName).x
                local yearNameH = imgui.CalcTextSize(yearName).y
                local totalH = monthNameH + yearNameH + 2
                local textStartY = headerPos.y + (headerH - totalH) / 2
                calDrawList:AddText(imgui.ImVec2(headerPos.x + (headerW - monthNameW) / 2, textStartY), 0xFF6078E0, monthName)
                calDrawList:AddText(imgui.ImVec2(headerPos.x + (headerW - yearNameW) / 2, textStartY + monthNameH + 2), 0xFFAAAAAA, yearName)

                imgui.SetCursorScreenPos(imgui.ImVec2(headerPos.x, headerPos.y + headerH))
                imgui.Dummy(imgui.ImVec2(headerW, 4))

                local subSepY = imgui.GetCursorScreenPos().y + 2
                calDrawList:AddLine(imgui.ImVec2(headerPos.x, subSepY), imgui.ImVec2(headerPos.x + headerW, subSepY), 0xFF2A2A2A, 1.0)
                imgui.SetCursorScreenPos(imgui.ImVec2(headerPos.x, subSepY + 8))

                local hdrPos = imgui.GetCursorScreenPos()
                for i, wd in ipairs(weekdayNamesRu) do
                    local isWeekend = (i == 6 or i == 7)
                    local wdW = imgui.CalcTextSize(wd).x
                    calDrawList:AddText(imgui.ImVec2(hdrPos.x + (i - 1) * step + (cellSize - wdW) / 2, hdrPos.y), isWeekend and WEEKEND_COL or 0xFF666666, wd)
                end
                imgui.Dummy(imgui.ImVec2(headerW, 18))

                local startWd = firstWeekdayOfMonth(oilCalendarYear, oilCalendarMonth)
                local totalDays = daysInMonth(oilCalendarYear, oilCalendarMonth)
                local gridPos = imgui.GetCursorScreenPos()

                local row, col = 0, startWd - 1
                for dnum = 1, totalDays do
                    local cellX = gridPos.x + col * step
                    local cellY = gridPos.y + row * step
                    local center = imgui.ImVec2(cellX + cellSize / 2, cellY + cellSize / 2)
                    local radius = cellSize / 2 - 1

                    local dateStr = string.format("%04d-%02d-%02d", oilCalendarYear, oilCalendarMonth, dnum)
                    local hasIncome = seenDates[dateStr] == true
                    local isSelected = (dateStr == oilSelectedDateStr)
                    local isToday = (dateStr == todayStr)
                    local weekdayIdx = ((startWd - 1 + dnum - 1) % 7) + 1
                    local isWeekend = (weekdayIdx == 6 or weekdayIdx == 7)

                    local cellHovered = (mouseP.x >= cellX and mouseP.x <= cellX + cellSize and mouseP.y >= cellY and mouseP.y <= cellY + cellSize)

                    if isSelected and isToday then
                        calDrawList:AddCircleFilled(center, radius, ACCENT, 24)
                        calDrawList:AddCircle(center, radius, TODAY_RING, 24, 2.0)
                    elseif isSelected then
                        calDrawList:AddCircleFilled(center, radius, ACCENT, 24)
                    elseif isToday then
                        calDrawList:AddCircle(center, radius, TODAY_RING, 24, 1.5)
                    elseif cellHovered then
                        calDrawList:AddCircle(center, radius, 0xFF444444, 24, 1.0)
                    end

                    local dayStr = tostring(dnum)
                    local dayStrSz = imgui.CalcTextSize(dayStr)
                    local textCol
                    if isSelected then textCol = 0xFFFFFFFF
                    elseif isToday then textCol = 0xFF1AE591
                    elseif isWeekend then textCol = WEEKEND_COL
                    elseif cellHovered then textCol = 0xFFEEEEEE
                    else textCol = 0xFFCCCCCC end
                    calDrawList:AddText(imgui.ImVec2(center.x - dayStrSz.x / 2, center.y - dayStrSz.y / 2 - (hasIncome and 3 or 0)), textCol, dayStr)

                    if hasIncome then
                        local dotCol = isSelected and 0xFFFFFFFF or DOT_GREEN
                        calDrawList:AddCircleFilled(imgui.ImVec2(center.x, center.y + dayStrSz.y / 2 + 2), 2.0, dotCol, 12)
                    end

                    imgui.SetCursorScreenPos(imgui.ImVec2(cellX, cellY))
                    if imgui.InvisibleButton("##oilcal_" .. dateStr, imgui.ImVec2(cellSize, cellSize)) then
                        oilSelectedDateStr = dateStr
                        imgui.CloseCurrentPopup()
                    end

                    if cellHovered then
                        imgui.BeginTooltip()
                        imgui.Text(dayStr .. " " .. monthNamesRu[oilCalendarMonth])
                        local dayIncome = getDateIncome(dateStr)
                        local dAZ = 0
                        for _, log in ipairs(currentLog) do
                            if getGameDate(log.time) == dateStr then dAZ = dAZ + (log.az or 0) end
                        end
                        if dayIncome > 0 or dAZ > 0 then
                            imgui.Text(u8("Итого: ") .. formatNumber(dayIncome) .. "$  |  AZ: " .. formatNumber(dAZ))
                        else
                            imgui.Text(u8("Нет данных"))
                        end
                        imgui.EndTooltip()
                    end

                    col = col + 1
                    if col > 6 then col = 0; row = row + 1 end
                end

                imgui.SetCursorScreenPos(imgui.ImVec2(gridPos.x, gridPos.y + (row + 1) * step + 4))

                local legY = imgui.GetCursorScreenPos().y + 6
                calDrawList:AddLine(imgui.ImVec2(headerPos.x, legY), imgui.ImVec2(headerPos.x + headerW, legY), 0xFF2A2A2A, 1.0)

                local legendY = legY + 8
                calDrawList:AddCircleFilled(imgui.ImVec2(headerPos.x + 6, legendY + 5), 2.0, DOT_GREEN, 12)
                calDrawList:AddText(imgui.ImVec2(headerPos.x + 14, legendY), 0xFF777777, u8("Есть доход"))

                local todayLabel = u8("Сегодня")
                local todayLabelW = imgui.CalcTextSize(todayLabel).x
                calDrawList:AddCircle(imgui.ImVec2(headerPos.x + headerW - todayLabelW - 16, legendY + 5), 4.0, TODAY_RING, 12, 1.2)
                calDrawList:AddText(imgui.ImVec2(headerPos.x + headerW - todayLabelW, legendY), 0xFF777777, todayLabel)

                imgui.SetCursorScreenPos(imgui.ImVec2(headerPos.x, legendY + 20))
                imgui.Dummy(imgui.ImVec2(headerW, 1))

                imgui.EndPopup()
            end

            imgui.SetCursorScreenPos(imgui.ImVec2(btnPos.x, btnPos.y + btnH))
            imgui.Dummy(imgui.ImVec2(btnW, 4))

            if selectedDate and logCount > 0 then
                imgui.Spacing()
                local logs = {}
                for i = 1, math.min(#currentLog, 500) do
                    local log = currentLog[i]
                    if getGameDate(log.time) == selectedDate then table.insert(logs, log) end
                end

                local hdrX = imgui.GetCursorScreenPos().x
                local tblTopY = imgui.GetCursorScreenPos().y
                local hdrH = 28
                local rowH = 32
                local tblTotalH = hdrH + #logs * rowH

                local ACCENT_GREEN = 0xFF33CC66
                local NEUTRAL = 0xFFE0E0E0
                local timeW = 70
                local casesW = 55
                local azW = 55
                local totalColW = 120
                local midW = (listW - timeW - casesW - azW - totalColW) / 1
                local colX = {
                    hdrX,
                    hdrX + timeW,
                    hdrX + timeW + midW,
                    hdrX + timeW + midW + casesW,
                    hdrX + timeW + midW + casesW + azW,
                    hdrX + listW,
                }
                local headerLabels = {u8("Время"), u8("Тип"), u8("Ларцы"), u8("AZ"), u8("Сумма")}
                local headerAligns = {"left", "left", "center", "center", "right"}
                local headerColors = {tableHdrText, tableHdrText, tableHdrText, 0xFF00CCFF, ACCENT_GREEN}
                local rightEdge = colX[#colX]

                drawList:AddRectFilled(imgui.ImVec2(hdrX, tblTopY), imgui.ImVec2(hdrX + listW, tblTopY + tblTotalH), 0xFF0C0C0C, 8, 15)
                drawList:AddRectFilled(imgui.ImVec2(hdrX, tblTopY), imgui.ImVec2(hdrX + listW, tblTopY + hdrH), tableHdrBg, 8, 3)

                for i, lbl in ipairs(headerLabels) do
                    local cx0, cx1 = colX[i], colX[i + 1]
                    local tw = imgui.CalcTextSize(lbl).x
                    local tx
                    if headerAligns[i] == "center" then tx = cx0 + (cx1 - cx0 - tw) / 2
                    elseif headerAligns[i] == "right" then tx = cx1 - tw - 12
                    else tx = cx0 + 12 end
                    drawList:AddText(imgui.ImVec2(tx, tblTopY + 7), headerColors[i], lbl)
                end

                local function centeredX(colIdx, text)
                    local cx0, cx1 = colX[colIdx], colX[colIdx + 1]
                    return cx0 + (cx1 - cx0 - imgui.CalcTextSize(text).x) / 2
                end

                local kindLabels = {
                    water = u8("Водная вышка"),
                    ground_money = u8("Вышки (электрокомпании)"),
                    ground_az = u8("Наземные нефтевышки (AZ)"),
                    bonus_az = u8("Бонус AZ"),
                    buy_water = u8("Закупка (вода)"),
                    buy_ground = u8("Закупка (Наземные нефтевышки)"),
                    case_drop = u8("Кейс"),
                }

                for logIdx, log in ipairs(logs) do
                    local msk = log.time + 10800; local timeStr = os.date("!%H:%M", msk)
                    local rowY = tblTopY + hdrH + (logIdx - 1) * rowH
                    local mp = imgui.GetMousePos()
                    local rowHovered = (mp.x >= hdrX and mp.x <= hdrX + listW and mp.y >= rowY and mp.y <= rowY + rowH)
                    local rowBg = rowHovered and 0xFF1E1E1E or ((logIdx % 2 == 0) and 0xFF171717 or 0xFF121212)
                    local isLastRow = (logIdx == #logs)
                    drawList:AddRectFilled(imgui.ImVec2(hdrX + 1, rowY), imgui.ImVec2(hdrX + listW - 1, rowY + rowH), rowBg, isLastRow and 8 or 0, isLastRow and 12 or 0)
                    drawList:AddText(imgui.ImVec2(colX[1] + 10, rowY + 8), 0xFF999999, timeStr)

                    local kindText = kindLabels[log.kind] or u8("Прочее")
                    local kindColor = NEUTRAL
                    if log.kind == "buy_water" or log.kind == "buy_ground" then kindColor = 0xFFFF6666
                    elseif log.kind == "case_drop" then kindColor = 0xFFD4BC00 end
                    drawList:AddText(imgui.ImVec2(colX[2] + 10, rowY + 8), kindColor, kindText)

                    local caseCountStr = (log.caseCount or 0) > 0 and formatNumber(log.caseCount) or ""
                    drawList:AddText(imgui.ImVec2(centeredX(3, caseCountStr), rowY + 8), 0xFFD4BC00, caseCountStr)

                    local azStr = formatNumber(log.az or 0)
                    drawList:AddText(imgui.ImVec2(centeredX(4, azStr), rowY + 8), 0xFF00CCFF, azStr)

                    local moneyVal = log.money or 0
                    local totalStr = (moneyVal >= 0 and "+" or "") .. formatNumber(moneyVal) .. "$"
                    local totalTW = imgui.CalcTextSize(totalStr).x
                    local totalX = rightEdge - totalTW - 8
                    drawList:AddText(imgui.ImVec2(totalX, rowY + 8), (moneyVal < 0 and 0xFFFF6666 or ACCENT_GREEN), totalStr)

                    -- Иконка детализации
                    local iconX = totalX - 20
                    drawList:AddText(imgui.ImVec2(iconX, rowY + 8), 0xFF888888, fa.ICON_INFO_CIRCLE)
                    imgui.SetCursorScreenPos(imgui.ImVec2(iconX, rowY))
                    if imgui.InvisibleButton("##oil_detail_" .. log.time, imgui.ImVec2(18, rowH)) then end
                    if imgui.IsItemHovered() then
                        imgui.BeginTooltip()
                        if log.kind == "water" then
                            -- Водная бочка: базовая цена продажи на пирсе
                            local totalMoney = log.money or 0
                            local caseCost = 0
                            if log.caseType and caseConfig[log.caseType] then
                                caseCost = caseConfig[log.caseType].cost or 0
                            end
                            local basePrice = totalMoney - caseCost
                            imgui.Text(u8("Доход с бочки: ") .. formatNumber(basePrice) .. "$")
                            -- Надбавки с бонусов (если были)
                            if basePrice > (oilConfig.groundOilMoney or 270000) then
                                local bonusAmount = basePrice - (oilConfig.groundOilMoney or 270000)
                                imgui.Text(u8("Надбавки с бонусов: ") .. formatNumber(bonusAmount) .. "$")
                            end
                            if log.isBonusAZ and log.az > 0 then
                                imgui.Text(u8("Бонус AZ: ") .. formatNumber(log.az) .. " AZ")
                            end
                            if caseCost > 0 then
                                imgui.Text(u8("Доход с кейса: ") .. formatNumber(caseCost) .. "$")
                            end
                        elseif log.kind == "ground_money" then
                            -- Наземная бочка: базовая цена + доплата электрокомпании
                            local basePrice = oilConfig.groundOilMoney or 270000
                            local companyBonus = oilConfig.groundBarrelCompanyBonus or 0
                            imgui.Text(u8("Доход с бочки: ") .. formatNumber(basePrice) .. "$")
                            imgui.Text(u8("Надбавки с электрокомпании: ") .. formatNumber(companyBonus) .. "$")
                            -- Надбавки с бонусов
                            local totalNoCase = basePrice + companyBonus
                            local actualNoCase = (log.money or 0)
                            if log.caseType and caseConfig[log.caseType] and caseConfig[log.caseType].cost > 0 then
                                actualNoCase = actualNoCase - caseConfig[log.caseType].cost
                            end
                            if actualNoCase > totalNoCase then
                                local bonusAmount = actualNoCase - totalNoCase
                                imgui.Text(u8("Надбавки с бонусов: ") .. formatNumber(bonusAmount) .. "$")
                            end
                            if log.caseType and caseConfig[log.caseType] and caseConfig[log.caseType].cost > 0 then
                                imgui.Text(u8("Доход с кейса: ") .. formatNumber(caseConfig[log.caseType].cost) .. "$")
                            end
                        elseif log.kind == "case_drop" then
                            local caseName = caseConfig[log.caseType] and caseConfig[log.caseType].name or u8("Неизвестный кейс")
                            imgui.Text(u8("Кейс: ") .. caseName)
                            imgui.Text(u8("Цена за шт: ") .. formatNumber(log.money) .. "$")
                            imgui.Text(u8("Кол-во: ") .. (log.caseCount or 1))
                        elseif log.kind == "ground_az" then
                            local basePrice = oilConfig.groundOilMoney or 270000
                            local totalMoney = log.money or 0
                            local caseCost = 0
                            if log.caseType and caseConfig[log.caseType] then
                                caseCost = caseConfig[log.caseType].cost or 0
                            end
                            local actualNoCase = totalMoney - caseCost
                            imgui.Text(u8("Доход с бочки: ") .. formatNumber(basePrice) .. "$")
                            if actualNoCase > basePrice then
                                local bonusAmount = actualNoCase - basePrice
                                imgui.Text(u8("Надбавки с бонусов: ") .. formatNumber(bonusAmount) .. "$")
                            end
                            if caseCost > 0 then
                                imgui.Text(u8("Доход с кейса: ") .. formatNumber(caseCost) .. "$")
                            end
                        elseif log.kind == "bonus_az" then
                            imgui.Text(u8("Бонус AZ: ") .. formatNumber(log.az))
                        end
                        imgui.EndTooltip()
                    end

                    if not isLastRow then
                        drawList:AddLine(imgui.ImVec2(hdrX + 6, rowY + rowH), imgui.ImVec2(hdrX + listW - 6, rowY + rowH), 0xFF232323, 1.0)
                    end
                end

                for i = 2, #colX - 1 do
                    drawList:AddLine(imgui.ImVec2(colX[i], tblTopY), imgui.ImVec2(colX[i], tblTopY + tblTotalH), 0xFF3A3A3A, 1.0)
                end

                drawList:AddRect(imgui.ImVec2(hdrX, tblTopY), imgui.ImVec2(hdrX + listW, tblTopY + tblTotalH), 0xFF333333, 8, 15, 1.2)

                imgui.SetCursorScreenPos(imgui.ImVec2(hdrX, tblTopY + tblTotalH + 8))
                imgui.Dummy(imgui.ImVec2(listW, 0))
            end
        else
            local iconSz = imgui.CalcTextSize(fa.ICON_FIRE)
            local textSz = imgui.CalcTextSize(u8("Нет данных"))
            local emptyPos = imgui.GetCursorScreenPos()
            local cy = emptyPos.y + 20
            drawList:AddText(imgui.ImVec2(emptyPos.x + (listW - iconSz.x) / 2, cy), 0xFF3A3A3A, fa.ICON_FIRE)
            drawList:AddText(imgui.ImVec2(emptyPos.x + (listW - textSz.x) / 2, cy + iconSz.y + 10), 0xFF666666, u8("Нет данных"))
            imgui.Dummy(imgui.ImVec2(listW, iconSz.y + 10 + textSz.y + 40))
        end
    end
end
function drawOilOverlay()
    local cfg = oilOverlayConfig
    imgui.SetNextWindowPos(imgui.ImVec2(cfg.x, cfg.y), imgui.Cond.FirstUseEver)
    imgui.SetNextWindowSize(imgui.ImVec2(cfg.w, cfg.h), imgui.Cond.FirstUseEver)

    imgui.PushStyleVar(imgui.StyleVar.WindowRounding, settings.overlayStyle == 2 and 8 or 0)
    imgui.PushStyleVar(imgui.StyleVar.WindowPadding, imgui.ImVec2(8, 6))
    if settings.overlayStyle == 2 then
        imgui.PushStyleColor(imgui.Col.Border, imgui.ImVec4(0.12, 0.12, 0.12, 1.0))
        imgui.PushStyleColor(imgui.Col.WindowBg, imgui.ImVec4(0.08, 0.08, 0.08, 0.94))
    else
        imgui.PushStyleColor(imgui.Col.Border, imgui.ImVec4(0, 0, 0, 0))
        imgui.PushStyleColor(imgui.Col.WindowBg, imgui.ImVec4(0, 0, 0, 0))
    end
    imgui.PushStyleColor(imgui.Col.ResizeGrip, imgui.ImVec4(0, 0, 0, 0))
    imgui.PushStyleColor(imgui.Col.ResizeGripHovered, imgui.ImVec4(0, 0, 0, 0))
    imgui.PushStyleColor(imgui.Col.ResizeGripActive, imgui.ImVec4(0, 0, 0, 0))

    local isHovered = settings.overlayHideOnHover and isMouseOverOverlay(cfg)
    if isHovered then
        imgui.PushStyleVar(imgui.StyleVar.Alpha, 0.0)
    end

    imgui.Begin(u8("Доход за сегодня (Нефтевышки)"), true, imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoTitleBar)

    if settings.overlayStyle == 2 then
        imgui.SetCursorPos(imgui.ImVec2(8, 8))
    else
        local winPos = imgui.GetWindowPos()
        local winSize = imgui.GetWindowSize()
        local drawList = imgui.GetWindowDrawList()
        drawList:AddRectFilled(winPos, imgui.ImVec2(winPos.x + winSize.x, winPos.y + winSize.y), 0xFF141414)
        drawList:AddRectFilled(winPos, imgui.ImVec2(winPos.x + winSize.x, winPos.y + 22), 0xFF0E0E0E)
        local titleText = u8("Нефтевышки")
        local titleWidth = imgui.CalcTextSize(titleText).x
        drawList:AddText(imgui.ImVec2(winPos.x + (winSize.x - titleWidth) / 2, winPos.y + 3), 0xFF1AE591, titleText)
        drawList:AddLine(imgui.ImVec2(winPos.x, winPos.y + 22), imgui.ImVec2(winPos.x + winSize.x, winPos.y + 22), 0xFF2A2A2A, 1.0)
        imgui.SetCursorPos(imgui.ImVec2(8, 28))
    end

    local todayAll, todayAZ = 0, 0
    local todayDate = getGameDate()
    for _, log in ipairs(oilLog) do
        if getGameDate(log.time) == todayDate then
            todayAll = todayAll + (log.money or 0)
            todayAZ = todayAZ + (log.az or 0)
        end
    end

    imgui.TextColored(imgui.ImVec4(0.5, 0.5, 0.5, 1), u8("Доход за день"))
    imgui.Text(u8("Доход: ")); imgui.SameLine();
    imgui.TextColored(imgui.ImVec4(0.3, 1.0, 0.3, 1), formatNumber(todayAll) .. "$")
    imgui.Text(u8("AZ: ")); imgui.SameLine();
    imgui.TextColored(imgui.ImVec4(0.0, 0.8, 1.0, 1), formatNumber(todayAZ))

    imgui.Spacing()
    if settings.overlayStyle == 2 then imgui.Separator()
    else
        local cursorY = imgui.GetCursorPosY()
        local drawList2 = imgui.GetWindowDrawList()
        local winPos = imgui.GetWindowPos()
        local winSize = imgui.GetWindowSize()
        imgui.SetCursorPos(imgui.ImVec2(8, cursorY + 2))
        drawList2:AddLine(imgui.ImVec2(winPos.x + 8, winPos.y + cursorY + 2), imgui.ImVec2(winPos.x + winSize.x - 8, winPos.y + cursorY + 2), 0xFF2A2A2A, 1.0)
        imgui.SetCursorPos(imgui.ImVec2(8, cursorY + 8))
    end
    imgui.Spacing()

    imgui.TextColored(imgui.ImVec4(0.5, 0.5, 0.5, 1), u8("Доход за сессию"))
    imgui.Text(u8("Доход: ")); imgui.SameLine();
    imgui.TextColored(imgui.ImVec4(0.3, 1.0, 0.3, 1), formatNumber(oilSessionData.money) .. "$")
    imgui.Text(u8("AZ: ")); imgui.SameLine();
    imgui.TextColored(imgui.ImVec4(0.0, 0.8, 1.0, 1), formatNumber(oilSessionData.az))

    if settings.overlayTimerEnabled then
        imgui.SetCursorPosY(imgui.GetCursorPosY() + 4)
        imgui.Text(u8("Время работы: ")); imgui.SameLine();
        if overlayTimer.running then
            imgui.TextColored(imgui.ImVec4(0.3, 1.0, 1.0, 1), overlayTimer.displayedTime)
        else
            imgui.TextColored(imgui.ImVec4(0.6, 0.6, 0.6, 1), u8("00:00:00"))
        end
    end

    local pos, size = imgui.GetWindowPos(), imgui.GetWindowSize()
    if pos and pos.x > 0 and pos.y > 0 and (cfg.x ~= pos.x or cfg.y ~= pos.y or cfg.w ~= size.x or cfg.h ~= size.y) then
        cfg.x, cfg.y, cfg.w, cfg.h = pos.x, pos.y, size.x, size.y; saveOverlayConfig()
    end

    imgui.End()
    if isHovered then
        imgui.PopStyleVar()
    end
    imgui.PopStyleColor(5)
    imgui.PopStyleVar(2)
end
function drawGoalsTab()
    local drawList = imgui.GetWindowDrawList()
    local listW = imgui.GetWindowWidth() - 25
    local cardH = 38
    
    local function getCardColors(hovered)
        if useCustomTheme then
            return imVec4ToHex(hovered and CUSTOM_THEME.cardBgHovered or CUSTOM_THEME.cardBg),
                   imVec4ToHex(CUSTOM_THEME.cardBorder),
                   imVec4ToHex(CUSTOM_THEME.cardIcon),
                   imVec4ToHex(CUSTOM_THEME.cardTitle)
        else
            return (hovered and 0xFF222222 or 0xFF1A1A1A), 0xFF333333, 0xFF1AE591, 0xFF1AE591
        end
    end
    
    -- Цели Фермы
    local cardY = imgui.GetCursorScreenPos().y
    local cardX = imgui.GetCursorScreenPos().x
    local hovered = (imgui.GetMousePos().x >= cardX and imgui.GetMousePos().x <= cardX + listW and 
                    imgui.GetMousePos().y >= cardY and imgui.GetMousePos().y <= cardY + cardH)
    local bgCol, borderCol, iconCol, titleCol = getCardColors(hovered)
    drawList:AddRectFilled(imgui.ImVec2(cardX, cardY), imgui.ImVec2(cardX + listW, cardY + cardH), bgCol, 6)
    drawList:AddRect(imgui.ImVec2(cardX, cardY), imgui.ImVec2(cardX + listW, cardY + cardH), borderCol, 6, 15, 1.0)
    drawList:AddText(imgui.ImVec2(cardX + 10, cardY + (cardH - 14) / 2), iconCol, fa.ICON_LEAF)
    drawList:AddText(imgui.ImVec2(cardX + 35, cardY + (cardH - 14) / 2), titleCol, u8("Цели на сегодня (Ферма)"))
    imgui.SetCursorScreenPos(imgui.ImVec2(cardX, cardY))
    if not goalsExpandedFarm then goalsExpandedFarm = false end
    if imgui.InvisibleButton("##goals_farm", imgui.ImVec2(listW, cardH)) then goalsExpandedFarm = not goalsExpandedFarm end
    if goalsExpandedFarm then imgui.Spacing(); drawFarmGoals(); imgui.Spacing() end
    
    -- Цели Шахты
    cardY = imgui.GetCursorScreenPos().y; cardX = imgui.GetCursorScreenPos().x
    hovered = (imgui.GetMousePos().x >= cardX and imgui.GetMousePos().x <= cardX + listW and imgui.GetMousePos().y >= cardY and imgui.GetMousePos().y <= cardY + cardH)
    bgCol, borderCol, iconCol, titleCol = getCardColors(hovered)
    drawList:AddRectFilled(imgui.ImVec2(cardX, cardY), imgui.ImVec2(cardX + listW, cardY + cardH), bgCol, 6)
    drawList:AddRect(imgui.ImVec2(cardX, cardY), imgui.ImVec2(cardX + listW, cardY + cardH), borderCol, 6, 15, 1.0)
    drawList:AddText(imgui.ImVec2(cardX + 10, cardY + (cardH - 14) / 2), iconCol, fa.ICON_GAVEL)
    drawList:AddText(imgui.ImVec2(cardX + 35, cardY + (cardH - 14) / 2), titleCol, u8("Цели на сегодня (Шахта)"))
    imgui.SetCursorScreenPos(imgui.ImVec2(cardX, cardY))
    if not goalsExpandedMine then goalsExpandedMine = false end
    if imgui.InvisibleButton("##goals_mine", imgui.ImVec2(listW, cardH)) then goalsExpandedMine = not goalsExpandedMine end
    if goalsExpandedMine then imgui.Spacing(); drawMineGoals(); imgui.Spacing() end
    
    -- Цели Лесопилки
    cardY = imgui.GetCursorScreenPos().y; cardX = imgui.GetCursorScreenPos().x
    hovered = (imgui.GetMousePos().x >= cardX and imgui.GetMousePos().x <= cardX + listW and imgui.GetMousePos().y >= cardY and imgui.GetMousePos().y <= cardY + cardH)
    bgCol, borderCol, iconCol, titleCol = getCardColors(hovered)
    drawList:AddRectFilled(imgui.ImVec2(cardX, cardY), imgui.ImVec2(cardX + listW, cardY + cardH), bgCol, 6)
    drawList:AddRect(imgui.ImVec2(cardX, cardY), imgui.ImVec2(cardX + listW, cardY + cardH), borderCol, 6, 15, 1.0)
    drawList:AddText(imgui.ImVec2(cardX + 10, cardY + (cardH - 14) / 2), iconCol, fa.ICON_TREE)
    drawList:AddText(imgui.ImVec2(cardX + 35, cardY + (cardH - 14) / 2), titleCol, u8("Цели на сегодня (Лесопилка)"))
    imgui.SetCursorScreenPos(imgui.ImVec2(cardX, cardY))
    if not goalsExpandedSaw then goalsExpandedSaw = false end
    if imgui.InvisibleButton("##goals_saw", imgui.ImVec2(listW, cardH)) then goalsExpandedSaw = not goalsExpandedSaw end
    if goalsExpandedSaw then imgui.Spacing(); drawSawmillGoals(); imgui.Spacing() end
    
    imgui.Spacing(); imgui.Separator(); imgui.Spacing()
    
    -- Общие цели
    cardY = imgui.GetCursorScreenPos().y; cardX = imgui.GetCursorScreenPos().x
    hovered = (imgui.GetMousePos().x >= cardX and imgui.GetMousePos().x <= cardX + listW and imgui.GetMousePos().y >= cardY and imgui.GetMousePos().y <= cardY + cardH)
    bgCol, borderCol, iconCol, titleCol = getCardColors(hovered)
    drawList:AddRectFilled(imgui.ImVec2(cardX, cardY), imgui.ImVec2(cardX + listW, cardY + cardH), bgCol, 6)
    drawList:AddRect(imgui.ImVec2(cardX, cardY), imgui.ImVec2(cardX + listW, cardY + cardH), borderCol, 6, 15, 1.0)
    drawList:AddText(imgui.ImVec2(cardX + 10, cardY + (cardH - 14) / 2), iconCol, fa.ICON_BULLSEYE)
    drawList:AddText(imgui.ImVec2(cardX + 35, cardY + (cardH - 14) / 2), titleCol, u8("Общие цели"))
    imgui.SetCursorScreenPos(imgui.ImVec2(cardX, cardY))
    if not goalsExpandedGeneral then goalsExpandedGeneral = false end
    if imgui.InvisibleButton("##goals_general", imgui.ImVec2(listW, cardH)) then goalsExpandedGeneral = not goalsExpandedGeneral end
    if goalsExpandedGeneral then
        imgui.Spacing()
        local progress = settings.totalIncomeGoal > 0 and math.min(totalDailyIncome / settings.totalIncomeGoal, 1.0) or 0
        imgui.TextColored(imgui.ImVec4(1.0, 0.8, 0.2, 1), u8("Общий доход за сегодня:"))
        imgui.Spacing()
        imgui.Text(u8("Доход: ")); imgui.SameLine(); imgui.TextColored(imgui.ImVec4(0.3, 1.0, 0.3, 1), formatNumber(totalDailyIncome) .. "$")
        imgui.Text(u8("Цель: ")); imgui.SameLine(); imgui.TextColored(imgui.ImVec4(1.0, 0.8, 0.2, 1), formatNumber(settings.totalIncomeGoal) .. "$")
        imgui.ProgressBar(progress, imgui.ImVec2(-1, 20), u8(math.floor(progress * 100) .. "%"))
        if totalIncomeGoalReached then imgui.TextColored(imgui.ImVec4(0.3, 1.0, 0.3, 1), u8("Цель достигнута!")) end
        imgui.Spacing(); imgui.Separator(); imgui.Spacing()
        imgui.Text(u8("Настройка цели:")); imgui.PushItemWidth(250)
        if imgui.InputInt("##total_income_goal", totalGoalEdit, 100000, 1000000) then
            if totalGoalEdit.v >= 0 then settings.totalIncomeGoal = totalGoalEdit.v; totalIncomeGoalReached = false; saveTotalIncomeGoal() end
        end
        imgui.PopItemWidth(); imgui.Spacing()
        local btnW2 = (imgui.GetWindowWidth() - 25 - 8) / 2
        if StyleButton(u8("Сохранить цель"), nil, btnW2) then saveTotalIncomeGoal(); sampAddChatMessage(SCRIPT_PREFIX .. "Общая цель дохода сохранена!", SCRIPT_COLOR) end
        imgui.SameLine()
        if StyleButton(u8("Сбросить"), nil, btnW2) then totalIncomeGoalReached = false; totalDailyIncome = 0; totalIncomeCacheTime = 0; saveTotalIncomeGoal(); sampAddChatMessage(SCRIPT_PREFIX .. "Прогресс общей цели сброшен!", SCRIPT_COLOR) end
        imgui.Spacing()
    end
end
function drawAchievementsTab()
    imgui.TextColored(imgui.ImVec4(1.0, 0.8, 0.2, 1), u8("Достижения"))
    imgui.Separator()
    imgui.Spacing()
    
    local drawList = imgui.GetWindowDrawList()
    local listW = imgui.GetWindowWidth() - 25
    
    local categoryKeys = {"Все", "Ферма", "Шахта", "Лесопилка", "Item Market", "Общие"}
    local categoryNames = {u8("Все"), u8("Ферма"), u8("Шахта"), u8("Лесопилка"), u8("Item Market"), u8("Общие")}
    local catIcons = {fa.ICON_STAR, fa.ICON_LEAF, fa.ICON_GAVEL, fa.ICON_TREE, fa.ICON_SHOPPING_CART, fa.ICON_BULLSEYE}
    local btnW = (listW - 25) / 6
    for i, cat in ipairs(categoryNames) do
        if i > 1 then imgui.SameLine(0, 4) end
        if StyleButton(cat, catIcons[i], btnW, achCategoryFilter.v == i - 1) then
            achCategoryFilter.v = i - 1
        end
    end
    
    imgui.Spacing(); imgui.Separator(); imgui.Spacing()
    
    -- Статистика и радиальный прогресс
    local completedCount = 0
    local totalCount = 0
    for _, ach in ipairs(ACHIEVEMENTS) do
        if achCategoryFilter.v == 0 or ach.category == categoryKeys[achCategoryFilter.v + 1] then
            totalCount = totalCount + 1
            if ach.completed then completedCount = completedCount + 1 end
        end
    end
    local overallProgress = totalCount > 0 and (completedCount / totalCount) or 0
    
    local statCardH = 70
    local statY = imgui.GetCursorScreenPos().y
    local statX = imgui.GetCursorScreenPos().x
    
    drawList:AddRectFilled(imgui.ImVec2(statX, statY), imgui.ImVec2(statX + listW, statY + statCardH), 0xFF141414, 8)
    drawList:AddRect(imgui.ImVec2(statX, statY), imgui.ImVec2(statX + listW, statY + statCardH), 0xFF2A2A2A, 8, 15, 1.0)
    
    local ringCenter = imgui.ImVec2(statX + 35, statY + statCardH / 2)
    local ringRadius = 24; local ringThickness = 5
    
    drawList:AddCircle(ringCenter, ringRadius, 0xFF2A2A2A, 64, ringThickness)
    if overallProgress > 0 then
        local numSegments = 64
        local filledSegments = math.floor(overallProgress * numSegments)
        local startAngle = -math.pi / 2
        for i = 0, filledSegments - 1 do
            local a1 = startAngle + (i / numSegments) * 2 * math.pi
            local a2 = startAngle + ((i + 1) / numSegments) * 2 * math.pi
            drawList:AddLine(imgui.ImVec2(ringCenter.x + math.cos(a1) * ringRadius, ringCenter.y + math.sin(a1) * ringRadius),
                             imgui.ImVec2(ringCenter.x + math.cos(a2) * ringRadius, ringCenter.y + math.sin(a2) * ringRadius), 0xFF1AE591, ringThickness)
        end
    end
    
    local pctText = math.floor(overallProgress * 100) .. "%"
    local pctSz = imgui.CalcTextSize(pctText)
    drawList:AddText(imgui.ImVec2(ringCenter.x - pctSz.x / 2, ringCenter.y - pctSz.y / 2), 0xFF1AE591, pctText)
    
    local textX = statX + 75
    drawList:AddText(imgui.ImVec2(textX, statY + 12), 0xFFFFFFFF, u8("Выполнено: ") .. completedCount .. " / " .. totalCount)
    
    local catStats = {
        {name = u8("Ферма"), icon = fa.ICON_LEAF, catKey = "Ферма"},
        {name = u8("Шахта"), icon = fa.ICON_GAVEL, catKey = "Шахта"},
        {name = u8("Лесопилка"), icon = fa.ICON_TREE, catKey = "Лесопилка"},
        {name = u8("IM"), icon = fa.ICON_SHOPPING_CART, catKey = "Item Market"},
        {name = u8("Общие"), icon = fa.ICON_BULLSEYE, catKey = "Общие"},
    }
    local miniBarX = textX + imgui.CalcTextSize(u8("Выполнено: 00 / 00")).x + 30
    local miniBarW = (listW - (miniBarX - statX) - 40) / 5
    for i, cs in ipairs(catStats) do
        local catComp = 0; local catTot = 0
        for _, ach in ipairs(ACHIEVEMENTS) do
            if ach.category == cs.catKey then
                catTot = catTot + 1
                if ach.completed then catComp = catComp + 1 end
            end
        end
        local catPct = catTot > 0 and (catComp / catTot) or 0
        local bx = miniBarX + (i - 1) * (miniBarW + 6); local by = statY + 12
        drawList:AddText(imgui.ImVec2(bx, by), 0xFF888888, cs.icon)
        drawList:AddRectFilled(imgui.ImVec2(bx + 16, by + 16), imgui.ImVec2(bx + 16 + miniBarW - 20, by + 22), 0xFF1E1E1E, 3)
        drawList:AddRectFilled(imgui.ImVec2(bx + 16, by + 16), imgui.ImVec2(bx + 16 + (miniBarW - 20) * catPct, by + 22), 0xFF1AE591, 3)
        local miniPct = math.floor(catPct * 100) .. "%"; local miniPctW = imgui.CalcTextSize(miniPct).x
        drawList:AddText(imgui.ImVec2(bx + 16 + miniBarW / 2 - miniPctW / 2 - 10, by + 25), 0xFF888888, miniPct)
    end
    
    imgui.SetCursorScreenPos(imgui.ImVec2(statX, statY + statCardH))
    imgui.Dummy(imgui.ImVec2(listW, 0))
    imgui.Spacing(); imgui.Separator(); imgui.Spacing()
    
    -- Сетка достижений
    local filteredAch = {}
    for _, ach in ipairs(ACHIEVEMENTS) do
        if achCategoryFilter.v == 0 or ach.category == categoryKeys[achCategoryFilter.v + 1] then
            table.insert(filteredAch, ach)
        end
    end
    table.sort(filteredAch, function(a, b)
        if a.completed ~= b.completed then return a.completed end
        return (a.progress / a.target) > (b.progress / a.target)
    end)
    
    local gridCols = 2
    local gridGap = 6
    local cardW = (listW - gridGap) / gridCols
    local cardH = 72
    
    local gridStartY = imgui.GetCursorScreenPos().y
    local gridRow = 0
    local gridCol = 0
    
    for _, ach in ipairs(filteredAch) do
        local cardX = statX + gridCol * (cardW + gridGap)
        local cardY = gridStartY + gridRow * (cardH + gridGap)
        
        local progress = ach.completed and 1.0 or math.min(ach.progress / ach.target, 1.0)
        
        local cardBg = ach.completed and 0xFF1A2E1A or 0xFF1A1A1A
        local borderCol = ach.completed and 0xFF2A5A2A or 0xFF2A2A2A
        drawList:AddRectFilled(imgui.ImVec2(cardX, cardY), imgui.ImVec2(cardX + cardW, cardY + cardH), cardBg, 6)
        drawList:AddRect(imgui.ImVec2(cardX, cardY), imgui.ImVec2(cardX + cardW, cardY + cardH), borderCol, 6, 15, 1.0)
        
        local iconCol = ach.completed and 0xFF1AE591 or 0xFF555555
        drawList:AddText(imgui.ImVec2(cardX + 8, cardY + 6), iconCol, ach.icon)
        
        local nameText = u8(ach.name)
        local nameMaxW = cardW - 75
        if imgui.CalcTextSize(nameText).x > nameMaxW then
            while imgui.CalcTextSize(nameText .. "...").x > nameMaxW and #nameText > 1 do
                nameText = nameText:sub(1, -2)
            end
            nameText = nameText .. "..."
        end
        drawList:AddText(imgui.ImVec2(cardX + 30, cardY + 6), iconCol, nameText)
        
        local descText = u8(ach.desc)
        local descMaxW = cardW - 16
        if imgui.CalcTextSize(descText).x > descMaxW then
            while imgui.CalcTextSize(descText .. "...").x > descMaxW and #descText > 1 do
                descText = descText:sub(1, -2)
            end
            descText = descText .. "..."
        end
        drawList:AddText(imgui.ImVec2(cardX + 8, cardY + 24), 0xFF777777, descText)
        
        local barY = cardY + 46
        local barH = 5
        drawList:AddRectFilled(imgui.ImVec2(cardX + 8, barY), imgui.ImVec2(cardX + cardW - 8, barY + barH), 0xFF1E1E1E, 3)
        if progress > 0 then
            drawList:AddRectFilled(imgui.ImVec2(cardX + 8, barY), imgui.ImVec2(cardX + 8 + (cardW - 16) * progress, barY + barH), 0xFF1AE591, 3)
        end
        
        local progText
        if ach.completed then progText = u8("[OK]")
        elseif ach.id:find("_goal$") then progText = ach.progress .. "/" .. ach.target
        elseif ach.id:find("_collector$") then progText = formatNumber(ach.progress) .. "/" .. formatNumber(ach.target)
        else progText = math.floor(progress * 100) .. "%" end
        local progW = imgui.CalcTextSize(progText).x
        drawList:AddText(imgui.ImVec2(cardX + cardW - progW - 8, barY + barH + 2), 0xFF888888, progText)
        
        local resetX = cardX + cardW - 20; local resetY = cardY + 3
        local resetHovered = (imgui.GetMousePos().x >= resetX and imgui.GetMousePos().x <= resetX + 16 and imgui.GetMousePos().y >= resetY and imgui.GetMousePos().y <= resetY + 16)
        if resetHovered then drawList:AddRectFilled(imgui.ImVec2(resetX, resetY), imgui.ImVec2(resetX + 16, resetY + 16), 0xFF3A3A3A, 3) end
        drawList:AddText(imgui.ImVec2(resetX + 1, resetY), resetHovered and 0xFFFFFFFF or 0xFF444444, fa.ICON_REPEAT)
        imgui.SetCursorScreenPos(imgui.ImVec2(resetX, resetY))
        if imgui.InvisibleButton("##reset_ach_" .. ach.id, imgui.ImVec2(16, 16)) then
            ach.progress = 0; ach.completed = false
            saveAchievements()
        end
        
        gridCol = gridCol + 1
        if gridCol >= gridCols then gridCol = 0; gridRow = gridRow + 1 end
    end
    
    local totalRows = gridRow + (gridCol > 0 and 1 or 0)
    imgui.SetCursorScreenPos(imgui.ImVec2(statX, gridStartY + totalRows * (cardH + gridGap) + 8))
    imgui.Dummy(imgui.ImVec2(listW, 0))
end
function drawAboutTab()
    local drawList = imgui.GetWindowDrawList()
    local listW = imgui.GetWindowWidth() - 25
    
    local cardY = imgui.GetCursorScreenPos().y
    local cardX = imgui.GetCursorScreenPos().x
    local cardH = 55
    drawList:AddRectFilled(imgui.ImVec2(cardX, cardY), imgui.ImVec2(cardX + listW, cardY + cardH), 0xFF1A1A1A, 8)
    drawList:AddRect(imgui.ImVec2(cardX, cardY), imgui.ImVec2(cardX + listW, cardY + cardH), 0xFF333333, 8, 15, 1.0)
    drawList:AddText(imgui.ImVec2(cardX + 15, cardY + 10), 0xFF1AE591, fa.ICON_USER)
    drawList:AddText(imgui.ImVec2(cardX + 40, cardY + 10), 0xFFFFFFFF, u8("Разработчик: Ryder_Nakata [31]"))
    drawList:AddText(imgui.ImVec2(cardX + 15, cardY + 30), 0xFF888888, u8("Resource Helper v" .. scr.version .. "  •  Arizona RP"))
    imgui.Dummy(imgui.ImVec2(listW, cardH + 6))
    
    local btnW = (listW - 14) / 4
    
    -- Telegram
    local tgPos = imgui.GetCursorScreenPos()
    if StyleButton("Telegram", fa.ICON_PAPER_PLANE, btnW) then
        shell32.ShellExecuteA(nil, "open", "https://t.me/RyderNakata", nil, nil, 0)
    end
    if imgui.IsItemHovered() then
        imgui.BeginTooltip()
        imgui.Text(u8("Связь в случае возникновения проблем или для предложений."))
        imgui.EndTooltip()
    end
    imgui.SameLine()
    
    -- VK
    if StyleButton("VK", fa.ICON_VK, btnW) then
        shell32.ShellExecuteA(nil, "open", "https://vk.com/ryder.nakata", nil, nil, 0)
    end
    if imgui.IsItemHovered() then
        imgui.BeginTooltip()
        imgui.Text(u8("Альтернативная связь в случае возникновения проблем или для предложений."))
        imgui.EndTooltip()
    end
    imgui.SameLine()
    
    -- BlastHack
    if StyleButton("BlastHack", fa.ICON_COMMENT, btnW) then
        shell32.ShellExecuteA(nil, "open", "https://www.blast.hk/threads/254420/post-1678762", nil, nil, 0)
    end
    if imgui.IsItemHovered() then
        imgui.BeginTooltip()
        imgui.Text(u8("Основная тема со всем функционалом. Буду рад лайку и коменту в теме для продвижения."))
        imgui.EndTooltip()
    end
    imgui.SameLine()
    
    -- GitHub
    if StyleButton("GitHub", fa.ICON_GITHUB, btnW) then
        shell32.ShellExecuteA(nil, "open", "https://github.com/Ryder8471/ArzResHelper", nil, nil, 0)
    end
    if imgui.IsItemHovered() then
        imgui.BeginTooltip()
        imgui.Text(u8("Основные файлы и все новые версии."))
        imgui.EndTooltip()
    end
    
	imgui.Spacing()
    imgui.Separator()
    imgui.Spacing()
	
    if newversion ~= "" and newversion ~= scr.version then
        imgui.Spacing()
        imgui.Separator()
        imgui.Spacing()
        imgui.TextColored(imgui.ImVec4(1.0, 0.8, 0.2, 1), u8("Доступна версия v" .. newversion))
        if StyleButton(fa.ICON_DIAMOND .. u8(" Обновить до v" .. newversion), nil, listW) then updateScript() end
    end
    
    imgui.Spacing()
    if StyleButton(u8("Список изменений"), fa.ICON_LIST, listW) then
        downloadChangelog()
        sampAddChatMessage(SCRIPT_PREFIX .. "Загружаю список изменений...", SCRIPT_COLOR)
    end
    imgui.Spacing()
    
    if changelogData then
        local sortedVersions = {}
        for ver, _ in pairs(changelogData) do table.insert(sortedVersions, ver) end
        table.sort(sortedVersions, function(a, b) return a > b end)
        
        for _, ver in ipairs(sortedVersions) do
            local isNewest = (ver == scr.version)
            local label = "v" .. ver .. (isNewest and " (текущая)" or "")
            local cY = imgui.GetCursorScreenPos().y; local cX = imgui.GetCursorScreenPos().x; local cH = 36
            local hovered = (imgui.GetMousePos().x >= cX and imgui.GetMousePos().x <= cX + listW and imgui.GetMousePos().y >= cY and imgui.GetMousePos().y <= cY + cH)
            drawList:AddRectFilled(imgui.ImVec2(cX, cY), imgui.ImVec2(cX + listW, cY + cH), hovered and 0xFF222222 or 0xFF1A1A1A, 6)
            drawList:AddRect(imgui.ImVec2(cX, cY), imgui.ImVec2(cX + listW, cY + cH), 0xFF333333, 6, 15, 1.0)
            drawList:AddText(imgui.ImVec2(cX + 10, cY + 9), isNewest and 0xFF1AE591 or 0xFFFFCC00, fa.ICON_STAR)
            drawList:AddText(imgui.ImVec2(cX + 35, cY + 9), isNewest and 0xFF1AE591 or 0xFFFFCC00, u8(label))
            imgui.SetCursorScreenPos(imgui.ImVec2(cX, cY))
            if not changelogExpanded then changelogExpanded = {} end
            if changelogExpanded[ver] == nil then changelogExpanded[ver] = false end
            if imgui.InvisibleButton("##changelog_" .. ver, imgui.ImVec2(listW, cH)) then changelogExpanded[ver] = not changelogExpanded[ver] end
            if changelogExpanded[ver] then
                imgui.Spacing()
                for _, change in ipairs(changelogData[ver]) do
                    imgui.Bullet(); imgui.SameLine(); imgui.PushTextWrapPos()
                    imgui.TextWrapped(u8(change))
                    imgui.PopTextWrapPos()
                end
                imgui.Spacing()
            end
        end
    end
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
function drawFarmOverlay()
    local cfg = overlayConfigs[WORK_TYPES.FARM]
    imgui.SetNextWindowPos(imgui.ImVec2(cfg.x, cfg.y), imgui.Cond.FirstUseEver)
    imgui.SetNextWindowSize(imgui.ImVec2(cfg.w, cfg.h), imgui.Cond.FirstUseEver)
    
    imgui.PushStyleVar(imgui.StyleVar.WindowRounding, settings.overlayStyle == 2 and 8 or 0)
    imgui.PushStyleVar(imgui.StyleVar.WindowPadding, imgui.ImVec2(8, 6))
    if settings.overlayStyle == 2 then
        imgui.PushStyleColor(imgui.Col.Border, imgui.ImVec4(0.12, 0.12, 0.12, 1.0))
        imgui.PushStyleColor(imgui.Col.WindowBg, imgui.ImVec4(0.08, 0.08, 0.08, 0.94))
    else
        imgui.PushStyleColor(imgui.Col.Border, imgui.ImVec4(0, 0, 0, 0))
        imgui.PushStyleColor(imgui.Col.WindowBg, imgui.ImVec4(0, 0, 0, 0))
    end
    imgui.PushStyleColor(imgui.Col.ResizeGrip, imgui.ImVec4(0, 0, 0, 0))
    imgui.PushStyleColor(imgui.Col.ResizeGripHovered, imgui.ImVec4(0, 0, 0, 0))
    imgui.PushStyleColor(imgui.Col.ResizeGripActive, imgui.ImVec4(0, 0, 0, 0))
    
    local isHovered = settings.overlayHideOnHover and isMouseOverOverlay(cfg)
    if isHovered then
        imgui.PushStyleVar(imgui.StyleVar.Alpha, 0.0)
    end
    
    imgui.Begin(u8("Добыча за сегодня (Ферма)"), true, imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoTitleBar)
    
    if settings.overlayStyle == 2 then
        imgui.SetCursorPos(imgui.ImVec2(8, 8))
    else
        local winPos = imgui.GetWindowPos()
        local winSize = imgui.GetWindowSize()
        local drawList = imgui.GetWindowDrawList()
        drawList:AddRectFilled(winPos, imgui.ImVec2(winPos.x + winSize.x, winPos.y + winSize.y), 0xFF141414)
        drawList:AddRectFilled(winPos, imgui.ImVec2(winPos.x + winSize.x, winPos.y + 22), 0xFF0E0E0E)
        local titleText = u8("Ферма")
        local titleWidth = imgui.CalcTextSize(titleText).x
        drawList:AddText(imgui.ImVec2(winPos.x + (winSize.x - titleWidth) / 2, winPos.y + 3), 0xFF1AE591, titleText)
        drawList:AddLine(imgui.ImVec2(winPos.x, winPos.y + 22), imgui.ImVec2(winPos.x + winSize.x, winPos.y + 22), 0xFF2A2A2A, 1.0)
        imgui.SetCursorPos(imgui.ImVec2(8, 28))
    end
    
    if currentWork == WORK_TYPES.FARM then
        local useSession = overlaySessionActive[WORK_TYPES.FARM]
        local displayData = useSession and overlaySessionResources[WORK_TYPES.FARM] or getTodayStats()
        local todayTotal = 0
        for _, k in ipairs(config.resourceOrder) do
            local price = getPriceForResource(k, WORK_TYPES.FARM)
            todayTotal = todayTotal + ((displayData[k] or 0) * price)
        end
        for _, k in ipairs(config.resourceOrder) do 
            imgui.Text(u8(config.resourceNames[k] .. ": ")); imgui.SameLine(); 
            imgui.TextColored(imgui.ImVec4(1.0, 0.8, 0.2, 1), formatNumber(displayData[k] or 0)) 
        end
        imgui.Spacing()
        if settings.overlayStyle == 2 then imgui.Separator()
        else
            local cursorY = imgui.GetCursorPosY()
            local drawList = imgui.GetWindowDrawList()
            local winPos = imgui.GetWindowPos()
            local winSize = imgui.GetWindowSize()
            imgui.SetCursorPos(imgui.ImVec2(8, cursorY + 2))
            drawList:AddLine(imgui.ImVec2(winPos.x + 8, winPos.y + cursorY + 2), imgui.ImVec2(winPos.x + winSize.x - 8, winPos.y + cursorY + 2), 0xFF2A2A2A, 1.0)
            imgui.SetCursorPos(imgui.ImVec2(8, cursorY + 8))
        end
        imgui.Text(u8("Доход: ")); imgui.SameLine(); 
        imgui.TextColored(imgui.ImVec4(0.3, 1.0, 0.3, 1), formatNumber(todayTotal) .. "$")
        if settings.overlayTimerEnabled then
            imgui.SetCursorPosY(imgui.GetCursorPosY() + 4)
            imgui.Text(u8("Время работы: ")); imgui.SameLine(); 
            if overlayTimer.running then
                imgui.TextColored(imgui.ImVec4(0.3, 1.0, 1.0, 1), overlayTimer.displayedTime)
            else
                imgui.TextColored(imgui.ImVec4(0.6, 0.6, 0.6, 1), u8("00:00:00"))
            end
        end
    else 
        imgui.TextColored(imgui.ImVec4(0.6, 0.6, 0.6, 1), u8("Переключитесь на ферму")) 
    end
    
    local pos, size = imgui.GetWindowPos(), imgui.GetWindowSize()
    if pos and pos.x > 0 and pos.y > 0 and (cfg.x ~= pos.x or cfg.y ~= pos.y or cfg.w ~= size.x or cfg.h ~= size.y) then 
        cfg.x, cfg.y, cfg.w, cfg.h = pos.x, pos.y, size.x, size.y; saveOverlayConfig()
    end
    
    imgui.End()
    if isHovered then
        imgui.PopStyleVar()
    end
    imgui.PopStyleColor(5)
    imgui.PopStyleVar(2)
end
function drawMineOverlay()
    local cfg = overlayConfigs[WORK_TYPES.MINE]
    imgui.SetNextWindowPos(imgui.ImVec2(cfg.x, cfg.y), imgui.Cond.FirstUseEver)
    imgui.SetNextWindowSize(imgui.ImVec2(cfg.w, cfg.h), imgui.Cond.FirstUseEver)
    
    imgui.PushStyleVar(imgui.StyleVar.WindowRounding, settings.overlayStyle == 2 and 8 or 0)
    imgui.PushStyleVar(imgui.StyleVar.WindowPadding, imgui.ImVec2(8, 6))
    if settings.overlayStyle == 2 then
        imgui.PushStyleColor(imgui.Col.Border, imgui.ImVec4(0.12, 0.12, 0.12, 1.0))
        imgui.PushStyleColor(imgui.Col.WindowBg, imgui.ImVec4(0.08, 0.08, 0.08, 0.94))
    else
        imgui.PushStyleColor(imgui.Col.Border, imgui.ImVec4(0, 0, 0, 0))
        imgui.PushStyleColor(imgui.Col.WindowBg, imgui.ImVec4(0, 0, 0, 0))
    end
    imgui.PushStyleColor(imgui.Col.ResizeGrip, imgui.ImVec4(0, 0, 0, 0))
    imgui.PushStyleColor(imgui.Col.ResizeGripHovered, imgui.ImVec4(0, 0, 0, 0))
    imgui.PushStyleColor(imgui.Col.ResizeGripActive, imgui.ImVec4(0, 0, 0, 0))
    
    local isHovered = settings.overlayHideOnHover and isMouseOverOverlay(cfg)
    if isHovered then
        imgui.PushStyleVar(imgui.StyleVar.Alpha, 0.0)
    end
    
    imgui.Begin(u8("Добыча за сегодня (Шахта)"), true, imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoTitleBar)
    
    if settings.overlayStyle == 2 then imgui.SetCursorPos(imgui.ImVec2(8, 8))
    else
        local winPos = imgui.GetWindowPos(); local winSize = imgui.GetWindowSize()
        local drawList = imgui.GetWindowDrawList()
        drawList:AddRectFilled(winPos, imgui.ImVec2(winPos.x + winSize.x, winPos.y + winSize.y), 0xFF141414)
        drawList:AddRectFilled(winPos, imgui.ImVec2(winPos.x + winSize.x, winPos.y + 22), 0xFF0E0E0E)
        local titleText = u8("Шахта"); local titleWidth = imgui.CalcTextSize(titleText).x
        drawList:AddText(imgui.ImVec2(winPos.x + (winSize.x - titleWidth) / 2, winPos.y + 3), 0xFF1AE591, titleText)
        drawList:AddLine(imgui.ImVec2(winPos.x, winPos.y + 22), imgui.ImVec2(winPos.x + winSize.x, winPos.y + 22), 0xFF2A2A2A, 1.0)
        imgui.SetCursorPos(imgui.ImVec2(8, 28))
    end
    
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
                imgui.Text(u8(config.resourceNames[k] .. ": ")); imgui.SameLine(); 
                imgui.TextColored(imgui.ImVec4(1.0, 0.8, 0.2, 1), formatNumber(displayData[k] or 0))
            end
        else
            local contentWidth = imgui.GetWindowSize().x - 16; local colWidth = contentWidth / 2
            imgui.Columns(2, "overlay_mine_cols", false); imgui.SetColumnWidth(0, colWidth - 24)
            for _, k in ipairs(config.leftColumnOrder) do 
                imgui.Text(u8(config.resourceNames[k] .. ": ")); imgui.SameLine(); 
                imgui.TextColored(imgui.ImVec4(1.0, 0.8, 0.2, 1), formatNumber(displayData[k] or 0)); imgui.NextColumn() 
            end
            imgui.SetColumnWidth(1, colWidth + 20)
            for _, k in ipairs(config.rightColumnOrder) do 
                imgui.Text(u8(config.resourceNames[k] .. ": ")); imgui.SameLine(); 
                imgui.TextColored(imgui.ImVec4(1.0, 0.8, 0.2, 1), formatNumber(displayData[k] or 0)); imgui.NextColumn() 
            end
            imgui.Columns(1)
        end
        imgui.Spacing()
        if settings.overlayStyle == 2 then imgui.Separator()
        else
            local cursorY = imgui.GetCursorPosY(); local drawList = imgui.GetWindowDrawList()
            local winPos = imgui.GetWindowPos(); local winSize = imgui.GetWindowSize()
            imgui.SetCursorPos(imgui.ImVec2(8, cursorY + 2))
            drawList:AddLine(imgui.ImVec2(winPos.x + 8, winPos.y + cursorY + 2), imgui.ImVec2(winPos.x + winSize.x - 8, winPos.y + cursorY + 2), 0xFF2A2A2A, 1.0)
            imgui.SetCursorPos(imgui.ImVec2(8, cursorY + 8))
        end
        imgui.Text(u8("Доход: ")); imgui.SameLine(); 
        imgui.TextColored(imgui.ImVec4(0.3, 1.0, 0.3, 1), formatNumber(todayTotal) .. "$")
        if settings.overlayTimerEnabled then
            imgui.SetCursorPosY(imgui.GetCursorPosY() + 4)
            imgui.Text(u8("Время работы: ")); imgui.SameLine(); 
            if overlayTimer.running then imgui.TextColored(imgui.ImVec4(0.3, 1.0, 1.0, 1), overlayTimer.displayedTime)
            else imgui.TextColored(imgui.ImVec4(0.6, 0.6, 0.6, 1), u8("00:00:00")) end
        end
        if settings.mineSpawnTimerEnabled then
            if settings.overlayStyle == 2 then imgui.Separator()
            else
                local cursorY = imgui.GetCursorPosY(); local drawList = imgui.GetWindowDrawList()
                local winPos = imgui.GetWindowPos(); local winSize = imgui.GetWindowSize()
                imgui.SetCursorPos(imgui.ImVec2(8, cursorY + 2))
                drawList:AddLine(imgui.ImVec2(winPos.x + 8, winPos.y + cursorY + 2), imgui.ImVec2(winPos.x + winSize.x - 8, winPos.y + cursorY + 2), 0xFF2A2A2A, 1.0)
                imgui.SetCursorPos(imgui.ImVec2(8, cursorY + 8))
            end
            local stoneTimer, golemTimer = getSpawnTimers()
            if stoneTimer then
                local stoneMin = math.floor(stoneTimer / 60); local stoneSec = stoneTimer % 60
                imgui.Text(u8("До спавна камней: ")); imgui.SameLine()
                imgui.TextColored(imgui.ImVec4(1.0, 0.8, 0.2, 1), string.format("%02d:%02d", stoneMin, stoneSec))
            else imgui.TextColored(imgui.ImVec4(0.6, 0.6, 0.6, 1), u8("Шахта закрыта")) end
            if golemTimer then
                local golemMin = math.floor(golemTimer / 60); local golemSec = golemTimer % 60
                imgui.Text(u8("До спавна големов: ")); imgui.SameLine()
                imgui.TextColored(imgui.ImVec4(1.0, 0.8, 0.2, 1), string.format("%02d:%02d", golemMin, golemSec))
            end
        end
    else imgui.TextColored(imgui.ImVec4(0.6, 0.6, 0.6, 1), u8("Переключитесь на шахту")) end
    
    local pos, size = imgui.GetWindowPos(), imgui.GetWindowSize()
    if pos and pos.x > 0 and pos.y > 0 and (cfg.x ~= pos.x or cfg.y ~= pos.y or cfg.w ~= size.x or cfg.h ~= size.y) then 
        cfg.x, cfg.y, cfg.w, cfg.h = pos.x, pos.y, size.x, size.y; saveOverlayConfig()
    end
    imgui.End()
    if isHovered then
        imgui.PopStyleVar()
    end
    imgui.PopStyleColor(5)
    imgui.PopStyleVar(2)
end
function drawSawmillOverlay()
    local cfg = overlayConfigs[WORK_TYPES.SAWMILL]
    imgui.SetNextWindowPos(imgui.ImVec2(cfg.x, cfg.y), imgui.Cond.FirstUseEver)
    imgui.SetNextWindowSize(imgui.ImVec2(cfg.w, cfg.h), imgui.Cond.FirstUseEver)
    
    imgui.PushStyleVar(imgui.StyleVar.WindowRounding, settings.overlayStyle == 2 and 8 or 0)
    imgui.PushStyleVar(imgui.StyleVar.WindowPadding, imgui.ImVec2(8, 6))
    if settings.overlayStyle == 2 then
        imgui.PushStyleColor(imgui.Col.Border, imgui.ImVec4(0.12, 0.12, 0.12, 1.0))
        imgui.PushStyleColor(imgui.Col.WindowBg, imgui.ImVec4(0.08, 0.08, 0.08, 0.94))
    else
        imgui.PushStyleColor(imgui.Col.Border, imgui.ImVec4(0, 0, 0, 0))
        imgui.PushStyleColor(imgui.Col.WindowBg, imgui.ImVec4(0, 0, 0, 0))
    end
    imgui.PushStyleColor(imgui.Col.ResizeGrip, imgui.ImVec4(0, 0, 0, 0))
    imgui.PushStyleColor(imgui.Col.ResizeGripHovered, imgui.ImVec4(0, 0, 0, 0))
    imgui.PushStyleColor(imgui.Col.ResizeGripActive, imgui.ImVec4(0, 0, 0, 0))
    
    local isHovered = settings.overlayHideOnHover and isMouseOverOverlay(cfg)
    if isHovered then
        imgui.PushStyleVar(imgui.StyleVar.Alpha, 0.0)
    end
    
    imgui.Begin(u8("Добыча за сегодня (Лесопилка)"), true, imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoTitleBar)
    
    if settings.overlayStyle == 2 then imgui.SetCursorPos(imgui.ImVec2(8, 8))
    else
        local winPos = imgui.GetWindowPos(); local winSize = imgui.GetWindowSize()
        local drawList = imgui.GetWindowDrawList()
        drawList:AddRectFilled(winPos, imgui.ImVec2(winPos.x + winSize.x, winPos.y + winSize.y), 0xFF141414)
        drawList:AddRectFilled(winPos, imgui.ImVec2(winPos.x + winSize.x, winPos.y + 22), 0xFF0E0E0E)
        local titleText = u8("Лесопилка"); local titleWidth = imgui.CalcTextSize(titleText).x
        drawList:AddText(imgui.ImVec2(winPos.x + (winSize.x - titleWidth) / 2, winPos.y + 3), 0xFF1AE591, titleText)
        drawList:AddLine(imgui.ImVec2(winPos.x, winPos.y + 22), imgui.ImVec2(winPos.x + winSize.x, winPos.y + 22), 0xFF2A2A2A, 1.0)
        imgui.SetCursorPos(imgui.ImVec2(8, 28))
    end
    
    if currentWork == WORK_TYPES.SAWMILL then
        local useSession = overlaySessionActive[WORK_TYPES.SAWMILL]
        local displayData = useSession and overlaySessionResources[WORK_TYPES.SAWMILL] or getTodayStats()
        local todayTotal = 0
        for _, k in ipairs(config.resourceOrder) do
            local price = getPriceForResource(k, WORK_TYPES.SAWMILL)
            todayTotal = todayTotal + ((displayData[k] or 0) * price)
        end
        for _, k in ipairs(config.resourceOrder) do 
            imgui.Text(u8(config.resourceNames[k] .. ": ")); imgui.SameLine(); 
            imgui.TextColored(imgui.ImVec4(1.0, 0.8, 0.2, 1), formatNumber(displayData[k] or 0)) 
        end
        imgui.Spacing()
        if settings.overlayStyle == 2 then imgui.Separator()
        else
            local cursorY = imgui.GetCursorPosY(); local drawList = imgui.GetWindowDrawList()
            local winPos = imgui.GetWindowPos(); local winSize = imgui.GetWindowSize()
            imgui.SetCursorPos(imgui.ImVec2(8, cursorY + 2))
            drawList:AddLine(imgui.ImVec2(winPos.x + 8, winPos.y + cursorY + 2), imgui.ImVec2(winPos.x + winSize.x - 8, winPos.y + cursorY + 2), 0xFF2A2A2A, 1.0)
            imgui.SetCursorPos(imgui.ImVec2(8, cursorY + 8))
        end
        imgui.Text(u8("Доход: ")); imgui.SameLine(); 
        imgui.TextColored(imgui.ImVec4(0.3, 1.0, 0.3, 1), formatNumber(todayTotal) .. "$")
        if settings.overlayTimerEnabled then
            imgui.SetCursorPosY(imgui.GetCursorPosY() + 4)
            imgui.Text(u8("Время работы: ")); imgui.SameLine(); 
            if overlayTimer.running then imgui.TextColored(imgui.ImVec4(0.3, 1.0, 1.0, 1), overlayTimer.displayedTime)
            else imgui.TextColored(imgui.ImVec4(0.6, 0.6, 0.6, 1), u8("00:00:00")) end
        end
    else imgui.TextColored(imgui.ImVec4(0.6, 0.6, 0.6, 1), u8("Переключитесь на лесопилку")) end
    
    local pos, size = imgui.GetWindowPos(), imgui.GetWindowSize()
    if pos and pos.x > 0 and pos.y > 0 and (cfg.x ~= pos.x or cfg.y ~= pos.y or cfg.w ~= size.x or cfg.h ~= size.y) then 
        cfg.x, cfg.y, cfg.w, cfg.h = pos.x, pos.y, size.x, size.y; saveOverlayConfig()
    end
    imgui.End()
    if isHovered then
        imgui.PopStyleVar()
    end
    imgui.PopStyleColor(5)
    imgui.PopStyleVar(2)
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
function drawMainMenu()
    local theme
    if useCustomTheme then
        theme = CUSTOM_THEME
    else
        theme = THEME_CONFIGS[currentTheme] or THEME_CONFIGS[THEMES.DEFAULT]
    end
    if not theme then theme = THEME_CONFIGS[THEMES.DEFAULT] end
    
    -- Универсальная функция получения HEX-цвета
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
    
    -- Универсальная функция получения ImVec4 цвета
    function getColorVec4(colorValue)
        if useCustomTheme then
            return colorValue
        else
            if type(colorValue) == "number" then
                return hexToImVec4(colorValue)
            else
                return colorValue
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
            imgui.SetNextWindowSize(imgui.ImVec2(550, 450), imgui.Cond.FirstUseEver)
            imgui.OpenPopup(u8("Что нового?##changelog"))
        else
            downloadChangelog()
        end
    end
    if imgui.BeginPopupModal(u8("Что нового?##changelog"), nil, imgui.WindowFlags.NoResize) then
        local winWidth = imgui.GetWindowWidth()
        local headerText = u8("Обновление до версии " .. scr.version)
        local headerWidth = imgui.CalcTextSize(headerText).x
        imgui.SetCursorPosX((winWidth - headerWidth) / 2)
        imgui.Text(headerText)
        imgui.Separator()
        imgui.Spacing()
        imgui.BeginChild("##changelog_scroll", imgui.ImVec2(0, 320), true)
        if changelogData and changelogData[scr.version] then
            for _, change in ipairs(changelogData[scr.version]) do
                imgui.Bullet(); imgui.SameLine()
                imgui.PushTextWrapPos()
                imgui.TextWrapped(u8(change))
                imgui.PopTextWrapPos()
            end
        else
            imgui.Text(u8("Список изменений загружается..."))
        end
        imgui.EndChild()
        imgui.Spacing(); imgui.Separator(); imgui.Spacing()
        local btnW = 120
        imgui.SetCursorPosX((winWidth - btnW) / 2)
        if imgui.Button(u8("Понятно"), imgui.ImVec2(btnW, 25)) then
            markChangelogAsShown()
            imgui.CloseCurrentPopup()
        end
        imgui.EndPopup()
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
    
    drawList:AddRectFilled(winPos, imgui.ImVec2(winPos.x + winSize.x, winPos.y + winSize.y), getColorHex(theme.windowBg), 6)
    local leftPanelWidth = 190
    drawList:AddRectFilled(imgui.ImVec2(winPos.x, winPos.y), imgui.ImVec2(winPos.x + leftPanelWidth, winPos.y + winSize.y), getColorHex(theme.leftPanelBg), 6, 9)
    drawList:AddLine(imgui.ImVec2(winPos.x + leftPanelWidth, winPos.y), imgui.ImVec2(winPos.x + leftPanelWidth, winPos.y + winSize.y), getColorHex(theme.borderColor), 1.0)
    drawList:AddRectFilled(imgui.ImVec2(winPos.x + 6, winPos.y), imgui.ImVec2(winPos.x + leftPanelWidth, winPos.y + 45), getColorHex(theme.titleBg), 0, 0)
    drawList:AddRectFilled(imgui.ImVec2(winPos.x + leftPanelWidth, winPos.y), imgui.ImVec2(winPos.x + winSize.x - 6, winPos.y + 45), getColorHex(theme.rightTitleBg), 0, 6)
    drawList:AddLine(imgui.ImVec2(winPos.x + leftPanelWidth, winPos.y + 8), imgui.ImVec2(winPos.x + leftPanelWidth, winPos.y + 37), getColorHex(theme.borderColor), 1.0)
    
    local reloadX = winPos.x + winSize.x - 70; local reloadY = winPos.y + 10
    local reloadHovered = (imgui.GetMousePos().x >= reloadX and imgui.GetMousePos().x <= reloadX + 25 and imgui.GetMousePos().y >= reloadY and imgui.GetMousePos().y <= reloadY + 25)
    drawList:AddRectFilled(imgui.ImVec2(reloadX, reloadY), imgui.ImVec2(reloadX + 25, reloadY + 25), reloadHovered and 0xFF3A3A3A or 0xFF222222, 4)
    drawList:AddRect(imgui.ImVec2(reloadX, reloadY), imgui.ImVec2(reloadX + 25, reloadY + 25), 0xFF444444, 4, 15, 1.0)
    local reloadIconW = imgui.CalcTextSize(fa.ICON_REPEAT).x; local reloadIconH = imgui.CalcTextSize(fa.ICON_REPEAT).y
    drawList:AddText(imgui.ImVec2(reloadX + (25 - reloadIconW) / 2, reloadY + (25 - reloadIconH) / 2), reloadHovered and 0xFFFFFFFF or 0xFF888888, fa.ICON_REPEAT)
    imgui.SetCursorScreenPos(imgui.ImVec2(reloadX, reloadY))
    if imgui.InvisibleButton("##reload_btn", imgui.ImVec2(25, 25)) then consumeWindowMessage(true, false); showCursor(false); scr:reload() end
    
    local closeX = winPos.x + winSize.x - 35; local closeY = winPos.y + 10
    local closeHovered = (imgui.GetMousePos().x >= closeX and imgui.GetMousePos().x <= closeX + 25 and imgui.GetMousePos().y >= closeY and imgui.GetMousePos().y <= closeY + 25)
    drawList:AddRectFilled(imgui.ImVec2(closeX, closeY), imgui.ImVec2(closeX + 25, closeY + 25), closeHovered and 0xFF3A3A3A or 0xFF222222, 4)
    drawList:AddRect(imgui.ImVec2(closeX, closeY), imgui.ImVec2(closeX + 25, closeY + 25), 0xFF444444, 4, 15, 1.0)
    local closeIconW = imgui.CalcTextSize(fa.ICON_TIMES).x; local closeIconH = imgui.CalcTextSize(fa.ICON_TIMES).y
    drawList:AddText(imgui.ImVec2(closeX + (25 - closeIconW) / 2, closeY + (25 - closeIconH) / 2), closeHovered and 0xFFFFFFFF or 0xFF888888, fa.ICON_TIMES)
    imgui.SetCursorScreenPos(imgui.ImVec2(closeX, closeY))
    if imgui.InvisibleButton("##close_btn", imgui.ImVec2(25, 25)) then mainWin.v = false; imgui.ShowCursor = false end
    
    imgui.SetCursorPos(imgui.ImVec2(15, 15))
    imgui.TextColored(getColorVec4(theme.accent), fa.ICON_WRENCH .. "  Resource Helper")
    imgui.SetCursorPos(imgui.ImVec2(10, 40)); imgui.Separator(); imgui.Spacing()
    
    drawMenuButtons(winPos, winSize, leftPanelWidth, theme)
    drawRightPanelContent(winPos, leftPanelWidth, winSize, theme)
    
    -- Заголовок правой панели (САМЫЙ ПОСЛЕДНИЙ, поверх всего)
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
    }
    local headerText = menuIcons[currentTab] .. "  " .. menuTitles[currentTab]
    if useCustomTheme then
        drawList:AddText(imgui.ImVec2(winPos.x + leftPanelWidth + 20, winPos.y + 15), imVec4ToHex(theme.accent), headerText)
    else
        drawList:AddText(imgui.ImVec2(winPos.x + leftPanelWidth + 20, winPos.y + 15), 0xFF1AE591, headerText)
    end
    
    -- ====== Иконка профиля в шапке ======
    if not homeDashCache or os.clock() - homeDashCacheTime > 15 then
        refreshHomeDashboard()
    end
    if not lbEnabledCacheTime or os.clock() - lbEnabledCacheTime > 15 then
        lbEnabledCache = getLbEnabled()
        lbEnabledCacheTime = os.clock()
    end
    
    local tgOk = tgConfig.enabled and tgConfig.botToken ~= "" and tgConfig.chatId ~= ""
    local lbOk = lbEnabledCache
    
    local avatarCX = winPos.x + winSize.x - 94
    local avatarCY = winPos.y + 22
    local avatarR = 14
    local avatarHovered = imgui.IsMouseHoveringRect(imgui.ImVec2(avatarCX - avatarR, avatarCY - avatarR), imgui.ImVec2(avatarCX + avatarR, avatarCY + avatarR), false)
    avatarHoveredGlobal = avatarHovered
    
    local avatarBg = avatarHovered and getColorHex(theme.accent) or 0xFF2A2A2A
    drawList:AddCircleFilled(imgui.ImVec2(avatarCX, avatarCY), avatarR, avatarBg, 24)
    drawList:AddCircle(imgui.ImVec2(avatarCX, avatarCY), avatarR, 0xFF444444, 24, 1.0)
    local userIconSz = imgui.CalcTextSize(fa.ICON_USER)
    drawList:AddText(imgui.ImVec2(avatarCX - userIconSz.x / 2, avatarCY - userIconSz.y / 2), avatarHovered and 0xFF0A0A0A or 0xFFCCCCCC, fa.ICON_USER)
    
    local statusDotColor = (tgOk or lbOk) and 0xFF33CC66 or 0xFF666666
    drawList:AddCircleFilled(imgui.ImVec2(avatarCX + avatarR - 3, avatarCY + avatarR - 3), 4, 0xFF141414, 12)
    drawList:AddCircleFilled(imgui.ImVec2(avatarCX + avatarR - 3, avatarCY + avatarR - 3), 3, statusDotColor, 12)
    
    imgui.SetCursorScreenPos(imgui.ImVec2(avatarCX - avatarR, avatarCY - avatarR))
    if imgui.InvisibleButton("##profile_chip", imgui.ImVec2(avatarR * 2, avatarR * 2)) then
        profilePopupOpen = not profilePopupOpen
    end
    
    if windowAnimAlpha < 1.0 then
        local maskColor = applyAlpha(getColorHex(theme.windowBg), 1.0 - windowAnimAlpha)
        drawList:AddRectFilled(winPos, imgui.ImVec2(winPos.x + winSize.x, winPos.y + winSize.y), maskColor, 6)
    end
    
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
        {title = u8("Ферма"), icon = fa.ICON_LEAF, id = 2},
        {title = u8("Шахта"), icon = fa.ICON_GAVEL, id = 3},
        {title = u8("Лесопилка"), icon = fa.ICON_TREE, id = 4},
        {title = u8("Нефтевышки"), icon = fa.ICON_FIRE, id = 12},
        {title = u8("Сторонний доход"), icon = fa.ICON_SHOPPING_CART, id = 5},
        {header = u8("Функции:")},
        {title = u8("Настройки"), icon = fa.ICON_WRENCH, id = 10},
        {title = u8("Биндер"), icon = fa.ICON_KEYBOARD_O, id = 9},
        {title = u8("Цели"), icon = fa.ICON_BULLSEYE, id = 7},
    }
    
    local drawList = imgui.GetWindowDrawList()
    local topAreaEnd = winPos.y + 43
    local btnHeight = 38; local headerHeight = 16; local spacing = 1
    local actualBtnIdx = 0; local headerOffset = 0
    
    local targetHighlightY = nil
    for idx, item in ipairs(menuItems) do
        if item.header then
            headerOffset = headerOffset + headerHeight + 6
        else
            local btnPosY = topAreaEnd + actualBtnIdx * (btnHeight + spacing) + headerOffset
            if item.id == currentTab then targetHighlightY = btnPosY end
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
        drawList:AddRectFilled(imgui.ImVec2(hlX, menuHighlightY), imgui.ImVec2(hlX + 178, menuHighlightY + btnHeight), imVec4ToHex(theme.buttonActive), 5)
        drawList:AddRect(imgui.ImVec2(hlX, menuHighlightY), imgui.ImVec2(hlX + 178, menuHighlightY + btnHeight), imVec4ToHex(theme.borderActive), 5, 15, 1.5)
    end
    
    actualBtnIdx = 0; headerOffset = 0
    for idx, item in ipairs(menuItems) do
        if item.header then
            local headerPosY = topAreaEnd + actualBtnIdx * (btnHeight + spacing) + headerOffset + 5
            drawList:AddText(imgui.ImVec2(winPos.x + 15, headerPosY), 0x55FFFFFF, item.header)
            headerOffset = headerOffset + headerHeight + 6
        else
            local isActive = (item.id == currentTab)
            local btnPosX = winPos.x + 7
            local btnPosY = topAreaEnd + actualBtnIdx * (btnHeight + spacing) + headerOffset
            local btnHovered = (imgui.GetMousePos().x >= btnPosX and imgui.GetMousePos().x <= btnPosX + 178 and imgui.GetMousePos().y >= btnPosY and imgui.GetMousePos().y <= btnPosY + btnHeight)
            
            if not isActive and btnHovered then
                drawList:AddRectFilled(imgui.ImVec2(btnPosX, btnPosY), imgui.ImVec2(btnPosX + 178, btnPosY + btnHeight), imVec4ToHex(theme.buttonHover), 5)
            end
            
            local textCol = theme.textNormal
            if isActive then textCol = theme.textActive elseif btnHovered then textCol = theme.textHover end
            local iconH = 14
            local textH = imgui.CalcTextSize(item.title).y
            drawList:AddText(imgui.ImVec2(btnPosX + 12, btnPosY + (btnHeight - iconH) / 2), imVec4ToHex(textCol), item.icon)
            drawList:AddText(imgui.ImVec2(btnPosX + 45, btnPosY + (btnHeight - textH) / 2), imVec4ToHex(textCol), item.title)
            
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
        drawList:AddText(imgui.ImVec2(winPos.x + 15, winPos.y + winSize.y - 40), 0xFF555555, "v" .. scr.version)
        drawList:AddText(imgui.ImVec2(winPos.x + 15, winPos.y + winSize.y - 25), 0xFF1AE591, u8("Есть обновление v") .. newversion)
    else
        drawList:AddText(imgui.ImVec2(winPos.x + 15, winPos.y + winSize.y - 25), 0xFF555555, "v" .. scr.version)
    end
end
function drawRightPanelContent(winPos, leftPanelWidth, winSize, theme)
    imgui.SetCursorPos(imgui.ImVec2(leftPanelWidth + 15, 55))
    local childX = winPos.x + leftPanelWidth + 15; local childY = winPos.y + 55
    local childW = winSize.x - leftPanelWidth - 30; local childH = winSize.y - 65
    imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(childX, childY), imgui.ImVec2(childX + childW, childY + childH), imVec4ToHex(theme.childBg), 4)
    imgui.BeginChild("right_panel", imgui.ImVec2(childW, childH), false, imgui.WindowFlags.NoScrollbar)
    
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
    elseif currentTab == 5 then drawItemMarketTab()
    elseif currentTab == 6 then drawLeaderboardTab()
    elseif currentTab == 7 then drawGoalsTab()
    elseif currentTab == 8 then drawAchievementsTab()
    elseif currentTab == 9 then drawBinderTab()
    elseif currentTab == 10 then drawSettingsTab()
    elseif currentTab == 11 then drawAboutTab()
    elseif currentTab == 12 then drawOilTab() end
    
    if rightPanelAlpha < 1.0 then
        local maskColor = applyAlpha(imVec4ToHex(theme.childBg), 1.0 - rightPanelAlpha)
        imgui.GetWindowDrawList():AddRectFilled(imgui.ImVec2(childX, childY), imgui.ImVec2(childX + childW, childY + childH), maskColor, 4)
    end
    
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
    
    local achCompleted, achTotal = 0, #ACHIEVEMENTS
    for _, ach in ipairs(ACHIEVEMENTS) do
        if ach.completed then achCompleted = achCompleted + 1 end
    end
    
    homeDashCache = {
        payday = paydayToday, paydayAZ = paydayAZToday,
        farm = farmToday, mine = mineToday, sawmill = sawmillToday, oil = oilToday, oilAZ = oilAZToday,
        other = rentToday + shardsToday + investToday,
        total = paydayToday + farmToday + mineToday + sawmillToday + oilToday + rentToday + shardsToday + investToday,
        totalAZ = paydayAZToday + oilAZToday,
        achCompleted = achCompleted, achTotal = achTotal,
    }
    homeDashCacheTime = os.clock()
end

function drawHomeTab()
    local drawList = imgui.GetWindowDrawList()
    local contentWidth = imgui.GetWindowWidth() - 10
    
    local function getCardColors()
        if useCustomTheme then
            return imVec4ToHex(CUSTOM_THEME.cardBg),
                   imVec4ToHex(CUSTOM_THEME.cardBorder),
                   imVec4ToHex(CUSTOM_THEME.cardIcon),
                   imVec4ToHex(CUSTOM_THEME.cardTitle)
        else
            return 0xFF1A1A1A, 0xFF333333, 0xFF1AE591, 0xFF1AE591
        end
    end
    
    if logoArz then
        local imgHeight = contentWidth * (195 / 750)
        imgui.SetCursorPosX(0)
        imgui.Image(logoArz, imgui.ImVec2(contentWidth, imgHeight))
    end
    imgui.Spacing()
    
    if not homeDashCache or os.clock() - homeDashCacheTime > 15 then
        refreshHomeDashboard()
    end
    local dash = homeDashCache
    local mp = imgui.GetMousePos()
    
    -- Крупная сводка дохода за сегодня
    local bigCardY = imgui.GetCursorScreenPos().y
    local bigCardX = imgui.GetCursorScreenPos().x
    local bigCardH = 46
    do
        local bgCol, borderCol = getCardColors()
        drawList:AddRectFilled(imgui.ImVec2(bigCardX, bigCardY), imgui.ImVec2(bigCardX + contentWidth, bigCardY + bigCardH), bgCol, 8)
        drawList:AddRect(imgui.ImVec2(bigCardX, bigCardY), imgui.ImVec2(bigCardX + contentWidth, bigCardY + bigCardH), borderCol, 8, 15, 1.2)

        local hasAZ = dash.totalAZ > 0
        local halfW = hasAZ and (contentWidth / 2) or contentWidth

        local incLabel = u8("Доход за сегодня")
        local incValue = formatNumber(dash.total) .. "$"
        local incLabelW = imgui.CalcTextSize(incLabel).x
        local incValueW = imgui.CalcTextSize(incValue).x
        drawList:AddText(imgui.ImVec2(bigCardX + (halfW - incLabelW) / 2, bigCardY + 6), 0xFF888888, incLabel)
        drawList:AddText(imgui.ImVec2(bigCardX + (halfW - incValueW) / 2, bigCardY + 24), 0xFF33DD77, incValue)

        if hasAZ then
            drawList:AddLine(imgui.ImVec2(bigCardX + halfW, bigCardY + 8), imgui.ImVec2(bigCardX + halfW, bigCardY + bigCardH - 8), borderCol, 1.0)

            local azLabel = u8("Заработано AZ")
            local azValue = "+" .. formatNumber(dash.totalAZ) .. " AZ"
            local azLabelW = imgui.CalcTextSize(azLabel).x
            local azValueW = imgui.CalcTextSize(azValue).x
            drawList:AddText(imgui.ImVec2(bigCardX + halfW + (halfW - azLabelW) / 2, bigCardY + 6), 0xFF888888, azLabel)
            drawList:AddText(imgui.ImVec2(bigCardX + halfW + (halfW - azValueW) / 2, bigCardY + 24), 0xFF00CCFF, azValue)
        end
    end
    imgui.SetCursorScreenPos(imgui.ImVec2(bigCardX, bigCardY + bigCardH))
    imgui.Dummy(imgui.ImVec2(contentWidth, 8))
    
    local tiles = {
        {label = u8("Пейдей"), value = dash.payday, az = dash.paydayAZ, icon = fa.ICON_MONEY, tab = nil},
        {label = u8("Ферма"), value = dash.farm, icon = fa.ICON_LEAF, tab = 2, workType = WORK_TYPES.FARM},
        {label = u8("Шахта"), value = dash.mine, icon = fa.ICON_GAVEL, tab = 3, workType = WORK_TYPES.MINE},
        {label = u8("Лесопилка"), value = dash.sawmill, icon = fa.ICON_TREE, tab = 4, workType = WORK_TYPES.SAWMILL},
        {label = u8("Нефтевышка"), value = dash.oil, az = dash.oilAZ, icon = fa.ICON_FIRE, tab = 12},
        {label = u8("Сторонний доход"), value = dash.other, icon = fa.ICON_SHOPPING_CART, tab = 5},
    }
    local tileCols = 3
    local tileSpacing = 6
    local tileW = (contentWidth - tileSpacing * (tileCols - 1)) / tileCols
    local tileH = 46
    local tileRows = math.ceil(#tiles / tileCols)
    local gridX = imgui.GetCursorScreenPos().x
    local gridY = imgui.GetCursorScreenPos().y
    for i, tile in ipairs(tiles) do
        local col = (i - 1) % tileCols
        local row = math.floor((i - 1) / tileCols)
        local tx = gridX + col * (tileW + tileSpacing)
        local ty = gridY + row * (tileH + tileSpacing)
        local hovered = tile.tab and (mp.x >= tx and mp.x <= tx + tileW and mp.y >= ty and mp.y <= ty + tileH)
        local tBg, tBorder = getCardColors()
        if hovered then tBg = 0xFF222222 end
        drawList:AddRectFilled(imgui.ImVec2(tx, ty), imgui.ImVec2(tx + tileW, ty + tileH), tBg, 6)
        drawList:AddRect(imgui.ImVec2(tx, ty), imgui.ImVec2(tx + tileW, ty + tileH), hovered and 0xFF1AE591 or tBorder, 6, 15, 1.0)
        local iconW = imgui.CalcTextSize(tile.icon).x
        drawList:AddText(imgui.ImVec2(tx + 10, ty + 8), 0xFF1AE591, tile.icon)
        drawList:AddText(imgui.ImVec2(tx + 14 + iconW, ty + 8), 0xFF888888, tile.label)
        local valueStr = formatNumber(tile.value) .. "$"
        if tile.az and tile.az > 0 then
            valueStr = valueStr .. " | " .. formatNumber(tile.az) .. " AZ"
        end
        drawList:AddText(imgui.ImVec2(tx + 10, ty + 26), 0xFFFFFFFF, valueStr)
        if tile.tab then
            imgui.SetCursorScreenPos(imgui.ImVec2(tx, ty))
            if imgui.InvisibleButton("##dash_tile_" .. i, imgui.ImVec2(tileW, tileH)) then
                if not scanState.active then
                    currentTab = tile.tab
                    if tile.workType then
                        switchWorkType(tile.workType); workTypeSelected = true
                        if not scannedThisSession[tile.workType] then pendingScan = tile.workType end
                    end
                end
            end
        end
    end
    local gridH = tileRows * tileH + (tileRows - 1) * tileSpacing
    imgui.SetCursorScreenPos(imgui.ImVec2(gridX, gridY + gridH))
    imgui.Dummy(imgui.ImVec2(contentWidth, 10))
    
    -- Ачивки - сводка одной строкой с прогресс-баром, клик открывает вкладку
    local achY = imgui.GetCursorScreenPos().y
    local achX = imgui.GetCursorScreenPos().x
    local achH = 40
    do
        local bgCol, borderCol = getCardColors()
        local achHovered = (mp.x >= achX and mp.x <= achX + contentWidth and mp.y >= achY and mp.y <= achY + achH)
        drawList:AddRectFilled(imgui.ImVec2(achX, achY), imgui.ImVec2(achX + contentWidth, achY + achH), achHovered and 0xFF222222 or bgCol, 8)
        drawList:AddRect(imgui.ImVec2(achX, achY), imgui.ImVec2(achX + contentWidth, achY + achH), achHovered and 0xFF1AE591 or borderCol, 8, 15, 1.0)
        drawList:AddText(imgui.ImVec2(achX + 14, achY + 12), 0xFF1AE591, fa.ICON_TROPHY)
        drawList:AddText(imgui.ImVec2(achX + 38, achY + 12), 0xFFFFFFFF, u8("Достижения: ") .. dash.achCompleted .. "/" .. dash.achTotal)
        local barW, barH = 140, 6
        local barX = achX + contentWidth - barW - 16
        local barY = achY + achH / 2 - barH / 2
        local progress = dash.achTotal > 0 and (dash.achCompleted / dash.achTotal) or 0
        drawList:AddRectFilled(imgui.ImVec2(barX, barY), imgui.ImVec2(barX + barW, barY + barH), 0xFF2A2A2A, barH / 2)
        drawList:AddRectFilled(imgui.ImVec2(barX, barY), imgui.ImVec2(barX + barW * progress, barY + barH), 0xFF1AE591, barH / 2)
    end
    imgui.SetCursorScreenPos(imgui.ImVec2(achX, achY))
    if imgui.InvisibleButton("##dash_achievements", imgui.ImVec2(contentWidth, achH)) then
        currentTab = 8
    end
    imgui.SetCursorScreenPos(imgui.ImVec2(achX, achY + achH))
    imgui.Dummy(imgui.ImVec2(contentWidth, 8))
    imgui.Spacing()
    
    local cardY = imgui.GetCursorScreenPos().y
    local cardX = imgui.GetCursorScreenPos().x
    local cardH = 50
    local bgCol, borderCol, iconCol, titleCol = getCardColors()
    drawList:AddRectFilled(imgui.ImVec2(cardX, cardY), imgui.ImVec2(cardX + contentWidth, cardY + cardH), bgCol, 8)
    drawList:AddRect(imgui.ImVec2(cardX, cardY), imgui.ImVec2(cardX + contentWidth, cardY + cardH), borderCol, 8, 15, 1.0)
    drawList:AddText(imgui.ImVec2(cardX + 15, cardY + 10), iconCol, fa.ICON_WRENCH)
    drawList:AddText(imgui.ImVec2(cardX + 40, cardY + 10), 0xFFFFFFFF, u8("Resource Helper v" .. scr.version))
    if config and config.name then
        drawList:AddText(imgui.ImVec2(cardX + 15, cardY + 30), titleCol, u8("Текущий режим: " .. config.name))
    else
        drawList:AddText(imgui.ImVec2(cardX + 15, cardY + 30), 0xFF888888, u8("Выберите режим работы в меню слева. Нажмите: Ферма, Шахта или Лесопилка чтобы начать работу."))
    end
    imgui.Dummy(imgui.ImVec2(contentWidth, cardH + 8))
    
    imgui.Spacing()
    
    cardY = imgui.GetCursorScreenPos().y
    cardX = imgui.GetCursorScreenPos().x
    local cardW = imgui.GetWindowWidth() - 10
    cardH = editingMenuKey and 54 or 38
    
    bgCol, borderCol, iconCol, titleCol = getCardColors()
    drawList:AddRectFilled(imgui.ImVec2(cardX, cardY), imgui.ImVec2(cardX + cardW, cardY + cardH), bgCol, 8)
    drawList:AddRect(imgui.ImVec2(cardX, cardY), imgui.ImVec2(cardX + cardW, cardY + cardH), editingMenuKey and 0xFF1AE591 or borderCol, 8, 15, 1.5)
    
    local contentCenterY = cardY + cardH / 2
    
    drawList:AddText(imgui.ImVec2(cardX + 15, contentCenterY - 8), iconCol, fa.ICON_KEYBOARD_O)
    drawList:AddText(imgui.ImVec2(cardX + 40, contentCenterY - 8), 0xFF888888, u8("Клавиша активации меню"))
    
    local keyNames = {}
    local currentKeys = editingMenuKey and menuKeyBuffer or settings.menuKey
    if currentKeys and #currentKeys > 0 then
        for _, key in ipairs(currentKeys) do
            table.insert(keyNames, vkeys.id_to_name(key))
        end
    end
    local keyStr = #keyNames > 0 and table.concat(keyNames, " + ") or u8("Не назначено")
    
    local btnW = imgui.CalcTextSize(keyStr).x + 24
    local btnH = 24
    local btnX = cardX + cardW - btnW - 12
    local btnY = contentCenterY - btnH / 2
    local btnHovered = (imgui.GetMousePos().x >= btnX and imgui.GetMousePos().x <= btnX + btnW and 
                       imgui.GetMousePos().y >= btnY and imgui.GetMousePos().y <= btnY + btnH)
    
    local btnBg = editingMenuKey and 0xFF1E3D1E or (btnHovered and 0xFF2A2A2A or 0xFF252525)
    local btnBorder = editingMenuKey and 0xFF1AE591 or (btnHovered and 0xFF555555 or 0xFF3A3A3A)
    local btnTextCol = editingMenuKey and 0xFF1AE591 or (btnHovered and 0xFFFFFFFF or 0xFFCCCCCC)
    
    drawList:AddRectFilled(imgui.ImVec2(btnX, btnY), imgui.ImVec2(btnX + btnW, btnY + btnH), btnBg, 4)
    drawList:AddRect(imgui.ImVec2(btnX, btnY), imgui.ImVec2(btnX + btnW, btnY + btnH), btnBorder, 4, 15, 1.5)
    
    local keyTextW = imgui.CalcTextSize(keyStr).x
    drawList:AddText(imgui.ImVec2(btnX + (btnW - keyTextW) / 2, btnY + 4), btnTextCol, keyStr)
    
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
        
        for vk, name in pairs(vkeys.key_names) do
            if type(vk) == "number" and wasKeyPressed(vk) then
                local alreadyExists = false
                for _, existing in ipairs(menuKeyBuffer) do
                    local isAlt1 = false; for _, av in ipairs(altVariants) do if vk == av then isAlt1 = true; break end end
                    local isAlt2 = false; for _, av in ipairs(altVariants) do if existing == av then isAlt2 = true; break end end
                    if isAlt1 and isAlt2 then alreadyExists = true; break end
                    
                    local isCtrl1 = false; for _, cv in ipairs(ctrlVariants) do if vk == cv then isCtrl1 = true; break end end
                    local isCtrl2 = false; for _, cv in ipairs(ctrlVariants) do if existing == cv then isCtrl2 = true; break end end
                    if isCtrl1 and isCtrl2 then alreadyExists = true; break end
                    
                    local isShift1 = false; for _, sv in ipairs(shiftVariants) do if vk == sv then isShift1 = true; break end end
                    local isShift2 = false; for _, sv in ipairs(shiftVariants) do if existing == sv then isShift2 = true; break end end
                    if isShift1 and isShift2 then alreadyExists = true; break end
                    
                    if vk == existing then alreadyExists = true; break end
                end
                
                if not alreadyExists then
                    table.insert(menuKeyBuffer, vk)
                end
            end
        end
        
        local sorted = {}
        for _, vk in ipairs(menuKeyBuffer) do
            local isCtrl = false; for _, cv in ipairs(ctrlVariants) do if vk == cv then isCtrl = true; break end end
            if isCtrl then table.insert(sorted, 17) end
        end
        for _, vk in ipairs(menuKeyBuffer) do
            local isAlt = false; for _, av in ipairs(altVariants) do if vk == av then isAlt = true; break end end
            if isAlt then table.insert(sorted, 18) end
        end
        for _, vk in ipairs(menuKeyBuffer) do
            local isShift = false; for _, sv in ipairs(shiftVariants) do if vk == sv then isShift = true; break end end
            if isShift then table.insert(sorted, 16) end
        end
        for _, vk in ipairs(menuKeyBuffer) do
            local isMod = false
            for _, cv in ipairs(ctrlVariants) do if vk == cv then isMod = true; break end end
            for _, av in ipairs(altVariants) do if vk == av then isMod = true; break end end
            for _, sv in ipairs(shiftVariants) do if vk == sv then isMod = true; break end end
            if not isMod then table.insert(sorted, vk) end
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
    end
    
    if editingMenuKey then
        local hintText = u8("Нажимайте клавиши, кликните вне поля для сохранения. Esc - отмена")
        drawList:AddText(imgui.ImVec2(cardX + 15, cardY + cardH - 18), 0xFF888888, hintText)
    end
    
imgui.SetCursorScreenPos(imgui.ImVec2(cardX, cardY + cardH))
    imgui.Dummy(imgui.ImVec2(cardW, 0))
end
function drawFarmTab()
    if not config then
        imgui.Text(u8("Сначала выберите режим работы (нажмите Ферма в меню слева)"))
        return
    end
    local drawList = imgui.GetWindowDrawList()
    local listW = imgui.GetWindowWidth() - 25
    
    -- Три раздела: Меню / Цены / Статистика
    if not farmSectionTab then farmSectionTab = imgui.ImInt(0) end
    local farmSectionNames = {u8("Меню"), u8("Цены"), u8("Статистика")}
    local farmSectionBtnW = (imgui.GetWindowWidth() - 25 - 8) / 3
    for i, name in ipairs(farmSectionNames) do
        if i > 1 then imgui.SameLine() end
        if StyleButton(name, nil, farmSectionBtnW, farmSectionTab.v == i - 1) then
            local prev = farmSectionTab.v
            farmSectionTab.v = i - 1
            if farmSectionTab.v == 1 and prev ~= 1 and not pricesLoading then loadGlobalPrices() end
        end
    end
    imgui.Spacing(); imgui.Separator(); imgui.Spacing()
    
    
    --  МЕНЮ
    
    if farmSectionTab.v == 0 then
        local scanColor, scanIcon, scanStatusText
        if scanState.active then
            scanColor = 0xFFFFCC33; scanIcon = fa.ICON_REFRESH; scanStatusText = u8("Сканирование: ") .. u8(scanState.statusText)
        elseif scannedThisSession[currentWork] then
            scanColor = 0xFF33CC66; scanIcon = fa.ICON_CHECK; scanStatusText = u8("Инвентарь отсканирован")
        else
            scanColor = 0xFFFF8833; scanIcon = fa.ICON_EXCLAMATION_TRIANGLE; scanStatusText = u8("Инвентарь не отсканирован")
        end
        
        local cardX = imgui.GetCursorScreenPos().x
        local cardY = imgui.GetCursorScreenPos().y
        local scanCardH = 56
        drawList:AddRectFilled(imgui.ImVec2(cardX, cardY), imgui.ImVec2(cardX + listW, cardY + scanCardH), 0xFF141414, 8)
        drawList:AddRect(imgui.ImVec2(cardX, cardY), imgui.ImVec2(cardX + listW, cardY + scanCardH), 0xFF2A2A2A, 8, 15, 1.0)
        drawList:AddText(imgui.ImVec2(cardX + 14, cardY + 10), scanColor, scanIcon)
        drawList:AddText(imgui.ImVec2(cardX + 38, cardY + 10), scanColor, scanStatusText)
        drawList:AddText(imgui.ImVec2(cardX + 14, cardY + 30), 0xFF666666, u8("Сканируй инвентарь перед началом сбора ресурсов"))
        
        imgui.SetCursorScreenPos(imgui.ImVec2(cardX, cardY + scanCardH + 8))
        local scanBtnText = scanState.active and u8("Сканирование...") or (scannedThisSession[currentWork] and u8("Пересканировать инвентарь") or u8("Сканировать инвентарь"))
        if scanState.active then
            imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.3, 0.3, 0.3, 0.5))
            imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.3, 0.3, 0.3, 0.5))
            imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.3, 0.3, 0.3, 0.5))
            StyleButton(scanBtnText, fa.ICON_SEARCH)
            imgui.PopStyleColor(3)
        else
            if StyleButton(scanBtnText, fa.ICON_SEARCH) then startInventoryScan() end
        end
        
        imgui.Spacing(); imgui.Separator(); imgui.Spacing()
        
        if ToggleSwitch(u8("Считать ресурсы с фермы"), cb_farm) then
            settings.farmEnabled = cb_farm.v; saveConfig(); needSave = true
        end
        if ToggleSwitch(u8("Показывать оверлей на экране"), cb_farm_overlay) then
            if cb_farm_overlay.v then
                settings.farmOverlayEnabled = true
                settings.mineOverlayEnabled = false
                settings.sawmillOverlayEnabled = false
                settings.oilOverlayEnabled = false
                cb_mine_overlay.v = false
                cb_sawmill_overlay.v = false
                cb_oil_overlay.v = false
                if settings.overlayAutoTimer and not overlayTimer.running then
                    overlayTimer.running = true; overlayTimer.startTime = os.time()
                    overlayTimer.elapsed = 0; overlayTimer.displayedTime = "00:00:00"
                end
            else
                settings.farmOverlayEnabled = false
            end
            saveConfig()
        end
        
        imgui.Spacing(); imgui.Separator(); imgui.Spacing()
        
        -- Быстрый итог за сегодня (раскрывающийся)
        if not farmExpandIncome then farmExpandIncome = false end
        local todayData = getTodayStats()
        local todayTotal = 0
        for _, k in ipairs(config.resourceOrder) do
            todayTotal = todayTotal + ((todayData[k] or 0) * getPriceForResource(k, WORK_TYPES.FARM))
        end
        local todayCardX = imgui.GetCursorScreenPos().x
        local todayCardY = imgui.GetCursorScreenPos().y
        local todayCardH = 50
        local incomeHovered = (imgui.GetMousePos().x >= todayCardX and imgui.GetMousePos().x <= todayCardX + listW and imgui.GetMousePos().y >= todayCardY and imgui.GetMousePos().y <= todayCardY + todayCardH)
        drawList:AddRectFilled(imgui.ImVec2(todayCardX, todayCardY), imgui.ImVec2(todayCardX + listW, todayCardY + todayCardH), incomeHovered and 0xFF1E1E1E or 0xFF141414, 8)
        drawList:AddRect(imgui.ImVec2(todayCardX, todayCardY), imgui.ImVec2(todayCardX + listW, todayCardY + todayCardH), farmExpandIncome and 0xFF1AE591 or 0xFF2A2A2A, 8, 15, farmExpandIncome and 2.0 or 1.0)
        drawList:AddText(imgui.ImVec2(todayCardX + 14, todayCardY + 8), 0xFF888888, u8("Доход за сегодня"))
        drawList:AddText(imgui.ImVec2(todayCardX + 14, todayCardY + 26), 0xFF33CC66, formatNumber(todayTotal) .. "$")
        local incomeArrow = farmExpandIncome and fa.ICON_ANGLE_UP or fa.ICON_ANGLE_DOWN
        local incomeArrowW = imgui.CalcTextSize(incomeArrow).x
        drawList:AddText(imgui.ImVec2(todayCardX + listW - incomeArrowW - 14, todayCardY + 26), 0xFF888888, incomeArrow)
        imgui.SetCursorScreenPos(imgui.ImVec2(todayCardX, todayCardY))
        if imgui.InvisibleButton("##farm_expand_income", imgui.ImVec2(listW, todayCardH)) then
            farmExpandIncome = not farmExpandIncome
        end
        imgui.SetCursorScreenPos(imgui.ImVec2(todayCardX, todayCardY + todayCardH))
        imgui.Dummy(imgui.ImVec2(listW, 0))
        
        if farmExpandIncome then
            imgui.Spacing()
            local tPos = imgui.GetCursorScreenPos()
            local tableWidth2 = imgui.GetWindowWidth() - 25
            local rowH2 = 24; local rows2 = #config.resourceOrder
            
            drawList:AddRectFilled(tPos, imgui.ImVec2(tPos.x + tableWidth2, tPos.y + rows2 * rowH2 + 4), 0xFF141414, 8)
            drawList:AddRect(tPos, imgui.ImVec2(tPos.x + tableWidth2, tPos.y + rows2 * rowH2 + 4), 0xFF2A2A2A, 8, 15, 1.0)
            
            for i, k in ipairs(config.resourceOrder) do
                local y = tPos.y + (i - 1) * rowH2
                local rowBgColor = (i % 2 == 0) and 0xFF1E1E1E or 0xFF181818
                drawList:AddRectFilled(imgui.ImVec2(tPos.x + 2, y + 1), imgui.ImVec2(tPos.x + tableWidth2 - 2, y + rowH2 - 1), rowBgColor)
                drawList:AddText(imgui.ImVec2(tPos.x + 12, y + 4), 0xFFCCCCCC, u8(config.resourceNames[k]))
                local amtStr = formatNumber(todayData[k] or 0); local amtW = imgui.CalcTextSize(amtStr).x
                drawList:AddText(imgui.ImVec2(tPos.x + tableWidth2 - amtW - 12, y + 4), 0xFFFFCC00, amtStr)
            end
            
            imgui.SetCursorScreenPos(imgui.ImVec2(tPos.x, tPos.y + rows2 * rowH2 + 4))
            imgui.Dummy(imgui.ImVec2(tableWidth2, 4))
        end
    end
    
    
    --  ЦЕНЫ
    
    if farmSectionTab.v == 1 then
        if ToggleSwitch(u8("Использовать собственные цены"), cb_useCustomFarmPrices, u8("Отключит возможность участия в рейтинге. Цены из Google таблицы не будут применяться.")) then
            useCustomFarmPrices = cb_useCustomFarmPrices.v
            if useCustomFarmPrices then
                saveLbConfig("", false)
                for _, k in ipairs(configs[WORK_TYPES.FARM].resourceOrder) do
                    if not customPriceEditFarm[k] then
                        customPriceEditFarm[k] = imgui.ImInt(resourcePrices[k] or configs[WORK_TYPES.FARM].defaultPrices[k])
                    end
                end
            end
            if currentWork == WORK_TYPES.FARM then
                loadedLogs = false; loadStats(); cachedTodayStats = nil; cachedWeekStats = nil
            end
            saveCustomPricesConfig()
        end
        imgui.Spacing()
        if not useCustomFarmPrices then
            imgui.TextColored(imgui.ImVec4(0.6, 0.6, 0.6, 1), u8("Цены средние по Vice City под SA. Авто-обновление раз в сутки."))
        end
        imgui.Spacing()
        if pricesLoading then
            imgui.TextColored(imgui.ImVec4(1.0, 0.8, 0.2, 1), u8("Цены обновляются..."))
            imgui.Spacing()
        end
        if not globalPrices or not next(globalPrices) then
            imgui.TextColored(imgui.ImVec4(1.0, 0.8, 0.2, 1), u8("Цены загружаются..."))
            imgui.Spacing()
        else
            local pos = imgui.GetCursorScreenPos()
            local tableWidth = imgui.GetWindowWidth() - 25
            local headerHeight = 28; local rowHeight = 26; local rows = #config.resourceOrder
            
            drawList:AddRectFilled(pos, imgui.ImVec2(pos.x + tableWidth, pos.y + headerHeight + rows * rowHeight), 0xFF141414, 6)
            drawList:AddRect(pos, imgui.ImVec2(pos.x + tableWidth, pos.y + headerHeight + rows * rowHeight), 0xFF2A2A2A, 6, 15, 1.5)
            drawList:AddText(imgui.ImVec2(pos.x + 10, pos.y + 6), 0xFF1AE591, u8("Ресурс"))
            drawList:AddText(imgui.ImVec2(pos.x + tableWidth/2 + 10, pos.y + 6), 0xFF1AE591, u8("Цена"))
            drawList:AddLine(imgui.ImVec2(pos.x + 6, pos.y + headerHeight), imgui.ImVec2(pos.x + tableWidth - 6, pos.y + headerHeight), 0xFF2A2A2A, 1.5)
            drawList:AddLine(imgui.ImVec2(pos.x + tableWidth/2, pos.y + 8), imgui.ImVec2(pos.x + tableWidth/2, pos.y + headerHeight + rows * rowHeight - 4), 0xFF2A2A2A, 1.0)
            
            for i, k in ipairs(config.resourceOrder) do
                local y = pos.y + headerHeight + (i - 1) * rowHeight
                local rowBgColor = (i % 2 == 0) and 0xFF1E1E1E or 0xFF181818
                drawList:AddRectFilled(imgui.ImVec2(pos.x + 2, y + 1), imgui.ImVec2(pos.x + tableWidth - 2, y + rowHeight - 1), rowBgColor)
                if i > 1 then drawList:AddLine(imgui.ImVec2(pos.x + 6, y), imgui.ImVec2(pos.x + tableWidth - 6, y), 0xFF222222, 0.5) end
                drawList:AddLine(imgui.ImVec2(pos.x + tableWidth/2, y + 2), imgui.ImVec2(pos.x + tableWidth/2, y + rowHeight - 2), 0xFF252525, 0.5)
                drawList:AddText(imgui.ImVec2(pos.x + 10, y + 5), 0xFFFFFFFF, u8(config.resourceNames[k]))
                if useCustomFarmPrices and customPriceEditFarm[k] then
                    local editPos = imgui.ImVec2(pos.x + tableWidth/2 + 10, y + 2)
                    imgui.SetCursorScreenPos(editPos); imgui.PushItemWidth(130)
                    if imgui.InputInt("##custom_price_farm_" .. k, customPriceEditFarm[k], 1000, 10000) then
                        saveCustomPricesConfig(); needSave = true
                    end
                    imgui.PopItemWidth()
                else
                    drawList:AddText(imgui.ImVec2(pos.x + tableWidth/2 + 10, y + 5), 0xFF33CC33, formatNumber(priceEdit[k].v) .. "$")
                end
            end
            imgui.SetCursorScreenPos(imgui.ImVec2(pos.x, pos.y + headerHeight + rows * rowHeight + 8))
            imgui.Dummy(imgui.ImVec2(tableWidth, 0))
        end
        
        if not useCustomFarmPrices then
            imgui.Spacing()
            if StyleButton(u8("Обновить цены на актуальные"), fa.ICON_REPEAT) then loadGlobalPrices() end
        end
    end
    
    
    --  СТАТИСТИКА
    
    if farmSectionTab.v == 2 then
        local todayData = getTodayStats()
        local todayTotal = 0
        for _, k in ipairs(config.resourceOrder) do
            todayTotal = todayTotal + ((todayData[k] or 0) * getPriceForResource(k, WORK_TYPES.FARM))
        end
        local weekData = getWeekStats()
        local weekTotal = 0
        for _, k in ipairs(config.resourceOrder) do
            weekTotal = weekTotal + ((weekData[k] or 0) * getPriceForResource(k, WORK_TYPES.FARM))
        end
        
        local spacing = 8
        local cardWidth = (listW - spacing) / 2
        local statCardH = 55
        local statPos = imgui.GetCursorScreenPos()
        
        -- Карточка "За сегодня"
        local todayHovered = (imgui.GetMousePos().x >= statPos.x and imgui.GetMousePos().x <= statPos.x + cardWidth and imgui.GetMousePos().y >= statPos.y and imgui.GetMousePos().y <= statPos.y + statCardH)
        drawList:AddRectFilled(statPos, imgui.ImVec2(statPos.x + cardWidth, statPos.y + statCardH), todayHovered and 0xFF1E1E1E or 0xFF1A1A1A, 6)
        drawList:AddRect(statPos, imgui.ImVec2(statPos.x + cardWidth, statPos.y + statCardH), farmExpandToday and 0xFF1AE591 or 0xFF333333, 6, 15, farmExpandToday and 2.0 or 1.0)
        drawList:AddText(imgui.ImVec2(statPos.x + 10, statPos.y + 8), 0xFF888888, u8("За сегодня"))
        drawList:AddText(imgui.ImVec2(statPos.x + 10, statPos.y + 28), 0xFFFFCC00, formatNumber(todayTotal) .. "$")
        local todayArrow = farmExpandToday and fa.ICON_ANGLE_UP or fa.ICON_ANGLE_DOWN
        local todayArrowW = imgui.CalcTextSize(todayArrow).x
        drawList:AddText(imgui.ImVec2(statPos.x + cardWidth - todayArrowW - 10, statPos.y + 28), 0xFF888888, todayArrow)
        imgui.SetCursorScreenPos(statPos)
        if imgui.InvisibleButton("##farm_expand_today", imgui.ImVec2(cardWidth, statCardH)) then
            farmExpandToday = not farmExpandToday; farmExpandWeek = false
        end
        
        -- Карточка "За неделю"
        local statPos2 = imgui.ImVec2(statPos.x + cardWidth + spacing, statPos.y)
        local weekHovered = (imgui.GetMousePos().x >= statPos2.x and imgui.GetMousePos().x <= statPos2.x + cardWidth and imgui.GetMousePos().y >= statPos2.y and imgui.GetMousePos().y <= statPos2.y + statCardH)
        drawList:AddRectFilled(statPos2, imgui.ImVec2(statPos2.x + cardWidth, statPos2.y + statCardH), weekHovered and 0xFF1E1E1E or 0xFF1A1A1A, 6)
        drawList:AddRect(statPos2, imgui.ImVec2(statPos2.x + cardWidth, statPos2.y + statCardH), farmExpandWeek and 0xFF1AE591 or 0xFF333333, 6, 15, farmExpandWeek and 2.0 or 1.0)
        drawList:AddText(imgui.ImVec2(statPos2.x + 10, statPos2.y + 8), 0xFF888888, u8("За неделю"))
        drawList:AddText(imgui.ImVec2(statPos2.x + 10, statPos2.y + 28), 0xFF33CCFF, formatNumber(weekTotal) .. "$")
        local weekArrow = farmExpandWeek and fa.ICON_ANGLE_UP or fa.ICON_ANGLE_DOWN
        local weekArrowW = imgui.CalcTextSize(weekArrow).x
        drawList:AddText(imgui.ImVec2(statPos2.x + cardWidth - weekArrowW - 10, statPos2.y + 28), 0xFF888888, weekArrow)
        imgui.SetCursorScreenPos(statPos2)
        if imgui.InvisibleButton("##farm_expand_week", imgui.ImVec2(cardWidth, statCardH)) then
            farmExpandWeek = not farmExpandWeek; farmExpandToday = false
        end
        
        imgui.SetCursorScreenPos(imgui.ImVec2(statPos.x, statPos.y + statCardH))
        imgui.Dummy(imgui.ImVec2(listW, 0))
        
        if farmExpandToday then
            imgui.Spacing()
            local tPos = imgui.GetCursorScreenPos()
            local tableWidth2 = imgui.GetWindowWidth() - 25
            local rowH2 = 24; local rows2 = #config.resourceOrder
            
            drawList:AddRectFilled(tPos, imgui.ImVec2(tPos.x + tableWidth2, tPos.y + rows2 * rowH2 + 4), 0xFF141414, 8)
            drawList:AddRect(tPos, imgui.ImVec2(tPos.x + tableWidth2, tPos.y + rows2 * rowH2 + 4), 0xFF2A2A2A, 8, 15, 1.0)
            
            for i, k in ipairs(config.resourceOrder) do
                local y = tPos.y + (i - 1) * rowH2
                local rowBgColor = (i % 2 == 0) and 0xFF1E1E1E or 0xFF181818
                drawList:AddRectFilled(imgui.ImVec2(tPos.x + 2, y + 1), imgui.ImVec2(tPos.x + tableWidth2 - 2, y + rowH2 - 1), rowBgColor)
                drawList:AddText(imgui.ImVec2(tPos.x + 12, y + 4), 0xFFCCCCCC, u8(config.resourceNames[k]))
                local amtStr = formatNumber(todayData[k] or 0); local amtW = imgui.CalcTextSize(amtStr).x
                drawList:AddText(imgui.ImVec2(tPos.x + tableWidth2 - amtW - 12, y + 4), 0xFFFFCC00, amtStr)
            end
            
            imgui.SetCursorScreenPos(imgui.ImVec2(tPos.x, tPos.y + rows2 * rowH2 + 4))
            imgui.Dummy(imgui.ImVec2(tableWidth2, 4))
        end
        
        if farmExpandWeek then
            imgui.Spacing()
            local tPos = imgui.GetCursorScreenPos()
            local tableWidth2 = imgui.GetWindowWidth() - 25
            local rowH2 = 24; local rows2 = #config.resourceOrder
            
            drawList:AddRectFilled(tPos, imgui.ImVec2(tPos.x + tableWidth2, tPos.y + rows2 * rowH2 + 4), 0xFF141414, 8)
            drawList:AddRect(tPos, imgui.ImVec2(tPos.x + tableWidth2, tPos.y + rows2 * rowH2 + 4), 0xFF2A2A2A, 8, 15, 1.0)
            
            for i, k in ipairs(config.resourceOrder) do
                local y = tPos.y + (i - 1) * rowH2
                local rowBgColor = (i % 2 == 0) and 0xFF1E1E1E or 0xFF181818
                drawList:AddRectFilled(imgui.ImVec2(tPos.x + 2, y + 1), imgui.ImVec2(tPos.x + tableWidth2 - 2, y + rowH2 - 1), rowBgColor)
                drawList:AddText(imgui.ImVec2(tPos.x + 12, y + 4), 0xFFCCCCCC, u8(config.resourceNames[k]))
                local amtStr = formatNumber(weekData[k] or 0); local amtW = imgui.CalcTextSize(amtStr).x
                drawList:AddText(imgui.ImVec2(tPos.x + tableWidth2 - amtW - 12, y + 4), 0xFF33CCFF, amtStr)
            end
            
            imgui.SetCursorScreenPos(imgui.ImVec2(tPos.x, tPos.y + rows2 * rowH2 + 4))
            imgui.Dummy(imgui.ImVec2(tableWidth2, 4))
        end
        
        imgui.Spacing(); imgui.Separator(); imgui.Spacing()
        
        local availableDates = getAvailableDates()
        local seenDates = {}
        for _, d in ipairs(availableDates) do seenDates[d] = true end
        
        if #availableDates > 0 then
            if not imStatCalendarFarmDate then
                imStatCalendarFarmDate = availableDates[1]
                local yy, mm = imStatCalendarFarmDate:match("(%d+)-(%d+)-")
                imStatCalendarFarmYear = tonumber(yy); imStatCalendarFarmMonth = tonumber(mm)
            end
            
            local btnW = imgui.GetWindowWidth() - 25
            local btnPos = imgui.GetCursorScreenPos()
            local hovered = (imgui.GetMousePos().x >= btnPos.x and imgui.GetMousePos().x <= btnPos.x + btnW and imgui.GetMousePos().y >= btnPos.y and imgui.GetMousePos().y <= btnPos.y + 30)
            local bg = hovered and 0xFF222222 or 0xFF1A1A1A
            local border = hovered and 0xFF555555 or 0xFF333333
            drawList:AddRectFilled(btnPos, imgui.ImVec2(btnPos.x + btnW, btnPos.y + 30), bg, 4)
            drawList:AddRect(btnPos, imgui.ImVec2(btnPos.x + btnW, btnPos.y + 30), border, 4, 15, 1.0)
            local y2, m2, d2 = imStatCalendarFarmDate:match("(%d+)-(%d+)-(%d+)")
            local displayDate = imStatCalendarFarmDate
            if y2 and m2 and d2 then displayDate = d2 .. "." .. m2 .. "." .. y2 end
            drawList:AddText(imgui.ImVec2(btnPos.x + 10, btnPos.y + 6), 0xFF1AE591, fa.ICON_CALENDAR .. " " .. displayDate)
            drawList:AddText(imgui.ImVec2(btnPos.x + btnW - 20, btnPos.y + 6), 0xFF888888, fa.ICON_ARROW_DOWN)
            imgui.SetCursorScreenPos(btnPos)
            if imgui.InvisibleButton("##stat_farm_date_btn", imgui.ImVec2(btnW, 30)) then
                imgui.OpenPopup("##stat_farm_calendar_popup")
            end
            
            if imgui.BeginPopup("##stat_farm_calendar_popup") then
                local monthNamesRu = {u8("Январь"), u8("Февраль"), u8("Март"), u8("Апрель"), u8("Май"), u8("Июнь"), u8("Июль"), u8("Август"), u8("Сентябрь"), u8("Октябрь"), u8("Ноябрь"), u8("Декабрь")}
                local weekdayNamesRu = {u8("Пн"), u8("Вт"), u8("Ср"), u8("Чт"), u8("Пт"), u8("Сб"), u8("Вс")}
                local todayStr = getGameDate()
                local ACCENT = 0xFF6078E0; local TODAY_RING = 0xFFFFFFFF
                local WEEKEND_COL = 0xFF6078E0; local DOT_GREEN = 0xFFD4BC00
                
                local function daysInMonth(yy, mm)
                    local dim = {31,28,31,30,31,30,31,31,30,31,30,31}
                    if mm == 2 and (yy % 4 == 0 and (yy % 100 ~= 0 or yy % 400 == 0)) then return 29 end
                    return dim[mm]
                end
                local function firstWeekdayOfMonth(yy, mm)
                    local t = os.time({year = yy, month = mm, day = 1, hour = 12})
                    local w = tonumber(os.date("%w", t)); if w == 0 then w = 7 end; return w
                end
                
                local calDrawList = imgui.GetWindowDrawList()
                local cellSize = 34; local cellGap = 2; local step = cellSize + cellGap; local headerW = step * 7
                local headerPos = imgui.GetCursorScreenPos(); local headerH = 30; local btnSz = 24
                
                local leftBtnX = headerPos.x; local leftBtnY = headerPos.y + (headerH - btnSz) / 2
                local mouseP = imgui.GetMousePos()
                local leftHovered = (mouseP.x >= leftBtnX and mouseP.x <= leftBtnX + btnSz and mouseP.y >= leftBtnY and mouseP.y <= leftBtnY + btnSz)
                local leftCenter = imgui.ImVec2(leftBtnX + btnSz / 2, leftBtnY + btnSz / 2)
                calDrawList:AddCircleFilled(leftCenter, btnSz / 2, leftHovered and 0xFF2E2E2E or 0xFF1C1C1C, 20)
                local leftArrow = fa.ICON_ANGLE_LEFT; local leftArrowSz = imgui.CalcTextSize(leftArrow)
                calDrawList:AddText(imgui.ImVec2(leftCenter.x - leftArrowSz.x / 2, leftCenter.y - leftArrowSz.y / 2), leftHovered and 0xFFFFFFFF or 0xFFAAAAAA, leftArrow)
                imgui.SetCursorScreenPos(imgui.ImVec2(leftBtnX, leftBtnY))
                if imgui.InvisibleButton("##stat_farm_left", imgui.ImVec2(btnSz, btnSz)) then
                    imStatCalendarFarmMonth = imStatCalendarFarmMonth - 1
                    if imStatCalendarFarmMonth < 1 then imStatCalendarFarmMonth = 12; imStatCalendarFarmYear = imStatCalendarFarmYear - 1 end
                end
                
                local rightBtnX = headerPos.x + headerW - btnSz; local rightBtnY = leftBtnY
                local rightHovered = (mouseP.x >= rightBtnX and mouseP.x <= rightBtnX + btnSz and mouseP.y >= rightBtnY and mouseP.y <= rightBtnY + btnSz)
                local rightCenter = imgui.ImVec2(rightBtnX + btnSz / 2, rightBtnY + btnSz / 2)
                calDrawList:AddCircleFilled(rightCenter, btnSz / 2, rightHovered and 0xFF2E2E2E or 0xFF1C1C1C, 20)
                local rightArrow = fa.ICON_ANGLE_RIGHT; local rightArrowSz = imgui.CalcTextSize(rightArrow)
                calDrawList:AddText(imgui.ImVec2(rightCenter.x - rightArrowSz.x / 2, rightCenter.y - rightArrowSz.y / 2), rightHovered and 0xFFFFFFFF or 0xFFAAAAAA, rightArrow)
                imgui.SetCursorScreenPos(imgui.ImVec2(rightBtnX, rightBtnY))
                if imgui.InvisibleButton("##stat_farm_right", imgui.ImVec2(btnSz, btnSz)) then
                    imStatCalendarFarmMonth = imStatCalendarFarmMonth + 1
                    if imStatCalendarFarmMonth > 12 then imStatCalendarFarmMonth = 1; imStatCalendarFarmYear = imStatCalendarFarmYear + 1 end
                end
                
                local monthName = monthNamesRu[imStatCalendarFarmMonth]; local yearName = tostring(imStatCalendarFarmYear)
                local monthNameW = imgui.CalcTextSize(monthName).x; local monthNameH = imgui.CalcTextSize(monthName).y
                local yearNameW = imgui.CalcTextSize(yearName).x; local yearNameH = imgui.CalcTextSize(yearName).y
                local totalH = monthNameH + yearNameH + 2; local textStartY = headerPos.y + (headerH - totalH) / 2
                calDrawList:AddText(imgui.ImVec2(headerPos.x + (headerW - monthNameW) / 2, textStartY), 0xFF6078E0, monthName)
                calDrawList:AddText(imgui.ImVec2(headerPos.x + (headerW - yearNameW) / 2, textStartY + monthNameH + 2), 0xFFAAAAAA, yearName)
                
                imgui.SetCursorScreenPos(imgui.ImVec2(headerPos.x, headerPos.y + headerH)); imgui.Dummy(imgui.ImVec2(headerW, 4))
                local subSepY = imgui.GetCursorScreenPos().y + 2
                calDrawList:AddLine(imgui.ImVec2(headerPos.x, subSepY), imgui.ImVec2(headerPos.x + headerW, subSepY), 0xFF2A2A2A, 1.0)
                imgui.SetCursorScreenPos(imgui.ImVec2(headerPos.x, subSepY + 8))
                
                local hdrPos2 = imgui.GetCursorScreenPos()
                for i, wd in ipairs(weekdayNamesRu) do
                    local isWeekend = (i == 6 or i == 7); local wdW = imgui.CalcTextSize(wd).x
                    calDrawList:AddText(imgui.ImVec2(hdrPos2.x + (i - 1) * step + (cellSize - wdW) / 2, hdrPos2.y), isWeekend and WEEKEND_COL or 0xFF666666, wd)
                end
                imgui.Dummy(imgui.ImVec2(headerW, 18))
                
                local startWd = firstWeekdayOfMonth(imStatCalendarFarmYear, imStatCalendarFarmMonth)
                local totalDays = daysInMonth(imStatCalendarFarmYear, imStatCalendarFarmMonth)
                local gridPos = imgui.GetCursorScreenPos()
                
                local row, col = 0, startWd - 1
                for dnum = 1, totalDays do
                    local cellX = gridPos.x + col * step; local cellY = gridPos.y + row * step
                    local center = imgui.ImVec2(cellX + cellSize / 2, cellY + cellSize / 2); local radius = cellSize / 2 - 1
                    local dateStr = string.format("%04d-%02d-%02d", imStatCalendarFarmYear, imStatCalendarFarmMonth, dnum)
                    local hasData = seenDates[dateStr] == true
                    local isSelected = (dateStr == imStatCalendarFarmDate); local isToday = (dateStr == todayStr)
                    local cellHovered = (mouseP.x >= cellX and mouseP.x <= cellX + cellSize and mouseP.y >= cellY and mouseP.y <= cellY + cellSize)
                    
                    if isSelected and isToday then
                        calDrawList:AddCircleFilled(center, radius, ACCENT, 24); calDrawList:AddCircle(center, radius, TODAY_RING, 24, 2.0)
                    elseif isSelected then calDrawList:AddCircleFilled(center, radius, ACCENT, 24)
                    elseif isToday then calDrawList:AddCircle(center, radius, TODAY_RING, 24, 1.5)
                    elseif cellHovered then calDrawList:AddCircle(center, radius, 0xFF444444, 24, 1.0) end
                    
                    local dayStr = tostring(dnum); local dayStrSz = imgui.CalcTextSize(dayStr)
                    local textCol
                    if isSelected then textCol = 0xFFFFFFFF elseif isToday then textCol = 0xFF1AE591
                    elseif hasData then textCol = 0xFFCCCCCC elseif cellHovered then textCol = 0xFFEEEEEE else textCol = 0xFF666666 end
                    calDrawList:AddText(imgui.ImVec2(center.x - dayStrSz.x / 2, center.y - dayStrSz.y / 2 - (hasData and 3 or 0)), textCol, dayStr)
                    
                    if hasData then
                        local dotCol = isSelected and 0xFFFFFFFF or DOT_GREEN
                        calDrawList:AddCircleFilled(imgui.ImVec2(center.x, center.y + dayStrSz.y / 2 + 2), 2.0, dotCol, 12)
                    end
                    if cellHovered then
                        local dayData = getDayStats(dateStr); local dayTotal = 0
                        for _, k in ipairs(configs[WORK_TYPES.FARM].resourceOrder) do
                            dayTotal = dayTotal + ((dayData[k] or 0) * getPriceForResource(k, WORK_TYPES.FARM))
                        end
                        imgui.BeginTooltip(); imgui.Text(dayStr .. " " .. monthNamesRu[imStatCalendarFarmMonth])
                        if dayTotal > 0 then imgui.Text(u8("Доход: ") .. formatNumber(dayTotal) .. "$") else imgui.Text(u8("Нет записей")) end
                        imgui.EndTooltip()
                    end
                    imgui.SetCursorScreenPos(imgui.ImVec2(cellX, cellY))
                    if imgui.InvisibleButton("##stat_farm_cal_" .. dateStr, imgui.ImVec2(cellSize, cellSize)) then
                        imStatCalendarFarmDate = dateStr; imgui.CloseCurrentPopup()
                    end
                    col = col + 1; if col > 6 then col = 0; row = row + 1 end
                end
                
                imgui.SetCursorScreenPos(imgui.ImVec2(gridPos.x, gridPos.y + (row + 1) * step + 4))
                local legY = imgui.GetCursorScreenPos().y + 6
                calDrawList:AddLine(imgui.ImVec2(headerPos.x, legY), imgui.ImVec2(headerPos.x + headerW, legY), 0xFF2A2A2A, 1.0)
                local legendY = legY + 8
                calDrawList:AddCircleFilled(imgui.ImVec2(headerPos.x + 6, legendY + 5), 2.0, DOT_GREEN, 12)
                calDrawList:AddText(imgui.ImVec2(headerPos.x + 14, legendY), 0xFF777777, u8("Есть записи"))
                local todayLabel = u8("Сегодня"); local todayLabelW = imgui.CalcTextSize(todayLabel).x
                calDrawList:AddCircle(imgui.ImVec2(headerPos.x + headerW - todayLabelW - 16, legendY + 5), 4.0, TODAY_RING, 12, 1.2)
                calDrawList:AddText(imgui.ImVec2(headerPos.x + headerW - todayLabelW, legendY), 0xFF777777, todayLabel)
                imgui.SetCursorScreenPos(imgui.ImVec2(headerPos.x, legendY + 20)); imgui.Dummy(imgui.ImVec2(headerW, 1))
                imgui.EndPopup()
            end
            
            imgui.Spacing()
            
            local dayData = getDayStats(imStatCalendarFarmDate)
            local dayTotal = 0
            for _, k in ipairs(config.resourceOrder) do
                dayTotal = dayTotal + ((dayData[k] or 0) * getPriceForResource(k, WORK_TYPES.FARM))
            end
            
            local tPos = imgui.GetCursorScreenPos()
            local tableWidth2 = imgui.GetWindowWidth() - 25
            local rowH2 = 26; local rows2 = #config.resourceOrder
            local totalRowH = 32; local tblH2 = rows2 * rowH2 + totalRowH
            
            drawList:AddRectFilled(tPos, imgui.ImVec2(tPos.x + tableWidth2, tPos.y + tblH2), 0xFF141414, 8)
            drawList:AddRect(tPos, imgui.ImVec2(tPos.x + tableWidth2, tPos.y + tblH2), 0xFF2A2A2A, 8, 15, 1.0)
            
            for i, k in ipairs(config.resourceOrder) do
                local y = tPos.y + (i - 1) * rowH2
                local rowBgColor = (i % 2 == 0) and 0xFF1E1E1E or 0xFF181818
                drawList:AddRectFilled(imgui.ImVec2(tPos.x + 2, y + 1), imgui.ImVec2(tPos.x + tableWidth2 - 2, y + rowH2 - 1), rowBgColor)
                drawList:AddText(imgui.ImVec2(tPos.x + 12, y + 5), 0xFFCCCCCC, u8(config.resourceNames[k]))
                local amtStr = formatNumber(dayData[k] or 0); local amtW = imgui.CalcTextSize(amtStr).x
                drawList:AddText(imgui.ImVec2(tPos.x + tableWidth2 - amtW - 12, y + 5), 0xFFFFCC00, amtStr)
            end
            
            local totalY = tPos.y + rows2 * rowH2
            drawList:AddRectFilled(imgui.ImVec2(tPos.x + 2, totalY + 1), imgui.ImVec2(tPos.x + tableWidth2 - 2, totalY + totalRowH - 2), 0xFF1E2E22, 6)
            drawList:AddText(imgui.ImVec2(tPos.x + 12, totalY + 9), 0xFF888888, u8("Доход"))
            local totalStr = formatNumber(dayTotal) .. "$"; local totalW2 = imgui.CalcTextSize(totalStr).x
            drawList:AddText(imgui.ImVec2(tPos.x + tableWidth2 - totalW2 - 12, totalY + 9), 0xFF33CC66, totalStr)
            
            imgui.SetCursorScreenPos(imgui.ImVec2(tPos.x, tPos.y + tblH2 + 8))
            imgui.Dummy(imgui.ImVec2(tableWidth2, 0))
        else
            imgui.TextColored(imgui.ImVec4(0.8, 0.3, 0.3, 1), u8("Нет данных"))
        end
    end
end
function drawMineTab()
    if not config then
        imgui.Text(u8("Сначала выберите режим работы (нажмите Шахта в меню слева)"))
        return
    end
    local drawList = imgui.GetWindowDrawList()
    local listW = imgui.GetWindowWidth() - 25
    
    -- Три раздела: Меню / Цены / Статистика
    if not mineSectionTab then mineSectionTab = imgui.ImInt(0) end
    local mineSectionNames = {u8("Меню"), u8("Цены"), u8("Статистика")}
    local mineSectionBtnW = (imgui.GetWindowWidth() - 25 - 8) / 3
    for i, name in ipairs(mineSectionNames) do
        if i > 1 then imgui.SameLine() end
        if StyleButton(name, nil, mineSectionBtnW, mineSectionTab.v == i - 1) then
            local prev = mineSectionTab.v
            mineSectionTab.v = i - 1
            if mineSectionTab.v == 1 and prev ~= 1 and not pricesLoading then loadGlobalPrices() end
        end
    end
    imgui.Spacing(); imgui.Separator(); imgui.Spacing()
    
    
    --  МЕНЮ
    
    if mineSectionTab.v == 0 then
        local scanColor, scanIcon, scanStatusText
        if scanState.active then
            scanColor = 0xFFFFCC33; scanIcon = fa.ICON_REFRESH; scanStatusText = u8("Сканирование: ") .. u8(scanState.statusText)
        elseif scannedThisSession[currentWork] then
            scanColor = 0xFF33CC66; scanIcon = fa.ICON_CHECK; scanStatusText = u8("Инвентарь отсканирован")
        else
            scanColor = 0xFFFF8833; scanIcon = fa.ICON_EXCLAMATION_TRIANGLE; scanStatusText = u8("Инвентарь не отсканирован")
        end
        
        local cardX = imgui.GetCursorScreenPos().x
        local cardY = imgui.GetCursorScreenPos().y
        local scanCardH = 56
        drawList:AddRectFilled(imgui.ImVec2(cardX, cardY), imgui.ImVec2(cardX + listW, cardY + scanCardH), 0xFF141414, 8)
        drawList:AddRect(imgui.ImVec2(cardX, cardY), imgui.ImVec2(cardX + listW, cardY + scanCardH), 0xFF2A2A2A, 8, 15, 1.0)
        drawList:AddText(imgui.ImVec2(cardX + 14, cardY + 10), scanColor, scanIcon)
        drawList:AddText(imgui.ImVec2(cardX + 38, cardY + 10), scanColor, scanStatusText)
        drawList:AddText(imgui.ImVec2(cardX + 14, cardY + 30), 0xFF666666, u8("Сканируй инвентарь перед началом сбора ресурсов"))
        
        imgui.SetCursorScreenPos(imgui.ImVec2(cardX, cardY + scanCardH + 8))
        local scanBtnText = scanState.active and u8("Сканирование...") or (scannedThisSession[currentWork] and u8("Пересканировать инвентарь") or u8("Сканировать инвентарь"))
        if scanState.active then
            imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.3, 0.3, 0.3, 0.5))
            imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.3, 0.3, 0.3, 0.5))
            imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.3, 0.3, 0.3, 0.5))
            StyleButton(scanBtnText, fa.ICON_SEARCH)
            imgui.PopStyleColor(3)
        else
            if StyleButton(scanBtnText, fa.ICON_SEARCH) then startInventoryScan() end
        end
        
        imgui.Spacing(); imgui.Separator(); imgui.Spacing()
        
        imgui.TextColored(imgui.ImVec4(0.3, 0.8, 0.3, 1), u8("Режимы счета:"))
        if ToggleSwitch(u8("Подземная шахта"), cb_undermine) then 
            settings.undermineEnabled = cb_undermine.v
            if cb_undermine.v then cb_regular.v = false; settings.regularmineEnabled = false end
            saveConfig(); needSave = true 
        end
        if ToggleSwitch(u8("Лавка (вычитает ресурсы)"), cb_lavka) then 
            settings.underminelavkaEnabled = cb_lavka.v
            if cb_lavka.v then cb_undermine.v = true; settings.undermineEnabled = true end
            saveConfig(); needSave = true 
        end
        if ToggleSwitch(u8("Обычная шахта"), cb_regular) then 
            settings.regularmineEnabled = cb_regular.v
            if cb_regular.v then cb_undermine.v = false; settings.undermineEnabled = false end
            saveConfig(); needSave = true 
        end
        
        imgui.Spacing(); imgui.Separator(); imgui.Spacing()
        
        if ToggleSwitch(u8("Показывать оверлей на экране"), cb_mine_overlay) then
            if cb_mine_overlay.v then
                settings.mineOverlayEnabled = true
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
        
        if ToggleSwitch(u8("Таймер спавна в оверлее"), cb_mineSpawnTimer) then
            settings.mineSpawnTimerEnabled = cb_mineSpawnTimer.v
            saveConfig()
        end
        
        imgui.Spacing(); imgui.Separator(); imgui.Spacing()
        
        -- Быстрый итог за сегодня (раскрывающийся)
        if not mineExpandIncome then mineExpandIncome = false end
        local todayData = getTodayStats()
        local todayTotal = 0
        for _, k in ipairs(config.resourceOrder) do
            todayTotal = todayTotal + ((todayData[k] or 0) * getPriceForResource(k, WORK_TYPES.MINE))
        end
        local todayCardX = imgui.GetCursorScreenPos().x
        local todayCardY = imgui.GetCursorScreenPos().y
        local todayCardH = 50
        local incomeHovered = (imgui.GetMousePos().x >= todayCardX and imgui.GetMousePos().x <= todayCardX + listW and imgui.GetMousePos().y >= todayCardY and imgui.GetMousePos().y <= todayCardY + todayCardH)
        drawList:AddRectFilled(imgui.ImVec2(todayCardX, todayCardY), imgui.ImVec2(todayCardX + listW, todayCardY + todayCardH), incomeHovered and 0xFF1E1E1E or 0xFF141414, 8)
        drawList:AddRect(imgui.ImVec2(todayCardX, todayCardY), imgui.ImVec2(todayCardX + listW, todayCardY + todayCardH), mineExpandIncome and 0xFF1AE591 or 0xFF2A2A2A, 8, 15, mineExpandIncome and 2.0 or 1.0)
        drawList:AddText(imgui.ImVec2(todayCardX + 14, todayCardY + 8), 0xFF888888, u8("Доход за сегодня"))
        drawList:AddText(imgui.ImVec2(todayCardX + 14, todayCardY + 26), 0xFF33CC66, formatNumber(todayTotal) .. "$")
        local incomeArrow = mineExpandIncome and fa.ICON_ANGLE_UP or fa.ICON_ANGLE_DOWN
        local incomeArrowW = imgui.CalcTextSize(incomeArrow).x
        drawList:AddText(imgui.ImVec2(todayCardX + listW - incomeArrowW - 14, todayCardY + 26), 0xFF888888, incomeArrow)
        imgui.SetCursorScreenPos(imgui.ImVec2(todayCardX, todayCardY))
        if imgui.InvisibleButton("##mine_expand_income", imgui.ImVec2(listW, todayCardH)) then
            mineExpandIncome = not mineExpandIncome
        end
        imgui.SetCursorScreenPos(imgui.ImVec2(todayCardX, todayCardY + todayCardH))
        imgui.Dummy(imgui.ImVec2(listW, 0))
        
        if mineExpandIncome then
            imgui.Spacing()
            local tPos = imgui.GetCursorScreenPos()
            local tableWidth2 = imgui.GetWindowWidth() - 25
            local rowH2 = 24; local halfRows = math.ceil(#config.resourceOrder / 2)
            
            drawList:AddRectFilled(tPos, imgui.ImVec2(tPos.x + tableWidth2, tPos.y + halfRows * rowH2 + 4), 0xFF141414, 8)
            drawList:AddRect(tPos, imgui.ImVec2(tPos.x + tableWidth2, tPos.y + halfRows * rowH2 + 4), 0xFF2A2A2A, 8, 15, 1.0)
            
            for i = 1, halfRows do
                local k = config.resourceOrder[i]
                local y = tPos.y + (i - 1) * rowH2
                local rowBgColor = (i % 2 == 0) and 0xFF1E1E1E or 0xFF181818
                drawList:AddRectFilled(imgui.ImVec2(tPos.x + 2, y + 1), imgui.ImVec2(tPos.x + tableWidth2 / 2 - 2, y + rowH2 - 1), rowBgColor)
                drawList:AddText(imgui.ImVec2(tPos.x + 8, y + 4), 0xFFCCCCCC, u8(config.resourceNames[k]))
                local amtStr = formatNumber(todayData[k] or 0); local amtW = imgui.CalcTextSize(amtStr).x
                drawList:AddText(imgui.ImVec2(tPos.x + tableWidth2 / 2 - amtW - 12, y + 4), 0xFFFFCC00, amtStr)
            end
            for i = halfRows + 1, #config.resourceOrder do
                local k = config.resourceOrder[i]
                local y = tPos.y + (i - halfRows - 1) * rowH2
                local rowBgColor = ((i - halfRows) % 2 == 0) and 0xFF1E1E1E or 0xFF181818
                drawList:AddRectFilled(imgui.ImVec2(tPos.x + tableWidth2 / 2 + 2, y + 1), imgui.ImVec2(tPos.x + tableWidth2 - 2, y + rowH2 - 1), rowBgColor)
                drawList:AddText(imgui.ImVec2(tPos.x + tableWidth2 / 2 + 8, y + 4), 0xFFCCCCCC, u8(config.resourceNames[k]))
                local amtStr = formatNumber(todayData[k] or 0); local amtW = imgui.CalcTextSize(amtStr).x
                drawList:AddText(imgui.ImVec2(tPos.x + tableWidth2 - amtW - 12, y + 4), 0xFFFFCC00, amtStr)
            end
            
            imgui.SetCursorScreenPos(imgui.ImVec2(tPos.x, tPos.y + halfRows * rowH2 + 4))
            imgui.Dummy(imgui.ImVec2(tableWidth2, 4))
        end
    end
    
    
    --  ЦЕНЫ
    
    if mineSectionTab.v == 1 then
        if ToggleSwitch(u8("Использовать собственные цены"), cb_useCustomMinePrices, u8("Отключит возможность участия в рейтинге. Цены из Google таблицы не будут применяться.")) then
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
        imgui.Spacing()
        if not useCustomMinePrices then
            imgui.TextColored(imgui.ImVec4(0.6, 0.6, 0.6, 1), u8("Цены средние по Vice City под SA. Авто-обновление раз в сутки."))
        end
        imgui.Spacing()
        if pricesLoading then
            imgui.TextColored(imgui.ImVec4(1.0, 0.8, 0.2, 1), u8("Цены обновляются..."))
            imgui.Spacing()
        end
        if not globalPrices or not next(globalPrices) then
            imgui.TextColored(imgui.ImVec4(1.0, 0.8, 0.2, 1), u8("Цены загружаются..."))
            imgui.Spacing()
        else
            local pos = imgui.GetCursorScreenPos()
            local tableWidth = imgui.GetWindowWidth() - 25
            local headerHeight = 28; local rowHeight = 26; local rows = #config.resourceOrder
            
            drawList:AddRectFilled(pos, imgui.ImVec2(pos.x + tableWidth, pos.y + headerHeight + rows * rowHeight), 0xFF141414, 6)
            drawList:AddRect(pos, imgui.ImVec2(pos.x + tableWidth, pos.y + headerHeight + rows * rowHeight), 0xFF2A2A2A, 6, 15, 1.5)
            drawList:AddText(imgui.ImVec2(pos.x + 10, pos.y + 6), 0xFF1AE591, u8("Ресурс"))
            drawList:AddText(imgui.ImVec2(pos.x + tableWidth/2 + 10, pos.y + 6), 0xFF1AE591, u8("Цена"))
            drawList:AddLine(imgui.ImVec2(pos.x + 6, pos.y + headerHeight), imgui.ImVec2(pos.x + tableWidth - 6, pos.y + headerHeight), 0xFF2A2A2A, 1.5)
            drawList:AddLine(imgui.ImVec2(pos.x + tableWidth/2, pos.y + 8), imgui.ImVec2(pos.x + tableWidth/2, pos.y + headerHeight + rows * rowHeight - 4), 0xFF2A2A2A, 1.0)
            
            for i, k in ipairs(config.resourceOrder) do
                local y = pos.y + headerHeight + (i - 1) * rowHeight
                local rowBgColor = (i % 2 == 0) and 0xFF1E1E1E or 0xFF181818
                drawList:AddRectFilled(imgui.ImVec2(pos.x + 2, y + 1), imgui.ImVec2(pos.x + tableWidth - 2, y + rowHeight - 1), rowBgColor)
                if i > 1 then drawList:AddLine(imgui.ImVec2(pos.x + 6, y), imgui.ImVec2(pos.x + tableWidth - 6, y), 0xFF222222, 0.5) end
                drawList:AddLine(imgui.ImVec2(pos.x + tableWidth/2, y + 2), imgui.ImVec2(pos.x + tableWidth/2, y + rowHeight - 2), 0xFF252525, 0.5)
                drawList:AddText(imgui.ImVec2(pos.x + 10, y + 5), 0xFFFFFFFF, u8(config.resourceNames[k]))
                if useCustomMinePrices and customPriceEditMine[k] then
                    local editPos = imgui.ImVec2(pos.x + tableWidth/2 + 10, y + 2)
                    imgui.SetCursorScreenPos(editPos); imgui.PushItemWidth(130)
                    if imgui.InputInt("##custom_price_mine_" .. k, customPriceEditMine[k], 1000, 10000) then
                        saveCustomPricesConfig(); needSave = true
                    end
                    imgui.PopItemWidth()
                else
                    drawList:AddText(imgui.ImVec2(pos.x + tableWidth/2 + 10, y + 5), 0xFF33CC33, formatNumber(priceEdit[k].v) .. "$")
                end
            end
            imgui.SetCursorScreenPos(imgui.ImVec2(pos.x, pos.y + headerHeight + rows * rowHeight + 8))
            imgui.Dummy(imgui.ImVec2(tableWidth, 0))
        end
        
        if not useCustomMinePrices then
            imgui.Spacing()
            if StyleButton(u8("Обновить цены на актуальные"), fa.ICON_REPEAT) then loadGlobalPrices() end
        end
    end
    
    
    --  СТАТИСТИКА
    
    if mineSectionTab.v == 2 then
        local todayData = getTodayStats()
        local todayTotal = 0
        for _, k in ipairs(config.resourceOrder) do
            todayTotal = todayTotal + ((todayData[k] or 0) * getPriceForResource(k, WORK_TYPES.MINE))
        end
        local weekData = getWeekStats()
        local weekTotal = 0
        for _, k in ipairs(config.resourceOrder) do
            weekTotal = weekTotal + ((weekData[k] or 0) * getPriceForResource(k, WORK_TYPES.MINE))
        end
        
        local spacing = 8
        local cardWidth = (listW - spacing) / 2
        local statCardH = 55
        local statPos = imgui.GetCursorScreenPos()
        
        -- Карточка "За сегодня"
        local todayHovered = (imgui.GetMousePos().x >= statPos.x and imgui.GetMousePos().x <= statPos.x + cardWidth and imgui.GetMousePos().y >= statPos.y and imgui.GetMousePos().y <= statPos.y + statCardH)
        drawList:AddRectFilled(statPos, imgui.ImVec2(statPos.x + cardWidth, statPos.y + statCardH), todayHovered and 0xFF1E1E1E or 0xFF1A1A1A, 6)
        drawList:AddRect(statPos, imgui.ImVec2(statPos.x + cardWidth, statPos.y + statCardH), mineExpandToday and 0xFF1AE591 or 0xFF333333, 6, 15, mineExpandToday and 2.0 or 1.0)
        drawList:AddText(imgui.ImVec2(statPos.x + 10, statPos.y + 8), 0xFF888888, u8("За сегодня"))
        drawList:AddText(imgui.ImVec2(statPos.x + 10, statPos.y + 28), 0xFFFFCC00, formatNumber(todayTotal) .. "$")
        local todayArrow = mineExpandToday and fa.ICON_ANGLE_UP or fa.ICON_ANGLE_DOWN
        local todayArrowW = imgui.CalcTextSize(todayArrow).x
        drawList:AddText(imgui.ImVec2(statPos.x + cardWidth - todayArrowW - 10, statPos.y + 28), 0xFF888888, todayArrow)
        imgui.SetCursorScreenPos(statPos)
        if imgui.InvisibleButton("##mine_expand_today", imgui.ImVec2(cardWidth, statCardH)) then
            mineExpandToday = not mineExpandToday; mineExpandWeek = false
        end
        
        -- Карточка "За неделю"
        local statPos2 = imgui.ImVec2(statPos.x + cardWidth + spacing, statPos.y)
        local weekHovered = (imgui.GetMousePos().x >= statPos2.x and imgui.GetMousePos().x <= statPos2.x + cardWidth and imgui.GetMousePos().y >= statPos2.y and imgui.GetMousePos().y <= statPos2.y + statCardH)
        drawList:AddRectFilled(statPos2, imgui.ImVec2(statPos2.x + cardWidth, statPos2.y + statCardH), weekHovered and 0xFF1E1E1E or 0xFF1A1A1A, 6)
        drawList:AddRect(statPos2, imgui.ImVec2(statPos2.x + cardWidth, statPos2.y + statCardH), mineExpandWeek and 0xFF1AE591 or 0xFF333333, 6, 15, mineExpandWeek and 2.0 or 1.0)
        drawList:AddText(imgui.ImVec2(statPos2.x + 10, statPos2.y + 8), 0xFF888888, u8("За неделю"))
        drawList:AddText(imgui.ImVec2(statPos2.x + 10, statPos2.y + 28), 0xFF33CCFF, formatNumber(weekTotal) .. "$")
        local weekArrow = mineExpandWeek and fa.ICON_ANGLE_UP or fa.ICON_ANGLE_DOWN
        local weekArrowW = imgui.CalcTextSize(weekArrow).x
        drawList:AddText(imgui.ImVec2(statPos2.x + cardWidth - weekArrowW - 10, statPos2.y + 28), 0xFF888888, weekArrow)
        imgui.SetCursorScreenPos(statPos2)
        if imgui.InvisibleButton("##mine_expand_week", imgui.ImVec2(cardWidth, statCardH)) then
            mineExpandWeek = not mineExpandWeek; mineExpandToday = false
        end
        
        imgui.SetCursorScreenPos(imgui.ImVec2(statPos.x, statPos.y + statCardH))
        imgui.Dummy(imgui.ImVec2(listW, 0))
        
        if mineExpandToday then
            imgui.Spacing()
            local tPos = imgui.GetCursorScreenPos()
            local tableWidth2 = imgui.GetWindowWidth() - 25
            local rowH2 = 24; local halfRows = math.ceil(#config.resourceOrder / 2)
            
            drawList:AddRectFilled(tPos, imgui.ImVec2(tPos.x + tableWidth2, tPos.y + halfRows * rowH2 + 4), 0xFF141414, 8)
            drawList:AddRect(tPos, imgui.ImVec2(tPos.x + tableWidth2, tPos.y + halfRows * rowH2 + 4), 0xFF2A2A2A, 8, 15, 1.0)
            
            for i = 1, halfRows do
                local k = config.resourceOrder[i]
                local y = tPos.y + (i - 1) * rowH2
                local rowBgColor = (i % 2 == 0) and 0xFF1E1E1E or 0xFF181818
                drawList:AddRectFilled(imgui.ImVec2(tPos.x + 2, y + 1), imgui.ImVec2(tPos.x + tableWidth2 / 2 - 2, y + rowH2 - 1), rowBgColor)
                drawList:AddText(imgui.ImVec2(tPos.x + 8, y + 4), 0xFFCCCCCC, u8(config.resourceNames[k]))
                local amtStr = formatNumber(todayData[k] or 0); local amtW = imgui.CalcTextSize(amtStr).x
                drawList:AddText(imgui.ImVec2(tPos.x + tableWidth2 / 2 - amtW - 12, y + 4), 0xFFFFCC00, amtStr)
            end
            for i = halfRows + 1, #config.resourceOrder do
                local k = config.resourceOrder[i]
                local y = tPos.y + (i - halfRows - 1) * rowH2
                local rowBgColor = ((i - halfRows) % 2 == 0) and 0xFF1E1E1E or 0xFF181818
                drawList:AddRectFilled(imgui.ImVec2(tPos.x + tableWidth2 / 2 + 2, y + 1), imgui.ImVec2(tPos.x + tableWidth2 - 2, y + rowH2 - 1), rowBgColor)
                drawList:AddText(imgui.ImVec2(tPos.x + tableWidth2 / 2 + 8, y + 4), 0xFFCCCCCC, u8(config.resourceNames[k]))
                local amtStr = formatNumber(todayData[k] or 0); local amtW = imgui.CalcTextSize(amtStr).x
                drawList:AddText(imgui.ImVec2(tPos.x + tableWidth2 - amtW - 12, y + 4), 0xFFFFCC00, amtStr)
            end
            
            imgui.SetCursorScreenPos(imgui.ImVec2(tPos.x, tPos.y + halfRows * rowH2 + 4))
            imgui.Dummy(imgui.ImVec2(tableWidth2, 4))
        end
        
        if mineExpandWeek then
            imgui.Spacing()
            local tPos = imgui.GetCursorScreenPos()
            local tableWidth2 = imgui.GetWindowWidth() - 25
            local rowH2 = 24; local halfRows = math.ceil(#config.resourceOrder / 2)
            
            drawList:AddRectFilled(tPos, imgui.ImVec2(tPos.x + tableWidth2, tPos.y + halfRows * rowH2 + 4), 0xFF141414, 8)
            drawList:AddRect(tPos, imgui.ImVec2(tPos.x + tableWidth2, tPos.y + halfRows * rowH2 + 4), 0xFF2A2A2A, 8, 15, 1.0)
            
            for i = 1, halfRows do
                local k = config.resourceOrder[i]
                local y = tPos.y + (i - 1) * rowH2
                local rowBgColor = (i % 2 == 0) and 0xFF1E1E1E or 0xFF181818
                drawList:AddRectFilled(imgui.ImVec2(tPos.x + 2, y + 1), imgui.ImVec2(tPos.x + tableWidth2 / 2 - 2, y + rowH2 - 1), rowBgColor)
                drawList:AddText(imgui.ImVec2(tPos.x + 8, y + 4), 0xFFCCCCCC, u8(config.resourceNames[k]))
                local amtStr = formatNumber(weekData[k] or 0); local amtW = imgui.CalcTextSize(amtStr).x
                drawList:AddText(imgui.ImVec2(tPos.x + tableWidth2 / 2 - amtW - 12, y + 4), 0xFF33CCFF, amtStr)
            end
            for i = halfRows + 1, #config.resourceOrder do
                local k = config.resourceOrder[i]
                local y = tPos.y + (i - halfRows - 1) * rowH2
                local rowBgColor = ((i - halfRows) % 2 == 0) and 0xFF1E1E1E or 0xFF181818
                drawList:AddRectFilled(imgui.ImVec2(tPos.x + tableWidth2 / 2 + 2, y + 1), imgui.ImVec2(tPos.x + tableWidth2 - 2, y + rowH2 - 1), rowBgColor)
                drawList:AddText(imgui.ImVec2(tPos.x + tableWidth2 / 2 + 8, y + 4), 0xFFCCCCCC, u8(config.resourceNames[k]))
                local amtStr = formatNumber(weekData[k] or 0); local amtW = imgui.CalcTextSize(amtStr).x
                drawList:AddText(imgui.ImVec2(tPos.x + tableWidth2 - amtW - 12, y + 4), 0xFF33CCFF, amtStr)
            end
            
            imgui.SetCursorScreenPos(imgui.ImVec2(tPos.x, tPos.y + halfRows * rowH2 + 4))
            imgui.Dummy(imgui.ImVec2(tableWidth2, 4))
        end
        
        imgui.Spacing(); imgui.Separator(); imgui.Spacing()
        
        local availableDates = getAvailableDates()
        local seenDates = {}
        for _, d in ipairs(availableDates) do seenDates[d] = true end
        
        if #availableDates > 0 then
            if not imStatCalendarMineDate then
                imStatCalendarMineDate = availableDates[1]
                local yy, mm = imStatCalendarMineDate:match("(%d+)-(%d+)-")
                imStatCalendarMineYear = tonumber(yy); imStatCalendarMineMonth = tonumber(mm)
            end
            
            local btnW = imgui.GetWindowWidth() - 25
            local btnPos = imgui.GetCursorScreenPos()
            local hovered = (imgui.GetMousePos().x >= btnPos.x and imgui.GetMousePos().x <= btnPos.x + btnW and imgui.GetMousePos().y >= btnPos.y and imgui.GetMousePos().y <= btnPos.y + 30)
            local bg = hovered and 0xFF222222 or 0xFF1A1A1A
            local border = hovered and 0xFF555555 or 0xFF333333
            drawList:AddRectFilled(btnPos, imgui.ImVec2(btnPos.x + btnW, btnPos.y + 30), bg, 4)
            drawList:AddRect(btnPos, imgui.ImVec2(btnPos.x + btnW, btnPos.y + 30), border, 4, 15, 1.0)
            local y2, m2, d2 = imStatCalendarMineDate:match("(%d+)-(%d+)-(%d+)")
            local displayDate = imStatCalendarMineDate
            if y2 and m2 and d2 then displayDate = d2 .. "." .. m2 .. "." .. y2 end
            drawList:AddText(imgui.ImVec2(btnPos.x + 10, btnPos.y + 6), 0xFF1AE591, fa.ICON_CALENDAR .. " " .. displayDate)
            drawList:AddText(imgui.ImVec2(btnPos.x + btnW - 20, btnPos.y + 6), 0xFF888888, fa.ICON_ARROW_DOWN)
            imgui.SetCursorScreenPos(btnPos)
            if imgui.InvisibleButton("##stat_mine_date_btn", imgui.ImVec2(btnW, 30)) then
                imgui.OpenPopup("##stat_mine_calendar_popup")
            end
            
            if imgui.BeginPopup("##stat_mine_calendar_popup") then
                local monthNamesRu = {u8("Январь"), u8("Февраль"), u8("Март"), u8("Апрель"), u8("Май"), u8("Июнь"), u8("Июль"), u8("Август"), u8("Сентябрь"), u8("Октябрь"), u8("Ноябрь"), u8("Декабрь")}
                local weekdayNamesRu = {u8("Пн"), u8("Вт"), u8("Ср"), u8("Чт"), u8("Пт"), u8("Сб"), u8("Вс")}
                local todayStr = getGameDate()
                local ACCENT = 0xFF6078E0; local TODAY_RING = 0xFFFFFFFF
                local WEEKEND_COL = 0xFF6078E0; local DOT_GREEN = 0xFFD4BC00
                
                local function daysInMonth(yy, mm)
                    local dim = {31,28,31,30,31,30,31,31,30,31,30,31}
                    if mm == 2 and (yy % 4 == 0 and (yy % 100 ~= 0 or yy % 400 == 0)) then return 29 end
                    return dim[mm]
                end
                local function firstWeekdayOfMonth(yy, mm)
                    local t = os.time({year = yy, month = mm, day = 1, hour = 12})
                    local w = tonumber(os.date("%w", t)); if w == 0 then w = 7 end; return w
                end
                
                local calDrawList = imgui.GetWindowDrawList()
                local cellSize = 34; local cellGap = 2; local step = cellSize + cellGap; local headerW = step * 7
                local headerPos = imgui.GetCursorScreenPos(); local headerH = 30; local btnSz = 24
                
                local leftBtnX = headerPos.x; local leftBtnY = headerPos.y + (headerH - btnSz) / 2
                local mouseP = imgui.GetMousePos()
                local leftHovered = (mouseP.x >= leftBtnX and mouseP.x <= leftBtnX + btnSz and mouseP.y >= leftBtnY and mouseP.y <= leftBtnY + btnSz)
                local leftCenter = imgui.ImVec2(leftBtnX + btnSz / 2, leftBtnY + btnSz / 2)
                calDrawList:AddCircleFilled(leftCenter, btnSz / 2, leftHovered and 0xFF2E2E2E or 0xFF1C1C1C, 20)
                calDrawList:AddText(imgui.ImVec2(leftCenter.x - imgui.CalcTextSize(fa.ICON_ANGLE_LEFT).x / 2, leftCenter.y - imgui.CalcTextSize(fa.ICON_ANGLE_LEFT).y / 2), leftHovered and 0xFFFFFFFF or 0xFFAAAAAA, fa.ICON_ANGLE_LEFT)
                imgui.SetCursorScreenPos(imgui.ImVec2(leftBtnX, leftBtnY))
                if imgui.InvisibleButton("##stat_mine_left", imgui.ImVec2(btnSz, btnSz)) then
                    imStatCalendarMineMonth = imStatCalendarMineMonth - 1
                    if imStatCalendarMineMonth < 1 then imStatCalendarMineMonth = 12; imStatCalendarMineYear = imStatCalendarMineYear - 1 end
                end
                
                local rightBtnX = headerPos.x + headerW - btnSz; local rightBtnY = leftBtnY
                local rightHovered = (mouseP.x >= rightBtnX and mouseP.x <= rightBtnX + btnSz and mouseP.y >= rightBtnY and mouseP.y <= rightBtnY + btnSz)
                local rightCenter = imgui.ImVec2(rightBtnX + btnSz / 2, rightBtnY + btnSz / 2)
                calDrawList:AddCircleFilled(rightCenter, btnSz / 2, rightHovered and 0xFF2E2E2E or 0xFF1C1C1C, 20)
                calDrawList:AddText(imgui.ImVec2(rightCenter.x - imgui.CalcTextSize(fa.ICON_ANGLE_RIGHT).x / 2, rightCenter.y - imgui.CalcTextSize(fa.ICON_ANGLE_RIGHT).y / 2), rightHovered and 0xFFFFFFFF or 0xFFAAAAAA, fa.ICON_ANGLE_RIGHT)
                imgui.SetCursorScreenPos(imgui.ImVec2(rightBtnX, rightBtnY))
                if imgui.InvisibleButton("##stat_mine_right", imgui.ImVec2(btnSz, btnSz)) then
                    imStatCalendarMineMonth = imStatCalendarMineMonth + 1
                    if imStatCalendarMineMonth > 12 then imStatCalendarMineMonth = 1; imStatCalendarMineYear = imStatCalendarMineYear + 1 end
                end
                
                local monthName = monthNamesRu[imStatCalendarMineMonth]; local yearName = tostring(imStatCalendarMineYear)
                local monthNameW = imgui.CalcTextSize(monthName).x; local monthNameH = imgui.CalcTextSize(monthName).y
                local yearNameW = imgui.CalcTextSize(yearName).x; local yearNameH = imgui.CalcTextSize(yearName).y
                local totalH = monthNameH + yearNameH + 2; local textStartY = headerPos.y + (headerH - totalH) / 2
                calDrawList:AddText(imgui.ImVec2(headerPos.x + (headerW - monthNameW) / 2, textStartY), 0xFF6078E0, monthName)
                calDrawList:AddText(imgui.ImVec2(headerPos.x + (headerW - yearNameW) / 2, textStartY + monthNameH + 2), 0xFFAAAAAA, yearName)
                
                imgui.SetCursorScreenPos(imgui.ImVec2(headerPos.x, headerPos.y + headerH)); imgui.Dummy(imgui.ImVec2(headerW, 4))
                local subSepY = imgui.GetCursorScreenPos().y + 2
                calDrawList:AddLine(imgui.ImVec2(headerPos.x, subSepY), imgui.ImVec2(headerPos.x + headerW, subSepY), 0xFF2A2A2A, 1.0)
                imgui.SetCursorScreenPos(imgui.ImVec2(headerPos.x, subSepY + 8))
                
                local hdrPos2 = imgui.GetCursorScreenPos()
                for i, wd in ipairs(weekdayNamesRu) do
                    local isWeekend = (i == 6 or i == 7)
                    calDrawList:AddText(imgui.ImVec2(hdrPos2.x + (i - 1) * step + (cellSize - imgui.CalcTextSize(wd).x) / 2, hdrPos2.y), isWeekend and WEEKEND_COL or 0xFF666666, wd)
                end
                imgui.Dummy(imgui.ImVec2(headerW, 18))
                
                local startWd = firstWeekdayOfMonth(imStatCalendarMineYear, imStatCalendarMineMonth)
                local totalDays = daysInMonth(imStatCalendarMineYear, imStatCalendarMineMonth)
                local gridPos = imgui.GetCursorScreenPos()
                
                local row, col = 0, startWd - 1
                for dnum = 1, totalDays do
                    local cellX = gridPos.x + col * step; local cellY = gridPos.y + row * step
                    local center = imgui.ImVec2(cellX + cellSize / 2, cellY + cellSize / 2); local radius = cellSize / 2 - 1
                    local dateStr = string.format("%04d-%02d-%02d", imStatCalendarMineYear, imStatCalendarMineMonth, dnum)
                    local hasData = seenDates[dateStr] == true
                    local isSelected = (dateStr == imStatCalendarMineDate); local isToday = (dateStr == todayStr)
                    local cellHovered = (mouseP.x >= cellX and mouseP.x <= cellX + cellSize and mouseP.y >= cellY and mouseP.y <= cellY + cellSize)
                    
                    if isSelected and isToday then
                        calDrawList:AddCircleFilled(center, radius, ACCENT, 24); calDrawList:AddCircle(center, radius, TODAY_RING, 24, 2.0)
                    elseif isSelected then calDrawList:AddCircleFilled(center, radius, ACCENT, 24)
                    elseif isToday then calDrawList:AddCircle(center, radius, TODAY_RING, 24, 1.5)
                    elseif cellHovered then calDrawList:AddCircle(center, radius, 0xFF444444, 24, 1.0) end
                    
                    local dayStr = tostring(dnum); local dayStrSz = imgui.CalcTextSize(dayStr)
                    local textCol
                    if isSelected then textCol = 0xFFFFFFFF elseif isToday then textCol = 0xFF1AE591
                    elseif hasData then textCol = 0xFFCCCCCC elseif cellHovered then textCol = 0xFFEEEEEE else textCol = 0xFF666666 end
                    calDrawList:AddText(imgui.ImVec2(center.x - dayStrSz.x / 2, center.y - dayStrSz.y / 2 - (hasData and 3 or 0)), textCol, dayStr)
                    
                    if hasData then
                        local dotCol = isSelected and 0xFFFFFFFF or DOT_GREEN
                        calDrawList:AddCircleFilled(imgui.ImVec2(center.x, center.y + dayStrSz.y / 2 + 2), 2.0, dotCol, 12)
                    end
                    if cellHovered then
                        local dayData = getDayStats(dateStr); local dayTotal = 0
                        for _, k in ipairs(configs[WORK_TYPES.MINE].resourceOrder) do
                            dayTotal = dayTotal + ((dayData[k] or 0) * getPriceForResource(k, WORK_TYPES.MINE))
                        end
                        imgui.BeginTooltip(); imgui.Text(dayStr .. " " .. monthNamesRu[imStatCalendarMineMonth])
                        if dayTotal > 0 then imgui.Text(u8("Доход: ") .. formatNumber(dayTotal) .. "$") else imgui.Text(u8("Нет записей")) end
                        imgui.EndTooltip()
                    end
                    imgui.SetCursorScreenPos(imgui.ImVec2(cellX, cellY))
                    if imgui.InvisibleButton("##stat_mine_cal_" .. dateStr, imgui.ImVec2(cellSize, cellSize)) then
                        imStatCalendarMineDate = dateStr; imgui.CloseCurrentPopup()
                    end
                    col = col + 1; if col > 6 then col = 0; row = row + 1 end
                end
                
                imgui.SetCursorScreenPos(imgui.ImVec2(gridPos.x, gridPos.y + (row + 1) * step + 4))
                local legY = imgui.GetCursorScreenPos().y + 6
                calDrawList:AddLine(imgui.ImVec2(headerPos.x, legY), imgui.ImVec2(headerPos.x + headerW, legY), 0xFF2A2A2A, 1.0)
                local legendY = legY + 8
                calDrawList:AddCircleFilled(imgui.ImVec2(headerPos.x + 6, legendY + 5), 2.0, DOT_GREEN, 12)
                calDrawList:AddText(imgui.ImVec2(headerPos.x + 14, legendY), 0xFF777777, u8("Есть записи"))
                local todayLabel = u8("Сегодня"); local todayLabelW = imgui.CalcTextSize(todayLabel).x
                calDrawList:AddCircle(imgui.ImVec2(headerPos.x + headerW - todayLabelW - 16, legendY + 5), 4.0, TODAY_RING, 12, 1.2)
                calDrawList:AddText(imgui.ImVec2(headerPos.x + headerW - todayLabelW, legendY), 0xFF777777, todayLabel)
                imgui.SetCursorScreenPos(imgui.ImVec2(headerPos.x, legendY + 20)); imgui.Dummy(imgui.ImVec2(headerW, 1))
                imgui.EndPopup()
            end
            
            imgui.Spacing()
            
            local dayData = getDayStats(imStatCalendarMineDate)
            local dayTotal = 0
            for _, k in ipairs(config.resourceOrder) do
                dayTotal = dayTotal + ((dayData[k] or 0) * getPriceForResource(k, WORK_TYPES.MINE))
            end
            
            local tPos = imgui.GetCursorScreenPos()
            local tableWidth2 = imgui.GetWindowWidth() - 25
            local rowH2 = 26; local halfRows = math.ceil(#config.resourceOrder / 2)
            local totalRowH = 32; local tblH2 = halfRows * rowH2 + totalRowH
            
            drawList:AddRectFilled(tPos, imgui.ImVec2(tPos.x + tableWidth2, tPos.y + tblH2), 0xFF141414, 8)
            drawList:AddRect(tPos, imgui.ImVec2(tPos.x + tableWidth2, tPos.y + tblH2), 0xFF2A2A2A, 8, 15, 1.0)
            
            for i = 1, halfRows do
                local k = config.resourceOrder[i]
                local y = tPos.y + (i - 1) * rowH2
                local rowBgColor = (i % 2 == 0) and 0xFF1E1E1E or 0xFF181818
                drawList:AddRectFilled(imgui.ImVec2(tPos.x + 2, y + 1), imgui.ImVec2(tPos.x + tableWidth2 / 2 - 2, y + rowH2 - 1), rowBgColor)
                drawList:AddText(imgui.ImVec2(tPos.x + 8, y + 5), 0xFFCCCCCC, u8(config.resourceNames[k]))
                local amtStr = formatNumber(dayData[k] or 0); local amtW = imgui.CalcTextSize(amtStr).x
                drawList:AddText(imgui.ImVec2(tPos.x + tableWidth2 / 2 - amtW - 12, y + 5), 0xFFFFCC00, amtStr)
            end
            for i = halfRows + 1, #config.resourceOrder do
                local k = config.resourceOrder[i]
                local y = tPos.y + (i - halfRows - 1) * rowH2
                local rowBgColor = ((i - halfRows) % 2 == 0) and 0xFF1E1E1E or 0xFF181818
                drawList:AddRectFilled(imgui.ImVec2(tPos.x + tableWidth2 / 2 + 2, y + 1), imgui.ImVec2(tPos.x + tableWidth2 - 2, y + rowH2 - 1), rowBgColor)
                drawList:AddText(imgui.ImVec2(tPos.x + tableWidth2 / 2 + 8, y + 5), 0xFFCCCCCC, u8(config.resourceNames[k]))
                local amtStr = formatNumber(dayData[k] or 0); local amtW = imgui.CalcTextSize(amtStr).x
                drawList:AddText(imgui.ImVec2(tPos.x + tableWidth2 - amtW - 12, y + 5), 0xFFFFCC00, amtStr)
            end
            
            local totalY = tPos.y + halfRows * rowH2
            drawList:AddRectFilled(imgui.ImVec2(tPos.x + 2, totalY + 1), imgui.ImVec2(tPos.x + tableWidth2 - 2, totalY + totalRowH - 2), 0xFF1E2E22, 6)
            drawList:AddText(imgui.ImVec2(tPos.x + 12, totalY + 9), 0xFF888888, u8("Доход"))
            local totalStr = formatNumber(dayTotal) .. "$"; local totalW2 = imgui.CalcTextSize(totalStr).x
            drawList:AddText(imgui.ImVec2(tPos.x + tableWidth2 - totalW2 - 12, totalY + 9), 0xFF33CC66, totalStr)
            
            imgui.SetCursorScreenPos(imgui.ImVec2(tPos.x, tPos.y + tblH2 + 8))
            imgui.Dummy(imgui.ImVec2(tableWidth2, 0))
        else
            imgui.TextColored(imgui.ImVec4(0.8, 0.3, 0.3, 1), u8("Нет данных"))
        end
    end
end
function drawSawmillTab()
    if not config then
        imgui.Text(u8("Сначала выберите режим работы (нажмите Лесопилка в меню слева)"))
        return
    end
    local drawList = imgui.GetWindowDrawList()
    local listW = imgui.GetWindowWidth() - 25
    
    -- Три раздела: Меню / Цены / Статистика
    if not sawSectionTab then sawSectionTab = imgui.ImInt(0) end
    local sawSectionNames = {u8("Меню"), u8("Цены"), u8("Статистика")}
    local sawSectionBtnW = (imgui.GetWindowWidth() - 25 - 8) / 3
    for i, name in ipairs(sawSectionNames) do
        if i > 1 then imgui.SameLine() end
        if StyleButton(name, nil, sawSectionBtnW, sawSectionTab.v == i - 1) then
            local prev = sawSectionTab.v
            sawSectionTab.v = i - 1
            if sawSectionTab.v == 1 and prev ~= 1 and not pricesLoading then loadGlobalPrices() end
        end
    end
    imgui.Spacing(); imgui.Separator(); imgui.Spacing()
    
    
    --  МЕНЮ
    
    if sawSectionTab.v == 0 then
        local scanColor, scanIcon, scanStatusText
        if scanState.active then
            scanColor = 0xFFFFCC33; scanIcon = fa.ICON_REFRESH; scanStatusText = u8("Сканирование: ") .. u8(scanState.statusText)
        elseif scannedThisSession[currentWork] then
            scanColor = 0xFF33CC66; scanIcon = fa.ICON_CHECK; scanStatusText = u8("Инвентарь отсканирован")
        else
            scanColor = 0xFFFF8833; scanIcon = fa.ICON_EXCLAMATION_TRIANGLE; scanStatusText = u8("Инвентарь не отсканирован")
        end
        
        local cardX = imgui.GetCursorScreenPos().x
        local cardY = imgui.GetCursorScreenPos().y
        local scanCardH = 56
        drawList:AddRectFilled(imgui.ImVec2(cardX, cardY), imgui.ImVec2(cardX + listW, cardY + scanCardH), 0xFF141414, 8)
        drawList:AddRect(imgui.ImVec2(cardX, cardY), imgui.ImVec2(cardX + listW, cardY + scanCardH), 0xFF2A2A2A, 8, 15, 1.0)
        drawList:AddText(imgui.ImVec2(cardX + 14, cardY + 10), scanColor, scanIcon)
        drawList:AddText(imgui.ImVec2(cardX + 38, cardY + 10), scanColor, scanStatusText)
        drawList:AddText(imgui.ImVec2(cardX + 14, cardY + 30), 0xFF666666, u8("Сканируй инвентарь перед началом сбора ресурсов"))
        
        imgui.SetCursorScreenPos(imgui.ImVec2(cardX, cardY + scanCardH + 8))
        local scanBtnText = scanState.active and u8("Сканирование...") or (scannedThisSession[currentWork] and u8("Пересканировать инвентарь") or u8("Сканировать инвентарь"))
        if scanState.active then
            imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.3, 0.3, 0.3, 0.5))
            imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.3, 0.3, 0.3, 0.5))
            imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.3, 0.3, 0.3, 0.5))
            StyleButton(scanBtnText, fa.ICON_SEARCH)
            imgui.PopStyleColor(3)
        else
            if StyleButton(scanBtnText, fa.ICON_SEARCH) then startInventoryScan() end
        end
        
        imgui.Spacing(); imgui.Separator(); imgui.Spacing()
        
        if ToggleSwitch(u8("Считать ресурсы с лесопилки"), cb_sawmill) then
            settings.sawmillEnabled = cb_sawmill.v; saveConfig(); needSave = true
        end
        if ToggleSwitch(u8("Показывать оверлей на экране"), cb_sawmill_overlay) then
            if cb_sawmill_overlay.v then
                settings.sawmillOverlayEnabled = true
                settings.farmOverlayEnabled = false
                settings.mineOverlayEnabled = false
                settings.oilOverlayEnabled = false
                cb_farm_overlay.v = false
                cb_mine_overlay.v = false
                cb_oil_overlay.v = false
                if settings.overlayAutoTimer and not overlayTimer.running then
                    overlayTimer.running = true; overlayTimer.startTime = os.time()
                    overlayTimer.elapsed = 0; overlayTimer.displayedTime = "00:00:00"
                end
            else
                settings.sawmillOverlayEnabled = false
            end
            saveConfig()
        end
        
        imgui.Spacing(); imgui.Separator(); imgui.Spacing()
        
        -- Быстрый итог за сегодня (раскрывающийся)
        if not sawExpandIncome then sawExpandIncome = false end
        local todayData = getTodayStats()
        local todayTotal = 0
        for _, k in ipairs(config.resourceOrder) do
            todayTotal = todayTotal + ((todayData[k] or 0) * getPriceForResource(k, WORK_TYPES.SAWMILL))
        end
        local todayCardX = imgui.GetCursorScreenPos().x
        local todayCardY = imgui.GetCursorScreenPos().y
        local todayCardH = 50
        local incomeHovered = (imgui.GetMousePos().x >= todayCardX and imgui.GetMousePos().x <= todayCardX + listW and imgui.GetMousePos().y >= todayCardY and imgui.GetMousePos().y <= todayCardY + todayCardH)
        drawList:AddRectFilled(imgui.ImVec2(todayCardX, todayCardY), imgui.ImVec2(todayCardX + listW, todayCardY + todayCardH), incomeHovered and 0xFF1E1E1E or 0xFF141414, 8)
        drawList:AddRect(imgui.ImVec2(todayCardX, todayCardY), imgui.ImVec2(todayCardX + listW, todayCardY + todayCardH), sawExpandIncome and 0xFF1AE591 or 0xFF2A2A2A, 8, 15, sawExpandIncome and 2.0 or 1.0)
        drawList:AddText(imgui.ImVec2(todayCardX + 14, todayCardY + 8), 0xFF888888, u8("Доход за сегодня"))
        drawList:AddText(imgui.ImVec2(todayCardX + 14, todayCardY + 26), 0xFF33CC66, formatNumber(todayTotal) .. "$")
        local incomeArrow = sawExpandIncome and fa.ICON_ANGLE_UP or fa.ICON_ANGLE_DOWN
        local incomeArrowW = imgui.CalcTextSize(incomeArrow).x
        drawList:AddText(imgui.ImVec2(todayCardX + listW - incomeArrowW - 14, todayCardY + 26), 0xFF888888, incomeArrow)
        imgui.SetCursorScreenPos(imgui.ImVec2(todayCardX, todayCardY))
        if imgui.InvisibleButton("##saw_expand_income", imgui.ImVec2(listW, todayCardH)) then
            sawExpandIncome = not sawExpandIncome
        end
        imgui.SetCursorScreenPos(imgui.ImVec2(todayCardX, todayCardY + todayCardH))
        imgui.Dummy(imgui.ImVec2(listW, 0))
        
        if sawExpandIncome then
            imgui.Spacing()
            local tPos = imgui.GetCursorScreenPos()
            local tableWidth2 = imgui.GetWindowWidth() - 25
            local rowH2 = 24; local rows2 = #config.resourceOrder
            
            drawList:AddRectFilled(tPos, imgui.ImVec2(tPos.x + tableWidth2, tPos.y + rows2 * rowH2 + 4), 0xFF141414, 8)
            drawList:AddRect(tPos, imgui.ImVec2(tPos.x + tableWidth2, tPos.y + rows2 * rowH2 + 4), 0xFF2A2A2A, 8, 15, 1.0)
            
            for i, k in ipairs(config.resourceOrder) do
                local y = tPos.y + (i - 1) * rowH2
                local rowBgColor = (i % 2 == 0) and 0xFF1E1E1E or 0xFF181818
                drawList:AddRectFilled(imgui.ImVec2(tPos.x + 2, y + 1), imgui.ImVec2(tPos.x + tableWidth2 - 2, y + rowH2 - 1), rowBgColor)
                drawList:AddText(imgui.ImVec2(tPos.x + 12, y + 4), 0xFFCCCCCC, u8(config.resourceNames[k]))
                local amtStr = formatNumber(todayData[k] or 0); local amtW = imgui.CalcTextSize(amtStr).x
                drawList:AddText(imgui.ImVec2(tPos.x + tableWidth2 - amtW - 12, y + 4), 0xFFFFCC00, amtStr)
            end
            
            imgui.SetCursorScreenPos(imgui.ImVec2(tPos.x, tPos.y + rows2 * rowH2 + 4))
            imgui.Dummy(imgui.ImVec2(tableWidth2, 4))
        end
    end
    
    
    --  ЦЕНЫ
    
    if sawSectionTab.v == 1 then
        if ToggleSwitch(u8("Использовать собственные цены"), cb_useCustomSawmillPrices, u8("Отключит возможность участия в рейтинге. Цены из Google таблицы не будут применяться.")) then
            useCustomSawmillPrices = cb_useCustomSawmillPrices.v
            if useCustomSawmillPrices then
                saveLbConfig("", false)
                for _, k in ipairs(configs[WORK_TYPES.SAWMILL].resourceOrder) do
                    if not customPriceEditSaw[k] then
                        customPriceEditSaw[k] = imgui.ImInt(resourcePrices[k] or configs[WORK_TYPES.SAWMILL].defaultPrices[k])
                    end
                end
            end
            if currentWork == WORK_TYPES.SAWMILL then
                loadedLogs = false; loadStats(); cachedTodayStats = nil; cachedWeekStats = nil
            end
            saveCustomPricesConfig()
        end
        imgui.Spacing()
        if not useCustomSawmillPrices then
            imgui.TextColored(imgui.ImVec4(0.6, 0.6, 0.6, 1), u8("Цены средние по Vice City под SA. Авто-обновление раз в сутки."))
        end
        imgui.Spacing()
        if pricesLoading then
            imgui.TextColored(imgui.ImVec4(1.0, 0.8, 0.2, 1), u8("Цены обновляются..."))
            imgui.Spacing()
        end
        if not globalPrices or not next(globalPrices) then
            imgui.TextColored(imgui.ImVec4(1.0, 0.8, 0.2, 1), u8("Цены загружаются..."))
            imgui.Spacing()
        else
            local pos = imgui.GetCursorScreenPos()
            local tableWidth = imgui.GetWindowWidth() - 25
            local headerHeight = 28; local rowHeight = 26; local rows = #config.resourceOrder
            
            drawList:AddRectFilled(pos, imgui.ImVec2(pos.x + tableWidth, pos.y + headerHeight + rows * rowHeight), 0xFF141414, 6)
            drawList:AddRect(pos, imgui.ImVec2(pos.x + tableWidth, pos.y + headerHeight + rows * rowHeight), 0xFF2A2A2A, 6, 15, 1.5)
            drawList:AddText(imgui.ImVec2(pos.x + 10, pos.y + 6), 0xFF1AE591, u8("Ресурс"))
            drawList:AddText(imgui.ImVec2(pos.x + tableWidth/2 + 10, pos.y + 6), 0xFF1AE591, u8("Цена"))
            drawList:AddLine(imgui.ImVec2(pos.x + 6, pos.y + headerHeight), imgui.ImVec2(pos.x + tableWidth - 6, pos.y + headerHeight), 0xFF2A2A2A, 1.5)
            drawList:AddLine(imgui.ImVec2(pos.x + tableWidth/2, pos.y + 8), imgui.ImVec2(pos.x + tableWidth/2, pos.y + headerHeight + rows * rowHeight - 4), 0xFF2A2A2A, 1.0)
            
            for i, k in ipairs(config.resourceOrder) do
                local y = pos.y + headerHeight + (i - 1) * rowHeight
                local rowBgColor = (i % 2 == 0) and 0xFF1E1E1E or 0xFF181818
                drawList:AddRectFilled(imgui.ImVec2(pos.x + 2, y + 1), imgui.ImVec2(pos.x + tableWidth - 2, y + rowHeight - 1), rowBgColor)
                if i > 1 then drawList:AddLine(imgui.ImVec2(pos.x + 6, y), imgui.ImVec2(pos.x + tableWidth - 6, y), 0xFF222222, 0.5) end
                drawList:AddLine(imgui.ImVec2(pos.x + tableWidth/2, y + 2), imgui.ImVec2(pos.x + tableWidth/2, y + rowHeight - 2), 0xFF252525, 0.5)
                drawList:AddText(imgui.ImVec2(pos.x + 10, y + 5), 0xFFFFFFFF, u8(config.resourceNames[k]))
                if useCustomSawmillPrices and customPriceEditSaw[k] then
                    local editPos = imgui.ImVec2(pos.x + tableWidth/2 + 10, y + 2)
                    imgui.SetCursorScreenPos(editPos); imgui.PushItemWidth(130)
                    if imgui.InputInt("##custom_price_saw_" .. k, customPriceEditSaw[k], 1000, 10000) then
                        saveCustomPricesConfig(); needSave = true
                    end
                    imgui.PopItemWidth()
                else
                    drawList:AddText(imgui.ImVec2(pos.x + tableWidth/2 + 10, y + 5), 0xFF33CC33, formatNumber(priceEdit[k].v) .. "$")
                end
            end
            imgui.SetCursorScreenPos(imgui.ImVec2(pos.x, pos.y + headerHeight + rows * rowHeight + 8))
            imgui.Dummy(imgui.ImVec2(tableWidth, 0))
        end
        
        if not useCustomSawmillPrices then
            imgui.Spacing()
            if StyleButton(u8("Обновить цены на актуальные"), fa.ICON_REPEAT) then loadGlobalPrices() end
        end
    end
    
    
    --  СТАТИСТИКА
    
    if sawSectionTab.v == 2 then
        local todayData = getTodayStats()
        local todayTotal = 0
        for _, k in ipairs(config.resourceOrder) do
            todayTotal = todayTotal + ((todayData[k] or 0) * getPriceForResource(k, WORK_TYPES.SAWMILL))
        end
        local weekData = getWeekStats()
        local weekTotal = 0
        for _, k in ipairs(config.resourceOrder) do
            weekTotal = weekTotal + ((weekData[k] or 0) * getPriceForResource(k, WORK_TYPES.SAWMILL))
        end
        
        local spacing = 8
        local cardWidth = (listW - spacing) / 2
        local statCardH = 55
        local statPos = imgui.GetCursorScreenPos()
        
        -- Карточка "За сегодня"
        local todayHovered = (imgui.GetMousePos().x >= statPos.x and imgui.GetMousePos().x <= statPos.x + cardWidth and imgui.GetMousePos().y >= statPos.y and imgui.GetMousePos().y <= statPos.y + statCardH)
        drawList:AddRectFilled(statPos, imgui.ImVec2(statPos.x + cardWidth, statPos.y + statCardH), todayHovered and 0xFF1E1E1E or 0xFF1A1A1A, 6)
        drawList:AddRect(statPos, imgui.ImVec2(statPos.x + cardWidth, statPos.y + statCardH), sawExpandToday and 0xFF1AE591 or 0xFF333333, 6, 15, sawExpandToday and 2.0 or 1.0)
        drawList:AddText(imgui.ImVec2(statPos.x + 10, statPos.y + 8), 0xFF888888, u8("За сегодня"))
        drawList:AddText(imgui.ImVec2(statPos.x + 10, statPos.y + 28), 0xFFFFCC00, formatNumber(todayTotal) .. "$")
        local todayArrow = sawExpandToday and fa.ICON_ANGLE_UP or fa.ICON_ANGLE_DOWN
        local todayArrowW = imgui.CalcTextSize(todayArrow).x
        drawList:AddText(imgui.ImVec2(statPos.x + cardWidth - todayArrowW - 10, statPos.y + 28), 0xFF888888, todayArrow)
        imgui.SetCursorScreenPos(statPos)
        if imgui.InvisibleButton("##saw_expand_today", imgui.ImVec2(cardWidth, statCardH)) then
            sawExpandToday = not sawExpandToday; sawExpandWeek = false
        end
        
        -- Карточка "За неделю"
        local statPos2 = imgui.ImVec2(statPos.x + cardWidth + spacing, statPos.y)
        local weekHovered = (imgui.GetMousePos().x >= statPos2.x and imgui.GetMousePos().x <= statPos2.x + cardWidth and imgui.GetMousePos().y >= statPos2.y and imgui.GetMousePos().y <= statPos2.y + statCardH)
        drawList:AddRectFilled(statPos2, imgui.ImVec2(statPos2.x + cardWidth, statPos2.y + statCardH), weekHovered and 0xFF1E1E1E or 0xFF1A1A1A, 6)
        drawList:AddRect(statPos2, imgui.ImVec2(statPos2.x + cardWidth, statPos2.y + statCardH), sawExpandWeek and 0xFF1AE591 or 0xFF333333, 6, 15, sawExpandWeek and 2.0 or 1.0)
        drawList:AddText(imgui.ImVec2(statPos2.x + 10, statPos2.y + 8), 0xFF888888, u8("За неделю"))
        drawList:AddText(imgui.ImVec2(statPos2.x + 10, statPos2.y + 28), 0xFF33CCFF, formatNumber(weekTotal) .. "$")
        local weekArrow = sawExpandWeek and fa.ICON_ANGLE_UP or fa.ICON_ANGLE_DOWN
        local weekArrowW = imgui.CalcTextSize(weekArrow).x
        drawList:AddText(imgui.ImVec2(statPos2.x + cardWidth - weekArrowW - 10, statPos2.y + 28), 0xFF888888, weekArrow)
        imgui.SetCursorScreenPos(statPos2)
        if imgui.InvisibleButton("##saw_expand_week", imgui.ImVec2(cardWidth, statCardH)) then
            sawExpandWeek = not sawExpandWeek; sawExpandToday = false
        end
        
        imgui.SetCursorScreenPos(imgui.ImVec2(statPos.x, statPos.y + statCardH))
        imgui.Dummy(imgui.ImVec2(listW, 0))
        
        if sawExpandToday then
            imgui.Spacing()
            local tPos = imgui.GetCursorScreenPos()
            local tableWidth2 = imgui.GetWindowWidth() - 25
            local rowH2 = 24; local rows2 = #config.resourceOrder
            
            drawList:AddRectFilled(tPos, imgui.ImVec2(tPos.x + tableWidth2, tPos.y + rows2 * rowH2 + 4), 0xFF141414, 8)
            drawList:AddRect(tPos, imgui.ImVec2(tPos.x + tableWidth2, tPos.y + rows2 * rowH2 + 4), 0xFF2A2A2A, 8, 15, 1.0)
            
            for i, k in ipairs(config.resourceOrder) do
                local y = tPos.y + (i - 1) * rowH2
                local rowBgColor = (i % 2 == 0) and 0xFF1E1E1E or 0xFF181818
                drawList:AddRectFilled(imgui.ImVec2(tPos.x + 2, y + 1), imgui.ImVec2(tPos.x + tableWidth2 - 2, y + rowH2 - 1), rowBgColor)
                drawList:AddText(imgui.ImVec2(tPos.x + 12, y + 4), 0xFFCCCCCC, u8(config.resourceNames[k]))
                local amtStr = formatNumber(todayData[k] or 0); local amtW = imgui.CalcTextSize(amtStr).x
                drawList:AddText(imgui.ImVec2(tPos.x + tableWidth2 - amtW - 12, y + 4), 0xFFFFCC00, amtStr)
            end
            
            imgui.SetCursorScreenPos(imgui.ImVec2(tPos.x, tPos.y + rows2 * rowH2 + 4))
            imgui.Dummy(imgui.ImVec2(tableWidth2, 4))
        end
        
        if sawExpandWeek then
            imgui.Spacing()
            local tPos = imgui.GetCursorScreenPos()
            local tableWidth2 = imgui.GetWindowWidth() - 25
            local rowH2 = 24; local rows2 = #config.resourceOrder
            
            drawList:AddRectFilled(tPos, imgui.ImVec2(tPos.x + tableWidth2, tPos.y + rows2 * rowH2 + 4), 0xFF141414, 8)
            drawList:AddRect(tPos, imgui.ImVec2(tPos.x + tableWidth2, tPos.y + rows2 * rowH2 + 4), 0xFF2A2A2A, 8, 15, 1.0)
            
            for i, k in ipairs(config.resourceOrder) do
                local y = tPos.y + (i - 1) * rowH2
                local rowBgColor = (i % 2 == 0) and 0xFF1E1E1E or 0xFF181818
                drawList:AddRectFilled(imgui.ImVec2(tPos.x + 2, y + 1), imgui.ImVec2(tPos.x + tableWidth2 - 2, y + rowH2 - 1), rowBgColor)
                drawList:AddText(imgui.ImVec2(tPos.x + 12, y + 4), 0xFFCCCCCC, u8(config.resourceNames[k]))
                local amtStr = formatNumber(weekData[k] or 0); local amtW = imgui.CalcTextSize(amtStr).x
                drawList:AddText(imgui.ImVec2(tPos.x + tableWidth2 - amtW - 12, y + 4), 0xFF33CCFF, amtStr)
            end
            
            imgui.SetCursorScreenPos(imgui.ImVec2(tPos.x, tPos.y + rows2 * rowH2 + 4))
            imgui.Dummy(imgui.ImVec2(tableWidth2, 4))
        end
        
        imgui.Spacing(); imgui.Separator(); imgui.Spacing()
        
        local availableDates = getAvailableDates()
        local seenDates = {}
        for _, d in ipairs(availableDates) do seenDates[d] = true end
        
        if #availableDates > 0 then
            if not imStatCalendarSawDate then
                imStatCalendarSawDate = availableDates[1]
                local yy, mm = imStatCalendarSawDate:match("(%d+)-(%d+)-")
                imStatCalendarSawYear = tonumber(yy); imStatCalendarSawMonth = tonumber(mm)
            end
            
            local btnW = imgui.GetWindowWidth() - 25
            local btnPos = imgui.GetCursorScreenPos()
            local hovered = (imgui.GetMousePos().x >= btnPos.x and imgui.GetMousePos().x <= btnPos.x + btnW and imgui.GetMousePos().y >= btnPos.y and imgui.GetMousePos().y <= btnPos.y + 30)
            local bg = hovered and 0xFF222222 or 0xFF1A1A1A
            local border = hovered and 0xFF555555 or 0xFF333333
            drawList:AddRectFilled(btnPos, imgui.ImVec2(btnPos.x + btnW, btnPos.y + 30), bg, 4)
            drawList:AddRect(btnPos, imgui.ImVec2(btnPos.x + btnW, btnPos.y + 30), border, 4, 15, 1.0)
            local y2, m2, d2 = imStatCalendarSawDate:match("(%d+)-(%d+)-(%d+)")
            local displayDate = imStatCalendarSawDate
            if y2 and m2 and d2 then displayDate = d2 .. "." .. m2 .. "." .. y2 end
            drawList:AddText(imgui.ImVec2(btnPos.x + 10, btnPos.y + 6), 0xFF1AE591, fa.ICON_CALENDAR .. " " .. displayDate)
            drawList:AddText(imgui.ImVec2(btnPos.x + btnW - 20, btnPos.y + 6), 0xFF888888, fa.ICON_ARROW_DOWN)
            imgui.SetCursorScreenPos(btnPos)
            if imgui.InvisibleButton("##stat_saw_date_btn", imgui.ImVec2(btnW, 30)) then
                imgui.OpenPopup("##stat_saw_calendar_popup")
            end
            
            if imgui.BeginPopup("##stat_saw_calendar_popup") then
                local monthNamesRu = {u8("Январь"), u8("Февраль"), u8("Март"), u8("Апрель"), u8("Май"), u8("Июнь"), u8("Июль"), u8("Август"), u8("Сентябрь"), u8("Октябрь"), u8("Ноябрь"), u8("Декабрь")}
                local weekdayNamesRu = {u8("Пн"), u8("Вт"), u8("Ср"), u8("Чт"), u8("Пт"), u8("Сб"), u8("Вс")}
                local todayStr = getGameDate()
                local ACCENT = 0xFF6078E0; local TODAY_RING = 0xFFFFFFFF
                local WEEKEND_COL = 0xFF6078E0; local DOT_GREEN = 0xFFD4BC00
                
                local function daysInMonth(yy, mm)
                    local dim = {31,28,31,30,31,30,31,31,30,31,30,31}
                    if mm == 2 and (yy % 4 == 0 and (yy % 100 ~= 0 or yy % 400 == 0)) then return 29 end
                    return dim[mm]
                end
                local function firstWeekdayOfMonth(yy, mm)
                    local t = os.time({year = yy, month = mm, day = 1, hour = 12})
                    local w = tonumber(os.date("%w", t)); if w == 0 then w = 7 end; return w
                end
                
                local calDrawList = imgui.GetWindowDrawList()
                local cellSize = 34; local cellGap = 2; local step = cellSize + cellGap; local headerW = step * 7
                local headerPos = imgui.GetCursorScreenPos(); local headerH = 30; local btnSz = 24
                
                local leftBtnX = headerPos.x; local leftBtnY = headerPos.y + (headerH - btnSz) / 2
                local mouseP = imgui.GetMousePos()
                local leftHovered = (mouseP.x >= leftBtnX and mouseP.x <= leftBtnX + btnSz and mouseP.y >= leftBtnY and mouseP.y <= leftBtnY + btnSz)
                local leftCenter = imgui.ImVec2(leftBtnX + btnSz / 2, leftBtnY + btnSz / 2)
                calDrawList:AddCircleFilled(leftCenter, btnSz / 2, leftHovered and 0xFF2E2E2E or 0xFF1C1C1C, 20)
                local leftArrow = fa.ICON_ANGLE_LEFT; local leftArrowSz = imgui.CalcTextSize(leftArrow)
                calDrawList:AddText(imgui.ImVec2(leftCenter.x - leftArrowSz.x / 2, leftCenter.y - leftArrowSz.y / 2), leftHovered and 0xFFFFFFFF or 0xFFAAAAAA, leftArrow)
                imgui.SetCursorScreenPos(imgui.ImVec2(leftBtnX, leftBtnY))
                if imgui.InvisibleButton("##stat_saw_left", imgui.ImVec2(btnSz, btnSz)) then
                    imStatCalendarSawMonth = imStatCalendarSawMonth - 1
                    if imStatCalendarSawMonth < 1 then imStatCalendarSawMonth = 12; imStatCalendarSawYear = imStatCalendarSawYear - 1 end
                end
                
                local rightBtnX = headerPos.x + headerW - btnSz; local rightBtnY = leftBtnY
                local rightHovered = (mouseP.x >= rightBtnX and mouseP.x <= rightBtnX + btnSz and mouseP.y >= rightBtnY and mouseP.y <= rightBtnY + btnSz)
                local rightCenter = imgui.ImVec2(rightBtnX + btnSz / 2, rightBtnY + btnSz / 2)
                calDrawList:AddCircleFilled(rightCenter, btnSz / 2, rightHovered and 0xFF2E2E2E or 0xFF1C1C1C, 20)
                local rightArrow = fa.ICON_ANGLE_RIGHT; local rightArrowSz = imgui.CalcTextSize(rightArrow)
                calDrawList:AddText(imgui.ImVec2(rightCenter.x - rightArrowSz.x / 2, rightCenter.y - rightArrowSz.y / 2), rightHovered and 0xFFFFFFFF or 0xFFAAAAAA, rightArrow)
                imgui.SetCursorScreenPos(imgui.ImVec2(rightBtnX, rightBtnY))
                if imgui.InvisibleButton("##stat_saw_right", imgui.ImVec2(btnSz, btnSz)) then
                    imStatCalendarSawMonth = imStatCalendarSawMonth + 1
                    if imStatCalendarSawMonth > 12 then imStatCalendarSawMonth = 1; imStatCalendarSawYear = imStatCalendarSawYear + 1 end
                end
                
                local monthName = monthNamesRu[imStatCalendarSawMonth]; local yearName = tostring(imStatCalendarSawYear)
                local monthNameW = imgui.CalcTextSize(monthName).x; local monthNameH = imgui.CalcTextSize(monthName).y
                local yearNameW = imgui.CalcTextSize(yearName).x; local yearNameH = imgui.CalcTextSize(yearName).y
                local totalH = monthNameH + yearNameH + 2; local textStartY = headerPos.y + (headerH - totalH) / 2
                calDrawList:AddText(imgui.ImVec2(headerPos.x + (headerW - monthNameW) / 2, textStartY), 0xFF6078E0, monthName)
                calDrawList:AddText(imgui.ImVec2(headerPos.x + (headerW - yearNameW) / 2, textStartY + monthNameH + 2), 0xFFAAAAAA, yearName)
                
                imgui.SetCursorScreenPos(imgui.ImVec2(headerPos.x, headerPos.y + headerH)); imgui.Dummy(imgui.ImVec2(headerW, 4))
                local subSepY = imgui.GetCursorScreenPos().y + 2
                calDrawList:AddLine(imgui.ImVec2(headerPos.x, subSepY), imgui.ImVec2(headerPos.x + headerW, subSepY), 0xFF2A2A2A, 1.0)
                imgui.SetCursorScreenPos(imgui.ImVec2(headerPos.x, subSepY + 8))
                
                local hdrPos2 = imgui.GetCursorScreenPos()
                for i, wd in ipairs(weekdayNamesRu) do
                    local isWeekend = (i == 6 or i == 7); local wdW = imgui.CalcTextSize(wd).x
                    calDrawList:AddText(imgui.ImVec2(hdrPos2.x + (i - 1) * step + (cellSize - wdW) / 2, hdrPos2.y), isWeekend and WEEKEND_COL or 0xFF666666, wd)
                end
                imgui.Dummy(imgui.ImVec2(headerW, 18))
                
                local startWd = firstWeekdayOfMonth(imStatCalendarSawYear, imStatCalendarSawMonth)
                local totalDays = daysInMonth(imStatCalendarSawYear, imStatCalendarSawMonth)
                local gridPos = imgui.GetCursorScreenPos()
                
                local row, col = 0, startWd - 1
                for dnum = 1, totalDays do
                    local cellX = gridPos.x + col * step; local cellY = gridPos.y + row * step
                    local center = imgui.ImVec2(cellX + cellSize / 2, cellY + cellSize / 2); local radius = cellSize / 2 - 1
                    local dateStr = string.format("%04d-%02d-%02d", imStatCalendarSawYear, imStatCalendarSawMonth, dnum)
                    local hasData = seenDates[dateStr] == true
                    local isSelected = (dateStr == imStatCalendarSawDate); local isToday = (dateStr == todayStr)
                    local cellHovered = (mouseP.x >= cellX and mouseP.x <= cellX + cellSize and mouseP.y >= cellY and mouseP.y <= cellY + cellSize)
                    
                    if isSelected and isToday then
                        calDrawList:AddCircleFilled(center, radius, ACCENT, 24); calDrawList:AddCircle(center, radius, TODAY_RING, 24, 2.0)
                    elseif isSelected then calDrawList:AddCircleFilled(center, radius, ACCENT, 24)
                    elseif isToday then calDrawList:AddCircle(center, radius, TODAY_RING, 24, 1.5)
                    elseif cellHovered then calDrawList:AddCircle(center, radius, 0xFF444444, 24, 1.0) end
                    
                    local dayStr = tostring(dnum); local dayStrSz = imgui.CalcTextSize(dayStr)
                    local textCol
                    if isSelected then textCol = 0xFFFFFFFF elseif isToday then textCol = 0xFF1AE591
                    elseif hasData then textCol = 0xFFCCCCCC elseif cellHovered then textCol = 0xFFEEEEEE else textCol = 0xFF666666 end
                    calDrawList:AddText(imgui.ImVec2(center.x - dayStrSz.x / 2, center.y - dayStrSz.y / 2 - (hasData and 3 or 0)), textCol, dayStr)
                    
                    if hasData then
                        local dotCol = isSelected and 0xFFFFFFFF or DOT_GREEN
                        calDrawList:AddCircleFilled(imgui.ImVec2(center.x, center.y + dayStrSz.y / 2 + 2), 2.0, dotCol, 12)
                    end
                    if cellHovered then
                        local dayData = getDayStats(dateStr); local dayTotal = 0
                        for _, k in ipairs(configs[WORK_TYPES.SAWMILL].resourceOrder) do
                            dayTotal = dayTotal + ((dayData[k] or 0) * getPriceForResource(k, WORK_TYPES.SAWMILL))
                        end
                        imgui.BeginTooltip(); imgui.Text(dayStr .. " " .. monthNamesRu[imStatCalendarSawMonth])
                        if dayTotal > 0 then imgui.Text(u8("Доход: ") .. formatNumber(dayTotal) .. "$") else imgui.Text(u8("Нет записей")) end
                        imgui.EndTooltip()
                    end
                    imgui.SetCursorScreenPos(imgui.ImVec2(cellX, cellY))
                    if imgui.InvisibleButton("##stat_saw_cal_" .. dateStr, imgui.ImVec2(cellSize, cellSize)) then
                        imStatCalendarSawDate = dateStr; imgui.CloseCurrentPopup()
                    end
                    col = col + 1; if col > 6 then col = 0; row = row + 1 end
                end
                
                imgui.SetCursorScreenPos(imgui.ImVec2(gridPos.x, gridPos.y + (row + 1) * step + 4))
                local legY = imgui.GetCursorScreenPos().y + 6
                calDrawList:AddLine(imgui.ImVec2(headerPos.x, legY), imgui.ImVec2(headerPos.x + headerW, legY), 0xFF2A2A2A, 1.0)
                local legendY = legY + 8
                calDrawList:AddCircleFilled(imgui.ImVec2(headerPos.x + 6, legendY + 5), 2.0, DOT_GREEN, 12)
                calDrawList:AddText(imgui.ImVec2(headerPos.x + 14, legendY), 0xFF777777, u8("Есть записи"))
                local todayLabel = u8("Сегодня"); local todayLabelW = imgui.CalcTextSize(todayLabel).x
                calDrawList:AddCircle(imgui.ImVec2(headerPos.x + headerW - todayLabelW - 16, legendY + 5), 4.0, TODAY_RING, 12, 1.2)
                calDrawList:AddText(imgui.ImVec2(headerPos.x + headerW - todayLabelW, legendY), 0xFF777777, todayLabel)
                imgui.SetCursorScreenPos(imgui.ImVec2(headerPos.x, legendY + 20)); imgui.Dummy(imgui.ImVec2(headerW, 1))
                imgui.EndPopup()
            end
            
            imgui.Spacing()
            
            local dayData = getDayStats(imStatCalendarSawDate)
            local dayTotal = 0
            for _, k in ipairs(config.resourceOrder) do
                dayTotal = dayTotal + ((dayData[k] or 0) * getPriceForResource(k, WORK_TYPES.SAWMILL))
            end
            
            local tPos = imgui.GetCursorScreenPos()
            local tableWidth2 = imgui.GetWindowWidth() - 25
            local rowH2 = 26; local rows2 = #config.resourceOrder
            local totalRowH = 32; local tblH2 = rows2 * rowH2 + totalRowH
            
            drawList:AddRectFilled(tPos, imgui.ImVec2(tPos.x + tableWidth2, tPos.y + tblH2), 0xFF141414, 8)
            drawList:AddRect(tPos, imgui.ImVec2(tPos.x + tableWidth2, tPos.y + tblH2), 0xFF2A2A2A, 8, 15, 1.0)
            
            for i, k in ipairs(config.resourceOrder) do
                local y = tPos.y + (i - 1) * rowH2
                local rowBgColor = (i % 2 == 0) and 0xFF1E1E1E or 0xFF181818
                drawList:AddRectFilled(imgui.ImVec2(tPos.x + 2, y + 1), imgui.ImVec2(tPos.x + tableWidth2 - 2, y + rowH2 - 1), rowBgColor)
                drawList:AddText(imgui.ImVec2(tPos.x + 12, y + 5), 0xFFCCCCCC, u8(config.resourceNames[k]))
                local amtStr = formatNumber(dayData[k] or 0); local amtW = imgui.CalcTextSize(amtStr).x
                drawList:AddText(imgui.ImVec2(tPos.x + tableWidth2 - amtW - 12, y + 5), 0xFFFFCC00, amtStr)
            end
            
            local totalY = tPos.y + rows2 * rowH2
            drawList:AddRectFilled(imgui.ImVec2(tPos.x + 2, totalY + 1), imgui.ImVec2(tPos.x + tableWidth2 - 2, totalY + totalRowH - 2), 0xFF1E2E22, 6)
            drawList:AddText(imgui.ImVec2(tPos.x + 12, totalY + 9), 0xFF888888, u8("Доход"))
            local totalStr = formatNumber(dayTotal) .. "$"; local totalW2 = imgui.CalcTextSize(totalStr).x
            drawList:AddText(imgui.ImVec2(tPos.x + tableWidth2 - totalW2 - 12, totalY + 9), 0xFF33CC66, totalStr)
            
            imgui.SetCursorScreenPos(imgui.ImVec2(tPos.x, tPos.y + tblH2 + 8))
            imgui.Dummy(imgui.ImVec2(tableWidth2, 0))
        else
            imgui.TextColored(imgui.ImVec4(0.8, 0.3, 0.3, 1), u8("Нет данных"))
        end
    end
end
lbCacheState = lbCacheState or {
    mode = nil, period = nil, filterIdx = nil,
    cacheRef = nil,
    serverList = nil, serverListClean = nil,
    normalCache = nil, filteredCache = nil, devEntry = nil
}
if not lbRowsLimit then lbRowsLimit = 9999 end

function drawLeaderboardTab()
    imgui.TextColored(imgui.ImVec4(1.0, 0.8, 0.2, 1), u8("Таблица лидеров"))
    imgui.Separator()
    imgui.Spacing()

    if not getLbEnabled() then
        imgui.TextColored(imgui.ImVec4(1.0, 0.5, 0.2, 1), u8("Включите рейтинг в настройках и укажите ник!"))
        imgui.Spacing()
        if imgui.Button(u8("Открыть настройки"), imgui.ImVec2(200, 25)) then
            currentTab = 10
        end
        return
    end

    imgui.TextColored(imgui.ImVec4(0.6, 0.6, 0.6, 1), u8("Выберите период и режим, затем нажмите \"Показать рейтинг\""))
    imgui.Spacing(); imgui.Separator(); imgui.Spacing()

    local drawList = imgui.GetWindowDrawList()
    local periods = {u8("За день"), u8("За неделю"), u8("За все время")}
    local modes = {u8("Общий доход"), u8("Ферма"), u8("Шахта"), u8("Лесопилка"), u8("Сторонний доход")}
    local periodsList = {"Daily", "Weekly", "Total"}
    local modesList = {"Income", "Farm", "Mine", "Sawmill", "IM"}

    imgui.Text(u8("Период:")); imgui.SameLine()
    for i, periodName in ipairs(periods) do
        if i > 1 then imgui.SameLine(0, 4) end
        local isActive = (lbTab.v == i - 1)
        local btnW, btnH = 127, 24
        local btnPos = imgui.GetCursorScreenPos()
        local hovered = (imgui.GetMousePos().x >= btnPos.x and imgui.GetMousePos().x <= btnPos.x + btnW and imgui.GetMousePos().y >= btnPos.y and imgui.GetMousePos().y <= btnPos.y + btnH)
        local bgColor = isActive and 0xFF1E3D1E or (hovered and 0xFF2A2A2A or 0xFF1A1A1A)
        local borderColor = isActive and 0xFF1AE591 or (hovered and 0xFF555555 or 0xFF333333)
        local textColor = isActive and 0xFF1AE591 or (hovered and 0xFFFFFFFF or 0xFF999999)
        drawList:AddRectFilled(btnPos, imgui.ImVec2(btnPos.x + btnW, btnPos.y + btnH), bgColor, 4)
        drawList:AddRect(btnPos, imgui.ImVec2(btnPos.x + btnW, btnPos.y + btnH), borderColor, 4, 15, 1.5)
        local textW = imgui.CalcTextSize(periodName).x
        drawList:AddText(imgui.ImVec2(btnPos.x + (btnW - textW) / 2, btnPos.y + 4), textColor, periodName)
        imgui.SetCursorScreenPos(btnPos)
        if imgui.InvisibleButton("##period_" .. i, imgui.ImVec2(btnW, btnH)) then
            lbTab.v = i - 1
            lbServerFilter.v = 0
        end
    end

    imgui.Spacing(); imgui.Spacing()
    imgui.Text(u8("Режим:")); imgui.SameLine()
    for i, modeName in ipairs(modes) do
        if i > 1 then imgui.SameLine(0, 4) end
        local isActive = (lbModeTab.v == i - 1)
        local btnW, btnH = 129, 24
        local btnPos = imgui.GetCursorScreenPos()
        local hovered = (imgui.GetMousePos().x >= btnPos.x and imgui.GetMousePos().x <= btnPos.x + btnW and imgui.GetMousePos().y >= btnPos.y and imgui.GetMousePos().y <= btnPos.y + btnH)
        local bgColor = isActive and 0xFF1E3D1E or (hovered and 0xFF2A2A2A or 0xFF1A1A1A)
        local borderColor = isActive and 0xFF1AE591 or (hovered and 0xFF555555 or 0xFF333333)
        local textColor = isActive and 0xFF1AE591 or (hovered and 0xFFFFFFFF or 0xFF999999)
        drawList:AddRectFilled(btnPos, imgui.ImVec2(btnPos.x + btnW, btnPos.y + btnH), bgColor, 4)
        drawList:AddRect(btnPos, imgui.ImVec2(btnPos.x + btnW, btnPos.y + btnH), borderColor, 4, 15, 1.5)
        local textW = imgui.CalcTextSize(modeName).x
        drawList:AddText(imgui.ImVec2(btnPos.x + (btnW - textW) / 2, btnPos.y + 4), textColor, modeName)
        imgui.SetCursorScreenPos(btnPos)
        if imgui.InvisibleButton("##mode_" .. i, imgui.ImVec2(btnW, btnH)) then
            lbModeTab.v = i - 1
            lbServerFilter.v = 0
        end
    end

    imgui.Spacing(); imgui.Separator(); imgui.Spacing()

    if StyleButton(u8("Показать рейтинг"), fa.ICON_SEARCH) then
        local period = periodsList[lbTab.v + 1]
        local mode = modesList[lbModeTab.v + 1]
        showLoading = true
        loadLeaderboard(period, mode)
        if mode == "Income" then
            lua_thread.create(function()
                local subModes = {"Farm", "Mine", "Sawmill", "IM"}
                local modeNames = {Farm = "Ферма", Mine = "Шахта", Sawmill = "Лесопилка", IM = "Сторонний доход"}
                local function waitForLeaderboard(m, maxMs)
                    local waited = 0
                    while waited < maxMs do
                        local cache = leaderboardCache[m] and leaderboardCache[m][period]
                        if cache and #cache > 0 then return true end
                        wait(300)
                        waited = waited + 300
                    end
                    return false
                end
                for _, m in ipairs(subModes) do
                    sampAddChatMessage(SCRIPT_PREFIX .. "Загрузка " .. modeNames[m] .. "...", SCRIPT_COLOR)
                    loadLeaderboard(period, m, true)
                    local ok = waitForLeaderboard(m, 15000)
                    if not ok then
                        loadLeaderboard(period, m, true)
                        ok = waitForLeaderboard(m, 15000)
                    end
                    if ok then
                        sampAddChatMessage(SCRIPT_PREFIX .. modeNames[m] .. " загружена!", SCRIPT_COLOR)
                    else
                        sampAddChatMessage(SCRIPT_PREFIX .. "Загрузка " .. modeNames[m] .. " не удалась.", SCRIPT_COLOR)
                    end
                end
                sampAddChatMessage(SCRIPT_PREFIX .. "Все данные загружены!", SCRIPT_COLOR)
                showLoading = false
            end)
        else
            showLoading = false
        end
    end

    imgui.Spacing(); imgui.Separator(); imgui.Spacing()

    local period = periodsList[lbTab.v + 1]
    local mode = modesList[lbModeTab.v + 1]
    local cache = leaderboardCache[mode] and leaderboardCache[mode][period]

    if showLoading and not (cache and #cache > 0) then
        local mode2 = modesList[lbModeTab.v + 1]
        local period2 = periodsList[lbTab.v + 1]
        local cacheFile = io.open(configDir .. "lb_cache_" .. mode2 .. "_" .. period2 .. "_cache.json", "r")
        if cacheFile then
            local content = cacheFile:read("*all")
            cacheFile:close()
            local decoded = u8:decode(content)
            local data = decodeJson(decoded)
            if data and #data > 0 then
                leaderboardCache[mode2][period2] = data
                cache = data
            end
        end
        if cache and #cache > 0 then
            showLoading = false
        else
            imgui.TextColored(imgui.ImVec4(1.0, 0.8, 0.2, 1), u8("Идёт загрузка таблицы. Ожидайте пару секунд..."))
            return
        end
    end

    if not (cache and #cache > 0) then
        imgui.TextColored(imgui.ImVec4(0.6, 0.6, 0.6, 1), u8("Нажмите \"Показать рейтинг\" для загрузки данных"))
        return
    end

    
    --  ПРОКРУЧИВАЕМАЯ ОБЛАСТЬ РЕЗУЛЬТАТОВ
    
    local availH = imgui.GetContentRegionAvail().y
    imgui.BeginChild("##lb_results_scroll", imgui.ImVec2(0, availH), false)
    drawList = imgui.GetWindowDrawList()

    local childPos = imgui.GetWindowPos()
    local childH = imgui.GetWindowHeight()
    local visMinY = childPos.y - 8
    local visMaxY = childPos.y + childH + 8

    
    --  ДАННЫЕ
    
    local developerName = "Ryder_Nakata"
    local _, myId = sampGetPlayerIdByCharHandle(PLAYER_PED)
    local myName = sampGetPlayerNickname(myId)
    local isDeveloper = (myName == developerName)
    local hasResources = (mode == "Farm" or mode == "Mine" or mode == "Sawmill")
    local isIM = (mode == "IM")
    local isIncome = (mode == "Income")
    local showDetailCol = hasResources or isIncome or isIM

    if not lbServerFilter then lbServerFilter = imgui.ImInt(0) end

    local needRebuild = (lbCacheState.cacheRef ~= cache)
        or (lbCacheState.mode ~= mode)
        or (lbCacheState.period ~= period)
        or (lbCacheState.filterIdx ~= lbServerFilter.v)

    if needRebuild then
        local devEntryTmp = nil
        local normalCacheTmp = {}
        for _, entry in ipairs(cache) do
            if entry.name == developerName then
                devEntryTmp = entry
            else
                table.insert(normalCacheTmp, entry)
            end
        end

        local serverListCleanTmp = {u8("Все сервера")}
        local serverSet, serverCounts = {}, {}
        for _, entry in ipairs(normalCacheTmp) do
            if entry.server then
                serverCounts[entry.server] = (serverCounts[entry.server] or 0) + 1
                if not serverSet[entry.server] then
                    serverSet[entry.server] = true
                    table.insert(serverListCleanTmp, entry.server)
                end
            end
        end
        local serverOrder = {
            "Phoenix", "Tucson", "Scottdale", "Chandler", "Brainburg",
            "Saint-Rose", "Mesa", "Red-Rock", "Yuma", "Surprise",
            "Prescott", "Glendale", "Kingman", "Winslow", "Payson",
            "Gilbert", "Show Low", "Casa-Grande", "Page", "Sun-City",
            "Queen-Creek", "Sedona", "Holiday", "Wednesday", "Yava",
            "Faraway", "Bumble Bee", "Christmas", "Mirage", "Love",
            "Drake", "Space"
        }
        table.sort(serverListCleanTmp, function(a, b)
            if a == u8("Все сервера") then return true
            elseif b == u8("Все сервера") then return false
            else
                local ia, ib = 99, 99
                for i, name in ipairs(serverOrder) do
                    if name == a then ia = i end
                    if name == b then ib = i end
                end
                return ia < ib
            end
        end)
        local serverListTmp = {}
        for _, cleanName in ipairs(serverListCleanTmp) do
            if cleanName == u8("Все сервера") then
                table.insert(serverListTmp, u8("Все сервера") .. " (" .. #normalCacheTmp .. ")")
            else
                table.insert(serverListTmp, cleanName .. " (" .. (serverCounts[cleanName] or 0) .. ")")
            end
        end

        local filteredCacheTmp = normalCacheTmp
        if lbServerFilter.v > 0 and lbServerFilter.v <= #serverListCleanTmp then
            local selectedServer = serverListCleanTmp[lbServerFilter.v + 1]
            if selectedServer ~= u8("Все сервера") then
                filteredCacheTmp = {}
                for _, entry in ipairs(normalCacheTmp) do
                    if entry.server == selectedServer then table.insert(filteredCacheTmp, entry) end
                end
            end
        end

        lbCacheState.cacheRef = cache
        lbCacheState.mode = mode
        lbCacheState.period = period
        lbCacheState.filterIdx = lbServerFilter.v
        lbCacheState.devEntry = devEntryTmp
        lbCacheState.normalCache = normalCacheTmp
        lbCacheState.serverListClean = serverListCleanTmp
        lbCacheState.serverList = serverListTmp
        lbCacheState.filteredCache = filteredCacheTmp
    end

    local devEntry = lbCacheState.devEntry
    local serverListClean = lbCacheState.serverListClean
    local serverList = lbCacheState.serverList
    local filteredCache = lbCacheState.filteredCache

    
    --  ВИЗУАЛЬНЫЕ ХЕЛПЕРЫ
    
    local C = {
        ACCENT      = 0xFF1AE591,
        TXT_MAIN    = 0xFFE8E8E8,
        ME_ACCENT   = 0xFFFFAA00,
        HEADER_TXT  = 0xFFB8B8B8,
        CARD_BG     = 0xFF141414,
        CARD_BG_ALT = 0xFF1E1E1E,
        CARD_BORDER = 0xFF2E2E2E,
        CORNER_R    = 8,
        GOLD_COL    = 0xFF00D7FF,
        SILVER_COL  = 0xFFC7C7C7,
        BRONZE_COL  = 0xFF327FCD,
        DEV_BG      = 0xFF141414,
        DEV_LINE    = 0xFF4444CC,
        DEV_ICON    = 0xFF6666CC,
        DEV_TEXT    = 0xFFCCCCFF,
    }

    local SERVER_ICON_COLOR = {
        ["Gilbert"] = 0xFF5A2314, ["Glendale"] = 0xFF441F0A, ["Holiday"] = 0xFFA83F5B,
        ["Kingman"] = 0xFF521F0F, ["Love"] = 0xFF8C2DE6, ["Mesa"] = 0xFF4D1F0E,
        ["Mirage"] = 0xFF1F3A1B, ["Page"] = 0xFF451A0D, ["Payson"] = 0xFF281EC8,
        ["Phoenix"] = 0xFF2B59E0, ["Prescott"] = 0xFF6B3A1B, ["Brainburg"] = 0xFF3A1EC4,
        ["Bumble Bee"] = 0xFF05B7F2, ["Casa-Grande"] = 0xFF29774A, ["Chandler"] = 0xFF451A0D,
        ["Christmas"] = 0xFF3D2114, ["Drake"] = 0xFF3D6B1F, ["Faraway"] = 0xFF20401B,
        ["Surprise"] = 0xFF2C1EC4, ["Tucson"] = 0xFF6B2B14, ["Wednesday"] = 0xFF8C2A5A,
        ["Winslow"] = 0xFF2B5A8B, ["Yava"] = 0xFFA0A84F, ["Yuma"] = 0xFF5E2314,
        ["Queen-Creek"] = 0xFFB26F1F, ["Red-Rock"] = 0xFF50230F, ["Saint-Rose"] = 0xFF883C1F,
        ["Scottdale"] = 0xFF2E20B5, ["Sedona"] = 0xFF30B8E8, ["Show Low"] = 0xFF2A18A3,
        ["Space"] = 0xFF5E1B2A, ["Sun-City"] = 0xFF5C2212,
    }

    local function serverColor(name)
        if not name or name == "" then return 0xFF555555 end
        if SERVER_ICON_COLOR[name] then return SERVER_ICON_COLOR[name] end
        local hash = 7
        for i = 1, #name do hash = (hash * 33 + string.byte(name, i)) % 16777216 end
        local r = 70 + (hash % 130)
        local g = 70 + (math.floor(hash / 7) % 130)
        local b = 100 + (math.floor(hash / 13) % 140)
        return 0xFF000000 + b * 65536 + g * 256 + r
    end

    local function rankLineColor(i)
        if i == 1 then return C.GOLD_COL
        elseif i == 2 then return C.SILVER_COL
        elseif i == 3 then return C.BRONZE_COL
        else return nil end
    end

    local function rankVisual(i)
        if i == 1 then return fa.ICON_TROPHY, C.GOLD_COL
        elseif i == 2 then return fa.ICON_TROPHY, C.SILVER_COL
        elseif i == 3 then return fa.ICON_TROPHY, C.BRONZE_COL
        else return tostring(i), 0xFF666666 end
    end

    local function drawHeader(x, y, colX, w, labels, aligns, attached, skipIdx)
        local h = 30
        local flags = attached and 3 or 15
        drawList:AddRectFilled(imgui.ImVec2(x, y), imgui.ImVec2(x + w, y + h), 0xFF1A1A1A, 6, flags)
        for i, lbl in ipairs(labels) do
            if i ~= skipIdx then
                local cx0 = colX[i]
                local cx1 = colX[i + 1]
                local tw = imgui.CalcTextSize(lbl).x
                local tx
                if aligns[i] == "center" then tx = cx0 + (cx1 - cx0 - tw) / 2
                elseif aligns[i] == "right" then tx = cx1 - tw - 12
                else tx = cx0 + 12 end
                drawList:AddText(imgui.ImVec2(tx, y + 8), C.HEADER_TXT, lbl)
            end
        end
        drawList:AddLine(imgui.ImVec2(x + 4, y + h), imgui.ImVec2(x + w - 4, y + h), C.ACCENT, 1.5)
        return h
    end

    local function drawColumnLines(x, colXs, y0, y1, startIdx)
        startIdx = startIdx or 2
        for i = startIdx, #colXs - 1 do
            drawList:AddLine(imgui.ImVec2(colXs[i], y0), imgui.ImVec2(colXs[i], y1), C.CARD_BORDER, 1.0)
        end
    end

    local function drawServerTag(colX0, colX1, yCenter, server)
        if not server or server == "" then return end
        local col = serverColor(server)
        local label = server
        local hasIcon = serverIcons[server] ~= nil
        local iconW = hasIcon and 20 or 0
        local tw = imgui.CalcTextSize(label).x
        local padX = 8
        local tagW = tw + padX * 2 + iconW
        local tagH = 22
        local colW = colX1 - colX0
        local x = colX0 + (colW - tagW) / 2
        if x < colX0 + 4 then x = colX0 + 4 end
        local y0 = yCenter - tagH / 2
        
        local mp = imgui.GetMousePos()
        local hovered = (mp.x >= x and mp.x <= x + tagW and mp.y >= y0 and mp.y <= y0 + tagH)
        
        drawList:AddRectFilled(imgui.ImVec2(x, y0), imgui.ImVec2(x + tagW, y0 + tagH), (col - 0xFF000000) + (hovered and 0x55000000 or 0x33000000), 5, 15)
        drawList:AddRect(imgui.ImVec2(x, y0), imgui.ImVec2(x + tagW, y0 + tagH), col, 5, 15, hovered and 2.0 or 1.0)
        
        if hasIcon then
            drawList:AddImage(serverIcons[server], imgui.ImVec2(x + 6, y0 + 3), imgui.ImVec2(x + 22, y0 + 19))
            drawList:AddText(imgui.ImVec2(x + iconW + 6, y0 + 3), 0xFFEFEFEF, label)
        else
            drawList:AddText(imgui.ImVec2(x + padX, y0 + 3), 0xFFEFEFEF, label)
        end
        
        imgui.SetCursorScreenPos(imgui.ImVec2(x, y0))
        if imgui.InvisibleButton("##srv_tag_" .. server .. "_" .. yCenter, imgui.ImVec2(tagW, tagH)) then
            local foundIdx = -1
            for si = 1, #serverListClean do
                if serverListClean[si] == server then foundIdx = si - 1; break end
            end
            if lbServerFilter.v == foundIdx then lbServerFilter.v = 0
            else lbServerFilter.v = foundIdx end
        end
        
        if hovered then
            imgui.BeginTooltip()
            local foundIdx = -1
            for si = 1, #serverListClean do
                if serverListClean[si] == server then foundIdx = si - 1; break end
            end
            if lbServerFilter.v == foundIdx then
                imgui.Text(u8("Повторно нажмите для отмены фильтрации по серверу: ") .. server)
            else
                imgui.Text(u8("Нажмите для фильтрации по серверу: ") .. server)
            end
            imgui.EndTooltip()
        end
        
        return tagW
    end

    local function drawDetailButton(x, yCenter, id, tooltipFn, onClick)
        local size = 24
        local y0 = yCenter - size / 2
        local center = imgui.ImVec2(x + size / 2, yCenter)
        local mp = imgui.GetMousePos()
        local hovered = (mp.x >= x and mp.x <= x + size and mp.y >= y0 and mp.y <= y0 + size)
        drawList:AddCircleFilled(center, size / 2, hovered and 0xFF24382F or 0xFF1B1B1B, 16)
        drawList:AddCircle(center, size / 2, hovered and C.ACCENT or 0xFF3A3A3A, 16, 1.2)
        local icon = fa.ICON_ANGLE_RIGHT
        local isz = imgui.CalcTextSize(icon)
        drawList:AddText(imgui.ImVec2(center.x - isz.x / 2, center.y - isz.y / 2), hovered and C.ACCENT or 0xFF999999, icon)
        imgui.SetCursorScreenPos(imgui.ImVec2(x, y0))
        if imgui.InvisibleButton(id, imgui.ImVec2(size, size)) and onClick then onClick() end
        if imgui.IsItemHovered() and tooltipFn then
            imgui.BeginTooltip(); tooltipFn(); imgui.EndTooltip()
        end
        return size
    end

    local function drawRow(x, y, w, colX, entry, rankIdx, isDevRow, cornerFlags, rowH)
        rowH = rowH or 40
        local mp = imgui.GetMousePos()
        local hovered = (mp.x >= x and mp.x <= x + w and mp.y >= y and mp.y <= y + rowH)
        local isMeRow = (not isDevRow) and myName and entry.name == myName

        local bg
        if isDevRow then bg = C.DEV_BG
        elseif isMeRow then bg = 0xFF2A2410
        elseif hovered then bg = C.CARD_BG_ALT
        elseif rankIdx and rankIdx % 2 == 0 then bg = 0xFF191919
        else bg = C.CARD_BG end

        drawList:AddRectFilled(imgui.ImVec2(x, y), imgui.ImVec2(x + w, y + rowH), bg, 6, cornerFlags or 0)

        local stripeTop, stripeBottom = y, y + rowH
        if cornerFlags == 12 then stripeBottom = y + rowH - C.CORNER_R end
        if isDevRow then
            drawList:AddRectFilled(imgui.ImVec2(x, stripeTop), imgui.ImVec2(x + 3, stripeBottom), C.DEV_LINE, 2)
        elseif isMeRow then
            drawList:AddRectFilled(imgui.ImVec2(x, stripeTop), imgui.ImVec2(x + 3, stripeBottom), C.ME_ACCENT, 2)
        else
            local rlc = rankLineColor(rankIdx)
            if rlc then drawList:AddRectFilled(imgui.ImVec2(x, stripeTop), imgui.ImVec2(x + 3, stripeBottom), rlc, 2) end
        end

        local rankX0, rankX1 = colX[1], colX[2]
        if isDevRow then
            local icon = fa.ICON_WRENCH; local isz = imgui.CalcTextSize(icon)
            drawList:AddText(imgui.ImVec2(rankX0 + (rankX1 - rankX0 - isz.x) / 2, y + (rowH - isz.y) / 2), C.DEV_ICON, icon)
        else
            local label, col = rankVisual(rankIdx); local lsz = imgui.CalcTextSize(label)
            drawList:AddText(imgui.ImVec2(rankX0 + (rankX1 - rankX0 - lsz.x) / 2, y + (rowH - lsz.y) / 2), col, label)
        end

        local nameX0 = colX[2]
        local displayName = entry.name
        if isMeRow then
            if #displayName > 18 then displayName = displayName:sub(1, 15) .. "..." end
            displayName = displayName .. u8(" (Вы)")
        elseif #displayName > 22 then displayName = displayName:sub(1, 19) .. "..." end
        if isDevRow then
            drawList:AddText(imgui.ImVec2(nameX0 + 12, y + 7), C.DEV_TEXT, displayName)
            drawList:AddText(imgui.ImVec2(nameX0 + 12, y + 22), C.DEV_ICON, u8("Разработчик"))
        else
            local nameSz = imgui.CalcTextSize(displayName)
            drawList:AddText(imgui.ImVec2(nameX0 + 12, y + (rowH - nameSz.y) / 2), isMeRow and C.ME_ACCENT or C.TXT_MAIN, displayName)
        end

        drawServerTag(colX[3], colX[4], y + rowH / 2, entry.server)

        local amtX0, amtX1 = colX[4], colX[5]
        local amtTxt = formatNumber(entry.amount) .. "$"
        local atw = imgui.CalcTextSize(amtTxt).x; local athh = imgui.CalcTextSize(amtTxt).y
        drawList:AddText(imgui.ImVec2(amtX1 - atw - 16, y + (rowH - athh) / 2), 0xFF33CC33, amtTxt)

        return rowH, hovered
    end

    
    --  ОБЩИЕ ГЕОМЕТРИЯ КОЛОНОК
    
    local pos = imgui.GetCursorScreenPos()
    local tableWidth = imgui.GetWindowWidth() - 25

    local maxServerLen = 5
    for _, e in ipairs(cache) do if e.server and #e.server > maxServerLen then maxServerLen = #e.server end end
    local serverColW = math.max(90, maxServerLen * 7 + 50)

    local col1W = 46
    local col5W = showDetailCol and 44 or 0
    local col3W = serverColW
    local col4W = 150
    local col2W = tableWidth - (col1W + col3W + col4W + col5W)

    local colX = {pos.x, pos.x + col1W, pos.x + col1W + col2W, pos.x + col1W + col2W + col3W, pos.x + col1W + col2W + col3W + col4W, pos.x + tableWidth}
    local labels = {fa.ICON_LIST_OL, u8("Игрок"), u8("Сервер"), u8("Доход")}
    local aligns = {"center", "left", "left", "right"}
    if showDetailCol then table.insert(labels, fa.ICON_QUESTION_CIRCLE); table.insert(aligns, "center") end

    local rowHFixed = 40
    local headerHFixed = 30

    
    --  КАРТОЧКА РАЗРАБОТЧИКА
    
    if devEntry and isDeveloper then
        local devTableH = headerHFixed + rowHFixed
        local devTopY = pos.y
        drawList:AddRectFilled(imgui.ImVec2(pos.x, devTopY), imgui.ImVec2(pos.x + tableWidth, devTopY + devTableH), 0xFF0C0C0C, 8, 15)
        local devLabels = {fa.ICON_LIST_OL, u8("Особый статус"), u8("Сервер"), u8("Доход")}
        local devAligns = {"center", "left", "center", "right"}
        if showDetailCol then table.insert(devLabels, fa.ICON_QUESTION_CIRCLE); table.insert(devAligns, "center") end
        local hH = drawHeader(pos.x, pos.y, colX, tableWidth, devLabels, devAligns, true)
        pos.y = pos.y + hH
        local rowH = drawRow(pos.x, pos.y, tableWidth, colX, devEntry, nil, true, 12, rowHFixed)
        if hasResources and devEntry.resources then
            local resKeys = {}; for k, _ in pairs(devEntry.resources) do resKeys[#resKeys + 1] = k end; table.sort(resKeys)
            drawDetailButton(colX[6] - 34, pos.y + rowH / 2, "##dev_res", function()
                for _, rk in ipairs(resKeys) do imgui.Text(u8(rk .. ": " .. formatNumber(devEntry.resources[rk] or 0))) end
            end, nil)
        elseif (isIncome or isIM) then
            drawDetailButton(colX[6] - 34, pos.y + rowH / 2, "##dev_detail", function()
                if isIM and devEntry.resources then
                    local imVal = devEntry.resources["Item Market"] or devEntry.resources["im"] or 0
                    local shVal = devEntry.resources["Осколки тайников"] or devEntry.resources["shards"] or 0
                    imgui.Text("Item Market: " .. formatNumber(imVal) .. "$")
                    imgui.Text(u8("Осколки тайников: ") .. formatNumber(shVal) .. "$")
                elseif isIncome then
                    local name = devEntry.name
                    local modeNames = {Farm = u8("Ферма"), Mine = u8("Шахта"), Sawmill = u8("Лесопилка"), IM = u8("Сторонний доход")}
                    for _, m in ipairs({"Farm", "Mine", "Sawmill", "IM"}) do
                        local otherCache = leaderboardCache[m] and leaderboardCache[m][period]
                        local found = false
                        if otherCache then for _, e in ipairs(otherCache) do if e.name == name then imgui.Text(modeNames[m] .. ": " .. formatNumber(e.amount) .. "$"); found = true; break end end end
                        if not found then imgui.Text(modeNames[m] .. ": 0$") end
                    end
                end
            end, function() for _, m in ipairs({"Farm", "Mine", "Sawmill", "IM"}) do loadLeaderboard(period, m) end end)
        end
        drawColumnLines(pos.x, colX, devTopY, devTopY + devTableH)
        drawList:AddRect(imgui.ImVec2(pos.x, devTopY), imgui.ImVec2(pos.x + tableWidth, devTopY + devTableH), C.CARD_BORDER, 8, 15, 1.2)
        pos.y = devTopY + devTableH + 12
        imgui.SetCursorScreenPos(imgui.ImVec2(pos.x, pos.y))
        imgui.Dummy(imgui.ImVec2(tableWidth, 0))
    end

    
    --  ОСНОВНАЯ ТАБЛИЦА
    
    if #filteredCache == 0 then
        imgui.SetCursorScreenPos(pos)
        local blockH = drawEmptyState(drawList, pos.x, pos.y, tableWidth, fa.ICON_USERS, u8("Нет игроков по заданному фильтру"))
        imgui.Dummy(imgui.ImVec2(tableWidth, blockH))
        imgui.EndChild()
        return
    end

    local resKeysMain = {}
    if hasResources and filteredCache[1] and filteredCache[1].resources then
        for k, _ in pairs(filteredCache[1].resources) do resKeysMain[#resKeysMain + 1] = k end; table.sort(resKeysMain)
    end

    local visibleRows = math.min(#filteredCache, lbRowsLimit)
    local tableTotalH = headerHFixed + visibleRows * rowHFixed
    local tableTopY = pos.y

    drawList:AddRectFilled(imgui.ImVec2(pos.x, tableTopY), imgui.ImVec2(pos.x + tableWidth, tableTopY + tableTotalH), 0xFF0C0C0C, 8, 15)

    local hH = drawHeader(pos.x, pos.y, colX, tableWidth, labels, aligns, true, 3)

    -- Кнопка настройки количества строк
    imgui.SetCursorScreenPos(imgui.ImVec2(colX[1], pos.y))
    if imgui.InvisibleButton("##lb_rows_limit", imgui.ImVec2(col1W, hH)) then
        imgui.OpenPopup("##lb_rows_popup")
    end
    if imgui.IsItemHovered() then
        imgui.BeginTooltip()
        imgui.Text(u8("Строк: ") .. (lbRowsLimit == 9999 and u8("Все") or tostring(lbRowsLimit)) .. u8("\nНажмите чтобы изменить"))
        imgui.EndTooltip()
    end
    if imgui.BeginPopup("##lb_rows_popup") then
        local rowOptions = {9999, 10, 25, 50, 100, 200}
        local rowLabels = {u8("Без ограничений"), "10", "25", "50", "100", "200"}
        imgui.TextColored(imgui.ImVec4(1.0, 0.8, 0.2, 1), u8("Строк в таблице:"))
        imgui.Separator()
        for i, opt in ipairs(rowOptions) do
            if imgui.Selectable(rowLabels[i], lbRowsLimit == opt) then
                lbRowsLimit = opt
                saveLbRowsLimit()
                imgui.CloseCurrentPopup()
            end
        end
        imgui.EndPopup()
    end

    local srvHdrX = colX[3]
    local srvHdrW = col3W
    local srvLabelWithArrow = labels[3] .. " " .. fa.ICON_ANGLE_DOWN
    local srvLabelW = imgui.CalcTextSize(srvLabelWithArrow).x
    drawList:AddText(imgui.ImVec2(srvHdrX + (srvHdrW - srvLabelW) / 2, pos.y + 8), C.HEADER_TXT, srvLabelWithArrow)

    imgui.SetCursorScreenPos(imgui.ImVec2(srvHdrX, pos.y))
    if imgui.InvisibleButton("##server_filter_btn2", imgui.ImVec2(srvHdrW, hH)) then
        imgui.OpenPopup("##server_filter_popup2")
    end
    if imgui.IsItemHovered() then
        imgui.BeginTooltip()
        imgui.Text(u8("Нажмите для фильтрации по серверу"))
        if lbServerFilter.v > 0 then
            local activeServer = serverListClean[lbServerFilter.v + 1]
            if activeServer then imgui.TextColored(imgui.ImVec4(1.0, 0.8, 0.2, 1), u8("Активен: ") .. activeServer) end
        end
        imgui.EndTooltip()
    end
    if lbServerFilter.v > 0 then
        drawList:AddText(imgui.ImVec2(colX[4] - 18, pos.y + 8), 0xFFFFAA00, fa.ICON_FILTER)
    end
    if imgui.BeginPopup("##server_filter_popup2") then
        local popupDrawList = imgui.GetWindowDrawList()
        local popupPos = imgui.GetWindowPos()
        local popupSize = imgui.GetWindowSize()
        popupDrawList:AddRectFilled(popupPos, imgui.ImVec2(popupPos.x + popupSize.x, popupPos.y + popupSize.y), 0xFF121212, 6)
        popupDrawList:AddRect(popupPos, imgui.ImVec2(popupPos.x + popupSize.x, popupPos.y + popupSize.y), 0xFF2A2A2A, 6, 15, 1.0)
        imgui.TextColored(imgui.ImVec4(1.0, 0.8, 0.2, 1), u8("Фильтр по серверу:"))
        imgui.Spacing()
        if not lbShowAllServers then lbShowAllServers = imgui.ImBool(false) end
        imgui.Checkbox(u8("Показать все сервера"), lbShowAllServers)
        imgui.Separator()
        imgui.Spacing()
        local itemH = 26
        local cardW = 177
        local childW = 200
        if lbShowAllServers.v then
            for i = 1, #serverList do
                local srv = serverList[i]; local isSelected = (lbServerFilter.v == i - 1)
                local srvName = serverListClean[i]; local hasIcon = srvName and serverIcons[srvName] ~= nil
                local itemPos = imgui.GetCursorScreenPos()
                local hovered = (imgui.GetMousePos().x >= itemPos.x and imgui.GetMousePos().x <= itemPos.x + cardW and imgui.GetMousePos().y >= itemPos.y and imgui.GetMousePos().y <= itemPos.y + itemH)
                local bg = isSelected and 0xFF1E3D1E or (hovered and 0xFF2A2A2A or 0xFF181818)
                local border = isSelected and 0xFF1AE591 or (hovered and 0xFF555555 or 0xFF2A2A2A)
                popupDrawList:AddRectFilled(itemPos, imgui.ImVec2(itemPos.x + cardW, itemPos.y + itemH), bg, 4)
                popupDrawList:AddRect(itemPos, imgui.ImVec2(itemPos.x + cardW, itemPos.y + itemH), border, 4, 15, 1.0)
                if hasIcon then
                    popupDrawList:AddImage(serverIcons[srvName], imgui.ImVec2(itemPos.x + 6, itemPos.y + 5), imgui.ImVec2(itemPos.x + 22, itemPos.y + 21))
                    popupDrawList:AddText(imgui.ImVec2(itemPos.x + 28, itemPos.y + 4), hovered and 0xFFFFFFFF or 0xFFCCCCCC, srv)
                else
                    popupDrawList:AddText(imgui.ImVec2(itemPos.x + 8, itemPos.y + 4), hovered and 0xFFFFFFFF or 0xFFCCCCCC, srv)
                end
                imgui.SetCursorScreenPos(itemPos)
                if imgui.InvisibleButton("##srv_filter_" .. i, imgui.ImVec2(cardW, itemH)) then
                    lbServerFilter.v = i - 1; imgui.CloseCurrentPopup()
                end
            end
        else
            local visibleCount = math.min(#serverList, 10)
            local scrollH = visibleCount * itemH + 2
            imgui.BeginChild("##srv_filter_scroll", imgui.ImVec2(childW, scrollH), true)
            local childDrawList = imgui.GetWindowDrawList()
            for i = 1, #serverList do
                local srv = serverList[i]; local isSelected = (lbServerFilter.v == i - 1)
                local srvName = serverListClean[i]; local hasIcon = srvName and serverIcons[srvName] ~= nil
                local itemPos = imgui.GetCursorScreenPos()
                local hovered = (imgui.GetMousePos().x >= itemPos.x and imgui.GetMousePos().x <= itemPos.x + cardW and imgui.GetMousePos().y >= itemPos.y and imgui.GetMousePos().y <= itemPos.y + itemH)
                local bg = isSelected and 0xFF1E3D1E or (hovered and 0xFF2A2A2A or 0xFF181818)
                local border = isSelected and 0xFF1AE591 or (hovered and 0xFF555555 or 0xFF2A2A2A)
                childDrawList:AddRectFilled(itemPos, imgui.ImVec2(itemPos.x + cardW, itemPos.y + itemH), bg, 4)
                childDrawList:AddRect(itemPos, imgui.ImVec2(itemPos.x + cardW, itemPos.y + itemH), border, 4, 15, 1.0)
                if hasIcon then
                    childDrawList:AddImage(serverIcons[srvName], imgui.ImVec2(itemPos.x + 6, itemPos.y + 5), imgui.ImVec2(itemPos.x + 22, itemPos.y + 21))
                    childDrawList:AddText(imgui.ImVec2(itemPos.x + 28, itemPos.y + 4), hovered and 0xFFFFFFFF or 0xFFCCCCCC, srv)
                else
                    childDrawList:AddText(imgui.ImVec2(itemPos.x + 8, itemPos.y + 4), hovered and 0xFFFFFFFF or 0xFFCCCCCC, srv)
                end
                imgui.SetCursorScreenPos(itemPos)
                if imgui.InvisibleButton("##srv_filter_" .. i, imgui.ImVec2(cardW, itemH)) then
                    lbServerFilter.v = i - 1; imgui.CloseCurrentPopup()
                end
            end
            imgui.EndChild()
        end
        imgui.EndPopup()
    end

    pos.y = pos.y + hH

    for i, entry in ipairs(filteredCache) do
        if i > lbRowsLimit then break end
        local rowTop = pos.y
        if rowTop + rowHFixed < visMinY or rowTop > visMaxY then
            pos.y = pos.y + rowHFixed
        else
            local cornerFlags = (i == visibleRows) and 12 or 0
            local rowH, hovered = drawRow(pos.x, pos.y, tableWidth, colX, entry, i, false, cornerFlags, rowHFixed)
            if hasResources then
                drawDetailButton(colX[6] - 34, pos.y + rowH / 2, "##res_" .. i, function()
                    for _, rk in ipairs(resKeysMain) do imgui.Text(u8(rk .. ": " .. formatNumber(entry.resources[rk] or 0))) end
                end, nil)
            elseif isIM then
                drawDetailButton(colX[6] - 34, pos.y + rowH / 2, "##detail_" .. i, function()
                    local imVal, shVal = 0, 0
                    if entry.resources then imVal = entry.resources["im"] or 0; shVal = entry.resources["shards"] or 0 end
                    imgui.Text("Item Market: " .. formatNumber(imVal) .. "$")
                    imgui.Text(u8("Осколки тайников: ") .. formatNumber(shVal) .. "$")
                end, nil)
            elseif isIncome then
                drawDetailButton(colX[6] - 34, pos.y + rowH / 2, "##detail_" .. i, function()
                    local name = entry.name
                    local modeNames = {Farm = u8("Ферма"), Mine = u8("Шахта"), Sawmill = u8("Лесопилка"), IM = u8("Сторонний доход")}
                    for _, m in ipairs({"Farm", "Mine", "Sawmill", "IM"}) do
                        local otherCache = leaderboardCache[m] and leaderboardCache[m][period]
                        local found = false
                        if otherCache then for _, e in ipairs(otherCache) do if e.name == name then imgui.Text(modeNames[m] .. ": " .. formatNumber(e.amount) .. "$"); found = true; break end end end
                        if not found then imgui.Text(modeNames[m] .. ": 0$") end
                    end
                end, function() for _, m in ipairs({"Farm", "Mine", "Sawmill", "IM"}) do loadLeaderboard(period, m) end end)
            end
            if i < visibleRows then
                drawList:AddLine(imgui.ImVec2(pos.x + 6, pos.y + rowH), imgui.ImVec2(pos.x + tableWidth - 6, pos.y + rowH), C.CARD_BORDER, 1.0)
            end
            pos.y = pos.y + rowH
        end
    end

    drawColumnLines(pos.x, colX, tableTopY, tableTopY + tableTotalH)
    drawList:AddRect(imgui.ImVec2(pos.x, tableTopY), imgui.ImVec2(pos.x + tableWidth, tableTopY + tableTotalH), C.CARD_BORDER, 8, 15, 1.2)

    imgui.SetCursorScreenPos(imgui.ImVec2(pos.x, pos.y + 10))
    imgui.Dummy(imgui.ImVec2(tableWidth, 0))
    imgui.EndChild()
end
function drawBinderTab()
    local winW = imgui.GetWindowWidth()
    local drawList = imgui.GetWindowDrawList()
    local listW = imgui.GetWindowWidth() - 25
    
    local colCardH = 22
    local colCardY = imgui.GetCursorScreenPos().y
    local colCardX = imgui.GetCursorScreenPos().x
    
    local headerBg = useCustomTheme and imVec4ToHex(CUSTOM_THEME.cardBg) or 0xFF222222
    drawList:AddRectFilled(imgui.ImVec2(colCardX, colCardY), imgui.ImVec2(colCardX + listW, colCardY + colCardH), headerBg, 4)
    
    local headerNazvanie = u8("Название бинда")
    local headerKlavisha = u8("Клавиша")
    local headerUpravlenie = u8("Управление")
    
    local klavW = imgui.CalcTextSize(headerKlavisha).x
    local uprW = imgui.CalcTextSize(headerUpravlenie).x
    
    drawList:AddText(imgui.ImVec2(colCardX + 12, colCardY + 3), 0xFF888888, headerNazvanie)
    drawList:AddText(imgui.ImVec2(colCardX + listW / 2 - klavW / 2, colCardY + 3), 0xFF888888, headerKlavisha)
    drawList:AddText(imgui.ImVec2(colCardX + listW - 65 - uprW / 2, colCardY + 3), 0xFF888888, headerUpravlenie)
    
    imgui.Dummy(imgui.ImVec2(listW, colCardH + 4))
    
    if #bindDatabase.binds == 0 then
        imgui.Text(u8("Нет биндов. Создайте новый!"))
    else
        for key, val in ipairs(bindDatabase.binds) do
            imgui.BindCard(key, val, winW)
        end
    end
    
    -- Попап редактирования
    if imgui.BeginPopupModal(u8("Редактирование бинда"), nil, imgui.WindowFlags.AlwaysAutoResize) then
        if editingBindIdx and bindDatabase.binds[editingBindIdx] then
            local val = bindDatabase.binds[editingBindIdx]
            imgui.Text(u8("Название:")); imgui.PushItemWidth(350)
            imgui.InputText("##editname", editBindName); imgui.PopItemWidth()
            imgui.Spacing(); imgui.Separator(); imgui.Spacing()
            if imadd.HotKey("##edithotkey", val, lastKeys, 100) then saveBinderDatabase() end
            imgui.SameLine(); imgui.Text(u8("Клавиша(-и)"))
            imgui.Spacing(); imgui.Separator(); imgui.Spacing()
            if imgui.CollapsingHeader(u8("Подсказка по переменным")) then
                imgui.BulletText(u8("{WAIT-5} - задержка 5 сек."))
                imgui.BulletText(u8("{INPUT} в конце - ввод без отправки"))
                imgui.BulletText(u8("{CMD} в конце - команда скрипта"))
                imgui.BulletText(u8("{MY_NAME} / {MY_ID}"))
            end
            imgui.Spacing()
            imgui.Text(u8("Текст бинда (каждая строка - отдельное сообщение):"))
            imgui.InputTextMultiline("##edittext", editBindMultiline, imgui.ImVec2(400, 150))
            imgui.Spacing(); imgui.Separator(); imgui.Spacing()
            local winWidth = imgui.GetWindowWidth(); local btnW = 120
            imgui.SetCursorPosX((winWidth - btnW * 2 - 10) / 2)
            if imgui.Button(u8("Сохранить"), imgui.ImVec2(btnW, 25)) then
                if editBindName.v ~= "" and editBindMultiline.v ~= "" then
                    val.name = u8:decode(editBindName.v); val.text = {}
                    for line in (u8:decode(editBindMultiline.v) .. "\n"):gmatch("(.-)\r?\n") do
                        if line ~= "" then table.insert(val.text, line) end
                    end
                    saveBinderDatabase(); imgui.CloseCurrentPopup()
                else sampAddChatMessage(SCRIPT_PREFIX .. "Заполните все поля!", SCRIPT_COLOR) end
            end
            imgui.SameLine()
            if imgui.Button(u8("Отмена"), imgui.ImVec2(btnW, 25)) then imgui.CloseCurrentPopup() end
        end
        imgui.EndPopup()
    end
    
    imgui.Spacing()
    if StyleButton(fa.ICON_PLUS .. u8("  ДОБАВИТЬ БИНД"), nil, nil) then
        bindDatabase.binds[#bindDatabase.binds + 1] = {name = "", text = {}, v = {}}
        imgui.OpenPopup(u8("Добавление бинда##add_popup"))
    end
    
    if imgui.BeginPopupModal(u8("Добавление бинда##add_popup"), nil, imgui.WindowFlags.AlwaysAutoResize) then
        imgui.Text(u8("Название:")); imgui.PushItemWidth(350)
        imgui.InputText("##addname", addBindName); imgui.PopItemWidth()
        imgui.Spacing(); imgui.Separator(); imgui.Spacing()
        if imadd.HotKey("##addhotkey", bindDatabase.binds[#bindDatabase.binds], lastKeys, 120) then saveBinderDatabase() end
        imgui.SameLine(); imgui.Text(u8("Клавиша(-и)"))
        imgui.Spacing(); imgui.Separator(); imgui.Spacing()
        if imgui.CollapsingHeader(u8("Подсказка по переменным")) then
            imgui.BulletText(u8("{WAIT-5} - задержка 5 сек."))
            imgui.BulletText(u8("{INPUT} в конце - ввод без отправки"))
            imgui.BulletText(u8("{CMD} в конце - команда скрипта"))
            imgui.BulletText(u8("{MY_NAME} / {MY_ID}"))
        end
        imgui.Spacing()
        imgui.Text(u8("Текст бинда (каждая строка - отдельное сообщение):"))
        imgui.InputTextMultiline("##addtext", addBindMultiline, imgui.ImVec2(400, 150))
        imgui.Spacing(); imgui.Separator(); imgui.Spacing()
        local winWidth = imgui.GetWindowWidth(); local btnW = 120
        imgui.SetCursorPosX((winWidth - btnW * 2 - 10) / 2)
        if imgui.Button(u8("Добавить"), imgui.ImVec2(btnW, 25)) then
            if addBindName.v ~= "" and addBindMultiline.v ~= "" then
                local newBind = bindDatabase.binds[#bindDatabase.binds]
                newBind.name = u8:decode(addBindName.v); newBind.text = {}
                for line in (u8:decode(addBindMultiline.v) .. "\n"):gmatch("(.-)\r?\n") do
                    if line ~= "" then table.insert(newBind.text, line) end
                end
                saveBinderDatabase(); imgui.CloseCurrentPopup()
                addBindName.v = ""; addBindMultiline.v = ""
            else sampAddChatMessage(SCRIPT_PREFIX .. "Заполните все поля!", SCRIPT_COLOR) end
        end
        imgui.SameLine()
        if imgui.Button(u8("Отмена"), imgui.ImVec2(btnW, 25)) then
            table.remove(bindDatabase.binds, #bindDatabase.binds); imgui.CloseCurrentPopup()
        end
        imgui.EndPopup()
    end
end
function drawProfileCard()
    if not profilePopupOpen then return end
    if not headerWinPos or not headerWinSize then return end
    refreshMyOverallRank()
    
    local cardW, cardH = 280, 330
    local cardX = mainWinPos.x + 1020 + 5
    local cardY = mainWinPos.y
    
    imgui.SetNextWindowPos(imgui.ImVec2(cardX, cardY), imgui.Cond.Always)
    imgui.SetNextWindowSize(imgui.ImVec2(cardW, cardH), imgui.Cond.Always)
    imgui.PushStyleVar(imgui.StyleVar.WindowPadding, imgui.ImVec2(0, 0))
    imgui.PushStyleVar(imgui.StyleVar.WindowRounding, 10)
    imgui.Begin(u8("##profile_card"), nil, imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar)
    
    local winPos = imgui.GetWindowPos()
    local drawList = imgui.GetWindowDrawList()
    local mp = imgui.GetMousePos()
    
    local theme
    if useCustomTheme then
        theme = CUSTOM_THEME
    else
        theme = THEME_CONFIGS[currentTheme] or THEME_CONFIGS[THEMES.DEFAULT]
    end
    if not theme then theme = THEME_CONFIGS[THEMES.DEFAULT] end
    local accentHex = getColorHex(theme.accent)
    
    if imgui.IsMouseClicked(0) and not avatarHoveredGlobal
        and not imgui.IsMouseHoveringRect(winPos, imgui.ImVec2(winPos.x + cardW, winPos.y + cardH), false) then
        profilePopupOpen = false
    end
    
    local cX, cY = winPos.x, winPos.y
    drawList:AddRectFilled(imgui.ImVec2(cX + 3, cY + 3), imgui.ImVec2(cX + cardW + 3, cY + cardH + 3), 0x55000000, 10)
    drawList:AddRectFilled(imgui.ImVec2(cX, cY), imgui.ImVec2(cX + cardW, cY + cardH), 0xFF181818, 10)
    drawList:AddRect(imgui.ImVec2(cX, cY), imgui.ImVec2(cX + cardW, cY + cardH), 0xFF2E2E2E, 10, 15, 1.0)
    
    local _, ppid = sampGetPlayerIdByCharHandle(PLAYER_PED)
    local nick = sampGetPlayerNickname(ppid) or "?"
    local tgOk = tgConfig.enabled and tgConfig.botToken ~= "" and tgConfig.chatId ~= ""
    local lbOk = lbEnabledCache
    local dash = homeDashCache or {}
    
    local headH = 64
    drawList:AddRectFilled(imgui.ImVec2(cX, cY), imgui.ImVec2(cX + cardW, cY + headH), applyAlpha(accentHex, 0.12), 10, 3)
    drawList:AddLine(imgui.ImVec2(cX, cY + headH), imgui.ImVec2(cX + cardW, cY + headH), 0xFF2E2E2E, 1.0)
    
    local avR = 20
    drawList:AddCircleFilled(imgui.ImVec2(cX + 34, cY + headH / 2), avR, accentHex, 28)
    drawList:AddCircle(imgui.ImVec2(cX + 34, cY + headH / 2), avR + 2, applyAlpha(accentHex, 0.4), 28, 1.5)
    local bigUserSz = imgui.CalcTextSize(fa.ICON_USER)
    drawList:AddText(imgui.ImVec2(cX + 34 - bigUserSz.x / 2, cY + headH / 2 - bigUserSz.y / 2), 0xFF0A0A0A, fa.ICON_USER)
    
    drawList:AddText(imgui.ImVec2(cX + 64, cY + 14), 0xFFFFFFFF, nick)
    drawList:AddText(imgui.ImVec2(cX + 64, cY + 34), 0xFF999999, u8(getCurrentServer()))
    
    local rowY = cY + headH + 14
    
    local metricW = (cardW - 32 - 10) / 2
    local metricH = 54
    
    -- Доход за сегодня
    drawList:AddRectFilled(imgui.ImVec2(cX + 16, rowY), imgui.ImVec2(cX + 16 + metricW, rowY + metricH), 0xFF1E1E1E, 6)
    drawList:AddRect(imgui.ImVec2(cX + 16, rowY), imgui.ImVec2(cX + 16 + metricW, rowY + metricH), 0xFF333333, 6, 15, 1.0)
    drawList:AddText(imgui.ImVec2(cX + 26, rowY + 8), 0xFF888888, u8("Доход за сегодня"))
    drawList:AddText(imgui.ImVec2(cX + 26, rowY + 24), 0xFF33CC66, formatNumber(dash.total or 0) .. "$")
    if (dash.totalAZ or 0) > 0 then
        drawList:AddText(imgui.ImVec2(cX + 26, rowY + 38), 0xFFE0B84C, "+" .. formatNumber(dash.totalAZ or 0) .. " AZ")
    end
    
    -- Время в игре
    local m2X = cX + 16 + metricW + 10
    drawList:AddRectFilled(imgui.ImVec2(m2X, rowY), imgui.ImVec2(m2X + metricW, rowY + metricH), 0xFF1E1E1E, 6)
    drawList:AddRect(imgui.ImVec2(m2X, rowY), imgui.ImVec2(m2X + metricW, rowY + metricH), 0xFF333333, 6, 15, 1.0)
    drawList:AddText(imgui.ImVec2(m2X + 10, rowY + 8), 0xFF888888, u8("Время в игре"))
    local sessionSec = os.time() - (gameSessionStartTime or os.time())
    local sessionH = math.floor(sessionSec / 3600)
    local sessionM = math.floor((sessionSec % 3600) / 60)
    local sessionS = sessionSec % 60
    drawList:AddText(imgui.ImVec2(m2X + 10, rowY + 28), 0xFFDDDDDD, u8(string.format("%d ч %02d мин %02d сек", sessionH, sessionM, sessionS)))
    
    rowY = rowY + metricH + 14
    
    local nextAch, nextRatio = nil, -1
    for _, ach in ipairs(ACHIEVEMENTS) do
        if not ach.completed and ach.target and ach.target > 0 then
            local ratio = (ach.progress or 0) / ach.target
            if ratio > nextRatio then nextRatio = ratio; nextAch = ach end
        end
    end
    
    drawList:AddText(imgui.ImVec2(cX + 16, rowY), 0xFF888888, u8("Ближайшее достижение"))
    rowY = rowY + 18
    local goalH = 46
    local goalHovered = mp.x >= cX + 16 and mp.x <= cX + cardW - 16 and mp.y >= rowY and mp.y <= rowY + goalH
    drawList:AddRectFilled(imgui.ImVec2(cX + 16, rowY), imgui.ImVec2(cX + cardW - 16, rowY + goalH), goalHovered and 0xFF232323 or 0xFF1E1E1E, 6)
    drawList:AddRect(imgui.ImVec2(cX + 16, rowY), imgui.ImVec2(cX + cardW - 16, rowY + goalH), goalHovered and accentHex or 0xFF333333, 6, 15, 1.0)
    if nextAch then
        drawList:AddText(imgui.ImVec2(cX + 26, rowY + 8), accentHex, nextAch.icon or fa.ICON_STAR)
        local iconW = imgui.CalcTextSize(nextAch.icon or fa.ICON_STAR).x
        drawList:AddText(imgui.ImVec2(cX + 30 + iconW, rowY + 8), 0xFFEEEEEE, u8(nextAch.name))
        local barW2 = cardW - 32 - 20
        local barX2 = cX + 26
        local barY2 = rowY + 28
        drawList:AddRectFilled(imgui.ImVec2(barX2, barY2), imgui.ImVec2(barX2 + barW2, barY2 + 6), 0xFF2A2A2A, 3)
        drawList:AddRectFilled(imgui.ImVec2(barX2, barY2), imgui.ImVec2(barX2 + barW2 * nextRatio, barY2 + 6), accentHex, 3)
        local progLabel = (nextAch.progress or 0) .. "/" .. nextAch.target
        local progLabelW = imgui.CalcTextSize(progLabel).x
        drawList:AddText(imgui.ImVec2(cX + cardW - 16 - progLabelW - 6, rowY + 8), 0xFF999999, progLabel)
    else
        drawList:AddText(imgui.ImVec2(cX + 26, rowY + 16), 0xFF888888, u8("Все достижения выполнены!"))
    end
    imgui.SetCursorScreenPos(imgui.ImVec2(cX + 16, rowY))
    if imgui.InvisibleButton("##profile_goal", imgui.ImVec2(cardW - 32, goalH)) then
        currentTab = 8
        profilePopupOpen = false
    end
    rowY = rowY + goalH + 14
    
    local pillH = 30
    local pillGap = 8
    local pillW = (cardW - 32 - pillGap) / 2
    
    -- Telegram
    do
        local px = cX + 16
        local hovered = mp.x >= px and mp.x <= px + pillW and mp.y >= rowY and mp.y <= rowY + pillH
        local col = tgOk and (hovered and 0xFF234A32 or 0xFF1E3324) or (hovered and 0xFF232323 or 0xFF1E1E1E)
        local border = tgOk and 0xFF2E7D45 or (hovered and accentHex or 0xFF333333)
        local fg = tgOk and 0xFF4CD973 or 0xFF888888
        drawList:AddRectFilled(imgui.ImVec2(px, rowY), imgui.ImVec2(px + pillW, rowY + pillH), col, pillH / 2)
        drawList:AddRect(imgui.ImVec2(px, rowY), imgui.ImVec2(px + pillW, rowY + pillH), border, pillH / 2, 15, 1.0)
        drawList:AddText(imgui.ImVec2(px + 10, rowY + 8), fg, fa.ICON_PAPER_PLANE)
        drawList:AddText(imgui.ImVec2(px + 28, rowY + 8), fg, tgOk and u8("Telegram") or u8("Не настроен"))
        imgui.SetCursorScreenPos(imgui.ImVec2(px, rowY))
        if imgui.InvisibleButton("##profile_pill_1", imgui.ImVec2(pillW, pillH)) then
            currentTab = 10
            settingsExpandedTelegram = true
            profilePopupOpen = false
        end
    end
    
    -- Рейтинг
    do
        local px = cX + 16 + pillW + pillGap
        local hovered = mp.x >= px and mp.x <= px + pillW and mp.y >= rowY and mp.y <= rowY + pillH
        local col = lbOk and (hovered and 0xFF234A32 or 0xFF1E3324) or (hovered and 0xFF232323 or 0xFF1E1E1E)
        local border = lbOk and 0xFF2E7D45 or (hovered and accentHex or 0xFF333333)
        local fg = lbOk and 0xFF4CD973 or 0xFF888888
        drawList:AddRectFilled(imgui.ImVec2(px, rowY), imgui.ImVec2(px + pillW, rowY + pillH), col, pillH / 2)
        drawList:AddRect(imgui.ImVec2(px, rowY), imgui.ImVec2(px + pillW, rowY + pillH), border, pillH / 2, 15, 1.0)
        drawList:AddText(imgui.ImVec2(px + 10, rowY + 8), fg, fa.ICON_TROPHY)
        drawList:AddText(imgui.ImVec2(px + 28, rowY + 8), fg, lbOk and u8("Рейтинг") or u8("Не участвует"))
        imgui.SetCursorScreenPos(imgui.ImVec2(px, rowY))
        if imgui.InvisibleButton("##profile_pill_2", imgui.ImVec2(pillW, pillH)) then
            currentTab = 6
            profilePopupOpen = false
        end
    end
    
    rowY = rowY + pillH + 12
    
    local RANK_GOLD   = 0xFF00D7FF
    local RANK_SILVER = 0xFFC7C7C7
    local RANK_BRONZE = 0xFF327FCD
    local rankIcon, rankLabel, rankCol, rankBg, rankAmountText
    if not lbOk then
        rankIcon = fa.ICON_TROPHY
        rankLabel = u8("Рейтинг отключен")
        rankCol, rankBg = 0xFF666666, 0xFF1E1E1E
    elseif myOverallRank == nil then
        rankIcon = fa.ICON_TROPHY
        rankLabel = u8("Загрузка рейтинга...")
        rankCol, rankBg = 0xFF888888, 0xFF1E1E1E
    elseif myOverallRank == -1 then
        rankIcon = fa.ICON_TROPHY
        rankLabel = u8("Нет в рейтинге")
        rankCol, rankBg = 0xFF888888, 0xFF1E1E1E
    else
        rankIcon = fa.ICON_TROPHY
        rankLabel = u8("#" .. myOverallRank)
        if myOverallAmount then rankAmountText = formatNumber(myOverallAmount) .. "$" end
        if myOverallRank == 1 then rankCol, rankBg = RANK_GOLD, applyAlpha(RANK_GOLD, 0.14)
        elseif myOverallRank == 2 then rankCol, rankBg = RANK_SILVER, applyAlpha(RANK_SILVER, 0.14)
        elseif myOverallRank == 3 then rankCol, rankBg = RANK_BRONZE, applyAlpha(RANK_BRONZE, 0.14)
        else rankCol, rankBg = accentHex, applyAlpha(accentHex, 0.12) end
    end
    
    local rankBadgeX1, rankBadgeX2 = cX + 16, cX + cardW - 16
    if rankAmountText then
        local rankBadgeH = 50
        drawList:AddRectFilled(imgui.ImVec2(rankBadgeX1, rowY), imgui.ImVec2(rankBadgeX2, rowY + rankBadgeH), rankBg, 8)
        drawList:AddRect(imgui.ImVec2(rankBadgeX1, rowY), imgui.ImVec2(rankBadgeX2, rowY + rankBadgeH), applyAlpha(rankCol, 0.5), 8, 15, 1.0)
        local midX = rankBadgeX1 + (rankBadgeX2 - rankBadgeX1) / 2
        drawList:AddLine(imgui.ImVec2(midX, rowY + 8), imgui.ImVec2(midX, rowY + rankBadgeH - 8), 0xFF333333, 1.0)
        drawList:AddText(imgui.ImVec2(rankBadgeX1 + 12, rowY + 8), 0xFF888888, u8("Место в рейтинге"))
        drawList:AddText(imgui.ImVec2(rankBadgeX1 + 12, rowY + 26), rankCol, rankIcon .. "  " .. rankLabel)
        drawList:AddText(imgui.ImVec2(midX + 12, rowY + 8), 0xFF888888, u8("Общий доход"))
        drawList:AddText(imgui.ImVec2(midX + 12, rowY + 26), 0xFF33CC66, rankAmountText)
        rowY = rowY + rankBadgeH
    else
        local rankBadgeH = 32
        drawList:AddRectFilled(imgui.ImVec2(rankBadgeX1, rowY), imgui.ImVec2(rankBadgeX2, rowY + rankBadgeH), rankBg, rankBadgeH / 2)
        drawList:AddRect(imgui.ImVec2(rankBadgeX1, rowY), imgui.ImVec2(rankBadgeX2, rowY + rankBadgeH), applyAlpha(rankCol, 0.5), rankBadgeH / 2, 15, 1.0)
        local rankIconSz = imgui.CalcTextSize(rankIcon)
        local rankTextSz = imgui.CalcTextSize(rankLabel)
        local rankGap = 8
        local rankGroupW = rankIconSz.x + rankGap + rankTextSz.x
        local rankGroupX = rankBadgeX1 + ((rankBadgeX2 - rankBadgeX1) - rankGroupW) / 2
        local rankCenterY = rowY + rankBadgeH / 2
        drawList:AddText(imgui.ImVec2(rankGroupX, rankCenterY - rankIconSz.y / 2), rankCol, rankIcon)
        drawList:AddText(imgui.ImVec2(rankGroupX + rankIconSz.x + rankGap, rankCenterY - rankTextSz.y / 2), rankCol, rankLabel)
        rowY = rowY + rankBadgeH
    end
    
    imgui.End()
    imgui.PopStyleVar(2)
end
function imgui.OnDrawFrame()
    if not mainWin.v and not isWindowAnimating() and not settings.farmOverlayEnabled and not settings.mineOverlayEnabled and not settings.sawmillOverlayEnabled and not settings.oilOverlayEnabled and #achievementNotifications == 0 then return end
    
    if settings.farmOverlayEnabled then drawFarmOverlay() end
    if settings.mineOverlayEnabled then drawMineOverlay() end
    if settings.sawmillOverlayEnabled then drawSawmillOverlay() end
    if settings.oilOverlayEnabled then drawOilOverlay() end
    if mainWin.v or isWindowAnimating() then drawMainMenu() end
    if not mainWin.v then profilePopupOpen = false end
    drawProfileCard()
    drawAchievementNotifications()
end
function imgui.TextColoredRGB(string)
    local style = imgui.GetStyle()
    local colors = style.Colors
    local clr = imgui.Col
    local function color_imvec4(color)
        if color:upper():sub(1, 6) == 'SSSSSS' then return imgui.ImVec4(colors[clr.Text].x, colors[clr.Text].y, colors[clr.Text].z, tonumber(color:sub(7, 8), 16) and tonumber(color:sub(7, 8), 16)/255 or colors[clr.Text].w) end
        local color = type(color) == 'number' and ('%X'):format(color):upper() or color:upper()
        local rgb = {}
        for i = 1, #color/2 do rgb[#rgb+1] = tonumber(color:sub(2*i-1, 2*i), 16) end
        return imgui.ImVec4(rgb[1]/255, rgb[2]/255, rgb[3]/255, rgb[4] and rgb[4]/255 or colors[clr.Text].w)
    end
    local function render_text(string)
        for w in string:gmatch('[^\r\n]+') do
            local text, color = {}, {}
            local m = 1
            w = w:gsub('{(......)}', '{%1FF}')
            while w:find('{........}') do
                local n, k = w:find('{........}')
                if tonumber(w:sub(n+1, k-1), 16) or (w:sub(n+1, k-3):upper() == 'SSSSSS' and tonumber(w:sub(k-2, k-1), 16) or w:sub(k-2, k-1):upper() == 'SS') then
                    text[#text], text[#text+1] = w:sub(m, n-1), w:sub(k+1, #w)
                    color[#color+1] = color_imvec4(w:sub(n+1, k-1))
                    w = w:sub(1, n-1)..w:sub(k+1, #w); m = n
                else w = w:sub(1, n-1)..w:sub(n, k-3)..'}'..w:sub(k+1, #w) end
            end
            if text[0] then
                for i, k in pairs(text) do imgui.TextColored(color[i] or colors[clr.Text], u8(k)); imgui.SameLine(nil, 0) end
                imgui.NewLine()
            else imgui.Text(u8(w)) end
        end
    end
    render_text(string)
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
    
    -- Если версия совпадает и папка server_icons существует - выходим
    if currentVersion == RESOURCE_VERSION and doesDirectoryExist(dirml.."/ResHelper/files/server_icons/") then return end
    
    -- Создаём папки
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
                    
                    local cmd = 'powershell -WindowStyle Hidden -NoProfile -ExecutionPolicy Bypass -command "$sh=New-Object -ComObject Shell.Application;$sh.Namespace(\\"' .. dirml .. '\\").CopyHere($sh.Namespace(\\"' .. zipPath .. '\\").Items(),16)"'
                    os.execute(cmd)
                    
                    lua_thread.create(function()
                        wait(3000)
                        if doesFileExist(zipPath) then os.remove(zipPath) end
                        
                        local f = io.open(versionFile, "w")
                        if f then f:write(RESOURCE_VERSION); f:close() end
                        
                        sampAddChatMessage(SCRIPT_PREFIX .. "Ресурсы обновлены! Перезагружаю скрипт...", SCRIPT_COLOR)
                        wait(500)
                        thisScript():reload()
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
    checkAndInstallResources()
    if doesFileExist(dirml.."/ResHelper/files/logo-ArzResHelper.png") then
        logoArz = imgui.CreateTextureFromFile(dirml.."/ResHelper/files/logo-ArzResHelper.png")
    end
    loadServerIcons()
    loadConfig()
    loadTgConfig()
    tgTokenInput.v = u8(tgConfig.botToken)
    tgChatIdInput.v = u8(tgConfig.chatId)
    loadThemeConfig()
    loadCustomTheme()
    cb_useCustomTheme.v = useCustomTheme
    initStatsMigration()
    loadOverlayConfig()
    initPricesFile()
    initGoalsFiles()
    loadGoalsProgress()
    loadAchievements()
    loadItemMarketStats()
    loadShardStats()
	loadInvestmentStats()
    loadInvestmentConfig()
    loadPaydayStats()
    loadOilStats()
    loadOilConfig()
    loadCaseConfig()
	loadLbRowsLimit()
    local today = getGameDate()
    local lastPricesDate = ""
    local pf = io.open(pricesStatePath, "r")
    if pf then lastPricesDate = pf:read("*line") or ""; pf:close() end
    if lastPricesDate ~= today then loadGlobalPrices() end
    loadTotalIncomeGoal()
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
    local savedSessDate, savedSessStart = loadSessionState()
    if savedSessDate == getGameDate() and savedSessStart then
        gameSessionStartTime = savedSessStart
    else
        gameSessionStartTime = os.time()
        saveSessionState()
    end
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