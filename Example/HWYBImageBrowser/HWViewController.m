//
//  HWViewController.m
//  HWYBImageBrowser
//
//  Created by 571100944@qq.com on 01/15/2019.
//  Copyright (c) 2019 571100944@qq.com. All rights reserved.
//

#import "HWViewController.h"
#import <HWYBImageBrowser/YBImageBrowser.h>

@interface HWViewController ()<YBImageBrowserDelegate,YBImageBrowserDataSource>

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (nonatomic, strong) NSMutableArray *previewArray;

@end

@implementation HWViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImage)];
    [self.view addGestureRecognizer:tap];
    
    
}

- (void)tapImage {
    
    NSArray *imgURL = @[@"https://img1.haowmc.com/hwmc/test/material/2019011487058684.jpg?x-oss-process=style/q80",
                        @"https://img1.haowmc.com/hwmc/test/material/2018112678115899.jpg?x-oss-process=style/q80",
                        @"https://img1.haowmc.com/hwmc/test/material/2018111270720030.jpg?x-oss-process=style/q80",
                        @"https://img1.haowmc.com/hwmc/test/material/2018112314494622.jpg?x-oss-process=style/q80",
                        @"https://img1.haowmc.com/hwmc/test/material/2018112467781339.jpg?x-oss-process=style/q80",
                        @"https://img1.haowmc.com/hwmc/test/material/2018112431876854.jpg?x-oss-process=style/q80"];
    NSArray *videoURL = @[@"https://img1.haowmc.com/hwmc/test/videos/output/1543042212075.mp4",];
    
    self.previewArray = [[NSMutableArray alloc] init];
    
    for (NSString *urlString in imgURL) {
        YBImageBrowseCellData *imageBrowseCellData = [YBImageBrowseCellData new];
        imageBrowseCellData.url = [NSURL URLWithString:urlString];
        [self.previewArray addObject:imageBrowseCellData];
    }
    
    YBVideoBrowseCellData *videoBrowseCellData = [YBVideoBrowseCellData new];
    videoBrowseCellData.url = [NSURL URLWithString:videoURL.firstObject];
    [self.previewArray addObject:videoBrowseCellData];

    
    
    YBImageBrowser *browser = [YBImageBrowser new];
    browser.dataSource = self;
    browser.delegate = self;
    browser.currentIndex = 0;
    [browser show];
}

#pragma mark - YBImageBrowserDataSource

- (NSUInteger)yb_numberOfCellForImageBrowserView:(YBImageBrowserView *)imageBrowserView {
    return self.previewArray.count;
}

- (id<YBImageBrowserCellDataProtocol>)yb_imageBrowserView:(YBImageBrowserView *)imageBrowserView dataForCellAtIndex:(NSUInteger)index {
    return self.previewArray[index];
}


#pragma mark - YBImageBrowserDelegate

- (void)yb_imageBrowser:(YBImageBrowser *)imageBrowser pageIndexChanged:(NSUInteger)index data:(id<YBImageBrowserCellDataProtocol>)data {
    
    if (index == self.previewArray.count -1) {
        NSLog(@"已经是最后一页了");
    }
}


@end
