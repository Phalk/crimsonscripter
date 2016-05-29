--///////////////////////////////////
-------------------------------------
-- CRIMSON SCRIPTER
-- Author: 	Phalk
-- Web:		www.phalk.net
-- Version:	0.3b (02/20/2016)
-------------------------------------
--\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

-------------------------------------
-- GENERAL CONFIGURATION
-------------------------------------
-- Defines current directory
dir = System.currentDirectory().."/"
--dir = System.currentDirectory()

-- Loads up the Config.lua file
dofile(dir.."sys/config.lua")

-- Set up the default font
Font.setPixelSizes(defaultfont,fontsize)

-------------------------------------
-- GENERAL VARIABLE INITIALIZING
-------------------------------------
posline = marginy
oldpad = 0
debugtext = false
alertpos = marginy -- debug text initial position
playing = false
paused = false
soundduration = 0
screenshotnum = 0

timer = Timer.new() -- General-use timer

-------------------------------------
-- SCRIPT.TXT-RELATED VARIABLES
-------------------------------------
line = 0
bg = ""
music = ""
charleft = ""
charmiddle = ""
charright = ""
image = ""
waiting = false
textbgdrawn = false
miliseconds = 0

-----------------------------------------------
-- SYSTEM COMPONENTS INITIALIZATION
-----------------------------------------------
Sound.init() -- Initialize sound
dofile(dir.."sys/functions.lua") -- Loads general functions

-----------------------------------------------
-- SCRIPT.TXT LOADING AND BUFFERING
-----------------------------------------------

script = io.open(dir.."script.txt", FREAD)
filesize = io.size(script)
text = explode("\n",io.read(script,0,filesize))
io.close(script)

--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
-- FUNCTIONS SECTION START
--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

-- Double buffering fix
function db ()
		Screen.flip()
		Screen.refresh()
end

-- Wait function
function wait (ms)
Timer.reset(timer)
miliseconds = tonumber(ms)
waiting = true
end

-- Draws an image at the top screen
function image (img)
	--if (bg ~= "") then Screen.freeImage(bitmap) end
	bg = img
	bitmap = Screen.loadImage(dir..bg)
	Screen.drawImage(0,0,bitmap,TOP_SCREEN)
	db()
	Screen.drawImage(0,0,bitmap,TOP_SCREEN)
	refreshTop()
	Screen.freeImage(bitmap)
	
end

-- Draw the text background
function drawtextbg (s)
	--if drawtextbgdrawn then Screen.freeImage(textbgfile) end
	textbgfile = Screen.loadImage(dir..s)
	Screen.drawImage(0,0,textbgfile,BOTTOM_SCREEN)
	db()
	Screen.drawImage(0,0,textbgfile,BOTTOM_SCREEN)
	drawtextbgdrawn = true
	Screen.freeImage(textbgfile) 
end

-- Show a character in the left
function cleft (val)
	if (charleft == "") then charleft = val end
	if (System.doesFileExist(dir..charleft)) then
		chleft = Screen.loadImage(dir..val)
		chleftheight = Screen.getImageHeight(chleft)
		chlefty = 240 - chleftheight
		Screen.drawImage(marginx,chlefty,chleft,TOP_SCREEN)
		db()
		Screen.drawImage(marginx,chlefty,chleft,TOP_SCREEN)
		Screen.freeImage(chleft) 
	end
end

-- Show a character in the right
function cright (val)
	if (charright == "") then charright = val end
	if (System.doesFileExist(dir..charright)) then

		chright = Screen.loadImage(dir..val)
		chheight = Screen.getImageHeight(chright)
		chwidth = Screen.getImageWidth(chright)
		chy = 240 - chheight
		chx = 400 - chwidth
		Screen.drawImage(chx,chy,chright,TOP_SCREEN)
		db()
		Screen.drawImage(chx,chy,chright,TOP_SCREEN)
		Screen.freeImage(chright) 
	end
end

-- Show a character in the middle
function cmiddle (val)
	if (charmiddle == "") then charmiddle = val end
	if (System.doesFileExist(dir..charmiddle)) then
		chmiddle = Screen.loadImage(dir..val)
		chheight = Screen.getImageHeight(chmiddle)
		chwidth = Screen.getImageWidth(chmiddle)
		chy = 240 - chheight
		chx = 200 - math.floor(chwidth / 2)
		Screen.drawImage(chx,chy,chmiddle,TOP_SCREEN)
		db()
		Screen.drawImage(chx,chy,chmiddle,TOP_SCREEN)
		Screen.freeImage(chmiddle) 
	end
end

-- Removes sprites
function rm ()
	charmiddle = ""
	image(bg)
	refreshTop()
end
function rl ()
	charleft = ""
	image(bg)
	refreshTop()
end
function rr () 
	charright = ""
	image(bg)
	refreshTop()
end

-- Refresh Top Screen
function refreshTop()
	cleft(charleft)
	cmiddle(charmiddle)
	cright(charright)
end

-- Plays BGM
function bgm (bgmfile)
	if (System.doesFileExist(dir..bgmfile)) then
		if (playing == true) then stopbgm() end
		music = bgmfile
		bgm_song = Sound.openOgg(dir..bgmfile,true)
		Sound.play(bgm_song,LOOP)
		playing = true
	end
end

-- Stop BGM
function stopbgm ()
	if playing then 
		Sound.close(bgm_song) 
		Sound.pause(bgm_song)
		playing = false
	end
end

-- Play SOUND - TEMPORARILY DISABLED
-- function snd (sndfile,snddur)
	-- snd = Sound.openWav(dir..sndfile,false)
	-- Sound.play(snd,NO_LOOP)
	-- timersndclose = Timer.new()
	-- if (not snddur) then soundduration = 1000 else soundduration = tonumber(snddur) end
	-- soundplaying = true
-- end
function snd (sndfile, snddur) return end

-- String wordwrapping
function newline (text)
	strsize = string.len(text)
	if strsize > 0 then
		if (strsize >= mchr) then
			linecount = math.floor(strsize / mchr + 0.5)
			newlineblocksize = linecount*fontsize
			if (newlineblocksize+posline >= 240) then
				cleartext()
				newline(text)
				return 
			end
			printline = 0
			remainingtext = text
			
			while printline <= linecount+1 do
				paragraph = string.sub(remainingtext,0,mchr)
				ln = paragraph:find"%s$" or paragraph:find"%s%S-$" or mchr
				addline(string.sub(trim(remainingtext),0,ln))
				
				printline = printline+1
				remainingtext = string.sub(remainingtext,ln+1)
			end
		else
			addline(trim(text))
		end
	end
end


-- Script.txt parsing routine
function nextline()
	if (waiting == false) then
		line = line+1
		chr = string.sub(text[line],0,1)
		
		-- Script.txt # instructions
		if (chr == "#") then
			explosion = explode(" ",text[line])
			if (explosion[1] == "#bgm") then bgm(trim(explosion[2])) end
			if (explosion[1] == "#stopbgm") then stopbgm() end
			if (explosion[1] == "#bg") then image(trim(explosion[2])) end
			if (explosion[1] == "#cl") then cleft(trim(explosion[2])) end
			if (explosion[1] == "#cr") then cright(trim(explosion[2])) end
			if (explosion[1] == "#cm") then cmiddle(trim(explosion[2])) end
			if (trim(explosion[1]) == "#rm") then rm() end
			if (trim(explosion[1]) == "#rl") then rl() end
			if (trim(explosion[1]) == "#rr") then rr() end
			if (explosion[1] == "#snd") then snd(trim(explosion[2]),explosion[3]) end
			if (explosion[1] == "#page") then cleartext() end
			if (explosion[1] == "#center") then center(text[line],true) return end
			if (explosion[1] == "#right") then right(text[line],true) return end
			if (explosion[1] == "#append") then append(trim(explosion[2]),explosion[3]) return end
			if (explosion[1] == "#wait") then wait(trim(explosion[2])) return end
			nextline()
			return
		end
		
		if (chr == "\r") then
			addline(" ")
			nextline()
			return
		end
		
		if (chr == "$") then
			cleartext()
			Font.print(defaultfont, 5, 5, "-- THE END --", textcolor, TOP_SCREEN)
			db()
			Font.print(defaultfont, 5, 5, "-- THE END --", textcolor, TOP_SCREEN)
			line = line-1
			return
		end		
		newline(text[line])
	end
end


-- Add new lines of text
function addline(val)
	if (val ~= "" and val ~= nil) then 
		if (posline+fontsize <= 240) then
			Font.print(defaultfont, marginx, posline, val, textcolor, BOTTOM_SCREEN)
			db()
			Font.print(defaultfont, marginx, posline, val, textcolor, BOTTOM_SCREEN)
			posline = posline + fontsize
		else 
			cleartext()
			addline(val)
		end
	end
end

-- Print a line aligned to the right
function right (val,fromscript)
	if (posline+fontsize <= 240) then
		if (fromscript == true) then subtext = string.sub(val,8) else subtext = val end
		tmppos = (320 - marginx) - (string.len(subtext) * (fontsize/2))
		Font.print(defaultfont, tmppos, posline, trim(subtext), textcolor, BOTTOM_SCREEN)
		db()
		Font.print(defaultfont, tmppos, posline, trim(subtext), textcolor, BOTTOM_SCREEN)
		posline = posline + fontsize
	else 
		cleartext()
		addline(val)
	end
end

-- Print a line aligned to the center
function center (val,fromscript)
	if (posline+fontsize <= 240) then
		if (fromscript == true) then subtext = string.sub(val,8) else subtext = val end
		tmppos = (160) - ((string.len(subtext)) / 2) * (fontsize/2)
		Font.print(defaultfont, tmppos, posline, trim(subtext), textcolor, BOTTOM_SCREEN)
		db()
		Font.print(defaultfont, tmppos, posline, trim(subtext), textcolor, BOTTOM_SCREEN)
		posline = posline + fontsize
	else 
		cleartext()
		addline(val)
	end
end

-- Append image to text
function append (val,position)
	if (System.doesFileExist(dir..val)) then
		append = Screen.loadImage(dir..val)
		appendwidth = Screen.getImageWidth(append)
			if ((posline+Screen.getImageHeight(append)) > 240) then cleartext() end
			if position == nil then position = marginx end
			if string.match(position, "right") then position = 320 - appendwidth end
			if string.match(position, "center") then position = 160 - math.floor(appendwidth / 2) end
			Screen.drawImage(position,posline,append,BOTTOM_SCREEN)
			db()
			Screen.drawImage(position,posline,append,BOTTOM_SCREEN)
			posline = posline + Screen.getImageHeight(append)
			Screen.freeImage(append) 
	end
end

-- Clear and prepare to start a new page of text
function cleartext(arg)
	clearbottomscreen()
	db()
	clearbottomscreen()
	posline = marginy
	if (arg == 1) then -- if this arg is provided, it also clears the top screen
		Screen.clear(TOP_SCREEN)
		db()
		Screen.clear(TOP_SCREEN)
	end
end

-- Work around to avoid clearing the Text BG if there is one
function clearbottomscreen ()
	if usetextbg then
		drawtextbg(textbg)
	else
		Screen.clear(BOTTOM_SCREEN)
	end
end

-- Debug Alerts
function alert (alert)
	alertpos = alertpos+fontsize
	Screen.debugPrint(marginx, alertpos, alert, Color.new(255,0,0), TOP_SCREEN) 
	db()
	Screen.debugPrint(marginx, alertpos, alert, Color.new(255,0,0), TOP_SCREEN) 
	debugtext = true
end

-- Function for the A Button press
function buttonA ()
	if (debugtext == true) then -- Check if you had just saved then clear the "Saved!" message from top screen
		if (bg ~= "") then image(bg) else Screen.clear(TOP_SCREEN) end
		if (alertpos >= 120) then alertpos = 0 end
		debugtext = false
		return
	end
	if (titlescreen == true) then -- Checks if you are on the title screen and then does things
		titlescreen = false
		cleartext(1)
		stopbgm()
		Font.print(defaultfont, 5, 5, "Press START to save your progress.", textcolor, TOP_SCREEN)
		db()
		Font.print(defaultfont, 5, 5, "Press START to save your progress.", textcolor, TOP_SCREEN)
	end
	if usetextbg and not textbgdrawn then drawtextbg(textbg) textbgdrawn = true end -- text bg stuff
	nextline()
end


-- Save the game
function save ()
	savefile = io.open(dir.."save.sav",FCREATE)
	savestring = line.."#"..bg.."#"..music.."#"..charleft.."#"..charmiddle.."#"..charright.."#"
	savestringlen = string.len(savestring)
	io.write(savefile,0,savestring,savestringlen)
	io.close(savefile)
	Font.print(defaultfont, 180, 120, "Saved!", textcolor, TOP_SCREEN)
	db()
	Font.print(defaultfont, 180, 120, "Saved!", textcolor, TOP_SCREEN)
	debugtext = true
end

-- Load the saved game
function continue ()
	if System.doesFileExist(dir.."save.sav") then
		savefile = io.open(dir.."save.sav", FREAD)
		size = io.size(savefile)
		file = io.read(savefile,0,size)
		io.close(savefile)
		savearray = explode("#",file,size)
		
		cleartext(1)
		line = (tonumber(savearray[1])-1)
		bg = savearray[2]
		bgm(savearray[3])
		charleft = savearray[4]
		charmiddle = savearray[5]
		charright = savearray[6]
		image(bg)
		refreshTop()
		titlescreen = false
		buttonA()
	end
end

-- Unloads complements and quit the application
function quit ()
		--if (bg ~= "") then Screen.freeImage(bitmap) end
		--if (textbgdrawn) then Screen.freeImage(textbgfile) end
		if (bgm_song) then Sound.close(bgm_song) end
		Font.unload(defaultfont)
		Sound.term()
		System.exit()
end

function screenshot()
	screenshotnum = screenshotnum+1
	screenshotfile = dir.."screenshot"..screenshotnum..".jpg"
	if System.doesFileExist(screenshotfile) then return screenshot() end
	System.takeScreenshot(screenshotfile,true)
	Font.print(defaultfont, 5, 5, "Screenshot taken.", textcolor, TOP_SCREEN)
	db()
	Font.print(defaultfont, 5, 5, "Screenshot taken.", textcolor, TOP_SCREEN)
	timerfade = Timer.new()
	Timer.reset(timerfade)
	while true do if (Timer.getTime(timerfade) >= 2000) then image(bg) refreshTop() break end end
	
end

--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
-- FUNCTIONS SECTION END
--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
dofile(dir.."sys/titlescreen.lua") -- Sets the Title Screen

-----------------------------
-- SCRIPT.TXT STARTING POINT
-----------------------------
--newline(text[0])

----------------------
-- MAIN LOOP HURRAY!
----------------------
while true do
	Screen.refresh()
	
	-- Proceeds with the script.txt parsing after #wait is over
	if (waiting == true) then
		if (Timer.getTime(timer) >= miliseconds) then 
			waiting = false 
			nextline()
		end
	end
	
	-- Sound stuff
	if playing then Sound.updateStream() end
	if soundplaying then if Timer.getTime(timersndclose) >= soundduration then soundplaying = false soundduration = 0 Sound.close(snd) end end
	
	-- Title screen stuff
	if (titleimg == nil) then  
		image(title_img)
		titleimg = true 
	end

	-- Read controls
	pad = Controls.read() 
	
	-- HOME Button - Return to Homebrew
	if (Controls.check(Controls.read(),KEY_HOME)) then
		quit()
	end

	-- A Button
	if (Controls.check(pad,KEY_A)) and not (Controls.check(oldpad,KEY_A)) then
		buttonA()
	end
	
	-- R Button
	-- if (Controls.check(pad,KEY_R)) and not (Controls.check(oldpad,KEY_R)) then
		-- screenshot()
	-- end

	-- START Button
	if (Controls.check(pad,KEY_START)) and not (Controls.check(oldpad,KEY_START)) then
		if (titlescreen == false) then save() end
	end		
	
	-- SELECT Button
	if (Controls.check(pad,KEY_SELECT)) and not (Controls.check(oldpad,KEY_SELECT)) then
		if (titlescreen == true) then continue() end
	end	
	
	-- Screen stuff
	Screen.flip()
	Screen.waitVblankStart()

	oldpad = pad -- Variable to receive a button input only once per button press.
end