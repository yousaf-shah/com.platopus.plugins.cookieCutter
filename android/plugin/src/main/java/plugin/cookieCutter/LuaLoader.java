//
//  LuaLoader.java
//  TemplateApp
//
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

// This corresponds to the name of the Lua library,
// e.g. [Lua] require "plugin.library"
package plugin.cookieCutter;

import com.ansca.corona.CoronaActivity;
import com.ansca.corona.CoronaEnvironment;
import com.ansca.corona.CoronaLua;
import com.ansca.corona.CoronaRuntime;
import com.ansca.corona.CoronaRuntimeListener;
import com.ansca.corona.CoronaRuntimeTask;
import com.naef.jnlua.JavaFunction;
import com.naef.jnlua.LuaState;
import com.naef.jnlua.LuaType;
import com.naef.jnlua.NamedJavaFunction;

import android.app.Service;

import android.content.ComponentName;
import android.content.Context;

import android.os.Handler;
import android.os.IBinder;
import android.os.Looper;
import android.util.Log;
import android.webkit.CookieManager;

/**
 * Implements the Lua interface for a Corona plugin.
 * <p>
 * Only one instance of this class will be created by Corona for the lifetime of the application.
 * This instance will be re-used for every new Corona activity that gets created.
 */
@SuppressWarnings({"WeakerAccess", "unused"})
public class LuaLoader implements JavaFunction, CoronaRuntimeListener {
	/** Lua registry ID to the Lua function to be called when the ad request finishes. */
	private int fListener;
	private Handler handler = new Handler(Looper.getMainLooper());
	private static final String DATA = "data";
	private Context activity;

	private static final String SOURCE = "source_byte";

	/** This corresponds to the event name, e.g. [Lua] event.name */
	private static final String EVENT_NAME = "cookieCutter";


	/**
	 * Creates a new Lua interface to this plugin.
	 * <p>
	 * Note that a new LuaLoader instance will not be created for every CoronaActivity instance.
	 * That is, only one instance of this class will be created for the lifetime of the application process.
	 * This gives a plugin the option to do operations in the background while the CoronaActivity is destroyed.
	 */
	@SuppressWarnings("unused")
	public LuaLoader() {
		// Initialize member variables.
		fListener = CoronaLua.REFNIL;

		// Set up this plugin to listen for Corona runtime events to be received by methods
		// onLoaded(), onStarted(), onSuspended(), onResumed(), and onExiting().
		CoronaEnvironment.addRuntimeListener(this);
	}

	/**
	 * Called when this plugin is being loaded via the Lua require() function.
	 * <p>
	 * Note that this method will be called every time a new CoronaActivity has been launched.
	 * This means that you'll need to re-initialize this plugin here.
	 * <p>
	 * Warning! This method is not called on the main UI thread.
	 * @param L Reference to the Lua state that the require() function was called from.
	 * @return Returns the number of values that the require() function will return.
	 *         <p>
	 *         Expected to return 1, the library that the require() function is loading.
	 */
	@Override
	public int invoke(LuaState L) {
		// Register this plugin into Lua with the following functions.
		NamedJavaFunction[] luaFunctions = new NamedJavaFunction[] {
			new getWebviewCookie(),
		};
		String libName = L.toString( 1 );
		L.register(libName, luaFunctions);

		// Returning 1 indicates that the Lua require() function will return the above Lua library.
		return 1;
	}

	/**
	 * Called after the Corona runtime has been created and just before executing the "main.lua" file.
	 * <p>
	 * Warning! This method is not called on the main thread.
	 * @param runtime Reference to the CoronaRuntime object that has just been loaded/initialized.
	 *                Provides a LuaState object that allows the application to extend the Lua API.
	 */
	@Override
	public void onLoaded(CoronaRuntime runtime) {
		// Note that this method will not be called the first time a Corona activity has been launched.
		// This is because this listener cannot be added to the CoronaEnvironment until after
		// this plugin has been required-in by Lua, which occurs after the onLoaded() event.
		// However, this method will be called when a 2nd Corona activity has been created.

	}

	/**
	 * Called just after the Corona runtime has executed the "main.lua" file.
	 * <p>
	 * Warning! This method is not called on the main thread.
	 * @param runtime Reference to the CoronaRuntime object that has just been started.
	 */
	@Override
	public void onStarted(CoronaRuntime runtime) {
	}

	/**
	 * Called just after the Corona runtime has been suspended which pauses all rendering, audio, timers,
	 * and other Corona related operations. This can happen when another Android activity (ie: window) has
	 * been displayed, when the screen has been powered off, or when the screen lock is shown.
	 * <p>
	 * Warning! This method is not called on the main thread.
	 * @param runtime Reference to the CoronaRuntime object that has just been suspended.
	 */
	@Override
	public void onSuspended(CoronaRuntime runtime) {
	}

	/**
	 * Called just after the Corona runtime has been resumed after a suspend.
	 * <p>
	 * Warning! This method is not called on the main thread.
	 * @param runtime Reference to the CoronaRuntime object that has just been resumed.
	 */
	@Override
	public void onResumed(CoronaRuntime runtime) {
	}

	/**
	 * Called just before the Corona runtime terminates.
	 * <p>
	 * This happens when the Corona activity is being destroyed which happens when the user presses the Back button
	 * on the activity, when the native.requestExit() method is called in Lua, or when the activity's finish()
	 * method is called. This does not mean that the application is exiting.
	 * <p>
	 * Warning! This method is not called on the main thread.
	 * @param runtime Reference to the CoronaRuntime object that is being terminated.
	 */
	@Override
	public void onExiting(CoronaRuntime runtime) {
	}

	/**
	 * Simple example on how to dispatch events to Lua. Note that events are dispatched with
	 * Runtime dispatcher. It ensures that Lua is accessed on it's thread to avoid race conditions
	 * @param message simple string to sent to Lua in 'message' field.
	 */
//	@SuppressWarnings("unused")
	public void dispatchCookieEvent(final Boolean cookieFound, String domainName, String cookieName, String cookieValue) {
		CoronaEnvironment.getCoronaActivity().getRuntimeTaskDispatcher().send( new CoronaRuntimeTask() {
			@Override
			public void executeUsing(CoronaRuntime runtime) {
				LuaState L = runtime.getLuaState();

				CoronaLua.newEvent( L, "cookieCutter" );

				L.pushString(domainName);
				L.setField(-2, "domainName");
				L.pushString(cookieName);
				L.setField(-2, "cookieName");
				L.pushString(cookieValue);
				L.setField(-2, "cookieValue");
				L.pushBoolean(cookieFound);
				L.setField(-2, "cookieFound");

				try {
					CoronaLua.dispatchEvent( L, fListener, 0 );
				} catch (Exception ignored) {
				}
			}
		} );
	}
	public class getWebviewCookie implements com.naef.jnlua.NamedJavaFunction {
		// This reports a class name back to Lua during the initiation phase.
		@Override
		public String getName() {
			return "getWebviewCookie";
		}

		// This is what actually gets invoked by the Lua call
		@Override
		public int invoke(final LuaState luaState) {

			Boolean cookieFound = false;
			String cookieValue = "";
			String domainName = "";
			String cookieName = "";

			// check number or args
			int nargs = luaState.getTop();
			if ((nargs < 3) || (nargs > 3)){
				Log.e("getWebviewCookie", "[cookieCutter] 3 arguments expected, got: " + nargs);
				return 0;
			}

			// get site name
			if (luaState.type(1) == LuaType.STRING) {
				domainName = luaState.toString(1);
			} else {
				Log.e("getWebviewCookie", "[cookieCutter] domainName (string) expected, got: " + luaState.typeName(1));
				return 0;
			}

			// get cookie name
			if (luaState.type(2) == LuaType.STRING) {
				cookieName = luaState.toString(2);
			} else {
				Log.e("getWebviewCookie", "[cookieCutter] String (cookie name) expected, got: " + luaState.typeName(1));
				return 0;
			}

			if ( CoronaLua.isListener( luaState, 3, "cookieCutter" ) ) {
				fListener = CoronaLua.newRef( luaState, 3 );
			} else {
				Log.e("getWebviewCookie", "[cookieCutter] function (listener) expected, got: " + luaState.typeName(1));
				return 0;
			}

			try {
				cookieValue = getCookie(domainName,cookieName);

				if (cookieValue == null) {
					cookieFound = false;
					cookieValue = "";
					Log.e("getWebviewCookie", "[cookieCutter] no matching cookie");
				} else {
					cookieFound = true;
					Log.e("getWebviewCookie", "[cookieCutter] matched cookie, value = " + cookieValue);
				}

			} catch (Exception e) {
//				e.printStackTrace();
			}

			dispatchCookieEvent(cookieFound,domainName,cookieName,cookieValue);

			return 0;
		}

	}

	public String getCookie(String siteName,String CookieName){
		String CookieValue = null;

		CookieManager cookieManager = CookieManager.getInstance();
		String cookies = cookieManager.getCookie("https://"+siteName);
		if(cookies != null){
			String[] temp=cookies.split(";");
			for (String ar1 : temp ){
				if(ar1.contains(CookieName)){
					String[] temp1=ar1.split("=");
					CookieValue = temp1[1];
				}
			}
		}
		return CookieValue;
	}



}
