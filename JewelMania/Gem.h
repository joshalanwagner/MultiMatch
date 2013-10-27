//
//  Gem.h
//  JellyMania
//
//  Created by Chris on 13-7-13.
//
//


#import "cocos2d.h"
@interface Gem : CCSprite{
    @public
    NSString *type;
    CCSprite *img;
    
    BOOL addedToTheRemoveList;
    //是否已经作为参考宝石与其他宝石检查过
    BOOL checked;
    int indexH;
    int indexV;
    
    int memoryIndexV;
    
    BOOL hasToMove;
    float gx;
    float gy;
    
    
    /// junaid
    BOOL checkedInLine;
}

@end
