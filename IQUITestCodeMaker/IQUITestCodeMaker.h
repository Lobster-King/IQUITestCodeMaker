//
//  IQUITestCodeMaker.h
//  IQUITestCodeMaker
//
//  Created by lobster on 2018/8/3.
//  Copyright © 2018年 lobster. All rights reserved.
//

/*注意：
 1.该组件通过运行时自动生成并获取标签，会有一定的性能开销，默认DEBUG模式开启，RELEASE模式关闭。
 2.也可以通过打开#define IQ_UITEST_CODEMAKER_ENABLED 0 强制关闭该组件。
 */

//#define IQ_UITEST_CODEMAKER_ENABLED 0

#ifdef IQ_UITEST_CODEMAKER_ENABLED
#define IQ_CODEMAKER_ENABLED IQ_UITEST_CODEMAKER_ENABLED
#else
#define IQ_CODEMAKER_ENABLED DEBUG
#endif

/*Debug球注意事项：
 1.默认对于Debug球相关UI不做hook操作。
 2.可以通过打开//#define IQ_UITEST_DEBUGBALL_ENABLED 0 强制关闭Debug工具
 */

//#define IQ_UITEST_DEBUGBALL_ENABLED 0

#ifdef IQ_UITEST_DEBUGBALL_ENABLED
#define IQ_DEBUGBALL_ENABLED IQ_UITEST_DEBUGBALL_ENABLED
#else
#define IQ_DEBUGBALL_ENABLED DEBUG
#endif

/*
 获取设备UDID注意事项：（用此工具，默认你身边没有Mac没有iTunes，没有iTools，没有Xcode等工具、算了撸主太懒还是先用蒲公英的吧）
 1.此功能不能上架Appstore！！！
 2.此功能不能上架Appstore！！！
 3.此功能不能上架Appstore！！！
 4.默认DEBUG开启，RELEASE关闭
 */

//#define IQ_UITEST_UDIDFETCH_ENABLED 0

#ifdef IQ_UITEST_UDIDFETCH_ENABLED
#define IQ_UDIDFETCH_ENABLED IQ_UITEST_UDIDFETCH_ENABLED
#else
#define IQ_UDIDFETCHL_ENABLED DEBUG
#endif

#define DebugView(prefixClsString) ([prefixClsString hasPrefix:@"IQUITestDebug"])
#define WhiteListView(prefixClsString)  ([@[@"_UISnapshotWindow",@"UITableViewCellContentView",@"UISwitchModernVisualElement",@"UIFieldEditor",@"UITextField",@"UITextView"] containsObject:prefixClsString])

