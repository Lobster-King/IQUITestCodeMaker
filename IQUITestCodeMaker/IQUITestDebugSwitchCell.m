//
//  IQUITestDebugSwitchCell.m
//  IQUITestCodeMaker
//
//  Created by lobster on 2018/8/6.
//  Copyright © 2018年 lobster. All rights reserved.
//

#import "IQUITestDebugSwitchCell.h"
#import "IQUITestDebugSwitchModel.h"

@interface IQUITestDebugSwitch : UISwitch

@end

@implementation IQUITestDebugSwitch

@end

@interface IQUITestDebugSwitchCell ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) IQUITestDebugSwitch *stopRecord;
@property (nonatomic, strong) IQUITestDebugSwitchModel *swModel;

@end

@implementation IQUITestDebugSwitchCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setUpSubviews];
    }
    return self;
}

- (void)setUpSubviews {
    self.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.stopRecord];
}

- (void)stopSwitchClick:(UISwitch*)sw {
    [self.swModel handleSwitchState:sw.isOn withCallBack:^{
        /*刷新脚本section*/
        if (self.delegate && [self.delegate respondsToSelector:@selector(reordControlStateHasChanged)]) {
            [self.delegate reordControlStateHasChanged];
        }
    }];
}

- (void)updateViewWithViewModel:(IQUITestDebugSwitchModel *)model {
    self.swModel = model;
    self.titleLabel.text = model.title;
    self.stopRecord.on = model.isSwitchOn;
}

#pragma mark--Getters & Setters--
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(12, 2, ([[UIScreen mainScreen] bounds].size.width) - 80, 40)];
        _titleLabel.font = [UIFont systemFontOfSize:15];
        _titleLabel.textColor = [UIColor blackColor];
    }
    return _titleLabel;
}

- (IQUITestDebugSwitch *)stopRecord {
    if (!_stopRecord) {
        _stopRecord = [[IQUITestDebugSwitch alloc]initWithFrame:CGRectMake([[UIScreen mainScreen] bounds].size.width - 12 - 50, 5, 50, 40)];
        [_stopRecord addTarget:self action:@selector(stopSwitchClick:) forControlEvents:UIControlEventTouchUpInside];
        _stopRecord.on = NO;
    }
    return _stopRecord;
}

@end
