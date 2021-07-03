#import <UIKit/UIKit.h>
#import <MRYIPCCenter.h>
#import <dlfcn.h>
#import <AppList/AppList.h>
#include <unistd.h>
#include <CommonCrypto/CommonDigest.h>
#include <spawn.h>
#include <errno.h>
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
#include <sys/stat.h>
#include <sys/sysctl.h>
#include <sys/mount.h>
#include <sys/utsname.h>
#include <sys/socket.h>
#include <sys/mman.h>
#import "ABPattern.h"
#import "codesign.h"
#import "writeData.h"

#if !defined(PT_DENY_ATTACH)
#define PT_DENY_ATTACH 31
#endif

#define ABPattern RTPattern
#define ABSI [ABPattern sharedInstance]
static MRYIPCCenter* center;
NSString *identifier;
BOOL isSubstitute;

typedef void (*CDUnknownFunctionPointerType)(void); // 알 수 없는 포인터 타입 리턴
typedef void (^CDUnknownBlockType)(void); // 알 수 없는 블럭 리턴 


off_t binary_size = 0;

off_t bSize() {
    char binary_path[PATH_MAX];
    struct stat binary_stat;

    if (binary_size == 0) {
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wdeprecated-declarations"
        if (syscall(336, 2, getpid(), 11, 0, binary_path, sizeof(binary_path)) == 0) {
    #pragma clang diagnostic pop
            if (lstat(binary_path, &binary_stat) != -1) {
                binary_size = binary_stat.st_size;
            }
        }
    }
    
    return binary_size;
}

int isSafePTR(int64_t ptr) {
    int64_t base_address = (int64_t) _dyld_get_image_header(0);
    int64_t max_address = bSize() + base_address;
    
    if (ptr >= base_address && ptr <= max_address) {
        return 0;
    }

    return -1;
}

%group framework
%hook S
-(void)getList {
  NSLog(@"누구세요?");
}
%end
%hook Diresu
+(int)s:(NSString*)apiKey:(NSString*)userName:(NSString*)appName:(NSString*)version {
  NSLog(@"응안돼");
  return 0;
}
+(int)o:(IMP)pointer:(bool)useAlert {
  NSLog(@"안돼 안바꿔줘 돌아가");
  return 0;
}
%end

%hook __AMSLBouncerInternal
-(NSData *)decrypt:(NSData *)data key:(NSData *)key padding:(NSInteger)padding {
  return [@"/엿머겅/두번머겅/ProtectedBy.ABypass" dataUsingEncoding:4];
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
// %hook Liapp
// +(int)LA1 {
//   return 0;
// }
// %end
// %hook w0n6Y
// -(void)setV6Egg3pzeF {

// }
// %end
%hook __ns_d
-(NSString *)detectionObject {
  NSString *ret = %orig;
  if([ret containsString:@"san.dat"] || [ret containsString:@"updateinfo.dat"]) return ret;
  return @"/니얼굴";
}
%end
%hook AGFramework
-(void)CGColorSpaceCopyName:(bool)arg2 B:(void * *)arg3 {

}
%end
// KT PASS 충돌
// %hook __ns_g
// -(void)parser:(void *)arg2 didStartElement:(NSString *)arg3 namespaceURI:(NSString *)arg4 qualifiedName:(void *)arg5 attributes:(NSDictionary *)arg6 {
//   HBLogDebug(@"Removed by A-Bypass");
// }
// %end
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
  NSData *object_nsdata = [@"ㅎㅇ" dataUsingEncoding:NSUTF8StringEncoding];
  return object_nsdata;
}
-(id)fairPlayWithResponseAck:(id)arg1 {
  return nil;
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
  return 121;
}
%end
%hook _TtC6SSGPAY19DetectionController
-(void)sendLogWithFrgflsType:(id)arg1 {
  NSLog(@"뭘 봐");
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
  return [@"/엿머겅/두번머겅/ProtectedBy.ABypass" dataUsingEncoding:4];
}
%end
%hook AMSLBouncer
-(NSData *)decrypt:(NSData *)data key:(NSData *)key padding:(NSInteger)padding {
  return [@"/엿머겅/두번머겅/ProtectedBy.ABypass" dataUsingEncoding:4];
}
%end
%hook ShinHanManager
+(bool)serverCheckHash:(void *)arg2 from:(void *)arg3 {
  return true;
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
//   if(![identifier isEqualToString:@"com.idongbu.sca"]) return %orig;
//   return 9013;
// }
// 일부 앱에서 충돌 발생, 어차피 없어도 잘됨.
-(id)authApp:(id)arg1 {
  if(![identifier isEqualToString:@"com.idongbu.sca"]) return %orig;
  return (id)CFSTR("0000");
}
%end
%hook iIiIIiIii
-(id)IiIIiIiII:(id)arg1 {
  NSData *orig = %orig;
  NSString* decode = [[NSString alloc] initWithData:orig encoding:4];
  decode = [decode stringByReplacingOccurrencesOfString:@"/var" withString:@"/있었는데요없었습니다."];
  decode = [decode stringByReplacingOccurrencesOfString:@"/Library" withString:@"/있었는데요없었습니다."];
  decode = [decode stringByReplacingOccurrencesOfString:@"/Applications" withString:@"/있었는데요없었습니다."];
  decode = [decode stringByReplacingOccurrencesOfString:@"/usr" withString:@"/있었는데요없었습니다."];
  decode = [decode stringByReplacingOccurrencesOfString:@"/etc" withString:@"/있었는데요없었습니다."];
  decode = [decode stringByReplacingOccurrencesOfString:@"/private" withString:@"/있었는데요없었습니다."];
  decode = [decode stringByReplacingOccurrencesOfString:@"/System" withString:@"/있었는데요없었습니다."];
  decode = [decode stringByReplacingOccurrencesOfString:@"/bin" withString:@"/있었는데요없었습니다."];
  NSData *encode = [decode dataUsingEncoding:NSUTF8StringEncoding];
  return encode;
}
%end
%hook Sanne
-(NSDictionary *)sanneResult {
  return @{@"ResultCode": @"0000"};
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
%end
%hook SCiPAppDelegate 
-(void)arxanJailPoint {
  HBLogError(@"ABPattern arxanJailPoint");
}
-(void)arxan11 {
  HBLogError(@"ABPattern arxan11");
}
-(void)arxan1 {
  HBLogError(@"ABPattern arxan1");
}
%end
%hook AIPExecutor 
// -(void)detectedWith:(id)arg1 type:(long long)arg2 {
//   HBLogError(@"ABPattern AIPExecutor %@ %lld", arg1, arg2);
// }
-(void)configureAIP {
  
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


%hook MasController
-(bool)checkJailbreak {
  return false;
}
%end
%hook _y_q_l_h_s_i
-(id)_f_g_1_h_d_i {
  return (id)CFSTR("AMMPASS");
}
%end


%hook CustomShieldCallBackManager
-(void)libraryInjectionPrevented {

}
-(void)libraryInjectionDetected {

}
-(void)hookingFrameworksDetected {

}
-(void)shieldEventOcuured:(long long)arg2 value:(int)arg3 {
  
}
%end

struct STS1 {
    unsigned char uv[16];
    id il;
    unsigned char uq[12];
    struct STS2 *pSTS2;
};

struct STS2 {
    unsigned char iu[16];
    struct mach_header *lo;
    unsigned char we[7];
    id il;
    struct STS3 *nb;
    unsigned char uh[30];
    unsigned char uq[30];
    unsigned char sd[30];
    unsigned char ur;
    unsigned char op;
    unsigned char mv;
    unsigned char ao;
    unsigned char ei;
    unsigned char wz;
    unsigned char vu[7];
};

struct STS3 {
    unsigned char po[16];
    id pu;
    unsigned char pa[9];
    id px;
    unsigned char pb[7];
    id pz;
    unsigned char pm[7];
    id pl;
    id pv;
    id ps;
    id pi;
    id pc;
};

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
@interface StatementImplicitA
+(char *)defRandomString;
@end
@interface SyncFactoryDescripto
@property (nonatomic, assign) struct STS1 *sts1;
@property (nonatomic, assign) struct STS2 *sts2;
@property (nonatomic, assign) struct STS3 *sts3;
-(struct STS1 *)viewWillAtIndex;
-(id)init:(id)arg;
-(id)viewDidUnload:(id)arg1 Loader2:(int)arg2;
-(id)viewWillTransitionToSize:(id)arg;
-(struct STS2 *)GetEnumerator;
-(id)viewDidLoad;
-(void)didReceiveMemoryWarning;
-(void)viewDidUnload2;
@end
@interface BasicTableUISQLNonTr
-(struct STS1 *)viewWillAtIndex;
-(struct STS2 *)GetEnumerator;
-(void)viewDidUnload2;
-(void)didReceiveMemoryWarning;
@end
%hook UpdateMIssuesManager
-(unsigned int)viewDidUnload:(struct mach_header *)arg2 Loader2:(int)arg3 {
  [self didReceiveMemoryWarning];
  if(![[NSBundle mainBundle].bundleIdentifier isEqualToString:@"com.vivarepublica.cash"]) %orig;
  return 0;
}
%end
%hook SyncFactoryDescripto
-(unsigned int)viewDidUnload:(struct mach_header *)arg2 Loader2:(int)arg3 {
  [self didReceiveMemoryWarning];
  if(![[NSBundle mainBundle].bundleIdentifier isEqualToString:@"com.vivarepublica.cash"]) %orig;
  return 0;
}
%end
%hook ZipOutputStreamStrin
-(unsigned int)viewDidUnload:(struct mach_header *)arg2 Loader2:(int)arg3 {
  [self didReceiveMemoryWarning];
  if(![[NSBundle mainBundle].bundleIdentifier isEqualToString:@"com.vivarepublica.cash"]) %orig;
  return 0;
}
%end

%hook BasicTableUISQLNonTr
-(unsigned int)viewDidUnload:(struct mach_header *)arg2 Loader2:(int)arg3 {
  [self didReceiveMemoryWarning];
  if(![[NSBundle mainBundle].bundleIdentifier isEqualToString:@"com.vivarepublica.cash"]) %orig;
  return 0;
}
%end

%hook ServantObjectJScroll
-(id)viewWillTransitionToSize:(struct STS2 *)arg {
  id ret = %orig;
  HBLogError(@"[ABAlice] viewWillTransitionToSize");
  strcpy((char*)arg->uh, "A00000000000000000000000000000000000000000000000000000000000abc0e000i00l0nop0rstu000000000/00000");
  // strcpy((char*)arg->uh, "ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^0123456789:;<=>?@ABCDEFGHIJKLMabcdefghijklmnopqrstuvwxyz{|}~/_%@.-");
   return ret;
}
%end

// [CurrentHolderSQLTr load]

// %hook UIWindow
// -(void)makeKeyAndVisible {
//   HBLogError(@"ABPattern UIWindow makeKeyAndVisible %@", [NSThread callStackSymbols]);
// }
// %end

%end



%group ObjcMethods

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
  [[ABPattern sharedInstance] add:path to:ret];
  return ret;
}
- (NSArray<NSString *> *)contentsOfDirectoryAtPath:(NSString *)path error:(NSError *_Nullable *)error {
  HBLogError(@"ABPattern WARNING: contentsOfDirectoryAtPath DETECTED %@", path);
  if([path isEqualToString:@"/bin"] || [path isEqualToString:@"/Applications"] || ![[ABPattern sharedInstance] u:path i:11012]) {
    HBLogError(@"ABPattern WARNING: contentsOfDirectoryAtPath WAS BLOCKED %@", path);
    return %orig(@"없는 디렉토리입니다. 확인 후 다시 시도해주세요.", error);
  }
  return %orig;
}
%end

%hook UIApplication
-(BOOL)canOpenURL:(NSURL *)path {
  HBLogError(@"ABPattern canOpenURL %@", [path absoluteString]);
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

// -(NSString *)stringByAppendingString: (NSString *)aString {
//   NSString *orig = %orig;
//   HBLogError(@"ABPattern stringByAppendingString %@", orig);
//   // if([orig isEqualToString:@"JBJB123456789"]) return @"KBKB123456788";
//   if([orig isEqualToString:@"%@ %@"]) return @"모행? ㅋ";
//   return orig;
// }

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
  HBLogError(@"ABPattern writeToFile %@",path);
  if(![[ABPattern sharedInstance] u:path i:13004]) {
    * error = [[ABPattern sharedInstance] er];
    // * error = [NSError errorWithDomain:@"ProtectedBy.ABypass" code:200 userInfo:nil];
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
    // * error = [NSError errorWithDomain:@"ProtectedBy.ABypass" code:200 userInfo:nil];
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
    
    return %orig;
}

+ (instancetype)bundleWithPath:(NSString *)path {
    if(![[ABPattern sharedInstance] u:path i:16002]) return nil;

    return %orig;
}

- (instancetype)initWithURL:(NSURL *)url {
    if(![[ABPattern sharedInstance] u:[url absoluteString] i:16003]) return nil;
    
    return %orig;
}

- (instancetype)initWithPath:(NSString *)path {
    if(![[ABPattern sharedInstance] u:path i:16004]) return nil;

    return %orig;
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
  if([path isEqualToString:@"/etc/localtime"]) return %orig("ㅂㅂ", statbuf);
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
//   if(![[ABPattern sharedInstance] c:[[NSString alloc] initWithUTF8String:path]]) return %orig("/jb/ProtectedBy.ABypass", flags);
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
    // HBLogError(@"dladdr %s", info->dli_fname);
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

//   NSArray *symbols = @[ @"MSHookFunction", @"MSHookMessageEx", @"MSFindSymbol", @"MSGetImageByName", @"ZzBuildHook", @"DobbyHook", @"LHHookFunctions" ];
//   if([symbols containsObject:sym]) return NULL;
//   return %orig;
// }

%hookf(int, sysctl, int *name, u_int namelen, void *oldp, size_t *oldlenp, void *newp, size_t newlen) {
  if(namelen == 4
  && name[0] == CTL_KERN
  && name[1] == KERN_PROC
  && name[2] == KERN_PROC_ALL
  && name[3] == 0) {
    *oldlenp = 0;
    return 0;
  }
  int ret = %orig;
  if(ret == 0
  && name[0] == CTL_KERN
  && name[1] == KERN_PROC
  && name[2] == KERN_PROC_PID
  && name[3] == getpid()) {
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
%hookf(const char *, _dyld_get_image_name, uint32_t image_index) {
  const char *ret = %orig;
  NSString *image_name = [[NSFileManager defaultManager] stringWithFileSystemRepresentation:ret length:strlen(ret)];
  if([[ABPattern sharedInstance] i:image_name]) {
    NSString *uuid = [[NSUUID UUID] UUIDString];
    return [[NSString stringWithFormat:@"/usr/lib/%@.dylib", uuid] UTF8String];
    // return "/.file";
    // return "찾을 수 없는 파일입니다. 잠시 후 다시 시도하세요. 만약 문제가 지속되면, ABypassTeam@protonmail.com으로 문의해주세요.";
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
%hookf(char *, realpath, const char *pathname, char *resolved_path) {
    BOOL doFree = (resolved_path != NULL);
    NSString *path = nil;

    if(pathname) {
        path = [[NSFileManager defaultManager] stringWithFileSystemRepresentation:pathname length:strlen(pathname)];

        if(![[ABPattern sharedInstance] u:path i:20019]) {
            errno = ENOENT;
            return NULL;
        }
    }

    char *ret = %orig;

    // Recheck resolved path.
    if(ret) {
        NSString *resolved_path_ns = [[NSFileManager defaultManager] stringWithFileSystemRepresentation:ret length:strlen(ret)];

        if(![[ABPattern sharedInstance] u:resolved_path_ns i:20020]) {
            errno = ENOENT;

            if(doFree) {
                free(ret);
            }

            return NULL;
        }
    }

    return ret;
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

// %hookf(void, _dyld_register_func_for_add_image, void (*func)(const struct mach_header* mh, intptr_t vmaddr_slide)) {
//   HBLogError(@"ABPattern _dyld_register_func_for_add_image denied.");
// }

@import Darwin.POSIX.glob;
// int glob(const char *pattern, int flags, int (*errfunc) (const char *epath, int eerrno), glob_t *pglob);
%hookf(int, glob, const char *pattern, int flags, int *errfunc, glob_t *pglob) {
  if([@(pattern) hasPrefix:@"/Applications/"]) {
    return %orig("/Library/BawAppie/ABypass/*.*", flags, errfunc, pglob);
  }
  return %orig;
}

%hookf(kern_return_t, task_info, task_name_t target_task, task_flavor_t flavor, task_info_t task_info_out, mach_msg_type_number_t *task_info_outCnt) {   
    if (flavor == TASK_DYLD_INFO) {
        kern_return_t ret = %orig(target_task, flavor, task_info_out, task_info_outCnt);

        if (ret == KERN_SUCCESS) {
            struct task_dyld_info *task_info = (struct task_dyld_info *) task_info_out;
            struct dyld_all_image_infos *dyld_info = (struct dyld_all_image_infos *) task_info->all_image_info_addr;
            dyld_info->infoArrayCount = 1;
            dyld_info->uuidArrayCount = 1;
        }

        return ret;
    }

    return %orig(target_task, flavor, task_info_out, task_info_outCnt);
}

struct sockaddr_in {
  short sin_family; // 주소 체계: AF_INET
  u_short sin_port; // 16 비트 포트 번호, network byte order 
  struct in_addr sin_addr; // 32 비트 IP 주소 
  char sin_zero[8]; // 전체 크기를 16 비트로 맞추기 위한 dummy
};

int connect(int sockfd, const struct sockaddr *addr, socklen_t addrlen);
%hookf(int, connect, int sockfd, const struct sockaddr *addr, socklen_t addrlen) {
  struct sockaddr_in *addr2 = (struct sockaddr_in *)addr;

  if((*addr2).sin_port == htons(27042) || (*addr2).sin_port == htons(15371)) {
    (*addr2).sin_port = htons(25865);
  }
  // return %orig(sockfd, (struct sockaddr *)&addr2, sizeof(struct sockaddr_in));
  return %orig;
}
// %hookf(int, exit, int) {
//   HBLogError(@"ABPattern exit detected.. %@", [NSThread callStackSymbols]);
//   return %orig;
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
int fake_syscall(int number, ...) {
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
            NSLog(@"[AntiDebugBypass] catch 'syscall(SYS_ptrace, PT_DENY_ATTACH, 0, "
                  @"0, 0)' and bypass.");
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


static int (*orig_ptrace) (int request, pid_t pid, caddr_t addr, int data);
static int my_ptrace (int request, pid_t pid, caddr_t addr, int data){
    HBLogError(@"[ABZZ] ptrace");
    if(request == 31){
        HBLogError(@"[ABZZ] 31");
        return 0;
    }
    return orig_ptrace(request,pid,addr,data);
}

@import Darwin.POSIX.dirent;
static DIR *(*orig_opendir)(const char *filename);
static DIR *hook_opendir(const char *filename) {
  HBLogError(@"ABPattern opendir detected.");
  if(filename) {
    NSString *path = [[NSFileManager defaultManager] stringWithFileSystemRepresentation:filename length:strlen(filename)];
    if(![[ABPattern sharedInstance] u:path i:20025]) {
      errno = ENOENT;
      return NULL;
    }
  }
  return orig_opendir(filename);
}



void findSegment(const uint8_t *target, const uint32_t target_len, void (*callback)(uint8_t *)) {
  const struct mach_header_64 *header = (const struct mach_header_64*) _dyld_get_image_header(0);
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
    NSLog(@"[ABASM] ABASM Patcher has crashed. Aborting patch.. (%p)", target);
    return false;
  }

  return true;
}

void patchEnchantedSYS_open(uint8_t* match) {
  uint8_t patch[] = {
    0x40, 0x00, 0x80, 0xD2 // MOV  X16, #2
  };
  patchCode(match+4, patch, sizeof(patch));
  NSLog(@"[ABASM] A-Bypass found the malware and removed it. (SYS_open: %p)", match);
}

void removeEnchantedSYS_open() {
  const uint8_t target[] = {
    0xB0, 0x00, 0x80, 0xD2, // MOV  X16, #5
    0x01, 0x10, 0x00, 0xD4 // SVC  0x80
  };
  NSLog(@"[ABASM] Starting malware detection. (SYS_open)");
  findSegment(target, sizeof(target), &patchEnchantedSYS_open);
}


void patchSYS_access(uint8_t* match) {
  uint8_t patch[] = {
    0x40, 0x00, 0x80, 0xD2 // MOV  X16, #2
  };
  patchCode(match+4, patch, sizeof(patch));
  NSLog(@"[ABASM] A-Bypass found the malware and removed it. (SYS_access: %p)", match);
}

void removeSYS_access() {
  const uint8_t target[] = {
    0x30, 0x04, 0x80, 0xD2, // MOV  X16, #0x21
    0x01, 0x10, 0x00, 0xD4, // SVC  0x80
  };
  NSLog(@"[ABASM] Starting malware detection. (SYS_access)");
  findSegment(target, sizeof(target), &patchSYS_access);
}

void patchSYS_open(uint8_t* match) {
  uint8_t patch[] = {
    0x40, 0x00, 0x80, 0xD2 // MOV  X16, #2
  };
  patchCode(match+4, patch, sizeof(patch));
  NSLog(@"[ABASM] A-Bypass found the malware and removed it. (SYS_open: %p)", match);
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
  NSLog(@"[ABASM] Starting malware detection. (SYS_open)");
  findSegment(target, sizeof(target), &patchSYS_open);
  findSegment(target2, sizeof(target2), &patchSYS_open);
  findSegment(target3, sizeof(target3), &patchSYS_open);
}

void patchSYS_symlink(uint8_t* match) {
  uint8_t patch[] = {
    0x40, 0x00, 0x80, 0xD2 // MOV  X16, #2
  };
  patchCode(match+4, patch, sizeof(patch));
  NSLog(@"[ABASM] A-Bypass found the malware and removed it. (SYS_symlink: %p)", match);
}

void removeSYS_symlink() {
  const uint8_t target[] = {
    0x30, 0x07, 0x80, 0xD2, // MOV  X16, #57
    0x01, 0x10, 0x00, 0xD4 // SVC  0x80
  };
  NSLog(@"[ABASM] Starting malware detection. (SYS_symlink)");
  findSegment(target, sizeof(target), &patchSYS_symlink);
}

void patchSVC80(uint8_t* match) {
  uint8_t patch[] = {
    0x10, 0x00, 0x80, 0x92 // NOP
  };
  patchCode(match+4, patch, sizeof(patch));
  NSLog(@"[ABASM] A-Bypass found the malware and removed it. (SVC80: %p)", match);
}

void removeSVC80() {
  const uint8_t target[] = {
    0x01,0x10, 0x00, 0xD4 // SVC  0x80
  };
  NSLog(@"[ABASM] Starting malware detection. (SVC80)");
  findSegment(target, sizeof(target), &patchSVC80);
}



// HANAMEMBERS
void patch2(uint8_t* match) {
  uint8_t patch[] = {
    0x1F, 0x20, 0x03, 0xD5,
    0x1F, 0x20, 0x03, 0xD5,
    0x1F, 0x20, 0x03, 0xD5,
    0x1F, 0x20, 0x03, 0xD5,
    0x1F, 0x20, 0x03, 0xD5,
    0x1F, 0x20, 0x03, 0xD5,
  };
  patchCode(match, patch, sizeof(patch));
}
void remove2() {
  const uint8_t target[] = {
    0x5B, 0x28, 0x1E, 0x94,
    0x95, 0xBF, 0x1D, 0x94,
    0x0E, 0x53, 0x16, 0x94,
    0x1F, 0xC6, 0x15, 0x94,
    0x03, 0xE2, 0x15, 0x94,
    0xB7, 0x0D, 0x1A, 0x94,
  };
  findSegment(target, sizeof(target), &patch2);
}

// NICEZKIMI
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

// HWAHAE
void patch4(uint8_t* match) {
  uint8_t patch[] = {
    0x00, 0x00, 0x80, 0xD2,
    0xC0, 0x03, 0x5F, 0xD6
  };
  patchCode(match-0x18, patch, sizeof(patch));
}
void remove4() {
  const uint8_t target[] = {
    0x08, 0x09, 0xA0, 0x72,
    0x1F, 0x00, 0x08, 0x6B,
    0xA1, 0x01, 0x00, 0x54
  };
  findSegment(target, sizeof(target), &patch4);
}

// ARXAN
void patch5(uint8_t* match) {
  uint8_t patch[] = {
    0xC0, 0x03, 0x5F, 0xD6  // RET
  };
  patchCode(match, patch, sizeof(patch));
}
void remove5() {
  const uint8_t target[] = {
    0xFC, 0x6F, 0xBA, 0xA9,
  };
  findSegment(target, sizeof(target), &patch5);
}




void (*orig)(void);
void repl(void) {
  HBLogError(@"Removing JAILBREAK22 Detection");
  return;
}

void hookSymbol(const char *string) {
  void* hook = MSFindSymbol(NULL, string);
  MSHookFunction((void *)hook, (void *)repl, (void **)&orig);
}

int (*orig0)(void);
int repl0(void) {
  HBLogError(@"Removing JAILBREAK22 Detection");
  return 0;
}

void hookSymbol0(const char *string) {
  void* hook = MSFindSymbol(NULL, string);
  MSHookFunction((void *)hook, (void *)repl0, (void **)&orig0);
}


#include <hookzz.h>
struct section_64 *zz_macho_get_section_64_via_name(struct mach_header_64 *header, char *sect_name);
zpointer zz_vm_search_data(const zpointer start_addr, zpointer end_addr, zbyte *data, zsize data_len);
struct segment_command_64 *zz_macho_get_segment_64_via_name(struct mach_header_64 *header, char *segment_name);

typedef zpointer (*zzgetcallstackdata_ptr_t)(CallStack *callstack_ptr, char *key);
typedef bool (*zzsetcallstackdata_ptr_t)(CallStack *callstack_ptr, char *key, zpointer value_ptr, zsize value_size);


#ifdef DEBUG
#define debugMsg(...) HBLogError(__VA_ARGS__)
#else
#define debugMsg(...)
#endif

void hook_svc_pre_call(RegState *rs, ThreadStack *threadstack, CallStack *callstack) {
    int num_syscall;
    int request;
    num_syscall = (int)(uint64_t)(rs->general.regs.x16);
    request = (int)(uint64_t)(rs->general.regs.x0);
    debugMsg(@"[ABZZ] SVC PRECALL! %d", num_syscall);
    
    zzsetcallstackdata_ptr_t ZzSetCallStackData_ = (zzsetcallstackdata_ptr_t)MSFindSymbol(MSGetImageByName("/Library/BawAppie/ABypass/Dependency.dylib"), "_ZzSetCallStackData");
    #define STACK_SET_(callstack, key, value, type) ZzSetCallStackData_(callstack, key, &(value), sizeof(type))

    if (num_syscall == SYS_syscall) {
        int arg1 = (int)(uint64_t)(rs->general.regs.x1);
        if (request == SYS_ptrace && arg1 == PT_DENY_ATTACH) {
            *(unsigned long *)(&rs->general.regs.x1) = 10;
            debugMsg(@"[ABZZ] catch 'SVC #0x80; syscall(ptrace)' and bypass");
        } else if(request == SYS_access) {
          char *arg1str = (char *)rs->general.regs.x1;
          NSString *nsArg1 = [[NSString alloc] initWithUTF8String:arg1str];
          debugMsg(@"[ABZZ] SVC ACCESS DETECTED!!!! %@", nsArg1);
          if(![[ABPattern sharedInstance] u:nsArg1 i:30002]) {
            debugMsg(@"[ABZZ] BLOCKED!!!!");
            const char **arg1 = (const char **)&rs->general.regs.x1;
            const char *path = "/ProtectedBy.ABypass.With.ABZZ";
            *arg1 = path;
          }
        }
    } else if (num_syscall == SYS_ptrace) {
        request = (int)(uint64_t)(rs->general.regs.x0);
        if (request == PT_DENY_ATTACH) {
            *(unsigned long *)(&rs->general.regs.x0) = 10;
            debugMsg(@"[ABZZ] catch 'SVC-0x80; ptrace' and bypass");
        }
    } else if(num_syscall == SYS_sysctl) {
        STACK_SET_(callstack, (char *)"num_syscall", num_syscall, int);
        STACK_SET_(callstack, (char *)"info_ptr", rs->general.regs.x2, zpointer);
    } else if(num_syscall == SYS_open || num_syscall == SYS_access || num_syscall == SYS_statfs64 || num_syscall == SYS_statfs || num_syscall == SYS_lstat64 || num_syscall == SYS_stat64) {
        char *arg1str = (char *)rs->general.regs.x0;
        debugMsg(@"[ABZZ] SYS_open with SVC 80, %s", arg1str);
        if(![[ABPattern sharedInstance] u:[[NSString alloc] initWithUTF8String:arg1str] i:30001]) {
          debugMsg(@"[ABZZ] Blocked!");
          const char **arg1 = (const char **)&rs->general.regs.x0;
          const char *path = "/ProtectedBy.ABypass.With.ABZZ";
          *arg1 = path;
        }
    }
}

void hook_svc_half_call(RegState *rs, ThreadStack *threadstack, CallStack *callstack) {
    zzgetcallstackdata_ptr_t ZzGetCallStackData_ = (zzgetcallstackdata_ptr_t)MSFindSymbol(MSGetImageByName("/Library/BawAppie/ABypass/Dependency.dylib"), "_ZzGetCallStackData");
    #define STACK_GET_(callstack, key, type) *(type *)ZzGetCallStackData_(callstack, key)

    if((bool)ZzGetCallStackData_(callstack, (char *)"num_syscall")) {
        int num_syscall = STACK_GET_(callstack, (char *)"num_syscall", int);
        struct kinfo_proc *info = STACK_GET_(callstack, (char *)"info_ptr", struct kinfo_proc *);
        if (num_syscall == SYS_sysctl) {
          if((info->kp_proc.p_flag & P_TRACED) == P_TRACED) {
            HBLogError(@"[ABZZ] catch 'SVC-0x80; sysctl' and bypass");
            info->kp_proc.p_flag &= ~P_TRACED;
          }
        }
    }
}
struct section_64 *zz_macho_get_section_64_via_name(struct mach_header_64 *header, char *sect_name) {
    struct load_command *load_cmd;
    struct segment_command_64 *seg_cmd_64;
    struct section_64 *sect_64;
    
    load_cmd = (struct load_command *)((zaddr)header + sizeof(struct mach_header_64));
    for (zsize i = 0; i < header->ncmds;
         i++, load_cmd = (struct load_command *)((zaddr)load_cmd + load_cmd->cmdsize)) {
        if (load_cmd->cmd == LC_SEGMENT_64) {
            seg_cmd_64 = (struct segment_command_64 *)load_cmd;
            sect_64 = (struct section_64 *)((zaddr)seg_cmd_64 +
                                            sizeof(struct segment_command_64));
            for (zsize j = 0; j < seg_cmd_64->nsects;
                 j++, sect_64 = (struct section_64 *)((zaddr)sect_64 + sizeof(struct section_64))) {
                if (!strcmp(sect_64->sectname, sect_name)) {
                    return sect_64;
                }
            }
        }
    }
    return NULL;
}
zpointer zz_vm_search_data(const zpointer start_addr, zpointer end_addr, zbyte *data,
                           zsize data_len)
{
    zpointer curr_addr;
    // if (start_addr <= 0)
    //     printf("search address start_addr(%p) < 0", (zpointer)start_addr);
    if (start_addr > end_addr)
        printf("search start_add(%p) < end_addr(%p)", (zpointer)start_addr, (zpointer)end_addr);
    
    curr_addr = start_addr;
    
    while (end_addr > curr_addr)
    {
        if (!memcmp(curr_addr, data, data_len))
        {
            return curr_addr;
        }
        curr_addr = (zpointer)((zaddr)curr_addr + data_len);
    }
    return 0;
}
struct segment_command_64 *
zz_macho_get_segment_64_via_name(struct mach_header_64 *header,
                                 char *segment_name) {
    struct load_command *load_cmd;
    struct segment_command_64 *seg_cmd_64;
    // struct section_64 *sect_64;
    
    load_cmd = (struct load_command *)((zaddr)header + sizeof(struct mach_header_64));
    for (zsize i = 0; i < header->ncmds;
         i++, load_cmd = (struct load_command *)((zaddr)load_cmd + load_cmd->cmdsize)) {
        if (load_cmd->cmd == LC_SEGMENT_64) {
            seg_cmd_64 = (struct segment_command_64 *)load_cmd;
            if(!strcmp(seg_cmd_64->segname, segment_name)) {
                return seg_cmd_64;
            }
        }
    }
    return NULL;
}

typedef ZZSTATUS (*zzbuildhookaddress_ptr_t)(zpointer target_start_ptr, zpointer target_end_ptr, PRECALL pre_call_ptr, HALFCALL half_call_ptr);
typedef ZZSTATUS (*zzbuildhook_ptr_t)(zpointer target_ptr, zpointer replace_ptr, zpointer *origin_ptr, PRECALL pre_call_ptr, POSTCALL post_call_ptr);
typedef ZZSTATUS (*zzenablehook_ptr_t)(zpointer target_ptr);

void hookSVC80Real(int num) {
    zaddr svc_x80_addr;
    zaddr curr_addr, text_start_addr, text_end_addr;
    uint32_t svc_x80_byte = 0xd4001001;
    
    const struct mach_header *header = _dyld_get_image_header(num);
    struct segment_command_64 *seg_cmd_64 = zz_macho_get_segment_64_via_name((struct mach_header_64 *)header, (char *)"__TEXT");
    zsize slide = (zaddr)header - (zaddr)seg_cmd_64->vmaddr;
    
    struct section_64 *sect_64 = zz_macho_get_section_64_via_name((struct mach_header_64 *)header, (char *)"__text");
    
    text_start_addr = slide + (zaddr)sect_64->addr;
    text_end_addr = text_start_addr + sect_64->size;
    curr_addr = text_start_addr;
    
    while (curr_addr < text_end_addr) {
        svc_x80_addr = (zaddr)zz_vm_search_data((zpointer)curr_addr, (zpointer)text_end_addr, (zbyte *)&svc_x80_byte, 4);
        if (svc_x80_addr) {
            HBLogError(@"hook svc #0x80 at %p with aslr (%p without aslr)", (void *)svc_x80_addr, (void *)(svc_x80_addr - slide));
            zzbuildhookaddress_ptr_t ZzBuildHookAddress_ = (zzbuildhookaddress_ptr_t)MSFindSymbol(MSGetImageByName("/Library/BawAppie/ABypass/Dependency.dylib"), "_ZzBuildHookAddress");
            zzenablehook_ptr_t ZzEnableHook_ = (zzenablehook_ptr_t)MSFindSymbol(MSGetImageByName("/Library/BawAppie/ABypass/Dependency.dylib"), "_ZzEnableHook");
            ZzBuildHookAddress_((void *)svc_x80_addr, (void *)(svc_x80_addr + 4), hook_svc_pre_call, hook_svc_half_call);
            ZzEnableHook_((void *)svc_x80_addr);
            curr_addr = svc_x80_addr + 4;
        } else {
            break;
        }
    }
}

void hookingSVC80() {
  HBLogError(@"[ABZZ] Hello, Jailbreak Detections!");
  dlopen("/Library/BawAppie/ABypass/Dependency.dylib", RTLD_NOW);

  uint32_t count = _dyld_image_count();
  Dl_info dylib_info;
  for(uint32_t i = 0; i < count; i++) {
    dladdr(_dyld_get_image_header(i), &dylib_info);
    NSString *detectedDyld = [NSString stringWithUTF8String:dylib_info.dli_fname];
    if([detectedDyld containsString:@"/var"]) {
      HBLogError(@"[ABZZ] We'll hooking %s! haha!", dylib_info.dli_fname);
      hookSVC80Real(i);
    }
  }
}

const int symbolsHideCount = 2;
const char *symbolsHide[] = {
    "MSHookMessageEx",
    "MSHookFunction"
};

const int symbolsFakeCount = 4;
const char *symbolsFake[] = {
    "dlsym",
    "_dyld_image_count",
    "_dyld_get_image_header",
    "dladdr"
};

const uint8_t fakePrologue[] = {
    0xff, 0xc3, 0x02, 0xd1 // SUB SP, SP, #0xB0
};

bool dlsymReal = true;

void *(*orig_dlsym)(void *, const char *);
void *hooked_dlsym(void *handle, const char *symbol) {
    HBLogError(@"ABPattern dlsym symbol %s", symbol);
    int64_t link_register = 0;
    __asm ("MOV %[output], LR" : [output] "=r" (link_register));
    if (isSafePTR(link_register) == 0) {
        for (int i = 0; i < symbolsHideCount; i++) {
            if (strcmp(symbol, symbolsHide[i]) == 0) {
                // NSLog(@"[SnapHide] > Denied dlsym of %s, was actually %p", symbol, orig_dlsym(handle, symbol));
                return 0;
            }
        }
        if (strstr(symbol, "dlsym") != 0) {
            if (dlsymReal) {
                dlsymReal = false;
                // NSLog(@"[SnapHide] > Replaced dlsym of %s", symbol);
                return (void *)&hooked_dlsym;
            }
            dlsymReal = true;
        }
        for (int i = 0; i < symbolsFakeCount; i++) {
            if (strcmp(symbol, symbolsFake[i]) == 0) {
                // NSLog(@"[SnapHide] > Need to fake %s", symbol);
                return (void *) fakePrologue;
            }
        }
    }
    return orig_dlsym(handle, symbol);
}

extern const char** environ;

void patchPolice() {
    const struct mach_header_64 *header = (const struct mach_header_64*) _dyld_get_image_header(0);
    const struct section_64 *section = getsectbynamefromheader_64(header, "__DATA", "__got");

    const intptr_t startAddress = (intptr_t) header + section->offset;
    const intptr_t endAddress = startAddress + section->size;
    const intptr_t target = (intptr_t) environ;

    char ****environStolen = 0;

    for (uint64_t current = startAddress; current < endAddress; current += 8) {
        intptr_t *ptrOne = *(intptr_t **)current;
        if (ptrOne != 0) {
            intptr_t ptrTwo = *ptrOne;
            if (ptrTwo == target) {
                environStolen = (char ****) current;
                break;
            }
        }
    }

    if (environStolen == 0) {
        return;
    }

    int environSize = 0;
    char** ogEnviron = **environStolen;

    while (ogEnviron[environSize]) {
        environSize++;
    }

    char** newEnviron = (char **) malloc((environSize + 1) * sizeof(char *));
    int newEnvironCounter = 0;

    for (int i = 0; i < environSize; i++) {
        char *entry = ogEnviron[i];
        const char needle[22] = "DYLD_INSERT_LIBRARIES";

        if (strstr(entry, needle) != 0 || entry[0] == '_') {
            continue;
        }

        newEnviron[newEnvironCounter++] = entry;
    }

    newEnviron[newEnvironCounter] = 0;

    char*** newEnvironPtr = (char***) malloc(sizeof(char***));
    *newEnvironPtr = newEnviron;
    *environStolen = newEnvironPtr;
}




%group toss
@interface ADL : UILabel
@end
%hook ADL
-(NSString *)text {
  NSString *ret = %orig;
  if([ret containsString:@"금융의 모든 것"]) {
    NSString *toss = [ret stringByReplacingOccurrencesOfString:@"금융" withString:@"탈옥 감지"];
    [self setText:toss];
  }
  return ret;
}
%end
%end

%group BinaryChecker
%hook NSString
- (NSString *)substringFromIndex: (NSUInteger)from {
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

%ctor {
  // HBLogError(@"[ABLoader] Hello! I'm ABLoader!");
  identifier = [NSBundle mainBundle].bundleIdentifier;    
  NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
  center = [MRYIPCCenter centerNamed:@"com.rpgfarm.a-bypass"];

  NSFileManager *manager = [NSFileManager defaultManager];

  NSMutableDictionary *flyjb = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/kr.xsf1re.flyjb.plist"];
  if([manager fileExistsAtPath:@"/Library/MobileSubstrate/DynamicLibraries/ FlyJB2.dylib"] && [flyjb[identifier] isEqual:@1]) {
    [center callExternalVoidMethod:@selector(handleShowNotification:) withArguments:@{
      @"title" : @"A-Bypass Warning",
      @"message" : @"A-Bypass has detected that FlyJB is turned on for this app. This can cause conflict with each other.",
      @"identifier": @"com.apple.Preferences"
    }];
  }
  NSMutableDictionary *libertylite = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.ryleyangus.libertylite.plist"];
  if([manager fileExistsAtPath:@"/Library/MobileSubstrate/DynamicLibraries/zzzzzLiberty.dylib"] && [libertylite[[NSString stringWithFormat:@"Liberty-%@", identifier]] isEqual:@1]) {
    [center callExternalVoidMethod:@selector(handleShowNotification:) withArguments:@{
      @"title" : @"A-Bypass Warning",
      @"message" : @"A-Bypass has detected that Liberty Lite is turned on for this app. This can cause conflict with each other.",
      @"identifier": @"com.apple.Preferences"
    }];
  }
  NSMutableDictionary *shadow = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/me.jjolano.shadow.apps.plist"];
  if([manager fileExistsAtPath:@"/Library/MobileSubstrate/DynamicLibraries/0Shadow.dylib"] && [shadow[identifier] isEqual:@1]) {
    [center callExternalVoidMethod:@selector(handleShowNotification:) withArguments:@{
      @"title" : @"A-Bypass Warning",
      @"message" : @"A-Bypass has detected that Shadow is turned on for this app. This can cause conflict with each other.",
      @"identifier": @"com.apple.Preferences"
    }];
  }

  #ifdef DEBUG
  if(true) {
  #else
  if(![[NSBundle mainBundle] pathForResource:@"embedded" ofType:@"mobileprovision"]) {
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

    ABSI.ABASMBlackList = @[
      @"com.kakaobank.channel",
      @"com.iwilab.kakaotalk",
      @"com.vivarepublica.cash",
      @"com.kbcard.kbkookmincard",
      @"com.kbcard.cxh.appcard",
      @"com.shinhancard.MobilePay",
      @"com.lottecard.appcard",
      @"com.toyopagroup.picaboo"
    ];

    ABSI.useRemoveSYS_Open = @[
      @"com.tmoney.tmpay",
      @"com.suhyup.pesmb",
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
      // @"kr.xsf1re.XFTestApp",
    ];

    if([ABSI.hookSVC80 containsObject:identifier]) hookingSVC80();

    isSubstitute = ([manager fileExistsAtPath:@"/usr/lib/libsubstitute.dylib"] && ![manager fileExistsAtPath:@"/usr/lib/substrate"] && ![manager fileExistsAtPath:@"/usr/lib/libhooker.dylib"]);
    HBLogError(@"[ABLoader] It is Substitute? %d", isSubstitute);

    [[ABPattern sharedInstance] setup:dic[@"data"]];
    %init(framework);
    %init(CFunction);
    %init(ObjcMethods);
    if([identifier isEqualToString:@"com.iwilab.kakaotalk"]) return;
    if([identifier isEqualToString:@"com.kakaopay.biz.store"]) return;

    if([identifier isEqualToString:@"com.kakaobank.channel"]) {
      //____block_invoke
      if([version isEqualToString:@"2.1.0"]) {
        hookSymbol("_alV5hUS0FPUslWb3Iye8WAiqoT683zmOM");
        hookSymbol("_nx5INjj8JMw7yKOFeJWRF5uvxdP5V9AWZ");
        hookSymbol("_c6XRrqvcKDif4uraTqm4kPNcIA9yqnHex");
        hookSymbol("_gF0zwreOmJu2hgizmljZyeNJoC7DqJnXF");
      } else if([version isEqualToString:@"2.1.1"]) {
        hookSymbol("_xUteZoGzpA6kmhmEvjEVOZcygzxCcpDDX");
        hookSymbol("_gj7uZBpjZnVu8pDghEwA7WYC7BDycyPMt");
        hookSymbol("_zWNoIyTcdGrMqQ9YuOhAXZMw5jXtVhHRm");
        hookSymbol("_kh77Zk42DiEZ4aObRdUEkzCpZGo3Sfp5m");
        hookSymbol("_mRbBQDQqj0i4G4zNgH26SR59YS4ExvbH3");
      } else if([version isEqualToString:@"2.1.2"]) {
        hookSymbol("_yGXM3FciwxROCjTZDXkC7AOTekXG0QuN0");
        hookSymbol("_gj0oY2Z7mnBAlWmW3SoyYCbfPzAHpOPDB");
        hookSymbol("_v4FYY46DPNI5lJLCn8Q5Fsevachq5coEB");
        hookSymbol("_qdokMiL599zGXbNUYRQBmJIR4UAevrHcY");
        hookSymbol("_bW0xPLz98GyvHEXyiTYBKdxPssfk7VMRI");
      } else if([version isEqualToString:@"2.1.3"]) {
        hookSymbol("_rsLiQZ2R994kANAVMzWZExct2mYqY9OPB");
        hookSymbol("_cdXh4gwRgstkD6j6XgpJMr0hj2jodSZYf");
        hookSymbol("_c82lahUfYF3tnumOvx5TuKU0MsG92bkpO");
        hookSymbol("_i1dWv63Mi8WbOczLP9DK4PvTA3oCgrb3j");
        hookSymbol("_yQHvfWG0wWqja1wykggzQppO8g3MVJOas");
      } else if([version isEqualToString:@"2.2.0"]) {
        hookSymbol("_jrJICh4hLxfRNNa408Q0fdPNLk9YMZyUy");
        hookSymbol("_lBBTkshV3YNayn7jXKUINZOg3UgdgJwhn");
        hookSymbol("_b4pvVqrR8YBcPNYYdNDsJLsvwTu7b4HMe");
        hookSymbol("_aVSjJ8Sv1fVv7kyDtJ6kaHK06itGW40ry");
        hookSymbol("_tiZsZdyB5mP6Hf48gSODIjSTjGiGK6kRa");
      } else if([version isEqualToString:@"2.2.1"]) {
        hookSymbol("_tkXaezmftrCEQjdGTs8ry6gDDzL8FLUSD");
        hookSymbol("_dNbB9ABhV4KXIudOHBYligYRGbm2wWk2n");
        hookSymbol("_xnuPRjdXcws00st2B9ID5zToOEZ6R3Xg6");
        hookSymbol("_gQ5cTFyckbTAJFZDtXXjfRihyNAOPyDdE");
        hookSymbol("_x1BD2d1npuSlUBNXWYK3nkj8gefcyBKu9");
      }
    }
    if([identifier isEqualToString:@"com.kscc.t-gift"]) {
      // writeData(0x1001f013c, 0xC0035FD6);
    }

    if([identifier isEqualToString:@"com.vivarepublica.cash"]) %init(toss, ADL = objc_getClass("TDS.AdaptiveLabel"));
    if([identifier isEqualToString:@"com.suhyup.pesmb"]) removeSVC80();
    if([identifier isEqualToString:@"qa.com.qnb.eazymobile"]) removeSVC80();

    if(![ABSI.ABASMBlackList containsObject:identifier] && ![ABSI.hookSVC80 containsObject:identifier]) {
      if([ABSI.useRemoveSYS_Open containsObject:identifier]) removeEnchantedSYS_open();
      else removeSYS_open();
      removeSYS_access();
      removeSYS_symlink();
    }
    // return;

    if(objc_getClass("BinaryChecker") || objc_getClass("mVaccine")) %init(BinaryChecker);
    if([identifier isEqualToString:@"com.hana.hanamembers"]) remove2();
    if([identifier isEqualToString:@"com.nice.MyCreditManager"] || [identifier isEqualToString:@"com.niceid.niceipin"]) remove3();
    if([identifier isEqualToString:@"birdview.HwaHae"]) remove4();
    patchPolice();
    if(0)remove5();

    if(0)MSHookFunction(&dlsym, &hooked_dlsym, &orig_dlsym);
    MSHookFunction((void *)open, (void *)hook_open, (void **)&orig_open);
    MSHookFunction((void *)MSFindSymbol(NULL,"_syscall"), (void *)fake_syscall, (void **)&orig_syscall);
    MSHookFunction((void *)MSFindSymbol(NULL,"_ptrace"),(void*)my_ptrace,(void**)&orig_ptrace);
    // MSHookMessageEx([NSString class], @selector(stringWithFormat:), (IMP)repl_stringWithFormat, (IMP *)&orig_stringWithFormat);
    if(!isSubstitute) MSHookFunction((void *)MSFindSymbol(NULL,"_opendir"), (void *)hook_opendir, (void **)&orig_opendir);

    Class Stelian = objc_getClass("StockNewsdmManager") ?: (objc_getClass("StatementImplicitA") ?: (objc_getClass("SimpleScriptContex") ?: objc_getClass("CurrentHolderSQLTr")));

    if(Stelian && strcmp([Stelian defRandomString], "00000000") != 0) {
      [center callExternalVoidMethod:@selector(handleShowNotification:) withArguments:@{
        @"title" : [NSString stringWithFormat:@"A-Bypass seems not working (%s)", [Stelian defRandomString]],
        @"message" : @"A-Bypass stopped this app to protect your account.",
        @"identifier": @"com.apple.Preferences"
      }];
      exit(0);
    }

    if([[NSFileManager defaultManager] fileExistsAtPath:@"/Library/BawAppie/ABypass/ABKernel"]) {
      void *libHandle = dlopen("/System/Library/Frameworks/CoreFoundation.framework/CoreFoundation", RTLD_LAZY);
      CFNotificationCenterRef (*CFNotificationCenterGetDistributedCenter)() = (CFNotificationCenterRef (*)())dlsym(libHandle, "CFNotificationCenterGetDistributedCenter");
      if(CFNotificationCenterGetDistributedCenter) {
        NSDictionary* info = @{ @"Pid" : [NSNumber numberWithInt:getpid()] };
        CFNotificationCenterPostNotification(CFNotificationCenterGetDistributedCenter(), (__bridge CFStringRef)@"com.rpgfarm.abkernel", NULL, (__bridge CFDictionaryRef)info, YES);
      }
      dlclose(libHandle);
    }


  }
  NSDictionary* result = [center callExternalMethod:@selector(handleUpdateLicense:) withArguments:@{
    @"type": @2
  }];
  if(result) return;
  return;
}
