/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2011 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 * 
 * WARNING: This is generated code. Modify at your own risk and without support.
 */
#ifdef USE_TI_UISCROLLABLEVIEW

#import "TiUIScrollableView.h"
#import "TiUtils.h"
#import "TiViewProxy.h"


@interface InnerScrollView : UIScrollView<UIScrollViewDelegate>
{
}
@end

@implementation InnerScrollView

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
	if ([[self subviews] count] > 0) {
		return [[self subviews] objectAtIndex:0];
	}
	return nil;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView_ withView:(UIView *)view atScale:(float)scale 
{
}

@end



@implementation TiUIScrollableView

#pragma mark Internal 

-(void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	RELEASE_TO_NIL(views);
	RELEASE_TO_NIL(scrollview);
	RELEASE_TO_NIL(pageControl);
	[super dealloc];
}

-(id)init
{
	if (self = [super init]) {
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(didRotate:) name:UIApplicationDidChangeStatusBarOrientationNotification
												   object:nil];
        cacheSize = 3;
	}
	return self;
}

-(void)initializerState
{
	maxScale = 1.0;
	minScale = 1.0;
}

-(CGRect)pageControlRect
{
	CGRect boundsRect = [self bounds];
	return CGRectMake(boundsRect.origin.x, 
					  boundsRect.origin.y + boundsRect.size.height - pageControlHeight,
					  boundsRect.size.width, 
					  pageControlHeight);
}

-(UIPageControl*)pagecontrol 
{
	if (pageControl==nil)
	{
		pageControl = [[UIPageControl alloc] initWithFrame:[self pageControlRect]];
		[pageControl setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin];
		[pageControl addTarget:self action:@selector(pageControlTouched:) forControlEvents:UIControlEventValueChanged];
		[pageControl setBackgroundColor:[UIColor blackColor]];
		[self addSubview:pageControl];
	}
	return pageControl;
}

-(UIScrollView*)scrollview 
{
	if (scrollview==nil)
	{
		scrollview = [[UIScrollView alloc] initWithFrame:[self bounds]];
		[scrollview setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
		[scrollview setPagingEnabled:YES];
		[scrollview setDelegate:self];
		[scrollview setBackgroundColor:[UIColor clearColor]];
		[scrollview setShowsVerticalScrollIndicator:NO];
		[scrollview setShowsHorizontalScrollIndicator:NO];
		[scrollview setDelaysContentTouches:NO];
		[scrollview setClipsToBounds:[TiUtils boolValue:[self.proxy valueForKey:@"clipViews"] def:YES]];
		[self insertSubview:scrollview atIndex:0];
	}
	return scrollview;
}

-(void)refreshPageControl
{
	if (showPageControl)
	{
		UIPageControl *pg = [self pagecontrol];
		[pg setFrame:[self pageControlRect]];
		[pg setNumberOfPages:[views count]];
	}	
}

-(UIView *)parentViewForChild:(TiViewProxy *)child
{	//TODO: Remove and put in the proxy where it belongs.
	int index = [views indexOfObject:child];
	if (index == NSNotFound)
	{
		return nil;
	}
	NSArray * scrollWrappers = [[self scrollview] subviews];
	if (index < [scrollWrappers count])
	{
		return [scrollWrappers objectAtIndex:index];
	}
	//TODO: Generate the view?
	return nil;
}

-(void)renderViewForIndex:(int)index
{
	UIScrollView *sv = [self scrollview];
	NSArray * svSubviews = [sv subviews];
	int svSubviewsCount = [svSubviews count];

	if ((index < 0) || (index >= svSubviewsCount))
	{
		return;
	}

	UIView *wrapper = [svSubviews objectAtIndex:index];
	TiViewProxy *viewproxy = [views objectAtIndex:index];
	if ([[wrapper subviews] count]==0)
	{
		// we need to realize this view
		[viewproxy windowWillOpen];
		TiUIView *uiview = [viewproxy view];
		[wrapper addSubview:uiview];
		[viewproxy reposition];
	}
	[viewproxy parentWillShow];
}

-(NSRange)cachedFrames
{
    int startPage;
    int endPage;
    
    // Step 1: Check to see if we're actually smaller than the cache range:
    if (cacheSize >= [views count]) {
        startPage = 0;
        endPage = [views count] - 1;
    }
    else {
		startPage = (currentPage - (cacheSize - 1) / 2);
		endPage = (currentPage + (cacheSize - 1) / 2);
		
        // Step 2: Check to see if we're rendering outside the bounds of the array, and if so, adjust accordingly.
        if (startPage < 0) {
            endPage -= startPage;
            startPage = 0;
        }
        if (endPage >= [views count]) {
            int diffPage = endPage - [views count];
            endPage = [views count] -  1;
            startPage += diffPage;
        }
		if (startPage > endPage) {
			startPage = endPage;
		}
    }
    
	return NSMakeRange(startPage, endPage - startPage + 1);
}

-(void)manageCache
{
    if (views == nil || [views count] == 0) {
        return;
    }
    
    NSRange renderRange = [self cachedFrames];
    for (int i=0; i < [views count]; i++) {
		NSDate* startProcess = [NSDate date];
        TiViewProxy* viewProxy = [views objectAtIndex:i];
        if (i >= renderRange.location && i < NSMaxRange(renderRange)) {
            [self renderViewForIndex:i];
        }
        else if ([viewProxy viewAttached]) {
            [viewProxy detachView];
        }
    }
}

-(void)listenerAdded:(NSString*)event count:(int)count
{
	[super listenerAdded:event count:count];
	for (TiViewProxy* viewProxy in views) {
		if ([viewProxy viewAttached]) {
			[[viewProxy view] updateTouchHandling];
		}
	}
}

-(void)refreshScrollView:(CGRect)visibleBounds readd:(BOOL)readd
{
	CGRect viewBounds;
	viewBounds.size.width = visibleBounds.size.width;
	viewBounds.size.height = visibleBounds.size.height - (showPageControl ? pageControlHeight : 0);
	viewBounds.origin = CGPointMake(0, 0);
	
	UIScrollView *sv = [self scrollview];
	
	[self refreshPageControl];
	
	if (readd)
	{
		for (UIView *view in [sv subviews])
		{
			[view removeFromSuperview];
		}
	}
	
	for (int c=0;c<[views count];c++)
	{
		viewBounds.origin.x = c*visibleBounds.size.width;
		
		if (readd)
		{
			//TODO: optimize for non-scaled?
			InnerScrollView *view = [[InnerScrollView alloc] initWithFrame:viewBounds];
			[view setMaximumZoomScale:maxScale];
			[view setMinimumZoomScale:minScale];
			[view setShowsVerticalScrollIndicator:NO];
			[view setShowsHorizontalScrollIndicator:NO];
			[view setDelegate:view];
//			[view setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
			[view setPagingEnabled:NO];
			[view setBackgroundColor:[UIColor clearColor]];
			[view setDelaysContentTouches:NO];
			[sv addSubview:view];
			[view release];
		}
		else 
		{
			UIView *view = [[sv subviews] objectAtIndex:c];
			view.frame = viewBounds;
		}
	}
    
	if (currentPage==0 || readd)
	{
        [self manageCache];
	}
	
	CGRect contentBounds;
	contentBounds.origin.x = viewBounds.origin.x;
	contentBounds.origin.y = viewBounds.origin.y;
	contentBounds.size.width = viewBounds.size.width;
	contentBounds.size.height = viewBounds.size.height-(showPageControl ? pageControlHeight : 0);
	contentBounds.size.width *= [views count];
	
	[sv setContentSize:contentBounds.size];
	[sv setFrame:CGRectMake(0, 0, visibleBounds.size.width, visibleBounds.size.height)];
}

-(void)frameSizeChanged:(CGRect)frame bounds:(CGRect)visibleBounds
{
	if (!CGRectIsEmpty(visibleBounds))
	{
		[self refreshScrollView:visibleBounds readd:YES];
		
		if (![scrollview isDecelerating] && ![scrollview isDragging] && ![scrollview isTracking])
		{
			[scrollview setContentOffset:CGPointMake(currentPage*visibleBounds.size.width,0)];
		}
	}
}

#pragma mark Public APIs

-(void)setCacheSize_:(id)args
{
    ENSURE_SINGLE_ARG(args, NSNumber);
    int newCacheSize = [args intValue];
    if (newCacheSize < 3) {
        // WHAT.  Let's make it something sensible.
        newCacheSize = 3;
    }
    if (newCacheSize % 2 == 0) {
        NSLog(@"[WARN] Even scrollable cache size %d; setting to %d", newCacheSize, newCacheSize-1);
        newCacheSize -= 1;
    }
    cacheSize = newCacheSize;
    [self manageCache];
}

-(void)setViews_:(id)args
{
	BOOL refresh = (views!=nil);
	if (views!=nil)
	{
		for (TiViewProxy *proxy in views)
		{
			[proxy detachView];
		}
	}
	RELEASE_TO_NIL(views);
	views = [args retain];
	
	// Reparent views
	for (TiViewProxy* proxy in views) {
		[proxy setParent:[self proxy]];
	}
	
	if (refresh)
	{
		[self refreshScrollView:[self bounds] readd:YES];
	}
}

-(void)setShowPagingControl_:(id)args
{
	showPageControl = [TiUtils boolValue:args];
	if (pageControl!=nil)
	{
		if (showPageControl==NO)
		{
			[pageControl removeFromSuperview];
			RELEASE_TO_NIL(pageControl);
		}
	}
	else if (showPageControl)
	{
		[self pagecontrol];
	}
}

-(void)setPagingControlHeight_:(id)args
{
	showPageControl=YES;
	pageControlHeight = [TiUtils floatValue:args def:20.0];
	if (pageControlHeight < 5.0)
	{
		pageControlHeight = 20.0;
	}
	[[self pagecontrol] setFrame:[self pageControlRect]];
}

-(void)setPageControlHeight_:(id)arg
{
	// for 0.8 backwards compat, renamed all for consistency
	[self setPagingControlHeight_:arg];
}

-(void)setPagingControlColor_:(id)args
{
	[[self pagecontrol] setBackgroundColor:[[TiUtils colorValue:args] _color]];
}

-(int)pageNumFromArg:(id)args
{
	int pageNum = 0;
	
	if ([args isKindOfClass:[TiViewProxy class]])
	{
		for (int c=0;c<[views count];c++)
		{
			if (args == [views objectAtIndex:c])
			{
				pageNum = c;
				break;
			}
		}
	}
	else
	{
		pageNum = [TiUtils intValue:args];
	}
	
	return pageNum;
}

-(void)scrollToView:(id)args
{
	int pageNum = [self pageNumFromArg:args];
	[[self scrollview] setContentOffset:CGPointMake([self bounds].size.width * pageNum, 0) animated:YES];
	currentPage = pageNum;
	
    [self manageCache];
	
	[self.proxy replaceValue:NUMINT(pageNum) forKey:@"currentPage" notification:NO];
}

-(void)addView:(id)viewproxy
{
	ENSURE_SINGLE_ARG(viewproxy,TiProxy);
	[viewproxy setParent:(TiViewProxy *)self.proxy];
	if (views != nil)
	{
		[views addObject:viewproxy];
	}
	else
	{
		views = [[NSMutableArray alloc] initWithObjects:viewproxy,nil];
	}

	[self refreshScrollView:[self bounds] readd:YES];
}

-(void)removeView:(id)args
{
	int pageNum = [self pageNumFromArg:args];
	if (pageNum >=0 && pageNum < [views count])
	{
		if (currentPage==pageNum)
		{
			currentPage = [views count]-1;
			[self.proxy replaceValue:NUMINT(currentPage) forKey:@"currentPage" notification:NO];
		}
		TiViewProxy *viewproxy = [views objectAtIndex:pageNum];
		[viewproxy setParent:nil];
		[views removeObjectAtIndex:pageNum];
		[self refreshScrollView:[self bounds] readd:YES];
	}
}

-(int)currentPage
{
	CGPoint offset = [[self scrollview] contentOffset];
	CGSize scrollFrame = [self bounds].size;
	return floor(offset.x/scrollFrame.width);
}

-(void)setCurrentPage_:(id)page
{
	int newPage = [TiUtils intValue:page];
	if (newPage >=0 && newPage < [views count])
	{
		[scrollview setContentOffset:CGPointMake([self bounds].size.width * newPage, 0) animated:NO];
		currentPage = newPage;
		pageControl.currentPage = newPage;
		
        [self manageCache];
        
		[self.proxy replaceValue:NUMINT(newPage) forKey:@"currentPage" notification:NO];
	}
}

-(void)setMaxZoomScale_:(id)scale
{
	maxScale = [TiUtils floatValue:scale];
}

-(void)setMinZoomScale_:(id)scale
{
	minScale = [TiUtils floatValue:scale];
}

#pragma mark Notifications

-(void)didRotate:(NSNotification*)note
{
	if ([scrollview isDecelerating]) {
		rotatedWhileScrolling = YES;
	}
}

#pragma mark Delegate calls

-(void)pageControlTouched:(id)sender
{
	int pageNum = [(UIPageControl *)sender currentPage];
	[scrollview setContentOffset:CGPointMake([self bounds].size.width * pageNum, 0) animated:YES];
	handlingPageControlEvent = YES;
	
	currentPage = pageNum;
	[self manageCache];
	
	[self.proxy replaceValue:NUMINT(pageNum) forKey:@"currentPage" notification:NO];
	
	if ([self.proxy _hasListeners:@"click"])
	{
		[self.proxy fireEvent:@"click" withObject:[NSDictionary dictionaryWithObjectsAndKeys:
													NUMINT(pageNum),@"currentPage",
													[views objectAtIndex:pageNum],@"view",nil]]; 
	}
	
}

-(void)scrollViewDidScroll:(UIScrollView *)sender
{
	//switch page control at 50% across the center - this visually looks better
    CGFloat pageWidth = scrollview.frame.size.width;
    int page = floor((scrollview.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
	if (currentPage != page) {
		[pageControl setCurrentPage:page];
		currentPage = page;
        [self manageCache];
	}
}

-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
	// called when setContentOffset/scrollRectVisible:animated: finishes. not called if not animating
	[self scrollViewDidEndDecelerating:scrollView];
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
	if (rotatedWhileScrolling) {
		rotatedWhileScrolling = NO;
		[[self scrollview] setContentOffset:CGPointMake([self bounds].size.width * currentPage, 0) animated:YES];
	}
		
	// At the end of scroll animation, reset the boolean used when scrolls originate from the UIPageControl
	int pageNum = [self currentPage];
	handlingPageControlEvent = NO;

	[self.proxy replaceValue:NUMINT(pageNum) forKey:@"currentPage" notification:NO];
	
	if ([self.proxy _hasListeners:@"scroll"])
	{
		[self.proxy fireEvent:@"scroll" withObject:[NSDictionary dictionaryWithObjectsAndKeys:
											  NUMINT(currentPage),@"currentPage",
											  [views objectAtIndex:pageNum],@"view",nil]]; 
	}
	currentPage=pageNum;
	[pageControl setCurrentPage:pageNum];
}

@end

#endif