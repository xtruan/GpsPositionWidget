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
        
            var geoFormat = App.getApp().getGeoFormat();
            if (geoFormat == :const_deg || geoFormat == :const_dm || geoFormat == :const_dms) {
                var formatter = new GpsPositionFormatter(posInfoGlance);
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
            } else {
                // if not a lat/lon format, show MGRS
                var formatter = new GpsPositionFormatter(posInfoGlance);
                var fMGRS = formatter.getMGRS();
                navStringTop = fMGRS[0];
                navStringBot = fMGRS[1];
            }
            
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