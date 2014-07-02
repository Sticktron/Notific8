//
//  Notific8
//  Created by Sticktron in 2014.
//
//	NewAttributionWidget is an iOS 8-styled replacement for the iOS 7 widget.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Headers/SpringBoardUIServices/_SBUIWidgetViewController.h"

@class SBNotificationCenterSeparatorView;

@interface NewAttributionWidget : _SBUIWidgetViewController
@property (nonatomic, strong) UIButton *button;
@property (nonatomic, strong) UIView *buttonBGView;
@property (nonatomic, strong) UIView *attributionView;
@property (nonatomic, strong) SBNotificationCenterSeparatorView *separatorView;

- (void)applySettings;
- (void)hideButtonIfLocked;
- (void)highlight:(id)sender;
- (void)unhighlight:(id)sender;
- (void)jump:(id)sender;

@end
