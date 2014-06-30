//
//  Notific8
//  Created by Sticktron in 2014.
//
//	NewAttributionWidget is an iOS 8-styled replacement for the iOS 7 widget.
//
//

#define DEBUG_PREFIX @"🔶 [Notific8] "
#import "DebugLog.h"

#import "NewAttributionWidget.h"


#define BUTTON_BG_COLOR			[UIColor colorWithWhite:0.55f alpha:1.0f]
#define BUTTON_COLOR			[UIColor colorWithWhite:1.0f alpha:0.2f]
#define BUTTON_COLOR_ON			[UIColor colorWithWhite:0 alpha:0.2f]
#define TEXT_COLOR				[UIColor colorWithWhite:0.52f alpha:1.0f]
#define HEADER_FILTER			@"plusD"
#define CONTENT_FILTER			@"colorDodgeBlendMode"
#define YAHOO_IMAGE_PATH		@"/Library/PreferenceBundles/Notific8Settings.bundle/Yahoo!@2x.png"


static float kWidgetTopMargin = 32.5f;
static float kWidgetBottomMargin = 10.0f;

static float kButtonTopMargin = 27.5f;
static float kButtonBottomMargin = 18.0f;

static float kButtonWidth = 223.0f;
static float kButtonHeight = 28.0f;

static float kAttributionViewHeight = 60.0f;

NSString* MyLocalizedString(NSString *string);




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
//
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
	float height;
	float maxHeight = kWidgetTopMargin + kButtonTopMargin + kButtonHeight + kButtonBottomMargin + kAttributionViewHeight + kWidgetBottomMargin;
//	
//	// calculate height based on visible subviews...
//	
//	if (!self.button) {	// no view yet; use max height
		height =  maxHeight;
//		
//	} else {
//		if (self.button.hidden && self.attributionView.hidden) { // both hidden
//			height = kWidgetTopMargin + kWidgetBottomMargin;
//			
//		} else if (self.button.hidden) { // only button hidden
//			height = kWidgetTopMargin + kButtonTopMargin + kAttributionViewHeight + kWidgetBottomMargin;
//			
//		} else if (self.attributionView.hidden) { // only attribution view hidden
//			height = kWidgetTopMargin + kButtonTopMargin + kButtonHeight + kButtonBottomMargin;
//		} else {
//			height = maxHeight;
//		}
//	}
//	
	return CGSizeMake([[UIScreen mainScreen] bounds].size.width, height);
}

- (void)loadView {
	DebugLog0;
	
	UIView *view = [[UIView alloc] initWithFrame:(CGRect){CGPointZero, self.preferredViewSize}];
	view.clipsToBounds = YES;
	view.autoresizesSubviews = NO;
	view.backgroundColor = UIColor.clearColor;
	
	float x = (view.bounds.size.width - kButtonWidth) / 2.0f;
	
	
	// separator line ...
	
	CGRect sepFrame = CGRectMake(0, kWidgetTopMargin, self.preferredViewSize.width, 0.5f);
	Class $SBNotificationCenterSeparatorView = NSClassFromString(@"SBNotificationCenterSeparatorView");
	SBNotificationCenterSeparatorView *sepView = [[$SBNotificationCenterSeparatorView alloc]
												  initWithFrame:sepFrame mode:0];
	[view addSubview:sepView];
	
	
	// edit button & backing view ...
	
	CGRect buttonFrame = CGRectMake(x, kWidgetTopMargin + kButtonTopMargin, kButtonWidth, kButtonHeight);
	
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
	
	
	// attribution stuff ...
	
	CGRect attFrame;
	attFrame.origin = (CGPoint){x, self.button.frame.origin.y + kButtonHeight + kButtonBottomMargin};
	attFrame.size = (CGSize){self.button.frame.size.width, kAttributionViewHeight};
	
	UIView *attributionView = [[UIView alloc] initWithFrame:attFrame];
	attributionView.layer.compositingFilter = CONTENT_FILTER;
//	attributionView.backgroundColor = UIColor.blueColor;
	
	self.attributionView = attributionView;
	[view addSubview:self.attributionView];
	
	
	// ... weather ...
	
	UILabel *weatherLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	weatherLabel.font = [UIFont systemFontOfSize:12.0f];
	weatherLabel.textAlignment = NSTextAlignmentLeft;
	weatherLabel.numberOfLines = 0;
	weatherLabel.textColor = TEXT_COLOR;
	weatherLabel.text = [NSString stringWithFormat:@"%@\n%@", @"Weather information provided by", @"The Weather Channel, LLC."];
	[weatherLabel sizeToFit];
	
	[self.attributionView addSubview:weatherLabel];
	
	
	// ... stocks ...
	
	UILabel *stocksLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 33.0f, 0, 0)];
	stocksLabel.font = [UIFont systemFontOfSize:12.0f];
	stocksLabel.textAlignment = NSTextAlignmentLeft;
	stocksLabel.textColor = TEXT_COLOR;
	stocksLabel.text = @"Stock information provided by";
	[stocksLabel sizeToFit];
	
	[self.attributionView addSubview:stocksLabel];
	
	
	// ... Yahoo logo ...
	
	NSString *yahooLogoPath = YAHOO_IMAGE_PATH;
	UIImage *yahooImage = [UIImage imageWithContentsOfFile:yahooLogoPath];
	yahooImage = [yahooImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
	
	UIImageView *yahooImageView = [[UIImageView alloc] initWithImage:yahooImage];
	CGRect yFrame = yahooImageView.frame;
	yFrame.origin.x = stocksLabel.frame.size.width + 2.0f;
	yFrame.origin.y = stocksLabel.frame.origin.y + 1.0f;
	yahooImageView.frame = yFrame;
	yahooImageView.tintColor = TEXT_COLOR;
	//	yahooImageView.layer.compositingFilter = kTextFilter;
	DebugLog(@"yahoo logo: %@", yahooImageView);
	
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
	
	
	
	// >>>>> need to update Widget Height
	
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

	
	//DebugLog(@"widgetHost.delegate=%@", [self.widgetHost delegate]);
	//[[[self widgetHost] delegate] widget:[self widgetHost] didUpdatePreferredSize:[self preferredViewSize]];
	
	
	[super hostWillPresent];
}

//

- (void)applySettings {
	DebugLog0;
	
	NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Preferences/com.sticktron.notific8.plist"];
	NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:path];
	
	if (settings) {
		// apply Hide Text setting
		if (self.attributionView) {
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
		frame.origin.y = self.button.frame.origin.y + kButtonHeight + kButtonBottomMargin;
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

