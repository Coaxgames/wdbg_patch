HasPatched = false
local function get_steam_path()
    -- Query the official Steam registry key
    local handle = io.popen('reg query "HKLM\\SOFTWARE\\WOW6432Node\\Valve\\Steam" /v InstallPath 2>nul || reg query "HKLM\\SOFTWARE\\Valve\\Steam" /v InstallPath 2>nul')
    local result = handle:read("*a")
    handle:close()
    
    local path = result:match("InstallPath%s+REG_SZ%s+([^\r\n]+)")
    return path
end


function OnModPreInit()

    local steam_path = get_steam_path()
    print("Steam path: " .. (steam_path or "Not found"))
    print("Loading Patch")

    --Cant overwrite steam mods, and when we can its too late to patch BEFORE the original mod starts using the file. Makes sense on why it works but doesnt patch with steam mods now
    local original_script_path = tostring(steam_path).."/steamapps/workshop/content/881100/2572385079/files/debugger.lua" --mods/wand_dbg/files/debugger.lua
    local source_file = io.open(original_script_path, "r")

    --Get size of target file
    local file_size = source_file:seek("end")
    local Patch_File = io.open("mods/wdbg_patch/files/cachedpatch.lua", "r")
    local Patch_FS = Patch_File:seek("end") or 0
    source_file:close()
    if Patch_File then Patch_File:close() end

    print ("Target file size: ".. tonumber(file_size))
    print ("Patch file size: ".. tonumber(Patch_FS))
    if tonumber(file_size) == tonumber(Patch_FS) then
         print ("Patch Already applied!")
         HasPatched = true
    else
        source_file = io.open(original_script_path, "r")
        print ("Re-opened file!")
    end
    

    --print("Original script file found: ".. source_file)
    if source_file and not HasPatched then
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
                local replacement = "EntityHasTag                             = function(entity_id, tag) if(entity_id == type(\"table\"))"
                
                

                -- Apply the replacement to this line
                local modified_line = string.gsub(line, pattern, replacement)
                
                if line ~= modified_line then
                    print("Line 632 modified successfully!")
                    print("  Old: " .. line)
                    print("  New: " .. modified_line)
                    table.insert(lines, modified_line)
                else
                    print("Pattern not found on line 632, keeping original")
                    table.insert(lines, line)
                end
            else
                table.insert(lines, line)
            end
            line_number = line_number + 1
        end
        source_file:close()

    --Patch and Cache section

        -- Write the modified content back to the original file
        local target_file = io.open(original_script_path, "w")
        local orig_file = io.open("mods/wdbg_patch/files/cachedoriginal.lua", "w")
        local Cached_file = io.open("mods/wdbg_patch/files/cachedpatch.lua", "w")

        --write the patch to the Target mod file
        if target_file then
            for i, line1 in pairs(lines) do --write the new and old lines at once 
                --print("Writing line to target file: ".. tostring(line1))
                target_file:write(line1 .. "\n")
                Cached_file:write(line1 .. "\n")
            end
            target_file:close()
            Cached_file:close()
            print("File patched and Cached successfully!")

            --then write the original to a separate file we can restore later if needed
            for i, line2 in pairs(OrigLines) do
                orig_file:write(line2 .. "\n")
            end
            orig_file:close()
            print("Original File Cached successfully!")
        else
            print("Could not open target file for writing")
        end

        --later on consider editing the enabledmods file in th users save00 folder to disable this mod, the next time its enabled it can re-install the original (maybe if a setting is set to false though)


    else
        print("Could not read source file OR already patched (will make this clear in the future)")
    end
end
