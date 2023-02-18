
#import "cookieCutter.h"

#include <CoronaRuntime.h>
#import <WebKit/WebKit.h>

#define UTF8StringWithFormat(format, ...) [[NSString stringWithFormat:format, ##__VA_ARGS__] UTF8String]
#define UTF8IsEqual(utf8str1, utf8str2) (strcmp(utf8str1, utf8str2) == 0)
#define MsgFormat(format, ...) [NSString stringWithFormat:format, ##__VA_ARGS__]

static NSString * const ERROR_MSG   = @"ERROR: ";
static NSString * const WARNING_MSG = @"WARNING: ";
static NSString * const INFO_MSG = @"INFO: ";

// ----------------------------------------------------------------------------

class cookieCutter
{
	public:
		typedef cookieCutter Self;

	public:
		static const char kName[];
		static const char kEvent[];

	protected:
    cookieCutter();

	public:
		bool Initialize( CoronaLuaRef listener );

	public:
		CoronaLuaRef GetListener() const { return fListener; }

	public:
		static int Open( lua_State *L );

	protected:
		static int Finalizer( lua_State *L );

	public:
		static Self *ToLibrary( lua_State *L );

	public:
		static int getWebviewCookie( lua_State *L );

	private:
        static void logMsg(lua_State *L, NSString *msgType,  NSString *errorMsg);
		CoronaLuaRef fListener;
        NSString *functionSignature;              // used in logMsg to identify function
        UIViewController *coronaViewController;   // application's view controller
};

// ----------------------------------------------------------------------------

void
cookieCutter::logMsg(lua_State *L, NSString* msgType, NSString* errorMsg)
{
    Self *context = ToLibrary(L);
    
    if (context) {
        Self& library = *context;
        
        NSString *functionID = [library.functionSignature copy];
        if (functionID.length > 0) {
            functionID = [functionID stringByAppendingString:@", "];
        }
        
        CoronaLuaLogPrefix(L, [msgType UTF8String], UTF8StringWithFormat(@"%@%@", functionID, errorMsg));
    }
}

static NSString *
ToNSString( lua_State *L, int index )
{
    NSString *result = nil;
    
    int t = lua_type( L, -2 );
    switch ( t )
    {
        case LUA_TNUMBER:
            result = [NSString stringWithFormat:@"%g", lua_tonumber( L, index )];
            break;
        default:
            result = [NSString stringWithUTF8String:lua_tostring( L, index )];
            break;
    }
    
    return result;
}

const char cookieCutter::kName[] = "plugin.cookieCutter";

const char cookieCutter::kEvent[] = "plugin.cookieCutter";

cookieCutter::cookieCutter()
:	fListener( NULL )
{
}

bool
cookieCutter::Initialize( CoronaLuaRef listener )
{
	// Can only initialize listener once
	bool result = ( NULL == fListener );

	if ( result )
	{
		fListener = listener;
	}

	return result;
}

int
cookieCutter::Open( lua_State *L )
{
	// Register __gc callback
	const char kMetatableName[] = __FILE__; // Globally unique string to prevent collision
	CoronaLuaInitializeGCMetatable( L, kMetatableName, Finalizer );

	// Functions in library
	const luaL_Reg kVTable[] =
	{
		{ "getWebviewCookie", getWebviewCookie },

		{ NULL, NULL }
	};

	// Set library as upvalue for each library function
	Self *library = new Self;
	CoronaLuaPushUserdata( L, library, kMetatableName );

	luaL_openlib( L, kName, kVTable, 1 ); // leave "library" on top of stack

	return 1;
}

int
cookieCutter::Finalizer( lua_State *L )
{
	Self *library = (Self *)CoronaLuaToUserdata( L, 1 );

	CoronaLuaDeleteRef( L, library->GetListener() );

	delete library;

	return 0;
}

cookieCutter *
cookieCutter::ToLibrary( lua_State *L )
{
	// library is pushed as part of the closure
	Self *library = (Self *)CoronaLuaToUserdata( L, lua_upvalueindex( 1 ) );
	return library;
}

int
cookieCutter::getWebviewCookie( lua_State *L )
{
    NSString *myDomain = NULL;
    NSString *myCookieName = NULL;
    CoronaLuaRef solarListener = NULL;
    
    __block NSString *cookieValue = @"";
    
    int nargs = lua_gettop(L);
    if (nargs != 3) {
        logMsg(L, @"getWebviewCookie", MsgFormat(@"[cookieCutter] 3 arguments expected, got: %d", nargs));
        return 0;
    }
    
    if(lua_type(L, 1) == LUA_TSTRING){
        myDomain = ToNSString(L, 1);
    } else {
        logMsg(L, @"getWebviewCookie", MsgFormat(@"[cookieCutter] domainName (string) expected, got: %s", luaL_typename(L, 1)));
        return 0;
    }
    
    if(lua_type(L, 2) == LUA_TSTRING){
        myCookieName = ToNSString(L, 2);
    } else {
        logMsg(L, @"getWebviewCookie", MsgFormat(@"[cookieCutter] String (cookie name) expected, got: %s", luaL_typename(L, 1)));
        return 0;
    }
    
    if(CoronaLuaIsListener(L, 3, "cookieCutter")){
        solarListener = CoronaLuaNewRef(L, 3);
    } else {
        logMsg(L, @"getWebviewCookie", MsgFormat(@"[cookieCutter] function (listener) expected, got: %s", luaL_typename(L, 1)));
        return 0;
    }
    
    #if TARGET_OS_IPHONE
        if (@available(iOS 11.0, *)) {
            [[[WKWebsiteDataStore defaultDataStore] httpCookieStore] getAllCookies:^(NSArray<NSHTTPCookie *> * _Nonnull cookies) {
//                NSLog(@"run125 %@",cookies);
                for(NSHTTPCookie* cookie in cookies ){
                    if([cookie.domain isEqualToString:myDomain] && [cookie.name isEqualToString:myCookieName]){
                        cookieValue = cookie.value;
                        CoronaLuaNewEvent(L, "cookieCutter");
                        lua_pushstring(L, myDomain.UTF8String);
                        lua_setfield(L, -2, "domainName");
                        lua_pushstring(L, myCookieName.UTF8String);
                        lua_setfield(L, -2, "cookieName");
                        lua_pushstring(L, cookie.value.UTF8String);
                        lua_setfield(L, -2, "cookieValue");
                        lua_pushboolean(L, true);
                        lua_setfield(L, -2, "cookieFound");
                        CoronaLuaDispatchEvent(L, solarListener, 0);
                        return;
                    }
                }
                //No cookie value found
                CoronaLuaNewEvent(L, "cookieCutter");
                lua_pushstring(L, myDomain.UTF8String);
                lua_setfield(L, -2, "domainName");
                lua_pushstring(L, myCookieName.UTF8String);
                lua_setfield(L, -2, "cookieName");
                lua_pushstring(L, "");
                lua_setfield(L, -2, "cookieValue");
                lua_pushboolean(L, false);
                lua_setfield(L, -2, "cookieFound");
                CoronaLuaDispatchEvent(L, solarListener, 0);
            }];
        }

    #else
    
        if (@available(macOS 10.13, *)) {
            for(NSHTTPCookie* cookie in [NSHTTPCookieStorage.sharedHTTPCookieStorage cookies]){
                if([cookie.domain isEqualToString:myDomain] && [cookie.name isEqualToString:myCookieName]){
                    cookieValue = cookie.value;
                    CoronaLuaNewEvent(L, "cookieCutter");
                    lua_pushstring(L, myDomain.UTF8String);
                    lua_setfield(L, -2, "domainName");
                    lua_pushstring(L, myCookieName.UTF8String);
                    lua_setfield(L, -2, "cookieName");
                    lua_pushstring(L, cookie.value.UTF8String);
                    lua_setfield(L, -2, "cookieValue");
                    lua_pushboolean(L, true);
                    lua_setfield(L, -2, "cookieFound");
                    CoronaLuaDispatchEvent(L, solarListener, 0);
                    return 0;
                }
            }
            
            CoronaLuaNewEvent(L, "cookieCutter");
            lua_pushstring(L, myDomain.UTF8String);
            lua_setfield(L, -2, "domainName");
            lua_pushstring(L, myCookieName.UTF8String);
            lua_setfield(L, -2, "cookieName");
            lua_pushstring(L, "");
            lua_setfield(L, -2, "cookieValue");
            lua_pushboolean(L, false);
            lua_setfield(L, -2, "cookieFound");
            CoronaLuaDispatchEvent(L, solarListener, 0);
            return 0;
        }
    
    #endif
    
    return 0;
    
}



// ----------------------------------------------------------------------------

CORONA_EXPORT int luaopen_plugin_cookieCutter( lua_State *L )
{
	return cookieCutter::Open( L );
}
