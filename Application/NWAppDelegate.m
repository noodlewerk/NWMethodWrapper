//
//  NWAppDelegate.m
//  WrapperApp
//
//  Created by Martijn Thé on 10/30/11.
//  Copyright (c) 2011 Noodlewerk BV. All rights reserved.
//

#import "NWAppDelegate.h"
#import "NWMethodWrapper.h"

@implementation NWAppDelegateBase
@synthesize window = _window;

- (void)boogie:(id)sender {
    self.window.backgroundColor = [UIColor colorWithHue:((CGFloat)rand() / (CGFloat)RAND_MAX) saturation:1.0f brightness:0.5f alpha:1.0f];
}
@end


@implementation NWAppDelegate {
    NWMethodWrapper* wrapper;
    UIButton* wrapperButton;
    UITextView* logTextView;
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    wrapperButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [wrapperButton setBounds:CGRectMake(0, 0, 300, 44)];
    [wrapperButton setTitle:@"wrap" forState:UIControlStateNormal];
    [wrapperButton addTarget:self action:@selector(toggle) forControlEvents:UIControlEventTouchUpInside];
    [self.window addSubview:wrapperButton];
    CGPoint center = self.window.center;
    wrapperButton.center = center;
    
    UIButton* boogieButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [boogieButton setBounds:CGRectMake(0, 0, 300, 44)];
    [boogieButton setTitle:@"boogie!" forState:UIControlStateNormal];
    [boogieButton addTarget:self action:@selector(boogie:) forControlEvents:UIControlEventTouchUpInside];
    [self.window addSubview:boogieButton];
    center.y -= 64.f;
    boogieButton.center = center;
    NSLog(@"%p", boogieButton);
    
    logTextView = [[[UITextView alloc] initWithFrame:CGRectMake(10, 30, 300, 100)] autorelease];
    logTextView.font = [UIFont systemFontOfSize:9.0];
    logTextView.text = @"log..\n";
    [self.window addSubview:logTextView];
    
    return YES;
}

- (void)toggle {
    if (wrapper) {
        [wrapper release];
        wrapper = nil;
        [wrapperButton setTitle:@"wrap" forState:UIControlStateNormal];
    } else {
        ImpBlock beforeBlock = (ImpBlock)^void(id _self, id sender) {
            NSString* oldText = logTextView.text;
            logTextView.text = [oldText stringByAppendingFormat:@"%.01f] old: %@\n", [NSDate timeIntervalSinceReferenceDate], self.window.backgroundColor];
        };
        
        ImpBlock afterBlock = (ImpBlock)^void(id _self, id sender) {
            NSString* oldText = logTextView.text;
            logTextView.text = [oldText stringByAppendingFormat:@"%.01f] new: %@\n", [NSDate timeIntervalSinceReferenceDate], self.window.backgroundColor];
        };
        
        // If the method cannot be found in the class, the base classes will be searched for the method
        wrapper = [[NWMethodWrapper wrap:[NWAppDelegate class] instanceMethodForSelector:@selector(boogie:) before:beforeBlock after:afterBlock] retain];
        
        [wrapperButton setTitle:@"unwrap" forState:UIControlStateNormal];
    }
}

- (void)boogie:(id)sender {
    // just to test out if super still works
    [super boogie:sender];
    NSLog(@"boogie!");
}

@end
