-- MM2 Script Loader with Eclipse Hub Authentication
-- This loader first authenticates with Eclipse Hub, then loads the MM2 script

print("🚀 MM2 SCRIPT LOADER STARTING...")
print("🔐 Step 1: Loading Eclipse Hub Authentication...")


getgenv().mainKey = "nil"

local loadstring, request, assert, tostring = loadstring, request or http_request or (http and http.request) or (syn and syn.request), assert, tostring
local eclipseUrl = "https://api.eclipsehub.xyz/auth"


assert(loadstring and request, "Executor not Supported")


local success1, error1 = pcall(function()
    local response = request({
        Url = eclipseUrl .. "?key=" .. tostring(mainKey),
        Headers = {["User-Agent"] = "Eclipse"}
    })
    
    if response and response.Body then
        loadstring(response.Body)()
        print("✅ Eclipse Hub authentication loaded successfully!")
    else
        error("Failed to get response from Eclipse Hub")
    end
end)

if not success1 then
    warn("❌ Eclipse Hub authentication failed: " .. tostring(error1))
    return
end

print("⏳ Waiting for Eclipse Hub to initialize...")
wait(3) -- Give it 3 seconds to fully load

print("🎯 Step 2: Loading MM2 Optimization Script...")

local mm2ScriptUrl = "https://raw.githubusercontent.com/Numass/Clemou/refs/heads/main/mom2.lua"

local success2, error2 = pcall(function()
    local mm2Response = request({
        Url = mm2ScriptUrl,
        Method = "GET"
    })
    
    if mm2Response and mm2Response.Body then
        loadstring(mm2Response.Body)()
        print("✅ MM2 Script loaded successfully from GitHub!")
    else
        error("Failed to load MM2 script from GitHub")
    end
end)

if not success2 then
    warn("❌ MM2 Script loading failed: " .. tostring(error2))
    print("🔄 Falling back to local script execution...")
    
    -- Fallback: Load the local script content if GitHub fails
    -- (You would paste your MM2 script content here as a fallback)
    print("💡 Note: Update the GitHub URL in the loader with your actual repository link")
end

print("🏁 LOADER EXECUTION COMPLETE!")
