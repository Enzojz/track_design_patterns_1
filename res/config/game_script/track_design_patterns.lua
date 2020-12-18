local script = {
    guiHandleEvent = function(id, name, param)
        if id == "constructionBuilder" then
            if name == "builder.proposalCreate" then
                local toAdd = param.proposal.toAdd
                if toAdd and #toAdd == 1 then
                    local con = toAdd[1]
                    if (con.fileName == [[track_design_patterns/switch.con]]
                        or con.fileName == [[track_design_patterns/ladders.con]]
                        or con.fileName == [[track_design_patterns/crossover.con]]) then
                        if not api.gui.util.getById("tdp.menu.img") then
                            local trackIconList = api.res.constructionRep.get(api.res.constructionRep.find(con.fileName)).updateScript.params.trackIconList
                            local menu = api.gui.util.getById("menu.construction.terrain.settings")
                            local menuLayout = menu:getLayout()
                            local tr = menuLayout:getItem(1)
                            local layout = tr:getLayout()
                            local cbox = layout:getItem(1)
                            local img = api.gui.comp.ImageView.new(trackIconList[cbox:getCurrentIndex() + 1])
                            img:setId("tdp.menu.img")
                            layout:addItem(img)
                            layout:removeItem(cbox)
                            layout:addItem(cbox)
                            cbox:onIndexChanged(function(i)img:setImage(trackIconList[i + 1], true) end)
                        end
                    end
                end
            end
        end
    end
}

function data()
    return script
end
