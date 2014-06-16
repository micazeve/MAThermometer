//
//  MAThermometer.m
//  MAThermometer-Demo
//
//  Created by Michael Azevedo on 16/06/2014.
//

#import "MAThermometer.h"


static const CGFloat colorsBlueToRed[] =  {
    0.0, 0.0, 1.0, 1.0,
	0.0, 1.0, 1.0, 1.0,
    0.0, 1.0, 0.0, 1.0,
	1.0, 1.0, 0.0, 1.0,
	1.0, 0.0, 0.0, 1.0
};


@interface MAThermometer () {

    CGPoint pointTemp[5];
    CGFloat customGradientValues[8];
}

@property (nonatomic, assign) CGFloat span;

@end


@implementation MAThermometer

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self customInit];
    }
    return self;
}

-(id)init
{
    self = [super init];
    if (self) {
        // Initialization code
        [self customInit];
    }
    return self;
    
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        [self customInit];
    }
    return self;
}

-(void)customInit
{
    _curValue = 0;
    
    [self setMinValue:0 maxValue:100];
    customGradientValues[3] = 1;
    customGradientValues[7] = 1;
    
    self.backgroundColor = [UIColor clearColor];
    self.transform =CGAffineTransformMakeRotation(M_PI);
}

#pragma mark - Custom setters


-(void)setCurValue:(CGFloat)curValue
{
    if (curValue < _minValue)
        curValue = _minValue;
    else if (curValue > _maxValue)
        curValue = _maxValue;
    
    _curValue = curValue;
    
    [self setNeedsDisplay];
}

-(void)setMinValue:(CGFloat)minValue
{
    [self setMinValue:minValue maxValue:_maxValue];
}

-(void)setMaxValue:(CGFloat)maxValue
{
    [self setMinValue:_minValue maxValue:maxValue];
}


-(void)setMinValue:(CGFloat)minValue
          maxValue:(CGFloat)maxValue
{
    if (minValue < maxValue) {
        _minValue = minValue;
        _maxValue = maxValue;
    } else {
        _minValue = maxValue;
        _maxValue = minValue;
    }
    _span = _maxValue - _minValue;
    
    [self setCurValue:_curValue];
}

#pragma mark - Drawing methods

- (void)drawRect:(CGRect)rect
{
	//FIX: optimise and save some reusable stuff
    CGColorSpaceRef baseSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextClearRect(context, rect);
    
    
    // Calcul du point du centre
    
    CGFloat lineWidth = self.frame.size.height/100.f;
    

    CGFloat radius = (self.frame.size.height -2*lineWidth)/8;
    
    
    CGPoint circleCenter = CGPointMake(CGRectGetMidX(self.bounds), radius + lineWidth);
    
    // premier point
    
    CGPoint circleFirst = CGPointMake((circleCenter.x - cos(M_PI_4)*radius),
                                      (circleCenter.y + sin(M_PI_4)*radius));
    
    CGPoint circleMiddle = CGPointMake(circleCenter.x,
                                       circleCenter.y - radius);
    
    CGPoint circleSecond = CGPointMake((circleCenter.x + cos(M_PI_4)*radius),
                                       (circleCenter.y + sin(M_PI_4)*radius));
    
    CGFloat radiusSmall = (circleSecond.x - circleFirst.x)/2;
    
    CGPoint circleSmallCenter   = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMaxY(self.bounds) - lineWidth - radiusSmall);
    
    CGPoint circleSmallFirst    = CGPointMake(circleFirst.x, circleSmallCenter.y);
    CGPoint circleSmallMiddle   = CGPointMake(circleSmallCenter.x,circleSmallCenter.y + radiusSmall);
    
    CGPoint circleSmallSecond   = CGPointMake(circleSecond.x, circleSmallCenter.y);

    
    CGContextAddEllipseInRect(context, CGRectMake(circleCenter.x - radius, circleCenter.y - radius, radius*2, radius*2));
    
    CGContextMoveToPoint(context, circleSecond.x, circleSecond.y);
    
    CGContextAddLineToPoint(context, circleSmallSecond.x, circleSmallSecond.y);
    CGContextAddArcToPoint(context, circleSmallSecond.x, circleSmallMiddle.y,
                           circleSmallMiddle.x, circleSmallMiddle.y, radiusSmall);
    
    CGContextAddArcToPoint(context, circleSmallFirst.x, circleSmallMiddle.y,
                           circleSmallFirst.x, circleSmallFirst.y, radiusSmall);
    CGContextAddLineToPoint(context, circleFirst.x, circleFirst.y);
    
    CGContextClosePath(context);
    CGContextSaveGState(context);
    CGContextClip(context);

    
    
    // on calcule en fonction du pourcentage
    
    
    
    CGContextSetFillColorWithColor(context,[[UIColor blueColor] CGColor]);
    
    NSInteger height = circleSmallMiddle.y - circleMiddle.y;
    
    for (uint8_t i = 0; i < 5 ; ++i)
    {
        pointTemp[i] = CGPointMake(CGRectGetMidX(self.bounds), circleMiddle.y + (i*height)/4);
    }
    
    
    if (_curValue > _minValue)
    {
        if (_curValue > _minValue + 0.25f*_span)
        {
            [self drawFullGradientNum:0 withBaseSpace:baseSpace inContext:context];
            
            if (_curValue > _minValue + 0.5f*_span)
            {
               [self drawFullGradientNum:1 withBaseSpace:baseSpace inContext:context];
                
                if (_curValue > _minValue + 0.75f*_span)
                {
                    [self drawFullGradientNum:2 withBaseSpace:baseSpace inContext:context];
                    
                    if (_curValue == _maxValue)
                    {
                        [self drawFullGradientNum:3 withBaseSpace:baseSpace inContext:context];
                    }
                    else
                    {
                        [self drawIntermediateGradientNum:3 withBaseSpace:baseSpace inContext:context];
                    }
                }
                else
                {
                    [self drawIntermediateGradientNum:2 withBaseSpace:baseSpace inContext:context];
                }
            }
            else
            {
                [self drawIntermediateGradientNum:1 withBaseSpace:baseSpace inContext:context];
            }
        }
        else
        {
            [self drawIntermediateGradientNum:0 withBaseSpace:baseSpace inContext:context];
            
        }
    }

    CGContextRestoreGState(context);
  
    CGContextSetLineWidth(context, lineWidth);
    CGContextSetStrokeColorWithColor(context,[[UIColor whiteColor] CGColor]);
    
    // Calcul du point du centre
    
    CGContextMoveToPoint(context, circleFirst.x, circleFirst.y);
    CGContextAddArcToPoint(context, circleMiddle.x -2*radius, circleMiddle.y,
                           circleMiddle.x, circleMiddle.y, radius);
    
    CGContextMoveToPoint(context, circleSecond.x, circleSecond.y);
    CGContextAddArcToPoint(context, circleMiddle.x +2*radius, circleMiddle.y,
                           circleMiddle.x, circleMiddle.y, radius);
    
    CGContextMoveToPoint(context, circleFirst.x, circleFirst.y-lineWidth/2);
    CGContextAddLineToPoint(context, circleSmallFirst.x, circleSmallFirst.y);

    CGContextMoveToPoint(context, circleSecond.x, circleSecond.y-lineWidth/2);
    CGContextAddLineToPoint(context, circleSmallSecond.x, circleSmallSecond.y);
    
    CGContextAddArcToPoint(context, circleSmallSecond.x, circleSmallMiddle.y,
                           circleSmallMiddle.x, circleSmallMiddle.y, radiusSmall);
    
    CGContextMoveToPoint(context, circleSmallFirst.x, circleSmallFirst.y);
    
    CGContextAddArcToPoint(context, circleSmallFirst.x, circleSmallMiddle.y,
                           circleSmallMiddle.x, circleSmallMiddle.y, radiusSmall);
    
    CGContextStrokePath(context);
    
    
    CGFloat diff = circleSmallFirst.y - circleFirst.y;
    
    
    for (NSInteger i = 0; i <4 ; ++i)
    {
        CGPoint origin = CGPointMake(circleSmallFirst.x, circleFirst.y + diff*i/4.f + diff/8.f);
        CGPoint dest = CGPointMake(origin.x + 0.6f * (circleSmallSecond.x -circleSmallFirst.x) , origin.y);
        
        
        CGContextMoveToPoint(context, origin.x, origin.y);
        CGContextAddLineToPoint(context, dest.x, dest.y);
        
        CGContextStrokePath(context);
    }
    
    CGColorSpaceRelease(baseSpace), baseSpace = NULL;
    
    
}


-(void)drawFullGradientNum:(uint8_t)numGradient withBaseSpace:(CGColorSpaceRef) baseSpace inContext:(CGContextRef) context
{
    CGGradientRef gradient = CGGradientCreateWithColorComponents(baseSpace, colorsBlueToRed + numGradient*4, NULL, 2);
    CGContextDrawLinearGradient(context, gradient, pointTemp[numGradient], pointTemp[numGradient+1], 0);
    CGGradientRelease(gradient), gradient = NULL;
}

-(void)drawIntermediateGradientNum:(uint8_t)numGradient withBaseSpace:(CGColorSpaceRef) baseSpace inContext:(CGContextRef) context
{
    CGFloat percent = (_curValue - _minValue)/(_maxValue - _minValue);
    CGFloat percentGradient = 4 * percent - numGradient;
    
    CGFloat rValue = percentGradient * colorsBlueToRed[((numGradient+1)*4)] + (1.f-percentGradient) * colorsBlueToRed[(numGradient *4)];
    CGFloat gValue = percentGradient * colorsBlueToRed[((numGradient+1)*4) +1] + (1.f-percentGradient) * colorsBlueToRed[(numGradient *4) +1];
    CGFloat bValue = percentGradient * colorsBlueToRed[((numGradient+1)*4) +2] + (1.f-percentGradient) * colorsBlueToRed[(numGradient *4) +2];
    
    customGradientValues[0]     = colorsBlueToRed[numGradient *4];
    customGradientValues[1]     = colorsBlueToRed[(numGradient *4) +1];
    customGradientValues[2]     = colorsBlueToRed[(numGradient *4) +2];
    customGradientValues[4]     = rValue;
    customGradientValues[5]     = gValue;
    customGradientValues[6]     = bValue;
    
    CGPoint sommet = CGPointMake(pointTemp[numGradient].x, pointTemp[numGradient].y + (pointTemp[numGradient +1].y - pointTemp[numGradient].y)*percentGradient);
    
    CGGradientRef gradient = CGGradientCreateWithColorComponents(baseSpace, customGradientValues, NULL, 2);
    CGContextDrawLinearGradient(context, gradient, pointTemp[numGradient], sommet, 0);
    CGGradientRelease(gradient), gradient = NULL;
}


@end
