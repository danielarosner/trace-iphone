//
//  TraceUsersTableViewController.m
//  Trace Map
//
//  Created by Steve Cahill on 2/12/15.
//  Copyright (c) 2015 University of Washington. All rights reserved.
//

#import "TraceUsersTableViewController.h"
#import "TracesMgr.h"
#import "ShareViewController.h"
#import "UnmatchedEmailData.h"

@interface TraceUsersTableViewController ()

@end

@implementation TraceUsersTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self.tableView setEditing:YES animated:NO];
    
    self.traceUsers = [[NSMutableArray alloc] initWithCapacity:8];
    self.unmatchedEmails = [[NSMutableArray alloc] initWithCapacity:4];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger cnt;
    
    if (section == 0) {
        cnt = [self.traceUsers count];
    }
    else {
        cnt = [self.unmatchedEmails count];
    }
    return(cnt);
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title = nil;
    
    switch(section)
    {
        case kUnknownUsersSection:
            if ([self.unmatchedEmails count] > 0)  {
                title = NSLocalizedString(@"Users_UnknownUsers_SectionHeader", nil);
            }
            break;
            
        default:
            if ([self.traceUsers count] > 0)  {
                title = NSLocalizedString(@"Users_TraceUsers_SectionHeader", nil);
            }
            break;
    }
    
    return(title);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserCell"
 forIndexPath:indexPath];
    NSInteger row = [indexPath row];
    NSInteger section = [indexPath section];
    
    if (cell)
    {
        if (section == 0)
        {
            PFUser *pfUser = [self.traceUsers objectAtIndex:row];
            cell.textLabel.text = pfUser.username;
            cell.detailTextLabel.text = pfUser.email;
        }
        else {
            UnmatchedEmailData *unmatchedEmailData = [self.unmatchedEmails objectAtIndex:row];
            cell.textLabel.text = [unmatchedEmailData email];
            
            if ([unmatchedEmailData dateEmailedInvitaion] != nil) {
                cell.detailTextLabel.text = @"";
            }
            else {
                cell.detailTextLabel.text = NSLocalizedString(@"Users_TableEmailPendingMsg", nil);
            }
        }
    }
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = [indexPath row];
    NSInteger section = [indexPath section];
    
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        // Delete the row from the data source
        if (section == kPFUsersSection) {
            [self.traceUsers removeObjectAtIndex:row];
        }
        else {
            [self.unmatchedEmails removeObjectAtIndex:row];
        }
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } 
     /* else
     if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
    */
}


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark -

- (IBAction)onAddUser:(UIButton *)sender
{
    NSString *newUsername = self.userTextField.text;
    PFUser *newRecipient;
    NSRange searchRange;
    
    if ([newUsername length] > 0)
    {
        [self.activityIndicator startAnimating];
        
        newRecipient = [TracesMgr checkTraceUsername:newUsername];  // BLOCKING
        if (newRecipient == nil)
        {
            NSString *emailLowercase = [newUsername lowercaseString];
            newRecipient = [TracesMgr checkTraceEmail:emailLowercase]; // BLOCKING
        }
        
        [self.activityIndicator stopAnimating];
        
        if (newRecipient)
        {
            NSInteger userIndex = [self.traceUsers indexOfObject:newRecipient];
            if (userIndex == NSNotFound)
            {
                // *** Add verified PFUser ***
                //
                [self.traceUsers addObject:newRecipient];
                [self.tableView reloadData];
                self.userTextField.text = @"";                  // clear added User TextField
            }
            else
            {
                // already in list
                [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Warning", nil)
                                            message:NSLocalizedString(@"Users_UserInList", nil)
                                           delegate:nil
                                  cancelButtonTitle:nil
                                  otherButtonTitles:@"OK", nil] show];
            }
        }
        else
        {
            // not a Trace Map User
            //
            searchRange = [newUsername rangeOfString:@"@"];
            if (searchRange.location == NSNotFound)
            {
                // not an email
                [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Users_UnknownUserTitle", nil)
                                            message:NSLocalizedString(@"Users_UnknownUser", nil)
                                           delegate:nil
                                  cancelButtonTitle:nil
                                  otherButtonTitles:@"OK", nil] show];
            }
            else
            {
                // email, but not Trace User (see alertView clickedButtonAtIndex)
                NSString *msg = [NSString stringWithFormat:NSLocalizedString(@"Users_UnknownUser_SendEmail", nil), newUsername];
                // email not found, ask to use email to link to User when registered
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Users_UnknownUserTitle", nil)
                                                                message:msg
                                                               delegate:self
                                                      cancelButtonTitle:NSLocalizedString(@"No", nil)
                                                      otherButtonTitles:NSLocalizedString(@"Yes", nil) , nil
                                      ];
                [alert show];
            }
        }
    }
    else
    {
        // no new user text
        [[[UIAlertView alloc] initWithTitle:nil
                                    message:NSLocalizedString(@"Users_NoUserToAdd", nil)
                                   delegate:nil
                          cancelButtonTitle:nil
                          otherButtonTitles:@"OK", nil] show];
    }
}

- (IBAction)onDone:(UIBarButtonItem *)sender
{
    NSInteger traceUsersCnt = [self.traceUsers count];
    NSInteger unmatchedUsersCnt = [self.unmatchedEmails count];
    
    if ((traceUsersCnt + unmatchedUsersCnt) == 0)
    {
        [[[UIAlertView alloc] initWithTitle:nil
                                 message:NSLocalizedString(@"Users_AtLeastOneUser", nil)
                                delegate:nil
                       cancelButtonTitle:nil
                       otherButtonTitles:@"OK", nil] show];
    }
    else
    {
        if (! [self sendInvitationsIfNeeded])
        {
            // all clear to move on to Send
            [self performSegueWithIdentifier:@"ShareTrace" sender:nil];
        }
        // else
        //    We are presenting a modal MFMessageComposeViewController
    }
}


// Returns true - There is a modal email compser
//
-(Boolean) sendInvitationsIfNeeded
{
    Boolean inMailComposer = NO;
    PFUser *curUser = [PFUser currentUser];
    
    NSInteger cnt = [self.unmatchedEmails count];
    NSMutableArray *arrayOfEmails = [[NSMutableArray alloc] initWithCapacity:cnt];
    UnmatchedEmailData *curUnmatchedEmailData;
    
    for (curUnmatchedEmailData in self.unmatchedEmails)
    {
        // only send 1 email please, because can go back from Send
        if ([curUnmatchedEmailData dateEmailedInvitaion] == nil)
        {
            [arrayOfEmails addObject:[curUnmatchedEmailData email]];
        }
    }
    
    // arrayOfEmails is the list of people needing to emailed
    // that they have a Trace for them.
    cnt = [arrayOfEmails count];
    if (cnt > 0)
    {
        if ([MFMailComposeViewController canSendMail])
        {
            inMailComposer = YES;
            
            self.mailComposer = [[MFMailComposeViewController alloc] init];
            self.mailComposer.mailComposeDelegate = self;
            [self.mailComposer setToRecipients:arrayOfEmails];
            [self.mailComposer setSubject: NSLocalizedString(@"Invitation_Subject", nil)];
            
            NSString *bodyStr = [NSString stringWithFormat:NSLocalizedString(@"Invitation_Body", nil), curUser.username, NSLocalizedString(@"Invitation_iOSApp", nil)];
            [self.mailComposer setMessageBody:bodyStr isHTML:YES];
            
            [self presentViewController:self.mailComposer animated:YES completion:nil];
        }
        else
        {
            // email is not setup!
            [[[UIAlertView alloc] initWithTitle:nil
                                        message:NSLocalizedString(@"Invitation_EmailNotAvailable", nil)
                                       delegate:nil
                              cancelButtonTitle:nil
                              otherButtonTitles:@"OK", nil] show];
        }
            
    }
    return(inMailComposer);
}


-(void) timestampUnverifiedEmails
{
    NSDate *now = [NSDate date];
    UnmatchedEmailData *curUnmatchedEmailData;
    for (curUnmatchedEmailData in self.unmatchedEmails)
    {
        [curUnmatchedEmailData setDateEmailedInvitaion:now];
    }
}


#pragma  mark - UIAlertViewDelegate

// will need to move to UIAlertController when iOS 7 support is dropped
//
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    UnmatchedEmailData *unmatchedEmailData;
    
    // since only using for unmatched emails, assume that is where we came from
    switch (buttonIndex) {
        case kSendEmailsButtonIndex:
            //
            // *** Add unverified User ***
            //
            unmatchedEmailData = [[UnmatchedEmailData alloc] init];
            [unmatchedEmailData setEmail: [self.userTextField.text lowercaseString]];
            
            [self.unmatchedEmails addObject: unmatchedEmailData];
            [self.tableView reloadData];
            self.userTextField.text = @"";                  // clear added User TextField
            break;
            
        case kDoNotSendEmailsButtonIndex:
        default:
            break;
    }
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error
{
    switch(result)
    {
        case MFMailComposeResultSent:
        case MFMailComposeResultSaved:      // do we want to count this?
            [self timestampUnverifiedEmails];
            break;
        
        default:
            break;
    }
    
    __weak TraceUsersTableViewController *weakSelf = self;
    [controller dismissViewControllerAnimated:NO completion:^{
        [weakSelf setMailComposer:nil];
        [weakSelf performSegueWithIdentifier:@"ShareTrace" sender:nil];
    }];
     
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ShareTrace"])
    {
        ShareViewController *shareViewController = segue.destinationViewController;
        
        [shareViewController setTraceData:self.traceData];
        [shareViewController setTraceUsers:self.traceUsers];
        [shareViewController setUnmatchedEmails: self.unmatchedEmails];
    }
}

@end
