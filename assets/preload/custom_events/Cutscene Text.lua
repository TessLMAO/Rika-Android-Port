function onCreatePost()
   makeLuaText('cutsceneText', 'Fuck you.', getPropertyFromClass('flixel.FlxG', 'width') - 100, 0, 570);
   setObjectCamera('cutsceneText', 'camOther');
   screenCenter('cutsceneText', 'x');
   setTextFont('cutsceneText', 'DeathValley-KnA7.ttf');
   setTextAlignment('cutsceneText', 'center');
   setTextSize('cutsceneText', 50);
   setProperty('cutsceneText.alpha', 0);
   setProperty('cutsceneText.antialiasing', false);
   setObjectOrder('cutsceneText', getObjectOrder('bottomBar') + 1);
   addLuaText('cutsceneText');
end

   
function onEvent(name, value1, value2)
   if name == 'Cutscene Text' then
      cancelTween('textFadeIn');
	  cancelTimer('visibleTime');
   
      setProperty('cutsceneText.alpha', 1);
	  
      setTextString('cutsceneText', value1);
	  
	  runTimer('visibleTime', tonumber(value2), 1);
   end
end

function onTimerCompleted(tag, loops, loopsLeft)
   if tag == 'visibleTime' then
      setProperty('cutsceneText.alpha', 0);
   end
end