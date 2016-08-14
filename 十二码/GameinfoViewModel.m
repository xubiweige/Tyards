//
//  GameinfoViewModel.m
//  十二码
//
//  Created by 汪宇豪 on 16/8/10.
//  Copyright © 2016年 汪宇豪. All rights reserved.
//

#import "GameinfoViewModel.h"

@implementation GameinfoViewModel
- (instancetype) initWithDictionary:(NSDictionary *)dictionary
{
    self = [super initWithDictionary:dictionary];
    if (self)
    {
        self.status = 0;
        //[self fetchData:[(NSNumber*)dictionary[@"id"] stringValue]];
        //先用这个测试
        [self fetchData:@"9"];
        self.infoTableviewRowNumber = @[@1,@5];
        self.infotableviewCellname = @[@"主办方",@"赛制",@"时间",@"地区",@"球队数量"];
        
    }
    return self;
}
- (void)fetchData:(NSString*)tournamentId
{
    SEMNetworkingManager* manager = [SEMNetworkingManager sharedInstance];
    [manager fetchGameInfo:tournamentId success:^(id data) {
        self.model = data;
        NSMutableArray* array = [[NSMutableArray alloc] init];
        if (self.model.host) {
            [array addObject:self.model.host];
        }
        else
        {
            [array addObject:@""];
        }
        if ([self.model getMatchTypeInfo]) {
            [array addObject:[self.model getMatchTypeInfo]];
        }
        else
        {
            [array appendObject:@""];
        }
        if ([self.model getDateInfo]) {
            [array addObject:[self.model getDateInfo]];
        }
        else
        {
            [array addObject:@""];
        }
        if (self.model.area.name) {
            [array addObject:self.model.area.name];
        }
        else
        {
            [array addObject:@""];
        }
        [array addObject:[@(self.model.teamSize) stringValue]];
    
        
        self.infoTableViewCellInfo = array;
        
        self.status += 1;
    } failure:^(NSError *aError) {

    }];
    [manager fetchGameSchedule:tournamentId success:^(id data) {
        self.scheduleModel = data;
        self.status += 1;
    } failure:^(NSError *aError) {
        
    }];
    [manager fetchGameTeams:tournamentId success:^(id data) {
        self.teamModel = data;
        self.status += 1;
    } failure:^(NSError *aError) {
        
    }];
}
-(RACCommand *)likeCommand
{
    if (!_likeCommand) {
        _likeCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
            return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
                SEMNetworkingManager* manager = [SEMNetworkingManager sharedInstance];
                [manager postLikeTournament:[@(self.model.id) stringValue] token:[self getToken] success:^(id data) {
                    [subscriber sendNext:@1];
                    [subscriber sendCompleted];
                } failure:^(NSError *aError) {

                }];
                return nil;
            }];
        }];
    }
    return _likeCommand;
}
- (RACCommand *)shareCommand
{
    if (!_shareCommand) {
        _shareCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
            return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
                NSLog(@"点击了分享按钮");
                [subscriber sendNext:@1];
                [subscriber sendCompleted];
                return nil;
            }];
        }];
    }
    return _shareCommand;
}
@end
