if ModSettingGet("wdbg_patch.enabledpatch") then
    dofile("mods/wdbg_patch/data/patcher.lua")
end

local done, done2 = false, false
function OnWorldPreUpdate()
    if GameGetFrameNum() % 120 == 0 then
        if ModSettingGet("wdbg_patch.enabledpatch") then
            if not done then GamePrint("Patch Enabled!") done=true done2=false end
            if Content_orig == Content_new then
                GamePrint("PATCH: Restart Required for wand_dbg patch to Take effect")
            end
        else
            if not done2 then GamePrint("Patch Disabled!") done=false done2=true end
            if Content_new == Content_orig then
                --GamePrint("Debug: Un-patched content while disabled (no restart needed)")
            elseif Content_new ~= Content_orig then
                GamePrint("PATCH: Restart Required for wand_dbg restoration to Take effect")
            end
        end
    end
end
