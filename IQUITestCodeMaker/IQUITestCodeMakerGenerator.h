//
//  IQUITestCodeMakerGenerator.h
//  IQUITestCodeMaker
//
//  Created by lobster on 2018/8/4.
//  Copyright © 2018年 lobster. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IQUITestProtocol.h"

@class IQUITestCodeMakerFactory,GCDWebServer;

void IQRuntimeMethodExchange(Class aClass, SEL oldSEL, SEL newSEL);

@interface IQUITestCodeMakerGenerator : NSObject<IQUITestProtocol>

@property (nonatomic, strong, readonly) IQUITestCodeMakerFactory *factory;
@property (nonatomic, strong, readonly) GCDWebServer *webServer;

+ (instancetype)sharePersistent;
- (void)hook;
- (void)handleConvertTaskWithIdentifier:(NSString *)identifier;
- (void)handleCapChangeTaskWithKey:(NSString *)key value:(NSString *)value;
- (void)handleRecordControlEventWithState:(BOOL)state;

@end
