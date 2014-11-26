//
//  WPMenu.m
//  IUEditor
//
//

#import "WPMenu.h"

@implementation WPMenu

#pragma mark - class attributes

+ (NSImage *)classImage{
    return [NSImage imageNamed:@"wp_menu"];
}

+ (NSImage *)navigationImage{
    return [NSImage imageNamed:@"stack_wpmenu"];
}

+ (IUWidgetType)widgetType{
    return IUWidgetTypeWP;
}


#pragma mark - initialize

- (id)initWithPreset{
    self = [super initWithPreset];
    if(self){
        [self.undoManager disableUndoRegistration];
        
        //property
        self.itemCount = 4;
        self.leftRightPadding = 16;
        self.align = IUAlignLeft;
        
        //css
        self.enableHCenter = YES;
        self.defaultPositionStorage.y = @(160);
        self.defaultStyleStorage.width = @(800);
        self.defaultStyleStorage.height = @(40);
        
        self.defaultStyleStorage.bgColor = nil;
        
        //font
        self.defaultStyleStorage.fontSize = @(12);
        self.defaultStyleStorage.fontLineHeight = @(1.0);
        self.defaultStyleStorage.fontAlign = @(IUAlignCenter);
        self.defaultStyleStorage.fontName = @"Roboto";
        self.defaultStyleStorage.fontColor = [NSColor rgbColorRed:0 green:120 blue:220 alpha:1];
        
        //border
        self.defaultStyleStorage.topBorderColor = [NSColor rgbColorRed:204 green:204 blue:204 alpha:1];
        self.defaultStyleStorage.bottomBorderColor = [NSColor rgbColorRed:204 green:204 blue:204 alpha:1];
        self.defaultStyleStorage.topBorderWidth = @(1);
        self.defaultStyleStorage.bottomBorderWidth = @(1);
        
        [self.undoManager enableUndoRegistration];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [super encodeWithCoder:aCoder];
    [aCoder encodeFromObject:self withProperties:[[WPMenu class] properties]];
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];

    [aDecoder decodeToObject:self withProperties:[[WPMenu class] properties]];
    
    return self;
}

#pragma mark - property

- (void)setItemCount:(NSInteger)itemCount{
    if(_itemCount != itemCount){
        [[self.undoManager prepareWithInvocationTarget:self] setItemCount:_itemCount];

        _itemCount = itemCount;
        [self updateHTML];
    }
}

- (void)setAlign:(IUAlign)align{
    if(_align != align){
        
        [(WPMenu *)[self.undoManager prepareWithInvocationTarget:self] setAlign:_align];
        _align = align;
        [self updateCSS];
    }
}

- (void)setLeftRightPadding:(NSInteger)leftRightPadding{
    if(_leftRightPadding != leftRightPadding){
        [[self.undoManager prepareWithInvocationTarget:self] setLeftRightPadding:_leftRightPadding];
        _leftRightPadding = leftRightPadding;
        [self updateCSSWithIdentifiers:@[self.itemIdetnfier]];
    }
}

#pragma mark - css
- (NSString *)containerIdentifier{
    return [self.cssIdentifier stringByAppendingString:@" > div > ul"];
}
- (NSString *)itemIdetnfier{
    return [self.cssIdentifier stringByAppendingString:@" > div > ul > li"];
}

#pragma mark - default

- (NSString*)sampleInnerHTML{
    NSMutableString *returnText = [NSMutableString stringWithString:@"<div class='menu-samplemenu-container'><ul id='menu-samplemenu'>\
                                   <li id='menu-item-01' class='menu-item'>JDLab blog</li>"];
    if (_itemCount > 1) {
        [returnText appendString:@"<li id='menu-item-02' class='menu-item'>Rosa</li>"];
    }
    if (_itemCount > 2) {
        [returnText appendString:@"<li id='menu-item-03' class='menu-item'>Eschscholzia Californica</li>"];
    }
    if (_itemCount > 3) {
        [returnText appendString:@"<li id='menu-item-04' class='menu-item'>Camellia japonica</li>"];
    }
    if (_itemCount > 4) {
        [returnText appendString:@"<li id='menu-item-05' class='menu-item'>Malus</li>"];
    }
    if (_itemCount > 5) {
        [returnText appendString:@"<li id='menu-item-06' class='menu-item'>Kalmia latifolia</li>"];
    }
    if (_itemCount > 6) {
        [returnText appendString:@"<li id='menu-item-07' class='menu-item'>Pinus strobus</li>"];
    }
    [returnText appendString:@"</ul></div>"];
    return [returnText copy];
}

-(BOOL)canAddIUByUserInput{
    return NO;
}
-(NSString*)code{
    return @"<? wp_nav_menu() ?>";
}

@end
