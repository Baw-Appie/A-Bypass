#import <UIKit/UIKit.h>
#import <MRYIPCCenter.h>
#import <dlfcn.h>
#import <AppList/AppList.h>
#include <unistd.h>
#include <CommonCrypto/CommonDigest.h>
#include <spawn.h>
#include <errno.h>
#import <mach-o/getsect.h>
#import <mach/mach.h>
#import <mach-o/dyld.h>
#import <substrate.h>
#import <Foundation/Foundation.h>
#import <sys/types.h>
#import <sys/syscall.h>
#include <sys/stat.h>
#include <sys/sysctl.h>
#include <sys/mount.h>
#import <APToast.h>
#import "header.h"
#import "ABWindow.h"

BOOL isSubstitute = ([[NSFileManager defaultManager] fileExistsAtPath:@"/usr/lib/libsubstitute.dylib"] && ![[NSFileManager defaultManager] fileExistsAtPath:@"/usr/lib/substrate"]) && ![[NSFileManager defaultManager] fileExistsAtPath:@"/usr/lib/libhooker.dylib"];
const char *DisableLocation = "/var/tmp/.substitute_disable_loader";

static BBServer *bbServer = nil;
static MRYIPCCenter* center;
NSArray *disableIdentifiers;
NSArray *subloader;
float iosVersion;

static void easy_spawn(const char* args[]) {
    pid_t pid;
    int status;
    posix_spawn(&pid, args[0], NULL, NULL, (char* const*)args, NULL);
    waitpid(pid, &status, WEXITED);
}

static dispatch_queue_t getBBServerQueue() {
	static dispatch_queue_t queue;
	static dispatch_once_t predicate;
	dispatch_once(&predicate, ^{
		void *handle = dlopen(NULL, RTLD_GLOBAL);
		if (handle) {
			dispatch_queue_t *pointer = (dispatch_queue_t *) dlsym(handle, "__BBServerQueue");
			if (pointer) {
				queue = *pointer;
			}
			dlclose(handle);
		}
	});
	return queue;
}
static void fakeNotification(NSString *sectionID, NSString *title, NSString *message) {
    BBBulletin *bulletin = [[%c(BBBulletin) alloc] init];
    NSDate *date = [NSDate date];

    bulletin.title = title;
    bulletin.message = message;
    bulletin.sectionID = sectionID;
    bulletin.bulletinID = [[NSProcessInfo processInfo] globallyUniqueString];
    bulletin.recordID = [[NSProcessInfo processInfo] globallyUniqueString];
    bulletin.publisherBulletinID = [[NSProcessInfo processInfo] globallyUniqueString];
    bulletin.date = date;
    bulletin.defaultAction = [%c(BBAction) actionWithLaunchBundleID:sectionID callblock:nil];
    bulletin.clearable = YES;
    bulletin.showsMessagePreview = YES;
    bulletin.publicationDate = date;
    bulletin.lastInterruptDate = date;

    if ([bbServer respondsToSelector:@selector(publishBulletin:destinations:)]) {
        dispatch_sync(getBBServerQueue(), ^{
            [bbServer publishBulletin:bulletin destinations:15];
        });
    }
}

%group SpringBoard
%hook BBServer
-(id)initWithQueue:(id)arg1 {
    bbServer = %orig;
    return bbServer;
}
-(id)initWithQueue:(id)arg1 dataProviderManager:(id)arg2 syncService:(id)arg3 dismissalSyncCache:(id)arg4 observerListener:(id)arg5 utilitiesListener:(id)arg6 conduitListener:(id)arg7 systemStateListener:(id)arg8 settingsListener:(id)arg9 {
    bbServer = %orig;
    return bbServer;
}
- (void)dealloc {
  if (bbServer == self) bbServer = nil;
  %orig;
}
%end

extern "C" CFPropertyListRef MGCopyAnswer(CFStringRef property);

@interface SpringBoard
@property (nonatomic, strong) MRYIPCCenter *centerForABypass;
@property (nonatomic, strong) APLoadingToast *loadingToastForABypass;
@end
%hook SpringBoard
%property (strong) MRYIPCCenter *centerForABypass;
%property (strong) APLoadingToast *loadingToastForABypass;
-(void)applicationDidFinishLaunching:(id)application {
  %orig;

  self.centerForABypass = [MRYIPCCenter centerNamed:@"com.rpgfarm.a-bypass"];
  [self.centerForABypass addTarget:self action:@selector(handleShowNotification:)];
  [self.centerForABypass addTarget:self action:@selector(handleUpdateLicense:)];

  self.loadingToastForABypass = [[objc_getClass("APLoadingToast") alloc] initWithView:[[ABWindow sharedInstance] rootViewController].view];
}

%new
-(void)handleShowNotification:(NSDictionary *)userInfo {
  fakeNotification(userInfo[@"identifier"], userInfo[@"title"], userInfo[@"message"]);
}

%new
-(NSDictionary *)handleUpdateLicense:(NSDictionary *)userInfo {
  NSError *error = nil;
  #ifndef DEBUG
  if([userInfo[@"type"] isEqual:@1]) {
    NSString *server = @"i.repo.co.kr";
    NSMutableDictionary *plistDict = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.rpgfarm.abypassprefs.plist"];
    if(plistDict[@"licenseServer"]) server = plistDict[@"licenseServer"];
    NSString *udid = (__bridge NSString *)MGCopyAnswer(CFSTR("UniqueDeviceID"));
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setHTTPMethod:@"GET"];
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://%@/file/A-Bypass/getLicense?udid=%@&bundleID=%@&version=5", server, udid, userInfo[@"identifier"]]]];
    [request setTimeoutInterval:3.0];
    NSHTTPURLResponse *responseCode = nil;
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wdeprecated-declarations"
    NSData *oResponseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&responseCode error:&error];
    #pragma clang diagnostic pop
    if(error) return @{@"success": @0, @"message": [error localizedDescription], @"errno": @1};
    [oResponseData writeToFile:@"/Library/BawAppie/ABypass/ABLicense" options:0 error:&error];
    if(error) return @{@"success": @0, @"message": [error localizedDescription], @"errno": @2};
  } else if([userInfo[@"type"] isEqual:@2]) {
    [[NSFileManager defaultManager] removeItemAtPath:@"/Library/BawAppie/ABypass/ABLoader" error:&error];
  } else
  #endif
  if([userInfo[@"type"] isEqual:@3]) {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^() {
      dispatch_async(dispatch_get_main_queue(), ^() {
        [self.loadingToastForABypass showToast:@"Loading A-Bypass" withMessage:[NSString stringWithFormat:@"0/%@ Completed", userInfo[@"max"]]];
      });
    });
  } else if([userInfo[@"type"] isEqual:@4]) {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^() {
      dispatch_async(dispatch_get_main_queue(), ^() {
        [self.loadingToastForABypass setPercent:[userInfo[@"per"] doubleValue]/[userInfo[@"max"] doubleValue]];
        self.loadingToastForABypass.subtitleLabel.text = [NSString stringWithFormat:@"%@/%@ Completed", userInfo[@"per"], userInfo[@"max"]];
      });
    });
  } else if([userInfo[@"type"] isEqual:@5]) {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^() {
      dispatch_async(dispatch_get_main_queue(), ^() {
        [self.loadingToastForABypass hideToast];
      });
    });
  }
  if(error) return @{@"success": @0, @"message": [error localizedDescription]};
  return @{@"success": @1};
}
%end


%hook _SBApplicationLaunchAlertInfo
-(NSString *)bundleID {
  if (isSubstitute && access(DisableLocation, F_OK) != -1) remove(DisableLocation);
  return %orig;
}
%end

%hook FBProcessManager
- (id)_createProcessWithExecutionContext:(FBProcessExecutionContext *)executionContext {
  NSString *bundleID = executionContext.identity.embeddedApplicationIdentifier;
  NSMutableDictionary* environmentM = [executionContext.environment mutableCopy];
  NSMutableDictionary *plistDict = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.rpgfarm.abypassprefs.plist"];
  if(![plistDict[bundleID] isEqual:@1]) return %orig;
  if([subloader containsObject:bundleID]) [environmentM setObject:@"/usr/lib/ABSubLoader.dylib" forKey:@"DYLD_INSERT_LIBRARIES"];
  if([disableIdentifiers containsObject:bundleID]) {
    [environmentM setObject:@"/usr/lib/ABDYLD.dylib" forKey:@"DYLD_INSERT_LIBRARIES"];
    if(isSubstitute) {
      fopen(DisableLocation, "w");
    } else {
      [environmentM setObject:@(1) forKey:@"_MSSafeMode"];
      [environmentM setObject:@(1) forKey:@"_SafeMode"];
    }
  }
  executionContext.environment = [environmentM copy];
  return %orig(executionContext);
}

-(id)createApplicationProcessForBundleID:(NSString *)bundleID withExecutionContext:(FBProcessExecutionContext*)executionContext {
  NSMutableDictionary* environmentM = [executionContext.environment mutableCopy];
  NSMutableDictionary *plistDict = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.rpgfarm.abypassprefs.plist"];
  if(![plistDict[bundleID] isEqual:@1]) return %orig;
  if([subloader containsObject:bundleID]) [environmentM setObject:@"/usr/lib/ABSubLoader.dylib" forKey:@"DYLD_INSERT_LIBRARIES"];
  if([disableIdentifiers containsObject:bundleID]) {
    [environmentM setObject:@"/usr/lib/ABDYLD.dylib" forKey:@"DYLD_INSERT_LIBRARIES"];
    if(isSubstitute) {
      fopen(DisableLocation, "w");
    } else {
      [environmentM setObject:@(1) forKey:@"_MSSafeMode"];
      [environmentM setObject:@(1) forKey:@"_SafeMode"];
    }
  }
  executionContext.environment = [environmentM copy];
  return %orig(bundleID, executionContext);
}

%end

%end

%ctor {
  HBLogError(@"Hello! Jailbreak Detection! A-Bypass is Loading...");
  HBLogError(@"A-Bypass by Baw Appie <pp121324@gmail.com>");

	NSString *identifier = [NSBundle mainBundle].bundleIdentifier;
	NSMutableDictionary *plistDict = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.rpgfarm.abypassprefs.plist"];
  center = [MRYIPCCenter centerNamed:@"com.rpgfarm.a-bypass"];

	if([identifier isEqualToString:@"com.apple.springboard"]) {
    dlopen("/usr/local/lib/libAPToast.dylib", RTLD_NOW);

    NSData *data = [NSData dataWithContentsOfFile:@"/var/mobile/Library/Preferences/ABPattern" options:0 error:nil];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];

    iosVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
    disableIdentifiers = [dic[@"disableIdentifiers"] copy];
    subloader = [dic[@"subloader"] copy];

		%init(SpringBoard);
		return;
	}

	if([plistDict[identifier] isEqual:@1]) {

    if(plistDict[@"stopABLivePatch"] && ![[NSFileManager defaultManager] fileExistsAtPath:@"/Library/BawAppie/ABypass/ABLicense"]) {
      [center callExternalVoidMethod:@selector(handleShowNotification:) withArguments:@{
        @"title" : @"A-Bypass Live Patch",
        @"message" : @"A-Bypass Live Patch is not available. Start Live Patch Update..",
        @"identifier": @"com.apple.Preferences"
      }];
      plistDict[@"stopABLivePatch"] = nil;
    }

    if(!plistDict[@"stopABLivePatch"]) {
      NSDictionary *result = [center callExternalMethod:@selector(handleUpdateLicense:) withArguments:@{
        @"type": @1,
        @"identifier": identifier
      }];
      if([result[@"success"] isEqual:@0]) {
        if([result[@"errno"] isEqual:@1] && [[NSFileManager defaultManager] fileExistsAtPath:@"/Library/BawAppie/ABypass/ABLicense"]) {
          [center callExternalVoidMethod:@selector(handleShowNotification:) withArguments:@{
            @"title" : @"A-Bypass Live Patch",
            @"message" : [NSString stringWithFormat:@"A network error has occurred. Skipping live patch update... (%@)", result[@"message"]],
            @"identifier": @"com.apple.Preferences"
          }];
        } else {
          [center callExternalVoidMethod:@selector(handleShowNotification:) withArguments:@{
            @"title" : @"A-Bypass License Manager Error.",
            @"message" : result[@"message"],
            @"identifier": @"com.apple.Preferences"
          }];
          exit(0);
          return;
        }
      }

      if(![[NSFileManager defaultManager] fileExistsAtPath:@"/Library/BawAppie/ABypass/ABLicense"]) {
        [center callExternalVoidMethod:@selector(handleShowNotification:) withArguments:@{
          @"title" : @"ABLoader Exception",
          @"message" : @"A-Bypass license cannot be verified or server is offline.",
          @"identifier": @"com.apple.Preferences"
        }];
        exit(0);
        return;
      }
    }

    // HBLogError(@"[ABLoader] Start Loading!");
    void *loader = dlopen("/Library/BawAppie/ABypass/ABLicense", RTLD_NOW);

    if(loader == nil) {
      easy_spawn((const char *[]){"/usr/bin/cynject", [[NSString stringWithFormat:@"%d", getpid()] UTF8String], "/Library/BawAppie/ABypass/ABLicense", NULL});
      [[NSString stringWithFormat:@"ABLOADER EXCEPTION\n\n%s", dlerror()] writeToFile:[NSString stringWithFormat:@"%@/Documents/ABLoaderError.log", NSHomeDirectory()] atomically:true encoding:NSUTF8StringEncoding error:nil];
      [center callExternalVoidMethod:@selector(handleShowNotification:) withArguments:@{
        @"title" : @"ABLoader Exception",
        @"message" : @"ABLoader is unable to load A-Bypass, retrying using cynject. Please report this error to @BawAppie",
        @"identifier": @"com.apple.Preferences"
      }];
      exit(0);
    }
    NSLog(@"A-Bypass V2 Initialize complete!");
	}
	return;
}
