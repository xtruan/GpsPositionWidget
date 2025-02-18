using Toybox.Application as App;
using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.Position as Pos;

(:glance)
class GpsPositionGlanceView extends Ui.GlanceView {
    
    //const DEG_SIGN = StringUtil.utf8ArrayToString([0xC2,0xB0]); // deg sign
    //hidden var posInfoGlance = null;
    
    function initialize() {
        GlanceView.initialize();
    }
    
    function onHide() {
        App.getApp().stopPositioning();
        //Pos.enableLocationEvents(Position.LOCATION_DISABLE, method(:onPositionGlance));
    }
    
    function onShow() {
        App.getApp().startPositioning(Pos.LOCATION_ONE_SHOT);
        //Pos.enableLocationEvents(Position.LOCATION_ONE_SHOT, method(:onPositionGlance));
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
            var formatter = new PosInfoFormatter(posInfoGlance);
            
            // Swiss Grid not available because of memory limitations in glance
            if (geoFormat == :const_sgrlv95 || geoFormat == :const_sgrlv03) {
                geoFormat = :const_mgrs;
            }
            
            var nav = formatter.format(geoFormat);
            navStringTop = nav[0];
            navStringBot = nav[1];
            
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