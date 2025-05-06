#import "Swizzler.h"

@implementation Swizzler
+ (void)swizzle:(NSString* )m1 with:(NSString *)m2 forClass:(Class)cls {
  NSLog(@"Swizzle %@ with %@", m1, m2);
}
@end
