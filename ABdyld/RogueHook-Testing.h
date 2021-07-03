//
//  RogueHook-Testing.h
//  Created on 8/4/19
//

@interface RogueHookImplementor : NSObject

+ (const char *)currentImage;

+ (BOOL)implementAllMethodHooksForImage:(const char *)image;

@end
