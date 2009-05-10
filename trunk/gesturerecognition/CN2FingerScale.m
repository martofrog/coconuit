//
//  CN2FingerScale.m
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


#import "CN2FingerScale.h"
#import "CNPathElement.h"
#import "CNLayer.h"

@implementation CN2FingerScale

-(id)init{
	if(self = [super init]){
		super.GestureName = @"2FingersScale";
		state = WaitingGesture;
		anchorPoint = NSMakePoint(0.5, 0.5);
	}
	return self;
}

-(BOOL)recognize:(id)sender{
	//E' da rifare così non mi convince
	if([sender isKindOfClass:[CNLayer class]]){
		NSMutableArray* gStrokes = [[sender myMultitouchEvent] strokes];
		
		if([gStrokes count] == 2){
			//Controllare la velocità diversa da zero
			CNStroke* stroke_0 = [gStrokes objectAtIndex:0];
			CNStroke* stroke_1 = [gStrokes objectAtIndex:1];
			
			if(stroke_0.strokePath.count>1 && stroke_1.strokePath.count>1){
				CNTouch* Touch0 = (CNTouch*)stroke_0;
				CNTouch* Touch1 = (CNTouch*)stroke_1;
				
				NSPoint stroke_0_old_position = [(CNPathElement*)[stroke_0.strokePath objectAtIndex:([stroke_0.strokePath count]-2)] position];
				NSPoint stroke_1_old_position = [(CNPathElement*)[stroke_1.strokePath objectAtIndex:([stroke_1.strokePath count]-2)] position];
				NSPoint mediumPoint = getMediumPoint(stroke_0_old_position,stroke_1_old_position);
				CN2dVect* vect_0_old = [[CN2dVect alloc] initWithPoint:mediumPoint andPoint:stroke_0_old_position];
				CN2dVect* vect_0 = [[CN2dVect alloc] initWithPoint:mediumPoint andPoint:stroke_0.position];
				CN2dVect* vect_0_proj = getProjectionOfVector(vect_0,vect_0_old);
				//fabs(vect_0-vect_0_proj) > soglia
				double alfa_0 = getAngleBetweenVector(vect_0_old,vect_0);
				
				CN2dVect* vect_1_old = [[CN2dVect alloc] initWithPoint:mediumPoint andPoint:stroke_1_old_position];
				CN2dVect* vect_1 = [[CN2dVect alloc] initWithPoint:mediumPoint andPoint:stroke_1.position];
				CN2dVect* vect_1_proj = getProjectionOfVector(vect_1,vect_1_old);
				double alfa_1 = getAngleBetweenVector(vect_1_old,vect_1);
				
				double alfa = getAngleBetweenVector(vect_0_proj,vect_1_proj);
				
				double Max2FingerScaleAngle = [[GesturesParams objectForKey:@"Max2FingerScaleAngle"] doubleValue];
				double Min2FingerScaleValue = [[GesturesParams objectForKey:@"Min2FingerScaleValue"] doubleValue];
				
				double minAlfa = Max2FingerScaleAngle*M_PI/180;
				if(Touch0.type==ReleaseTouch || Touch1.type==ReleaseTouch){
					state=EndGesture;
				}
				if(alfa_0<(minAlfa)&&alfa_1<(minAlfa) ||state==EndGesture){
					if(fabs(alfa)>=M_PI-0.10){//????
						if(state==BeginGesture){
							state=UpdateGesture;
						}
						if(state==WaitingGesture){
							state=BeginGesture;
							anchorPoint = getMediumPoint(stroke_0_old_position,stroke_1_old_position);
						}
						double firstLenght = ((CN2dVect*)[[CN2dVect alloc] initWithPoint:stroke_0_old_position andPoint:stroke_1_old_position]).module;
						double secondLenght = ((CN2dVect*)[[CN2dVect alloc] initWithPoint:stroke_0.position andPoint:stroke_1.position]).module;
						
						//double firstLenght =  vect_0_old.module+vect_1_old.module;
						//double secondLenght = vect_1_proj.module+vect_0_proj.module;
						
						//double scale_0 = vect_0_proj.module - vect_0_old.module;
						//double scale_1 = vect_1_proj.module - vect_1_old.module;
						
						double scale = secondLenght/firstLenght;
						
						//NSLog(@"Scale del fattore %d ",maxDouble(scale_0,scale_1));//da correggere se il segno dei fatt di scala è negativo deve tornare il min
						if(fabs(vect_0.module-vect_0_proj.module)>Min2FingerScaleValue || fabs(vect_1.module-vect_1_proj.module)>Min2FingerScaleValue){
							
							//[sender twoFingerScale:scale withCenter:anchorPoint andGestureState:self.state];
							
							NSArray* keys = [NSArray arrayWithObjects:@"scaleValue", @"center", @"gState",nil];
							
							NSNumber* scalePar = [NSNumber numberWithFloat:scale];
							NSValue* centerPar = [NSValue valueWithPoint:anchorPoint];
							NSNumber* gStatePar = [NSNumber numberWithInt:self.state];
							
							NSArray* objects = [NSArray arrayWithObjects:scalePar, centerPar, gStatePar, nil];
							
							
							NSDictionary* params = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
							
							
							[sender performGesture:@"TwoFingerScale" withData:params];

						}
					}
					
					if(state==EndGesture){
						state=WaitingGesture;
					}
					return TRUE;
				}
				
			}
		}
	}
	return FALSE;
}

@end