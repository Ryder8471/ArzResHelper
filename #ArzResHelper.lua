script_name("ResHelper")
script_authors("Ryder")
script_description("Helper for Farm & Mine Resources")
script_version("1.0.19")
script_properties("work-in-progress")
setver = 1

require "lib.sampfuncs"
require "lib.moonloader"
local mem = require "memory"
local vkeys = require "vkeys"
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
local firstOpen = true
local autoScanned = false
local autoScanningInProgress = false
local ignoreInventoryUntil = 0
local scanSlotCounts = {}
local scanSlots = {}
local logoArz = nil
local LOG_AGGREGATION_INTERVAL = 10 -- секунд для объединения записей

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
Не обнаружены некоторые важные файлы для работы скрипта.
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
local res, fa = pcall(require, 'faIcons')
assert(res, "Библиотека faIcons не найдена")
local res, rkeys = pcall(require, 'rkeysFD')
assert(res, "Библиотека Rkeys не найдена")

-- Добавляем ImGui Addons для HotKey (если нет)
local imadd = nil
if doesFileExist(getWorkingDirectory() .. "/lib/imgui_addons.lua") then
    imadd = require "imgui_addons"
else
    -- Если нет библиотеки, создадим базовый HotKey
    imadd = {}
    function imadd.HotKey(label, bindTable, lastKeys, width)
        -- Заглушка, реальный HotKey может не работать без библиотеки
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
local select_menu = {true, false, false, false, false, false, false, false}

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
local farmGoalsConfigPath = configDir .. "farm_goals.json"
local mineGoalsConfigPath = configDir .. "mine_goals.json"

if not doesDirectoryExist(configDir) then createDirectory(configDir) end
if not doesDirectoryExist(soundsDir) then createDirectory(soundsDir) end

local WORK_TYPES = { FARM = 1, MINE = 2, SAWMILL = 3 }

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
        resourceOrder = {"firewood", "quality_wood", "rare_box"},
        resourceNames = { firewood = "Дрова", quality_wood = "Древесина высшего качества", rare_box = "Выпавшие ларцы" },
        defaultPrices = { firewood = 5000, quality_wood = 50000, rare_box = 0 },
        defaultGoals = { firewood = 200, quality_wood = 20, rare_box = 5 },
        rareResources = {"quality_wood", "rare_box"},
        statsPath = configDir .. "sawmill_stats.json",
        scanNames = {
            ["Дрова"] = "firewood",
            ["Древесина высшего качества"] = "quality_wood"
        }
    }
}	

local currentWork = WORK_TYPES.FARM
local config = configs[currentWork]

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
local sessionStartTime = os.time()  -- Время начала текущей сессии

local resourceLog = {}
local loadedLogs = false

local settings = {
    chatNotifyEnabled = false, goalSoundEnabled = true, pickupSoundEnabled = true,
    goalSoundVolume = 80, pickupSoundVolume = 80,
    farmOverlayEnabled = false, mineOverlayEnabled = false, sawmillOverlayEnabled = false,
    undermineEnabled = false, underminelavkaEnabled = false, regularmineEnabled = false, farmEnabled = false, sawmillEnabled = false,
    overlayTimerEnabled = false, totalIncomeGoal = 1000000
}

local inventoryCache = {}

local scanState = {
    active = false,
    scanning = false,
    foundResources = {},
    statusText = "",
    waitForInventory = false,
    scanned = false
}

local inventoryBase = {}
local lastServerMessageTime = {}  -- Время последнего сообщения "Вам был добавлен предмет" для каждого ресурса
local pendingResources = {}  -- Ожидающие засчитывания: {resourceName = amount}
local changelogShown = false
local changelogPath = configDir .. "changelog_shown.txt"
local changelogData = nil
local changelogUrl = "https://raw.githubusercontent.com/Ryder8471/ArzResHelper/main/changelog.json"

local mineItemMappingByID = { ["596"] = "stone", ["597"] = "metal", ["598"] = "bronze", ["599"] = "silver", ["600"] = "gold", ["7425"] = "diamond", ["7424"] = "tkan", ["7423"] = "splav", ["7281"] = "materia", ["7426"] = "azbox" }
local mineItemAmounts = { stone = 6, metal = 3, bronze = 3, silver = 2, gold = 2, diamond = 1, tkan = 1, splav = 1, materia = 1, azbox = 1 }

local needSave = false
local needSaveColor = imgui.ImColor(250, 66, 66, 102):GetVec4()

local overlayConfigs = {
    [WORK_TYPES.FARM] = { x = 15, y = 300, w = 220, h = 160 },
    [WORK_TYPES.MINE] = { x = 15, y = 300, w = 280, h = 200 },
    [WORK_TYPES.SAWMILL] = { x = 15, y = 300, w = 220, h = 120 }
}

-- Таймер для оверлея
local overlayTimer = {
    enabled = false,
    running = false,
    startTime = 0,
    elapsed = 0,
    displayedTime = "00:00:00",
}
local cb_overlay_timer = imgui.ImBool(false)  -- Чекбокс в настройках
local totalGoalEdit = imgui.ImInt(0)

-- Настройки для GUI
local cb_farm = imgui.ImBool(false)
local cb_undermine = imgui.ImBool(false)
local cb_lavka = imgui.ImBool(false)
local cb_regular = imgui.ImBool(false)
local cb_chatNotify = imgui.ImBool(false)
local cb_goalSound = imgui.ImBool(false)
local cb_pickupSound = imgui.ImBool(false)
local cb_farm_overlay = imgui.ImBool(false)
local cb_mine_overlay = imgui.ImBool(false)
local cb_sawmill_overlay = imgui.ImBool(false)
local cb_sawmill = imgui.ImBool(false)
local goal_vol_slider = imgui.ImInt(80)
local pickup_vol_slider = imgui.ImInt(80)
local selectedDateIndexFarm = imgui.ImInt(0)
local selectedDateIndexMine = imgui.ImInt(0)
local farmStatsTab = imgui.ImInt(0)
local mineStatsTab = imgui.ImInt(0)

local priceEdit = {}
local goalEdit = {}
local farmGoalEditCache = {}
local mineGoalEditCache = {}
local sawmillGoalEditCache = {}

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

local function playSoundFile(fn, vol)
    local sf = soundsDir .. fn
    if doesFileExist(sf) then local a = loadAudioStream(sf); if a then setAudioStreamVolume(a, vol / 100); setAudioStreamState(a, 1) end end
end

local function playGoalSound() if settings.goalSoundEnabled and settings.goalSoundVolume > 0 then playSoundFile("achiv.wav", settings.goalSoundVolume) end end

local function playPickupSound(rn)
    if not settings.pickupSoundEnabled or settings.pickupSoundVolume <= 0 then return end
    if rn == "coal" then
        playSoundFile("ugol.wav", settings.pickupSoundVolume)
        return
    end
    if config.rareResources then 
        for _, r in ipairs(config.rareResources) do 
            if rn == r then 
                playSoundFile("rare.wav", settings.pickupSoundVolume)
                return 
            end 
        end 
    end
    playSoundFile("pickup.wav", settings.pickupSoundVolume)
end

local function checkGoalReached(rn)
    local ca = dailyResources[rn] or 0; local g = goals[rn] or 1
    if ca >= g and not goalsReached[rn] then goalsReached[rn] = true; playGoalSound()
        if settings.chatNotifyEnabled then sampAddChatMessage("{00FF00}" .. config.prefix .. " {FFFFFF}Цель достигнута! " .. config.resourceNames[rn] .. ": " .. formatNumber(ca) .. " / " .. formatNumber(g), -1) end
    end
end

local function getGameDate(timestamp)
    local ts = timestamp or os.time()
    local mskTime = ts + 3 * 3600
    local hour = tonumber(os.date("%H", mskTime))
    if hour < 5 then
        mskTime = mskTime - 24 * 3600
    end
    return os.date("%Y-%m-%d", mskTime)
end

local function getDayStats(dateStr)
    local result = {total = 0}
    for _, k in ipairs(config.resourceOrder) do result[k] = 0 end
    for _, log in ipairs(resourceLog) do
        if getGameDate(log.time) == dateStr then
            result[log.resource] = (result[log.resource] or 0) + log.amount
        end
    end
    result.total = 0
    for _, k in ipairs(config.resourceOrder) do
        local price = resourcePrices[k] or config.defaultPrices[k] or 0
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
    
    -- Определяем дату понедельника текущей недели
    local todayDate = getGameDate()
    local year, month, day = todayDate:match("(%d+)-(%d+)-(%d+)")
    year, month, day = tonumber(year), tonumber(month), tonumber(day)
    
    -- Получаем день недели (1 = понедельник, 7 = воскресенье) для игровой даты
    -- Используем МСК для определения дня недели
    local mskTime = os.time() + 3 * 3600
    local mskHour = tonumber(os.date("%H", mskTime))
    local currentDay = tonumber(os.date("%w", mskTime)) -- 0 = воскресенье, 1 = понедельник, ..., 6 = суббота
    if currentDay == 0 then currentDay = 7 end -- Делаем воскресенье = 7
    
    -- Если сейчас до 5 утра, то игровой день ещё предыдущий
    if mskHour < 5 then
        currentDay = currentDay - 1
        if currentDay == 0 then currentDay = 7 end
    end
    
    local result = {total = 0}
    for _, k in ipairs(config.resourceOrder) do result[k] = 0 end
    
    -- Считаем с понедельника по текущий день
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
    if not sessionResources[resourceName] then return end
    local price = resourcePrices[resourceName] or config.defaultPrices[resourceName] or 0
    local value = amount * price
    sessionResources[resourceName] = sessionResources[resourceName] + amount
    sessionTotal = sessionTotal + value
    dailyResources[resourceName] = (dailyResources[resourceName] or 0) + amount
    dailyTotal = dailyTotal + value
    
    -- Оптимизированное логирование
    local now = os.time()
    
    -- Определяем интервал агрегации: для обычных ресурсов дольше, для редких короче
    local isRare = false
    if config.rareResources then
        for _, r in ipairs(config.rareResources) do
            if r == resourceName then isRare = true; break end
        end
    end
    local aggregationInterval = isRare and 600 or 300  -- Редкие: 600 сек, обычные: 300 сек
    
    -- Ищем последнюю запись этого же ресурса
    local lastLog = nil
    for i = #resourceLog, 1, -1 do
        if resourceLog[i].resource == resourceName then
            lastLog = resourceLog[i]
            break
        end
    end
    
    if lastLog and (now - lastLog.time) <= aggregationInterval then
        -- Если таймер запущен и старая запись была до запуска таймера,
        -- создаём новую запись чтобы не смешивать старую статистику с новой
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
        -- Создаём новую запись
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
        if config.scanNames then
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
        flax = 1000, cotton = 1000, rare_tkan = 3000, water = 200, dye = 100, coal = 1500,
        stone = 1000, metal = 1000, bronze = 1000, silver = 1000, gold = 1000,
        diamond = 200, tkan = 200, splav = 200, materia = 50, azbox = 100
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
    scanState.foundResources = {}
    scanState.statusText = "Открываю статистику..."
    scanState.waitForInventory = false
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
    scanSlots = {}
    scanState.scanned = true
        local foundItems = {}
    for _, resKey in ipairs(config.resourceOrder) do
        if resKey ~= "rare_box" then
            local amount = inventoryBase[resKey] or 0
            table.insert(foundItems, config.resourceNames[resKey] .. ": " .. amount .. " шт.")
        end
    end
    sampAddChatMessage("{00FF00}[ResHelher] Сканирование завершено! Найдено в инвентаре:", -1)
    for _, msg in ipairs(foundItems) do
        sampAddChatMessage("{FFFFFF}  " .. msg, -1)
    end
    sampAddChatMessage("{FFA500}[ResHelher] База установлена. Учитывается только новая добыча.", -1)
    scanState.active = false
    scanState.scanning = false
    scanState.statusText = "Готово"
    ignoreInventoryUntil = os.time() + 3
    saveInventoryBase()
    sampCloseCurrentDialogWithButton(0)
end

-- ====== СОХРАНЕНИЕ/ЗАГРУЗКА БАЗЫ ИНВЕНТАРЯ ======
function saveInventoryBase()
    local path
    if currentWork == WORK_TYPES.FARM then path = farmBasePath
    elseif currentWork == WORK_TYPES.MINE then path = mineBasePath
    else path = sawmillBasePath end
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
    local path
    if currentWork == WORK_TYPES.FARM then path = farmBasePath
    elseif currentWork == WORK_TYPES.MINE then path = mineBasePath
    else path = sawmillBasePath end
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
end

-- ====== СОХРАНЕНИЕ/ЗАГРУЗКА ======
function saveStats()
    local file = io.open(config.statsPath, "w")
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
    if loadedLogs then return end
    local file = io.open(config.statsPath, "r")
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
    local path
    if currentWork == WORK_TYPES.FARM then path = farmGoalsProgressPath
    elseif currentWork == WORK_TYPES.MINE then path = mineGoalsProgressPath
    else path = sawmillGoalsProgressPath end
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
    local path
    if currentWork == WORK_TYPES.FARM then path = farmGoalsProgressPath
    elseif currentWork == WORK_TYPES.MINE then path = mineGoalsProgressPath
    else path = sawmillGoalsProgressPath end
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
    local checked = false
    changelogMessageShown = false  
    downloadUrlToFile(changelogUrl, dir, function(id, status, p1, p2)
        if checked then return end
        if status == dlstatus.STATUS_ENDDOWNLOADDATA then
            checked = true
            if doesFileExist(dir) then
                local f = io.open(dir, "r")
                if f then
                    local content = f:read("*a")
                    f:close()
                    local converted = encoding.UTF8:decode(content)
                    changelogData = decodeJson(converted)
                    if changelogData then
                        if not changelogMessageShown then 
                            sampAddChatMessage(SCRIPT_PREFIX .. "Список изменений успешно загружен!", SCRIPT_COLOR)
                            changelogMessageShown = true  
                        end
                    else
                        if not changelogMessageShown then  
                            sampAddChatMessage(SCRIPT_PREFIX .. "Ошибка при чтении списка изменений!", SCRIPT_COLOR)
                            changelogMessageShown = true
                        end
                    end
                end
            end
        elseif status == dlstatus.STATUSEX_ENDDOWNLOAD then
            if not checked then
                checked = true
                if not changelogMessageShown then  
                    sampAddChatMessage(SCRIPT_PREFIX .. "Ошибка при загрузке списка изменений!", SCRIPT_COLOR)
                    changelogMessageShown = true  
            end
        end
    end)
end

-- ====== СБРОС ЦЕЛЕЙ ======
function checkAndResetDaily()
    local mskTime = os.time() + 3 * 3600
    local today = os.date("%Y-%m-%d", mskTime)
    local mskHour = tonumber(os.date("%H", mskTime))
    
    -- Определяем игровую дату (день меняется в 05:00 МСК)
    local gameDate
    if mskHour >= 5 then
        gameDate = today
    else
        gameDate = os.date("%Y-%m-%d", mskTime - 24 * 3600)
    end
    
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
        local f = io.open(resetFile, "w")
        if f then
            f:write(gameDate)
            f:close()
        end
        
        -- Сбрасываем цели для ВСЕХ типов работ
        -- Ферма
        local farmProgressPath = configDir .. "farm_goals_progress.json"
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
        local mineProgressPath = configDir .. "mine_goals_progress.json"
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
        local sawmillProgressPath = configDir .. "sawmill_goals_progress.json"
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
        for _, k in ipairs(config.resourceOrder) do
            goalsReached[k] = false
            sessionResources[k] = 0
            dailyResources[k] = 0
        end
        sessionTotal = 0
        dailyTotal = 0
        sessionStartTime = os.time()
        
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
    file:write("[Settings]\ncurrentWork=" .. currentWork .. "\n")
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
    file:write("sawmillEnabled=" .. (settings.sawmillEnabled and "1" or "0") .. "\n")
    file:close()
end

function loadConfig()
    local file = io.open(configPath, "r")
    if not file then
        for k, v in pairs(config.defaultPrices) do resourcePrices[k] = v; if not priceEdit[k] then priceEdit[k] = imgui.ImInt(v) else priceEdit[k].v = v end end
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
                    if k == "currentWork" then currentWork = tonumber(v) or WORK_TYPES.FARM
                    elseif k == "chatNotifyEnabled" then settings.chatNotifyEnabled = (v == "1")
                    elseif k == "goalSoundEnabled" then settings.goalSoundEnabled = (v == "1")
                    elseif k == "pickupSoundEnabled" then settings.pickupSoundEnabled = (v == "1")
                    elseif k == "goalSoundVolume" then settings.goalSoundVolume = tonumber(v) or 80
                    elseif k == "pickupSoundVolume" then settings.pickupSoundVolume = tonumber(v) or 80
                    elseif k == "farmOverlayEnabled" then settings.farmOverlayEnabled = (v == "1")
                    elseif k == "mineOverlayEnabled" then settings.mineOverlayEnabled = (v == "1")
                    elseif k == "farmEnabled" then settings.farmEnabled = (v == "1")
                    elseif k == "undermineEnabled" then settings.undermineEnabled = (v == "1")
                    elseif k == "underminelavkaEnabled" then settings.underminelavkaEnabled = (v == "1")
                    elseif k == "regularmineEnabled" then settings.regularmineEnabled = (v == "1") 
					elseif k == "overlayTimerEnabled" then settings.overlayTimerEnabled = (v == "1") 
					elseif k == "totalIncomeGoal" then settings.totalIncomeGoal = tonumber(v) or 1000000 
					elseif k == "sawmillOverlayEnabled" then settings.sawmillOverlayEnabled = (v == "1")
                    elseif k == "sawmillEnabled" then settings.sawmillEnabled = (v == "1") end
                end
            end
        end
    end
    file:close()
    switchWorkType(currentWork, true)
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
    -- Блокируем смену режима во время автосканирования
    if not initialLoad and not autoScanned and not scanState.scanned then
        sampAddChatMessage(SCRIPT_PREFIX .. "Дождитесь завершения автосканирования!", SCRIPT_COLOR)
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
	sessionStartTime = os.time()  -- Сбрасываем время начала сессии
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
    loadGoals()
    loadStats()
    loadGoalsProgress()
	sessionStartTime = os.time()  -- Устанавливаем время начала сессии при загрузке скрипта
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
                if text:find("event.inventory.playerInventory") then
                    if os.time() < ignoreInventoryUntil then
                        for itemIdStr, newAmountStr in text:gmatch('"item":(%d+),"amount":(%d+)') do
                            local itemId = tonumber(itemIdStr)
                            local newAmount = tonumber(newAmountStr)
                            if inventoryCache[itemId] then
                                local slots = inventoryCache[itemId]
                                local found = false
                                for i, slotAmount in ipairs(slots) do
                                    if newAmount == slotAmount then found = true; break
                                    elseif math.abs(newAmount - slotAmount) <= 10 then slots[i] = newAmount; found = true; break end
                                end
                                if not found then table.insert(slots, newAmount) end
                            end
                        end
                        saveInventoryBase()
                        raknetBitStreamSetReadOffset(bs, origPos)
                        return
                    end
                    for itemIdStr, newAmountStr in text:gmatch('"item":(%d+),"amount":(%d+)') do
                        local itemId = tonumber(itemIdStr)
                        local newAmount = tonumber(newAmountStr)
                        if currentWork == WORK_TYPES.FARM then
                            local resKey = FARM_ITEM_TO_RES[itemId]
                            local maxStack = getMaxStack(resKey)
                            if newAmount > maxStack * 2 then break end
                            if resKey then
                                if not inventoryCache[itemId] then inventoryCache[itemId] = {} end
                                local slots = inventoryCache[itemId]
                                local found = false
                                local added = 0
                                for i, slotAmount in ipairs(slots) do
                                    if newAmount == slotAmount then found = true; break
                                    elseif newAmount > slotAmount and (newAmount - slotAmount) <= 10 then added = newAmount - slotAmount; slots[i] = newAmount; found = true; break
                                    elseif newAmount < slotAmount and (slotAmount - newAmount) <= 10 then slots[i] = newAmount; found = true; break end
                                end
                                if not found then
                                    local bestMatch = false
                                    for i, slotAmount in ipairs(slots) do
                                        if newAmount > slotAmount then added = newAmount - slotAmount; slots[i] = newAmount; bestMatch = true; break
                                        elseif slotAmount == 100 and newAmount < 100 then slots[i] = newAmount; bestMatch = true; break end
                                    end
                                    if not bestMatch then table.insert(slots, newAmount) end
                                end
                                if added > 0 and added <= 1000 then
                                    pendingResources[resKey] = added
                                    saveInventoryBase()
                                end
                            end
                        elseif currentWork == WORK_TYPES.MINE then
                            if settings.undermineEnabled or settings.underminelavkaEnabled then
                                local resKey = MINE_ITEM_TO_RES[itemId]
                                if resKey then
                                    local maxStack = getMaxStack(resKey)
                                    if newAmount > maxStack * 2 then break end
                                    if not inventoryCache[itemId] then inventoryCache[itemId] = {} end
                                    local slots = inventoryCache[itemId]
                                    local found = false
                                    local added = 0
                                    for i, slotAmount in ipairs(slots) do
                                        if newAmount == slotAmount then found = true; break
                                        elseif newAmount > slotAmount and (newAmount - slotAmount) <= 10 then added = newAmount - slotAmount; slots[i] = newAmount; found = true; break
                                        elseif newAmount < slotAmount and (slotAmount - newAmount) <= 10 then slots[i] = newAmount; found = true; break end
                                    end
                                    if not found then
                                        local bestMatch = false
                                        for i, slotAmount in ipairs(slots) do
                                            if newAmount > slotAmount then added = newAmount - slotAmount; slots[i] = newAmount; bestMatch = true; break end
                                        end
                                        if not bestMatch then table.insert(slots, newAmount) end
                                    end
                                    if added > 0 and added <= 1000 then
                                        pendingResources[resKey] = added
                                        saveInventoryBase()
                                    end
                                end
                            end
                        elseif currentWork == WORK_TYPES.SAWMILL then
                            local resKey = SAWMILL_ITEM_TO_RES[itemId]
                            if resKey then
                                if not inventoryCache[itemId] then inventoryCache[itemId] = {} end
                                local slots = inventoryCache[itemId]
                                local found = false
                                local added = 0
                                for i, slotAmount in ipairs(slots) do
                                    if newAmount == slotAmount then found = true; break
                                    elseif newAmount > slotAmount and (newAmount - slotAmount) <= 10 then added = newAmount - slotAmount; slots[i] = newAmount; found = true; break
                                    elseif newAmount < slotAmount and (slotAmount - newAmount) <= 10 then slots[i] = newAmount; found = true; break end
                                end
                                if not found then
                                    local bestMatch = false
                                    for i, slotAmount in ipairs(slots) do
                                        if newAmount > slotAmount then added = newAmount - slotAmount; slots[i] = newAmount; bestMatch = true; break end
                                    end
                                    if not bestMatch then table.insert(slots, newAmount) end
                                end
                                if added > 0 and added <= 1000 then
                                    pendingResources[resKey] = added
                                    saveInventoryBase()
                                end
                            end
                        end
                    end
                end
            end
        end
        raknetBitStreamSetReadOffset(bs, origPos)
    end
end

function hook.onServerMessage(color, text)
    if not text then return end
    if text:match("^%[%d+%]") or text:match("^.*?:") or text:match("^.*сказал") then return end
	
	   -- Лесопилка: перехват сообщений хранилища (ларцы)
    if currentWork == WORK_TYPES.SAWMILL then
        if text:match("^%[Хранилище предметов%] Добавлен новый предмет") then
            addResource("rare_box", 1)
            return
        end
    end
    
    -- Ферма и Шахта: засчитываем ресурс когда приходит сообщение
    if text:match("^Вам был добавлен предмет") then
        local itemId = text:match(":item(%d+):")
        if itemId then
            local id = tonumber(itemId)
            
            -- Ферма
            if currentWork == WORK_TYPES.FARM then
                local resKey = FARM_ITEM_TO_RES[id]
                if resKey then
                    local amount = pendingResources[resKey] or 1
                    addResource(resKey, amount)
                    pendingResources[resKey] = nil
                end
            end
            
            -- Шахта (подземная/лавка)
            if currentWork == WORK_TYPES.MINE then
                if settings.undermineEnabled or settings.underminelavkaEnabled then
                    -- Проверяем, не покупка ли это (для лавки)
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
                        -- Добыча в подземной шахте
                        local resKey = MINE_ITEM_TO_RES[id]
                        if resKey then
                            local amount = pendingResources[resKey] or 1
                            addResource(resKey, amount)
                            pendingResources[resKey] = nil
                        end
                    end
                end
            end
            
            -- Лесопилка
            if currentWork == WORK_TYPES.SAWMILL then
                local resKey = SAWMILL_ITEM_TO_RES[id]
                if resKey then
                    local amount = pendingResources[resKey] or 1
                    addResource(resKey, amount)
                    pendingResources[resKey] = nil
                end
            end
        end
        return
    end
    
    return
end

function hook.onDisplayGameText(style, tm, text)
    if not text then return end
    if currentWork == WORK_TYPES.FARM then 
        if not settings.farmEnabled then return end
        local resType, amount = text:match("^(%a+) %+(%d+)$")
        if resType and amount then 
            amount = tonumber(amount) or 1
            resType = resType:lower()
            if resType == "linen" then addResource("flax", amount) 
            elseif resType == "cotton" then addResource("cotton", amount) end 
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
                local success, err = pcall(addResource, mapping[resType], amount)
                if not success then sampAddChatMessage("{FF0000}[ResHelherMine] Ошибка при добавлении ресурса: " .. tostring(err), -1) end 
            end
        end
    end
end

function hook.onShowDialog(id, style, title, button1, button2, text)
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
            for line in text:gmatch("[^\r\n]+") do processInventoryLine(line) end
            if text and text:find(">> Следующая страница") then
                scanState.statusText = "Перехожу на следующую страницу..."
                scanState.waitForInventory = true
                sampSendDialogResponse(id, 1)
                return true
            else
                scanState.statusText = "Завершаю сканирование..."
                sampSendDialogResponse(id, 0)
                lua_thread.create(function() wait(500); finishScan() end)
                return true
            end
        end
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
    fa_font = imgui.GetIO().Fonts:AddFontFromFileTTF('moonloader/ResHelper/files/font-icon.ttf', 15.0, font_config, fa_glyph_ranges)
  end
  if fa_font_awesome == nil then
    local faPath = getWorkingDirectory() .. "/ResHelper/files/fontawesome.ttf"
    if doesFileExist(faPath) then
      local font_config = imgui.ImFontConfig()
      font_config.MergeMode = true
      fa_font_awesome = imgui.GetIO().Fonts:AddFontFromFileTTF(faPath, 15.0, font_config, fa_glyph_ranges)
    end
  end
end

function drawSettingsTab()
    imgui.Separator()
    imgui.TextColored(imgui.ImVec4(1.0, 0.8, 0.2, 1), u8("Уведомления:"))
    if imgui.Checkbox(u8("Уведомления о целях в чат"), cb_chatNotify) then 
        settings.chatNotifyEnabled = cb_chatNotify.v
        saveConfig()
        needSave = true 
    end
    imgui.Separator()
    imgui.TextColored(imgui.ImVec4(1.0, 0.8, 0.2, 1), u8("Звуки:"))
    if imgui.Checkbox(u8("Звук при выполнении цели"), cb_goalSound) then 
        settings.goalSoundEnabled = cb_goalSound.v
        saveConfig()
        needSave = true 
    end
    if cb_goalSound.v then 
        imgui.Text(u8("Громкость звука цели:"))
        imgui.PushItemWidth(-1)
        if imgui.SliderInt("##goal_vol", goal_vol_slider, 0, 100) then 
            settings.goalSoundVolume = goal_vol_slider.v
            saveConfig() 
        end
        imgui.PopItemWidth()
    end
    imgui.Spacing()
    if imgui.Checkbox(u8("Звуки при добыче ресурсов"), cb_pickupSound) then 
        settings.pickupSoundEnabled = cb_pickupSound.v
        saveConfig()
        needSave = true 
    end
    if cb_pickupSound.v then 
        imgui.Text(u8("Громкость звуков добычи:"))
        imgui.PushItemWidth(-1)
        if imgui.SliderInt("##pickup_vol", pickup_vol_slider, 0, 100) then 
            settings.pickupSoundVolume = pickup_vol_slider.v
            saveConfig() 
        end
        imgui.PopItemWidth()
    end
    imgui.Separator()
    imgui.TextColored(imgui.ImVec4(1.0, 0.8, 0.2, 1), u8("Оверлеи:"))
    if imgui.Checkbox(u8("Оверлей фермы"), cb_farm_overlay) then 
        settings.farmOverlayEnabled = cb_farm_overlay.v
        saveConfig()
        needSave = true 
    end
    imgui.SameLine()
    ShowHelpMarker(u8("Показывает окно с добычей за сегодня на ферме"))
    if imgui.Checkbox(u8("Оверлей шахты"), cb_mine_overlay) then 
        settings.mineOverlayEnabled = cb_mine_overlay.v
        saveConfig()
        needSave = true 
    end
    imgui.SameLine()
    ShowHelpMarker(u8("Показывает окно с добычей за сегодня в шахте"))
    if imgui.Checkbox(u8("Оверлей лесопилки"), cb_sawmill_overlay) then 
        settings.sawmillOverlayEnabled = cb_sawmill_overlay.v
        saveConfig()
        needSave = true 
    end
    imgui.SameLine()
    ShowHelpMarker(u8("Показывает окно с добычей за сегодня на лесопилке"))
    imgui.Spacing()
    imgui.Separator()
    imgui.TextColored(imgui.ImVec4(1.0, 0.8, 0.2, 1), u8("Таймер:"))
    if imgui.Checkbox(u8("Таймер в оверлее"), cb_overlay_timer) then 
        settings.overlayTimerEnabled = cb_overlay_timer.v
        if not cb_overlay_timer.v then 
            overlayTimer.running = false
            overlayTimer.elapsed = 0
            overlayTimer.displayedTime = "00:00:00"
        end
        saveConfig()
        needSave = true 
    end
    imgui.SameLine()
    ShowHelpMarker(u8("Показывает таймер времени работы в оверлее"))
    
    if settings.overlayTimerEnabled then
        imgui.Spacing()
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
    imgui.Separator()
    imgui.PushStyleColor(imgui.Col.Button, needSaveColor)
    if imgui.Button(u8("Сохранить все настройки"), imgui.ImVec2(-1, 30)) then
        saveConfig()
        savePrices()
        saveOverlayConfig()
        saveGoals()
        saveStats()
        sampAddChatMessage(SCRIPT_PREFIX.."Настройки сохранены!", SCRIPT_COLOR)
        needSave = false
    end
    imgui.PopStyleColor(1)
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
    
    local fpf = io.open(farmGoalsProgressPath, "r")
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
    if imgui.Button(u8("Сохранить цели"), imgui.ImVec2(btnWidth, 25)) then
        local saveData = {}
        for _, k in ipairs(farmOrder) do
            saveData[k] = farmGoalEditCache[k].v
        end
        local f = io.open(farmGoalsConfigPath, "w")
        if f then f:write(encodeJson(saveData)); f:close() end
        sampAddChatMessage(SCRIPT_PREFIX.."Цели фермы сохранены!", SCRIPT_COLOR)
    end
    imgui.SameLine()
    if imgui.Button(u8("Сбросить прогресс"), imgui.ImVec2(btnWidth, 25)) then
        local saveData = {}
        for _, k in ipairs(farmOrder) do
            saveData[k] = {reached = false, amount = 0}
        end
        saveData.dailyTotal = 0
        local f = io.open(farmGoalsProgressPath, "w")
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
    
    local mpf = io.open(mineGoalsProgressPath, "r")
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
    if imgui.Button(u8("Сохранить цели"), imgui.ImVec2(btnWidth, 25)) then
        local saveData = {}
        for _, k in ipairs(mineOrder) do
            saveData[k] = mineGoalEditCache[k].v
        end
        local f = io.open(mineGoalsConfigPath, "w")
        if f then f:write(encodeJson(saveData)); f:close() end
        sampAddChatMessage(SCRIPT_PREFIX.."Цели шахты сохранены!", SCRIPT_COLOR)
    end
    imgui.SameLine()
    if imgui.Button(u8("Сбросить прогресс"), imgui.ImVec2(btnWidth, 25)) then
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
    
    local spf = io.open(sawmillGoalsProgressPath, "r")
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
    if imgui.Button(u8("Сохранить цели"), imgui.ImVec2(btnWidth, 25)) then
        local saveData = {}
        for _, k in ipairs(sawOrder) do
            saveData[k] = sawmillGoalEditCache[k].v
        end
        local f = io.open(sawmillGoalsConfigPath, "w")
        if f then f:write(encodeJson(saveData)); f:close() end
        sampAddChatMessage(SCRIPT_PREFIX.."Цели лесопилки сохранены!", SCRIPT_COLOR)
    end
    imgui.SameLine()
    if imgui.Button(u8("Сбросить прогресс"), imgui.ImVec2(btnWidth, 25)) then
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

function imgui.OnDrawFrame()
    if not mainWin.v and not settings.farmOverlayEnabled and not settings.mineOverlayEnabled and not settings.sawmillOverlayEnabled then return end
    
    -- Оверлеи (без изменений)
    if settings.farmOverlayEnabled then
        local cfg = overlayConfigs[WORK_TYPES.FARM]
        imgui.SetNextWindowPos(imgui.ImVec2(cfg.x, cfg.y), imgui.Cond.FirstUseEver)
        imgui.SetNextWindowSize(imgui.ImVec2(cfg.w, cfg.h), imgui.Cond.FirstUseEver)
        imgui.Begin(u8("Добыча за сегодня (Ферма)"), true, imgui.WindowFlags.NoScrollbar)
        if currentWork == WORK_TYPES.FARM then
            local todayData = getTodayStats()
            local todayTotal = todayData.total
            for _, k in ipairs(config.resourceOrder) do 
                imgui.Text(u8(config.resourceNames[k] .. ": ")); imgui.SameLine(); 
                imgui.TextColored(imgui.ImVec4(1.0, 0.8, 0.2, 1), formatNumber(todayData[k] or 0)) 
            end
            imgui.Separator()
            imgui.Text(u8("Доход: ")); imgui.SameLine(); 
            imgui.TextColored(imgui.ImVec4(0.3, 1.0, 0.3, 1), formatNumber(todayTotal) .. "$")
            if settings.overlayTimerEnabled then
                imgui.Separator()
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
    end
    
    if settings.mineOverlayEnabled then
        local cfg = overlayConfigs[WORK_TYPES.MINE]
        imgui.SetNextWindowPos(imgui.ImVec2(cfg.x, cfg.y), imgui.Cond.FirstUseEver)
        imgui.SetNextWindowSize(imgui.ImVec2(cfg.w, cfg.h), imgui.Cond.FirstUseEver)
        imgui.Begin(u8("Добыча за сегодня (Шахта)"), true, imgui.WindowFlags.NoScrollbar)
        if currentWork == WORK_TYPES.MINE then
            local todayData = getTodayStats()
            local todayTotal = todayData.total
            imgui.Columns(2, "overlay_mine_cols", false)
            imgui.SetColumnWidth(0, imgui.GetWindowWidth() * 0.5)
            for _, k in ipairs(config.leftColumnOrder) do 
                imgui.Text(u8(config.resourceNames[k] .. ": ")); imgui.SameLine(); 
                imgui.TextColored(imgui.ImVec4(1.0, 0.8, 0.2, 1), formatNumber(todayData[k] or 0)); imgui.NextColumn() 
            end
            imgui.SetColumnWidth(1, imgui.GetWindowWidth() * 0.5)
            for _, k in ipairs(config.rightColumnOrder) do 
                imgui.Text(u8(config.resourceNames[k] .. ": ")); imgui.SameLine(); 
                imgui.TextColored(imgui.ImVec4(1.0, 0.8, 0.2, 1), formatNumber(todayData[k] or 0)); imgui.NextColumn() 
            end
            imgui.Columns(1)
            imgui.Separator()
            imgui.Text(u8("Доход: ")); imgui.SameLine(); 
            imgui.TextColored(imgui.ImVec4(0.3, 1.0, 0.3, 1), formatNumber(todayTotal) .. "$")
            if settings.overlayTimerEnabled then
                imgui.Separator()
                imgui.Text(u8("Время работы: ")); imgui.SameLine(); 
                if overlayTimer.running then
                    imgui.TextColored(imgui.ImVec4(0.3, 1.0, 1.0, 1), overlayTimer.displayedTime)
                else
                    imgui.TextColored(imgui.ImVec4(0.6, 0.6, 0.6, 1), u8("00:00:00"))
                end
            end
        else 
            imgui.TextColored(imgui.ImVec4(0.6, 0.6, 0.6, 1), u8("Переключитесь на шахту")) 
        end
        local pos, size = imgui.GetWindowPos(), imgui.GetWindowSize()
        if pos and pos.x > 0 and pos.y > 0 and (cfg.x ~= pos.x or cfg.y ~= pos.y or cfg.w ~= size.x or cfg.h ~= size.y) then 
            cfg.x, cfg.y, cfg.w, cfg.h = pos.x, pos.y, size.x, size.y; saveOverlayConfig()
        end
        imgui.End()
    end
	
    if settings.sawmillOverlayEnabled then
        local cfg = overlayConfigs[WORK_TYPES.SAWMILL]
        imgui.SetNextWindowPos(imgui.ImVec2(cfg.x, cfg.y), imgui.Cond.FirstUseEver)
        imgui.SetNextWindowSize(imgui.ImVec2(cfg.w, cfg.h), imgui.Cond.FirstUseEver)
        imgui.Begin(u8("Добыча за сегодня (Лесопилка)"), true, imgui.WindowFlags.NoScrollbar)
        if currentWork == WORK_TYPES.SAWMILL then
            local todayData = getTodayStats()
            local todayTotal = todayData.total
            for _, k in ipairs(config.resourceOrder) do 
                imgui.Text(u8(config.resourceNames[k] .. ": ")); imgui.SameLine(); 
                imgui.TextColored(imgui.ImVec4(1.0, 0.8, 0.2, 1), formatNumber(todayData[k] or 0)) 
            end
            if settings.overlayTimerEnabled then
                imgui.Separator()
                imgui.Text(u8("Время работы: ")); imgui.SameLine(); 
                if overlayTimer.running then
                    imgui.TextColored(imgui.ImVec4(0.3, 1.0, 1.0, 1), overlayTimer.displayedTime)
                else
                    imgui.TextColored(imgui.ImVec4(0.6, 0.6, 0.6, 1), u8("00:00:00"))
                end
            end
            imgui.Separator()
            imgui.Text(u8("Доход: ")); imgui.SameLine(); 
            imgui.TextColored(imgui.ImVec4(0.3, 1.0, 0.3, 1), formatNumber(todayTotal) .. "$")
        else 
            imgui.TextColored(imgui.ImVec4(0.6, 0.6, 0.6, 1), u8("Переключитесь на лесопилку")) 
        end
        local pos, size = imgui.GetWindowPos(), imgui.GetWindowSize()
        if pos and pos.x > 0 and pos.y > 0 and (cfg.x ~= pos.x or cfg.y ~= pos.y or cfg.w ~= size.x or cfg.h ~= size.y) then 
            cfg.x, cfg.y, cfg.w, cfg.h = pos.x, pos.y, size.x, size.y; saveOverlayConfig()
        end
        imgui.End()
    end
    
    -- Главное меню в новом стиле
    if mainWin.v then
        local sw, sh = getScreenResolution()
        imgui.SetNextWindowSize(imgui.ImVec2(955, 550), imgui.Cond.Always)
        imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.Always, imgui.ImVec2(0.5, 0.5))
        
    -- Убираем все рамки и отступы
        imgui.PushStyleVar(imgui.StyleVar.WindowPadding, imgui.ImVec2(4, 4))
        imgui.PushStyleColor(imgui.Col.Border, imgui.ImVec4(0, 0, 0, 0))
        imgui.PushStyleColor(imgui.Col.WindowBg, imgui.ImVec4(0, 0, 0, 0))
        
        local title = u8("Resource Helper v" .. scr.version)
        if newversion ~= scr.version then
            title = title .. u8(" (обновление!)")
        end
        
        imgui.Begin(title, mainWin, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoBringToFrontOnFocus)
        
        -- Ченжлог попап 
        if not changelogShown then
            if changelogData then
                imgui.SetNextWindowSizeConstraints(imgui.ImVec2(500, 200), imgui.ImVec2(600, 600))
                imgui.OpenPopup(u8("Что нового?##changelog"))
            else
                downloadChangelog()
            end
        end
        if imgui.BeginPopupModal(u8("Что нового?##changelog"), nil, imgui.WindowFlags.AlwaysAutoResize) then
            local winWidth = imgui.GetWindowWidth()
            local headerText = u8("Обновление до версии " .. scr.version)
            local headerWidth = imgui.CalcTextSize(headerText).x
            imgui.SetCursorPosX((winWidth - headerWidth) / 2)
            imgui.Text(headerText)
            imgui.Separator()
            imgui.Spacing()
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
        
                -- Фон всего окна
        drawList:AddRectFilled(winPos, imgui.ImVec2(winPos.x + winSize.x, winPos.y + winSize.y), 0xFF141414, 6)
        
        -- Левая панель 
        local leftPanelWidth = 190
        drawList:AddRectFilled(
            imgui.ImVec2(winPos.x, winPos.y),
            imgui.ImVec2(winPos.x + leftPanelWidth, winPos.y + winSize.y),
            0xFF0E0E0E, 6, 9
        )
        -- Тонкая линия-разделитель между панелями 
        drawList:AddLine(
            imgui.ImVec2(winPos.x + leftPanelWidth, winPos.y),
            imgui.ImVec2(winPos.x + leftPanelWidth, winPos.y + winSize.y),
            0xFF2A2A2A, 1.0
        )
        
        -- Верхняя панель - левая часть 
        drawList:AddRectFilled(
            imgui.ImVec2(winPos.x + 6, winPos.y),
            imgui.ImVec2(winPos.x + leftPanelWidth, winPos.y + 45),
            0xFF0E0E0E, 0, 0
        )
        -- Верхняя панель - правая часть
        drawList:AddRectFilled(
            imgui.ImVec2(winPos.x + leftPanelWidth, winPos.y),
            imgui.ImVec2(winPos.x + winSize.x - 6, winPos.y + 45),
            0xFF141414, 0, 6
        )
		
		        
        -- Разделитель в заголовке между левой и правой частью
        drawList:AddLine(
            imgui.ImVec2(winPos.x + leftPanelWidth, winPos.y + 8),
            imgui.ImVec2(winPos.x + leftPanelWidth, winPos.y + 37),
            0xFF2A2A2A, 1.0
        )
        
        -- Кнопка закрытия
        local closeX = winPos.x + winSize.x - 35
        local closeY = winPos.y + 10
        local closeHovered = (imgui.GetMousePos().x >= closeX and imgui.GetMousePos().x <= closeX + 25 and 
                             imgui.GetMousePos().y >= closeY and imgui.GetMousePos().y <= closeY + 25)
        drawList:AddRectFilled(imgui.ImVec2(closeX, closeY), imgui.ImVec2(closeX + 25, closeY + 25), 
            closeHovered and 0xFF333333 or 0xFF222222, 4)
        drawList:AddText(imgui.ImVec2(closeX + 7, closeY + 5), 0xFFFFFFFF, fa.ICON_TIMES)
        if closeHovered and imgui.IsMouseReleased(0) then
            mainWin.v = false
            imgui.ShowCursor = false
        end
        
        -- Кнопка перезагрузки
        local reloadX = winPos.x + winSize.x - 70
        local reloadHovered = (imgui.GetMousePos().x >= reloadX and imgui.GetMousePos().x <= reloadX + 25 and 
                              imgui.GetMousePos().y >= closeY and imgui.GetMousePos().y <= closeY + 25)
        drawList:AddRectFilled(imgui.ImVec2(reloadX, closeY), imgui.ImVec2(reloadX + 25, closeY + 25), 
            reloadHovered and 0xFF333333 or 0xFF222222, 4)
        drawList:AddText(imgui.ImVec2(reloadX + 7, closeY + 5), 0xFFFFFFFF, fa.ICON_REPEAT)
                if reloadHovered and imgui.IsMouseClicked(0) then 
            consumeWindowMessage(true, false)
            showCursor(false); scr:reload() 
        end
        
        -- Иконка в левом верхнем углу
        imgui.SetCursorPos(imgui.ImVec2(15, 15))
        imgui.TextColored(imgui.ImVec4(0.26, 0.98, 0.26, 1.0), fa.ICON_WRENCH .. "  Resource Helper")
        imgui.SetCursorPos(imgui.ImVec2(10, 40))
        imgui.Separator()
        imgui.Spacing()
        
        -- Кнопки навигации
local menuItems = {
    {title = u8("Главная"), icon = fa.ICON_HOME, id = 1},
    {title = u8("Ферма"), icon = fa.ICON_LEAF, id = 2},
    {title = u8("Шахта"), icon = fa.ICON_CUBE, id = 3},
    {title = u8("Лесопилка"), icon = fa.ICON_TREE, id = 4},
    {title = u8("Цели"), icon = fa.ICON_BULLSEYE, id = 5},
    {title = u8("Биндер"), icon = fa.ICON_KEYBOARD_O, id = 6},
    {title = u8("Настройки"), icon = fa.ICON_WRENCH, id = 7},
    {title = u8("О скрипте"), icon = fa.ICON_SEARCH, id = 8},
}

local currentMenuId = 1
for i = 1, #menuItems do
    if select_menu[i] then currentMenuId = i; break end
end

-- Название текущего раздела в верхней панели
imgui.SetCursorPos(imgui.ImVec2(leftPanelWidth + 20, 12))
imgui.TextColored(imgui.ImVec4(0.26, 0.98, 0.26, 1.0), menuItems[currentMenuId].icon .. "  " .. menuItems[currentMenuId].title)

-- Расчёт равномерного распределения кнопок
local topAreaEnd = winPos.y + 45 
local bottomAreaStart = winPos.y + winSize.y - 25  
local availableHeight = bottomAreaStart - topAreaEnd 
local btnHeight = 38  
local totalBtnsHeight = btnHeight * #menuItems  
local totalSpacing = availableHeight - totalBtnsHeight  
local spacing = totalSpacing / (#menuItems + 1)  

for idx, item in ipairs(menuItems) do
    local isActive = (idx == currentMenuId)
    local btnPosX = winPos.x + 7
    local btnPosY = topAreaEnd + spacing + (idx - 1) * (btnHeight + spacing)  
    local btnHovered = (imgui.GetMousePos().x >= btnPosX and imgui.GetMousePos().x <= btnPosX + 178 and 
                       imgui.GetMousePos().y >= btnPosY and imgui.GetMousePos().y <= btnPosY + btnHeight)
    
    -- Фон кнопки
    local btnColor = 0x00000000
    if isActive then
        btnColor = 0xFF1E3D1E
    elseif btnHovered then
        btnColor = 0xFF2A2A2A
    end
    
    if btnColor ~= 0x00000000 then
        drawList:AddRectFilled(imgui.ImVec2(btnPosX, btnPosY), imgui.ImVec2(btnPosX + 178, btnPosY + btnHeight), btnColor, 5)
    end
    
    -- Тонкая обводка для всех кнопок
    local borderColor = 0xFF333333
    if isActive then
        borderColor = 0xFF1AE591
    elseif btnHovered then
        borderColor = 0xFF555555
    end
    drawList:AddRect(imgui.ImVec2(btnPosX, btnPosY), imgui.ImVec2(btnPosX + 178, btnPosY + btnHeight), borderColor, 5, 15, 1.5)
    
    -- Иконка и текст
    local textCol = isActive and 0xFF1AE591 or (btnHovered and 0xFFFFFFFF or 0xFF999999)
    drawList:AddText(imgui.ImVec2(btnPosX + 12, btnPosY + 9), textCol, item.icon)
    drawList:AddText(imgui.ImVec2(btnPosX + 45, btnPosY + 9), textCol, item.title)
    
    -- Обработка клика
    if btnHovered and imgui.IsMouseClicked(0) then
        if autoScanningInProgress and idx >= 2 and idx <= 4 then
            -- Блокируем
        else
            select_menu = {false, false, false, false, false, false, false, false}
            select_menu[idx] = true
            if idx == 2 and currentWork ~= WORK_TYPES.FARM then switchWorkType(WORK_TYPES.FARM)
            elseif idx == 3 and currentWork ~= WORK_TYPES.MINE then switchWorkType(WORK_TYPES.MINE)
            elseif idx == 4 and currentWork ~= WORK_TYPES.SAWMILL then switchWorkType(WORK_TYPES.SAWMILL)
            end
        end
    end
end
        
        -- Версия внизу левой панели
        drawList:AddText(imgui.ImVec2(winPos.x + 15, winPos.y + winSize.y - 25), 0xFF555555, "v" .. scr.version)
        
        -- Правая панель 
        imgui.SetCursorPos(imgui.ImVec2(leftPanelWidth + 15, 55))
        imgui.BeginChild("right_panel", imgui.ImVec2(winSize.x - leftPanelWidth - 30, winSize.y - 65), false)
        
        imgui.Spacing()
        
        -- Содержимое разделов
                if select_menu[1] then
            -- Логотип 
            if logoArz then
                imgui.SetCursorPosX((imgui.GetWindowWidth() - 750) / 2)
                imgui.Image(logoArz, imgui.ImVec2(750, 224))
            end
            imgui.Spacing()
            imgui.Separator()
            imgui.Spacing()
            imgui.TextColored(imgui.ImVec4(1.0, 0.8, 0.2, 1), u8("Добро пожаловать в Resource Helper!"))
            imgui.Spacing()
            imgui.TextWrapped(u8("Этот скрипт поможет вам отслеживать добычу ресурсов на ферме, шахте и лесопилке на проекте Arizona RP."))
            imgui.Spacing()
            imgui.Separator()
            imgui.Spacing()
            imgui.TextColored(imgui.ImVec4(0.26, 0.98, 0.26, 1.0), u8("Возможности:"))
            imgui.BulletText(u8("Отслеживание добычи ресурсов в реальном времени"))
            imgui.BulletText(u8("Подсчет заработка за сессию"))
            imgui.BulletText(u8("Статистика за сегодня/неделю/все время"))
            imgui.BulletText(u8("Настройка целей и отслеживание прогресса"))
            imgui.BulletText(u8("Звуковые уведомления о редких ресурсах"))
            imgui.BulletText(u8("Оверлеи с информацией о добыче"))
            imgui.BulletText(u8("Биндер клавиш"))
            imgui.Spacing()
            imgui.Separator()
            imgui.Spacing()
            imgui.TextColored(imgui.ImVec4(0.26, 0.98, 0.26, 1.0), u8("Текущий режим: " .. config.name))
            
        elseif select_menu[2] then
            local scanBtnText
            if scanState.active then scanBtnText = u8("Сканирование...")
            elseif scanState.scanned or autoScanned then scanBtnText = u8("Пересканировать инвентарь")
            else scanBtnText = u8("Сканировать инвентарь") end
            if imgui.Button(scanBtnText, imgui.ImVec2(-1, 25)) then
                if not scanState.active then startInventoryScan() end
            end
            if scanState.active then imgui.TextColored(imgui.ImVec4(1.0, 0.8, 0.2, 1), u8("Статус: " .. scanState.statusText))
            elseif autoScanned then imgui.TextColored(imgui.ImVec4(0.3, 1.0, 0.3, 1), u8("Автосканирование выполнено"))
            elseif scanState.scanned then imgui.TextColored(imgui.ImVec4(0.3, 1.0, 0.3, 1), u8("Инвентарь отсканирован"))
            else imgui.TextColored(imgui.ImVec4(1.0, 0.5, 0.2, 1), u8("Инвентарь не отсканирован!")) end
            imgui.Separator()
            if imgui.Checkbox(u8("Считать ресурсы с фермы"), cb_farm) then settings.farmEnabled = cb_farm.v; saveConfig(); needSave = true end
            imgui.Separator()
            if imgui.CollapsingHeader(u8("Цены за единицу")) then
                for _, k in ipairs(config.resourceOrder) do 
                    imgui.PushItemWidth(200); imgui.Text(u8(config.resourceNames[k] .. ":"))
                    if imgui.InputInt("##price_farm_" .. k, priceEdit[k], 1000, 10000) then end
                    imgui.PopItemWidth()
                end
                if imgui.Button(u8("Сохранить цены"), imgui.ImVec2(-1, 25)) then
                    for k, v in pairs(priceEdit) do resourcePrices[k] = v.v end
                    savePrices(); sampAddChatMessage(SCRIPT_PREFIX.."Цены обновлены!", SCRIPT_COLOR)
                end
            end
            imgui.Separator()
            if imgui.CollapsingHeader(u8("Статистика")) then
                local btnWidth = imgui.GetWindowWidth() / 3 - 10
                if imgui.Button(u8("Сегодня"), imgui.ImVec2(btnWidth, 25)) then farmStatsTab.v = 0 end
                imgui.SameLine()
                if imgui.Button(u8("Неделя"), imgui.ImVec2(btnWidth, 25)) then farmStatsTab.v = 1 end
                imgui.SameLine()
                if imgui.Button(u8("Все время"), imgui.ImVec2(btnWidth, 25)) then farmStatsTab.v = 2 end
                imgui.Separator()
                if farmStatsTab.v == 0 then
                    local todayData = getTodayStats()
                    for _, k in ipairs(config.resourceOrder) do 
                        imgui.Text(u8(config.resourceNames[k] .. ": ")); imgui.SameLine(); 
                        imgui.TextColored(imgui.ImVec4(1.0, 0.8, 0.2, 1), formatNumber(todayData[k] or 0)) 
                    end
                    local todayTotal = 0
                    for _, k in ipairs(config.resourceOrder) do
                        local price = resourcePrices[k] or config.defaultPrices[k] or 0
                        todayTotal = todayTotal + ((todayData[k] or 0) * price)
                    end
                    imgui.Text(u8("Доход за сегодня: ")); imgui.SameLine(); 
                    imgui.TextColored(imgui.ImVec4(0.3, 1.0, 0.3, 1), formatNumber(todayTotal) .. "$")
                elseif farmStatsTab.v == 1 then
                    local weekData = getWeekStats()
                    for _, k in ipairs(config.resourceOrder) do 
                        imgui.Text(u8(config.resourceNames[k] .. ": ")); imgui.SameLine(); 
                        imgui.TextColored(imgui.ImVec4(1.0, 0.8, 0.2, 1), formatNumber(weekData[k] or 0)) 
                    end
                    imgui.Text(u8("Доход за неделю: ")); imgui.SameLine(); 
                    imgui.TextColored(imgui.ImVec4(0.3, 1.0, 0.3, 1), formatNumber(weekData.total or 0) .. "$")
                elseif farmStatsTab.v == 2 then
                    local availableDates = getAvailableDates()
                    if #availableDates > 0 then
                        local comboStr = ""
                        for i, v in ipairs(availableDates) do 
                            if i > 1 then comboStr = comboStr .. "\0" end
                            comboStr = comboStr .. v 
                        end
                        comboStr = comboStr .. "\0"
                        imgui.Text(u8("Выберите дату:")); imgui.PushItemWidth(-1)
                        if imgui.Combo(u8("##date_select_farm"), selectedDateIndexFarm, comboStr) then end
                        imgui.PopItemWidth(); imgui.Separator()
                        local idx = selectedDateIndexFarm.v + 1
                        if idx <= #availableDates then
                            local selectedDate = availableDates[idx]
                            local dayData = getDayStats(selectedDate)
                            for _, k in ipairs(config.resourceOrder) do 
                                imgui.Text(u8(config.resourceNames[k] .. ": ")); imgui.SameLine(); 
                                imgui.TextColored(imgui.ImVec4(1.0, 0.8, 0.2, 1), formatNumber(dayData[k] or 0)) 
                            end
                            imgui.Text(u8("Доход: ")); imgui.SameLine(); 
                            imgui.TextColored(imgui.ImVec4(0.3, 1.0, 0.3, 1), formatNumber(dayData.total or 0) .. "$")
                        end
                    else imgui.TextColored(imgui.ImVec4(0.8, 0.3, 0.3, 1), u8("Нет данных")) end
                end
            end
            
        elseif select_menu[3] then
            local scanBtnText
            if scanState.active then scanBtnText = u8("Сканирование...")
            elseif scanState.scanned or autoScanned then scanBtnText = u8("Пересканировать инвентарь")
            else scanBtnText = u8("Сканировать инвентарь") end
            if imgui.Button(scanBtnText, imgui.ImVec2(-1, 25)) then
                if not scanState.active then startInventoryScan() end
            end
            if scanState.active then imgui.TextColored(imgui.ImVec4(1.0, 0.8, 0.2, 1), u8("Статус: " .. scanState.statusText))
            elseif autoScanned then imgui.TextColored(imgui.ImVec4(0.3, 1.0, 0.3, 1), u8("Автосканирование выполнено"))
            elseif scanState.scanned then imgui.TextColored(imgui.ImVec4(0.3, 1.0, 0.3, 1), u8("Инвентарь отсканирован"))
            else imgui.TextColored(imgui.ImVec4(1.0, 0.5, 0.2, 1), u8("Инвентарь не отсканирован!")) end
            imgui.Separator()
            imgui.TextColored(imgui.ImVec4(0.3, 0.8, 0.3, 1), u8("Режимы счета:"))
            if imgui.Checkbox(u8("Подземная шахта"), cb_undermine) then 
                settings.undermineEnabled = cb_undermine.v
                if cb_undermine.v then cb_regular.v = false; settings.regularmineEnabled = false end
                saveConfig(); needSave = true 
            end
            if imgui.Checkbox(u8("Лавка (вычитает ресурсы)"), cb_lavka) then 
                settings.underminelavkaEnabled = cb_lavka.v
                if cb_lavka.v then cb_undermine.v = true; settings.undermineEnabled = true end
                saveConfig(); needSave = true 
            end
            if imgui.Checkbox(u8("Обычная шахта"), cb_regular) then 
                settings.regularmineEnabled = cb_regular.v
                if cb_regular.v then cb_undermine.v = false; settings.undermineEnabled = false end
                saveConfig(); needSave = true 
            end
            imgui.Separator()
            if imgui.CollapsingHeader(u8("Цены за единицу")) then
                for _, k in ipairs(config.resourceOrder) do 
                    imgui.PushItemWidth(200); imgui.Text(u8(config.resourceNames[k] .. ":"))
                    if imgui.InputInt("##price_mine_" .. k, priceEdit[k], 1000, 10000) then end
                    imgui.PopItemWidth()
                end
                if imgui.Button(u8("Сохранить цены"), imgui.ImVec2(-1, 25)) then
                    for k, v in pairs(priceEdit) do resourcePrices[k] = v.v end
                    savePrices(); sampAddChatMessage(SCRIPT_PREFIX.."Цены обновлены!", SCRIPT_COLOR)
                end
            end
            imgui.Separator()
            if imgui.CollapsingHeader(u8("Статистика")) then
                local btnWidth = imgui.GetWindowWidth() / 3 - 10
                if imgui.Button(u8("Сегодня"), imgui.ImVec2(btnWidth, 25)) then mineStatsTab.v = 0 end
                imgui.SameLine()
                if imgui.Button(u8("Неделя"), imgui.ImVec2(btnWidth, 25)) then mineStatsTab.v = 1 end
                imgui.SameLine()
                if imgui.Button(u8("Все время"), imgui.ImVec2(btnWidth, 25)) then mineStatsTab.v = 2 end
                imgui.Separator()
                if mineStatsTab.v == 0 then
                    local todayData = getTodayStats()
                    imgui.Columns(2, "mine_today_cols", false)
                    for _, k in ipairs(config.leftColumnOrder) do 
                        imgui.Text(u8(config.resourceNames[k] .. ": ")); imgui.SameLine(); 
                        imgui.TextColored(imgui.ImVec4(1.0, 0.8, 0.2, 1), formatNumber(todayData[k] or 0)); imgui.NextColumn()
                    end
                    for _, k in ipairs(config.rightColumnOrder) do 
                        imgui.Text(u8(config.resourceNames[k] .. ": ")); imgui.SameLine(); 
                        imgui.TextColored(imgui.ImVec4(1.0, 0.8, 0.2, 1), formatNumber(todayData[k] or 0)); imgui.NextColumn()
                    end
                    imgui.Columns(1)
                    local todayTotal = 0
                    for _, k in ipairs(config.resourceOrder) do
                        local price = resourcePrices[k] or config.defaultPrices[k] or 0
                        todayTotal = todayTotal + ((todayData[k] or 0) * price)
                    end
                    imgui.Text(u8("Доход за сегодня: ")); imgui.SameLine(); 
                    imgui.TextColored(imgui.ImVec4(0.3, 1.0, 0.3, 1), formatNumber(todayTotal) .. "$")
                elseif mineStatsTab.v == 1 then
                    local weekData = getWeekStats()
                    imgui.Columns(2, "mine_week_cols", false)
                    for _, k in ipairs(config.leftColumnOrder) do 
                        imgui.Text(u8(config.resourceNames[k] .. ": ")); imgui.SameLine(); 
                        imgui.TextColored(imgui.ImVec4(1.0, 0.8, 0.2, 1), formatNumber(weekData[k] or 0)); imgui.NextColumn()
                    end
                    for _, k in ipairs(config.rightColumnOrder) do 
                        imgui.Text(u8(config.resourceNames[k] .. ": ")); imgui.SameLine(); 
                        imgui.TextColored(imgui.ImVec4(1.0, 0.8, 0.2, 1), formatNumber(weekData[k] or 0)); imgui.NextColumn()
                    end
                    imgui.Columns(1)
                    imgui.Text(u8("Доход за неделю: ")); imgui.SameLine(); 
                    imgui.TextColored(imgui.ImVec4(0.3, 1.0, 0.3, 1), formatNumber(weekData.total or 0) .. "$")
                elseif mineStatsTab.v == 2 then
                    local availableDates = getAvailableDates()
                    if #availableDates > 0 then
                        local comboStr = ""
                        for i, v in ipairs(availableDates) do 
                            if i > 1 then comboStr = comboStr .. "\0" end
                            comboStr = comboStr .. v 
                        end
                        comboStr = comboStr .. "\0"
                        imgui.Text(u8("Выберите дату:")); imgui.PushItemWidth(-1)
                        if imgui.Combo(u8("##date_select_mine"), selectedDateIndexMine, comboStr) then end
                        imgui.PopItemWidth(); imgui.Separator()
                        local idx = selectedDateIndexMine.v + 1
                        if idx <= #availableDates then
                            local selectedDate = availableDates[idx]
                            local dayData = getDayStats(selectedDate)
                            imgui.Columns(2, "mine_date_cols", false)
                            for _, k in ipairs(config.leftColumnOrder) do 
                                imgui.Text(u8(config.resourceNames[k] .. ": ")); imgui.SameLine(); 
                                imgui.TextColored(imgui.ImVec4(1.0, 0.8, 0.2, 1), formatNumber(dayData[k] or 0)); imgui.NextColumn()
                            end
                            for _, k in ipairs(config.rightColumnOrder) do 
                                imgui.Text(u8(config.resourceNames[k] .. ": ")); imgui.SameLine(); 
                                imgui.TextColored(imgui.ImVec4(1.0, 0.8, 0.2, 1), formatNumber(dayData[k] or 0)); imgui.NextColumn()
                            end
                            imgui.Columns(1)
                            imgui.Text(u8("Доход: ")); imgui.SameLine(); 
                            imgui.TextColored(imgui.ImVec4(0.3, 1.0, 0.3, 1), formatNumber(dayData.total or 0) .. "$")
                        end
                    else imgui.TextColored(imgui.ImVec4(0.8, 0.3, 0.3, 1), u8("Нет данных")) end
                end
            end
            
        elseif select_menu[4] then
            local scanBtnText
            if scanState.active then scanBtnText = u8("Сканирование...")
            elseif scanState.scanned or autoScanned then scanBtnText = u8("Пересканировать инвентарь")
            else scanBtnText = u8("Сканировать инвентарь") end
            if imgui.Button(scanBtnText, imgui.ImVec2(-1, 25)) then
                if not scanState.active then startInventoryScan() end
            end
            if scanState.active then imgui.TextColored(imgui.ImVec4(1.0, 0.8, 0.2, 1), u8("Статус: " .. scanState.statusText))
            elseif autoScanned then imgui.TextColored(imgui.ImVec4(0.3, 1.0, 0.3, 1), u8("Автосканирование выполнено"))
            elseif scanState.scanned then imgui.TextColored(imgui.ImVec4(0.3, 1.0, 0.3, 1), u8("Инвентарь отсканирован"))
            else imgui.TextColored(imgui.ImVec4(1.0, 0.5, 0.2, 1), u8("Инвентарь не отсканирован!")) end
            imgui.Separator()
            if imgui.CollapsingHeader(u8("Цены за единицу")) then
                for _, k in ipairs(config.resourceOrder) do 
                    imgui.PushItemWidth(200); imgui.Text(u8(config.resourceNames[k] .. ":"))
                    if imgui.InputInt("##price_saw_" .. k, priceEdit[k], 1000, 10000) then end
                    imgui.PopItemWidth()
                end
                if imgui.Button(u8("Сохранить цены"), imgui.ImVec2(-1, 25)) then
                    for k, v in pairs(priceEdit) do resourcePrices[k] = v.v end
                    savePrices(); sampAddChatMessage(SCRIPT_PREFIX.."Цены обновлены!", SCRIPT_COLOR)
                end
            end
            imgui.Separator()
            if imgui.CollapsingHeader(u8("Статистика")) then
                local btnWidth = imgui.GetWindowWidth() / 3 - 10
                if imgui.Button(u8("Сегодня"), imgui.ImVec2(btnWidth, 25)) then farmStatsTab.v = 0 end
                imgui.SameLine()
                if imgui.Button(u8("Неделя"), imgui.ImVec2(btnWidth, 25)) then farmStatsTab.v = 1 end
                imgui.SameLine()
                if imgui.Button(u8("Все время"), imgui.ImVec2(btnWidth, 25)) then farmStatsTab.v = 2 end
                imgui.Separator()
                if farmStatsTab.v == 0 then
                    local todayData = getTodayStats()
                    for _, k in ipairs(config.resourceOrder) do 
                        imgui.Text(u8(config.resourceNames[k] .. ": ")); imgui.SameLine(); 
                        imgui.TextColored(imgui.ImVec4(1.0, 0.8, 0.2, 1), formatNumber(todayData[k] or 0)) 
                    end
                    local todayTotal = 0
                    for _, k in ipairs(config.resourceOrder) do
                        local price = resourcePrices[k] or config.defaultPrices[k] or 0
                        todayTotal = todayTotal + ((todayData[k] or 0) * price)
                    end
                    imgui.Text(u8("Доход за сегодня: ")); imgui.SameLine(); 
                    imgui.TextColored(imgui.ImVec4(0.3, 1.0, 0.3, 1), formatNumber(todayTotal) .. "$")
                elseif farmStatsTab.v == 1 then
                    local weekData = getWeekStats()
                    for _, k in ipairs(config.resourceOrder) do 
                        imgui.Text(u8(config.resourceNames[k] .. ": ")); imgui.SameLine(); 
                        imgui.TextColored(imgui.ImVec4(1.0, 0.8, 0.2, 1), formatNumber(weekData[k] or 0)) 
                    end
                    imgui.Text(u8("Доход за неделю: ")); imgui.SameLine(); 
                    imgui.TextColored(imgui.ImVec4(0.3, 1.0, 0.3, 1), formatNumber(weekData.total or 0) .. "$")
                elseif farmStatsTab.v == 2 then
                    local availableDates = getAvailableDates()
                    if #availableDates > 0 then
                        local comboStr = ""
                        for i, v in ipairs(availableDates) do 
                            if i > 1 then comboStr = comboStr .. "\0" end
                            comboStr = comboStr .. v 
                        end
                        comboStr = comboStr .. "\0"
                        imgui.Text(u8("Выберите дату:")); imgui.PushItemWidth(-1)
                        if imgui.Combo(u8("##date_select_saw"), selectedDateIndexFarm, comboStr) then end
                        imgui.PopItemWidth(); imgui.Separator()
                        local idx = selectedDateIndexFarm.v + 1
                        if idx <= #availableDates then
                            local selectedDate = availableDates[idx]
                            local dayData = getDayStats(selectedDate)
                            for _, k in ipairs(config.resourceOrder) do 
                                imgui.Text(u8(config.resourceNames[k] .. ": ")); imgui.SameLine(); 
                                imgui.TextColored(imgui.ImVec4(1.0, 0.8, 0.2, 1), formatNumber(dayData[k] or 0)) 
                            end
                            imgui.Text(u8("Доход: ")); imgui.SameLine(); 
                            imgui.TextColored(imgui.ImVec4(0.3, 1.0, 0.3, 1), formatNumber(dayData.total or 0) .. "$")
                        end
                    else imgui.TextColored(imgui.ImVec4(0.8, 0.3, 0.3, 1), u8("Нет данных")) end
                end
            end
            
        elseif select_menu[5] then
            if imgui.CollapsingHeader(u8("Цели на сегодня (Ферма)"), imgui.ImVec2(-1, 25)) then
                drawFarmGoals()
            end
            imgui.Spacing()
            if imgui.CollapsingHeader(u8("Цели на сегодня (Шахта)"), imgui.ImVec2(-1, 25)) then
                drawMineGoals()
            end
            imgui.Spacing()
            if imgui.CollapsingHeader(u8("Цели на сегодня (Лесопилка)"), imgui.ImVec2(-1, 25)) then
                drawSawmillGoals()
            end
            imgui.Spacing(); imgui.Separator(); imgui.Spacing()
            if imgui.CollapsingHeader(u8("Общие цели"), imgui.ImVec2(-1, 25)) then
                local progress = settings.totalIncomeGoal > 0 and math.min(totalDailyIncome / settings.totalIncomeGoal, 1.0) or 0
                imgui.TextColored(imgui.ImVec4(1.0, 0.8, 0.2, 1), u8("Общий доход за сегодня:"))
                imgui.Spacing()
                imgui.Text(u8("Доход: ")); imgui.SameLine()
                imgui.TextColored(imgui.ImVec4(0.3, 1.0, 0.3, 1), formatNumber(totalDailyIncome) .. "$")
                imgui.Text(u8("Цель: ")); imgui.SameLine()
                imgui.TextColored(imgui.ImVec4(1.0, 0.8, 0.2, 1), formatNumber(settings.totalIncomeGoal) .. "$")
                imgui.ProgressBar(progress, imgui.ImVec2(-1, 20), u8(math.floor(progress * 100) .. "%"))
                if totalIncomeGoalReached then
                    imgui.TextColored(imgui.ImVec4(0.3, 1.0, 0.3, 1), u8("Цель достигнута!"))
                end
                imgui.Spacing(); imgui.Separator(); imgui.Spacing()
                imgui.Text(u8("Настройка цели:"))
                imgui.PushItemWidth(250)
                if imgui.InputInt("##total_income_goal", totalGoalEdit, 100000, 1000000) then
                    if totalGoalEdit.v >= 0 then
                        settings.totalIncomeGoal = totalGoalEdit.v
                        totalIncomeGoalReached = false
                        saveTotalIncomeGoal()
                    end
                end
                imgui.PopItemWidth()
                imgui.Spacing()
                if imgui.Button(u8("Сохранить цель"), imgui.ImVec2(-1, 25)) then
                    saveTotalIncomeGoal()
                    sampAddChatMessage(SCRIPT_PREFIX .. "Общая цель дохода сохранена!", SCRIPT_COLOR)
                end
                imgui.SameLine()
                if imgui.Button(u8("Сбросить"), imgui.ImVec2(-1, 25)) then
                    totalIncomeGoalReached = false
                    totalDailyIncome = 0
                    totalIncomeCacheTime = 0
                    saveTotalIncomeGoal()
                    sampAddChatMessage(SCRIPT_PREFIX .. "Прогресс общей цели сброшен!", SCRIPT_COLOR)
                end
            end
   
        elseif select_menu[6] then
            local winW = imgui.GetWindowWidth()
            local centerX = winW / 2
            local headerKlavisha = u8("Клавиша")
            local headerKlavishaWidth = imgui.CalcTextSize(headerKlavisha).x
            imgui.TextColored(imgui.ImVec4(0.3, 1.0, 0.3, 1), u8("Название бинда"))
            imgui.SameLine(centerX - headerKlavishaWidth / 2)
            imgui.TextColored(imgui.ImVec4(0.3, 1.0, 0.3, 1), headerKlavisha)
            local headerUpravlenie = u8("Управление")
            local headerUpravlenieWidth = imgui.CalcTextSize(headerUpravlenie).x
            imgui.SameLine(winW - 60 - headerUpravlenieWidth / 2)
            imgui.TextColored(imgui.ImVec4(0.3, 1.0, 0.3, 1), headerUpravlenie)
            imgui.Separator()
            if #bindDatabase.binds == 0 then
                imgui.Text(u8("Нет биндов. Создайте новый!"))
            else
                for key, val in ipairs(bindDatabase.binds) do
                    -- Фон строки
                    imgui.PushStyleColor(imgui.Col.ChildWindowBg, imgui.ImVec4(0.12, 0.12, 0.12, 1.0))
                    imgui.BeginChild("bind_row_" .. key, imgui.ImVec2(imgui.GetWindowWidth() - 10, 36), false)
                    imgui.SetCursorPosY(imgui.GetCursorPosY() + 3)
                    
                    imgui.TextColored(imgui.ImVec4(1.0, 0.8, 0.2, 1), "#" .. key)
                    imgui.SameLine(35)
                    imgui.Text(u8(val.name or "Без названия"))
                    local keyNames = {}
                    for _, vk in ipairs(val.v or {}) do table.insert(keyNames, vkeys.id_to_name(vk)) end
                    local keyStr = #keyNames > 0 and table.concat(keyNames, " + ") or "НЕТ"
                    local keyTextWidth = imgui.CalcTextSize(u8(keyStr)).x
                    imgui.SameLine(winW / 2 - keyTextWidth / 2)
                    imgui.Text(u8(keyStr))
                    imgui.SameLine(winW - 90)
                    if imgui.Button(fa.ICON_PENCIL_SQUARE_O .. "##edit" .. key, imgui.ImVec2(25, 25)) then
                        local temp = {}
                        for _, v in ipairs(val.text) do table.insert(temp, v) end
                        editBindMultiline.v = u8(table.concat(temp, "\n"))
                        editBindName.v = u8(val.name)
                        imgui.OpenPopup(u8("Редактирование бинда##edit_popup_" .. key))
                    end
                    imgui.SameLine()
                    if imgui.Button(fa.ICON_TRASH_O .. "##del" .. key, imgui.ImVec2(25, 25)) then
                        sampAddChatMessage(SCRIPT_PREFIX .. "Бинд \"" .. val.name .. "\" удалён.", SCRIPT_COLOR)
                        table.remove(bindDatabase.binds, key); saveBinderDatabase()
                    end
                    
                    -- Попап редактирования
                    if imgui.BeginPopupModal(u8("Редактирование бинда##edit_popup_" .. key), nil, imgui.WindowFlags.AlwaysAutoResize) then
                        imgui.Text(u8("Название:")); imgui.PushItemWidth(350)
                        imgui.InputText("##editname" .. key, editBindName); imgui.PopItemWidth()
                        imgui.Spacing(); imgui.Separator(); imgui.Spacing()
                        if imadd.HotKey("##edithotkey" .. key, val, lastKeys, 100) then saveBinderDatabase() end
                        imgui.SameLine(); imgui.Text(u8("Клавиша(-и)"))
                        imgui.Spacing(); imgui.Separator(); imgui.Spacing()
                        if imgui.CollapsingHeader(u8("Подсказка по переменным")) then
                            imgui.BulletText(u8("{WAIT-5} — задержка 5 сек."))
                            imgui.BulletText(u8("{INPUT} в конце — ввод без отправки"))
                            imgui.BulletText(u8("{CMD} в конце — команда скрипта"))
                            imgui.BulletText(u8("{MY_NAME} / {MY_ID}"))
                        end
                        imgui.Spacing()
                        imgui.Text(u8("Текст бинда (каждая строка — отдельное сообщение):"))
                        imgui.InputTextMultiline("##edittext" .. key, editBindMultiline, imgui.ImVec2(400, 150))
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
                        imgui.EndPopup()
                    end
                    
                    imgui.EndChild()
                    imgui.PopStyleColor(1)
                end
            end
            imgui.Spacing()
            if imgui.Button(fa.ICON_PLUS .. u8("  ДОБАВИТЬ БИНД"), imgui.ImVec2(-1, 25)) then
                bindDatabase.binds[#bindDatabase.binds + 1] = {name = "", text = {}, v = {}}
                imgui.OpenPopup(u8("Добавление бинда##add_popup"))
            end
            
            -- Попап добавления
            if imgui.BeginPopupModal(u8("Добавление бинда##add_popup"), nil, imgui.WindowFlags.AlwaysAutoResize) then
                imgui.Text(u8("Название:")); imgui.PushItemWidth(350)
                imgui.InputText("##addname", addBindName); imgui.PopItemWidth()
                imgui.Spacing(); imgui.Separator(); imgui.Spacing()
                if imadd.HotKey("##addhotkey", bindDatabase.binds[#bindDatabase.binds], lastKeys, 120) then saveBinderDatabase() end
                imgui.SameLine(); imgui.Text(u8("Клавиша(-и)"))
                imgui.Spacing(); imgui.Separator(); imgui.Spacing()
                if imgui.CollapsingHeader(u8("Подсказка по переменным")) then
                    imgui.BulletText(u8("{WAIT-5} — задержка 5 сек."))
                    imgui.BulletText(u8("{INPUT} в конце — ввод без отправки"))
                    imgui.BulletText(u8("{CMD} в конце — команда скрипта"))
                    imgui.BulletText(u8("{MY_NAME} / {MY_ID}"))
                end
                imgui.Spacing()
                imgui.Text(u8("Текст бинда (каждая строка — отдельное сообщение):"))
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
   
        elseif select_menu[7] then
            drawSettingsTab()
            
        elseif select_menu[8] then
            imgui.TextColored(imgui.ImVec4(0.26, 0.98, 0.26, 1.0), u8("Информация о скрипте"))
            imgui.Spacing()
            imgui.Text(fa.ICON_LINK); imgui.SameLine()
            imgui.TextColoredRGB("Разработчик - {74BAF4}Ryder")
            imgui.Bullet(); imgui.TextColoredRGB("Скрипт для отслеживания добычи ресурсов")
            imgui.Bullet(); imgui.TextColoredRGB("Работает на проекте {FFB700}Arizona RP")
            imgui.Bullet(); imgui.TextColoredRGB("Поддерживает ферму, шахту и лесопилку")
            imgui.Spacing()
            if imgui.Button(fa.ICON_WRENCH..u8" Перезагрузить скрипт", imgui.ImVec2(200, 30)) then showCursor(false); scr:reload() end
            if newversion ~= scr.version then
                imgui.Spacing()
                if imgui.Button(fa.ICON_DIAMOND..u8" Обновить до v"..newversion, imgui.ImVec2(200, 30)) then updateScript() end
            end
            imgui.Spacing(); imgui.Separator(); imgui.Spacing()
            if imgui.Button(u8("Загрузить список изменений"), imgui.ImVec2(250, 25)) then
                downloadChangelog()
                sampAddChatMessage(SCRIPT_PREFIX .. "Загружаю список изменений...", SCRIPT_COLOR)
            end
            imgui.Spacing()
            if changelogData then
                if imgui.CollapsingHeader(u8("Список изменений"), imgui.ImVec2(-1, 25)) then
                    local sortedVersions = {}
                    for ver, _ in pairs(changelogData) do
                        table.insert(sortedVersions, ver)
                    end
                    table.sort(sortedVersions, function(a, b) return a > b end)
                    for _, ver in ipairs(sortedVersions) do
                        local isNewest = (ver == scr.version)
                        local label = "v" .. ver .. (isNewest and " (текущая)" or "")
                        if isNewest then
                            imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.26, 0.98, 0.26, 1.0))
                        else
                            imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(1.0, 0.8, 0.2, 1.0))
                        end
                        if imgui.TreeNodeEx(u8(label), imgui.TreeNodeFlags.DefaultOpen) then
                            imgui.PopStyleColor(1)
                            for _, change in ipairs(changelogData[ver]) do
                                imgui.Bullet()
                                imgui.SameLine()
                                imgui.PushTextWrapPos()
                                imgui.TextWrapped(u8(change))
                                imgui.PopTextWrapPos()
                            end
                            imgui.TreePop()
                        else
                            imgui.PopStyleColor(1)
                        end
                    end
                end
            else
                imgui.TextColored(imgui.ImVec4(0.6, 0.6, 0.6, 1), u8("Список изменений не загружен"))
            end
        end
        
        imgui.EndChild() -- Правая панель
        
                imgui.End() -- Главное окно
        imgui.PopStyleColor(2)
        imgui.PopStyleVar(1)
    end
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
    sampAddChatMessage(SCRIPT_PREFIX .."Скачиваю обновление...", SCRIPT_COLOR)
    local dir = getWorkingDirectory().."/#ArzResHelper.lua"
    local url = "https://raw.githubusercontent.com/Ryder8471/ArzResHelper/refs/heads/main/%23ArzResHelper.lua?t=" .. os.time()
    local checked = false
    downloadUrlToFile(url, dir, function(id, status, p1, p2)
        if checked then return end
        if status == dlstatus.STATUS_ENDDOWNLOADDATA then
            checked = true
                        if doesFileExist(changelogPath) then os.remove(changelogPath) end
			sampAddChatMessage(SCRIPT_PREFIX .."Обновление скачано! Перезагружаю скрипт...", SCRIPT_COLOR)
            lua_thread.create(function() wait(500); showCursor(false); scr:reload() end)
        elseif status == dlstatus.STATUSEX_ENDDOWNLOAD then
            if not checked then checked = true; sampAddChatMessage(SCRIPT_PREFIX .."Ошибка при скачивании обновления.", SCRIPT_COLOR) end
        end
    end)
end

function updateCheck()
    sampAddChatMessage(SCRIPT_PREFIX .."Проверяем наличие обновлений...", SCRIPT_COLOR)
    local dir = getWorkingDirectory().."/ResHelper/files/info.upd"
    local url = "https://raw.githubusercontent.com/Ryder8471/ArzResHelper/refs/heads/main/info.upd?t=" .. os.time()
    local checked = false
    downloadUrlToFile(url, dir, function(id, status, p1, p2)
        if checked then return end
        if status == dlstatus.STATUS_ENDDOWNLOADDATA then
            checked = true
            if doesFileExist(dir) then
                local f = io.open(dir, "r")
                if f then
                    local content = f:read("*a"); f:close()
                    local upd = decodeJson(content)
                    if upd and upd.version then
                        newversion = upd.version; newdate = upd.release_date
                        if upd.version ~= scr.version then
                            sampAddChatMessage(SCRIPT_PREFIX .."Доступна версия v"..newversion.."!", SCRIPT_COLOR)
                            sampAddChatMessage(SCRIPT_PREFIX .."Откройте /rh -> О скрипте -> Обновить до v"..newversion, SCRIPT_COLOR)
                        else sampAddChatMessage(SCRIPT_PREFIX .."У вас актуальная версия v"..scr.version, SCRIPT_COLOR) end
                    end
                end
            end
        elseif status == dlstatus.STATUSEX_ENDDOWNLOAD then
            if not checked then checked = true; sampAddChatMessage(SCRIPT_PREFIX .."Не удалось проверить обновления.", SCRIPT_COLOR) end
        end
    end)
end

function saveOverlayConfig()
    local file = io.open(configDir .. "overlay_config.ini", "w")
    if file then
        file:write("[Farm]\nx=" .. overlayConfigs[WORK_TYPES.FARM].x .. "\ny=" .. overlayConfigs[WORK_TYPES.FARM].y .. "\nw=" .. overlayConfigs[WORK_TYPES.FARM].w .. "\nh=" .. overlayConfigs[WORK_TYPES.FARM].h .. "\n")
        file:write("[Mine]\nx=" .. overlayConfigs[WORK_TYPES.MINE].x .. "\ny=" .. overlayConfigs[WORK_TYPES.MINE].y .. "\nw=" .. overlayConfigs[WORK_TYPES.MINE].w .. "\nh=" .. overlayConfigs[WORK_TYPES.MINE].h .. "\n")
        file:write("[Sawmill]\nx=" .. overlayConfigs[WORK_TYPES.SAWMILL].x .. "\ny=" .. overlayConfigs[WORK_TYPES.SAWMILL].y .. "\nw=" .. overlayConfigs[WORK_TYPES.SAWMILL].w .. "\nh=" .. overlayConfigs[WORK_TYPES.SAWMILL].h .. "\n")
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

function main()
    repeat wait(100) until isSampAvailable()
    local base = getModuleHandle("samp.dll")
    local sampVer = mem.tohex( base + 0xBABE, 10, true )
    if sampVer == "E86D9A0A0083C41C85C0" then
        sampIsLocalPlayerSpawned = function()
            local res, id = sampGetPlayerIdByCharHandle(PLAYER_PED)
            return sampGetGamestate() == 3 and res and sampGetPlayerAnimationId(id) ~= 0
        end
    end
    if script.this.filename:find("%.luac") then os.rename(getWorkingDirectory().."\\ResHelper.luac", getWorkingDirectory().."\\ResHelper.lua") end
    if not doesDirectoryExist(dirml.."/ResHelper/files/") then createDirectory(dirml.."/ResHelper/files/") end
    print("{82E28C}Проверка изображений..")
    if not doesFileExist(dirml.."/ResHelper/files/logo-ArzResHelper.png") then print("{FF2525}Ошибка: {FFD825}Отсутствует изображение logo-ArzResHelper.png") end
    logoArz = imgui.CreateTextureFromFile(dirml.."/ResHelper/files/logo-ArzResHelper.png")
    loadConfig(); loadOverlayConfig(); loadInventoryBase(); initPricesFile(); initGoalsFiles(); loadGoalsProgress(); loadTotalIncomeGoal()
	
	-- Пересчитываем общий доход за сегодня при загрузке
    local gameDate = getGameDate()
    totalDailyIncome = 0
    
    -- Загружаем цены фермы
    local farmPrices = {}
    local farmPriceFile = io.open(farmPricesPath, "r")
    if farmPriceFile then
        for line in farmPriceFile:lines() do
            local k, v = line:match("^(.-)=(.*)$")
            if k and v then farmPrices[k] = tonumber(v) end
        end
        farmPriceFile:close()
    end
    
    -- Загружаем цены шахты
    local minePrices = {}
    local minePriceFile = io.open(minePricesPath, "r")
    if minePriceFile then
        for line in minePriceFile:lines() do
            local k, v = line:match("^(.-)=(.*)$")
            if k and v then minePrices[k] = tonumber(v) end
        end
        minePriceFile:close()
    end
    
    -- Считаем доход фермы
    local farmLogPath = configs[WORK_TYPES.FARM].statsPath
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
    
    -- Считаем доход шахты
    local mineLogPath = configs[WORK_TYPES.MINE].statsPath
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
	
	-- Считаем доход лесопилки
    local sawmillPrices = {}
    local sawmillPriceFile = io.open(sawmillPricesPath, "r")
    if sawmillPriceFile then
        for line in sawmillPriceFile:lines() do
            local k, v = line:match("^(.-)=(.*)$")
            if k and v then sawmillPrices[k] = tonumber(v) end
        end
        sawmillPriceFile:close()
    end
    
    local sawmillLogPath = configs[WORK_TYPES.SAWMILL].statsPath
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
    
    saveTotalIncomeGoal()
	
	sessionStartTime = os.time()
	checkChangelog()
    cb_farm.v = settings.farmEnabled; cb_undermine.v = settings.undermineEnabled; cb_lavka.v = settings.underminelavkaEnabled; cb_regular.v = settings.regularmineEnabled
    cb_chatNotify.v = settings.chatNotifyEnabled; cb_goalSound.v = settings.goalSoundEnabled; cb_pickupSound.v = settings.pickupSoundEnabled
    cb_farm_overlay.v = settings.farmOverlayEnabled; cb_mine_overlay.v = settings.mineOverlayEnabled; cb_overlay_timer.v = settings.overlayTimerEnabled
	totalGoalEdit.v = settings.totalIncomeGoal
	cb_sawmill_overlay.v = settings.sawmillOverlayEnabled
    cb_sawmill.v = settings.sawmillEnabled
    goal_vol_slider.v = settings.goalSoundVolume; pickup_vol_slider.v = settings.pickupSoundVolume
    sampRegisterChatCommand("rh", function() 
        mainWin.v = not mainWin.v; imgui.ShowCursor = mainWin.v
                        if firstOpen and mainWin.v then
            firstOpen = false
            autoScanningInProgress = true
            lua_thread.create(function()
                wait(200)
                local savedWork = currentWork
                switchWorkType(WORK_TYPES.FARM, true); wait(300); startInventoryScan()
                while scanState.active do wait(50) end; wait(500)
                switchWorkType(WORK_TYPES.MINE, true); wait(300); startInventoryScan()
                while scanState.active do wait(50) end; wait(500)
                switchWorkType(WORK_TYPES.SAWMILL, true); wait(300); startInventoryScan()
                while scanState.active do wait(50) end; wait(500)
                switchWorkType(savedWork, true)
                autoScanned = true
                autoScanningInProgress = false
                sampAddChatMessage(SCRIPT_PREFIX.."Авто-сканирование завершено! Все режимы отсканированы.", SCRIPT_COLOR)
            end)
        end
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
    checkAndResetDaily()
    repeat wait(100) until sampIsLocalPlayerSpawned()
    sampAddChatMessage(string.format(SCRIPT_PREFIX.."ResHelper загружен! /rh - меню. Версия: %s", scr.version), SCRIPT_COLOR)
    updateCheck()
    imgui.ShowCursor = false
    while true do
        wait(0)
        if os.time() % 60 == 0 then checkAndResetDaily() end
        if isKeyDown(VK_LMENU) and isKeyJustPressed(VK_K) and not sampIsChatInputActive() then mainWin.v = not mainWin.v; imgui.ShowCursor = mainWin.v end
        if not mainWin.v and imgui.ShowCursor then imgui.ShowCursor = false end
        if not sampIsChatInputActive() and not sampIsDialogActive() then binderStart() end
        
        -- Обновление таймера (каждую секунду)
        if overlayTimer.running and os.time() ~= (overlayTimer.lastUpdate or 0) then
            overlayTimer.elapsed = os.time() - overlayTimer.startTime
            overlayTimer.displayedTime = formatTime(overlayTimer.elapsed)
            overlayTimer.lastUpdate = os.time()
        end
        
        local needRender = mainWin.v or settings.farmOverlayEnabled or settings.mineOverlayEnabled or settings.sawmillOverlayEnabled
        if imgui.Process ~= needRender then imgui.Process = needRender end
    end
end