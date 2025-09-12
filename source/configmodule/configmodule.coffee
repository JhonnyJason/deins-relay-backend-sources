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
export passphrase = localCfg.passphrase || "I shall pass!"
