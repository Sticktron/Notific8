//
//  Notific8
//  Created by Sticktron in 2014.
//
//	NewAttributionWidget is an iOS 8-styled replacement for the iOS 7 widget.
//
//

#import "NewAttributionWidget.h"

#define DEBUG_PREFIX @"🔶 [Notific8] "
#import "DebugLog.h"


#define BUTTON_BG_COLOR		[UIColor colorWithWhite:0.55f alpha:1.0f]
#define BUTTON_COLOR			[UIColor colorWithWhite:1.0f alpha:0.2f]
#define BUTTON_COLOR_ON		[UIColor colorWithWhite:0 alpha:0.2f]
#define TEXT_COLOR				[UIColor colorWithWhite:0.52f alpha:1.0f]

#define HEADER_FILTER			@"plusD"
#define CONTENT_FILTER		@"colorDodgeBlendMode"
#define YAHOO_IMAGE_PATH		@"/Library/PreferenceBundles/Notific8Settings.bundle/Yahoo!@2x.png"


/*

layouts:

(full)
–––––––––––––––––––––––––––
MARGIN		32.5	a*
–––––––––	line
MARGIN		27.5	b*
[EDIT]		28		c
MARGIN		18		d
[ATTRIB]	60		e
MARGIN		10		f*
–––––––––––––––––––––––––––



(no button)
–––––––––––––––––––––––––––
MARGIN		32.5	a
–––––––––	line
MARGIN		27.5	b
[EDIT]		-		- c
MARGIN		-		- d
[ATTRIB]	60		e
MARGIN		10		f
–––––––––––––––––––––––––––
 


(no attrib)
–––––––––––––––––––––––––––
MARGIN		32.5	a
–––––––––	line
MARGIN		27.5	b
[EDIT]		28		c
MARGIN				- d
[ATTRIB]			- e
MARGIN		10		f
–––––––––––––––––––––––––––

*/


#define MARGIN_TOP							32.5f
#define SPACE_AFTER_LINE					27.5f
#define BUTTON_SIZE						(CGSize){223, 28}
#define SPACE_BETWEEN_BUTTON_AND_TEXT	18.0f
#define TEXT_HEIGHT						60.0f
#define MARGIN_BOTTOM						10.0f

#define is_iPad							(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)


extern NSString* MyLocalizedString(NSString *string);





//----------------------------------------//
// Private Interfaces
//----------------------------------------//


@interface SpringBoard
- (BOOL)isLocked;
@end


@interface SBNotificationCenterSeparatorView : UIView
- (id)initWithFrame:(CGRect)frame mode:(long long)mode;
@end


//@protocol SBWidgetViewControllerHostDelegate <NSObject>
//@optional
//- (void)widget:(id)arg1 didUpdatePreferredSize:(struct CGSize)arg2;
//@end


//@interface SBNotificationCenterController : NSObject <SBWidgetViewControllerHostDelegate>
//+ (id)sharedInstance;
//@end





//----------------------------------------//
// Custom Attribution Widget
//----------------------------------------//

@implementation NewAttributionWidget

- (id)init {
	if (self = [super init]) {
		DebugLog(@"init'd");
	}
	return self;
}

- (CGSize)preferredViewSize {
	// adjust height based on subview visibility
	
	float width = is_iPad ? 580.0f : UIScreen.mainScreen.bounds.size.width;
	float height = 0;
	
	height = MARGIN_TOP + SPACE_AFTER_LINE;
	
//	// only attrib view is hidden...
//	if (self.button.hidden == NO && self.attributionView.hidden == YES) {
//		return (CGSize){width, height += (BUTTON_SIZE.height + MARGIN_BOTTOM)};
//	}
//	
//	// only button is hidden...
//	if (self.button.hidden == YES && self.attributionView.hidden == NO) {
//		return (CGSize){width, height += (TEXT_HEIGHT + MARGIN_BOTTOM)};
//	}
	
	if (self.button.hidden == NO && self.attributionView.hidden == NO) {
		// both are showing...
		return (CGSize){width, height += (BUTTON_SIZE.height + SPACE_BETWEEN_BUTTON_AND_TEXT + TEXT_HEIGHT + MARGIN_BOTTOM)};
	} else {
		// both are hidden...
		return (CGSize){width, 0};
	}
}

- (void)loadView {
	DebugLog0;
	
	UIView *view = [[UIView alloc] initWithFrame:(CGRect){CGPointZero, self.preferredViewSize}];
	view.clipsToBounds = YES;
	view.autoresizesSubviews = NO;
	view.backgroundColor = UIColor.clearColor;
	
	float x = (view.bounds.size.width - BUTTON_SIZE.width) / 2.0f;
	float y = 	MARGIN_TOP;

	
	
	// separator line ...
	
	CGRect sepFrame = (CGRect){{0, y}, {self.preferredViewSize.width, 0.5f}};
	Class $SBNotificationCenterSeparatorView = NSClassFromString(@"SBNotificationCenterSeparatorView");
	SBNotificationCenterSeparatorView *sepView = [[$SBNotificationCenterSeparatorView alloc] initWithFrame:sepFrame mode:0];
	
	self.separatorView = sepView;
	[view addSubview:self.separatorView];
	
	
	
	// edit button & backing view ...
	
	y += SPACE_AFTER_LINE;
	CGRect buttonFrame = (CGRect){{x, y}, BUTTON_SIZE};
	
	UIView *bg = [[UIView alloc] initWithFrame:buttonFrame];
	bg.backgroundColor = BUTTON_BG_COLOR;
	bg.layer.compositingFilter = CONTENT_FILTER;
	bg.layer.borderWidth = 0;
	bg.layer.cornerRadius = 5.0f;
	
	self.buttonBGView = bg;
	[view addSubview:self.buttonBGView];
	
	
	UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
	btn.frame = buttonFrame;
	btn.backgroundColor = BUTTON_COLOR;
	btn.layer.borderWidth = 0;
	btn.layer.cornerRadius = 5.0f;
	
	[btn setTitle:MyLocalizedString(@"Edit") forState:UIControlStateNormal];
	[btn setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
	btn.titleLabel.font = [UIFont systemFontOfSize:14.0f];
	
	[btn addTarget:self action:@selector(jump:) forControlEvents:UIControlEventTouchUpInside];
	[btn addTarget:self action:@selector(highlight:) forControlEvents:UIControlEventTouchDown];
	[btn addTarget:self action:@selector(unhighlight:) forControlEvents:UIControlEventTouchDragOutside];
	[btn addTarget:self action:@selector(unhighlight:) forControlEvents:UIControlEventTouchDragExit];
	
	self.button = btn;
	[view addSubview:self.button];
	
	
	
	// attribution text ...
	
	y += BUTTON_SIZE.height + SPACE_BETWEEN_BUTTON_AND_TEXT;
	CGRect attFrame = (CGRect){{x, y}, {BUTTON_SIZE.width, TEXT_HEIGHT}};
	
	UIView *attributionView = [[UIView alloc] initWithFrame:attFrame];
	attributionView.layer.compositingFilter = CONTENT_FILTER;
	
	self.attributionView = attributionView;
	[view addSubview:self.attributionView];
	
	
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
	label.font = [UIFont systemFontOfSize:13.0f];
	label.textAlignment = NSTextAlignmentLeft;
	label.textColor = TEXT_COLOR;
	label.text = @"Weather and stock information provided by";
	[label sizeToFit];
	
	[self.attributionView addSubview:label];
	
	
	
	// Yahoo logo ...
	
	NSString *yahooLogoPath = YAHOO_IMAGE_PATH;
	UIImage *yahooImage = [UIImage imageWithContentsOfFile:yahooLogoPath];
	yahooImage = [yahooImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
	
	UIImageView *yahooImageView = [[UIImageView alloc] initWithImage:yahooImage];
	yahooImageView.frame = (CGRect){{0, label.frame.size.height}, yahooImageView.frame.size};
	yahooImageView.tintColor = TEXT_COLOR;
	//	yahooImageView.layer.compositingFilter = kTextFilter;
	//DebugLog(@"yahoo logo: %@", yahooImageView);
	
	[self.attributionView addSubview:yahooImageView];
	
	
	self.view = view;
}

- (void)viewDidLoad {
	DebugLog0;
	
	[super viewDidLoad];
	
	[self applySettings];
	[self hideButtonIfLocked];
	
	// >>>>> need to update Widget Height
	
}

- (void)hostWillPresent {
	DebugLog0;
	
	[self hideButtonIfLocked];
	
	// hide the separator if button isn't showing
	if (self.attributionView.hidden && self.button.hidden) {
		DebugLog(@"Should hide separator");
		self.separatorView.hidden = YES;
	} else {
		DebugLog(@"Should NOT hide separator");
		self.separatorView.hidden = NO;
	}
	

	
// >>>>> need to update Widget Height
//	
//	DebugLog(@"self.widgetHost=%@", self.widgetHost);
//
//	Class $SBNotificationCenterController = NSClassFromString(@"SBNotificationCenterController");
//	SBNotificationCenterController *ncc = [$SBNotificationCenterController sharedInstance];
//	DebugLog(@"NC controller = %@", ncc);
//	
//	DebugLog(@"preferred size=%@", NSStringFromCGSize(self.preferredViewSize));
//	
//	//[ncc widget:self.widgetHost didUpdatePreferredSize:self.preferredViewSize];
//	//[ncc widget:self didUpdatePreferredSize:self.preferredViewSize];
//	
//	[self __requestPreferredViewSizeWithReplyHandler:nil];

	
//  DebugLog(@"widgetHost.delegate=%@", [self.widgetHost delegate]);
//  [[[self widgetHost] delegate] widget:[self widgetHost] didUpdatePreferredSize:[self preferredViewSize]];
	
	
	[super hostWillPresent];
}

//

- (void)applySettings {
	DebugLog0;
	
	NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Preferences/com.sticktron.notific8.plist"];
	NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:path];
	
	if (settings) {
		
		if (self.attributionView) {
			
			// apply Hide Text setting
			self.attributionView.hidden = [settings[@"HideText"] boolValue];
			
			// TODO >>>>> widget height needs update
		}
	}
}

- (void)hideButtonIfLocked {
	DebugLog0;
	
	if (!self.isViewLoaded) {
		DebugLog(@"view hasn't loaded");
		return;
	}
	
	if ([(SpringBoard *)[UIApplication sharedApplication] isLocked]) {
		DebugLog(@"Device is locked");
		
		self.button.hidden = YES;
		self.buttonBGView.hidden = YES;
		
	} else {
		DebugLog(@"Device is NOT locked");
		
		self.button.hidden = NO;
		self.buttonBGView.hidden = NO;
	}
	
	// re-position the attribution view (based on the button's visibility)
	if (self.button.hidden) {
		CGRect frame = self.attributionView.frame;
		frame.origin.y = self.button.frame.origin.y;
		self.attributionView.frame = frame;
	} else {
		CGRect frame = self.attributionView.frame;
		frame.origin.y = self.button.frame.origin.y + BUTTON_SIZE.height + SPACE_BETWEEN_BUTTON_AND_TEXT;
		self.attributionView.frame = frame;
	}
	
	// TODO >>>>> widget height needs update
}

- (void)highlight:(id)sender {
	self.button.backgroundColor = BUTTON_COLOR_ON;
}

- (void)unhighlight:(id)sender {
	self.button.backgroundColor = BUTTON_COLOR;
}

- (void)jump:(id)sender {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=NOTIFICATIONS_ID"]];
	[self unhighlight:nil];
}

@end

