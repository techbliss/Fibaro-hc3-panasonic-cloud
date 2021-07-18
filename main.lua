-- by @zadow28
-- feel free to use and adjust code for personal use.
-- github https://github.com/techbliss/HC3_Quickapp_Panasonic_cloud
-- feel free to contact me at https://forum.fibaro.com/

---------------------------------------------------------------------------------------
     -- Panasonic comfort cloud for fibaro home center 3 
     -- version 1.0.0

---------------------------------------------------------------------------------------  

---------------------------------------------------------------------------------------
     -- Panasonic change app version often so we check for new version
---------------------------------------------------------------------------------------  



function QuickApp:getpresentversion()

    local httpver = net.HTTPClient()--{timeout = 5000})  --  5 seconds
    local urlver = "https://itunes.apple.com/lookup?id=1348640525"

    local inputheaders = {
    ['accept'] = 'application/json', 
    ['content-type'] = 'application/json', 
    }
    httpver:request(urlver, {
            options = { 
            method = "GET",
            headers = inputheaders,
            }, 

            success = function(response)
                self:debug(response.status)
                self:debug(response.data)
                verbob = json.decode(response.data)
                APPversion = verbob.results[1].version
                if verbob.results[1].version == nil then
                    APPversion = '1.12.0'
                end
                if response.status == 200  then
                    print("Appversion retrieved")
                end

            end,  --  success
            
            error = function(msg)
                self:debug('Error:'..msg)

            end  --  error
        }) 

end

 

function QuickApp:onInit()
    QuickApp:getpresentversion()
    setInterval(function() QuickApp:getpresentversion() end, 3600*1000) -- check for new appversion every hour
    ------------------------------------------------------------------------------------------
                --slider settings
    --------------------------------------------------------------------------------------------
    self:debug("onInit")
    self:updateView("slider","min","16")
    self:updateView("slider","max", "30")
    self:updateView("slider", "value", "21") 
    self:updateView("slider", "step", "0.5")


    lang = self:getVariable("language")
    pass = self:getVariable("password")
    user = self:getVariable("Username")
    --self:turnOn()
    fibaro.setTimeout(1000, function() QuickApp:turn1()() end)
    fibaro.setTimeout(3000, function() QuickApp:turn2() end)
    fibaro.setTimeout(604800000, function() QuickApp:onInit() end) --token restart every month
    ------------------------------------------------------------------------------------------
                --hide debug buttons
    --------------------------------------------------------------------------------------------
    self:updateView("bntindebugU", "visible", false)
    self:updateView("btnnow", "visible", false) 
    self:updateView("btnhis", "visible", false)

end

---------------------------------------------------------------------------------------
                            -- login
---------------------------------------------------------------------------------------  

function QuickApp:turn1()
    local http = net.HTTPClient()--{timeout = 5000})  --  5 seconds
    local data = nil
    local url = "https://accsmart.panasonic.com/auth/login/"
    print(url)


    local params = {
        ['language'] = lang,
        ['password'] = pass,
        ['loginId'] = user

        }
        --print(type(params))
        --sert = '\certificatechain.pem' 
        print(sert)
    
    local inputheaders = {
        ['X-APP-TYPE'] = '1', 
        ['X-APP-VERSION'] = APPversion,
        ['user-agent'] = 'G-RAC',
        ['accept'] = 'application/json', 
        ['content-type'] = 'application/json', 
        --['SERVER_PROTOCOL'] = 'HTTP/1.1'
        }

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
            print(accessToken)
            if response.status == 200  then
                print("Token retrieved")
            end

        end,  --  success
        
        error = function(msg)
            self:debug('Error:'..msg)
        end  --  error
    })
               
end
---------------------------------------------------------------------------------------
                            -- get devices and status
---------------------------------------------------------------------------------------  
function QuickApp:turn2()    
    local http = net.HTTPClient()--{timeout = 5000})  --  5 seconds
    local data = nil
    local url2 = "https://accsmart.panasonic.com/device/group"
    
    local inputheaders2 = {
        ['X-APP-TYPE'] = '1', 
        ['X-APP-VERSION'] = APPversion,
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
            print("get devices ok")
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
        self:debug("guid: ", json.encode(guid))
        self:debug("name: ", json.encode(modulenu))
        self:debug("labeltemp: ", json.encode(tempe))
        self:debug("Nano X active: ", json.encode(nano))
        end,  --  success
        
        error = function(response)
            self:debug(response.status)
            if response.status == 401 then 
                print("something went wrong")
            end    
        
        --print(data) -- no data
        end 
    })
    
    
end

function QuickApp:sendcommand()
    local hhtpcommand = net.HTTPClient()
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
        ['X-APP-VERSION'] = APPversion,
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
        end  --  error
    })
end

---------------------------------------------------------------------------------
                        -- get status now temperute inside etc
--------------------------------------------------------------------------------

function QuickApp:getNow()
    local hhtpgetda = net.HTTPClient()
    urlgetda = "https://accsmart.panasonic.com/deviceStatus/now/"..guid

     local inputheadersda = {
        ['X-APP-TYPE'] = '1', 
        ['X-APP-VERSION'] = APPversion,
        ['user-agent'] = 'G-RAC',
        ['accept'] = 'application/json', 
        ['content-type'] = 'application/json', 
        ["X-User-Authorization"] = accessToken,
    }

    hhtpgetda:request(urlgetda, {
        options = { 
        method = "GET",
        headers = inputheadersda
        
        }, 
    --params,
        success = function(response)
        self:debug(response.status)
        self:debug(response.data)
        bob3 = json.decode(response.data)
        tempe = bob3.parameters.temperatureSet
       -- print(bob3.parameters.insideTemperature)
       -- print(parameters.outTemperature)
        fibaro.setGlobalVariable('inside heatpump temperature', tostring(bob3.parameters.insideTemperature))
        fibaro.setGlobalVariable('Outside heatpump', tostring(bob3.parameters.outTemperature))
        self:debug("labeltemp now: ", json.encode(tempe))      
        if response.status == 200  then
            print("GET NOOOOOOOOOOOOOOOOOO")
        end

    end,  --  success
        
        error = function(msg)
            self:debug('Error:'..msg)
        end  --  error
    })
end

---------------------------------------------------------------------------------
                        -- for future apps History data cost energi etc
--------------------------------------------------------------------------------
function QuickApp:getHis()
    local hhtpgethis = net.HTTPClient()
    urlgethis = "https://accsmart.panasonic.com/deviceHistoryData/"


    local paramshis = {
        ['dataMode'] = '0',
        ['date'] = '20210101',
        ['deviceGuid'] = guid,
        ['osTimezone'] = '+01:00'

        }
     local inputheadershis = {
        ['X-APP-TYPE'] = '1', 
        ['X-APP-VERSION'] = APPversion,
        ['user-agent'] = 'G-RAC',
        ['accept'] = 'application/json', 
        ['content-type'] = 'application/json', 
        ["X-User-Authorization"] = accessToken,
    }

    hhtpgethis:request(urlgethis, {
        options = { 
        data = json.encode(paramshis),
        method = "POST",
        headers = inputheadershis
        
        }, 
    --params,
        success = function(response)
        self:debug(response.status)
        self:debug(response.data)
        if response.status == 200  then
            print("GET HISTORY")
        end
    end,  --  success
        
        error = function(msg)
            self:debug('Error:'..msg)
        --print(data) -- no data
        end  --  error
    })
end
function QuickApp:gettemp()
    QuickApp:getNow()
    fibaro.setTimeout(1500, function() QuickApp:updatelabel() end)
end

function QuickApp:updatelabel()
    self:updateView("labeltemp", "text", json.encode(bob3.parameters.temperatureSet))
end
---------------------------------------------------------------------------------
                        -- On / OFF
--------------------------------------------------------------------------------



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
    ecoM = tostring('0')
    QuickApp:sendcommand()
    fanS = fanS
    ecoM = ecoM
    self:updateView("labelfan", "text", "Fan speed "..tostring(fanS))
    self:updateView("labeleco", "text", "Eco mode off")
end 

function QuickApp:presstwo()
    fanS = tostring('2')
    ecoM = tostring('0')

    QuickApp:sendcommand()
    fanS = fanS
    fanAutoM = fanAutoM
    ecoM = ecoM
    self:updateView("labelfan", "text", "Fan speed "..tostring(fanS))
    self:updateView("labeleco", "text", "Eco mode off")
end

function QuickApp:presstree()
    fanS = tostring('3')
    ecoM = tostring('0')

    QuickApp:sendcommand()
    fanS = fanS
    fanAutoM = fanAutoM
    ecoM = ecoM
    self:updateView("labelfan", "text", "Fan speed "..tostring(fanS))
    self:updateView("labeleco", "text", "Eco mode off")
end

function QuickApp:pressfour()
    fanS = tostring('4')
    ecoM = tostring('0')

    QuickApp:sendcommand()
    fanS = fanS
    fanAutoM = fanAutoM
    ecoM = ecoM
    self:updateView("labelfan", "text", "Fan speed "..tostring(fanS)) 
    self:updateView("labeleco", "text", "Eco mode off")
end

function QuickApp:pressfive()
    fanS = tostring('5')
    ecoM = tostring('0')

    QuickApp:sendcommand()
    fanS = fanS
    fanAutoM = fanAutoM
    ecoM = ecoM
    self:updateView("labelfan", "text", "Fan speed "..tostring(fanS))
    self:updateView("labeleco", "text", "Eco mode off")
end
---------------------------------------------------------------------------------
                        -- AUTOFAN MODES
--------------------------------------------------------------------------------

function QuickApp:onfanspeed()
    fanAutoM = tostring('1')
    QuickApp:sendcommand() 
    fanAutoM = fanAutoM
    self:updateView("labelfanu", "text", "Swing mode off "..tostring(fanAutoM)) 

end

function QuickApp:pressedswingau()
    fanAutoM = tostring('0')
    QuickApp:sendcommand() 
    fanAutoM = fanAutoM
    self:updateView("labelfanu", "text", "Swing mode  auto "..tostring(fanAutoM)) 
end 

function QuickApp:pressedfantauleftright()
    fanAutoM = tostring('3')
    QuickApp:sendcommand() 
    fanAutoM = fanAutoM
    self:updateView("labelfanu", "text", "Swing mode left - right "..tostring(fanAutoM)) 
end

function QuickApp:pressedswingupdao()
    fanAutoM = tostring('2')
    QuickApp:sendcommand() 
    fanAutoM = fanAutoM
    self:updateView("labelfanu", "text", "Swing mode up - down "..tostring(fanAutoM)) 
end


---------------------------------------------------------------------------------
                        -- eco modes
--------------------------------------------------------------------------------

function QuickApp:pressqui()
    ecoM = tostring('2')
    QuickApp:sendcommand()
    if ecoM == '0' then
        ecoM = 'Auto'   
    elseif  ecoM == '1' then
        ecoM = 'powefull'  
    elseif  ecoM == '2' then
        ecoM = 'quiet'
    end  
    self:updateView("labeleco", "text", "Eco mode "..ecoM)
    self:updateView("labelfan", "text", "Fan speed "..tostring(fanS))

    ecoM = ecoM
end

function QuickApp:Presspowf()
     ecoM = tostring('1')
     QuickApp:sendcommand()
    if ecoM == '0' then
        ecoM = 'Auto'   
    elseif  ecoM == '1' then
        ecoM = 'powefull'  
    elseif  ecoM == '2' then
        ecoM = 'quiet'
    end  
    self:updateView("labeleco", "text", "Eco mode "..ecoM)
    self:updateView("labelfan", "text", "Fan speed "..tostring(fanS))

    ecoM = ecoM
end

function QuickApp:pressauf()
    ecoM = tostring('0')
     QuickApp:sendcommand()
    if ecoM == '0' then
        ecoM = 'Auto'   
    elseif  ecoM == '1' then
        ecoM = 'powefull'  
    elseif  ecoM == '2' then
        ecoM = 'quiet'
    end  
    self:updateView("labeleco", "text", "Eco mode "..ecoM)
    self:updateView("labelfan", "text", "Fan speed "..tostring(fanS))

    ecoM = ecoM
end







---------------------------------------------------------------------------------
                        -- Mode modes
--------------------------------------------------------------------------------
function QuickApp:heatpressed()
    operationM = tostring('3')
    tempe = self:getVariable("Heat start temp")
    QuickApp:sendcommand()
    operationM = operationM
    tempe = tempe
    self:updateView("labelmode", "text", "Mode "..tostring(operationM)) 
    self:updateView("labeltemp", "text", tostring(tempe))
    self:updateView("labelfan", "text", "Fan speed "..tostring(fanS)) 
end

function QuickApp:coolpressed()
    operationM = tostring('2')
    tempe = self:getVariable("Cool start temp")
    QuickApp:sendcommand() 
    operationM = operationM
    tempe = tempe
    self:updateView("labelmode", "text", "Mode "..tostring(operationM))
    self:updateView("labeltemp", "text", tostring(tempe)) 
    self:updateView("labelfan", "text", "Fan speed "..tostring(fanS)) 
end

function QuickApp:drypressed()
    operationM = tostring('3')
    tempe = self:getVariable("dry start temp")
    QuickApp:sendcommand() 
    operationM = operationM
    tempe = tempe
    self:updateView("labelmode", "text", "Mode "..tostring(operationM))
    self:updateView("labeltemp", "text", tostring(tempe))
    self:updateView("labelfan", "text", "Fan speed "..tostring(fanS)) 
end
function QuickApp:fanpressed()
    operationM = tostring('4')
    QuickApp:sendcommand()
    operationM = operationM
    self:updateView("labelmode", "text", "Mode "..tostring(operationM))
    self:updateView("labeltemp", "text", tostring(tempe))
    self:updateView("labelfan", "text", "Fan speed "..tostring(fanS)) 
end
function QuickApp:aupressed()
    operationM = tostring('0')
    tempe = self:getVariable("Auto start temp")
    QuickApp:sendcommand()
    operationM = operationM
    tempe = tempe
    self:updateView("labelmode", "text", "Mode "..tostring(operationM))
    self:updateView("labeltemp", "text", tostring(tempe))
    self:updateView("labelfan", "text", "Fan speed "..tostring(fanS)) 
end

---------------------------------------------------------------------------------
                        -- Nanoe X 
--------------------------------------------------------------------------------
function QuickApp:pressedonnano()
    nano = tostring('2')
    actualN = tostring('2')
    QuickApp:sendcommand()
    self:updateView("labelx", "text", "Nanoe X  "..tostring(nano))
    nano = nano
    actualN = actualN
end

function QuickApp:pressesoffnano()
    nano = tostring('1')
    actualN = tostring('1')
    QuickApp:sendcommand()
    self:updateView("labelx", "text", "Nanoe X  "..tostring(operationM))
    nano = nano
    actualN = actualN
end



---------------------------------------------------------------------------------
                        -- slider
--------------------------------------------------------------------------------

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
    operate = tostring('1')
    QuickApp:sendcommand()
    operate = operate
    self:updateView("labeltemp", "text", tostring(tempe)) 
    self:updateProperty("value", true)   
end

function QuickApp:turnOff()
    operate = tostring('0')
    print (operate)
    QuickApp:sendcommand()
    operate = operate
    self:updateView("labeltemp", "text", "OFF")  
    self:updateProperty("value", false)    
end
