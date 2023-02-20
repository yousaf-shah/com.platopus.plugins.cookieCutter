# CookieCutter-Plugin

Solar2D plugin to get a cookie from webview for iOS, MacOS/Sim and Android


Basic Api Guide
```
cookieCutter.getWebviewCookie("domain.name", "cookieName", function(ev)
     if(ev.foundCookie)then
         print("Cookie Result:")
         print(ev.cookie)
     else
         print("no cookie found")
     end

 end )
 ````
