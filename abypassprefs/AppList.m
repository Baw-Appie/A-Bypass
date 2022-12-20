#import "AppList.h"

NSArray *getAllInstalledApplications() {
	LSApplicationWorkspace *workspace = [LSApplicationWorkspace defaultWorkspace];
	if(![workspace respondsToSelector:@selector(enumerateApplicationsOfType:block:)]) return [workspace allInstalledApplications];

	NSMutableArray* installedApplications = [NSMutableArray new];
	[workspace enumerateApplicationsOfType:0 block:^(LSApplicationProxy* appProxy) {
		[installedApplications addObject:appProxy];
	}];
	[workspace enumerateApplicationsOfType:1 block:^(LSApplicationProxy* appProxy) {
		[installedApplications addObject:appProxy];
	}];
	return installedApplications;
}