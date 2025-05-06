#import <Foundation/Foundation.h>
// 👇 expect xccache to convert to nested angle-bracket style `#import <Swizzler/Swizzler.h>`
#import <Swizzler.h>

NS_ASSUME_NONNULL_BEGIN

@interface DebugKit: NSObject
@property (class, nonatomic, readonly, strong) NSBundle *bundle;
+ (NSString *)loadToken;
+ (void)diagnose;
@end

NS_ASSUME_NONNULL_END
