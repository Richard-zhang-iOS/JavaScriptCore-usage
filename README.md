# JavaScriptCore C API 详细解析

## JavaScriptCore介绍

JavaScriptCore 是 JavaScript 引擎，通常会被叫做虚拟机，专门设计来解释和执行 JavaScript 代码，可以理解为一个浏览器的运行内核。

JavaScriptCore Framework 是 iOS7 引入的新功能，其实就是基于 Webkit 中以 C/C++ 实现的 JavaScriptCore 的一个封装,大多数 iOS 比较熟悉的是它的 Objective-C API，可以用简介的方式 JS 与Native 通讯，其实它还有C API的部分，虽然也是开源的，但是在查看源代码时只有较少的介绍，而且我们知道 Objective-C API 只是 C API 接口的封装。本文主要介绍 C API 部分，帮助大家更好理解 JavaScriptCore Framework。

## JavaScriptCore C API

JavaScriptCore C API 部分包含六个类 下面我们详细解释每个类的作用及用法

- ##### JSBase.h

  JavaScriptCore 的接口文件，这个类中 import 了其他的类，简单封装了其他的 C API。

- ##### JSContextRef.h

  JSContextRef 相当于 Objective-C 中的 JSContext，主要提供 JS 执行的上下文环境。

- ##### JSObjectRef.h

  JSObjectRef 相当于 Objective-C 中的 JSObject，它代表一个JavaScript对象，交互的核心放在都在这个类中实现。

- ##### JSStringRef.h

  是 JavaScript 中基本的字符串表示形式。

- ##### JSStringRefCF.h

  包含 CFString 便利的方法。

- ##### JSValueRef.h

  JSValueRef 相当于 Objective-C 中的 JSValue ，对应一个 JavaScript 的值，它是所有JavaScript值的基本类型

### JSBase.h

定义了 JavaScriptCore 接口文件 ，主要提供了三个方法 

```
//检查JavaScript 字符串中的语法错误。
bool JSCheckScriptSyntax(JSContextRef ctx, JSStringRef script, JSStringRef sourceURL, int startingLineNumber, JSValueRef *exception);

//执行一段js语句
JSValueRef JSEvaluateScript(JSContextRef ctx, JSStringRef script, JSObjectRef thisObject, JSStringRef sourceURL, int startingLineNumber, JSValueRef *exception);

//执行JavaScript GC  在JavaScript执行期间，一般不需要调用此函数; JavaScript 引擎将根据需要进行垃圾回收，在释放对上下文组的最后一个引用时，将自动销毁在上下文组中创建的JavaScript值。
void JSGarbageCollect(JSContextRef ctx);
```

### JSContextRef.h

主要提供 JS 执行所需所有资源和环境

```
//获取全局的 globalObject 对象，该对象将全局的 JavaScript 设置为跟对象，因此我们可以将我们自己的对象定义为 JavaScript 执行环境。
JSObjectRef JSContextGetGlobalObject(JSContextRef ctx);

// contextGroup 对象提供了虚拟机的功能 简单类比 JSVirtualMachine 但是需要自己管理内存。
JSContextGroupRef JSContextGetGroup(JSContextRef ctx);
JSContextGroupRef JSContextGroupCreate(void);
void JSContextGroupRelease(JSContextGroupRef group);
JSContextGroupRef JSContextGroupRetain(JSContextGroupRef group);

//globalContext对象是提供执行 js 的环境 简单类比 JSContext
JSGlobalContextRef JSGlobalContextCreate(JSClassRef globalObjectClass);//crete
JSGlobalContextRef JSGlobalContextCreateInGroup(JSContextGroupRef group, JSClassRef globalObjectClass);//CreateInGroup
void JSGlobalContextRelease(JSGlobalContextRef ctx);//relase
JSGlobalContextRef JSGlobalContextRetain(JSGlobalContextRef ctx);//retain
```

### JSObjectRef.h

是一个 JavaScript 对象，主要提供了两部分API，一部分是创建 JS 对象，还有一部分是给创建的 JS 对象添加对应的 Callback。

#### Functions

```
// 创建 JavaScript 类 JSClassCreate JSClassRelease JSClassRetain
JSClassRef JSClassCreate(const JSClassDefinition *definition);

JSObjectMake //创建 JavaScript 对象
JSObjectMakeArray //创建数组
JSObjectMakeConstructor
JSObjectMakeDate 、
JSObjectMakeError
JSObjectMakeFunction
JSObjectMakeRegExp

//JavaScript 对象作为构造函数来调用
JSObjectRef JSObjectCallAsConstructor(JSContextRef ctx, JSObjectRef object, size_t argumentCount, const JSValueRef arguments[], JSValueRef *exception);

//JavaScript 对象作为方法来调用
JSValueRef JSObjectCallAsFunction(JSContextRef ctx, JSObjectRef object, JSObjectRef thisObject, size_t argumentCount, const JSValueRef arguments[], JSValueRef *exception);

JSObjectCopyPropertyNames //获取对象的所有可枚举属性
JSObjectDeleteProperty //从对象中删除属性

//对 JS 对象的 Private、Property、Prototype 操作
JSObjectGetPrivate JSObjectSetPrivate
JSObjectGetProperty JSObjectSetProperty
JSObjectGetPrototype JSObjectSetPrototype
JSObjectGetPropertyAtIndex JSObjectSetPropertyAtIndex

//对 JS 对象的属性名的操作
JSPropertyNameArrayRetain
JSPropertyNameArrayRelease
JSPropertyNameArrayGetNameAtIndex
JSPropertyNameArrayGetCount
JSPropertyNameAccumulatorAddName

//JS对象条件判断
JSObjectHasProperty //是否有属性
JSObjectIsFunction // 是否是一个方法
JSObjectIsConstructor // 是否是构造函数

```

#### callBacks

在创建一个JS对象的同时，可以给该对象设置对应的callback，例如可以在先创建一个function`JSObjectMakeFunction`，同时设置该方法被调用的callback `JSObjectCallAsFunctionCallback`最后调用该方法 `JSObjectCallAsFunction`此时callback设置的方法就会响应 

上述所有创建对象的方法都有对应的callback可以设置，我们可以灵活的使用这些方法

如

```
Type Alias JSObjectCallAsConstructorCallback //当该对象被座位构造函数调用是响应callback
typedef JSObjectRef (*JSObjectCallAsConstructorCallback)(JSContextRef ctx, JSObjectRef constructor, size_t argumentCount, const JSValueRef arguments[], JSValueRef *exception);

JSObjectCallAsFunctionCallback
typedef JSValueRef (*JSObjectCallAsFunctionCallback)(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount, const JSValueRef arguments[], JSValueRef *exception);

```

### JSValueRef.h

一个 JavaScript 值，提供用Object-C的基础数据类型来创建 JS 的值，或者将JS 的值转变为OC的基础数据类型

```
//获取JavaScript值类型
JSValueGetType

//OC基础数据创建JS的值
JSValueCreateJSONString
JSValueMakeBoolean
JSValueMakeFromJSONString
JSValueMakeNull
JSValueMakeNumber
JSValueMakeString
JSValueMakeUndefined

//JS值转变为OC基础数据
JSValueToBoolean
JSValueToNumber
JSValueToObject
JSValueToStringCopy

//存储JSValue
JSValueProtect
JSValueUnprotect

//比较判断JavaScript值类型
JSValueIsBoolean
JSValueIsNull
JSValueIsNumber
JSValueIsObject
JSValueIsObjectOfClass
JSValueIsStrictEqual
JSValueIsString
JSValueIsUndefined
JSValueIsEqual
JSValueIsInstanceOfConstructor

```

### JSStringRef.h

JavaScript 对象中字符串对象，公开的api包括如下

```
JSStringCreateWithCharacters 
JSStringCreateWithUTF8CString
JSStringGetCharactersPtr
JSStringGetLength
JSStringGetMaximumUTF8CStringSize
JSStringGetUTF8CString
JSStringIsEqual
JSStringIsEqualToUTF8CString
JSStringRelease
JSStringRetain
```

### JSStringRefCF.h

CFString 与  JavaScript string 相互转化

```
CFStringRef JSStringCopyCFString(CFAllocatorRef alloc, JSStringRef string);
JSStringRef JSStringCreateWithCFString(CFStringRef string);
```



## 测试Demo

上面介绍完整个JavaScriptCore C API部分，下面我们通过一个demo来详细分析如何使用这些api

```
#import "ViewController.h"
#import <JavaScriptCore/JavaScriptCore.h>

JSValueRef ObjectGetPropertyCallback(JSContextRef ctx, JSObjectRef object, JSStringRef propertyName, JSValueRef *exception){
     NSLog(@"ObjectGetPropertyCallback");
    return nil;
};

JSValueRef ObjectCallAsFunctionCallback(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount, const JSValueRef arguments[], JSValueRef* exception) {
     NSLog(@"ObjectCallAsFunctionCallback");
    return JSValueMakeUndefined(ctx);
}

void ObjectConstructorFinalize(JSObjectRef object) {
   NSLog(@"ObjectConstructorFinalize");
}

bool ObjectConstructorHasInstance(JSContextRef ctx, JSObjectRef constructor, JSValueRef possibleInstance, JSValueRef* exception) {
    NSLog(@"ObjectConstructorHasInstance");
    return nil;
}

JSObjectRef ObjectCallAsConstructor(JSContextRef ctx, JSObjectRef constructor, size_t argc, const JSValueRef argv[], JSValueRef* exception) {
     NSLog(@"ObjectCallAsConstructor");
    return nil;
}

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    JSContextGroupRef contextGroup = JSContextGroupCreate();
    JSGlobalContextRef globalContext = JSGlobalContextCreateInGroup(contextGroup, nil);
    JSObjectRef globalObject = JSContextGetGlobalObject(globalContext);
    
    JSClassDefinition constructorClassDef = kJSClassDefinitionEmpty;
    constructorClassDef.getProperty = ObjectGetPropertyCallback;
    constructorClassDef.callAsFunction = ObjectCallAsFunctionCallback;
    constructorClassDef.callAsConstructor = ObjectCallAsConstructor;
    constructorClassDef.hasInstance = ObjectConstructorHasInstance;
    constructorClassDef.finalize = ObjectConstructorFinalize;
  
    JSClassRef loaderClass = JSClassCreate(&constructorClassDef);
    
    JSObjectRef loader = JSObjectMake(globalContext, loaderClass, (__bridge void *)(self.view));
    JSStringRef logFunctionName = JSStringCreateWithUTF8CString("log");
    JSObjectSetProperty(globalContext, globalObject, logFunctionName, loader, kJSPropertyAttributeNone, nil);
    
    JSStringRef logCallStatement = JSStringCreateWithUTF8CString("log()");
    
    JSEvaluateScript(globalContext, logCallStatement, nil, nil, 1,nil);
    
    /* memory management code to prevent memory leaks */
    
    JSGlobalContextRelease(globalContext);
    JSContextGroupRelease(contextGroup);
    JSStringRelease(logFunctionName);
    JSStringRelease(logCallStatement);
}



```

执行结果

`2018-07-02 20:29:47.485072+0800  ObjectCallAsFunctionCallback`

`2018-07-02 20:29:47.485290+0800  ObjectGetPropertyCallback`

`2018-07-02 20:29:47.489448+0800  ObjectConstructorFinalize`

下面我们详细分析这段代码

```
contextGroup 是JS执行的虚拟机，后续所有的一切基于它来进行

globalContext 是JavaScript的执行环境，第一个参数数虚拟机，第二个参数是nil，是使用默认的类来作为跟对象

globalObject 获取全局的 globalObject 对象

constructorClassDef 定义一个 JavaScript 类，同时设置该类的特殊事件的callback 如getProperty、callAsFunction

loaderClass 创建一个 JavaScript 类

loader  通过 JavaScript 类 创建一个 JavaScript 对象

JSObjectSetProperty  给全局的 globalObject 对象设置关联信息 @“log”

JSEvaluateScript 执行log方法

JSObjectSetProperty  给全局的 globalObject 对象设置class 

JSEvaluateScript 调用 class 的 方法

```

github地址: https://github.com/Richard-zhang-iOS/JavaScriptCore-C-Demo 原创不易，欢迎star