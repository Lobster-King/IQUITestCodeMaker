//
//  IQUITestDebugScriptModel.m
//  IQUITestCodeMaker
//
//  Created by lobster on 2018/8/6.
//  Copyright © 2018年 lobster. All rights reserved.
//

#import "IQUITestDebugScriptModel.h"
#import "IQUITestCodeMakerGenerator.h"
#import "IQUITestCodeMakerCapabilities.h"
#import "IQUITestCodeMakerFactory.h"

@interface IQUITestDebugScriptModel ()

@property (nonatomic, copy, readwrite) NSArray *codeTextArray;

@end

@implementation IQUITestDebugScriptModel

+ (IQUITestDebugScriptModel *)viewModelWithScript:(NSString *)scriptPath {
    IQUITestDebugScriptModel *model = [[IQUITestDebugScriptModel alloc]init];
    model.codeTextArray = @[@"asadadadadsadadadadasdadasdadadas",@"asadadadadsadadadadasdadasdadadas",@"asadadadadsadadadadasdadasdadadas"];
    return model;
}

- (void)handleSegmentControlSelected:(NSInteger)selectIndex withCallBack:(IQHandleScriptBlock)cabllBack {
    /*update local cap cache*/
    NSArray * items = @[@"Ruby",@"Python",@"JSWdio",@"JSPromise",@"Java"];
    IQUITestCodeMakerGenerator *persistent = [IQUITestCodeMakerGenerator sharePersistent];
    [persistent handleConvertTaskWithIdentifier:items[selectIndex]];
    
    if (cabllBack) {
        cabllBack();
    }
}

@end
