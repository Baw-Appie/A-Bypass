//
//  RGELog.m
//  Created on 8/4/19
//

#import "RGELog.h"

#import <os/log.h>
// @import os.log;

@implementation RGELog

+ (void)log:(NSString *)format, ... {
    static os_log_t log;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        const char *identifier = "com.rogue";
        log = os_log_create(identifier, "log");
    });

    va_list ap;
    va_start (ap, format);
    NSString *message = [[NSString alloc] initWithFormat:format arguments:ap];
    va_end (ap);

    os_log(log, "[Rougue] %{public}@", message);
}

@end
