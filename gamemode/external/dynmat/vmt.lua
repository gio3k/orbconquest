-- VMTParser: basic VMT reading functions
-- 2021, par0-git
-- please refer to this image: https://cdn.discordapp.com/attachments/508965036325339140/834419248486809650/unknown.png

VMTVariableType = {}
VMTParserStatus = {}
VMTParser = {}

VMTVariableType = {
	Undefined = 1,
	--Color = 2,
	Float = 3,
	Int = 4,
	--Matrix = 5,
	String = 6,
	Texture = 7, -- how am I supposed to get the texture from just a string ???
	Vector = 8,
	--Vector4 = 9,
	
	-- Texture Extensions
	PNGTexture = 10,
	EngineTexture = 11
}

VMTParserStatus = {
	Looking = 1, -- Initial state. Looks for first table
	ReadingVariableKey = 2, -- Reading keys
	ReadingVariableValue = 3, -- Reading values 
	Comment = 4 -- Waiting for a new line
}

VMTParserDataStatus = {
	None = 1,
	Quotes = 2,
	Spaces = 3
}

VMTParser = {
	-- If set to true texture types are added for use with Dynamic Materials 
	textureExtensions = true,
	
	-- getVariableType(string) return VMTVariableType
	-- Takes text [string] and figures out what variable it is
	getVariableType = function(text)
		if (#text == 0) then return VMTVariableType.Undefined end -- No text to parse
		
		-- Create variables
		local textContainsDot = false
		local textContainsSquareBracket = false
		local textDelimiterAmount = 0 -- Amount of commas
		local textContainsOnlyNumericCharacters = tonumber(text) ~= nil -- Make this character based
		
		-- Clean string
		text = VMTParser.clean(text)
		
		-- Read string & set variables
		text:gsub(".", function(c)
			if (c == "[" or c == "]") then textContainsSquareBracket = true end
			if (c == ",") then textDelimiterAmount = textDelimiterAmount + 1 end -- Comma check
			if (c == ".") then textContainsDot = true end -- Dot check
		end)
			
		if (textContainsOnlyNumericCharacters) then
			-- Is a number
			if (textContainsDot) then
				-- Decimal place
				return VMTVariableType.Float
			else
				-- No decimal place
				return VMTVariableType.Int
			end
		end
		
		--if (textContainsSquareBracket and textContainsDot) then return VMTVariableType.Vector end
		if (textContainsSquareBracket) then return VMTVariableType.Vector end -- should this be matrix or vector ??? who knows
		
		-- Check for texture extensions
		if (VMTParser.textureExtensions) then
			-- 4 char prefix: ???@
			-- eg.: png:
			-- eg.: eng: 
			if (#text < 4) then goto cont end -- Not big enough for a prefix
			local prefix = text:sub(1, 4)

			if (prefix:sub(#prefix) ~= ":") then goto cont end -- Check for : at end of prefix
			
			local extension = prefix:sub(1,3)
			if (extension == "png") then
				-- PNG Texture
				return VMTVariableType.PNGTexture
			elseif (extension == "eng") then
				-- Engine Texture
				return VMTVariableType.EngineTexture
			end
		end

		::cont::
		-- Can't find a suitable variable type, just be a string
		return VMTVariableType.String
	end,
	
	-- clean(string, bool, bool) return string
	-- Takes a generic string [string] and cleans it for use in parsing
	clean = function(text, removeQuotes, removeWhitespace)
		removeQuotes = removeQuotes or true
		removeWhitespace = removeWhitespace or true
	
		if (removeQuotes) then 
			if (text:sub(1, 1) == '"' and -- Check for quote at start of string
				text:sub(#text) == '"') then -- Check for quote at end of string
				text = text:sub(2, #text-1) -- Remove double quotes
			end
		end
		
		if (removeWhitespace) then
			-- http://lua-users.org/wiki/StringTrim
			text = text:gsub("^%s*(.-)%s*$", "%1")
		end
		
		return text
	end,
	
    -- parse(string) return table
	-- Takes a VMT file [string] and parses it into a table
	parse = function(text)
		if (text == nil) then print("VMT [error]: Provided text to parse was nil") return end

		-- Generic variables
		local result = {}
        local saved = "" -- Saved data by handleData() if it can't do anything with it when ran
        local preCommentStatus = VMTParserStatus.Looking
        -- Variables for parsing the text
        local preComment = false -- Has the first comment character been used?
		local buffer = ""
		local method = VMTParserDataStatus.None
        local status = VMTParserStatus.Looking

		-- Functions
		local function handleData(data) -- Deal with any data
            if (status == VMTParserStatus.Looking) then
                -- Assume that this is a variable name
                status = VMTParserStatus.ReadingVariableKey
            elseif (status == VMTParserStatus.ReadingVariableKey) then
                -- Assume that this is a variable value
                -- We can just use "saved" for the variable name because it hasn't been reset yet
                result[saved] = {}
                result[saved].value = data
                result[saved].type = VMTParser.getVariableType(data)

                -- Reset status
                status = VMTParserStatus.Looking
            end
            
            buffer = ""
            saved = data
		end

		local function handleTableStart(name)
			-- Table start should create & prepare a new table and set it to current table
            status = VMTParserStatus.Looking

            -- Create table
            result[name] = {}

            -- Prepare table
            result[name].parent = result

            -- Set it to current table
            result = result[name]

            -- Clear buffer
            buffer = ""
		end

		local function handleTableEnd()
			-- Table end should clean buffers and set current table to its parent
            status = VMTParserStatus.Looking

            -- Check if current table is global
            if (result.parent == nil) then
                print("VMT [warn]: Can't get parent of global table. Too many close brackets?")
                return
            end

            -- Set current table to its parent
            result = result.parent

            -- Clear buffer
            buffer = ""
		end

		-- Loop over every character in the text
		text:gsub(".", function(c)
            -- Check if this is a comment
            if (status == VMTParserStatus.Comment) then
                if (c == '\n') then
                    status = preCommentStatus
                end
                return
            end
 
            if (method == VMTParserDataStatus.Spaces and (string.byte(c) == 10 or string.byte(c) == 13 or c == ' ' or c == '\t')) then
                -- Space found while we are looking for spaces, perfect!
                -- Handle this word
                handleData(buffer)

                -- Reset method to default
                method = VMTParserDataStatus.None
                return
            end

            -- Don't bother with newlines
			if (string.byte(c) == 10 or string.byte(c) == 13) then return end 

            -- Don't bother with spaces if not reading data
			if (c == ' ' and method == VMTParserDataStatus.None) then return end 

            -- Don't bother with tabs
			if (c == '\t') then return end 

            -- Check for comment
            if (c == '/') then
                if (preComment) then status = VMTParserStatus.Comment end -- It's a comment!
                preComment = true
                return
            elseif (c ~= '/' and preComment) then
                preComment = false
            end

            -------------------
            -- Handle quotes --
            -------------------

            -- Check for starting quote
            if (c == '"' and method == VMTParserDataStatus.None) then
                -- Clear buffer
                buffer = ""
                
                -- Set method to read quotes
                method = VMTParserDataStatus.Quotes
                return
            end

            -- Check for ending quote
            if (c == '"' and method == VMTParserDataStatus.Quotes) then 
                -- Handle data
                handleData(buffer)

                -- Reset method to default
                method = VMTParserDataStatus.None
                return
            end

            -- Don't bother doing anything while inside quotes
            if (method == VMTParserDataStatus.Quotes) then
                buffer = buffer .. c
                return
            end

            ------------------------------
            -- Handle table start & end --
            ------------------------------ 

            -- Check for table start
            if (c == '{' and status == VMTParserStatus.ReadingVariableKey) then
                handleTableStart(saved) -- Handle table start with saved data
                return
            elseif (c == '{') then
                print ("VMT [warn]: Unexpected table starter. (status):" .. status) 
            end

            -- Check for table end
            if (c == '}' and status == VMTParserStatus.Looking)  then
                handleTableEnd() -- Handle table end
                return
            elseif (c == '}') then
                print ("VMT [warn]: Unexpected table end. (status):" .. status) 
            end

            --------------------------
            -- Handle unquoted data --
            -------------------------- 

            -- Check for data
            -- At this point in the function there would be nothing else to do, everything else has been looked for
            if (method ~= VMTParserDataStatus.Spaces and (status == VMTParserStatus.Looking or status == VMTParserStatus.ReadingVariableKey)) then
                -- Nothing else to do with this data, start searching for 1 word strings
                method = VMTParserDataStatus.Spaces
            end

            -- Add to buffer if we make it here
            buffer = buffer .. c -- Add to buffer
		end)

        return result
	end,

    -- toVector(string) return Vector
	-- Takes a string [Matrix] and parses it into the desired type
    toVector = function(input)
		input = VMTParser.clean(input)

        if (input:sub(1, 1) == '[' and input:sub(#input) == ']') then -- Check for brackets at start and end of string
			input = input:sub(2, #input-1) -- Remove brackets
        else print("VMT [warn]: Provided matrix did not contain start or end bracket.") end

        local result = Vector()
        local index = 1

        for key in input:gmatch("([^ ]+)") do 
            result[index] = tonumber(key)
            index = index + 1
        end
        
        return result
    end,
}