#import "AnimationHelper.h"

@implementation AnimationHelper

+ (CCAnimate *) burstAnimationWithColor:(BurstColor) color {
    NSMutableArray *frames = [NSMutableArray array];
    static const int burstAnimationFrameCount = 12;
    NSString *prefix = [NSString stringWithFormat:@"burst%d", color];
    for (int i = 0; i < burstAnimationFrameCount; i++) {
        NSString *s = [NSString stringWithFormat:(i < 10 ? @"%@_0000%u.png" : @"%@_000%u.png"), prefix, i];
        [frames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:s]];
    }
    static const CGFloat burstAnimationFrameRate = 1.0 / 30.0;
    return [CCAnimate actionWithAnimation:[CCAnimation animationWithSpriteFrames:frames delay:burstAnimationFrameRate]];
}

+ (void) setup {
    // burst animations
    for (int i = 1; i <= 6; i++) {
        NSString *filename = [NSString stringWithFormat:@"burst%d.plist", i];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:filename];
    }
}

@end
