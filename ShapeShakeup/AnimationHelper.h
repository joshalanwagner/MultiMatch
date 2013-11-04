typedef enum {
    BurstColorPurple = 1,
    BurstColorBlue,
    BurstColorYellow,
    BurstColorRed,
    BurstColorGreen,
    BurstColorOrange
} BurstColor;

@interface AnimationHelper : NSObject
+ (void) setup;
+ (CCAnimate *) burstAnimationWithColor:(BurstColor) color;
@end
