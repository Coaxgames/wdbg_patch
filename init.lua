if ModSettingGet("wdbg_patch.enabledpatch") then
    dofile("mods/wdbg_patch/files/patcher.lua")
end

local done=false
function OnWorldPreUpdate()
    if GameGetFrameNum() % 120 == 0 and not done then
        if ModSettingGet("wdbg_patch.enabledpatch") then
            print("Patch Enabled!")
        else
            print("Patch Disabled!")
        end
        done = true
    end
end