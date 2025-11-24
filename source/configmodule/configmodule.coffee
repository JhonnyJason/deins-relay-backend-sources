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

############################################################
export deins_prompt_1_id = "pmpt_68ee58f82f188190a14cd2a2899a25f60f4cac5098d729bb"
export legalOrigins = ["https://localhost"]
export ttlSessionMS = 7_200_000 # ~2h 
export messageLimit = 66

############################################################
export name = "Deins Relay"
export version = "0.0.1"