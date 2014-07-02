//
//  notific8 Settings
//  Created by Sticktron in 2014.
//
//

#define DEBUG_PREFIX @"🔵 [Notific8Settings] "
#import "../DebugLog.h"

#import "Headers/Preferences/PSListController.h"
#import "Headers/Preferences/PSSpecifier.h"
#import "Headers/Preferences/PSTableCell.h"


#define EMAIL_COLE					@"mailto:davidcolehunt@me.com"
#define TWITTER_WEB_COLE			@"http://twitter.com/cohlman"
#define TWITTER_APP_COLE			@"twitter://user?screen_name=cohlman"

#define EMAIL_STICKTRON				@"mailto:sticktron@hotmail.com"
#define TWITTER_WEB_STICKTRON		@"http://twitter.com/sticktron"
#define TWITTER_APP_STICKTRON		@"twitter://user?screen_name=sticktron"
//#define URL_GITHUB				@"http://github.com/Sticktron"

#define LOGO_PATH				@"/Library/PreferenceBundles/Notific8Settings.bundle/Logo.png"
#define ICON_PATH				@"/Library/PreferenceBundles/Notific8Settings.bundle/Icon.png"


@class Notific8SettingsController;
static Notific8SettingsController *controller = nil;




//----------------------------------------//
// handle respring notification
//----------------------------------------//

static void respringNotification(CFNotificationCenterRef center, void *observer, CFStringRef name,
								 const void *object, CFDictionaryRef userInfo) {
	
	DebugLogC(@"******** Respring notification  ********");
	
	if (controller) {
		UIAlertView *alert = [[UIAlertView alloc]
							  initWithTitle:@"Respring Required"
							  message:@"Would you like to respring now?"
							  delegate:controller
							  cancelButtonTitle:@"NO"
							  otherButtonTitles:@"YES", nil];
		[alert show];
	}
}




//----------------------------------------//
// LogoCell Class
//----------------------------------------//


@interface LogoCell : PSTableCell
@property (nonatomic, strong) UIImageView *logoView;
@end


//----------------------------------------//


@implementation LogoCell

- (id)initWithSpecifier:(PSSpecifier *)specifier {
	self = [super initWithStyle:UITableViewCellStyleDefault
				reuseIdentifier:@"LogoCell"
					  specifier:specifier];
	
	if (self) {
		self.opaque = YES;
		
		UIImage *logo = [[UIImage alloc] initWithContentsOfFile:LOGO_PATH];
		UIImageView *logoView = [[UIImageView alloc] initWithImage:logo];
		
		[self addSubview:logoView];
	}
	
	return self;
}

- (CGFloat)preferredHeightForWidth:(CGFloat)height {
	return 100.f;
}

@end





//----------------------------------------//
// Settings Controller
//----------------------------------------//


@interface Notific8SettingsController : PSListController
- (id)initForContentSize:(CGSize)size;
- (void)openEmailForCole;
- (void)openEmailForSticktron;
- (void)openTwitterForSticktron;
- (void)openTwitterForCole;
- (void)openTwitterForCole;
- (void)respring;
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
@end


//----------------------------------------//


@implementation Notific8SettingsController

- (id)initForContentSize:(CGSize)size {
	DebugLog0;
	
	controller = [super initForContentSize:size];
	
	// add a Respring button to the navbar
	UIBarButtonItem *respringButton = [[UIBarButtonItem alloc] initWithTitle:@"Respring"
																	   style:UIBarButtonItemStyleDone
																	  target:self
																	  action:@selector(respring)];
	
	respringButton.tintColor = [UIColor colorWithRed:0.639 green:0.412 blue:0.831 alpha:1]; /*#a369d4*/
	[self.navigationItem setRightBarButtonItem:respringButton];
	
	// handle notification from Enabled switch
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
									NULL,
									(CFNotificationCallback)respringNotification,
									CFSTR("com.sticktron.notific8.settings-changed-respring"),
									NULL,
									CFNotificationSuspensionBehaviorDeliverImmediately);

	return controller;
}

- (id)specifiers {
	if (_specifiers == nil) {
		_specifiers = [self loadSpecifiersFromPlistName:@"Notific8Settings" target:self];
	}
    
	return _specifiers;
}

- (void)setTitle:(id)title {
	UIImage *icon = [[UIImage alloc] initWithContentsOfFile:ICON_PATH];
	UIImageView *iconView = [[UIImageView alloc] initWithImage:icon];
	
	self.navigationItem.titleView = iconView;	
}

- (void)openEmailForSticktron {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:EMAIL_STICKTRON]];
}

- (void)openEmailForCole {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:EMAIL_COLE]];
}

- (void)openTwitterForSticktron {
	// try the app first, otherwise use web
	if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter:"]]) {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:TWITTER_APP_STICKTRON]];
	} else {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:TWITTER_WEB_STICKTRON]];
	}
}

- (void)openTwitterForCole {
	// try the app first, otherwise use web
	if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter:"]]) {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:TWITTER_APP_COLE]];
	} else {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:TWITTER_WEB_COLE]];
	}
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
		[self respring];
    }
}

- (void)respring {
	NSLog(@"Notific8 called for a respring.");
	system("killall -HUP SpringBoard");
}

@end

