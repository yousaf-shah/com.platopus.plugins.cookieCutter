# CookieCutter-Plugin

Solar2D plugin to get a cookie from webview for iOS, MacOS/Sim and Android

cookieCutter.getWebviewCookie("domainName", "cookieName", listener)

To be consistent across supported platforms, the function triggers an event in a given listener and returns:

event.name = String "cookieCutter"
event.domainName = (String) the domain name you supplied
event.cookieName = (String) the cookie name you supplied
event.cookieValue = (String) the cookie value, "" if no cookie found
event.cookieFound = (Boolean) true if cookie was found


Basic Example to get the geo cookie from https://apple.com/

NOTE: You must have a Native Webview open pointed to a URL at this domain. The plugin does not make any requests to the site.
```
-- your code here to display a webview of https://apple.com/

function cookieListener(event)
     if event.cookieFound then
          print ("Cookie Found for domain " .. event.domainName)
          print ("Cookie " .. event.cookieName .. " = " .. event.cookieValue)
     end
end

cookieCutter.getWebviewCookie("apple.com", "geo", cookieListener)

````
