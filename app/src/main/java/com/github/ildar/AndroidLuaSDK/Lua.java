package com.github.ildar.AndroidLuaSDK;

import android.app.Service;
import android.content.Intent;
import android.content.res.AssetManager;
import android.os.IBinder;
import android.os.StrictMode;
import android.util.Log;

import java.io.*;
import java.net.*;

import org.keplerproject.luajava.*;

public class Lua extends Service {
	public static LuaState L = null;
	static boolean printToString = true;
	static PrintWriter printer = null;
	static Lua main_instance = null;
	static final StringBuilder output = new StringBuilder();
	private final static char REPLACE = '\001';

	@Override
	public int onStartCommand (Intent intent, int flags, int startId) {
		StrictMode.setThreadPolicy(StrictMode.ThreadPolicy.LAX);
		log("starting Lua service");
		if (L == null) {
			main_instance = this;
			L = newState(true);
			setGlobal("service", this);
			setGlobal("intent", intent);
		}
		log("Lua service started");
		new Thread() { public void run() {
			log("Starting `init`");
			require("init");
			log("`init` started");
		} }.start();
		
		return START_STICKY;
	}

	@Override
	public IBinder onBind(Intent intent) {
		//TODO for communication return IBinder implementation
		return null;
	}

	public static LuaState newState(boolean startServer) {
		LuaState L = LuaStateFactory.newLuaState();
		L.openLibs();
		final AssetManager am = main_instance.getAssets();
		JavaFunction assetLoader = new JavaFunction(L) {
			@Override
			public int execute() throws LuaException {
				String name = L.toString(-1);
				name = name.replace('.', '/');
				InputStream is;
				try {
					try {
						is = am.open(name + ".lua");
					} catch (IOException e) {
						is = am.open(name + "/init.lua");
					}
					byte[] bytes = readAll(is);
					L.LloadBuffer(bytes, name);
					return 1;
				} catch (Exception e) {
					ByteArrayOutputStream os = new ByteArrayOutputStream();
					e.printStackTrace(new PrintStream(os));
					L.pushString("Cannot load module "+name+":\n"+os.toString());
					return 1;
				}
			}
		};

		L.getGlobal("package");	    // package
		L.getField(-1, "loaders");	 // package loaders
		int nLoaders = L.objLen(-1);       // package loaders
		
		try {
			L.pushJavaFunction(assetLoader);   // package loaders loader
		} catch (LuaException e) {
			log("Couldn't push assetLoader into LuaState");
		}
		L.rawSetI(-2, nLoaders + 1);       // package loaders
		L.pop(1);			  // package
		
		// add searching in FilesDir / ExternalFilesDir
		String filesDir, customPath;
		L.getField(-1, "path");	    // package path
		filesDir = main_instance.getFilesDir().toString();
		customPath = ";" + filesDir+"/?.lua;"+filesDir+"/?/init.lua";
		filesDir = main_instance.getExternalFilesDir(null).toString();
		customPath += ";" + filesDir+"/?.lua;"+filesDir+"/?/init.lua";
		L.pushString(customPath);    // package path custom
		L.concat(2);		       // package pathCustom
		L.setField(-2, "path");	    // package
		L.getField(-1, "cpath");	    // package cpath
		filesDir = main_instance.getFilesDir().toString() + "/../lib";
		customPath = ";" + filesDir+"/lib?.so";
		filesDir = main_instance.getExternalFilesDir(null).toString() + "/../lib";
		customPath += ";" + filesDir+"/lib?.so";
		L.pushString(customPath);    // package cpath custom
		L.concat(2);		       // package cpathCustom
		L.setField(-2, "cpath");	    // package
		L.pop(1);
		
		return L;
	}

	public static void log(String msg) {
		if (printer != null) {
			printer.println(msg + REPLACE);
			printer.flush();
			Log.d("lua",msg);
		} else {
			Log.d("lua",msg);
		}
	}

	public void setGlobal(String name, Object value) {
		L.pushJavaObject(value);
		L.setGlobal(name);
	}

	public LuaObject require(String mod) {
		L.getGlobal("require");
		L.pushString(mod);
		if (L.pcall(1, 1, 0) != 0) {
			log("require "+L.toString(-1));
			return null;
		}
		return L.getLuaObject(-1);
	}

	private static byte[] readAll(InputStream input) throws Exception {
		ByteArrayOutputStream output = new ByteArrayOutputStream(4096);
		byte[] buffer = new byte[4096]; 
		int n = 0;
		while (-1 != (n = input.read(buffer))) {
			output.write(buffer, 0, n);
		}
		return output.toByteArray();
	}

}
