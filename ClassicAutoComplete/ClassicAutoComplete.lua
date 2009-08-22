
local ClassicAutoComplete_Version = 3
local ClassicAutoComplete_loaded = false

local ClassicAutoComplete_origGetAutoCompleteResults = nil
local ClassicAutoComplete_realmName
local ClassicAutoComplete_MyAlts = { }

-- http://ricilake.blogspot.com/2007/10/iterating-bits-in-lua.html
function ClassicAutoComplete_hasbit(x, p)
	return x % (p + p) >= p
end 

function ClassicAutoComplete_OnChar(s)

	local name = s:GetText()

	if ( strlen(name) <= 0 ) then
		return
	end

	local completedName = (
		ClassicAutoComplete_GetAutoCompleteAltResults(name) or
		ClassicAutoComplete_origGetAutoCompleteResults(name, AUTOCOMPLETE_FLAG_ONLINE + AUTOCOMPLETE_FLAG_FRIEND, 0, 1) or 
		ClassicAutoComplete_origGetAutoCompleteResults(name, AUTOCOMPLETE_FLAG_ONLINE + AUTOCOMPLETE_FLAG_IN_GUILD, 0, 1) or 
		ClassicAutoComplete_origGetAutoCompleteResults(name, AUTOCOMPLETE_FLAG_FRIEND, 0, 1) or
		ClassicAutoComplete_origGetAutoCompleteResults(name, AUTOCOMPLETE_FLAG_IN_GUILD, 0, 1) or
		ClassicAutoComplete_origGetAutoCompleteResults(name, AUTOCOMPLETE_FLAG_ALL, 0, 1)
	)

	if completedName then
		completedNameRemainderPosition=s:GetCursorPosition()
		s:SetText(completedName)
		s:HighlightText(completedNameRemainderPosition, strlen(completedName))
	end

	-- to keep the new auto complete functionality
	AutoComplete_Update(s, name, completedNameRemainderPosition)
	SendMailFrame_Update()
end

function ClassicAutoComplete_GetAutoCompleteResults(t, include, exclude, maxResults, ...)

	local result = { ClassicAutoComplete_origGetAutoCompleteResults(t, include, exclude, maxResults, ...) }

	-- AUTOCOMPLETE_FLAG_FRIEND 	 0x00000004 	 Players on your friends list 
	local k, v, ik, iv
	if ( ClassicAutoComplete_hasbit(include, 3) ) then
		for k, v in ipairs { ClassicAutoComplete_GetAutoCompleteAltResults(t) } do
			local found = 0
			for ik, iv in ipairs(result) do
				if ( v == iv ) then
					found = 1
				end
			end

			if ( found == 0 ) then
				table.insert(result, v)
			end
		end
	end

	table.sort(result)

	local i = table.getn(result)
	while ( i > maxResults ) do
		table.remove(result)
		i=i-1
	end

	return unpack(result)
end

function ClassicAutoComplete_GetAutoCompleteAltResults(t)

	local result = { }

	local text = string.lower(t)
	local textlen = strlen(text)

	for name, _ in pairs(ClassicAutoComplete_MyAlts) do
		if (( strlen(name) >= textlen ) and ( string.sub(string.lower(name), 1, textlen) == text )) then
			table.insert(result, name)
		end
	end

	return unpack(result)
end



function ClassicAutoComplete_initialize()

	if ( ClassicAutoComplete_loaded ) then
		return
	end
	ClassicAutoComplete_loaded = true

	ClassicAutoComplete_realmName = GetCVar("realmName")

	if ( ClassicAutoComplete_MyChars == nil ) then
		ClassicAutoComplete_MyChars = { }
	end

	if ( ClassicAutoComplete_MyChars[ClassicAutoComplete_realmName] == nil ) then
		ClassicAutoComplete_MyChars[ClassicAutoComplete_realmName] = { }
	end

	local now = time()
	local myName = UnitName("player")

	ClassicAutoComplete_MyChars[ClassicAutoComplete_realmName][myName] = now

	for name, lastLogin in pairs(ClassicAutoComplete_MyChars[ClassicAutoComplete_realmName]) do
		if ( now > (lastLogin + 60 * 60 * 24 * 31) ) then
			ClassicAutoComplete_MyChars[ClassicAutoComplete_realmName][name] = nil
		elseif ( name ~= myName ) then
			ClassicAutoComplete_MyAlts[name] = 1
		end
	end

	ClassicAutoComplete_origGetAutoCompleteResults = GetAutoCompleteResults
	GetAutoCompleteResults = ClassicAutoComplete_GetAutoCompleteResults

	SendMailNameEditBox:SetScript("OnTextChanged", nil)
	SendMailNameEditBox:SetScript("OnChar", ClassicAutoComplete_OnChar)

	DEFAULT_CHAT_FRAME:AddMessage(string.format("ClassicAutoComplete %i loaded.", ClassicAutoComplete_Version))
end

function ClassicAutoComplete_OnEvent(event, ...)

	if ( event == "ADDON_LOADED" ) then
		local addon = ...
		if (( addon ~= nil ) and ( addon == "ClassicAutoComplete" )) then
			this:UnregisterEvent("ADDON_LOADED")

			ClassicAutoComplete_initialize()
		end
	end
end

