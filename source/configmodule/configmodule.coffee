############################################################
import fs from "fs"
import path from "path"

############################################################
import * as sS from "./serverstatemodule.js"

try
    configPath = path.resolve(process.cwd(), "./.config.json")
    localCfgString = fs.readFileSync(configPath, 'utf8')
    localCfg = JSON.parse(localCfgString)
catch err
    console.error "Local Config File could not be read or parsed!"
    console.error err
    sS.setError(err)
    localCfg = {}

############################################################
export openAIKey = localCfg.openAIKey || "none"
export assistantID = localCfg.assistantID || "none"
export passphrase = localCfg.passphrase || "I shall pass!"

############################################################
export deins_prompt_1_id = "pmpt_68ee58f82f188190a14cd2a2899a25f60f4cac5098d729bb"
export legalOrigins = ["https://localhost"]