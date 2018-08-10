//
//  IQUITestDebugServerInfoModel.h
//  IQUITestCodeMaker
//
//  Created by lobster on 2018/8/6.
//  Copyright © 2018年 lobster. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IQUITestDebugServerInfoModel : NSObject

@property (nonatomic, copy, readonly) NSString *serverUrl;

+ (IQUITestDebugServerInfoModel *)viewModelWithServer:(id)server;

@end
