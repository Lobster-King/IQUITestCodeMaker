//
//  IQUITestCodeMakerRubyUnit.m
//  IQUITestCodeMaker
//
//  Created by lobster on 2018/8/4.
//  Copyright © 2018年 lobster. All rights reserved.
//

#import "IQUITestCodeMakerRubyUnit.h"
#import "IQUITestCapabilities.h"
#import "IQUITestOperationEvent.h"

@implementation IQUITestCodeMakerRubyUnit

- (void)produceCodeWithOperationEvent:(IQUITestOperationEvent *)op {
    [self produceTemplateCodeOnce];
    switch (op.eventType) {
        case IQUIEventUnknown:
        {
            /*未知*/
        }
            break;
        case IQUIEventTap:
            {
                [self produceTapCodeWithOperationEvent:op];
            }
            break;
        case IQUIEventDoubleTap:
        {
            
        }
            break;
        case IQUIEventSwipe:
        {
            
        }
            break;
        case IQUIEventPinch:
        {
            
        }
            break;
        case IQUIEventZoom:
        {
            
        }
            break;
        case IQUIEventLongPress:
        {
            
        }
            break;
        case IQEventEndCode:
        {
            [self produceEndCodeOnce];
        }
            break;
        default:
            break;
    }
}

- (void)produceTapCodeWithOperationEvent:(IQUITestOperationEvent *)op {
    if (!self.isConverting) {
        [self.eventQueue addObject:op];
    }
    self.eventIndex++;
    NSString *tapCode = [NSString stringWithFormat:@"el%ld = driver.find_element(:accessibility_id, \"%@\")\nel%ld.click\n\n",self.eventIndex,op.identifier,self.eventIndex];
    [self storeProductCode:tapCode];
}

- (void)produceTemplateCodeOnce {
    if (!self.templateCodeFlag) {
        [self templateCode];
    }
    self.templateCodeFlag++;
}

- (void)templateCode {
    if (!self.isConverting) {
        IQUITestOperationEvent *event = [IQUITestOperationEvent new];
        event.eventType = IQEventTemplateCode;
        [self.eventQueue addObject:event];
    }
    
    NSString *code = [NSString stringWithFormat:@"\n\
#IQ UITest Code Maker.Rquire Appium Version(%@)#\n\
#This Sample Code Uses The Appium Ruby Client#\n\
#Install It With Cmd 'gem install appium_lib'#\n\
#Require appium_lib Version(9.14.3),Require Ruby Version >= 2.2 .#\n\
\n\
\n\
require 'rubygems'\n\
require 'appium_lib'\n\
caps = {}\n\
caps[\"platformName\"] = \"%@\"\n\
caps[\"platformVersion\"] = \"%@\"\n\
caps[\"deviceName\"] = \"%@\"\n\
caps[\"automationName\"] = \"%@\"\n\
caps[\"app\"] = \"%@\"\n ",
self.cap.appiumCap.appiumVersion,self.cap.appiumCap.platformName,self.cap.appiumCap.platformVersion,self.cap.appiumCap.deviceName,self.cap.appiumCap.automationName,self.cap.appiumCap.app];

    code = [code stringByAppendingFormat:@"\n\
\n\
opts = {\n\
\tsauce_username: nil,\n\
\tserver_url: \"http://%@:%@/wd/hub\"\n\
}\n\
driver = Appium::Driver.new({caps: caps, appium_lib: opts}).start_driver\n\
\n", self.cap.appiumCap.serverAddress, self.cap.appiumCap.serverPort];
    
    [[NSFileManager defaultManager] removeItemAtPath:self.scriptPath error:nil];
    [self storeProductCode:code];
}

- (void)produceEndCodeOnce {
    if (!self.endCodeFlag) {
        [self endCode];
    }
    self.endCodeFlag++;
}

- (void)endCode {
    if (!self.isConverting) {
        IQUITestOperationEvent *event = [IQUITestOperationEvent new];
        event.eventType = IQEventEndCode;
        [self.eventQueue addObject:event];
    }
    NSString *code = @"\ndriver.quit\n";
    [self storeProductCode:code];
}

- (void)convertEvetQueueToScript {
    self.isConverting = YES;
    for (IQUITestOperationEvent *op in self.eventQueue) {
        if (op.eventType == IQEventTemplateCode) {
            [self produceTemplateCodeOnce];
        } else if (op.eventType == IQEventEndCode) {
            [self produceEndCodeOnce];
        } else {
            [self produceCodeWithOperationEvent:op];
        }
    }
    self.isConverting = NO;
}

@end
