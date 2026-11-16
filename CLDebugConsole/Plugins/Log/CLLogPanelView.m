// CLDebugConsole/Plugins/Log/CLLogPanelView.m

#import "CLLogPanelView.h"
#import "CLLogPlugin.h"
#import "CLLogStorage.h"
#import "CLLogEntry.h"
#import "CLLogFilter.h"
#import "CLLogLevel.h"

static const CGFloat kTopToolbarHeight = 50.0;
static const CGFloat kSearchBarHeight = 44.0;

@interface CLLogPanelView () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UIView *topToolbar;
@property (nonatomic, strong) UIButton *saveButton;
@property (nonatomic, strong) UIButton *actionBtn;
@property (nonatomic, strong) UIButton *deleteButton;
@property (nonatomic, strong) UIButton *minimizeButton;
@property (nonatomic, strong) UIButton *fullscreenButton;

@property (nonatomic, strong) UIView *searchBar;
@property (nonatomic, strong) UITextField *searchTextField;
@property (nonatomic, strong) UIButton *levelFilterButton;

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIButton *backToTopButton;

@property (nonatomic, strong) NSArray<CLLogEntry *> *displayedLogs;
@property (nonatomic, strong) NSArray<CLLogEntry *> *allLogs;
@property (nonatomic, assign) BOOL isDetailedMode;
@property (nonatomic, assign) BOOL autoScrollEnabled;
@property (nonatomic, assign) CLLogLevel currentLevelFilter;
@property (nonatomic, assign) BOOL isLevelFilterEnabled;

@end

@implementation CLLogPanelView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
        [self setupNotifications];
        _autoScrollEnabled = YES;
        _isDetailedMode = YES;
        _isLevelFilterEnabled = NO;
        _currentLevelFilter = CLLogLevelInfo;
    }
    return self;
}

- (void)setupUI {
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.85];

    [self setupTopToolbar];
    [self setupSearchBar];
    [self setupTableView];
    [self setupBackToTopButton];
}

- (void)setupTopToolbar {
    _topToolbar = [[UIView alloc] init];
    _topToolbar.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.9];
    [self addSubview:_topToolbar];

    // Left: minimize, fullscreen
    _minimizeButton = [self createToolbarButton:@"CLConsole_zuixiaohua" action:@selector(minimizeTapped)];
    _fullscreenButton = [self createToolbarButton:@"CLConsole_zuidahua" action:@selector(fullscreenTapped)];
    [_topToolbar addSubview:_minimizeButton];
    [_topToolbar addSubview:_fullscreenButton];

    // Right: save, copy, delete
    _saveButton = [self createToolbarButton:@"CLConsole_save" action:@selector(saveTapped)];
    _actionBtn = [self createToolbarButton:@"CLConsole_load" action:@selector(copyTapped)];
    _deleteButton = [self createToolbarButton:@"CLConsole_clear" action:@selector(deleteTapped)];
    [_topToolbar addSubview:_saveButton];
    [_topToolbar addSubview:_actionBtn];
    [_topToolbar addSubview:_deleteButton];
}

- (UIButton *)createToolbarButton:(NSString *)imageName action:(SEL)action {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 30, 30);

    NSBundle *bundle = [NSBundle mainBundle];
    NSString *bundlePath = [bundle pathForResource:@"CLDebugConsole" ofType:@"bundle"];
    UIImage *image = nil;

    if (bundlePath) {
        NSBundle *resourceBundle = [NSBundle bundleWithPath:bundlePath];
        image = [UIImage imageNamed:imageName inBundle:resourceBundle compatibleWithTraitCollection:nil];
    }

    if (!image) {
        image = [UIImage imageNamed:imageName];
    }

    [button setImage:image forState:UIControlStateNormal];
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (void)setupSearchBar {
    _searchBar = [[UIView alloc] init];
    _searchBar.backgroundColor = [[UIColor darkGrayColor] colorWithAlphaComponent:0.5];
    [self addSubview:_searchBar];

    _searchTextField = [[UITextField alloc] init];
    _searchTextField.placeholder = @"Search logs...";
    _searchTextField.textColor = [UIColor whiteColor];
    _searchTextField.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    _searchTextField.layer.cornerRadius = 5;
    _searchTextField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 8, 30)];
    _searchTextField.leftViewMode = UITextFieldViewModeAlways;
    _searchTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _searchTextField.font = [UIFont systemFontOfSize:14];
    [_searchTextField addTarget:self action:@selector(searchTextChanged:) forControlEvents:UIControlEventEditingChanged];
    [_searchBar addSubview:_searchTextField];

    _levelFilterButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [_levelFilterButton setTitle:@"All Levels" forState:UIControlStateNormal];
    [_levelFilterButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_levelFilterButton addTarget:self action:@selector(levelFilterTapped) forControlEvents:UIControlEventTouchUpInside];
    [_searchBar addSubview:_levelFilterButton];
}

- (void)setupTableView {
    _tableView = [[UITableView alloc] init];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"LogCell"];
    [self addSubview:_tableView];
}

- (void)setupBackToTopButton {
    _backToTopButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [_backToTopButton setTitle:@"Back to Top" forState:UIControlStateNormal];
    [_backToTopButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _backToTopButton.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.7];
    _backToTopButton.layer.cornerRadius = 15;
    _backToTopButton.hidden = YES;
    [_backToTopButton addTarget:self action:@selector(backToTopTapped) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_backToTopButton];
}

- (void)setupNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleNewLog:)
                                                 name:@"CLLogStorageDidAddLog"
                                               object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)layoutSubviews {
    [super layoutSubviews];

    CGFloat width = self.bounds.size.width;
    CGFloat topY = 0;

    _topToolbar.frame = CGRectMake(0, topY, width, kTopToolbarHeight);
    topY += kTopToolbarHeight;

    _searchBar.frame = CGRectMake(0, topY, width, kSearchBarHeight);
    topY += kSearchBarHeight;

    CGFloat remainingHeight = self.bounds.size.height - topY;
    _tableView.frame = CGRectMake(0, topY, width, remainingHeight);

    // Position toolbar buttons
    CGFloat btnPadding = 10;
    CGFloat btnSize = 30;
    CGFloat btnSpacing = 8;

    _minimizeButton.frame = CGRectMake(btnPadding, (kTopToolbarHeight - btnSize) / 2.0, btnSize, btnSize);
    _fullscreenButton.frame = CGRectMake(btnPadding + btnSize + btnSpacing, (kTopToolbarHeight - btnSize) / 2.0, btnSize, btnSize);

    _deleteButton.frame = CGRectMake(width - btnPadding - btnSize, (kTopToolbarHeight - btnSize) / 2.0, btnSize, btnSize);
    _actionBtn.frame = CGRectMake(width - btnPadding - btnSize * 2 - btnSpacing, (kTopToolbarHeight - btnSize) / 2.0, btnSize, btnSize);
    _saveButton.frame = CGRectMake(width - btnPadding - btnSize * 3 - btnSpacing * 2, (kTopToolbarHeight - btnSize) / 2.0, btnSize, btnSize);

    // Position search bar elements
    CGFloat searchPadding = 10;
    _searchTextField.frame = CGRectMake(searchPadding, 7, width - 120, 30);
    _levelFilterButton.frame = CGRectMake(width - 110, 7, 100, 30);

    // Position back to top button
    CGFloat btnWidth = 100;
    CGFloat btnHeight = 30;
    _backToTopButton.frame = CGRectMake((width - btnWidth) / 2.0,
                                         self.bounds.size.height - btnHeight - 10,
                                         btnWidth, btnHeight);
}

#pragma mark - Public

- (void)refreshLogs {
    CLLogPlugin *plugin = [CLLogPlugin sharedPlugin];
    self.allLogs = [plugin allLogs];

    CLLogFilter *filter = [CLLogFilter defaultFilter];

    NSString *keyword = self.searchTextField.text;
    if (keyword.length > 0) {
        filter.keyword = keyword;
    }

    if (self.isLevelFilterEnabled) {
        filter.level = self.currentLevelFilter;
        filter.levelFilterEnabled = YES;
    }

    self.displayedLogs = [[CLLogStorage sharedStorage] logsWithFilter:filter];

    [self.tableView reloadData];

    if (self.autoScrollEnabled && self.displayedLogs.count > 0) {
        NSIndexPath *lastIndex = [NSIndexPath indexPathForRow:self.displayedLogs.count - 1 inSection:0];
        [self.tableView scrollToRowAtIndexPath:lastIndex atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

- (void)setDisplayMode:(BOOL)isDetailed {
    _isDetailedMode = isDetailed;
    [self.tableView reloadData];
}

#pragma mark - Actions

- (void)handleNewLog:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self refreshLogs];
    });
}

- (void)searchTextChanged:(UITextField *)textField {
    [self refreshLogs];
}

- (void)levelFilterTapped {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Filter by Level"
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];

    [alert addAction:[UIAlertAction actionWithTitle:@"All Levels" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        self.isLevelFilterEnabled = NO;
        [self.levelFilterButton setTitle:@"All Levels" forState:UIControlStateNormal];
        [self refreshLogs];
    }]];

    [alert addAction:[UIAlertAction actionWithTitle:@"Info" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self filterByLevel:CLLogLevelInfo title:@"Info"];
    }]];

    [alert addAction:[UIAlertAction actionWithTitle:@"Warning" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self filterByLevel:CLLogLevelWarning title:@"Warning"];
    }]];

    [alert addAction:[UIAlertAction actionWithTitle:@"Error" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self filterByLevel:CLLogLevelError title:@"Error"];
    }]];

    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];

    UIViewController *parentVC = [self findViewController];
    if (parentVC) {
        [parentVC presentViewController:alert animated:YES completion:nil];
    }
}

- (void)filterByLevel:(CLLogLevel)level title:(NSString *)title {
    [self.levelFilterButton setTitle:title forState:UIControlStateNormal];
    self.isLevelFilterEnabled = YES;
    self.currentLevelFilter = level;
    [self refreshLogs];
}

- (UIViewController *)findViewController {
    UIResponder *responder = self;
    while (responder) {
        responder = [responder nextResponder];
        if ([responder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)responder;
        }
    }
    return nil;
}

- (void)minimizeTapped {
    // Delegate to CLDebugConsole
}

- (void)fullscreenTapped {
    // Delegate to CLDebugConsole
}

- (void)saveTapped {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Export Logs"
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];

    [alert addAction:[UIAlertAction actionWithTitle:@"Export as Text" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self exportAsText];
    }]];

    [alert addAction:[UIAlertAction actionWithTitle:@"Export as JSON" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self exportAsJSON];
    }]];

    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];

    UIViewController *parentVC = [self findViewController];
    if (parentVC) {
        [parentVC presentViewController:alert animated:YES completion:nil];
    }
}

- (void)exportAsText {
    [[CLLogPlugin sharedPlugin] exportAsText:^(NSString *filePath) {
        [self shareFile:filePath];
    }];
}

- (void)exportAsJSON {
    [[CLLogPlugin sharedPlugin] exportAsJSON:^(NSString *filePath) {
        [self shareFile:filePath];
    }];
}

- (void)shareFile:(NSString *)filePath {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSURL *fileURL = [NSURL fileURLWithPath:filePath];
        UIActivityViewController *activity = [[UIActivityViewController alloc] initWithActivityItems:@[fileURL] applicationActivities:nil];
        UIViewController *parentVC = [self findViewController];
        if (parentVC) {
            [parentVC presentViewController:activity animated:YES completion:nil];
        }
    });
}

- (void)copyTapped {
    NSMutableString *allText = [NSMutableString string];
    for (CLLogEntry *entry in self.displayedLogs) {
        [allText appendFormat:@"%@\n", [entry formattedString]];
    }
    [UIPasteboard generalPasteboard].string = allText;

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Copied"
                                                                   message:@"Logs copied to clipboard"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    UIViewController *parentVC = [self findViewController];
    if (parentVC) {
        [parentVC presentViewController:alert animated:YES completion:nil];
    }
}

- (void)deleteTapped {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Clear Logs"
                                                                   message:@"Are you sure you want to clear all logs?"
                                                            preferredStyle:UIAlertControllerStyleAlert];

    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Clear" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        [[CLLogPlugin sharedPlugin] clearLogs];
    }]];

    UIViewController *parentVC = [self findViewController];
    if (parentVC) {
        [parentVC presentViewController:alert animated:YES completion:nil];
    }
}

- (void)backToTopTapped {
    if (self.displayedLogs.count > 0) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                              atScrollPosition:UITableViewScrollPositionTop
                                      animated:YES];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.displayedLogs ? self.displayedLogs.count : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LogCell" forIndexPath:indexPath];

    CLLogEntry *entry = self.displayedLogs[indexPath.row];

    // Remove old labels
    for (UIView *subview in cell.contentView.subviews) {
        [subview removeFromSuperview];
    }

    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    NSString *text = _isDetailedMode ? [entry formattedString] : [entry simpleString];
    UIColor *color = CLLogLevelColor(entry.level);

    UILabel *label = [[UILabel alloc] init];
    label.text = text;
    label.textColor = color;
    label.font = [UIFont fontWithName:@"Menlo" size:11];
    label.numberOfLines = 0;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.tag = 100;
    [cell.contentView addSubview:label];

    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    // Layout the label
    UILabel *label = [cell.contentView viewWithTag:100];
    if ([label isKindOfClass:[UILabel class]]) {
        CGFloat padding = 8;
        CGFloat maxWidth = tableView.bounds.size.width - padding * 2;
        CGSize size = [label sizeThatFits:CGSizeMake(maxWidth, CGFLOAT_MAX)];
        label.frame = CGRectMake(padding, 4, maxWidth, size.height);
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!self.displayedLogs || indexPath.row >= self.displayedLogs.count) {
        return 44;
    }

    CLLogEntry *entry = self.displayedLogs[indexPath.row];
    NSString *text = _isDetailedMode ? [entry formattedString] : [entry simpleString];

    CGFloat padding = 8;
    CGFloat maxWidth = tableView.bounds.size.width - padding * 2;
    if (maxWidth <= 0) {
        maxWidth = [UIScreen mainScreen].bounds.size.width - padding * 2;
    }
    UIFont *font = [UIFont fontWithName:@"Menlo" size:11];
    CGSize size = [text boundingRectWithSize:CGSizeMake(maxWidth, CGFLOAT_MAX)
                                     options:NSStringDrawingUsesLineFragmentOrigin
                                  attributes:@{NSFontAttributeName: font}
                                     context:nil].size;
    return size.height + 8;
}

#pragma mark - UITableViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    BOOL isAtBottom = (scrollView.contentOffset.y >= scrollView.contentSize.height - scrollView.bounds.size.height - 50);
    self.autoScrollEnabled = isAtBottom;
    self.backToTopButton.hidden = isAtBottom;
}

@end
