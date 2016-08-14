//
//  GameinfoViewModel.h
//  十二码
//
//  Created by 汪宇豪 on 16/8/10.
//  Copyright © 2016年 汪宇豪. All rights reserved.
//

#import "SEMViewModel.h"
#import "MDABizManager.h"
@interface GameinfoViewModel : SEMViewModel
@property (nonatomic, strong) GameInfoModel *model;
@property (nonatomic, strong) ScheduleModel *scheduleModel;
@property (nonatomic, strong) NSArray<MatchTeamModel *> *teamModel;
@property (nonatomic,assign ) NSInteger     status;
@property (nonatomic,strong ) RACCommand    * shareCommand;
@property (nonatomic,strong ) RACCommand    * likeCommand;
@property (nonatomic,strong) NSArray* infoTableviewRowNumber;
@property (nonatomic,strong) NSArray* infoTableViewCellInfo;
@property (nonatomic,strong) NSArray* infotableviewCellname;
@end
