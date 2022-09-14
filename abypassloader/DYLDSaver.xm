#include <sys/utsname.h>
#include <sys/stat.h>
#include <mach-o/dyld.h>
#include <sys/syscall.h>
#include <errno.h>
#include <dlfcn.h>
#include <mach/mach.h>
#include <mach-o/dyld_images.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <netdb.h>
#include <dirent.h>
#import <substrate.h>
#import "ABPattern.h"

uint32_t dyldCount = 0;
char **dyldNames = 0;
struct mach_header **dyldHeaders = 0;
intptr_t *dyldSlides = 0;


static uint32_t (*orig_dyld_image_count)();
static uint32_t hook_dyld_image_count() {
	return dyldCount;
}
static const char *(*orig_dyld_get_image_name)(uint32_t image_index);
static const char *hook_dyld_get_image_name(uint32_t image_index) {
	return dyldNames[image_index];
}
static struct mach_header *(*orig_dyld_get_image_header)(uint32_t image_index);
static struct mach_header *hook_dyld_get_image_header(uint32_t image_index) {
	return dyldHeaders[image_index];
}
static intptr_t (*orig_dyld_get_image_vmaddr_slide)(uint32_t image_index);
static intptr_t hook_dyld_get_image_vmaddr_slide(uint32_t image_index) {
	return dyldSlides[image_index];
}


void syncDyldArray() {
	uint32_t count = orig_dyld_image_count();
	uint32_t counter = 0;
	//NSLog(@"[FlyJB] There are %u images", count);
	dyldNames = (char **) calloc(count, sizeof(char **));
	dyldHeaders = (struct mach_header **) calloc(count, sizeof(struct mach_header **));
	dyldSlides = (intptr_t *) calloc(count, sizeof(intptr_t *));
	for (int i = 0; i < count; i++) {
		const char *charName = orig_dyld_get_image_name(i);
		if (!charName) {
			continue;
		}
		NSString *name = [NSString stringWithUTF8String: charName];
		if (!name) {
			continue;
		}
		NSString *lower = [name lowercaseString];
		if ([[ABPattern sharedInstance] ozd:lower]) {
			// HBLogError(@"[ABPattern] BYPASSED dyld = %@", name);
			// if([lower containsString:@"eversafe"]) HBLogError(@"[ABPattern] Eversafe? %@", lower);
			continue;
		}
		uint32_t idx = counter++;
		dyldNames[idx] = strdup(charName);
		dyldHeaders[idx] = (struct mach_header *) orig_dyld_get_image_header(i);
		dyldSlides[idx] = orig_dyld_get_image_vmaddr_slide(i);
	}
	dyldCount = counter;
}

void add_binary_image(const struct mach_header *header, intptr_t slide) {
    Dl_info DlInfo;
    dladdr(header, &DlInfo);
    const char* image_name = DlInfo.dli_fname;
    if([[@(image_name) lowercaseString] containsString:@"eversafe"]) {
    	// HBLogError(@"[ABPattern] Eversafe일까? %s", image_name);
    	syncDyldArray();
    }
}

// %group DYLDSaver
// %hookf(uint32_t, _dyld_image_count) {
// 	return dyldCount;
// }
// %hookf(const char *, _dyld_get_image_name, uint32_t image_index) {
// 	return dyldNames[image_index];
// }
// %hookf(struct mach_header *, _dyld_get_image_header, uint32_t image_index) {
// 	return dyldHeaders[image_index];
// }
// %hookf(intptr_t, _dyld_get_image_vmaddr_slide, uint32_t image_index) {
// 	return dyldSlides[image_index];
// }
// %end

void DYLDSaver() {
	MSHookFunction((void *)_dyld_image_count, (void *)hook_dyld_image_count, (void **)&orig_dyld_image_count);
	MSHookFunction((void *)_dyld_get_image_name, (void *)hook_dyld_get_image_name, (void **)&orig_dyld_get_image_name);
	MSHookFunction((void *)_dyld_get_image_header, (void *)hook_dyld_get_image_header, (void **)&orig_dyld_get_image_header);
	MSHookFunction((void *)_dyld_get_image_vmaddr_slide, (void *)hook_dyld_get_image_vmaddr_slide, (void **)&orig_dyld_get_image_vmaddr_slide);
	// %init(DYLDSaver);
	syncDyldArray();
	_dyld_register_func_for_add_image(&add_binary_image);
}