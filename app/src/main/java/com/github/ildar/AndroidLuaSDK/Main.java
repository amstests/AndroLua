package com.github.ildar.AndroidLuaSDK;

import android.os.Bundle;
import android.app.Activity;
import android.content.Intent;
import android.view.Menu;

public class Main extends Activity {

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_hello_world);
		// use this to start and trigger a service
		Intent i= new Intent(this, Lua.class);
		startService(i);
	}

}
