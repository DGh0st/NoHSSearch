@interface SBRootFolderView : UIView { // iOS 7 - 13
	// _SBRootFolderLayoutWrapperView* _searchPulldownWrapperView; // iOS 10 - 13
	// _SBRootFolderLayoutWrapperView* _searchableTodayWrapperView; // iOS 10 - 13
}
-(UIView *)searchableTodayWrapperView; // iOS 13
-(CGFloat)_scrollOffsetForPageAtIndex:(NSInteger)index; // iOS 7 - 13
@end

@interface FBSystemService : NSObject // iOS 8 - 13
+(instancetype)sharedInstance; // iOS 8 - 13
-(void)exitAndRelaunch:(BOOL)relaunch; // iOS 8 - 13
@end

#define DISABLE_SPOTLIGHT_KEY @"DisableSpotlight"
#define DISABLE_TODAY_PAGE_KEY @"DisableTodayPage"
#define RESPRING_NOTIFICATION (CFStringRef)@"com.dgh0st.nohssearch/respring"

static BOOL isSpotlightDisabled = YES;
static BOOL isTodayPageDisabled = YES;

%hook SBSearchScrollView
-(BOOL)gestureRecognizerShouldBegin:(id)gesture { // iOS 7 - 13
	return isSpotlightDisabled ? NO : %orig(gesture);
}
%end

%hook SBRootFolderView
-(id)initWithFolder:(id)folder orientation:(UIInterfaceOrientation)orientation viewMap:(id)map forSnapshot:(BOOL)snapshot { // iOS 7 - 12
	self = %orig(folder, orientation, map, snapshot);
	if (self != nil && isTodayPageDisabled) {
		// [(UIView *)[self valueForKey:@"_searchPulldownWrapperView"] removeFromSuperview];
		[(UIView *)[self valueForKey:@"_searchableTodayWrapperView"] removeFromSuperview];
	}
	return self;
}

-(id)initWithConfiguration:(id)configuration { // iOS 13
	self = %orig(configuration);
	if (self != nil && isTodayPageDisabled) {
		// [(UIView *)[self valueForKey:@"_searchPulldownWrapperView"] removeFromSuperview];
		[[self searchableTodayWrapperView] removeFromSuperview];
	}
	return self;
}

-(NSUInteger)_minusPageCount { // iOS 9 - 12
	return isTodayPageDisabled ? 0 : %orig();
}

-(CGFloat)_todayViewVisiblilityProgress { // iOS 11 - 12
	return isTodayPageDisabled ? 0.0 : %orig();
}

-(CGFloat)_offsetForTodayViewPage { // iOS 11 - 12
	if ([UIApplication sharedApplication].userInterfaceLayoutDirection == UIUserInterfaceLayoutDirectionRightToLeft || !isTodayPageDisabled)
		return %orig();
	else
		return [self _scrollOffsetForPageAtIndex:0] - 1;
}

-(CGFloat)todayViewVisibilityProgress { // iOS 13
	return isTodayPageDisabled ? 0.0 : %orig();
}

-(BOOL)isSearchHidden { // iOS 13
	return isSpotlightDisabled ? YES : %orig();
}

-(BOOL)isTodayViewPageHidden { // iOS 13
	return isTodayPageDisabled ? YES : %orig();
}
%end

%hook SBIconController
-(id)searchGesture { // iOS 11 - 12
	return isSpotlightDisabled ? nil : %orig();
}
%end

%hook SBHIconManager
-(id)searchGesture { // iOS 13
	return isSpotlightDisabled ? nil : %orig();
}
%end

static void respringDevice() {
	[[%c(FBSystemService) sharedInstance] exitAndRelaunch:YES];
}

%ctor {
	NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"com.dgh0st.nohssearch"];
	isSpotlightDisabled = [userDefaults objectForKey:DISABLE_SPOTLIGHT_KEY] ? [userDefaults boolForKey:DISABLE_SPOTLIGHT_KEY] : YES;
	isTodayPageDisabled = [userDefaults objectForKey:DISABLE_TODAY_PAGE_KEY] ? [userDefaults boolForKey:DISABLE_TODAY_PAGE_KEY] : YES;
	[userDefaults release];

	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)respringDevice, RESPRING_NOTIFICATION, NULL, CFNotificationSuspensionBehaviorDeliverImmediately);

	%init();
}

%dtor {
	CFNotificationCenterRemoveObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, RESPRING_NOTIFICATION, NULL);
}