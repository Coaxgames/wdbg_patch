if ModSettingGet("wdbg_patch.enabledpatch") then
    dofile("mods/wdbg_patch/data/patcher.lua")
end


function OnWorldPreUpdate()
    if GameGetFrameNum() % 120 == 0 then
        if ModSettingGet("wdbg_patch.enabledpatch") then
            --print("Patch Enabled!")
            if Content_orig == Content_new then
                GamePrint("PATCH: Restart Required for wand_dbg patch to Take effect")
            end
        else
            --print("Patch Disabled!")
            if Content_new == Content_orig then
                --GamePrint("Debug: Un-patched content while disabled (no restart needed)")
            elseif Content_new ~= Content_orig then
                GamePrint("PATCH: Restart Required for wand_dbg restoration to Take effect")
            end
        end
    end
end
