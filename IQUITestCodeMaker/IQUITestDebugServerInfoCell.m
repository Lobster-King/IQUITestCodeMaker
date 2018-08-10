//
//  IQUITestDebugServerInfoCell.m
//  IQUITestCodeMaker
//
//  Created by lobster on 2018/8/7.
//  Copyright © 2018年 lobster. All rights reserved.
//

#import "IQUITestDebugServerInfoCell.h"
#import "IQUITestDebugServerInfoModel.h"

@interface IQUITestDebugServerInfoCell ()

@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation IQUITestDebugServerInfoCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setUpSubviews];
    }
    return self;
}

- (void)setUpSubviews {
    self.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:self.titleLabel];
}

- (void)updateViewWithViewModel:(IQUITestDebugServerInfoModel *)model {
    self.titleLabel.text = model.serverUrl;
}

#pragma mark--Getters & Setters--
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(12, 2, ([[UIScreen mainScreen] bounds].size.width) - 24, 40)];
        _titleLabel.font = [UIFont systemFontOfSize:15];
        _titleLabel.textColor = [UIColor blackColor];
    }
    return _titleLabel;
}

@end
