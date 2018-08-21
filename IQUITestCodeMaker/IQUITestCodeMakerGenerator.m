//
//  IQUITestCodeMakerGenerator.m
//  IQUITestCodeMaker
//
//  Created by lobster on 2018/8/4.
//  Copyright © 2018年 lobster. All rights reserved.
//

#import "IQUITestCodeMakerGenerator.h"
#import "IQUITestCodeMaker.h"
#import "IQUITestOperationEvent.h"
#import "IQUITestCodeMakerFactory.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import <UIKit/UIKit.h>
#import "IQUITestDebugBall.h"
#import "IQUITestCodeMakerCapabilities.h"
#import "GCDWebServer.h"

static IQUITestCodeMakerGenerator *persistent = nil;
static NSString *const kAutoSetIdentifier   = @"[A]";
static NSString *const kManualIdentifier    = @"[M]";

static NSString *const kViewHierarchy       = @"VHierarchy";
static NSString *const kViewTag             = @"VTag";
static NSString *const kViewIvarName        = @"VIvar";
static NSString *const kViewText            = @"VText";
static NSString *const kViewTitle           = @"VTitle";
static NSString *const kViewImageName       = @"VImage";
static NSString *const kViewSection         = @"VSection";
static NSString *const kViewIndexRow        = @"VRow";

static NSString *const kCapabilitiesKey = @"kCapabilitiesKey";

void IQTapTask(id target) {
    IQUITestOperationEvent *op = [IQUITestOperationEvent new];
    op.eventType = IQUIEventTap;
    op.identifier= [target accessibilityIdentifier];
    
    IQUITestCodeMakerGenerator *persistent = [IQUITestCodeMakerGenerator sharePersistent];
    [persistent.factory produceCodeWithOperationEvent:op];
}

void IQTapTaskWithLocation(CGPoint point) {
    IQUITestOperationEvent *op = [IQUITestOperationEvent new];
    op.locateStrategy = IQElementLocateByCoordinate;
    op.eventType = IQUIEventTap;
    op.touchPoint = point;
    
    IQUITestCodeMakerGenerator *persistent = [IQUITestCodeMakerGenerator sharePersistent];
    [persistent.factory produceCodeWithOperationEvent:op];
}

void IQSendKeyTask(id target) {
    IQUITestOperationEvent *op = [IQUITestOperationEvent new];
    op.eventType = IQUIEventSendKey;
    op.identifier = [target accessibilityIdentifier];
    
    if ([target isKindOfClass:[UITextField class]]) {
        op.value = [(UITextField *)target text];
    } else if ([target isKindOfClass:[UITextView class]]) {
        op.value = [(UITextView *)target text];
    }
    
    IQUITestCodeMakerGenerator *persistent = [IQUITestCodeMakerGenerator sharePersistent];
    [persistent.factory produceCodeWithOperationEvent:op];
}

void IQQuitTask(void) {
    
}

void IQRuntimeMethodExchange(Class aClass, SEL oldSEL, SEL newSEL) {
    Method originalMethod = class_getInstanceMethod(aClass, oldSEL);
    Method swizzledMethod = class_getInstanceMethod(aClass, newSEL);
    BOOL didAddMethod =
    class_addMethod(aClass,
                    oldSEL,
                    method_getImplementation(swizzledMethod),
                    method_getTypeEncoding(swizzledMethod));
    if (didAddMethod) {
        class_replaceMethod(aClass,
                            newSEL,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

/*hook touchBegin\touchMoved\touchCanceled*/
static NSMutableDictionary<NSString *, NSMutableSet<NSString *> *> *SwizzledClassMethods()
{
    static dispatch_once_t onceToken;
    static NSMutableDictionary *swizzledMethods = nil;
    dispatch_once(&onceToken, ^{
        swizzledMethods = [[NSMutableDictionary alloc] init];
    });
    
    return swizzledMethods;
}
static void ImplementTouchMethodsIfNeeded(Class viewClass, SEL aSelector)
{
    NSCParameterAssert(viewClass && aSelector);
    if (!viewClass || !aSelector) {
        return;
    }
    Class superclass = class_getSuperclass(viewClass);
    NSCParameterAssert(superclass);
    if (!superclass || !class_getInstanceMethod(superclass, aSelector)) {
        return;
    }
    
    NSString *className = NSStringFromClass(viewClass);
    NSString *methodName = NSStringFromSelector(aSelector);
    NSMutableSet<NSString *> *swizzledMethods = [SwizzledClassMethods() objectForKey:className];
    if ([swizzledMethods containsObject:methodName]) {
        return;
    }
    
    IMP defaultIMP = imp_implementationWithBlock(^(id self, NSSet<UITouch *> *touches, UIEvent *event) {
        struct objc_super super = {
            .receiver = self,
            .super_class = superclass
        };
        void (*touchesEventHandler)(struct objc_super *, SEL, NSSet<UITouch *> *, UIEvent *) = (__typeof__(touchesEventHandler))objc_msgSendSuper;
        return touchesEventHandler(&super, aSelector, touches, event);
    });
    Method method = class_getInstanceMethod(superclass, aSelector);
    class_addMethod(viewClass, aSelector, defaultIMP, method_getTypeEncoding(method));
    
    if(swizzledMethods == nil) {
        swizzledMethods = [[NSMutableSet alloc] init];
        [SwizzledClassMethods() setObject:swizzledMethods forKey:className];
    }
    [swizzledMethods addObject:methodName];
}

#pragma mark--UITextField--
@implementation UITextField (IQRunTimeHook)

+ (void)IQHook {
    IQRuntimeMethodExchange([UITextField class], @selector(setDelegate:), @selector(IQ_setDelegate:));
}

- (void)IQ_setDelegate:(id<UITextFieldDelegate>)delegate {
    [self IQ_setDelegate:delegate];
    
    if (DebugView(NSStringFromClass([self class]))) {
        return;
    }
    
    /*hook @selector(tableView:cellForRowAtIndexPath:)*/
    if (![delegate respondsToSelector:@selector(textFieldDidEndEditing:)]) {
        return;
    }
    
    Method originMethod = class_getInstanceMethod([delegate class], @selector(textFieldDidEndEditing:));
    IMP    originImp    = method_getImplementation(originMethod);
    Method currentMethod = class_getInstanceMethod([self class], @selector(IQ_textFieldDidEndEditing:));
    IMP    currentImp    = method_getImplementation(currentMethod);
    
    class_addMethod([delegate class], @selector(IQ_textFieldDidEndEditing:), currentImp, method_getTypeEncoding(currentMethod));
    
    BOOL didAddMethod = class_addMethod([delegate class], @selector(textFieldDidEndEditing:), currentImp, method_getTypeEncoding(currentMethod));
    
    if (didAddMethod) {
        class_replaceMethod([delegate class], @selector(IQ_textFieldDidEndEditing:), originImp, method_getTypeEncoding(originMethod));
    } else {
        IQRuntimeMethodExchange([delegate class], @selector(textFieldDidEndEditing:), @selector(IQ_textFieldDidEndEditing:));
    }
    
}

- (void)IQ_textFieldDidEndEditing:(UITextField *)textField {
    [self IQ_textFieldDidEndEditing:textField];
    IQSendKeyTask(textField);
}

@end

#pragma mark--UINavigationController--

@implementation UINavigationController (IQRunTimeHook)

+ (void)IQHook {
    IQRuntimeMethodExchange([UINavigationController class], @selector(navigationBar:shouldPopItem:), @selector(IQ_navigationBar:shouldPopItem:));
}

- (BOOL)IQ_navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item {
    BOOL ret = [self IQ_navigationBar:navigationBar shouldPopItem:item];
    
#warning 系统自带导航需要在此截获事件
    UINavigationItem *backItem = navigationBar.backItem;
    
    IQUITestOperationEvent *op = [IQUITestOperationEvent new];
    op.eventType = IQUIEventTap;
    op.identifier= backItem.title;
    
    IQUITestCodeMakerGenerator *persistent = [IQUITestCodeMakerGenerator sharePersistent];
    [persistent.factory produceCodeWithOperationEvent:op];
    
    return ret;
}

@end

#pragma mark--UIGestureRecognizer--

@implementation UIGestureRecognizer (IQRunTimeHook)

+ (void)IQHook {
    IQRuntimeMethodExchange([UIGestureRecognizer class], @selector(initWithTarget:action:), @selector(IQ_initWithTarget:action:));
    IQRuntimeMethodExchange([UIGestureRecognizer class], @selector(addTarget:action:), @selector(IQ_addTarget:action:));
}

- (instancetype)IQ_initWithTarget:(nullable id)target action:(nullable SEL)action {
    id ges = [self IQ_initWithTarget:target action:action];
    
    if (DebugView(NSStringFromClass([target class]))) {
        return ges;
    }
    
    if (![target respondsToSelector:action]) {
        return ges;
    }
    
    if (![self isKindOfClass:[UITapGestureRecognizer class]]) {
        return ges;
    }
    
    Method originMethod = class_getInstanceMethod([target class], action);
    IMP    originImp    = method_getImplementation(originMethod);
    Method currentMethod = class_getInstanceMethod([self class], @selector(IQ_delegateMethodWithFirstArg:));
    IMP    currentImp    = method_getImplementation(currentMethod);
    
    class_addMethod([target class], @selector(IQ_delegateMethodWithFirstArg:), currentImp, method_getTypeEncoding(currentMethod));
    
    BOOL didAddMethod = class_addMethod([target class], action, currentImp, method_getTypeEncoding(currentMethod));
    
    if (didAddMethod) {
        class_replaceMethod([target class], @selector(IQ_delegateMethodWithFirstArg:), originImp, method_getTypeEncoding(originMethod));
    } else {
        IQRuntimeMethodExchange([target class], action, @selector(IQ_delegateMethodWithFirstArg:));
    }
    
    return ges;
}

- (void)IQ_addTarget:(id)target action:(SEL)action {
    [self IQ_addTarget:target action:action];
    
    if (DebugView(NSStringFromClass([target class]))) {
        return;
    }
    
    if (![target respondsToSelector:action]) {
        return;
    }
    /*一个视图添加多个手势，hook会出现问题*/
    if (![self isKindOfClass:[UITapGestureRecognizer class]]) {
        return;
    }
    
    Method originMethod = class_getInstanceMethod([target class], action);
    IMP    originImp    = method_getImplementation(originMethod);
    Method currentMethod = class_getInstanceMethod([self class], @selector(IQ_delegateMethodWithFirstArg:));
    IMP    currentImp    = method_getImplementation(currentMethod);
    
    class_addMethod([target class], @selector(IQ_delegateMethodWithFirstArg:), currentImp, method_getTypeEncoding(currentMethod));
    
    BOOL didAddMethod = class_addMethod([target class], action, currentImp, method_getTypeEncoding(currentMethod));
    
    if (didAddMethod) {
        class_replaceMethod([target class], @selector(IQ_delegateMethodWithFirstArg:), originImp, method_getTypeEncoding(originMethod));
    } else {
        IQRuntimeMethodExchange([target class], action, @selector(IQ_delegateMethodWithFirstArg:));
    }
    
}

- (void)IQ_delegateMethodWithFirstArg:(id)arg,... NS_REQUIRES_NIL_TERMINATION {
    NSMutableArray *array = [NSMutableArray array];
    if (arg){
        va_list args;
        id cusorObj;
        va_start(args, arg);
        while((cusorObj = va_arg(args, id))) {
            [array addObject:cusorObj];
        }
        va_end(args);
    }
    
    switch (array.count) {
        case 0:
        {
            [self IQ_delegateMethodWithFirstArg:nil];
        }
            break;
        case 1:
        {
            [self IQ_delegateMethodWithFirstArg:array[0],nil];
        }
            break;
        case 2:
        {
            [self IQ_delegateMethodWithFirstArg:array[0],array[1],nil];
        }
            break;
        case 3:
        {
            [self IQ_delegateMethodWithFirstArg:array[0],array[1],array[2],nil];
        }
            break;
        case 4:
        {
            [self IQ_delegateMethodWithFirstArg:array[0],array[1],array[2],array[3],nil];
        }
            break;
        case 5:
        {
            [self IQ_delegateMethodWithFirstArg:array[0],array[1],array[2],array[3],array[4],nil];
        }
            break;
            
        default:
            break;
    }
    
    id target = self;
    
    IQTapTask(target);
    
}


@end

#pragma mark--UIImage--
@implementation UIImage (IQRunTimeHook)

+ (void)IQHook {
    IQRuntimeMethodExchange([UIImage class], @selector(imageNamed:), @selector(IQ_imageNamed:));
    IQRuntimeMethodExchange([UIImage class], @selector(imageWithContentsOfFile:), @selector(IQ_imageWithContentsOfFile:));
    IQRuntimeMethodExchange([UIImage class], @selector(accessibilityIdentifier), @selector(IQ_accessibilityIdentifier));
}

+ (UIImage *)IQ_imageNamed:(NSString *)imageName{
    UIImage *image = [UIImage IQ_imageNamed:imageName];
    image.accessibilityIdentifier = imageName;
    return image;
}

+ (UIImage *)IQ_imageWithContentsOfFile:(NSString *)path
{
    UIImage *image = [UIImage IQ_imageWithContentsOfFile:path];
    NSArray *components = [path pathComponents];
    if (components.count > 0) {
        image.accessibilityIdentifier = components.lastObject;
    }
    else {
        image.accessibilityIdentifier = path;
    }
    return image;
}

- (id)assetName {return nil;}

- (NSString *)IQ_accessibilityIdentifier {
    NSString *IQ_accessibilityIdentifier = [self IQ_accessibilityIdentifier];
    if (IQ_accessibilityIdentifier.length == 0 && [self respondsToSelector:@selector(imageAsset)]) {
        IQ_accessibilityIdentifier = [(id)self.imageAsset assetName];
        self.accessibilityIdentifier = IQ_accessibilityIdentifier;
    }
    
    return IQ_accessibilityIdentifier;
}

@end

#pragma mark--UIResponder--
@implementation UIResponder (IQRunTimeHook)

-(NSString *)nameWithInstance:(id)instance {
    unsigned int numIvars = 0;
    NSString *key=nil;
    Ivar * ivars = class_copyIvarList([self class], &numIvars);
    for(int i = 0; i < numIvars; i++) {
        Ivar thisIvar = ivars[i];
        const char *type = ivar_getTypeEncoding(thisIvar);
        NSString *stringType =  [NSString stringWithCString:type encoding:NSUTF8StringEncoding];
        if (![stringType hasPrefix:@"@"]) {
            continue;
        }
        if ((object_getIvar(self, thisIvar) == instance)) {
            key = [NSString stringWithUTF8String:ivar_getName(thisIvar)];
            break;
        }
    }
    free(ivars);
    return key;
}

- (NSString *)findNameWithInstance:(UIView *) instance
{
    id nextResponder = [self nextResponder];
    NSString *name = [self nameWithInstance:instance];
    if (!name) {
        return [nextResponder findNameWithInstance:instance];
    }
    if ([name hasPrefix:@"_"]) {
        name = [name substringFromIndex:1];
    }
    return name;
}

@end

#pragma mark--UIView--
@implementation UIView (IQRunTimeHook)

+ (void)IQHook {
    IQRuntimeMethodExchange([UIView class], @selector(accessibilityIdentifier), @selector(IQ_accessibilityIdentifier));
    IQRuntimeMethodExchange([UIView class], @selector(addGestureRecognizer:), @selector(IQ_addGestureRecognizer:));
#warning has problem !!! fix me !!!
    ImplementTouchMethodsIfNeeded([UIView class], @selector(touchesBegan:withEvent:));
}

- (NSString *)IQ_accessibilityIdentifier {
    NSLog(@"========>%@",NSStringFromClass([self class]));
    
    if (DebugView(NSStringFromClass([self class]))) {
        return [self IQ_accessibilityIdentifier];
    }
    
    /*apple一些系统控件会自动设置accessibilityIdentifier，为视力不好的人自动设置标识。例如系统导航的返回按钮等*/
    NSString *accessibilityIdentifier = [self IQ_accessibilityIdentifier];
    
    /*针对于UICollectionViewCell、UITableViewCell一般需要根据indexPath.section和indexPth.row以及tableView所属的UIViewController唯一确定其identifier（需要考虑一个controller是多个表视图的delegate的情况）*/
    /*若identifier已经有值且开发手动代码设置的，直接return其identifier*/
    /*若identifier已经有值且prefix是自动代码设置的，直接return其identifier*/
    /*若以上不满足，则获取控件的基本属性，尽可能的达到唯一标识的目的。
     基本属性（基本不会变的）：1.tag。2.在一类中的property name或者成员变量名称。
     UILabel:1.text。。
     UIButton:1.title。2.imageName。
     UIImageView:1.imageName。
     其他类型：获取其在父视图的同类型的索引（Debug模式对于可交互的控件，可考虑回溯到controller级，懒加载基本能保证获取控件id时的视图基本是全的，这样还有个问题就是，视图层级可能因为接口或者某些原因导致变化）。
     */
    
    if ([self isKindOfClass:[UITableViewCell class]] || [self isKindOfClass:[UICollectionViewCell class]]) {
        return accessibilityIdentifier;
    }
    if ([accessibilityIdentifier hasPrefix:kManualIdentifier]) {
        /*已手动设置*/
        return accessibilityIdentifier;
    }
    if ([accessibilityIdentifier hasPrefix:kAutoSetIdentifier]) {
        /*已自动设置*/
        return accessibilityIdentifier;
    }
    
    NSMutableDictionary *jsonFormat = [NSMutableDictionary dictionary];
    [jsonFormat setValue:@"" forKey:kViewHierarchy];
    [jsonFormat setValue:@"" forKey:kViewTag];
    [jsonFormat setValue:@"" forKey:kViewIvarName];
    NSString *identifierJsonFormat = @"";
    NSInteger tag = self.tag;
    /*从父类中查询ivar name*/
    NSString *ivarName = [self.superview findNameWithInstance:self];
    
    if ([self isKindOfClass:[UILabel class]]) {
        NSString *text = [(UILabel *)self text]?:@"";
        NSInteger index = 0;
        if ([[self gestureRecognizers] count]) {
            index = [self indexOfCurrentViewInSuperView:self];
        }
        NSString *hierarchy = [NSString stringWithFormat:@"%@[%ld]",NSStringFromClass([self class]),index];
        identifierJsonFormat = [identifierJsonFormat stringByAppendingString:[NSString stringWithFormat:@"%@{%@:%@,%@:%ld,%@:%@,%@:%@}",kAutoSetIdentifier,kViewHierarchy,hierarchy,kViewTag,tag,kViewIvarName,ivarName,kViewText,text]];
    } else if ([self isKindOfClass:[UIButton class]]) {
        UIButton *btn = (UIButton *)self;
        NSString *btnTitle = btn.titleLabel.text?:@"";
        NSInteger index = [self indexOfCurrentViewInSuperView:self];
        NSString *imageName = btn.imageView.image.accessibilityIdentifier;
#warning 打开按钮的图片会影响appium定位 fix me !!!
        NSString *hierarchy = [NSString stringWithFormat:@"%@[%ld]",NSStringFromClass([self class]),index];
        identifierJsonFormat = [identifierJsonFormat stringByAppendingString:[NSString stringWithFormat:@"%@{%@:%@,%@:%ld,%@:%@,%@:%@}",kAutoSetIdentifier,kViewHierarchy,hierarchy,kViewTag,tag,kViewIvarName,ivarName,kViewTitle,btnTitle]];
    } else if ([self isKindOfClass:[UIImageView class]]) {
        UIImageView *imageView = (UIImageView *)self;
        NSString *imageName = imageView.image.accessibilityIdentifier;
        NSInteger index = 0;
        //        if ([[self gestureRecognizers] count]) {
        index = [self indexOfCurrentViewInSuperView:self];
        //        }
        NSString *hierarchy = [NSString stringWithFormat:@"%@[%ld]",NSStringFromClass([self class]),index];
        identifierJsonFormat = [identifierJsonFormat stringByAppendingString:[NSString stringWithFormat:@"%@{%@:%@,%@:%ld,%@:%@,%@:%@}",kAutoSetIdentifier,kViewHierarchy,hierarchy,kViewTag,tag,kViewIvarName,ivarName,kViewImageName,imageName]];
    } else {
#warning 通过touch来响应操作事件会过滤掉，有待解决。
        NSInteger index = 0;
        if ([NSStringFromClass([self class]) isEqualToString:@"BaseBottomBarItem"]) {
            
        }
        if ([[self gestureRecognizers] count]) { /*打开则会把通过touch事件操作给过滤掉*/
            index = [self indexOfCurrentViewInSuperView:self];
        }
        
        NSString *hierarchy = [NSString stringWithFormat:@"%@[%ld]",NSStringFromClass([self class]),index];
        identifierJsonFormat = [identifierJsonFormat stringByAppendingString:[NSString stringWithFormat:@"%@{%@:%@,%@:%ld,%@:%@}",kAutoSetIdentifier,kViewHierarchy,hierarchy,kViewTag,tag,kViewIvarName,ivarName]];
    }
    if (!identifierJsonFormat.length) {
        identifierJsonFormat = @"Oh,My God!";
    }
    [self setAccessibilityIdentifier:identifierJsonFormat];
    return identifierJsonFormat;
}

- (NSInteger)indexOfCurrentViewInSuperView:(UIView *)currentView {
    
    NSInteger cursor= 0;
    NSString *cls = NSStringFromClass([currentView class]);
    for (UIView *subview in [self.superview subviews]) {
        NSString *subCls = NSStringFromClass([subview class]);
        if ([subCls isEqualToString:cls]) {
            cursor++;
        }
        if (subview == self) {
            break;
        }
    }
    
    return cursor;
}

- (void)IQ_addGestureRecognizer:(UIGestureRecognizer*)gestureRecognizer {
    [self IQ_addGestureRecognizer:gestureRecognizer];
    
    if (DebugView(NSStringFromClass([self class])) || WhiteListView(NSStringFromClass([self class]))) {
        return;
    }
    
    if ([self IQ_accessibilityIdentifier]) {
        /*若已经设置了id则return掉，此处可能有隐患（已经设置id的情况是addSubView在addGestureRecognizer之前）
         UIButton等一些控件内部也会调用这个方法*/
        return;
    }
    NSLog(@"addGestureRecognizer========>%@",NSStringFromClass([self class]));
    
    /*此处仍然有问题：假如有三个UIImageView都添加了点击手势，而且是通过动态添加到一个父类里面，其id都成一样的了
     解决方案：添加手势的时候，先获取到superView，然后看下当前类在superView的索引*/
    
    /*按钮采用懒加载*/
    
    if (![NSStringFromClass([self class]) isEqualToString:@"UIButton"] ) {
        /*拼接更多有用信息*/
        //        UIButton *btn = (UIButton *)self;
        //        NSString *btnTitle = btn.titleLabel.text?:@"";
        //        NSString *identiLabel = btn.accessibilityLabel;
        //        NSString *varName = btn.accessibilityIdentifier;
        //        contentStr = [NSString stringWithFormat:@"/Content{'var':%@,'title':%@,'tag':%ld,'label':%@}",varName,btnTitle,btn.tag,identiLabel];
        
        /**/
        NSInteger index = [self indexOfCurrentViewInSuperView:self];
        NSString *identifier = [NSString stringWithFormat:@"%@%@[%ld]",kAutoSetIdentifier,NSStringFromClass([gestureRecognizer.view class]),index];
        self.accessibilityIdentifier = identifier;
        
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    /*事件传递*/
    [super touchesBegan:touches withEvent:event];
    /*判断是否时系统UI的touch事件，系统级的touch事件过滤，或者根据自己工程自定义*/
    /*可通过设置白名单来解决*/
    if (DebugView(NSStringFromClass([self class]))) {
        return;
    }
    
    if ([NSStringFromClass([self class]) isEqualToString:@"BaseBottomBarItem"]) {
        id target = self;
        IQTapTask(target);
    }
    
    if ([NSStringFromClass([self class])  isEqualToString:@"UIWebBrowserView"]) {
//        __block UITouch *firstTouch = nil;
        [touches enumerateObjectsUsingBlock:^(UITouch * _Nonnull obj, BOOL * _Nonnull stop) {
            CGPoint point = [obj locationInView:[UIApplication sharedApplication].keyWindow];
            IQTapTaskWithLocation(point);
            *stop = YES;
        }];
        
    }
}

@end

#pragma mark--UITableView--
@implementation UITableView (IQRunTimeHook)

+ (void)IQHook {
    IQRuntimeMethodExchange([UITableView class], @selector(setDelegate:), @selector(IQ_setDelegate:));
}

- (void)IQ_setDelegate:(id<UITableViewDelegate>)delegate{
    [self IQ_setDelegate:delegate];
    
    if (DebugView(NSStringFromClass([self class]))) {
        return;
    }
    
    /*hook @selector(tableView:cellForRowAtIndexPath:)*/
    if (![delegate respondsToSelector:@selector(tableView:cellForRowAtIndexPath:)]) {
        return;
    }
    
    Method originMethod = class_getInstanceMethod([delegate class], @selector(tableView:cellForRowAtIndexPath:));
    IMP    originImp    = method_getImplementation(originMethod);
    Method currentMethod = class_getInstanceMethod([self class], @selector(IQ_tableView:cellForRowAtIndexPath:));
    IMP    currentImp    = method_getImplementation(currentMethod);
    
    class_addMethod([delegate class], @selector(IQ_tableView:cellForRowAtIndexPath:), currentImp, method_getTypeEncoding(currentMethod));
    
    BOOL didAddMethod = class_addMethod([delegate class], @selector(tableView:cellForRowAtIndexPath:), currentImp, method_getTypeEncoding(currentMethod));
    
    if (didAddMethod) {
        class_replaceMethod([delegate class], @selector(IQ_tableView:cellForRowAtIndexPath:), originImp, method_getTypeEncoding(originMethod));
    } else {
        IQRuntimeMethodExchange([delegate class], @selector(tableView:cellForRowAtIndexPath:), @selector(IQ_tableView:cellForRowAtIndexPath:));
    }
    
    if (![delegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)]) {
        return;
    }
    
    Method didSelectOriginMethod = class_getInstanceMethod([delegate class], @selector(tableView:didSelectRowAtIndexPath:));
    IMP    didSelectOriginImp    = method_getImplementation(didSelectOriginMethod);
    Method didSelectCurrentMethod = class_getInstanceMethod([self class], @selector(IQ_tableView:didSelectRowAtIndexPath:));
    IMP    didSelectCurrentImp    = method_getImplementation(didSelectCurrentMethod);
    
    class_addMethod([delegate class], @selector(IQ_tableView:didSelectRowAtIndexPath:), didSelectCurrentImp, method_getTypeEncoding(didSelectCurrentMethod));
    
    BOOL didSelectdidAddMethod = class_addMethod([delegate class], @selector(tableView:didSelectRowAtIndexPath:), didSelectCurrentImp, method_getTypeEncoding(didSelectCurrentMethod));
    
    if (didSelectdidAddMethod) {
        class_replaceMethod([delegate class], @selector(IQ_tableView:didSelectRowAtIndexPath:), didSelectOriginImp, method_getTypeEncoding(didSelectOriginMethod));
    } else {
        IQRuntimeMethodExchange([delegate class], @selector(tableView:didSelectRowAtIndexPath:), @selector(IQ_tableView:didSelectRowAtIndexPath:));
    }
    
}

- (void)IQ_tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self IQ_tableView:tableView didSelectRowAtIndexPath:indexPath];
    if (DebugView(NSStringFromClass([self class]))) {
        return;
    }
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    IQTapTask(cell);
}

- (UITableViewCell *)IQ_tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self IQ_tableView:tableView cellForRowAtIndexPath:indexPath];
    if (DebugView(NSStringFromClass([self class]))) {
        return cell;
    }
    NSString *prefix = @"";
    prefix = [NSString stringWithFormat:@"%@%@/",kAutoSetIdentifier,NSStringFromClass([self class])];
    
    NSString *reuseIdentifier = [cell reuseIdentifier];
    if (!reuseIdentifier) {
        reuseIdentifier = NSStringFromClass([cell class]);
    }
    
    [cell setAccessibilityIdentifier:[NSString stringWithFormat:@"%@%@/%ld",prefix,reuseIdentifier,indexPath.row]];
    
    return cell;
}

- (UIViewController*)attributeControllerWithView:(UIView *)view {
    for (UIView* next = view; next; next = next.superview) {
        UIResponder* nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController*)nextResponder;
        }
    }
    return nil;
}

@end

#pragma mark--UICollectionView--

@implementation UICollectionView (IQRunTimeHook)

+ (void)IQHook {
    IQRuntimeMethodExchange([UICollectionView class],@selector(setDelegate:),@selector(IQ_setDelegate:));
}

- (void)IQ_setDelegate:(id<UICollectionViewDelegate>)delegate{
    [self IQ_setDelegate:delegate];
    
    if (DebugView(NSStringFromClass([self class]))) {
        return;
    }
    
    /*hook @selector(collectionView:cellForItemAtIndexPath:)*/
    if (![delegate respondsToSelector:@selector(collectionView:cellForItemAtIndexPath:)]) {
        return;
    }
    
    Method originMethod = class_getInstanceMethod([delegate class], @selector(collectionView:cellForItemAtIndexPath:));
    IMP originImp = method_getImplementation(originMethod);
    
    Method currentMethod = class_getInstanceMethod([self class], @selector(IQ_collectionView:cellForItemAtIndexPath:));
    IMP currentImp = method_getImplementation(currentMethod);
    
    class_addMethod([delegate class], @selector(IQ_collectionView:cellForItemAtIndexPath:), currentImp, method_getTypeEncoding(currentMethod));
    
    BOOL didAddMethod = class_addMethod([delegate class], @selector(collectionView:cellForItemAtIndexPath:), currentImp, method_getTypeEncoding(currentMethod));
    
    if (didAddMethod) {
        class_replaceMethod([delegate class], @selector(IQ_collectionView:cellForItemAtIndexPath:), originImp, method_getTypeEncoding(originMethod));
    } else {
        IQRuntimeMethodExchange([delegate class],
                                @selector(collectionView:cellForItemAtIndexPath:),
                                @selector(IQ_collectionView:cellForItemAtIndexPath:));
    }
    
    if (![delegate respondsToSelector:@selector(collectionView:didSelectItemAtIndexPath:)]) {
        return;
    }
    
    Method didSelectOriginMethod = class_getInstanceMethod([delegate class], @selector(collectionView:didSelectItemAtIndexPath:));
    IMP didSelectOriginImp = method_getImplementation(didSelectOriginMethod);
    
    Method didSelectCurrentMethod = class_getInstanceMethod([self class], @selector(IQ_collectionView:didSelectItemAtIndexPath:));
    IMP didSelectCurrentImp = method_getImplementation(didSelectCurrentMethod);
    
    class_addMethod([delegate class], @selector(IQ_collectionView:didSelectItemAtIndexPath:), didSelectCurrentImp, method_getTypeEncoding(didSelectCurrentMethod));
    
    BOOL didSelectDidAddMethod = class_addMethod([delegate class], @selector(collectionView:didSelectItemAtIndexPath:), didSelectCurrentImp, method_getTypeEncoding(didSelectCurrentMethod));
    
    if (didSelectDidAddMethod) {
        class_replaceMethod([delegate class], @selector(IQ_collectionView:didSelectItemAtIndexPath:), didSelectOriginImp, method_getTypeEncoding(didSelectOriginMethod));
    } else {
        IQRuntimeMethodExchange([delegate class],
                                @selector(collectionView:didSelectItemAtIndexPath:),
                                @selector(IQ_collectionView:didSelectItemAtIndexPath:));
    }
    
}

- (UICollectionViewCell *)IQ_collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [self IQ_collectionView:collectionView cellForItemAtIndexPath:indexPath];
    
    if (DebugView(NSStringFromClass([self class]))) {
        return cell;
    }
    
    NSString *prefix = @"";
    prefix = [NSString stringWithFormat:@"%@%@/",kAutoSetIdentifier,NSStringFromClass([self class])];
    
    NSString *reuseIdentifier = [cell reuseIdentifier];
    if (!reuseIdentifier) {
        reuseIdentifier = NSStringFromClass([cell class]);
    }
    
    [cell setAccessibilityIdentifier:[NSString stringWithFormat:@"%@%@/%ld",prefix,reuseIdentifier,indexPath.row]];
    NSLog(@"------->%@",[cell accessibilityIdentifier]);
    return cell;
}

-(void)IQ_collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self IQ_collectionView:collectionView didSelectItemAtIndexPath:indexPath];
    if (DebugView(NSStringFromClass([self class]))) {
        return;
    }
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    IQTapTask(cell);
}

- (UIViewController*)attributeControllerWithView:(UIView *)view {
    for (UIView* next = view; next; next = next.superview) {
        UIResponder* nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController*)nextResponder;
        }
    }
    return nil;
}

@end

#pragma mark--UIApplication--

@implementation UIApplication (IQRunTimeHook)

+ (void)IQHook {
    IQRuntimeMethodExchange([UIApplication class], @selector(sendAction:to:from:forEvent:), @selector(IQ_sendAction:to:from:forEvent:));
    IQRuntimeMethodExchange([UIApplication class], @selector(sendEvent:), @selector(IQ_sendEvent:));
}

- (void)IQ_sendEvent:(UIEvent *)event {
    [self IQ_sendEvent:event];
    
}

- (BOOL)IQ_sendAction:(SEL)action to:(id)target from:(id)sender forEvent:(UIEvent *)event {
    BOOL ret = [self IQ_sendAction:action to:target from:sender forEvent:event];
    if (DebugView(NSStringFromClass([sender class]))) {
        return ret;
    }
    /*白名单，系统返回按钮已在should：popItem中拦截*/
    if ([sender isKindOfClass:NSClassFromString(@"_UIButtonBarButton")]){
        return ret;
    }
    
    IQTapTask(sender);
    return ret;
}

@end

#pragma mark--IQUITestCodeMakerGenerator--

@interface IQUITestCodeMakerGenerator ()<GCDWebServerDelegate>

@property (nonatomic, strong, readwrite) IQUITestCodeMakerFactory *factory;
@property (nonatomic, strong, readwrite) GCDWebServer *webServer;

@end

@implementation IQUITestCodeMakerGenerator

+ (instancetype)sharePersistent {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        persistent = [[IQUITestCodeMakerGenerator alloc]init];
        
    });
    return persistent;
}

- (void)hook {
    [UIApplication IQHook];
    [UITableView IQHook];
    [UICollectionView IQHook];
    [UIGestureRecognizer IQHook];
    [UIView IQHook];
    [UIImage IQHook];
    [UINavigationController IQHook];
    [UITextField IQHook];
}

- (void)handleApplicationWillResignActiveNotification {
    /*系统级弹框会触发应用willResignActive操作*/
    //    IQUITestOperationEvent *op = [IQUITestOperationEvent new];
    //    op.eventType = IQEventResignActive;
    //
    //    IQUITestCodeMakerGenerator *persistent = [IQUITestCodeMakerGenerator sharePersistent];
    //    [persistent.factory produceCodeWithOperationEvent:op];
}

- (void)handleApplicationWillTerminateNotification {
    //    IQUITestOperationEvent *op = [IQUITestOperationEvent new];
    //    op.eventType = IQEventWillTerminate;
    //
    //    IQUITestCodeMakerGenerator *persistent = [IQUITestCodeMakerGenerator sharePersistent];
    //    [persistent.factory produceCodeWithOperationEvent:op];
}

- (void)handleApplicationDidReceiveMemoryWarningNotification {
    
}

- (void)handleConvertTaskWithIdentifier:(NSString *)identifier {
    if (identifier) {
        NSDictionary *localCap = [[NSUserDefaults standardUserDefaults] objectForKey:kCapabilitiesKey];
        NSMutableDictionary *mutaleCap = [NSMutableDictionary dictionaryWithDictionary:localCap];
        [mutaleCap setValue:identifier forKey:@"appiumLanguage"];
        [[NSUserDefaults standardUserDefaults] setObject:mutaleCap forKey:kCapabilitiesKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    IQUITestCodeMakerCapabilities *capInstance = [[IQUITestCodeMakerCapabilities alloc]init];
    capInstance.driverType = IQUITestDriverAppium;
    
    IQUITestCodeMakerCapabilities *cap = [[IQUITestCodeMakerCapabilities alloc]init];
    cap.driverType = IQUITestDriverAppium;
    
    [self removeAllScript];
    
    IQUITestCodeMakerFactory *factory = [IQUITestCodeMakerFactory handleTaskUnitWithCap:cap];
    factory.eventQueue = [NSMutableArray arrayWithArray:self.factory.eventQueue];
    self.factory = factory;
    [self.factory convertEvetQueueToScript];
    [self restartServer];
}

- (void)handleCapChangeTaskWithKey:(NSString *)key value:(NSString *)value {
    NSDictionary *capLocal = [[NSUserDefaults standardUserDefaults] objectForKey:kCapabilitiesKey];
    NSMutableDictionary *mutableCap = [NSMutableDictionary dictionaryWithDictionary:capLocal];
    [mutableCap setValue:value forKey:key];
    [[NSUserDefaults standardUserDefaults] setObject:mutableCap forKey:kCapabilitiesKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    /*脚本重新生成*/
    [self handleConvertTaskWithIdentifier:nil];
}

- (void)handleRecordControlEventWithState:(BOOL)state {
    if (state) {
        /*开启，移除本地脚本缓存*/
        //        NSArray *directoryPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES);
        //        NSString *documentDirectory = [directoryPaths objectAtIndex:0];
        //        NSString *scriptDir = [documentDirectory stringByAppendingString:@"/IQScripts"];
        //        [[NSFileManager defaultManager] removeItemAtPath:scriptDir error:NULL];
        [self removeAllScript];
        
        IQUITestCodeMakerCapabilities *capInstance = [[IQUITestCodeMakerCapabilities alloc]init];
        capInstance.driverType = IQUITestDriverAppium;
        
        IQUITestCodeMakerCapabilities *cap = [[IQUITestCodeMakerCapabilities alloc]init];
        cap.driverType = IQUITestDriverAppium;
        
        IQUITestCodeMakerFactory *factory = [IQUITestCodeMakerFactory handleTaskUnitWithCap:cap];
        self.factory = factory;
    } else {
        IQUITestOperationEvent *lastEvent = [self.factory.eventQueue lastObject];
        if (!lastEvent || lastEvent.eventType == IQEventEndCode) {
            return;
        }
        /*结束录制*/
        IQUITestOperationEvent *op = [IQUITestOperationEvent new];
        op.eventType = IQEventEndCode;
        [self.factory produceCodeWithOperationEvent:op];
    }
}

- (void)handleApplicationDidFinishLaunching {
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    IQUITestDebugBall *debugBall = [[IQUITestDebugBall alloc]initWithFrame:CGRectMake([[UIScreen mainScreen] bounds].size.width/2 - 40, 20, 80, 80)];
    [keyWindow addSubview:debugBall];
}

#pragma mark--GCDWebServer--
- (void)webServerDidStart:(GCDWebServer*)server {
    
}

- (void)removeAllScript {
    NSArray *directoryPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES);
    NSString *documentDirectory = [directoryPaths objectAtIndex:0];
    NSString *scriptDir = [documentDirectory stringByAppendingString:@"/IQScripts"];
    [[NSFileManager defaultManager] removeItemAtPath:scriptDir error:NULL];
}

- (void)restartServer {
    [_webServer stop];
    [_webServer removeAllHandlers];
    [_webServer addGETHandlerForPath:@"/" filePath:_factory.scriptPath isAttachment:NO cacheAge:2 allowRangeRequests:YES];
    [_webServer start];
}

#pragma mark--Getters & Setters--
- (IQUITestCodeMakerFactory *)factory {
    if (!_factory) {
        [self removeAllScript];
        _factory = [IQUITestCodeMakerFactory handleTaskUnit];
    }
    return _factory;
}

- (GCDWebServer *)webServer {
    if (!_webServer){
        _webServer = [[GCDWebServer alloc]init];
        _webServer.delegate = self;
        [_webServer addGETHandlerForPath:@"/" filePath:self.factory.scriptPath isAttachment:NO cacheAge:2 allowRangeRequests:YES];
    }
    return _webServer;
}

@end
