//
//  Notific8
//  Created by Sticktron in 2014.
//
//  An iOS 8-style makeover for the Notification Center.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "NewAttributionWidget.h"
#import "Headers/SpringBoardUIServices/_SBUIWidgetViewController.h"

#define DEBUG_PREFIX @"🔴 [Notific8] "
#import "DebugLog.h"



// Private Interfaces
//----------------------------------------//

@interface SBNotificationCenterViewController : UIViewController
+ (id)_localizableTitleForBulletinViewControllerOfClass:(Class)theClass;
- (id)_allModeViewControllerCreateIfNecessary:(_Bool)arg1;
@end


@interface SBNotificationCenterController : NSObject
@property(readonly, nonatomic) SBNotificationCenterViewController *viewController; // @synthesize viewController=_viewController;
+ (id)sharedInstance;
@end


@interface SBModeViewController : UIViewController
- (void)setViewControllers:(id)arg1;
@end


@interface SBNotificationCenterSeparatorView : UIView
@end


@interface SBBulletinViewController : UIViewController
- (id)tableView:(id)arg1 viewForHeaderInSection:(long long)arg2;
@end


@interface SBTodayWidgetAndTomorrowSectionHeaderView : UITableViewHeaderFooterView
{
//    UILabel *_titleLabel;
//    UIImageView *_iconImageView;
    SBNotificationCenterSeparatorView *_separatorView;
}
//+ (id)defaultFont;
//+ (id)defaultBackgroundColor;
- (id)initWithFrame:(struct CGRect)arg1;
//- (void)prepareForReuse;
//- (void)layoutSubviews;
@end


@interface SBNotificationsAllModeViewController : SBModeViewController
@property (readonly, nonatomic) NSArray *orderedSectionIDs;
- (void)_setHeaderViewCurrentlyInClearState:(id)arg1;
- (void)invalidateContentLayout;
@end


//@protocol SBWidgetViewControllerHostDelegate <NSObject>
//@optional
//- (void)widget:(id)arg1 didUpdatePreferredSize:(struct CGSize)arg2;
//@end


//@interface SBNotificationCenterController : NSObject <SBWidgetViewControllerHostDelegate>
//+ (id)sharedInstance;
//- (void)reloadAllWidgets;
//@end


//@interface SBTodayBulletinCell : UIView
//@property(copy, nonatomic) NSString *labelText;
//@property(nonatomic) struct CGRect textRect;
//- (id)initWithStyle:(long long)arg1 reuseIdentifier:(id)arg2;
//@end


@interface SBNotificationsSectionHeaderView : UIView
//- (id)initWithFrame:(struct CGRect)arg1;
//- (void)_addClearButtons;
//- (id)_circleXImage;
//- (struct CGRect)_clearButtonFrame;
//- (id)_clearImage;
//- (void)_removeClearButtons;
- (void)_setShowsClear:(_Bool)arg1 animated:(_Bool)arg2;
//- (struct CGRect)_xButtonFrame;
//- (void)buttonAction:(id)arg1;
//- (struct CGRect)contentBounds;
//- (long long)initialGraphicsQuality;
- (_Bool)isShowingClear;
//- (void)layoutSubviews;
//- (void)prepareForReuse;
//- (void)resetAnimated:(_Bool)arg1;
//- (void)setBackgroundView:(id)arg1;
//- (void)setFloating:(_Bool)arg1;
//- (void)setHasClearButton:(_Bool)arg1;
//- (void)setTarget:(id)arg1 forClearButtonAction:(CDUnknownBlockType)arg2;
//- (void)setTarget:(id)arg1 forClearButtonVisibleAction:(CDUnknownBlockType)arg2;
@end



#define iPad						(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

#define TINT_VIEW_HEIGHT			36.0f
#define TINT_COLOR				[UIColor colorWithWhite:0 alpha:0.2f]
#define TINT_VIEW_TAG			420

#define SEP_VIEW_TAG				911

#define LOCALIZATIONS_PATH		@"/Library/Application Support/Notific8/Localizations/"

static NewAttributionWidget *newAttributionWidget;
static NSBundle *bundle;
static BOOL isDisabled = NO;
static BOOL alwaysShowClear = YES;



// Substitutes strings with localized versions
NSString* MyLocalizedString(NSString *string) {
	if (!bundle) {
		bundle = [NSBundle bundleWithPath:LOCALIZATIONS_PATH];
	}
	
	NSString *result = [bundle localizedStringForKey:string value:string table:nil];
	NSLog(@"[Notific8] translating:%@ >>> %@", string, result);
	
	return result;
}


// Loads user preferences
static void loadSettings() {
	NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Preferences/com.sticktron.notific8.plist"];
	NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:path];
	
	isDisabled = (settings[@"Enabled"] && ([settings[@"Enabled"] boolValue] == NO));
	alwaysShowClear = (settings[@"AlwaysShowClear"] && [settings[@"AlwaysShowClear"] boolValue] == NO) ? NO:YES;
	
	NSLog(@"[Notific8] settings are now......");
	NSLog(@"[Notific8] isDisabled=%@", isDisabled ? @"yes":@"no");
	NSLog(@"[Notific8] alwaysShowClear=%@", alwaysShowClear ? @"yes":@"no");
}


// Called when settings are changed
static void prefsChanged(CFNotificationCenterRef center, void *observer, CFStringRef name,
						 const void *object, CFDictionaryRef userInfo) {
	DebugLogC(@"******** Settings Changed Notification ********");
	
	loadSettings();
	
	// update our attribution widget
	if (newAttributionWidget) {
		[newAttributionWidget applySettings];
	}
	
	// force the Clear buttons to be updated by invalidating the view controller's layout
	Class $SBNotificationCenterController = NSClassFromString(@"SBNotificationCenterController");
	SBNotificationCenterController *cc = [$SBNotificationCenterController sharedInstance];
	
	if (cc && cc.viewController) {
		id amvc = [cc.viewController _allModeViewControllerCreateIfNecessary:NO];
		DebugLogC(@"AllModeViewController=%@", amvc);
		
		if ([amvc respondsToSelector:@selector(invalidateContentLayout)]) {
			DebugLogC(@"invalidating layout, Clear buttons should update.");
			[amvc invalidateContentLayout];
			DebugLogC(@">>> invalidated.");
		} else {
			DebugLogC(@"does not respond to invalidate");
		}
	}
	
//	for (id sectionID in amvc.orderedSectionIDs) {
//		//
//	}
		 
}



// Hooks
//----------------------------------------//


// Replace the Attribution Widget controller
%hook _SBUIWidgetViewController
- (id)init {
	DebugLog0;
	
	// when the AttributionWeeApp controller is loaded, replace it with a custom controller
	if ([NSStringFromClass([self class]) isEqualToString:@"AttributionWeeAppController"]) {
		self = newAttributionWidget;
		DebugLog(@"Replacing the Attribution Widget with: %@", self);
		
	} else {
		self = %orig;
	}
	
	return self;
}
%end


// Hide the MISSED section tab.
%hook SBModeViewController
- (void)setViewControllers:(id)controllers {
	NSMutableArray *newControllers = [[NSMutableArray alloc] init];
	
	for (id vc in controllers) {
//		DebugLog(@"controller=%@", [vc class]);
		if (![vc isKindOfClass:[%c(SBNotificationsMissedModeViewController) class]]) {
			[newControllers addObject:vc];
		}
	}
	
	%orig(newControllers);
}
%end


// Change the title of the ALL section tab
%hook SBNotificationCenterViewController
+ (id)_localizableTitleForBulletinViewControllerOfClass:(Class)theClass {
	
	if ([NSStringFromClass(theClass) isEqualToString:@"SBNotificationsAllModeViewController"]) {
		return MyLocalizedString(@"Notifications");
	} else {
		return %orig;
	}
}
%end


// Modify Section Headers
%hook SBTodayWidgetAndTomorrowSectionHeaderView
- (id)initWithFrame:(CGRect)frame {
	DebugLog0;
	//DebugLog(@"frame=%@", NSStringFromCGRect(frame));
	
	// create the tint view...
	
	SBTodayWidgetAndTomorrowSectionHeaderView *view = %orig;
	
	CGRect tframe = CGRectMake(0, 0, view.bounds.size.width, TINT_VIEW_HEIGHT);
	UIView *tintView = [[UIView alloc] initWithFrame:tframe];
	tintView.layer.compositingFilter = @"plusD";
	tintView.backgroundColor = TINT_COLOR;
	tintView.tag = TINT_VIEW_TAG;
	
	[view insertSubview:tintView atIndex:0];
	
	
	return view;
}
- (void)layoutSubviews {
	%orig;
	
	// set tintView's index to 0 again...
	
	UIView *tintView = [self viewWithTag:TINT_VIEW_TAG];
	if (tintView) {
		[self sendSubviewToBack:tintView];
		
		// set y co-ord
		CGRect frame = self.bounds;
		frame.origin.y = self.bounds.size.height - TINT_VIEW_HEIGHT - 1.0f;
		frame.size.height = TINT_VIEW_HEIGHT;
		[tintView setFrame:frame];
	}
	
	
	// hide separator...
	
	SBNotificationCenterSeparatorView *separator = MSHookIvar<id>(self, "_separatorView");
	DebugLog(@"hooked separator: %@", separator);
	
	if (separator != nil) {
		separator.hidden = YES;
	}
}
%end


// Always show the Clear buttons
%hook SBNotificationsSectionHeaderView
- (void)_setShowsClear:(_Bool)arg1 animated:(_Bool)arg2 {
	DebugLog0;
	
	if (alwaysShowClear) {
		return %orig(YES, NO);
	} else {
		return %orig;
	}
}

%end



// Constructor
%ctor {
	@autoreleasepool {
		
		loadSettings();
		
		if (isDisabled) {
			NSLog(@" Notific8 is disabled.");
			
		} else {
			NSLog(@" Notific8 is enabled.");
			
			newAttributionWidget = [[NewAttributionWidget alloc] init];
			
			// start listening for notifications from Settings
			CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
											NULL,
											(CFNotificationCallback)prefsChanged,
											CFSTR("com.sticktron.notific8.settings-changed"),
											NULL,
											CFNotificationSuspensionBehaviorDeliverImmediately
			);
			
			%init;
		}
	}
}



