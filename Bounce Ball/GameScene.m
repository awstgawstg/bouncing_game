#import "GameScene.h"
#import "GameOverScene.h"


@interface GameScene ()<SKPhysicsContactDelegate>
//initial ball
@property (nonatomic) SKSpriteNode * ball;

//add time control to calculate the time inorder to add more balls
@property (nonatomic) NSTimeInterval lastSpawnTimeInterval;
@property (nonatomic) NSTimeInterval lastUpdateTimeInterval;

//store the swipe value with direction and speed
@property (nonatomic)CGFloat mdx;
@property (nonatomic)CGFloat mdy;
@property (nonatomic)CGFloat mspeed;


@end


@implementation GameScene
//the time label
SKLabelNode *myTimeLabel;



//this is the category for the hit objects, each objects will belong to a category
static const uint32_t ballCategory = 0x1 << 1;
static const uint32_t bottomCategory = 0x1 << 2;
static const uint32_t fingerCategory = 0x1 << 3;
static const uint32_t edgeCategory = 0x1 << 4;

//check whether the game is a new game or not
int flag = 0;
int startgame=1;
int backtogame=0;

CGPoint start;

//get the start time for each swipe and the beginTime for each game, and the gameover time
NSTimeInterval startTime;
NSTimeInterval beginTime;
NSTimeInterval gameoverTime;
NSTimeInterval backgroundTime;
NSTimeInterval nowTime;




//define the value for swipe
#define kMinDistance    10
#define kMinDuration    0.0001
#define kMinSpeed       100
#define kMaxSpeed       100000


applicationWillResignActive = NO;
applicationDidEnterBackground = YES;
applicationWillEnterForeground = YES;
applicationDidBecomeActive = YES;


-(id)initWithSize:(CGSize)size {
    
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(applicationDidEnterBackground)
     name:UIApplicationDidEnterBackgroundNotification
     object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(yourUpdateMethodGoesHere:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    
    
    if (self = [super initWithSize:size]) {
        flag=0;
        startgame=1;
        // show the window range
        NSLog(@"Size: %@", NSStringFromCGSize(size));
        
        //make the gravity is 2
        self.physicsWorld.gravity = CGVectorMake(0,-2);
        self.physicsWorld.contactDelegate = self;
        
        
        // initialize the color and the bounce range
        self.backgroundColor = [SKColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
        
        // add edges
        [self addEdge];
        
        //put the five bottoms
        [self addBottom:1];
        [self addBottom:3];
        [self addBottom:5];
        [self addBottom:7];
        [self addBottom:9];
 
      
        // show the time lable
        myTimeLabel = [SKLabelNode labelNodeWithFontNamed:@"HelveticaNeue"];
        myTimeLabel.text = @"00:00:00";
        myTimeLabel.fontSize = 30;
        myTimeLabel.position = CGPointMake(self.frame.size.width*10/12,
                                           self.frame.size.height*16/17);
        myTimeLabel.fontColor = [SKColor colorWithRed:0 green:0 blue:0 alpha:1.0];
        myTimeLabel.name = @"myTimeLabel";
        
        [self addChild:myTimeLabel];
    }
    return self;
}



// addedge fuction for add the walls and ceiling
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



//addfinger with the start point and end point of the swipe and also put 10 fingers in the swipe to make sure will catch the ball
- (void)addfinger:(CGPoint) location start:(CGPoint)start {
    
    //for loop to travel the swipe
    for (int i = 0; i <= 10; i++){
        SKSpriteNode * finger = [SKSpriteNode spriteNodeWithImageNamed:@"download"];
        finger.physicsBody.dynamic = YES;
        finger.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:finger.size.width];
        finger.physicsBody.categoryBitMask = fingerCategory;
        finger.physicsBody.contactTestBitMask = ballCategory;
        finger.physicsBody.restitution = 0.5;
        finger.position = CGPointMake(i*location.x/10+(10-i)*start.x/10,i*location.y/10+(10-i)*start.y/10);
        [self addChild:finger];
        [finger runAction:
         [SKAction sequence:@[
                              [SKAction waitForDuration:0.01],
                              [SKAction removeFromParent]
                              ]]
         ];


    }
    
    
    
}



//add the bottom at the bottom
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




//add ball at the same height but different place
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



// to check whether two things are hit each other, if they are the category we want then do the action
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
    //NSLog([NSString stringWithFormat:@"%f", self.frame.size.height]);
    //NSLog(@"first");
    //NSLog( [NSString stringWithFormat:@"%d", firstBody.categoryBitMask]);
    //NSLog(@"second");
    //NSLog( [NSString stringWithFormat:@"%d", secondBody.categoryBitMask]);
    
    
    
    //if the two objects are ball and bottom then gameover
    if ((firstBody.categoryBitMask & ballCategory) != 0 &&
        (secondBody.categoryBitMask & bottomCategory) != 0)
    {
        NSLog(@"End Edge");
        NSLog(secondBody.description);
        
         SKTransition *reveal = [SKTransition flipVerticalWithDuration:0.5];
         SKScene * gameOverScene = [[GameOverScene alloc] initWithSize:self.size time:gameoverTime];
         [self.view presentScene:gameOverScene transition: reveal];
          
        
    }
    
    
    //if the two objects are ball and finger then the ball should move
    if ((firstBody.categoryBitMask & ballCategory) != 0 &&
        (secondBody.categoryBitMask & fingerCategory) != 0)
    {
        NSLog(@"End Finger");
        firstBody.velocity = self.physicsBody.velocity;
        [firstBody applyImpulse:CGVectorMake(self.mdx*self.speed*3, self.mdy*self.speed*3)];
        [secondBody.node removeFromParent];
    }
}


//update time

- (void)updateWithTimeSinceLastUpdate:(CFTimeInterval)timeSinceLast {
    CGPoint location = CGPointMake(-1, -1);
    
    if(flag==0){
        [self addBall:location];
        flag=1;
    }
    
    self.lastSpawnTimeInterval += timeSinceLast;
    if (self.lastSpawnTimeInterval > 5) {
        self.lastSpawnTimeInterval = 0;
        [self addBall:location];
    }
    
}



//update current time, and also the game over time
- (void)update:(NSTimeInterval)currentTime {
    // Handle time delta.
    // If we drop below 60fps, we still want everything to move the same distance.
    if(backtogame==1){
        backtogame=0;
        beginTime=currentTime-backgroundTime+beginTime;
        
    }
    nowTime=currentTime;
    CFTimeInterval timeSinceLast = currentTime - self.lastUpdateTimeInterval;
    self.lastUpdateTimeInterval = currentTime;
    if (timeSinceLast > 1) { // more than a second since last update
        timeSinceLast = 1.0 / 1000.0;
        self.lastUpdateTimeInterval = currentTime;
    }
    
    [self updateWithTimeSinceLastUpdate:timeSinceLast];
    if(startgame==1){
    beginTime=currentTime;
        startgame=0;
    }
    CFGregorianDate elapsedTime  = CFAbsoluteTimeGetGregorianDate((currentTime - beginTime), nil);
    NSString *formattedDateString = [NSString stringWithFormat:@"%02d:%02d:%02.1f", elapsedTime.hour, elapsedTime.minute, elapsedTime.second];
    myTimeLabel.text = formattedDateString;
    gameoverTime=currentTime - beginTime;
    
    
}



// get touch action and get the swipe data
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
                [self addfinger:location start:start];
                
            }
        }
    }
}






// get the touch began

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


- (void) applicationDidEnterBackground{
    NSLog(@"Enter to background");
    NSLog([NSString stringWithFormat:@"%f", nowTime]);
    backgroundTime=nowTime;
    
    //self.scene.view.paused  =YES;
}


- (void) yourUpdateMethodGoesHere:(NSNotification *) note {
    NSLog(@"back to the game");
    backtogame=1;

    
}




@end