//
//  LVRotationGestureRecognizer.m
//  LVSDK
//
//  Created by 董希成 on 15/3/9.
//  Copyright (c) 2015年 dongxicheng. All rights reserved.
//

#import "LVRotationGestureRecognizer.h"
#import "LVGestureRecognizer.h"
#import "LView.h"

@implementation LVRotationGestureRecognizer

-(void) dealloc{
    LVLog(@"LVRotationGestureRecognizer.dealloc");
    [LVGestureRecognizer releaseUD:_lv_userData];
}

-(id) init:(lv_State*) l{
    self = [super initWithTarget:self action:@selector(handleGesture:)];
    if( self ){
        self.lv_lview = (__bridge LView *)(l->lView);
    }
    return self;
}

-(void) handleGesture:(LVRotationGestureRecognizer*)sender {
    lv_State* l = self.lv_lview.l;
    if ( l ){
        lv_checkStack32(l);
        lv_pushUserdata(l,self.lv_userData);
        [LVUtil call:l lightUserData:self key:"callback" nargs:1];
    }
}

static int lvNewGestureRecognizer (lv_State *L) {
    {
        LVRotationGestureRecognizer* gesture = [[LVRotationGestureRecognizer alloc] init:L];
        
        if( lv_type(L, 1) == LV_TFUNCTION ) {
            [LVUtil registryValue:L key:gesture stack:1];
        }
        
        {
            NEW_USERDATA(userData, LVUserDataGesture);
            gesture.lv_userData = userData;
            userData->gesture = CFBridgingRetain(gesture);
            
            lvL_getmetatable(L, META_TABLE_RotaionGesture );
            lv_setmetatable(L, -2);
        }
    }
    return 1; /* new userdatum is already on the stack */
}

static int rotation (lv_State *L) {
    LVUserDataGesture * user = (LVUserDataGesture *)lv_touserdata(L, 1);
    if( LVIsType(user,LVUserDataGesture) ){
        LVRotationGestureRecognizer* gesture =  (__bridge LVRotationGestureRecognizer *)(user->gesture);
        float s = gesture.rotation;
        lv_pushnumber(L, s);
        return 1;
    }
    return 0;
}

+(int) classDefine:(lv_State *)L {
    {
        lv_pushcfunction(L, lvNewGestureRecognizer);
        lv_setglobal(L, "UIRotationGestureRecognizer");
    }
    
    lv_createClassMetaTable(L ,META_TABLE_RotaionGesture);
    
    lvL_openlib(L, NULL, [LVGestureRecognizer baseMemberFunctions], 0);
    
    {
        const struct lvL_reg memberFunctions [] = {
            {"rotation", rotation},
            {NULL, NULL}
        };
        lvL_openlib(L, NULL, memberFunctions, 0);
    }
    return 1;
}


@end