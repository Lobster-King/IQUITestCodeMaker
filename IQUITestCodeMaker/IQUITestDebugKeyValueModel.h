//
//  IQUITestDebugKeyValueModel.h
//  IQUITestCodeMaker
//
//  Created by lobster on 2018/8/6.
//  Copyright © 2018年 lobster. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IQUITestDebugKVModel;

@interface IQUITestDebugKeyValueModel : NSObject

@property (nonatomic, copy, readonly) NSArray<IQUITestDebugKVModel*> *kvArray;

+ (IQUITestDebugKeyValueModel *)viewModelWithCap:(id)cap;
- (void)updateKVModelArray;

@end

@interface IQUITestDebugKVModel : NSObject

@property (nonatomic, copy, readonly) NSString *title;
@property (nonatomic, copy, readonly) NSString *placeholder;

@end
