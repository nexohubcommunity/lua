return {
    junkiedevelopment = {
        Name = "Junkie Development",
        Icon = "rbxassetid://106310347705078",
        Args = {"ServiceId", "ApiKey", "Provider"},

        New = require("./JunkieDevelopment").New
    },
}
