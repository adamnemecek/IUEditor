//
//  IUWebMovie.m
//  IUEditor
//
//  Created by ChoiSeungmi on 2014. 4. 16..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import "IUWebMovie.h"

@interface IUWebMovie()


@end

@implementation IUWebMovie{
}

#pragma mark - class attributes

+ (NSImage *)classImage{
    return [NSImage imageNamed:@"tool_webmovie"];
}

+ (NSImage *)navigationImage{
    return [NSImage imageNamed:@"stack_webmovie"];
}

+ (IUWidgetType)widgetType{
    return IUWidgetTypeSecondary;
}

#pragma mark - Initialize

- (id)initWithProject:(id <IUProjectProtocol>)project options:(NSDictionary *)options{
    self = [super initWithProject:project options:options];
    if(self){
        [self.undoManager disableUndoRegistration];

        _thumbnail = YES;
        _movieType = IUWebMovieTypeVimeo;
        _movieLink = @"http://vimeo.com/101677733";
        _playType = IUWebMoviePlayTypeNone;
        _enableLoop = YES;
        _thumbnailID = @"101677733";
        _thumbnailPath = @"http://i.vimeocdn.com/video/483513294_640.jpg";
        
        [self.css setValue:@(700) forTag:IUCSSTagPixelWidth forViewport:IUCSSDefaultViewPort];
        [self.css setValue:@(400) forTag:IUCSSTagPixelHeight forViewport:IUCSSDefaultViewPort];

        
        [self.undoManager enableUndoRegistration];
    }
    return self;
}
-(id)initWithCoder:(NSCoder *)aDecoder{
    self =  [super initWithCoder:aDecoder];
    if(self){
        [self.undoManager disableUndoRegistration];

        [aDecoder decodeToObject:self withProperties:[[IUWebMovie class] properties]];
        
        [self.undoManager enableUndoRegistration];
    }
    return self;
}
-(void)encodeWithCoder:(NSCoder *)aCoder{
    [super encodeWithCoder:aCoder];
    [aCoder encodeFromObject:self withProperties:[[IUWebMovie class] properties]];
    
}
- (id)copyWithZone:(NSZone *)zone{
    IUWebMovie *webMovie = [super copyWithZone:zone];
    [self.undoManager disableUndoRegistration];
    [_canvasVC disableUpdateAll:self];
    
    webMovie.thumbnail = self.thumbnail;
    webMovie.thumbnailID = [_thumbnailID copy];
    webMovie.thumbnailPath = [_thumbnailPath copy];
    
    webMovie.movieType = _movieType;
    webMovie.playType = _playType;
    webMovie.enableLoop = _enableLoop;
    webMovie.movieLink = [_movieLink copy];
    webMovie.movieID = [_movieID copy];
    
    [_canvasVC enableUpdateAll:self];
    [self.undoManager enableUndoRegistration];
    return webMovie;
}

- (void)connectWithEditor{
    [super connectWithEditor];
    [self classifyWebMovieSource];
}

#pragma mark - should setting
- (BOOL)canAddIUByUserInput{
    return NO;
}


#pragma mark - property

- (void)setMovieLink:(NSString *)movieLink{
    if([_movieLink isEqualToString:movieLink]){
        return;
    }
    [[self.undoManager prepareWithInvocationTarget:self] setMovieLink:_movieLink];
    _movieLink = movieLink;
    if(self.isConnectedWithEditor){
        [self classifyWebMovieSource];
    }
}

- (void)setPlayType:(IUWebMoviePlayType)playType{
    if(playType != _playType){
        [[self.undoManager prepareWithInvocationTarget:self] setPlayType:_playType];
        _playType = playType;
    }
    [self classifyWebMovieSource];
}

- (void)setEnableLoop:(BOOL)enableLoop{
    if(_enableLoop != enableLoop){
        [[self.undoManager prepareWithInvocationTarget:self] setEnableLoop:_enableLoop];
        _enableLoop = enableLoop;
    }
    [self classifyWebMovieSource];
}

#pragma mark - webmovie
- (void)classifyWebMovieSource{
    
    //vimeo
    if([_movieLink containsString:@"vimeo"]){
        //http://vimeo.com/channels/staffpicks/79426902
        //<iframe src="//player.vimeo.com/video/VIDEO_ID" width="WIDTH" height="HEIGHT" frameborder="0" webkitallowfullscreen mozallowfullscreen allowfullscreen></iframe>

        _movieID = [_movieLink lastPathComponent];
        
        if([_movieID rangeOfCharacterFromSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]].length > 0){
            //not found
            _movieID = nil;
            _movieType = IUWebMovieTypeUnknown;
        }
        else{
            _movieType = IUWebMovieTypeVimeo;
        }
    }
    else if([_movieLink containsString:@"youtu.be"]){
        //http://youtu.be/Z0uknBJc8NI
        //http://youtu.be/EM06XSULpgc?list=RDEM06XSULpgc
        //<iframe width="560" height="315" src="//www.youtube.com/embed/Sl-BDzmORX0?list=RDHCzBybJtuKWjA" frameborder="0" allowfullscreen></iframe>
        if([_movieLink lastPathComponent].length > 10){
            _movieID = [[_movieLink lastPathComponent] substringWithRange:NSMakeRange(0, 11)];
            _movieType = IUWebMovieTypeYoutube;
        }
        else{
            //not found
            _movieID = nil;
            _movieType = IUWebMovieTypeUnknown;
        }

    }
    else{
        _movieType = IUWebMovieTypeUnknown;
        return;
    }
    
    if(_movieType != IUWebMovieTypeUnknown && _movieID && _movieID.length > 0){
        [self updateThumbnailOfWebMovie];
    }
}


-(void)updateThumbnailOfWebMovie{
    if([_thumbnailID isEqualToString:_movieID] && _thumbnail){
        return;
    }
    else{
        _thumbnail = NO;
    }

    if (_movieType == IUWebMovieTypeYoutube){
        _thumbnailID = _movieID;
        //http://stackoverflow.com/questions/2068344/how-do-i-get-a-youtube-video-thumbnail-from-the-youtube-api
        NSString *youtubePath = [NSString stringWithFormat:@"http://img.youtube.com/vi/%@/sdddefault.jpg", _movieID];
        NSInteger width = [[_canvasVC callWebScriptMethod:@"getImageWidth" withArguments:@[youtubePath]] integerValue];
        if(width < 130 ){
            youtubePath = [NSString stringWithFormat:@"http://img.youtube.com/vi/%@/0.jpg", _movieID];
        }
        
        _thumbnailPath = youtubePath;
        _thumbnail = YES;
        
        [self updateHTML];
    }
    // 2. vimeo
    else if (_movieType == IUWebMovieTypeVimeo){
        _thumbnailID = _movieID;
        NSURL *filePath =[NSURL URLWithString:[NSString stringWithFormat:@"http://www.vimeo.com/api/v2/video/%@.json", _movieID]];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) , ^{
            NSData* data = [NSData dataWithContentsOfURL:
                            filePath];
            [self performSelectorOnMainThread:@selector(fetchedVimeoData:)
                                   withObject:data waitUntilDone:YES];
        });
        
    }
}

- (void)fetchedVimeoData:(NSData *)responseData {

    //data 연결 등의 문제로 empty일때
    if(responseData == nil) return;
    NSError* error;
    
    //parse out the json data
    NSArray* json = [NSJSONSerialization
                     JSONObjectWithData:responseData //1
                     
                     options:kNilOptions
                     error:&error];
    
    NSDictionary* vimeoDict = json[0];
    _thumbnailPath = [vimeoDict objectForKey:@"thumbnail_large"]; //2
    _thumbnail = YES;
    
    [self updateHTML];
    
}

@end
