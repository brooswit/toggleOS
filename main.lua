os.loadAPI( 'prompt.lua' )
os.loadAPI( 'configManager.lua' )
os.loadAPI( 'LDClient.lua' )

local config = configManager.load( "toggleOS" )
-- config.clientSideID = config.clientSideID || prompt( "Enter client-side ID" )
-- config.apiKey       = config.apiKey       || prompt( "Enter API key" )
-- config.flagKey      = config.flagKey      || prompt( "Enter flag key" )
-- config.userKey      = config.userKey      || prompt( "Enter user key" )
configManager.save( "toggleOS", config )

local ldClient = nil
local function reinit()
    if ldClient ~= nil then
        ldClient.close()
        ldClient = nil
    end
    ldClient = launchDarkly.init( config.clientSideID, { key = config.userKey } )
end

local function reidentify()
    if ldClient ~= nil then
        ldClient.identify( { key = config.userKey } )
    end
end

local state = "main"
while true do
    local ldVariation = nil
    if ldClient != nil then
        ldVariation = ldClient.variation( config.flagKey )
    end

    local choice = nil
    local event, key = os.pullEvent( "key_up" )
    if key == keys.one then choice = 1
    elseif key == keys.two then
        choice = 2
    elseif key == keys.three then
        choice = 3
    elseif key == keys.four then
        choice = 4
    elseif key == keys.five then
        choice = 5
    elseif key == keys.six then
        choice = 6
    elseif key == keys.seven then
        choice = 7
    elseif key == keys.eight then
        choice = 8
    elseif key == keys.nine then
        choice = 9
    elseif key == keys.zero then
        choice = 0
    end

    term.setBackgroundColor(colours.black)  -- Set the background colour to black.
    term.clear()                            -- Paint the entire display with the current background colour.
    term.setCursorPos(1,1)                  -- Move the cursor to the top left position.

    print( "--------------------------------------------------------------------------------" )
    print( "--                            Welcome to ToggleOS                             --" )
    print( "--------------------------------------------------------------------------------" )
    print( "Flag " .. config.flagKey .. " is serving " .. ldVariation .. " to user " .. config.userKey .. ".")
    print( "--------------------------------------------------------------------------------" )
    if state == "main" then
        print( "--                                 Main Menu                                  --" )
        print( "--------------------------------------------------------------------------------" )
        print( "Choose an option:" )
        print( "1 ) Configure LaunchDarkly" )
        print( "2 ) Configure Interfaces" )
        print( "--------------------------------------------------------------------------------" )
        if choice == 1 then
            state = "config_ld"
        elseif choice == 2 then
            state = "config_faces"
        elseif choice ~= nil then
            print( "INVALID INPUT: " .. choice)
        end


    elseif state == "config_ld" then
        print( "--                           Configure LaunchDarkly                           --" )
        print( "--------------------------------------------------------------------------------" )
        print( "1 ) Change client-side ID" )
        print( "2 ) Change API key" )
        print( "3 ) Change flag key" )
        print( "4 ) Change user key" )
        print( "5 ) Add, remove, or change user attributes" )
        print( "6 ) Change flag state" )
        print( "7 ) Change flag targeting" )
        print( "--------------------------------------------------------------------------------" )
        print( "0 ) Go back" )
        if choice == 1 then
            promptFor("client_side_id")
        elseif choice == 2 then
            promptFor("api_key")
        elseif choice == 3 then
            promptFor("flag_key")
        elseif choice == 4 then
            promptFor("user_key")
        elseif choice == 0 then
            state = "main"
        elseif choice ~= nil then
            print( "INVALID INPUT: " .. choice)
        end


    elseif state == "config_faces" then
        print( "--                            Configure Interfaces                            --" )
        print( "--------------------------------------------------------------------------------" )
        print( "1 ) Front   - (STATUS)" )
        print( "2 ) Back    - (STATUS)" )
        print( "3 ) Right   - (STATUS)" )
        print( "4 ) Left    - (STATUS)" )
        print( "5 ) Top     - (STATUS)" )
        print( "6 ) Buttom  - (STATUS)" )
        print( "7 ) Default - (STATUS)" )
        print( "--------------------------------------------------------------------------------" )
        print( "0 ) Go back" )
        if choice == 0 then
            state = "main"
        elseif choice ~= nil then
            print( "INVALID INPUT: " .. choice)
        end


    elseif state == "config_face" then
        print( "--                            Configure Interface                             --" )
        print( "--------------------------------------------------------------------------------" )
        print( "Side (SIDE) is currently configured to (STATUS).")
        print( "--------------------------------------------------------------------------------" )
        print( "1 ) Disabled                 (Do nothing)" )
        print( "2 ) Default                  (Use behavior of 'default' face)" )
        print( "3 ) Output - flag variation  (Output redstone signal)" )
        print( "4 ) Input  - track goal      (Track a specific goal using redstone signal)" )
        print( "5 ) Input  - goal metric     (Track a specific metric using redstone signal)" )
        print( "6 ) Input  - flag state      (Turn flag on/off using redstone signal)" )
        print( "7 ) Input  - flag targeting  (Turn flag on/off for user using redstone signal)")
        print( "8 ) Input  - redstone state  (Include redstone signal in user attributes)" )
        print( "9 ) Input  - redstone count  (Include redstone signal in user attributes)" )
        print( "--------------------------------------------------------------------------------" )
        print( "0 ) Go back" )
        if choice == 0 then
            state = "main"
        elseif choice ~= nil then
            print( "INVALID INPUT: " .. choice)
        end


    else
        print( "INVALID STATE: " .. state)
        state="main"


    end
    sleep( 0 )
end