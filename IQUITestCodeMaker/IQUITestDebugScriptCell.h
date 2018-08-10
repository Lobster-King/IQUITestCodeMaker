//
//  IQUITestDebugScriptCell.h
//  IQUITestCodeMaker
//
//  Created by lobster on 2018/8/6.
//  Copyright © 2018年 lobster. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IQUITestDebugScriptModel;

@protocol IQUITestDebugScriptDelegate <NSObject>

- (void)scriptCodeHasGenerated;

@end

@interface IQUITestDebugScriptCell : UITableViewCell

@property (nonatomic, weak) id<IQUITestDebugScriptDelegate>delegate;

- (void)updateViewWithViewModel:(IQUITestDebugScriptModel *)model;

@end
