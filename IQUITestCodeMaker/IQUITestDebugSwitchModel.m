//
//  IQUITestDebugSwitchModel.m
//  IQUITestCodeMaker
//
//  Created by lobster on 2018/8/6.
//  Copyright © 2018年 lobster. All rights reserved.
//

#import "IQUITestDebugSwitchModel.h"
#import "IQUITestCodeGenerator.h"
#import "IQUITestOperationEvent.h"
#import "IQUITestCodeMakerFactory.h"

static NSString *const kCapabilitiesKey = @"kCapabilitiesKey";

@interface IQUITestDebugSwitchModel ()

@property (nonatomic, copy, readwrite) NSString *title;

@end

@implementation IQUITestDebugSwitchModel

+ (IQUITestDebugSwitchModel *)viewModelWithState:(BOOL)state {
    IQUITestDebugSwitchModel *model = [[IQUITestDebugSwitchModel alloc]init];
    model.title = @"重新开启录制会清除上次缓存脚本";
    IQUITestCodeGenerator *persistent = [IQUITestCodeGenerator sharePersistent];
    IQUITestOperationEvent *op = persistent.factory.eventQueue.lastObject;
    if (op && (op.eventType != IQEventEndCode)) {
        model.swOn = YES;
    } else {
        model.swOn = NO;
    }
    return model;
}

- (void)updateSwitchModel {
    IQUITestCodeGenerator *persistent = [IQUITestCodeGenerator sharePersistent];
    IQUITestOperationEvent *op = persistent.factory.eventQueue.lastObject;
    if (op && (op.eventType != IQEventEndCode)) {
        self.swOn = YES;
    } else {
        self.swOn = NO;
    }
}

- (void)handleSwitchState:(BOOL)state withCallBack:(IQHandleSwitchBlock)callBack {
    IQUITestCodeGenerator *persistent = [IQUITestCodeGenerator sharePersistent];
    [persistent handleRecordControlEventWithState:state];
    
    if (callBack) {
        callBack();
    }
}

@end
