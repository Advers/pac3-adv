local L = pace.LanguageString

local function add_expensive_submenu_load(pnl, callback)
	local old = pnl.OnCursorEntered
	pnl.OnCursorEntered = function(...)
		callback()
		pnl.OnCursorEntered = old
		return old(...)
	end
end

local function populate_pac(menu)
	do
		local menu, icon = menu:AddSubMenu(L"save", function() pace.SaveParts() end)
		menu:SetDeleteSelf(false)
		icon:SetImage(pace.MiscIcons.save)
		add_expensive_submenu_load(icon, function() pace.AddSaveMenuToMenu(menu) end)
	end

	do
		local menu, icon = menu:AddSubMenu(L"load", function() pace.LoadParts(nil, true) end)
		menu:SetDeleteSelf(false)
		icon:SetImage(pace.MiscIcons.load)
		add_expensive_submenu_load(icon, function() pace.AddSavedPartsToMenu(menu, true) end)
	end

	do
		local menu, icon = menu:AddSubMenu(L"wear", function() pace.WearParts() end)
		menu:SetDeleteSelf(false)
		icon:SetImage(pace.MiscIcons.wear)

		pace.PopulateWearMenu(menu)
	end

	do
		menu:AddOption(L"request", function() RunConsoleCommand("pac_request_outfits") pac.Message('Requesting outfits.') end):SetImage(pace.MiscIcons.replace)
	end

	do
		local menu, icon = menu:AddSubMenu(L"clear", function() end)
		icon:SetImage(pace.MiscIcons.clear)
		menu.GetDeleteSelf = function() return false end
		menu:AddOption(L"OK", function() pace.ClearParts() end):SetImage(pace.MiscIcons.clear)
	end

	menu:AddSpacer()

	do
		local help, help_pnl = menu:AddSubMenu(L"help", function() pace.ShowWiki() end)
		help.GetDeleteSelf = function() return false end
		help_pnl:SetImage(pace.MiscIcons.help)

		help:AddOption(
			L"Getting Started",
			function() pace.ShowWiki(pace.WikiURL .. "Beginners-FAQ") end
		):SetImage(pace.MiscIcons.info)

		help:AddOption(
			L"PAC3 Wiki",
			function() pace.ShowWiki("https://wiki.pac3.info/start") end
		):SetImage(pace.MiscIcons.info)

		do
			local chat_pnl = help:AddOption(
				L"Discord / PAC3 Chat",
				function() gui.OpenURL("https://discord.gg/utpR3gJ") cookie.Set("pac3_discord_ad", 3)  end
			) chat_pnl:SetImage(pace.MiscIcons.chat)

			if cookie.GetNumber("pac3_discord_ad", 0) < 3 then
				help_pnl.PaintOver = function(_,w,h) surface.SetDrawColor(255,255,0,50 + math.sin(SysTime()*20)*20) surface.DrawRect(0,0,w,h) end
				chat_pnl.PaintOver = help_pnl.PaintOver
				cookie.Set("pac3_discord_ad", cookie.GetNumber("pac3_discord_ad", 0) + 1)
			end
		end

		local version_string = _G.PAC_VERSION and PAC_VERSION()
		if version_string then
			local version, version_pnl = help:AddSubMenu(L"Version", function() pace.ShowWiki() end)
			version.GetDeleteSelf = function() return false end
			version_pnl:SetImage(pace.MiscIcons.info)

			version:AddOption(version_string)

			version:AddOption("update news", function() pac.OpenMOTD(false) end)
		end

		

		help:AddOption(
			L"about",
			function() pace.ShowAbout() end
		):SetImage(pace.MiscIcons.about)
	end

	do
		menu:AddOption(L"exit", function() pace.CloseEditor() end):SetImage(pace.MiscIcons.exit)
	end
end

local function populate_view(menu)
	menu:AddOption(L"hide editor",
		function() pace.Call("ToggleFocus") chat.AddText("[PAC3] \"ctrl + e\" to get the editor back")
	end):SetImage("icon16/application_delete.png")

	menu:AddCVar(L"camera follow: "..GetConVar("pac_camera_follow_entity"):GetInt(), "pac_camera_follow_entity", "1", "0"):SetImage("icon16/camera_go.png")
	menu:AddCVar(L"enable editor camera: "..GetConVar("pac_enable_editor_view"):GetInt(), "pac_enable_editor_view", "1", "0"):SetImage("icon16/camera.png")
	menu:AddOption(L"reset view position", function() pace.ResetView() end):SetImage("icon16/camera_link.png")
	menu:AddOption(L"reset zoom", function() pace.ResetZoom() end):SetImage("icon16/magnifier.png")
end

local function populate_options(menu)
	menu:AddOption(L"settings", function() pace.OpenSettings() end)
	menu:AddCVar(L"Keyboard shortcuts: Legacy mode", "pac_editor_shortcuts_legacy_mode", "1", "0")
	menu:AddCVar(L"inverse collapse/expand controls", "pac_reverse_collapse", "1", "0")
	menu:AddCVar(L"enable shift+move/rotate clone", "pac_grab_clone", "1", "0")
	menu:AddCVar(L"remember editor position", "pac_editor_remember_position", "1", "0")
	menu:AddCVar(L"ask before loading autoload", "pac_prompt_for_autoload", "1", "0")
	if game.SinglePlayer() then menu:AddCVar(L"queue prop / npc outfits for next spawned entity", "pac_prompt_for_autoload", "2", "0") end
	menu:AddCVar(L"show parts IDs", "pac_show_uniqueid", "1", "0")
	local popups, pnlp = menu:AddSubMenu("configure editor popups", function() end)
		popups.GetDeleteSelf = function() return false end
		pnlp:SetImage("icon16/comment.png")
		popups:AddCVar(L"enable editor popups", "pac_popups_enable", "1", "0")
		popups:AddCVar(L"don't kill popups on autofade", "pac_popups_preserve_on_autofade", "1", "0")
		popups:AddOption("Configure popups appearance", function() pace.OpenPopupConfig() end):SetImage('icon16/color_wheel.png')
		local popup_pref_mode, pnlppm = popups:AddSubMenu("prefered location", function() end)
			pnlppm:SetImage("icon16/layout_header.png")
			popup_pref_mode.GetDeleteSelf = function() return false end
			popup_pref_mode:AddOption(L"parts on viewport", function() RunConsoleCommand("pac_popups_preferred_location", "part world") end):SetImage('icon16/camera.png')
			popup_pref_mode:AddOption(L"part label on tree", function() RunConsoleCommand("pac_popups_preferred_location", "pac tree label") end):SetImage('icon16/layout_content.png')
			popup_pref_mode:AddOption(L"menu bar", function() RunConsoleCommand("pac_popups_preferred_location", "menu bar") end):SetImage('icon16/layout_header.png')
			popup_pref_mode:AddOption(L"cursor", function() RunConsoleCommand("pac_popups_preferred_location", "cursor") end):SetImage('icon16/mouse.png')
			popup_pref_mode:AddOption(L"screen", function() RunConsoleCommand("pac_popups_preferred_location", "screen") end):SetImage('icon16/monitor.png')

	local combat_consents, pnlcc = menu:AddSubMenu("pac combat consents", function() end)
	combat_consents.GetDeleteSelf = function() return false end
	pnlcc:SetImage("icon16/joystick.png")
	
	combat_consents:AddCVar(L"damage_zone part (area damage)", "pac_client_damage_zone_consent", "1", "0")
	combat_consents:AddCVar(L"hitscan part (bullets)", "pac_client_hitscan_consent", "1", "0")
	combat_consents:AddCVar(L"force part (physics forces)", "pac_client_force_consent", "1", "0")
	combat_consents:AddCVar(L"lock part's grab (can take control of your position)", "pac_client_grab_consent", "1", "0")
	combat_consents:AddCVar(L"lock part's grab calcview (can take control of your view)", "pac_client_lock_camera_consent", "1", "0")
	
	
	menu:AddSpacer()
	menu:AddOption(L"position grid size", function()
		Derma_StringRequest(L"position grid size", L"size in units:", GetConVarNumber("pac_grid_pos_size"), function(val)
			RunConsoleCommand("pac_grid_pos_size", val)
		end)
	end)
	menu:AddOption(L"angles grid size", function()
		Derma_StringRequest(L"angles grid size", L"size in degrees:", GetConVarNumber("pac_grid_ang_size"), function(val)
			RunConsoleCommand("pac_grid_ang_size", val)
		end)
	end)
	menu:AddCVar(L"render attachments as bones", "pac_render_attachments", "1", "0").DoClick = function() pace.ToggleRenderAttachments() end
	menu:AddSpacer()

	menu:AddCVar(L"automatic property size", "pac_auto_size_properties", "1", "0")
	menu:AddCVar(L"enable language identifier in text fields", "pac_editor_languageid", "1", "0")
	pace.AddLanguagesToMenu(menu)
	pace.AddFontsToMenu(menu)

	menu:AddSpacer()

	local rendering, pnl = menu:AddSubMenu(L"rendering", function() end)
		rendering.GetDeleteSelf = function() return false end
		pnl:SetImage("icon16/camera_edit.png")
		rendering:AddCVar(L"no outfit reflections", "pac_optimization_render_once_per_frame", "1", "0")
end

local function populate_player(menu)
	local pnl = menu:AddOption(L"t pose", function() pace.SetTPose(not pace.GetTPose()) end):SetImage("icon16/user_go.png")
	menu:AddOption(L"reset eye angles", function() pace.ResetEyeAngles() end):SetImage("icon16/user_delete.png")
	menu:AddOption(L"reset zoom", function() pace.ResetZoom() end):SetImage("icon16/magnifier.png")

	-- this should be in pacx but it's kinda stupid to add a hook just to populate the player menu
	-- make it more generic
	if pacx and pacx.GetServerModifiers then
		local mods, pnl = menu:AddSubMenu(L"modifiers", function() end)
		pnl:SetImage("icon16/user_edit.png")
		mods.GetDeleteSelf = function() return false end
		for name in pairs(pacx.GetServerModifiers()) do
			mods:AddCVar(L(name), "pac_modifier_" .. name, "1", "0")
		end
	end
end

function pace.PopulateMenuBarTab(menu, tab)
	if tab == "pac" then
		populate_pac(menu)
	elseif tab == "player" then
		populate_player(menu)
	elseif tab == "options" then
		populate_options(menu)
	elseif tab == "view" then
		populate_view(menu)
	end
end

function pace.OnMenuBarPopulate(bar)
	for k,v in pairs(bar.Menus) do
		v:Remove()
	end

	populate_pac(bar:AddMenu("pac"))
	populate_view(bar:AddMenu(L"view"))
	populate_options(bar:AddMenu(L"options"))
	populate_player(bar:AddMenu(L"player"))
	pace.AddToolsToMenu(bar:AddMenu(L"tools"))

	bar:RequestFocus(true)
	timer.Simple(0.2, function()
		if IsValid(bar) then
			bar:RequestFocus(true)
		end
	end)
end

function pace.OnOpenMenu()
	local menu = DermaMenu()
	menu:SetPos(input.GetCursorPos())

	populate_player(menu) menu:AddSpacer()
	populate_view(menu) menu:AddSpacer()
	populate_options(menu) menu:AddSpacer()
	populate_pac(menu) menu:AddSpacer()

	local menu, pnl = menu:AddSubMenu(L"tools")
	pnl:SetImage("icon16/plugin.png")
	pace.AddToolsToMenu(menu)

	menu:MakePopup()
end
