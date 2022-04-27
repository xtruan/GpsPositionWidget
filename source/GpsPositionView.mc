using Toybox.Application as App;
using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Lang as Lang;
using Toybox.Position as Pos;
using Toybox.Timer;

class GpsPositionView extends Ui.View {
    
    //hidden var posInfo = null;
    hidden var deviceSettings = null;
    hidden var deviceId = null;
    hidden var showLabels = true;
    hidden var progressTimer = null;
    hidden var progressDots = "";
    hidden var isMono = false;
    hidden var isOcto = false;
    
    function initialize() {
        View.initialize();
    }

    //! Load your resources here
    function onLayout(dc as Dc) {
        progressTimer = new Timer.Timer();
        progressTimer.start(method(:updateProgress), 1000, true);
    }
    
    function updateProgress() {
        progressDots = progressDots + ".";
        if (progressDots.length() > 3) {
            progressDots = "";
        }
        Ui.requestUpdate();
    }

    function onHide() {
        //Pos.enableLocationEvents(Position.LOCATION_DISABLE, method(:onPosition));
    }
    //! Restore the state of the app and prepare the view to be shown
    function onShow() {
        //Pos.enableLocationEvents(Position.LOCATION_CONTINUOUS, method(:onPosition));
        deviceSettings = Sys.getDeviceSettings();
        deviceId = Ui.loadResource(Rez.Strings.DeviceId);
        isOcto = deviceId != null && deviceId.equals("octo");
        // only octo watches are mono... at least for now
        isMono = isOcto;
        //System.println(deviceId);
    }

    //! Update the view
    function onUpdate(dc as Dc) {
        // Get position
        var posInfo = App.getApp().getCurrentPosition();
    
        // holders for position data
        var navStringTop = "";
        var navStringBot = "";
        // holder for misc data
        var string;

        // Set background color
        dc.setColor( Gfx.COLOR_TRANSPARENT, Gfx.COLOR_BLACK );
        dc.clear();
        var pos = 0;
        
        // display battery life
        var battPercent = Sys.getSystemStats().battery;
        if (isMono) {
            dc.setColor( Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT );
        } else if (battPercent > 50.0) {
            dc.setColor( Gfx.COLOR_GREEN, Gfx.COLOR_TRANSPARENT );
        } else if (battPercent > 20.0) {
            dc.setColor( Gfx.COLOR_YELLOW, Gfx.COLOR_TRANSPARENT );
        } else {
            dc.setColor( Gfx.COLOR_RED, Gfx.COLOR_TRANSPARENT );
        }
        string = "Bat: " + battPercent.format("%.1f") + "%";
        pos = pos + Gfx.getFontHeight(Gfx.FONT_TINY) - 4;
        if (isOcto) {
            dc.drawText( (dc.getWidth() / 3) - 2, pos, Gfx.FONT_TINY, string, Gfx.TEXT_JUSTIFY_CENTER );
        } else {
            dc.drawText( (dc.getWidth() / 2), pos, Gfx.FONT_TINY, string, Gfx.TEXT_JUSTIFY_CENTER );
        }
        
        if( posInfo != null ) {
            if (progressTimer != null) {
                progressTimer.stop();
            }
            if (isMono) {
                dc.setColor( Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT );
            } else if (posInfo.accuracy == Pos.QUALITY_GOOD) {
                dc.setColor( Gfx.COLOR_GREEN, Gfx.COLOR_TRANSPARENT );
            } else if (posInfo.accuracy == Pos.QUALITY_USABLE) {
                dc.setColor( Gfx.COLOR_YELLOW, Gfx.COLOR_TRANSPARENT );
            } else if (posInfo.accuracy == Pos.QUALITY_POOR) {
                dc.setColor( Gfx.COLOR_RED, Gfx.COLOR_TRANSPARENT );
            } else {
                dc.setColor( Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT );
            }
            
            var formatter = new GpsPositionFormatter(posInfo);
            var geoFormat = App.getApp().getGeoFormat();
            if (geoFormat == :const_deg || geoFormat == :const_dm || geoFormat == :const_dms) {
                // if decimal degrees, we're done
                if (geoFormat == :const_deg) {
                    var fDeg = formatter.getDeg();
                    navStringTop = fDeg[0];
                    navStringBot = fDeg[1];
                // do conversions for degs mins or degs mins secs
                } else if (geoFormat == :const_dm) {
                    var fDM = formatter.getDM();
                    navStringTop = fDM[0]; 
                    navStringBot = fDM[1];
                } else { // :const_dms
                    var fDMS = formatter.getDMS();
                    navStringTop = fDMS[0]; 
                    navStringBot = fDMS[1];
                }
            } else if (geoFormat == :const_utm || geoFormat == :const_usng || geoFormat == :const_mgrs ||geoFormat == :const_ukgr) {
                var degrees = posInfo.position.toDegrees();
                var functions = new GpsPositionFunctions();
                if (geoFormat == :const_utm) {
                    var utmcoords = functions.LLtoUTM(degrees[0], degrees[1]);
                    navStringTop = "" + utmcoords[2] + " " + utmcoords[0];
                    navStringBot = "" + utmcoords[1];
                } else if (geoFormat == :const_usng) {
                    var usngcoords = functions.LLtoUSNG(degrees[0], degrees[1], 5);
                    if (usngcoords[1].length() == 0 || usngcoords[2].length() == 0 || usngcoords[3].length() == 0) {
                        navStringTop = "" + usngcoords[0]; // error message
                    } else {
                        navStringTop = "" + usngcoords[0] + " " + usngcoords[1];
                        navStringBot = "" + usngcoords[2] + " " + usngcoords[3];
                    }
                } else if (geoFormat == :const_ukgr) {
                    var ukgrid = functions.LLToOSGrid(degrees[0], degrees[1]);
                    if (ukgrid[1].length() == 0 || ukgrid[2].length() == 0) {
                        navStringTop = ukgrid[0]; // error message
                    } else {
                        navStringTop = "" + ukgrid[0] + " " + ukgrid[1];
                        navStringBot =  "" + ukgrid[2];
                    }
                } else { // :const_mgrs
                    if (formatter.DEBUG) {
                        // do USNG for debugging since it's using the correct datum to be equivalent to MGRS
                        var usngcoords = functions.LLtoUSNG(degrees[0], degrees[1], 5);
                        if (usngcoords[1].length() == 0 || usngcoords[2].length() == 0 || usngcoords[3].length() == 0) {
                            navStringTop = "" + usngcoords[0]; // error message
                        } else {
                            navStringTop = "" + usngcoords[0] + " " + usngcoords[1];
                            navStringBot = "" + usngcoords[2] + " " + usngcoords[3];
                        }
                        System.println("A: " + navStringTop);
                        System.println("A: " + navStringBot);
                    }
                    var fMGRS = formatter.getMGRS();
                    navStringTop = fMGRS[0];
                    navStringBot = fMGRS[1];
                }
            } else {
                // invalid format, reset to Degs/Mins/Secs
                navStringTop = "...";
                App.getApp().setGeoFormat(:const_dms); // Degs/Mins/Secs
            }
            
            // display navigation (position) string
            if (!isOcto) {
                pos = displayNavString(dc, pos, navStringTop, navStringBot);
            }
            
            // draw border around position
            //dc.setColor( Gfx.COLOR_LT_GRAY, Gfx.COLOR_TRANSPARENT );
            //dc.drawLine(0, (dc.getHeight() / 2) - 62, dc.getWidth(), (dc.getHeight() / 2) - 62);
            //dc.drawLine(0, (dc.getHeight() / 2) - 18, dc.getWidth(), (dc.getHeight() / 2) - 18);
            
            // display heading
            dc.setColor( Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT );
            var headingRad = posInfo.heading;
            var headingDeg = headingRad * 57.2957795;
            if (showLabels) {
                string = "Hdg: ";
            } else {
                string = "";
            }
            string = string + headingDeg.format("%.1f") + formatter.DEG_SIGN; // + " deg";
            //pos = pos + Gfx.getFontHeight(Gfx.FONT_MEDIUM) - 2;
            pos = pos + Gfx.getFontHeight(Gfx.FONT_TINY);
            if (isOcto) {
                pos = pos + 2;
                dc.drawText( (dc.getWidth() / 3) - 2, pos, Gfx.FONT_TINY, string, Gfx.TEXT_JUSTIFY_CENTER );
            } else {
                dc.drawText( (dc.getWidth() / 2), pos, Gfx.FONT_TINY, string, Gfx.TEXT_JUSTIFY_CENTER );
            }
            
            // display navigation (position) string
            if (isOcto) {
                pos = pos + 4;
                pos = displayNavString(dc, pos, navStringTop, navStringBot);
                pos = pos + 2;
            }
            
            // display altitude
            var altMeters = posInfo.altitude;
            var altFeet = altMeters * 3.28084;
            if (showLabels) {
                string = "Alt: ";
            } else {
                string = "";
            }
            if (deviceSettings.distanceUnits == Sys.UNIT_METRIC) {
                string = string + altMeters.format("%.1f") + " m";
            } else { // deviceSettings.distanceUnits == Sys.UNIT_STATUTE
                string = string + altFeet.format("%.1f") + " ft";
            }
            pos = pos + Gfx.getFontHeight(Gfx.FONT_TINY);
            dc.drawText( (dc.getWidth() / 2), pos, Gfx.FONT_TINY, string, Gfx.TEXT_JUSTIFY_CENTER );
            
            // display speed in mph or km/h based on device unit settings
            var speedMsec = posInfo.speed;
            if (showLabels) {
                string = "Spd: ";
            } else {
                string = "";
            }
            if (deviceSettings.distanceUnits == Sys.UNIT_METRIC) {
                var speedKmh = speedMsec * 3.6;
                string = string + speedKmh.format("%.1f") + " km/h";
            } else { // deviceSettings.distanceUnits == Sys.UNIT_STATUTE
                var speedMph = speedMsec * 2.23694;
                string = string + speedMph.format("%.1f") + " mph";
            }
            pos = pos + Gfx.getFontHeight(Gfx.FONT_TINY);
            dc.drawText( (dc.getWidth() / 2), pos, Gfx.FONT_TINY, string, Gfx.TEXT_JUSTIFY_CENTER );
            
            // display Fix posix time
            //string = "Fix: " + posInfo.when.value().toString();
            //dc.drawText( (dc.getWidth() / 2), ((dc.getHeight() / 2) + 30 ), Gfx.FONT_TINY, string, Gfx.TEXT_JUSTIFY_CENTER );
        }
        else {
            // display default text for no GPS
            var posShift = 0;
            if (isOcto) {
                posShift = 10;
            }
            
            dc.setColor( Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT );
            dc.drawText( (dc.getWidth() / 2), posShift + (dc.getHeight() / 2) - Gfx.getFontHeight(Gfx.FONT_SMALL), Gfx.FONT_SMALL, "Waiting for GPS" + progressDots, Gfx.TEXT_JUSTIFY_CENTER );
            if (isMono) {
                dc.setColor( Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT );
            } else {
                dc.setColor( Gfx.COLOR_RED, Gfx.COLOR_TRANSPARENT );
            }
            dc.drawText( (dc.getWidth() / 2), posShift + (dc.getHeight() / 2), Gfx.FONT_SMALL, "Position unavailable", Gfx.TEXT_JUSTIFY_CENTER );
        }
        
    }
    
    function displayNavString(dc, screenPos, navStringTop, navStringBot) {
        // display navigation (position) string
        var pos = screenPos;
        if (navStringBot.length() != 0) {
            pos = pos + Gfx.getFontHeight(Gfx.FONT_SMALL);
            dc.drawText( (dc.getWidth() / 2), pos, Gfx.FONT_MEDIUM, navStringTop, Gfx.TEXT_JUSTIFY_CENTER );
            pos = pos + Gfx.getFontHeight(Gfx.FONT_MEDIUM) - 6;
            dc.drawText( (dc.getWidth() / 2), pos, Gfx.FONT_MEDIUM, navStringBot, Gfx.TEXT_JUSTIFY_CENTER );
        }
        else {
            pos = pos + Gfx.getFontHeight(Gfx.FONT_SMALL);
            dc.drawText( (dc.getWidth() / 2), pos, Gfx.FONT_MEDIUM, navStringTop, Gfx.TEXT_JUSTIFY_CENTER );
            pos = pos + Gfx.getFontHeight(Gfx.FONT_MEDIUM) - 6;
        }
        pos = pos + Gfx.getFontHeight(Gfx.FONT_MEDIUM) - Gfx.getFontHeight(Gfx.FONT_TINY);
        return pos;
    }
}
