//
//  CProfilesDetailViewController.m
//  gpen
//
//  Created by fredformout on 04.12.12.
//  Copyright (c) 2012 XP.Guild. All rights reserved.
//

#import "CProfilesDetailViewController.h"
#import "AppDelegate.h"
#import "CUpdater.h"

@interface CProfilesDetailViewController ()

@end

@implementation CProfilesDetailViewController

@synthesize profile = _profile;
@synthesize backButton = _backButton;
@synthesize editButton = _editButton;
@synthesize backupInfo = _backupInfo;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationItem setTitle:[NSString stringWithFormat:@"%@ %@", [_profile.name capitalizedString], [_profile.lastname capitalizedString]]];
    
    _backupInfo = [[NSMutableDictionary alloc] init];
    
    editingMode = NO;
}

- (IBAction)editAction
{
    if (editingMode == NO)
    {
        [self fillBackUp];//сохранение в бэкап
        
        //TODO сделать поля редактируемыми, кнопку сделать главным спрятать и показать кнопку удалить профиль
        
        [_backButton setImage:[UIImage imageNamed:@"cancel-for-nav.png"] forState:UIControlStateNormal];
        [_editButton setImage:[UIImage imageNamed:@"done-for-nav.png"] forState:UIControlStateNormal];
        
        editingMode = YES;
    }
    else
    {
        //TODO действие для конца редактирования, наверн надо какую крутилку посередине и заблочить все, могу дать отличный рецепт оверлэя поверх всего экрана
        
        AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        
        dispatch_async(delegate.dispatcher.dataUpdateQueue, ^{
            
            //TODO сформировать из полей такой же словарик как в логине но с ИМЕНЕМ ПРОФИЛЯ еще для проверки подлинности пользователя и передать его в функцию ниже
            status requestStatus = [delegate.updater editProfileAndUpdate:_profile data:[NSDictionary dictionary]];
            
            if (requestStatus == GOOD)
            {
                [_backButton setImage:[UIImage imageNamed:@"back-for-nav.png"] forState:UIControlStateNormal];
                [_editButton setImage:[UIImage imageNamed:@"edit-for-nav.png"] forState:UIControlStateNormal];
                
                //TODO убрать редактируемость полей
                
                [_backupInfo removeAllObjects];
                
                editingMode = NO;
            }
        });
    }
}

- (IBAction)goBack
{
    if (editingMode == NO)
    {
        [super goBack];
    }
    else
    {
        //TODO убрать редактируемость полей
        
        [self fillFields];//восстановление данных из бэкапа
        
        [_backButton setImage:[UIImage imageNamed:@"back-for-nav.png"] forState:UIControlStateNormal];
        [_editButton setImage:[UIImage imageNamed:@"edit-for-nav.png"] forState:UIControlStateNormal];
        
        [_backupInfo removeAllObjects];
        
        editingMode = NO;
    }
}

- (void)fillBackUp
{
    //TODO здесь вставить необходимую инфу для восстановления
    [_backupInfo setObject:@"" forKey:@"name"];
    [_backupInfo setObject:@"" forKey:@"patronymic"];
    [_backupInfo setObject:@"" forKey:@"surname"];
    [_backupInfo setObject:@"" forKey:@"license"];
    [_backupInfo setObject:@"" forKey:@"birthday"];
    [_backupInfo setObject:@"" forKey:@"email"];
    [_backupInfo setObject:@"" forKey:@"profileName"];
}

- (void)fillFields
{
    //TODO засунуть в нужные поля инфу из словаря видом выше
}

//TODO действие для кнопки СДЕЛАТЬ ГЛАВНЫМ
- (IBAction)makeMain
{
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate.updater updateLastSignForProfile:_profile];
    [self goBack];
}

//TODO действие для кнопки УДАЛИТЬ ПРОФИЛЬ
- (IBAction)deleteProfile
{
    UIAlertView* dialog = [[UIAlertView alloc] init];
    [dialog setDelegate:self];
    [dialog setTitle:@"Внимание"];
    [dialog setMessage:@"Удалить данный профиль?"];
    [dialog addButtonWithTitle:@"OK"];
    [dialog addButtonWithTitle:@"Отмена"];
    [dialog show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [delegate.updater deleteProfile:_profile];
        editingMode = NO;
        [self goBack];
    }
}

@end
