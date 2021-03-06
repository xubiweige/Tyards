//
//  SEMMeViewController.m
//  十二码
//
//  Created by 汪宇豪 on 16/7/22.
//  Copyright © 2016年 汪宇豪. All rights reserved.
//

#import "SEMMeViewController.h"
#import "SEMMeViewModel.h"
#import "MeinfoVIew.h"
#import "MeTopView.h"
#import "MDABizManager.h"
#import "SEMLoginViewController.h"
#import  "LoginCommand.h"
#import "UserModel.h"
//#import "PersonalInfoController.h"
#import "MyZoneVC.h"
#import "MyArticle.h"
#import "UIViewController+MMDrawerController.h"
#import "SEMTabViewController.h"
#import "MyConcernController.h"
#import "MyMessageController.h"
#import "InvitationViewController.h"
#import "FeedBackController.h"
#import "ChangeNickNameController.h"
#import "ShareView.h"
#import "UMSocialWechatHandler.h"
#import "UMSocial.h"
#import  "MyLabel.h"

#define kShareTargetUrl @"http://a.app.qq.com/o/simple.jsp?pkgname=com.tyards"

@interface SEMMeViewController ()<UITableViewDelegate,UITableViewDataSource,ShareViewDelegate>
@property (strong,nonatomic)SEMMeViewModel* viewModel;
@property (nonatomic,strong)MeTopView* topView;
@property (nonatomic,strong)UITableView* tableview;
@property (nonatomic,strong)LoginCommand* login;
@property (nonatomic,strong)ShareView* shareView;
@property (nonatomic,strong)UIView* maskView;


@end

@implementation SEMMeViewController

#pragma mark- lifeCycle
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.viewModel fetchInvitation];
    [self.viewModel fetchReply];
    self.viewModel.info = (UserModel*)[DataArchive unarchiveUserDataWithFileName:@"userinfo"];
    if (self.viewModel.info) {
        self.topView.name = self.viewModel.info.nickname;
        self.topView.userHeadView.image = (UIImage*)[DataArchive unarchiveUserDataWithFileName:@"headimage"];
        self.topView.infoView.hidden = NO;
        self.viewModel.isLogined = YES;
        UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithActionBlock:^(id  _Nonnull sender) {
            [self.mm_drawerController closeDrawerAnimated: YES completion:^(BOOL finished) {
                
            }];
            
            UINavigationController* nav = (UINavigationController*)(((SEMTabViewController*)self.mm_drawerController.centerViewController).selectedViewController);
            
//            PersonalInfoController* controller = [HRTRouter objectForURL:@"myInfo" withUserInfo:@{}];
            MyZoneVC *controller = [HRTRouter objectForURL:@"myInfo" withUserInfo:@{}];
            controller.hidesBottomBarWhenPushed = YES;
            [nav pushViewController:controller animated:YES];
        }];
        [self.topView.userHeadView addGestureRecognizer:tap];
    }
    else
    {
        self.topView.name = @"请登录";
        self.topView.headImage = [UIImage imageNamed:@"Group 2"];
        self.topView.infoView.hidden = YES;
        self.viewModel.isLogined = NO;
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupView];
    [self bindModel];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark- controllerSetup
- (void)setupView
{
    self.view.backgroundColor = [UIColor whiteColor];
    [self addSubviews];
    [self makeConstraits];
}

- (void)addSubviews
{
    [self.view addSubview:self.topView];
    [self.view addSubview:self.tableview];
//    [self.view addSubview:self.maskView];
    [self.maskView addSubview:self.shareView];
}

- (void)makeConstraits
{
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.and.left.and.right.equalTo(self.view);
        make.height.equalTo(self.view.mas_height).dividedBy(2.8);
    }];
    [self.tableview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.topView.mas_bottom);
        make.left.and.right.equalTo(self.view);
        make.height.equalTo(@(55*7*self.view.scale));
    }];
}

- (void)bindModel
{
    self.title = self.viewModel.title;
    self.login = [LoginCommand sharedInstance];
    [[self.login.weixinLoginedCommand executionSignals] subscribeNext:^(id x) {
//        self.viewModel.info = x;
//        NSLog(@"%@",self.viewModel.info.nickname);
//        NSLog(@"成功获取用户信息");
    }];
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithActionBlock:^(id  _Nonnull sender) {
        [self.mm_drawerController closeDrawerAnimated: YES completion:^(BOOL finished) {
            
        }];
        ChangeNickNameController* controller =[[ChangeNickNameController alloc] initWithDictionary:@{@"name":self.viewModel.info.nickname}];
        UINavigationController* nav = (UINavigationController*)(((SEMTabViewController*)self.mm_drawerController.centerViewController).selectedViewController);
        controller.hidesBottomBarWhenPushed = YES;
        [nav pushViewController:controller animated:YES];
    }];
    [self.topView.infoView.infoLabel addGestureRecognizer:tap];
}

#pragma mark -viewModelSet

- (void)setRouterParameters:(NSDictionary *)routerParameters
{
    self.viewModel = [[SEMMeViewModel alloc] initWithDictionary: routerParameters];
}

#pragma mark- uitableViewdelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.viewModel.items.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MeViewCell"];
    cell.imageView.image = [UIImage imageNamed:self.viewModel.images[indexPath.row]];
    [cell.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(cell.contentView.mas_centerY);
        make.height.equalTo(@20);
        make.width.equalTo(@20);
        make.left.equalTo(cell.contentView.mas_left).offset(9);
    }];
    cell.textLabel.text = self.viewModel.items[indexPath.row];
    [cell.textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(cell.contentView.mas_left).offset(45*self.view.scale);
        make.centerY.equalTo(cell.contentView.mas_centerY);
    }];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    if (indexPath.row == 2 && [self.viewModel getReply]) {
        MyLabel* label = [[MyLabel alloc] init];
//        label.textInsets = UIEdgeInsetsMake(5, 5, 5, 5);
        [cell.contentView addSubview:label];
        label.sd_layout
        .centerYEqualToView(cell.contentView)
        .leftSpaceToView(cell.textLabel,10*self.view.scale)
        .heightIs(15*self.view.scale)
        .widthEqualToHeight();
        label.layer.cornerRadius = label.width / 2;
        label.layer.masksToBounds = YES;
        label.backgroundColor = [UIColor redColor];
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont systemFontOfSize:10*self.view.scale];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = [self.viewModel getReply];
        
    }
    if (indexPath.row == 3 && [self.viewModel getInvitation]) {
        MyLabel* label = [[MyLabel alloc] init];
        //        label.textInsets = UIEdgeInsetsMake(5, 5, 5, 5);
        [cell.contentView addSubview:label];
        label.sd_layout
        .centerYEqualToView(cell.contentView)
        .leftSpaceToView(cell.textLabel,10*self.view.scale)
        .heightIs(15*self.view.scale)
        .widthEqualToHeight();
        label.sd_cornerRadiusFromWidthRatio = @0.5;
        label.layer.masksToBounds = YES;
        label.backgroundColor = [UIColor redColor];
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont systemFontOfSize:10*self.view.scale];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = [self.viewModel getInvitation];

    }
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
        {
            return 50*self.view.scale;
        }
#pragma  mark-TableDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //进入个人资料页面
    if (indexPath.row == 0) {
        if (self.viewModel.isLogined) {
            [self.mm_drawerController closeDrawerAnimated: YES completion:^(BOOL finished) {
                
            }];
            
            UINavigationController* nav = (UINavigationController*)(((SEMTabViewController*)self.mm_drawerController.centerViewController).selectedViewController);
            
//            PersonalInfoController* controller = [HRTRouter objectForURL:@"myInfo" withUserInfo:@{}];
            MyZoneVC *controller = [HRTRouter objectForURL:@"myInfo" withUserInfo:@{}];
            controller.hidesBottomBarWhenPushed = YES;
            [nav pushViewController:controller animated:YES];
        }
        else
        {
            [XHToast showCenterWithText:@"请先登录"];
        }
        
    }else if (indexPath.row==1){
        if (self.viewModel.isLogined) {
            [self.mm_drawerController closeDrawerAnimated: YES completion:^(BOOL finished) {
                
            }];
            
            UINavigationController* nav = (UINavigationController*)(((SEMTabViewController*)self.mm_drawerController.centerViewController).selectedViewController);
            MyArticle *controller = [HRTRouter objectForURL:@"myArticle" withUserInfo:@{}];
            controller.hidesBottomBarWhenPushed = YES;
            [nav pushViewController:controller animated:YES];
        }
        else
        {
            [XHToast showCenterWithText:@"请先登录"];
        }
    }
    else if (indexPath.row == 2)
    {
        if (self.viewModel.isLogined) {
            [self.mm_drawerController closeDrawerAnimated: YES completion:^(BOOL finished) {
            }];
            UINavigationController* nav = (UINavigationController*)(((SEMTabViewController*)self.mm_drawerController.centerViewController).selectedViewController);
            
            MyConcernController* controller = [HRTRouter objectForURL:@"Myconcern" withUserInfo:@{@"id":@(self.viewModel.model.id)}];
            controller.hidesBottomBarWhenPushed = YES;
            [nav pushViewController:controller animated:YES];
        }
        else
        {
            [XHToast showCenterWithText:@"请先登录"];
        }
        
    }
    else if (indexPath.row == 3)
    {
        if (self.viewModel.isLogined) {
            [self.mm_drawerController closeDrawerAnimated: YES completion:^(BOOL finished) {
            }];
            UINavigationController* nav = (UINavigationController*)(((SEMTabViewController*)self.mm_drawerController.centerViewController).selectedViewController);
            
            MyMessageController* controller = [HRTRouter objectForURL:@"MyMessage" withUserInfo:@{}];
            controller.hidesBottomBarWhenPushed = YES;
            [nav pushViewController:controller animated:YES];
        }
        else
        {
             [XHToast showCenterWithText:@"请先登录"];
        }

    }
    else if (indexPath.row == 7)
    {
        [self.mm_drawerController closeDrawerAnimated: YES completion:^(BOOL finished) {
        }];
        UINavigationController* nav = (UINavigationController*)(((SEMTabViewController*)self.mm_drawerController.centerViewController).selectedViewController);
        
        MyMessageController* controller = [HRTRouter objectForURL:@"setup" withUserInfo:@{@"login":@(self.viewModel.isLogined)}];
        controller.hidesBottomBarWhenPushed = YES;
        [nav pushViewController:controller animated:YES];
    }
    else if (indexPath.row == 4)
    {
        [self.mm_drawerController closeDrawerAnimated: YES completion:^(BOOL finished) {
        }];
        UINavigationController* nav = (UINavigationController*)(((SEMTabViewController*)self.mm_drawerController.centerViewController).selectedViewController);
        InvitationViewController* controller = [[InvitationViewController alloc] initWithDictionary:@{}];
        controller.hidesBottomBarWhenPushed = YES;
        [nav pushViewController:controller animated:YES];
    }
    else if (indexPath.row == 5)
    {
        FeedBackController* controller = [[FeedBackController alloc] init];
        [self.mm_drawerController closeDrawerAnimated: YES completion:^(BOOL finished) {
        }];
        UINavigationController* nav = (UINavigationController*)(((SEMTabViewController*)self.mm_drawerController.centerViewController).selectedViewController);
        controller.hidesBottomBarWhenPushed = YES;
        [nav pushViewController:controller animated:YES];
        
    }else if (indexPath.row==6){
        [[UIApplication sharedApplication].keyWindow addSubview:self.maskView];

        
        CALayer* imageLayer = self.shareView.layer;
//        self.maskView.hidden = NO;
        CGPoint fromPoint = imageLayer.position;
        CGPoint toPoint = CGPointMake(0, self.view.height - 200*self.view.scale);
        // 创建不断改变CALayer的position属性的属性动画
        CABasicAnimation* anim = [CABasicAnimation
                                  animationWithKeyPath:@"position"];
        // 设置动画开始的属性值
        anim.fromValue = [NSValue valueWithCGPoint:fromPoint];
        // 设置动画结束的属性值
        anim.toValue = [NSValue valueWithCGPoint:toPoint];
        anim.duration = 0.3;
        imageLayer.position = toPoint;
        anim.removedOnCompletion = YES;
        // 为imageLayer添加动画
        [imageLayer addAnimation:anim forKey:nil];
    }
}
#pragma mark-ShareViewDelegate
- (void)didSelectedShareView:(NSInteger)index
{
    
    
    NSLog(@"%ld",(long)index);
    switch (index) {
        case 0:
        {
            [UMSocialData defaultData].extConfig.wechatSessionData.url = kShareTargetUrl;
            UMSocialUrlResource *urlResource = [[UMSocialUrlResource alloc] initWithSnsResourceType:UMSocialUrlResourceTypeImage url:@""];
            [[UMSocialDataService defaultDataService]  postSNSWithTypes:@[UMShareToWechatSession] content:@"推荐一个我天天用的校园足球App给你" image:[UIImage imageNamed:@"logo"] location:nil urlResource:urlResource presentedController:self completion:^(UMSocialResponseEntity *response){
                if (response.responseCode == UMSResponseCodeSuccess) {
                    NSLog(@"分享成功！");
                }
            }];
        }
            
            break;
        case 1:
        {
            [UMSocialData defaultData].extConfig.wechatTimelineData.url = kShareTargetUrl;
            UMSocialUrlResource *urlResource = [[UMSocialUrlResource alloc] initWithSnsResourceType:UMSocialUrlResourceTypeImage url:@""];
            [[UMSocialDataService defaultDataService]  postSNSWithTypes:@[UMShareToWechatTimeline] content:@"推荐一个我天天用的校园足球App给你" image:[UIImage imageNamed:@"logo"] location:nil urlResource:urlResource presentedController:self completion:^(UMSocialResponseEntity *response){
                if (response.responseCode == UMSResponseCodeSuccess) {
                    NSLog(@"分享成功！");
                }
            }];
        }
            break;
        case 2:
        {
            [UMSocialData defaultData].extConfig.qqData.url = kShareTargetUrl;
            [UMSocialData defaultData].extConfig.qqData.shareImage=[UIImage imageNamed:@"logo"];
            UMSocialUrlResource *urlResource = [[UMSocialUrlResource alloc] initWithSnsResourceType:UMSocialUrlResourceTypeImage url:@""];
            [[UMSocialDataService defaultDataService]  postSNSWithTypes:@[UMShareToQQ] content:@"推荐一个我天天用的校园足球App给你" image:[UIImage imageNamed:@"logo"] location:nil urlResource:urlResource presentedController:self completion:^(UMSocialResponseEntity *response){
                if (response.responseCode == UMSResponseCodeSuccess) {
                    NSLog(@"分享成功！");
                }
            }];
        }
            break;
        case 3:
        {
            [UMSocialData defaultData].extConfig.qzoneData.url = kShareTargetUrl;
            [UMSocialData defaultData].extConfig.qzoneData.shareImage=[UIImage imageNamed:@"logo"];
            UMSocialUrlResource *urlResource = [[UMSocialUrlResource alloc] initWithSnsResourceType:UMSocialUrlResourceTypeImage url:@""];
            [[UMSocialDataService defaultDataService]  postSNSWithTypes:@[UMShareToQzone] content:@"推荐一个我天天用的校园足球App给你" image:[UIImage imageNamed:@"logo"] location:nil urlResource:urlResource presentedController:self completion:^(UMSocialResponseEntity *response){
                if (response.responseCode == UMSResponseCodeSuccess) {
                    NSLog(@"分享成功！");
                }
            }];
        }
            break;
        case 4:
            [self hideMaskView];
            break;
        default:
            break;
    }
}
- (void)hideMaskView
{
//    _maskView.hidden = YES;
    [_maskView removeFromSuperview];
    CALayer* imageLayer = self.shareView.layer;
    CGPoint fromPoint = imageLayer.position;
    CGPoint toPoint = CGPointMake(0, self.view.height);
    // 创建不断改变CALayer的position属性的属性动画
    CABasicAnimation* anim = [CABasicAnimation
                              animationWithKeyPath:@"position"];
    // 设置动画开始的属性值
    anim.fromValue = [NSValue valueWithCGPoint:fromPoint];
    // 设置动画结束的属性值
    anim.toValue = [NSValue valueWithCGPoint:toPoint];
    anim.duration = 0.3;
    imageLayer.position = toPoint;
    anim.removedOnCompletion = YES;
    // 为imageLayer添加动画
    [imageLayer addAnimation:anim forKey:nil];
}
#pragma mark -Getter
- (MeTopView*)topView
{
    if (!_topView) {
        _topView = [[MeTopView alloc] initWithFrame:CGRectZero];
        _topView.name = @"爱足球的宝贝";
        _topView.headImage = [UIImage imageNamed:@"logo"];
        _topView.userInteractionEnabled = YES;
        UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithActionBlock:^(id  _Nonnull sender) {
            if (self.viewModel.isLogined == NO) {
                SEMLoginViewController* login = [HRTRouter objectForURL:@"login" withUserInfo:@{}];
                [self presentViewController:login animated:YES completion:nil];
            }
        }];
        [_topView.userHeadView addGestureRecognizer:tap];
    }
    return _topView;
}

- (UITableView*)tableview
{
    if (!_tableview) {
        _tableview = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableview.separatorInset = UIEdgeInsetsMake(0, 35, 0, 0);
        _tableview.delegate = self;
        _tableview.dataSource = self;
        _tableview.separatorColor = [UIColor whiteColor];
    }
    return _tableview;
}
- (ShareView *)shareView
{
    if (!_shareView) {
        _shareView = [[ShareView alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width, 200*self.view.scale)];
        _shareView.layer.anchorPoint = CGPointMake(0, 0);
        _shareView.frame = CGRectMake(0, self.view.height, self.view.width, 200*self.view.scale);
        _shareView.delegate = self;
        _shareView.layer.anchorPoint = CGPointMake(0, 0);
        NSLog(@"%@",_shareView.description);
    }
    return _shareView;
}
- (UIView *)maskView
{
    if (!_maskView) {
        _maskView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
        _maskView.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.5];
//        _maskView.alpha = 0.5;
//        _maskView.hidden = YES;
        
        //添加点击之后的手势
        UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideMaskView)];
        [_maskView addGestureRecognizer:tap];
    }
    return _maskView;
}
@end
