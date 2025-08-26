local original_script_path = "mods/wand_dbg/files/debugger.lua"

function OnModPreInit()
    local source_file = io.open(original_script_path, "r")
    if source_file then
        local lines = {}
        local line_number = 1
        
        -- Read all lines and modify line 626
        for line in source_file:lines() do
            if line_number == 626 then
                print("Found line 626: " .. line)
                local pattern = "EntityHasTag%s*=%s*function%(entity_id,%s*tag%)%s*if%(entity_id%)"
                local replacement = "EntityHasTag                             = function(entity_id, tag) if(entity_id == type(\"table\"))"
                
                -- Apply the replacement to this line
                local modified_line = string.gsub(line, pattern, replacement)
                
                if line ~= modified_line then
                    print("Line 626 modified successfully!")
                    print("  Old: " .. line)
                    print("  New: " .. modified_line)
                    table.insert(lines, modified_line)
                else
                    print("Pattern not found on line 626, keeping original")
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