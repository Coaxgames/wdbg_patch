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
    --print("Original script file found: ".. source_file)
    if source_file then
        local lines = {}
        local line_number = 1
        
        -- Read all lines and modify line 632
        for line in source_file:lines() do
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

        -- Write the modified content back to the original file
        local target_file = io.open(original_script_path, "w")
        if target_file then
            for _, line in ipairs(lines) do
                target_file:write(line .. "\n")
            end
            target_file:close()
            print("File patched successfully!")
        else
            print("Could not open target file for writing")
        end


    else
        print("Could not read source file")
    end
end