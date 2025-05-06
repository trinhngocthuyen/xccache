#import <Foundation/Foundation.h>
#import <DebugKit.h>
#import <Diagnose.h>
#import <Swizzler.h>

@implementation DebugKit
+ (NSBundle *)bundle {
  return SWIFTPM_MODULE_BUNDLE;
}
+ (NSString *)loadToken {
  NSBundle *bundle = SWIFTPM_MODULE_BUNDLE;
  NSString *tokenPath = [bundle pathForResource:@"token" ofType:@"txt"];
  NSString *content = [NSString stringWithContentsOfFile:tokenPath encoding:NSUTF8StringEncoding error:nil];
  return [content stringByReplacingOccurrencesOfString:@"\n" withString:@""];
}
+ (void)diagnose {
  [Swizzler swizzle:@"foo" with:@"bar" forClass:DebugKit.class];
  [Diagnoser diagnoseDevice];
}
@end
