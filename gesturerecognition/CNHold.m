//
//  CNHold.m
//
//  CocoNuit is free software: you can redistribute it and/or modify
//  it under the terms of the GNU Lesser General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version. 
//
//  CocoNuit is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU Lesser General Public License for more details.
//
//  You should have received a copy of the GNU Lesser General Public License
//  along with CocoNuit.  If not, see <http://www.gnu.org/licenses/>.
//
//  Copyright 2009 Nicola Martorana <martorana.nicola@gmail.com>.
//

#import "CNHold.h"
#import "CNGestureFactory.h"
#import "CNLayer.h"
#import "Math.h"

@implementation CNHold

-(id)init{
	if(self = [super init]){
		super.GestureName = @"CNHold";
		state = WaitingGesture;
	}
	return self;
}

-(BOOL)recognize:(id)sender{
	
	if([sender isKindOfClass:[CNLayer class]]){
		
		NSMutableArray* gStrokes = [[sender myMultitouchEvent] strokes];
		
		if([gStrokes count]>0){
			if([gStrokes count]>1){///if the Touchs number is greater than one
				if(touch==Nil){
					touch = [[CNTouch alloc] init];
				}
				[self groupStrokesToOne:gStrokes andUpdateTouch:touch];///grouping the touches to one
			}
			else{
				[touch release];
				touch = [[gStrokes lastObject] copy];///else get the only one
				}
		}
		
		if(touch){

			double minHoldTimeInterval = [[GesturesParams objectForKey:@"MinHoldTimeInterval"] doubleValue];
			double minMoveVelocity = [[GesturesParams objectForKey:@"MinMoveVelocity"] doubleValue];
			
			if(touch.lifetime>minHoldTimeInterval && pointIsGreater(NSMakePoint(minMoveVelocity, minMoveVelocity),touch.velocity)){///if the touch lifetime is greater than minHoldTimeInterval and the touch velocity is lesser than a Threshold 
				
				if(state==WaitingGesture && touch.type==UpdateTouch){///if update touch type and Waiting Gesture State get Hold
					state=BeginGesture;
					state=EndGesture;//gesture ends suddenly
					[sender performGesture:@"Hold" withData:Nil];///calling perform HoldGesture on the related layer [sender performGesture:@"Hold" withData:nil];
					return TRUE;//gesture recognized
				}
				
				if(state==EndGesture && touch.type==ReleaseTouch){///else simply set the Gesture state to Waiting
					state=WaitingGesture;
					return FALSE;
				}

			}
		}
	}
	return FALSE;
}
	
@end

