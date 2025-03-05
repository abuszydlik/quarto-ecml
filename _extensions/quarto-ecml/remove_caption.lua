-- Filter to remove 'caption' package. Generated with the help of Claude Sonnet 3.7 

-- remove_caption.lua
-- This script will find and modify the TeX file based on the PDF output

-- Get the list of output files from Quarto's environment variable
local output_files_str = os.getenv("QUARTO_PROJECT_OUTPUT_FILES")

if not output_files_str or output_files_str == "" then
  print("No output files found in QUARTO_PROJECT_OUTPUT_FILES")
  os.exit(0)
end

-- Split the newline-separated list into individual files
local output_files = {}
for file in output_files_str:gmatch("[^\r\n]+") do
  table.insert(output_files, file)
end

-- Process each output file
local processed = false
for _, file_path in ipairs(output_files) do
  -- We're looking for PDF files, but will process their corresponding TeX files
  if file_path:match("%.pdf$") then
    print("Found PDF file: " .. file_path)
    
    -- Determine the corresponding TeX file
    local tex_file = file_path:gsub("%.pdf$", ".tex")
    print("Looking for TeX file: " .. tex_file)
    
    -- Check if the TeX file exists
    local tex_handle = io.open(tex_file, "r")
    if not tex_handle then
      print("Error: Could not find TeX file " .. tex_file)
      goto continue
    end
    
    -- Read the TeX file content
    local content = tex_handle:read("*all")
    tex_handle:close()
    
    -- Store original length for comparison
    local original_length = #content
    
    -- Remove the caption package commands
    content = content:gsub("\\@ifpackageloaded%s*{caption}%s*{}%s*{%s*\\usepackage%s*{caption}%s*}", "")
    content = content:gsub("\\@ifpackageloaded%s*{subcaption}%s*{}%s*{%s*\\usepackage%s*{subcaption}%s*}", "")
    
    -- Check if we made any changes
    if #content < original_length then
      print("Removed caption commands: " .. (original_length - #content) .. " characters")
      
      -- Write the modified content back
      local out_file = io.open(tex_file, "w")
      if not out_file then
        print("Error: Could not write to " .. tex_file)
        goto continue
      end
      out_file:write(content)
      out_file:close()
      print("Successfully updated " .. tex_file)
      
      -- Recompile the PDF
      os.execute("latexmk -synctex=1 -interaction=nonstopmode -file-line-error -pdf " .. tex_file)
      print("Recompiled PDF: " .. file_path)
      
      processed = true
    else
      print("No caption commands found in " .. tex_file)
    end
    
    ::continue::
  end
end

if not processed then
  print("No PDF files were found to process their corresponding TeX files")
end