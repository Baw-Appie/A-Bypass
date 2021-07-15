#include "ABPRootListController.h"
#include "ABPAppDetailController.h"
#import <AppList/AppList.h>
#import <objc/runtime.h>
#import <MRYIPCCenter.h>

#define PREFERENCE_IDENTIFIER @"/var/mobile/Library/Preferences/com.rpgfarm.abypassprefs.plist"

@interface UIApplication (private)
- (void)openURL:(NSURL *)url options:(NSDictionary *)options completionHandler:(void (^)(BOOL success))completion;
@end

#define LocalizeString(key) [[NSBundle bundleWithPath:@"/Library/PreferenceBundles/ABypassPrefs.bundle"] localizedStringForKey:key value:key table:@"prefs"]

static NSInteger DictionaryTextComparator(id a, id b, void *context) {
	return [[(__bridge NSDictionary *)context objectForKey:a] localizedCaseInsensitiveCompare:[(__bridge NSDictionary *)context objectForKey:b]];
}

NSMutableDictionary *prefs;
PSSpecifier *livePatchSpecifier;
PSSpecifier *livePatchToggleSpecifier;

@implementation ABPRootListController

- (NSArray *)specifiers {
	if (!_specifiers) {
		[self getPreference];
		NSMutableArray *specifiers = [[NSMutableArray alloc] init];

		[specifiers addObject:({
			PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:LocalizeString(@"Credits") target:self set:nil get:nil detail:nil cell:PSGroupCell edit:nil];
			specifier;
		})];
		[specifiers addObject:({
			PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:@"@BawAppie (Developer)" target:self set:nil get:nil detail:nil cell:PSButtonCell edit:nil];
			[specifier setIdentifier:@"BawAppie"];
	    	specifier->action = @selector(openCredits:);
			specifier;
		})];
		[specifiers addObject:({
			PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:@"@winstar0070 (Support)" target:self set:nil get:nil detail:nil cell:PSButtonCell edit:nil];
			[specifier setIdentifier:@"winstar0070"];
	    	specifier->action = @selector(openCredits:);
			specifier;
		})];
		[specifiers addObject:({
			PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:@"@XsF1re (Support)" target:self set:nil get:nil detail:nil cell:PSButtonCell edit:nil];
			[specifier setIdentifier:@"xsf1re"];
	    	specifier->action = @selector(openCredits:);
			specifier;
		})];
		[specifiers addObject:({
			PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:@"LICENSE" target:self set:nil get:nil detail:nil cell:PSButtonCell edit:nil];
			[specifier setIdentifier:@"license"];
	    	specifier->action = @selector(openCredits:);
			specifier;
		})];

		[specifiers addObject:[PSSpecifier preferenceSpecifierNamed:LocalizeString(@"Support A-Bypass") target:self set:nil get:nil detail:nil cell:PSGroupCell edit:nil]];
		[specifiers addObject:({
			PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:LocalizeString(@"Donate with PayPal") target:self set:nil get:nil detail:nil cell:PSButtonCell edit:nil];
			[specifier setIdentifier:@"donate"];
	    	specifier->action = @selector(openCredits:);
			specifier;
		})];
		[specifiers addObject:({
			PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:LocalizeString(@"Donate with KakaoPay") target:self set:nil get:nil detail:nil cell:PSButtonCell edit:nil];
			[specifier setIdentifier:@"donatekakaopay"];
	    	specifier->action = @selector(openCredits:);
			specifier;
		})];
		[specifiers addObject:({
			PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:LocalizeString(@"Donate with Patreon") target:self set:nil get:nil detail:nil cell:PSButtonCell edit:nil];
			[specifier setIdentifier:@"donatepatreon"];
	    	specifier->action = @selector(openCredits:);
			specifier;
		})];



		[specifiers addObject:({
			PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:LocalizeString(@"A-Bypass Update") target:self set:nil get:nil detail:nil cell:PSGroupCell edit:nil];
			[specifier.properties setValue:LocalizeString(@"Always use the latest version for the best experience.") forKey:@"footerText"];	
			specifier;
		})];
		[specifiers addObject:({
			PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:LocalizeString(@"A-Bypass Version") target:self set:nil get:@selector(getTitleValueCellData:) detail:nil cell:PSTitleValueCell edit:nil];
			[specifier setIdentifier:@"abypassversion"];
			specifier;
		})];
		[specifiers addObject:({
			PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:LocalizeString(@"Ruleset Version") target:self set:nil get:@selector(getTitleValueCellData:) detail:nil cell:PSTitleValueCell edit:nil];
			[specifier setIdentifier:@"abpatternversion"];
			specifier;
		})];
		[specifiers addObject:({
			PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:LocalizeString(@"Live Patch Version") target:self set:nil get:@selector(getTitleValueCellData:) detail:nil cell:PSTitleValueCell edit:nil];
			[specifier setIdentifier:@"abliveversion"];
			livePatchSpecifier = specifier;
			specifier;
		})];
		[specifiers addObject:({
			PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:LocalizeString(@"Check for ruleset updates") target:self set:nil get:nil detail:nil cell:PSButtonCell edit:nil];
	    	specifier->action = @selector(checkUpdate:);
			specifier;
		})];


		[specifiers addObject:({
			PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:LocalizeString(@"A-Bypass Live Patch") target:self set:nil get:nil detail:nil cell:PSGroupCell edit:nil];
			[specifier.properties setValue:LocalizeString(@"If you stop A-Bypass Live Patch Auto Update, you will not be able to receive new updates.") forKey:@"footerText"];	
			specifier;
		})];
		if(prefs[@"stopABLivePatch"]) {
			[specifiers addObject:({
				PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:LocalizeString(@"Enable Live Patch Auto Update") target:self set:nil get:nil detail:nil cell:PSButtonCell edit:nil];
		    	livePatchToggleSpecifier = specifier;
		    	specifier->action = @selector(toggleABLivePatch:);
				specifier;
			})];
		} else {
			[specifiers addObject:({
				PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:LocalizeString(@"Stop Live Patch Auto Update") target:self set:nil get:nil detail:nil cell:PSButtonCell edit:nil];
		    	livePatchToggleSpecifier = specifier;
		    	specifier->action = @selector(toggleABLivePatch:);
				specifier;
			})];
		}


		[specifiers addObject:[PSSpecifier preferenceSpecifierNamed:LocalizeString(@"Installed Applications") target:self set:nil get:nil detail:nil cell:PSGroupCell edit:nil]];
		[specifiers addObject:[PSSpecifier preferenceSpecifierNamed:LocalizeString(@"Advanced Settings") target:self set:nil get:nil detail:[ABPAppListController class] cell:PSLinkListCell edit:nil]];

		ALApplicationList *applicationList = [ALApplicationList sharedApplicationList];
		NSDictionary *applications = [applicationList applicationsFilteredUsingPredicate:[NSPredicate predicateWithFormat:@"isSystemApplication = FALSE"]];
		NSMutableArray *displayIdentifiers = [[applications allKeys] mutableCopy];

		[displayIdentifiers sortUsingFunction:DictionaryTextComparator context:(__bridge void *)applications];

		for (NSString *displayIdentifier in displayIdentifiers) {
			PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:applications[displayIdentifier] target:self set:@selector(setSwitch:forSpecifier:) get:@selector(getSwitch:) detail:nil cell:PSSwitchCell edit:nil];
			[specifier.properties setValue:displayIdentifier forKey:@"displayIdentifier"];

			UIImage *icon = [applicationList iconOfSize:ALApplicationIconSizeSmall forDisplayIdentifier:displayIdentifier];
			if (icon) [specifier setProperty:icon forKey:@"iconImage"];

			[specifiers addObject:specifier];
		}


		_specifiers = [specifiers copy];
	}

	return _specifiers;
}

-(void)setSwitch:(NSNumber *)value forSpecifier:(PSSpecifier *)specifier {
	prefs[[specifier propertyForKey:@"displayIdentifier"]] = [NSNumber numberWithBool:[value boolValue]];
	[[prefs copy] writeToFile:PREFERENCE_IDENTIFIER atomically:FALSE];
	// HBLogDebug(@"setSwitch %@, %@, %@", value, [specifier propertyForKey:@"displayIdentifier"], prefs);
}
-(NSNumber *)getSwitch:(PSSpecifier *)specifier {
	NSString *identifier = [specifier propertyForKey:@"displayIdentifier"];
	return [prefs[identifier] isEqual:@1] ? @1 : @0;
}

-(void)viewDidLoad {
	[super viewDidLoad];
	if(!prefs) [self getPreference];
	if(prefs[@"stopABLivePatch"]) {
		self.livePatchVersion = [NSString stringWithFormat:@"[Stopped] %@", [NSString stringWithContentsOfFile:@"/var/mobile/Library/Preferences/ABLivePatch" encoding:NSUTF8StringEncoding error:nil]];
		return;
	}

	// BOOL isSubstitute = ([manager fileExistsAtPath:@"/usr/lib/libsubstitute.dylib"] && ![manager fileExistsAtPath:@"/usr/lib/substrate"] && ![manager fileExistsAtPath:@"/usr/lib/libhooker.dylib"]);
 //    BOOL isLibHooker = [manager fileExistsAtPath:@"/usr/lib/libhooker.dylib"];
 //    if(!isLibHooker && !isSubstitute) {
	// 	alert = [UIAlertController alertControllerWithTitle:LocalizeString(@"Unsupported Device") message:LocalizeString(@"Please use OdysseyRa1n instead of Checkra1n. Some features are disabled.") preferredStyle:UIAlertControllerStyleAlert];
	// 	[alert addAction:[UIAlertAction actionWithTitle:LocalizeString(@"Done") style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {}]];
	// 	[self reloadSpecifiers];
	// 	[self presentViewController:alert animated:YES completion:nil];
 //    }

	NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
	NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://i.repo.co.kr/file/A-Bypass/getVersion?version=5"]];
	[[defaultSession dataTaskWithRequest:request completionHandler:^(NSData *oResponseData, NSURLResponse *responseCode, NSError *error) {
		if(error) {
			self.livePatchVersion = @"-";
		} else {
			NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:oResponseData options:0 error:nil];
			self.livePatchVersion = dic[@"livepatch"];
		}
		NSInteger index = [self indexOfSpecifier:livePatchSpecifier];
		[self removeSpecifierAtIndex:index animated:true];
		[self insertSpecifier:({
			PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:LocalizeString(@"Live Patch Version") target:self set:nil get:@selector(getTitleValueCellDataForLivePatch:) detail:nil cell:PSTitleValueCell edit:nil];
			[specifier setIdentifier:@"abliveversion"];
			specifier;
		}) atIndex:index animated:true];
	}] resume];
}
-(id)getTitleValueCellDataForLivePatch:(PSSpecifier *)specifier {
	return self.livePatchVersion;
}
-(id)getTitleValueCellData:(PSSpecifier *)specifier {
	NSString *identifier = specifier.identifier;
	if([identifier isEqualToString:@"abypassversion"]) return VERSION;
	if([identifier isEqualToString:@"abpatternversion"]) {
	    NSData *data = [NSData dataWithContentsOfFile:@"/var/mobile/Library/Preferences/ABPattern" options:0 error:nil];
	    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
	    return dic[@"version"];
	}
	if([identifier isEqualToString:@"abliveversion"]) {
		if(self.livePatchVersion) return self.livePatchVersion;
		return @"Checking..";
	}
	return @"-";
}

-(void)getPreference {
	if(![[NSFileManager defaultManager] fileExistsAtPath:PREFERENCE_IDENTIFIER]) prefs = [[NSMutableDictionary alloc] init];
	else prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:PREFERENCE_IDENTIFIER];
}
-(void)openCredits:(PSSpecifier *)specifier {
	NSString *value = specifier.identifier;
	if([value isEqualToString:@"BawAppie"]) [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://twitter.com/BawAppie"] options:@{} completionHandler:nil];
	else if([value isEqualToString:@"donate"]) [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://paypal.me/pp121324"] options:@{} completionHandler:nil];
	else if([value isEqualToString:@"donatekakaopay"]) [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://links.rpgfarm.com/kakaopay"] options:@{} completionHandler:nil];
	else if([value isEqualToString:@"donatepatreon"]) [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://patreon.com/join/BawAppie"] options:@{} completionHandler:nil];
	else if([value isEqualToString:@"winstar0070"]) [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://twitter.com/winstar0070"] options:@{} completionHandler:nil];
	else if([value isEqualToString:@"xsf1re"]) [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://twitter.com/XsF1re"] options:@{} completionHandler:nil];
	else if([value isEqualToString:@"license"]) [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://gitlab.com/-/snippets/2001684"] options:@{} completionHandler:nil];
	// else if([value isEqualToString:@"iospeterdev"]) [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://twitter.com/iospeterdev"] options:@{} completionHandler:nil];
}

UIAlertController *alert;

-(void)toggleABLivePatch:(PSSpecifier *)specifier {
	if(prefs[@"stopABLivePatch"]) {
		alert = [UIAlertController alertControllerWithTitle:LocalizeString(@"A-Bypass Live Patch") message:LocalizeString(@"You have successfully enabled A-Bypass Live Patch Auto Update.") preferredStyle:UIAlertControllerStyleAlert];
		prefs[@"stopABLivePatch"] = nil;
	} else {
		alert = [UIAlertController alertControllerWithTitle:LocalizeString(@"A-Bypass Live Patch") message:LocalizeString(@"You have successfully disabled A-Bypass Live Patch Auto Update.") preferredStyle:UIAlertControllerStyleAlert];
		[self.livePatchVersion writeToFile:@"/var/mobile/Library/Preferences/ABLivePatch" atomically:YES encoding:NSUTF8StringEncoding error:nil];
		prefs[@"stopABLivePatch"] = @1;
	}

	[self presentViewController:alert animated:YES completion:nil];
	[alert addAction:[UIAlertAction actionWithTitle:LocalizeString(@"Done") style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {}]];

	[[prefs copy] writeToFile:PREFERENCE_IDENTIFIER atomically:FALSE];
	[self reloadSpecifiers];
	[self viewDidLoad];
}

-(void)checkUpdate:(PSSpecifier *)specifier {
	alert = [UIAlertController alertControllerWithTitle:LocalizeString(@"Check for updates") message:[NSString stringWithFormat:@"%@\n\n\n", LocalizeString(@"Connect to Baw Repository File Share Service..")] preferredStyle:UIAlertControllerStyleAlert];

	UIActivityIndicatorView* spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	[spinner startAnimating];
	spinner.frame = CGRectMake(120, 80, 32, 32);
	[alert.view addSubview:spinner];
	[self presentViewController:alert animated:YES completion:nil];

	NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
	NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://i.repo.co.kr/file/A-Bypass/getVersion?version=5"]];
	[[defaultSession dataTaskWithRequest:request completionHandler:^(NSData *oResponseData, NSURLResponse *responseCode, NSError *firstError) {
		NSString *checkError = nil;
		if(firstError != nil) checkError = LocalizeString(@"The update server is not responding. Please try again later.");
		else {
			NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:oResponseData options:0 error:nil];
			 if(![dic[@"version"] isEqualToString:VERSION]) checkError = LocalizeString(@"Latest version of A-Bypass is available. Please update A-Bypass from Cydia or Sileo");
		}
	    if(checkError) {
	    	[alert dismissViewControllerAnimated:YES completion:^() {
				alert = [UIAlertController alertControllerWithTitle:LocalizeString(@"Download updates") message:checkError preferredStyle:UIAlertControllerStyleAlert];
				[alert addAction:[UIAlertAction actionWithTitle:LocalizeString(@"Cancel") style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {}]];
				[self presentViewController:alert animated:YES completion:nil];
			}];
			return;
	    }




		NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://i.repo.co.kr/file/A-Bypass/last_roleset"]];
		[[defaultSession dataTaskWithRequest:request completionHandler:^(NSData *oResponseData, NSURLResponse *responseCode, NSError *error) {
			NSString *res = [[NSString alloc] initWithData:oResponseData encoding:NSUTF8StringEncoding];
			if([(NSHTTPURLResponse *)responseCode statusCode] != 200 || error != nil) {
				[alert dismissViewControllerAnimated:YES completion:^() {
					alert = [UIAlertController alertControllerWithTitle:LocalizeString(@"Check for updates") message:LocalizeString(@"Failed to connect to Baw Repository File Share Service. Please try again.") preferredStyle:UIAlertControllerStyleAlert];
					[alert addAction:[UIAlertAction actionWithTitle:LocalizeString(@"Cancel") style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {}]];
					[self presentViewController:alert animated:YES completion:nil];
				}];
			} else {
				NSData *data = [NSData dataWithContentsOfFile:@"/var/mobile/Library/Preferences/ABPattern" options:0 error:nil];
				NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
				if([res isEqualToString:dic[@"version"]]) {
					[alert dismissViewControllerAnimated:YES completion:^() {
						alert = [UIAlertController alertControllerWithTitle:LocalizeString(@"Download updates") message:[NSString stringWithFormat:LocalizeString(@"Already up to date. (%@)"), res] preferredStyle:UIAlertControllerStyleAlert];
						[alert addAction:[UIAlertAction actionWithTitle:LocalizeString(@"Cancel") style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {}]];
						[self presentViewController:alert animated:YES completion:nil];
					}];
					return;
				}
				
				NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://i.repo.co.kr/file/A-Bypass/roleset/%@.json", res]]];
				[[defaultSession dataTaskWithRequest:request completionHandler:^(NSData *updateData, NSURLResponse *responseCode2, NSError *error2) {

					if([(NSHTTPURLResponse *)responseCode2 statusCode] != 200 || error2 != nil) {

						[alert dismissViewControllerAnimated:YES completion:^() {
							alert = [UIAlertController alertControllerWithTitle:LocalizeString(@"Download updates") message:[NSString stringWithFormat:LocalizeString(@"Failed to download update. Please try again. (%@)"), res] preferredStyle:UIAlertControllerStyleAlert];
							[alert addAction:[UIAlertAction actionWithTitle:LocalizeString(@"Cancel") style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {}]];
							[self presentViewController:alert animated:YES completion:nil];
						}];
					
					} else {
						NSError *errorr = nil;
						[[[NSString alloc] initWithData:updateData encoding:NSUTF8StringEncoding] writeToFile:@"/var/mobile/Library/Preferences/ABPattern" atomically:YES encoding:NSUTF8StringEncoding error:&errorr];
						
						NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:updateData options:0 error:nil];
						[alert dismissViewControllerAnimated:YES completion:^() {
							alert = [UIAlertController alertControllerWithTitle:LocalizeString(@"Check for updates") message:[NSString stringWithFormat:LocalizeString(@"A-Bypass engine ruleset has been updated. (%@)"), dic[@"version"]] preferredStyle:UIAlertControllerStyleAlert];
							[alert addAction:[UIAlertAction actionWithTitle:LocalizeString(@"Done") style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {}]];
							[self reloadSpecifiers];
							[self presentViewController:alert animated:YES completion:nil];
						}];
					}
				}] resume];
			}
		}] resume];

	}] resume];

}



@end
