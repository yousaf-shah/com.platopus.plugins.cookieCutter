# CookieCutter-Plugin

Solar2D plugin to get a cookie from webview for iOS, MacOS/Sim and Android

cookieCutter.getWebviewCookie("domainName", "cookieName", listener)

To be consistent across supported platforms, the function triggers an event in a given listener and returns:

- event.name = (String) "cookieCutter"
- event.domainName = (String) the domain name you supplied
- event.cookieName = (String) the cookie name you supplied
- event.cookieValue = (String) the cookie value, "" if no cookie found
- event.cookieFound = (Boolean) true if cookie was found


```lua
-- Basic Example to get the 'geo' cookie from https://apple.com/

-- The plugin does not make any requests to the site.
-- You must have a Native Webview open pointed to a URL at this domain.

local domainName = "apple.com"
local cookieName = "geo"

function cookieListener(event)
     if event.cookieFound then
          print ("Cookie Found for domain " .. event.domainName)
          print ("Cookie " .. event.cookieName .. " = " .. event.cookieValue)
     end
end

local function webListener( event )
    if event.type ~= nil and event.type == "loaded" then
        print( "Page Loaded - Fetching Cookie")
        cookieCutter.getWebviewCookie(domainName, cookieName, cookieListener)
    end
end

local webView = native.newWebView( display.contentCenterX, display.contentCenterY, 320, 480 )
webView:request( "https://" .. domainName .. "/" )


````


If you are wondering why this triggers an event and does not return a cookie directly, on iOS the call to the cookie store is asynchronous, I'm sure this could be dealt with but it was simpler to adapt to this and make all patforms behave the same way.
