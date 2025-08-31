patchEnabled = ModSettingGet("wdbg_patch.enabledpatch")
originalScriptPath = "mods/wand_dbg/files/debugger.lua"
PatchedScriptPath = "data/patchedv1.lua"
Content = nil
Content_orig = nil
Content_new = nil

function GetFileStuff()
    Content = ModTextFileGetContent(PatchedScriptPath)
    Content_orig = ModTextFileGetContent(originalScriptPath)
    return
end
function ApplyPatchToTarget()
    --GetFileStuff() --now called as its needed
    ModTextFileSetContent(originalScriptPath, Content)
    Content_new = ModTextFileGetContent(originalScriptPath)
    print("wdbg Patch applied!")
    return
end

--still in prgress of writing this section, tis ment to overwrite the original script back to the source mod to trigger the restart needed text
function RemovePatchFromTarget()--just test this, it seems like it will work now but i have to head up (Nope, Cant call ModTextFileGetContent after world has loaded)
    ModTextFileSetContent(originalScriptPath, Content_orig)
    Content_new = ModTextFileGetContent(originalScriptPath)
    print("wdbg Patch applied!")
    return
end


--Main logic, Runs once on startup
if patchEnabled and (ModIsEnabled("quant.ew") and ModIsEnabled("wand_dbg")) then
    -- Apply the patch by setting the mod setting to use the patched script
    GetFileStuff()
    ApplyPatchToTarget()
else
    GetFileStuff() --set here for init.lua as a falback
    Content_new = ModTextFileGetContent(originalScriptPath)
    print("No Patch applied!")
    if patchEnabled then
        if not ModIsEnabled("quant.ew") then
            print("Patch Failed! quants.ew is disabled or missing.")
            GamePrint("Patch Failed! quants.ew is disabled or missing.")
        end
        if not ModIsEnabled("wand_dbg") then
            print("Patch Failed! wand_dbg is disabled or missing.")
            GamePrint("Patch Failed! wand_dbg is disabled or missing.")
        end
    end
    
end


