function OnModPreInit()
    local patchEnabled = ModSettingGet("wdbg_patch.enabledpatch")
    local originalScriptPath = "mods/wand_dbg/files/debugger.lua"
    local patchedScriptPath = "mods/wdbg_patch/patchedv1.lua"

    if patchEnabled then
        -- Apply the patch by setting the mod setting to use the patched script
        ModSettingSet("wand_dbg.script_path", patchedScriptPath)
        print("wdbg Patch applied!")
        --GamePrint("Patch applied. Please restart the game for changes to take effect.")
    else
        -- Dont Patch the Script
        --ModSettingSet("wand_dbg.script_path", originalScriptPath)
        print("No Patch applied!")
    end
end

function OnWorldPreUpdate()
    if GameGetFrameNum() % 120 == 0 then
        if ModSettingGet("wdbg_patch.enabledpatch") then
            print("Patch Enabled!")
        end
        --GamePrint("Patch state changed. Please restart the game for changes to take effect.")
    end
end