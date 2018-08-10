//
//  IQUITestDebugKeyValueModel.m
//  IQUITestCodeMaker
//
//  Created by lobster on 2018/8/6.
//  Copyright © 2018年 lobster. All rights reserved.
//

#import "IQUITestDebugKeyValueModel.h"

@class IQAppiumCapabilities;

static NSString *const kCapabilitiesKey = @"kCapabilitiesKey";

@interface IQUITestDebugKeyValueModel ()

@property (nonatomic, copy, readwrite) NSArray *kvArray;

@end

@interface IQUITestDebugKVModel ()

@property (nonatomic, copy, readwrite) NSString *title;
@property (nonatomic, copy, readwrite) NSString *placeholder;

@end

@implementation IQUITestDebugKeyValueModel

+ (IQUITestDebugKeyValueModel *)viewModelWithCap:(id)cap {
    
    NSMutableArray *kvArray = [NSMutableArray array];
    NSDictionary *localCap = [[NSUserDefaults standardUserDefaults] objectForKey:kCapabilitiesKey];
    for (NSString *key in localCap.allKeys) {
        IQUITestDebugKVModel *model = [[IQUITestDebugKVModel
                                         alloc]init];
        model.title = key;
        model.placeholder = localCap[key];
        [kvArray addObject:model];
        
    }
    
    IQUITestDebugKeyValueModel *model = [[IQUITestDebugKeyValueModel alloc]init];
    model.kvArray = [kvArray copy];
    return model;
}

- (void)updateKVModelArray {
    NSMutableArray *kvArray = [NSMutableArray array];
    NSDictionary *localCap = [[NSUserDefaults standardUserDefaults] objectForKey:kCapabilitiesKey];
    for (NSString *key in localCap.allKeys) {
        IQUITestDebugKVModel *model = [[IQUITestDebugKVModel
                                        alloc]init];
        model.title = key;
        model.placeholder = localCap[key];
        [kvArray addObject:model];
    }
    self.kvArray = [kvArray copy];
}

@end

@implementation IQUITestDebugKVModel

@end
