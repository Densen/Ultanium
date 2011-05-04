//Wrap all code in a self-calling function to protect the global namespace
(function() {
	//Create sub-namespace
	app.helper = {};
	
	// WINDOW HELPER
	app.helper.createWindow = function(_id, _class, _title) {
		var win = Ti.UI.createWindow({  
			id: _id,
			className: _class,
		    title: _title,
			orientationModes : [
			Ti.UI.PORTRAIT,
			Ti.UI.LANDSCAPE_LEFT,
			Ti.UI.LANDSCAPE_RIGHT
			] 
		});	
		return win;
	};
	
	// TAB HELPER
	app.helper.createTab = function(_id, _class, _title, _window) {
		var tab = Ti.UI.createTab({
			id: _id,
			className: _class,			
		  	title: _title,
		  	window: _window			
		});
		return tab;
	};
	
	// BUTTON HELPER
	app.helper.createButton = function(_id, _class, _title) {
		var button = Ti.UI.createButton({
			id: _id, 
			className: _class,
			title: _title
		});
		return button;
	};
	
})();	