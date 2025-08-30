HasPatched = false
local function get_steam_path()
    -- Query the official Steam registry key
    local handle = io.popen(
    'reg query "HKLM\\SOFTWARE\\WOW6432Node\\Valve\\Steam" /v InstallPath 2>nul || reg query "HKLM\\SOFTWARE\\Valve\\Steam" /v InstallPath 2>nul')
    local result = handle:read("*a")
    handle:close()

    local path = result:match("InstallPath%s+REG_SZ%s+([^\r\n]+)")
    return path
end
local function is_file_empty(file_path)
    local file = io.open(file_path, "r")
    if file then
        local content = file:read("*a") -- Read the entire file
        file:close()
        if content == "" then
            print("File is empty: " .. file_path)
            return false
        else
            return true
        end
    else
        print("Failed to open file: " .. file_path)
        return false
    end
end
local function clear_file(file_path)
    local file = io.open(file_path, "w") -- Open the file in write mode
    if file then
        file:write("") -- Write an empty string to the file
        file:close() -- Close the file
        print("File cleared: " .. file_path)
    else
        print("Failed to open file for clearing: " .. file_path)
    end
end


function OnModPreInit()
    local Original = nil
    local steam_path = get_steam_path()
    print("Steam path: " .. (steam_path or "Not found"))
    print("Loading Patch")

    --Cant overwrite steam mods, and when we can its too late to patch BEFORE the original mod starts using the file. Makes sense on why it works but doesnt patch with steam mods now
    local original_script_path = tostring(steam_path) ..
    "/steamapps/workshop/content/881100/2572385079/files/debugger.lua"                                                    --mods/wand_dbg/files/debugger.lua
    local source_file = io.open(original_script_path, "r")

    --Check if source is in Mods/ instead of steamapps/workshop/content/881100/
    print(tostring(source_file))
    if source_file == nil then
        print("Could not get Original script file from steamapps/workshop/content/881100/")
        source_file = io.open("mods/wand_dbg/files/debugger.lua", "r")
        if source_file == nil then
            print("Original script file not found in either mods/wand_dbg/ or steamapps/workshop/content/881100/")
            return
        end
    end

    --If Source is found then See if we made the patch already-
    print("Err: "..tostring(is_file_empty("mods/wdbg_patch/original.lua")))  
    Original = is_file_empty("mods/wdbg_patch/original.lua")
    

    --only if Original is missing AND enabledpatch is false then proceed with patching, otherwise do nothing here
    --print("Original script file found: ".. source_file)
    if source_file and (ModSettingGet("wdbg_patch.enabledpatch") and not Original) then --if Src file and PatchEnabled AND PatchFile is missing then->
        Original = {}                                                                      --if not format to table rather than nil so it can be written to file later (write the patch)
        local lines = {}
        local OrigLines = {}
        local line_number = 1

        -- Read all lines and modify line 632
        for line in source_file:lines() do
            --save to original file (in line structure)
            table.insert(OrigLines, line)
            --print("Reading line: ".. tostring(line))
            if line_number == 632 then
                print("Found line 632: " .. line)
                local pattern = "EntityHasTag%s*=%s*function%(entity_id,%s*tag%)%s*if%(entity_id%)"
                local replacement =
                "EntityHasTag                             = function(entity_id, tag) if(entity_id == type(\"table\"))"



                -- Apply the replacement to this line
                local modified_line = string.gsub(line, pattern, replacement)

                --Check if it Actually modified, if it didnt dont save the change incase of syntax errors or messed regex remains
                if line ~= modified_line then
                    print("Line 632 modified successfully!")
                    print("  Old: " .. line)
                    print("  New: " .. modified_line)
                    table.insert(lines, modified_line)
                else
                    print("Pattern not found on line 632, keeping original")
                    table.insert(lines, line)
                end

                --Save to Original.lua
                table.insert(Original, line)
            else                             --Just Write the old line to the table
                table.insert(lines, line)
                table.insert(Original, line) --Save to Original.lua
            end
            line_number = line_number + 1
        end
        source_file:close()

        -- Write the modified content back to the original file
        local target_file = io.open(original_script_path, "w")
        local Original_Copy = io.open("mods/wdbg_patch/original.lua", "w")
        --write the copy first
        for _, line in ipairs(Original) do
            Original_Copy:write(line .. "\n")
        end
        Original_Copy:close()
        print("File Copied successfully!")

        --then write the Patch file to the Target mod
        for _, line in ipairs(lines) do
            target_file:write(line .. "\n")
        end
        target_file:close()
        print("File patched successfully!")
        GamePrint("Patch applied. Please restart the game for changes to take effect.")
        HasPatched = true
    elseif source_file and (not ModSettingGet("wdbg_patch.enabledpatch") and Original) then --This is where we will overwrite the mod original with original.lua if enabledpatch is false (removes patch)
        print("Loading Original Mod Data (Un-patching)")    
    -- Write the modified content back to the original file
        local target_file = io.open(original_script_path, "w")
        local Original_Copy = io.open("mods/wdbg_patch/original.lua", "r")
        --write the copy overtop of the original
        for line in Original_Copy:lines() do
            target_file:write(line .. "\n")
        end
        Original_Copy:close()
        print("Original Mod reverted!")

        --then close and delet the Original.lua, (using os.remove as im not sure of any way to do it with safeAPI)
        target_file:close()
        clear_file("mods/wdbg_patch/original.lua")
        print("Patch File Removed!")
        GamePrint("Patch Reverted. Please restart the game for changes to take effect.")
        --these are just fallbacks, not needed but they help me rememeber this whole thing runs 2 times to patch or un-patch
        HasPatched = true

    --these are just fallbacks, not needed but they help me rememeber this whole thing runs 2 times to patch or un-patch
    elseif source_file and (ModSettingGet("wdbg_patch.enabledpatch") and Original) then --Just a empty fallback, this means enabled and Already patched
        print("Already Patched Original Mod Data (Patched)")   
    elseif source_file and (not ModSettingGet("wdbg_patch.enabledpatch") and not Original) then --Just a empty fallback, this means disabled and no patch file exists
        print("Already Reverted to Original Mod Data (Un-patched)")   
    else                                                                                           --if this is ever triggered its edge case or wand_dbg is not installed (other edges: SafeMode on, Unshackled missing, ect)
        print("Could not read source file, please report the issue to the mod author.")
    end
end


function OnWorldPreUpdate()
    if HasPatched and (GameGetFrameNum() % 80 == 0) then
        GamePrint("Patch Applied/Reverted. Please restart the game for changes to take effect.")
    end
end