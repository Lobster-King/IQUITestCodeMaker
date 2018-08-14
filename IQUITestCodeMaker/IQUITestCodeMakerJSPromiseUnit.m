//
//  IQUITestCodeMakerJSPromiseUnit.m
//  IQUITestCodeMaker
//
//  Created by lobster on 2018/8/9.
//  Copyright © 2018年 lobster. All rights reserved.
//

#import "IQUITestCodeMakerJSPromiseUnit.h"
#import "IQUITestCodeMakerCapabilities.h"
#import "IQUITestOperationEvent.h"

@implementation IQUITestCodeMakerJSPromiseUnit

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
        case IQUIEventSendKey:
        {
            [self produceSendKeyCodeWithOperationEvent:op];
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
    NSString *tapCode = [NSString stringWithFormat:@"\n\
  let el%ld = await driver.elementByAccessibilityId(\"%@\");\n\
  await el%ld.click()\n",self.eventIndex,op.identifier,self.eventIndex];
    [self storeProductCode:tapCode];
}

- (void)produceSendKeyCodeWithOperationEvent:(IQUITestOperationEvent *)op {
    if (!self.isConverting) {
        [self.eventQueue addObject:op];
    }
    self.eventIndex++;
    NSString *sendKeyCode = [NSString stringWithFormat:@"\n\
  let el%ld = await driver.elementByAccessibilityId(\"%@\");\n\
  await el%ld.type(\"%@\")\n",self.eventIndex,op.identifier,self.eventIndex,op.value];
    [self storeProductCode:sendKeyCode];
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
/*IQ UITest Code Maker.Rquire Appium Version(%@)*/\n\
/*This Sample Code Uses admc/wd Client Library*/\n\
/*Install It With Cmd 'npm install wd'*/\n\
\n\
\n\
const wd = require('wd');\n\
const caps = {\"platformName\":\"%@\",\"platformVersion\":\"%@\",\"deviceName\":\"%@\",\"automationName\":\"%@\",\"app\":\"%@\"};\n ",
                      self.cap.appiumCap.appiumVersion,self.cap.appiumCap.platformName,self.cap.appiumCap.platformVersion,self.cap.appiumCap.deviceName,self.cap.appiumCap.automationName,self.cap.appiumCap.app];
    
    code = [code stringByAppendingFormat:@"\n\
\n\
const driver = wd.promiseChainRemote(\"http://%@:%@/wd/hub\");\n\
\n\
\n\
async function main () {\n\
  await driver.init(caps);", self.cap.appiumCap.serverAddress, self.cap.appiumCap.serverPort];
    
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
    NSString *code = @"\n\
  await driver.quit();\n\
}\n\
main().catch(console.log);\n";
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
