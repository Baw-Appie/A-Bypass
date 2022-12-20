@interface LSApplicationProxy
-(NSString *)bundleIdentifier;
-(NSString *)localizedName;
-(NSString *)applicationType;
@end

@interface LSApplicationWorkspace : NSObject
+(id)defaultWorkspace;
-(id)allInstalledApplications;
- (void)enumerateApplicationsOfType:(NSUInteger)type block:(void (^)(LSApplicationProxy*))block;
@end

@interface UIImage (Icon)
+(id)_applicationIconImageForBundleIdentifier:(id)arg1 format:(int)arg2 scale:(double)arg3;
@end

NSArray *getAllInstalledApplications();