function data()
    return {
        info = {
            minorVersion = 0,
            severityAdd = "NONE",
            severityRemove = "CRITICAL",
            name = _("name"),
            description = _("desc"),
            authors = {
                {
                    name = "Enzojz",
                    role = "CREATOR",
                    text = "Idea, Scripting, Modeling",
                    steamProfile = "enzojz",
                    tfnetId = 27218,
                }
            },
            tags = {"Bridge", "Track", "Wall", "Track Assert", "Train Depot", "Train Station", "Tunnel"},
        },
        postRunFn = function(settings, params)
            local tracks = api.res.trackTypeRep.getAll()
            local trackList = {}
            local trackIconList = {}
            local trackNames = {}
            for __, trackName in pairs(tracks) do
                local track = api.res.trackTypeRep.get(api.res.trackTypeRep.find(trackName))
                local pos = #trackList + 1
                if trackName == "standard.lua" then 
                    pos = 1
                elseif trackName == "high_speed.lua" then 
                    pos = tracks[1] == "standard.lua" and 2 or 1
                end
                table.insert(trackList, pos, trackName)
                table.insert(trackIconList, pos, track.icon)
                table.insert(trackNames, pos, track.name)
            end
            
            local con = api.res.constructionRep.get(api.res.constructionRep.find("track_design_patterns/crossover.con"))
            for i = 1, #con.params do
                local p = con.params[i]
                local param = api.type.ScriptParam.new()
                param.key = p.key
                param.name = p.name
                if (p.key == "trackType") then
                    param.values = trackNames
                else
                    param.values = p.values
                end
                param.defaultIndex = p.defaultIndex or 0
                param.uiType = p.uiType
                con.params[i] = param
            end
            con.updateScript.fileName = "construction/track_design_patterns/crossover.updateFn"
            con.updateScript.params = {
                trackList = trackList,
                trackIconList = trackIconList
            }

            
            local con = api.res.constructionRep.get(api.res.constructionRep.find("track_design_patterns/ladders.con"))
            for i = 1, #con.params do
                local p = con.params[i]
                local param = api.type.ScriptParam.new()
                param.key = p.key
                param.name = p.name
                if (p.key == "trackType") then
                    param.values = trackNames
                else
                    param.values = p.values
                end
                param.defaultIndex = p.defaultIndex or 0
                param.uiType = p.uiType
                con.params[i] = param
            end
            con.updateScript.fileName = "construction/track_design_patterns/ladders.updateFn"
            con.updateScript.params = {
                trackList = trackList,
                trackIconList = trackIconList
            }
            
            local con = api.res.constructionRep.get(api.res.constructionRep.find("track_design_patterns/switch.con"))
            for i = 1, #con.params do
                local p = con.params[i]
                local param = api.type.ScriptParam.new()
                param.key = p.key
                param.name = p.name
                if (p.key == "trackType") then
                    param.values = trackNames
                else
                    param.values = p.values
                end
                param.defaultIndex = p.defaultIndex or 0
                param.uiType = p.uiType
                con.params[i] = param
            end
            con.updateScript.fileName = "construction/track_design_patterns/switch.updateFn"
            con.updateScript.params = {
                trackList = trackList,
                trackIconList = trackIconList
            }
        end
    }
end
