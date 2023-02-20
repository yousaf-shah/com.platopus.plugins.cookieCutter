-- Basic Example to get the 'StrictCookie' cookie from the testing site https://samesitetest.com/cookies/set

-- The plugin does not make any requests to the site.
-- You must have a Native Webview open pointed to a URL at this domain.

local cookieCutter = require ( "plugin.cookieCutter" )
local domainName = "samesitetest.com"
local domainTestUrl = "https://samesitetest.com/cookies/set"
local cookieName = "StrictCookie"

function cookieListener(event)
     if event.name == "cookieCutter" then
          print("COOKIE: found = " .. tostring(event.cookieFound))
          if event.cookieFound == true then
               print("COOKIE: domain = "..event.domainName)
               print("COOKIE: cookie = "..event.cookieName)
               print("COOKIE: value = "..event.cookieValue)
               native.showAlert(event.domainName,event.cookieName .. " = " .. event.cookieValue,{"OK"})
          end
     end
end

local function webListener( event )
     if event.type ~= nil and event.type == "loaded" then
          print( "WEBVIEW: Page Loaded - Fetching Cookie")
          cookieCutter.getWebviewCookie(domainName, cookieName, cookieListener)
     end
end

local webView = native.newWebView( display.contentCenterX, display.contentCenterY, 320, 480 )
webView:addEventListener( "urlRequest", webListener )
webView:request( domainTestUrl )
