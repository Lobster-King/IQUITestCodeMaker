//
//  UIApplication+IQGlobalHook.m
//  IQUITestCodeMaker
//
//  Created by lobster on 2018/8/4.
//  Copyright © 2018年 lobster. All rights reserved.
//

#import "UIApplication+IQGlobalHook.h"
#import "IQUITestCodeMakerGenerator.h"
#import "IQUITestCodeMaker.h"
#import "IQUITestProtocol.h"

@implementation UIApplication (IQGlobalHook)

+ (void)load {
#if IQ_CODEMAKER_ENABLED
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        IQUITestCodeMakerGenerator *persistent = [IQUITestCodeMakerGenerator sharePersistent];
        [persistent hook];
        /*start web server*/
        if ([persistent.webServer start]) {
            NSLog(@"%@",[NSString stringWithFormat:NSLocalizedString(@"GCDWebServer running locally on port %i", nil), (int)persistent.webServer.port]);
        } else {
            NSLog(@"GCDWebServer not running!");
        }
        /*add observer*/
        [[NSNotificationCenter defaultCenter] addObserver:persistent selector:@selector(handleApplicationDidFinishLaunching) name:UIApplicationDidFinishLaunchingNotification object:nil];
//        [[NSNotificationCenter defaultCenter]addObserver:persistent selector:@selector(handleApplicationWillResignActiveNotification) name:UIApplicationWillResignActiveNotification object:nil];
//        [[NSNotificationCenter defaultCenter]addObserver:persistent selector:@selector(handleApplicationWillTerminateNotification) name:UIApplicationWillTerminateNotification object:nil];
//        [[NSNotificationCenter defaultCenter]addObserver:persistent selector:@selector(handleApplicationDidReceiveMemoryWarningNotification) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
        
    });
    
#endif
}


@end
