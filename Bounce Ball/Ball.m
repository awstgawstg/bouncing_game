//
//  Ball.m
//  Bounce Ball
//
//  Created by Xinyan Zhou on 4/18/15.
//  Copyright (c) 2015 awstgawstg. All rights reserved.
//
#import "Ball.h"
#import <Foundation/Foundation.h>

@implementation Ball;

@property SKSpriteNode * ball;

- (void)makeBall:(int) mode {
    // Create ball
    SKSpriteNode * ball = [SKSpriteNode spriteNodeWithImageNamed:@"1"];
    ball.size = CGSizeMake(self.frame.size.height/20, self.frame.size.height/20);
    ball.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:ball.size.width * 0.5];
    ball.physicsBody.dynamic = YES;
    //ball.physicsBody.collisionBitMask = 1;
    ball.physicsBody.categoryBitMask = ballCategory;
    ball.physicsBody.contactTestBitMask = ballCategory | bottomCategory | fingerCategory | edgeCategory;
    ball.physicsBody.mass = 0.8;
    ball.physicsBody.restitution = 0.5;
}

@end