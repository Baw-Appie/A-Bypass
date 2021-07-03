#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>

@interface PSListController (Private)
-(void)insertSpecifier:(id)arg1 atIndex:(long long)arg2 animated:(BOOL)arg3 ;
-(void)removeSpecifierAtIndex:(long long)arg1 animated:(BOOL)arg2 ;

@end

@interface ABPRootListController : PSListController
@property (nonatomic, strong) NSString *livePatchVersion;
@end
