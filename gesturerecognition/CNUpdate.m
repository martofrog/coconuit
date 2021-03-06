//
//  CNUpdate.m
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

#import "CNUpdate.h"
#import "CNLayer.h"

@implementation CNUpdate

-(id)init{
	if(self = [super init]){
		GestureName = @"Update";
		state = WaitingGesture;
	}
	return self;
}

-(BOOL)recognize:(id)sender{
	
	if([sender isKindOfClass:[CNLayer class]]){
		
		NSMutableArray* gStrokes = [[sender myMultitouchEvent] strokes];
		CNTouch* touch = [gStrokes lastObject];
		
		if(touch.type==UpdateTouch&&[gStrokes count]>0){///if the number of update touches in the active area is heighter than 0   
			state = BeginGesture;
			
			[sender performGesture:@"Update" withData:Nil];///calls PerformUpdateGesture on the related layer [sender performGesture:@"updateTouch" withData:Nil];
			
			state = EndGesture;
			state = WaitingGesture;
			return TRUE;//gesture recognized
			}
		else{
			return FALSE;			
		}
	}
	return FALSE;
}
@end
