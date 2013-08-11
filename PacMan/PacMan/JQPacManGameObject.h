//
//  JQPacManGameObject.h
//  PacMan
//
//  Created by Javier Quevedo on 7/15/13.
//  Copyright (c) 2013 Javier Quevedo. All rights reserved.
//

#import "JQTravelGameObject.h"
@class JQPacManGameObject;
@protocol PacmanObjectDelegate <TravelObjectDelegate>

-(void)pacmanDidDie:(JQPacManGameObject *)pacman;

@end

@interface JQPacManGameObject : JQTravelGameObject

@property (nonatomic, assign) int lives;
@property (nonatomic, assign) int score;
@property (nonatomic, assign) float speed;
@property (nonatomic, assign) float shield;
@property (nonatomic, weak) id<PacmanObjectDelegate> delegate;

-(void)die;




@end
