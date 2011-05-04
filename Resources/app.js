/**********************************************************************
	App Declarations & Scope
**********************************************************************/
	var app = {}; // global namespace
	
	Ti.UI.iPhone.statusBarStyle = 2;

	Ti.include( //we'll be including all the files for our namespace in the root app context
		'helper.js',
		'ui.js'
	);
	
		
	//Use our custom UI constructors to build the app's UI
	var init = app.ui.initApp();
	init.open({
		transition:Ti.UI.iPhone.AnimationStyle.CURL_UP
	});