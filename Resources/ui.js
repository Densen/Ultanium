//Wrap all code in a self-calling function to protect the global namespace
(function() {
	//Create sub-namespace
	app.ui = {};
		
	// Create initial tab group
	app.ui.initApp = function() {
			
		// WINDOW 1
		app.ui.win1 = app.helper.createWindow('win1', 'win', 'hi');
		var btn = app.helper.createButton('btnCall', 'btnBig', 'Call me!!');
		app.ui.win1.add(btn);
		
		// WINDOW 2
		app.win2 = app.helper.createWindow('win2', 'win', 'TableView');
		Ti.include('content/tableview.js');
		
		// WINDOW 3
		app.win3 = app.helper.createWindow('win3', 'win', 'there');
		

		// TABGROUP
		var tabGroup = Ti.UI.createTabGroup();
		
		app.tab1 = app.helper.createTab('tab1', 'tab', 'This is tab1', app.ui.win1);
		app.tab2 = app.helper.createTab('tab2', 'tab', 'TableView', app.win2);
		app.tab3 = app.helper.createTab('tab3', 'tab', 'and.. tab3', app.win3);
				
		tabGroup.addTab(app.tab1);
		tabGroup.addTab(app.tab2);
		tabGroup.addTab(app.tab3);
					
		return tabGroup;
	};

})();