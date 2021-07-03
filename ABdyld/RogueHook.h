//
//  RogueHook.h
//  Created on 8/4/19
//

#import <Foundation/Foundation.h>
// @import Foundation;

NS_ASSUME_NONNULL_BEGIN

@protocol RogueHook <NSObject>

@optional

/// The classes that should be hooked.
@property (class, readonly, nonatomic) NSArray <NSString *> *targetClasses;

/// The class that should be hooked.
@property (class, readonly, nonatomic) NSString *targetClass;

/// Whether hooks should be implemented on load of the library the class is contained within.
/// Defaults to TRUE.
@property (class, readonly, nonatomic) BOOL hookOnLoad;

/// When hookOnLoad is set to FALSE, this method is added to your class so you can hook
/// after loading.
+ (BOOL)hook;

/// Use this to call original class methods.
@property (class, readonly, nonatomic) id original;

/// Use this to call original instance methods.
/// Adheres to protocol RogueInstanceProxy
@property (readonly, nonatomic) id original;

@end

@protocol RogueInstanceProxy

- (BOOL)getVariabledNamed:(NSString *)variable outValue:(void * _Nonnull * _Nullable)outValue;

@end

NS_ASSUME_NONNULL_END
