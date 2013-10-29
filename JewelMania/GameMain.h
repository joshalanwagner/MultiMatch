//
//  HelloWorldLayer.h
//  JellyMania
//
//  Created by Chris on 13-7-13.
//  Copyright AppyPocket 2013. All rights reserved.
//


#import <GameKit/GameKit.h>
#import "ALAdView.h"
// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
#import "SharedData.h"
#import "Gem.h"
// HelloWorldLayer
@interface GameMain : CCLayerColor<GKAchievementViewControllerDelegate>
{
    @public
    CCSprite *mainMengBG;
    CCMenu *startBtn;
    CCMenu *moreAppsBtn;
    
    
    //////////// junaid //////////
    SharedData * sd;
    CCMenu  *multiPlayerBtn;
    CCMenu  *leaderBtn;
    CCMenu  *removAdBtn;
    CCMenu  *restoreBtn;
    CCMenu  *freeBtn;
    CCMenu  *moreGamesBtnGameOver;
    bool isMultiPlayer;
    ALAdView *appLovinBanner;
    ///////////////////////////////
    
    
    CCSprite *mainMenuSprite;
    
    CCSprite *inGame;
    
    CCSprite *gemsCMC;
    
    NSMutableArray *gem2DArr;
 
    Gem *memoryTouchedGem;
    
    Gem *gemMoved;
    Gem *gemToBeExchanged;
    
    float gemHei;
    float gemWid;
    
    int kindsNum;
    
    NSMutableArray *___toRemoveArr;
    
    
    ///// junaid ///////
    CCLabelTTF * scoreTextTTF;
    CCLabelTTF * scoreTextTTF2;
    ////////////////////
    CCLabelBMFont *scoreText;
    CCLabelBMFont *scoreText2;
    
    int vNum;
    
    CCMenu *backBtn,*okBtn;
    BOOL closeAble;
    
    CCSprite *gameOver;
    CCSprite *timeBar;
    CCSprite *timeBarTray;
    
    int hNum;
    int score;
    float time;
    
    BOOL moveAble;
    
    BOOL gameIsOver;
    
    float gameTime;
    
    BOOL touchTargetAdded;
    
    
    /////// junaid ////////// changing for new game play
    
    NSMutableArray * arrayOfGemsToRemove;
    NSMutableArray * arrayOfLines;
    CGPoint positionOfLastGemInLine;
}

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

@end
