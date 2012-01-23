//
//  NWAppDelegate.h
//  WrapperApp
//
//  Created by Martijn Thé on 10/30/11.
//  Copyright (c) 2011 Noodlewerk BV. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NWAppDelegateBase : UIResponder
@property (strong, nonatomic) UIWindow *window;
@end

@interface NWAppDelegate : NWAppDelegateBase <UIApplicationDelegate>

@end
