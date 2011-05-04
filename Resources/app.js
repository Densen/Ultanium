/**********************************************************************
	App Declarations & Scope
**********************************************************************/
	var app = {}; // global namespace

	if (Titanium.Platform.name == 'iPhone OS') {
		Ti.UI.iPhone.statusBarStyle = 2;
	} 
		
	Ti.include( //we'll be including all the files for our namespace in the root app context
		'helper.js',
		'ui.js'
	);
	
		
	//Use our custom UI constructors to build the app's UI
	var init = app.ui.initApp();

	
	
	if (Titanium.Platform.name == 'iPhone OS') {
		init.open({
			transition:Ti.UI.iPhone.AnimationStyle.CURL_UP
		});
	} else {
		init.open();
	}