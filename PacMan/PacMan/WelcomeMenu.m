//
//  WelcomeMenu.m
//  PacMan
//
//  Created by Javier Quevedo on 7/17/13.
//  Copyright (c) 2013 Javier Quevedo. All rights reserved.
//

#import "WelcomeMenu.h"
#import "PacManLevelLayer.h"
#import "CCBReader.h"
#import "SimpleAudioEngine.h"
@interface WelcomeMenu(){
    ALuint _intermissionSoundId;
}
@end

@implementation WelcomeMenu

-(id) init{
    if (self = [super init])
    {
        _intermissionSoundId = [[SimpleAudioEngine sharedEngine] playEffect:@"pacman_intermission.wav"];

    }
  return self;
}


-(void) startButtonWasTapped:(id)sender{
    
//    JQGameOverLayer *menu = [[JQGameOverLayer alloc] init];
   // [[CCDirector sharedDirector] pushScene:[CCBReader sceneWithNodeGraphFromFile:@"GameOverLayer.ccbi" owner:[JQGameOverLayer scene]]];
    [[SimpleAudioEngine sharedEngine] stopEffect:_intermissionSoundId];
    [[CCDirector sharedDirector]  pushScene:[PacManLevelLayer scene]];

}


-(void) aboutButtonWasTapped:(id)sender{
    NSLog(@"About!");
    
}

@end
