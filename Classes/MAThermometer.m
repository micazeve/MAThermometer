//
//  MAThermometer.m
//  MAThermometer-Demo
//
//  Created by Michael Azevedo on 16/06/2014.
//

#import "MAThermometer.h"


static const CGFloat colorsBlueToRed[] =  {
    0.0, 0.0, 1.0, 1.0,     // Blue
	0.0, 1.0, 1.0, 1.0,     // Cyan
    0.0, 1.0, 0.0, 1.0,     // Green
	1.0, 1.0, 0.0, 1.0,     // Yellow
	1.0, 0.0, 0.0, 1.0      // Red
};

static const CGFloat colorsLight [] = {
	1.0, 1.0, 1.0, 0.5,
	1.0, 1.0, 1.0, 0.0
};

static const CGFloat colorsReflect [] = {
	1.0, 1.0, 1.0, 1.0,
	1.0, 1.0, 1.0, 0.0
};

@interface MAThermometer () {

    CGPoint pointTemp[5];
    CGFloat customGradientValues[8];
}

@property (nonatomic, assign) CGFloat span;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign) CGFloat yOffset;


@property (nonatomic, assign) CGFloat lineWidth;

// Lower part of the thermometer
@property (nonatomic, assign) CGFloat lowerCircleRadius;
@property (nonatomic, assign) CGPoint lowerCircleCenter;
@property (nonatomic, assign) CGPoint lowerCircleFirst;
@property (nonatomic, assign) CGPoint lowerCircleMiddle;
@property (nonatomic, assign) CGPoint lowerCircleSecond;

// Upper part of the thermometer
@property (nonatomic, assign) CGFloat upperCircleRadius;
@property (nonatomic, assign) CGPoint upperCircleCenter;
@property (nonatomic, assign) CGPoint upperCircleFirst;
@property (nonatomic, assign) CGPoint upperCircleMiddle;
@property (nonatomic, assign) CGPoint upperCircleSecond;




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
    _curValue               = 0;
    _yOffset                = 0;
    _darkTheme              = NO;
    _shadowEnabled          = NO;
    
    _height = CGRectGetHeight(self.bounds);
    
    CGFloat width = CGRectGetWidth(self.bounds);
    
    if (_height/width > 4) {
        _height = width* 4;
        _yOffset = (CGRectGetHeight(self.bounds) - _height)/2;
    }
    
    
    [self setMinValue:0 maxValue:100];
    customGradientValues[3] = 1;
    customGradientValues[7] = 1;
        
    // We compute all the points in order to save some time on drawRect method
    
    _lineWidth              = _height/100.f;
    
    
    _lowerCircleRadius      = (_height -2*_lineWidth)/8;
    _lowerCircleCenter      = CGPointMake(CGRectGetMidX(self.bounds), _height - (_lowerCircleRadius + _lineWidth) + _yOffset);
    _lowerCircleFirst       = CGPointMake((_lowerCircleCenter.x - cos(M_PI_4) * _lowerCircleRadius),
                                          (_lowerCircleCenter.y - sin(M_PI_4) * _lowerCircleRadius));
    _lowerCircleMiddle      = CGPointMake(_lowerCircleCenter.x,
                                          _lowerCircleCenter.y + _lowerCircleRadius);
    _lowerCircleSecond      = CGPointMake((_lowerCircleCenter.x + cos(M_PI_4) * _lowerCircleRadius),
                                          (_lowerCircleCenter.y - sin(M_PI_4) * _lowerCircleRadius));
    
    
    _upperCircleRadius      = (_lowerCircleSecond.x - _lowerCircleFirst.x)/2;
    _upperCircleCenter      = CGPointMake(CGRectGetMidX(self.bounds), _lineWidth + _upperCircleRadius+ _yOffset);
    _upperCircleFirst       = CGPointMake(_lowerCircleFirst.x, _upperCircleCenter.y);
    _upperCircleMiddle      = CGPointMake(_upperCircleCenter.x,_upperCircleCenter.y - _upperCircleRadius);
    _upperCircleSecond      = CGPointMake(_lowerCircleSecond.x, _upperCircleCenter.y);
    

    self.backgroundColor = [UIColor clearColor];
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
    
    
    CGContextAddEllipseInRect(context, CGRectMake(_lowerCircleCenter.x - _lowerCircleRadius, _lowerCircleCenter.y - _lowerCircleRadius,
                                                  _lowerCircleRadius*2, _lowerCircleRadius*2));
    
    CGContextMoveToPoint(context, _lowerCircleFirst.x, _lowerCircleFirst.y);
    
    CGContextAddLineToPoint(context, _upperCircleFirst.x, _upperCircleFirst.y);
    CGContextAddArcToPoint(context, _upperCircleFirst.x, _upperCircleMiddle.y,
                           _upperCircleMiddle.x, _upperCircleMiddle.y, _upperCircleRadius);
    
    CGContextAddArcToPoint(context, _upperCircleSecond.x, _upperCircleMiddle.y,
                           _upperCircleSecond.x,_upperCircleSecond.y, _upperCircleRadius);
    CGContextAddLineToPoint(context, _lowerCircleSecond.x, _lowerCircleSecond.y);
    
    CGContextClosePath(context);
    CGContextSaveGState(context);
    CGContextClip(context);


        // on calcule en fonction du pourcentage
    
    
    CGContextSetFillColorWithColor(context,[[UIColor blueColor] CGColor]);
    
    NSInteger height = _upperCircleMiddle.y - _lowerCircleMiddle.y;
    
    for (uint8_t i = 0; i < 5 ; ++i)
    {
        pointTemp[i] = CGPointMake(CGRectGetMidX(self.bounds), _lowerCircleMiddle.y + (i*height)/4);
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
    
    if (_shadowEnabled)
    {
        CGGradientRef gradient = CGGradientCreateWithColorComponents(baseSpace, colorsLight, NULL, 2);
        
        CGContextMoveToPoint(context, _lowerCircleCenter.x, _lowerCircleCenter.y);
        CGContextAddArc(context, _lowerCircleCenter.x, _lowerCircleCenter.y, _lowerCircleRadius, -M_PI_4, -3* M_PI_4, 0);
        CGContextClosePath(context);
        CGContextSaveGState(context);
        CGContextClip(context);
        CGContextDrawRadialGradient(context, gradient, _lowerCircleCenter, _lowerCircleRadius, _lowerCircleCenter, _lowerCircleRadius - _upperCircleRadius, 0);
        CGContextRestoreGState(context);
        
        
        CGContextMoveToPoint(context, _lowerCircleFirst.x, _lowerCircleFirst.y);
        CGContextAddArc(context, _lowerCircleFirst.x, _lowerCircleFirst.y, _upperCircleRadius, 0, M_PI_4, 0);
        CGContextClosePath(context);
        CGContextSaveGState(context);
        CGContextClip(context);
        CGContextDrawRadialGradient(context, gradient, _lowerCircleFirst, 0, _lowerCircleFirst, _upperCircleRadius , 0);
        CGContextRestoreGState(context);
        
        
        CGContextMoveToPoint(context, _lowerCircleSecond.x, _lowerCircleSecond.y);
        CGContextAddArc(context, _lowerCircleSecond.x, _lowerCircleSecond.y, _upperCircleRadius, M_PI,3*M_PI_4, 1);
        CGContextClosePath(context);
        CGContextSaveGState(context);
        CGContextClip(context);
        CGContextDrawRadialGradient(context, gradient, _lowerCircleSecond, 0, _lowerCircleSecond, _upperCircleRadius , 0);
        CGContextRestoreGState(context);
        
        CGContextAddRect(context, CGRectMake(_upperCircleFirst.x, _upperCircleFirst.y, _upperCircleCenter.x - _upperCircleFirst.x, _lowerCircleFirst.y - _upperCircleFirst.y));
        CGContextClosePath(context);
        CGContextSaveGState(context);
        CGContextClip(context);
        CGContextDrawLinearGradient(context, gradient, _upperCircleFirst, CGPointMake(_upperCircleMiddle.x ,_upperCircleFirst.y), 0);
        CGContextRestoreGState(context);
        
        CGContextAddRect(context, CGRectMake(_upperCircleCenter.x, _upperCircleCenter.y, _upperCircleSecond.x - _upperCircleCenter.x, _lowerCircleSecond.y - _upperCircleSecond.y));
        CGContextClosePath(context);
        CGContextSaveGState(context);
        CGContextClip(context);
        CGContextDrawLinearGradient(context, gradient, _upperCircleSecond, CGPointMake(_upperCircleMiddle.x ,_upperCircleSecond.y), 0);
        CGContextRestoreGState(context);
        
        CGContextAddArc(context, _upperCircleCenter.x, _upperCircleCenter.y, _upperCircleRadius, 0, M_PI, 1);
        CGContextClosePath(context);
        CGContextSaveGState(context);
        CGContextClip(context);
        CGContextDrawRadialGradient(context, gradient, _upperCircleCenter, _upperCircleRadius, _upperCircleCenter, 0, 0);
        CGContextRestoreGState(context);
        
        CGGradientRelease(gradient), gradient = NULL;
        
        gradient = CGGradientCreateWithColorComponents(baseSpace, colorsReflect, NULL, 2);
        
        CGPoint reflectionPoint = CGPointMake((_lowerCircleFirst.x + _lowerCircleCenter.x) /2,
                                              (_lowerCircleFirst.y + _lowerCircleCenter.y) /2);
        
        
        CGContextDrawRadialGradient(context, gradient, reflectionPoint, 0, reflectionPoint, _lineWidth *2, 0);
        
        
        
        
        CGGradientRelease(gradient), gradient = NULL;
    }
    
    CGContextSetLineWidth(context, _lineWidth);
    
    
    
    
    
    if (_darkTheme)
        CGContextSetStrokeColorWithColor(context,[[UIColor blackColor] CGColor]);
    else
        CGContextSetStrokeColorWithColor(context,[[UIColor whiteColor] CGColor]);
    
    CGContextMoveToPoint(context, _lowerCircleFirst.x, _lowerCircleFirst.y);
    CGContextAddArcToPoint(context, _lowerCircleMiddle.x -2*_lowerCircleRadius, _lowerCircleMiddle.y,
                           _lowerCircleMiddle.x, _lowerCircleMiddle.y, _lowerCircleRadius);
    
    CGContextMoveToPoint(context, _lowerCircleSecond.x, _lowerCircleSecond.y);
    CGContextAddArcToPoint(context, _lowerCircleMiddle.x +2*_lowerCircleRadius, _lowerCircleMiddle.y,
                           _lowerCircleMiddle.x, _lowerCircleMiddle.y, _lowerCircleRadius);
    
    CGContextMoveToPoint(context, _lowerCircleFirst.x, _lowerCircleFirst.y+_lineWidth/2);
    CGContextAddLineToPoint(context, _upperCircleFirst.x, _upperCircleFirst.y);

    CGContextMoveToPoint(context, _lowerCircleSecond.x, _lowerCircleSecond.y+_lineWidth/2);
    CGContextAddLineToPoint(context, _upperCircleSecond.x, _upperCircleSecond.y);
    
    CGContextAddArcToPoint(context, _upperCircleSecond.x, _upperCircleMiddle.y,
                           _upperCircleMiddle.x, _upperCircleMiddle.y, _upperCircleRadius);
    
    CGContextMoveToPoint(context, _upperCircleFirst.x, _upperCircleFirst.y);
    
    CGContextAddArcToPoint(context, _upperCircleFirst.x, _upperCircleMiddle.y,
                           _upperCircleMiddle.x, _upperCircleMiddle.y, _upperCircleRadius);
    
    CGContextStrokePath(context);
    
    
    CGFloat diff = _upperCircleFirst.y - _lowerCircleFirst.y;
    
    
    for (NSInteger i = 0; i <4 ; ++i)
    {
        CGPoint origin = CGPointMake(_upperCircleSecond.x, _lowerCircleFirst.y + diff*i/4.f + diff/8.f);
        CGPoint dest = CGPointMake(origin.x - 0.6f * (_upperCircleSecond.x -_upperCircleFirst.x) , origin.y);
        
        
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
