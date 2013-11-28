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
- (void)cleanCurrentGame;
@end


@interface FFMenuViewController : UIView

@property (weak, nonatomic) id<FFMenuViewControllerDelegate> delegate;

- (void)didLoad;

- (void)didAppear;

- (void)didDisappear;

- (void)localChallengeSelected;

- (void)goBackToMenuAfterFinished;

- (void)restartGame;

- (void)pauseTapped;

- (void)resumeGame;

- (void)giveUpAndBackToChallengeMenu;

- (void)goBackToMainMenu;

- (void)hotSeatTapped;

- (void)startHotSeatGame;

- (void)activatePuzzleAtIndex:(NSUInteger)i;

- (void)activateRandomChallengeAtIndex:(NSUInteger)i;

- (void)proceedToNextChallenge;

- (void)anotherRandomChallenge;
@end
