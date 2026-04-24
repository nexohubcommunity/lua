local JunkieDevelopment = {}

function JunkieDevelopment.New(ServiceId, ApiKey, Provider)
    JunkieProtected.API_KEY = ApiKey
    JunkieProtected.PROVIDER = Provider
    JunkieProtected.SERVICE_ID = ServiceId

    local function ValidateKey(key)
        if not key or key == "" then
            print("No key provided!")
            return false, "No key provided. Please get a key."
        end

        local keylessCheck = JunkieProtected.IsKeylessMode()
        if keylessCheck and keylessCheck.keyless_mode then
            print("Keyless mode enabled. Starting script...")
            return true, "Keyless mode enabled. Starting script..."
        end

        local result = JunkieProtected.ValidateKey({ Key = key })
        if result == "valid" then
            print("Key is valid! Starting script...")
            load()                                                                                                               
            if _G.JD_IsPremium then                       
                print("Premium user detected!")
            else
                print("Standard user")
            end

            return true, "Key is valid!"
        else
            local keyLink = JunkieProtected.GetKeyLink()
            print("Invalid key!")
            return false, "Invalid key. Get one from:" .. keyLink
        end                                                                                                            
    end

    local function copyLink()
        local link = JunkieProtected.GetKeyLink()                                                                                        
        if setclipboard then
            setclipboard(link)
        end
    end                                                                                                                                                                                                                                                                       
    return {
        Verify = ValidateKey,
        Copy = copyLink
    }
end

return JunkieDevelopment


