#import <UIKit/UIKit.h>
#import <MRYIPCCenter.h>
#import <dlfcn.h>
#import <AppList/AppList.h>
#import <unistd.h>
#import <CommonCrypto/CommonDigest.h>
#import <spawn.h>
#import <errno.h>
#import <mach/mach.h>
#import <mach-o/getsect.h>
#import <mach-o/dyld.h>
#import <mach-o/dyld_images.h>
#import <mach/task.h>
#import <substrate.h>
#import <Foundation/Foundation.h>
#import <CoreFoundation/CoreFoundation.h>
#import <sys/types.h>
#import <sys/syscall.h>
#import <sys/stat.h>
#import <sys/sysctl.h>
#import <sys/mount.h>
#import <sys/utsname.h>
#import <sys/socket.h>
#import <sys/mman.h>
#include <Dobby/Dobby.h>
#import "ABPattern.h"
#import "codesign.h"
#import "writeData.h"
#import "fishhook.h"

#ifdef DEBUG
#define debugMsg(...) HBLogError(__VA_ARGS__)
#else
#define debugMsg(...)
#endif

#if !defined(PT_DENY_ATTACH)
#define PT_DENY_ATTACH 31
#endif

#define ABPattern AppIePattern
#define ABSI [ABPattern sharedInstance]

// #define MSHookFunction DobbyHook

static MRYIPCCenter* center;
NSString *identifier;
BOOL isSubstitute;

off_t binary_size = 0;

off_t bSize() {
  char binary_path[PATH_MAX];
  struct stat binary_stat;
  if (binary_size == 0) {
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wdeprecated-declarations"
    if (syscall(336, 2, getpid(), 11, 0, binary_path, sizeof(binary_path)) == 0) {
    #pragma clang diagnostic pop
      if (lstat(binary_path, &binary_stat) != -1) binary_size = binary_stat.st_size;
    }
  }
  return binary_size;
}

int isSafePTR(int64_t ptr) {
  int64_t base_address = (int64_t) _dyld_get_image_header(0);
  int64_t max_address = bSize() + base_address;
  if (ptr >= base_address && ptr <= max_address) return 0;
  return -1;
}

%group framework
%hook UnityLiappWrapper
+(int)LA1 {
  return 0;
}
%end
%hook w0n6Y
-(id)u0tutZS {
  return [[NSUUID UUID] UUIDString];
}
%end
// %hook UIViewController
// - (void)presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion {
//   HBLogError(@"[ABPattern] ????");
//   HBLogError(@"[ABPattern] %@", [NSThread callStackSymbols]);
//   [[NSString stringWithFormat:@"ABLOADER EXCEPTION\n\n%@", [NSThread callStackSymbols]] writeToFile:[NSString stringWithFormat:@"%@/Documents/ABLoaderError.log", NSHomeDirectory()] atomically:true encoding:NSUTF8StringEncoding error:nil];
// }
// %end
%hook CMARConditionalLaunchState
-(int)blockers {
  return 0;
}
-(BOOL)requiresPolicyEnforcment {
  return false;
}
%end
%hook CMARJailBreakUtils
+(bool)isDeviceJailbroken {
  return false;
}
-(bool)requiresInteractiveRemediationForIdentity:(id)arg1 {
  return false;
}
%end
%hook S
-(void)getList {

}
%end
%hook Diresu
+(int)s:(NSString*)apiKey:(NSString*)userName:(NSString*)appName:(NSString*)version {
  return 0;
}
+(int)s:(NSString*)arg1 {
  return 0;
}
+(void)b:(id)arg1 {
  return;
}
+(void)c:(id)arg1 {
  return;
}
+(int)v:(void *)arg1 {
  return 0;
}
+(int)o:(IMP)pointer:(bool)useAlert {
  return 0;
}
%end

%hook __AMSLBouncerInternal
-(NSData *)decrypt:(NSData *)data key:(NSData *)key padding:(NSInteger)padding {
  return [@"/ABypass" dataUsingEncoding:4];
}
%end
%hook ASMLFairPlayInspector
-(id)hmacWithSierraEchoCharlieRomeoEchoTango:(id)arg1 andData:(id)arg2 {
  return %orig;
}
-(id)fairPlayWithResponseAck:(id)arg {
  return nil;
}
%end
@interface iX_SelfChecker
-(void)stopToCheckSystem;
@end
%hook iX_SelfChecker
-(bool)startToCheckError:(void * *)arg2 {
  %orig;
  [self stopToCheckSystem];
  return false;
}
%end
@interface SN_SelfChecker
-(void)stopToCheckSystem;
@end
%hook SN_SelfChecker
-(bool)startToCheckError:(void * *)arg2 {
  %orig;
  [self stopToCheckSystem];
  return false;
}
%end
%hook iXDetectedPattern
-(NSString *)pattern_type_id {
  return @"0000";
}
%end
// %hook NSFastEnumeration
// - (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id)buffer count:(NSUInteger)len {
//   HBLogError(@"[ABPattern sharedInstance] %@", buffer);
//   return %orig;
// }
// %end
%hook __ns_d
-(NSString *)detectionObject {
  NSString *ret = %orig;
  if([ret containsString:@"san.dat"] || [ret containsString:@"updateinfo.dat"]) return ret;
  return @"/ABypass";
}
%end
%hook __ns_z
-(NSString *)detectionObject {
  NSString *ret = %orig;
  if([ret containsString:@"san.dat"] || [ret containsString:@"updateinfo.dat"]) return ret;
  return @"/ABypass";
}
%end
%hook AGFramework
-(void)CGColorSpaceCopyName:(bool)arg2 B:(void * *)arg3 {

}
-(void)CGColorGetPattern: (int)arg1 {
  ;
}
%end
%hook amsLibrary
- (long long)a3142:(id)arg1 {
  if([identifier isEqualToString:@"com.samsungfire.sfm"] || [identifier isEqualToString:@"kr.co.kdb.smart.SmartKDB"]) return %orig;
  if([ABSI.hookSVC80 containsObject:identifier]) return %orig;
  return %orig-10;
}
%end
%hook AMSLFairPlayInspector
+(id)unarchive:(id)arg1 {
  NSMutableDictionary *dict = [NSMutableDictionary dictionary];
  NSData *object_nsdata = [@"ㅎㅇ" dataUsingEncoding:NSUTF8StringEncoding];
  [dict setObject:object_nsdata forKey:@"kConfirm"];
  [dict setObject:object_nsdata forKey:@"kConfirmValidation"];
  return dict;
}
+(id)hmacWithSierraEchoCharlieRomeoEchoTango:(id)arg1 andData:(id)arg2 {
  return [@"ㅎㅇ" dataUsingEncoding:NSUTF8StringEncoding];
}
-(id)fairPlayWithResponseAck:(id)arg1 {
  return [@"ㅎㅇ" dataUsingEncoding:NSUTF8StringEncoding];
}
%end
%hook CommonUtil
+(BOOL)isJailbroken {
  return false;
}

+(BOOL) isJailBreakPhone {
  return false;
}
%end
%hook SFAntiPiracy
+(void)lllI {

}
%end
%hook XASAskJobs
+(BOOL)isPure {
  return false;
}
+(int)updateCheck {
  if([identifier isEqualToString:@"com.lottecard.mobilepay"]) {
    patchData(0x1000CC88C, 0x60000054);
    patchData(0x1000544C0, 0x69000010);
    patchData(0x1001C5A24, 0x49010010);
    patchData(0x1001CCCC0, 0x85720E94);
    patchData(0x10003AC28, 0x69000010);
  }
  return 121;
}
%end
%hook _TtC6SSGPAY19DetectionController
-(void)sendLogWithFrgflsType:(id)arg1 {

}
%end
%hook ams2Library
// -(long long)a3142:(id)arg1 {
//   return %orig-10;
// }
// -(long long)fairPlay:(void *)arg2 {
//   return %orig-144;
// }
-(NSData *)decrypt:(NSData *)data key:(NSData *)key padding:(NSInteger)padding {
  return [@"/ABypass" dataUsingEncoding:4];
}
%end
%hook AMSLBouncer
-(NSData *)decrypt:(NSData *)data key:(NSData *)key padding:(NSInteger)padding {
  return [@"/ABypass" dataUsingEncoding:4];
}
%end
%hook BTWCGXMLParser
-(id)checkRootingWithRCL:(id)arg1 {
  return (id)CFSTR("0");
}
%end
%hook I3GDeviceInfo
+(id)getJailbreakInfo {
  return (id)CFSTR("NO");
}
%end
%hook AppJailBrokenChecker
+(unsigned char)isAppJailbroken {
  return 0;
}
%end
%hook BSAppIron
// -(int)IiiIiIiiI {
//   if(![identifier isEqualToString:@"kr.go.eduro.hcs"]) return %orig;
//   return 9013;
// }
// 일부 앱에서 충돌 발생, 어차피 없어도 잘됨.
-(id)authApp:(id)arg1 {
  if(![identifier isEqualToString:@"com.idongbu.sca"]) return %orig;
  return (id)CFSTR("0000");
}
-(int)isDeviceRooting {
  return 0;
}
%end
%hook iIiIIiIii
-(id)IiIIiIiII:(id)arg1 {
  NSData *orig = %orig;
  NSString* decode = [[NSString alloc] initWithData:orig encoding:4];
  decode = [decode stringByReplacingOccurrencesOfString:@"/var" withString:@"/ABypass"];
  decode = [decode stringByReplacingOccurrencesOfString:@"/Library" withString:@"/ABypass"];
  decode = [decode stringByReplacingOccurrencesOfString:@"/Applications" withString:@"/ABypass"];
  decode = [decode stringByReplacingOccurrencesOfString:@"/usr" withString:@"/ABypass"];
  decode = [decode stringByReplacingOccurrencesOfString:@"/etc" withString:@"/ABypass"];
  decode = [decode stringByReplacingOccurrencesOfString:@"/private" withString:@"/ABypass"];
  decode = [decode stringByReplacingOccurrencesOfString:@"/System" withString:@"/ABypass"];
  decode = [decode stringByReplacingOccurrencesOfString:@"/bin" withString:@"/ABypass"];
  NSData *encode = [decode dataUsingEncoding:NSUTF8StringEncoding];
  return encode;
}
%end
%hook iiiIIiIi
- (id)IiIIiIiII:(id)arg1 {
  NSData *orig = %orig;
  NSString* decode = [[NSString alloc] initWithData:orig encoding:4];
  decode = [decode stringByReplacingOccurrencesOfString:@"/var" withString:@"/ABypass"];
  decode = [decode stringByReplacingOccurrencesOfString:@"/Library" withString:@"/ABypass"];
  decode = [decode stringByReplacingOccurrencesOfString:@"/Applications" withString:@"/ABypass"];
  decode = [decode stringByReplacingOccurrencesOfString:@"/usr" withString:@"/ABypass"];
  decode = [decode stringByReplacingOccurrencesOfString:@"/etc" withString:@"/ABypass"];
  decode = [decode stringByReplacingOccurrencesOfString:@"/private" withString:@"/ABypass"];
  decode = [decode stringByReplacingOccurrencesOfString:@"/System" withString:@"/ABypass"];
  decode = [decode stringByReplacingOccurrencesOfString:@"/bin" withString:@"/ABypass"];
  NSData *encode = [decode dataUsingEncoding:NSUTF8StringEncoding];
  return encode;
}
%end
%hook Sanne
-(NSDictionary *)sanneResult {
  return @{@"ResultCode": @"0000"};
}
%end
%hook ProbeCallbacks
+(void)notifyWith:(id)arg1 {
  arg1 = [arg1 stringByReplacingOccurrencesOfString:@":1" withString:@":0"];
  %orig;
}
%end
%hook BlsujIEwxuxylpvGHBqInrznykfmtEiC
+(void)notifyWith:(id)arg1 {
  arg1 = [arg1 stringByReplacingOccurrencesOfString:@":1" withString:@":0"];
  %orig;
}
%end
%hook vgvqbhckkomGtvbGibdswrwnvwFxGlko
+(void)notifyWith:(id)arg1 {
  arg1 = [arg1 stringByReplacingOccurrencesOfString:@":1" withString:@":0"];
  %orig;
}
%end
%hook DataManager
-(void)setP_gCheckGuard:(id)arg1 {
  
}
-(void)setGCheckGuard:(id)arg1 {
  
}
%end
%hook AFSDKChecksum
+(BOOL)isJailbroken {
  return false;
}
%end
%hook TossManager
-(BOOL)isJailBrokenDevice {
  return false;
}
%end
%hook KSFileUtil
+(int)checkJailBreak {
  return 1;
}
%end
%hook DocumentPath
+(BOOL)isJailbroken {
  return false;
}
%end
%hook SCS_AIP
-(void)showAlertViewWithTitle:(id)arg1 withMessage:(id)arg2 {

}
-(void)show:(id)arg1 {

}
-(void)timeOut {

}
-(void)crash {

}
%end
%hook SpaceClass
-(void)alertView:(id)arg1 clickedButtonAtIndex:(NSInteger)arg2 {

}
%end
%hook SCMHArxan
-(void)timeOut {

}
-(void)crash {

}
-(void)showPopup:(id)arg1 {

}
%end
%hook EN_AIP
-(void)jailBreakDetection {
}

-(void)checkSum {
}

-(void)swizzlingDetection {
}

-(void)resourceVerification {
}

-(void)sendMobileLog:(id)arg1 t_comment:(id)arg2 {
}

-(void)stopApplication {
}

-(void)debuggerDetection {
}

-(void)hookingDetection {
}

-(void)deleteMemo {
}

-(void)onKillTimer {

}
-(void)showAlertAndExit {

}
-(void)i3GGetEXDataCollAddr {

}
-(void)getIpInsideDataWithCode:(int)arg1 {

}
-(void)didSendFinishedEX:(id)arg1 {

}
-(void)aaa {

}
%end
%hook ArxanAIPCallDetection
+(void)jailbreak {

}
+(void)swizzling {
	
}
+(void)hooking {
	
}
+(void)debugging {
	
}
+(void)checksum {
	
}
+(void)executeAIP:(NSInteger)arg1 {

}
%end
%hook _TtC17kakaobank_library10Networking
-(void)prepareForArxanWithConfiguration:(id)arg2 {

}
%end
%hook _TtC17kakaobank_library13ArxanDetector
-(void)detectWithSource:(id)arg1 type:(NSInteger)arg2 completion:(id)arg3 {

}
-(void)detectedWithSource:(id)arg1 rawValue:(NSInteger)arg2 completion:(id)arg3 {
  
}
+(void)detectWithSource:(id)arg1 type:(NSInteger)arg2 completion:(id)arg3 {

}
+(void)detectedWithSource:(id)arg1 rawValue:(NSInteger)arg2 completion:(id)arg3 {
  
}
%end
%hook _TtC17kakaobank_library13ArxanReporter
-(void)reportWith:(id)arg1 type:(NSInteger)arg2 completion:(id)arg3 {

}
%end
%hook NetworkForArxan
-(void)requestWithSource:(id)arg1 type:(NSInteger)arg2 completion:(id)arg3 {

}
-(void)requestDetectedWithSource:(id)arg1 type:(NSInteger)arg2 completion:(id)arg3 {

}
-(void)createSession {

}
%end
%hook AIPExecutor 
-(void)configureAIP {
  
}
-(void)configureReport:(id)arg1 {

}
-(void)detectedWith:(id)arg1 type:(NSInteger)arg2 {

}
-(void)forceExecuteAIPWith:(id)arg1 {

}
%end
%hook ArxanTamper
-(void)Arxan_appFinish {

}
-(void)didSendFinishedEx:(id)arg1 {

}
-(void)get_eFDS_info:(id)arg1 {

}
%end
%hook BCAppDelegate
- (void)arxanHackingDetected:(id)arg1 {
  
}
%end
%hook mVaccine
-(BOOL)isJailBreak {
  return false;
}

-(bool)mvc {
  if([ABSI.hookSVC80 containsObject:identifier]) %orig;
  return 0;
}

-(bool)cbf:(bool)arg1 {
  return false;
}
%end
%hook WebViewController
-(void)excuteAppProtection {

}
%end
%hook VaccineManager
-(void)mVaccine:(void (^)(BOOL))arg2 {
  arg2(true);
}
%end
%hook MasController
-(bool)checkJailbreak {
  return false;
}
-(void)coreMAS {

}
%end
%hook _y_q_l_h_s_i
-(id)_f_g_1_h_d_i {
  return (id)CFSTR("AMMPASS");
}
-(void *)_i_g_l_h_d_a {
  return @"성공";
}
%end

@interface StockNewsdmManager
+(char *)defRandomString;
@end
@interface UpdateMIssuesManager
@property (nonatomic, assign) struct STS1 *sts1;
@property (nonatomic, assign) struct STS2 *sts2;
@property (nonatomic, assign) struct STS3 *sts3;
-(struct STS1 *)viewWillAtIndex;
-(id)init:(id)arg;
-(id)viewDidUnload:(id)arg1 Loader2:(int)arg2;
-(id)viewWillTransitionToSize:(id)arg;
-(id)GetEnumerator;
-(id)viewDidLoad;
-(void)didReceiveMemoryWarning;
-(void)viewDidUnload2;
@end
%hook UpdateMIssuesManager
-(unsigned int)viewDidUnload:(struct mach_header *)arg2 Loader2:(int)arg3 {
  [self didReceiveMemoryWarning];
  if(![[NSBundle mainBundle].bundleIdentifier isEqualToString:@"com.vivarepublica.cash"]) %orig;
  return 0;
}
%end


%hook _TtC10gsthefresh5Utils
+(void)showConfirmWithTitle:(void *)arg2 message:(NSString *)arg3 willDissmiss:(bool)arg4 rightButtnTitle:(void *)arg5 onRightButtonClick:(void *)arg6 {
  if(![arg3 containsString:@"비정상 단말"]) %orig;
}
%end
%hook _TtC4gs255Utils
+(void)showConfirmWithTitle:(void *)arg2 message:(NSString *)arg3 willDissmiss:(bool)arg4 rightButtnTitle:(void *)arg5 onRightButtonClick:(void *)arg6 {
  if(![arg3 containsString:@"비정상 단말"]) %orig;
}
%end
%hook _TtC6thepop5Utils
+(void)showConfirmWithTitle:(void *)arg2 message:(NSString *)arg3 willDissmiss:(bool)arg4 rightButtnTitle:(void *)arg5 onRightButtonClick:(void *)arg6 {
  if(![arg3 containsString:@"비정상 단말"]) %orig;
}
%end

// %hook NonPersistentCollector
// -(id)jailbroken {
//   return @"false";
// }
// %end
// %hook BMBSession
// -(void)didDetectJailbreak {

// }
// %end
// %hook BNBTaskManager
// -(void)displayJailbreakInformation {

// }
// %end
// %hook MACContainer
// -(BOOL)isJailbroken {
//   return false;
// }
// %end
// %hook BRCContainer
// -(BOOL)isJailbroken {
//   return false;
// }
// +(void)setupContainer:(id)arg1 {
//   HBLogError(@"[ABPattern sharedInstance]");
//   %orig;
//   HBLogError(@"[ABPattern sharedInstance] %@", arg1);
// }
// %end
// %hook MACSecurity
// // +(char *)deobfuscateText:(char *)arg2 {
// //   return arg2;
// // }
// -(BOOL)isJailbroken {
//   return !%orig;
// }
// -(void)calcJailbreakBitFlags:(unsigned int *)arg2 flagCount:(unsigned int *)arg3 {
//   // unsigned int i = 1000;
//   // HBLogError(@"[ABPattern sharedInstance] alloc %d", *arg3);
//   // return %orig(&i, &i);
//   // %orig();
// }
// %end

%end



%group ObjcMethods

%hook NSException
// +(void)raise:(id)arg1 format:(id)arg2 {
//   if(![identifier isEqualToString:@"be.bmid.itsme"]) %orig;
// }
// + (NSException *)exceptionWithName:(NSExceptionName)name reason:(NSString *)reason userInfo:(NSDictionary *)userInfo {
//   return %orig(name, @"hongfarm", userInfo);
// }
%end

// %hook UIApplication
// - (void)suspend {
//   HBLogError(@"[ABPattern sharedInstance] %@", [NSThread callStackSymbols]);
// }
// %end

%hook NSFileManager
- (BOOL)fileExistsAtPath:(NSString *)path {
  if(![[ABPattern sharedInstance] u:path i:11001]) return false;
  return %orig;
}
- (BOOL)fileExistsAtPath:(NSString *)path isDirectory:(BOOL *)isDirectory {
  if(![[ABPattern sharedInstance] u:path i:11002]) return false;
  return %orig;
}
-(BOOL)changeCurrentDirectoryPath:(id)path {
  if(![[ABPattern sharedInstance] u:path i:11003]) return false;
  return %orig;
}
-(BOOL)createDirectoryAtPath:(NSString *)path withIntermediateDirectories:(BOOL)createIntermediates attributes:(NSDictionary *)attributes error:(NSError * _Nullable *)error {
  if(![[ABPattern sharedInstance] u:path i:11004]) return false;
  return %orig;
}
-(BOOL)copyItemAtPath:(NSString *)srcPath  to:(NSString *)dstPath  error:(NSError * _Nullable *)error {
  if(![[ABPattern sharedInstance] u:srcPath i:11005]) return false;
  if(![[ABPattern sharedInstance] u:dstPath i:11006]) return false;
  return %orig;
}
- (BOOL)isReadableFileAtPath:(NSString *)path {
  if(![[ABPattern sharedInstance] u:path i:11007]) return false;
  return %orig;
}
- (BOOL)isExecutableFileAtPath:(NSString *)path {
  if(![[ABPattern sharedInstance] u:path i:11008]) return false;
  return %orig;
}
- (BOOL)isWritableFileAtPath:(NSString *)path {
  if(![[ABPattern sharedInstance] u:path i:11009]) return false;
  return %orig;
}
- (BOOL)isDeletableFileAtPath:(NSString *)path {
  if(![[ABPattern sharedInstance] u:path i:11010]) return false;
  return %orig;
}
- (NSString *)destinationOfSymbolicLinkAtPath:(NSString *)path error:(NSError * _Nullable *)error {
  if(![[ABPattern sharedInstance] u:path i:11011]) return nil;
  NSString *ret = %orig;
  // [[ABPattern sharedInstance] usk:path n:ret];
  return ret;
}
- (NSArray<NSString *> *)contentsOfDirectoryAtPath:(NSString *)path error:(NSError *_Nullable *)error {
   // 이거 넣으면 일부 트윅과 충돌함.
   // || ![[ABPattern sharedInstance] u:path i:11012]
  if([path isEqualToString:@"/bin"] || [path isEqualToString:@"/Applications"]) {
    if(error) *error = [NSError errorWithDomain:NSCocoaErrorDomain code:257 userInfo:@{
        NSLocalizedDescriptionKey: @"Operation was unsuccessful.",
        NSLocalizedFailureReasonErrorKey: @"Object does not exist.",
        NSLocalizedRecoverySuggestionErrorKey: @"Don't access this again"
    }];
    return @[];
    return %orig(@"없는 디렉토리입니다. 확인 후 다시 시도해주세요.", error);
  }
  return %orig;
}
%end

%hook UIApplication
-(BOOL)canOpenURL:(NSURL *)path {
  for (NSString* key in @[@"cydia", @"sileo", @"undecimus", @"zbra", @"filza", @"activator"]) {
    if([path.absoluteString containsString:key]) return false;
  }
  return %orig;
}
%end

%hook UIImage
- (instancetype)initWithContentsOfFile:(NSString *)path {
  if(![[ABPattern sharedInstance] u:path i:12001]) return nil;
  return %orig;
}
+ (UIImage *)imageWithContentsOfFile:(NSString *)path {
  if(![[ABPattern sharedInstance] u:path i:12002]) return nil;
  return %orig;
}
%end

%hook NSString

+ (instancetype)stringWithUTF8String:(const char *)nullTerminatedCString {
  if(nullTerminatedCString) return %orig;
  else return %orig("");
}


-(id)initWithContentsOfFile:(id)path encoding:(unsigned long long)arg2 error:(id*)arg3 {
  if(![[ABPattern sharedInstance] u:path i:13001]) return nil;
  return %orig;
}
-(id)initWithContentsOfFile:(id)path {
  if(![[ABPattern sharedInstance] u:path i:13002]) return nil;
  return %orig;
}
- (BOOL)writeToFile:(NSString *)path {
  if(![[ABPattern sharedInstance] u:path i:13003]) return false;
  return %orig;
}
- (BOOL)writeToFile:(NSString *)path atomically:(BOOL)useAuxiliaryFile encoding:(NSStringEncoding)enc error:(NSError **)error {
  if(![[ABPattern sharedInstance] u:path i:13004]) {
    * error = [[ABPattern sharedInstance] er];
    return false;
  }
  return %orig;
}
- (BOOL)writeToFile:(NSString *)path atomically:(BOOL)useAuxiliaryFile {
  if(![[ABPattern sharedInstance] u:path i:13005]) return false;
  return %orig;
}
%end
%hook NSData
-(id)initWithContentsOfFile:(id)path encoding:(unsigned long long)arg2 error:(id*)arg3 {
  if(![[ABPattern sharedInstance] u:path i:14001]) return nil;
  return %orig;
}
-(id)initWithContentsOfFile:(id)path {
  if(![[ABPattern sharedInstance] u:path i:14002]) return nil;
  return %orig;
}
- (BOOL)writeToFile:(NSString *)path {
  if(![[ABPattern sharedInstance] u:path i:14003]) return false;
  return %orig;
}
- (BOOL)writeToFile:(NSString *)path atomically:(BOOL)useAuxiliaryFile encoding:(NSStringEncoding)enc error:(NSError **)error {
  if(![[ABPattern sharedInstance] u:path i:14004]) {
    * error = [[ABPattern sharedInstance] er];
    // * error = [NSError errorWithDomain:@"ABypass" code:200 userInfo:nil];
    return false;
    // return %orig(@"/Library/ABypass/NoPerm", useAuxiliaryFile, enc);
  }
  return %orig;
}
- (BOOL)writeToFile:(NSString *)path atomically:(BOOL)useAuxiliaryFile {
  if(![[ABPattern sharedInstance] c:path]) return false;
  return %orig;
}

- (instancetype)initWithContentsOfURL:(NSURL *)url {
  if(![[ABPattern sharedInstance] u:[url absoluteString] i:14005]) return nil;
  return %orig;
}
- (instancetype)initWithContentsOfURL:(NSURL *)url options:(NSDataReadingOptions)readOptionsMask error:(NSError * _Nullable *)error {
  if(![[ABPattern sharedInstance] u:[url absoluteString] i:14006]) return nil;
  return %orig;
}

+ (instancetype)dataWithContentsOfURL:(NSURL *)url {
  if(![[ABPattern sharedInstance] u:[url absoluteString] i:14007]) return nil;
  return %orig;
}

+ (instancetype)dataWithContentsOfURL:(NSURL *)url options:(NSDataReadingOptions)readOptionsMask error:(NSError * _Nullable *)error {
  if(![[ABPattern sharedInstance] u:[url absoluteString] i:14008]) return nil;
  return %orig;
}
%end

%hook NSFileHandle
+(id)fileHandleForReadingAtPath:(id)path {
  if(![[ABPattern sharedInstance] u:path i:15001]) return nil;
  return %orig;
}

+ (instancetype)fileHandleForReadingFromURL:(NSURL *)url error:(NSError * _Nullable *)error {
  if(![[ABPattern sharedInstance] u:[url absoluteString] i:15002]) return nil;
  return %orig;
}

+ (instancetype)fileHandleForWritingAtPath:(NSString *)path {
  if(![[ABPattern sharedInstance] u:path i:15003]) return nil;
  return %orig;
}

+ (instancetype)fileHandleForWritingToURL:(NSURL *)url error:(NSError * _Nullable *)error {
  if(![[ABPattern sharedInstance] u:[url absoluteString] i:15004]) return nil;
  return %orig;
}

+ (instancetype)fileHandleForUpdatingAtPath:(NSString *)path {
  if(![[ABPattern sharedInstance] u:path i:15005]) return nil;
  return %orig;
}

+ (instancetype)fileHandleForUpdatingURL:(NSURL *)url error:(NSError * _Nullable *)error {
  if(![[ABPattern sharedInstance] u:[url absoluteString] i:15006]) return nil;
  return %orig;
}
%end
%hook NSBundle
- (id)objectForInfoDictionaryKey:(NSString *)key {
    if([key isEqualToString:@"SignerIdentity"]) {
        return nil;
    }

    return %orig;
}

+ (instancetype)bundleWithURL:(NSURL *)url {
    if(![[ABPattern sharedInstance] u:[url absoluteString] i:16001]) return nil;

    NSBundle *ret = %orig;
    return ret;
}

+ (instancetype)bundleWithPath:(NSString *)path {
    if(![[ABPattern sharedInstance] u:path i:16002]) return nil;

    NSBundle *ret = %orig;
    return ret;
}

- (instancetype)initWithURL:(NSURL *)url {
    if(![[ABPattern sharedInstance] u:[url absoluteString] i:16003]) return nil;

    NSBundle *ret = %orig;
    return ret;
}

- (instancetype)initWithPath:(NSString *)path {
    if(![[ABPattern sharedInstance] u:path i:16004]) return nil;

    NSBundle *ret = %orig;
    return ret;
}
%end

%hook NSProcessInfo
-(NSDictionary *)environment {
  NSMutableDictionary *dict = [%orig mutableCopy];
  [dict removeObjectForKey:@"DYLD_INSERT_LIBRARIES"];
  return dict;
}
%end

%end




%group CFunction

int lstat(const char *pathname, struct stat *statbuf);
%hookf(int, lstat, const char *pathname, struct stat *statbuf) {
  NSString *path = [NSString stringWithUTF8String:pathname];
  if(![[ABPattern sharedInstance] u:path i:20001]) {
    return %orig("여긴 아무것도 없는 것 같습니다. 뒤로 돌아가, 다시 시도해보세요.", statbuf);
    errno = ENOENT;
    return -1;
  }
  int ret = %orig;
  if(statbuf) {
    if([path isEqualToString:@"/Applications"]
    || [path isEqualToString:@"/usr/share"]
    || [path isEqualToString:@"/usr/libexec"]
    || [path isEqualToString:@"/usr/include"]
    || [path isEqualToString:@"/Library/Ringtones"]
    || [path isEqualToString:@"/Library/Wallpaper"]) {
      if(ret == 0 && (statbuf->st_mode & S_IFLNK) == S_IFLNK) {
        statbuf->st_mode &= ~S_IFLNK;
      }
    }
    if([path isEqualToString:@"/bin"]) {
      if(ret == 0 && statbuf->st_size > 128) {
        statbuf->st_size = 128;
      }
    }
  }
  return %orig;
}
int stat(const char *path, struct stat *result);
%hookf(int, stat, const char *pathname, struct stat *statbuf) {
  NSString *path = [NSString stringWithUTF8String:pathname];
  if(![[ABPattern sharedInstance] u:path i:20002]) {
    return %orig("여긴 아무것도 없는 것 같습니다. 뒤로 돌아가, 다시 시도해보세요.", statbuf);
    errno = ENOENT;
    return -1;
  }
  int ret = %orig;
  if(statbuf) {
    if([path isEqualToString:@"/Applications"]
    || [path isEqualToString:@"/usr/share"]
    || [path isEqualToString:@"/usr/libexec"]
    || [path isEqualToString:@"/usr/include"]
    || [path isEqualToString:@"/Library/Ringtones"]
    || [path isEqualToString:@"/Library/Wallpaper"]) {
      if(ret == 0 && (statbuf->st_mode & S_IFLNK) == S_IFLNK) {
        statbuf->st_mode &= ~S_IFLNK;
      }
    }
    if([path isEqualToString:@"/bin"]) {
      if(ret == 0 && statbuf->st_size > 128) {
        statbuf->st_size = 128;
      }
    }
  }
  return %orig;
}
%hookf(FILE *, fopen, const char *path, const char *mode) {
  if(![[ABPattern sharedInstance] u:[[NSString alloc] initWithUTF8String:path] i:20003]) {
    errno = ENOENT;
    return %orig("/응없어", mode);
  }
  return %orig;
}
%hookf(pid_t, vfork) {
  errno = ENOSYS;
  return -1;
}
%hookf(pid_t, fork) {
  errno = ENOSYS;
  return -1;
}
%hookf(FILE *, popen, const char *command, const char *type) {
  errno = ENOSYS;
  return NULL;
}
// 밑에서 재구현.
// %hookf(int, open, const char *path, int flags) {
//   if(![[ABPattern sharedInstance] c:[[NSString alloc] initWithUTF8String:path]]) return %orig("/jb/ABypass", flags);
//   return %orig;
// }
%hookf(char *, getenv, const char *name) {
  NSString *n = [[NSString alloc] initWithUTF8String:name];
  if([n isEqualToString:@"DYLD_INSERT_LIBRARIES"]
    || [n isEqualToString:@"_MSSafeMode"]
    || [n isEqualToString:@"_SafeMode"]
    || [n isEqualToString:@"_SubstituteSafeMode"]
  ) return NULL;
  return %orig;
}
%hookf(int, unlink, const char* path) {
  if(![[ABPattern sharedInstance] u:[[NSString alloc] initWithUTF8String:path] i:20004]) return -1;
  return %orig;
}
%hookf(int, symlink, const char *path1, const char *path2) {
  if(![[ABPattern sharedInstance] u:[[NSString alloc] initWithUTF8String:path1] i:20005]) return -1;
  if(![[ABPattern sharedInstance] u:[[NSString alloc] initWithUTF8String:path2] i:20006]) return -1;
  return %orig;
}
%hookf(int, link, const char *path1, const char *path2) {
  if(![[ABPattern sharedInstance] u:[[NSString alloc] initWithUTF8String:path1] i:20007]) return -1;
  if(![[ABPattern sharedInstance] u:[[NSString alloc] initWithUTF8String:path2] i:20008]) return -1;
  return %orig;
}
// %hookf(int, "system", const char* cmd) {
//  return 0;
// }
%hookf(int, access, const char *path, int mode) {
  if(![[ABPattern sharedInstance] u:[[NSString alloc] initWithUTF8String:path] i:20009]) return %orig("/엿머겅.두번머겅", mode);
  return %orig;
}
%hookf(int, dladdr, void *addr, Dl_info *info) {
  int ret = %orig;
  if(ret && info) {
    if([@(info->dli_fname) containsString:@"ABypass"]) info->dli_fname = "/System/Library/Frameworks/Foundation.framework/Foundation";
    if([@(info->dli_fname) containsString:@"substitute"]) info->dli_fname = "/System/Library/Frameworks/Foundation.framework/Foundation";
    if([@(info->dli_fname) containsString:@"substrate"]) info->dli_fname = "/System/Library/Frameworks/Foundation.framework/Foundation";
    if([@(info->dli_fname) containsString:@"DynamicLibraries"]) info->dli_fname = "/System/Library/Frameworks/Foundation.framework/Foundation";
    if([@(info->dli_fname) containsString:@"TweakInject"]) info->dli_fname = "/System/Library/Frameworks/Foundation.framework/Foundation";
    if([@(info->dli_fname) containsString:@"Cephei"]) info->dli_fname = "/System/Library/Frameworks/Foundation.framework/Foundation";
    if([@(info->dli_fname) containsString:@"SnowBoardBase"]) info->dli_fname = "/System/Library/Frameworks/Foundation.framework/Foundation";
    if([@(info->dli_fname) containsString:@"libhooker"]) info->dli_fname = "/System/Library/Frameworks/Foundation.framework/Foundation";
    if([@(info->dli_fname) containsString:@"rocketbootstrap"]) info->dli_fname = "/System/Library/Frameworks/Foundation.framework/Foundation";
    // if([@(info->dli_fname) containsString:@"ABypass"]) HBLogError(@"dladdr %s", info->dli_fname);
  }
  return ret;
}
%hookf(int, posix_spawn, pid_t *pid, const char *pathname, const posix_spawn_file_actions_t *file_actions, const posix_spawnattr_t *attrp, char *const argv[], char *const envp[]) {
  if(pathname) {
    NSString *path = [[NSFileManager defaultManager] stringWithFileSystemRepresentation:pathname length:strlen(pathname)];
    if(![[ABPattern sharedInstance] u:path i:20009]) return ENOENT;
  }
  return %orig;
}
%hookf(int, posix_spawnp, pid_t *pid, const char *pathname, const posix_spawn_file_actions_t *file_actions, const posix_spawnattr_t *attrp, char *const argv[], char *const envp[]) {
  if(pathname) {
    NSString *path = [[NSFileManager defaultManager] stringWithFileSystemRepresentation:pathname length:strlen(pathname)];
    if(![[ABPattern sharedInstance] u:path i:20010]) return ENOENT;
  }
  return %orig;
}
%hookf(uid_t, getuid) {
  return 501;
}
%hookf(gid_t, getgid) {
  return 501;
}
%hookf(uid_t, geteuid) {
  return 501;
}
%hookf(uid_t, getegid) {
  return 501;
}
%hookf(pid_t, getppid) {
  return 1;
}
%hookf(int, setreuid, uid_t ruid, uid_t euid) {
  if(ruid == 0 || euid == 0) {
    errno = EPERM;
    return -1;
  }
  return %orig;
}
%hookf(int, setregid, gid_t rgid, gid_t egid) {
  if(rgid == 0 || egid == 0) {
    errno = EPERM;
    return -1;
  }
  return %orig;
}
%hookf(bool, dlopen_preflight, const char *path) {
  if(path) {
    NSString *sym = [NSString stringWithUTF8String:path];
    if([[ABPattern sharedInstance] i:sym]) {
      return false;
    }
  }
  return %orig;
}
%hookf(int, rename, const char *oldname, const char *newname) {
  NSString *oldname_ns = nil;
  NSString *newname_ns = nil;
  if(oldname && newname) {
    oldname_ns = [[NSFileManager defaultManager] stringWithFileSystemRepresentation:oldname length:strlen(oldname)];
    newname_ns = [[NSFileManager defaultManager] stringWithFileSystemRepresentation:newname length:strlen(newname)];
    if([oldname_ns hasPrefix:@"/tmp"] || [newname_ns hasPrefix:@"/tmp"]) {
      errno = ENOENT;
      return -1;
    }
  }
  return %orig;
}

// %hookf(void *, dlsym, void *handle, const char *symbol) {
//   NSString *sym = [NSString stringWithUTF8String:symbol];

//   HBLogError(@"dlsym %s", sym);

//   NSArray *symbols = @[ @"MSHookFunction", @"MSHookMessageEx", @"MSFindSymbol", @"MSGetImageByName", @"ZzBuildHook", @"DobbyHook", @"LHHookFunctions", @"MSHookMemory", @"MSHookClassPair", @"_Z13flyjb_patternP8NSString", @"_Z9hms_falsev", @"rocketbootstrap_cfmessageportcreateremote", @"rocketbootstrap_cfmessageportexposelocal", @"rocketbootstrap_distributedmessagingcenter_apply", @"rocketbootstrap_look_up", @"rocketbootstrap_register", @"rocketbootstrap_unlock" ];
//   if([symbols containsObject:sym]) return NULL;
//   return %orig;
// }

%hookf(int, sysctl, int *name, u_int namelen, void *oldp, size_t *oldlenp, void *newp, size_t newlen) {
  if(namelen == 4 && name[0] == CTL_KERN && name[1] == KERN_PROC && name[2] == KERN_PROC_ALL && name[3] == 0) {
    *oldlenp = 0;
    return 0;
  }
  int ret = %orig;
  if(ret == 0 && name[0] == CTL_KERN && name[1] == KERN_PROC && name[2] == KERN_PROC_PID && name[3] == getpid()) {
    if(oldp) {
      struct kinfo_proc *p = ((struct kinfo_proc *) oldp);
      if((p->kp_proc.p_flag & P_TRACED) == P_TRACED) {
        p->kp_proc.p_flag &= ~P_TRACED;
      }
    }
  }
  return ret;
}
%hookf(int, fstatfs, int fd, struct statfs *buf) {
  int ret = %orig;
  if(ret == 0) {
    char path[PATH_MAX];
    if(fcntl(fd, F_GETPATH, path) != -1) {
      NSString *pathname = [[NSFileManager defaultManager] stringWithFileSystemRepresentation:path length:strlen(path)];
      if(![[ABPattern sharedInstance] u:pathname i:20011]) {
        errno = ENOENT;
        return -1;
      }
      if(![pathname hasPrefix:@"/var"] && ![pathname hasPrefix:@"/private/var"]) {
        if(buf) {
          buf->f_flags |= MNT_RDONLY | MNT_ROOTFS;
          return ret;
        }
      } else {
        buf->f_flags |= MNT_NOSUID | MNT_NODEV;
        return ret;
      }
    }
  }
  return ret;
}
%hookf(int, statfs, const char *path, struct statfs *buf) {
  int ret = %orig;
  if(ret == 0) {
    NSString *pathname = [[NSFileManager defaultManager] stringWithFileSystemRepresentation:path length:strlen(path)];
    // 원래 check였는데 왜 그거 썼는지 모르겠음..
    if(![[ABPattern sharedInstance] u:pathname i:20012]) {
      errno = ENOENT;
      return -1;
    }
    if(![pathname hasPrefix:@"/var"] && ![pathname hasPrefix:@"/private/var"]) {
      if(buf) {
        buf->f_flags |= MNT_RDONLY | MNT_ROOTFS;
        return ret;
      }
    } else {
      buf->f_flags |= MNT_NOSUID | MNT_NODEV;
      return ret;
    }
  }
  return ret;
}
%hookf(int, uname, struct utsname *value) {
  int ret = %orig;
  if (value) {
    const char *kernelName = value->version;
    NSString *kernelName_ns = [NSString stringWithUTF8String:kernelName];
    if([kernelName_ns containsString:@"hacked"] || [kernelName_ns containsString:@"MarijuanARM"]) {
      kernelName_ns = [kernelName_ns stringByReplacingOccurrencesOfString:@"hacked" withString:@""];
      kernelName_ns = [kernelName_ns stringByReplacingOccurrencesOfString:@"MarijuanARM" withString:@""];
      kernelName = [kernelName_ns cStringUsingEncoding:NSUTF8StringEncoding];
      strcpy(value->version, kernelName);
    }
  }
  return ret;
}
%hookf(int, chdir, const char *pathname) {
  if(pathname) {
    NSString *path = [[NSFileManager defaultManager] stringWithFileSystemRepresentation:pathname length:strlen(pathname)];
    if(![[ABPattern sharedInstance] u:path i:20013]) {
      errno = ENOENT;
      return -1;
    }
  }
  return %orig(pathname);
}
%hookf(int, fchdir, int fd) {
  char dirfdpath[PATH_MAX];
  if(fcntl(fd, F_GETPATH, dirfdpath) != -1) {
    NSString *path = [[NSFileManager defaultManager] stringWithFileSystemRepresentation:dirfdpath length:strlen(dirfdpath)];
    if(![[ABPattern sharedInstance] u:path i:20014]) {
      errno = ENOENT;
      return -1;
    }
  }
  return %orig(fd);
}
%hookf (int, mkdir, const char *pathname, mode_t mode) {
  NSString *path = [NSString stringWithUTF8String:pathname];
  if([path hasPrefix:@"/tmp/"]) {
    errno = ENOENT;
    return -1;
  }
  return %orig;
}

%hookf(int, rmdir, const char *pathname) {
  if(pathname) {
    NSString *path = [[NSFileManager defaultManager] stringWithFileSystemRepresentation:pathname length:strlen(pathname)];
    if(![[ABPattern sharedInstance] u:path i:20015]) {
      errno = ENOENT;
      return -1;
    }
  }
  return %orig(pathname);
}
%hookf(int, fstatat, int dirfd, const char *pathname, struct stat *buf, int flags) {
  if(pathname) {
    NSString *path = [[NSFileManager defaultManager] stringWithFileSystemRepresentation:pathname length:strlen(pathname)];
    if(![[ABPattern sharedInstance] u:path i:20016]) {
      errno = ENOENT;
      return -1;
    }
  }
  return %orig(dirfd, pathname, buf, flags);
}


%hookf(FILE *, freopen, const char *pathname, const char *mode, FILE *stream) {
    if(pathname) {
        NSString *path = [[NSFileManager defaultManager] stringWithFileSystemRepresentation:pathname length:strlen(pathname)];
        if(![[ABPattern sharedInstance] u:path i:20018]) {
            fclose(stream);
            errno = ENOENT;
            return NULL;
        }
    }

    return %orig;
}
%hookf(int, remove, const char *filename) {
    if(filename) {
        NSString *path = [[NSFileManager defaultManager] stringWithFileSystemRepresentation:filename length:strlen(filename)];

        if(![[ABPattern sharedInstance] u:path i:20021]) {
            errno = ENOENT;
            return -1;
        }
    }

    return %orig;
}
%hookf(int, unlinkat, int dirfd, const char *pathname, int flags) {
    if(pathname) {
        NSString *path = [[NSFileManager defaultManager] stringWithFileSystemRepresentation:pathname length:strlen(pathname)];

        if(![path isAbsolutePath]) {
            // Get path of dirfd.
            char dirfdpath[PATH_MAX];
        
            if(fcntl(dirfd, F_GETPATH, dirfdpath) != -1) {
                NSString *dirfd_path = [[NSFileManager defaultManager] stringWithFileSystemRepresentation:dirfdpath length:strlen(dirfdpath)];
                path = [dirfd_path stringByAppendingPathComponent:path];
            }
        }
        
        if(![[ABPattern sharedInstance] u:path i:20022]) {
            errno = ENOENT;
            return -1;
        }
    }

    return %orig;
}
%hookf(int, faccessat, int dirfd, const char *pathname, int mode, int flags) {
    if(pathname) {
        NSString *path = [[NSFileManager defaultManager] stringWithFileSystemRepresentation:pathname length:strlen(pathname)];

        if(![path isAbsolutePath]) {
            // Get path of dirfd.
            char dirfdpath[PATH_MAX];
        
            if(fcntl(dirfd, F_GETPATH, dirfdpath) != -1) {
                NSString *dirfd_path = [[NSFileManager defaultManager] stringWithFileSystemRepresentation:dirfdpath length:strlen(dirfdpath)];
                path = [dirfd_path stringByAppendingPathComponent:path];
            }
        }
        
        if(![[ABPattern sharedInstance] u:path i:20023]) {
            errno = ENOENT;
            return -1;
        }
    }

    return %orig;
}
%hookf(int, chroot, const char *dirname) {
    if(dirname) {
        NSString *path = [[NSFileManager defaultManager] stringWithFileSystemRepresentation:dirname length:strlen(dirname)];

        if(![[ABPattern sharedInstance] u:path i:20024]) {
            errno = ENOENT;
            return -1;
        }
    }

    int ret = %orig;
    return ret;
}

%hookf(int, csops, pid_t pid, unsigned int ops, void *useraddr, size_t usersize) {
    int ret = %orig;

    if(ops == CS_OPS_STATUS && (ret & CS_PLATFORM_BINARY) == CS_PLATFORM_BINARY && pid == getpid()) {
        // Ensure that the platform binary flag is not set.
        ret &= ~CS_PLATFORM_BINARY;
    }

    return ret;
}
%hookf(const char * _Nonnull *, objc_copyImageNames, unsigned int *outCount) {
    const char * _Nonnull *ret = %orig;

    if(ret && outCount) {
        const char *exec_name = _dyld_get_image_name(0);
        unsigned int i;

        for(i = 0; i < *outCount; i++) {
            if(strcmp(ret[i], exec_name) == 0) {
                // Stop after app executable.
                *outCount = (i + 1);
                break;
            }
        }
    }

    return ret;
}

%hookf(const char * _Nonnull *, objc_copyClassNamesForImage, const char *image, unsigned int *outCount) {
    if(image) {
        NSString *image_ns = [NSString stringWithUTF8String:image];

        if(![[ABPattern sharedInstance] u:image_ns i:20024]) {

            *outCount = 0;
            return NULL;
        }
    }

    return %orig;
}

%hookf(void, _dyld_register_func_for_add_image, void (*func)(const struct mach_header* mh, intptr_t vmaddr_slide)) {
  if(![identifier isEqualToString:@"com.hanaskcard.mobileportal"] && !objc_getClass("Liapp")) return %orig;
  HBLogError(@"ABPattern _dyld_register_func_for_add_image denied.");
}

@import Darwin.POSIX.glob;
%hookf(int, glob, const char *pattern, int flags, int *errfunc, glob_t *pglob) {
  // HBLogError(@"[ABPattern] GLOB %@", @(pattern));
  // exit(1);
  if([@(pattern) isEqualToString:@"/Applications/*.*"]) {
    return %orig("/Library/BawAppie/ABypass/*.에휴", flags, errfunc, pglob);
  }
  return %orig;
}

%hookf(kern_return_t, task_info, task_name_t target_task, task_flavor_t flavor, task_info_t task_info_out, mach_msg_type_number_t *task_info_outCnt) {   
  // debugMsg(@"[ABAB] task_info %u", flavor);
  if (flavor == TASK_DYLD_INFO) {
    kern_return_t ret = %orig(target_task, flavor, task_info_out, task_info_outCnt);
    if (ret == KERN_SUCCESS) {
      struct task_dyld_info *task_info = (struct task_dyld_info *) task_info_out;
      struct dyld_all_image_infos *dyld_info = (struct dyld_all_image_infos *) task_info->all_image_info_addr;
      // debugMsg(@"[ABAB] task_info->all_image_info_addr %llu", task_info->all_image_info_addr);
      // task_info->all_image_info_addr = 0x0;
      dyld_info->infoArrayCount = 1;
      dyld_info->uuidArrayCount = 1;
      HBLogError(@"ABPattern task_info denied.");
    }
    return ret;
  }
  return %orig(target_task, flavor, task_info_out, task_info_outCnt);
}

// struct sockaddr_in {
//   short sin_family;
//   u_short sin_port;
//   struct in_addr sin_addr;
//   char sin_zero[8];
// };
// int connect(int sockfd, const struct sockaddr *addr, socklen_t addrlen);
// %hookf(int, connect, int sockfd, const struct sockaddr *addr, socklen_t addrlen) {
//   struct sockaddr_in *addr2 = (struct sockaddr_in *)addr;
//   if((*addr2).sin_port == htons(27042) || (*addr2).sin_port == htons(15371)) {
//     (*addr2).sin_port = htons(25865);
//   }
//   return %orig;
// }
%hookf(BOOL, class_addMethod, Class cls, SEL name, IMP imp, const char *types) {
  if([NSStringFromSelector(name) isEqualToString:@"hmacWithSierraEchoCharlieRomeoEchoTango:andData:"]) {
    id (^block)(id, id, id) = ^(id _self, id arg1, id arg2) {
      return [@"겨우 이걸로 막을라고?" dataUsingEncoding:NSUTF8StringEncoding];
    };
    return %orig(cls, name, imp_implementationWithBlock(block), types);
  }
  if([NSStringFromSelector(name) isEqualToString:@"fairPlayWithResponseAck:"]) {
    id (^block)(id, id) = ^(id _self, id arg1) {
      return [@"겨우 이걸로 막을라고?" dataUsingEncoding:NSUTF8StringEncoding];
    };
    return %orig(cls, name, imp_implementationWithBlock(block), types);
  }
  if([NSStringFromSelector(name) isEqualToString:@"unarchive:"]) {
    id (^block)(id, id) = ^(id _self, id arg1) {
      return [ABPatternObject alloc];
    };
    return %orig(cls, name, imp_implementationWithBlock(block), types);
  }
  return %orig;
}
// %hookf(Boolean, CFStringGetCString, CFStringRef theString, char *buffer, CFIndex bufferSize, CFStringEncoding encoding) {
//   HBLogError(@"[ABPattern sharedInstance] %@", (__bridge NSString *)theString);
//   return %orig;
// }
// %hookf(kern_return_t, vm_region_recurse_64, vm_map_t map, vm_address_t *address, vm_size_t *size, uint32_t *depth, vm_region_recurse_info_64_t info, mach_msg_type_number_t *infoCnt) {
//   HBLogError(@"[ABPattern sharedInstance]");
//     [[NSString stringWithFormat:@"ABLOADER EXCEPTION\n\n%@", [NSThread callStackSymbols]] writeToFile:[NSString stringWithFormat:@"%@/Documents/ABLoaderError.log", NSHomeDirectory()] atomically:true encoding:NSUTF8StringEncoding error:nil];
//   return KERN_FAILURE;
// }
%end


static int (*orig_open)(const char *path, int oflag, ...);
static int hook_open(const char *path, int oflag, ...) {
  int result = 0;
  if(path) {
    NSString *pathname = [[NSFileManager defaultManager] stringWithFileSystemRepresentation:path length:strlen(path)];
    if(![[ABPattern sharedInstance] u:pathname i:20017]) {
      errno = ((oflag & O_CREAT) == O_CREAT) ? EACCES : ENOENT;
      return -1;
    }
  }
  if((oflag & O_CREAT) == O_CREAT) {
    mode_t mode;
    va_list args;
    va_start(args, oflag);
    mode = (mode_t) va_arg(args, int);
    va_end(args);
    result = orig_open(path, oflag, mode);
  } else {
    result = orig_open(path, oflag);
  }
  return result;
}

int (*orig_syscall)(int number, ...);
int hooked_syscall(int number, ...) {
    int request;
    pid_t pid;
    caddr_t addr;
    int data;
    char *path;
    
    // fake stack, why use `char *` ? hah
    char *stack[8];
    
    va_list args;
    va_start(args, number);
    
    // get the origin stack args copy.(must >= origin stack args)
    memcpy(stack, args, 8 * 8);
    
    if (number == SYS_ptrace) {
        request = va_arg(args, int);
        pid = va_arg(args, pid_t);
        addr = va_arg(args, caddr_t);
        data = va_arg(args, int);
        va_end(args);
        if (request == PT_DENY_ATTACH) {
            return 0;
        }
    } else if(number == SYS_access) {
      path = va_arg(args, char *);
      va_end(args);
      if(![[ABPattern sharedInstance] u:@(path) i:20026]) {
        errno = ENOENT;
        return -1;
      }
    } else {
        va_end(args);
    }
    // must understand the principle of `function call`. `parameter pass` is
    // before `switch to target` so, pass the whole `stack`, it just actually
    // faked an original stack. Do not pass a large structure,  will be replace with
    // a `hidden memcpy`.
    int x = orig_syscall(number, stack[0], stack[1], stack[2], stack[3], stack[4],
                         stack[5], stack[6], stack[7]);
    return x;
}


@import Darwin.POSIX.dirent;
static DIR *(*orig_opendir)(const char *filename);
static DIR *hook_opendir(const char *filename) {
  // HBLogError(@"ABPattern opendir detected.");
  if(filename) {
    NSString *path = [[NSFileManager defaultManager] stringWithFileSystemRepresentation:filename length:strlen(filename)];
    if(![[ABPattern sharedInstance] u:path i:20025]) {
      errno = ENOENT;
      return NULL;
    }
  }
  return orig_opendir(filename);
}

static char* (*orig_strstr)(char* str1, const char* str2);
static char* my_strstr(char* str1, const char* str2) {
  if([identifier isEqualToString:@"com.kakaogames.moonlight"]) {
    if([@(orig_strstr(str1, str2)) containsString:@"pattern"]) return NULL;
  }
  // if(orig_strstr(str1, str2) != nil) HBLogError(@"ABPatternstrstr %s %s %s", orig_strstr(str1, str2), str1, str2);
  // if([@(str1) containsString:@"substitute"]) return NULL;
  if([@(str2) containsString:@"ubstrate"]) return NULL;
  return orig_strstr(str1, str2);
}


void findSegment(const uint8_t *target, const uint32_t target_len, void (*callback)(uint8_t *), int image_num) {
  const struct mach_header_64 *header = (const struct mach_header_64*) _dyld_get_image_header(image_num);
  const struct section_64 *executable_section = getsectbynamefromheader_64(header, "__TEXT", "__text");

  uint8_t *start_address = (uint8_t *) ((intptr_t) header + executable_section->offset);
  uint8_t *end_address = (uint8_t *) (start_address + executable_section->size);

  uint8_t *current = start_address;
  uint32_t index = 0;

  uint8_t current_target = 0;

  while (current < end_address) {
    current_target = target[index];

    if (current_target == *current++ || current_target == 0xFF) index++;
    else index = 0;

    if (index == target_len) {
      index = 0;
      callback(current - target_len);
    }
  }
}

void findSegment(const uint8_t *target, const uint32_t target_len, void (*callback)(uint8_t *)) {
  findSegment(target, target_len, callback, 0);
}

void findSegmentForDyldImage(const uint8_t *target, const uint32_t target_len, void (*callback)(uint8_t *)) {
  uint32_t count = _dyld_image_count();
  Dl_info dylib_info;
  for(uint32_t i = 0; i < count; i++) {
    dladdr(_dyld_get_image_header(i), &dylib_info);
    NSString *detectedDyld = [NSString stringWithUTF8String:dylib_info.dli_fname];
    if([detectedDyld containsString:@"/var"]) {
      debugMsg(@"[ABZZ] We'll hooking %s! haha!", dylib_info.dli_fname);
      findSegment(target, target_len, callback, i);
    }
  }
}

uint8_t *findS(const uint8_t *target) {
  const struct mach_header_64 *header = (const struct mach_header_64*) _dyld_get_image_header(0);
  const struct section_64 *executable_section = getsectbynamefromheader_64(header, "__TEXT", "__text");
  uint32_t *start = (uint32_t *) ((intptr_t) header + executable_section->offset);

  uint32_t *current = (uint32_t *)target;

  for (; current >= start; current--) {
    uint32_t op = *current;

    if ((op & 0xFFC003FF) == 0x910003FD) {
      unsigned delta = (op >> 10) & 0xFFF;
      if ((delta & 0xF) == 0) {
        uint8_t *prev = (uint8_t *)current - ((delta >> 4) + 1) * 4;
        if ((*(uint32_t *)prev & 0xFFC003E0) == 0xA98003E0
            || (*(uint32_t *)prev & 0xFFC003E0) == 0x6D8003E0) {  //STP x, y, [SP,#-imm]!
          return prev;
        }
      }
    }
  }

  return (uint8_t *)target;
}

void findSegment2ForDyldImage(const uint64_t *target, const uint64_t *mask, const uint32_t target_len, void (*callback)(uint8_t *), int image_num) {
    const struct mach_header_64 *header = (const struct mach_header_64*) _dyld_get_image_header(image_num);
    const struct section_64 *executable_section = getsectbynamefromheader_64(header, "__TEXT", "__text");

    uint64_t *start_address = (uint64_t *) ((intptr_t) header + executable_section->offset);
    uint64_t *end_address = (uint64_t *) (start_address + executable_section->size);

    uint32_t *current = (uint32_t *)start_address;
    uint32_t index = 0;

    uint32_t current_target = 0;

    while (start_address < end_address) {
        current_target = target[index];
        if (current_target == (*current++ & mask[index])) index++;
        else index = 0;
        if (index == target_len) {
            index = 0;
            callback((uint8_t *)(current - target_len));
        }
        start_address+=0x4;
    }
}

void findSegment2(const uint64_t *target, const uint64_t *mask, const uint32_t target_len, void (*callback)(uint8_t *)) {
  uint32_t count = _dyld_image_count();
  Dl_info dylib_info;
  for(uint32_t i = 0; i < count; i++) {
    dladdr(_dyld_get_image_header(i), &dylib_info);
    NSString *detectedDyld = [NSString stringWithUTF8String:dylib_info.dli_fname];
    if([detectedDyld containsString:@"/var"]) {
      debugMsg(@"[ABZZ] We'll hooking %s! haha!", dylib_info.dli_fname);
      findSegment2ForDyldImage(target, mask, target_len, callback, i);
    }
  }
}

bool patchCode(void *target, const void *data, size_t size) {
  @try {
    kern_return_t err;
    mach_port_t port = mach_task_self();
    vm_address_t address = (vm_address_t) target;

    err = vm_protect(port, address, size, false, VM_PROT_READ | VM_PROT_WRITE | VM_PROT_COPY);
    if (err != KERN_SUCCESS) return false;

    err = vm_write(port, address, (vm_address_t) data, size);
    if (err != KERN_SUCCESS) return false;

    err = vm_protect(port, address, size, false, VM_PROT_READ | VM_PROT_EXECUTE);
    if (err != KERN_SUCCESS) return false;
  } @catch(NSException *e) {
    debugMsg(@"[ABASM] ABASM Patcher has crashed. Aborting patch.. (%p)", target);
    return false;
  }

  return true;
}


void patchSYS_access(uint8_t* match) {
  uint8_t patch[] = {
    0x40, 0x00, 0x80, 0xD2 // MOV  X16, #2
  };
  patchCode(match+4, patch, sizeof(patch));
  debugMsg(@"[ABASM] A-Bypass found the malware and removed it. (SYS_access: %p)", match);
}

void removeSYS_access() {
  const uint8_t target[] = {
    0x30, 0x04, 0x80, 0xD2, // MOV  X16, #0x21
    0x01, 0x10, 0x00, 0xD4, // SVC  0x80
  };
  debugMsg(@"[ABASM] Starting malware detection. (SYS_access)");
  findSegment(target, sizeof(target), &patchSYS_access);
}

void patchSYS_access2(uint8_t* match) {
  uint8_t patch[] = {
    0xB0, 0x00, 0x80, 0xD2, //MOV X16, #21
    0x1F, 0x20, 0x03, 0xD5,  //NOP
    0x1F, 0x20, 0x03, 0xD5,  //NOP
    0x1F, 0x20, 0x03, 0xD5,  //NOP
    0x40, 0x00, 0x80, 0x52  //MOV X0, #2
  };
  patchCode(match+4, patch, sizeof(patch));
  debugMsg(@"[ABASM] A-Bypass found the malware and removed it. (SYS_access: %p)", match);
}

void removeSYS_access2() {
  const uint8_t target[] = {
    0x30, 0x04, 0x80, 0xD2,         //MOV X16, #21
    0x1F, 0x20, 0x03, 0xD5,         //NOP
    0x1F, 0x20, 0x03, 0xD5,         //NOP
    0x1F, 0x20, 0x03, 0xD5,         //NOP
    0x01, 0x10, 0x00, 0xD4          //SVC #0x80
  };
  debugMsg(@"[ABASM] Starting malware detection. (SYS_access)");
  findSegment(target, sizeof(target), &patchSYS_access2);
}

void patchSYS_open(uint8_t* match) {
  uint8_t patch[] = {
    0x40, 0x00, 0x80, 0xD2 // MOV  X16, #2
  };
  patchCode(match+4, patch, sizeof(patch));
  debugMsg(@"[ABASM] A-Bypass found the malware and removed it. (SYS_open: %p)", match);
}

void removeSYS_open() {
  const uint8_t target[] = {
    0xB0, 0x04, 0x80, 0xD2, // MOV  X16, #5
    0x01, 0x10, 0x00, 0xD4 // SVC  0x80
  };
  const uint8_t target2[] = {
    0xF0, 0x07, 0x40, 0xF9, // ldr x16, [sp, #0x30 + var_28]
    0x01, 0x10, 0x00, 0xD4 // SVC  0x80
  };
  const uint8_t target3[] = {
    0xB0, 0x04, 0x80, 0xD2, // movz x16, #0x5
    0x01, 0x10, 0x00, 0xD4 // SVC  0x80
  };
  debugMsg(@"[ABASM] Starting malware detection. (SYS_open)");
  findSegment(target, sizeof(target), &patchSYS_open);
  findSegment(target2, sizeof(target2), &patchSYS_open);
  findSegment(target3, sizeof(target3), &patchSYS_open);
}

void patchSYS_symlink(uint8_t* match) {
  uint8_t patch[] = {
    0x40, 0x00, 0x80, 0xD2 // MOV  X16, #2
  };
  patchCode(match+4, patch, sizeof(patch));
  debugMsg(@"[ABASM] A-Bypass found the malware and removed it. (SYS_symlink: %p)", match);
}

void removeSYS_symlink() {
  const uint8_t target[] = {
    0x30, 0x07, 0x80, 0xD2, // MOV  X16, #57
    0x01, 0x10, 0x00, 0xD4 // SVC  0x80
  };
  debugMsg(@"[ABASM] Starting malware detection. (SYS_symlink)");
  findSegment(target, sizeof(target), &patchSYS_symlink);
}

uint8_t RET[] = {
  0xC0, 0x03, 0x5F, 0xD6  //RET
};

// iXGuard
void patch1(uint8_t* match) {
  patchCode(findS(match), RET, sizeof(RET));
  debugMsg(@"[ABASM] patched r1: %p", match - _dyld_get_image_vmaddr_slide(0));
}
void remove1() {
  const uint64_t target[] = {
    0x7100041F, // CMP wN, #1
    0xF9000000, // STR x*, [x*]
    0x540000A1, // B.NE #0x14
    0xF9400000  // LDR x*, [x*, ...]
  };

  const uint64_t mask[] = {
    0xFFFFFC1F,
    0xFF000000,
    0xFFFFFFFF,
    0xFFC00000
  };

  findSegment2(target, mask, sizeof(target)/sizeof(uint64_t), &patch1);
}
// LxShields
void patch2(uint8_t* match) {
  patchCode(findS(match), RET, sizeof(RET));
}
void remove2() {
  const uint8_t target[] = {
    0xFD, 0x83, 0x01, 0x91,
    0xFF, 0x03, 0x15, 0xD1,
    0xA8, 0x43, 0x08, 0xD1
  };
  findSegment(target, sizeof(target), &patch2);

  const uint8_t target2[] = { //v2 ~ v4
    0x00, 0x40, 0x62, 0x1E,
    0x00, 0x20, 0x28, 0x1E,
    0xE8, 0x57, 0x9F, 0x1A
  };
  findSegment(target2, sizeof(target2), &patch2);
}
// AppSolid Legacy
void patch3(uint8_t* match) {
  uint8_t patch[] = {
    0x1F, 0x20, 0x03, 0xD5
  };
  patchCode(match-0x2C, patch, sizeof(patch));
}
void remove3() {
  const uint8_t target[] = {
    0x2B, 0x81, 0x00, 0x91,
    0x29, 0xA1, 0x00, 0x91,
    0xE0, 0x03, 0x08, 0xAA
  };
  findSegment(target, sizeof(target), &patch3);
}
// AppSolid NEW
void patch4(uint8_t* match) {
  patchCode(match, RET, sizeof(RET));
}
void remove4() {
  // 나이스아이핀 
  // 0x100194908
  const uint8_t target[] = {
    0x08, 0x00, 0x80, 0xD2,
    0xE0, 0x03, 0x08, 0xAA,
    0x01, 0x80, 0x9C, 0xD2
  };
  findSegment(target, sizeof(target), &patch4);
}
// AppSolid NEW
void patch5(uint8_t* match) {
  patchCode(match, RET, sizeof(RET));
}
void remove5() {
  const uint8_t target[] = {
    0xFD, 0x83, 0x01, 0x91,
    0xFF, 0x03, 0x16, 0xD1,
    0xA8, 0x83, 0x08, 0xD1
  };
  findSegment(target, sizeof(target), &patch5);
}

struct ix_detected_pattern {
    char resultCode[12];
    char object[128];
    char description[128];
};

struct ix_detected_pattern_list_gamehack {
    struct ix_detected_pattern *pattern;
    int listCount;
};

int (*orig_ix_sysCheckStart)(struct ix_detected_pattern **p_info);
int hook_ix_sysCheckStart(struct ix_detected_pattern **p_info) {
  struct ix_detected_pattern *patternInfo = (struct ix_detected_pattern*)malloc(sizeof(struct ix_detected_pattern));
  strcpy(patternInfo->resultCode, "0000");
  strcpy(patternInfo->object, "SYSTEM_OK");
  strcpy(patternInfo->description, "SYSTEM_OK");
  *p_info = patternInfo;
  return 1;
}

int (*orig_ix_sysCheck_gamehack)(struct ix_detected_pattern **p_info, struct ix_detected_pattern_list_gamehack **p_list_gamehack);
int hook_ix_sysCheck_gamehack(struct ix_detected_pattern **p_info, struct ix_detected_pattern_list_gamehack **p_list_gamehack) {

  struct ix_detected_pattern *patternInfo = (struct ix_detected_pattern*)malloc(sizeof(struct ix_detected_pattern));
  struct ix_detected_pattern_list_gamehack *patternList = (struct ix_detected_pattern_list_gamehack*)malloc(sizeof(struct ix_detected_pattern_list_gamehack));

  strcpy(patternInfo->resultCode, "0000");
  strcpy(patternInfo->object, "SYSTEM_OK");
  strcpy(patternInfo->description, "SYSTEM_OK");
  patternList->listCount = 0;

  if((void *)p_info == (void *)0x1) {
    void patch6_2(uint8_t*);
    const uint8_t target[] = {
      0x08, 0x01, 0x0C, 0xCA,
      0xF0, 0x03, 0x08, 0xAA,
      0x01, 0x10, 0x00, 0xD4
    };

    findSegment(target, sizeof(target), &patch6_2);
    return orig_ix_sysCheck_gamehack(p_info, p_list_gamehack);
  }

  *p_info = patternInfo;
  *p_list_gamehack = patternList;

  return 1;
}

int (*orig_ix_sysCheck_result)(struct ix_detected_pattern **p_info);
int hook_ix_sysCheck_result(struct ix_detected_pattern **p_info) {

  struct ix_detected_pattern *patternInfo = (struct ix_detected_pattern*)malloc(sizeof(struct ix_detected_pattern));

  strcpy(patternInfo->resultCode, "0000");
  strcpy(patternInfo->object, "SYSTEM_OK");
  strcpy(patternInfo->description, "SYSTEM_OK");

  *p_info = patternInfo;

  return 1;
}

void patch6(uint8_t* match) {
  MSHookFunction((void *)findS(match), (void *)hook_ix_sysCheckStart, (void **)&orig_ix_sysCheckStart);
}
void patch6_1(uint8_t* match) {
  MSHookFunction((void *)findS(match), (void *)hook_ix_sysCheck_gamehack, (void **)&orig_ix_sysCheck_gamehack);
}
void patch6_2(uint8_t* match) {
  MSHookFunction((void *)findS(match), (void *)hook_ix_sysCheck_result, (void **)&orig_ix_sysCheck_result);
}

void remove6() {
  const uint64_t ix_sysCheckStart_target[] = {
    0x37000AAA, // TBNZ w10, #0, #0x154
    0x4A090108, // EOR w8, w8, w9
    0x37000A68  // TBNZ w8, #0, #0x154
  };

  const uint64_t ix_sysCheckStart_mask[] = {
    0xFFFFFFFF,
    0xFFFFFFFF,
    0xFFFFFFFF
  };

  findSegment2(ix_sysCheckStart_target, ix_sysCheckStart_mask, sizeof(ix_sysCheckStart_target)/sizeof(uint64_t), &patch6);

  const uint64_t ix_sysCheck_gamehack_target[] = {
    0x71000D1F, // CMP w8, #3
    0x1A9F27E8, // CSET W8, CC
    0x90000000, // ADRP
    0x39000000, // STRB w*, [x*] //LDRB
    0x7100013F, // CMP w9, #0
    0x1A9F17E9  // CSET w9, EQ
  };

  const uint64_t ix_sysCheck_gamehack_mask[] = {
    0xFFFFFFFF,
    0xFFFFFFFF,
    0x9F000000,
    0xFF000000,
    0xFFFFFFFF,
    0xFFFFFFFF
  };

  findSegment2(ix_sysCheck_gamehack_target, ix_sysCheck_gamehack_mask, sizeof(ix_sysCheck_gamehack_target)/sizeof(uint64_t), &patch6_1);

}

void patch7(uint8_t* match) {
  uint8_t patch[] = {
    0x40, 0x00, 0x80, 0xD2 // MOV  X16, #2
  };
  patchCode(match, patch, sizeof(patch));
}
void remove7() {
  const uint8_t target[] = {
    0x01, 0x10, 0x00, 0xD4
  };
  findSegment(target, sizeof(target), &patch7);
}




void (*orig)(void);
void repl(void) {
  return;
}

void _hookSymbol(void *hook) {
  MSHookFunction((void *)hook, (void *)repl, (void **)&orig);
}
void hookSymbol(const char *string) {
  void* hook = MSFindSymbol(NULL, string);
  _hookSymbol((void *)hook);
}
void hookSymbolWithDLSYM(const char *string) {
  void* handle = dlopen(NULL, RTLD_LAZY);
  void* dlsymResult = dlsym(handle, string);
  if(dlsymResult == nil) return;
  _hookSymbol((void *)dlsymResult);
}
void hookSymbolWithDLSYMImage(const char *string, const char *image) {
  void* handle = dlopen(image, RTLD_LAZY);
  void* dlsymResult = dlsym(handle, string);
  if(dlsymResult == nil) return exit(1);
  _hookSymbol((void *)dlsymResult);
}

int (*orig0)(void);
int repl0(void) {
  return 0;
}

void _hookSymbol0(void *hook) {
  MSHookFunction((void *)hook, (void *)repl0, (void **)&orig0);
}

void hookSymbol0(const char *string) {
  void* hook = MSFindSymbol(NULL, string);
  _hookSymbol0((void *)hook);
}
void hookSymbol0WithDLSYM(const char *string) {
  void* handle = dlopen(NULL, RTLD_LAZY);
  void* dlsymResult = dlsym(handle, string);
  if(dlsymResult == nil) return;
  _hookSymbol0((void *)dlsymResult);
}

int (*orig1)(void);
int repl1(void) {
  return 1;
}

void _hookSymbol1(void *hook) {
  MSHookFunction((void *)hook, (void *)repl1, (void **)&orig1);
}
void hookSymbol1WithDLSYMImage(const char *string, const char *image) {
  void* handle = dlopen(image, RTLD_LAZY);
  void* dlsymResult = dlsym(handle, string);
  if(dlsymResult == nil) return;
  _hookSymbol1((void *)dlsymResult);
}
void hookSymbol1WithPrivateImage(const char *string, const char *image) {
  void* handle = dlopen([[NSString stringWithFormat:@"%@/%@.framework/%@", [[NSBundle mainBundle] privateFrameworksPath], @(image), @(image)] UTF8String], RTLD_LAZY);
  void* dlsymResult = dlsym(handle, string);
  if(dlsymResult == nil) return;
  _hookSymbol1((void *)dlsymResult);
}


BOOL enableSysctlHook = false;

void hook_svc_pre_call(RegisterContext *reg_ctx, const HookEntryInfo *info) {
    int num_syscall = (int)(uint64_t)(reg_ctx->general.regs.x16);
    char *arg1 = (char *)reg_ctx->general.regs.x0;
    debugMsg(@"[ABZZ] System PRECALL %d %p", num_syscall, info->target_address);
    
    // if (num_syscall == SYS_syscall) {
    //     int arg1 = (int)(uint64_t)(reg_ctx->general.regs.x1);
    //     if (request == SYS_ptrace && arg1 == PT_DENY_ATTACH) {
    //         *(unsigned long *)(&reg_ctx->general.regs.x1) = 10;
    //         // debugMsg(@"[ABZZ] catch 'SVC #0x80; syscall(ptrace)' and bypass");
    //     } else if(request == SYS_access) {
    //       char *arg1 = (char *)reg_ctx->general.regs.x1;
    //       NSString *nsArg1 = [[NSString alloc] initWithUTF8String:arg1];
    //       // debugMsg(@"[ABZZ] SVC ACCESS DETECTED!!!! %@", nsArg1);
    //       if(![[ABPattern sharedInstance] u:nsArg1 i:30002]) {
    //         // debugMsg(@"[ABZZ] BLOCKED!!!!");
    //         const char **arg1 = (const char **)&reg_ctx->general.regs.x1;
    //         const char *path = "/ABypass.With.ABZZ";
    //         *arg1 = path;
    //       }
    //     }
    // } else if (num_syscall == SYS_ptrace) {
    //     request = (int)(uint64_t)(reg_ctx->general.regs.x0);
    //     if (request == PT_DENY_ATTACH) {
    //         *(unsigned long *)(&reg_ctx->general.regs.x0) = 10;
    //         // debugMsg(@"[ABZZ] catch 'SVC-0x80; ptrace' and bypass");
    //     }

    // if(num_syscall == SYS_getxattr) {
    //   debugMsg(@"[ABZZ] getxattr %s", arg1);
    // }
    if(num_syscall == SYS_symlink) {
      char *arg2 = (char *)reg_ctx->general.regs.x1;
      [[ABPattern sharedInstance] usk:@(arg1) n:@(arg2)];
      // HBLogError(@"[ABZZ] symlink %s %s", arg1, arg2);
    }
    // if(num_syscall == SYS_fork) {
    //   *(unsigned long *)(&reg_ctx->general.regs.x16) = (unsigned long long)0;
    // }
    // if(num_syscall == SYS_getfsstat64) {
    //   *(unsigned long *)(&reg_ctx->general.regs.x16) = 0;
    // }
    // if(num_syscall == SYS_unlink) {
    //  HBLogError(@"[ABZZ] unlink %s", arg1);
    // }
    // if(num_syscall == SYS_sysctl) {
    //   enableSysctlHook = true;
    // }
    if(num_syscall == SYS_open || num_syscall == SYS_access || num_syscall == SYS_statfs64 || num_syscall == SYS_statfs || num_syscall == SYS_lstat64 || num_syscall == SYS_stat64 || num_syscall == SYS_rename || num_syscall == SYS_setxattr || num_syscall == SYS_pathconf) {
        debugMsg(@"[ABZZ] SYS_open with SVC 80, %s", arg1);
        if([@(arg1) isEqualToString:@"/dev/urandom"]) {
          *(unsigned long *)(&reg_ctx->general.regs.x0) = (unsigned long long)"/Protected.By.ABypass";
          return;
        }
        if(![[ABPattern sharedInstance] u:@(arg1) i:30001] && ![@(arg1) isEqualToString:@"/sbin/mount"]) {
          *(unsigned long *)(&reg_ctx->general.regs.x0) = (unsigned long long)"/Protected.By.ABypass";
        } else {
          debugMsg(@"[ABZZ] not blocked!");
        }
    }
}
void hook_svc_post_call(RegisterContext *reg_ctx, const HookEntryInfo *info) {
  int num_syscall = (int)(uint64_t)(reg_ctx->general.regs.x16);
  // void *orig = (void *)((uint8_t*)(info->target_address)-4);
  debugMsg(@"[ABZZ] System POSTCALL %d %p", num_syscall, orig);
  if(num_syscall == SYS_fork) {
    *(unsigned long *)(&reg_ctx->general.regs.x1) = (unsigned long long)-1;
  }
  if(enableSysctlHook && num_syscall == SYS_sysctl) {
    struct kinfo_proc *info = (struct kinfo_proc *)(&reg_ctx->general.regs.x4);
    if((info->kp_proc.p_flag & P_TRACED) == P_TRACED) {
      info->kp_proc.p_flag &= ~P_TRACED;
    }
  }
}

void hookSVC80Real(uint8_t* match) {

  // if(*((uint16_t*)match+4) != 0x80D2) return;

  debugMsg(@"[ABZZ] Hooking %p!", match);

  dobby_enable_near_branch_trampoline();
  DobbyInstrument((void *)(match), (DBICallTy)hook_svc_pre_call);
  dobby_disable_near_branch_trampoline();
  
  // 일부 앱 충돌
  // DobbyInstrument((void *)(match+4), (DBICallTy)hook_svc_post_call);
}

void hookingSVC80() {
  const uint8_t target[] = {
    0x01, 0x10, 0x00, 0xD4
  };
  findSegmentForDyldImage(target, sizeof(target), &hookSVC80Real);
}

void removeSVC80Real(uint8_t* match) {
  _hookSymbol0(findS(match));
}

void removingSVC80() {
  const uint8_t target[] = {
    0x01, 0x10, 0x00, 0xD4
  };
  findSegmentForDyldImage(target, sizeof(target), &removeSVC80Real);
}

void hookingAccessSVC80Handler(RegisterContext *reg_ctx, const HookEntryInfo *info) {

  const char* arg1 = (const char*)(uint64_t)(reg_ctx->general.regs.x0);
  NSMutableString *path = [@(arg1) mutableCopy];

  NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"/private/var/mobile/Containers/Data/Application/(.*)/tmp/([A-Za-z0-9])*" options:0 error:nil];
  // debugMsg(@"[ABPattern] ABZZ %@", path);
  [regex replaceMatchesInString:path options:0 range:NSMakeRange(0, [path length]) withTemplate:@""];
  debugMsg(@"[ABPattern] ABZZ %@", path);
  if(![[ABPattern sharedInstance] u:path i:30001] && ![path isEqualToString:@"/sbin/mount"]) {
    *(unsigned long *)(&reg_ctx->general.regs.x0) = (unsigned long long)"/Protected.By.ABypass";
  } else {
    debugMsg(@"[ABPattern] ABZZ not blocked! %@", path);
  }
}

void hookingAccessSVC804Real(uint8_t* match) {
  dobby_enable_near_branch_trampoline();
  DobbyInstrument((void *)(match), (DBICallTy)hookingAccessSVC80Handler);
  dobby_disable_near_branch_trampoline();
}

void hookingAccessSVC80() {
  const uint8_t target[] = {
    0x30, 0x04, 0x80, 0xD2,
    0x01, 0x10, 0x00, 0xD4
  };
  findSegmentForDyldImage(target, sizeof(target), &hookingAccessSVC804Real);
}

%group toss
%hook UILabel
-(void)drawRect:(id)arg1 {
  NSString *ret = self.text;
  if([ret containsString:@"금융의 모든 것"]) {
    [self setText:@"탈옥 우회의 모든 것\nA-Bypass로 간편하게"];
  }
  %orig;
}
%end
// %hookf(kern_return_t, vm_region_recurse_64, vm_map_t map, vm_address_t *address, vm_size_t *size, uint32_t *depth, vm_region_recurse_info_64_t info, mach_msg_type_number_t *infoCnt) {
//   return KERN_FAILURE;
// }
%end

%group BinaryChecker
%hook NSString
- (NSString *)substringFromIndex:(NSUInteger)from {
  if(from == 2) {
    NSString *path = %orig;
    if([path hasPrefix:@"/"] && ![[ABPattern sharedInstance] u:path i:40001]) {
      return @"/이 세상에는 존재하지 않는 파일입니다. 지옥에 가시기 바랍니다.";
    }
    return path;
  }
  return %orig(from);
}
%end
%end

%group KakaoTaxiFix
%hook UIImage
+ (UIImage *)imageNamed:(NSString *)name inBundle:(NSBundle *)bundle withConfiguration:(id)configuration {
  if([bundle.bundleIdentifier hasPrefix:@"org.cocoapods."]) return %orig(name, [NSBundle mainBundle], configuration);
  return %orig;
}
%end
%end

%group dyldUnc0ver
%hookf(const char *, _dyld_get_image_name, uint32_t image_index) {
  const char *ret = %orig;
  if([[ABPattern sharedInstance] i:@(ret)]) {
    NSString *uuid = [[NSUUID UUID] UUIDString];
    return [[NSString stringWithFormat:@"/usr/lib/%@.dylib", uuid] UTF8String];
  }
  return ret;
}
%end

void showProgress() { [center callExternalMethod:@selector(handleUpdateLicense:) withArguments:@{ @"type": @3, @"max": @"10" }]; }
void loadingProgress(NSString *per) { [center callExternalMethod:@selector(handleUpdateLicense:) withArguments:@{ @"type": @4, @"per": per, @"max": @"10" }]; }
void hideProgress() { [center callExternalMethod:@selector(handleUpdateLicense:) withArguments:@{ @"type": @5 }]; }

%ctor {
  // return;
  identifier = [NSBundle mainBundle].bundleIdentifier;    
  center = [MRYIPCCenter centerNamed:@"com.rpgfarm.a-bypass"];
  [NSThread sleepForTimeInterval:0.15];
  showProgress();

  NSFileManager *manager = [NSFileManager defaultManager];
  if(![manager fileExistsAtPath:@"/Library/MobileSubstrate/DynamicLibraries/!ABypass2.dylib"]) {
    [center callExternalVoidMethod:@selector(handleShowNotification:) withArguments:@{
      @"title" : @"A-Bypass Warning",
      @"message" : @"A-Bypass has been restricted for an unknown reason. Try disabling other tweaks. (like FlyJB, Shadow, Liberty Lite)",
      @"identifier": @"com.apple.Preferences"
    }];
  }

  NSMutableDictionary *flyjb = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/kr.xsf1re.flyjb.plist"];
  if(([manager fileExistsAtPath:@"/Library/MobileSubstrate/DynamicLibraries/ FlyJB2.dylib"] || [manager fileExistsAtPath:@"/Library/MobileSubstrate/DynamicLibraries/ FlyJB.dylib"] || [manager fileExistsAtPath:@"/Library/MobileSubstrate/DynamicLibraries/ FlyJBX.dylib"]) && [flyjb[identifier] isEqual:@1]) {
    [center callExternalVoidMethod:@selector(handleShowNotification:) withArguments:@{
      @"title" : @"A-Bypass Warning",
      @"message" : @"FlyJB is enabled for this app. To avoid crashes, please disable it.",
      @"identifier": @"com.apple.Preferences"
    }];
  }
  NSMutableDictionary *libertylite = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.ryleyangus.libertylite.plist"];
  if([manager fileExistsAtPath:@"/Library/MobileSubstrate/DynamicLibraries/zzzzzLiberty.dylib"] && [libertylite[[NSString stringWithFormat:@"Liberty-%@", identifier]] isEqual:@1]) {
    [center callExternalVoidMethod:@selector(handleShowNotification:) withArguments:@{
      @"title" : @"A-Bypass Warning",
      @"message" : @"Liberty Lite is enabled for this app. To avoid crashes, please disable it.",
      @"identifier": @"com.apple.Preferences"
    }];
  }
  NSMutableDictionary *shadow = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/me.jjolano.shadow.apps.plist"];
  if([manager fileExistsAtPath:@"/Library/MobileSubstrate/DynamicLibraries/0Shadow.dylib"] && [shadow[identifier] isEqual:@1]) {
    [center callExternalVoidMethod:@selector(handleShowNotification:) withArguments:@{
      @"title" : @"A-Bypass Warning",
      @"message" : @"Shadow is enabled for this app. To avoid crashes, please disable it.",
      @"identifier": @"com.apple.Preferences"
    }];
  }

  #ifdef DEBUG
  if(true) {
  #else
  if(![[NSBundle mainBundle] pathForResource:@"embedded" ofType:@"mobileprovision"] && [[NSBundle mainBundle] appStoreReceiptURL]) {
  #endif

    struct sigaction act_old;
    sigaction(3, &act_old, NULL);
    sigaction(4, &act_old, NULL);
    sigaction(5, &act_old, NULL);
    sigaction(6, &act_old, NULL);
    sigaction(7, &act_old, NULL);
    sigaction(8, &act_old, NULL);
    sigaction(10, &act_old, NULL);
    sigaction(11, &act_old, NULL);
    sigaction(12, &act_old, NULL);

    NSData *data = [NSData dataWithContentsOfFile:@"/var/mobile/Library/Preferences/ABPattern" options:0 error:nil];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    loadingProgress(@"1");

    ABSI.ABASMBlackList = @[
      @"com.iwilab.kakaotalk",
      @"com.vivarepublica.cash",
      @"com.kbcard.kbkookmincard",
      @"com.kbcard.cxh.appcard",
      @"com.shinhancard.MobilePay",
      @"com.lottecard.appcard",
      @"com.toyopagroup.picaboo",
      @"com.shinhancard.SmartShinhan2",
      @"com.lottecard.mobilepay",
      @"com.kebhana.hanapush",
      @"uk.co.barclays.bmbappstore",
    ];

    ABSI.hookSVC80 = @[
      @"com.kfcc.banking",
      @"kr.co.cu.onbank",
      @"com.kbinsure.kbinsureapp",
      @"com.rpgfarm.jbDetection",
      @"kr.co.jbbank.smartbank",
      @"com.samsungCard.samsungCard",
      @"kr.co.uplus.Paynow",
      @"kr.go.mma.bcpsauthapp",
      @"com.daishin.iphonecreon",
      @"com.tmoney.tmpay",
      @"com.kscc.t-gift",
      @"com.sbi.saidabank",
      @"com.mysmilepay.app",
      @"com.miraeasset.smartasset",
      @"com.miraeasset.trade",
      @"com.hana.hanamembers",
      @"com.wooriwm.txsmart",
      @"com.samsungCard.msa",
      @"com.app.shd.pstock",
      @"com.hanasec.world",
      @"com.hanasec.stock",
      @"com.app.shd.spstock",
      @"kr.or.kftc.ZpayStore",
      @"com.eugenefn.smartchampion2",
      @"com.nhlife.customer.mobile.ios",
      @"com.kismobile.pay",
      @"org.safeexambrowser.ios.seb",
      @"kr.or.nhic.www",
      @"com.dgbfnlife.mcc",
      @"com.suhyup.pesmb",
      @"com.tongyang.TYLife",
      @"com.lotte.mybee.lpay",
      @"com.hyundaicard.hcappcard",
      @"be.bmid.itsme",
      @"com.sktelecom.tauth"
    ];

    ABSI.noHookingPlz = @[
      @"com.hana.hanamembers",
      @"com.app.shd.pstock",
      @"com.app.shd.spstock",
      @"com.hanasec.world",
      @"com.hanasec.stock",
    ];

    ABSI.enforceDYLD = @[
      @"com.kismobile.pay",
      @"co.kr.acuonsavingsbank.acuonsb",
      @"com.sbi.saidabank"
    ];

    NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.rpgfarm.abypassprefs.plist"];
    if([prefs[@"advanced"][identifier][@"ABASMBlackList"] isEqual:@1]) ABSI.ABASMBlackList = @[identifier];
    if([prefs[@"advanced"][identifier][@"hookSVC80"] isEqual:@1]) ABSI.hookSVC80 = @[identifier];
    if([prefs[@"advanced"][identifier][@"noHookingPlz"] isEqual:@1]) ABSI.noHookingPlz = @[identifier];
    if([prefs[@"advanced"][identifier][@"enforceDYLD"] isEqual:@1]) ABSI.enforceDYLD = @[identifier];

    if([ABSI.hookSVC80 containsObject:identifier]) hookingSVC80();

    if([identifier isEqualToString:@"com.vivarepublica.cash"]) {
      %init(toss);
      if(!objc_getClass("StockNewsdmManager")) {
        NSString *version = [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"];
        if([version isEqualToString:@"5.5.0"]) {
          // didFinishLaunchingWithOptions 최상단
          patchData(0x101290dc4, 0xC0035FD6);
        } else if([version isEqualToString:@"5.16.0"]) {
          // didFinishLaunchingWithOptions 최하단 함수
          // -> vm_region_recurse_64가 있는 if 마지막 블록 후 첫 sub 함수
          patchData(0x1002d0534, 0xC0035FD6);
        }

        // 이건 자동으로 찾아내는 것
        remove1();
        return hideProgress();
      }
    }
    loadingProgress(@"2");

    isSubstitute = ([manager fileExistsAtPath:@"/usr/lib/libsubstitute.dylib"] && ![manager fileExistsAtPath:@"/usr/lib/substrate"] && ![manager fileExistsAtPath:@"/usr/lib/libhooker.dylib"]);
    BOOL isLibHooker = [[NSFileManager defaultManager] fileExistsAtPath:@"/usr/lib/libhooker.dylib"];
    HBLogError(@"[ABPattern] It is libhooker? %d", isLibHooker);

    [[ABPattern sharedInstance] setup:dic[@"data"]];
    if([ABSI.noHookingPlz containsObject:identifier]) return hideProgress();

    // Sublime Text등 일부 텍스트 에디터에서만 정상적으로 표시됨.
    // 절대 전부 똑같은게 아님!
    // 낚이지 말자.
    %init(framework, -SCMHArxan=objc_getClass(" "), -SpaceClass=objc_getClass(" "));
    %init(CFunction);
    %init(ObjcMethods);
    loadingProgress(@"3");

    float iosVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
    NSString *version = [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"];

    if([identifier isEqualToString:@"com.kakao.taxi"]) %init(KakaoTaxiFix);
    if([identifier isEqualToString:@"com.iwilab.KakaoTalk"]) return hideProgress();
    if([identifier isEqualToString:@"com.samsungcard.shopping"]) return hideProgress();
    if([identifier isEqualToString:@"com.nhncorp.NaverSearch"]) return hideProgress();
    if([identifier isEqualToString:@"com.nhnent.TOASTPAY"]) {
      if([version isEqualToString:@"3.16.0"]) {
        patchData(0x101171BD0, 0xC0035FD6);
        patchData(0x100573E40, 0xC0035FD6);
      } else {
        hookingAccessSVC80();
      }
      return hideProgress();
    }
    if([identifier isEqualToString:@"com.lottecard.mobilepay"]) {
      patchData(0x1000CC88C, 0x4A080014);
      patchData(0x1000544C0, 0x27630014);
      patchData(0x1001C5A24, 0xE11B0014);
      patchData(0x1001CCCC0, 0x1F2003D5);
      patchData(0x10003AC28, 0x950A0014);
      return hideProgress();
    }
    if([identifier isEqualToString:@"com.tmoney.tmpay"]) {
      hookSymbol0("__ZN9cbpp_core13SecurityCheck14detect_rootingEv");
      hookSymbol0("__ZN9cbpp_core13SecurityCheck15detect_debuggerEv");
      hookSymbol0("__ZN9cbpp_core13SecurityCheck19detect_modificationEv");
      hookSymbol0("__ZN9cbpp_core13SecurityCheck16detect_substrateEv");
      hookSymbol0("__ZN9cbpp_core13SecurityCheck17detect_custom_romEv");
      hookSymbol0("__ZN9cbpp_core13SecurityCheck15detect_emulatorEv");
      hookSymbol0("__ZN9cbpp_core13MpaSdkManager22notify_security_detectENS_21SecurityDetectionTypeE");
    }
    // Fiserv
    hookSymbol1WithPrivateImage("$s12FICoreModule19AppdomeEventManagerC24checkNotJailBrokenDeviceSbyFZ", "FICoreModule");
    loadingProgress(@"4");

    if(![ABSI.ABASMBlackList containsObject:identifier] && ![ABSI.hookSVC80 containsObject:identifier]) {
      removeSYS_open();
      removeSYS_access();
      removeSYS_access2();
      removeSYS_symlink();
    }
    loadingProgress(@"5");

    if(objc_getClass("BinaryChecker") || objc_getClass("mVaccine")) %init(BinaryChecker);
    if([identifier isEqualToString:@"com.kakaogames.gdtskr"] || [identifier isEqualToString:@"com.hyundaicapital.myAccount"]) remove2();
    if([identifier isEqualToString:@"com.nice.MyCreditManager"] || [identifier isEqualToString:@"com.niceid.niceipin"] || [identifier isEqualToString:@"com.korail.KorailTalk"]) {
      remove3();
      remove4();
    }
    if(objc_getClass("iXManager")) remove6();

    loadingProgress(@"6");

    if(!(iosVersion > 14 && !isLibHooker && !isSubstitute)) MSHookFunction((void *)open, (void *)hook_open, (void **)&orig_open);
    else abreset((struct rebinding[1]){{"open", (void *)hook_open, (void **)&orig_open}}, 1);
    // Fishhook 다 개소리.. 작동 안함!
    abreset((struct rebinding[1]){{"opendir", (void *)hook_opendir, (void **)&orig_opendir}}, 1);
    MSHookFunction((void *)dlsym(RTLD_DEFAULT, "strstr"), (void *)my_strstr, (void **)&orig_strstr);
    if(0)MSHookFunction((void *)dlsym(RTLD_DEFAULT, "syscall"), (void *)hooked_syscall, (void **)&orig_syscall);
    loadingProgress(@"7");

    if(!objc_getClass("Eversafe")) {
      if((isLibHooker && iosVersion < 14) || [ABSI.enforceDYLD containsObject:identifier]) {
        void DYLDSaver();
        DYLDSaver();
      } else {
        %init(dyldUnc0ver);
      }
  		// _dyld_register_func_for_add_image(&image_added);
    }

    loadingProgress(@"8");

    loadingProgress(@"9");
  } else {
    [center callExternalVoidMethod:@selector(handleShowNotification:) withArguments:@{
      @"title" : @"A-Bypass Warning",
      @"message" : @"This app is self-signed, and A-Bypass has been disabled to protect users from attacks.",
      @"identifier": @"com.apple.Preferences"
    }];
    return hideProgress();
  }
  NSDictionary* result = [center callExternalMethod:@selector(handleUpdateLicense:) withArguments:@{
    @"type": @2
  }];
  loadingProgress(@"10");
  if(result) return hideProgress();
  return;
}
