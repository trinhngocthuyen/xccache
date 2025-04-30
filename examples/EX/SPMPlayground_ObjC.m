#import "SPMPlayground_ObjC.h"
@import Foundation;
@import CoreUtils_Wrapper;
@import DebugKit;
@import ResourceKit;

@implementation ObjCPlayground

void objc_playground(void) {
  check(CoreUtils_Wrapper.class);
  check(DebugKit.class);
  check(ResourceKit.class);
}

void check(id object) {
  NSLog(@"%@", object);
}

@end
