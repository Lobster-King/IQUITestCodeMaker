# 总览

[英文说明](https://github.com/Lobster-King/IQUITestCodeMaker/blob/master/README.md)

IQUITestCodeMaker是一款轻量级的、无侵入性的自动生成UI测试脚本的工具，目前支持Appium相关脚本代码的自动生成，后续会支持对阿里Macaca相关主流框架脚本代码的自动生成。

Tester：对于测试朋友来讲，你需要做的就是让你们的iOSer把该框架通过pod引入工程即可。你不需要启动Appium Desktop或者启动inspector服务去编写UI测试脚本，你只需要点点点，然后利用Debug工具把脚本导出。

iOSer：利用IQUITestCodeMaker中截获用户事件的相关实现，结合控件唯一标识方案，还可以做很多事情（比如无侵入打点等）。

## IQUITestCodeMaker特性

* 无侵入性，不需要开发人员添加额外代码到工程中，你只需要用pod安装一下依赖即可。
* 所有的流程都是自动化的，不需要人为介入，用户的操作事件会被自动截获并生成相关代码。
* 为了让测试结果更准确，强烈建议开发人员手动给控件设置accessibilityIdentifier，通过runtime生成的id并不完全可靠，而且会有一定的性能开销。
* IQUITestCodeMaker默认再DEBUG模式开启，在RELEASE模式关闭。
* 通过Debug Ball，你可以很方便的把脚本导出到桌面，你也可以很方便的进行代码转换。

## 目前支持的语言
- [x] Ruby
- [x] Python
- [x] JavaScript(webdriverio)
- [x] JavaScript(Promise)
- [x] Java
- [ ] Objective-C
- [ ] Swift

## 参考文档
* [Generating UI test label automatically for iOS（腾讯大佬给出的自动生成控件唯一标识的方案）](https://github.com/yulingtianxia/TBUIAutoTest)
* [Appium Server and Inspector in Desktop GUIs for Mac, Windows, and Linux（Appium GUI工具）](https://github.com/appium/appium-desktop)

# 让我们开始吧
## 安装步骤
### 安装cocoapods
```bash
$ gem install cocoapods
```
### 修改Podfile
```
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'

target 'Example' do
    pod 'IQUITestCodeMaker',:git => 'https://github.com/Lobster-King/IQUITestCodeMaker.git',:configurations => ['Debug']
end
```
### 执行命令
```bash
$ pod install
```
### IQUITestCodeMaker.h
```bash
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
```
# 关于Appium
Appium是一个开源的、跨平台的自动化测试框架，目前支持native、hybrid、web、app、模拟器相关的自动化测试。

附一链接：

* [How to install appium ?](https://github.com/appium/appium/blob/master/docs/en/about-appium/getting-started.md)

# IQUITestCodeMaker路线图

* 后续支持Macaca等其他主流框架。
* 支持更多脚本语言。
* 多种UI元素定位策略，目前只支持accessibilityIdentifier。

# 遇到问题？

你可以通过如下的方式联系到我

* 提交PR或者ISSUE。
* 通过Email联系：[zhiwei.geek@gmail.com](mailto:zhiwei.geek@gmail.com)



