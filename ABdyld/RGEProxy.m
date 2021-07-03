//
//  RGEProxy.m
//  Created on 10/18/19
//

#import "RGEProxy.h"
#import "RGELog.h"
#import <objc/runtime.h>
// @import ObjectiveC.runtime;

@implementation RGEProxy

- (instancetype)initWithTarget:(id)target {
    self = [super init];
    if (self) {
        _target = target;
    }
    return self;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    return [self.target methodSignatureForSelector:aSelector];
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    SEL aSelector = [invocation selector];
    NSString *targetMethodName = NSStringFromSelector(aSelector);

    NSString *originalStorePrefix = @"original_";

    NSString *originalStoreMethodName = [originalStorePrefix stringByAppendingString:targetMethodName];
    SEL originalStoreSelector = NSSelectorFromString(originalStoreMethodName);

    if ([self.target respondsToSelector:originalStoreSelector]) {
        invocation.selector = originalStoreSelector;
        [invocation invokeWithTarget:self.target];
    } else {
        [self.target forwardInvocation:invocation];
    }
}

- (BOOL)getVariabledNamed:(NSString *)variable outValue:(void **)outValue {
    return [self.class instance:self.target getVariabledNamed:variable outValue:outValue];
}

+ (BOOL)instance:(id)target getVariabledNamed:(NSString *)variable outValue:(void **)outValue {
    if (!target) {
        return FALSE;
    }

    uint32_t ivarCount;
    Ivar *ivars = class_copyIvarList([target class], &ivarCount);
    if (!ivars) {
        [RGELog log:@"Failed to copy ivar list for %@", NSStringFromClass([target class])];
        return FALSE;
    }

    const char *variableNameCString = variable.UTF8String;
    for(uint32_t index = 0; index < ivarCount; index += 1) {
        Ivar ivar = ivars[index];
        if (strcmp(ivar_getName(ivar), variableNameCString) != 0) {
            continue;
        }
        *outValue = (__bridge void *)object_getIvar(target, ivar);
        free(ivars);
        return TRUE;
    }

    [RGELog log:@"Failed to find ivar %@", variable];
    free(ivars);
    return FALSE;
}

+ (id)instance:(id)target getObjectVariabledNamed:(NSString *)variable {
    if (!target) {
        [RGELog log:@"-instance:getObjectVariabledNamed: passed NULL target for %@", variable];
        return nil;
    }

    uint32_t ivarCount;
    Ivar *ivars = class_copyIvarList([target class], &ivarCount);
    if (!ivars) {
        [RGELog log:@"Failed to copy ivar list for %@", NSStringFromClass([target class])];
        return nil;
    }

    const char *variableNameCString = variable.UTF8String;
    for(uint32_t index = 0; index < ivarCount; index += 1) {
        Ivar ivar = ivars[index];
        if (strcmp(ivar_getName(ivar), variableNameCString) != 0) {
            continue;
        }
        id value = NULL;
        value = object_getIvar(target, ivar);
        free(ivars);
        return value;
    }

    [RGELog log:@"Failed to find ivar %@", variable];
    free(ivars);
    return nil;
}

@end
