// Copyright (c) 2014 KinWah
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import <dlfcn.h>

#import <XCTest/XCTest.h>
#import <OCMock.h>
#define EXP_SHORTHAND
#import <Expecta.h>
#import "RefactoringLogic.h"
#import "DVTKit.h"

@interface RefactoringLogicTests : XCTestCase
{
    id dvtTextView;
    RefactoringLogic *rlogic;
    NSString *multilines;
    Class dvtSourceTextViewClass;
    Class dvtSourceTextStorageClass;
    
    NSString *aClass;
}
@end

@implementation RefactoringLogicTests

// This loading the framework and get the class is to allow us to mock the class
- (void)loadDVTFrameworkAndClass
{
    /**
     * Another way of loading the private framework
     * NSBundle *dvtF = [NSBundle bundleWithPath:@"/Applications/Xcode.app/Contents/SharedFrameworks/DVTFoundation.framework"];
     * [dvtF load];
     * NSBundle *dvt = [NSBundle bundleWithPath:@"/Applications/Xcode.app/Contents/SharedFrameworks/DVTKit.framework"];
     * [dvt load];
     **/
    
    void* handleDVTFoundation = dlopen("/Applications/Xcode.app/Contents/SharedFrameworks/DVTFoundation.framework/Versions/Current/DVTFoundation", RTLD_NOW);
    void* handleDVTKit = dlopen("/Applications/Xcode.app/Contents/SharedFrameworks/DVTKit.framework/Versions/Current/DVTKit", RTLD_NOW);
    dvtSourceTextViewClass = NSClassFromString(@"DVTSourceTextView");
    dvtSourceTextStorageClass = NSClassFromString(@"DVTSourceTextStorage");
    dlclose(handleDVTFoundation);
    dlclose(handleDVTKit);
}

- (void)setUp
{
    [super setUp];
    
    [self loadDVTFrameworkAndClass];
    
    dvtTextView = [OCMockObject mockForClass:dvtSourceTextViewClass];
    rlogic = [[RefactoringLogic alloc] init];
    
    
    multilines = [NSString stringWithContentsOfFile:getTestFile(@"FileForLineManipuationTest.text") encoding:NSUTF8StringEncoding error:NULL];
    aClass = [NSString stringWithContentsOfFile:getTestFile(@"ClassForRefactoring.m") encoding:NSUTF8StringEncoding error:NULL];
    
    [[[dvtTextView stub] andReturn:multilines] string];
}

NSString* getTestFile(NSString* testFile)
{
    return [[@__FILE__ stringByDeletingLastPathComponent] stringByAppendingPathComponent:testFile];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testDeleteSelectedLine
{
    [[dvtTextView expect] setSelectedRange:NSMakeRange(0, 67)];
    [[dvtTextView expect] deleteToEndOfLine:nil];
    [rlogic deleteLineWithRange:NSMakeRange(0, 0) inTextView:dvtTextView];
    [dvtTextView verify];
}

- (void)testDuplicateSelectedLine
{
    [[dvtTextView expect] setSelectedRange:NSMakeRange(67, 0)];
    [[dvtTextView expect] setSelectedRange:NSMakeRange(67, 67)]; // to highlight the duplicated line
    [[dvtTextView expect] insertText:OCMOCK_ANY];
    [rlogic duplicateLineWithRange:NSMakeRange(0, 0) inTextView:dvtTextView];
    [dvtTextView verify];
}

- (void)testMoveSelectedLineDown
{
    [[dvtTextView expect] setSelectedRange:NSMakeRange(0, 0)];
    [[dvtTextView expect] moveCurrentLineDown:[OCMArg isNil]];
    [[[dvtTextView expect] andReturnValue:[NSValue valueWithRange:NSMakeRange(22, 0)]] selectedRange];
    [[dvtTextView expect] setSelectedRange:NSMakeRange(0, 67)];
    [rlogic moveDownLineWithRange:NSMakeRange(0, 0) inTextView:dvtTextView];
    [dvtTextView verify];
}

- (void)testMoveSelectedLineUp
{
    [[dvtTextView expect] setSelectedRange:NSMakeRange(0, 0)];
    [[dvtTextView expect] moveCurrentLineUp:[OCMArg isNil]];
    [[[dvtTextView expect] andReturnValue:[NSValue valueWithRange:NSMakeRange(22, 0)]] selectedRange];
    [[dvtTextView expect] setSelectedRange:NSMakeRange(0, 67)];
    [rlogic moveUpLineWithRange:NSMakeRange(0, 0) inTextView:dvtTextView];
    [dvtTextView verify];
}
@end
