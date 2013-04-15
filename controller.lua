--require "KAGParser"
local app, script = unpack({...})
local Controller = {}


local delaytime = 0
local tmp_delay = 0

local message_delay = 0
local tmp_message_delay = 1


local ifTable = {}
local hactTable = {}

local prefabs = {}

local orign_waittime = 0


local if_exp = nil
local hact_exp = nil

local check_if = false
local check_hact = false
local check_ignore = false


--root~~~
Controller.root = UI.View()
local root = Controller.root
root:setPosition({top=0,left=0})
root:setSize(1024,768)
app:set_layout(root)

--圖像處理相關
Controller.imageArgs = {}
Controller.imageIndex = 1


--按鈕處理相關
Controller.buttonArgs = {}
Controller.buttonIndex = 1


--文字顯示速度
Controller.textspeed=0
---------
--存入變數用
Controller.varSet = {}
--影像儲存
--Controller.VideoAudio = {}

Controller.videoChannel[1] = nil
Controller.videoChannel[2] = nil


--Frame處理
Controller.frameArgs = {}
Controller.frameIndex = 1

--文字處理
Controller.textLeft=0
Controller.textTop=0
Controller.baseTop=0
Controller.baseLeft=0
Controller.chIndex = 1
Controller.rubyIndex = 1
Controller.linesize = 0
Controller.linespacing = 0
Controller.lines=1

--紀錄最尾端位置(文字)
Controller.lastX = 0
Controller.lastY = 0
--目前使用標記符號
Controller.glyphTag = nil


--link相關
Controller.canlink=true
--書籤相關
Controller.canMakeSnapShot=true
Controller.canRestoreSnapShot=true
--控制場景
Controller.canSkip=true
--startanchor設定
Controller.startanchor=true
--SE相關
--Controller.SeSet = {}
Controller.defaultSE = 1
--trigger 設定
Controller.triggerSet = {}
--pimage相關
Controller.pimageArgs = {}
Controller.pimageIndex=1

--SE效果處理相關
--Controller.containedSE={}
Controller.seIndex = 1
--BGM控制
--Controller.containedBGM = {}
Controller.bgmVolume=1

--新增
--切字串記錄用
Controller.maxWidth = 0
--文字速度
Controller.defaultSpeed=0
----------------------

--優先讀取--
local filename ="first.ks"
------------
local handlers
handlers = {
  p=function(args)
		Controller:got_click()
	end,

	l=function(args)
		Controller:got_click()
	end,

	locklink = function(args)
		Controller.canlink=false
	end,

	unlocklink = function(args)
		Controller.canlink=true
	end

	wait = function(args)
    	delaytime=args.time	
    	if args.mode=="until" then orign_waittime=args.time end	
	end,

	jump = function(args)
		Controller:jumpAction(args)
	end,

	resetfont = function(args)
		Controller.fontStyle=nil
	end,

	resetstyle = function(args)
		Controller.align=nil
		Controller.linespacing=0
		Controller.pitch=0
		Controller.linesize=0
		Controller.autoreturn=nil
	end,

	defstyle = function(args)
		if args.linesize~=nil then Controller.linesize=args.linesize end
		if args.linespacing~= nil then Controller.linespacing=args.linespacing end
		--args.pitch 未實裝 
	end,

	--else = function(args)
	--end,

	--elseif = function(args)
	--end,

	emb = function(args)
		--get var
		for i=1,#Controller.varSet do
			if Controller.varSet[i]:find(args.exp)~=nil then
				Controller.varSet[i]=args.exp
				break
			end 
		end
	end,
	
	eval = function(args)
		table.insert(Controller.varSet,args.exp)
	end,


	--待續
	--message layer操作
	layopt = function(args)
		--local current = Controller.lastLayer
		local layer = Controller[tostring("message"..args.layer)]
		if args.page==nil then args.page="fore" end
		if args.visible==nil then args.visible=layer.status end
		if args.visible==nil then args.visible=true end
		if args.opacity==nil then args.opacity=255 end


		local opacity = args.opacity/255
		
		layer:setAlpha(opacity)

		if args.top~=nil and args.left~=nil then
			layer:setPosition({top=args.top,left=args.left})
		end


		if args.visible=="true" or args.visible==true then
			if layer.status==false or layer.status=="false"then
				root:appendView(layer)
			end

		end
		if args.visible=="false" or args.visible==false then
			if layer.status==true or layer.status=="true" then
				root:removeView(layer)
			end
		end

		if args.autohide~=nil then
			handlers.hidemessage()
		end

		if args.index~=nil then
			--???
		end

	end,

	r = function(args) 
		Controller.textTop = Controller.textTop + Controller.fontStyle.size*1.2
		Controller.textLeft = 0 + Controller.baseLeft
		if Controller.fontStyle.rubysize~=nil and Controller.fontStyle.rubyoffset~=nil then
			Controller.lines = Controller.lines + 1
		end
	end,

	image = function(args) 
		Controller:imageHandler(args)
	end,

	call = function(args)
		local prefab = Controller(args.storage)
	end,

	loadplugin = function(args)
		--載入插件，未實作
	end,

	iscript = function(args)
		--處理tjs，未實作
	end,

	style = function(args)
		Controller.align=args.align
		Controller.linespacing=args.linespacing
		Controller.pitch=args.pitch
		Controller.linesize=args.linesize
		Controller.autoreturn=args.autoreturn
	end,

	current = function(args)
		local TargetLayer = Controller[args.layer]
		Controller.lastLayer=TargetLayer
		--指定層不實作(?)
	end,

	locate = function(args)
		if args.x==nil then args.x=0 end
		if args.y==nil then args.y=0 end
		Controller.textTop = Controller.textTop + args.y
		Controller.textLeft = Controller.textLeft + args.x
		Controller.baseLeft = args.x
		Controller.baseTop = args.y
	end,

	history = function(args)
		--顯示歷史訊息
	end,

	hact = function(args)
		check_hact=true
		hact_exp=args.exp		
	end,

	hactend = function(args)
		check_hact=false
	end,

	delay = function(args)
		if args.speed=="nowait" then
			handlers.nowait()
		elseif args.speed=="user" then
			Controller.textspeed=Controller.defaultSpeed
		else
			Controller.textspeed=args.speed
		end
	end,

	move = function(args)
		local target = Controller[tostring("message"..args.layer)]
		if args.page=="fore" then
			Controller.movingLayer=target.fore
		elseif args.page=="back" then
			Controller.movingLayer=target.back
		elseif args.page==nil then
			Controller.movingLayer=target.fore
		end
		Controller:moveTarget(args)
	end,

	timeout = function(args)
		app:setTimeout({Controller,function self:timeout_action(args) end},args.time)
	end,

	title = function(args)
		--未實裝
	end,

	deffont = function(args)
	--設定字型
		if args.size==nil then args.size=Controller.linesize end

		Controller.fontStyle = {size=args.size,
								face=args.face,
								color=args.color,
								rubysize=args.rubysize,
								rubyoffset=args.rubyoffset,
								shadow=args.shadow,
								edge=args.edge,
								edgecolor=args.edgecolor,
								shadowcolor=args.shadowcolor,
								bold=args.bold
								}
	end,

	img = function(args)
		Controller:imageHandler(args)
	end,

	clickskip = function(args)
		Controller.canSkip=args.enabled
	end,

	nowait = function(args)
		if Controller.nowait ~= nil then return end
		Controller.nowait = Controller.textspeed
		Controller.textspeed = 0
	end,

	endnowait = function(args)
		if Controller.nowait == nil then return end
		Controller.textspeed = Controller.nowait
		Controller.nowait = nil
	end,

	autowc = function(args)
		--自動文字數(args.time)
	end,

	clearsysvar = function(args)
		local tmp_sysvar = {}
		for i=1,#Controller.varSet do
			if Controller.varSet[i]:find("^sf.") then table.insert(tmp_sysvar,Controller.varSet[i]) end
		end
		for i=1,#tmp_sysvar do
			table.remove(Controller.varSet,tmp_sysvar[i])
		end
	end,

	close = function(args)
		if args.ask==nil or args.ask=="true" or args.ask==true then
			app:releaseMedias(Controller.AllResource)
			app:stop()
		end
	end,

	cursor = function(args)
		--未實裝
	end,

	hidemessage = function(args)
		local msglayer = Controller.messagelayer
		local fore = msglayer.fore
		for i=1,Controller.chIndex-1 do
			if fore:getSubviewByName(tostring("ch"..i))~=nil then
				fore:removeView(fore:getSubviewByName(tostring("ch"..i)))
			end
		end
		for i=1,Controller.rubyIndex-1 do
			if fore:getSubviewByName(tostring("ruby"..i))~=nil then
				fore:removeView(fore:getSubviewByName(tostring("ruby"..i)))
			end
		end
		root:bind("click",Controller.allmessage)
		
	end,

	mappfont = function(args)
		--未實裝
	end,

	nextskip = function(args)
		Controller.nextskip=args.enabled
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
		--未實裝
	end,

	resetwait = function(args)
		--delaytime=orign_waittime
	end,

	s = function(args)
		Controller.stopgame=true
	end,

	stopquake = function(args)
		root:flush()
	end,

	waitclick = function(args)
		root:bind('click')
	end,

	wc = function(args)
		--指定文字數的等待時間
	end,

	wf = function(args)
		--效果音fade指定
		--未實裝
	end,

	checkbox = function(args)
		--???
	end,

	commit = function(args)
		--表單內容確定
		--未實裝
	end,

	edit = function(args)
		--製作單行的輸入框
		--未實裝
	end,

	hr = function(args)
		--history 換 r 作用
	end,

	link = function(args)
		if Controller.canlink==true then
			if args.storage~=nil then
				--change current file
			end
			if args.target~=nil then
			
			else
			end

			--args.exp 未實裝

		end
	end,

	--return = function(args)
	--	routine = {}
	--end,

	animestart = function(args)
		--跟video差在哪裡阿阿阿阿阿阿阿

	end,

	animestop = function(args)
	end,

	copylay = function(args)
		if args.destlayer:find("message")==nil then
			args.destlayer="imageLayer"..args.destlayer
		end

		if args.srclayer:find("message")==nil then
			args.srclayer="imageLayer"..args.srclayer
		end

		if args.srcpage~=nil and args.destpage~=nil then
			Controller[tostring(args.destlayer)].both=Controller:deepcopy(Controller[tostring(args.srclayer)][args.srcpage])
			Controller[tostring(args.destlayer)]=Controller:deepcopy(Controller[tostring("message"..args.srclayer)])
			Controller[args.srclayer]=nil
			Controller[args.destlayer]=nil

		else
			Controller[tostring(args.destlayer)]=Controller:deepcopy(Controller[tostring("message"..args.srclayer)])
		end
		
	end,

	ct = function(args)
		root:removeView(Controller["message0"])
	end,

	freeimage = function(args)
		local layer = Controller[tostring("imageLayer"..args.layer)]
		if args.page==nil then args.page="fore" end
		local sub_image = layer[args.page]:subviews()
		for i,n in pairs(sub_image) do
			--if sub_image:name():find("fore")==nil and sub_image:name():find("")
			layer[args.page]:removeView(n)
			local temp = {}
			table.insert(temp,n:name())
			app:releaseMedias(temp)
		end
	end,

	laycount = function(args)

	end,

	mapaction = function(args)
		--未實裝
	end,

	mapdisable = function(args)
		--未實裝
	end,

	mapimage = function(args)
		--未實裝
	end,

	pimage = function(args)
		table.insert(Controller.pimageArgs,args)
		local tmp = {}
		table.insert(tmp,args.storage)
		app:requireMedias(tmp,Controller.loadpimage)

		--key 未實裝
	end,

	ptext = function(args)
		local layer=Controller["imageLayer"..args.layer]
		if args.page==nil then args.page=="fore" end
		if args.size==nil then args.size=12 end

		local target = layer[args.page]
		local text = target.ptext
		text=UI.LabelView()
		text:setText(args.text)
		text:setPosition({top=args.y,left=args.x})
		text:setFontSize(args.size)
		if args.font~=nil then text:setFont(args.font) end
		local w = Controller:countUTF8Words(args.text)*args.size
		local h = args.size*1.2
		
		text:setSize(w,h)
		
		if args.color~=nil then
			local color = Controller:getColor(args.color)
			text:setTextContent({textFillColor={a=1,r=color.red,g=color.green,b=color.blue}})
		end
		
		--edge設定
		if args.edge~=nil and args.edgecolor~=nil then
			local stroke = Controller:getColor(args.edgecolor)
			ch_message:setTextStyle({textStrokeColor={a=1,r=stroke.red,g=stroke.green,b=stroke.blue},textStrokeWidth=2})
		end

		target:appendView(text)
	end,

	stopmove = function(args)
	end,

	stoptrans = function(args)
	end,

	trans = function(args)
		if args.layer==nil then args.layer="imageLayerbase" end
		if args.layer=="message" then args.layer=Controller.lastLayer end

		if args.layer:find("message")==nil and args.layer:find("imageLayerbase")==nil  then
			args.layer="imageLayer"..args.layer
		end
		--args.time
		--args.method
		if args.method==nil then args.method="universal" end
		
		local layer = Controller[args.layer]
		Controller.transLayer=layer
		local callback = function(){return {Controller, Controller.someTransitionEnd}}

		if args.method =="universal" then
			layer.back:transIn(args.rule, args.duration, args.vague, nil, callback())
			layer.fore:transOut(args.rule, args.duration, args.vague, nil, callback())
		else 	--scroll以crossfade處理
			layer.back:fadeIn(args.duration, callback())
			layer.fore:fadeOut(args.duration, callback())
		end

		local temp = layer.fore
		layer.fore = layer.back
		layer.back = temp
	end,

	wa = function(args)
		--wait animation
		args.type="animation"

		Controller:waitEvent(args)
	end,

	wt = function(args)
		--wait trans
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
		Controller.bgmVolume=(args.volume/100)*(args.gvolume/100)
		Controller.bgmlayer:setVolume(Controller.bgmVolume)
	end,

	fadebgm = function(args)
		--未實裝
	end,

	fadepausebgm = function(args)
		-- 未實裝
	end,

	fadese = function(args)
		--未實裝
	end,

	hch = function(args)
		-- 未實裝
	end

	fadeinbgm = function(args)
		--未實裝
	end,

	playbgm = function(args)
		Controller.bgmArgs=args
		local tmp = {}
		app:requireMedias(tmp,Controller.playCurrentBGM)
	end,

	fadeinse = function(args)
		--未實裝
	end,

	fadeoutbgm = function(args)
		--未實裝
	end,

	fadeoutse = function(args)
		--未實裝
	end,

	resumebgm = function(args)
		local bgm = Controller.bgmlayer
		bgm:play()
	end,

	playse = function(args)
		local tmp = {}
		table.insert(tmp,args.storage)
		app:requireMedias(tmp,{Controller,function self:playCurrentSE(args) end})
	end,

	seopt = function(args)
		if args.buf==nil then args.buf=0 end
		if args.volume==nil then
			args.volume=Controller.defaultSE
		end
		if args.gvolume==nil then args.gvolume=100 end
		Controller.SeSet[args.buf].volume=args.volume/100*args.gvolume/100
	end,

	pausebgm = function(args)
		local bgm = Controller.bgmlayer
		bgm:pause()
	end,

	stopbgm = function(args)
		local bgm = Controller.bgmlayer
		bgm:stop()
	end,

	clearbgmstop = function(args)
		local bgm = Controller.bgmlayer
		bgm:play()
	end,

	stopse = function(args)
		if args.buf==nil then args.buf=0 end
		Controller.SeSet[args.buf].se:stop()
	end,

	---------VIDEO事件
	--Video再生準備開始--
	openvideo = function(args)
		if args.slot==nil then args.slot=0 end
		Controller.VideoSlot[args.slot]=args.storage

		local video = {}
		table.insert(video,args.storage)
		app:prepareMedias(video)
		
	end
	-------------------------------------
	----------VIDEO再生準備結束----------
	-------------------------------------
	preparevideo = function(args)
		if args.slot==nil then args.slot=0 end
		local tmp = {}
		table.insert(tmp,Controller.VideoSlot[args.slot])
		app:requireMedias(tmp)
	end,

	--撥放影片
	playvideo = function(args)
		if args.slot==nil then args.slot=0 end
		if args.storage~=nil then
			local video = {}
			table.insert(video,args.storage)
			app:prepareMedias(video,{Controller,function self:playVideo(args) end})
		else
			Controller:playVideo(args)
		end
	end,

	cancelvideoevent = function(args)
		Controller.VideoSet[args.slot]=nil
	end,

	cancelvideosegloop = function(args)
		Controller.VideoSet[args.slot].segloop=nil
	end,

	clearvideolayer = function(args)
		if args.slot==nil then args.slot=0 end
		root:removeView(Controller[Controller.VideoSet[args.slot].layer])
		Controller.videoChannel[args.channel]=nil
	end,

	resumevideo = function(args)
		if args.slot==nil then args.slot=0 end
		local video = Controller.VideoSet[args.slot].video
		video:play()
	end,

	rewindvideo = function(args)
		--未實裝
	end,

	stopvideo = function(args)
		if args.slot==nil then args.slot=0 end
		local video = Controller.VideoSet[args.slot].video
		video:stop()
	end,

	video = function(args)
		if args.slot==nil then args.slot=0 end

		Controller.VideoSet[args.slot] = {
							visible=args.visible,
							left=args.left,
							top=args.top,
							width=args.width,
							height=args.height,
							loop=args.loop,
							position=args.position,
							frame=args.frame,
							mode=args.mode,
							playrate=args.playrate, --未實裝
							volume=args.volume,
							pan=args.pan, --未實裝
							audiostreamnum=args.audiostreamnum --API已經實裝
						}
	end,

	videoevent = function(args)
		if args.slot==nil then args.slot=0 end
		Controller.currentVideoEvent = Controller.VideoSet[args.slot]
	end,

	pausevideo = function(args)
		if args.slot==nil then args.slot=0 end
		local video = Controller.VideoSet[args.slot].video
		video:pause()
	end,

	videolayer = function(args)
		if args.slot==nil then args.slot=0 end
		Controller.VideoSet[args.slot].page=args.page
		Controller.VideoSet[args.slot].channel=args.channel

		
		Controller:addLayer(tostring("videolayer"..args.layer))
		Controller.VideoSet[args.slot].layer=tostring("videolayer"..args.layer)
	end,

	videosegloop = function(args)
		if args.slot == nil then args.slot=0 end
		local video = Controller.VideoSet[args.slot].video
		--以下未實裝
	end,

	----------------------

	wb = function(args)
		--未實裝
	end,

	wf = function(args)
		--未實裝
	end,

	wl = function(args)
		args.type="bgm"

		Controller:waitEvent(args)
	end,


	wp = function(args)

	end,
	
	
	ws = function(args)
		--未實裝
		--[[
		args.type="se"

		Controller.waitEvent(args)
		]]--
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
		--args.time fadeout 特效 未實裝
		--args.overlap 未實裝
		bgm:stop()
		local tmp = {}
		table.insert(tmp,Controller.bgmlayer:name())
		app:releaseMedias(tmp)

		Controller.bgmArgs=args
		local tmp1 = {}
		table.insert(tmp1,args.storage)
		app:prepareMedias(tmp1,Controller.playCurrentBGM)
	end,

	clearbgmlabel = function(args)
		--未實裝
	end,

	clearvar = function(args)
		Controller.varSet = {}
	end,

	endif = function(args)
		check_if=false
	end,

	--if = function(args)
	--	check_if=true
	--	if_exp=args.exp
	--end,

	ignore = function(args)
		check_ignore=true
	end,

	endignore = function(args)
		check_ignore=false
	end,

	input = function(args)
		--未實裝
	end,

	trace = function(args)
		--未實裝
	end,

	waittrig = function(args)
		if args.canskip==nil then args.canskip=false end
		local trigger = Controller.triggerSet[args.storage]
		trigger["skipOption"]=args.canskip
		trigger["onskipOption"]=args.onskip
	end,

	copybookmark = function(args)
		
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
		--未實裝
	end,

	goback = function(args)
	end,

	gostart = function(args)
	end,

	load = function(args)
		--詢問視窗待完成
		if Controller.canRestoreSnapShot==true then
			if args.place==nil then args.place=0 end
			if args.ask==nil then args.ask=false end
			Controller:load(args)
		end
	end,

	locksnapshot = function(args)
		Controller.canMakeSnapShot=false
	end,

	record = function(args)
		--...?
		app:makeSnapshot("checkpoint")
	end,

	save = function(args)
		if Controller.canMakeSnapShot==true then 
			if args.place==nil then args.place=0 end
			if args.ask==nil then args.ask=false end
			--if ask=true情況實作
			Controller:save(args)
		end
	end,

	startanchor = function(args)
	end,

	store = function(args)
		Controller.canMakeSnapShot=args.enabled
	end,

	tempload = function(args)
		if Controller.canRestoreSnapShot=true then
			local num = args.place
			if num==nil then num=0 end
			if args.bgm==nil then args.bum=true end
			if args.se==nil then args.se=true end
			app:restoreSnapshot(tostring("tmpsave"..num))
			Controller.playTempLoadBGM=args.bgm
			Controller.playTempLoadSE=args.se
			--args.backlay
		end
	end,

	backlay = function(args)

	end,

	tempsave = function(args)
		if Controller.canMakeSnapShot==true then
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
		--未實裝(?)
	end,

	cwheel = function(args)
		--未實裝(?)
	end,

	ch = function(args)
	    local msglayer = Controller.messagelayer
	    local ch_message=msglayer.fore[tostring("ch"..Controller.chIndex)]
	    ch_message=UI.LabelView()
	    ch_message:setName(tostring("ch"..Controller.chIndex))
	    Controller.currentMsg=ch_message
	    Controller.chIndex = Controller.chIndex + 1
	    ch_message:setTextSpeed(tonumber(Controller.textspeed))
	    
	    local w = Controller:countUTF8Words(args.text)*Controller.fontStyle.size
	    local h = Controller.fontStyle.size*1.2 + Controller.linespacing
	    
	    --過長文字判斷
	    local too_long = false
	    local v 

	    if tonumber(Controller.textLeft + Controller.baseLeft + w) > tonumber(Controller.maxWidth) then
      		local tmp = Controller.textLeft + Controller.baseLeft 
      		local count = 0
      		while true do
        		tmp = tmp + Controller.fontStyle.size
        		if tmp > tonumber(Controller.maxWidth) then break else count=count+1 end
        		--if count==100 then break end--保護機制
      		end

      		v=Controller:utf8sub(args.text,count+1,Controller:countUTF8Words(args.text))
      		w = Controller.fontStyle.size*count
      		args.text=Controller:utf8sub(args.text,1,count)
    		too_long=true
    	end

    	ch_message:setText(args.text)
	    ch_message:setSize(w,h)
	    msglayer.fore:appendView(ch_message)
	    if msglayer:hasSubView(msglayer.fore)==false then msglayer:appendView(msglayer.fore) end
	    Controller:setTextContent()
	    --紀錄最左位置
	    Controller.lastX = Controller.lastX + w
	    Controller.textLeft=Controller.textLeft+w

    	--過長文字換行
    	if too_long==true then
      		handlers.r()
      		local tmp = {}
      		tmp.text=tostring(v)
      		tmp.tag="ch"
      		if Controller.hasCutRuby~=nil then
      			handlers.ruby(Controller.hasCutRuby)
      			Controller.fontStyle.rubyoffset=tonumber(Controller.tmpRubyOffset)
      			Controller.hasCutRuby=nil
      		end
   			handlers.ch(tmp)
    	end
	end,
	
	position = function(args)
		table.insert(Controller.frameArgs,args)
 	  	if args.layer==nil then args.layer=Controller.lastLayer end
	    ----------------
	    --msglayer命名--
	    ----------------	

	  	if args.layer~=nil then 
	      Controller:addLayer(args.layer)
	      Controller.messagelayer=Controller[args.layer] 
	    end
	    if root:hasSubView(Controller[args.layer])==false then
	      Controller.messagelayer.fore:setName(tostring(args.layer.."fore"))
	      Controller.messagelayer.back:setName(tostring(args.layer.."back"))
	    end
	    Controller.chIndex=1
	    Controller.rubyIndex=1
	    Controller.lines=1
	    Controller.fixRuby=nil
	    Controller.textLeft=Controller.baseLeft
	    Controller.textTop=Controller.baseTop
	    ----------------

 	  	if args.frame ~=nil then
 	  		local frames = {}
 	  		table.insert(frames,args.frame)
  			prepareMedias(frames,Controller.ch_layerHandler)

 	  	else
 	  		Controller:ch_layerHandler()
 	  	end
	end,

	ruby = function(args)
		if Controller.fontStyle.rubysize~=nil and Controller.fontStyle.rubyoffset~=nil then
			local msglayer = Controller.messagelayer
			local ruby = msglayer.fore[tostring("ruby"..Controller.rubyIndex)]
			local rubywidth = Controller.fontStyle.rubysize*Controller:countUTF8Words(args.text)
			local rubyheight = Controller.fontStyle.rubysize*1.2
			local rubyTop = Controller.textTop + Controller.baseTop + Controller.fontStyle.rubysize*1.2*(Controller.lines-1)
			local rubyLeft = Controller.fontStyle.rubyoffset+Controller.textLeft + Controller.baseLeft
				

			--------------------
		    --假定ruby超出界線--
		    --------------------
		    local v
		    local count = 0
		    if tonumber(rubyLeft+rubywidth)>tonumber(Controller.maxWidth) then
		      local tmp = Controller.fontStyle.rubyoffset+Controller.textLeft+Controller.baseLeft
		      while true do
		        tmp = tmp + Controller.fontStyle.rubysize
		        --print(count)
		        if tmp > tonumber(Controller.maxWidth) then break else count=count+1 end
		      end
		      v=Controller:utf8sub(args.text,count+1,Controller:countUTF8Words(args.text))
		      Controller.hasCutRuby=v
		      Controller.tmpRubyOffset=tonumber(Controller.fontStyle.rubyoffset)	

		      Controller.fontStyle.rubyoffset = 0
		      rubywidth = Controller.fontStyle.rubysize*count
		      args.text=Controller:utf8sub(args.text,1,count)
		      too_long=true
		    end
		    --------------------
				

			ruby=UI.LabelView()
			
			ruby:setName(tostring("ruby"..Controller.rubyIndex))
			Controller.rubyIndex = Controller.rubyIndex +1	

			ruby:setFontSize(Controller.fontStyle.rubysize)
			ruby:setText(args.text)
			ruby:setSize(rubywidth,rubyheight)
			ruby:setTextSpeed(Controller.textspeed)
			ruby:setPosition({top=rubyTop,left=rubyLeft})
			msglayer.fore:appendView(ruby)	

			if msglayer:hasSubView(msglayer.fore)==false then msglayer:appendView(msglayer.fore) end
		end
	end,

	cm = function(args)
		local all_layer = root:subviews()
		for i,n in pairs(all_layer) do
			if n:name():find("^message")~=nil then
				local sub_ch = n.fore:subviews()
				for x,y in pairs(sub_ch) do
					if y:name():find("ch")~=nil or y:name():find("ruby")~=nil then
						if n.fore:hasSubView(y) then n.fore:removeView(y) end
						if n.back:hasSubView(y) then n.back:removeView(y) end
					end
				end
			end
		end
		Controller.chIndex=1
		Controller.rubyIndex=1
		Controller.lines=1
		Controller.fixRuby=nil
	end,

	er = function(args)
		local msglayer = Controller.messagelayer
		local fore = msglayer.fore
		local back = msglayer.back
		local chs = fore:subviews()
		for k,v in pairs(chs) do
			if v:name():find("ch")~=nil or v:name():find("ruby")~=nil then
				if fore:hasSubView(v) then fore:removeView(v) end
				if back:hasSubView(v) then back:removeView(v) end
			end
		end
		Controller.chIndex=1
		Controller.rubyIndex=1
		Controller.lines=1
		Controller.fixRuby=nil
	end,

	glyph = function(args)
		Controller.glyphTag.args=args
		if args.line~= nil then
			local tmp = {}
			table.insert(tmp,args.line)
			app:requireMedias(tmp,Controller.setglyph)
		else
			Controller:setglyph()
		end
	end,

	setbgmstop = function(args)
		-- jump機能
	end,

	graph = function(args)
		-- inline機能
	end,
	--------------
	--custom tag--
	--------------
	thisfile = function(args)
		--break
	end
	--------------
}
Controller.handlers["if"]=function(args)
end

Controller.handlers["else"] = function(args)
end

Controller.handlers["return"] = function(args)
end
--------------------------------------
--Controller.handlers["macro"] = function(job)
--	Controller.macros[job.name] = job
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




--function Controller:handleNewAnimation(target, id)
--	if not id then return end
--	if not self.state.wait then return end
--	if not self.current_animations[id] then
--		self.current_animations[id] = target
--		self.current_animations_count = self.current_animations_count +1
--		else  error("handleNewAnimation error "..id)
--		end
--end

--function Controller:handleAnimatationEnd(target, args)
  --if args then table.extract(args) end
--	if self.current_animations[args.id] then
--		self.current_animations[args.id] = nil
--  	self.current_animations_count = self.current_animations_count -1
--	if self.current_animations_count == 0 and self.state.wait then
--     	self:handleWaitEnd()
--    	return
--    end
--    	if self.current_animations_count <0 then
--      		error("current_animations count error!!")
--    	end
--	end
--end

function Controller:imageHandler(args)
    --記錄參數資料
    table.insert(Controller.imageArgs,args)
    Controller:addLayer("imageLayer"..args.layer)
    local images = {}
    table.insert(images,args.storage)
	app:prepareMedias(Controller.images,Controller.loadImage)
end

	--[[
	key
	mode
	grayscale
	rgamma
	ggamma
	bgamma
	rfloor
	gfloor
	bfloor
	rceil
	gceil
	bceil
	mcolor
	mopacity
	lightcolor
	lighttype
	shadow
	shadowopacity
	shadowx
	shadowy
	shadowblur
	flipud
	fliplr
	mapimage
	mapaction
	index
	]]--


function controller:buttonHandler(args)
	--暫存button資料
	table.insert(Controller.buttonArgs,args)
	Controller:addLayer("buttonLayer")
	local tmp = {}
	table.insert(tmp,args.graphic)
	app:requireMedias(tmp,Controller.loadButton)


	--[[
	graphic
	graphickey 未實裝
	storage
	target
	recthit 未實裝
	exp 未實裝
	hint 未實裝
	onenter
	onleave
	countpage
	clickse
	clicksebuf
	enterse
	entersebuf
	leavese
	leavesebuf
	]]--
end

function Controller:loadButton()
	-- 讀取button(image)用的拉~~
	local args = Controller.buttonArgs[Controller.buttonIndex]
	local buttonLayer = Controller.buttonLayer
	buttonLayer:setSize(1024,768)
	buttonLayer.fore:setSize(1024,768)
	buttonLayer.back:setSize(1024,768)
	buttonLayer.both:setSize(1024,768)
	local button = Controller.buttonLayer["button"..buttonIndex]
	button=UI.ButtonView()

	--button大小決定在圖片大小...(?)

	if args.target~=nil then
		--jump動作
	end

	buttonLayer.fore:appendView(button)
	
	button:onClick(function(args)
		if args.clickse~=nil then
			if args.clicksebuf==nil then args.clicksebuf=0 end
			local cl_se_args = Controller.SeSet[args.clicksebuf]
			cl_se_args.storage=args.clickse
		end
		local enter_se_agrs = Controller.SeSet[args.entersebuf]
	end)

	Controller.buttonIndex = Controller.buttonIndex + 1
end

--增加layer
function Controller:addLayer(layer)
	if root:getSubviewByName(tostring(layer))==nil then
		local newlayer = UI.View()
		Controller[layer]=newlayer
		newlayer.fore = UI.View()
		newlayer.back = UI.View()
		newlayer.both = UI.View()
		newlayer:setName(tostring(layer))
	end
end


function Controller:_quakenow()
	local args = Controller.tmpArgs
	if args.vmax~= nil then root:moveSequential({args.vmax,0 , 0,0},args.time,Controller.onFinishAction) end
	if args.hmax~= nil then root:moveSequential({0,args.hmax , 0,0},args.time,Controller.onFinishAction) end
end

function Controller:getPath(path,type)
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

	local temp = split(x,"%(")
	local output = {}
	for i=1,#temp do
		local t = split(temp[i],"%)")
		table.insert(output,t[1])
	end
	local result = {}
	if type=="x" or type=="X" then
		for k,v in pairs(output) do
			local data = split(v,",")[1]
			table.insert(result,data)
		end
	elseif type=="y" or type=="Y" then
		for k,v in pairs(output) do
			local data = split(v,",")[2]
			table.insert(result,data)
		end
	elseif type=="opacity" then
		for k,v in pairs(output) do
			local data = split(v,",")[3]
			table.insert(result,data)
		end
	end

	if result~=nil then 
		return result 
	else
		return nil
	end
end

--移動畫面
function Controller:moveTarget(args)
	local target = Controller.movingLayer
	local pahtX = Controller:getPath(args.path,"x")
	local pathY = Controller:getPath(args.path,"y")
	local opacity = Controller:getPath(args.path,"opacity")
	if args.delay==nil then args.delay=0 end
	app:setTimeout(function(Controller,args,pathX,pathY,opacity)
						for i=1,#pathX do
							Controller.movingLayer:moveTo({top=tonumber(pathX[i]),left=tonumber(pathY[i])},tonumber(args.time))
							--Controller.movingLayer:
						end
					end,tonumber(args.delay))
	
end

--設定文字效果
function Controller:setTextContent()
  local ch_message = Controller.currentMsg
  local msglayer = Controller.messagelayer
  local ruby = Controller.currentRuby
  
  if Controller.fontStyle~=nil then
    local fontStyle = Controller.fontStyle
    
    if fontStyle.size~=nil then
      ch_message:setFontSize(tonumber(fontStyle.size))
    end
    
    if fontStyle.face~=nil then ch_message:setFont(fontStyle.face) end
    
    if fontStyle.color~=nil then 
      local color = Controller:getColor(fontStyle.color)
      --[[if fontStyle.bold=="true" or fontStyle.bold==true then
        ch_message:setTextStyle({textStrokeColor={a=1,r=color.red,g=color.green,b=color.blue},textStrokeWidth=10})
      end]]--
      ch_message:setTextStyle(textFillColor{a=1,r=color.red,g=color.green,b=color.blue})
    end
    --[[if fontStyle.bold=="true" or fontStyle.bold==true and fontStyle.color==nil then
      ch_message:setTextStyle({textStrokeColor={a=1,r=0,g=0,b=0},textStrokeWidth=10})
    end]]--

    if fontStyle.rubysize~=nil then 
    	--在ruby tag標籤實裝
    end
    
    if fontStyle.rubyoffset~=nil then
       	--在ruby tag標籤實裝
    end
    
    if fontStyle.shadow~= nil then
      --未實裝
    end
    
    if fontStyle.edge~=nil then
      if fontStyle.edge==true or fontStyle.edge=="true" then
        ch_message:setTextStyle({textStrokeWidth=2})
      else
        ch_message:setTextStyle({textStrokeWidth=1})
      end
    end
    
    if fontStyle.edgecolor~=nil then
      local color = Controller:getColor(fontStyle.edgecolor)
      ch_message:setTextStyle({textStrokeColor={a=1,r=color.red,g=color.green,b=color.blue}})
    end
    
    if fontStyle.shadowcolor~=nil then
      --未實裝
    end

    if fontStyle.rubyoffset~=nil and fontStyle.rubysize~=nil then
    	local top = Controller.textTop + Controller.baseTop +fontStyle.rubysize*1.2*Controller.lines + Controller.linespacing
	    local left = Controller.textLeft + Controller.baseLeft
	    Controller.fixRuby=tonumber(fontStyle.rubysize)
	    ch_message:setPosition({top=top,left=left})
	    Controller.lastY = top
	    Controller.lastX = left
     
    else
    	local top = Controller.textTop + Controller.baseTop +Controller.linespacing
    	local left = Controller.textLeft + Controller.baseLeft
    	if Controller.fixRuby~= nil then top = top + (Controller.lines-1)*Controller.fixRuby*1.2 end
      	ch_message:setPosition({top=top,left=left})
	    Controller.lastY = top
	    Controller.lastX = left
    end
    
  end
end

--讀取image
function Controller:loadImage()
    local args = Controller.imageArgs[Controller.imageIndex]
    local imgLayer = Controller[args.layer]
    local name = args.storage
    local fore = imgLayer.fore
    local back = imgLayer.back
    local both = imgLayer.both
    local img = fore[tostring("image"..Controller.imageIndex)]
    local tmp = {}
    img=UI.ImageView()

    fore:setName(tostring("fore"..args.layer))
    back:setName(tostring("back"..args.layer))
    both:setName(tostring("both"..args.layer))

    --imgLayer:setName(tostring("imageLayer"..args.layer))
    img:setImage(tostring(name))
    -------------------------------------------
    --處理image及圖層大小
    if args.clipheight~=nil and args.clipwidth ~=nil then
    	img:setSize(args.clipwidth,args.clipheight)
    else
    	img:setSize(800,600)
    end
    --設定圖層大小
    fore:setSize(1024,768)
   	back:setSize(1024,768)
   	both:setSize(1024,768)
    imgLayer:setSize(1024,768)
    ------------------------------------------


    --處理imageLayer的位置
    if args.top~=nil and args.left~=nil then imgLayer:setPosition({top=args.top,left=args.left}) end
    --處理imageLayer上的image位置
    if args.clipleft~=nil and args.cliptop~=nil then img:setPosition({top=args.cliptop,left=args.clipleft}) end
    --處理layer透明度
    if args.opacity~= nil then imgLayer:setAlpha(args.opacity/255) end

    ----------------------------------
    ------------未實裝----------------
    --處理Layer預設位置指定(文字表示)
    if args.pos~=nil then 
      if args.pos=="left_center" then
      	imgLayer:setPosition({top=((768/2)-(768/4)),left=0})
      elseif args.pos=="right_center" then
      	imgLayer:setPosition({top=((768/2)-(768/4)),left=0})
      end
    end
    ----------------------------------
    ----------------------------------
    back:setAlpha(0)
    if args.visible==nil or args.visible==true or args.visible=="true" and args.page=="fore" or args.page==nil then
    	fore:appendView(img)
    	if fore:getSubviewByName(back:name())==nil then fore:appendView(back) end
    	if both:getSubviewByName(fore:name())==nil then both:appendView(fore) end
    	if imgLayer:getSubviewByName(both:name())==nil then imgLayer:appendView(both) end
    	if root:getSubviewByName(imgLayer:name())==nil then root:appendView(imgLayer) end

    elseif args.visible==nil or args.visible==true or args.visible=="true" and args.page=="back" then
    	back:appendView(img)
    	if fore:getSubviewByName(back:name())==nil then fore:appendView(back) end
    	if both:getSubviewByName(fore:name())==nil then both:appendView(fore) end
    	if imgLayer:getSubviewByName(both:name())==nil then imgLayer:appendView(both) end
    	if root:getSubviewByName(imgLayer:name())==nil then root:appendView(imgLayer) end

  	elseif args.visible==false or args.visible=="false" then
  		--don't append
    end
    print("set image:"..name)
    Controller.imageIndex = Controller.imageIndex + 1
end


--播放video，來源從video tag裡面取得
function Controller:playVideo(args)
	if args.slot==nil then args.slot=0 end
	local set = Controller.VideoSet[args.slot]

	if set~=nil then
		if Controller.videoChannel[set.channel]==nil then
			
			--通道占用
			Controller.videoChannel[set.channel]=true
			--

			if args.storage==nil then args.storage=Controller.VideoSlot[args.slot] end
			local layer = Controller[tostring("videolayer"..set.layer)]
			local video = layer.fore.video
			Controller.VideoSet[args.slot].storage=args.storage
			Controller.VideoSet[args.slot].video=video
			Controller.VideoSet[args.slot].layer=layer

			Controller.currentVideo=video

			video=UI.VideoView()
			video:setName(tostring("Video"..args.slot))
			video:setSrc(tostring(args.storage))

			if set.loop ~=nil then
				if set.loop=="true" or set.loop==true then
					video:setLoop(true)
				elseif set.loop=="false" or set.loop==false then
					video:setLoop(false)
				end
			else
				video:setLoop(false)
			end
			
			if set.top==nil then set.top=0 end
			if set.left==nil then set.left=0 end

			video:setPosition({top=set.top,left=set.left})

			if set.width==0 and set.height==0 then
				set.width=1024
				set.height=768
			end

			video:setSize(set.width,set.height)
			layer:setSize(set.width,set.height)
			layer.fore:setSize(set.width,set.height)
			layer.back:setSize(set.width,set.height)
			layer.both:setSize(set.width,set.height)
			--set.playrate 播放速度未實裝

			if set.volume==nil then set.volume=100 end
			video:setVolume(tonumber(set.volume)/100)

			--args.pan左右聲道未實裝
			----------------------------------
			---audiostreamnum API已實裝功能---
			----------------------------------

				--開始位置指定--
			if set.position~=nil then video:seek(set.position) end
			
			layer.back:setAlpha(0)

			if set.page=="fore" then
				layer.fore:appendView(video)
				if layer.fore:hasSubView(layer.back)==false then layer.fore:appendView(layer.back) end
				if layer.both:hasSubView(layer.fore)==false then layer.both:appendView(layer.fore) end
				if layer:hasSubView(layer.both)==false then layer:appendView(layer.both) end
				if root:hasSubView(layer)==false then root:appendView(layer) end
				video:play()
				video:onFinish({Controller,function self:destroy(video) end})
			end

			if set.page=="back" then
				layer.back:appendView(video)
				if layer.fore:hasSubView(layer.back)==false then layer.fore:appendView(layer.back) end
				if layer.both:hasSubView(layer.fore)==false then layer.both:appendView(layer.fore) end
				if layer:hasSubView(layer.both)==false then layer:appendView(layer.both) end
				if root:hasSubView(layer)==false then root:appendView(layer) 
				video:play()
				video:onFinish({Controller,function self:destroy(video) end})
			end
			print("set video:"args.storage)
		end
	end
end

function Controller:ch_layerHandler()
	-- body
	local args = Controller.frameArgs[Controller.frameIndex]
 	local ch_layer = Controller[args.layer]
 	local status = ch_layer.visible
    local fore = ch_layer.fore
    local back = ch_layer.back
    local both = ch_layer.both
    local ch_frame = fore.ch_frame
    ch_frame = UI.ImageView()

    --ch_layer.fore.message=UI.LabelView()
    if args.left~=nil and args.top~=nil then
      	ch_layer:setPosition({top=args.top,left=args.left})
    elseif args.left==nil or args.top==nil then
      	ch_layer:setPosition({top=0,left=0})
    end
	
    if args.width~=nil and args.height~=nil then
      	ch_layer:setSize(args.width,args.height)
      	fore:setSize(args.width,args.height)
      	back:setSize(args.width,args.height)
      	both:setSize(args.width,args.height)
      	Controller.maxWidth=tonumber(args.width)
    end
	
    if args.frame~=nil and args.width~=nil and args.height~=nil then
    	ch_frame:setName(args.frame)
      	ch_frame:setPosition({top=0,left=0})
 	    ch_frame:setSize(args.width,args.height)
        ch_frame:setImage(args.frame)
    end
	if args.framekey~=nil and args.width~=nil and args.height~=nil then
		--framekey 未實裝
        --local color = Controller:getColor(args.framekey)
        ch_frame:setPosition({top=0,left=0})
        ch_frame:setSize(args.width,args.height)
        --ch_frame:setBackgroundColor({a=1,r=color.red,g=color.green,b=color.blue})
    end
    if args.color~=nil then
        local color = Controller:getColor(args.color)
        ch_layer:setBackgroundColor({a=1,r=color.red,g=color.green,b=color.blue})
    end
    if args.opacity~=nil then
        ch_layer:setAlpha(tonumber(args.opacity)/255)
    end

    both:setAlpha(0)
	if args.page=="fore" or args.page==nil then
		fore:appendView(ch_frame)
		if fore:hasSubView(back)==false then fore:appendView(back) end
		if both:hasSubView(fore)==false then both:appendView(fore) end
		if ch_layer:hasSubView(both)==false then ch_layer:appendView(both) end
	elseif args.page=="back"then
		if fore:hasSubView(back)==false then fore:appendView(back) end
		if both:hasSubView(fore)==false then both:appendView(fore) end
		if ch_layer:hasSubView(both)==false then ch_layer:appendView(both) end
	end
 	--[[
     marginl no  左余白 ( pixel 単位 )  メッセージレイヤの左余白を指定します。
     margint no  上余白 ( pixel 単位 )  メッセージレイヤの上余白を指定します。
     未實裝
     marginr no  右余白 ( pixel 単位 )  メッセージレイヤの右余白を指定します。
     marginb no  下余白 ( pixel 単位 )  メッセージレイヤの下余白を指定します。
     vertical no "true" または "false"  　メッセージレイヤを縦書きにモードにするには "true" を指定します。 横書きにするには "false" を指定してください。
     draggable no  "true" または "false"  　true に設定すると、marginl, margint, marginr, marginb で指定した マージンの部分でかつ、フレーム画像の不透明度が 64 以上の箇所を、マウスで ドラッグすることによりメッセージレイヤをユーザが移動できるようになります。
　 true false を指定するとこの動作は行われません。
     ]]--
    if args.margint~=nil then
    	Controller.textTop=args.margint
    end

    if args.marginl~=nil then
    	Controller.textLeft=args.marginl
    end

    if args.marginr~=nil then
    end

    if args.marginb~=nil then
    end

	if args.visible==nil or args.visible==true or args.visible=="true" then
       status=args.visible
       root:appendView(ch_layer)
    else
    	status=args.visible
    end
    Controller.frameIndex = Controller.frameIndex + 1
end

--[[
function Controller:Contains(table,needle)
	for i=1,#table do
		if table[i]==needle then return true end
	end
	return false
end
]]--

--算文字數目
function Controller:countUTF8Words(a)
  local count = 0
  if not (type( a) == "string") then
    return 0
  end

  for x in a:gmatch("([%z\1-\127\194-\244][\128-\191]*)") do
    count = count + 1
  end
  return count 
end

function Controller:allmessage()
	local msglayer = Controller.messagelayer
	local fore = msglayer.fore
	for i=1,Controller.chIndex-1 do
		fore:appendView(fore[tostring("ch"..chIndex)])
	end
	for i=1,Controller.rubyIndex-1 do
		fore:appendView(fore[tostring("ruby"..rubyIndex)])
	end
	root:unbind("click",Controller.allmessage)
end

function Controller:save(args)
	app:makeSnapshot(tostring("save"..args.place))
end

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

--video 事件呼叫及 voice(BGM/SE)相關事件呼叫(onFinish)
function Controller:destroy(needle)
	needle:stop()
	
	--作法變更:等到該ks檔案讀取完畢自動釋出記憶體

	--local tmp = {}
	--table.insert(tmp,needle)
	--app:releaseMedias(needle)

	if Controller.needwait==true then
		Controller.needwait=false
		Controller:enter()
	end
end

--讀入pimage
function Controller:loadpimage()
	local args = Controller.pimageArgs[Controller.pimageIndex]
	local layer = Controller["imageLayer"..args.layer]
	if args.page==nil then args.page="fore" end
	local target = layer[args.page]
	local pimg = target[tostring("pimage"..Controller.pimageIndex)]
	pimg=UI.ImageView()
	pimg:setImage(args.storage)
	pimg:setPosition({top=args.dy,left=args.dx})
	target:appendView(pimage)
	Controller.pimageIndex = Controller.pimageIndex + 1
end


--讀入換行符號
function Controller:setglyph()
	local clickTag = Controller.glyphTag
	local args = clickTag.args
	local glyph = args.line
	
	--if clickTag==nil then
		clickTag=UI.ImageView()
		clickTag:setImage(glyph)
	--end
	clickTag:setSize(fontStyle.size,fontStyle.size)
	if args.fix==nil or args.fix==false then
		clickTag:setPosition({top=Controller.lastY,left=Controller.lastX})
	elseif args.fix==true or args.fix=="true" then
		if args.left~=nil and args.top~=nil then
			clickTag:setPosition({top=args.top,left=args.left})
		end
	end
	Controller.messagelayer.fore:appendView(clickTag)
end

--切割顏色字串
function Controller:getColor(colorstring)
	local red = colorstring:sub(3,4)
    local green = colorstring:sub(5,6)
    local blue = colorstring:sub(7,8)
    local color = {}
    color.red=tonumber(red,16)/255
    color.green=tonumber(green,16)/255
    color.blue=tonumber(blue,16)/255
    return color
end


--移除目標
function Controller:removeTarget(table,needle)
	for k,v in pairs(table) do
		if needle==v then table[k]=nil end
	end
	local clone = {}
	for i=1,#table do
		if table[i]~=nil then table.insert(clone,table[i]) end
	end
	return clone
end


--播放BGM
function Controller:playCurrentBGM()
	local args = Controller.bgmArgs
	if args.loop==nil then
		args.loop=true
	end
	if args.start==nil then
		args.start=0
	end
	
	local bgm = Controller.bgmlayer
	bgm=Audio.Audio()
	bgm:setName(args.storage)
	bgm:setLoop(args.loop)
	bgm:setSrc(args.storage)
	if args.vloume==nil then
		bgm:setVolume(Controller.bgmVolume)
	else
		bgm:setVolume(args.volume/100)
	end
	bgm:seek(args.start)
	bgm:play()

	local layer=nil
	bgm:onFinish({Controller,function self:destroy(bgm) end})
end


--播放效果音
function Controller:playCurrentSE(args)
	if args.buf==nil then args.buf=0 end
	if args.loop==nil then args.loop=false end
	if args.start==nil then args.start=0 end
	
	local slot=Controller.SeSet[args.buf]
	local se = slot.se
	if slot.volume==nil then slot.volume=1 end

	se=Audio.Audio()

	se:setVolume(slot.volume)
	se:setSrc(args.storage)
	se:setLoop(args.loop)
	se:seek(args.start)
	se:play()
	se:onFinish({Controller,function self:destroy(se) end})
end


--CLICK動作
function Controller:continue(args)
	root:unbind("click",Controller.continue)
	if Controller.needwait==true then
		
		Controller.needwait=false

		if args.type=="video" then
			Controller:forceVideoStop(args)
			Controller:enter()

		elseif args.type=="move" then
			Controller:forceMoveStop()
			Controller:enter()

		elseif args.type=="transition" then
			Controller:forceTrasitionStop()
			Controller:enter()

		elseif args.type=="bgm" then
			Controller:forceBGMStop()
			Controller:enter

		elseif args.type=="quake" then
			Controller:forceQuakeStop()
			Controller:enter()

		elseif args.type=="se" then
			Controller:forceSEStop(args)
			Controller:enter()

		else
			Controller:enter()
		end
	end
end

function Controller:forceTrasitionStop()
	
end

function Controller:forceSEStop(args)
	local se=Controller.SeSet[args.buf].se
	se:stop()
end

function Controller:forceBGMStop()
	local bgm = Controller.bgmlayer
	bgm:stop()
end

function Controller:forceQuakeStop()
	root:flush()
end

function Controller:forceMoveStop()
	local move = Controller.movingLayer
	move:flush()
end

function Controller:forceVideoStop(args)
	local set = Controller.VideoSet[args.slot]
	local video = set.video
	local layer = set.layer
	local channel = set.channel
	Controller.videoChannel[channel]=nil
	video:stop()
	root:removeView(layer)
end




----------------------------
--掃描所有檔案進去cilent端--
----------------------------

function Controller:scanThis()
	
	Controller.AllResource={}
	local tmp = Controller.AllResource
	while parser:curEle()~=nil do
		local job = parser:curEle()

		if job.tag=="img" then table.insert(tmp,job.storage) end
	
		elseif job.tag=="image" then table.insert(tmp,job.storage) end
	
		elseif job.tag=="video" then
			if job.storage~=nil then table.insert(tmp,job.storage) end
		end
	
		elseif job.tag=="position" then 
			if job.frame~=nil then table.insert(tmp,job.frame) end
		end
	
		elseif job.tag=="openvideo" then 
			table.insert(tmp,job.storage)
		end
	
		elseif job.tag=="pimage" then table.insert(tmp,job.storage) end
	
		elseif job.tag=="playbgm" then table.insert(tmp,job.storage) end
	
		elseif job.tag=="playse" then table.insert(tmp,job.storage) end
	
		elseif job.tag=="playvideo" then 
			if job.storage~= nil then table.insert(tmp,job.storage) end
		end

		elseif job.tag=="glyph" then 
			if job.line~=nil then table.insert(tmp,job.line) end
		end
	
		elseif job.tag=="button" then 
			table.insert(tmp,job.graphic)
			if job.clickse~=nil then table.insert(tmp,job.clickse) end
			if job.enterse~=nil then table.insert(tmp,job.enterse) end
			if job.leavese~=nil then table.insert(tmp,job.leavese) end
		end

		elseif job.tag=="graph" then
			table.insert(tmp,job.storage)
		end

		parser:next()
	end
	parser:setPos(1)
	Controller.loadComplete=true
	app:prepareMedias(tmp,Controller.enter)
end


function Controller:waitEvent(args)
	if args.type=="bgm" and args.canskip==nil then args.canskip=false end
	if args.type=="move" and args.canskip==nil then args.canskip=true end
	if args.type=="quake" and args.canskip==nil then args.canskip=false end
	if args.type=="transition" and args.canskip==nil then args.canskip=true end
	if args.type=="video" and args.canskip==nil then args.canskip=false end
	if args.type=="se" and args.canskip==nil then args.canskip=false end

	if args.canskip==true or args.canskip=="true" then
		root:bind("click",{Controller, function self:continue(args) end})
		Controller.needwait=true
	else args.canskip==false or args.canskip=="false"then
		Controller.needwait=true
	end
end

function Controller:timeout_action(args)
	if args.sebuf==nil then args.sebuf=0 end

	if args.se~=nil and args.sebuf~=nil then
		local slot=Controller.SeSet[args.sebuf]
		local se = slot.se
		if slot.volume==nil then slot.volume=1 end

		se=Audio.Audio()	
		se:setVolume(slot.volume)
		se:setSrc(args.se)
		se:setLoop(false)
		se:seek(0)
		se:play()
		se:onFinish({Controller,function self:destroy(se) end})
	end

	Controller:jumpAction(args)
end

-----------初始化--------------
local parser = KAGParser(filename)
Controller.macros = parser:getMacros()

Controller.root=UI.View()
local root = Controller.root

Controller.loadComplete=false

root.left=(app.width-1024)/2
root.top=0

root:setSize(1024,768)
root:setPosition({top=root.top,left=root.left})
root:setBackgroundColor({a=1,r=0,g=0,b=0})


--Constructor建構子
function Controller:enter()
	if Controller.loadComplete==false then 
		Controller:scanThis()
	else
		while self:start() do end
	end
end

--遊戲執行
function Controller:start()
	local job = parser:curEle()
	if job==nil then return false end

	local result = handlers[job.tag]
	if result==nil then
		Controller:handleCustomMacro(job)
	else
		result(job)
	end
	parser:next()

	if Controller.needwait==true then return false else return true end
end


---------------------
----JUMP標籤動作-----
----args.storage-----
----args.target------
---------------------
function Controller:jumpAction(args)
	if filename==args.storage and args.target~=nil then
		local target = parser:jumpTo(args.target)
		if target==nil then error("Unknown jump tag"..args.target) else parser:setPos(target) end
		Controller:enter()

	elseif filename==args.storage and args.target==nil then
		parser:setPos(1)
		Controller:enter()

	elseif filename~=args.storage and args.target~=nil then
		parser=KAGParser(args.storage)
		local target = parser:jumpTo(args.target)
		if target==nil then error("Unknown jump tag:"..args.target) else parser:setPos(target) end
		parser=KAGParser(args.storage)
		
		Controller.loadComplete=false
		Controller.macros=parser:getMacros()
		app:releaseMedias(Controller.AllResource)
		Controller.AllResource={}
		Controller:enter()

	elseif filename~=args.storage and args.target==nil then
		parser=KAGParser(args.storage)
		parser:setPos(1)
		filename=args.storage
		parser=KAGParser(args.storage)

		Controller.macros=parser:getMacros()
		app:releaseMedias(Controller.AllResource)
		Controller.AllResource={}
		Controller.loadComplete=false
		Controller:enter()
	end

end

function Controller:utf8sub(str, startChar, numChars)
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
      local char = string.byte(str, startIndex)
      startIndex = startIndex + chsize(char)
      startChar = startChar - 1
  end
 
  local currentIndex = startIndex
 
  while numChars > 0 and currentIndex <= #str do
    local char = string.byte(str, currentIndex)
    currentIndex = currentIndex + chsize(char)
    numChars = numChars -1
  end
  return str:sub(startIndex, currentIndex - 1)
end

function Controller:resume()
	root:unbind("click",Controller.resume)
	Controller.needwait=false
	Controller:enter()
end

--先行離開並且等待點擊
function Controller:got_click()
	root:bind("click",Controller.resume)
	Controller.needwait=true
end

function Controller:deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

return Controller
