//
//  HelloWorldLayer.h
//  JellyMania
//
//  Created by Chris on 13-7-13.
//  Copyright AppyPocket 2013. All rights reserved.
//


#import <GameKit/GameKit.h>
// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
#import "SharedData.h"
#import "Gem.h"
#import "MPInterstitialAdController.h"
// HelloWorldLayer
@interface GameMain : CCLayerColor <GKAchievementViewControllerDelegate, MPInterstitialAdControllerDelegate>
{
    @public
    CCSprite *mainMenuBG;
    CCMenu *startBtn;
    CCMenu *startOverBtn;
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
    CCLabelTTF * wellPlayedText;
    CCLabelTTF * newHighText;
    CCLabelTTF * highScoreText;
    CCLabelTTF * hsLabel;
    CCLabelBMFont * timeText;
    CCLabelBMFont * wowText;
    
    int vNum;
    
    CCMenu *backBtn,*okBtn;
    BOOL closeAble;
    
    CCSprite *gameOver;
    CCSprite *timeBar;
    CCSprite *timeBarTray;
    CCSprite *topBar;
    CCSprite *lockup;
    CCSprite *highScorePanel;
    int hNum;
    int score;
    int savedHighScore;
    int time;
    
    BOOL moveAble;
    
    BOOL gameIsOver;
    
    float gameTime;
    
    BOOL touchTargetAdded;
    
    
    /////// junaid ////////// changing for new game play
    
    NSMutableArray * arrayOfGemsToRemove;
    NSMutableArray * arrayOfLines;
    CGPoint positionOfLastGemInLine;
}

@property (nonatomic, retain) MPInterstitialAdController *interstitial;

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

@end
