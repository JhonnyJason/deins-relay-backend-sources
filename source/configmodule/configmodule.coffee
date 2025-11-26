############################################################
import fs from "fs"
import path from "path"

############################################################
import * as bs from "./bugsnitch.js"

############################################################
localCfg = Object.create(null)
############################################################
try
    configPath = path.resolve(process.cwd(), "./.config.json")
    localCfgString = fs.readFileSync(configPath, 'utf8')
    localCfg = JSON.parse(localCfgString)
catch err
    msg = "@configmodule - config parsing:\n"
    msg += " Local Config File could not be read or parsed!\n "
    msg += err.message
    bs.report(msg)

############################################################
export openAIKey = localCfg.openAIKey || "none"
export snitchSocket = localCfg.snitchSocket || "/run/bugsnitch.sk"

############################################################
export deins_prompt_1_id = "pmpt_68ee58f82f188190a14cd2a2899a25f60f4cac5098d729bb"
export legalHostnames = ["localhost", "assboto-relay-dev.dotv.ee"]
export ttlSessionMS = 7_200_000 # ~2h 
export messageLimit = 66
export probationPeriodMS = 14_400_000 # ~4h

############################################################
export userMessageSizeLimit = 4096
export apiUsageLimit = 150
export apiUsageResetMS = 86_400_000 # ~24h

############################################################
export name = "Deins Relay"
export version = "0.0.1"