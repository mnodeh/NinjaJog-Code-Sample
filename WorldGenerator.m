//
//  WorldGenerator.m
//  HippityHop
//
//  Created by Mohamed Odeh on 3/27/15.
//  Copyright (c) 2015 Mohamed Odeh. All rights reserved.
//

#import "WorldGenerator.h"

@interface WorldGenerator()

@property double currentFloorX;
@property double currentHurdleX;
@property double currentCloudX;
@property SKNode *world;

@end

@implementation WorldGenerator

static const uint32_t hurdleCategory = 0x1 << 1;
static const uint32_t floorCategory = 0x1 << 2;

+ (id)generateWithWorld:(SKNode *)world {
    
    WorldGenerator *generator = [WorldGenerator node];
    generator.currentFloorX = 0;
    generator.currentHurdleX = 400;
    generator.currentCloudX = 450;
    generator.world = world;
    
    return generator;
}

//Creates initial 2 floor nodes
- (void)generateCaller {
    
    for (int i = 0; i < 2; i++) {
        [self generate];
    }
}

- (void)generate {
    //Create floor node
    SKSpriteNode *floor = [SKSpriteNode spriteNodeWithImageNamed:@"ground.png"];
    
    floor.position = CGPointMake(self.currentFloorX, -self.scene.size.height/2 + floor.size.height/2);
    floor.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:floor.size];
    floor.name = @"floor";
    floor.physicsBody.categoryBitMask = floorCategory;
    
    //Stop gravity from effecting ground
    floor.physicsBody.dynamic = NO;
    [self.world addChild:floor];
    
    //Move current floor X for the correct position of the newly placed floor
    self.currentFloorX += floor.size.width;
    
    //Set hurdle on floor
    SKSpriteNode *hurdle = [SKSpriteNode spriteNodeWithImageNamed:@"hurdle.png"];
    hurdle.position = CGPointMake(self.currentHurdleX, floor.position.y + floor.size.height/2 + hurdle.size.height/2);
    hurdle.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:hurdle.size];
    hurdle.name = @"hurdle";
    hurdle.physicsBody.categoryBitMask = hurdleCategory;
    hurdle.physicsBody.dynamic = NO;
    [self.world addChild:hurdle];
    
    //Distance between hurdles
    self.currentHurdleX += [self hurdleDistance];
    
    //Set cloud
    SKSpriteNode *cloud = [SKSpriteNode spriteNodeWithImageNamed:[self loadCloud]];
    cloud.position = CGPointMake(self.currentCloudX, [self cloudHeight]);
    cloud.name = @"cloud";
    [self.world addChild:cloud];
    
    //Distance between clouds
    self.currentCloudX += [self cloudDistance];
}

//Sets random cloud height
- (float)cloudHeight {
    
    return 3 * (arc4random_uniform(100) + 1);
}

//Loads random cloud
- (NSString *)loadCloud {
    
    int chooseCloud = arc4random_uniform(4);
    
    switch (chooseCloud) {
        case 0:
            return @"Cloud1.png";
            break;
        case 1:
            return @"Cloud2.png";
            break;
        case 2:
            return @"Cloud3.png";
            break;
        case 3:
            return @"Cloud4.png";
            break;
        case 4:
            return @"Cloud5.png";
            break;
            
        default:
            break;
    }
    
    return NULL;
}

//Distance between clouds
- (int)cloudDistance {
    
    return 10 * ((arc4random() % 20) + 24);
}

//Distance between hurdles
- (int)hurdleDistance {
    
    return 10 * ((arc4random() % 16) + 20);
}



@end
