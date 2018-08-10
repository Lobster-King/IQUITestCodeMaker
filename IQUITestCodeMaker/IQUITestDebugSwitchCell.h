//
//  IQUITestDebugSwitchCell.h
//  IQUITestCodeMaker
//
//  Created by lobster on 2018/8/6.
//  Copyright © 2018年 lobster. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IQUITestDebugSwitchModel;

@protocol IQUITestDebugSwitchDelegate <NSObject>

- (void)reordControlStateHasChanged;

@end

@interface IQUITestDebugSwitchCell : UITableViewCell

@property (nonatomic, weak) id<IQUITestDebugSwitchDelegate>delegate;

- (void)updateViewWithViewModel:(IQUITestDebugSwitchModel *)model;

@end
