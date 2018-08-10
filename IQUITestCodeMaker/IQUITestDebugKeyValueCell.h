//
//  IQUITestDebugKeyValueCell.h
//  IQUITestCodeMaker
//
//  Created by lobster on 2018/8/6.
//  Copyright © 2018年 lobster. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IQUITestDebugKeyValueModel.h"
@class IQUITestDebugKVModel;

@protocol IQUITestDebugKeyValueDelegate <NSObject>

- (void)capMapHasChanged;

@end

@interface IQUITestDebugKeyValueCell : UITableViewCell

@property (nonatomic, weak) id<IQUITestDebugKeyValueDelegate>delegate;

- (void)updateViewWithViewModel:(IQUITestDebugKVModel *)viewModel;

@end
