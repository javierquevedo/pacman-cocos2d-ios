//
//  PacManLevelLayer.h
//  PacMan
//
//  Created by Javier Quevedo on 7/9/13.
//  Copyright 2013 Javier Quevedo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "JQTouchPad.h"
#import "JQPacManGameObject.h"
#import "JQGhostGameObject.h"
#import "CCTMXLayer+TileAdditions.h"

@interface PacManLevelLayer : CCLayer <JQTouchPadDelegate, TravelObjectDelegate, TravelObjectDatasource, PacmanObjectDelegate> {
    
}

+(CCScene *) scene;


@end
