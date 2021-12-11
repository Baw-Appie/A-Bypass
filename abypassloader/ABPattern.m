#import "ABPattern.h"

@implementation AppIePattern

+(instancetype)sharedInstance {
  static dispatch_once_t p = 0;
  __strong static id _sharedSelf = nil;
  dispatch_once(&p, ^{
    _sharedSelf = [[self alloc] init];
  });
  return _sharedSelf;
}

-(id)init {
  self = [super init];
  if(self) {
    k = [NSMutableArray new];
    p = [NSMutableArray new];
    z = [NSMutableArray new];
    u = [NSMutableArray new];
    // 이거 절대 l 아님.. 대문자 i 임!!
    I = [NSMutableDictionary new];
    o = [NSMutableDictionary new];
  }
  return self;
}

-(NSArray *)pattern {
  return z;
}

-(void)setup:(NSMutableArray *)array {
  z = [array mutableCopy];
  HBLogError(@"%@", @"ABPattern setup complete!");
}

-(void)usk:(NSString *)oldpath n:(NSString *)newpath {
  if(![oldpath isAbsolutePath]) {
    NSString *oldpath_abs = [[[NSFileManager defaultManager] currentDirectoryPath] stringByAppendingPathComponent:oldpath];
    oldpath = oldpath_abs;
  }
  if(![newpath isAbsolutePath]) {
    NSString *newpath_abs = [[[NSFileManager defaultManager] currentDirectoryPath] stringByAppendingPathComponent:newpath];
    newpath = newpath_abs;
  }
  // HBLogError(@"[ABZZ] %@ is %@.. OK!", oldpath, newpath);
  I[newpath] = oldpath;
}

-(BOOL)c:(NSString *)path {
  return [self u:path i:0];
}

-(BOOL)u:(NSString *)path i:(int)index {
  #ifdef DEBUG
  // NSLog(@"ABPattern Request %@", path);
  #endif
  path = [path stringByReplacingOccurrencesOfString:@"file://" withString:@""];
  path = [path stringByReplacingOccurrencesOfString:@"//" withString:@"/"];
  if(![path isAbsolutePath]) {
    NSString *path_abs = [[[NSFileManager defaultManager] currentDirectoryPath] stringByAppendingPathComponent:path];
    path = path_abs;
  }
  for(NSString *item in [I allKeys]) {
    if([path hasPrefix:item]) {
      path = [path stringByReplacingOccurrencesOfString:item withString:I[item]];
      path = [path stringByReplacingOccurrencesOfString:@"file://" withString:@""];
      path = [path stringByReplacingOccurrencesOfString:@"//" withString:@"/"];
      if(![path isAbsolutePath]) {
        NSString *path_abs = [[[NSFileManager defaultManager] currentDirectoryPath] stringByAppendingPathComponent:path];
        path = path_abs;
      }
    }
  }
  if([path hasPrefix:@"/User"]) {
    NSMutableArray *pathComponents = [NSMutableArray arrayWithArray:[path pathComponents]];
    [pathComponents removeObjectAtIndex:0];
    [pathComponents removeObjectAtIndex:0];
    [pathComponents insertObject:@"/mobile" atIndex:0];
    [pathComponents insertObject:@"/var" atIndex:0];
    path = [NSString pathWithComponents:pathComponents];
  }
  if([path hasPrefix:@"/private/"]) {
    if(![path isEqualToString:@"/private/"] && ![path hasPrefix:@"/private/etc"] && ![path hasPrefix:@"/private/system_data"] && ![path hasPrefix:@"/private/var"] && ![path hasPrefix:@"/private/xarts"]) {
      return false;
    }
  }
  if([path hasPrefix:@"/private/var"] || [path hasPrefix:@"/private/etc"] || [path hasPrefix:@"/var/tmp"]) {
    NSMutableArray *pathComponents = [NSMutableArray arrayWithArray:[path pathComponents]];
    [pathComponents removeObjectAtIndex:1];
    path = [NSString pathWithComponents:pathComponents];
  }
  if([path containsString:@"ABypass"] || [path containsString:@"ABPattern"] || [path containsString:@"AutoTouch"] || [path containsString:@"flyjb"]) {
    // HBLogError(@"[ABPattern] 아니 뭐하세요..?? %@ %@", path, [NSThread callStackSymbols]);
    return false;
  }
  if([path isEqualToString:@"/dev/null"] || [path isEqualToString:@"/sbin/launchd"]) return true;
  if([path isEqualToString:@"/sbin/mount"] && index == 30001) return true;
  if([path isEqualToString:@"/sbin/mount"]) return false;
  if([path isEqualToString:@"/Applications"] || [path isEqualToString:@"/Applications/"] || [path isEqualToString:@"/usr/lib/"] || [path hasPrefix:@"/usr/lib/libobjc"] || [path containsString:@"libobjc"] || [path containsString:@"DSTK_DO_LOG"] || [path hasPrefix:@"/usr/lib/system"]) return true;
  if([path containsString:@"liberty"] || [path containsString:@"jailprotect"] || [path containsString:@"tsprotector"] || [path containsString:@"kernbypass"] || [path containsString:@"vnodebypass"]) return false;
  if([path containsString:@"AppList"] || [path containsString:@"PreferenceLoader"] || [path containsString:@"SnowBoard"] || [path containsString:@"Snowboard"] || [path containsString:@"iCleaner"]) return false;
  if([path hasSuffix:@"xargs"] || [path hasSuffix:@"unzip2"] || [path hasSuffix:@"libsubstrate.dylib"] || [path hasSuffix:@"substrate.h"] || [path hasSuffix:@"recache"]) return false;
  if(([path hasPrefix:@"/Library/MobileSubstrate/"] || [path hasPrefix:@"/usr/lib/TweakInject/"]) && ([path hasSuffix:@".dylib"] || [path hasSuffix:@".plist"])) {
    if([path isEqualToString:@"/Library/MobileSubstrate/MobileSubstrate.dylib"]) return false;
    if(!o[path]) {
      o[path] = @1;
      return true;
    } else if([o[path] isEqual:@1]) {
      o[path] = @2;
      return true;
    } else if([o[path] isEqual:@2]) {
      return false;
    }
  }
  for(NSString *search in z) {
    if([path hasPrefix:search]) {
      #ifdef DEBUG
      HBLogError(@"ABPattern Threat Detected %@, %@, %d", path, search, index);
      #endif
       return false;
    }
  }
  #ifdef DEBUG
  if(![path containsString:@"/System"] && ![path containsString:@"/var/mobile/Containers/Data"] && ![path containsString:@"/var/containers/Bundle/Application/"] && ![path isEqualToString:@"/"]) HBLogError(@"ABPattern Detection Fail %@ %d", path, index);
  #endif
  return true;
}
-(BOOL)k:(NSURL *)url {
  return [self c:[url absoluteString]];
}

-(BOOL)i:(NSString *)name {
  if([name hasPrefix:@"/Library/Frameworks"]
  || [name hasPrefix:@"/Library/Caches"]
  || [name hasPrefix:@"/Library/MobileSubstrate"]
  || [name hasPrefix:@"/usr/lib/tweaks"]
  || [name hasPrefix:@"/usr/lib/TweakInject"]
  || [name hasPrefix:@"/var/containers/Bundle/tweaksupport"]
  || [name hasPrefix:@"/var/containers/Bundle/dylibs"]
  || [name containsString:@"ubstrate"]
  || [name containsString:@"substrate"]
  || [name containsString:@"substitute"]
  || [name containsString:@"Substitrate"]
  || [name containsString:@"TweakInject"]
  || [name containsString:@"jailbreak"]
  || [name containsString:@"cycript"]
  || [name containsString:@"SBInject"]
  || [name containsString:@"pspawn"]
  || [name containsString:@"rocketbootstrap"]
  || [name containsString:@"libCS"]
  || [name containsString:@"libjailbreak"]
  || [name containsString:@"cynject"]
  || [name containsString:@"frida"]
  || [name containsString:@"Frida"]
  || [name containsString:@"libhooker"]
  || [name containsString:@"mryipc"]
  || [name containsString:@"ABLicense"]
  || [name containsString:@"Cephei"]
  || [name containsString:@"SnowBoard"]
  || [name containsString:@"ABypass"]
  || [name containsString:@"bfdecrypt"]) return YES;
  // if(![name isAbsolutePath]) name = [NSString stringWithFormat:@"/usr/lib/lib%@.dylib", name];
  // if(![self c:name]) return YES;
  return NO;
}
-(BOOL)ozd:(NSString *)name {
  if ([name containsString:@"substrate"] ||
      [name containsString:@"abdyld"] ||
      [name containsString:@"bawappie"] ||
      [name containsString:@"substitute"] ||
      [name containsString:@"substitrate"] ||
      [name containsString:@"cephei"] ||
      [name containsString:@"rocketbootstrap"] ||
      [name containsString:@"tweakinject"] ||
      [name containsString:@"jailbreak"] ||
      [name containsString:@"cycript"] ||
      [name containsString:@"pspawn"] ||
      [name containsString:@"libcolorpicker"] ||
      [name containsString:@"libcs"] ||
      [name containsString:@"bfdecrypt"] ||
      [name containsString:@"sbinject"] ||
      [name containsString:@"dobby"] ||
      [name containsString:@"libhooker"] ||
      [name containsString:@"snowboard"] ||
      [name containsString:@"libblackjack"] ||
      // [name containsString:@"libobjc-trampolines"] ||
      [name containsString:@"cephei"] ||
      [name containsString:@"libmryipc"] ||
      [name containsString:@"libactivator"] ||
      [name containsString:@"blackjack"] ||
      [name containsString:@"alderis"]) {
    return true;
  } else return false;
}

- (NSString *)re:(NSString *)path {
  NSDictionary *links = [m copy];

  for(NSString *key in links) {
    if([path hasPrefix:key]) {
      NSString *value = links[key];
      if([key isEqualToString:@"/"]) {
        path = [value stringByAppendingPathComponent:path];
      } else {
        path = [path stringByReplacingOccurrencesOfString:key withString:value];
      }
      break;
    }
  }

  return path;
}
// 페이크 끝

-(NSError *)er {
    NSDictionary *userInfo = @{
        NSLocalizedDescriptionKey: @"Operation was unsuccessful.",
        NSLocalizedFailureReasonErrorKey: @"Object does not exist.",
        NSLocalizedRecoverySuggestionErrorKey: @"Don't access this again"
    };

    NSError *error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFileNoSuchFileError userInfo:userInfo];
    return error;
}


@end
@implementation ABPatternObject
// ASML
- (id)objectForKeyedSubscript:(id)key {
  return [@"겨우 이걸로 막을라고?" dataUsingEncoding:NSUTF8StringEncoding];
}
- (id)valueForUndefinedKey:(id)key {
  return [@"겨우 이걸로 막을라고?" dataUsingEncoding:NSUTF8StringEncoding];
}
@end
