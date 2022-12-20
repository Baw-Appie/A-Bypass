#import "ABPAppDetailController.h"
#include "AppList.h"

#define PREFERENCE_IDENTIFIER @"/var/mobile/Library/Preferences/com.rpgfarm.abypassprefs.plist"
#define LocalizeString(key) [[NSBundle bundleWithPath:@"/Library/PreferenceBundles/ABypassPrefs.bundle"] localizedStringForKey:key value:key table:@"prefs"]

NSMutableDictionary *prefs;

@implementation ABPAppListController
- (id)specifiers {
	if(_specifiers == nil) {
		NSMutableArray *specifiers = [[NSMutableArray alloc] init];

		[specifiers addObject:[PSSpecifier preferenceSpecifierNamed:@"ABModules" target:self set:nil get:nil detail:nil cell:PSGroupCell edit:nil]];

		[self getPreference];

		NSArray *applications = getAllInstalledApplications();
		NSArray *sortDescriptor = @[[NSSortDescriptor sortDescriptorWithKey:@"localizedName" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
		applications = [applications sortedArrayUsingDescriptors:sortDescriptor];
		applications = [applications filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"applicationType == %@", @"User"]];
		for (LSApplicationProxy *application in applications) {
			if(![prefs[application.bundleIdentifier] isEqual:@1]) continue;
			UIImage* icon = [UIImage _applicationIconImageForBundleIdentifier:application.bundleIdentifier format:0 scale:[UIScreen mainScreen].scale];
			PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:application.localizedName target:nil set:nil get:nil detail:[ABPAppDetailController class] cell:PSLinkListCell edit:nil];
			[specifier.properties setValue:application.bundleIdentifier forKey:@"displayIdentifier"];
			if (icon) [specifier setProperty:icon forKey:@"iconImage"];
			[specifiers addObject:specifier];
		}

		_specifiers = [specifiers copy];
	}

	return _specifiers;
}

-(void)viewDidLoad {
	[super viewDidLoad];
	UIAlertController *alert = [UIAlertController alertControllerWithTitle:LocalizeString(@"You are in danger zone.") message:LocalizeString(@"The advanced setting of A-Bypass is very powerful, but dangerous. If you're not sure what you're doing, don't change anything.") preferredStyle:UIAlertControllerStyleAlert];
	[alert addAction:[UIAlertAction actionWithTitle:LocalizeString(@"Done") style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {}]];
	[self presentViewController:alert animated:YES completion:nil];

}

-(void)getPreference {
	if(![[NSFileManager defaultManager] fileExistsAtPath:PREFERENCE_IDENTIFIER]) prefs = [[NSMutableDictionary alloc] init];
	else prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:PREFERENCE_IDENTIFIER];
}
@end
