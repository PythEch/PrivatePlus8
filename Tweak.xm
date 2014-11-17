#import "Tweak.h"
#import "substrate.h"
#import <UIKit/UITableView.h>
#import <UIKit/UISwitch.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreGraphics/CoreGraphics.h>

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_TWEAK_ENABLED (isSwitchON && isThereAnyBlacklistedTab && !didUserEnterIncognito)
#define BLACKLIST_PATH @"/var/mobile/Library/Preferences/inpornito.plist"

NSMutableArray *blacklist;
NSMutableDictionary *blacklistedTabs;
BOOL isThereAnyBlacklistedTab;
BOOL didUserEnterIncognito;
BOOL isSwitchON;
BOOL swagExists;

%ctor {
    NSDictionary *plist = [NSDictionary dictionaryWithContentsOfFile:BLACKLIST_PATH];
    blacklist = plist[@"Filters"] ? [plist[@"Filters"] mutableCopy] : [NSMutableArray array];
    isSwitchON = [plist[@"isEnabled"] boolValue];
    blacklistedTabs = [NSMutableDictionary dictionary];
    isThereAnyBlacklistedTab = NO;
    didUserEnterIncognito = NO;
    swagExists = YES;
}

void saveSettings() {
    NSDictionary *plist = @{@"Filters": blacklist, @"isEnabled": @(isSwitchON)};
    [plist writeToFile:BLACKLIST_PATH atomically:NO];
}

void setIncognitoMode(BrowserController *bc, BOOL newValue) {
    [bc writePrivateBrowsingPreference:newValue];
    [bc updatePrivateBrowsingPreferences];

    didUserEnterIncognito = NO; // *we* set the incognito mode, not the user :)
}

NSString *checkIfLinkIsFiltered(NSString *link) {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%@ LIKE[cd] SELF", link]; // don't build predicate every time
    for (NSString *filter in blacklist) {
        if ([predicate evaluateWithObject:filter]) {
            return filter;
        }
    }

    return nil;
}

@interface SwagClass : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextViewDelegate>
@property (assign) UITextView *textView;
@property (assign) UITableView *tableView;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
- (void) doAlertWithTableView;
- (void) switchChanged:(id)sender;
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;
- (void) reverseSwag:(id)sender;
- (void) swag:(id)sender;
- (void) completeSwag:(id)sender;
@end

@implementation SwagClass : UIViewController
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 0 && indexPath.row == 0) {
        UITableViewCell* switchCell = [tableView dequeueReusableCellWithIdentifier:@"switchCell"];
        if(switchCell == nil) {
            switchCell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"switchCell"] autorelease];
            switchCell.textLabel.text = @"inpornito";
            switchCell.selectionStyle = UITableViewCellSelectionStyleNone;
            UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
            switchCell.accessoryView = switchView;
            [switchView setOn:isSwitchON animated:NO];
            [switchView addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
            [switchView release];
        }
        return switchCell;
    }
    else if(indexPath.section == 1 && indexPath.row == 0){
    //UITextView add filter
        UITableViewCell *textCell = [tableView dequeueReusableCellWithIdentifier:@"textCell"];
        if (textCell == nil) {
            textCell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"textCell"] autorelease];
            self.textView = [[UITextView alloc] initWithFrame:CGRectMake(textCell.frame.origin.x, textCell.frame.origin.y, textCell.frame.size.width, tableView.rowHeight)];
            self.textView.delegate = self;
            [textCell.contentView addSubview:self.textView];
            [self.textView release];
        }
        return textCell;
    } else if (indexPath.section == 1 && indexPath.row == 1) {
    //UIButton submit button, FIX IT'S FUCKING LOOK
        UITableViewCell *reverseSwagCell = [tableView dequeueReusableCellWithIdentifier:@"reverseSwagCell"];
        if (reverseSwagCell == nil) {
            reverseSwagCell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"reverseSwagCell"] autorelease];
            UIButton *reverseSwagButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [reverseSwagButton addTarget:self action:@selector(reverseSwag:) forControlEvents:UIControlEventTouchUpInside];
            [reverseSwagButton setTitle:@"add filter" forState:UIControlStateNormal];
            [reverseSwagButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            reverseSwagButton.frame = CGRectMake(reverseSwagCell.frame.origin.x, reverseSwagCell.frame.origin.y, reverseSwagCell.frame.size.width, tableView.rowHeight);
            [reverseSwagCell.contentView addSubview:reverseSwagButton];
        }
        reverseSwagCell.selectionStyle = UITableViewCellSelectionStyleNone;
        return reverseSwagCell;
    } else if (indexPath.section == 2 && indexPath.row == 0) {
        if (IS_TWEAK_ENABLED && swagExists) {
        //UIButton remove from blacklist button, FIX IT'S FUCKING LOOK
            UITableViewCell *swagCell = [tableView dequeueReusableCellWithIdentifier:@"swagCell"];
            if (swagCell == nil) {
                swagCell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"swagCell"] autorelease];
                UIButton *swagButton = [UIButton buttonWithType:UIButtonTypeCustom];
                [swagButton addTarget:self action:@selector(swag:) forControlEvents:UIControlEventTouchUpInside];
                [swagButton setTitle:@"remove current filter" forState:UIControlStateNormal];
                [swagButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                swagButton.frame = CGRectMake(swagCell.frame.origin.x, swagCell.frame.origin.y, swagCell.frame.size.width, tableView.rowHeight);
                [swagCell.contentView addSubview:swagButton];
            }
            swagCell.selectionStyle = UITableViewCellSelectionStyleNone;
            return swagCell;
        } else {
        //regular table cell, complete filter remove
            UITableViewCell *completeSwagCell = [tableView dequeueReusableCellWithIdentifier:@"completeSwagCell"];
            if (completeSwagCell == nil) {
                completeSwagCell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"completeSwagCell"] autorelease];
                UIButton *completeSwagButton = [UIButton buttonWithType:UIButtonTypeCustom];
                [completeSwagButton addTarget:self action:@selector(completeSwag:) forControlEvents:UIControlEventTouchUpInside];
                [completeSwagButton setTitle:@"remove all filters" forState:UIControlStateNormal];
                [completeSwagButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                completeSwagButton.frame = CGRectMake(completeSwagCell.frame.origin.x, completeSwagCell.frame.origin.y, completeSwagCell.frame.size.width, tableView.rowHeight);
                [completeSwagCell.contentView addSubview:completeSwagButton];
            }
            completeSwagCell.selectionStyle = UITableViewCellSelectionStyleNone;
            return completeSwagCell;
            swagExists = YES;
        }
    } else if (indexPath.section == 2 && indexPath.row == 1) {
        //regular table cell, complete filter remove
        UITableViewCell *completeSwagCell = [tableView dequeueReusableCellWithIdentifier:@"completeSwagCell"];
        if (completeSwagCell == nil) {
            completeSwagCell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"completeSwagCell"] autorelease];
            UIButton *completeSwagButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [completeSwagButton addTarget:self action:@selector(completeSwag:) forControlEvents:UIControlEventTouchUpInside];
            [completeSwagButton setTitle:@"remove all filters" forState:UIControlStateNormal];
            [completeSwagButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            completeSwagButton.frame = CGRectMake(completeSwagCell.frame.origin.x, completeSwagCell.frame.origin.y, completeSwagCell.frame.size.width, tableView.rowHeight);
            [completeSwagCell.contentView addSubview:completeSwagButton];
        }
        completeSwagCell.selectionStyle = UITableViewCellSelectionStyleNone;
        return completeSwagCell;
    } else if (indexPath.section == 3 && indexPath.row == 0) {
    //if exists, regular table cell, credits
        UITableViewCell *creditCell = [tableView dequeueReusableCellWithIdentifier:@"creditCell"];
        if (creditCell == nil) {
            creditCell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"creditCell"] autorelease];
        }
        creditCell.selectionStyle = UITableViewCellSelectionStyleNone;
        creditCell.textLabel.text = @"Made by Cool-Aid Club";
        return creditCell;
    } else {
        NSLog(@"lolk section:%li row:%li", (long)indexPath.section, (long)indexPath.row);
        UITableViewCell *failCell = [tableView dequeueReusableCellWithIdentifier:@"failCell"];
        if (failCell == nil) {
            failCell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"failCell"] autorelease];
        }
        failCell.selectionStyle = UITableViewCellSelectionStyleNone;
        failCell.textLabel.text = @"ur an failur";
        return failCell;
    }
}

- (void)completeSwag:(id)sender {
    //ask user in an actionsheet, then remove all filters.
}

- (void)reverseSwag:(id)sender {
    //done: add some kind of filter
    NSString *regexString = @"^((https?:\\/\\/|\\*)(([\\da-z\\.*?-]+)\\.([a-z\\.*?]{2,}).*\\/?|(.+)?\\*)\\*?|\\*)$";
    NSString *addedFilter = self.textView.text;
    NSPredicate *regexPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regexString];
    if ([regexPredicate evaluateWithObject:addedFilter]){
      [blacklist addObject:addedFilter];
      saveSettings();
      NSLog(@"new blacklist is %@", blacklist);
      self.textView.text = @"";
    }
    else{
      NSLog(@"invalid filter d00d");
      //tell user somehow
    }
}

- (void)swag:(id)sender {
    //done: make the button disappear
    BrowserController *bc = [%c(BrowserController) sharedBrowserController];
    NSString *filter = [blacklistedTabs objectForKey:[NSValue valueWithPointer:[[bc tabController] activeTabDocument]]]; //fix this
    [blacklist removeObject:filter];
    saveSettings();
    NSLog(@"new blacklist is %@", blacklist);
    swagExists = NO;
    [self.tableView reloadData];
}
- (void)switchChanged:(id)sender {
    UISwitch* switchControl = sender;
    NSLog( @"The switch is %@", switchControl.on ? @"ON" : @"OFF" );
    isSwitchON = switchControl.on;
    saveSettings();
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    // Return the number of rows in the section.
    // If you're serving data from an array, return the length of the array:
    switch (section) {
        case 0:
        case 3:
            return 1;
            break;
        case 1:
            return 2;
            break;
        case 2:
            if(IS_TWEAK_ENABLED && swagExists){return 2;break;}
            else{return 1;break;}
        default:
            NSLog(@"well fuck section:%li", (long)section);
            return 5;
            break;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    NSString *sectionTitle;
    switch (section) {
        case 0:
            sectionTitle = @"on/off";
            break;
        case 1:
            sectionTitle = @"add blacklist filter";
            break;
        case 2:
          if(IS_TWEAK_ENABLED && swagExists){
              sectionTitle = @"remove current filter";
              break;
          }
          else{
              sectionTitle = nil;
              break;
          }
        case 3:
            sectionTitle = nil;
            break;
        default:
            sectionTitle = @"faulty section";
            NSLog(@"well fuck section:%li", (long)section);
            break;
    }
    return sectionTitle;
}

- (void)doAlertWithTableView {
    UIAlertView *menuAlert = [[UIAlertView alloc] initWithTitle:@"inpornito menu"
                                                        message:nil
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"OK", nil];
    menuAlert.cancelButtonIndex = -1;
    self.tableView = [[[UITableView alloc] initWithFrame:CGRectMake(10, 40, 264, 150) style:UITableViewStyleGrouped] autorelease];

    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor clearColor];

    [menuAlert setValue:self.tableView forKey:@"accessoryView"];
    [menuAlert show];
    [menuAlert release];
}
@end

%hook History
- (void)_visitedURL:(NSString *)URLString title:(id)arg2 asHTTPNonGet:(BOOL)arg3 visitWasFailure:(BOOL)arg4 incrementVisitCount:(BOOL)arg5 {
    if (IS_TWEAK_ENABLED && checkIfLinkIsFiltered(URLString)) return;

    %orig;
}
%end

%hook TabDocument
%new
- (BOOL)isBlacklisted {
    return blacklistedTabs[[NSValue valueWithPointer:self]] != nil;
}
%new
- (void)addToBlacklistWithFilter:(NSString *)filter {
    [blacklistedTabs setObject:filter forKey:[NSValue valueWithPointer:self]];

    isThereAnyBlacklistedTab = [blacklistedTabs count] > 0;
}
%new
- (void)removeFromBlacklist {
    [blacklistedTabs removeObjectForKey:[NSValue valueWithPointer:self]];

    isThereAnyBlacklistedTab = [blacklistedTabs count] > 0;
}

- (id)initWithTitle:(id)title URL:(NSURL *)URL UUID:(id)UUID hibernated:(BOOL)hibernated bookmark:(id)bookmark {
    if (isSwitchON) {
        NSString *filter = checkIfLinkIsFiltered([URL absoluteString]);
        if (filter) {
            [self addToBlacklistWithFilter:filter];
        }
    }

    return %orig;
}

- (void)willClose {
    if ([self isBlacklisted]) {
        [self removeFromBlacklist];
    }

    %orig;
}

%end

%hook BrowserController
- (void)writePrivateBrowsingPreference:(BOOL)preference {
    didUserEnterIncognito = preference;

    %orig;
}

- (void)catalogViewController:(id)arg1 mightSelectCompletionItem:(id)arg2 forString:(id)arg3 {
    // DO FUCKING NOTHING
    // FUCK YEAH
    // FUCK YOU SAFARI
    // NO FUCKING PRE-UPDATE URL
}

- (void)tabDocumentDidUpdateURL:(TabDocument *)tab {
    if (isSwitchON) {
        NSString *filter = checkIfLinkIsFiltered([tab URLString]);

        if (![tab isBlacklisted] && filter) {
            [tab addToBlacklistWithFilter:filter];
            if ([[self tabController] activeTabDocument] == tab && !didUserEnterIncognito) setIncognitoMode(self, YES);
        } else if ([tab isBlacklisted] && !filter) {
            [tab removeFromBlacklist];
            if ([[self tabController] activeTabDocument] == tab && !didUserEnterIncognito) setIncognitoMode(self, NO);
        }
    }

    %orig;
}

// These don't work on iPad
- (void)willDismissTiltedTabView {
    if (IS_TWEAK_ENABLED && ![self privateBrowsingEnabled] && [[[self tabController] activeTabDocument] isBlacklisted]) {
        setIncognitoMode(self, YES);
    }

    %orig;
}

- (void)willPresentTiltedTabView {
    if (IS_TWEAK_ENABLED && [self privateBrowsingEnabled]) {
        setIncognitoMode(self, NO);
    }

    %orig;
}

// For iPad
- (void)switchFromTabDocument:(TabDocument *)fromTab toTabDocument:(TabDocument *)toTab {
    if (IS_IPAD && IS_TWEAK_ENABLED) {
        if (![self privateBrowsingEnabled] && [toTab isBlacklisted]) {
            setIncognitoMode(self, YES);
        } else if ([self privateBrowsingEnabled] && ![toTab isBlacklisted]) {
            setIncognitoMode(self, NO);
        }
    }

    %orig;
}

- (id)_newPrivateBrowsingBarButtonItemUsingButton:(id)button {
    id returnValue = %orig;

    UIButton *privateModeButton = IS_IPAD ? MSHookIvar<UIButton *>(self, "_privateBrowsingButton") : MSHookIvar<UIButton *>(self, "_tabViewPrivateBrowsingButton");

    UITapGestureRecognizer *tapTwice = [[%c(UITapGestureRecognizer) alloc] initWithTarget:self action:@selector(inpornitoMenuAction)];
    tapTwice.numberOfTapsRequired = 2;
    [privateModeButton addGestureRecognizer:tapTwice];

    return returnValue;
}

%new
- (void)inpornitoMenuAction {
    NSDictionary *plist = [NSDictionary dictionaryWithContentsOfFile:BLACKLIST_PATH];
    blacklist = plist[@"Filters"] ? [plist[@"Filters"] mutableCopy] : [NSMutableArray array];
    isSwitchON = [plist[@"isEnabled"] boolValue];
    [[SwagClass new] doAlertWithTableView];
}
%end
