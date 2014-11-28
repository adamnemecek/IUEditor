//
//  JDCoder+IUEditor_Test.m
//  IUEditor
//
//  Created by Joodong Yang on 2014. 10. 27..
//  Copyright (c) 2014년 JDLab. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>
#import "IUBox.h"
#import "IUBoxes.h"

@interface IUBoxCoder_Test : XCTestCase

@end

@implementation IUBoxCoder_Test{
    IUBox *parentBox;
    IUBox *childBox1;
    IUBox *childBox2;
}

- (void)setUp {
    [super setUp];
    NSLog(@"test");
    parentBox = [[IUBox alloc] initWithPreset];
    parentBox.htmlID = @"parentBox";
    
    childBox1 = [[IUBox alloc] initWithPreset];
    childBox1.htmlID = @"ChildBox1";
    
    childBox2 = [[IUBox alloc] initWithPreset];
    childBox2.htmlID = @"ChildBox2";
    
    [parentBox addIU:childBox1 error:nil];
    [parentBox addIU:childBox2 error:nil];
    
    childBox1.link = childBox2;
    childBox2.link = childBox1;
    
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


- (void)test1_IUBoxEncoding1{
    // This is an example of a functional test case.
    IUBox *parent = [[IUBox alloc] initWithPreset];
    parent.htmlID = @"parent";

    IUBox *oneBox = [[IUBox alloc] initWithPreset];
    oneBox.htmlID = @"oneBox";

    [parent addIU:oneBox error:nil];
    
    IUBox *second = [[IUBox alloc] initWithPreset];
    [parent addIU:second error:nil];
    
    oneBox.link = second;
    
    JDCoder *coder = [[JDCoder alloc] init];
    [coder encodeRootObject:parent];
    
    
    IUBox *resultBox = [coder decodeRootObject];
    
    IUBox *decodeOneBox, *decodeSecond;
    for(IUBox *box in resultBox.children){
        if([box.htmlID isEqualToString:@"oneBox"]){
            decodeOneBox = box;
        }
        else{
            decodeSecond = box;
        }
    }
    
    XCTAssert([resultBox.htmlID isEqualToString:@"parent"], @"Pass");
    XCTAssertEqual(decodeOneBox.link, decodeSecond);

}



- (void)test2_children{
    JDCoder *coder = [[JDCoder alloc] init];
    [coder encodeRootObject:parentBox];
    
    IUBox *resultBox = [coder decodeRootObject];
    IUBox *resultChildBox1 = [[resultBox children] objectAtIndex:0];
    
    XCTAssert([resultChildBox1.htmlID isEqualToString:@"ChildBox1"], @"Pass");
    XCTAssert([resultChildBox1.parent.htmlID isEqualToString:@"parentBox"], @"Pass");
}

- (void)test3_selector{
    JDCoder *coder = [[JDCoder alloc] init];
    [coder encodeRootObject:parentBox];
    
    IUBox *resultBox = [coder decodeRootObject];
    IUBox *resultChildBox1 = [[resultBox children] objectAtIndex:0];
    IUBox *resultChildBox2 = [[resultBox children] objectAtIndex:1];
    
    XCTAssert(resultChildBox1, @"Pass");
    XCTAssert(resultChildBox1.link == resultChildBox2, @"Pass");
    XCTAssert(resultChildBox2.link == resultChildBox1, @"Pass");
}

- (void)test4_IUPage{
    IUClass *headerClass = [[IUClass alloc] initWithPreset:IUClassPresetTypeHeader];
    IUHeader *header = [[IUHeader alloc] initWithPreset:headerClass];
    IUPage *page = [[IUPage alloc] initWithPresetWithLayout:IUPageLayoutDefault header:header footer:nil sidebar:nil];
    IUPageContent *pageContent = page.pageContent;
    IUText *titleBox = (IUText *)pageContent.children[0];
    titleBox.defaultPropertyStorage.innerHTML = @"hihi";
    
    JDCoder *coder = [[JDCoder alloc] init];
    [coder encodeRootObject:page];
    
    
    
    IUPage *decodePage = [coder decodeRootObject];
    IUPageContent *decodePageContent = decodePage.pageContent;
    IUText *decodeTitleBox = (IUText *)decodePageContent.children[0];

    
    XCTAssertEqual(decodePage.layout, IUPageLayoutDefault);
    XCTAssertEqual(decodeTitleBox.defaultPropertyStorage.innerHTML, @"hihi");

}

- (void)test5_IUClass{
    IUClass *iu = [[IUClass alloc] initWithPreset];
    IUImport *import = [[IUImport alloc] initWithPreset:iu];
    
    JDCoder *coder = [[JDCoder alloc] init];
    [coder encodeRootObject:iu];
    
    IUClass *decodeIU = [coder decodeRootObject];
    XCTAssertEqual(decodeIU.references.count, 1);

}

- (void)test6_IUHTML{
    IUHTML *iu = [[IUHTML alloc] initWithPreset];
    iu.innerHTML = @"<p>abc</p>";
    
    JDCoder *coder = [[JDCoder alloc] init];
    [coder encodeRootObject:iu];
    
    IUHTML *decodeIU = [coder decodeRootObject];
    XCTAssertEqual(decodeIU.innerHTML, @"<p>abc</p>");
}

- (void)test7_IUImage{
    IUImage *iu = [[IUImage alloc] initWithPreset];
    iu.imageName = @"a.jpg";
    
    JDCoder *coder = [[JDCoder alloc] init];
    [coder encodeRootObject:iu];
    
    IUImage *decodeIU = [coder decodeRootObject];
    XCTAssertEqual(decodeIU.imageName,@"a.jpg");
}

- (void)test8_IUMovie{
    IUMovie *iu = [[IUMovie alloc] initWithPreset];
    iu.videoPath = @"a.mp4";
    
    JDCoder *coder = [[JDCoder alloc] init];
    [coder encodeRootObject:iu];
    
    IUMovie *decodeIU = [coder decodeRootObject];
    XCTAssertEqual(decodeIU.videoPath,@"a.mp4");
}

- (void)test9_IUText{
    IUText *iu = [[IUText alloc] initWithPreset];
    iu.textType = IUTextTypeH1;
    
    JDCoder *coder = [[JDCoder alloc] init];
    [coder encodeRootObject:iu];
    
    IUText *decodeIU = [coder decodeRootObject];
    XCTAssertEqual(decodeIU.textType, IUTextTypeH1);
}

- (void)test10_IUCarousel{
    IUCarousel *iu = [[IUCarousel alloc] initWithPreset];
    iu.timer = 4;
    
    JDCoder *coder = [[JDCoder alloc] init];
    [coder encodeRootObject:iu];
    
    IUCarousel *decodeIU = [coder decodeRootObject];
    XCTAssertEqual(decodeIU.timer, 4);
    //default carousel item count = 3 (check children decode)
    XCTAssertEqual(decodeIU.count, 3);
}

- (void)test11_IUCollection{
    IUCollection *iu = [[IUCollection alloc] initWithPreset];
    iu.collectionVariable = @"test";
    
    JDCoder *coder = [[JDCoder alloc] init];
    [coder encodeRootObject:iu];
    
    IUCollection *decodeIU = [coder decodeRootObject];
    XCTAssertEqual(decodeIU.collectionVariable, @"test");
}


- (void)test12_IUCollectionView{
    
    IUBox *parent = [[IUBox alloc] initWithPreset];
    
    IUCollection *iu = [[IUCollection alloc] initWithPreset];
    iu.collectionVariable = @"test";
    IUCollectionView *view = [[IUCollectionView alloc] initWithPreset];
    view.collection = iu;
    
    [parent addIU:iu error:nil];
    [parent addIU:view error:nil];
    
    JDCoder *coder = [[JDCoder alloc] init];
    [coder encodeRootObject:parent];
    
    IUBox *decodeIU = [coder decodeRootObject];
    IUCollectionView *decodedView;
    for(IUBox *iu in decodeIU.children){
        if([iu isKindOfClass:[IUCollectionView class]]){
            decodedView = (IUCollectionView *)iu;
        }
            
    }
    XCTAssert(decodedView);
    XCTAssertEqual(decodedView.collection.collectionVariable, @"test");
}

- (void)test13_IUFBLike{
    IUFBLike *iu = [[IUFBLike alloc] initWithPreset];
    iu.likePage = @"test";
    
    JDCoder *coder = [[JDCoder alloc] init];
    [coder encodeRootObject:iu];
    
    IUFBLike *decodeIU = [coder decodeRootObject];
    XCTAssertEqual(decodeIU.likePage, @"test");
}

- (void)test14_IUtransition{
    IUTransition *iu = [[IUTransition alloc] initWithPreset];
    
    JDCoder *coder = [[JDCoder alloc] init];
    [coder encodeRootObject:iu];
    
    IUTransition *decodeIU = [coder decodeRootObject];
    XCTAssertEqual(decodeIU.children.count, 2);
}
@end
