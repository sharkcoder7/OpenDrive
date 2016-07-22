//
//  FilesScreenVC.m
//  OpenDrive
//
//  Created by Bin Jin on 1/13/16.
//  Copyright © 2016 Bin Jin. All rights reserved.
//

#import "FilesScreenVC.h"
#import "config.h"
#import "SideBar.h"
#import "SWTableViewCell.h"
#import "FilesTableViewCell.h"
#import "WelcomeVC.h"
#import "SVPullToRefresh.h"
#import "DataKeeper.h"
#import "UserDataModel.h"
#import "HttpClient.h"
#import "SVProgressHUD.h"
#import "FolderDataModel.h"
#import "UIImageView+AFNetworking.h"
#import "BrandDataModel.h"
#import "RenameVC.h"
#import "PreviewVC.h"

@interface FilesScreenVC () <SideBarDelegate, UITableViewDelegate, UITableViewDataSource, UITabBarDelegate, UISearchBarDelegate, SWTableViewCellDelegate, UIGestureRecognizerDelegate, SideBarDelegate>

@property (strong, nonatomic) IBOutlet UITabBar *tabbarTool;
@property (strong, nonatomic) IBOutlet UIButton *buttonAddItem;
@property (strong, nonatomic) IBOutlet UITableView *tableViewExplorer;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *tabBarBottomLC;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *buttonAddItemLC;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *searchBarLC;
@property (strong, nonatomic) IBOutlet SideBar *menuSideBar;

@property (strong, nonatomic) UITapGestureRecognizer    *tap;

@property (strong, nonatomic) NSString *searchQuery;

- (IBAction)addItemAction:(id)sender;

- (void)initNavigationItems;

- (void)initPullToRefresh;
- (void)insertRowAtTop;

- (void)getListFolderContent:(NSDictionary *)content;

- (UIImage *)makeThumbnail:(UIImage *)image OfSize:(CGSize)size;

- (void)loadData;

@end

@implementation FilesScreenVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    self.navigationController.navigationBarHidden = NO;
    
    [self initSideBar];
   
    _tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
    _tap.delegate = self;
    _tap.enabled = NO;
    [self.navigationController.view addGestureRecognizer:_tap];
    
    WelcomeVC *welcomeVC = [self.storyboard instantiateViewControllerWithIdentifier:@"WelcomeVC"];
    self.navigationController.viewControllers = @[welcomeVC, self];
    
    [self initNavigationItems];
    [self initPullToRefresh];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self initNavigationBar];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)initSideBar
{
    _menuSideBar.delegate = self;
    [_menuSideBar initSwipeGesture:self];
}

- (void)initPullToRefresh
{
    __weak FilesScreenVC *weakSelf = self;
    
    // setup pull-to-refresh
    [self.tableViewExplorer addPullToRefreshWithActionHandler:^{
        [weakSelf insertRowAtTop];
    }];
    
    [self.tableViewExplorer triggerPullToRefresh];    
}

- (void)insertRowAtTop
{
    DataKeeper *dataKeeper = [DataKeeper sharedInstance];
    
    if (dataKeeper.userDataModel.sessionID == nil)
    {
        int64_t delayInSeconds = 2.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self loadData];
        });
        
        return;
    }
    
    int64_t delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self loadData];
    });
}

- (void)initNavigationItems
{
    UIBarButtonItem *menuItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu.png"] style:UIBarButtonItemStyleDone target:self action:@selector(menuAction:)];
    self.navigationItem.leftBarButtonItem = menuItem;
    
    UIBarButtonItem *thumbItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"thumbnail.png"] style:UIBarButtonItemStyleDone target:self action:@selector(thumbAction:)];
    UIBarButtonItem *searchItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"search.png"] style:UIBarButtonItemStyleDone target:self action:@selector(searchAction:)];
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:searchItem, thumbItem, nil];

    DataKeeper *dataKeeper = [DataKeeper sharedInstance];
    self.navigationItem.title = dataKeeper.currentBrandDataModel.driveName;
    
    [self initNavigationBar];
}

- (void)initNavigationBar
{
    DataKeeper *dataKeeper = [DataKeeper sharedInstance];
    
    [self.navigationController.navigationBar setBarTintColor:dataKeeper.currentBrandDataModel.menuColor];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:dataKeeper.currentBrandDataModel.fontColor}];
    
    _menuSideBar.backgroundColor = dataKeeper.currentBrandDataModel.menuColor;
}

- (UIImage *)makeThumbnail:(UIImage *)image OfSize:(CGSize)size
{
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *thumbnail = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return thumbnail;
}

- (void)showSearchBar:(BOOL)bShow
{
    [self.view layoutIfNeeded];
    
    if (bShow)
        _searchBarLC.constant = 0;
    else
        _searchBarLC.constant = -44;
    
    [_searchBar resignFirstResponder];
    
    [UIView animateWithDuration:0.25 animations:^{
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self.view updateConstraintsIfNeeded];
    }];
    
    _tap.enabled = bShow;
}

- (void)closeSession
{
    void (^failureBlock)(NSError *) = ^(NSError *error)
    {
        [SVProgressHUD showErrorWithStatus:error.localizedDescription];
    };
    void (^successBlock)(NSDictionary *responseDic) = ^(NSDictionary *responseDic)
    {
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSDictionary *dic = [prefs dictionaryRepresentation];
        for (id key in dic) {
            [prefs removeObjectForKey:key];
        }
        [prefs synchronize];
        
        DataKeeper *dataKeeper = [DataKeeper sharedInstance];
        [dataKeeper.currentFolderDataModel.arrayFiles removeAllObjects];
        [dataKeeper.currentFolderDataModel.subFolders removeAllObjects];
        [dataKeeper.currentFolderDataModel reset];
        
        [self.navigationController popToRootViewControllerAnimated:YES];
    };
    
    DataKeeper *dataKeeper = [DataKeeper sharedInstance];
    NSDictionary *param = [NSDictionary dictionaryWithObjectsAndKeys:dataKeeper.userDataModel.sessionID, @"session_id", nil];
    
    [[HttpClient sharedClient] post:Post_SessionLogOutURL
                          withParam:param
                   withSuccessBlock:successBlock
                   withFailureBlock:failureBlock];
}

- (void)loadData
{
    __weak FilesScreenVC *weakSelf = self;
    
    void (^failureBlock)(NSError *) = ^(NSError *error)
    {
        [SVProgressHUD showErrorWithStatus:error.localizedDescription];
        
        [weakSelf.tableViewExplorer.pullToRefreshView stopAnimating];
    };
    void (^successBlock)(NSDictionary *responseDic) = ^(NSDictionary *responseDic)
    {
        [SVProgressHUD dismiss];
        
        [self getListFolderContent:responseDic];
        
        [weakSelf.tableViewExplorer reloadData];
        [weakSelf.tableViewExplorer.pullToRefreshView stopAnimating];
    };
    
    DataKeeper *dataKeeper = [DataKeeper sharedInstance];
    
    NSString *getUrl = nil;
    if (dataKeeper.currentFolderDataModel.folderID != nil)
        getUrl = [NSString stringWithFormat:@"%@/%@/%@", Get_ListFolderContentURL, dataKeeper.userDataModel.sessionID, dataKeeper.currentFolderDataModel.folderID];
    else
    {
        if ([dataKeeper.currentFolderDataModel isRootFolder])
            getUrl = [NSString stringWithFormat:@"%@/%@/0", Get_ListFolderContentURL, dataKeeper.userDataModel.sessionID];
        else
            getUrl = [NSString stringWithFormat:@"%@/%@", Get_ListFolderContentURL, dataKeeper.userDataModel.sessionID];
    }
    
    NSDictionary *param = [[HttpClient sharedClient] getListFolderContentParams:_searchQuery RequestTime:0/*dataKeeper.currentFolderDataModel.lastRequestTime*/ SharingId:nil EncryptionSupported:dataKeeper.currentFolderDataModel.encrypted];
    
    [[HttpClient sharedClient] get:getUrl withParam:param withSuccessBlock:successBlock withFailureBlock:failureBlock];
}

- (void)getListFolderContent:(NSDictionary*)content
{
    DataKeeper *dataKeeper = [DataKeeper sharedInstance];
    if ([dataKeeper.arrayPaths containsObject:dataKeeper.currentFolderDataModel] == NO)
    {
        [dataKeeper.arrayPaths addObject:dataKeeper.currentFolderDataModel];
        dataKeeper.pathDepth ++;
    }
    
    if (dataKeeper.pathDepth > 0)
    {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"arrowleft"] style:UIBarButtonItemStyleDone target:self action:@selector(backAction:)];
        self.navigationItem.title = dataKeeper.currentFolderDataModel.folderName;
    }
    else
    {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu.png"] style:UIBarButtonItemStyleDone target:self action:@selector(menuAction:)];
        self.navigationItem.title = dataKeeper.userDataModel.driveName;
    }

    [dataKeeper.currentFolderDataModel.arrayFiles removeAllObjects];
    [dataKeeper.currentFolderDataModel.subFolders removeAllObjects];
    [dataKeeper.currentFolderDataModel initFolderDatModel:content];
    dataKeeper.lastRequestTime = dataKeeper.currentFolderDataModel.lastRequestTime;
}

- (NSString *)getFileInfo:(FileDataModel *)file
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:file.dateModified];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMM dd, yyyy"];
    NSString *stringFromDate = [dateFormatter stringFromDate:date];
    NSString *stringDetail = [NSString stringWithFormat:@"%@ %@", [NSByteCountFormatter stringFromByteCount:file.fileSize countStyle:NSByteCountFormatterCountStyleFile], stringFromDate];
    
    return stringDetail;
}

- (NSArray *)rightButtons
{
    NSMutableArray *leftUtilityButtons = [NSMutableArray new];
    
    UIColor *bgColor = [UIColor colorWithRed:242.0f/255.0f green:242.0f/255.0f blue:242.0f/255.0f alpha:1.0f];
    [leftUtilityButtons sw_addUtilityButtonWithColor:bgColor icon:[UIImage imageNamed:@"edit.png"]];
    [leftUtilityButtons sw_addUtilityButtonWithColor:bgColor icon:[UIImage imageNamed:@"share.png"]];
    [leftUtilityButtons sw_addUtilityButtonWithColor:bgColor icon:[UIImage imageNamed:@"file_setting.png"]];
    [leftUtilityButtons sw_addUtilityButtonWithColor:bgColor icon:[UIImage imageNamed:@"delete.png"]];
    
    return leftUtilityButtons;
}

- (BOOL)IsImageContentTypeForData:(NSData *)data
{
    uint8_t c;
    [data getBytes:&c length:1];
    
    if (c == 0xFF || c == 0x89 || c == 0x47 || c== 0x42 || c == 0x4D)
        return YES;
    
    return NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation
 
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
// Get the new view controller using [segue destinationViewController].
// Pass the selected object to the new view controller.
}

#pragma mark - Action

- (void)menuAction:(id)sender
{
    [self.view layoutIfNeeded];
    
    if (_menuSideBar.isOpenSideBar)
    {
        [_menuSideBar hide];
        _tap.enabled = NO;
    }
    else
    {
        _tap.enabled = YES;
        [_menuSideBar show];
    }
}

- (IBAction)addItemAction:(id)sender
{
    [self.view layoutIfNeeded];
    
    _buttonAddItemLC.constant = -39;
    [UIView animateWithDuration:0.25 animations:^{
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        _tabBarBottomLC.constant = 0;
        
        [UIView animateWithDuration:0.25 animations:^{
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            
        }];
    }];
}

- (void)thumbAction:(id)sender
{
}

- (void)searchAction:(id)sender
{
    [self showSearchBar:YES];
}

- (void)tapAction
{
    [_menuSideBar hide];
    [self showSearchBar:NO];
}

- (void)backAction:(id)sender
{
    DataKeeper *dataKeeper = [DataKeeper sharedInstance];
    if (dataKeeper.pathDepth <= 0)
        return;
    
    [SVProgressHUD show];
    
    [dataKeeper.arrayPaths removeObject:dataKeeper.currentFolderDataModel];
    dataKeeper.pathDepth --;
    FolderDataModel *folder = [dataKeeper.arrayPaths lastObject];
    [dataKeeper setCurrentFolderDataModel:folder];
    [self loadData];
}

#pragma mark - Tabbar Delegate

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    [self.view layoutIfNeeded];
    
    _tabBarBottomLC.constant = -49;
    
    [UIView animateWithDuration:0.25 animations:^{
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self.view updateConstraintsIfNeeded];
        _buttonAddItemLC.constant = 0;
        
        [UIView animateWithDuration:0.25 animations:^{
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            [self.view updateConstraintsIfNeeded];
        }];
    }];
}

#pragma mark - TableView DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    DataKeeper *dataKeeper = [DataKeeper sharedInstance];
    NSInteger count = dataKeeper.currentFolderDataModel.subFolders.count + dataKeeper.currentFolderDataModel.arrayFiles.count;
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DataKeeper *dataKeeper = [DataKeeper sharedInstance];
    
    if (indexPath.row < dataKeeper.currentFolderDataModel.subFolders.count)
    {
        UITableViewCell *cell = [_tableViewExplorer dequeueReusableCellWithIdentifier:@"FolderCell" forIndexPath:indexPath];
        FolderDataModel *folder = [dataKeeper.currentFolderDataModel.subFolders objectAtIndex:indexPath.row];
        [cell.imageView setImage:[UIImage imageNamed:@"newfolder.png"]];
        cell.textLabel.text = folder.folderName;
        [cell.textLabel setTextColor:Folder_Text_Color];
        
        return cell;
    }
    else
    {
        FilesTableViewCell *cell = [_tableViewExplorer dequeueReusableCellWithIdentifier:@"FileCell" forIndexPath:indexPath];
        
        NSInteger index = indexPath.row - dataKeeper.currentFolderDataModel.subFolders.count;
        FileDataModel *file = [dataKeeper.currentFolderDataModel.arrayFiles objectAtIndex:index];

        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:file.thumbLink]];

        __unsafe_unretained FilesTableViewCell *weakCell = cell;
        
        [cell.imageView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
        {
            [weakCell.imageView setImage:[self makeThumbnail:image OfSize:CGSizeMake(32, 32)]];
            [weakCell setNeedsLayout];
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)
        {
        }];
        
        cell.textLabel.text = file.fileName;
        cell.textLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        [cell.textLabel setTextColor:Folder_Text_Color];
        
        cell.detailTextLabel.text = [self getFileInfo:file];
        cell.detailTextLabel.textColor = SizeDate_Text_Color;
        
        [cell setRightUtilityButtons:[self rightButtons] WithButtonWidth:90.0f];
        cell.delegate = self;
        
        return cell;
    }
}

#pragma mark - TableView Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return Default_TableViewCell_Height;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DataKeeper *dataKeeper = [DataKeeper sharedInstance];
    if (indexPath.row < dataKeeper.currentFolderDataModel.subFolders.count)
    {
        FolderDataModel *folder = [dataKeeper.currentFolderDataModel.subFolders objectAtIndex:indexPath.row];
        [dataKeeper setCurrentFolderDataModel:folder];
        [SVProgressHUD show];
        [self loadData];
    }
    else
    {
        NSInteger index = indexPath.row - dataKeeper.currentFolderDataModel.subFolders.count;
        FileDataModel *file = [dataKeeper.currentFolderDataModel.arrayFiles objectAtIndex:index];
        [dataKeeper setCurrentFileDataModel:file];
        PreviewVC *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"PreviewVC"];
        self.navigationItem.title = nil;
//        self.navigationController.navigationBar.translucent = NO;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - UISearchBar Delegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self showSearchBar:NO];
}

#pragma mark - SWTableViewDelegate

- (void)swipeableTableViewCell:(SWTableViewCell *)cell scrollingToState:(SWCellState)state
{
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index
{
    switch (index) {
        case 0:
        {
            [cell hideUtilityButtonsAnimated:YES];
            [_menuSideBar hide];
            [self showSearchBar:NO];
            
            NSLog(@"edit button was pressed");
            
            DataKeeper *dataKeeper = [DataKeeper sharedInstance];
            NSIndexPath *indexPath = [self.tableViewExplorer indexPathForCell:cell];
            NSInteger index = indexPath.row - dataKeeper.currentFolderDataModel.subFolders.count;
            FileDataModel *file = [dataKeeper.currentFolderDataModel.arrayFiles objectAtIndex:index];
            
            RenameVC *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"RenameVC"];
            vc.fileDataModel = file;
            self.navigationItem.title = nil;
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 1:
            NSLog(@"share button was pressed");
            break;
        case 2:
            NSLog(@"setting button was pressed");
            break;
        case 3:
            NSLog(@"delete button was pressed");
        default:
            break;
    }
}

- (BOOL)swipeableTableViewCellShouldHideUtilityButtonsOnSwipe:(SWTableViewCell *)cell
{
    // allow just one cell's utility button to be open at once
    return YES;
}

- (BOOL)swipeableTableViewCell:(SWTableViewCell *)cell canSwipeToState:(SWCellState)state
{
    [_menuSideBar hide];
    [self showSearchBar:NO];
    
    switch (state) {
        case 1:
            // set to NO to disable all left utility buttons appearing
            return YES;
            break;
        case 2:
            // set to NO to disable all right utility buttons appearing
            return YES;
            break;
        default:
            break;
    }
    
    return YES;
}

#pragma mark - SideBar Delegate

- (void)tapMenuItem:(SideBarItem)selectedItem
{
    [_menuSideBar selectedMenuItem:selectedItem];
    switch (selectedItem) {
        case SELECTED_EXPLORER:
            break;
        case SELECTED_SETTING:
            break;
        case SELECTED_LOGOUT:
        {
            [_menuSideBar hide];
            [self closeSession];
        }
            break;
        default:
            break;
    }
}

@end
