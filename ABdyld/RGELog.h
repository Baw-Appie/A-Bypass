//
//  RGELog.h
//  Created on 8/4/19
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RGELog : NSObject

+ (void)log:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2);

@end

NS_ASSUME_NONNULL_END
