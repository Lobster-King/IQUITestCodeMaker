//
//  IQUITestCodeMakerCapabilities.h
//  IQUITestCodeMaker
//
//  Created by lobster on 2018/8/4.
//  Copyright © 2018年 lobster. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger,IQUITestDriverType ) {
    IQUITestDriverAppium = 0,/*default*/
    IQUITestDriverMacaca = 1,/*support soon*/
};

@class IQAppiumCapabilities,IQMacacaCapabilities;

@interface IQUITestCodeMakerCapabilities : NSObject

@property (nonatomic, assign) IQUITestDriverType    driverType;
@property (nonatomic, strong) IQAppiumCapabilities  *appiumCap;
@property (nonatomic, strong) IQMacacaCapabilities  *macacaCap;

@end

@interface IQAppiumCapabilities : NSObject

@property (nonatomic, copy) NSString *appiumVersion;/*appium version 1.0*/
@property (nonatomic, copy) NSString *platformName;/*iOS*/
@property (nonatomic, copy) NSString *platformVersion;/*9.3~11.4*/
@property (nonatomic, copy) NSString *deviceName;/*iPhone 6s ..*/
#warning do not use it in relase mode ！！！
@property (nonatomic, copy) NSString *udid;/*device id*/
@property (nonatomic, copy) NSString *app;/*app path*/
@property (nonatomic, copy) NSString *serverAddress;/*127.0.0.1 default*/
@property (nonatomic, copy) NSString *serverPort;/*4723 default*/
@property (nonatomic, copy) NSString *appiumLanguage;/*Ruby default*/
@property (nonatomic, copy) NSString *autoAcceptAlerts;/*false default*/
@property (nonatomic, copy) NSString *interKeyDelay;/*click delay*/
@property (nonatomic, copy) NSString *showIOSLog;/*false default*/
@property (nonatomic, copy) NSString *waitTime;/*find element timeout,10s default*/
@property (nonatomic, copy) NSString *automationName;/*XCUITest default*/

@end

@interface IQMacacaCapabilities : NSObject

@property (nonatomic, copy) NSString *macacaLanguage;/*Ruby default*/

@end
