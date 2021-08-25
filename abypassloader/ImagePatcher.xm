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

#ifdef DEBUG
#define debugMsg(...) HBLogError(__VA_ARGS__)
#else
#define debugMsg(...)
#endif

void findSegmentByImageNum(const uint8_t *target, const uint32_t target_len, void (*callback)(uint8_t *), int image_num) {
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
  findSegmentByImageNum(target, target_len, callback, 0);
}

void findSegmentForDyldImage(const uint8_t *target, const uint32_t target_len, void (*callback)(uint8_t *)) {
  uint32_t count = _dyld_image_count();
  Dl_info dylib_info;
  for(uint32_t i = 0; i < count; i++) {
    dladdr(_dyld_get_image_header(i), &dylib_info);
    NSString *detectedDyld = [NSString stringWithUTF8String:dylib_info.dli_fname];
    if([detectedDyld containsString:@"/var"]) {
      debugMsg(@"[ABZZ] We'll hooking %s! haha!", dylib_info.dli_fname);
      findSegmentByImageNum(target, target_len, callback, i);
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
            || (*(uint32_t *)prev & 0xFFC003E0) == 0x6D8003E0
            || (*(uint32_t *)prev & 0xFFC003E0) == 0xD10003E0) {  //STP x, y, [SP,#-imm]!
          return prev;
        }
      }
    }
  }

  return (uint8_t *)target;
}

bool isSTP(uint32_t op) {
  return ((op & 0xFFC003E0) == 0xA98003E0
      || (op & 0xFFC003E0) == 0xA90003E0
      || (op & 0xFFC003E0) == 0x6D8003E0
      || (op & 0xFFC003E0) == 0xD10003E0
  );
}

uint8_t *findSA(const uint8_t *target) {
  const struct mach_header_64 *header = (const struct mach_header_64*) _dyld_get_image_header(0);
  const struct section_64 *executable_section = getsectbynamefromheader_64(header, "__TEXT", "__text");
  uint32_t *start = (uint32_t *) ((intptr_t) header + executable_section->offset);

  uint32_t *current = (uint32_t *)target;

  for(; current >= start; current -= 1) {
    uint32_t op = *current;
    if (isSTP(op)) {
        uint8_t *next = (uint8_t *)(current-1);
        if(isSTP(*(uint32_t *)next)) continue;
        return (uint8_t *)current;
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
uint8_t RET0[] = {
  0x00, 0x00, 0x80, 0xD2, //MOV X0, #0
  0xC0, 0x03, 0x5F, 0xD6  //RET
};
uint8_t RET1[] = {
  0x20, 0x00, 0x80, 0xD2, //MOV X0, #1
  0xC0, 0x03, 0x5F, 0xD6  //RET
};


// iXGuard
void patch1(uint8_t* match) {
  patchCode(findS(match), RET, sizeof(RET));
  patchCode(findSA(match), RET, sizeof(RET));
  debugMsg(@"[ABASM] patched or1: %p", match - _dyld_get_image_vmaddr_slide(0));
  debugMsg(@"[ABASM] patched r1: %p", findS(match) - _dyld_get_image_vmaddr_slide(0));
  debugMsg(@"[ABASM] patched r1 SA: %p", findSA(match) - _dyld_get_image_vmaddr_slide(0));
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
void patch2_1(uint8_t* match) {
  patchCode(findSA(match), RET0, sizeof(RET0));
  // debugMsg(@"[ABASM] patched r2-1: %p", match - _dyld_get_image_vmaddr_slide(0));
  // debugMsg(@"[ABASM] patched ret r2-1: %p", findSA(match) - _dyld_get_image_vmaddr_slide(0));
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

  // 탈옥 감지 결과 조회
  // Paycoin: -[Global checkLxShield:]
  // SKT PASS: -[SplashViewController lxShieldCheck]
  const uint8_t target3[] = {
    0x39, 0x01, 0x36, 0x0A,
    0xC9, 0x02, 0x29, 0x0A,
    0x29, 0x03, 0x09, 0x2A,
    0x59, 0x00, 0x36, 0x0A,
    0xC2, 0x02, 0x22, 0x0A,
    0x22, 0x03, 0x02, 0x2A, 
  };
  findSegment(target3, sizeof(target3), &patch2_1);
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

// ixShield
struct ix_detected_pattern {
    char resultCode[12];
    char object[128];
    char description[128];
};

struct ix_detected_pattern_list_gamehack {
    struct ix_detected_pattern *pattern;
    int listCount;
};

struct ix_verify_info {
    char verify_result[12];
    char verify_data[2048];
};

int (*orig_ix_sysCheckStart)(struct ix_detected_pattern **p_info);
int hook_ix_sysCheckStart(struct ix_detected_pattern **p_info) {
  // orig_ix_sysCheckStart(p_info);
  // HBLogError(@"[ABZZ] %s", (*p_info)->resultCode);
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

  *p_info = patternInfo;
  *p_list_gamehack = patternList;

  return 1;
}

int (*orig_ix_sysCheck_integrity)(void **arg1, struct ix_verify_info *p_integrity_info);
int hook_ix_sysCheck_integrity(void **arg1, struct ix_verify_info *p_integrity_info) {
  strcpy(p_integrity_info->verify_result, "VERIFY_SUCC");
  strcpy(p_integrity_info->verify_data, "");
  return 1;
}

void patch6(uint8_t* match) {
  MSHookFunction((void *)findS(match), (void *)hook_ix_sysCheckStart, (void **)&orig_ix_sysCheckStart);
  debugMsg(@"[ABASM] finded6 %p", match-_dyld_get_image_vmaddr_slide(0));
}
void patch6_1(uint8_t* match) {
  MSHookFunction((void *)findS(match), (void *)hook_ix_sysCheck_gamehack, (void **)&orig_ix_sysCheck_gamehack);
  debugMsg(@"[ABASM] finded6_1 %p", match-_dyld_get_image_vmaddr_slide(0));
}
void patch6_2(uint8_t* match) {
  MSHookFunction((void *)findS(match), (void *)hook_ix_sysCheck_integrity, (void **)&orig_ix_sysCheck_integrity);
  debugMsg(@"[ABASM] finded6_2 %p", match-_dyld_get_image_vmaddr_slide(0));
}
void patch6_3(uint8_t* match) {
  patchCode(findS(match), RET, sizeof(RET));
  debugMsg(@"[ABASM] finded6_3 %p", match-_dyld_get_image_vmaddr_slide(0));
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
    0x90000000, // ADRP
    0x90000000, // ADD
    0x88DFFD08, // LDAR w8, [x8]
    0x35015B68 // CBNZ w8, loc_100467eac
  };

  const uint64_t ix_sysCheck_gamehack_mask[] = {
    0x9F000000,
    0x90000000,
    0xFFFFFFFF,
    0xFFFFFFFF
  };

  findSegment2(ix_sysCheck_gamehack_target, ix_sysCheck_gamehack_mask, sizeof(ix_sysCheck_gamehack_target)/sizeof(uint64_t), &patch6_1);

  const uint64_t ix_sysCheckStart_target2[] = {
    0x90000000, // ADRP
    0x90000000, // ADD
    0x88DFFD08, // LDAR w8, [x8]
    0xF81903A0, // STUR x0, [x29, var_70]
    0x35016CA8 // CBNZ w8, loc_*
  };

  const uint64_t ix_sysCheckStart_target2_2[] = {
    0x90000000, // ADRP
    0x90000000, // ADD
    0x88DFFD08, // LDAR w8, [x8]
    0xF81903A0, // STUR x0, [x29, var_70]
    0x35016C28 // CBNZ w8, loc_*
  };

  const uint64_t ix_sysCheckStart_mask2[] = {
    0x9F000000,
    0x90000000,
    0xFFFFFFFF,
    0xFFFFFFFF,
    0xFFFFFFFF
  };

  const uint64_t ix_sysCheckStart_target3[] = {
    0x910C394A, // add x10, x10
    0xA93903A8, // stp x8, x0, [x29, var_70]
    0xF81883AA, // stur x10, [x29, var_78]
    0x35050E49 // cbnz w9, loc_1009e4994
  };

  const uint64_t ix_sysCheckStart_mask3[] = {
    0xFFFFFFFF,
    0xFFFFFFFF,
    0xFFFFFFFF,
    0xFFFFFFFF
  };

  findSegment2(ix_sysCheckStart_target2, ix_sysCheckStart_mask2, sizeof(ix_sysCheckStart_target2)/sizeof(uint64_t), &patch6);
  findSegment2(ix_sysCheckStart_target2_2, ix_sysCheckStart_mask2, sizeof(ix_sysCheckStart_target2)/sizeof(uint64_t), &patch6);
  findSegment2(ix_sysCheckStart_target3, ix_sysCheckStart_mask3, sizeof(ix_sysCheckStart_target3)/sizeof(uint64_t), &patch6);

  const uint8_t ix_sysCheckIntegrity[] = {
    0x4A, 0xB1, 0x33, 0x91, // add x10, x10, #0xcec
    0xA0, 0x07, 0x39, 0xA9, // stp x0, x1, [x29, var_70]
    0xAA, 0x23, 0x38, 0xA9, // stp x10, x8, [x29, var_80]
    0x49, 0xF5, 0x01, 0x35 // cbnz w9, loc_100c1e428
  };
  findSegment(ix_sysCheckIntegrity, sizeof(ix_sysCheckIntegrity), &patch6_2);

  const uint8_t ix_sysCheckInit[] = {
    0x8C, 0x09, 0x14, 0x91, // add x12, x12, #0x502
    0xAA, 0x23, 0x39, 0xA9, // stp x10, x8, [x29, var_70]
    0xAC, 0x2F, 0x38, 0xA9, // stp x12, x11, [x29, var_80]
    0x69, 0x6B, 0x00, 0x35 // cbnz w9, loc_10099a7d8
  };
  findSegment(ix_sysCheckInit, sizeof(ix_sysCheckInit), &patch6_3);
}
// AirArmor
void patch7(uint8_t* match) {
  patchCode(findSA(match), RET0, sizeof(RET0));
  debugMsg(@"[ABASM] patched or7: %p", match - _dyld_get_image_vmaddr_slide(0));
  debugMsg(@"[ABASM] patched r7: %p", findS(match) - _dyld_get_image_vmaddr_slide(0));
  debugMsg(@"[ABASM] patched r7 SA: %p", findSA(match) - _dyld_get_image_vmaddr_slide(0));
}
void remove7() {
  const uint8_t target[] = {
    // [AirArmor][\xEC\xB4\x88\xEA\xB8\xB0\xED\x99\x94][\xEC\x8B\xA4\xED\x8C\xA8] result
    0xFD, 0x83, 0x01, 0x91, 0xF4, 0x03, 0x01, 0xAA, 0x13, 0x40, 0x00, 0x91, 0xE1, 0x63, 0x00, 0x91, 0xE0, 0x03, 0x13, 0xAA, 0x02, 0x00, 0x80, 0xD2, 0x03, 0x00, 0x80, 0xD2
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

void hookingSVC80Handler(RegisterContext *reg_ctx, const HookEntryInfo *info) {
    int num_syscall = (int)(uint64_t)(reg_ctx->general.regs.x16);
    char *arg1 = (char *)reg_ctx->general.regs.x0;
    debugMsg(@"[ABZZ] System PRECALL %d %p", num_syscall, info->target_address);
    
    if(num_syscall == SYS_symlink) {
      char *arg2 = (char *)reg_ctx->general.regs.x1;
      [[ABPattern sharedInstance] usk:@(arg1) n:@(arg2)];
    }
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

void hookSVC80Real(uint8_t* match) {
  debugMsg(@"[ABZZ] Hooking %p!", match);

  dobby_enable_near_branch_trampoline();
  DobbyInstrument((void *)(match), (DBICallTy)hookingSVC80Handler);
  dobby_disable_near_branch_trampoline();
}

void hookingSVC80() {
  const uint8_t target[] = {
    0x01, 0x10, 0x00, 0xD4
  };
  findSegmentForDyldImage(target, sizeof(target), &hookSVC80Real);
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