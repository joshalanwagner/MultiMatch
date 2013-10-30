//
//  SharedData.h
//  JewelQuest
//
//  Created by Chris on 24/07/2013.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface SharedData : NSObject
{
    int m_nLevel;
    NSMutableArray * levelInfo;
    
    float scaleFactorX;
    float scaleFactorY;
    float scaleValue;
}
@property (nonatomic, assign) float scaleFactorX;
@property (nonatomic, assign) float scaleFactorY;
@property (nonatomic, assign) float imgScaleFactorX;
@property (nonatomic, assign) float imgScaleFactorY;

+(id)getSharedInstance;
-(id)init;
-(float)getFirePosition;
//-(void)populate;
@end
