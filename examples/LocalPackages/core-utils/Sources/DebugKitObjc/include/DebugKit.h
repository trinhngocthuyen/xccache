#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DebugKit: NSObject
@property (class, nonatomic, readonly, strong) NSBundle *bundle;
+ (NSString *)loadToken;
@end
NS_ASSUME_NONNULL_END
