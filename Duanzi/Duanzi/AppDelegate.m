//
//  AppDelegate.m
//  Duanzi
//
//  Created by mac on 15/4/29.
//  Copyright (c) 2015年 jiji. All rights reserved.
//

#import "AppDelegate.h"
#import "DuanziContentLoader.h"
#import "DuanziListViewController.h"
#import "DuanziSearchViewController.h"
#import "DuanziSettingViewController.h"
#import "DuanziCreateViewController.h"

@interface AppDelegate ()

@property (nonatomic, strong) UITabBarController *tabBarController;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([[[defaults valueForKey:@"FirstRun"] description] length] == 0)//首次运行
    {
        [defaults setBool:NO forKey:@"FirstRun"];
        
        
        //初始化默认数据库
        DuanziContentLoader *manager = [DuanziContentLoader duanziLoader];
        [manager createDatabaseAndSaveDefaultData];
        
        //搜索历史
        [defaults setObject:[NSArray new] forKey:Duanzi_SearchHistory_Key];
        
        [defaults synchronize];
    }
    
    self.window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, LCD_W, LCD_H)];
    self.window.backgroundColor = [UIColor whiteColor];
    
    self.tabBarController = [[UITabBarController alloc] init];
    
    
    DuanziListViewController *listVC = [[DuanziListViewController alloc] initWithNibName:@"DuanziListViewController" bundle:nil];
    UINavigationController *listNaviController = [[UINavigationController alloc] initWithRootViewController:listVC];
    
    DuanziCreateViewController *createVC = [[DuanziCreateViewController alloc] initWithNibName:@"DuanziCreateViewController" bundle:nil];
    UINavigationController *createNaviController = [[UINavigationController alloc] initWithRootViewController:createVC];
    
    DuanziSearchViewController *searchVC = [[DuanziSearchViewController alloc] initWithNibName:@"DuanziSearchViewController" bundle:nil];
    UINavigationController *searchNaviController = [[UINavigationController alloc] initWithRootViewController:searchVC];
    
    DuanziSettingViewController *settingVC = [[DuanziSettingViewController alloc] initWithNibName:@"DuanziSettingViewController" bundle:nil];
    UINavigationController *settingNaviController = [[UINavigationController alloc] initWithRootViewController:settingVC];
    
    [self.tabBarController setViewControllers:@[listNaviController, createNaviController, searchNaviController, settingNaviController]];
    
    self.window.rootViewController = self.tabBarController;
    
    [self.window makeKeyAndVisible];

    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end