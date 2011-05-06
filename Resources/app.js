/**********************************************************************
	App Declarations & Scope
**********************************************************************/
	// Set up the global namespace
	var app = {}; 
		
	// Include all the files for our namespace in the root app context	
	Ti.include( 
		'helper.js',
		'ui.js'
	);
	
	// Custom UI constructors to build the app's UI
	var init = app.ui.initApp();

	// Init App
	if (Titanium.Platform.name == 'iPhone OS') {
		// Set iOS bar to black
		Ti.UI.iPhone.statusBarStyle = 2;
		// Open iOS app with Curl Up
		init.open({
			transition:Ti.UI.iPhone.AnimationStyle.CURL_UP
		});
	} else {
		// Open Android app without anim
		init.open();
	}