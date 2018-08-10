//
//  IQUITestProtocol.h
//  IQUITestCodeMaker
//
//  Created by lobster on 2018/8/4.
//  Copyright © 2018年 lobster. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol IQUITestProtocol <NSObject>

- (void)handleApplicationDidFinishLaunching;
- (void)handleApplicationWillResignActiveNotification;
- (void)handleApplicationWillTerminateNotification;
- (void)handleApplicationDidReceiveMemoryWarningNotification;

@end
