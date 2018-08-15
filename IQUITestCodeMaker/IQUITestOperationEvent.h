//
//  IQUITestOperationEvent.h
//  IQUITestCodeMaker
//
//  Created by lobster on 2018/8/4.
//  Copyright © 2018年 lobster. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,IQEventType ) {
    IQUIEventUnknown    = 0,/*未知*/
    IQUIEventTap        = 1,/*单击*/
    IQUIEventDoubleTap  = 2,/*双击*/
    IQUIEventSwipe      = 3,/*轻扫*/
    IQUIEventPinch      = 4,/*捏合*/
    IQUIEventZoom       = 5,/*放大*/
    IQUIEventLongPress  = 6,/*长按*/
    IQUIEventSendKey    = 7,/*输入文本*/
    IQEventTemplateCode = 8,/*开始录制事件*/
    IQEventEndCode      = 9,/*结束录制事件*/
};

typedef NS_ENUM(NSInteger,IQElementLocateStrategy ) {
    IQElementLocateByIdentifier     = 0,/*通过控件identifier定位元素*/
    IQElementLocateByCoordinate     = 1,/*通过坐标定位元素*/
    IQElementLocateByPredicate      = 2,/*通过谓词定位元素*/
};

@interface IQUITestOperationEvent : NSObject

@property (nonatomic, assign) IQElementLocateStrategy *locateStrategy;/*定位策略，默认IQElementLocateByIdentifier*/
@property (nonatomic, assign) IQEventType eventType;
@property (nonatomic, copy)   NSString *identifier;
@property (nonatomic, copy)   NSString *value;
@property (nonatomic, assign) CGPoint touchPoint;

@end
