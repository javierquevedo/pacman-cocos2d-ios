//
//  CCTMXLayer+TileAdditions.m
//  PacMan
//
//  Created by Javier Quevedo on 7/27/13.
//  Copyright (c) 2013 Javier Quevedo. All rights reserved.
//

#import "CCTMXLayer+TileAdditions.h"

@implementation CCTMXLayer (TileAdditions)

-(int) numberOfTilesInLayer{
    int amount = 0;
    for (int i = 0; i < self.layerSize.width; i++){
        for (int j = 0; j < self.layerSize.height; j++){
            if ([self tileGIDAt:CGPointMake(i,j)])
                amount++;
        }
    }
    return amount;
}

@end
