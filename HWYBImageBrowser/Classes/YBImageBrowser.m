//
//  YBImageBrowser.m
//  YBImageBrowserDemo
//
//  Created by 杨波 on 2018/8/24.
//  Copyright © 2018年 杨波. All rights reserved.
//

#import "YBImageBrowser.h"
#import "YBImageBrowserViewLayout.h"
#import "YBImageBrowserView.h"
#import "YBImageBrowser+Internal.h"
#import "YBIBUtilities.h"
#import "YBIBWebImageManager.h"
#import "YBIBTransitionManager.h"
#import "YBIBLayoutDirectionManager.h"
#import "YBIBCopywriter.h"
#import <Photos/PHPhotoLibrary.h>
#import <Photos/PHAssetChangeRequest.h>
#import "AppDelegate.h"
#import "HWGoodDetailController.h"
#import "HWDisMiniCodeView.h"
#import "HWShareGoodsModel.h"
#import "HWDisPlayVideoController.h"
#import "HWMineAgentCenter.h"
#import "HWDisMaterialModel.h"
#import "HWSaveVideoManager.h"


@interface YBImageBrowser () <UIViewControllerTransitioningDelegate, YBImageBrowserViewDelegate, YBImageBrowserDataSource> {
    BOOL _isFirstViewDidAppear;
    YBImageBrowserLayoutDirection _layoutDirection;
    CGSize _containerSize;
    BOOL _isRestoringDeviceOrientation;
    UIInterfaceOrientation _statusBarOrientationBefore;
    UIWindowLevel _windowLevelByDefault;
}
@property (nonatomic, strong) YBIBLayoutDirectionManager *layoutDirectionManager;
@property (nonatomic, strong) YBIBTransitionManager *transitionManager;
@end

@implementation YBImageBrowser

#pragma mark - life cycle

- (void)dealloc {
    // If the current instance is released (possibly uncontrollable release), we need to restore the changes to external business.
    [YBIBWebImageManager restoreOutsideConfiguration];
    self.hiddenSourceObject = nil;
    [self setStatusBarHide:NO];
    [self removeObserverForSystem];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.transitioningDelegate = self;
        self.modalPresentationStyle = UIModalPresentationCustom;
        self.automaticallyAdjustsScrollViewInsets = NO;
        
        [self initVars];
        [YBIBWebImageManager storeOutsideConfiguration];
        [self.layoutDirectionManager startObserve];
    }
    return self;
}

- (void)initVars {
    self->_isFirstViewDidAppear = NO;
    self->_isRestoringDeviceOrientation = NO;
    
    self->_currentIndex = 0;
    self->_supportedOrientations = UIInterfaceOrientationMaskAllButUpsideDown;
    self->_backgroundColor = [UIColor blackColor];
    self->_enterTransitionType = YBImageBrowserTransitionTypeCoherent;
    self->_outTransitionType = YBImageBrowserTransitionTypeCoherent;
    self->_transitionDuration = 0.25;
    self->_autoHideSourceObject = YES;
    
    self.shouldPreload = YES;
    
    YBImageBrowserToolBar *toolBar = [YBImageBrowserToolBar new];
    self->_defaultToolBar = toolBar;
    self->_toolBars = @[toolBar];
    
    YBImageBrowserSheetView *sheetView = [YBImageBrowserSheetView new];
    YBImageBrowserSheetAction *saveAction = [YBImageBrowserSheetAction actionWithName:[YBIBCopywriter shareCopywriter].saveToPhotoAlbum identity:kYBImageBrowserSheetActionIdentitySaveToPhotoAlbum action:nil];
    sheetView.actions = @[saveAction];
    self->_defaultSheetView = sheetView;
    self->_sheetView = sheetView;
    
    self->_shouldHideStatusBar = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = self->_backgroundColor;
    [self addGesture];
    [self customBottomBarAction];
    [self addNotification];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setStatusBarHide:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self->_windowLevelByDefault = self.view.window.windowLevel;
    
    
    if (!self->_isFirstViewDidAppear) {
        
        [self updateLayoutOfSubViewsWithLayoutDirection:[YBIBLayoutDirectionManager getLayoutDirectionByStatusBar]];
        
        [self.browserView scrollToPageWithIndex:self->_currentIndex];
        
        [self addSubViews];
 
        self->_isFirstViewDidAppear = YES;

        [self addObserverForSystem];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self setStatusBarHide:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    NSLog(@"didReceiveMemoryWarning");
    [[SDImageCache sharedImageCache] clearMemory];
    
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return self.supportedOrientations;
}

- (void)setStatusBarHide:(BOOL)hide {
    if (self.shouldHideStatusBar) {
//        self.view.window.windowLevel = hide ? UIWindowLevelStatusBar + 1 : _windowLevelByDefault;
        [self setStatusBarBackgroundColor:hide ? RGB(0, 0, 0) : RGB(255, 255, 255)];
    }
}

- (void)setStatusBarBackgroundColor:(UIColor *)color {
    UIView *statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
    if ([statusBar respondsToSelector:@selector(setBackgroundColor:)]) {
        statusBar.backgroundColor = color;
    }
}

- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideVideoBottomBar) name:@"hideVideoBottomBar" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showVideoBottomBar) name:@"showVideoBottomBar" object:nil];
}

- (void)showVideoBottomBar {
    [self.defaultBottomBar showVideoToolBar:YES checkGoods_info:YES];
}

- (void)hideVideoBottomBar {
    [self.defaultBottomBar showVideoToolBar:NO checkGoods_info:NO];
}


#pragma mark - custom Action

- (void)customBottomBarAction {
    
    @weakify(self);
    [[self.defaultBottomBar.miniBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        [self dealWithType:0 index:self.currentIndex];
    }];
    
    [[self.defaultBottomBar.saveBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        [self dealWithType:1 index:self.currentIndex];
    }];
    
    [[self.defaultBottomBar.lookBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        [self dealWithType:2 index:self.currentIndex];
    }];
    
    [[self.defaultBottomBar.downLoadButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        [self saveVideo];
    }];
    
    [[self.defaultBottomBar.detailButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        [self lookDetailFromVideo];
    }];
    
}

- (void)dealWithType:(NSInteger)type index:(NSInteger)index{
    
    id<YBImageBrowserCellDataProtocol> data = [self currentData];
    
    YBImageBrowseCellData *imageCellData = nil;
    if ([data isKindOfClass:[YBImageBrowseCellData class]]) {
        imageCellData = data;
    }else{
        return;
    }
    
    HWDisMaterialModel *materiaModel = imageCellData.extraData;
    
    if (type == 0) {//生成小程序码 保存本地
        WS(weakSelf);
        HWDisMiniCodeView *codeView = [[HWDisMiniCodeView alloc] init];
        codeView.frame = CGRectMake(kScreenWidth, 0, 375, 1);
        [self.view addSubview:codeView];
        codeView.imgBlock = ^(HWDisMiniCodeView *tmp, UIImage *image) {
            if (image == nil) {
                [KKKNoticeHelper showNormalNoticeWithString:@"图片生成失败"];
            }else{
                [weakSelf savePicture:image];
            }
            [tmp removeFromSuperview];
        };
        
        HWShareGoodsModel *model = [[HWShareGoodsModel alloc] init];
        model.goodId = materiaModel.goods_info.goods_id;
        model.goodName = materiaModel.name;
        model.detail = materiaModel.details;
        model.picUrl = materiaModel.img_array[imageCellData.sectionIndex];
        model.miniPath = materiaModel.goods_info.wechat_detail_url;
        codeView.model = model;
        
    }else if (type == 1){//保存图片
        UIImage *image = imageCellData.image;
        [self savePicture:image];
    }else{
        //查看详情
        [self hide];
        
        UIViewController *vc = HWAppDelegate.currentVC;
        HWGoodDetailController *detailVC = [[HWGoodDetailController alloc] initWithGoodsId:materiaModel.goods_info.goods_id];
        detailVC.hidesBottomBarWhenPushed= YES;
        [vc.navigationController pushViewController:detailVC animated:YES];
    }
}

- (void)savePicture:(UIImage *)image{
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusRestricted || status == PHAuthorizationStatusDenied){
        //无权限
        [self showTip];
        return;
    }
    WS(weakSelf);
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        if (status == PHAuthorizationStatusAuthorized) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf saveImage:image];
            });
        }
    }];
}

- (void)saveImage:(UIImage *)image{
    
    if (image == nil) {
        [KKKNoticeHelper showNormalNoticeWithString:@"保存图片错误"];
        return;
    }
    
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        [PHAssetChangeRequest creationRequestForAssetFromImage:image];
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        if (error != nil) {
            return;
        }
        [KKKNoticeHelper showNormalNoticeWithString:@"保存图片成功"];
        
    }];
}

- (void)showTip{
    [KKKNoticeHelper showHudWithTitle:@"开启相册权限，更好卖货" message:@"" cancleMessage:@"取消" sureMessage:@"立即开启" cancleAction:^{
        
    } sureAction:^{
        NSURL *settingURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        
        if ([[UIApplication sharedApplication] canOpenURL:settingURL]) {
            [[UIApplication sharedApplication] openURL:settingURL];
        }
        
        [[UIApplication sharedApplication] openURL:settingURL];
    }];
}


- (void)saveVideo {
    
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusRestricted || status == PHAuthorizationStatusDenied){
        //无权限
        [self showTip];
        return;
    }
    WS(weakSelf);
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        if (status == PHAuthorizationStatusAuthorized) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf downloadVideo];
            });
        }
    }];
}


- (void)downloadVideo {
    
    id<YBImageBrowserCellDataProtocol> data = [self currentData];
    
    YBVideoBrowseCellData *videoCellData = nil;
    if ([data isKindOfClass:[YBVideoBrowseCellData class]]) {
        videoCellData = data;
    }else{
        return;
    }
    HWDisMaterialModel *materiaModel = videoCellData.extraData;
    
    HWBaseViewController *vc = (HWBaseViewController *)HWAppDelegate.currentVC;
    [vc setStatusBarBackgroundColor:[UIColor clearColor]];
    [[HWSaveVideoManager sharedInstance] saveVideoWithVideoUrlStr:materiaModel.video progress:nil success:^{
        [KKKNoticeHelper showNormalNoticeWithString:@"视频保存成功"];
        [vc setStatusBarBackgroundColor:[UIColor whiteColor]];
        
    } failuer:^(NSError *error) {
        NSLog(@"ss");
        [vc setStatusBarBackgroundColor:[UIColor whiteColor]];
        
    }];
}

- (void)lookDetailFromVideo {
    
    id<YBImageBrowserCellDataProtocol> data = [self currentData];
    
    YBVideoBrowseCellData *videoCellData = nil;
    if ([data isKindOfClass:[YBVideoBrowseCellData class]]) {
        videoCellData = data;
    }else{
        return;
    }
    HWDisMaterialModel *materiaModel = videoCellData.extraData;
    
    //查看详情
    [self hide];
    
    UIViewController *vc = HWAppDelegate.currentVC;
    HWGoodDetailController *detailVC = [[HWGoodDetailController alloc] initWithGoodsId:materiaModel.goods_info.goods_id];
    detailVC.hidesBottomBarWhenPushed= YES;
    [vc.navigationController pushViewController:detailVC animated:YES];
}


#pragma mark - gesture

- (void)addGesture {
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(respondsToLongPress:)];
    [self.view addGestureRecognizer:longPress];
}

- (void)respondsToLongPress:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(yb_imageBrowser:respondsToLongPress:)]) {
            [self.delegate yb_imageBrowser:self respondsToLongPress:sender];
            return;
        }
        
        if (self.sheetView && (![[self currentData] respondsToSelector:@selector(yb_browserAllowShowSheetView)] || [[self currentData] yb_browserAllowShowSheetView])) {
            [self.view addSubview:self.sheetView];
            [self.sheetView yb_browserShowSheetViewWithData:[self currentData] layoutDirection:self->_layoutDirection containerSize:self->_containerSize];
        }
    }
}

#pragma mark - observe

- (void)removeObserverForSystem {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidChangeStatusBarFrameNotification object:nil];
}

- (void)addObserverForSystem {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeStatusBarFrame) name:UIApplicationDidChangeStatusBarFrameNotification object:nil];
}

- (void)didChangeStatusBarFrame {
    if ([UIApplication sharedApplication].statusBarFrame.size.height > YBIB_HEIGHT_STATUSBAR) {
        self.view.frame = CGRectMake(0, 0, self->_containerSize.width, self->_containerSize.height);
    }
}

#pragma mark - private

- (void)addSubViews {
    [self.view addSubview:self.browserView];
    [self.toolBars enumerateObjectsUsingBlock:^(__kindof UIView<YBImageBrowserToolBarProtocol> * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.view addSubview:obj];
        if ([obj respondsToSelector:@selector(setYb_browserShowSheetViewBlock:)]) {
            __weak typeof(self) wSelf = self;
            [obj setYb_browserShowSheetViewBlock:^(id<YBImageBrowserCellDataProtocol> _Nonnull data) {
                __strong typeof(wSelf) sSelf = wSelf;
                if (sSelf.sheetView) {
                    [sSelf.view addSubview:sSelf.sheetView];
                    [sSelf.sheetView yb_browserShowSheetViewWithData:data layoutDirection:sSelf->_layoutDirection containerSize:sSelf->_containerSize];
                }
            }];
        }
    }];
    
    self.defaultBottomBar.frame = CGRectMake(0, kScreenHeight - 59*kDesignScaleXForIP6 - [HWUIManager iphoneXTabrOffset], kScreenWidth, 59*kDesignScaleXForIP6 + [HWUIManager iphoneXTabrOffset]);
    [self.view addSubview:self.defaultBottomBar];
}

- (void)updateLayoutOfSubViewsWithLayoutDirection:(YBImageBrowserLayoutDirection)layoutDirection {
    self->_layoutDirection = layoutDirection;
    CGSize containerSize = layoutDirection == YBImageBrowserLayoutDirectionHorizontal ? CGSizeMake(YBIMAGEBROWSER_HEIGHT, YBIMAGEBROWSER_WIDTH) : CGSizeMake(YBIMAGEBROWSER_WIDTH, YBIMAGEBROWSER_HEIGHT);
    self->_containerSize = containerSize;
    
    if (self.sheetView && self.sheetView.superview) {
        [self.sheetView yb_browserHideSheetViewWithAnimation:NO];
    }
    
    [self.browserView updateLayoutWithDirection:layoutDirection containerSize:containerSize];
    [self.toolBars enumerateObjectsUsingBlock:^(__kindof UIView<YBImageBrowserToolBarProtocol> * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj yb_browserUpdateLayoutWithDirection:layoutDirection containerSize:containerSize];
    }];
}

- (void)pageIndexChanged:(NSUInteger)index {
    self->_currentIndex = index;
    
    id<YBImageBrowserCellDataProtocol> data = [self currentData];
    
    id sourceObj = nil;
    if ([data respondsToSelector:@selector(yb_browserCellSourceObject)]) {
        sourceObj = data.yb_browserCellSourceObject;
    }
    self.hiddenSourceObject = sourceObj;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(yb_imageBrowser:pageIndexChanged:data:)]) {
        [self.delegate yb_imageBrowser:self pageIndexChanged:index data:data];
    }
    
    [self.toolBars enumerateObjectsUsingBlock:^(__kindof UIView<YBImageBrowserToolBarProtocol> * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if (self.defaultToolBar && self.sheetView && [self.sheetView yb_browserActionsCount] >= 2) {
            self.defaultToolBar.operationType = YBImageBrowserToolBarOperationTypeMore;
        }
        
        if ([obj respondsToSelector:@selector(yb_browserPageIndexChanged:totalPage:data:)]) {
            [obj yb_browserPageIndexChanged:index totalPage:[self.dataSource yb_numberOfCellForImageBrowserView:self.browserView] data:data];
        }
    }];
    
    if ([data isKindOfClass:[YBImageBrowseCellData class]]) {
        YBImageBrowseCellData *imageData = data;
        self.defaultBottomBar.materiaModel = imageData.extraData;
    }else{
        YBVideoBrowseCellData *videoData = data;
        self.defaultBottomBar.materiaModel = videoData.extraData;
    }

    
}

#pragma mark - public

- (void)setDataSource:(id<YBImageBrowserDataSource>)dataSource {
    self.browserView.yb_dataSource = dataSource;
}

- (id<YBImageBrowserDataSource>)dataSource {
    return self.browserView.yb_dataSource;
}

- (void)setCurrentIndex:(NSUInteger)currentIndex {
    if (currentIndex + 1 > [self.browserView.yb_dataSource yb_numberOfCellForImageBrowserView:self.browserView]) {
        YBIBLOG_ERROR(@"The index out of range.");
    } else {
        _currentIndex = currentIndex;
        if (self.browserView.superview) {
            [self.browserView scrollToPageWithIndex:currentIndex];
        }
    }
}

- (void)reloadData {
    [self.browserView yb_reloadData];
    [self.browserView scrollToPageWithIndex:self->_currentIndex];
    [self pageIndexChanged:self.browserView.currentIndex];
}

- (id<YBImageBrowserCellDataProtocol>)currentData {
    return [self.browserView currentData];
}

- (void)show {
    if ([self.browserView.yb_dataSource yb_numberOfCellForImageBrowserView:self.browserView] <= 0) {
        YBIBLOG_ERROR(@"The data sources is invalid.");
        return;
    }
    [self showFromController:[self currentViewController]];
}

- (UIViewController*)currentViewController{
    UIViewController* vc = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    if ([vc isKindOfClass:[UITabBarController class]]) {
        vc = ((UITabBarController*)vc).selectedViewController;
    }else if ([vc isKindOfClass:[UINavigationController class]]) {
        vc = ((UINavigationController*)vc).visibleViewController;
    }else if (vc.presentedViewController) {
        vc = vc.presentedViewController;
    }
    
    return vc;
}

- (void)showFromController:(UIViewController *)fromController {
    //Preload current data.
    if (self.shouldPreload) {
        id<YBImageBrowserCellDataProtocol> needPreloadData = [self.browserView dataAtIndex:self.currentIndex];
        if ([needPreloadData respondsToSelector:@selector(yb_preload)]) {
            [needPreloadData yb_preload];
        }
        
        if (self.currentIndex == 0) {
            [self.browserView preloadWithCurrentIndex:self.currentIndex];
        }
    }
    
    self->_statusBarOrientationBefore = [UIApplication sharedApplication].statusBarOrientation;
    self.browserView.statusBarOrientationBefore = self->_statusBarOrientationBefore;
    [fromController presentViewController:self animated:YES completion:nil];
}

- (void)hide {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)setDistanceBetweenPages:(CGFloat)distanceBetweenPages {
    _distanceBetweenPages = distanceBetweenPages;
    ((YBImageBrowserViewLayout *)self.browserView.collectionViewLayout).distanceBetweenPages = distanceBetweenPages;
}

- (void)setGiProfile:(YBIBGestureInteractionProfile *)giProfile {
    _giProfile = giProfile;
    self.browserView.giProfile = giProfile;
}

- (void)setDataCacheCountLimit:(NSUInteger)dataCacheCountLimit {
    _dataCacheCountLimit = dataCacheCountLimit;
    self.browserView.cacheCountLimit = dataCacheCountLimit;
}

- (void)setShouldPreload:(BOOL)shouldPreload {
    _shouldPreload = shouldPreload;
    self.browserView.shouldPreload = shouldPreload;
}


#pragma mark - internal

- (void)setHiddenSourceObject:(id)hiddenSourceObject {
    if (!self->_autoHideSourceObject) return;
    if (_hiddenSourceObject && [_hiddenSourceObject respondsToSelector:@selector(setHidden:)]) {
        [_hiddenSourceObject setValue:@(NO) forKey:@"hidden"];
    }
    if (hiddenSourceObject && [hiddenSourceObject respondsToSelector:@selector(setHidden:)]) {
        [hiddenSourceObject setValue:@(YES) forKey:@"hidden"];
    }
    _hiddenSourceObject = hiddenSourceObject;
}

#pragma mark <UIViewControllerTransitioningDelegate>

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    return self.transitionManager;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return self.transitionManager;
}

#pragma mark - <YBImageBrowserViewDelegate>

- (void)yb_imageBrowserViewDismiss:(YBImageBrowserView *)browserView {
    [self.toolBars enumerateObjectsUsingBlock:^(__kindof UIView<YBImageBrowserToolBarProtocol> * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.hidden = YES;
    }];
    
    self.defaultBottomBar.hidden = YES;
    
    if ([UIApplication sharedApplication].statusBarOrientation != self->_statusBarOrientationBefore && [[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        SEL selector = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        NSInteger val = self->_statusBarOrientationBefore;
        [invocation setArgument:&val atIndex:2];
        self->_isRestoringDeviceOrientation = YES;
        [invocation invoke];
    }
    
    [self hide];
}

- (void)yb_imageBrowserView:(YBImageBrowserView *)browserView changeAlpha:(CGFloat)alpha duration:(NSTimeInterval)duration {
    void (^animationsBlock)(void) = ^{
        self.view.backgroundColor = [self->_backgroundColor colorWithAlphaComponent:alpha];
    };
    void (^completionBlock)(BOOL) = ^(BOOL x){
        if (alpha == 1) [self setStatusBarHide:YES];
        if (alpha < 1) [self setStatusBarHide:NO];
    };
    if (duration <= 0) {
        animationsBlock();
        completionBlock(YES);
    } else {
        [UIView animateWithDuration:duration animations:animationsBlock completion:completionBlock];
    }
}

- (void)yb_imageBrowserView:(YBImageBrowserView *)browserView pageIndexChanged:(NSUInteger)index {
    [self pageIndexChanged:index];
}

- (void)yb_imageBrowserView:(YBImageBrowserView *)browserView hideTooBar:(BOOL)hidden {
    [self.toolBars enumerateObjectsUsingBlock:^(__kindof UIView<YBImageBrowserToolBarProtocol> * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.hidden = hidden;
    }];
    if (self.sheetView && self.sheetView.superview && hidden) {
        [self.sheetView yb_browserHideSheetViewWithAnimation:YES];
    }
}

#pragma mark - <YBImageBrowserDataSource>

- (NSUInteger)yb_numberOfCellForImageBrowserView:(YBImageBrowserView *)imageBrowserView {
    return self.dataSourceArray.count;
}

- (id<YBImageBrowserCellDataProtocol>)yb_imageBrowserView:(YBImageBrowserView *)imageBrowserView dataForCellAtIndex:(NSUInteger)index {
    return self.dataSourceArray[index];
}

#pragma mark - getter

- (YBImageBrowserView *)browserView {
    if (!_browserView) {
        _browserView = [YBImageBrowserView new];
        _browserView.yb_delegate = self;
        _browserView.yb_dataSource = self;
        _browserView.giProfile = [YBIBGestureInteractionProfile new];
    }
    return _browserView;
}

- (YBIBLayoutDirectionManager *)layoutDirectionManager {
    if (!_layoutDirectionManager) {
        _layoutDirectionManager = [YBIBLayoutDirectionManager new];
        __weak typeof(self) wSelf = self;
        [_layoutDirectionManager setLayoutDirectionChangedBlock:^(YBImageBrowserLayoutDirection layoutDirection) {
            __strong typeof(self) sSelf = wSelf;
            if (layoutDirection == YBImageBrowserLayoutDirectionUnknown || sSelf.transitionManager.isTransitioning || sSelf->_isRestoringDeviceOrientation) return;
            
            [sSelf updateLayoutOfSubViewsWithLayoutDirection:layoutDirection];
        }];
    }
    return _layoutDirectionManager;
}

- (YBIBTransitionManager *)transitionManager {
    if (!_transitionManager) {
        _transitionManager = [YBIBTransitionManager new];
        _transitionManager.imageBrowser = self;
    }
    return _transitionManager;
}

- (YBImageBrowserBottomBar *)defaultBottomBar {
    if (!_defaultBottomBar) {
        _defaultBottomBar = [YBImageBrowserBottomBar new];
    }
    return _defaultBottomBar;
}

@end
