function onCreatePost()

  -- fuck you psych ui
  setProperty('timeBarBG.visible',false)
  setProperty('timeBar.visible',false)
  setProperty('timeTxt.visible',false)
  setProperty('scoreTxt.visible',false)

  -- stole code from the forever engine ui
  makeLuaText('FPSScoreTxt', 'Score: 0 | Misses: 0 | Accuracy: 0%', 1280, 0, 680);
  setTextBorder("FPSScoreTxt", 2, '000000')
  setTextAlignment('FPSScoreTxt', 'CENTER')
  setTextSize('FPSScoreTxt', 22)
  if not getPropertyFromClass('ClientPrefs', 'hideHud') then addLuaText('FPSScoreTxt') end
end

function onUpdate()
  if misses >= 1 then
  setTextString('FPSScoreTxt', 'Score: '..score.. ' | Misses: '..misses.. ' | Accuracy: '..round((getProperty('ratingPercent') * 100), 2) ..'%');
 end
end

function goodNoteHit(id, dir, type, sustain)
 if misses <= 1 then
   setTextString('FPSScoreTxt', 'Score: '..score.. ' | Misses: '..misses.. ' | Accuracy: 100%');
 end
end

function round(x, n) --https://stackoverflow.com/questions/18313171/lua-rounding-numbers-and-then-truncate
  n = math.pow(10, n or 0)
  x = x * n
  if x >= 0 then x = math.floor(x + 0.5) else x = math.ceil(x - 0.5) end
  return x / n
end

function onRecalculateRating()
  reloadRating(round((getProperty('ratingPercent') * 100), 2))
end