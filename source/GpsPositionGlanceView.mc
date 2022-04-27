using Toybox.Application as App;
using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.Position as Pos;

(:glance)
class GpsPositionGlanceView extends Ui.GlanceView {
    
    const DEG_SIGN = StringUtil.utf8ArrayToString([0xC2,0xB0]); // deg sign
    //hidden var posInfoGlance = null;
    
    function initialize() {
        GlanceView.initialize();
    }
    
    function onHide() {
        //Pos.enableLocationEvents(Position.LOCATION_DISABLE, method(:onPositionGlance));
    }
    
    function onShow() {
        //Pos.enableLocationEvents(Position.LOCATION_CONTINUOUS, method(:onPositionGlance));
    }
    
    function onUpdate(dc) {
        // Get position
        var posInfoGlance = App.getApp().getCurrentPosition();
        
        // Set background color
        dc.setColor( Gfx.COLOR_TRANSPARENT, Gfx.COLOR_BLACK );
        dc.clear();
        
        var navStringTop = "GPS"; //Ui.loadResource(Rez.Strings.AppName);
        var navStringBot = "";
        if (posInfoGlance != null) {
        
            //// BEGIN FROM MAIN VIEW
        
            var geoFormat = App.getApp().getGeoFormat();
            
            var degrees = posInfoGlance.position.toDegrees();
            var lat = 0.0;
            var latHemi = "?";
            var long = 0.0;
            var longHemi = "?";
            // do latitude hemisphere
            if (degrees[0] < 0) {
                lat = degrees[0] * -1;
                latHemi = "S";
            } else {
                lat = degrees[0];
                latHemi = "N";
            }
            // do longitude hemisphere
            if (degrees[1] < 0) {
                long = degrees[1] * -1;
                longHemi = "W";
            } else {
                long = degrees[1];
                longHemi = "E";
            }

            if (geoFormat == :const_dm || geoFormat == :const_dms) {
                // do conversions for degs mins or degs mins secs
                // :const_dm OR :const_dms
                var latDegs = lat.toNumber();
                var latMins = (lat - latDegs) * 60;
                var longDegs = long.toNumber();
                var longMins = (long - longDegs) * 60;
                if (geoFormat == :const_dm) {
                    navStringTop = latHemi + " " + latDegs.format("%i") + DEG_SIGN + " " + latMins.format("%.4f") + "'"; 
                    navStringBot = longHemi + " " + longDegs.format("%i") + DEG_SIGN + " " + longMins.format("%.4f") + "'";
                    //string = posInfo.position.toGeoString(Pos.GEO_DM);
                } else { // :const_dms
                    var latMinsInt = latMins.toNumber();
                    var latSecs = (latMins - latMinsInt) * 60;
                    var longMinsInt = longMins.toNumber();
                    var longSecs = (longMins - longMinsInt) * 60;
                    navStringTop = latHemi + " " + latDegs.format("%i") + DEG_SIGN + " " + latMinsInt.format("%i") + "' " + latSecs.format("%.2f") + "\""; 
                    navStringBot = longHemi + " " + longDegs.format("%i") + DEG_SIGN + " " + longMinsInt.format("%i") + "' " + longSecs.format("%.2f") + "\"";
                    //string = posInfo.position.toGeoString(Pos.GEO_DMS);
                }
            
            } else {
                navStringTop = latHemi + " " + lat.format("%.6f") + DEG_SIGN;
                navStringBot = longHemi + " " + long.format("%.6f") + DEG_SIGN;
                //string = posInfo.position.toGeoString(Pos.GEO_DEG);
            }
            
            //// END FROM MAIN VIEW
            
            dc.setColor( Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT );
            dc.drawText(
                0, //dc.getWidth() / 2,                 // gets the width of the device and divides by 2
                (dc.getHeight() / 2) + 2 - Gfx.getFontHeight(Gfx.FONT_TINY), // gets the height of the device and divides by 2
                Gfx.FONT_TINY,                          // sets the font size
                navStringTop,                           // the String to display
                Gfx.TEXT_JUSTIFY_LEFT                   // sets the justification for the text
            );
            dc.drawText(
                0, //dc.getWidth() / 2,                 // gets the width of the device and divides by 2
                (dc.getHeight() / 2) - 2,// + Gfx.getFontHeight(Gfx.FONT_TINY), // gets the height of the device and divides by 2
                Gfx.FONT_TINY,                          // sets the font size
                navStringBot,                           // the String to display
                Gfx.TEXT_JUSTIFY_LEFT                   // sets the justification for the text
            );
        } else {
        
            dc.setColor( Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT );
            dc.drawText(
                0, //dc.getWidth() / 2,                 // gets the width of the device and divides by 2
                (dc.getHeight() / 2) - (Gfx.getFontHeight(Gfx.FONT_SMALL) / 2), // gets the height of the device and divides by 2
                Gfx.FONT_SMALL,                         // sets the font size
                navStringTop,                           // the String to display
                Gfx.TEXT_JUSTIFY_LEFT                   // sets the justification for the text
            );
        }
    }
}