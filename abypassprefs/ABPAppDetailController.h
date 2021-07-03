#import <substrate.h>

#import <UIKit/UIKit.h>
#import <Preferences/PSSpecifier.h>
// #import <Preferences/PSEditableListController.h>
#import <Preferences/PSListController.h>
#import <Preferences/PSListItemsController.h>

@interface PSEditableListController : PSListController
-(void)editDoneTapped;
-(id)_editButtonBarItem;
-(void)_setEditable:(BOOL)arg1 animated:(BOOL)arg2 ;
-(BOOL)performDeletionActionForSpecifier:(id)arg1 ;
-(void)setEditingButtonHidden:(BOOL)arg1 animated:(BOOL)arg2 ;
-(void)setEditButtonEnabled:(BOOL)arg1 ;
-(void)didLock;
-(void)showController:(id)arg1 animate:(BOOL)arg2 ;
-(void)_updateNavigationBar;
-(id)init;
-(void)viewWillAppear:(BOOL)arg1 ;
-(id)tableView:(id)arg1 willSelectRowAtIndexPath:(id)arg2 ;
-(long long)tableView:(id)arg1 editingStyleForRowAtIndexPath:(id)arg2 ;
-(void)tableView:(id)arg1 commitEditingStyle:(long long)arg2 forRowAtIndexPath:(id)arg3 ;
-(void)setEditable:(BOOL)arg1 ;
-(void)suspend;
-(BOOL)editable;
@end



@interface ABPAppListController : PSListController
@end

@interface ABPAppDetailController : PSListController
@end
