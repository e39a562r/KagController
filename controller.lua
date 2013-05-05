local app, script = unpack({...})
local Controller = {}
local sys = {}
local filename_t = "first.ks"
sys.log = ""

-------------------------------
-----------初始化--------------
-------------------------------
local root = UI.View()
Controller.loadComplete=false
------------

local left=(app.width-800)/2
local top=(app.height-600)/2

--root:setSize(KAGWindow_config.scWidth,KAGWindow_config.scHeight)
root:setSize(800,600)
root:setPosition({top=top,left=left})
root:setBackgroundColor({a=1,r=0.36,g=0.36,b=0.36})
app:set_layout(root)

print("System information:")
table.extract(app)



-----------------------------
-----------------------------
-----------------------------

-------------------
--KAGParser Start--
-------------------
function KAGParser(name)
local _KAGParser = {}
local filename

--flag can check whether the file exist or not
local flag = false
local content = ""
local origin_content = ""
local index = 1
local macro = {}
local iscript = {}
local elements = {}
_KAGParser.elements = elements
local tagNames = {}
local logLine = {}
local t_e = {}
local recordTjs = {}
local macro_names = {}
local tmp_t = {}
local macro_t = {}
local macro_tt = {}
local logWhere = {}
local deletedTag = {}

--constructor, for loading file
--KAGParser=class(function(a,name)
  -- body
--end)
function _KAGParser:getElements()
  if flag ~= false then
    return elements
  end
end

--iterate the next element
function _KAGParser:next()
  -- body
  if flag ~= false then
    index = index + 1
  end
end

function _KAGParser:curEle()
  -- body
  if flag ~= false then
    return elements[index]
  end
end

--print all content
function _KAGParser:printAll()
  -- body
  if flag ~= false then
    --cut the last "\n"
    print(string.sub(origin_content,1,#origin_content-1))
  end
end

--return all original content
function _KAGParser:getContent()
  -- body
  if flag ~= false then
    --cut the last "\n"
    return string.sub(origin_content,1,#origin_content-1)
  end
end


function _KAGParser:jumpTo(where)
  -- body
  if flag ~= false then
    for i=1,#logWhere do
      if logWhere[i][1]==where then
        return logWhere[i][2]+1
      end
    end
    return nil
  end
end
function _KAGParser:setPos(Pos)
  -- body
  if flag ~= false then
    index=Pos
  end
end

function _KAGParser:cur()
  -- body
  if flag ~= false then
    return index
  end
end

function _KAGParser:getMacros()
  -- body
  if flag~=false then
    local copy = {}
    for i=1,#macro do
      copy[macro[i].name]=macro[i]
    end
    return copy
  end
end
--
--other functions
--
function _KAGParser:_logJump()
  -- body
  local tmp = 1
  for i=1,#t_e do
    if t_e[i][1]=="tag=\"jumpTarget\"" then
      --if t_e[i][2]:find("^text=%*")~=nil then
        logWhere[tmp]={}
        logWhere[tmp][1]=_KAGParser:_split(t_e[i][2]:gsub("\"",""),"=")[2]
        logWhere[tmp][2]=i
        tmp = tmp + 1
      --end
    end
  end
  --table.extract(logWhere)
end

function _KAGParser:_clear()
  -- body
  filename = ""
  flag = false
  content = ""
  origin_content = ""
  index = 1
  macro = {}
  iscript = {}
  elements = {}
  tagNames = {}
  logLine = {}
  t_e = {}
  recordTjs = {}
  macro_names = {}
  tmp_t = {}
  macro_t = {}
  macro_tt = {}
  logWhere={}
  deletedTag = {}
end

--get tags with @(tags)
function _KAGParser:_getTag()
  -- body
  if flag ~= false then
    local tmp = {}
    local x = 1
    local z = 1
    local m = 1
    local t = 1
    --_KAGParser:_split into lines
    tmp = _KAGParser:_split(content,"\n")
    
    local i=1
    while true do
    if i==#tmp+1 then break end
    --for i=1, #tmp do
      if string.find(tmp[i],"^@") ~= nil then
        tmp_t = {}
        local tmp_elements = ""
        local tag = ""
        local check = 0
        tmp_t = _KAGParser:_split(tmp[i],"%s")
        local y = 2
    
        while true do
          if y <= #tmp_t then
            if _KAGParser:_char_count(tmp_t[y],"\"") == 0 or _KAGParser:_char_count(tmp_t[y],"\"") == 2 then
              if _KAGParser:_char_count(tmp_t[y],"\"") == 0 and tmp_t[y]~="*" then tmp_t[y]=_KAGParser:_split(tmp_t[y],"=")[1].."=\"".._KAGParser:_split(tmp_t[y],"=")[2].."\"" end
              if tmp_t[y]=="*" then tmp_t[y]="\""..tmp_t[y].."\"" end
              tmp_elements = tmp_elements..(","..tmp_t[y])
            elseif _KAGParser:_char_count(tmp_t[y],"\"") == 1 then
              tmp_elements = _KAGParser:_trim(tmp_elements .. (","))
              while true do
                tmp_elements = (tmp_elements .. (tmp_t[y].." "))
                y = y + 1
                if _KAGParser:_char_count(tmp_t[y],"\"") == 1 then
                  tmp_elements = (tmp_elements .. (tmp_t[y]))
                break
                end
                if y==#tmp_t then
                  if _KAGParser:_char_count(tmp_t[y],"\"") == 0 then
                    tmp_elements = (tmp_elements .. (tmp_t[y]))..";\""
                    break
                  end
                end
              end
            end
          end
          --print(y)
          y=y+1
          if y > #tmp_t then
            break
          end
        end
        
        tag = string.gsub(_KAGParser:_split(tmp_t[1],"@")[1],"\"","")

        if string.find(tag,"^iscript$") == nil and string.find(_KAGParser:_split(tmp_t[1],"@")[1],"^endscript$") == nil then
          elements[x] = "{tag=\""..tag.."\""..tmp_elements.."}"
          logLine[x] = i
          x = x + 1
        elseif string.find(tag,"^iscript$") ~= nil  then
          elements[x] = "{tag=\""..tag.."\",".."\""..iscript[z].."\"}"
          logLine[x] = i
          z = z + 1
          x = x + 1
        end
      end
      i = i + 1
    end

    _KAGParser:_elementsFind()
    --while true do
      tagNames={}
      for i=1,#elements do
        tagNames[i] = _KAGParser:_split(_KAGParser:_split(elements[i],"{tag=\"")[1],"\"")[1]
      end
  end
end

--get Tjs code below the @iscript
function _KAGParser:_getTjs()
  -- body
  if flag ~= false then
    local tmp = {}
    local iscript_index = 1
    --_KAGParser:_split into lines
    tmp = _KAGParser:_split(content,"\n")
    t = _KAGParser:_split(content,"\n")
    local check_tjs = 1
    for i=1, #tmp do
      local tmp_iscript = ""
      local x = i + 1
      if string.find(tmp[i],"iscript") ~= nil then
        while true do
          tmp_iscript=tmp_iscript..(tmp[x].."\n")
          recordTjs[check_tjs] = x
          x = x + 1
          check_tjs = check_tjs + 1
          if string.find(tmp[x],"endscript") ~= nil then
            break
          end
        end
        iscript[iscript_index]=_KAGParser:_trim(string.sub(tmp_iscript,1,#tmp_iscript-1)):gsub("\"","\\\""):gsub("/%*.-%*/",""):gsub("//.-\n",""):gsub("\n","")
        --print(content)
        iscript_index = iscript_index + 1
      end
    end
    --return iscript
    local r_tjs = ""
    for i=1,#t do
      for n=1,#recordTjs do
        if i==recordTjs[n] then
          t[i]=""
        end
      end
      r_tjs=r_tjs..(t[i].."\n")
    end
    content=r_tjs
  end 
end

--get macro code below the [macro] or @macro
function _KAGParser:_getMacro()
  -- body
  if flag ~= false then
    local tmp = {}
    local macro_index = 1
    local macro_tmp = {}
    local deleteLines = {}
    local deleteIndex = 1
    --_KAGParser:_split into lines
    tmp = _KAGParser:_split(content,"\n")

    for i=1, #tmp do
      local tmp_macro = ""
      local x = i 
      if string.find(tmp[i],"^@macro") ~= nil then
        --recordMacro[macro_index]=i
        while true do
          if x <= #tmp then
            if string.find(tmp[x],"endmacro") ~= nil then
            --print(tmp[x])
              for y=i,x do
                tmp_macro=tmp_macro..(tmp[y].."\n")
                deleteLines[deleteIndex]=y
                deleteIndex = deleteIndex + 1
              end
              break
            end
            x = x + 1
          end
        end
        macro_tmp[macro_index]=_KAGParser:_trim(string.sub(tmp_macro,1,#tmp_macro-1))
        --content = string.gsub(content, macro[macro_index],"")
        macro_index = macro_index + 1
      end
    end
    local local_index = 1
    while macro_tmp[local_index]~=nil do
      if local_index<=1 then
        macro[local_index]=macro_tmp[local_index]
        --print(macro_tmp[1])
      else
        macro[local_index]=macro_tmp[local_index+1]
        --print(macro_tmp[1])
      end
      local_index=local_index+1
    end
    for i=1,#deleteLines do
      local delete = deleteLines[i]
      tmp[delete] = ""
    end
    local tmp_content = ""
    for i=1,#tmp do
      tmp_content = tmp_content..(tmp[i].."\n")
    end
    content = tmp_content
    --_KAGParser:_translateMacro()
  end 
end

--_KAGParser:_trim all elements to 2D array(table)
function _KAGParser:_elementsFind()
  -- body
  local tmp = {}
  t_e = {}
  for i=1,#elements do
    tmp[i] = string.sub(elements[i],2,#elements[i]-1)
    t_e[i] = _KAGParser:_split(tmp[i],",")
  end
  --print(t_e[2][2])
end

--_KAGParser:_trim [ ] closure
function _KAGParser:_trimClosure()
  -- body
  if flag ~= nil then
    local tmp = _KAGParser:_split(content,"\n")
    for i=1,#tmp do
      if string.find(tmp[i],"^%[") ~= nil then
        if string.find(tmp[i],"^%[") ~= nil then
          tmp[i]=string.gsub(tmp[i],"^%[","@")
        end
        if string.find(tmp[i],"\]$") ~= nil then
          tmp[i]=string.gsub(tmp[i],"\]$","")
        end
      end
    end
    local t_content = ""
    for i=1,#tmp do
      t_content=t_content..(tmp[i].."\n")
    end
    content=t_content
  end
end

--translate macro into pieces
function _KAGParser:_translateMacro()
  -- body
  local macro_elements = {}
  local m_index=1
  for x=1,#macro do
    macro_elements[x] = {}
    for y=1,#_KAGParser:_split(macro[x],"\n") do
      if _KAGParser:_split(macro[x],"\n")[y]~="" then 
        table.insert(macro_elements[x],_KAGParser:_split(macro[x],"\n")[y])
      end
    end
  end
  --io.close(tmpfile)
  --local macro_names = {}
  for x=1,#macro_elements do
    macro_names[x] = string.gsub(_KAGParser:_split(_KAGParser:_split(macro_elements[x][1]," ")[2],"=")[2],"\"","")
  end

  local translated = {}
  --scan all elements, if text ,add @ch tag
  for x=1,#macro_elements do
    for y=1,#macro_elements[x] do
      if string.find(macro_elements[x][y],"^@") == nil then
        --add @ch tag
        macro_elements[x][y] = "@ch text=\""..macro_elements[x][y].."\""
      end
    end
  end
  local tmp_text = ""
  for x=1,#macro_elements do
    tmp_text = ""
    for y=1,#macro_elements[x] do
      if string.find(macro_elements[x][y],"^@macro") == nil and string.find(macro_elements[x][y],"^@endmacro") == nil then
        local t_macro = _KAGParser:_split(macro_elements[x][y]," ")
        
        local t = ""
        local n = 2
        --print(t_macro[1])
        while true do
          if n <= #t_macro then
            if _KAGParser:_char_count(t_macro[n],"\"") == 0 or _KAGParser:_char_count(t_macro[n],"\"") == 2 then
              if _KAGParser:_char_count(t_macro[n],"\"") == 0 and t_macro[n]~="*" and t_macro[n]:find("=")~=nil then
                t_macro[n]=_KAGParser:_split(t_macro[n],"=")[1].."=\"".._KAGParser:_split(t_macro[n],"=")[2].."\"" 
              end
              if t_macro[n]=="*" then t_macro[n]="\""..t_macro[n].."\"" end
              t = t .. (","..t_macro[n])
              --print(t_macro[n])
            elseif _KAGParser:_char_count(t_macro[n],"\"") == 1 then
              t = t .. ","
              while true do
                if n<= #t_macro then
                  t = t ..(t_macro[n].." ")
                  n = n + 1
                  if _KAGParser:_char_count(t_macro[n],"\"") == 1 then
                    t = t ..(t_macro[n])
                    break
                  end
                else
                  if _KAGParser:_char_count(t_macro[n],"\"")==0 then t=t..";\"" end
                  break
                end
              end
            end
          end
          n = n + 1
          if n > #t_macro then
            break
          end
        end
        tmp_text = tmp_text..",{tag=\""..string.gsub(string.gsub(t_macro[1],"@",""),"\"","") .."\"".. t.."}"
      end
    end 
    macro_t[x] = _KAGParser:_split(string.gsub(string.sub(tmp_text,2),"},{","}\n{"),"\n")--string.gsub(string.sub(tmp_text,3,#tmp_text-1),"},{","\n")
    macro_tt[x]=string.gsub(string.sub(tmp_text,3,#tmp_text-1),"},{","\n")
    macro[x] = "{tag=\"macro\",name=\""..macro_names[x].."\",content={"..string.sub(tmp_text,2).."}}"
  end
end

--get text
function _KAGParser:_getText()
  -- body
  local tmp = _KAGParser:_split(content,"\n")
  local tmp_c = ""

  for i=1,#tmp do
    if string.find(tmp[i],"^@") == nil and string.find(tmp[i],"^//") == nil and string.find(tmp[i],"^$") == nil and string.find(tmp[i],"^;") == nil and tmp[i]~="\n" and tmp[i]:find("^%*")==nil then
      tmp[i] = "@ch text=\""..tmp[i].."\""
    elseif tmp[i]:find("^%*") then
      tmp[i] = "@jumpTarget text=\""..tmp[i].."\""
    end
    tmp_c = tmp_c ..(tmp[i].."\n")
  end
  content = tmp_c
end

--_KAGParser:_split string into pieces
function _KAGParser:_split(str, pat)
   local t = {}  -- NOTE: use {n = 0} in Lua-5.0
   local fpat = "(.-)" .. pat
   local last_end = 1
   local s, e, cap = str:find(fpat, 1)
   while s do
      if s ~= 1 or cap ~= "" then
   table.insert(t,cap)
      end
      last_end = e+1
      s, e, cap = str:find(fpat, last_end)
   end
   if last_end <= #str then
      cap = str:sub(last_end)
      table.insert(t, cap)
   end
   return t
end

--_KAGParser:_trim space
function _KAGParser:_trim(s)
    return (s:gsub("^%s*(.-)%s*$", "%1"))
end

--count how many chars
function _KAGParser:_char_count(str, char) 
    if not str then
        return 0
    end
    local count = 0 
    local byte_char = string.byte(char)
    for i = 1, #str do
        if string.byte(str, i) == byte_char then
            count = count + 1 
        end 
    end 
    return count
end
function _KAGParser:_parse()
  -- body
  if flag ~= false then
    _KAGParser:_trans_all(macro)
    _KAGParser:_trans_all(elements)
    --dumpTable(ele)
  end
end
function _KAGParser:_trans_all(ele)
  -- body
  for i,v in ipairs(ele)do
    local fn,errMsg = loadstring("return "..v)
    if fn then
      ele[i] = fn()
    else
      print(errMsg, v)
    end
  end
end

local tag_pattern = {"autowc"  ,"clearsysvar" ,"clickskip" ,"close" ,"cursor"  ,"hidemessage" ,"loadplugin"  ,"mappfont " ,"nextskip" ,"quake" ,"rclick"  ,"resetwait" ,"s" ,"stopquake" ,"title" ,"wait"  ,"waitclick","wc","wq","checkbox","commit","edit","endmacro","erasemacro","macro","cancelautomode"  ,"cancelskip"  ,"ch"  ,"cm"  ,"ct"  ,"current" ,"deffont" ,"defstyle"  ,"delay" ,"endindent" ,"endnowait" ,"er"  ,
  "font"  ,"glyph" ,"graph" ,"hch" ,"l" ,"locate"  ,"locklink"  ,"nowait"  ,"position"  ,"r" ,"resetfont" ,"resetstyle"  ,"ruby"  ,"style" ,"unlocklink","endhact","hact","history","hr","showhistory","button","call","cclick","click","ctimeout","cwheel","endlink","jump","return","timeout","wheel","animstart","animstop","backlay","copylay","freeimage","image","laycount",
  "layop","mapaction","mapdisable","mapimage","move","pimage","ptext","stopmove","stoptrans","trans","wa","wm","wt","bgmopt", "cancelvideoevent","cancelvideosegloop","clearbgmlabel","clearbgmstop","clearvideolayer", "fadebgm", "fadeinbgm","fadeinse","fadeoutbgm","fadeoutse","fadepausebgm","fadese",
  "openvideo","pausebgm","pausevideo","playbgm","playse","playvideo","preparevideo", "resumebgm","resumevideo", "rewindvideo", "seop","setbgmlabel","setbgmstop", "stopbgm","stopse", "stopvideo","video","videoevent","videolayer", "videosegloop","wb","wf", "wl","wp", "ws", "wv", "xchgbgm", "clearvar","else","elsif","emb","endif","endignore","endscript","eval","if","ignore","input", "iscript","trace","waittrig","copybookmark"  ,"disablestore","erasebookmark","goback" ,"gotostart" ,"load"  ,"locksnapshot","record","save" ,"startanchor","store","tempload" ,"tempsave" ,"unlocksnapshot" }


function string:_anylyzeThis()
  for k,v in pairs(tag_pattern) do
    self=self:gsub("%["..v.."+.-%]","\n".."%1".."\n")
  end
  return self
end
  --if io.open(name) == nil then
  --  print("cannot find file "..name..",Parser error")
 -- else
    _KAGParser:_clear()
    flag = true
    filename=name
  --KAG_LOAD
  --local content=load(filename)
    content=script
    content=content:_anylyzeThis()
    origin_content = script
    --print(content)
    content=content:gsub("]\\","]")
    _KAGParser:_getTjs()
    
    content=content:gsub(" = ","=")
    content=content:gsub(" == ","==")
    content=content:gsub(" === ","===")
    content=content:gsub(" != ","!=")
    content=content:gsub(" !== ","!==")
    content=content:gsub(" !=== ","!===")
    content=content:gsub(";.-\n","\n")
    content=content:gsub("   "," ")
    content=content:gsub("  "," ")
    --print(content)
    --content=content:gsub("%s%s"," ")
    _KAGParser:_trimClosure()
    _KAGParser:_getMacro()
    _KAGParser:_translateMacro()
    _KAGParser:_getText()
    _KAGParser:_getTag()
    _KAGParser:_logJump()
    --print(content)
    _KAGParser:_parse()
    --table.extract(_KAGParser:getElements())
  --end
return _KAGParser
end
-------------------------
------KAGParser end------
-------------------------

--require "KAGParser"--
local parser = KAGParser(filename_t)
Controller.macros = parser:getMacros()
-----------------------


local res = ENV.RESOURCES

local slot = {
  videoslot = {},
  seslot = {}
}


local mp = {}
local kag = {
  clickCount = 0,
  lastMouseDownX = 0,
  lastMouseDownY = 0,
  lastWaitTime = 0,
  skipMode = 0,
  autoMode = false,
  getBookMarkPageName = function()end,
  bgm = {},
  menu = {},
  fore = {message = {},layer = {}},
  back = {message = {},layer = {}},
  layer = {},
  message = {},
  slot = {},
  se = {},
  current = 0,
  close = function()end,
  shutdown = function()end,
  restoreBookMark = function()end,
  storeBookMark = function()end,
  loadBookMarkFromFileWithAsk = function()end,
  saveBookMarkToFileWithAsk = function()end,
  callExtraConductor = function ()end,
  process = function()end,
  leftClickHook = {add=function()end,remove=function()end},
  rightClickHook = {add=function()end,remove=function()end},
  keyDownHook = {add=function()end,remove=function()end},
  gvolume = 100,
  chSpeed = "normal",
  pagwait = "medium",
  linewait = "medium",
  delay = 0
}
kag.buf=kag.se

local System = {
  touchImages = function()end,
  getKeyState = function()end, -- は、現在その時点で、指定されたキーが押されているかどうかを判断することができます。
  shellExecute = function(url)end,
  exit = function()end,

}

local layers = {}
local KAGWindow_config = {}
KAGWindow_config.scWidth = 640
KAGWindow_config.scHeight = 480
KAGWindow_config.readOnlyMode = false
KAGWindow_config.freeSaveDataMode = false
KAGWindow_config.saveThumbnail = false
KAGWindow_config.thumbnailWidth = 133
KAGWindow_config.thumbnailDepth = 8
KAGWindow_config.dataName = "data"
KAGWindow_config.saveDataID = "00000000-0000-0000-0000-000000000000"
KAGWindow_config.saveDataMode = ""
KAGWindow_config.saveMacros = true
KAGWindow_config.chSpeeds = {}
KAGWindow_config.chSpeeds.fast = 10
KAGWindow_config.chSpeeds.normal = 30
KAGWindow_config.chSpeeds.slow = 50
KAGWindow_config.autoModePageWaits = {}
KAGWindow_config.autoModePageWaits.fast = 400
KAGWindow_config.autoModePageWaits.faster = 700
KAGWindow_config.autoModePageWaits.medium = 1000
KAGWindow_config.autoModePageWaits.slower = 1300
KAGWindow_config.autoModePageWaits.slow = 2000
KAGWindow_config.autoModeLineWaits = {}
KAGWindow_config.autoModeLineWaits.fast = 180
KAGWindow_config.autoModeLineWaits.faster = 240
KAGWindow_config.autoModeLineWaits.medium = 300
KAGWindow_config.autoModeLineWaits.slower = 360
KAGWindow_config.autoModeLineWaits.slow = 500
KAGWindow_config.cursorDefault = crArrow
KAGWindow_config.cursorPointed = crHandPoint
KAGWindow_config.cursorWaitingClick = crArrow
KAGWindow_config.cursorDraggable = crSizeAll
KAGWindow_config.autoRecordPageShowing = true
KAGWindow_config.recordHistoryOfStore = 0
KAGWindow_config.maxHistoryOfStore = 5
KAGWindow_config.defaultQuakeTimeInChUnit = false
KAGWindow_config.numSEBuffers = 3
KAGWindow_config.numMovies = 1
KAGWindow_config.numCharacterLayers = 3
KAGWindow_config.scPositionX = {}
KAGWindow_config.scPositionX.left = 160
KAGWindow_config.scPositionX.left_center = 240
KAGWindow_config.scPositionX.center = 320
KAGWindow_config.scPositionX.right_center = 400
KAGWindow_config.scPositionX.right = 480
KAGWindow_config.scPositionX.l = KAGWindow_config.scPositionX.left
KAGWindow_config.scPositionX.lc = KAGWindow_config.scPositionX.left_center
KAGWindow_config.scPositionX.c = KAGWindow_config.scPositionX.center
KAGWindow_config.scPositionX.rc = KAGWindow_config.scPositionX.right_center
KAGWindow_config.scPositionX.r = KAGWindow_config.scPositionX.right
KAGWindow_config.numMessageLayers = 2
KAGWindow_config.initialMessageLayerVisible = true
KAGWindow_config.numBookMarks = 10
KAGWindow_config.showBookMarkDate = true
KAGWindow_config.showFixedPitchOnlyInFontSelector = false
KAGWindow_config.helpFile = "readme.txt"
KAGWindow_config.aboutWidth = 320
KAGWindow_config.aboutHeight = 200

local Menu_visible_config = {}
Menu_visible_config.menu = {}
Menu_visible_config.menu.visible = true
Menu_visible_config.rightClickMenuItem = {}
Menu_visible_config.rightClickMenuItem.visible = true
Menu_visible_config.showHistoryMenuItem = {}
Menu_visible_config.showHistoryMenuItem.visible = true
Menu_visible_config.skipToNextStopMenuItem = {}
Menu_visible_config.skipToNextStopMenuItem.visible = true
Menu_visible_config.autoModeMenuItem = {}
Menu_visible_config.autoModeMenuItem.visible = true
Menu_visible_config.autoModeWaitMenu = {}
Menu_visible_config.autoModeWaitMenu.visible = true
Menu_visible_config.goBackMenuItem = {}
Menu_visible_config.goBackMenuItem.visible = true
Menu_visible_config.goToStartMenuItem = {}
Menu_visible_config.goToStartMenuItem.visible = true
Menu_visible_config.characterMenu = {}
Menu_visible_config.characterMenu.visible = true
Menu_visible_config.chNonStopToPageBreakItem = {}
Menu_visible_config.chNonStopToPageBreakItem.visible = true
Menu_visible_config.ch2ndSpeedMenu = {}
Menu_visible_config.ch2ndSpeedMenu.visible = true
Menu_visible_config.ch2ndNonStopToPageBreakItem = {}
Menu_visible_config.ch2ndNonStopToPageBreakItem.visible = true
Menu_visible_config.chAntialiasMenuItem = {}
Menu_visible_config.chAntialiasMenuItem.visible = true
Menu_visible_config.chChangeFontMenuItem = {}
Menu_visible_config.chChangeFontMenuItem.visible = true
Menu_visible_config.restoreMenu = {}
Menu_visible_config.restoreMenu.visible = true
Menu_visible_config.storeMenu = {}
Menu_visible_config.storeMenu.visible = true
Menu_visible_config.displayMenu = {}
Menu_visible_config.displayMenu.visible = true
Menu_visible_config.helpMenu = {}
Menu_visible_config.helpMenu.visible = true
Menu_visible_config.helpIndexMenuItem = {}
Menu_visible_config.helpIndexMenuItem.visible = false
Menu_visible_config.helpAboutMenuItem = {}
Menu_visible_config.helpAboutMenuItem.visible = false
Menu_visible_config.debugMenu = {}
Menu_visible_config.debugMenu.visible = false

local MessageLayer_config = {}
MessageLayer_config.layerType = ltAddAlpha
MessageLayer_config.frameGraphic = ""
MessageLayer_config.frameColor = 0x000000
MessageLayer_config.frameOpacity = 128
MessageLayer_config.marginL = 8
MessageLayer_config.marginT = 8
MessageLayer_config.marginR = 8
MessageLayer_config.marginB = 8
MessageLayer_config.ml = 16
MessageLayer_config.mt = 16
MessageLayer_config.mw = 640-32
MessageLayer_config.mh = 480-32
MessageLayer_config.defaultAutoReturn = true
MessageLayer_config.marginRCh = 2
MessageLayer_config.defaultFontSize = 24
MessageLayer_config.defaultLineSpacing = 6
MessageLayer_config.defaultPitch = 0
MessageLayer_config.userFace = "ＭＳ Ｐ明朝"
MessageLayer_config.defaultChColor = 0xffffff
MessageLayer_config.defaultBold = true
MessageLayer_config.defaultRubySize = 10
MessageLayer_config.defaultRubyOffset = -2
MessageLayer_config.defaultAntialiased = true
MessageLayer_config.defaultShadowColor = 0x000000
MessageLayer_config.defaultEdgeColor = 0x000000
MessageLayer_config.defaultShadow = true
MessageLayer_config.defaultEdge = false
MessageLayer_config.lineBreakGlyph = "LineBreak"
MessageLayer_config.pageBreakGlyph = "PageBreak"
MessageLayer_config.glyphFixedPosition = false
MessageLayer_config.glyphFixedLeft = 0
MessageLayer_config.glyphFixedTop = 0
MessageLayer_config.defaultLinkColor = 0x0080ff
MessageLayer_config.defaultLinkOpacity = 64
MessageLayer_config.vertical = false
MessageLayer_config.draggable = false

local BGM_config = {}
BGM_config.type = "MIDI"
BGM_config.cdVolume = "xxxx"
BGM_config.doubleBuffered = false
BGM_config.midiInitialMessage = "<% f0 7e 7f 09 01 f7 ff 00 %>"

local HistoryLayer_config = {}
HistoryLayer_config.fontName = "ＭＳ Ｐ明朝"
HistoryLayer_config.fontBold = true
HistoryLayer_config.fontHeight = 24
HistoryLayer_config.lineHeight = 26
HistoryLayer_config.verticalView = false
HistoryLayer_config.everypage = false
HistoryLayer_config.autoReturn = true
HistoryLayer_config.maxPages = 100
HistoryLayer_config.maxLines = 2000
HistoryLayer_config.storeState = false

function KAGPage()
  local p = UI.View()

  function p:assignImages(source)
    self:free()
    self:setSize(source:size())
    for i,v in ipairs(source:subviews()) do
      if v.constructor == UI.ImageView then
        local sub = UI.ImageView()
        sub:setSize(v:size())
        sub:setPosition(v:position())
        sub:setAlpha(v:alpha())
        sub:setImage(v:image())
        self:appendView(sub)
      end
    end
  end

  local oldimage = p.image

  function p:image(args)
    if not args then return oldimage(self) end
    local s = res[args.storage].size
    local w,h = args.clipwidth or s.width, args.clipheight or s.height
    self:free()
    self:setSize(w,h)
    local pp = UI.ImageView({View = {width=w,height=h}})
    pp:setImage(args.storage, -args.clipleft, -args.cliptop, w, h)
    self:appendView(pp)

    if args.key then print("Warning!! image.key", args.key) end
    if args.mode then print("Warning!! image.mode", args.mode) end
    if args.grayscale then print("Warning!! image.grayscale", args.grayscale) end
    if args.rgamma then print("Warning!! image.rgamma", args.rgamma) end
    if args.ggamma then print("Warning!! image.ggamma", args.ggamma) end
    if args.bgamma then print("Warning!! image.bgamma", args.bgamma) end
    if args.rfloor then print("Warning!! image.rfloor", args.rfloor) end
    if args.gfloor then print("Warning!! image.gfloor", args.gfloor) end
    if args.bfloor then print("Warning!! image.bfloor", args.bfloor) end
    if args.rceil then print("Warning!! image.rceil", args.rceil) end
    if args.gceil then print("Warning!! image.gceil", args.gceil) end
    if args.bceil then print("Warning!! image.bceil", args.bceil) end
    if args.mcolor then print("Warning!! image.mcolor", args.mcolor) end
    if args.mopacity then print("Warning!! image.mopacity", args.mopacity) end
    if args.lightcolor then print("Warning!! image.lightcolor", args.lightcolor) end
    if args.lighttype then print("Warning!! image.lighttype", args.lighttype) end
    if args.flipud~=nil then print("Warning!! image.flipud", args.flipud) end
    if args.fliplr~=nil then print("Warning!! image.fliplr", args.fliplr) end
  end

  function p:pimage(args) 
    if not args.storage then return print("fuck you! pimage must give storage") end
    if args.mode then print("Warning!! pimage.mode", args.mode) end
    if args.key then print("Warning!! pimage.key", args.key) end
    local s = res[args.storage].size
    local w,h = args.sw or s.width - args.sx, args.sh or s.height - args.sy
    local pp = UI.ImageView({View = {left = args.dx, top = args.dy, width=w,height=h,alpha=(args.opacity or 255)/255}})
    pp:setImage(args.storage, -args.sx, -args.sy, s.width, s.height)
  end

  function p:freetext() 
    local subviews = self:subviews()
    for i=1,#subviews do
      if subviews[i].constructor==UI.LabelView then
        self:removeView(subviews[i])
      end
    end
  end

  function p:free() 
    local subviews = self:subviews()
    for i=1,#subviews do
      self:removeView(subviews[i])
    end
    self:setSize(0,0)
  end

  return p
end

function KAGLayer()
  local l = UI.View()
  l:setSize(app.width, app.height)
  l.both = KAGPage()
  l.fore = KAGPage()
  l.back = KAGPage()
  l.back:setAlpha(0)

  l.fore:setAlpha(0)
  l.visible = false
  l.opacity = 255

  function l:backlay()
    local subviews = self.fore:subviews()
    for i=1,#subviews do
      self.both:appendView(subviews[i])
    end
    self.fore:free()
    self.back:free()
  end

  function l:copylay(src_l, src_page, dest_page)
    local spage = src_l[src_page or "fore"]
    local dpage = self[dest_page or "fore"]
    dpage:assignImages(spage)
  end

  function l:trans(args, callback)
    if args.method =="universal" then
      self.back:transIn(args.rule, args.time, args.vague, nil, callback)
      self.fore:transOut(args.rule, args.time, args.vague)
    else  --scroll以crossfade處理
      self.back:fadeIn(args.time, callback)
      self.fore:fadeOut(args.time)
    end

    local temp = self.fore
    self.fore = self.back
    self.back = temp
    self:insertBefore(self.fore, self.back)
  end

  function l:stoptrans(args)
    self.back:flush()
    self.fore:flush()
  end

  function l:image( args )
    if not res[args.storage] then error("Image Tag without storage!") end
    if args.shadow then print("Warning!! image.shadow", args.shadow) end
    if args.shadowopacity then print("Warning!! image.shadowopacity", args.shadowopacity) end
    if args.shadowx then print("Warning!! image.shadowx", args.shadowx) end
    if args.shadowy then print("Warning!! image.shadowy", args.shadowy) end
    if args.shadowblur then print("Warning!! image.shadowblur", args.shadowblur) end
    local page = self[args.page or "fore"]
    
    if args.visible~=nil then
      self.visible = args.visible
      self.fore:setAlpha(self.visible and 1 or 0)
    end

    if args.opacity then
      self.opacity = args.opacity
      self:setAlpha(self.opacity/255)
    end

    if args.left or args.top or args.pos then
      if not args.pos then
        local old_pos = self:position()        
        self:setPosition(args.left or old_pos.left, args.top or old_pos.top)
      else

        local img_size = res[args.storage].size
        self:setPosition(KAGWindow_config.scPositionX[args.pos] - img_size.width/2, scHeight - img_size.height)
      end
    end

    local subviews = self.both:subviews()
    for i=#subviews,1,-1 do
      self.back:insertView(subviews[i],1)
    end
    self.back:free()

    return page:image(args)
  end

  function l:pimage(args)
    if not res[args.storage] then error("Image Tag without storage!") end
    local target = self[args.page or "fore"]
    return target:pimage(args)
  end

  function l:freeimage(args)
    self[args.page or "fore"]:free()
  end
  
  l.__movelist = {}
  --改為移動layer
  function l:move(args)
    local getPath = function(path)
       split = function(str, pat)
          local t = {}  -- NOTE: use {n = 0} in Lua-5.0
          local fpat = "(.-)" .. pat
          local last_end = 1
          local s, e, cap = str:find(fpat, 1)
          while s do
            if s ~= 1 or cap ~= "" then
              table.insert(t,cap)
            end
              last_end = e+1
              s, e, cap = str:find(fpat, last_end)
          end
          if last_end <= #str then
            cap = str:sub(last_end)
            table.insert(t, cap)
          end
          return t
      end

      path=path:gsub(" ","")
      local temp = split(path,"%(")
      local output = {}
      for i=1,#temp do
        local t = split(temp[i],"%)")
        table.insert(output,t[1])
      end     
      local result = {}
      for i=1,#output do
        result[i].x=tonumber(split(output[i],",")[1])
        result[i].y=tonumber(split(output[i],",")[2])
        result[i].opacity=tonumber(split(output[i],",")[3])/255
      end

      if result~=nil then 
        return result 
      else
        return nil
      end
    end

    local paths

    if args then
      if args.delay==nil then args.delay=0 end
      paths=getPath(path)

      self.__movelist = {dur = tonumber(args.time) , delay=tonumber(args.delay) }
      while #path > 0 do table.insert(self.__movelist, table.remove(paths)) end
    end 

    if self.__movelist.delay then
      app:setTimeout({self, self.move}, self.__movelist.delay)
      self.__movelist.delay = nil
      return 
    end
    if self.__movelist and #self.__movelist > 0 then
       local path = table.remove(self.__movelist)  
       self:moveTo({left=path.x, top=path.y}, self.__movelist.dur, self.__moveend)
       self:fadeTo(path.opacity, self.__movelist.dur)
    end
  end
  
  function l:__moveend(e)
    controller:someMoveEnd()
    self:move()
  end

  function l:stopmove(args)
    while self.__movelist and #self.__movelist > 1 do
      table.remove(self.__movelist)
      self.__movelist.dur = 0
      self.__movelist.delay=nil
    end
    self:move()
    self:flush()
  end

  function l:animstart(args)
    --
    print("sorry what is animstart")
  end

  function l:animstop(args)
    --
    print("sorry what is animstop")
  end

  function l:layopt(args)
    if args.left or args.top then
      local old_pos = self:position()
      self:setPosition(args.top or old_pos.top , args.left or old_pos.left)
    end

    if args.visible~=nil then
      self.visible = args.visible
      self.fore:setAlpha(self.visible and 1 or 0)
    end

    if args.opacity then
      self.opacity = args.opacity
      self:setAlpha(self.opacity/255)
    end

    if args.autohide~=nil then
      self.autohide = toboolean(args.autohide) 
    end
  end

  function l:show()
    self.both:setAlpha(0)
    self.fore:setAlpha(0)
  end

  function l:hide()
    self.both:setAlpha(1)
    self.fore:setAlpha(1)
  end

  function l:mapaction(args)
    --
    print("sorry no mapaction")
  end
  
  function l:mapdisable(args)
    --
    print("sorry no mapdisable")
  end
  
  function l:mapimage(args)
    --
    print("sorry no mapimage")
  end
  
  function l:mappfont(args)
    --
    print("sorry no mappfont")
  end
  
  function l:ptext(args)
    local target = self[args.page or "fore"]
    local text =UI.LabelView()
    text:setText(args.text)
    text:setPosition({top=tonumber(args.y),left=tonumber(args.x)})
    text:setFontSize(tonumber(args.size) or 12)
    if args.font then text:setFont(args.font) end
    local w = args.text:countUTF8Words()*tonumber(args.size)
    local h = tonumber(args.size)*1.4
    text:setSize(w,h)
    
    if args.color then
      local color = args.color:getColor()
      text:setTextStyle({textFillColor={a=1,r=color.red,g=color.green,b=color.blue}})
    end
    
    if args.edge then
      if args.color then
        local stroke = args.edgecolor:getColor()
        text:setTextStyle({textStrokeColor={a=1,r=stroke.red,g=stroke.green,b=stroke.blue},textStrokeWidth=2})
      end
    end

    if args.bold then print("sorry no args.bold") end
    if args.shadowcolor then print("sorry no args.shadowcolor") end
    if args.shadow then print("sorry no args.shadow") end
    if args.italic then print("sorry no args.italic") end
    if args.angle then print("sorry no args.angle") end
    if args.vertical then print("sorry no args.vertical") end

    target:appendView(text)
  end
  
  l:appendView(l.both)
  l:appendView(l.fore)
  l:appendView(l.back)
  return l
end

function KAGBuf()
  local buf = Audio.Audio()
  buf:onFinish(function(self)
    self:_destroy()
  end)

  function buf:playse(args) 
    if not args.loop then args.loop=false end
    if not args.start then args.start=0 end  
    self:setSrc(args.storage)
    self:setLoop(toboolean(args.loop))
    self:seek(args.start)
    self:play()
  end

  function buf:seopt(args)
    if args.volume then self.volume1=tonumber(args.volume) end
    if args.gvolume then
      kag.gvolume=tonumber(args.gvolume)
    end
    self:setVolume(args.volume*kag.gvolume/10000)
    if args.pan then print("sorry no se.pan") end
  end

  function buf:fadeinse(args)
    self:setSrc(args.storage)
    if args.start then self:seek(tonumber(args.start)) end
    if args.loop then self:setLoop(toboolean(args.loop)) end
    self:play()
    self:fadese({time=tonumber(args.time),volume=100})
  end

  function buf:fadeoutse(args)
    self:fadese({time=tonumber(args.time),volume=0})
  end

  function buf:fadese(args)
    self:fade(tonumber(args.volume)*kag.gvolume/10000,tonumber(args.time),Controller._kagfadeend)
  end

--[[
  function buf:_kagfadeend()
    if Controller.needwait==true then
      Controller.needwait=false
      Controller:enter()
    end
  end
  ]]--

  function buf:stopse()
    self:stop()
  end

  function buf:_destroy()
    self:stop()
    if Controller.needwait==true then
      Controller.needwait=false
      Controller:enter()
    end
  end

  return buf
end


function KAGButton(args)
  local but = UI.LabelView()

  function but:_onclick(args)
    if self.locklink and self.locklink.locklink then return end
    if args.buf then Controller:_getbuf(args.buf):playse({storage=args.se}) end
    if args.exp then Controller:eval(args.exp) end
    if args.storage or args.target then Controller:jumpAction({storage=args.storage,target=args.target}) end
  end

  
  local s = res[args.graphic].size
  but:setSrc(args.graphic)
  but:setSize(s)
  but:setPosition(tonumber(args.left),tonumber(args.top))
  but._onclickargs={se=args.clickse,buf=args.clicksebuf,storage=args.storage,exp=args.exp,target=args.target} 
  but._onenterargs={se=args.enterse,buf=args.entersebuf,exp=args.onenter}
  but._onleaveargs={se=args.leavese,buf=args.leavesebuf,exp=args.onleave}
  but:bind('click',function(self) self:_onclick(self._onclickargs) end)
  but:bind('mouseover',function(self) self:_onclick(self._onenterargs) end)
  but:bind('mouseout',function(self) self:_onclick(self._onleaveargs) end)  
  if args.recthit then print("sorry no args.recthit") end
  if args.hint then print("sorry no args.hint") end
  if args.graphickey then print("sorry no args.graphickey") end
  if args.countpage then print("sorry ignore args.countpage") end
  

  return but
end

function KAGCheckbox(args)
  local color
  local bgcolor
  if args.color then color=args.color:getColor() else color=tostring("0xFF0000"):getColor() end
  if args.bgcolor then bgcolor=args.bgcolor:getColor() else bgcolor=tostring("0xFFFFFF"):getColor() end
  local ck = UI.Button({View={width=args.size,height=args.size,r=bgcolor.red,g=bgcolor.green,b=bgcolor.blue,a=tonumber(args.opacity)/255 or 0.5}})
  ck:load_layout({enable=true,selectable=true,
  textstyle={text=""},
  selectedtextstyle={text="✓",fontSize=args.size, textAlign="center", textBaseline="middle",
  textFillColor={r=color.red,g=color.green,b=color.blue,a=1}
    ,xOffset=args.size/2,yOffset=args.size/2
  }
  })
  if args.name then
    ck.flag = args.name
    ck:onSelect(function()
      Controller:eval(self.flag.."= true")
    end)
    ck:onDeselect(function()
      Controller:eval(self.flag.."= false")
    end)
  end
  return ck
end

function KAGMSGLayer()
  local kml = KAGLayer()
  
  kml.lineglyph=UI.ImageView()
  kml.pageglyph=UI.ImageView()

  kml._kml = {
    x=0,
    y=0,
    edits = {}
  }

  function kml:_position(args)
    local s = self:size()
    local p = self:position()
    self.fore:freetext()
    self.back:freetext()
    self.both:freetext()
    if args.top or args.left then self:setPosition(tonumber(args.left) or p.left,tonumber(args.top) or p.top) end
    
    if args.width or args.height then
      self:setSize(tonumber(args.width) or s.width,tonumber(args.height) or s.height)
    end
    if args.frame then
      self:image({storage=args.frame,page=args.page})
    end

    if args.visible then
      self:setAlpha(toboolean(args.visible) and 1 or 0)
    end

    local color 
    if args.color then color = args.color:getColor() end
    self:setBackgroundColor({a=MessageLayer_config.frameOpacity/255,r=color.red or 0,g=color.green or 0,b=color.blue or 0})

    if args.opacity then self:setAlpha(tonumber(args.opacity)/255) end
    self.margint=tonumber(args.margint) or MessageLayer_config.marginT
    self.marginl=tonumber(args.marginl) or MessageLayer_config.marginL
    self.marginr=tonumber(args.marginb) or MessageLayer_config.marginR
    self.marginb=tonumber(args.marginb) or MessageLayer_config.marginB
    self._kml.y=self.margint
    self._kml.x=self.marginl
    self:_gcurrentp(args.page)
  end
  
  function kml:indent()
    if self._kml.x then
      self._tmpx=tonumber(self._kml.x)
      if self.fontStyle then
        self._kml.x=self._kml.x+self.fontStyle.size*2
      end
    end
  end

  function kml:endindent()
    if self._tmpx then
      self._kml.x=tonumber(self._tmpx)
      self._tmpx=nil
    end    
  end  

  function kml:timeout(args)
    self._timeout=table.clone(args)
    app:setTimeout(function(self)
      self:_dotimeout()
    end,tonumber(args.time))
  end
  function kml:ctimeout(args)
    if self._timeout then self._timeout=nil end
  end
  function kml:_dotimeout()
    local args = self._dotimeout
    if args then
      Controller:_getbuf(args.sebuf):playse({storage=args.se,buf=args.sebuf})
      Controller:jumpAction({target=args.target,storage=args.storage})
    end
  end

  function kml:style(args)
    local mlc = MessageLayer_config
    if not self._style then self._style={} end
    self._style = {
      align=args.align or self._style.align or "left",
      linespacing=tonumber(args.linespacing) or self._style.linespacing or mlc.defaultLineSpacing,
      linesize=tonumber(args.linesize) or self._style.linesize or nil,
      autoreturn=toboolean(args.autoreturn) or self._style.autoreturn or mlc.defaultAutoReturn
    } 
    if args.pitch then print("sorry no pitch") end
  end
  function kml:resetstyle(args)
    self._style=nil
    self:style({})
  end
  function kml:ct(args)
    self:er()
    self:resetfont()
    self:resetstyle()
  end
  function kml:font(args)
    local mlc = MessageLayer_config
    if not self.fontStyle then self.fontStyle={} end
    self.fontStyle = {
      size=tonumber(args.size) or self.fontStyle.size or mlc.defaultFontSize,
      face=args.face or self.fontStyle.face or mlc.userFace,
      color=args.color or self.fontStyle.color or mlc.defaultChColor,
      rubysize=tonumber(args.rubysize) or self.fontStyle.rubysize or mlc.defaultRubySize,
      rubyoffset=tonumber(args.rubyoffset) or self.fontStyle.rubyoffset or mlc.defaultRubyOffset,
      shadow=toboolean(args.shadow) or self.fontStyle.shadow or mlc.defaultShadow,
      edge=toboolean(args.edge) or self.fontStyle.edge or mlc.defaultEdge,
      edgecolor=args.edgecolor or self.fontStyle.edgecolor or mlc.defaultEdgeColor,
      shadowcolor=args.shadowcolor or self.fontStyle.shadowcolor or mlc.defaultShadowColor,
      bold=toboolean(args.bold) or self.fontStyle.bold or mlc.defaultBold
                }
  end
  function kml:resetfont()
    self.fontStyle=nil
    self:font({})
  end

  function kml:_drawLineGY()
    local gy = self.lineglyph
    if self.fix then
      gy:setPosition(self.fix_left, self.fix_top)
    else
      local s = gy:size()
      gy:setPosition( self._kml.x,  self._kml.y + self._style.linespacing - s.height)
    end
    self.fore:appendView(gy)
  end

  function kml:_drawPageGY()
    local gy = self.pageglyph
    if self.fix then
      gy:setPosition(self.fix_left, self.fix_top)
    else
      local s = gy:size()
      gy:setPosition( self._kml.x,  self._kml.y + self._style.linespacing - s.height)
    end
    self.fore:appendView(gy)
  end

  function kml:_clearGY()
    if self.pageglyph:superview() then  self.pageglyph:superview():removeView(self.pageglyph) end
    if self.lineglyph:superview() then  self.lineglyph:superview():removeView(self.lineglyph) end
  end

  function kml:glyph(args)
    if args.line then
      self.lineglyph:setSize(res[args.line].size)
      self.lineglyph:setSrc(args.line or MessageLayer_config.lineBreakGlyph)
    end
    if args.page then
      self.pageglyph:setSize(res[args.page].size)
      self.pageglyph:setSrc(args.page or MessageLayer_config.pageBreakGlyph)
    end

    if args.top then
      self.fix_top = tonumber(args.top)
    end
    if args.left then
      self.fix_left = tonumber(args.left)
    end
    if args.fix~=nil then
      self.fix=toboolean(args.fix)
    end
  end

  function kml:_doclick()
    local args = self._doclickargs
    local se = kag.buf[args.sebuf]
    se=KAGBuf()
    se:playse({storage=args.se})
    Controller:eval(args.exp)
    if args.storage or args.target then Controller:jumpAction({storage=args.storage,target=args.target}) end
  end

  function kml:click(args)
    if not self._doclickargs then
      self:bind('click',self._doclick)
    end
    self._doclickargs=table.clone(args)
  end
  function kml:cclick(args)
    if self._doclickargs then
      self._doclickargs=nil 
      self:unbind('click',self._doclick)
    end
  end

  function kml:graph(args)
    local graph = self._kml.link and KAGButton(self._kml.link) or UI.ImageView()
    if self._kml.link then graph.locklink=self._kml end
    local s = res[args.storage].size
    graph:setSize(s)
    graph:setImage(args.storage)
    graph:setPosition(self._kml.x,self._kml.y)
    self.fore:appendView(graph)
  end

  function kml:wheel(args)
    print("sorry no wheel")
  end
  function kml:cwheel(args)
    print("sorry no cwheel")
  end

  function kml:l(args)
    self:_drawLineGY()
  end
  function kml:p(args)
    self:_drawPageGY()
  end

  function kml:ch(args)
    self:_clearGY()
    if not self.fontStyle then self:resetfont() end
    if not self._style then self:resetstyle() end
    
    --過長文字判斷
    local too_long = false
    local v     
    if self._kml.x + w > self:size().width and self._style.autoreturn==true then
      local tmp = self._kml.x
      local count = 0
      while true do
        tmp = tmp + self.fontStyle.size
        if tmp > self:size().width then break else count=count+1 end
      end        
      v=args.text:utf8sub(count+1,args.text:countUTF8Words())
      w = self.fontStyle.size*(count+1)
      args.text=args.text:utf8sub(1,count)
      too_long=true
    end

    local ch_message=self._kml.link and KAGButton(self._kml.link) or UI.LabelView()
    if self._kml.link then ch_message.locklink=self._kml end

    if toboolean(self.fontStyle.edge) then
      local e_color = self.fontStyle.edgecolor:getColor()
      ch_message:setTextStyle({textStrokeWidth=2,textStrokeColor={a=1,r=e_color.red,g=e_color.green,b=e_color.blue}})
    end

    if toboolean(self.fontStyle.shadow) then
      print("sorry no shadow")
      if self.fontStyle.shadowcolor then print("sorry no shadowcolor") end
    end

    if self.fontStyle.face then
      ch_message:setFont(self.fontStyle.face)
    end

    local w = args.text:countUTF8Words()*self.fontStyle.size
    local h = self._style.linesize or (self.fontStyle.size+self.fontStyle.rubysize)
    local color = self.fontStyle.color:getColor()
    ch_message:setSize(w,h)
    ch_message:setPosition(self._kml.x,self._kml.y)
    ch_message:setTextStyle({textFillColor={a=1,r=color.red,g=color.green,b=color.blue},
      fontsize=self.fontStyle.size,
      yOffset = h,
      textAlign="left",
      textBaseline="bottom"‎,
      xOffset=0,
      text=args.text,
      textSpeed=self:_getchspeed()
      })
    ch_message:bind('click',{self,dolink})

    --紀錄最左位置
    self._kml.x=self._kml.x+w
    
    if HistoryLayer_config.storeState then sys.log=tostring(args.text..sys.log) end

    if too_long then
      self:r()
      self:ch({text=v})
    end

    local page=self:_gcurrentp()    
    page:appendView(ch_message)
  end

  --ruby 未完成
  function kml:ruby(args)
    self:_clearGY()
    if not self.fontStyle then self:resetfont() end
    if not self._style then self:resetstyle() end

    if self.fontStyle.rubysize then

      local rubywidth = self.fontStyle.rubysize*args.text:countUTF8Words()
      local rubyheight = self.fontStyle.rubysize*1.4 + self.fontStyle.rubyoffset
      local rubyLeft = self._kml.x
      local color = self.fontStyle.color:getColor()
      
      local ruby=UI.LabelView()
      if self.fontStyle.face then ruby:setTextStyle({font=self.fontStyle.face}) end
      ruby:setSize()
      ruby:setTextStyle({text=args.text,
        textFillColor={a=1,r=color.red,g=color.green,b=color.blue},
        textBaseline="top",
        textAlign="left"
        fontsize=self.fontStyle.rubysize,
        yOffset=rubyheight,
        xOffset=rubywidth,
        textSpeed=self._getchspeed()
        })

      local page = self._targetpage
      if self[page or "fore"]:superview() then self[page or "fore"]:appendView(ruby) end
    end
  end
  function kml:r()
    if not self._tmpx then
      self._kml.x=self.marginl
    else
      self._kml.x=self._tmpx
    end
    self._kml.y=self._kml.y+(self._style.linesize or self.fontStyle.size+self.fontStyle.rubysize)+self._style.linespacing
  end
  function kml:er()
    self.fore:freetext()
    self.back:freetext()
    self._kml.x=self.marginl
    self._kml.y=self.margint
  end
  function kml:cm()
    self:er()
    self:resetfont({})
    self:resetstyle({})
  end

  function kml:button(args)
    args.left=self._kml.x
    args.top=self._kml.y
    local but = KAGButton(args)
    self:appendView(but)
  end

  function kml:checkbox(args)
    local checkbox = KAGCheckbox(args)
    checkbox:setPosition(self._kml.x,self._kml.y)
    self:appendView(checkbox)
  end

  function kml:link(args)
    if self._kml.link then error("[link][link]")end
    self._kml.link = args
  end
  function kml:endlink(args)    
    self._kml.link = nil 
  end
  function kml:locklink(args)
    self._kml.locklink = true
  end

  function kml:unlocklink(args)
    self._kml.locklink = false
  end

  function kml:edit(args)
    print("sorry no edit")
  end
  
  function kml:commit(args)
  end

  function kml:locate(args)
    self._kml.x=tonumber(args.x)+self._kml.x
    self._kml.y=tonumber(args.y)+self._kml.y
  end

  function kml:_gcurrentp(page)
    if not page then kag.currentpage=page or "fore" end
    kag.currentpage=page
    return kag.withback and kag.currentpage=="fore" and self.both or self[kag.currentpage or "fore"]
  end

  function kml:_getchspeed()    
    if kag.delay=="nowait" then
      return 0
    elseif kag.delay=="user" then
      return KAGWindow_config.chSpeeds[kag.chspeed]
    else
      return tonumber(kag.delay)
    end
  end

end

function KAGSlot()
  --local current_page
  --local current_storage
  local VideoSlot = UI.VideoView()
  VideoSlot:onFinish(function(self) self:_destroy() end)

  function VideoSlot:openvideo(args)
    local size = res[args.storage].size
    self:setSize(size)
    self:setSrc(args.storage)
  end

  function VideoSlot:preparevideo(args)
    --
    print("function scanThis did it")
  end

  function VideoSlot:resumevideo()
    self:play()
  end

  function VideoSlot:rewindvideo()
    if self.rewind then self:rewind() end
  end

  function VideoSlot:stopvideo(args)
    self:stop()
  end

  function VideoSlot:videoevent(args)
    if args.frame then print("sorry no video.frame") end
  end

  function VideoSlot:videolayer(args)
    if args.channel then print("sorry no video.channel") end
    if kag[args.page or "fore"][args.layer] then
      kag[args.page or "fore"][args.layer]:appendView(self) 
    else 
      kag[args.page or "fore"][args.layer]=KAGLayer() 
    end
  end

  function VideoSlot:clearvideolayer()
    if self:superview() then self:superview():removeView(self) end
  end

  function VideoSlot:videosegloop(args)
    print("sorry no video.segment")
  end

  function VideoSlot:cancelvideoevent()
    print("sorry no videoevent, then no cancelvideoevent")
  end

  function VideoSlot:playvideo(args)
    self:openvideo(args.storage)
    self:play()
  end

  function VideoSlot:video(args)
    if args.visible~=nil then self:setAlpha(toboolean(args.visible) and 1 or 0) end
    if args.mode then self.mode=args.mode end

    if args.left or args.top and self.mode=="layer" and self:superview() then
      self:superview():setPosition({top=tonumber(args.top),left=tonumber(args.left)})
    end

    if args.position then self:seek(tonumber(args.position)) end
    if args.volume then self:setVolume(tonumber(args.volume)) end
    if args.loop then self:setLoop(toboolean(args.loop)) end
    if args.height and args.width then
      self:setSize(tonumber(args.width),tonumber(args.height))
      if self.mode=="layer" and self:superview() then
        self:superview():setSize(tonumber(args.width),tonumber(args.height))
      elseif self.mode=="overlay" and self:superview() then
        local ss = self:superview():size()
        local s = self:size()

        self:setPosition((ss.width-s.width)/2,(ss.height-s.height)/2)
      end
    end
    if args.playrate then print("sorry no video.playrate") end
    if args.pan then print("sorry no video.pan") end
    if args.audiostreamnum then print("sorry no video.audiostreamnum") end
    if args.frame then print("sorry no video.frame") end
  end

  function VideoSlot:pausevideo()
    self:pause()
  end

  function VideoSlot:_destroy()
    self:stop()
    if Controller.needwait==true then
      Controller.needwait=false
      Controller:enter()
    end
  end

  return VideoSlot
end

function toboolean(v)
  return (type(v) == "string" and v == "true") or (type(v) == "number" and v ~= 0) or (type(v) == "boolean" and v)
end

function string:getColor()
  if #self==8 then
    local red = self:sub(3,4)
    local green = self:sub(5,6)
    local blue = self:sub(7,8)
    local color = {}
    color.red=tonumber(red,16)/255
    color.green=tonumber(green,16)/255
    color.blue=tonumber(blue,16)/255
    return color
  else
    return nil
  end
end

function string:countUTF8Words()
  local count = 0
  if not (type( self) == "string") then
    return 0
  end

  for x in self:gmatch("([%z\1-\127\194-\244][\128-\191]*)") do
    count = count + 1
  end
  return count 
end

function string:utf8sub(startChar, numChars)
  local chsize = function(char)
    if not char then
        return 0
    elseif char > 240 then
        return 4
    elseif char > 225 then
        return 3
    elseif char > 192 then
        return 2
    else
        return 1
    end
  end

  local startIndex = 1
  while startChar > 1 do
    local char = string.byte(self, startIndex)
    startIndex = startIndex + chsize(char)
    startChar = startChar - 1
  end
 
  local currentIndex = startIndex
 
  while numChars > 0 and currentIndex <= #self do
    local char = string.byte(self, currentIndex)
    currentIndex = currentIndex + chsize(char)
    numChars = numChars -1
  end
  return self:sub(startIndex, currentIndex - 1)
end

---------------------------------


script = [[
[history output=true enabled=true]
@image storage=aaa layer=1 opacity=255 opacity=100
[p]
@trans method=universal vague=0 time=1000 layer=1 rule=aaa
[p]
@layopt layer=1 opacity=255
@trans method=crossfade time=1000 layer=1
[p]
[showhistory]
[s]
@freeimage layer=1
@videolayer channel=1 layer=1
@playvideo storage=test
[wv canskip=true]
@clearvideolayer channel=1 layer=1
[p]
[close]
@playbgm storage=ch
[close]
]]


local delaytime = 0
local tmp_delay = 0

local message_delay = 0
local tmp_message_delay = 1

local orign_waittime = 0


local if_exp = nil
local hact_exp = nil

local check_if = false
local check_hact = false
local check_ignore = false

local ifTjs = false
local hactTjs = false
local ignoreTjs = false

--Controller setting--

--書籤相關
Controller.canMakeSnapShot=true
Controller.canRestoreSnapShot=true

--trigger 設定
Controller.triggerSet = {}

--BGM控制
Controller.bgmVolume=1

--goback 機能
Controller.startanchor=true

--hact用
Controller.hactTable = {}

--if用
Controller.ifTable = {}

--ignore用
Controller.ignoreTable = {}

----------------------
------------
local handlers
handlers = {
  indent=function(args)
    Controller:_getlayer("message"):indent()
  end,

  endindent = function(args)
    Controller:_getlayer("message"):endindent()
  end,

  p=function(args)
    if kag.skipMode then return Controller.needwait=true end
    if kag.autoMode then return Controller:_doAutoWait( KAGWindow_config.autoModePageWaits[kag.pagewait], true ) end
    kag.message[kag.current]:p(args)
    Controller:_waitClick()
  end,

  l=function(args)
    if kag.skipMode then return Controller.needwait=true end
    if kag.autoMode then return Controller:_doAutoWait( KAGWindow_config.autoModeLineWaits[kag.linewait], true ) end
    kag.message[kag.current]:l(args)
    Controller:_waitClick()
  end,

  locklink = function(args)
    for k,v in pairs(kag.message) do
      v:locklink()
    end
  end,

  ctimeout = function(args)
    Controller:_getlayer("message"):ctimeout()
  end,

  unlocklink = function(args)
    for k,v in pairs(kag.message) do
      v:unlocklink()
    end
  end,

  wait = function(args)
    args.time=tonumber(args.time)
    if args.mode=="until" then
      local time = args.time-Metaneta.Time.time()+(kag.lastWaitTime or 0)
      kag.lastWaitTime=time
      Controller:_dowait(time,toboolean(args.canskip))
    else
      Controller:_dowait(args.time,toboolean(args.canskip))
    end
    Controller.needwait=true
  end,

  jump = function(args)
    Controller:jumpAction(args)
  end,

  resetfont = function(args)
    Controller:_getlayer("message"):resetfont()
  end,

  resetstyle = function(args)
    Controller:_getlayer("message"):resetstyle()
  end,

  defstyle = function(args)
    local mlc = MessageLayer_config
    mlc.linespacing=tonumber(args.linespacing) or mlc.linespacing
    mlc.defaultPitch=tonumber(args.pitch) or mlc.defaultPitch
    mlc.linesize=tonumber(args.linesize) or mlc.linesize
  end,

  emb = function(args)
    handlers.ch({text = Controller:eval(args.exp)})
  end,
  
  eval = function(args)
    Controller:eval(args.exp)
  end,

  layopt = function(args)
    Controller:_getlayer(args.layer):layopt(args)
  end,

  r = function(args) 
    Controller:_getlayer("message"):r()
  end,

  image = function(args) 
    Controller:_getlayer(args.layer):image(args)
    root:appendView(Controller:_getlayer(args.layer))
  end,

  --return時實作
  call = function(args)
    if args.storage~=nil and args.target~=nil then
      Controller.prefab = KAGParser(args.storage)
      local t = Controller.prefab
      local pos
      if args.target~=nil then
        pos = t:jumpTo(args.target)
        t:setPos(pos)
        Controller.callPos=pos
      else
        t:setPos(1)
        Controller.callPos=pos
      end 

      if args.countpage then print("sorry no args.countpage") end 
    end
  end,

  loadplugin = function(args)
    print("sorry no loadplugin")
  end,

  iscript = function(args)
    --
    print("damn your iscript")
  end,

  style = function(args)
    Controller:_getlayer("message"):style(args)
  end,

  current = function(args)
    kag.current=args.current or kag.current
    kag.currentpage = args.page or kag.currentpage
    kag.withback = toboolean(args.withback) or kag.withback
  end,

  locate = function(args)
    --change current locate
    Controller:_getlayer("message"):locate(args)
  end,

  history = function(args)
    HistoryLayer_config.storeState = toboolean(args.output)
    Controller.enableHistory=toboolean(args.enabled)
  end,

  hact = function(args)
    if Controller:eval(args.exp) then hactTjs=true end
    check_hact=true 
  end,

  endhact = function(args)
    check_hact=false
    Controller:process(Controller.hactTable)
    hactTjs=nil
    Controller.hactTable=nil
  end,

  delay = function(args)
    kag.delay=args.speed or kag.delay
  end,

  move = function(args)
    Controller:_getlayer(args.layer):move(args)
  end,

  timeout = function(args)
    if Controller:eval(args.exp) then Controller:_getlayer("message"):timeout(args) end
  end,

  title = function(args)
    --API 未實裝
    print("sorry title is fafasoso")
  end,

  deffont = function(args)
  --設定"預設"字型
    local mlc = MessageLayer_config
    mlc.defaultFontSize=tonumber(args.size) or mlc.defaultFontSize
    mlc.userFace=args.face or mlc.userFace
    mlc.defaultChColor=args.color or mlc.defaultChColor
    mlc.defaultRubySize=tonumber(args.rubysize) or mlc.defaultRubySize
    mlc.defaultRubyOffset=tonumber(args.rubyoffset) or mlc.defaultRubyOffset
    mlc.defaultShadow=toboolean(args.shadow) or mlc.defaultShadow
    mlc.defaultEdge=toboolean(args.defaultEdge) or mlc.defaultEdge
    mlc.defaultEdgeColor=args.edgecolor or mlc.defaultEdgeColor
    mlc.defaultShadowColor =args.shadowcolor or mlc.defaultShadowColor
    mlc.defaultBold=toboolean(args.bold) or mlc.defaultBold

    if args.bold then print("sorry no args.bold") end
    if args.shadow then print("sorry no args.shadow") end
    if args.shadowcolor then print("sorry no args.shadowcolor") end
  end,

  img = function(args)
    Controller:_getlayer(args.layer):image(args)
    root:appendView(Controller:_getlayer(args.layer))
  end,

  clickskip = function(args)
    kag.clickskip=toboolean(args.enabled)
  end,

  nowait = function(args)
    kag.predelay=kag.delay
    kag.delay="nowait"
  end,

  endnowait = function(args)
    if not kag.predelay then return end
    kag.delay=kag.predelay
    kag.predelay=nil
  end,

  autowc = function(args)
    print("due to internet problem, we hate autowc")
  end,

  clearsysvar = function(args)
    app.data.sf={}
  end,

  close = function(args)
    if args.ask==nil or args.ask=="true" or args.ask==true then
      Controller.askTake="close"
      Controller:CallAskDialog()
    elseif args.ask=="false" or args.ask==false then
      app:releaseMedias(Controller.AllResource,function()
        app:stop()
      end)
    end
  end,

  cursor = function(args)
    --
    print("sorry no cursor")
  end,

  hidemessage = function(args)
    Controller:hidemessage()
  end,

  mappfont = function(args)
    print("sorry no mappfont")
  end,

  --???放置中(?)
  nextskip = function(args)

  end,

  quake = function(args)
    Controller.tmpArgs=args
    if args.timemode=="ms" or args.timemode==nil then
      Controller:_quakenow()
    else
      app:setTimeout(Controller._quakenow,tonumber(args.time))
    end
  end,

  rclick = function(args)
    Controller.rclickargs=table.clone(args)
    root:bind('rightclick',Controller._dorclick)
  end,

  click = function(args)
    Controller:_getlayer("message"):click(args)
  end,

  --有點意義不明...
  resetwait = function(args)
    local time = kag.lastWaitTime or 0
    Controller:_dowait(time,true)
  end,

  s = function(args)
    local blank_layer = UI.View()
    local stop_label = UI.LabelView()
    blank_layer:setSize(tonumber(root:size().width)-10,tonumber(root:size().height)-10)
    blank_layer:setPosition({top=(tonumber(blank_layer:size().height)/2-(tonumber(blank_layer:size().height)-10))/2,left=(tonumber(blank_layer:size().width)/2-(tonumber(blank_layer:size().width)-10))/2})
    blank_layer:setBackgroundColor({a=0.5,r=0,g=0,b=0})
    stop_label:setText("ゲームを一時中止します")
    stop_label:setFontSize(45)
    stop_label:setPosition({top=tonumber(blank_layer:size().height)/2-45*0.5,left=tonumber(blank_layer:size().widthblank_layer)/2-5.5*45})
    stop_label:setSize(12*45,45*1.4)
    stop_label:setTextStyle({textFillColor={a=1,r=1,g=1,b=1}})
    blank_layer:appendView(stop_label)
    root:appendView(blank_layer)
    root:bind('click',function() Controller:stopThis(blank_layer) end)
    Controller.needwait=true
  end,

  stopquake = function(args)
    root:flush()
  end,

  waitclick = function(args)
    handlers.p()
  end,

  wc = function(args)
    --指定文字數的等待時間
    --字數*等待時間
    app:setTimeout(function()
      Controller.needwait=false
      Controller.currentTextCount=0
      Controller:enter()
    end,tonumber(args.time)*Controller.currentTextCount)
    Controller.needwait=true
  end,

  checkbox = function(args)
    Controller:_getlayer("message"):checkbox(args)
  end,

  commit = function(args)
  end,

  edit = function(args)
    --
    print("sorry no edit")
  end,

  hr = function(args)
    sys.log=sys.log.."\n"
  end,

  link = function(args)
    for k,v in pairs(kag.message) do
      v:link(args)
    end
  end,

  animstart = function(args)
    --
    print("sorry no animstart")
  end,

  animstop = function(args)
    --
    print("sorry no animstop")
  end,

  copylay = function(args)
    Controller:_getlayer(args.layer):copylay(args)
  end,

  ct = function(args)
    root:removeView(kag.message[0])
  end,

  freeimage = function(args)
    Controller:_getlayer():freeimage()
  end,

  laycount = function(args)
    local messages,layers
    if args.messages then messages= tonumber(args.messages) end
    if args.layers then layers=tonumber(args.layers) end
    local count = 0
    if messages then
      for k,v in pairs(kag.messages) do
        count = count + 1
        if count> messages then root:removeView(v) end
      end
    end

    count=0
    if layers then
      for k,v in pairs(kag.layer) do
        count = count + 1
        if count> layers then root:removeView(v) end
      end
    end
  end,

  mapaction = function(args)
    --
    print("sorry no mapaction")
  end,

  mapdisable = function(args)
    --
    print("sorry no mapdisable")
  end,

  mapimage = function(args)
    --
    print("sorry no mapimage")
  end,

  pimage = function(args)
    Controller:_getlayer(args.layer):pimage(args)
  end,

  ptext = function(args)
    Controller:_getlayer(args.layer):ptext(args)
  end,

  stopmove = function(args)
    for k,v in pairs(kag.layer) do
      v:stopmove()
    end
    for k,v in pairs(kag.message) do
      v:stopmove()
    end
  end,

  stoptrans = function(args)
    for k,v in pairs(kag.layer) do
      v:stoptrans()
    end
    for k,v in pairs(kag.message) do
      v:stoptrans()
    end
  end,

  trans = function(args)
    Controller:_getlayer(args.layer):trans(args)
  end,

  wa = function(args)
    args.type="animation"
    Controller:waitEvent(args)
  end,

  wt = function(args)
    args.type="transition"
    Controller:waitEvent(args)
  end,

  bgmopt = function(args)
    if args.volume==nil then
      args.volume=100
    end
    if args.gvolume==nil then
      args.gvolume=100
    end
    Controller.bgmVolume=(tonumber(args.volume)/100)*(tonumber(args.gvolume)/100)
    Controller.bgmlayer:setVolume(Controller.bgmVolume)
  end,

  fadebgm = function(args)
    Controller.bgmlayer:fade(tonumber(args.volume)*kag.gvolume/10000,tonumber(args.time),Controller._kagfadeend)
  end,

  fadepausebgm = function(args)
    Controller.bgmlayer:fade(tonumber(args.volume)*kag.gvolume/10000,tonumber(args.time),function()
      Controller.bgmlayer:pause()
    end)
  end,

  fadese = function(args)
    Controller:_getbuf(args.buf):fadese(args)
  end,

  hch = function(args)
    --
    print("sorry no hch")
  end,

  fadeinbgm = function(args)
    Controller.bgmlayer:setSrc(args.storage)
    if args.start then Controller.bgmlayer:seek(tonumber(args.start)) end
    if args.loop~=nil then Controller.bgmlayer:setLoop(toboolean(args.loop)) end
    Controller.bgmlayer:fade({time=tonumber(args.time),volume=100})
    Controller.bgmlayer:play()
  end,

  playbgm = function(args)
    Controller.bgmArgs=args
    Controller.destroybgm=false
    Controller:playCurrentBGM()
  end,

  fadeinse = function(args)
    Controller:_getbuf(args.buf):fadeinse(args)
  end,

  fadeoutbgm = function(args)
    Controller.bgmlayer:fade({time=tonumber(args.time),volume=0})
  end,

  fadeoutse = function(args)
    Controller:_getbuf(args.buf):fadeoutse(args)
  end,

  resumebgm = function(args)
    local bgm = Controller.bgmlayer
    Controller.destroybgm=false
    bgm:setVolume(Controller.bgmVolume or 1)
    bgm:play()
  end,

  playse = function(args)
    Controller:_getbuf(args.buf):playse(args)
  end,

  seopt = function(args)
    Controller:_getbuf(args.buf):seopt(args)
  end,

  pausebgm = function(args)
    local bgm = Controller.bgmlayer
    bgm:pause()
  end,

  stopbgm = function(args)
    local bgm = Controller.bgmlayer
    Controller.destroybgm=true
    bgm:stop()
  end,

  clearbgmstop = function(args)
    handlers.resumebgm()
  end,

  stopse = function(args)
    Controller:_getbuf(args.buf):stopse()
  end,

  cclick = function(args)
    Controller:_getlayer("message"):cclick()
  end,

  ---------VIDEO事件
  --Video再生準備開始--
  openvideo = function(args)
    Controller:_getslot(args.slot):openvideo(args)
  end,

  preparevideo = function(args)
    --
    print("function scanThis did it")
  end,

  --撥放影片
  playvideo = function(args)
    Controller:_getslot(args.buf):playvideo(args)
  end,

  cancelvideoevent = function(args)
    Controller:_getslot(args.slot):cancelvideoevent()
  end,

  cancelvideosegloop = function(args)
    --
    print("sorry no cancelvideosegloop")
  end,

  clearvideolayer = function(args)
    Controller:_getslot(args.slot):clearvideolayer()
  end,

  resumevideo = function(args)
    Controller:_getslot(args.slot):resumevideo()
  end,

  rewindvideo = function(args)
    --
    print("sorry no rewindvideo")
  end,

  stopvideo = function(args)
    Controller:_getslot(args.slot):stopvideo()
  end,

  video = function(args)
    Controller:_getslot(args.slot):video(args)
  end,

  videoevent = function(args)
    --
    print("sorry no frame no videoevent")
  end,

  pausevideo = function(args)
    Controller:_getslot(args.slot):pausevideo()
  end,

  videolayer = function(args)
    Controller:_getslot(args.slot):videolayer(args)
  end,

  videosegloop = function(args)
    print("sorry no videosegloop")
  end,

  ----------------------

  wb = function(args)
    args.type="fadebgm"
    Controller:waitEvent(args)
  end,

  wf = function(args)
    args.type="fadese"
    Controller:waitEvent(args)
  end,

  wl = function(args)
    args.type="bgm"
    Controller:waitEvent(args)
  end,

  wp = function(args)
    --scan已經掃進去了，以及自動釋放
    --基本上不實作
    print("function scanThis did it,so wp won't work")
  end,
  
  ws = function(args)
    args.type="se"
    Controller:waitEvent(args)
  end,

  wv = function(args)
    args.type="video"
    Controller:waitEvent(args)
  end,

  wm = function(args)
    args.type="move"
    Controller:waitEvent(args)
  end,

  wq = function(args)
    args.type="quake"
    Controller:waitEvent(args)
  end,

  xchgbgm = function(args)
    if args.loop==nil then args.loop=true end
    local bgm = Controller.bgmlayer
    if args.overlap then print("sorry no args.overlap") end
    app:releaseMedias({Controller.bgmlayer:name():sub(4)})
    Controller.destroybgm=false
    Controller.bgmArgs=args
    bgm:fade(0,tonumber(args.time),Controller.playCurrentBGM)
  end,

  clearbgmlabel = function(args)
    --
    print("sorry no clearbgmlabel")
  end,

  clearvar = function(args)
    app.data.sf={}
    app.session.f={}
  end,

  endif = function(args)
    check_if=false
    Controller:process(Controller.ifTable)
    ifTjs=nil
    Controller.ifTable=nil
  end,

  ignore = function(args)
    if Controller:eval(args.exp) then ignoreTjs = true end
    check_ignore=true
  end,

  endignore = function(args)
    check_ignore=false
    Controller:process(Controller.ignoreTable)
    ignoreTjs=nil
    Controller.ignoreTable=nil
  end,

  input = function(args)
    --
    print("sorry no input")
  end,

  trace = function(args)
    --
    print("sorry no trace")
  end,

  waittrig = function(args)
    --can i eat it?
  end,

  copybookmark = function(args)
    --
    print("sorry no copybookmark")
  end,

  cancelautomode = function(args)
    kag.autoMode=true
  end,

  cancelskip = function(args)
    kag.skipMode=0
  end,

  showhistory = function(args)
    if Controller.enableHistory then
      Controller:showhistory()
    elseif not Controller.enableHistory then
      if root:getSubviewByName("history")~=nil then root:removeView(Controller.history) end
    end
  end,

  disablestore = function(args)
    if args.store==nil then args.store=false end
    if args.store==true then args.store=false end
    if args.store==false then args.store=true end
    if args.restore==nil then args.restore=false end
    Controller.canMakeSnapShot=args.store
    Controller.canRestoreSnapShot=args.restore
  end,

  erasebookmark = function(args)
    --
    print("sorry no erasebookmark")
  end,

  goback = function(args)
    --跟call對應
    if Controller.prefab~=nil then
      if args.ask==nil or args.ask==true or args.ask=="true" then
        Controller.askTake="goback"
        Controller:CallAskDialog()

      elseif args.ask==false or args.ask=="false" then
        Controller:release()
        parser=Controller.prefab
        parser:setPos(tonumber(Controller.callPos))
        Controller.macros=parser:getMacros()
        Controller:enter()

      end
    end
  end,

  gotostart = function(args)
    if Controller.startanchor==true or Controller.startanchor=="true" then
      if args.ask==nil or args.ask=="false" or args.ask==false then
        Controller:clear()
        local tmp = {}
        tmp.storage=Controller.startanchorInfo[1]
        tmp.target=Controller.startanchorInfo[2]
        Controller:jumpAction(tmp)

      elseif args.ask==true or args.ask=="true" then
        Controller.askTake="gotostart"
        Controller:CallAskDialog()
      end
    end
  end,

  load = function(args)
    --詢問視窗待完成
    if Controller.canRestoreSnapShot==true or Controller.canRestoreSnapShot=="true" then
      if args.place==nil then args.place=0 end
      if args.ask==nil or args.ask=="false" or args.ask==false then 
        Controller:load(args)
      elseif args.ask=="true" or args.ask==true then
        Controller.askTake="load"
        Controller.bookemarkPosition=args.place
        Controller:CallAskDialog()
      end
    end
  end,

  locksnapshot = function(args)
    Controller.canMakeSnapShot=false
  end,

  record = function(args)
    app:makeSnapshot("checkpoint")
  end,

  save = function(args)
    if Controller.canMakeSnapShot==true or Controller.canMakeSnapShot=="true" then 
      if args.place==nil then args.place=0 end
      if args.ask==nil or args.ask==false or args.ask=="false" then
        Controller:save(args)
      elseif args.ask=="true" or args.ask==true then
        Controller.askTake="save"
        Controller.bookemarkPosition=args.place
        Controller:CallAskDialog()
      end
    end
  end,

  startanchor = function(args)
    if args.enabled==nil then args.enabled=true end
    Controller.startanchor=args.enabled
    if Controller.startanchor==true or Controller.startanchor=="true" then
      Controller.startanchorInfo={}
      Controller.startanchorInfo[1]=filename_t
      Controller.startanchorInfo[2]=tonumber(parser:cur()+1)
    end
  end,

  store = function(args)
    Controller.canMakeSnapShot=args.enabled
  end,

  --未實裝完成
  tempload = function(args)
    if Controller.canRestoreSnapShot==true or Controller.canRestoreSnapShot=="true" then
      local num = args.place
      if num==nil then num=0 end
      if args.bgm==nil then args.bum=true end
      if args.se==nil then args.se=true end
      app:restoreSnapshot(tostring("tmpsave"..num))
      --args.backlay
    end
  end,

  backlay = function(args)
    Controller:_getlayer(args.layer):backlay()
  end,

  tempsave = function(args)
    if Controller.canMakeSnapShot==true or Controller.canMakeSnapShot=="true" then
      local num = args.place
      if num==nil then num=0 end
      app:makeSnapshot(tostring("tmpsave"..num))
    end
  end,

  unlocksnapshot = function(args)
    Controller.canMakeSnapShot=true
  end,

  jumpTarget = function(args)
    --do nothing...
  end,

  wheel = function(args)
    --
    print("sorry no wheel")
  end,

  cwheel = function(args)
    --
    print("sorry no cwheel")
  end,

  ch = function(args)
    Controller:_getlayer("message"):ch(args)
  end,
  
  position = function(args)
    Controller:_getlayer(args.layer):_position(args)
    root:appendView(Controller:_getlayer(args.layer))
  end,

  ruby = function(args)
    Controller:_getlayer("message"):ruby(args)
  end,

  cm = function(args)
    Controller:_getlayer("message"):cm()
  end,

  er = function(args)
    Controller:_getlayer("message"):er()
  end,

  glyph = function(args)
    Controller:_getlayer("message"):glyph(args)
  end,

  setbgmstop = function(args)
    -- 在主要迴圈實作
    Controller.setbgmstopargs=args
    Controller.setbgmstop=true
  end,

  graph = function(args)
    Controller:_getlayer("message"):graph(args)
  end
}
handlers["if"]=function(args)
  if Controller:eval(args.exp) then
    ifTjs=true
  else
    ifTjs=false
  end
  check_if=true
end

handlers["else"] = function(args)
  if ifTjs==false then
    Controller.ifTable={}
    ifTjs=true
  end
end

handlers["return"] = function(args)
  if Controller.prefab~=nil then
    parser = Controller.prefab
    parser:setPos(tonumber(Controller.callPos))
    Controller.macros=parser:getMacros()
    Controller:release()
    Controller:enter()
  elseif args.storage or args.target~=nil then
    handlers.call(args)
    Controller:enter()
  end
end
--------------------------------------
--Controller.handlers["macro"] = function(job)
--  Controller.macros[job.name] = job
--end

local index = {}

function Controller:handleCustomMacro(input , params)
  local jobs = input.content
  local g_para = params or input

  while Controller:_handleCustomMacro2(jobs , params) do end
end

function Controller:_handleCustomMacro2(jobs , params)
  job = jobs[index[jobs]]
  --for i,job in ipairs(jobs) do

    job = table.clone(job)
    for k,v in pairs(job) do
      if type(v) == "string" and string.byte(v,1) == string.byte("%",1) then
        job[k] = g_para[ string.sub(v, 2, #v) ]
      end
    end

    local handler = Controller.handlers[job.tag]
    if handler == nil then
      local custom_macro = Controller.macros[job.tag]
      --local custom_macro = macros[job.tag]
      if custom_macro then
        local new_para = {}
        for k,v in pairs(g_para) do new_para[k] = v end
        for k,v in pairs(job) do new_para[k] = v end
        new_para.tag = nil
        return Controller.handleCustomMacro(custom_macro, new_para)
        --handleCustomMacro(custom_macro)
      else
        error("Unknown Tag:"..job.tag)
      end
    else
      return handler(job)
    end
  --end
end
--------------------------------------

--moveSquential 壞了...
function Controller:_quakenow()
  local args = Controller.tmpArgs
  table.extract(args)
  if args.vmax or args.hmax then 
    root:moveSequential({
      {top=tonumber(args.vmax or 0),left=tonumber(args.hmax or 0)} , 
      {top=-tonumber(args.vmax or 0),left=-tonumber(args.hmax or 0)},
      {top=tonumber(args.vmax or 0),left=tonumber(args.hmax or 0)} , 
      {top=-tonumber(args.vmax or 0),left=-tonumber(args.hmax or 0)},
      {top=tonumber(args.vmax or 0),left=tonumber(args.hmax or 0)} , 
      {top=-tonumber(args.vmax or 0),left=-tonumber(args.hmax or 0)},
      {top=0, left =0}},
      tonumber(args.time or 300)*kag.delay,Controller.onFinishAction) 
  end
end

--[[
--移動畫面
function Controller:moveTarget(args)
  local target = Controller.movingLayer
  local pathX = Controller:getPath(args.path,"x")
  local pathY = Controller:getPath(args.path,"y")
  local opacity = Controller:getPath(args.path,"opacity")
  if args.delay==nil then args.delay=0 end
  Controller.moveArgs={time=args.time,pathX=pathX,pathY=pathY,opacity=opacity}
  app:setTimeout(Controller.moveAction,tonumber(args.delay))
end

--移動實作
function Controller:moveAction()
  local args = Controller.moveArgs
  for i=1,#args.pathX do
    args.opacity[i]=tonumber(args.opacity[i])
    if args.opacity[i]>255 then args.opacity[i]=255 end
    args.opacity[i]=args.opacity[i]/255 
    Controller.movingLayer:moveTo({top=tonumber(args.pathX[i])*sys.fix,left=tonumber(args.pathY[i])*sys.fix},tonumber(args.time)/#args.pathX)
    Controller.movingLayer:animation("alpha","fade", tonumber(args.time)/#args.pathX , tonumber(args.opacity[i]))
  end
end

]]--
--存檔
function Controller:save(args)
  app:makeSnapshot(tostring("save"..args.place))
end

--讀檔
function Controller:load(args)
  app:restoreSnapshot(tostring("save"..args.place))
end

--quake prepare事件呼叫(onFinish)
function Controller:onFinishAction()
  if Controller.needwait==true then
    Controller.needwait=false
    Controller:enter()
  end
end


--播放BGM
function Controller:playCurrentBGM()
  local args = Controller.bgmArgs

  print("bgm info:")
  table.extract(args)

  if args.loop==nil then
    args.loop=true
  end
  if args.start==nil then
    args.start=0
  end
  
  local bgm = Controller.bgmlayer
  bgm=Audio.Audio()
  bgm:setName(tostring("bgm"..args.storage))
  bgm:setLoop(args.loop)
  bgm:setSrc(args.storage)
  if args.vloume==nil then
    bgm:setVolume(Controller.bgmVolume)
  else
    bgm:setVolume(args.volume/100)
  end
  bgm:seek(args.start)
  bgm:play()

  bgm:onFinish(function() Controller:destroy(bgm) end)
end

--CLICK動作
function Controller:continue()
  root:unbind('click',Controller.continue)
  local args = Controller.continueargs
  if Controller.needwait==true then
    print("type:"..args.type.." stop")
    Controller.needwait=false

    if args.type=="video" then
      handlers.stopvideo()

    elseif args.type=="move" then
      handlers.stopmove()

    elseif args.type=="transition" then
      handlers.stoptrans()

    elseif args.type=="bgm" then
      handlers.stopbgm()

    elseif args.type=="quake" then
      handlers.stopquake()

    elseif args.type=="se" then
      handlers.stopse()

    elseif args.type=="fadebgm" then
      Controller.bgmlayer:setVolume(tonumber(args.volume)*kag.gvolume/10000)

    elseif args.type=="fadese" then
      Controller:_getbuf(args.buf):setVolume(tonumber(args.volume)*kag.gvolume/10000)

    end
    Controller:enter()
  end
end


function Controller:waitEvent(args)
  print("wait event:"..args.type)
  if args.type=="bgm" and args.canskip==nil then args.canskip=false end
  if args.type=="move" and args.canskip==nil then args.canskip=true end
  if args.type=="quake" and args.canskip==nil then args.canskip=false end
  if args.type=="transition" and args.canskip==nil then args.canskip=true end
  if args.type=="video" and args.canskip==nil then args.canskip=false end
  if args.type=="se" and args.canskip==nil then args.canskip=false end
  if args.type=="fadebgm" and args.canskip==nil then args.canskip=false end
  if args.type=="fadese" and args.canskip==nil then args.canskip=false end

  if args.canskip==true or args.canskip=="true" then
    if kag.skipMode==true then
      Controller.continueargs=args
      root:bind("click",Controller.continue)
    end

    Controller.needwait=true
  elseif args.canskip==false or args.canskip=="false" then
    Controller.needwait=true
  end
end
--[[
function Controller:timeout_action(args)
  if args.sebuf==nil then args.sebuf=0 end

  if args.se~=nil and args.sebuf~=nil then
    Controller:playCurrentSE({storage=args.se,buf=args.buf})
  end
  if args.storage~=nil or args.target~=nil then
    Controller:jumpAction(args)
  end
end
]]--

--遊戲執行
function Controller:start()
  Controller.needwait=false
  local job = parser:curEle()
  if job==nil then return false end
  
  if Controller.destroybgm==true and Controller.setbgmstop==true then Controller:handlesetbgmstop() end
  local result = handlers[job.tag]
  if result==nil then
    print("macro name:"..job.tag)
    --Controller:handleCustomMacro(job)
  else
    print("handle tag:"..job.tag)
    if check_hact==true and not Controller:exceptionTag(job.tag) then
      table.insert(Controller.hactTable,job)
    elseif check_if==true and not Controller:exceptionTag(job.tag) then
      table.insert(Controller.ifTable,job)
    elseif check_ignore==true and not Controller:exceptionTag(job.tag) then
      table.insert(Controller.ignoreTable,job)
    else
      result(job)
    end
  end
  parser:next()
  if Controller.needwait==true then return false else return true end
end


--Constructor建構子
function Controller:enter()
  root:unbind('click')
  Controller.needwait=false
  if Controller.loadComplete==false then 
    Controller:scanThis()
  else
    while Controller:start() do end
  end
end


---------------------
----JUMP標籤動作-----
----args.storage-----
----args.target------
---------------------
function Controller:jumpAction(args)
  Controller.needwait=false

  if args.storage~=nil and type(args.target)=="number" then
    parser=KAGParser(args.storage)
    parser:setPos(args.target)
    Controller.macros=parser:getMacros()

  elseif filename_t==args.storage or args.storage==nil and args.target~=nil then
    if args.storage==nil then args.storage=filename_t end
    parser=KAGParser(args.storage)
    local target = parser:jumpTo(args.target)
    if target==nil then error("Unknown jump tag:"..args.target) else parser:setPos(tonumber(target)) end
    Controller.macros=parser:getMacros()

  elseif filename_t==args.storage and args.target==nil then
    parser=KAGParser(args.storage)
    Controller.macros=parser:getMacros()
    parser:setPos(1)

  elseif filename_t~=args.storage and args.target~=nil then
    if args.storage==nil then args.storage=filename_t end
    parser=KAGParser(args.storage)
    local target = parser:jumpTo(args.target)
    if target==nil then error("Unknown jump tag:"..args.target) else parser:setPos(tonumber(target)) end
    Controller.macros=parser:getMacros()

  elseif filename_t~=args.storage and args.target==nil then
    if args.storage==nil then args.storage=filename_t end
    parser=KAGParser(args.storage)
    parser:setPos(1)
    Controller.macros=parser:getMacros()
  end

  if filename_t~=args.storage and args.storage~=nil then
    filename_t=args.storage
    Controller:release()
  end

  Controller:enter()
end

--釋放記憶體
function Controller:release()
  app:releaseMedias(Controller.AllResource)
  Controller.AllResource={}
  Controller.loadComplete=false
end

--回到enter
function Controller:resume()
  root:unbind('click',Controller.resume)
  if Controller.needwait then
    Controller.needwait=false
    Controller:enter()
  end
end

--先行離開並且等待點擊
function Controller:_waitClick()
  root:bind("click",Controller.resume)
  Controller.needwait=true
end

--建立詢問視窗
function Controller:CreateAskDialog()
  Controller:addLayer("askDialog")
  local layer = Controller["askDialog"]
  layer.true_b = UI.Button()
  layer.false_b = UI.Button()
  --layer name set--
  layer:setName("askDialogLayer")
  layer.true_b:setName("true")
  layer.false_b:setName("false")
  --name set finish
  ------------------
  local namefield=Controller.askTake
  local _label=Controller.askDialog._label
  local _text = Controller.askDialog._text
  _label=UI.LabelView()
  
  if namefield=="gotostart" then
    _text="最初に戻？"
  elseif namefield=="goback" then
    _text="前に戻？"
  elseif namefield=="close" then
    _text="ゲームを閉じ？"
  elseif namefield=="save" then
    _text="栞の保存？"
  elseif namefield=="load" then
    _text="栞の読み込み？"
  else
    _text=""
  end
  
  _label:setText(_text)
  _label:setFontSize(52)
  local _label_W = 52*Controller:countUTF8Words(_text)
  local _label_H = 52*1.3
  layer:setSize(root:size().width-15,root:size().height-15)
  layer:setPosition((root:size().width-(root:size().width-15))/2,(root:size().height-(root:size().height-15))/2)
  _label:setSize(_label_W,_label_H)
  _label:setPosition({top=tonumber(layer:size().height/2-26*1.3),left=tonumber(layer:size().width/2-52*_text:countUTF8Words()/2)})
  layer:appendView(_label)
  --Dialog size--
  
  ---------------

  --button detail--
  
  local f_s = 48*sys.fix
  local h_s = 50*sys.fix
  local l_s = 96*sys.fix
  local r_s = 144*sys.fix

  layer.true_b:load_layout({enable=true
    ,textstyle = {text="はい",yOffset=7,fontSize=f_s-5,textFillColor={r=0,g=0,b=0,a=1}}
    ,hovertextstyle = {text="はい",yOffset=0,fontSize=f_s,textFillColor={r=1,g=1,b=1,a=1}}})

  layer.false_b:load_layout({enable=true
    ,textstyle = {text="いいえ",yOffset=7,fontSize=f_s-5,textFillColor={r=0,g=0,b=0,a=1}}
    ,hovertextstyle = {text="いいえ",yOffset=0,fontSize=f_s,textFillColor={r=1,g=1,b=1,a=1}}})
  --image hoverimage
  --press
  --layer.false_b:setFontSize(f_s)
  layer.true_b:setSize(l_s+5,h_s+5)
  layer.false_b:setSize(r_s+5,h_s+5)
  -----------------
  local L1 = layer:size().width/4-f_s
  local L2 = layer:size().width/4*3-f_s*1.5
  layer.true_b:setPosition({top=0,left=L1})
  layer.false_b:setPosition({top=0,left=L2})

  layer.true_b:onClick(Controller.askDialogActionTrue)
  layer.false_b:onClick(Controller.askDialogActionFalse)

  --append--
  --true / false避免重複append
  layer:setBackgroundColor({a=0.5,r=0,g=0,b=0})
  if layer:getSubviewByName("true")==nil then layer:appendView(layer.true_b) end
  if layer:getSubviewByName("false")==nil then layer:appendView(layer.false_b) end
  if root:getSubviewByName(layer:name())==nil then 
    print("create dialog successful") 
    root:appendView(layer) 
  end

end

--ASK DIALOG狀況為否
function Controller:askDialogActionFalse()
  print("false")
  Controller:askDialogAction(false)
end

--ASK DIALOG狀況為真
function Controller:askDialogActionTrue()
  print("true")
  Controller:askDialogAction(true)
end

--呼叫詢問視窗
function Controller:CallAskDialog()
  if Controller.askDialog==nil then
    Controller:CreateAskDialog()
  else
    root:appendView(Controller.askDialog)
  end 
  Controller.needwait=true
end

--ask dialog action
function Controller:askDialogAction(act)
  root:removeView(Controller.askDialog)
  Controller.askDialog=nil
  Controller.needwait=false
  if act==true then

    if Controller.askTake=="gotostart" then
      Controller:clear()
      Controller.askTake=""
      Controller:jumpAction({storage=Controller.startanchorInfo[1],target=Controller.startanchorInfo[2]})
    
    elseif Controller.askTake=="close" then
      Controller:clear()
      Controller.askTake=""
      app:releaseMedias(Controller.AllResource)
      app:stop()

    elseif Controller.askTake=="goback" then
      Controller:clear()
      Controller.askTake=""
      parser=Controller.prefab
      parser:setPos(tonumber(Controller.callPos))
      Controller.macros=parser:getMacros()
      Controller:release()
      Controller:enter()

    elseif Controller.askTake=="save" then
      Controller.askTake=""
      Controller:save(Controller.bookemarkPosition)
    
    elseif Controller.askTake=="load" then
      Controller.askTake=""
      Controller:load(Controller.bookemarkPosition)
    end

  elseif act==false then
    Controller:enter()
  end
end

----------------------------
--掃描所有檔案進去cilent端--
----------------------------

function Controller:scanThis()
  Controller.AllResource={MessageLayer_config.lineBreakGlyph,MessageLayer_config.pageBreakGlyph}
  local tmp = Controller.AllResource
  while parser:curEle()~=nil do
    local job = parser:curEle()

    if job.tag=="img" then 
      table.insert(tmp,job.storage) 
  
    elseif job.tag=="image" then
      table.insert(tmp,job.storage)
  
    elseif job.tag=="video" then
      if job.storage~=nil then table.insert(tmp,job.storage) end
    
    elseif job.tag=="position" then
     if job.frame~=nil then table.insert(tmp,job.frame) end
    
    elseif job.tag=="openvideo" then 
      table.insert(tmp,job.storage)
      
    elseif job.tag=="pimage" then
      table.insert(tmp,job.storage)
  
    elseif job.tag=="playbgm" then
      table.insert(tmp,job.storage)
  
    elseif job.tag=="playse" then
      table.insert(tmp,job.storage)
  
    elseif job.tag=="playvideo" then 
      if job.storage~= nil then table.insert(tmp,job.storage) end

    elseif job.tag=="glyph" then 
      if job.line~=nil then table.insert(tmp,job.line) end
      if job.page~=nil then table.insert(tmp,job.page) end

    elseif job.tag=="button" then 
      table.insert(tmp,job.graphic)
      if job.clickse~=nil then table.insert(tmp,job.clickse) end
      if job.enterse~=nil then table.insert(tmp,job.enterse) end
      if job.leavese~=nil then table.insert(tmp,job.leavese) end

    elseif job.tag=="graph" then
      table.insert(tmp,job.storage)

    elseif job.tag=="trans" then
      if job.rule~=nil then table.insert(tmp,job.rule) end

    elseif job.tag=="fadeinbgm" then
      table.insert(tmp,job.storage)

    elseif job.tag=="fadeinse" then
      table.insert(tmp,job.storage)

    end
    parser:next()
  end
  
  if Controller.loadComplete==false then
    print("loaded resource")
    table.extract(tmp)
    print("load complete")
  end
  parser:setPos(1)
  Controller.loadComplete=true
  app:requireMedias(tmp,Controller.enter)
end

function Controller:clear()
  print("screen clear")
  local subs = root:subviews()
  for k,v in pairs(subs) do
    root:removeView(v)
  end
end

function Controller:showhistory()
  Controller.history=nil
  Controller:addLayer("history")
  local layer = Controller.history

  layer:setName("history")
  
  layer:setBackgroundColor({a=0.5,r=0,g=0,b=0})
  layer:setSize(root:size().width - 15,root:size().height - 15)

  Controller._historylog = {}

  local text = Controller:historyAnalyze()

  local i = 1
  local count = 0 --char count
  local x = 0 --length count
  local tmp_h

  while true do
    x = x + HistoryLayer_config.fontHeight
    if x>layer:size().width then break else count = count + 1 end
  end
  
  local start = 1
  local w = layer:size().width
  local h = HistoryLayer_config.lineHeight

  count=count-1
  local no = 1

  for k,v in pairs(text) do
    while true do
      tmp_h = 50
      Controller._historylog[i] = {}
      while true do
        local length = start+count
        if tmp_h > layer:size().height then break end
        
        local tmp = v:utf8sub(start,length)
        start=length+1
        local new_line=UI.LabelView()
        new_line:setSize(w,h)
        new_line:setPosition({top=tmp_h,left=0})
        new_line:setTextStyle({textFillColor={a=1,r=1,g=1,b=1}})
        new_line:setFontSize(HistoryLayer_config.fontHeight)
        new_line:setText(tmp)
        new_line:setName(tostring("history_no"..no))
        table.insert(Controller._historylog[i],new_line)
        no = no + 1
        tmp_h = tmp_h + HistoryLayer_config.lineHeight
      end
      i = i + 1
      if tmp:countUTF8Words()*HistoryLayer_config.fontHeight < layer:size().width then break end
    end
  end
  
  --last page
  Controller.currentHistoryPage=#Controller._historylog
  local last = Controller._historylog[Controller.currentHistoryPage]
  if last~=nil then
    for n=1,#last do
      layer:appendView(last[n])
    end
  end
  local next_b = UI.ButtonView()
  local past_b = UI.ButtonView()
  local close = UI.ButtonView()
  next_b:setText("次ページ＞")
  past_b:setText("＜前ページ")
  close:setText("閉じる")
  next_b:setSize(5*40,40*1.4)
  past_b:setSize(5*40,40*1.4)
  close:setSize(3*40,40*1.4)
  close:setFontSize(40)
  next_b:setFontSize(40)
  past_b:setFontSize(40)
  past_b:setPosition({top=0,left=0})
  next_b:setPosition({top=0,left=layer:size().width-5*40})
  close:setPosition({top=0,left=layer:size().width/2-1.5*40})
  next_b:setTextStyle({textFillColor={a=1,r=1,g=1,b=1}})
  past_b:setTextStyle({textFillColor={a=1,r=1,g=1,b=1}})
  close:setTextStyle({textFillColor={a=1,r=1,g=1,b=1}})
  next_b:onClick(function()
                    print("next page")
                    Controller.currentHistoryPage=Controller.currentHistoryPage+1
                    Controller:showhistoryPage(Controller.currentHistoryPage)
                  end)
  past_b:onClick(function()
                    print("past page")
                    Controller.currentHistoryPage=Controller.currentHistoryPage-1
                    Controller:showhistoryPage(Controller.currentHistoryPage)
                  end)
  close:onClick(function()
                    Controller:historyClose()
                end)
  layer:appendView(next_b)
  layer:appendView(past_b)
  layer:appendView(close)

  if root:getSubviewByName("history")==nil then
    root:appendView(layer)
    print("history layer created")
  end
  
  Controller.needwait=true
end

function Controller:showhistoryPage(page)
  print("to history page:"..page)
  local history = Controller._historylog[page]

  if history~=nil and page<=HistoryLayer_config.maxPages then
    if page <= #history and page>=1 then
      local layer = Controller.history  

      local subs = layer:subviews() 

      for k,v in pairs(subs) do
        if v:name():find("history_no")~=nil then
          layer:removeView(v)
        end
      end 

      for k,v in pairs(history) do
        layer:appendView(v)
      end
    end
  elseif page>HistoryLayer_config.maxPages then
    Controller.currentHistoryPage = Controller.currentHistoryPage - 1
    print("can't find page")

  elseif page<1 then
    Controller.currentHistoryPage = Controller.currentHistoryPage + 1
    print("can't find page")
  elseif history==nil then
    Controller.currentHistoryPage = Controller.currentHistoryPage - 1
    print("can't find page")
  end
end

function Controller:historyClose()
  root:removeView(Controller.history)
  Controller.history=nil
  Controller.needwait=false
  Controller:enter()
end

function Controller:process(type,table)
  local v_c
  if type=="if" then
    v_c=ifTjs
  elseif type=="ignore" then
    v_c=ignoreTjs
  elseif type=="hact" then
    v_c=hactTjs
  end
  
  if v_c==true then
    for k,v in pairs(table) do
      local result = handlers[v.tag]
      if result==nil then
        Controller:handleCustomMacro(v)
      else
        result(v)
      end
    end
  end
end

function Controller:exceptionTag(tag)
  local ex = {"endif","endhact","endignore","else"}
  for k,v in pairs(ex) do
    if v==tag then return true end
  end
  return false
end


function Controller:eval(text)
  return loadstring([[ 
      local _ = {...}
      local f = _[1]
      local sf = _[2]
      local kag = _[3]
      local mp = _[4]
      return ]] .. text)( app.session.f, app.data.sf ,self, self.macros)
end


function Controller:historyAnalyze()
  split = function(str, pat)
    local t = {}  -- NOTE: use {n = 0} in Lua-5.0
    local fpat = "(.-)" .. pat
    local last_end = 1
    local s, e, cap = str:find(fpat, 1)
    while s do
      if s ~= 1 or cap ~= "" then
    table.insert(t,cap)
      end
        last_end = e+1
        s, e, cap = str:find(fpat, last_end)
    end
    if last_end <= #str then
      cap = str:sub(last_end)
      table.insert(t, cap)
    end
    return t
  end
  local text=split(sys.log,"\n")
  return text
end

function Controller:stopThis(target)
  root:unbind('click',Controller.stopThis)
  root:removeView(target)
  Controller.needwait=false
  Controller:enter()
end

function Controller:handlesetbgmstop()
  Controller.setbgmstop=false
  Controller.destroybgm=false
  local args=Controller.setbgmstopargs
  Controller:jumpAction({storage=args.storage,target=args.target})
end

function Controller:exit(p)
  return {}
end


function Controller:_getlayer(num)
  num=tostring(num)
  if num:match("message") then
    num = tonumber(input:match("message([0-9]+)"))
    if not num then num = kag.current end
    for i=0,num do 
      if not kag.message[i] then
        kag.message[i] = KAGMSGLayer()
        --copy info to kag
        kag.fore.message[i] = kag.message[i].fore
        kag.back.message[i] = kag.message[i].back
     end 
   end
    return kag.message[num] 
  else
    if num == "base" then num = 0 else num = tonumber(num) end
    for i=0,num do 
      if not kag.layer[i] then
        kag.layer[i] = KAGLayer()
        --copy info to kag         
        kag.fore.layer[i] = kag.layer[i].fore
        kag.back.layer[i] = kag.layer[i].back
      end 
    end
    return kag.layer[num] 
  end
end

function Controller:_getslot(input)
  input = tonumber(input)
  for i=0,input do if not kag.slot[input] then kag.slot[input] = KAGSlot() end end
  return kag.slot[input]
end

function Controller:_getbuf(input)
  input = tonumber(input)
  for i=0,input do if not kag.buf[input] then kag.buf[input] = KAGBuf() end end
  return kag.buf[input]
end

function Controller:_dowait(time,canskip)
  self.canskip=canskip
  app:setTimeout({self,self.endwait},args.time)
  root:bind('click',function(self)
    self.endwait=nil
  end)
end

function Controller:hidemessage()
  for k,v in pairs(kag.layer) do
    if v.autohide then v:hide() end
  end
  for k,v in pairs(kag.message) do
    v:hide()
  end
  self.hidingmessage=UI.View({View={width=ENV.WIDTH,height=ENV.HEIGHT}})
  root:appendView(self.hidingmessage)
end

function Controller:showmessage()
  for k,v in pairs(kag.layer) do
    if v.autohide then v:show() end
  end
  for k,v in pairs(kag.message) do
    v:show()
  end
  root:removeView(self.hidingmessage)
  self.hidingmessage=nil
end

function Controller:_kagfadeend()
  if self.needwait==true then
    self.needwait=false
    self:enter()
  end
end


return Controller
