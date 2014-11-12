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

- (id)initWithProject:(id <IUProjectProtocol>)project options:(NSDictionary *)options{
    self = [super initWithProject:project options:options];
    [self.undoManager disableUndoRegistration];
    
    //property
    self.itemCount = 4;
    self.leftRightPadding = 16;
    self.align = IUAlignLeft;
    
    //css
    self.enableHCenter = YES;
    [self.css setValue:@(160) forTag:IUCSSTagPixelY forViewport:IUCSSDefaultViewPort];
    [self.css setValue:@(800) forTag:IUCSSTagPixelWidth forViewport:IUCSSDefaultViewPort];
    [self.css setValue:@(40) forTag:IUCSSTagPixelHeight forViewport:IUCSSDefaultViewPort];
    [self.css eradicateTag:IUCSSTagBGColor];
    
    //font
    [self.css setValue:@(12) forTag:IUCSSTagFontSize forViewport:IUCSSDefaultViewPort];
    [self.css setValue:@(1.0) forTag:IUCSSTagLineHeight forViewport:IUCSSDefaultViewPort];
    [self.css setValue:@(IUAlignCenter) forTag:IUCSSTagTextAlign forViewport:IUCSSDefaultViewPort];
    [self.css setValue:@"Roboto" forTag:IUCSSTagFontName forViewport:IUCSSDefaultViewPort];
    [self.css setValue:[NSColor rgbColorRed:0 green:120 blue:220 alpha:1] forTag:IUCSSTagFontColor forViewport:IUCSSDefaultViewPort];
    
    //border
    [self.css setValue:[NSColor rgbColorRed:204 green:204 blue:204 alpha:1] forTag:IUCSSTagBorderTopColor forViewport:IUCSSDefaultViewPort];
    [self.css setValue:[NSColor rgbColorRed:204 green:204 blue:204 alpha:1] forTag:IUCSSTagBorderBottomColor forViewport:IUCSSDefaultViewPort];
    [self.css setValue:@(1) forTag:IUCSSTagBorderTopWidth forViewport:IUCSSDefaultViewPort];
    [self.css setValue:@(1) forTag:IUCSSTagBorderBottomWidth forViewport:IUCSSDefaultViewPort];
    
    [self.undoManager enableUndoRegistration];
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
        
        [[self.undoManager prepareWithInvocationTarget:self] setAlign:_align];
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


-(BOOL)shouldCompileFontInfo{
    return YES;
}

-(BOOL)canAddIUByUserInput{
    return NO;
}
-(NSString*)code{
    return @"<? wp_nav_menu() ?>";
}

@end
