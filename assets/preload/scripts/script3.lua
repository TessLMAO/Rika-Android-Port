-- PSYCH ENGINE: VANILLA RESKIN VIA. LUA --
-- CREDITS:
-- @cyn#5661 - Original Custom Healthbar Script (https://discord.com/channels/922849922175340586/922851578996744252/941509137601269800)
-- @Kevin Kuntz#7641 - Splash offsets lol
-- @SkyBaoFall#7925 - Static strums code (from kade engine botplay: https://cdn.discordapp.com/attachments/922851578996744252/967430611532939264/kade_engine_botplay.zip)
-- @Stilic#5989 - Combo popup on the counter (was too lazy to make one LMAOOO) (https://cdn.discordapp.com/attachments/922851578996744252/974003348158185523/noteComboPack.zip)
-- ninja_muffin99 - Reference Code :nerd:

local isUsingGhost
local p1height;
local p2height;

-- how 2 use preferences

local preferences = {
	comboCamGame = true, -- if you want to see combo counter on camGame
	vanillaStrumPos = true, -- if you want the strums to position just like in vanilla (setting this to false also enables the strums to play animation on opponent strums)
	comboSprite = true, -- makes the combo text show
	prototypeText = false, -- if you want the prototype text to appear (set to true)
	vanillaCountFrom10 = true, -- if you want the combo number to show up after 10 combo (just like in vanilla) (set this to false in order to show numbers from start)
	vanillaHB = true, -- Want the vanilla healthbar colors?
	borderlessScore = true; -- Do you want the score text to be borderless?
}

-- More preferences coming soon

function string.starts(str, start)
    return string.sub(str, 1, string.len(start)) == start
end

function string.split(str, sep)
    if sep == nil then sep = "%s" end
    local t = {}
    for str in string.gmatch(str, "([^" .. sep .. "]+)") do
        table.insert(t, str)
    end
    return t
end

local count = 0

local function to_hex(rgb)
	return string.format("%x", (rgb[1] * 0x10000) + (rgb[2] * 0x100) + rgb[3])
end

function remapToRange(value, start1, stop1, start2, stop2)
	return start2 + (value - start1) * ((stop2 - start2) / (stop1 - start1))
end

function lerp(a, b, ratio)
	return a + ratio * (b - a)
end

function onCreatePost()

	luaDebugMode = true;
	p1height = getProperty('iconP1.height');
	p2height = getProperty('iconP2.height');

	setPropertyFromClass('lime.app.Application', 'current.window.title', "Friday Night Funkin Vs Rika")
	--setPropertyFromClass('Main', 'fpsVar.visible', 'true')

	hudHidden = getPropertyFromClass('ClientPrefs', 'hideHud')
	if not hudHidden and preferences.comboCamGame then
		setPropertyFromClass('ClientPrefs', 'hideHud', true)
	end

	if preferences.prototypeText then
		makeLuaText('proto', 'v0.3.0 (163ea06) PROTOTYPE', 300, 0, 0)
		setProperty('proto.x', screenWidth - getProperty('proto.width'))
		setProperty('proto.y', screenHeight - getProperty('proto.height'))
		setTextSize('proto', 16)
		setTextAlignment('proto', 'right')
		addLuaText('proto')
		setObjectOrder('proto', getObjectOrder('score'))
		setTextBorder('proto', 1.75, '000000')
	end
end

function onStartCountdown()
	doTheStupid();
end

function goodNoteHit(id, noteData, noteType, isSustainNote)
    if getProperty('cpuControlled') and not isSustainNote then
		addScore(350)
    end

    setTextString('score', 'Score: '.. getProperty('songScore'))

    if not isSustainNote and preferences.comboCamGame then
		popUpScore(id, math.abs(getPropertyFromClass('Conductor', 'songPosition') - getPropertyFromGroup('notes', id, 'strumTime')) )
    end
end

function noteMiss(...)
	setTextString('score', 'Score: '.. getProperty('songScore'))
end

function onDestroy()
	if getProperty('cpuControlled') then
		setPropertyFromClass('ClientPrefs', 'cpuControlled', true)
	end

	if isUsingGhost then setPropertyFromClass('ClientPrefs', 'ghostTapping', true) end
	if not hudHidden then setPropertyFromClass('ClientPrefs', 'hideHud', false) end
end

function onTimerCompleted(tag)
    if tag:starts('combo') then
        doTweenAlpha(tag, tag, 0, 0.2, 'linear')
    end
end

function onTweenCompleted(tag)
    if tag:starts('combo') then
        removeLuaSprite(tag, true)
    end
end

function popUpScore(note, noteHitDelay)

	local tag
	local myRating = getPropertyFromGroup('notes', note, 'rating')

	local pixel = getPropertyFromClass('PlayState', 'isPixelStage')
    local pixelShitPart1 = ''
    local pixelShitPart2 = ''
    local pixelMult = 1
    local antialiasing = getPropertyFromClass('ClientPrefs','globalAntialiasing')

    if pixel then
    	pixelShitPart1 = 'pixelUI/'
    	pixelShitPart2 = '-pixel'
    	pixelMult = getPropertyFromClass('PlayState', 'daPixelZoom')
    	antialiasing = false
    end

	count = count + 1
	tag = 'comboRating'..count

	makeLuaSprite(tag, pixelShitPart1 .. myRating .. pixelShitPart2, 0, 0)
	screenCenter(tag)
	setProperty(tag..'.x', screenWidth * 0.55 - 40)
	setProperty(tag..'.y', getProperty(tag..'.y') - 60)

	setGraphicSize(tag, getProperty(tag..'.width') * 0.7)
	setProperty(tag..'.antialiasing', antialiasing)
	if pixel then
		scaleObject(tag, 1, 1)
		setGraphicSize(tag, getProperty(tag..'.width') * pixelMult * 0.85)
	end

	updateHitbox(tag)
	
	addLuaSprite(tag, true)

	setProperty(tag..'.acceleration.y', 550)
	setProperty(tag..'.velocity.y', getProperty(tag..'.velocity.y') - math.random(140, 175))
	setProperty(tag..'.velocity.x', math.random(0, 10))
	runTimer(tag, crochet * 0.001)

	-- Modified combo text code made by Stilic

	if getProperty('combo') > 9 or not preferences.vanillaCountFrom10 then
		if preferences.comboSprite then
			-- lot of vars but shut up i know we need these
			count = count + 1
			tag = 'combo' .. count
			local offset = {0,0} --getPropertyFromClass('ClientPrefs', 'comboOffset')

			-- pixel style is great too
			makeLuaSprite(tag, pixelShitPart1 .. 'combo' .. pixelShitPart2, screenWidth * 0.55 + 45, 0)

			-- i wanted to put that after ratio var but psych don't let me do that
			screenCenter(tag, 'y')
			setProperty(tag .. '.y', getProperty(tag..'.y') + 35)

			setGraphicSize(tag, getProperty(tag..'.width') * 0.7)
			setProperty(tag..'.antialiasing', antialiasing)
			if pixel then
				scaleObject(tag, 1, 1)
				setGraphicSize(tag, getProperty(tag..'.width') * pixelMult * 0.85)
				setProperty(tag .. '.x', getProperty(tag..'.x') + 10)
				setProperty(tag .. '.y', getProperty(tag..'.y') + 25)
			end
			
			updateHitbox(tag)

			-- box2d based??? dik
			setProperty(tag .. '.acceleration.y', 600)
			setProperty(tag .. '.velocity.y', getProperty(tag .. '.velocity.y') - 150)
			setProperty(tag .. '.velocity.x', getProperty(tag .. '.velocity.x') - math.random(1,10))

			addLuaSprite(tag, true)

			-- fuck psych doesn't support startDelay so i use a timer instead
			runTimer(tag, crochet * 0.001)
		end

		-- k this part was made by me
	
		local combo = getProperty('combo')
		local seperatedScore = {}

		if combo >= 1000 then
			table.insert(seperatedScore, math.floor(combo / 1000) % 10)
		end
		table.insert(seperatedScore, math.floor(combo / 100) % 10)
		table.insert(seperatedScore, math.floor(combo / 10) % 10)
		table.insert(seperatedScore, combo % 10)

		for number,i in pairs(seperatedScore) do

			count = count + 1
			tag = 'comboNum'..count

			makeLuaSprite(tag,  pixelShitPart1 .. 'num'..i .. pixelShitPart2, 0, 0)
			screenCenter(tag)
			setProperty(tag..'.x', screenWidth * 0.55 + (43 * (number-1)) - 90)
			setProperty(tag..'.y', getProperty(tag..'.y') + 80)

			setGraphicSize(tag, getProperty(tag..'.width') * 0.5)
			setProperty(tag..'.antialiasing', antialiasing)
			if pixel then
				scaleObject(tag, 1, 1)
				setGraphicSize(tag, getProperty(tag..'.width') * pixelMult)
			end
			
			updateHitbox(tag)

			addLuaSprite(tag, true)

			setProperty(tag..'.acceleration.y', math.random(200, 300))
			setProperty(tag..'.velocity.y', getProperty(tag..'.velocity.y') - math.random(140, 160))
			setProperty(tag..'.velocity.x', math.random() + math.random(-5, 5))
			runTimer(tag, crochet * 0.002)
		end
	end
end