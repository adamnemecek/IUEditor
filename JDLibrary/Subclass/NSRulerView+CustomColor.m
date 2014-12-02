//
//  NSRulerView+CustomColor.m
//  IUEditor
//
//  Created by seungmi on 2014. 11. 11..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

/*
 this code from gnustep project
 http://wwwmain.gnustep.org/index.html
 
 ///////////////////////////////
 
 NSRulerView.m
 
 Copyright (C) 2002 Free Software Foundation, Inc.
 
 Author: Diego Kreutz (kreutz@inf.ufsm.br)
 Date: January 2002
 
 This file is part of the GNUstep GUI Library.
 
 This library is free software; you can redistribute it and/or
 modify it under the terms of the GNU Lesser General Public
 License as published by the Free Software Foundation; either
 version 2 of the License, or (at your option) any later version.
 
 This library is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.	 See the GNU
 Lesser General Public License for more details.
 
 You should have received a copy of the GNU Lesser General Public
 License along with this library; see the file COPYING.LIB.
 If not, see <http://www.gnu.org/licenses/> or write to the
 Free Software Foundation, 51 Franklin Street, Fifth Floor,
 Boston, MA 02110-1301, USA.
 

 */
#import "NSRulerView+CustomColor.h"

#define MIN_LABEL_DISTANCE 40
#define MIN_MARK_DISTANCE 5

#define MARK_SIZE 4
#define MID_MARK_SIZE 4
#define BIG_MARK_SIZE 6
#define LABEL_MARK_SIZE 11

#define RULER_THICKNESS 16
#define MARKER_THICKNESS 15

#define DRAW_HASH_MARK(path, size)			\
do {					\
if (self.orientation == NSHorizontalRuler)\
{					\
[path relativeLineToPoint: NSMakePoint(0, size)];	\
}					\
else					\
{					\
[path relativeLineToPoint: NSMakePoint(size, 0)];	\
}					\
} while (0)

@interface GSRulerUnit : NSObject
{
    NSString *_unitName;
    NSString *_abbreviation;
    CGFloat   _conversionFactor;
    NSArray  *_stepUpCycle;
    NSArray  *_stepDownCycle;
}

+ (GSRulerUnit *) unitWithName: (NSString *)uName
                  abbreviation: (NSString *)abbrev
  unitToPointsConversionFactor: (CGFloat)factor
                   stepUpCycle: (NSArray *)upCycle
                 stepDownCycle: (NSArray *)downCycle;
- (id) initWithUnitName: (NSString *)uName
           abbreviation: (NSString *)abbrev
unitToPointsConversionFactor: (CGFloat)factor
            stepUpCycle: (NSArray *)upCycle
          stepDownCycle: (NSArray *)downCycle;
- (NSString *) unitName;
- (NSString *) abbreviation;
- (CGFloat) conversionFactor;
- (NSArray *) stepUpCycle;
- (NSArray *) stepDownCycle;

@end

@implementation GSRulerUnit

+ (GSRulerUnit *) unitWithName: (NSString *)uName
                  abbreviation: (NSString *)abbrev
  unitToPointsConversionFactor: (CGFloat)factor
                   stepUpCycle: (NSArray *)upCycle
                 stepDownCycle: (NSArray *)downCycle
{
    return [[self alloc] initWithUnitName: uName
                              abbreviation: abbrev
              unitToPointsConversionFactor: factor
                               stepUpCycle: upCycle
                             stepDownCycle: downCycle];
}

- (id) initWithUnitName: (NSString *)uName
           abbreviation: (NSString *)abbrev
unitToPointsConversionFactor: (CGFloat)factor
            stepUpCycle: (NSArray *)upCycle
          stepDownCycle: (NSArray *)downCycle
{
    self = [super init];
    if (self != nil)
    {
        _unitName = uName;
        _abbreviation = abbrev;
        _conversionFactor = factor;
        _stepUpCycle = [upCycle copy];
        _stepDownCycle = [downCycle copy];
    }
    
    return self;
}

- (NSString *) unitName
{
    return _unitName;
}

- (NSString *) abbreviation
{
    return _abbreviation;
}

- (CGFloat) conversionFactor
{
    return _conversionFactor;
}

- (NSArray *) stepUpCycle
{
    return _stepUpCycle;
}

- (NSArray *) stepDownCycle
{
    return _stepDownCycle;
}

@end


@implementation NSRulerView_CustomColor{
    
    GSRulerUnit *_unit;

    
    /* Cached values. It's a little expensive to calculate them and they
     * change only when the unit or the originOffset is changed or when
     * clientView changes it's size or zooming factor.  This cache is
     * invalidated by -invalidateHashMarks method.  */
    BOOL  _cacheIsValid;
    float _markDistance;
    float _labelDistance;
    int   _marksToBigMark;
    int   _marksToMidMark;
    int   _marksToLabel;
    float _UNUSED;
    float _unitToRuler;
    NSString *_labelFormat;
}


/*
 * Class variables
 */
static NSMutableDictionary *units = nil;


/*
 * Class methods
 */
#if 0
+ (void) initialize
{
    if (self == [NSRulerView_CustomColor class])
    {
        NSArray *array05;
        NSArray *array052;
        NSArray *array2;
        NSArray *array10;
        
        [self setVersion: 1];
        
        units = [[NSMutableDictionary alloc] init];
        array05 = [NSArray arrayWithObject: [NSNumber numberWithFloat: 0.5]];
        array052 = [NSArray arrayWithObjects: [NSNumber numberWithFloat: 0.5],
                    [NSNumber numberWithFloat: 0.2], nil];
        array2 = [NSArray arrayWithObject: [NSNumber numberWithFloat: 2.0]];
        array10 = [NSArray arrayWithObject: [NSNumber numberWithFloat: 10.0]];
        [self registerUnitWithName: @"Inches"
                      abbreviation: @"in"
      unitToPointsConversionFactor: 72.0
                       stepUpCycle: array2
                     stepDownCycle: array05];
        [self registerUnitWithName: @"Centimeters"
                      abbreviation: @"cm"
      unitToPointsConversionFactor: 28.35
                       stepUpCycle: array2
                     stepDownCycle: array052];
        [self registerUnitWithName: @"Points"
                      abbreviation: @"pt"
      unitToPointsConversionFactor: 1.0
                       stepUpCycle: array10
                     stepDownCycle: array05];
        [self registerUnitWithName: @"Picas"
                      abbreviation: @"pc"
      unitToPointsConversionFactor: 12.0
                       stepUpCycle: array2
                     stepDownCycle: array05];
        

        NSArray *array055 = [NSArray arrayWithObjects:[NSNumber numberWithDouble:0.5],
                              [NSNumber numberWithDouble:0.5], nil];
        [self registerUnitWithName:@"Pixel"
                             abbreviation:@"px"
             unitToPointsConversionFactor:1
                              stepUpCycle:array10
                     stepDownCycle:array055];

    }
}

+ (void) registerUnitWithName: (NSString *)uName
                 abbreviation: (NSString *)abbreviation
 unitToPointsConversionFactor: (CGFloat)conversionFactor
                  stepUpCycle: (NSArray *)stepUpCycle
                stepDownCycle: (NSArray *)stepDownCycle
{
    GSRulerUnit *u = [GSRulerUnit unitWithName: uName
                                  abbreviation: abbreviation
                  unitToPointsConversionFactor: conversionFactor
                                   stepUpCycle: stepUpCycle
                                 stepDownCycle: stepDownCycle];
    [units setObject: u forKey: uName];
}


#pragma mark -

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    [[NSColor colorWithDeviceRed:207.0/255.0 green:108.0/255.0 blue:
      130.0/255.0 alpha:0.3] set];
    [NSBezierPath fillRect:dirtyRect];

    [self drawHashMarksAndLabelsInRect:dirtyRect];
    [self drawMarkersInRect:dirtyRect];
}

- (void)drawHashMarksAndLabelsInRect:(NSRect)aRect{
    [super drawHashMarksAndLabelsInRect:aRect];
    
    
    NSView *docView;
    NSRect docBounds;
    NSRect baselineRect;
    NSRect visibleBaselineRect;
    CGFloat firstBaselineLocation;
    CGFloat firstVisibleLocation;
    CGFloat lastVisibleLocation;
    int firstVisibleMark;
    int lastVisibleMark;
    int mark;
    int firstVisibleLabel;
    int lastVisibleLabel;
    int label;
    CGFloat baselineLocation = [self baselineLocation];
    NSPoint zeroPoint;
    CGFloat zeroLocation;
    NSBezierPath *path;
    NSFont *font = [NSFont systemFontOfSize: [NSFont smallSystemFontSize]];
    NSDictionary *attr = [[NSDictionary alloc]
                          initWithObjectsAndKeys:
                          font, NSFontAttributeName,
                          [NSColor greenColor], NSForegroundColorAttributeName,
                          nil];
    
    docView = [self.scrollView documentView];
    docBounds = [docView bounds];
    
    /* Calculate the location of 'zero' hash mark */
    // _originOffset is an offset from document bounds origin, in doc coords
    zeroPoint.x = docBounds.origin.x + self.originOffset;
    zeroPoint.y = docBounds.origin.y + self.originOffset;
    zeroPoint = [self convertPoint: zeroPoint fromView: docView];
    if (self.orientation == NSHorizontalRuler)
    {
        zeroLocation = zeroPoint.x;
    }
    else
    {
        zeroLocation = zeroPoint.y;
    }
    
    [self _verifyCachedValues];
    
    /* Calculate the base line (corresponds to the document bounds) */
    baselineRect = [self convertRect: docBounds  fromView: docView];
    if (self.orientation == NSHorizontalRuler)
    {
        baselineRect.origin.y = baselineLocation;
        baselineRect.size.height = 1;
        firstBaselineLocation = NSMinX(baselineRect);
        visibleBaselineRect = NSIntersectionRect(baselineRect, aRect);
        firstVisibleLocation = NSMinX(visibleBaselineRect);
        lastVisibleLocation = NSMaxX(visibleBaselineRect);
    }
    else
    {
        baselineRect.origin.x = baselineLocation;
        baselineRect.size.width = 1;
        firstBaselineLocation = NSMinY(baselineRect);
        visibleBaselineRect = NSIntersectionRect(baselineRect, aRect);
        firstVisibleLocation = NSMinY(visibleBaselineRect);
        lastVisibleLocation = NSMaxY(visibleBaselineRect);
    }
    /* draw the base line */
    [[NSColor blueColor] set];
    NSRectFill(visibleBaselineRect);
    
    /* draw hash marks */
    /*
    firstVisibleMark = ceil((firstVisibleLocation - zeroLocation)
                            / _markDistance);
    lastVisibleMark = floor((lastVisibleLocation - zeroLocation)
                            / _markDistance);
    path = [NSBezierPath new];
    
    for (mark = firstVisibleMark; mark <= lastVisibleMark; mark++)
    {
        CGFloat markLocation;
        
        markLocation = zeroLocation + mark * _markDistance;
        if (self.orientation == NSHorizontalRuler)
        {
            [path moveToPoint: NSMakePoint(markLocation, baselineLocation)];
        }
        else
        {
            [path moveToPoint: NSMakePoint(baselineLocation, markLocation)];
        }
        
        if ((mark % _marksToLabel) == 0)
        {
            DRAW_HASH_MARK(path, LABEL_MARK_SIZE);
        }
        else if ((mark % _marksToBigMark) == 0)
        {
            DRAW_HASH_MARK(path, BIG_MARK_SIZE);
        }
        else if ((mark % _marksToMidMark) == 0)
        {
            DRAW_HASH_MARK(path, MID_MARK_SIZE);
        }
        else
        {
            DRAW_HASH_MARK(path, MARK_SIZE);
        }
    }
    [path stroke];
     */
    
    /* draw labels */
    /* FIXME: shouldn't be using NSCell to draw labels? */
    firstVisibleLabel = floor((firstVisibleLocation - zeroLocation)
                              / (_marksToLabel * _markDistance));
    lastVisibleLabel = floor((lastVisibleLocation - zeroLocation)
                             / (_marksToLabel * _markDistance));
    /* firstVisibleLabel can be to the left of the visible ruler area.
     This is OK because just part of the label can be visible to the left
     when scrolling. However, it should not be drawn if outside of the
     baseline. */
    if (zeroLocation + firstVisibleLabel * _marksToLabel * _markDistance
        < firstBaselineLocation)
    {
        firstVisibleLabel++;
    }
    
    for (label = firstVisibleLabel; label <= lastVisibleLabel; label++)
    {
        CGFloat labelLocation = zeroLocation + label * _marksToLabel * _markDistance;
        // This has to be a float or we need to change the label format
        float labelValue = (labelLocation - zeroLocation) / _unitToRuler;
        NSString *labelString = [NSString stringWithFormat: _labelFormat, labelValue];
        NSSize size = [labelString sizeWithAttributes: attr];
        NSPoint labelPosition;
        
        if (self.orientation == NSHorizontalRuler)
        {
            labelPosition.x = labelLocation + 1;
            labelPosition.y = baselineLocation + LABEL_MARK_SIZE + 4 - size.height;
        }
        else
        {
            labelPosition.x = baselineLocation + self.ruleThickness - size.width;
            labelPosition.y = labelLocation + 1;
        }
        [labelString drawAtPoint: labelPosition withAttributes: attr];
    }
}



- (void) setMeasurementUnits: (NSString *)uName
{
    GSRulerUnit *newUnit;
    
    newUnit = [units objectForKey: uName];
    if (newUnit == nil)
    {
        [NSException raise: NSInvalidArgumentException
                    format: @"Unknown measurement unit %@", uName];
    }
    _unit =  newUnit;
    [self invalidateHashMarks];
}

- (NSString *) measurementUnits
{
    return [_unit unitName];
}

- (void) _verifyCachedValues
{
    if (! _cacheIsValid)
    {
        NSSize unitSize;
        CGFloat cf;
        int convIndex;
        
        /* calculate the size one unit in document view has in the ruler */
        cf = [_unit conversionFactor];
        unitSize = [self convertSize: NSMakeSize(cf, cf)
                            fromView: [self.scrollView documentView]];
        
        if (self.orientation == NSHorizontalRuler)
        {
            _unitToRuler = unitSize.width;
        }
        else
        {
            _unitToRuler = unitSize.height;
        }
        
        /* Calculate distance between marks.  */
        /* It must not be less than MIN_MARK_DISTANCE in ruler units
         * and must obey the current unit's step cycles.  */
        _markDistance = _unitToRuler;
        convIndex = 0;
        /* make sure it's smaller than MIN_MARK_DISTANCE */
        while ((_markDistance) > MIN_MARK_DISTANCE)
        {
            _markDistance /= [self _stepForIndex: convIndex];
            convIndex--;
        }
        /* find the first size that's not < MIN_MARK_DISTANCE */
        while ((_markDistance) < MIN_MARK_DISTANCE)
        {
            convIndex++;
            _markDistance *= [self _stepForIndex: convIndex];
        }
        
        /* calculate number of small marks in each bigger mark */
        _marksToMidMark = GSRoundTowardsInfinity([self _stepForIndex: convIndex + 1]);
        _marksToBigMark = _marksToMidMark
        * GSRoundTowardsInfinity([self _stepForIndex: convIndex + 2]);
        
        /* Calculate distance between labels.
         It must not be less than MIN_LABEL_DISTANCE. */
        _labelDistance = _markDistance;
        while (_labelDistance < MIN_LABEL_DISTANCE)
        {
            convIndex++;
            _labelDistance *= [self _stepForIndex: convIndex];
        }
        
        /* number of small marks between two labels */
        _marksToLabel = GSRoundTowardsInfinity(_labelDistance / _markDistance);
        
        /* format of labels */
        if (_labelDistance / _unitToRuler >= 1)
        {
            _labelFormat = @"%1.f";
        }
        else
        {
            /* smallest integral value not less than log10(1/labelDistInUnits) */
            int log = ceil(log10(1 / (_labelDistance / _unitToRuler)));
            NSString *string = [NSString stringWithFormat: @"%%.%df", (int)log];
            _labelFormat = string;
        }
        
        _cacheIsValid = YES;
    }
}

/**
 * Rounds to the nearest integer, and in the case of ties, round to the
 * larger integer. This is the recommended rounding function for rounding
 * graphics points.
 *
 * For example:
 * GSRoundTowardsInfinity(0.8) == 1.0
 * GSRoundTowardsInfinity(0.5) == 1.0
 * GSRoundTowardsInfinity(0.1) == 0.0
 * GSRoundTowardsInfinity(-2.5) == -2.0
 */
static inline CGFloat GSRoundTowardsInfinity(CGFloat x)
{
    return floor(x + 0.5);
}


- (float) _stepForIndex: (int)index
{
    int newindex;
    NSArray *stepCycle;
    
    if (index > 0)
    {
        stepCycle = [_unit stepUpCycle];
        newindex = (index - 1) % [stepCycle count];
        return [[stepCycle objectAtIndex: newindex] floatValue];
    }
    else
    {
        stepCycle = [_unit stepDownCycle];
        newindex = (-index) % [stepCycle count];
        return 1 / [[stepCycle objectAtIndex: newindex] floatValue];
    }
}
#endif



@end
