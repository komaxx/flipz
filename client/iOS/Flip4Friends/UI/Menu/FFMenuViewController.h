//
//  FFMenuViewController.h
//  Flip4Friends
//
//  Created by Matthias Schicker on 7/25/13.
//  Copyright (c) 2013 FlippyFriends. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol FFMenuViewControllerDelegate <NSObject>
- (NSString *)activeGameId;
- (void) activateGameWithId:(NSString *)gameId;
- (void)restartCurrentGame;
- (void)undoTapped;
- (void)cleanCurrentGame;
@end


@interface FFMenuViewController : UIView

@property (weak, nonatomic) id<FFMenuViewControllerDelegate> delegate;

- (void)didLoad;

- (void)didAppear;

- (void)activateGameWithId:(NSString *)gameId;

- (void)didDisappear;

- (void)localChallengeSelected;

- (void)goBackToMenuAfterFinished;

- (void)restartGame;

- (void)pauseTapped;

- (void)resumeGame;

- (void)giveUpAndBackToChallengeMenu;

- (void)goBackToMainMenu;

- (void)hotSeatTapped;

- (void)activateChallengeAtIndex:(NSUInteger)i;
@end
