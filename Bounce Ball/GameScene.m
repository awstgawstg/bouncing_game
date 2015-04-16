#import "GameScene.h"
#import "GameOverScene.h"

// 1
@interface GameScene ()<SKPhysicsContactDelegate>
@property (nonatomic) SKSpriteNode * ball;
@property (nonatomic) NSTimeInterval lastSpawnTimeInterval;
@property (nonatomic) NSTimeInterval lastflick;
@property (nonatomic) NSTimeInterval lastUpdateTimeInterval;
@property (nonatomic)CGFloat mdx;
@property (nonatomic)CGFloat mdy;
@property (nonatomic)CGFloat mspeed;
@end


@implementation GameScene
static const uint32_t ballCategory = 0x1 << 1;
static const uint32_t bottomCategory = 0x1 << 2;
static const uint32_t fingerCategory = 0x1 << 3;
static const uint32_t edgeCategory = 0x1 << 4;
int flag = 0;
CGPoint start;
NSTimeInterval startTime;
#define kMinDistance    10
#define kMinDuration    0.001
#define kMinSpeed       100
#define kMaxSpeed       10000


-(id)initWithSize:(CGSize)size {
    
    if (self = [super initWithSize:size]) {
        
        // show the window range
        NSLog(@"Size: %@", NSStringFromCGSize(size));
        
        //make the gravity is 2
        self.physicsWorld.gravity = CGVectorMake(0,-2);
        self.physicsWorld.contactDelegate = self;
        
        
        // initialize the color and the bounce range
        self.backgroundColor = [SKColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
        
        // add edges
        [self addEdge];
        
        //put the four bottoms
        [self addBottom:1];
        [self addBottom:3];
        [self addBottom:5];
        [self addBottom:7];
        [self addBottom:9];
        
    }
    return self;
}

- (void)addEdge {
    SKNode *edge = [SKNode node];
    edge.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:CGRectMake(self.frame.origin.x,
                                                                          self.frame.origin.y,
                                                                          self.frame.size.width,
                                                                          self.frame.size.height*5)];
    edge.physicsBody.categoryBitMask = edgeCategory;
    edge.physicsBody.contactTestBitMask = ballCategory;
    edge.physicsBody.restitution = 0.5;
    edge.physicsBody.dynamic = NO;
    [self addChild:edge];
}

- (void)addfinger:(CGPoint) location {
    SKSpriteNode * finger = [SKSpriteNode spriteNodeWithImageNamed:@"download"];
    finger.physicsBody.dynamic = YES;
    finger.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:finger.size.width];
    finger.physicsBody.categoryBitMask = fingerCategory;
    finger.physicsBody.contactTestBitMask = ballCategory;
    finger.physicsBody.restitution = 0.5;
    finger.position = location;
    [self addChild:finger];
    [finger runAction:
     [SKAction sequence:@[
                          [SKAction waitForDuration:0.01],
                          [SKAction removeFromParent]
                          ]]
     ];
    
}

- (void)addBottom:(int) x {
    SKSpriteNode * bottom = [SKSpriteNode spriteNodeWithImageNamed:@"1636430"];
    bottom.position =CGPointMake(x*self.frame.size.width/10,4*self.frame.size.height/280);
    bottom.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(self.frame.size.width/5,self.frame.size.height/35)];
    bottom.physicsBody.dynamic = NO;
    bottom.physicsBody.collisionBitMask = 1;
    bottom.physicsBody.categoryBitMask = bottomCategory;
    bottom.physicsBody.contactTestBitMask = ballCategory;
    bottom.physicsBody.restitution = 0.5;
    [self addChild:bottom];
}

- (void)addBall:(CGPoint) location {
    // Create ball
    SKSpriteNode * ball = [SKSpriteNode spriteNodeWithImageNamed:@"1"];
    ball.size = CGSizeMake(self.frame.size.height/20, self.frame.size.height/20);
    ball.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:ball.size.width * 0.5];
    ball.physicsBody.dynamic = YES;
    //   ball.physicsBody.collisionBitMask = 1;
    ball.physicsBody.categoryBitMask = ballCategory;
    ball.physicsBody.contactTestBitMask = ballCategory | bottomCategory | fingerCategory | edgeCategory;
    ball.physicsBody.mass = 0.8;
    ball.physicsBody.restitution = 0.5;
    
    // Create the ball slightly off-screen along the right edge,
    // and along a random position along the X axis as calculated above
    int minX = ball.size.height / 2;
    int maxX = self.frame.size.width - ball.size.width / 2;
    int rangeX = maxX - minX;
    int X=(arc4random() % rangeX)+minX;
    CGPoint defaultlocation = CGPointMake(X, 4*self.frame.size.height/5);
    if (location.x >= 0)
        defaultlocation = location;
    ball.position = defaultlocation;
    [self addChild:ball];
}

- (void)didBeginContact:(SKPhysicsContact *)contact
{
    // 1
    NSLog(@"Hit");
    SKPhysicsBody *firstBody, *secondBody;
    
    if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask)
    {
        firstBody = contact.bodyA;
        secondBody = contact.bodyB;
    }
    else
    {
        firstBody = contact.bodyB;
        secondBody = contact.bodyA;
    }
    NSLog([NSString stringWithFormat:@"%f", self.frame.size.height]);
    NSLog(@"first");
    NSLog( [NSString stringWithFormat:@"%d", firstBody.categoryBitMask]);
    NSLog(@"second");
    NSLog( [NSString stringWithFormat:@"%d", secondBody.categoryBitMask]);
    
    if ((firstBody.categoryBitMask & ballCategory) != 0 &&
        (secondBody.categoryBitMask & bottomCategory) != 0)
    {
        NSLog(@"End Edge");
        //NSLog(secondBody.description);
        /*
         SKTransition *reveal = [SKTransition flipVerticalWithDuration:0.5];
         SKScene * gameOverScene = [[GameOverScene alloc] initWithSize:self.size won:NO];
         [self.view presentScene:gameOverScene transition: reveal];
         */
    }
    
    if ((firstBody.categoryBitMask & ballCategory) != 0 &&
        (secondBody.categoryBitMask & fingerCategory) != 0)
    {
        NSLog(@"End Finger");
        firstBody.velocity = self.physicsBody.velocity;
        [firstBody applyImpulse:CGVectorMake(self.mdx*self.speed*3, self.mdy*self.speed*3)];
        [secondBody.node removeFromParent];
    }
}

- (void)updateWithTimeSinceLastUpdate:(CFTimeInterval)timeSinceLast {
    CGPoint location = CGPointMake(-1, -1);
    
    if(flag==0){
        [self addBall:location];
        flag=1;
    }
    
    self.lastSpawnTimeInterval += timeSinceLast;
    self.lastflick+= timeSinceLast;
    if (self.lastSpawnTimeInterval > 10) {
        self.lastSpawnTimeInterval = 0;
        [self addBall:location];
    }
    if(self.lastflick>1){
        self.lastflick=0;
        
    }
}


- (void)update:(NSTimeInterval)currentTime {
    // Handle time delta.
    // If we drop below 60fps, we still want everything to move the same distance.
    CFTimeInterval timeSinceLast = currentTime - self.lastUpdateTimeInterval;
    self.lastUpdateTimeInterval = currentTime;
    if (timeSinceLast > 1) { // more than a second since last update
        timeSinceLast = 1.0 / 60.0;
        self.lastUpdateTimeInterval = currentTime;
    }
    
    [self updateWithTimeSinceLastUpdate:timeSinceLast];
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    // NSLog(@"Swipe detected with speed");
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    // Determine distance from the starting point
    CGFloat dx = location.x - start.x;
    CGFloat dy = location.y - start.y;
    self.mdx=dx;
    self.mdy=dy;
    
    CGFloat magnitude = sqrt(dx*dx+dy*dy);
    if (magnitude >= kMinDistance) {
        NSLog(@"lagerthanmin");
        // Determine time difference from start of the gesture
        CGFloat dt = touch.timestamp - startTime;
        if (dt > kMinDuration) {
            NSLog(@"lagerthantimemin");
            // Determine gesture speed in points/sec
            CGFloat speed = magnitude / dt;
            self.mspeed=speed;
            if (speed >= kMinSpeed && speed <= kMaxSpeed) {
                NSLog(@"speedisgood");
                // Calculate normalized direction of the swipe
                dx = dx / magnitude;
                dy = dy / magnitude;
                NSLog(@"Swipe detected with speed = %g and direction (%g, %g)",speed, dx, dy);
                [self addfinger:location];
                
            }
        }
    }
}








-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    // NSLog(@"oh my lady gaga");
    /* Avoid multi-touch gestures (optional) */
    if ([touches count] > 1) {
        return;
    }
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    // Save start location and time
    start = location;
    startTime = touch.timestamp;
    
    
    
    
    
    
    /* Called when a touch begins */
    /*
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];
        [self addBall:location];
    }*/
    
}




@end