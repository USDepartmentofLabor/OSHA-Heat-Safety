//
//  DOLAppDelegate.h
//  OSHA Heat Safety
//
//  Created by Michael Pulsifer on 7/8/13.
//  Relased to the public domain
//

#import <Cocoa/Cocoa.h>
#import <CoreLocation/CoreLocation.h>
#import "XMLReader.h"
#import <WebKit/WebKit.h>

@interface DOLAppDelegate : NSObject <NSApplicationDelegate, CLLocationManagerDelegate> {
    
    IBOutlet NSTextField *temperatureField;
    NSButton *calculateBtn;
    NSButton *getTodayMaxBtn;
    NSButton *getCurrentBtn;
    IBOutlet NSTextField *heatIndexValue;
    IBOutlet NSTextField *riskLevelValue;
    IBOutlet NSTextField *humidityField;
    IBOutlet WebView *precautionsContent;
    CLLocationManager *locationManager;
    NSDictionary *_xmlDictionary;
    IBOutlet NSTextField *noaaTime;
    
}
// Button handlers
-(IBAction)getCurrent:(id)sender;
-(IBAction)getTodayMax:(id)sender;
-(void)showPrecautions;
-(IBAction)calculatePressed:(id)sender;

// Heat Index Methods
- (void)updateHeatLevel:(double)level;
- (void)calculateHeatIndex:(float)temperature withHumidity:(float)humidity;
- (float)getHeatIndex:(float)temp withHumidty:(float)humidity;
- (void)getCurrentHeatIndex;
- (void)getMaxHeatIndex;

- (void)resetApp;

// NOAA
- (void)getNOAAData;
- (void)getOpenWeatherData;

// UI Methods
- (void)alertBox:(NSString *)title withMessage:(NSString *)message andLabel:(NSString *)buttonLabel;
- (IBAction)showHeatSafetyTips:(id)sender;
- (IBAction)showSignsAndSymptoms:(id)sender;
- (IBAction)showFirstAid:(id)sender;
- (IBAction)showContactOSHA:(id)sender;
- (IBAction)showAboutThisApp:(id)sender;
- (IBAction)printPrecautions:(id)sender;

@property (assign) IBOutlet NSTextField *temperatureField;
@property (nonatomic, retain) NSButton *calculateBtn;
@property (nonatomic, retain) NSButton *getTodayMaxBtn;
@property (nonatomic, retain) NSButton *getCurrentBtn;
@property (assign) IBOutlet NSTextField *heatIndexValue;
@property (assign) IBOutlet NSTextField *riskLevelValue;
@property (assign) IBOutlet NSTextField *humidityField;
@property (assign) IBOutlet WebView *precautionsContent;
@property (nonatomic, retain) CLLocationManager *locationManager;
@property (assign) IBOutlet NSTextField *noaaTime;


@property (assign) IBOutlet NSWindow *window;

@end
