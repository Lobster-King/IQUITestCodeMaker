//
//  IQUITestDebugTable.m
//  IQUITestCodeMaker
//
//  Created by lobster on 2018/8/6.
//  Copyright © 2018年 lobster. All rights reserved.
//

#import "IQUITestDebugTable.h"
#import "IQUITestDebugKeyValueModel.h"
#import "IQUITestDebugScriptModel.h"
#import "IQUITestDebugSwitchModel.h"
#import "IQUITestDebugServerInfoModel.h"
#import "IQUITestDebugKeyValueCell.h"
#import "IQUITestDebugSwitchCell.h"
#import "IQUITestDebugScriptCell.h"
#import "IQUITestCodeMakerGenerator.h"
#import "IQUITestDebugServerInfoCell.h"

@interface IQUITestDebugDismissButton : UIButton

@end

@implementation IQUITestDebugDismissButton


@end

@interface IQUITestDebugTable ()<UITableViewDelegate,UITableViewDataSource,IQUITestDebugKeyValueDelegate,IQUITestDebugSwitchDelegate,IQUITestDebugScriptDelegate>

@property (nonatomic, strong) IQUITestDebugDismissButton *dismissButton;
@property (nonatomic, strong) UITableView *debugTable;
@property (nonatomic, strong) UIImageView *blurImgv;
@property (nonatomic, strong) UIVisualEffectView *effectView;
@property (nonatomic, strong) NSMutableArray *dataArray;

@end

@implementation IQUITestDebugTable

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setUpSubviews];
    }
    return self;
}

- (void)setUpSubviews {
    self.blurImgv = [[UIImageView alloc]initWithFrame:self.bounds];
    self.blurImgv.image = [self imageWithScreenshot];
    [self addSubview:self.blurImgv];
    
    UIBlurEffect *beffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    self.effectView = [[UIVisualEffectView alloc]initWithEffect:beffect];
    self.effectView.frame = self.blurImgv.frame;
    [self addSubview:self.effectView];

    self.debugTable.tableHeaderView = self.dismissButton;
    [self addSubview:self.debugTable];
    [self.debugTable reloadData];
}

- (void)dismissDebugView {
    if (self.debugBlock) {
        self.debugBlock();
    }
    self.hidden = YES;
}

- (void)showDebugView {
    self.hidden = NO;
    [self.blurImgv removeFromSuperview];
    [self.effectView removeFromSuperview];
    
    self.blurImgv = [[UIImageView alloc]initWithFrame:self.bounds];
    self.blurImgv.image = [self imageWithScreenshot];
    [self insertSubview:self.blurImgv atIndex:0];
    
    UIBlurEffect *beffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    self.effectView = [[UIVisualEffectView alloc]initWithEffect:beffect];
    self.effectView.frame = self.blurImgv.frame;
    [self insertSubview:self.effectView atIndex:1];
    [self.debugTable reloadData];
}

- (UIImage *)imageWithScreenshot
{
    CGSize imageSize = CGSizeZero;
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (UIInterfaceOrientationIsPortrait(orientation))
        imageSize = [UIScreen mainScreen].bounds.size;
    else
        imageSize = CGSizeMake([UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
    
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    for (UIWindow *window in [[UIApplication sharedApplication] windows])
    {
        CGContextSaveGState(context);
        CGContextTranslateCTM(context, window.center.x, window.center.y);
        CGContextConcatCTM(context, window.transform);
        CGContextTranslateCTM(context, -window.bounds.size.width * window.layer.anchorPoint.x, -window.bounds.size.height * window.layer.anchorPoint.y);
        if (orientation == UIInterfaceOrientationLandscapeLeft)
        {
            CGContextRotateCTM(context, M_PI_2);
            CGContextTranslateCTM(context, 0, -imageSize.width);
        }
        else if (orientation == UIInterfaceOrientationLandscapeRight)
        {
            CGContextRotateCTM(context, -M_PI_2);
            CGContextTranslateCTM(context, -imageSize.height, 0);
        } else if (orientation == UIInterfaceOrientationPortraitUpsideDown) {
            CGContextRotateCTM(context, M_PI);
            CGContextTranslateCTM(context, -imageSize.width, -imageSize.height);
        }
        if ([window respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)]){
            [window drawViewHierarchyInRect:window.bounds afterScreenUpdates:YES];
        }else{
            [window.layer renderInContext:context];
        }
        CGContextRestoreGState(context);
    }
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    NSData *data = UIImagePNGRepresentation(image);
    UIImage *returnImage = [UIImage imageWithData:data];
    return returnImage;
}

#pragma mark--UITableViewDelegate--
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataArray.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    id sectionModel = self.dataArray[section];
    if ([sectionModel isKindOfClass:[IQUITestDebugKeyValueModel class]]) {
        return @"设置Desired Capabilities";
    } else if ([sectionModel isKindOfClass:[IQUITestDebugServerInfoModel class]]) {
        return @"打开下面链接查看或导出脚本";
    } else if ([sectionModel isKindOfClass:[IQUITestDebugSwitchModel class]]) {
        return @"录制控制";
    } else if ([sectionModel isKindOfClass:[IQUITestDebugScriptModel class]]) {
        return @"脚本转换";
    }
    return @"";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id sectionModel = self.dataArray[section];
    if ([sectionModel isKindOfClass:[IQUITestDebugKeyValueModel class]]) {
        IQUITestDebugKeyValueModel *kvModel = (IQUITestDebugKeyValueModel *)sectionModel;
        return kvModel.kvArray.count;
    } else if ([sectionModel isKindOfClass:[IQUITestDebugServerInfoModel class]]) {
        return 1;
    } else if ([sectionModel isKindOfClass:[IQUITestDebugSwitchModel class]]) {
        return 1;
    } else if ([sectionModel isKindOfClass:[IQUITestDebugScriptModel class]]) {
        return 1;
    }
    return 0;
}
#pragma mark--UITableViewDataSource--
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    id sectionModel = self.dataArray[indexPath.section];
    if ([sectionModel isKindOfClass:[IQUITestDebugKeyValueModel class]]) {
        return 44;
    } else if ([sectionModel isKindOfClass:[IQUITestDebugServerInfoModel class]]) {
        return 44;
    } else if ([sectionModel isKindOfClass:[IQUITestDebugSwitchModel class]]) {
        return 44;
    } else if ([sectionModel isKindOfClass:[IQUITestDebugScriptModel class]]) {
        return 340;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    id sectionModel = self.dataArray[indexPath.section];
    if ([sectionModel isKindOfClass:[IQUITestDebugKeyValueModel class]]) {
        static NSString *reuseId = @"IQUITestDebugKeyValueCell";
        IQUITestDebugKeyValueModel *kvModel = (IQUITestDebugKeyValueModel *)sectionModel;
        IQUITestDebugKeyValueCell *keyValueCell = [tableView dequeueReusableCellWithIdentifier:reuseId];
        if (!keyValueCell) {
            keyValueCell = [[IQUITestDebugKeyValueCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseId];
            keyValueCell.delegate = self;
        }
        [keyValueCell updateViewWithViewModel:kvModel.kvArray[indexPath.row]];
        return keyValueCell;
        
    } else if ([sectionModel isKindOfClass:[IQUITestDebugServerInfoModel class]]) {
        static NSString *reuseId = @"IQUITestDebugServerInfoCell";
        IQUITestDebugServerInfoModel *infoModel = (IQUITestDebugServerInfoModel *)sectionModel;
        
        IQUITestDebugServerInfoCell *serverInfoCell = [tableView dequeueReusableCellWithIdentifier:reuseId];
        if (!serverInfoCell) {
            serverInfoCell = [[IQUITestDebugServerInfoCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseId];
        }
        [serverInfoCell updateViewWithViewModel:infoModel];
        return serverInfoCell;
    } else if ([sectionModel isKindOfClass:[IQUITestDebugSwitchModel class]]) {
        static NSString *reuseId = @"IQUITestDebugSwitchCell";
        IQUITestDebugSwitchModel *swModel = (IQUITestDebugSwitchModel *)sectionModel;
        IQUITestDebugSwitchCell *switchCell = [tableView dequeueReusableCellWithIdentifier:reuseId];
        if (!switchCell) {
            switchCell = [[IQUITestDebugSwitchCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseId];
            switchCell.delegate = self;
        }
        [swModel updateSwitchModel];
        [switchCell updateViewWithViewModel:swModel];
        return switchCell;
    } else if ([sectionModel isKindOfClass:[IQUITestDebugScriptModel class]]) {
        static NSString *reuseId = @"IQUITestDebugSwitchCell";
        IQUITestDebugScriptModel *scriptModel = (IQUITestDebugScriptModel *)sectionModel;
        IQUITestDebugScriptCell *scriptCell = [tableView dequeueReusableCellWithIdentifier:reuseId];
        if (!scriptCell) {
            scriptCell = [[IQUITestDebugScriptCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseId];
            scriptCell.delegate = self;
        }
        [scriptCell updateViewWithViewModel:scriptModel];
        return scriptCell;
    }
    return nil;
    
}

#pragma mark--IQUITestDebugKeyValueDelegate--
- (void)capMapHasChanged {
    [self.debugTable reloadSections:[NSIndexSet indexSetWithIndex:3] withRowAnimation:UITableViewRowAnimationFade];
}
#pragma mark--IQUITestDebugSwitchDelegate--
- (void)reordControlStateHasChanged {
    /*刷新script section*/
    [self.debugTable reloadSections:[NSIndexSet indexSetWithIndex:3] withRowAnimation:UITableViewRowAnimationFade];
}
#pragma mark--IQUITestDebugScriptDelegate--
- (void)scriptCodeHasGenerated {
    IQUITestDebugKeyValueModel *kvModel = self.dataArray[0];
    [kvModel updateKVModelArray];
    [self.debugTable reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
}
#pragma mark--Getters & Setters--
- (IQUITestDebugDismissButton *)dismissButton {
    if (!_dismissButton) {
        _dismissButton = [IQUITestDebugDismissButton buttonWithType:UIButtonTypeCustom];
        _dismissButton.frame = CGRectMake(12, 60, [[UIScreen mainScreen] bounds].size.width - 24, 60);
        [_dismissButton addTarget:self action:@selector(dismissDebugView) forControlEvents:UIControlEventTouchUpInside];
        [_dismissButton setTitle:@"🤪 Tap me to dismiss the Debug View 🤪" forState:UIControlStateNormal];
        [_dismissButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _dismissButton.titleLabel.font = [UIFont fontWithName:@"MarkerFelt-Thin" size:20];
        _dismissButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    }
    return _dismissButton;
}
- (UITableView *)debugTable {
    if (!_debugTable) {
        _debugTable = [[UITableView alloc]initWithFrame:CGRectMake(0, 60, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height - 60) style:UITableViewStyleGrouped];
        _debugTable.backgroundColor = [UIColor clearColor];
        _debugTable.delegate = self;
        _debugTable.dataSource = self;
    }
    return _debugTable;
}

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
        IQUITestDebugKeyValueModel *kvModel = [IQUITestDebugKeyValueModel viewModelWithCap:nil];
        IQUITestDebugServerInfoModel *infoModel = [IQUITestDebugServerInfoModel viewModelWithServer:nil];
        IQUITestDebugSwitchModel *swModel = [IQUITestDebugSwitchModel viewModelWithState:YES];
        IQUITestDebugScriptModel *scriptModel = [IQUITestDebugScriptModel viewModelWithScript:nil];
        
        [_dataArray addObject:kvModel];
        [_dataArray addObject:infoModel];
        [_dataArray addObject:swModel];
        [_dataArray addObject:scriptModel];
    }
    return _dataArray;
}

@end
