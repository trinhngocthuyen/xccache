#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Swizzler: NSObject
+ (void)swizzle:(NSString* )m1 with:(NSString *)m2 forClass:(Class)cls;
@end

NS_ASSUME_NONNULL_END
