#import <Foundation/Foundation.h>

#if __has_attribute(swift_private)
#define AC_SWIFT_PRIVATE __attribute__((swift_private))
#else
#define AC_SWIFT_PRIVATE
#endif

/// The "bell" asset catalog image resource.
static NSString * const ACImageNameBell AC_SWIFT_PRIVATE = @"bell";

/// The "camera" asset catalog image resource.
static NSString * const ACImageNameCamera AC_SWIFT_PRIVATE = @"camera";

/// The "diary-filled" asset catalog image resource.
static NSString * const ACImageNameDiaryFilled AC_SWIFT_PRIVATE = @"diary-filled";

/// The "diary-outline" asset catalog image resource.
static NSString * const ACImageNameDiaryOutline AC_SWIFT_PRIVATE = @"diary-outline";

/// The "gluco" asset catalog image resource.
static NSString * const ACImageNameGluco AC_SWIFT_PRIVATE = @"gluco";

/// The "rewards-filled" asset catalog image resource.
static NSString * const ACImageNameRewardsFilled AC_SWIFT_PRIVATE = @"rewards-filled";

/// The "rewards-outline" asset catalog image resource.
static NSString * const ACImageNameRewardsOutline AC_SWIFT_PRIVATE = @"rewards-outline";

/// The "user" asset catalog image resource.
static NSString * const ACImageNameUser AC_SWIFT_PRIVATE = @"user";

#undef AC_SWIFT_PRIVATE
