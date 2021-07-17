//
//  RogueHook.m
//  Created on 8/4/19
//

#import <Foundation/Foundation.h>
// @import Foundation;
#import <objc/runtime.h>
// @import ObjectiveC.runtime;
#import <mach-o/dyld.h>
// @import MachO.dyld;
#import <dlfcn.h>
// @import Darwin.POSIX.dlfcn;

#import "RogueHook.h"
#import "RogueHook-Testing.h"
#import "RGELog.h"
#import "RGEProxy.h"

@implementation RogueHookImplementor

static __attribute__((constructor))
void ctor() {
    hookProtocol = @protocol(RogueHook);
    // dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [RogueHookImplementor implementAllMethodHooksForCurrentImage];
    // });
}


static Protocol *hookProtocol;

// + (void)load {
//     hookProtocol = @protocol(RogueHook);
//     dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//         [self implementAllMethodHooksForCurrentImage];
//     });

// }

+ (BOOL)implementAllMethodHooksForCurrentImage {
    const char *image = [self currentImage];
    if (!image) {
        [RGELog log:@"Couldn't find image for class %@", NSStringFromClass(self.class)];
        return FALSE;
    }

    return [self implementAllMethodHooksForImage:image];
}

+ (BOOL)implementAllMethodHooksForImage:(const char *)image {
    unsigned int classCount = 0;
    const char **classNames;
    classNames = objc_copyClassNamesForImage(image, &classCount);

    for (unsigned int index = 0; index < classCount; index += 1) {
        const char *className = classNames[index];
        Class metaClass = objc_getMetaClass(className);
        if (!metaClass) {
            [RGELog log:@"Couldn't get MetaClass %s", className];
            continue;
        }

        Class hookClass = objc_getClass(className);
        if (!hookClass) {
            [RGELog log:@"Couldn't get class %s", className];
            continue;
        }

        if (class_conformsToProtocol(hookClass, hookProtocol) == FALSE) {
            continue;
        }
        [self implementHooksForMetaClassOnLoad:metaClass hookClass:hookClass className:className];
    }

    free(classNames);
    return TRUE;
}

// MARK: - Hooking

+ (BOOL)implementHooksForMetaClassOnLoad:(Class)metaClass
                               hookClass:(Class)hookClass
                               className:(const char *)className {
    if ([hookClass respondsToSelector:@selector(hookOnLoad)]) {
        if ([hookClass hookOnLoad] == FALSE) {
            Method hookMethod = class_getClassMethod(self.class, @selector(hookClass_hook));
            [self addMethodToClass:metaClass fromClass:self.class method:hookMethod newName:@selector(hook)];
            return FALSE;
        }
    }

    [self implementHooksForMetaClass:metaClass hookClass:hookClass className:className];
    return TRUE;
}

+ (BOOL)implementHooksForClass:(Class)targetClass {
    const char *className = class_getName(targetClass);
    Class metaClass = objc_getMetaClass(className);
    Class hookClass = objc_getClass(className);
    return [self implementHooksForMetaClass:metaClass hookClass:hookClass className:className];
}

+ (BOOL)implementHooksForMetaClass:(Class)metaClass
                         hookClass:(Class)hookClass
                         className:(const char *)classNameCString {
    NSString *className = @(classNameCString);

    NSArray *targetClasses;
    NSString *hookClassPrefix = @"HOOK_";
    if ([hookClass respondsToSelector:@selector(targetClasses)]) {
        targetClasses = [hookClass targetClasses];
    } else if ([hookClass respondsToSelector:@selector(targetClass)]) {
        targetClasses = @[[hookClass targetClass]];
    } else if ([className hasPrefix:hookClassPrefix]) {
        targetClasses = @[[className substringFromIndex:hookClassPrefix.length]];
    } else {
        [RGELog log:@"%@ must implement a target class method.", className];
        return FALSE;
    }

    for (NSString *targetClassName in targetClasses) {
        void (^handleHook)(Class targetClass) = ^(Class targetClass) {
            [RGELog log:@"Class: %@, target: %@", className, targetClassName];
            [self implementMethodHooksForClass:hookClass
                                   isMetaClass:FALSE
                                   targetClass:targetClass
                                     className:className.UTF8String];
            Class targetMetaClass = objc_getMetaClass(class_getName(targetClass));
            if (!targetMetaClass) {
                return;
            }

            [self implementMethodHooksForClass:metaClass
                                   isMetaClass:TRUE
                                   targetClass:targetMetaClass
                                     className:className.UTF8String];
        };

        Class targetClass = objc_getClass(targetClassName.UTF8String);
        if (!targetClass) {
            [RGELog log:@"Couldn't find target class %@, trying in 2 seconds", targetClassName];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                Class targetClass = objc_getClass(targetClassName.UTF8String);
                if (targetClass) {
                    handleHook(targetClass);
                }
            });
            continue;
        }

        handleHook(targetClass);
    }

    return TRUE;
}

+ (void)implementMethodHooksForClass:(Class)hookClass
                         isMetaClass:(BOOL)isMetaClass
                         targetClass:(Class)targetClass
                           className:(const char *)className {
    unsigned int methodCount;
    Method *methods = class_copyMethodList(hookClass, &methodCount);
    if (!methods) {
        [RGELog log:@"Couldn't get method list for class: %s", className];
        return;
    }

    Method originalMethod = class_getClassMethod(self.class, @selector(targetClass_original));
    [self addMethodToClass:targetClass fromClass:self.class method:originalMethod newName:@selector(original)];

    NSArray <NSString *> *blacklistedMethods = @[@".cxx_destruct"];

    for (unsigned int methodIndex = 0; methodIndex < methodCount; methodIndex += 1) {
        Method hookMethod = methods[methodIndex];
        if (!hookMethod) {
            [RGELog log:@"Unable to get method at index: %d", methodIndex];
            continue;
        }

        SEL hookMethodSelector = method_getName(hookMethod);
        if (!hookMethodSelector) {
            [RGELog log:@"Unable to get method method name index: %d", methodIndex];
            continue;
        }

        NSString *hookMethodName = NSStringFromSelector(hookMethodSelector);

        if ([blacklistedMethods containsObject:hookMethodName]) {
            continue;
        }

        NSString *originalStorePrefix = @"original_";
        if ([hookMethodName hasPrefix:originalStorePrefix]) {
            continue;
        }

        NSString *targetMethodName = hookMethodName;
        SEL targetMethodSelector = NSSelectorFromString(targetMethodName);
        Method targetMethod = class_getInstanceMethod(targetClass, targetMethodSelector);

        BOOL isHookProtocolMethod = FALSE;
        BOOL isInstance = isMetaClass == FALSE;
        struct objc_method_description protocolMethod;
        protocolMethod = protocol_getMethodDescription(hookProtocol, targetMethodSelector, FALSE, isInstance);
        isHookProtocolMethod = protocolMethod.name != NULL;

        if (isHookProtocolMethod) {
            continue;
        }

        if (targetMethod == NULL) {
            [self addMethodToClass:targetClass fromClass:hookClass method:hookMethod];
            continue;
        }

        const char *targetTypeEncoding = method_getTypeEncoding(targetMethod);
        const char *hookedTypeEncoding = method_getTypeEncoding(hookMethod);
        if (strcmp(targetTypeEncoding, hookedTypeEncoding) != 0) {
            [RGELog log:@"Error: Not implementing hook: target type encoding %s doesn't match hook type encoding: %s for selector %s",
             targetTypeEncoding, hookedTypeEncoding, sel_getName(targetMethodSelector)];
            // return;
        }

        IMP hookImplementation = method_getImplementation(hookMethod);
        if (!hookImplementation) {
            [RGELog log:@"Error: Couldn't get implementation for method %@", hookMethodName];
            continue;
        }

        NSString *originalStoreMethodName = [originalStorePrefix stringByAppendingString:targetMethodName];
        SEL originalStoreSelector = NSSelectorFromString(originalStoreMethodName);
        class_getClassMethod(hookClass, originalStoreSelector);

        IMP originalImplementation = method_getImplementation(targetMethod);
        if (!originalImplementation) {
            [RGELog log:@"Error: Couldn't get implementation for method %@", targetMethodName];
            continue;
        }

        class_addMethod(targetClass, originalStoreSelector, originalImplementation, targetTypeEncoding);

        IMP previousImplementation = class_replaceMethod(targetClass,
                                                         targetMethodSelector,
                                                         hookImplementation,
                                                         targetTypeEncoding);
        if (previousImplementation != NULL) {
            [RGELog log:@"Implemented hook for [%s %@]", class_getName(targetClass), targetMethodName];
        } else {
            [RGELog log:@"Failed to implement hook for [%s %@]", class_getName(targetClass), targetMethodName];
        }

    }

    free(methods);
}

+ (void)addMethodToClass:(Class)targetClass fromClass:(Class)fromClass method:(Method)method {
    [self addMethodToClass:targetClass fromClass:fromClass method:method newName:NULL];
}

+ (void)addMethodToClass:(Class)targetClass fromClass:(Class)fromClass method:(Method)method newName:(SEL)name {
    SEL selector;
    if (name) {
        selector = name;
    } else {
        selector = method_getName(method);
    }

    [RGELog log:@"Adding method %s to class: %s", sel_getName(selector), class_getName(targetClass)];

    const char *typeEncoding = method_getTypeEncoding(method);
    IMP implementation = method_getImplementation(method);
    class_addMethod(targetClass, selector, implementation, typeEncoding);
}

// MARK: - Utilities

+ (const char *)currentImage {
    static int imageSymbolMarker = 1;

    static int DLADDR_ERROR = 0;
    Dl_info result;
    if (dladdr(&imageSymbolMarker, &result) == DLADDR_ERROR) {
        return nil;
    }

    return result.dli_fname;
}

// MARK: - Methods Added To Hook Classes

+ (BOOL)hookClass_hook {
    id <RogueHook> target = (id)self;
    return [RogueHookImplementor implementHooksForClass:target.class];
}

+ (id)targetClass_original {
    return [[RGEProxy alloc] initWithTarget:self];
}

@end

