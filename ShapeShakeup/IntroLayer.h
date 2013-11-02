//
//  IntroLayer.h
//  JellyMania
//
//  Created by Chris on 13-7-13.
//  Copyright AppyPocket 2013. All rights reserved.
//


// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
#import "SharedData.h"
// HelloWorldLayer
@interface IntroLayer : CCLayerColor
{
    SharedData * sd;
    
@public
    CCSprite *mainMenuBG;
    CCSprite *tutorial;
    int savedHighScore;
}

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

@end
