//
//  HeProtectedUserInfoVC.m
//  nurseService
//
//  Created by Tony on 2017/1/10.
//  Copyright © 2017年 iMac. All rights reserved.
//

#import "HeProtectedUserInfoVC.h"
#import "HeProtectUserInfoTableCell.h"
#import "HeEditProtectUserInfoVC.h"
#import "AFHttpTool.h"
#import "HeEditProtectUserInfoVC.h"

@interface HeProtectedUserInfoVC ()
@property(strong,nonatomic)IBOutlet UITableView *tableview;
@property(strong,nonatomic)NSMutableArray *dataSource;
@property(strong,nonatomic)NSString *selectedProtectedPersonId;

@end

@implementation HeProtectedUserInfoVC
@synthesize tableview;
@synthesize dataSource;
@synthesize selectedProtectedPersonId;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.backgroundColor = [UIColor clearColor];
        label.font = APPDEFAULTTITLETEXTFONT;
        label.textColor = APPDEFAULTTITLECOLOR;
        label.textAlignment = NSTextAlignmentCenter;
        self.navigationItem.titleView = label;
        label.text = @"被受护人信息";
        [label sizeToFit];
        self.title = @"被受护人信息";
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self initializaiton];
    [self initView];
    [self getDataSource];
}

- (void)initializaiton
{
    [super initializaiton];
    dataSource = [[NSMutableArray alloc] initWithCapacity:0];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addUserInfo:) name:kAddProtectedUserInfoNotification object:nil];
}

- (void)initView
{
    [super initView];
    tableview.backgroundView = nil;
    tableview.backgroundColor = [UIColor colorWithWhite:237.0 / 255.0 alpha:1.0];
    [Tool setExtraCellLineHidden:tableview];
    tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)addUserInfo:(NSNotification *)notification
{
    NSLog(@"addUserInfo");
    [self getDataSource];
}

- (IBAction)addProtectUserInfo:(id)sender
{
    HeEditProtectUserInfoVC *editProtectUserInfoVC = [[HeEditProtectUserInfoVC alloc] init];
    editProtectUserInfoVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:editProtectUserInfoVC animated:YES];
}

#pragma mark - TableView Delegate

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return dataSource.count;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
    
    static NSString *cellIndentifier = @"HeProtectUserInfoTableCell";
    CGSize cellSize = [tableView rectForRowAtIndexPath:indexPath].size;
    
    NSDictionary *dict = nil;
    @try {
        dict = dataSource[row];
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
    HeProtectUserInfoTableCell *cell  = [tableView cellForRowAtIndexPath:indexPath];
    if (!cell) {
        cell = [[HeProtectUserInfoTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier cellSize:cellSize];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    NSString *name = [dict valueForKey:@"protectedPersonName"];
    
    id protectedPersonSex = dict[@"protectedPersonSex"];
    if ([protectedPersonSex isMemberOfClass:[NSNull class]]) {
        protectedPersonSex = @"";
    }
    NSString *sex = ([protectedPersonSex integerValue] == ENUM_SEX_Boy) ? @"男" : @"女";
    NSString *phone = [dict valueForKey:@"protectedPersonPhone"];
    
    id protectedDefault = dict[@"protectedDefault"];
    if ([protectedDefault isMemberOfClass:[NSNull class]]) {
        protectedDefault = @"";
    }
    BOOL isDefault = ([protectedDefault integerValue] == 1) ? YES : NO;
    if (isDefault) {
        //第一次默认选中默认受护人
        if (!selectedProtectedPersonId) {
            selectedProtectedPersonId = dict[@"protectedPersonId"];
        }
    }
    NSString *protectedPersonId = dict[@"protectedPersonId"];
    if ([selectedProtectedPersonId isEqualToString:protectedPersonId]) {
        cell.selectBt.selected = YES;
    }
    else{
        cell.selectBt.selected = NO;
    }
    cell.baseInfoLabel.text = [NSString stringWithFormat:@"%@  %@  %@",name,sex,phone];
    
    NSString *protectedAddress = dict[@"protectedAddress"];
    if ([protectedAddress isMemberOfClass:[NSNull class]]) {
        protectedAddress = @"";
    }
    cell.addressLabel.text = protectedAddress;
    cell.defaultLabel.text = isDefault ? @"默认信息" : @"设为默认";
//    cell.selectBt.selected = isDefault ? YES : NO;
    
    
    cell.selectBlock = ^(){
        NSString *protectedPersonId = dict[@"protectedPersonId"];
        if (![selectedProtectedPersonId isEqualToString:protectedPersonId]) {
            selectedProtectedPersonId = protectedPersonId;
            [tableview reloadData];
        }
        
    };
    cell.deleteBlock = ^(){
        NSLog(@"deleteBlock");
        [self deletProtectedUserInfoWithId:[dict valueForKey:@"protectedPersonId"]];
    };
    cell.editBlock = ^(){
        NSLog(@"edit");
        HeEditProtectUserInfoVC *editProtectUserInfoVC = [[HeEditProtectUserInfoVC alloc] init];
        editProtectUserInfoVC.isEdit = YES;
        editProtectUserInfoVC.hidesBottomBarWhenPushed = YES;
        editProtectUserInfoVC.userInfoDict = [[NSMutableDictionary alloc] initWithDictionary:dict];
        [self.navigationController pushViewController:editProtectUserInfoVC animated:YES];
        
    };

    return  cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    return 115;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
    
    NSDictionary *dict = nil;
    @try {
        dict = dataSource[row];
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
    HeEditProtectUserInfoVC *heEditProtectUserInfoVC = [[HeEditProtectUserInfoVC alloc] init];
    heEditProtectUserInfoVC.hidesBottomBarWhenPushed = YES;
    heEditProtectUserInfoVC.userInfoDict = [[NSMutableDictionary alloc] initWithDictionary:dict];
    [self.navigationController pushViewController:heEditProtectUserInfoVC animated:YES];
//    [_selectDelegate selectUserInfoWithDict:dict];
//    [self.navigationController popViewControllerAnimated:YES];
}

- (void)getDataSource{
    
    [self showHudInView:tableview hint:@"获取中..."];
    NSString *userid = [[NSUserDefaults standardUserDefaults] objectForKey:USERIDKEY];

    NSString *requestUrl = [NSString stringWithFormat:@"%@/protected/selectprotectedbyuserid.action",BASEURL];
    NSDictionary * params  = @{@"userid": userid};
    [AFHttpTool requestWihtMethod:RequestMethodTypePost url:requestUrl params:params success:^(AFHTTPRequestOperation* operation,id response){
        [self hideHud];
        NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        
        NSDictionary *respondDict = [NSDictionary dictionaryWithDictionary:[respondString objectFromJSONString]];
        if ([[[respondDict valueForKey:@"errorCode"] stringValue] isEqualToString:@"200"]) {
            NSLog(@"success");
            id jsonArray = [respondDict valueForKey:@"json"];
            if ([jsonArray isMemberOfClass:[NSNull class]] || jsonArray == nil) {
                jsonArray = [NSArray array];
            }
            [dataSource removeAllObjects];
            [dataSource addObjectsFromArray:jsonArray];
            
            if ([dataSource count] == 0) {
                UIView *bgView = [[UIView alloc] initWithFrame:self.view.bounds];
                UIImage *noImage = [UIImage imageNamed:@"img_no_data_refresh"];
                CGFloat scale = noImage.size.height / noImage.size.width;
                CGFloat imageW = 120;
                CGFloat imageH = imageW * scale;
                UIImageView *imageview = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img_no_data_refresh"]];
                imageview.frame = CGRectMake(100, 100, imageW, imageH);
                imageview.center = bgView.center;
                [bgView addSubview:imageview];
                tableview.backgroundView = bgView;
            }
            
            [tableview reloadData];
        }else{
            NSString *errorInfo = [respondDict valueForKey:@"data"];
            if ([errorInfo isMemberOfClass:[NSNull class]] || errorInfo == nil) {
                errorInfo = ERRORREQUESTTIP;
            }
            [self showHint:errorInfo];
            NSLog(@"faile");
        }
    } failure:^(NSError* err){
        NSLog(@"err:%@",err);
        [self hideHud];
        [self showHint:ERRORREQUESTTIP];
    }];
}

- (void)deletProtectedUserInfoWithId:(NSString *)userId{
    NSString *requestUrl = [NSString stringWithFormat:@"%@/address/deladdressbyid.action",BASEURL];

    NSDictionary * params  = @{@"addressid": userId};
    [AFHttpTool requestWihtMethod:RequestMethodTypePost url:requestUrl params:params success:^(AFHTTPRequestOperation* operation,id response){
        NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        
        NSDictionary *respondDict = [NSDictionary dictionaryWithDictionary:[respondString objectFromJSONString]];
        if ([[[respondDict valueForKey:@"errorCode"] stringValue] isEqualToString:@"200"]) {
            NSLog(@"success");
            [self showHint:[respondDict valueForKey:@"data"]];
            [self getDataSource];
        }else{
            NSString *errorInfo = [respondDict valueForKey:@"data"];
            if ([errorInfo isMemberOfClass:[NSNull class]] || errorInfo == nil) {
                errorInfo = ERRORREQUESTTIP;
            }
            [self showHint:errorInfo];
            NSLog(@"faile");
        }
    } failure:^(NSError* err){
        NSLog(@"err:%@",err);
        [self.view makeToast:ERRORREQUESTTIP duration:2.0 position:@"center"];
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
