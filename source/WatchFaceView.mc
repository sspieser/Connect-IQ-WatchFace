using Toybox.WatchUi as Ui;
using Toybox.Time.Gregorian as Gregorian;
using Toybox.Activity as Act;
using Toybox.System as Sys;
using Toybox.Graphics as Gfx;
using Toybox.Application as App;
using Toybox.Time;

class WatchFaceView extends Ui.WatchFace{
	hidden var cx;
    hidden var cy;
    hidden var settings;
    hidden var active;
    hidden var text_width_hour_10;
    hidden var text_width_point;
	hidden var text_width_minute;
	hidden var text_width_second;
	hidden var text_height_hour;
	hidden var text_height_second;
	hidden var text_y_second;
	hidden var start_x_active_hour_10;
	hidden var start_x_sleep_hour_10;
	hidden var text_color;
	hidden var shade_color;
	hidden var calorie_icon_white;
	hidden var calorie_icon_black;
	hidden var step_icon_white;
	hidden var step_icon_black;
	hidden var distance_icon_white;
	hidden var distance_icon_black;
	hidden var heart_icon_white;
	hidden var heart_icon_black;
	hidden var sunrise_icon_white;
	hidden var sunrise_icon_black;
	hidden var alarm_icon_white;
	hidden var alarm_icon_black;
	hidden var change_color;
	hidden var time_color;
	hidden var altitude = 0;
	hidden var heart_rate = 0;
	hidden var lastLoc;
	hidden var sunset_sunrise;
	hidden var sunset;
		
	function initialize() {
        WatchFace.initialize();
    }
    
    function onExitSleep() {
    	active=true;
    	Ui.requestUpdate();
    }

    function onEnterSleep() {
    	active=false;
    	Ui.requestUpdate();
    }
    
    function onShow(){
        calorie_icon_white = Ui.loadResource(Rez.Drawables.CalorieIconWhite);
    	calorie_icon_black = Ui.loadResource(Rez.Drawables.CalorieIconBlack);

    	step_icon_white = Ui.loadResource(Rez.Drawables.StepIconWhite);
    	step_icon_black = Ui.loadResource(Rez.Drawables.StepIconBlack);
    	
    	distance_icon_white = Ui.loadResource(Rez.Drawables.DistanceIconWhite);
    	distance_icon_black = Ui.loadResource(Rez.Drawables.DistanceIconBlack);
    	
    	heart_icon_white = Ui.loadResource(Rez.Drawables.HeartIconWhite);
    	heart_icon_black = Ui.loadResource(Rez.Drawables.HeartIconBlack);
    	    	
    	sunrise_icon_white = Ui.loadResource(Rez.Drawables.SunriseIconWhite);
    	sunrise_icon_black = Ui.loadResource(Rez.Drawables.SunriseIconBlack);
    	
    	alarm_icon_white = Ui.loadResource(Rez.Drawables.AlarmIconWhite);
    	alarm_icon_black = Ui.loadResource(Rez.Drawables.AlarmIconBlack);
    	
    }
    
    function onHide(){
    	
    }
    
    function onLayout(dc) {
        settings = System.getDeviceSettings();

        cx = dc.getWidth() / 2;
        cy = dc.getHeight() / 2;
        
        text_width_hour_10 = dc.getTextWidthInPixels("88",Gfx.FONT_NUMBER_THAI_HOT);
        text_width_point = dc.getTextWidthInPixels(":",Gfx.FONT_NUMBER_THAI_HOT);
        text_height_hour = dc.getFontHeight(Gfx.FONT_NUMBER_THAI_HOT);
        text_width_minute = dc.getTextWidthInPixels("88",Gfx.FONT_NUMBER_THAI_HOT);
        text_width_second=dc.getTextWidthInPixels("88",Gfx.FONT_NUMBER_MEDIUM);
        text_height_second = dc.getFontHeight(Gfx.FONT_NUMBER_MEDIUM);
        
        start_x_active_hour_10=(dc.getWidth()-(text_width_hour_10+text_width_point+text_width_minute+text_width_second+8))/2;
        start_x_sleep_hour_10=(dc.getWidth()-(text_width_hour_10+text_width_point+text_width_minute+4))/2;
   
    }
    
    function onUpdate(dc) {
    	var actInfo = Act.getActivityInfo();
    	//Property
    	var arc_type =  App.getApp().getProperty("arc_type");
    	var info_top = App.getApp().getProperty("info_top");
    	var info_bottom = App.getApp().getProperty("info_bottom");
    	var display_second = App.getApp().getProperty("second_display");
    	var date_type =  App.getApp().getProperty("date_type");
    	var battery_low =  App.getApp().getProperty("battery_low");
    	var battery_percentage = App.getApp().getProperty("battery_percentage");
    	var battery_profile = App.getApp().getProperty("battery_profile");
    	var altitude_profile = App.getApp().getProperty("altitude_profile");
    	var altitude_step =  App.getApp().getProperty("altitude_step");
    	//Battery
    	var battery = Sys.getSystemStats().battery;
    	//Hour
        var moment = Time.now();
        var info_date = Gregorian.info(moment, Time.FORMAT_LONG);
        //Altimeter
        
		if (actInfo != null && actInfo.altitude != null) {
			altitude = actInfo.altitude;
			var metric = settings.elevationUnits;
			if (metric==Sys.UNIT_STATUTE) {
				altitude = altitude*3.38;
			}				
		}
    	//hr
		if(info_top == 6 || info_bottom == 7){
			if(ActivityMonitor has :HeartRateIterator) {
    			var hrIter = ActivityMonitor.getHeartRateHistory(null, true);
        		if(hrIter != null){
        			var hr = hrIter.next();
					heart_rate = (hr.heartRate != ActivityMonitor.INVALID_HR_SAMPLE && hr.heartRate > 0) ? hr.heartRate : 0; 		
    			}
    		}
    	}
    	    	
    	//sunset or sunrise
    	if(actInfo.currentLocation!=null && (info_top == 7 || info_bottom == 8)){
    		lastLoc = actInfo.currentLocation.toRadians();
    		var sunrise_moment = getMoment(moment,SUNRISE);
    		var sunset_moment = getMoment(moment,SUNSET);

    		if(moment.greaterThan(sunset_moment) || moment.lessThan(sunrise_moment)){
    			sunset_sunrise = momentToString(sunrise_moment);
    			sunset=false;
    		}else{
    			sunset_sunrise = momentToString(sunset_moment);
    			sunset=true;
    		}	
    	}else{
    		sunset_sunrise = Ui.loadResource(Rez.Strings.none);
    	}
    	
    	if(battery_profile && battery<=battery_low){
    		info_top=1;
    	}
    	if(altitude_profile && altitude>altitude_step){
			info_bottom=0;
		}
    	   	
    	var bgk_color = getBackgroundColor();
    	dc.setColor(bgk_color,bgk_color);
    	
    	if(bgk_color==Gfx.COLOR_BLACK){
    		text_color=Gfx.COLOR_WHITE;
    	}else{
    		text_color=Gfx.COLOR_BLACK;
    	}
    	
    	shade_color = getColorShade(moment);
        dc.clear();
		
        drawHour(dc,info_date,info_bottom,active&&display_second);
    
		var y;
		if(info_top == 0){
			y = cy/2-27;
			Date.drawDate(dc,info_date,cx,y,text_color,date_type);
		}else if( info_top == 1){
			y = cy/2-15;
			Battery.drawIcon(dc,battery,battery_low,cx,y,text_color,battery_percentage);
		}else if (info_top == 2 && settings.phoneConnected){
			y = cy/2-15;
			PhoneConnected.drawIcon(dc,cx,y,text_color);
		}else if(info_top == 3){
			y = cy/2-15;
			var calorie_icon;
			if(bgk_color==Gfx.COLOR_BLACK){
				calorie_icon = calorie_icon_white;
			}else{
				calorie_icon = calorie_icon_black;
			}
			Utils.drawIconText(dc,ActivityMonitor.getInfo().calories,cx,y,text_color,calorie_icon);
		}else if(info_top == 4){
			y = cy/2-15;
			var step_icon;
			if(bgk_color==Gfx.COLOR_BLACK){
				step_icon = step_icon_white;
			}else{
				step_icon = step_icon_black;
			}
			Utils.drawIconText(dc,ActivityMonitor.getInfo().steps,cx,y,text_color,step_icon);
		}else if(info_top == 5){
			y = cy/2-15;
			var distance_icon;
			if(bgk_color==Gfx.COLOR_BLACK){
				distance_icon = distance_icon_white;
			}else{
				distance_icon = distance_icon_black;
			}
		
			InfoMonitor.drawIconDistance(dc,ActivityMonitor.getInfo().distance,cx,y,text_color,distance_icon);
		}else if(info_top == 6){
			y = cy/2-15;
			var heart_icon;
			if(bgk_color==Gfx.COLOR_BLACK){
				heart_icon = heart_icon_white;
			}else{
				heart_icon = heart_icon_black;
			}
		
			Utils.drawIconText(dc,heart_rate,cx,y,text_color,heart_icon);
		}else if(info_top == 7){
			y = cy/2-15;
			var sun_icon;
			if(bgk_color==Gfx.COLOR_BLACK){
				if(sunset){
					sun_icon = MoonPhase.getIconSunsetWhite(moment);
				}else{
					sun_icon = sunrise_icon_white;
				}
			}else{
				if(sunset){
					sun_icon = MoonPhase.getIconSunsetBlack(moment);
				}else{
					sun_icon = sunrise_icon_black;
				}
			}
		
			Utils.drawIconText(dc,sunset_sunrise,cx,y,text_color,sun_icon);
		}
				
		
		if(info_bottom == 0){
			
			if(settings.screenShape==Sys.SCREEN_SHAPE_SEMI_ROUND){
				y=dc.getHeight()-10;
			}else{
				y=dc.getHeight()*0.85;
			}
			
       		Altimeter.draw(dc,altitude,y,text_color,text_color,shade_color);	
		}else if( info_bottom == 1){
			y = cy+cy/2;
			Date.drawDate(dc,info_date,cx,y,text_color,date_type);
		}else if(info_bottom ==2){
			y = cy+cy/2 + 20;
			Battery.drawIcon(dc,battery,battery_low,cx,y,text_color,battery_percentage);	
		}else if (info_bottom == 3 && settings.phoneConnected){
			y = cy+cy/2 + 20;
			PhoneConnected.drawIcon(dc,cx,y,text_color);
		}else if(info_bottom == 4){
			y = cy+cy/2 + 20;
			var calorie_icon;
			if(bgk_color==Gfx.COLOR_BLACK){
				calorie_icon = calorie_icon_white;
			}else{
				calorie_icon = calorie_icon_black;
			}
			Utils.drawIconText(dc,ActivityMonitor.getInfo().calories,cx,y,text_color,calorie_icon);
		}else if(info_bottom == 5){
			y = cy+cy/2+20;
			var step_icon;
			if(bgk_color==Gfx.COLOR_BLACK){
				step_icon = step_icon_white;
			}else{
				step_icon = step_icon_black;
			}
			Utils.drawIconText(dc,ActivityMonitor.getInfo().steps,cx,y,text_color,step_icon);
		}else if(info_bottom == 6){
			y = cy+cy/2+20;
			var distance_icon;
			if(bgk_color==Gfx.COLOR_BLACK){
				distance_icon = distance_icon_white;
			}else{
				distance_icon = distance_icon_black;
			}
			
			InfoMonitor.drawIconDistance(dc,ActivityMonitor.getInfo().distance,cx,y,text_color,distance_icon);
		}else if(info_bottom == 7){
			y = cy+cy/2+20;
			var heart_icon;
			if(bgk_color==Gfx.COLOR_BLACK){
				heart_icon = heart_icon_white;
			}else{
				heart_icon = heart_icon_black;
			}
		
			Utils.drawIconText(dc,heart_rate,cx,y,text_color,heart_icon);
		}else if(info_bottom == 8){
			y = cy+cy/2+20;
			var sun_icon;
			if(bgk_color==Gfx.COLOR_BLACK){
				if(sunset){
					sun_icon = MoonPhase.getIconSunsetWhite(moment);
				}else{
					sun_icon = sunrise_icon_white;
				}
			}else{
				if(sunset){
					sun_icon = MoonPhase.getIconSunsetBlack(moment);
				}else{
					sun_icon = sunrise_icon_black;
				}
			}
		
			Utils.drawIconText(dc,sunset_sunrise,cx,y,text_color,sun_icon);
		}
		
		var arc_width =  App.getApp().getProperty("arc_width");
		if(arc_type<3){
       		
       		if(arc_type == 0){
       			Battery.drawArc(dc,battery,battery_low,cx,cy,getColorArc(),arc_width);
       		}else if (arc_type == 1) {
        		InfoMonitor.drawArcStep(dc,ActivityMonitor.getInfo().steps,ActivityMonitor.getInfo().stepGoal,cx,cy,getColorArc(),getColorArcGoal(),arc_width);
        	}else if (arc_type == 2) {
        		InfoMonitor.drawArcMoveBar(dc,ActivityMonitor.getInfo().moveBarLevel,ActivityMonitor.MOVE_BAR_LEVEL_MAX,cx,cy,getColorArc(),arc_width);
        	} 	
       	} 
       	
       	var alarm_count = settings.alarmCount;
       	var alarm =  App.getApp().getProperty("alarm_clock_display");
       	
       	if ( alarm_count > 0 && alarm) {
       		var alarm_clock_icon;
			if(bgk_color==Gfx.COLOR_BLACK){
				alarm_clock_icon = alarm_icon_white;
			}else{
				alarm_clock_icon = alarm_icon_black;
			}
       		dc.drawBitmap(cx*2-32-arc_width/2-alarm_clock_icon.getWidth()/2,cy/2-alarm_clock_icon.getHeight()/2,alarm_clock_icon);
       	}
       	      	
    }
            
    function drawHour(dc,info_date,info_bottom,display_second){
        var text_y_hour;
        if(info_bottom==0){
        	text_y_hour = cy-12;
        }else{
        	text_y_hour = cy;
        }
        var text_width_hour;
        var start_x;
        text_width_hour = text_width_hour_10;
        	if(active){
        		start_x=start_x_active_hour_10;
        	}else{
        		start_x=start_x_sleep_hour_10;
        	}
        
        var hour_color = getColorHour();
        var minute_color = getColorMinute();
        var second_color = getColorSecond();
        	
		Date.drawHour(dc,info_date,start_x,text_y_hour,[text_width_hour,text_width_point,text_width_minute],[text_height_hour,text_height_second],settings.is24Hour,[hour_color,text_color,minute_color,second_color], display_second);	 
    }
    
    function getColorShade(moment){
        var shade_color =  App.getApp().getProperty("shade_color");
        if(shade_color == 13){
        	var minute_change_color =  App.getApp().getProperty("minute_change_color");
        	var duration = new Time.Duration.initialize(minute_change_color*60);
       		if(time_color == null || moment.compare(time_color.add(duration))>=0){
        		var color = Math.rand()%11+1;
        		while(color == change_color){
        			color = Math.rand()%11+1;
        		}
        		change_color = color;		
        		shade_color = change_color;
        		time_color=moment;
        	}else{
        		shade_color = change_color;
        	}
        }
        return getColor(shade_color,Gfx.COLOR_DK_RED);
    }
    
    function getColorHour(){
        return getColor(App.getApp().getProperty("hour_color"),text_color);
    }
 
    function getColorMinute(){
        return getColor(App.getApp().getProperty("minute_color"),shade_color);
    }
        
    function getColorSecond(){
        return getColor(App.getApp().getProperty("second_color"),text_color);
    }
            
    function getBackgroundColor(){
        var bgk_color =  App.getApp().getProperty("bgk_color");
        if(bgk_color == 0){
        	return Gfx.COLOR_BLACK;
        }else{
        	return Gfx.COLOR_WHITE;
        }
    }
        
    function getColorArc(){
        return getColor(App.getApp().getProperty("arc_color"),text_color);
    }
    
    function getColorArcGoal(){
        return getColor(App.getApp().getProperty("arc_color_goal"),Gfx.COLOR_GREEN);
    }
    
   	function getColor(color_property, color_default){
        if (color_property == 1) {
        	return Gfx.COLOR_BLUE;
        }else if (color_property == 2) {
        	return Gfx.COLOR_DK_BLUE;
        }else if (color_property == 3) {
        	return Gfx.COLOR_GREEN;
        }else if (color_property == 4) {
        	return Gfx.COLOR_DK_GREEN;
        }else if (color_property == 5) {
        	return Gfx.COLOR_LT_GRAY;
        }else if (color_property == 6) {
        	return Gfx.COLOR_DK_GRAY;
        }else if (color_property == 7) {
        	return Gfx.COLOR_ORANGE;
        }else if (color_property == 8) {
        	return Gfx.COLOR_PINK;
        }else if (color_property == 9) {
        	return Gfx.COLOR_PURPLE;
        }else if (color_property == 10) {
        	return Gfx.COLOR_RED;
        }else if (color_property == 11) {
        	return Gfx.COLOR_DK_RED;
        }else if (color_property == 12) {
        	return Gfx.COLOR_YELLOW;
        }
        return color_default;
    } 
     
    function getMoment(now,what) {
		return SunCalc.calculate(now, lastLoc[0], lastLoc[1], what);
	}
	
	function momentToString(moment) {

		if (moment == null) {
			return "--:--";
		}

   		var tinfo = Time.Gregorian.info(new Time.Moment(moment.value() + 30), Time.FORMAT_SHORT);
		var text;
		if (settings.is24Hour) {
			text = tinfo.hour.format("%02d") + ":" + tinfo.min.format("%02d");
		} else {
			var hour = tinfo.hour % 12;
			if (hour == 0) {
				hour = 12;
			}
			text = hour.format("%02d") + ":" + tinfo.min.format("%02d");
			
			if (tinfo.hour < 12 || tinfo.hour == 24) {
				text = text + " AM";
			} else {
				text = text + " PM";
			}
		}

		return text;
	}
  
}