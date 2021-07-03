#import <UIKit/UIKit.h>
#import "ABWindow.h"

@implementation ABViewController

- (BOOL)shouldAutorotate {
  return FALSE;
}

@end

@implementation ABWindow

+ (instancetype)sharedInstance {
  static dispatch_once_t p = 0;
  __strong static id _sharedSelf = nil;
  dispatch_once(&p, ^{
    _sharedSelf = [[self alloc] init];
  });
  return _sharedSelf;
}

- (instancetype)init {
  self = [super initWithFrame:[[UIScreen mainScreen] bounds]];
  if (self != nil){
  	[self setHidden:NO];
    [self setWindowLevel:UIWindowLevelAlert];
    [self setRootViewController:[[ABViewController alloc] init]];
  	[self setBackgroundColor:[UIColor clearColor]];
  	[self setUserInteractionEnabled:YES];
  }
  return self;
}

-(bool)_shouldCreateContextAsSecure {
    return 0x0;
}

-(UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
  return nil;
}

@end
