#include "ABPAppDetailController.h"
#include "AppList.h"
#import <objc/runtime.h>

#define PREFERENCE_IDENTIFIER @"/var/mobile/Library/Preferences/com.rpgfarm.abypassprefs.plist"
#define LocalizeString(key) [[NSBundle bundleWithPath:@"/Library/PreferenceBundles/ABypassPrefs.bundle"] localizedStringForKey:key value:key table:@"prefs"]

NSMutableDictionary *prefs;
NSString *displayIdentifier;

@implementation ABPAppDetailController

- (NSArray *)specifiers {
	if (!_specifiers) {
		[self getPreference];
		NSMutableArray *specifiers = [[NSMutableArray alloc] init];
		displayIdentifier = self.specifier.properties[@"displayIdentifier"];

		NSArray *applications = getAllInstalledApplications();
		applications = [applications filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"bundleIdentifier == %@", displayIdentifier]];
		for (LSApplicationProxy *application in applications) {
			[specifiers addObject:({
				PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:application.localizedName target:self set:nil get:nil detail:nil cell:PSGroupCell edit:nil];
				specifier;
			})];
			[specifiers addObject:({
				PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:application.localizedName target:self set:nil get:nil detail:nil cell:PSStaticTextCell edit:nil];
				[specifier.properties setValue:application.bundleIdentifier forKey:@"displayIdentifier"];
				UIImage* icon = [UIImage _applicationIconImageForBundleIdentifier:application.bundleIdentifier format:0 scale:[UIScreen mainScreen].scale];
				if (icon) [specifier setProperty:icon forKey:@"iconImage"];
				specifier;
			})];
		}

		[specifiers addObject:({
			PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:LocalizeString(@"Disable ABASM") target:self set:@selector(setSwitch:forSpecifier:) get:@selector(getSwitch:) detail:nil cell:PSSwitchCell edit:nil];
			[specifier.properties setValue:@"ABASMBlackList" forKey:@"displayIdentifier"];
			specifier;
		})];
		[specifiers addObject:({
			PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:LocalizeString(@"Enable hookSVC80") target:self set:@selector(setSwitch:forSpecifier:) get:@selector(getSwitch:) detail:nil cell:PSSwitchCell edit:nil];
			[specifier.properties setValue:@"hookSVC80" forKey:@"displayIdentifier"];
			specifier;
		})];
		[specifiers addObject:({
			PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:LocalizeString(@"Enable noHookingPlz") target:self set:@selector(setSwitch:forSpecifier:) get:@selector(getSwitch:) detail:nil cell:PSSwitchCell edit:nil];
			[specifier.properties setValue:@"noHookingPlz" forKey:@"displayIdentifier"];
			specifier;
		})];
		[specifiers addObject:({
			PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:LocalizeString(@"Enforce DYLD Hook") target:self set:@selector(setSwitch:forSpecifier:) get:@selector(getSwitch:) detail:nil cell:PSSwitchCell edit:nil];
			[specifier.properties setValue:@"enforceDYLD" forKey:@"displayIdentifier"];
			specifier;
		})];

		_specifiers = [specifiers copy];
	}

	return _specifiers;
}

-(void)setSwitch:(NSNumber *)value forSpecifier:(PSSpecifier *)specifier {
	if(!prefs[@"advanced"]) prefs[@"advanced"] = [NSMutableDictionary dictionary];
	if(!prefs[@"advanced"][displayIdentifier]) prefs[@"advanced"][displayIdentifier] = [NSMutableDictionary dictionary];
	prefs[@"advanced"][displayIdentifier][[specifier propertyForKey:@"displayIdentifier"]] = [NSNumber numberWithBool:[value boolValue]];
	[[prefs copy] writeToFile:PREFERENCE_IDENTIFIER atomically:FALSE];
}
-(NSNumber *)getSwitch:(PSSpecifier *)specifier {
	NSString *identifier = [specifier propertyForKey:@"displayIdentifier"];
	return [prefs[@"advanced"][displayIdentifier][identifier] isEqual:@1] ? @1 : @0;
}

-(void)getPreference {
	if(![[NSFileManager defaultManager] fileExistsAtPath:PREFERENCE_IDENTIFIER]) prefs = [[NSMutableDictionary alloc] init];
	else prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:PREFERENCE_IDENTIFIER];
}



@end
