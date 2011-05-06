(function() {
	//Create sub-namespace
	app.tableview = {};

	// bug means we cannot use jss for tableview rows with data so hardcode styles in 
	var data = [
		{title:'HTML5 WebView', hasChild:true, color:'#7D0000', selectedBackgroundColor:'#A00C04', html:'content/webview.html'},
		{title:'HTML5 Video', hasChild:true, color:'#7D0000', selectedBackgroundColor:'#A00C04', html:'content/html5video.html'}
	];
	
	var tableViewStyle = null;	
	if (Ti.Platform.osname == "iphone") {
		tableViewStyle = Titanium.UI.iPhone.TableViewStyle.GROUPED;
	} 
			
	// Create TableView from options & array
	var tableViewOptions = {
			id:'tableview', 
			className:'tableview',
			data:data,
			style:tableViewStyle
		};		
		

	
	var tableview = Titanium.UI.createTableView(tableViewOptions);
	
	// Add TableView 
	app.ui.win2.add(tableview); 
	
	// EventListener
	tableview.addEventListener('click', function(e)
	{
		var rowdata = e.rowData;
		var win = app.helper.createWindow('tableviewWin', 'window', rowdata.title);
				
		// HTML loads in webpages / JS loads another TableView or Alternate Content	
		if(rowdata.html) {
			var webview = Ti.UI.createWebView();
			webview.url = rowdata.html;
			win.add(webview);
			app.tab2.open(win, {animated:true});
		} else if (rowdata.js) {
			win.url = rowdata.js;
			win.title = rowdata.title;
			app.tab2.open(win, {animated:true});
		}
	});
	
})();