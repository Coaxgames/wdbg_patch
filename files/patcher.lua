local patchEnabled = ModSettingGet("wdbg_patch.enabledpatch")
local originalScriptPath = "mods/wand_dbg/files/debugger.lua"
local patchedScriptPath = "mods/wdbg_patch/files/patchedv1.lua"
if patchEnabled then
    -- Apply the patch by setting the mod setting to use the patched script
    local Content = ModTextFileGetContent(patchedScriptPath)
    ModTextFileSetContent(originalScriptPath, Content)
    print("wdbg Patch applied!")
    --GamePrint("Patch applied. Please restart the game for changes to take effect.")
else
    -- Dont Patch the Script
    --ModSettingSet("wand_dbg.script_path", originalScriptPath)
    print("No Patch applied!")
end