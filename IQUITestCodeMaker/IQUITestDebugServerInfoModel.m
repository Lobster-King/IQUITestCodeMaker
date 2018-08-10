//
//  IQUITestDebugServerInfoModel.m
//  IQUITestCodeMaker
//
//  Created by lobster on 2018/8/6.
//  Copyright © 2018年 lobster. All rights reserved.
//

#import "IQUITestDebugServerInfoModel.h"
#import "IQUITestCodeGenerator.h"

@interface IQUITestDebugServerInfoModel ()

@property (nonatomic, copy, readwrite) NSString *serverUrl;

@end

@implementation IQUITestDebugServerInfoModel

+ (IQUITestDebugServerInfoModel *)viewModelWithServer:(id)server {
    IQUITestDebugServerInfoModel *infoModel = [[IQUITestDebugServerInfoModel alloc]init];
    infoModel.serverUrl = [IQUITestCodeGenerator sharePersistent].webServer.serverURL.absoluteString;
    return infoModel;
}

@end
