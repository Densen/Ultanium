//Wrap all code in a self-calling function to protect the global namespace
(function() {
	//Create sub-namespace
	app.ui = {};
		
	// Create initial tab group
	app.ui.initApp = function() {
		
		// WINDOW 1
		app.ui.win1 = app.helper.createWindow('win1', 'win', 'Win 1');
		Ti.include('content/win1.js');
		
		// WINDOW 2
		app.ui.win2 = app.helper.createWindow('win2', 'win', 'Win 2');
		Ti.include('content/win2.js');
		
		// WINDOW 3
		app.ui.win3 = app.helper.createWindow('win3', 'win', 'Win 3');
		Ti.include('content/win3.js');

		// TABGROUP
		var tabGroup = Ti.UI.createTabGroup();
		
		app.tab1 = app.helper.createTab('tab1', 'tab', 'This is tab1', app.ui.win1);
		app.tab2 = app.helper.createTab('tab2', 'tab', 'TableView', app.ui.win2);
		app.tab3 = app.helper.createTab('tab3', 'tab', 'and.. tab3', app.ui.win3);
				
		tabGroup.addTab(app.tab1);
		tabGroup.addTab(app.tab2);
		tabGroup.addTab(app.tab3);
					
		return tabGroup;
		
	};

})();