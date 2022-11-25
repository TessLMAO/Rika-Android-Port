function onEvent(name, value1, value2)
	if name == 'ArrowSwitch' then
		if flashingLights then
			cameraFlash('hud', 'ffeba8', 0.4, 'false')
		end
	end
end
