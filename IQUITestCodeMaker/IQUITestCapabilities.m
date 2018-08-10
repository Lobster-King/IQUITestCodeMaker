//
//  IQUITestCapabilities.m
//  IQUITestCodeMaker
//
//  Created by lobster on 2018/8/4.
//  Copyright © 2018年 lobster. All rights reserved.
//

#import "IQUITestCapabilities.h"
#import <UIKit/UIKit.h>
#import <objc/runtime.h>

static NSString *const kCapabilitiesKey = @"kCapabilitiesKey";

@implementation IQUITestCapabilities

- (instancetype)init {
    if (self = [super init]) {
        _driverType = IQUITestDriverAppium;
        /*
         1.本地有则取本地的cap。
         2.本地没有则用默认的。
         */
        
        NSDictionary *localCapDic = [[NSUserDefaults standardUserDefaults] objectForKey:kCapabilitiesKey];
        if (localCapDic) {
            IQAppiumCapabilities *localCap = [IQAppiumCapabilities new];
            for (NSString *key in localCapDic.allKeys) {
                [localCap setValue:localCapDic[key] forKey:key];
            }
            self.appiumCap = localCap;
        } else {
            IQAppiumCapabilities *cap = [IQAppiumCapabilities new];
            self.appiumCap  = cap;
        }
        _macacaCap  = nil;
    }
    return self;
}

- (void)setAppiumCap:(IQAppiumCapabilities *)appiumCap {
    if (appiumCap) {
        _appiumCap = appiumCap;
    }
    /*更新本地缓存
     1.将model转换成NSDictonary存入本地。
     */
    NSDictionary *cacheCap = [self convertModelToDict:_appiumCap];
    [[NSUserDefaults standardUserDefaults] setObject:cacheCap forKey:kCapabilitiesKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSDictionary *)appiumCapFromCache {
    NSDictionary *localCapDic = [[NSUserDefaults standardUserDefaults] objectForKey:kCapabilitiesKey];
    return localCapDic;
}

/*只能处理简单属性*/
- (NSDictionary *)convertModelToDict:(NSObject *)object {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    unsigned int count;
    objc_property_t *propertyList = class_copyPropertyList([object class], &count);
    
    for (int i = 0; i < count; i++) {
        objc_property_t property = propertyList[i];
        const char *cName = property_getName(property);
        NSString *name = [NSString stringWithUTF8String:cName];
        [dic setValue:[object valueForKey:name] forKey:name];
    }
    
    return [dic copy];
}

@end

@implementation IQAppiumCapabilities : NSObject

- (instancetype)init {
    if (self = [super init]) {
        _appiumVersion      = @"1.8.1";
        _platformName       = @"iOS";
        _platformVersion    = [UIDevice currentDevice].systemVersion;
        _deviceName         = @"iPhone X";
        NSString *bundleName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"];
        _app                = [NSString stringWithFormat:@"/Users/lobster/Desktop/%@.app",bundleName];
        _serverAddress      = @"127.0.0.1";
        _serverPort         = @"4723";
        _appiumLanguage     = @"Ruby";
        _autoAcceptAlerts   = @"1";
        _showIOSLog         = @"0";
        _interKeyDelay      = @"0";
        _waitTime           = @"10";
        _automationName     = @"XCUITest";
    }
    return self;
}

@end

@implementation IQMacacaCapabilities : NSObject


@end
