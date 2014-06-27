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

#define DEBUG_PREFIX @"⭕️⭕️⭕️ [Notific8] "
//#define DEBUG_MODE_ON
#import "DebugLog.h"


#define STRIPE_VIEW_TAG		420
#define HEADER_COLOR		[UIColor colorWithWhite:0 alpha:0.2f]

static NewAttributionWidget *newAttributionWidget;



//------------------------------------//
// Private Interfaces
//------------------------------------//

@interface SBNotificationCenterViewController
+ (id)_localizableTitleForBulletinViewControllerOfClass:(Class)theClass;
@end

@interface SBModeViewController
- (void)setViewControllers:(id)arg1;
@end

@interface SBTodayWidgetAndTomorrowSectionHeaderView : UITableViewHeaderFooterView
+ (id)defaultFont;
+ (id)defaultBackgroundColor;
- (void)prepareForReuse;
- (void)layoutSubviews;
- (void)dealloc;
- (id)initWithFrame:(struct CGRect)arg1;
@end

@interface SBNotificationsAllModeViewController
- (void)_setHeaderViewCurrentlyInClearState:(id)arg1;
- (id)_headerViewCurrentlyInClearState;
- (void)viewWillDisappear:(_Bool)arg1;
- (void)viewDidAppear:(_Bool)arg1;
@end

@protocol SBWidgetViewControllerHostDelegate <NSObject>
@optional
- (void)widget:(id)arg1 didUpdatePreferredSize:(struct CGSize)arg2;
@end

@interface SBNotificationCenterController : NSObject <SBWidgetViewControllerHostDelegate>
+ (id)sharedInstance;
- (void)reloadAllWidgets;
@end



//------------------------------------//
// Settings Notification Handler
//------------------------------------//

static void prefsChanged(CFNotificationCenterRef center, void *observer, CFStringRef name,
						 const void *object, CFDictionaryRef userInfo) {
	DebugLog1(@"******** Settings Changed Notification ********");
	
	if (newAttributionWidget) {
		[newAttributionWidget applySettings];
	}
}



//------------------------------------//
// Hooks
//------------------------------------//


//
// Replace the Attribution Widget.
//
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


//
// Hide the MISSED section tab.
//
%hook SBModeViewController

- (void)setViewControllers:(id)controllers {
	NSMutableArray *newControllers = [[NSMutableArray alloc] init];
	
	for (id vc in controllers) {
		if (![vc isKindOfClass:[%c(SBNotificationsMissedModeViewController) class]]) {
			[newControllers addObject:vc];
		}
	}
	
	%orig(newControllers);
}

%end


//
// Change the title of the ALL section tab.
//
%hook SBNotificationCenterViewController

+ (id)_localizableTitleForBulletinViewControllerOfClass:(Class)theClass {
	
	if ([NSStringFromClass(theClass) isEqualToString:@"SBNotificationsAllModeViewController"]) {
		return @"Notifications";
	} else {
		return %orig;
	}
}

%end


//
// Add a background stripe to the section headers.
//
%hook SBTodayWidgetAndTomorrowSectionHeaderView

- (id)initWithFrame:(struct CGRect)arg1 {
	self = %orig;
	
	UIView *stripe = [[UIView alloc] initWithFrame:self.bounds];
	stripe.backgroundColor = HEADER_COLOR;
	stripe.layer.compositingFilter = @"plusD";
	stripe.tag = STRIPE_VIEW_TAG;
	[self insertSubview:stripe atIndex:0];
	
	return self;
}

- (void)layoutSubviews {
	%orig;
	
	float height = 36.0f;
	CGRect frame = CGRectMake(self.bounds.origin.x, 70.0f - height - 1.0f, self.bounds.size.width, height);
	[[self viewWithTag:STRIPE_VIEW_TAG] setFrame:frame];
	
	for (id subview in [self.subviews[1] subviews]) {
		if ([subview isKindOfClass:%c(SBNotificationCenterSeparatorView)]) {
			[subview setHidden:YES];
			break;
		}
	}
}

%end



//------------------------------------//
// Constructor
//------------------------------------//

%ctor {
	@autoreleasepool {
		NSString *settingsPlistPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Preferences/com.sticktron.notific8.plist"];
		NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:settingsPlistPath];
		
		if (settings && ([settings[@"Enabled"] boolValue] == NO)) {
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
											CFNotificationSuspensionBehaviorDeliverImmediately);
			
			%init; // ok go!
		}
	}
}


