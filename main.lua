-- Binary switch type should handle actions turnOn, turnOff
-- To update binary switch state, update property "value" with boolean



-- To update controls you can use method self:updateView(<component ID>, <component property>, <desired value>). Eg:  
-- self:updateView("slider", "value", "55") 
-- self:updateView("button1", "text", "MUTE") 
-- self:updateView("label", "text", "TURNED ON") 

-- This is QuickApp inital method. It is called right after your QuickApp starts (after each save or on gateway startup). 
-- Here you can set some default values, setup http connection or get QuickApp variables.
-- To learn more, please visit: 
--    * https://manuals.fibaro.com/home-center-3/
--    * https://manuals.fibaro.com/home-center-3-quick-apps/

function loop()
   print("looooooping")
   
    setTimeout(loop,2*1000)
    QuickApp:turn2()
  -- self:updateView("labeltemp", "text", tostring(tempe)) 
   -- call function loop again in 1 minute
end



function QuickApp:onInit()
    self:debug("onInit")
    self:updateView("slider","min","16")
    self:updateView("slider","max", "28")
    self:updateView("slider", "value", "21") 
    
    --local lang = self:getVariable('language')
    --lang = tonumber(lang)
    --local pass = self:getVariable('password')
    --pass = json.decode(pass)
    --local user = self:getVariable('Username')
    --print(tostring('user'))
    lang = self:getVariable("language")
    pass = self:getVariable("password")
    user = self:getVariable("Username")
    self:turnOn()
    QuickApp:turn1()
    fibaro.setTimeout(3000, function() QuickApp:turn2() end)
    fibaro.setTimeout(5000, function() QuickApp:gettemp() end)
    fibaro.setTimeout(604800000, function() QuickApp:onInit() end)

    

end

function QuickApp:turn1()
    local http = net.HTTPClient()--{timeout = 5000})  --  5 seconds
    local data = nil
    local url = "https://accsmart.panasonic.com/auth/login/"
    print(url)
    --print(tostring('user'))

    local params = {
        ['language'] = lang,
        ['password'] = pass,
        ['loginId'] = user

        }
        print(type(params))
        sert = 'C:\\AMD\\certificatechain.pem' 
        print(sert)
    
    local inputheaders = {
        ['X-APP-TYPE'] = '1', 
        ['X-APP-VERSION'] = '1.12.0',
        ['user-agent'] = 'G-RAC',
        ['accept'] = 'application/json', 
        ['content-type'] = 'application/json', 
        --['SERVER_PROTOCOL'] = 'HTTP/1.1'
        }
       -- print(inputheaders)
        http:request(url, {
        options = { 
        method = "POST",
        data = json.encode(params),
        headers = inputheaders,
        }, 
    --params,
        success = function(response)
            self:debug(response.status)
            self:debug(response.data)
            bob = json.decode(response.data)
            accessToken = bob.uToken
           -- self:updateView("label1", "text" ,"Connected")
            print(tostring("change label"))
            print(accessToken)
            if response.status == 200  then
                print("everything okay")
            end

        end,  --  success
        
        error = function(msg)
            self:debug('Error:'..msg)
        --print(data) -- no data
        end  --  error
    })
               
end


function QuickApp:turn2()
    local http = net.HTTPClient()--{timeout = 5000})  --  5 seconds
    local data = nil
    local url2 = "https://accsmart.panasonic.com/device/group"
    
    local inputheaders2 = {
        ['X-APP-TYPE'] = '1', 
        ['X-APP-VERSION'] = '1.12.0',
        ['user-agent'] = 'G-RAC',
        ['accept'] = 'application/json', 
        ['content-type'] = 'application/json', 
        ["X-User-Authorization"] = accessToken,
        }

    http:request(url2, {
        options = { 
        method = "GET",
        headers = inputheaders2,
        }, 
    --params,
        success = function(response)
        self:debug(response.status)
        self:debug(response.data)
        if response.status == 200  then
            print("everything okay")
        end
---------------------------------------------------------------------------------------
                            -- parameters
---------------------------------------------------------------------------------------        
        bob2 = json.decode(response.data)
        operate = bob2.groupList[1].deviceList[1].parameters.operate
        operationM = bob2.groupList[1].deviceList[1].parameters.operationMode
        tempe = bob2.groupList[1].deviceList[1].parameters.temperatureSet
        fanS = bob2.groupList[1].deviceList[1].parameters.fanSpeed
        fanAutoM = bob2.groupList[1].deviceList[1].parameters.fanAutoMode
        SwingLR = bob2.groupList[1].deviceList[1].parameters.airSwingLR
        SwingUD = bob2.groupList[1].deviceList[1].parameters.airSwingUD
        ecoM = bob2.groupList[1].deviceList[1].parameters.ecoMode
        ecoN = bob2.groupList[1].deviceList[1].parameters.ecoNavi
        nano = bob2.groupList[1].deviceList[1].parameters.nanoe
        iAu = bob2.groupList[1].deviceList[1].parameters.iAuto
        actualN = bob2.groupList[1].deviceList[1].parameters.actualNanoe
        airD = bob2.groupList[1].deviceList[1].parameters.airDirection
        ecoF = bob2.groupList[1].deviceList[1].parameters.ecoFunctionData
---------------------------------------------------------------------------------------
                            -- Devicelist info
---------------------------------------------------------------------------------------  


        guid = bob2.groupList[1].deviceList[1].deviceGuid
        modulenu = bob2.groupList[1].deviceList[1].deviceModuleNumber
        
        nanostat = bob2.groupList[1].deviceList[1].nanoe
       -- tempe = fibaro.setGlobalVariable("boot", "rrrr")
        self:debug("guid: ", json.encode(guid))
        self:debug("name: ", json.encode(modulenu))
        self:debug("labeltemp: ", json.encode(tempe))
        --self:updateView("labeltemp", "text", tostring(tempe))
        self:debug("Nano X active: ", json.encode(nano))
       -- print(tostring(turn2.tempe))
        --looloop()
        end,  --  success
        
        error = function(response)
            self:debug(response.status)
            if response.status == 401 then 
               -- setTimeout(QuickApp:turn2(),10*1000)
               -- QuickApp:turn2() 
                print("something went wrong")
            end    
        
        --print(data) -- no data
        end 
    })
    
    
end

function QuickApp:Onpressed()
  --  self:updateView("labeltemp", "text", tostring(tempe))
    print("YEAAAAAAAAAAAAAAAAAAAAAAAAAAAH")

end

function QuickApp:sendcommand()
    local hhtpcommand = net.HTTPClient({timeout=2000})
    urlcom = "https://accsmart.panasonic.com/deviceStatus/control"
    local params3 = {
        ['deviceGuid'] = guid,
        ['parameters'] = { 
            ['operate'] = operate,
            ['operationMode'] = operationM,
            ['temperatureSet'] = tempe,
            ['fanSpeed'] = fanS,
            ['fanAutoMode'] = fanAutoM,
            ['airSwingLR'] = SwingLR,
            ['airSwingUD'] = SwingUD,
            ['ecoMode'] = ecoM,
            ['ecoNavi'] = ecoN,
            ['nanoe'] = nano,
            ['iAuto'] = iAu,
            ['actualNanoe'] = actualN,
            ['airDirection'] = airD,
            ['ecoFunctionData'] = ecoF

            }       
    }
    local inputheaders3 = {
        ['X-APP-TYPE'] = '1', 
        ['X-APP-VERSION'] = '1.12.0',
        ['user-agent'] = 'G-RAC',
        ['accept'] = 'application/json', 
        ['content-type'] = 'application/json', 
        ["X-User-Authorization"] = accessToken,
    }


    hhtpcommand:request(urlcom, {
        options = { 
        method = "POST",
        data = json.encode(params3),
        headers = inputheaders3
        
        }, 
    --params,
        success = function(response)
        self:debug(response.status)
        self:debug(response.data)
        if response.status == 200  then
            print("everything okay")
        end
    end,  --  success
        
        error = function(msg)
            self:debug('Error:'..msg)
        --print(data) -- no data
        end  --  error
    })


end
function QuickApp:gettemp()
print("WHYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY")
   self:updateView("labeltemp", "text", tostring(tempe))
end
function QuickApp:offpressed()
    operate = tostring('0')
    print (operate)
    QuickApp:sendcommand()
    operate = operate
    self:updateView("labeltemp", "text", "OFF") 
end

function QuickApp:Onpressed()
    operate = tostring('1')
    QuickApp:sendcommand()
    operate = operate
    self:updateView("labeltemp", "text", tostring(tempe)) 
end
---------------------------------------------------------------------------------
                        -- FanSpeed
--------------------------------------------------------------------------------
function QuickApp:press1()
    fanS = tostring('1')
    QuickApp:sendcommand()
    fanS = fanS
    self:updateView("labelfan", "text", "Fan speed "..tostring(fanS))
end 

function QuickApp:presstwo()
    fanS = tostring('2')
    QuickApp:sendcommand()
    fanS = fanS
    self:updateView("labelfan", "text", "Fan speed "..tostring(fanS)) 
end

function QuickApp:presstree()
    fanS = tostring('3')
    QuickApp:sendcommand()
    fanS = fanS
    self:updateView("labelfan", "text", "Fan speed "..tostring(fanS)) 
end

function QuickApp:pressfour()
    fanS = tostring('4')
    QuickApp:sendcommand()
    fanS = fanS
    self:updateView("labelfan", "text", "Fan speed "..tostring(fanS)) 
end

function QuickApp:pressfive()
    fanS = tostring('5')
    QuickApp:sendcommand()
    fanS = fanS
    self:updateView("labelfan", "text", "Fan speed "..tostring(fanS)) 
end
---------------------------------------------------------------------------------
                        -- AUTOFAN MODES
--------------------------------------------------------------------------------

function QuickApp:onfanspeed()
    fanAutoM = tostring('4')
    QuickApp:sendcommand() 
    fanAutoM = fanAutoM
    self:updateView("labelfan", "text", "Fan speed "..tostring(fanS)) 
    print(fanAutoM)
end

function QuickApp:SetVol(value)
   -- if tempe < 13 and tempe  < 30  then tempe = "-10" ..tempe end
    QuickApp:sendcommand()
    tempe = tempe
    self:updateView("labeltemp", "text", tostring(tempe))
end

function QuickApp:onSliderChanged(event)
   tempe = event.values[1]

   self:SetVol(value)
end



function QuickApp:turnOn()
    self:debug("binary switch turned off")
    self:updateProperty("value", True)    
end

function QuickApp:turnOff()
    self:debug("binary switch turned off")
    self:updateProperty("value", false)    
end
