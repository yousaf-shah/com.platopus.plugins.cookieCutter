local cookieCutter = require("plugin.cookieCutter")
local widget = require("widget")
local json = require("json")
local bg = display.newRect( display.contentCenterX, display.contentCenterY, display.actualContentWidth, display.actualContentHeight )
bg:setFillColor( 0,.5,0 )

function cookieListener(event)

        if event.name == "cookieCutter" then

                print("COOKIE: found = "..tostring(event.cookieFound))

                if event.cookieFound == true then

                        print("COOKIE: domain = "..event.domainName)
                        print("COOKIE: cookie = "..event.cookieName)
                        print("COOKIE: value = "..event.cookieValue)
                        native.showAlert(event.domainName,event.cookieName .. " = " .. event.cookieValue,{"OK"})

                end
        end

end

local webView = native.newWebView( display.contentCenterX, display.contentCenterY-100, 320, 280 )
webView:request( "https://charlestyrwhitt.platop.us/" )
local getCookies = widget.newButton( {
        x = display.contentCenterX,
        y = display.contentCenterY + 200,
        id = "getWebviewCookie",
        labelColor = { default={ 1, 1, 1 }, over={0, 0, 0, 0.5 } },
        label = "getWebviewCookie",
        onEvent = function ( e )
                if (e.phase == "ended") then
                        cookieCutter.getWebviewCookie("charlestyrwhitt.platop.us", "FS2SSID", cookieListener)
                end
        end
})
