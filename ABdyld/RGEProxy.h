//
//  RGEProxy.h
//  Created on 10/18/19
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RGEProxy : NSObject

@property (nonatomic, assign) id target;

- (instancetype)initWithTarget:(id)target;

+ (BOOL)instance:(id)target getVariabledNamed:(NSString *)variable outValue:(void * _Nonnull * _Nullable)outValue;
+ (id)instance:(id)target getObjectVariabledNamed:(NSString *)variable;

@end

NS_ASSUME_NONNULL_END
