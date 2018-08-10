//
//  IQUITestDebugSwitchModel.h
//  IQUITestCodeMaker
//
//  Created by lobster on 2018/8/6.
//  Copyright © 2018年 lobster. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^IQHandleSwitchBlock)(void);

@interface IQUITestDebugSwitchModel : NSObject

@property (nonatomic, copy, readonly) NSString *title;
@property (nonatomic, assign,getter=isSwitchOn) BOOL swOn;

+ (IQUITestDebugSwitchModel *)viewModelWithState:(BOOL)state;
- (void)handleSwitchState:(BOOL)state withCallBack:(IQHandleSwitchBlock)callBack;
- (void)updateSwitchModel;

@end
