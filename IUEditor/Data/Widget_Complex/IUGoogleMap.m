//
//  IUGoogleMap.m
//  IUEditor
//
//  Created by seungmi on 2014. 8. 7..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "IUGoogleMap.h"
#import "JDCode.h"
#import "IUProject.h"

@implementation IUGoogleMap

#pragma mark - Initialize

- (id)initWithProject:(IUProject *)project options:(NSDictionary *)options{
    self = [super initWithProject:project options:options];
    if(self){
        [self.undoManager disableUndoRegistration];
        
        self.zoomLevel = 14;
        self.latitude = @"37.790896";
        self.longitude = @"-122.401502";
        self.enableMarkerIcon = YES;
        self.markerTitle = @"JDLab @ RocketSpace";
        
        [self.css setValue:@(400) forTag:IUCSSTagPixelWidth forViewport:IUCSSDefaultViewPort];
        [self.css setValue:@(400) forTag:IUCSSTagPixelHeight forViewport:IUCSSDefaultViewPort];
        
        [self.undoManager enableUndoRegistration];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    self =  [super initWithCoder:aDecoder];
    [self.undoManager disableUndoRegistration];
    
    if(self){
        [aDecoder decodeToObject:self withProperties:[[IUGoogleMap class] properties]];
    }
    
    [self.undoManager enableUndoRegistration];
    return self;
}
-(void)encodeWithCoder:(NSCoder *)aCoder{
    [super encodeWithCoder:aCoder];
    
    [aCoder encodeFromObject:self withProperties:[[IUGoogleMap class] properties]];
    
}

-(id)copyWithZone:(NSZone *)zone{
    [self.undoManager disableUndoRegistration];
    [self.delegate disableUpdateAll:self];
    
    IUGoogleMap *map = [super copyWithZone:zone];
    
    map.longitude = _longitude;
    map.latitude = _latitude;
    map.zoomLevel = _zoomLevel;
    map.panControl = _panControl;
    map.zoomControl = _zoomControl;
    map.enableMarkerIcon = _enableMarkerIcon;
    map.markerIconName = [_markerIconName copy];
    map.markerTitle =[_markerTitle copy];
    
    
    [self.delegate enableUpdateAll:self];
    [self.undoManager enableUndoRegistration];
    return map;
}

#pragma mark - set Property


- (void)setLongitude:(NSString *)longitude{
    if([longitude isEqualToString:_longitude] == NO){
        [[self.undoManager prepareWithInvocationTarget:self] setLongitude:_longitude];
        _longitude = longitude;
    }
    [self updateHTML];
}

- (void)setLatitude:(NSString *)latitude{
    if([latitude isEqualToString:_latitude] == NO){
        [[self.undoManager prepareWithInvocationTarget:self] setLatitude:_latitude];
        _latitude = latitude;
    }
    [self updateHTML];
}

- (void)setZoomLevel:(NSInteger)zoomLevel{
    if(_zoomLevel != zoomLevel){
        [[self.undoManager prepareWithInvocationTarget:self] setZoomLevel:_zoomLevel];
        _zoomLevel = zoomLevel;
    }
    [self updateHTML];
}

- (void)setPanControl:(BOOL)panControl{
    if(_panControl != panControl){
        [[self.undoManager prepareWithInvocationTarget:self] setPanControl:_panControl];
        _panControl = panControl;
    }
    [self updateHTML];
}

- (void)setZoomControl:(BOOL)zoomControl{
    if(_zoomControl != zoomControl){
        [[self.undoManager prepareWithInvocationTarget:self] setZoomControl:_zoomControl];
        _zoomControl = zoomControl;
    }
    [self updateHTML];
}

- (void)setEnableMarkerIcon:(BOOL)enableMarkerIcon{
    if(_enableMarkerIcon != enableMarkerIcon){
        [[self.undoManager prepareWithInvocationTarget:self] setEnableMarkerIcon:_enableMarkerIcon];
        _enableMarkerIcon = enableMarkerIcon;
    }
    [self updateHTML];
}

- (void)setMarkerIconName:(NSString *)markerIconName{
    if([_markerIconName isEqualToString:markerIconName]){
        return;
    }
    
    [[self.undoManager prepareWithInvocationTarget:self] setMarkerIconName:_markerIconName];
    _markerIconName = markerIconName;
    [self updateHTML];
}

- (void)setMarkerTitle:(NSString *)markerTitle{
    if([_markerTitle isEqualToString:markerTitle]){
        return;
    }
    
    [[self.undoManager prepareWithInvocationTarget:self] setMarkerTitle:_markerTitle];
    _markerTitle = markerTitle;
    [self updateHTML];
}


#pragma mark - size
- (void)increaseSize:(NSSize)size withParentSize:(NSSize)parentSize{
    [super increaseSize:size withParentSize:parentSize];
    [self updateHTML];
}

#pragma mark - color theme
- (void)setThemeType:(IUGoogleMapThemeType)themeType{
    if(_themeType != themeType){
        [[self.undoManager prepareWithInvocationTarget:self] setThemeType:_themeType];
        _themeType = themeType;
        [self updateHTML];
    }
}
- (NSString *)currentThemeStyle{
    NSString *theme;
    switch (_themeType) {
        case IUGoogleMapThemeTypeDefault:
            theme = @"";
            break;
        case IUGoogleMapThemeTypeBlueGray:
            theme = [self styleWithIdentifier:@"bluegray"];
            break;
        case IUGoogleMapThemeTypeGreen:
            theme = [self styleWithIdentifier:@"green"];
            break;
        case IUGoogleMapThemeTypePaleDawn:
            theme = [self styleWithIdentifier:@"paledawn"];
            break;
        case IUGoogleMapThemeTypeSubtleGrayscale:
            theme = [self styleWithIdentifier:@"subtlegrayscale"];
            break;
        default:
            break;
    }
    return theme;
}


- (NSString *)innerCurrentThemeStyle{
    
    if(_themeType != 0){
        NSString *staticStyle = [self.delegate callWebScriptMethod:@"getGoogleMapStaticStyle" withArguments:@[@(_themeType-1)]];
        
        if(staticStyle){
            return [@"&" stringByAppendingString:staticStyle];
        }
    }
    return @"";
}

- (NSString *)styleWithIdentifier:(NSString *)identifier{
    NSString *googlemapjsPath = [[NSBundle mainBundle] pathForResource:@"iugooglemap_theme" ofType:@"js"];
    NSString *themejsStr = [NSString stringWithContentsOfFile:googlemapjsPath encoding:NSUTF8StringEncoding error:nil];;
    NSString *startString = [NSString stringWithFormat:@"//%@-start", identifier];
    NSString *endString = [NSString stringWithFormat:@"//%@-end", identifier];
    
    NSRange start =[themejsStr rangeOfString:startString];
    NSRange end =[themejsStr rangeOfString:endString];
    NSRange addRange = NSMakeRange(start.location+startString.length, end.location - start.location - startString.length);
    return [[themejsStr substringWithRange:addRange] stringByTrim];
}


#pragma mark - should
- (BOOL)canAddIUByUserInput{
    return NO;
}
@end
