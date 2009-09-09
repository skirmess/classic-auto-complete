
-- Copyright (c) 2009, Sven Kirmess

local Version = 5
local Loaded = false

local OrigGetAutoCompleteResults = nil
local RealmName
local MyAlts = { }

-- http://ricilake.blogspot.com/2007/10/iterating-bits-in-lua.html
local function IsBitSet(x, p)
	return x % (p + p) >= p
end

local function PrintableName(name)

	if ( name == nil ) then
		return nil
	end

	if ( name == "" ) then
		return nil
	end

	if ( string.match(string.lower(name), "[^a-z]") ~= nil ) then
		return nil
	end

	if ( string.len(name) < 2 ) then
		return string.upper(name)
	end

	return string.upper(string.sub(name, 1, 1)) .. string.lower(string.sub(name, 2))
end

local function Usage()
	DEFAULT_CHAT_FRAME:AddMessage(string.format("%s help", SLASH_CLASSICAUTOCOMPLETE1))
	DEFAULT_CHAT_FRAME:AddMessage(string.format("%s list   (list the content of your alt list)", SLASH_CLASSICAUTOCOMPLETE1))
	DEFAULT_CHAT_FRAME:AddMessage(string.format("%s add <name>   (add a character to your alt list)", SLASH_CLASSICAUTOCOMPLETE1))
	DEFAULT_CHAT_FRAME:AddMessage(string.format("%s remove <name>   (remove or unblock a character from your alt list)", SLASH_CLASSICAUTOCOMPLETE1))
	DEFAULT_CHAT_FRAME:AddMessage(string.format("%s block <name>   (block a character from being added to your alt list)", SLASH_CLASSICAUTOCOMPLETE1))
end

local function SlashCommandHandler(msg, editbox)

	local myName = UnitName("player")
	local argument = { }
	local k, v

	for v in string.gmatch(msg, "[^%s]+") do
		tinsert(argument, v)
	end

	-- help
	if ( argument[1] == "help" ) then
		Usage()

		return
	end

	-- list
	if ( argument[1] == "list" ) then

		for k, v in pairs(ClassicAutoComplete_MyChars[RealmName]) do
			local s = ""
			if ( v == 0 ) then
				s = " (added)"
			elseif ( v == -1 ) then
				s = " (blocked)"
			end
			DEFAULT_CHAT_FRAME:AddMessage(string.format("%s%s", k, s))
		end

		return
	end

	-- add
	-- block
	-- remove
	if (( argument[1] == "add" ) or
	    ( argument[1] == "block" ) or
	    ( argument[1] == "remove" )) then

		local name = PrintableName(argument[2])
		if ( name == nil ) then
			Usage()

			return
		end

		if (( argument[1] == "add" ) or ( argument[1] == "block" )) then
			-- add or block

			if (argument[1] == "add" ) then
				-- add
				ClassicAutoComplete_MyChars[RealmName][name] = 0
				if ( name ~= myName ) then
					MyAlts[name] = 1
				end

				DEFAULT_CHAT_FRAME:AddMessage(string.format("Character \"%s\" is now considered an alt of yours.", name))
			elseif ( argument[1] == "block" ) then
				-- block
				ClassicAutoComplete_MyChars[RealmName][name] = -1
				MyAlts[name] = nil

				DEFAULT_CHAT_FRAME:AddMessage(string.format("Alt \"%s\" is now blocked.", name))
			end
		else
			-- remove
			if ( name == myName ) then
				ClassicAutoComplete_MyChars[RealmName][myName] = now
			else
				ClassicAutoComplete_MyChars[RealmName][name] = nil
			end
			MyAlts[name] = nil

			DEFAULT_CHAT_FRAME:AddMessage(string.format("Alt \"%s\" is now removed (and no longer blocked if it was blocked).", name))
		end

		return
	end

	Usage()
end

local function OnCharHandler(s)

	local name = s:GetText()

	if ( strlen(name) <= 0 ) then
		return
	end

	local completedName = (
		GetAutoCompleteAltResults(name) or
		OrigGetAutoCompleteResults(name, AUTOCOMPLETE_FLAG_ONLINE + AUTOCOMPLETE_FLAG_FRIEND, 0, 1) or
		OrigGetAutoCompleteResults(name, AUTOCOMPLETE_FLAG_ONLINE + AUTOCOMPLETE_FLAG_IN_GUILD, 0, 1) or
		OrigGetAutoCompleteResults(name, AUTOCOMPLETE_FLAG_FRIEND, 0, 1) or
		OrigGetAutoCompleteResults(name, AUTOCOMPLETE_FLAG_IN_GUILD, 0, 1) or
		OrigGetAutoCompleteResults(name, AUTOCOMPLETE_FLAG_ALL, 0, 1)
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

local function NewGetAutoCompleteResults(t, include, exclude, maxResults, ...)

	local result = { OrigGetAutoCompleteResults(t, include, exclude, maxResults, ...) }

	-- AUTOCOMPLETE_FLAG_FRIEND 	 0x00000004 	 Players on your friends list
	local k, v, ik, iv
	if ( IsBitSet(include, 3) ) then
		for k, v in ipairs { GetAutoCompleteAltResults(t) } do
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

local function GetAutoCompleteAltResults(t)

	local result = { }

	local text = string.lower(t)
	local textlen = strlen(text)

	for name, _ in pairs(MyAlts) do
		if (( strlen(name) >= textlen ) and ( string.sub(string.lower(name), 1, textlen) == text )) then
			table.insert(result, name)
		end
	end

	return unpack(result)
end

local function initialize()

	if ( Loaded ) then
		return
	end
	Loaded = true

	RealmName = GetCVar("realmName")

	if ( ClassicAutoComplete_MyChars == nil ) then
		ClassicAutoComplete_MyChars = { }
	end

	if ( ClassicAutoComplete_MyChars[RealmName] == nil ) then
		ClassicAutoComplete_MyChars[RealmName] = { }
	end

	local now = time()
	local myName = UnitName("player")

	if ( ( ClassicAutoComplete_MyChars[RealmName][myName] == nil ) or
	     ( ClassicAutoComplete_MyChars[RealmName][myName] > 0 ) ) then
		ClassicAutoComplete_MyChars[RealmName][myName] = now
	end

	for name, lastLogin in pairs(ClassicAutoComplete_MyChars[RealmName]) do
		if ( ( ClassicAutoComplete_MyChars[RealmName][name] >= 0 ) and
		     ( name ~= myName ) ) then
			MyAlts[name] = 1
		end
	end

	OrigGetAutoCompleteResults = GetAutoCompleteResults
	GetAutoCompleteResults = NewGetAutoCompleteResults

	SendMailNameEditBox:SetScript("OnTextChanged", nil)
	SendMailNameEditBox:SetScript("OnChar", OnCharHandler)

	SLASH_CLASSICAUTOCOMPLETE1 = "/autocomplete"
	SlashCmdList["CLASSICAUTOCOMPLETE"] = SlashCommandHandler

	DEFAULT_CHAT_FRAME:AddMessage(string.format("ClassicAutoComplete %i loaded.", Version))
end

local function EventHandler(self, event, ...)

	if ( event == "ADDON_LOADED" ) then
		local addon = ...
		if (( addon ~= nil ) and ( addon == "ClassicAutoComplete" )) then
			self:UnregisterEvent("ADDON_LOADED")

			initialize()
		end
	end
end

-- main
local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", EventHandler)

