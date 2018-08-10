//
//  IQUITestDebugScriptModel.h
//  IQUITestCodeMaker
//
//  Created by lobster on 2018/8/6.
//  Copyright © 2018年 lobster. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^IQHandleScriptBlock)(void);

@interface IQUITestDebugScriptModel : NSObject

@property (nonatomic, copy, readonly) NSArray    *codeTextArray;

+ (IQUITestDebugScriptModel *)viewModelWithScript:(NSString *)scriptPath;

- (void)handleSegmentControlSelected:(NSInteger)selectIndex withCallBack:(IQHandleScriptBlock)cabllBack;

@end
