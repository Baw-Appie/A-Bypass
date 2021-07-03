#import <AppList/AppList.h>
#import "ABPAppDetailController.h"

#define PREFERENCE_IDENTIFIER @"/var/mobile/Library/Preferences/com.rpgfarm.abypassprefs.plist"

// from rpertich
static NSInteger DictionaryTextComparator(id a, id b, void *context) {
	return [[(__bridge NSDictionary *)context objectForKey:a] localizedCaseInsensitiveCompare:[(__bridge NSDictionary *)context objectForKey:b]];
}

#define LocalizeString(key) [[NSBundle bundleWithPath:@"/Library/PreferenceBundles/ABypassPrefs.bundle"] localizedStringForKey:key value:key table:@"prefs"]

NSMutableDictionary *prefs;

@implementation ABPAppListController
- (id)specifiers {
	if(_specifiers == nil) {
		// create "User Applications" group
		NSMutableArray *specifiers = [[NSMutableArray alloc] init];

		[specifiers addObject:[PSSpecifier preferenceSpecifierNamed:@"ABModules" target:self set:nil get:nil detail:nil cell:PSGroupCell edit:nil]];

		// get all applications
		ALApplicationList *applicationList = [ALApplicationList sharedApplicationList];
		NSDictionary *applications = [applicationList applicationsFilteredUsingPredicate:[NSPredicate predicateWithFormat:@"isSystemApplication = FALSE"]];
		NSMutableArray *displayIdentifiers = [[applications allKeys] mutableCopy];
		
		[self getPreference];
		NSMutableArray *realIdentifiers = [NSMutableArray array];
		for(NSString *key in [prefs allKeys]) {
			if([displayIdentifiers containsObject:key] && [prefs[key] isEqual:@1]) [realIdentifiers addObject:key];
		}

		// sort them alphabetically
		[realIdentifiers sortUsingFunction:DictionaryTextComparator context:(__bridge void *)applications];

		// add each app to the list
		for (NSString *displayIdentifier in realIdentifiers) {
			PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:applications[displayIdentifier] target:nil set:nil get:nil detail:[ABPAppDetailController class] cell:PSLinkListCell edit:nil];
			[specifier.properties setValue:displayIdentifier forKey:@"displayIdentifier"];

			UIImage *icon = [applicationList iconOfSize:ALApplicationIconSizeSmall forDisplayIdentifier:displayIdentifier];
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
