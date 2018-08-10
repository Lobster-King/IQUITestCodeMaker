//
//  IQUITestCodeMakerFactory.h
//  IQUITestCodeMaker
//
//  Created by lobster on 2018/8/4.
//  Copyright © 2018年 lobster. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IQUITestCodeMakerCapabilities,IQUITestOperationEvent;

@interface IQUITestCodeMakerFactory : NSObject

@property (nonatomic, strong, readonly) IQUITestCodeMakerCapabilities *cap;
@property (nonatomic, copy, readonly) NSString *scriptPath;
@property (nonatomic, assign) NSInteger eventIndex;
@property (nonatomic, strong) NSMutableArray <IQUITestOperationEvent*>*eventQueue;
@property (nonatomic, assign) BOOL isConverting;/*是否正在进行代码转换*/
@property (nonatomic, assign) NSInteger templateCodeFlag;
@property (nonatomic, assign) NSInteger endCodeFlag;

+ (IQUITestCodeMakerFactory *)handleTaskUnit;
+ (IQUITestCodeMakerFactory *)handleTaskUnitWithCap:(IQUITestCodeMakerCapabilities *)cap;
- (void)produceCodeWithOperationEvent:(IQUITestOperationEvent *)op;
- (void)storeProductCode:(NSString *)code;
- (void)convertEvetQueueToScript;

@end
