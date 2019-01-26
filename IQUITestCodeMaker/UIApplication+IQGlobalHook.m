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
#import "GCDWebServer.h"

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
        
        [[NSNotificationCenter defaultCenter] addObserver:persistent selector:@selector(handleApplicationDidFinishLaunching) name:UIApplicationDidFinishLaunchingNotification object:nil];
        
    });
    
#endif
}


@end
