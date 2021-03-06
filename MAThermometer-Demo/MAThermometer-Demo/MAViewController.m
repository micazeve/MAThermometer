//
//  MAViewController.m
//  MAThermometer-Demo
//
//  Created by Michael Azevedo on 16/06/2014.
//
//

#import "MAViewController.h"
#import "MAThermometer.h"

@interface MAViewController ()

@property (weak, nonatomic) IBOutlet UIView *viewForThermometer1;
@property (weak, nonatomic) IBOutlet UIView *viewForThermometer2;
@property (weak, nonatomic) IBOutlet UIView *viewForThermometer3;

@property (weak, nonatomic) IBOutlet UISlider *slider;
@property (weak, nonatomic) IBOutlet UILabel *labelSlider;

@property (nonatomic, strong) MAThermometer * thermometer1;
@property (nonatomic, strong) MAThermometer * thermometer2;
@property (nonatomic, strong) MAThermometer * thermometer3;
@property (weak, nonatomic) IBOutlet MAThermometer *thermometerWithoutShadow;
@property (weak, nonatomic) IBOutlet MAThermometer *thermometerWithShadow;

@end

@implementation MAViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    _thermometer1 = [[MAThermometer alloc] initWithFrame:_viewForThermometer1.bounds];
    [_thermometer1 setMaxValue:200];
    
    _thermometer2 = [[MAThermometer alloc] initWithFrame:_viewForThermometer2.bounds];
    
    _thermometer3 = [[MAThermometer alloc] initWithFrame:_viewForThermometer3.bounds];
    [_thermometer3 setDarkTheme:YES];
    [_thermometer3 setArrayColors:@[[UIColor whiteColor], [UIColor lightGrayColor], [UIColor orangeColor]]];
    
    [_thermometerWithShadow setGlassEffect:YES];

    [_viewForThermometer1 addSubview:_thermometer1];
    [_viewForThermometer2 addSubview:_thermometer2];
    [_viewForThermometer3 addSubview:_thermometer3];
    
    
    [_labelSlider setText:[NSString stringWithFormat:@"%.2f", _slider.value]];
    
}
- (IBAction)sliderMoved:(id)sender {
    [_labelSlider setText:[NSString stringWithFormat:@"%.2f", _slider.value]];
    
    _thermometer1.curValue = self.slider.value;
    _thermometer2.curValue = self.slider.value;
    _thermometer3.curValue = self.slider.value;
    _thermometerWithoutShadow.curValue = self.slider.value;
    _thermometerWithShadow.curValue = self.slider.value;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
