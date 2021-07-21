os.loadAPI( 'prompt.lua' )
os.loadAPI( 'configManager.lua' )
os.loadAPI( 'LDClient.lua' )

local function cleanConfig(config)
    local cleanConfig = {}

    local defaultConfig = {
        clientSideID = "",
        apiKey = "",
        flagKey = "",
        userKey = ""
    }

    for configKey, configValue in pairs(defaultConfig) do
        if config[configKey] ~= nil then
            cleanConfig[configKey] = config[configKey]
        else
            cleanConfig[configKey] = defaultConfig[configKey]
        end
    end

    return cleanConfig
end

local config = configManager.load( "toggleOS" )
config = cleanConfig(config)
configManager.save( "toggleOS", config )

local prevConfig = nil

local state = {
    ldClient = nil,
    ldVariation = nil,

    prevClientSideID = nil,
    prevUserKey = nil,
}

local function updateLaunchDarkly()
    state.ldVariation = nil
    if config.clientSideID ~= state.prevClientSideID then
        state.prevClientSideID = config.clientSideID
        if state.ldClient ~= nil then
            state.ldClient.close()
            state.ldClient = nil
        end
        if config.clientSideID ~= "" then
            state.ldClient = launchDarkly.init( config.clientSideID, { key = config.userKey } )
        end
    else
        if config.userKey ~= state.prevUserKey then
            state.prevUserKey = config.userKey
            if state.ldClient ~= nil then
                state.ldClient.identify( { key = config.userKey } )
            end
        end
    end
    if state.ldClient ~= nil then
        if state.flagKey ~= "" and state.userKey ~= ""  then
            state.ldVariation = state.ldClient.variation()
        end
    end
end

local function printLDStatus(config)
    if state.ldClient == nil then
        print("No Client-Side ID provided")
    elseif not state.ldClient.isInitialized() then
        if not state.ldClient.isLDReachable() then
            print("LaunchDarkly is not reachable")
        elseif not state.ldClient.isClientSideIDValid() then
            print("Invalid Client-Side ID")
        end
    elseif state.userKey == nil then
        print("No User key provided")
    elseif state.flagKey == nil then
        print("No Flag key provided")
    else
        print( "LD Flag " .. config.flagKey .. " is serving " .. state.ldVariation .. " to user " .. config.userKey )
    end
end

local stateName = "main"
local choice = nil
local skipInput = false

while true do
    config = cleanConfig(config)
    updateLaunchDarkly()

    term.setBackgroundColor(colours.black)  -- Set the background colour to black.
    term.clear()                            -- Paint the entire display with the current background colour.
    term.setCursorPos(1,1)                  -- Move the cursor to the top left position.

-------------------------------------------------------
    print( '===================================================' )
    print( '==              Welcome to ToggleOS              ==' )
    print( '===================================================' )
    printLDStatus(config)
    print( '---------------------------------------------------' )
    if stateName == 'main' then
        print( '--                  Main Menu                    --' )
        print( '---------------------------------------------------' )
        print( 'Choose an option:' )
        print( '1 ) Configure LaunchDarkly' )
        print( '2 ) Configure Interfaces' )
        print( '---------------------------------------------------' )
    elseif stateName == 'config_ld' then
        print( '--             Configure LaunchDarkly            --' )
        print( '---------------------------------------------------' )
        print( '1 ) Change Client-Side ID - ("' .. config.clientSideID .. '")' )
        print( '2 ) Change API key' )
        print( '3 ) Change Flag key - ("' .. config.flagKey .. '")' )
        print( '4 ) Change User key - ("' .. config.userKey .. '")' )
        print( '5 ) Add, remove, or change user attributes' )
        print( '6 ) Change flag state' )
        print( '7 ) Change flag targeting' )
        print( '---------------------------------------------------' )
        print( '0 ) Go back' )
    elseif stateName == 'config_faces' then
        print( '--              Configure Interfaces             --' )
        print( '---------------------------------------------------' )
        print( '1 ) Front   - (STATUS)' )
        print( '2 ) Back    - (STATUS)' )
        print( '3 ) Right   - (STATUS)' )
        print( '4 ) Left    - (STATUS)' )
        print( '5 ) Top     - (STATUS)' )
        print( '6 ) Buttom  - (STATUS)' )
        print( '7 ) Default - (STATUS)' )
        print( '---------------------------------------------------' )
        print( '0 ) Go back' )
    elseif stateName == 'config_face' then
        print( '--              Configure Interface              --' )
        print( '---------------------------------------------------' )
        print( 'Side (SIDE) is currently configured to (STATUS).')
        print( '---------------------------------------------------' )
        print( '1 ) Disabled                 (Do nothing)' )
        print( '2 ) Default                  (Use behavior of 'default' face)' )
        print( '3 ) Output - flag variation  (Output redstone signal)' )
        print( '4 ) Input  - track goal      (Track a specific goal using redstone signal)' )
        print( '5 ) Input  - goal metric     (Track a specific metric using redstone signal)' )
        print( '6 ) Input  - flag state      (Turn flag on/off using redstone signal)' )
        print( '7 ) Input  - flag targeting  (Turn flag on/off for user using redstone signal)')
        print( '8 ) Input  - redstone state  (Include redstone signal in user attributes)' )
        print( '9 ) Input  - redstone count  (Include redstone signal in user attributes)' )
        print( '---------------------------------------------------' )
        print( '0 ) Go back' )
    else
        print( 'INVALID STATE: ' .. stateName)
        skipInput = true
    end

    choice = nil
    if not skipInput then
        local event, key = os.pullEvent( "key_up" )
        if key == keys.one then
        choice = 1
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
    end
    skipInput = false

    if stateName == "main" then
        if choice == 1 then
            stateName = "config_ld"
        elseif choice == 2 then
            stateName = "config_faces"
        elseif choice ~= nil then
            print( "INVALID INPUT: " .. choice)
        end


    elseif stateName == "config_ld" then
        if choice == 1 then
            print("Enter new client-side ID: ")
            state.clientSideID = read()
        -- elseif choice == 2 then
            -- promptFor("api_key")
        elseif choice == 3 then
            print("Enter new Flag key: ")
            state.flagKey = read()
        elseif choice == 4 then
            print("Enter new User key: ")
            state.userKey = read()
        elseif choice == 0 then
            stateName = "main"
        elseif choice ~= nil then
            print( "INVALID INPUT: " .. choice)
        end


    elseif stateName == "config_faces" then
        if choice == 0 then
            stateName = "main"
        elseif choice ~= nil then
            print( "INVALID INPUT: " .. choice)
        end


    elseif stateName == "config_face" then
        if choice == 0 then
            stateName = "main"
        elseif choice ~= nil then
            print( "INVALID INPUT: " .. choice)
        end


    else
        stateName="main"
    end

    sleep(0)
end
