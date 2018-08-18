//
//  IQUITestDebugKeyValueCell.m
//  IQUITestCodeMaker
//
//  Created by lobster on 2018/8/6.
//  Copyright © 2018年 lobster. All rights reserved.
//

#import "IQUITestDebugKeyValueCell.h"

static NSString *const kMobileConfigUrl = @"https://www.pgyer.com/udid";

@interface IQUIRightBarButton : UIButton

@end

@implementation IQUIRightBarButton


@end

@interface IQUITestDebugKeyValueCell ()<UITextFieldDelegate>

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UITextField *textFiled;
@property (nonatomic, strong) IQUITestDebugKVModel *kvModel;
@property (nonatomic, strong) IQUIRightBarButton *rightBarButton;

@end

@implementation IQUITestDebugKeyValueCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setUpSubviews];
    }
    return self;
}

- (void)setUpSubviews {
    self.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.textFiled];
    [self.contentView addSubview:self.rightBarButton];
}

- (void)updateViewWithViewModel:(IQUITestDebugKVModel *)viewModel {
    self.kvModel = viewModel;
    self.titleLabel.text = viewModel.title;
    self.textFiled.placeholder = viewModel.placeholder;
    if ([viewModel.title isEqualToString:@"appiumVersion"] || [viewModel.title isEqualToString:@"platformName"] || [viewModel.title isEqualToString:@"automationName"]) {
        [self.textFiled setEnabled:NO];
    }
    
    if ([viewModel.title isEqualToString:@"udid"]){
        self.rightBarButton.hidden = NO;
    } else {
        self.rightBarButton.hidden = YES;
    }
}

- (void)rightBarButtonClicked {
    NSURL *udidUrl = [NSURL URLWithString:kMobileConfigUrl];
    [[UIApplication sharedApplication] openURL:udidUrl];
}

#pragma mark--UITextFiledDelegate--
- (void)textFieldDidEndEditing:(UITextField *)textField {
    /*修改了cap之后，要更新本地cap缓存，并重新生成脚本*/
    /*刷新脚本section*/
    if (self.delegate && [self.delegate respondsToSelector:@selector(capMapHasChanged)]) {
        [self.delegate capMapHasChanged];
    }
}

#pragma mark--Getters & Setters--
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(12, 2, ([[UIScreen mainScreen] bounds].size.width)*0.33 - 12, 40)];
        _titleLabel.font = [UIFont systemFontOfSize:15];
        _titleLabel.textColor = [UIColor blackColor];
    }
    return _titleLabel;
}
- (UITextField *)textFiled {
    if (!_textFiled) {
        _textFiled = [[UITextField alloc]initWithFrame:CGRectMake(([[UIScreen mainScreen] bounds].size.width)*0.33 + 12, 2, ([[UIScreen mainScreen] bounds].size.width)*0.66 - 12, 40)];
        _textFiled.font = [UIFont systemFontOfSize:15];
        _textFiled.delegate = self;
    }
    return _textFiled;
}
- (IQUIRightBarButton *)rightBarButton {
    if (!_rightBarButton){
        _rightBarButton = [IQUIRightBarButton buttonWithType:UIButtonTypeDetailDisclosure];
        _rightBarButton.hidden = YES;
        _rightBarButton.frame = CGRectMake([[UIScreen mainScreen] bounds].size.width - 60, 2, 60, 40);
        [_rightBarButton addTarget:self action:@selector(rightBarButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _rightBarButton;
}

@end
