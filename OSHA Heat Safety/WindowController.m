//
//  WindowController.m
//  OSHA Heat Safety
//
//  Created by Michael Pulsifer on 7/8/13.
//  Copyright (c) 2013 U.S. Department of Labor. All rights reserved.
//

#import "WindowController.h"

@interface WindowController ()

@end

@implementation WindowController

@synthesize temperatureField, humidityField, calculateBtn, getCurrentBtn, getTodayMaxBtn, heatIndexValue, riskLevelValue,precautionsContent, noaaTime, masthead, locationManager;

// stored values
NSString *heatLevel;
NSString *currentHeatIndex;
NSString *currentMode = nil;
float temperature;
float humidity;

// location
float curLat = 42.46;
float curLon = -71.25;

// Date/Time/Temp items
NSMutableArray *_temperature;
NSMutableArray *_humidity;
NSMutableArray *_time;
NSMutableArray *validIndexes;
NSInteger day;
NSInteger hour;
NSInteger min;

// NOAA data
NSInteger noaaHour;
NSString *noaaAMPM = nil;
NSString *noaaURL = @"http://forecast.weather.gov/MapClick.php?lat=%f&lon=%f&FcstType=digitalDWML";

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    

}

#pragma mark - Location Handlers

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation{
    
    self.locationManager.delegate = nil;
    [self.locationManager stopUpdatingLocation];
    
    NSLog(@"Coords: %@", [NSString stringWithFormat:@"Latitude: %f Longitude: %f", newLocation.coordinate.latitude, newLocation.coordinate.longitude]);
    NSLog(@"currentMode: %@", currentMode);
    
    curLat = newLocation.coordinate.latitude;
    curLon = newLocation.coordinate.longitude;
    
    if([currentMode isEqualToString:@"getMax"]) {
        [self getMaxHeatIndex];
    } else if([currentMode isEqualToString:@"getCurrent"]) {
        [self getCurrentHeatIndex];
    } else {
        // do nothing
    }
    
    currentMode = nil;
}


- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError*)error {
    
    [self alertBox:NSLocalizedString(@"NOTIFICATION", @"") withMessage:NSLocalizedString(@"NO_GPS", @"") andLabel:NSLocalizedString(@"OK", @"")];
    
    [self.locationManager stopUpdatingLocation];
}

#pragma mark - Interface Builder Methods

- (void)resetApp {
    heatLevel = nil;
    currentHeatIndex = nil;
    currentMode = nil;
    temperature = 0;
    humidity = 0;
    _temperature = nil;
    _humidity = nil;
    _time = nil;
    validIndexes = nil;
    day = 0;
    hour = 0;
    min = 0;
    noaaHour = 0;
    noaaAMPM = nil;
    
    [noaaTime setStringValue:@""];
    [temperatureField setStringValue:@""];
    [humidityField setStringValue:@"" ];
    [heatIndexValue setStringValue:@"" ];
    [riskLevelValue setStringValue:@"" ];
    //[riskLevelValue setBackgroundColor:[NSColor colorWithSRGBRed:230.0/255 green:260.0/255 blue:230.0/255 alpha:1]];
}

-(IBAction)getCurrent {
    NSLog(@"[getCurrent]");
    //[self hideKeyboard];
    currentMode = @"getCurrent";
    
   /* if([(NSString *)[[UIDevice currentDevice] model] isEqualToString:@"iPhone Simulator"]) {
        [self getCurrentHeatIndex];
        return;
    }*/
    
    self.locationManager.delegate = self;
    [self.locationManager startUpdatingLocation];
}

-(IBAction)getTodayMax {
    NSLog(@"[getTodayMax]");
    //[self hideKeyboard];
    currentMode = @"getMax";
    
   /* if([(NSString *)[[UIDevice currentDevice] model] isEqualToString:@"iPhone Simulator"]) {
        [self getMaxHeatIndex];
        return;
    }*/
    
    self.locationManager.delegate = self;
    [self.locationManager startUpdatingLocation];
}

-(IBAction)showPrecautions {
    NSLog(@"[showPrecautions]");
    
    //[self hideKeyboard];
    
    //NSString *tmpHeatIndex = [heatIndexValue stringValue];
    //precautionsContent* subView = [[precautionsContent alloc] initWithNibName:@"PrecautionsView" bundle:nil];
    //[self.view addSubview:subView.view];
    //subView.view.frame = self.view.bounds;
    
    //subView.title = [Language getLocalizedString:@"PRECAUTIONS"];
    //[self.navigationController pushViewController:subView animated:YES];
    
    //[subView release];
    
    NSString *pageToLoad = @"";
    
    
    // set risk level, used all over the app
    if([heatLevel isEqualToString:@"extreme"]) {
        pageToLoad = @"precautions_veryhigh";
//        [precautionsContent displayPage:@"precautions_veryhigh":tmpHeatIndex:@"extreme"];
    } else if([heatLevel isEqualToString:@"high"]) {
        pageToLoad = @"precautions_moderate";
        //[subView displayPage:@"precautions_high":tmpHeatIndex:@"high"];
    } else if([heatLevel isEqualToString:@"moderate"]) {
        pageToLoad = @"precautions_moderate";
        //[subView displayPage:@"precautions_moderate":tmpHeatIndex:@"moderate"];
    } else if([heatLevel isEqualToString:@"lower"]) {
        pageToLoad = @"precautions_lower";
        //[subView displayPage:@"precautions_lower":tmpHeatIndex:@"lower"];
    } else {
        pageToLoad = @"precautions_lower";
        //[subView displayPage:@"precautions_lower":tmpHeatIndex:@"lower"];
    }
    NSString *path = [[NSBundle mainBundle] pathForResource:pageToLoad ofType:@"htm" inDirectory:NSLocalizedString(@"HTML_PATH", @"")];
    NSURL *url = [NSURL fileURLWithPath:path];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    //WebView *precautionsContent = [[WebView alloc] init];
    [[precautionsContent mainFrame] loadRequest:request] ;
    
    
    
    
/*    if([noaaTime isNotEqualTo:@""]) {
        [subView updateTime:noaaTime.text];
    }*/
}

-(IBAction)calculatePressed {
    NSLog(@"[calculatePressed]");
    //[self hideKeyboard];
    
    [noaaTime setStringValue:@""];
    
    temperature = [temperatureField floatValue];
    humidity = [humidityField floatValue];
    [self calculateHeatIndex:temperature withHumidity:humidity];
}

#pragma mark - Heat Index Methods

- (void)updateHeatLevel:(double)level {
    
    // Check heat level
    if(level > 115) {
        heatLevel = @"extreme";
    } else if(level > 103 & level <= 115) {
        heatLevel = @"high";
    } else if(level >= 91 & level <= 103) {
        heatLevel = @"moderate";
    } else if(level < 91) {
        heatLevel = @"lower";
    } else {
        heatLevel = @"lower";
    }
    
    // set heat index value
    currentHeatIndex = [NSString stringWithFormat:@"%.1f", level];
    [heatIndexValue setStringValue:[NSString stringWithFormat:@"%@ °F", currentHeatIndex]];
    
    /*
     Heat Level colors (rgb)
     -------------------------------
     low        r:255, g:255, b:0
     moderate   r:254, g:211, b:156
     high       r:247, g:142, b:1
     extreme    r:254, g:0, b:0
     -------------------------------
     */
    
    // set risk level, used all over the app
    if([heatLevel isEqualToString:@"extreme"]) {
        [riskLevelValue setStringValue:NSLocalizedString(@"LVL_EXTREME", @"")];
        [riskLevelValue setBackgroundColor:[NSColor colorWithSRGBRed:254.0/255 green:0/255 blue:0/255 alpha:1]];
    } else if([heatLevel isEqualToString:@"high"]) {
        [riskLevelValue setStringValue:NSLocalizedString(@"LVL_HIGH", @"")];
        [riskLevelValue setBackgroundColor:[NSColor colorWithSRGBRed:247.0/255 green:142.0/255 blue:1.0/255 alpha:1]];
    } else if([heatLevel isEqualToString:@"moderate"]) {
        [riskLevelValue setStringValue:NSLocalizedString(@"LVL_MODERATE", @"")];
        [riskLevelValue setBackgroundColor:[NSColor colorWithSRGBRed:254.0/255 green:211.0/255 blue:156.0/255 alpha:1]];
    } else if([heatLevel isEqualToString:@"lower"]) {
        [riskLevelValue setStringValue:NSLocalizedString(@"LVL_LOWER", @"")];
        [riskLevelValue setBackgroundColor:[NSColor colorWithSRGBRed:255.0/255 green:255.0/255 blue:0/255 alpha:1]];
    } else {
        [riskLevelValue setStringValue:NSLocalizedString(@"LVL_LOWER", @"")];
        [riskLevelValue setBackgroundColor:[NSColor colorWithSRGBRed:255.0/255 green:255.0/255 blue:0/255 alpha:1]];
    }
}

- (void)calculateHeatIndex:(float)temperature withHumidity:(float)humidity {
    NSLog(@"[calculateHeatIndex] temperature: %f, humidity: %f", temperature, humidity);
    
    BOOL errors = FALSE;
    
    [temperatureField setStringValue:[NSString stringWithFormat:@"%.1f", temperature]];
    [humidityField setStringValue:[NSString stringWithFormat:@"%.1f", humidity]];
    
    if(temperature == 0 && humidity == 0) {
        [self alertBox:NSLocalizedString(@"ERROR", @"") withMessage:NSLocalizedString(@"ALERT_TEMP_EMPTY", @"") andLabel:NSLocalizedString(@"OK", @"")];
        errors = TRUE;
    } else if(temperature == 0) {
        [self alertBox:NSLocalizedString(@"ERROR", @"") withMessage:NSLocalizedString(@"ALERT_TEMP_EMPTY", @"") andLabel:NSLocalizedString(@"OK", @"")];
        errors = TRUE;
    } else if(humidity == 0) {
        [self alertBox:NSLocalizedString(@"ERROR", @"") withMessage:NSLocalizedString(@"ALERT_HUMID_EMPTY", @"") andLabel:NSLocalizedString(@"OK", @"")];
        errors = TRUE;
    }
    
    if(temperature > 0 && humidity > 0) {
        if(temperature < 80) {
            [self alertBox:NSLocalizedString(@"ALERT", @"") withMessage:NSLocalizedString(@"TEMP_UNDER_80", @"") andLabel:NSLocalizedString(@"OK", @"")];
            errors = TRUE;
        } else if(humidity > 100) {
            [self alertBox:NSLocalizedString(@"ALERT", @"") withMessage:NSLocalizedString(@"HUMID_OVER_100", @"") andLabel:NSLocalizedString(@"OK", @"")];
            errors = TRUE;
        }
        
        [self updateHeatLevel:[self getHeatIndex:temperature withHumidty:humidity]];
        //precautionsBtn.enabled = true;
        
        if(errors) {
            [noaaTime setStringValue:@""];
            //riskLevelValue.text = @"";
            [heatIndexValue setStringValue:@""];
            //[riskLevelValue setBackgroundColor:[UIColor colorWithRed:230.0/255 green:230.0/255 blue:230.0/255 alpha:1]];
        }
    }
}

- (float)getHeatIndex:(float)temp withHumidty:(float)humidity {
    
    NSLog(@"[getHeatIndex] temp: %f, humidity: %f", temp, humidity);
    
    float hIndex =
    -42.379 + 2.04901523 * temp
    + 10.14333127 * humidity
    - 0.22475541 * temp * humidity
    - 6.83783 * pow(10, -3) * temp * temp
    - 5.481717 * pow(10, -2) * humidity * humidity
    + 1.22874 * pow(10, -3) * temp * temp * humidity
    + 8.5282 * pow(10, -4) * temp * humidity * humidity
    - 1.99 * pow(10, -6) * temp * temp * humidity * humidity;
    
    //hIndex = round(hIndex);
    NSLog(@"-Heat Index: %f", hIndex);
    return hIndex;
}

- (void)getCurrentHeatIndex {
    [self getNOAAData];
    
    [noaaTime setStringValue:@""];
    
    for(id obj in validIndexes) {
        NSInteger tmpHour = [[[_time objectAtIndex:[obj integerValue]] substringWithRange:NSMakeRange(11, 2)] integerValue];
        if(hour == tmpHour) {
            NSString *time = [_time objectAtIndex:[obj integerValue]];
            float temperature = [[_temperature objectAtIndex:[obj integerValue]] floatValue];
            float humidity = [[_humidity objectAtIndex:[obj integerValue]] floatValue];
            
            NSLog(@"time: %@", time);
            
            NSString *ampm = nil;
            
            if(tmpHour < 12) {
                ampm = @"am";
            } else {
                if(tmpHour > 12) {
                    tmpHour = (tmpHour - 12);
                }
                ampm = @"pm";
            }
            
            noaaHour = tmpHour;
            noaaAMPM = ampm;
            [noaaTime setStringValue:[NSString stringWithFormat:NSLocalizedString("@NOAA_TIME", @""), noaaHour, noaaAMPM]];
            
            [self calculateHeatIndex:temperature withHumidity:humidity];
            break;
        }
    }
}

- (void)getMaxHeatIndex {
    [self getNOAAData];
    
    [noaaTime setStringValue:@""];
    
    float tmpHeatIndex = 0;
    float tmpMaxHeatIndex = 0;
    float tmpTemperature = 0;
    float tmpHumidity = 0;
    
    for(id obj in validIndexes) {
        NSInteger tmpHour = [[[_time objectAtIndex:[obj integerValue]] substringWithRange:NSMakeRange(11, 2)] integerValue];
        if(tmpHour > hour) {
            NSLog(@"getMaxHeatIndex - Hour %ld", tmpHour);
            float temperature = [[_temperature objectAtIndex:[obj integerValue]] floatValue];
            float humidity = [[_humidity objectAtIndex:[obj integerValue]] floatValue];
            tmpHeatIndex = [self getHeatIndex:temperature withHumidty:humidity];
            if(tmpHeatIndex > tmpMaxHeatIndex)
            {
                tmpMaxHeatIndex = tmpHeatIndex;
                tmpTemperature = temperature;
                tmpHumidity = humidity;
                
                NSString *ampm = nil;
                
                if(tmpHour < 12) {
                    ampm = @"am";
                } else {
                    if(tmpHour > 12) {
                        tmpHour = (tmpHour - 12);
                    }
                    ampm = @"pm";
                }
                
                noaaHour = tmpHour;
                noaaAMPM = ampm;
                [noaaTime setStringValue:[NSString stringWithFormat:NSLocalizedString(@"NOAA_TIME", @""), noaaHour, noaaAMPM]];
            }
        }
    }
    
    if(tmpTemperature < 80.0) {
        [noaaTime setStringValue:@""];
        [self getCurrentHeatIndex];
        return;
    }
    
    NSLog(@"tmpMaxHeatIndex: %f", tmpMaxHeatIndex);
    //[self updateHeatLevel:tmpMaxHeatIndex];
    [self calculateHeatIndex:tmpTemperature withHumidity:tmpHumidity];
}

#pragma mark - NOAA Methods

- (void)getNOAAData {
    
    //[NSApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    // Process request
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:noaaURL, curLat, curLon]]];
    NSError *error = nil;
    NSURLResponse *response = nil;
    NSData *xmlData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    NSLog(@"NSURLRequest request: %@", request.URL);
    
    // Parse the XML Data
    _xmlDictionary = [XMLReader dictionaryForXMLData:xmlData error:&error];
    
    //
    // Pull in relevent information, clean data, then parse (very involved..)
    //
    
    // get temperature data (ex: 73)
    NSDictionary *_tempDict = [_xmlDictionary retrieveForPath:[NSString stringWithFormat:@"dwml.data.parameters.temperature.%d", 0]];
    
    if(_tempDict == nil) {
        [self alertBox:NSLocalizedString(@"NOTICE", @"") withMessage:NSLocalizedString(@"NOAA_UNAVAILABLE", @"") andLabel:NSLocalizedString(@"OK", @"")];
        //[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        return;
    }
    
    NSMutableArray *_temp2 = [NSMutableArray arrayWithArray:[_tempDict allValues]];[_temp2 removeObjectAtIndex:0];[_temp2 removeObjectAtIndex:0];
    _temperature = [NSMutableArray arrayWithArray:[_temp2 objectAtIndex:0]];
    
    // get humidity data (ex: 84)
    NSDictionary *_humidityDict = [_xmlDictionary retrieveForPath:[NSString stringWithFormat:@"dwml.data.parameters.humidity", nil]];
    NSMutableArray *_humidity2 = [NSMutableArray arrayWithArray:[_humidityDict allValues]];
    _humidity = [NSMutableArray arrayWithArray:[_humidity2 objectAtIndex:0]];
    
    // get time data (ex: 2011-08-10T10:00:00-04:00)
    _time = [_xmlDictionary retrieveForPath:@"dwml.data.time-layout.start-valid-time"];
    
    // Get current date
    NSDate* now = [NSDate date];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *dateComponents = [gregorian components:(NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit| NSSecondCalendarUnit) fromDate:now];
    day = [dateComponents day];
    hour = [dateComponents hour];
    min = [dateComponents minute];
    
    validIndexes = [[NSMutableArray alloc] init];
    
    //if(min > 30) hour++;
    hour++;
    
    int curID = 0;
    for(id object in _time) {
        NSInteger tmpDay = [[object substringWithRange:NSMakeRange(8, 2)] integerValue];
        if(tmpDay == day) {
            [validIndexes addObject:[NSNumber numberWithInteger:curID]];
        }
        ++curID;
    }
    
    //NSLog(@"Date %@", [NSString stringWithFormat:@"Day: %d, Hour: %d", day, hour]);
    
    //NSLog(@"_time: %@", _time);
    //NSLog(@"_temperature: %@", _temperature);
    //NSLog(@"_humidity: %@", _humidity);
    //NSLog(@"validIndexes: %@", validIndexes);
    
    //[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

#pragma mark - UI Methods
/*
- (void)redrawApp {
    
    [calculateBtn setTitle:NSLocalizedString(@"CALCULATE", @"") forState:UIControlStateNormal];
    [precautionsBtn setTitle:NSLocalizedString(@"PRECAUTIONS", @"") forState:UIControlStateNormal];
    [getCurrentBtn setTitle:NSLocalizedString(@"GET_CURRENT", @"") forState:UIControlStateNormal];
    [getTodayMaxBtn setTitle:[Language getLocalizedString:@"GET_TODAY_MAX"] forState:UIControlStateNormal];
    
    [temperatureLabel setText:[Language getLocalizedString:@"TEMPERATURE"]];
    [humidityLabel setText:[Language getLocalizedString:@"HUMIDITY"]];
    
    [heatIndexLabel setText:[Language getLocalizedString:@"HEAT_INDEX"]];
    [riskLevelLabel setText:[Language getLocalizedString:@"RISK_LEVEL"]];
    
    if(heatLevel != nil) {
        if(heatLevel == @"extreme") {
            riskLevelValue.text = [Language getLocalizedString:@"LVL_EXTREME"];
        } else if(heatLevel == @"high") {
            riskLevelValue.text = [Language getLocalizedString:@"LVL_HIGH"];
        } else if(heatLevel == @"moderate") {
            riskLevelValue.text = [Language getLocalizedString:@"LVL_MODERATE"];
        } else if(heatLevel == @"lower") {
            riskLevelValue.text = [Language getLocalizedString:@"LVL_LOWER"];
        }
    }
    
    // Time
    if(noaaAMPM != nil) {
        noaaTime.text = [NSString stringWithFormat:[Language getLocalizedString:@"NOAA_TIME"], noaaHour, noaaAMPM];
    }
    
    masthead.image = [UIImage imageNamed:[Language getLocalizedString:@"MASTHEAD"]];
}

- (void)hideKeyboard {
    // Hide keyboard!
    [temperatureField resignFirstResponder];
    [humidityField resignFirstResponder];
}
*/
- (void)alertBox:(NSString *)title withMessage:(NSString *)message andLabel:(NSString *)buttonLabel {
    NSString *errorTitle = title;
    NSString *errorString = message;
    NSAlert *errorView = [[[NSAlert alloc] init] autorelease];
    [errorView addButtonWithTitle:@"OK"];
    [errorView setMessageText:errorTitle];
    [errorView setInformativeText:errorString];
    [errorView setAlertStyle:NSWarningAlertStyle];
    [errorView runModal];
    //NSAlertView *errorView = [[UIAlertView alloc] initWithTitle:errorTitle message:errorString delegate:self cancelButtonTitle:nil otherButtonTitles:buttonLabel, nil];
    //[errorView show];
    //[errorView autorelease];
}

@end
