dofile("data/scripts/lib/mod_settings.lua")

-- Use ModSettingGet() in the game to query settings.
local mod_id = "wdbg_patch"
mod_settings_version = 1
mod_settings =
{
  {
    category_id = "patch_settings",
    ui_name = "Wand_DBG Patch Settings",
    ui_description = "Enable Patches for wand_DBG here",
    settings =
    {
      {
        id = "enabledpatch",
        ui_name = "Enable MP Fix",
        ui_description = "Fixes Wand_DBG to work with Quants.ew by patching the EntityHasTag function\n(Thats Caused by some other issue but should work anyway as it did for me)",
        value_default = true,
        scope = MOD_SETTING_SCOPE_RUNTIME,
      }
    }
  }
}

-- This function is called to ensure the correct setting values are visible to the game via ModSettingGet(). your mod's settings don't work if you don't have a function like this defined in settings.lua.
-- This function is called:
--		- when entering the mod settings menu (init_scope will be MOD_SETTINGS_SCOPE_ONLY_SET_DEFAULT)
-- 		- before mod initialization when starting a new game (init_scope will be MOD_SETTING_SCOPE_NEW_GAME)
--		- when entering the game after a restart (init_scope will be MOD_SETTING_SCOPE_RESTART)
--		- at the end of an update when mod settings have been changed via ModSettingsSetNextValue() and the game is unpaused (init_scope will be MOD_SETTINGS_SCOPE_RUNTIME)
function ModSettingsUpdate(init_scope)
  local old_version = mod_settings_get_version(mod_id)  -- This can be used to migrate some settings between mod versions.
  mod_settings_update(mod_id, mod_settings, init_scope)
end

-- This function should return the number of visible setting UI elements.
-- Your mod's settings wont be visible in the mod settings menu if this function isn't defined correctly.
-- If your mod changes the displayed settings dynamically, you might need to implement custom logic.
-- The value will be used to determine whether or not to display various UI elements that link to mod settings.
-- At the moment it is fine to simply return 0 or 1 in a custom implementation, but we don't guarantee that will be the case in the future.
-- This function is called every frame when in the settings menu.
function ModSettingsGuiCount()
  -- if (not DebugGetIsDevBuild()) then --if these lines are enabled, the menu only works in noita_dev.exe.
  -- 	return 0
  -- end

  return mod_settings_gui_count(mod_id, mod_settings)
end

function ModSettingsGui(gui, in_main_menu)
  mod_settings_gui(mod_id, mod_settings, gui, in_main_menu)
end
