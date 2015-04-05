//
//  GameScene.m
//  NinjaJog
//
//  Created by Mohamed Odeh on 3/27/15.
//  Copyright (c) 2015 Mohamed Odeh. All rights reserved.
//

#import "GameScene.h"
#import "Champ.h"
#import "WorldGenerator.h"
#import "CloudGenerator.h"
#import "Score.h"
#import "GameData.h"
#define GAME_FONT "AmericanTypewriter-Bold"

@interface GameScene ()

@property Champ *champ;
@property SKNode *world;
@property WorldGenerator *generator;
@property CloudGenerator *cloudGenerator;
@property BOOL isStarted;
@property BOOL isGameOver;

@end

@implementation GameScene

- (void)didMoveToView:(SKView *)view {

    //Set anchor point to the center of the View
    self.anchorPoint = CGPointMake(0.5,0.5);
    self.physicsWorld.contactDelegate = self;
    [self setBackground];
    [self initialContent];
}

- (void)setBackground {
    
    SKSpriteNode *moon = [SKSpriteNode spriteNodeWithImageNamed:@"moon.png"];
    moon.scale = .9;
    moon.position = CGPointMake(0, 50);
    moon.zPosition = -1;
    [self addChild:moon];
}

//Load world and champ
- (void)initialContent {
    //Create world node
    self.world = [SKNode node];
    [self addChild:self.world];
    
    //Create a world generator using our world node
    self.generator = [WorldGenerator generateWithWorld:self.world];
    [self addChild:self.generator];
    
    //Generates initial floors and hurdles
    [self.generator generateCaller];
    
    //Creates instance of our Champ
    self.champ = [Champ champ];
    [self.world addChild:self.champ];
    [self.champ breathe];
    [self labels];
}

//Display all labels
- (void)labels {
    
    GameData *data = [GameData data];
    [data load];
    
    Score *pointsLabel = [Score pointsLabelWithFontNamed:@GAME_FONT];
    pointsLabel.name = @"pointsLabel";
    pointsLabel.position = CGPointMake(-150, 200);
    [self addChild:pointsLabel];
    
    SKLabelNode *tapToBeginLabel = [SKLabelNode labelNodeWithFontNamed:@GAME_FONT];
    tapToBeginLabel.name = @"tapToBeginLabel";
    tapToBeginLabel.text = @"Tap to begin";
    tapToBeginLabel.fontSize = 20.0;
    [self addChild:tapToBeginLabel];
    [self pulseAction: tapToBeginLabel];
    
    Score *highScoreLabel = [Score pointsLabelWithFontNamed:@GAME_FONT];
    highScoreLabel.name = @"highScoreLabel";
    highScoreLabel.position = CGPointMake(150, 200);
    [highScoreLabel setHighScore:data.highScore];
    [self addChild:highScoreLabel];
    
    SKLabelNode *bestScoreLabel = [SKLabelNode labelNodeWithFontNamed:@GAME_FONT];
    bestScoreLabel.text = @"Best";
    bestScoreLabel.fontSize = 16.0;
    bestScoreLabel.position = CGPointMake(110, 200);
    [self addChild:bestScoreLabel];
}

- (void)highScoreUpdate {
    
    Score *pointsLabel = (Score *)[self childNodeWithName:@"pointsLabel"];
    Score *highScoreLabel = (Score *)[self childNodeWithName:@"highScoreLabel"];
    
    if (pointsLabel.number > highScoreLabel.number) {
        [highScoreLabel setHighScore:pointsLabel.number];
        
        GameData *data = [GameData data];
        data.highScore = pointsLabel.number;
        [data save];
    }
}

//Begin moving our champ
- (void)start {
    
    self.isStarted = YES;
    [[self childNodeWithName:@"tapToBeginLabel"] removeFromParent];
    [self.champ start];
}

//Resets scene for new game
- (void)clear {
    
    [[self childNodeWithName:@"tapToResetLabel"] removeFromParent];
    GameScene *scene = [[GameScene alloc] initWithSize:self.frame.size];
    scene.scaleMode = SKSceneScaleModeAspectFill;
    [self.view presentScene:scene];
    
}

//Stops champ movement and ends prompts user to tap to reset
- (void)gameOver {
    
    self.isGameOver = YES;
    [self.champ stop];
    
    SKLabelNode *gameOverLabel = [SKLabelNode labelNodeWithFontNamed:@GAME_FONT];
    gameOverLabel.text = @"Game Over";
    gameOverLabel.position = CGPointMake(0, 150);
    [self addChild:gameOverLabel];
    
    SKLabelNode *tapToResetLabel = [SKLabelNode labelNodeWithFontNamed:@GAME_FONT];
    tapToResetLabel.name = @"tapToResetLabel";
    tapToResetLabel.text = @"Tap to reset";
    tapToResetLabel.fontSize = 20.0;
    [self addChild:tapToResetLabel];
    [self pulseAction: tapToResetLabel];
    
    [self highScoreUpdate];
}

//Every time our champ moves right the camera stays centered on the champ
- (void)centerOnChampNode:(SKNode *)node {
    //Sets our Champ's position to be on the scene coordinate system oppose to the world coordinate system
    CGPoint positionOfChamp = [self convertPoint:node.position fromNode:node.parent];
    
    //Moves world node in accordance with champs movement
    self.world.position = CGPointMake(self.world.position.x - positionOfChamp.x, self.world.position.y);
}

//Add a point whenever a hurdle is successfully passed
- (void)addToPoints {
    
    [self.world enumerateChildNodesWithName:@"hurdle" usingBlock:^(SKNode *node, BOOL *stop){
        if (node.position.x < self.champ.position.x) {
            Score *pointsLabel = (Score *)[self childNodeWithName:@"pointsLabel"];
            [pointsLabel addPoint];
        }
    }];
}

//Generates all subsequent floors and hurdles
- (void)addToScene {
    
    [self.world enumerateChildNodesWithName:@"hurdle" usingBlock:^(SKNode *node, BOOL *stop){
        if (node.position.x < self.champ.position.x) {
            node.name = @"hurdlePassed";
            [self.generator generate];
        }
    }];
}

//Deletes all the cloud, floor and hurdle nodes that leave our view
- (void)sceneCleanup {
    
    [self.world enumerateChildNodesWithName:@"cloud" usingBlock:^(SKNode *node, BOOL *stop){
        if (node.position.x < self.champ.position.x - self.size.width/2 - node.frame.size.width/2) {
            [node removeFromParent];
        }
    }];
    
    [self.world enumerateChildNodesWithName:@"floor" usingBlock:^(SKNode *node, BOOL *stop){
        if (node.position.x < self.champ.position.x - self.size.width/2 - node.frame.size.width/2) {
            [node removeFromParent];
        }
    }];
    
    [self.world enumerateChildNodesWithName:@"hurdlePassed" usingBlock:^(SKNode *node, BOOL *stop){
        if (node.position.x < self.champ.position.x - self.size.width/2 - node.frame.size.width/2) {
            [node removeFromParent];
        }
    }];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if(!self.isStarted){
        [self start];
        [self.champ run];
    } else if (self.isGameOver) {
        [self clear];
    } else {
        [self.champ jump];
    }
}

- (void)didSimulatePhysics {

    [self centerOnChampNode:self.champ];
    [self addToPoints];
    [self addToScene];
    [self sceneCleanup];
}

//Check for collision between blocks and champ
- (void)didBeginContact:(SKPhysicsContact *)contact {
    
    if ([contact.bodyA.node.name isEqualToString:@"floor"] || [contact.bodyB.node.name isEqualToString: @"floor"]) {
        [self.champ land];
    } else {
        [self gameOver];
    }
}

//Creates pulse action
- (void)pulseAction:(SKNode *)node {
    
    SKAction *fadeOut = [SKAction fadeAlphaTo:0.0 duration:0.45];
    SKAction *fadeIn = [SKAction fadeAlphaTo:1.0 duration:0.45];
    SKAction *pulse = [SKAction sequence:@[fadeOut, fadeIn]];
    [node runAction:[SKAction repeatActionForever:pulse]];
}

@end
