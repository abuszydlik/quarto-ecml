-- Filter to remove 'caption' package. Generated with the help of Claude Sonnet 3.7 

-- remove_caption.lua
-- This script will remove caption package commands from a tex file

-- Get the output file path from Quarto's environment variable
local output_file = os.getenv("QUARTO_OUTPUT_FILE")

-- Only process .tex files
if output_file and output_file:match("%.tex$") then
  print("Processing TeX file: " .. output_file)

  -- Read the file
  local file = io.open(output_file, "r")
  if not file then
    print("Error: Could not open " .. output_file)
    os.exit(1)
  end
  
  local content = file:read("*all")
  file:close()
  
  -- Store original length for comparison
  local original_length = #content
  
  -- Remove the caption package commands - matching different possible formats
  content = content:gsub("\\@ifpackageloaded%s*{caption}%s*{}%s*{%s*\\usepackage%s*{caption}%s*}", "")
  content = content:gsub("\\@ifpackageloaded%s*{subcaption}%s*{}%s*{%s*\\usepackage%s*{subcaption}%s*}", "")
  
  -- Check if we made any changes
  if #content < original_length then
    print("Removed caption commands: " .. (original_length - #content) .. " characters")
    
    -- Write the modified content back
    local out_file = io.open(output_file, "w")
    if not out_file then
      print("Error: Could not write to " .. output_file)
      os.exit(1)
    end
    out_file:write(content)
    out_file:close()
    print("Successfully updated " .. output_file)
  else
    print("No caption commands found in " .. output_file)
  end
else
  print("No .tex file to process")
end