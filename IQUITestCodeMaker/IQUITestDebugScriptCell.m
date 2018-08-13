//
//  IQUITestDebugScriptCell.m
//  IQUITestCodeMaker
//
//  Created by lobster on 2018/8/6.
//  Copyright © 2018年 lobster. All rights reserved.
//

#import "IQUITestDebugScriptCell.h"
#import "IQUITestDebugScriptModel.h"
#import "IQUITestCodeMakerGenerator.h"
#import "IQUITestCodeMakerFactory.h"
#import "IQUITestCodeMakerCapabilities.h"

@interface IQUITestDebugSegmentControl : UISegmentedControl

@end

@implementation IQUITestDebugSegmentControl

@end

@interface IQUITestDebugScriptCell ()

@property (nonatomic, strong) IQUITestDebugSegmentControl *segmentControl;
@property (nonatomic, strong) UITextView *codeText;
@property (nonatomic, strong) NSArray *itemsArray;
@property (nonatomic, strong) IQUITestDebugScriptModel *sciptModel;

@end

@implementation IQUITestDebugScriptCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setUpSubviews];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setUpSubviews {
    self.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:self.segmentControl];
    [self.contentView addSubview:self.codeText];
}

- (void)updateViewWithViewModel:(IQUITestDebugScriptModel *)model {
    self.sciptModel = model;
    
    IQUITestCodeMakerGenerator *persistent = [IQUITestCodeMakerGenerator sharePersistent];
    NSInteger selectIndex = [self.itemsArray indexOfObject:persistent.factory.cap.appiumCap.appiumLanguage];
    self.segmentControl.selectedSegmentIndex = selectIndex;
    
    NSString *script = [NSString stringWithContentsOfFile:persistent.factory.scriptPath encoding:NSUTF8StringEncoding error:NULL];
    self.codeText.text = script;
}

- (void)selectItem:(IQUITestDebugSegmentControl *)segmentControl {
    /*
     1.保存当前的event queue。
     2.重新实力化cap。
     3.重新实力化脚本工厂。
     4.进行脚本转换。
     */
    [self.sciptModel handleSegmentControlSelected:segmentControl.selectedSegmentIndex withCallBack:^{
        [self reloadCodeText];
        /*刷新cap的section*/
        if (self.delegate && [self.delegate respondsToSelector:@selector(scriptCodeHasGenerated)]) {
            [self.delegate scriptCodeHasGenerated];
        }
    }];
}

- (void)reloadCodeText {
    IQUITestCodeMakerGenerator *persistent = [IQUITestCodeMakerGenerator sharePersistent];
    NSString *script = [NSString stringWithContentsOfFile:persistent.factory.scriptPath encoding:NSUTF8StringEncoding error:NULL];
    self.codeText.text = script;
}

#pragma mark--Getters & Setters--
- (IQUITestDebugSegmentControl *)segmentControl {
    if (!_segmentControl) {
        _segmentControl = [[IQUITestDebugSegmentControl alloc]initWithItems:self.itemsArray];
        _segmentControl.frame = CGRectMake(12, 5, [[UIScreen mainScreen] bounds].size.width - 24, 30);
        _segmentControl.selectedSegmentIndex = 0;/*取用户选择的语言*/
        [_segmentControl addTarget:self action:@selector(selectItem:) forControlEvents:UIControlEventValueChanged];
    }
    return _segmentControl;
}

- (UITextView *)codeText {
    if (!_codeText) {
        _codeText = [[UITextView alloc]initWithFrame:CGRectMake(12, 40, [[UIScreen mainScreen] bounds].size.width - 24, 300)];
        _codeText.backgroundColor = [UIColor clearColor];
        _codeText.font = [UIFont systemFontOfSize:13];
        _codeText.layer.cornerRadius = 5;
        _codeText.clipsToBounds = YES;
        _codeText.editable = NO;
    }
    return _codeText;
}

- (NSArray *)itemsArray {
    if (!_itemsArray) {
        _itemsArray = @[@"Ruby",@"Python",@"JSWdio",@"JSPromise",@"Java"];
    }
    return _itemsArray;
}

@end
