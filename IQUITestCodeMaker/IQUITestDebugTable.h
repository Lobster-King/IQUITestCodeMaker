//
//  IQUITestDebugTable.h
//  IQUITestCodeMaker
//
//  Created by lobster on 2018/8/6.
//  Copyright © 2018年 lobster. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^IQDebugBlock)(void);

@interface IQUITestDebugTable : UIView

@property (nonatomic, copy)IQDebugBlock debugBlock;

- (void)showDebugView;

@end
