//
//  Gem.m
//  JellyMania
//
//  Created by Chris on 13-7-13.
//
//

#import "Gem.h"

@implementation Gem


-(id) init{
    
    if( (self=[super init]) ) {
        
        addedToTheRemoveList=NO;
        checked=NO;
        hasToMove=NO;
        
    }
    
    return self;
}
@end
