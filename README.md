# CookieCutter-Plugin

Solar2D plugin to get a cookie from webview for Android, iOS, Mac-Sim, iPhone-Sim

Thanks to Scott Harrison @scottrules44 for help with the Apple versions!

## Installation

See [releases](https://github.com/yousaf-shah/com.platopus.plugins.cookieCutter/releases) for installation and downloads

## Usage

cookieCutter.getWebviewCookie("domainName", "cookieName", listener)

To be consistent across supported platforms, the function triggers an event in a given listener and returns:

- event.name = (String) "cookieCutter"
- event.domainName = (String) the domain name you supplied
- event.cookieName = (String) the cookie name you supplied
- event.cookieValue = (String) the cookie value, "" if no cookie found
- event.cookieFound = (Boolean) true if cookie was found


```lua
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


````


If you are wondering why this triggers an event and does not return a cookie directly, on iOS the call to the cookie store is asynchronous, I'm sure this could be dealt with but it was simpler to adapt to this and make all patforms behave the same way.
