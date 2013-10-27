//
//  SharedData.m
//  JewelQuest
//
//  Created by Chris on 24/07/2013.
//
//

#import "SharedData.h"

static SharedData * instance = nil;
@implementation SharedData
@synthesize scaleFactorX,scaleFactorY,imgScaleFactorX,imgScaleFactorY;
+(id)getSharedInstance
{
    if(instance == nil)
    {
        instance = [[SharedData alloc] init];
//        [instance populate];
    }
    return instance;
}
-(id)init
{
//    levelInfo = [[NSMutableArray alloc ] init];
//    NSBundle* mainBundle = [NSBundle mainBundle];
//    NSArray * optionsDict = [NSDictionary dictionaryWithContentsOfFile:[[mainBundle bundlePath] stringByAppendingPathComponent:@"LevelInfo.plist"]];
//    
//    NSLog(@"%@",optionsDict);
   
    return self;
}
-(float)getFirePosition
{
   
}
@end
