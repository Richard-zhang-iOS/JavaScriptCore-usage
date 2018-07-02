//
//  ViewController.m
//  JavaScriptCoreDemo
//
//  Created by yanqiang zhang on 02/07/2018.
//  Copyright © 2018 www.iqiyi.com. All rights reserved.
//

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
  //  JSObjectRef globalObject = JSContextGetGlobalObject(globalContext);
    
    JSClassDefinition constructorClassDef = kJSClassDefinitionEmpty;
    constructorClassDef.getProperty = ObjectGetPropertyCallback;
    constructorClassDef.callAsFunction = ObjectCallAsFunctionCallback;
    constructorClassDef.callAsConstructor = ObjectCallAsConstructor;
    constructorClassDef.hasInstance = ObjectConstructorHasInstance;
    constructorClassDef.finalize = ObjectConstructorFinalize;
    
    JSClassRef loaderClass = JSClassCreate(&constructorClassDef);
    
    JSObjectRef globalObject = JSContextGetGlobalObject(globalContext);
    
    JSStringRef logFunctionName = JSStringCreateWithUTF8CString("log");
    JSObjectRef functionObject = JSObjectMakeFunctionWithCallback(globalContext, logFunctionName, &ObjectCallAsFunctionCallback);

    
    JSObjectSetProperty(globalContext, globalObject, logFunctionName, functionObject, kJSPropertyAttributeNone, nil);
    
    JSStringRef logCallStatement = JSStringCreateWithUTF8CString("log()");
    JSEvaluateScript(globalContext, logCallStatement, nil, nil, 1,nil);
    
    
    JSObjectRef loader = JSObjectMake(globalContext, loaderClass, (__bridge void *)(self.view));
    JSStringRef myclass = JSStringCreateWithUTF8CString("myclass");
    JSObjectSetProperty(globalContext, globalObject, myclass, loader, kJSPropertyAttributeNone, nil);
    
    JSStringRef callMyclass = JSStringCreateWithUTF8CString("myclass.start()");
    JSEvaluateScript(globalContext, callMyclass, nil, nil, 1,nil);
    
  //  JSEvaluateScript(globalContext, logCallStatement, nil, nil, 1,nil);
    
    /* memory management code to prevent memory leaks */
    
    JSGlobalContextRelease(globalContext);
    JSContextGroupRelease(contextGroup);
    JSStringRelease(logFunctionName);
    JSStringRelease(logCallStatement);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
