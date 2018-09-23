
-- Copyright (c) 2009-2018, Sven Kirmess

local Version = 16
local Loaded = false

local RealmName
local MyAlts = { }

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

	local connectedRealms = GetAutoCompleteRealms()
	if ( connectedRealms == nil ) then
		connectedRealms = { RealmName }
	end

	-- help
	if ( argument[1] == "help" ) then
		Usage()

		return
	end

	-- list
	if ( argument[1] == "list" ) then

		local alts = { }

		for i = 1, #connectedRealms do

			local realmSuffix = ""

			if ( connectedRealms[i] == RealmName ) then
				realmSuffix = "-" .. PrintableName(string.gsub(connectedRealms[i], "%s+", ""))
			end

			for k, v in pairs(ClassicAutoComplete_MyChars[connectedRealms[i]]) do
				local s = ""
				if ( v == 0 ) then
					s = "(added)"
				elseif ( v == -1 ) then
					s = "(blocked)"
				end
				tinsert(alts, string.format("%s%s %s", k, realmSuffix, s))
			end
		end

		table.sort(alts)
		for i = 1, #alts do
			DEFAULT_CHAT_FRAME:AddMessage(string.format("%s", alts[i]))
		end

		return
	end

	-- add
	-- block
	-- remove
	if (( argument[1] == "add" ) or
	    ( argument[1] == "block" ) or
	    ( argument[1] == "remove" )) then

		if ( string.match(argument[2], "-") ~= nil ) then
			DEFAULT_CHAT_FRAME:AddMessage(string.format("%s", "You can only add, block and remove an alt from it's realm. Not from connected realms."))

			return
		end

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

	-- check if alts match
	local completedName = nil
	local result = { }

	local altName, v
	for altName, v in pairs( MyAlts ) do
		if ( ( strlen(name) <= strlen(altName) ) and ( string.lower(name) == string.sub(string.lower(altName), 1, strlen(name)) ) ) then
			-- DEFAULT_CHAT_FRAME:AddMessage(string.format("alt match: %s -> %s", altName, name))
			table.insert(result, 1, altName)
		end
	end

	if ( #result > 0 ) then
		table.sort(result)
		completedName = result[1]
	end

	-- check if friends match
	if ( completedName == nil ) then
		local numFriends = GetNumFriends()
		for iItem = 1, numFriends, 1 do
			friend = GetFriendInfo(iItem)

			if ( ( friend ) and ( strlen(name) <= strlen(friend) ) and ( string.lower(name) == string.sub(string.lower(friend), 1, strlen(name)) ) ) then
				-- DEFAULT_CHAT_FRAME:AddMessage(string.format("friend match: %s -> %s", friend, name))
				table.insert(result, 1, friend)
			end
		end

		if ( #result > 0 ) then
			table.sort(result)
			completedName = result[1]
		end
	end

	-- check if guild match
	if ( completedName == nil ) then
		local numGuildies = GetNumGuildMembers()
		for iItem = 1, numGuildies, 1 do
			guildie = GetGuildRosterInfo(iItem)

			if ( ( guildie ) and ( strlen(name) <= strlen(guildie) ) and ( string.lower(name) == string.sub(string.lower(guildie), 1, strlen(name)) ) ) then
				-- DEFAULT_CHAT_FRAME:AddMessage(string.format("guildie match: %s -> %s", guildie, name))
				table.insert(result, 1, guildie)
			end
		end

		if ( #result > 0 ) then
			table.sort(result)
			completedName = result[1]
		end
	end

	if ( completedName ~= nil ) then
		local completedNameRemainderPosition = s:GetCursorPosition()

		s:SetText(completedName)
		s:HighlightText(completedNameRemainderPosition, strlen(completedName))
	end
end

local function initialize()

	if ( Loaded ) then
		return
	end
	Loaded = true

	RealmName = GetRealmName()

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

	local connectedRealms = GetAutoCompleteRealms()
	if ( connectedRealms == nil ) then
		connectedRealms = { RealmName }
	end

	for i = 1, #connectedRealms do
		-- initialize database of connected realms
		if ( ClassicAutoComplete_MyChars[connectedRealms[i]] == nil ) then
			ClassicAutoComplete_MyChars[connectedRealms[i]] = { }
		end

		for name, lastLogin in pairs(ClassicAutoComplete_MyChars[connectedRealms[i]]) do
			if ( ClassicAutoComplete_MyChars[connectedRealms[i]][name] >= 0 ) then
				if ( connectedRealms[i] ~= RealmName ) then
					MyAlts[name .. "-" .. connectedRealms[i]] = 1
				elseif ( name ~= myName ) then
					MyAlts[name] = 1
				end
			end
		end
	end

	-- disable default auto complete drop down
	SendMailNameEditBox.autoCompleteParams = nil

	-- SendMailNameEditBox:SetScript("OnTextChanged", nil)
	SendMailNameEditBox:SetScript("OnChar", OnCharHandler)

	SLASH_CLASSICAUTOCOMPLETE1 = "/autocomplete"
	SlashCmdList["CLASSICAUTOCOMPLETE"] = SlashCommandHandler

	DEFAULT_CHAT_FRAME:AddMessage(string.format("ClassicAutoComplete %i loaded.", Version))
end

local function EventHandler(self, event, ...)

	if ( event == "ADDON_LOADED" ) then

		local addon = ...
		if ( addon == nil ) then
			return
		end

		if ( addon == "ClassicAutoComplete" ) then
			self:UnregisterEvent("ADDON_LOADED")
			initialize()
		end
	end
end

-- main
local frame = CreateFrame("Frame")
frame:SetScript("OnEvent", EventHandler)
frame:RegisterEvent("ADDON_LOADED")

