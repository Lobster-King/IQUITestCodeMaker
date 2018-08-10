//
//  IQUITestDebugServerInfoCell.h
//  IQUITestCodeMaker
//
//  Created by lobster on 2018/8/7.
//  Copyright © 2018年 lobster. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IQUITestDebugServerInfoModel;
@interface IQUITestDebugServerInfoCell : UITableViewCell

- (void)updateViewWithViewModel:(IQUITestDebugServerInfoModel *)model;

@end
