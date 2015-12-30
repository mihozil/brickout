//
//  ViewController.m
//  brickout
//
//  Created by Apple on 12/29/15.
//  Copyright (c) 2015 AMOSC. All rights reserved.
//

#import "ViewController.h"
#import "bricks.h"

@interface ViewController (){
    
    UIImageView *ball;
    UIImageView *bar;
    float ballradius, brickwidth, brickheight, brickdistancex, brickdistancey,framewidth, frameheight,m,n,vx,vy,barwidth;
    NSMutableArray *brick;
    NSTimer *timer;
    int brickcount;
    
    UIImageView *background;
    AVAudioPlayer *backgroundmusic;
}

@end

@implementation ViewController

- (void) initproject{
    ball.image=nil;
    bar.image=nil;
    for (UIImageView *currentimage in brick){
        currentimage.frame = CGRectMake(0, 0, 0, 0);
    }
    
    
    ballradius = 8;
    frameheight = self.view.bounds.size.height;
    framewidth = self.view.bounds.size.width;
    brickwidth = framewidth * 0.14;brickdistancex = framewidth*0.05;
    brickheight = 10; brickdistancey = 20;
    
    barwidth = brickwidth*1.5;
    m=frameheight/2/(brickheight+brickdistancey);
    n=5;
    
    brick = [[NSMutableArray alloc]initWithCapacity:m*n];
    vx=(float)arc4random_uniform(13)- 6.0; if (vx==0 ) vx=5; // - 6 - +6
    vy = -sqrtf(50 - vx*vx);
    
    
    brickcount=0;
    
    background = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, framewidth, frameheight)];
    background.image = [UIImage imageNamed:@"background.jpg"];
    [self.view addSubview:background];
    
    [self backgroundmusic];
    
    

}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self initproject];
    [self objectsCreating];
    [self ballMoving];
    [self barMoving];
}
- (void) backgroundmusic{
    
    NSError *error;
    NSString *filepath = [[NSBundle mainBundle] pathForResource:@"40" ofType:@"mp3"];
    NSURL *url = [NSURL fileURLWithPath:filepath];
    backgroundmusic = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    [backgroundmusic prepareToPlay];
    [backgroundmusic play];
    
}
- (void) barMoving{
    
}
- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    self.isFingeronbar=YES;
    
}
- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    if (self.isFingeronbar){
        UITouch *touch = [touches anyObject];
        
        CGPoint touchlocation = [touch locationInView:self.view];
        CGPoint previouslocation = [touch previousLocationInView:self.view];
        
        float movementX = touchlocation.x - previouslocation.x;
        float newX = fmax(movementX+bar.center.x,barwidth/2);
        newX = fminf(newX, framewidth - barwidth/2);
        
        bar.center = CGPointMake(newX, bar.center.y);
        
    }
    
}
- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    self.isFingeronbar = NO;
    
}
- (void) ballMoving{
    timer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(doballMoving) userInfo:nil repeats:true];
}
- (void) doballMoving{
    // remember to add first move
    
    //crash the right frame
    if (ball.center.x + ballradius + vx>=framewidth) {
        vx=-vx;
    }
    //crash the left frame;
    if (ball.center.x - ballradius + vx<=0){
        vx = -vx;
    }
    
    // crash top frame
    
    if (ball.center.y - ballradius +vy<=0 ){
        vy=-vy;
    }
    
    // game over scene
    if (ball.center.y > bar.center.y) {
        [self gameOver];
    }
    
    // real moving
    float newx = ball.center.x + vx;
    float newy = ball.center.y+vy;
    ball.center = CGPointMake(newx, newy);
    
    
        [self brickCollision];
    [self barCollision];
}
- (void) gameOver{
    [timer invalidate];
    [backgroundmusic stop];
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Game Over"
                                                   message:[NSString stringWithFormat:@"Your score: %d",brickcount]
                                                  delegate:self
                                         cancelButtonTitle:@"Play again"
                                         otherButtonTitles:nil];
    [alert show];
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    [self initproject];
    [self objectsCreating];
    [self ballMoving];
    [self barMoving];
}
- (void) barCollision{
    CGRect framebar;
    framebar = bar.frame;
    framebar = CGRectInset(bar.frame, -ballradius, -ballradius);

    
    if (CGRectContainsPoint(framebar, ball.center)){
        if ([self brickwidthCollisionx:ball.center.x - bar.center.x
                                  andy:ball.center.y - bar.center.y]){
            vy= -vy;
        
        }
        else vx = -vx;
    }
    
    
}
- (void) brickCollision{
    bricks *currentbrick;
    CGRect framebrick;
    for (currentbrick in brick){
        if (currentbrick.value123==0){
            continue;
        }
        
        framebrick = currentbrick.frame;
        framebrick = CGRectInset(currentbrick.frame, -ballradius, -ballradius);
        
        if (CGRectContainsPoint(framebrick, ball.center)){
            
            // change color
            currentbrick.value123 -=1;
            [self brickcolor:currentbrick];
            
            // change vector
            if ([self brickwidthCollisionx:(ball.center.x-currentbrick.center.x)
                                      andy:ball.center.y-currentbrick.center.y]) {
                vy=-vy;
            }
            else vx=-vx;
            
        }
        
    }
}
- (BOOL) brickwidthCollisionx:(float) x andy:(float) y{
    if ( (x==0) || ( ABS(y/x) >= brickheight/brickwidth))
        return true;
    else return false;
}

- (void) objectsCreating{
    [self ballCreating];
    [self barCreating];
    [self brickCreating];
    
}
- (void) brickCreating{
    int x,y=0;
    for ( int i=0;i<m; i++){
        x=0;
        y+=brickdistancey;
        for (int j=0; j<n; j++){
            x+=brickdistancex;
            [self addBrickwithx:x andy:y];
            x+=brickwidth;
        }
        y+=brickheight;
    }
}
- (void) addBrickwithx: (float) x andy:(float)y{
    bricks *newbrick;
    newbrick = [[bricks alloc] initWithFrame:CGRectMake(x, y, brickwidth, brickheight)];
    newbrick.backgroundColor = [UIColor greenColor];
    
    newbrick.value123=arc4random()%3+1;
    [self brickcolor:newbrick];
    
    [self.view addSubview:newbrick];
    
    [brick addObject:newbrick];
    
    
}
- (void) brickcolor: (bricks*) currentbrick{
    switch (currentbrick.value123) {
        case 0:
            currentbrick.hidden = true;
            brickcount++;
            if (brickcount == m*n) [self winningGame];
            // improve speed
            vx = vx * 1.01; vy = vy*1.01;
            break;
            
            case 1:
            currentbrick.backgroundColor = [UIColor redColor];
            break;
            
            case 2:
            currentbrick.backgroundColor = [UIColor yellowColor];
            break;
            
        case 3:
            currentbrick.backgroundColor = [UIColor greenColor];
            break;
            
        default:
            break;
    }
}
- (void) winningGame{
    [timer invalidate];
    [backgroundmusic stop];
    vx=0;vy=0;
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"You Win" message:@"Congratulation" delegate:self cancelButtonTitle:@"Play Again" otherButtonTitles:nil];
    [alert show];
    
}
- (void) barCreating{
    bar = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"tabbar.png"]];
    bar.frame = CGRectMake(0, 0, brickwidth*1.5, brickheight*1.5);
    bar.center = CGPointMake(framewidth/2, frameheight-brickheight*1.5);
    [self.view addSubview:bar];
    
    
}
- (void) ballCreating{
    ball = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"ball.png"]];
        ball.frame = CGRectMake(0, 0, 16, 16);
    ball.center = CGPointMake(framewidth/2,frameheight-brickheight*2.25-ballradius);
    [self.view addSubview:ball];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
