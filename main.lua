function love.load(args)
	if tableContains(args, "debug") then
		debug = true
	else
		debug = false
	end
	push = require "push"
	love.graphics.setDefaultFilter("nearest", "nearest")
	love.window.setTitle("Random Disaster Survival")
	truefalse_table = {false, true}
	scaling_methods = {"normal", "pixel-perfect", "stretched"}
	disaster = 0
	disasTimer = 0
	bg = love.graphics.newImage("image_assets/ground/bg.png")
	nightbg = love.graphics.newImage("image_assets/ground/nightbg.png")
	sunset = love.graphics.newImage("image_assets/ground/sunset.png")
	sideplat = love.graphics.newImage("image_assets/ground/miniplat.png")
	floatplat = love.graphics.newImage("image_assets/ground/floatplat.png")
	floor = love.graphics.newImage("image_assets/ground/floor.png")
	lava = love.graphics.newImage("image_assets/disaster_assets/lava.png")
	acid = love.graphics.newImage("image_assets/disaster_assets/acid.png")
	kaboom = love.graphics.newImage("image_assets/disaster_assets/kaboom.png")
	boomwarn = love.graphics.newImage("image_assets/disaster_assets/boomwarn.png")
	beam = love.graphics.newImage("image_assets/disaster_assets/BEAM.png")
	laser = love.graphics.newImage("image_assets/disaster_assets/laser.png")
	meteor = love.graphics.newImage("image_assets/disaster_assets/meteor.png")
	blackhole = love.graphics.newImage("image_assets/disaster_assets/black_hole_that_strangely_is_actually_orange_not_black.png")
	lightning = love.graphics.newImage("image_assets/disaster_assets/lightning.png")
	stormclouds = love.graphics.newImage("image_assets/disaster_assets/clouds.png")
	zombie = love.graphics.newImage("image_assets/disaster_assets/zombie.png")
	char = love.graphics.newImage("image_assets/chars/char_main.png")
	botchar = love.graphics.newImage("image_assets/chars/char_bot.png")
	warn = love.graphics.newImage("image_assets/ui_assets/warn.png")
	halo = love.graphics.newImage("image_assets/chars/halo.png")
	if tableContains(args, "marigold") then
		marigold = love.graphics.newImageFont("image_assets/ui_assets/marigold.png", " ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890!?.,#*x()<>:;/-=+v\\^", 1)
		love.graphics.setFont(marigold)
	else
		font = love.graphics.newImageFont("image_assets/ui_assets/font.png", " ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890!?.,#*x()<>:;/-=+v\\^", 1)
		love.graphics.setFont(font)
	end
	yesno_select = {"*", "v"}
	time_speeds_string = {"1/2", "1", "2", "3", "5", "10", "20", "30", "PAUSED"} 
	time_speeds_number = {0.5, 1, 2, 3, 5, 10, 20, 30, 1/0} --honestly idk if 1/0 for infinity is the *best* method here, but if it works it works on god
	warnquads = {love.graphics.newQuad(0, 0, 192, 32, 192, 288), love.graphics.newQuad(0, 32, 192, 32, 192, 288), love.graphics.newQuad(0, 64, 192, 32, 192, 288), love.graphics.newQuad(0, 96, 192, 32, 192, 288), love.graphics.newQuad(0, 128, 192, 32, 192, 288), love.graphics.newQuad(0, 160, 192, 32, 192, 288), love.graphics.newQuad(0, 192, 192, 32, 192, 288), love.graphics.newQuad(0, 224, 192, 32, 192, 288), love.graphics.newQuad(0, 256, 192, 32, 192, 288)}
	modifiers = {"MINI PLAYERS", "LOW GRAVITY", "HIGH GRAVITY", "MISSING PLATFORM", "GIANT PLAYERS"}
	jumpaudio = love.audio.newSource("audio_assets/why_does_this_kinda_sound_like_super_mario_world_jump.wav", "static")
	jump_sound_check = 0
	explodeaudio = love.audio.newSource("audio_assets/boom.wav", "static")
	warnaudio = love.audio.newSource("audio_assets/warn.wav", "static")
	deathaudio = love.audio.newSource("audio_assets/owie.wav", "static")
	meteoraudio = love.audio.newSource("audio_assets/meteor_strike.wav", "static")
	zapaudio = love.audio.newSource("audio_assets/zap.wav", "static")
	lightningaudio = love.audio.newSource("audio_assets/lightning.wav", "static")
	platwidth, platheight, platx, platy = 192, 37267, 0, 112 --37267 because maximum value of a 16-bit signed integer is BORING (also if you're reading this: sorry in advance for the code you're soon to read)
	leftplatwidth, leftplatheight, leftplatx, leftplaty = 48, 4, 0, 80
	rightplatwidth, rightplatheight, rightplatx, rightplaty = 48, 4, 144, 80
	floatplatwidth, floatplatheight, floatplatx, floatplaty, floatplatdir, floatplatpause, enableFloatPlat = 32, 9, 80, 64, 1, 0, true
	playwidth, playheight, playx, playy, playspeed, playvel, grav, playjump, playdir = 10, 21, (platwidth / 2)-5, 0, 100, 0, 100, 50, "left"
	botwidth, botheight, botx, boty, botspeed, botvel, botjump, botdir, botact, bottime = 10, 21, (platwidth / 2)-5, 0, 100, 0, 50, "left", 0, 3
	zombwidth, zombheight, zombx, zomby, zombspeed, zombvel, zombjump, zombdir, zombact, zombtime = 10, 21, (platwidth / 2)-5, 0, 75, 0, 50, "left", 0, 3
	lavawidth, lavaheight, lavax, lavay = 0, 0, -999, -999
	boomwidth, boomheight, boomx, boomy, boomactive, boomcount = 0, 0, -999, -999, false, 0
	beamwidth, beamheight, beamx, beamy = 0, 0, -999, -999
	meteorx, meteory, meteorwidth, meteorheight, meteorvel, meteorcount = -999, -999, 0, 0, 0, 0
	disaster_Stored = 0
	paused = false
	optionsMenu = false
	shopMenu = false
	buyMenu = false
	pausemenu_highlight = 0
	dead, botdead = 0, 0
	love.filesystem.setIdentity("random_disaster_survival", true)
	if love.filesystem.getInfo("savedata") == nil or tableContains(args, "reset_save_data_like_really_i_want_to_this_text_is_this_long_to_guarantee_i_intended_this") then
		file = love.filesystem.newFile("savedata", "w")
		file:write("0\n0\n0\n1\n1\n1\n6\nfalse\n0\n0\n5")
		file:close()
	end
	savetable = {}
	savecounter = 0
	for line in love.filesystem.lines("savedata") do
		savecounter = savecounter+1
		savetable[savecounter] = line
	end
	wins = tonumber(savetable[1])
	print(savetable[1])
	deaths = tonumber(savetable[2])
	print(savetable[2])
	coins = tonumber(savetable[3])
	print(savetable[3])
	fullscreen = tonumber(savetable[4])
	print(savetable[4])
	if tableContains(args, "fullscreen") then
		fullscreen = 2
		forcefullscreen = true
	end
	scaling_method = tonumber(savetable[5])
	print(savetable[5])
	bot_toggle = tonumber(savetable[6])
	print(savetable[6])
	time_speed = tonumber(savetable[7])
	print(savetable[7])
	print(time_speeds_string[time_speed])
	hardcore = savetable[8]
	print(savetable[8])
	hardcorewins = tonumber(savetable[9])
	print(savetable[9])
	hardcorehighscore = tonumber(savetable[10])
	print(savetable[10])
	disastDelay = tonumber(savetable[11])
	print(savetable[11])
	guh = love.math.random(0,100)
	if guh <= 10 then 
		char = love.graphics.newImage("image_assets/chars/char_main_2.png") 
	end
	love.window.setMode(1280, 720, {resizable=true})
	love.window.setFullscreen(truefalse_table[fullscreen])
	push.setupScreen(192, 144, {upscale = scaling_methods[scaling_method]})
	scaling_select = {"FULL", "PIXEL PERFECT", "STRETCHED"}
	scaledesc_line1 = {"SCALES GAME TO MAXIMUM SIZE WHILE KEEPING ASPECT", "SCALES GAME TO A MULTIPLE (2x, 3x), AVOIDING BLURRY ", "STRETCHES GAME TO FILL WHOLE SCREEN"}
	scaledesc_line2 = {"RATIO", "PIXEL EDGES", "(I, THE DEV, HAVE BEEF WITH YOU IF YOU USE THIS)"} 
	debug_disaster_number = 0
	border = love.graphics.newImage("image_assets/ui_assets/border.png")
	previous_disaster = 0
	worldR = 1 
	worldG = 1 
	worldB = 1
	starTransparency = 0
	sunsetTransparency = 0
	lasersx, lasersy, lasersw, lasersh = {-999,-999}, {-999,-999}, 0, 0 --16, 8
	hardcoredead = false
	death_messages_1 = {"SKILL ISSUE", "GG EZ", "R.I.P.", "CANT BELIEVE THAT KILLED", "WOMP WOMP", "EVER HEARD OF LIVING?", "NO WAY YOU DIED TO", "TRY DODGING NEXT TIME"}
	disastNamesThatWillOnlyBeUsedInTheDeathMessage = {"LAVA", "AN EXPLOSION", "A LASERBEAM", "ACID", "A METEOR", "A BLACK HOLE", "LASERS", "LIGHTNING", "A ZOMBIE"}
	death_messages_2 = {"", "", "", "YOU", "",  "TRY IT NEXT TIME.", disastNamesThatWillOnlyBeUsedInTheDeathMessage[disaster], ""}
	modifier = 0
	lightningx, lightningy = -999, -999
	guardian_angel = 1
	guardian_angel_active = 1
end

function moveToward(x1, y1, x2, y2, speed, deltaTime)
	angle = math.atan2(y1-y2, x1-x2)
	return x1 - math.cos(angle)*speed*deltaTime, y1 - math.sin(angle)*speed*deltaTime
end
function distanceBetweenPoints ( x1, y1, x2, y2 )
	local dx = x1 - x2
	local dy = y1 - y2
	return math.sqrt ( dx * dx + dy * dy )
  end
  

function tableContains(table, content)
	if table ~= nil then
		for _, v in pairs(table) do
			if v == content then
				return true
			end
		end
	end
end

function love.quit()
	success, err = love.filesystem.write("savedata", wins.."\n"..deaths.."\n"..coins.."\n"..fullscreen.."\n"..scaling_method.."\n"..bot_toggle.."\n"..time_speed.."\n"..hardcore.."\n"..hardcorewins.."\n"..hardcorehighscore.."\n"..disastDelay)
	return not success
end

function CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2)
	return x1 < x2+w2 and
		   x2 < x1+w1 and
		   y1 < y2+h2 and
		   y2 < y1+h1
end

function love.keypressed(key, sc, isrepeat)
	if hardcoredead and not isrepeat then
		love.event.quit(0)
	end
	if key=='escape' and isrepeat ~= 'true' then
		if paused then
			if optionsMenu or shopMenu then
				optionsMenu, shopMenu = false, false
				pausemenu_highlight = 0
			else
				paused = false
			end
		else
			paused = true
			optionsMenu, shopMenu = false, false
			pausemenu_highlight = 0
		end
	end
	if paused then
		if optionsMenu then
			maxPauseOptions = 5
		elseif shopMenu then
			maxPauseOptions = 1
		else
			maxPauseOptions = 3
		end
		if key=="down" and isrepeat ~= 'true' then
			pausemenu_highlight = pausemenu_highlight + 1
			if pausemenu_highlight > maxPauseOptions then 
				pausemenu_highlight = 0
			end
		end
		if key=="up" and isrepeat ~= 'true' then
			pausemenu_highlight = pausemenu_highlight - 1
			if pausemenu_highlight < 0 then 
				pausemenu_highlight = maxPauseOptions
			end
		end
		if optionsMenu then
			if (key=="left" or key=="a") and isrepeat~= 'true' then
				if pausemenu_highlight == 0 then
					scaling_method = scaling_method - 1
					if scaling_method < 1 then 
						scaling_method = 3
					end
					push.setupScreen(192, 144, {upscale = scaling_methods[scaling_method]}) 
				elseif pausemenu_highlight == 1 and not forcefullscreen then
					if fullscreen == 1 then 
						fullscreen = 2 
					else
						fullscreen = 1 
					end
					love.window.setFullscreen(truefalse_table[fullscreen])
					push.setupScreen(192, 144, {upscale = scaling_methods[scaling_method]})   
				elseif pausemenu_highlight == 2 then
					if bot_toggle == 1 then 
						bot_toggle = 2 
					else 
						bot_toggle = 1 
					end   
				elseif pausemenu_highlight == 3 then
					time_speed = time_speed - 1
					if time_speed < 1 then 
						time_speed = 9
					end
				elseif pausemenu_highlight == 4 then
					if hardcore == "true" then 
						hardcore = "false" 
					else
						hardcore = "true"
					end
				elseif pausemenu_highlight == 5 then
					disastDelay = disastDelay - 1
					if disastDelay < 2 then 
						disastDelay = 10
					end
				end
			end
			if (key=="right" or key=="d" or key=="return" or key=="space" or key=="z") and isrepeat~= 'true' then
				if pausemenu_highlight == 0 then
					scaling_method = scaling_method + 1
					if scaling_method > 3 then 
						scaling_method = 1
					end
					push.setupScreen(192, 144, {upscale = scaling_methods[scaling_method]})  
				elseif pausemenu_highlight == 1 and not forcefullscreen then
					if fullscreen == 1 then 
						fullscreen = 2 
					else
						fullscreen = 1 
					end
					love.window.setFullscreen(truefalse_table[fullscreen])
					push.setupScreen(192, 144, {upscale = scaling_methods[scaling_method]})   
				elseif pausemenu_highlight == 2 then
					if bot_toggle == 1 then 
						bot_toggle = 2 
					else 
						bot_toggle = 1 
					end 
				elseif pausemenu_highlight == 3 then
					time_speed = time_speed + 1
					if time_speed > 9 then 
						time_speed = 1
					end  
				elseif pausemenu_highlight == 4 then
					if hardcore == "true" then 
						hardcore = "false" 
					else
						hardcore = "true"
					end
				elseif pausemenu_highlight == 5 then
					disastDelay = disastDelay + 1
					if disastDelay > 10 then 
						disastDelay = 2
					end
				end
				if (key=="return" or key=="z" or key=="space") and isrepeat~= 'true' then
					if pausemenu_highlight==6 then
						optionsMenu = false
					end
				end
			end
		end
		if shopMenu then
			if buyMenu then
				if (key=="return" or key=="z" or key=="space") and isrepeat~= 'true' then
					if coins >= 15 then
						coins = coins - 15
						guardian_angel = guardian_angel + 1
					end
					buyMenu = false
				end
				if (key=="escape" or key=="backspace") and isrepeat~= 'true' then
					--Dont
					buyMenu = false
				end
			else
				if (key=="right" or key=="d" or key=="left" or key=="a") and isrepeat~= 'true' then
					if pausemenu_highlight == 0 then
						if guardian_angel_active == 1 and guardian_angel >= 1 then 
							guardian_angel_active = 2
						else
							guardian_angel_active = 1 
						end
					end
				end
				if (key=="return" or key=="z" or key=="space") and isrepeat~= 'true' then
					buyMenu = true
				end
			end
		end
		if not optionsMenu and not shopMenu then 
			if (key=="return" or key=="z" or key=="space") and isrepeat~= 'true' then
				if pausemenu_highlight==3 then
					love.event.quit(0)
				elseif pausemenu_highlight==2 then
					paused = false
				elseif pausemenu_highlight==1 then
					shopMenu = true
					pausemenu_highlight = 0
				elseif pausemenu_highlight==0 then
					optionsMenu = true
					pausemenu_highlight = 0
				end
			end
		end
	end
end

function stopDisaster()
	disasTimer = 0
	if disaster == 1 then			-- disaster.... outitialization??? tasks (e.g. zeroing out the lava variables so you dont die post-lava) go here
		lavawidth, lavaheight, lavax, lavay = 0, 0, -999, -999
	elseif disaster == 3 then
		beamwidth, beamheight, beamx, beamy = 0, 0, -999, -999
	elseif disaster == 4 then
		lavawidth, lavaheight, lavax, lavay = 0, 0, -999, -999
		platwidth, platheight, platx, platy = 192, 48, 0, 112
		leftplatwidth, leftplatheight, leftplatx, leftplaty = 48, 4, 0, 80
		rightplatwidth, rightplatheight, rightplatx, rightplaty = 48, 4, 144, 80
	elseif disaster == 7 then
		lasersx, lasersy, lasersw, lasersh = {-999,-999,-999}, {-999,-999,-999}, 0, 0 
	end
	if modifier == 1 or modifier == 5 then --modifier un-modifying tasks
		playwidth, playheight = 10, 21
		botwidth, botheight = 10, 21
		zombwidth, zombheight = 10, 21
	elseif modifier == 2 or modifier == 3 then
		grav = 100
	elseif modifier == 4 then
		enableFloatPlat = true
	end
	previous_disaster = disaster
	disaster = 0
	modifier = 0
	if dead ~= 0 then
		deaths = deaths+1
		dead = 0
	else
		if hardcore=="true" then
			hardcorewins = hardcorewins+1
			if guardian_angel_used then
				coins = coins + math.floor(love.math.random(3,7) / 2)
			else
				coins = coins + love.math.random(3,7)
			end
		else
			wins = wins+1
			if guardian_angel_used then
				coins = coins + math.floor(love.math.random(1,5) / 2)
			else
				coins = coins + love.math.random(1,5)
			end
		end
	end
	if botdead ~= 0 then
		botdead = 0
	end
	if guardian_angel_active == 2 then
		guardian_angel = guardian_angel - 1
		if guardian_angel <= 0 then
			guardian_angel_active = 1
		end
	end
end

function love.update(dt)
if not hardcoredead and not paused then
	time = (time or 0)+dt/time_speeds_number[time_speed]
	if (time or 0) <=60 then
		worldR = ((4-(0.57*(time*(0.0666666))))/4) --why does any of this code work i'm so confused
		worldG = ((3-(0.61*(time*(0.0500000))))/3)
		worldB = ((2-(0.53*(time*(0.0333333))))/2)
		sunsetTransparency = -0.5 + time*(0.0666666)
		starTransparency = -1 + time*(0.0333333)
	elseif time >= 60 and time <= 120 then
		worldR = 0.86 - ((4-(0.57*(time*(0.0666666))))/4)
		worldG = 0.76 - ((3-(0.61*(time*(0.0500000))))/3)
		worldB = 0.94 - ((2-(0.53*(time*(0.0333333))))/2)
		sunsetTransparency = 8 - time*(0.0666666) --"why have you done it like thi"-- shhh..... don't bother the horrors beyond comprehension
		starTransparency = 3 - time*(0.0333333)
	else 
		time = 0
	end
	if floatplatpause <= 0 then
		floatplatx = floatplatx + (50*floatplatdir)*dt
		if floatplatx >= 112 then
			floatplatdir = -1
			floatplatpause = 1
			floatplatx = 112
		elseif floatplatx <= 48 then
			floatplatdir = 1
			floatplatpause = 1
			floatplatx = 48
		end
	else
		floatplatpause = floatplatpause - dt
	end
if disaster == 0 then
	disasTimer = disasTimer + dt
	if disasTimer >= disastDelay-2 then
		if disaster_Stored == 0 then
			love.audio.play(warnaudio)
			disaster_Stored = love.math.random(1, 9)
			while disaster_Stored == previous_disaster do
				disaster_Stored = love.math.random(1, 9)
		    end
			if love.math.random(1, 10) == 10 then
				modifier = love.math.random(1,5)
				while disaster_Stored == 4 and modifier == 4 do
					love.math.random(1,5)
				end
			end
		end
		if disasTimer >= disastDelay then
			disaster = disaster_Stored
			disaster_Stored = 0
			disasTimer = 0
			-- modifier tasks
			if modifier == 1 then
				playwidth, playheight = 7.5, 15.75
				botwidth, botheight = 7.5, 15.75
				zombwidth, zombheight = 7.5, 15.75
			elseif modifier == 2 then
				grav = 25
			elseif modifier == 3 then
				grav = 175
			elseif modifier == 4 then
				enableFloatPlat = false
			elseif modifier == 5 then
				playwidth, playheight = 12.5, 26.25
				botwidth, botheight = 12.5, 26.25
				zombwidth, zombheight = 12.5, 26.25
			end
			-- disaster initialization tasks (e.g. making/setting variables) go here
			if disaster == 1 then
				lavawidth, lavaheight, lavax, lavay = 192, 64, 0, 120
			elseif disaster == 2 then
				boomcount = 0
			elseif disaster == 3 then
				beamwidth, beamheight, beamx, beamy, beamdir, beamloops = 16, 144, 20, 0, 1, 0
			elseif disaster == 4 then
					lavawidth, lavaheight, lavax, lavay = 192, 64, 0, 120
			elseif disaster == 5 then
				    meteorx, meteory, meteorwidth, meteorheight, meteorvel, meteorcount = love.math.random(0, 164), 0, 16, 16, 0, 0
			elseif disaster == 6 then
					disasTimer = 0
			        endBlackHoleTimer = 0
			elseif disaster == 7 then
					disasTimer = 0
					love.audio.play(zapaudio)
					lasersx, lasersy, lasersw, lasersh = {200,300}, {love.math.random(16,96), love.math.random(16,96)}, 16, 8
			elseif disaster == 8 then
				lightningTimer = 0
				lightningActive = false
				lightningx = -999
				lightCount = 0
			elseif disaster == 9 then
				disasTimer = 0
				zombx, zomby, zombdir, zombact, zombtime = (platwidth / 2)-5, 0, "left", 0, 3
			end
		end
		
	end
else
	-- main disaster tasks (e.g. changing variables) go here
	if disaster == 1 then
		if disasTimer >= 2 and lavay > 88 then
			lavay = lavay - dt*25
		else
			disasTimer = disasTimer + dt
			if disasTimer >= 5 then
				stopDisaster()
			end
		end
	elseif disaster == 2 then
		disasTimer = disasTimer + dt
		if disasTimer >= 1 then
			if boomwidth == 0 then
			 	boomx, boomy, boomwidth, boomheight, boomactive = love.math.random(0, 160), love.math.random(32, 112), 32, 32, false
			end
			if disasTimer >= 2 then
				boomactive = true
				love.audio.play(explodeaudio)
				if disasTimer >= 3 then
					boomwidth, boomheight, boomx, boomy, boomactive = 0, 0, 0, 0, false
					disasTimer = 0
					boomcount = boomcount + 1
					if boomcount >= 5 then
						stopDisaster()
					end
				end
			end
		end
	elseif disaster == 3 then
		beamx = beamx + (150*beamdir)*dt
		if beamx >= 156 then
			beamdir = -1
		elseif beamx <= 20 then
			beamdir = 1
			beamloops = beamloops+1
			if beamloops == 5 then
				stopDisaster()
			end
		end
	elseif disaster == 4 then
		platy, leftplaty, rightplaty = platy + dt*10, leftplaty + dt*10, rightplaty + dt*10
		if disasTimer >= 2 and lavay > 80 then
			lavay = lavay - dt*40
		else
			disasTimer = disasTimer + dt
			if disasTimer >= 5 then
				stopDisaster()
			end
		end
	elseif disaster == 5 then
		meteorvel = meteorvel + grav * dt
		meteory = meteory + meteorvel * dt
		if (CheckCollision(floatplatx, floatplaty, floatplatwidth, floatplatheight, meteorx, meteory, meteorwidth, meteorheight) and enableFloatPlat) or CheckCollision(platx, platy, platwidth, platheight, meteorx, meteory, meteorwidth, meteorheight) or CheckCollision(rightplatx, rightplaty, rightplatwidth, rightplatheight, meteorx, meteory, meteorwidth, meteorheight) or CheckCollision(leftplatx, leftplaty, leftplatwidth, leftplatheight, meteorx, meteory, meteorwidth, meteorheight) then
			meteorx, meteory, meteorwidth, meteorheight, meteorvel, meteorcount = love.math.random(0, 164), -16, 16, 16, 0, meteorcount + 1
			love.audio.play(meteoraudio)
			if meteorcount >= 10 then
				stopDisaster()
			end
		end
	elseif disaster == 6 then
		if disasTimer < 5 then
			disasTimer = disasTimer + dt
		else
			endBlackHoleTimer = endBlackHoleTimer + dt
			if endBlackHoleTimer > 5 then
				stopDisaster()
			end
		end
		playx, playy = moveToward(playx, playy, 96-(playwidth/2), 64-(playheight/2), playspeed/1.5+((math.abs(disasTimer)+disasTimer)), dt)
		botx, boty = moveToward(botx, boty, 96-(botwidth/2), 64-(botheight/2), botspeed/1.5+((math.abs(disasTimer)+disasTimer)), dt)
	elseif disaster == 7 then
		disasTimer = disasTimer + dt
		lasersx = {lasersx[1]-(90*dt), lasersx[2]-(90*dt)}
		if lasersx[1] <= -16 then
			love.audio.play(zapaudio)
			lasersx[1], lasersy[1] = 200, love.math.random(16,96)
		end
		if lasersx[2] <= -16 then
			love.audio.play(zapaudio)
			lasersx[2], lasersy[2] = 200, love.math.random(16,96)
		end
		if disasTimer >= 20 then
			stopDisaster()
		end
	elseif disaster == 8 then
		lightningTimer = lightningTimer + dt
		if lightningTimer >=0.5 and lightningx == -999 then
			lightningx = math.random(0, 168)
			if lightningx > 48 and lightningx < 144 then
				lightningy = 112
			else
				lightningy = 80
			end
			lightningWarn = true
		elseif lightningTimer >= 1 and lightningActive == false then
			lightningWarn = false
			lightningActive = true
			love.audio.play(lightningaudio)
		elseif lightningTimer >= 1.5 then
			lightningTimer = 0
			lightningActive = false
			lightningx = -999
			lightCount = lightCount+1
			if lightCount >= 10 then
				stopDisaster()
			end
		end
	elseif disaster == 9 then
		disasTimer = disasTimer + dt
		if disasTimer >= 10 then
			stopDisaster()
		end
		if (CheckCollision(floatplatx, floatplaty, floatplatwidth, floatplatheight, zombx, zomby, zombwidth, zombheight) and enableFloatPlat)  or CheckCollision(platx, platy, platwidth, platheight, zombx, zomby, zombwidth, zombheight) or CheckCollision(rightplatx, rightplaty, rightplatwidth, rightplatheight, zombx, zomby, zombwidth, zombheight) or CheckCollision(leftplatx, leftplaty, leftplatwidth, leftplatheight, zombx, zomby, zombwidth, zombheight) then
			zombvel = 0
			if CheckCollision(platx, platy, platwidth, platheight, zombx, zomby, zombwidth, zombheight) then
				zomby = platy - zombheight
			end
			if (CheckCollision(floatplatx, floatplaty, floatplatwidth, floatplatheight, zombx, zomby, zombwidth, zombheight) and enableFloatPlat) and floatplatpause <=0 then
				zombx = zombx + (50*floatplatdir)*dt
			end
		else
			zombvel = zombvel + grav * dt
			zomby = zomby + zombvel * dt
			if jump_sound_check == 1 then
				jump_sound_check = 0
			end
		end
		if zombtime <= 0 then
			if zombact ~= 0 then
				zombact = 0
				zombtime = love.math.random(1.0, 2.0)
			else
				zombact = love.math.random(1, 3)
				zombtime = love.math.random(0.5, 2.0)
			end
		else
		if zombact == 0 then
			zombtime = zombtime - dt
		elseif zombact == 1 then
			zombtime = zombtime - dt
			zombx = zombx - (zombspeed * dt)    -- The zomb moves to the left.
			zombdir = "left"
			if zombx < -1 then 
				zombact = 2
			end
		elseif zombact == 2 then
			zombtime = zombtime - dt
			zombx = zombx + (zombspeed * dt)
			zombdir = "right"
			if zombx+(9*(zombwidth/10)) > 192 then
				zombact = 1
			end
		elseif zombact == 3 then
			if (CheckCollision(floatplatx, floatplaty, floatplatwidth, floatplatheight, zombx, zomby, zombwidth, zombheight) and enableFloatPlat) or CheckCollision(platx, platy, platwidth, platheight, zombx, zomby, zombwidth, zombheight) or CheckCollision(rightplatx, rightplaty, rightplatwidth, rightplatheight, zombx, zomby, zombwidth, zombheight) or CheckCollision(leftplatx, leftplaty, leftplatwidth, leftplatheight, zombx, zomby, zombwidth, zombheight) then
				zombvel = zombjump*-1
				zomby = zomby + zombvel * dt
				if jump_sound_check == 0 then
					success = love.audio.play(jumpaudio)
					jump_sound_check = 1
				end
			end
			zombact = 0
		end
	end
	end
end
	-- This is how to assign keyboard inputs.
if love.keyboard.isDown('d', 'right') then                    -- When the player presses and holds down the "D" button:
	playx = playx + (playspeed * dt)
	playdir = "right"
	if playx+(9*(playwidth/10)) > 192 then
		playx = playx - (playspeed * dt)
	end
end
if love.keyboard.isDown('a', 'left') then                -- When the player presses and holds down the "A" button:
	playx = playx - (playspeed * dt)    -- The player moves to the left.
	playdir = "left"
	if playx < -1 then 
		playx = playx + (playspeed * dt)
	end
end
if (CheckCollision(floatplatx, floatplaty, floatplatwidth, floatplatheight, playx, playy, playwidth, playheight) and not love.keyboard.isDown('s', 'down') and enableFloatPlat) or CheckCollision(platx, platy, platwidth, platheight, playx, playy, playwidth, playheight) or (CheckCollision(rightplatx, rightplaty, rightplatwidth, rightplatheight, playx, playy, playwidth, playheight) and not love.keyboard.isDown('s', 'down')) or (CheckCollision(leftplatx, leftplaty, leftplatwidth, leftplatheight, playx, playy, playwidth, playheight) and not love.keyboard.isDown('s', 'down')) then
	playvel = 0
	if CheckCollision(platx, platy, platwidth, platheight, playx, playy, playwidth, playheight) then
		playy = platy -  playheight
	end
	if CheckCollision(floatplatx, floatplaty, floatplatwidth, floatplatheight, playx, playy, playwidth, playheight) and floatplatpause <=0 then
		playx = playx + (50*floatplatdir)*dt
	end
	if love.keyboard.isDown('space', 'z', 'w', 'up') then
		playvel = playjump*-1
		playy = playy + playvel * dt
		if jump_sound_check == 0 then
			success = love.audio.play(jumpaudio)
			jump_sound_check = 1
		end
	end
	
else
	playvel = playvel + grav * dt
	playy = playy + playvel * dt
	if jump_sound_check == 1 then
		jump_sound_check = 0
	end
end
if playy >= 144 or ( (CheckCollision(zombx, zomby, zombwidth, zombheight, playx, playy, playwidth, playheight) and disaster==9) or (CheckCollision(lightningx, lightningy-144, 24, 144, playx, playy, playwidth, playheight) and lightningActive) or  CheckCollision(lasersx[2]+2, lasersy[2]+2, lasersw-4, lasersh-4, playx, playy, playwidth, playheight) or CheckCollision(lasersx[1]+2, lasersy[1]+2, lasersw-4, lasersh-4, playx, playy, playwidth, playheight) or (CheckCollision(96-((16*disasTimer)/2), 72-((16*disasTimer)/2), disasTimer*16, disasTimer*16, playx, playy, playwidth, playheight) and disaster==6) or (CheckCollision(boomx, boomy, boomwidth, boomheight, playx, playy, playwidth, playheight) and boomactive) or CheckCollision(meteorx, meteory, meteorwidth, meteorheight, playx, playy, playwidth, playheight) or CheckCollision(lavax, lavay, lavawidth, lavaheight, playx, playy, playwidth, playheight) or CheckCollision(beamx, beamy, beamwidth, beamheight, playx, playy, playwidth, playheight) ) and dead~=1 then 
	if guardian_angel_active and not guardian_angel_used then
		guardian_angel_used = true
	else
	if hardcore == "true" then
		death_message = love.math.random(1, #death_messages_1)
		death_messages_2[7] = disastNamesThatWillOnlyBeUsedInTheDeathMessage[disaster]
		hardcoredead = true
		love.audio.stop()
		hardcorewins_Stored = hardcorewins
		if hardcorewins > hardcorehighscore then
			hardcorehighscore = hardcorewins
			newHigh = true
		else
			newHigh = false
		end
		hardcorewins = 0
		coins = math.floor(coins/2)
		love.audio.play(deathaudio)
	else
		love.audio.play(deathaudio)
   		dead, playx, playy = 1, (platwidth / 2)-8, 0
	end
	end
end
if (CheckCollision(floatplatx, floatplaty, floatplatwidth, floatplatheight, botx, boty, botwidth, botheight) and enableFloatPlat)  or CheckCollision(platx, platy, platwidth, platheight, botx, boty, botwidth, botheight) or CheckCollision(rightplatx, rightplaty, rightplatwidth, rightplatheight, botx, boty, botwidth, botheight) or CheckCollision(leftplatx, leftplaty, leftplatwidth, leftplatheight, botx, boty, botwidth, botheight) then
	botvel = 0
	if CheckCollision(platx, platy, platwidth, platheight, botx, boty, botwidth, botheight) then
		boty = platy - botheight
	end
	if CheckCollision(floatplatx, floatplaty, floatplatwidth, floatplatheight, botx, boty, botwidth, botheight) and floatplatpause <=0 then
		botx = botx + (50*floatplatdir)*dt
	end
else
	botvel = botvel + grav * dt
	boty = boty + botvel * dt
	if jump_sound_check == 1 then
		jump_sound_check = 0
	end
end
if boty >= 144 or ((CheckCollision(zombx, zomby, zombwidth, zombheight, botx, boty, botwidth, botheight) and disaster==9) or (CheckCollision(lightningx, lightningy-144, 24, 144, botx, boty, botwidth, botheight) and lightningActive) or CheckCollision(lasersx[2]+2, lasersy[2]+2, lasersw-4, lasersh-4, botx, boty, botwidth, botheight) or CheckCollision(lasersx[1]+2, lasersy[1]+2, lasersw-4, lasersh-4, botx, boty, botwidth, botheight) or (CheckCollision(96-((16*disasTimer)/2), 72-((16*disasTimer)/2), disasTimer*16, disasTimer*16, botx, boty, botwidth, botheight) and disaster==6) or (CheckCollision(boomx, boomy, boomwidth, boomheight, botx, boty, botwidth, botheight) and boomactive) or CheckCollision(meteorx, meteory, meteorwidth, meteorheight, botx, boty, botwidth, botheight) or CheckCollision(lavax, lavay, lavawidth, lavaheight, botx, boty, botwidth, botheight) or CheckCollision(beamx, beamy, beamwidth, beamheight, botx, boty, botwidth, botheight) ) and botdead~=1 then 
	love.audio.play(deathaudio)
    botdead, botx, boty = 1, (platwidth / 2)-8, 0
end
if bottime <= 0 then
	if botact ~= 0 then
		botact = 0
		bottime = love.math.random(1.0, 2.0)
	else
		botact = love.math.random(1, 3)
		bottime = love.math.random(0.5, 2.0)
	end
else
if botact == 0 then
	bottime = bottime - dt
elseif botact == 1 then
	bottime = bottime - dt
	botx = botx - (botspeed * dt)    -- The bot moves to the left.
	botdir = "left"
	if botx < -1 then 
		botact = 2
	end
elseif botact == 2 then
	bottime = bottime - dt
	botx = botx + (botspeed * dt)
	botdir = "right"
	if botx+(9*(botwidth/10)) > 192 then
		botact = 1
	end
elseif botact == 3 then
	if (CheckCollision(floatplatx, floatplaty, floatplatwidth, floatplatheight, botx, boty, botwidth, botheight) and enableFloatPlat)  or CheckCollision(platx, platy, platwidth, platheight, botx, boty, botwidth, botheight) or CheckCollision(rightplatx, rightplaty, rightplatwidth, rightplatheight, botx, boty, botwidth, botheight) or CheckCollision(leftplatx, leftplaty, leftplatwidth, leftplatheight, botx, boty, botwidth, botheight) then
		botvel = botjump*-1
		boty = boty + botvel * dt
		if jump_sound_check == 0 then
			success = love.audio.play(jumpaudio)
			jump_sound_check = 1
		end
	end
	botact = 0
end
end
elseif hardcoredead then
	playx, playy = moveToward(playx, playy, 96-(playwidth/2), 64-(playheight/2),distanceBetweenPoints(playx, playy, 96-(playwidth/2), 64-(playheight/2)), dt)
	if char ~= love.graphics.newImage("image_assets/chars/char_dead.png") then
		char = love.graphics.newImage("image_assets/chars/char_dead.png")
	end
end
end

function love.resize(width, height)
	push.resize(width, height)
end

function love.focus(f)
	if not f then
		paused=true
	end
end

function love.draw()
	border_width, border_height = love.graphics.getDimensions( )
	if border_width > border_height then
		love.graphics.draw(border,0,border_height/2-(96*(border_width/192)),0,(border_width/192))
	else
		love.graphics.draw(border,border_width+(border_height/2-(96*(border_width/192))),0,math.rad(90),(border_height/144))
	end
	push.start()
	if not hardcoredead then
	love.graphics.setColor(1,1,1)
	love.graphics.draw(bg, 0, 0)
	love.graphics.setColor(1,1,1,sunsetTransparency)
	love.graphics.draw(sunset, 0, 0)
	love.graphics.setColor(1,1,1,starTransparency)
	love.graphics.draw(nightbg, 0, 0)
	love.graphics.setColor(worldR, worldG, worldB)
	love.graphics.draw(floor, platx, platy)
	love.graphics.draw(sideplat, leftplatx, leftplaty)
	if enableFloatPlat then
		love.graphics.draw(floatplat, floatplatx, floatplaty)
	end
	love.graphics.draw(sideplat, rightplatx, rightplaty)
	if disaster == 1 then
		love.graphics.setColor(1,1,1)
		love.graphics.draw(lava, lavax, lavay)
	end
	if disaster == 2 and boomwidth==32 then
		love.graphics.setColor(1,1,1)
		if boomactive == false then
			love.graphics.draw(boomwarn, boomx, boomy)
		elseif modifier == 3 then
			grav = 100
		else
			love.graphics.draw(kaboom, boomx, boomy)
		end
	end
	if disaster == 3 then
		love.graphics.setColor(1,1,1)
		love.graphics.draw(beam, beamx, beamy)
	end
	if disaster == 4 then
		love.graphics.draw(acid, lavax, lavay)
	end
	if disaster == 5 then
		love.graphics.setColor(1,1,1)
		love.graphics.draw(meteor, meteorx, meteory-6)
	end
	if disaster == 6 then
		love.graphics.setColor(1,1,1)
		love.graphics.draw(blackhole, 96-((32*disasTimer)/2), 72-((32*disasTimer)/2), 0, disasTimer)
	end
	if disaster == 7 then
		love.graphics.setColor(1,1,1)
		love.graphics.draw(laser, lasersx[1], lasersy[1])
		love.graphics.draw(laser, lasersx[2], lasersy[2])
	end
	if disaster == 8 then
		love.graphics.setColor(1,1,1)
		if lightningActive then
			love.graphics.draw(lightning, lightningx-12, lightningy-108, 0, 1.5) --the -144 is because i wanna render it on the ground at whatever Y i set
			--better ways to do that? most definitely!! do i care? hell nah 🔥🔥🔥
			--oh and the -12 is because the hitbox is only 24 wide and it'd be weird to have the hitbox on the far left
		elseif lightningWarn then
			love.graphics.draw(boomwarn, lightningx-4, lightningy-32, 0, 1)
		end
		love.graphics.draw(stormclouds, 0, 0)
	end
	if disaster == 9 then
		if zombdir == "right" then
			love.graphics.draw(zombie, zombx-(3*(zombwidth/10)), zomby, 0, zombwidth/10)
		else
			love.graphics.draw(zombie, zombx+(13*(zombwidth/10)), zomby, 0, zombwidth/-10, zombwidth/10)
		end
	end
	love.graphics.setColor(255, 255, 255)
	if disaster_Stored ~= 0 then
		love.graphics.draw(warn, warnquads[disaster_Stored], 0, 0)
		if modifier ~= 0 then
			love.graphics.print("+"..modifiers[modifier], 0, 32)
		end
	end
	love.graphics.setColor(worldR, worldG, worldB, 1-(dead/2))
	if playdir == "right" then
		love.graphics.draw(char, playx-(3*(playwidth/10)), playy, 0, playwidth/10)
	else
		love.graphics.draw(char, playx+(13*(playwidth/10)), playy, 0, playwidth/-10, playwidth/10)
	end
	if guardian_angel_used then
		love.graphics.draw(halo, playx+(9*(playwidth/10)), playy-5, 0, playwidth/-10, playwidth/10)
	end
	love.graphics.setColor(worldR, worldG, worldB, 1-(botdead/2))
	if bot_toggle == 1 then
		if botdir == "right" then
			love.graphics.draw(botchar, botx-(3*(botwidth/10)), boty, 0, botwidth/10)
		else
			love.graphics.draw(botchar, botx+(13*(botwidth/10)), boty, 0, botwidth/-10, botwidth/10)
		end
	end
	love.graphics.setColor(255, 255, 255)
	if debug then	
		love.graphics.print("ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890!?.,#*^", 2)
		love.graphics.setColor(255, 0, 0)
		love.graphics.rectangle('line', platx, platy, platwidth, platheight)
		love.graphics.rectangle('line', playx, playy, playwidth, playheight)
		love.graphics.rectangle('line', botx, boty, botwidth, botheight)
		love.graphics.rectangle('line', leftplatx, leftplaty, leftplatwidth, leftplatheight)
		love.graphics.rectangle('line', rightplatx, rightplaty, rightplatwidth, rightplatheight)
		love.graphics.rectangle('line', lightningx, lightningy-144, 24, 144)
	end
	if paused then
		love.graphics.setColor(0, 0, 0, 0.5)
		love.graphics.rectangle('fill', 0, 0, 192, 144)
		love.graphics.setColor(1, 1, 1, 1)
		if not optionsMenu and not shopMenu then
			love.graphics.print("PAUSED", 2, 2, 0, 2)
			if pausemenu_highlight == 0 then
				love.graphics.print("OPTIONS FOR GRAPHICS, GAMEPLAY, ETC.", 0, 118)
				love.graphics.setColor(1, 1, 0, 1)
			else
				love.graphics.setColor(1, 1, 1, 1)
			end
			love.graphics.print("OPTIONS", 2, 16, 0, 2)
			if pausemenu_highlight == 1 then
				love.graphics.print("BUY POWERUPS, MODIFIERS, AND MORE", 0, 118)
				love.graphics.setColor(1, 1, 0, 1)
			else
				love.graphics.setColor(1, 1, 1, 1)
			end
			love.graphics.print("SHOP", 2, 28, 0, 2)
			if pausemenu_highlight == 2 then
				love.graphics.print("UNPAUSE AND RETURN TO THE GAME", 0, 118)
				love.graphics.setColor(1, 1, 0, 1)
			else
				love.graphics.setColor(1, 1, 1, 1)
			end
			love.graphics.print("BACK TO GAME", 2, 40, 0, 2)
			if pausemenu_highlight == 3 then
				love.graphics.print("SAVE YOUR COINS, WINS, AND DEATHS (TOP-RIGHT)", 0, 118)
				love.graphics.print("THEN EXIT AND RETURN TO DESKTOP/OS", 0, 124)
				love.graphics.setColor(1, 1, 0, 1)
			else
				love.graphics.setColor(1, 1, 1, 1)
			end
			love.graphics.print("SAVE + EXIT GAME", 2, 52, 0, 2)
		elseif optionsMenu then
			love.graphics.print("OPTIONS", 2, 2, 0, 2)
		if pausemenu_highlight == 0 then
			love.graphics.print(scaledesc_line1[scaling_method], 0, 118)
			love.graphics.print(scaledesc_line2[scaling_method], 0, 124)
			love.graphics.setColor(1, 1, 0, 1)
		else
			love.graphics.setColor(1, 1, 1, 1)
		end
		love.graphics.print("SCALING:"..scaling_select[scaling_method], 2, 16, 0, 2)
		if pausemenu_highlight == 1 then
			if forcefullscreen then
				love.graphics.print("OPTION UNAVAILABLE", 0, 118)
				love.graphics.print("(GAME STARTED WITH FULLSCREEN ARGUMENT)", 0, 124)
				love.graphics.setColor(1, 1, 0, 0.5)
			else
				love.graphics.print("WHETHER OR NOT TO SHOW THE GAME IN FULLSCREEN", 0, 118)
				love.graphics.setColor(1, 1, 0, 1)
			end
		else
			love.graphics.setColor(1, 1, 1, 1)
		end
		if forcefullscreen then
			love.graphics.print("FULLSCREEN:x", 2, 28, 0, 2)
		else
			love.graphics.print("FULLSCREEN:"..yesno_select[fullscreen], 2, 28, 0, 2)
		end
		if pausemenu_highlight == 2 then
			love.graphics.print("WHETHER OR NOT TO SHOW THE AI BOT (SILLY GUY)", 0, 118)
			love.graphics.setColor(1, 1, 0, 1)
		else
			love.graphics.setColor(1, 1, 1, 1)
		end
		love.graphics.print("HIDE ROBOT:"..yesno_select[bot_toggle], 2, 40, 0, 2)
		if pausemenu_highlight == 3 then
			love.graphics.print("TIME, IN MINUTES, FOR EACH HALF OF THE DAY TO CYCLE", 0, 118)
			love.graphics.print("(TOTALLY HALVED BECAUSE AM/PM. NOT UNINTENTIONAL)", 0, 124) --source: trust me bro
			love.graphics.setColor(1, 1, 0, 1)
		else
			love.graphics.setColor(1, 1, 1, 1)
		end
		love.graphics.print("TIME SPEED:"..time_speeds_string[time_speed], 2, 52, 0, 2)
		if pausemenu_highlight == 4 then
			love.graphics.print("UPON DEATH, LOSE ALL WINS AND HALF OF COINS, BUT GET", 0, 118)
			love.graphics.print("MORE COINS PER WIN (HARDCORE WINS ARE SAVED", 0, 124)
			love.graphics.print("SEPARATELY FROM REGULAR WINS)", 0, 130)
			love.graphics.setColor(1, 1, 0, 1)
		else
			love.graphics.setColor(1, 1, 1, 1)
		end
		love.graphics.print("HARDCORE:"..string.upper(hardcore), 2, 64, 0, 2)
		if pausemenu_highlight == 5 then
			love.graphics.print("DELAY BETWEEN DISASTERS BEING ACTIVATED", 0, 118)
			love.graphics.setColor(1, 1, 0, 1)
		else
			love.graphics.setColor(1, 1, 1, 1)
		end
		love.graphics.print("DISASTER DELAY: "..disastDelay, 2, 76, 0, 2)
		elseif shopMenu then
			love.graphics.print("SHOP", 2, 2, 0, 2)
		if pausemenu_highlight == 0 then
			love.graphics.print("GIVES YOU A SECOND CHANCE, BUT COIN PROFIT IS HALVED", 0, 118)
			love.graphics.print("OWNED:"..guardian_angel.." ACTIVE:"..yesno_select[guardian_angel_active], 0, 124)
			love.graphics.setColor(1, 1, 0, 1)
		else
			love.graphics.setColor(1, 1, 1, 1)
		end
		love.graphics.print("GUARDIAN ANGEL", 2, 16, 0, 2)
	end
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.printf("#x"..coins,1,1,191,"right",0,1)
	if hardcore == "true" then
		love.graphics.printf("\\x"..hardcorewins,1,8,191,"right",0,1)
		love.graphics.printf("\\^x"..hardcorehighscore,1,15,191,"right",0,1)
	else
		love.graphics.printf("vx"..wins,1,8,191,"right",0,1)
		love.graphics.printf("*x"..deaths,1,15,191,"right",0,1)
	end
	end
	else
		love.graphics.printf(death_messages_1[death_message],0,8,96,"center",0,2)
		love.graphics.printf(death_messages_2[death_message],0,20,96,"center",0,2)
		if newHigh then
			love.graphics.printf("FINAL SCORE:"..hardcorewins_Stored,0,108,96,"center",0,2)
			love.graphics.setColor(1, 1, 0, 1)
			love.graphics.printf("NEW HIGH SCORE!!",0,120,96,"center",0,2)
			love.graphics.setColor(1, 1, 1, 1)
		else
			love.graphics.printf("FINAL SCORE:"..hardcorewins_Stored,0,120,96,"center",0,2)
		end
		love.graphics.printf("PRESS ANY KEY TO EXIT.",0,132,192,"center",0,1)
		love.graphics.draw(char, playx-3, playy)
	end
	love.graphics.setColor(0, 0, 0, 0.5)
	love.graphics.rectangle('fill', 0, 137, 24, 7)
	love.graphics.setColor(255, 255, 255)
	love.graphics.print("FPS:"..love.timer.getFPS(), 1, 138)
	push.finish()
end
