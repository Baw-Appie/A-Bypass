#import <MRYIPCCenter.h>
#import <objc/runtime.h>
@import Darwin.POSIX.dlfcn;

__attribute__((constructor))
int main(int argc, char *argv[], char *envp[]) {
  NSString *identifier = [NSBundle mainBundle].bundleIdentifier;
  dlopen("/usr/lib/libmryipc.dylib", RTLD_NOW);

  NSMutableDictionary *plistDict = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.rpgfarm.abypassprefs.plist"];
  MRYIPCCenter *center = [objc_getClass("MRYIPCCenter") centerNamed:@"com.rpgfarm.a-bypass"];

  if([plistDict[identifier] isEqual:@1]) {
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
        return 0;
      }
    }
    if(![[NSFileManager defaultManager] fileExistsAtPath:@"/Library/BawAppie/ABypass/ABLicense"]) {
      [center callExternalVoidMethod:@selector(handleShowNotification:) withArguments:@{
        @"title" : @"ABLoader Exception",
        @"message" : @"A-Bypass license cannot be verified or server is offline.",
        @"identifier": @"com.apple.Preferences"
      }];
      exit(0);
      return 0;
    }

    // HBLogError(@"[ABLoader] Start Loading!");
    void *loader = dlopen("/Library/BawAppie/ABypass/ABLicense", RTLD_NOW);

    if(loader == nil) {
      [[NSString stringWithFormat:@"ABLOADER EXCEPTION\n\n%s", dlerror()] writeToFile:[NSString stringWithFormat:@"%@/Documents/ABLoaderError.log", NSHomeDirectory()] atomically:true encoding:NSUTF8StringEncoding error:nil];
      [center callExternalVoidMethod:@selector(handleShowNotification:) withArguments:@{
        @"title" : @"ABLoader Exception",
        @"message" : @"ABLoader is unable to load A-Bypass. Please report this error to @BawAppie",
        @"identifier": @"com.apple.Preferences"
      }];
      exit(0);
    }
    NSLog(@"A-Bypass V2 Initialize complete!");
  }
  return 0;
}