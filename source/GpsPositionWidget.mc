using Toybox.Application as App;
using Toybox.System as Sys;
using Toybox.WatchUi as Ui;
using Toybox.Application.Properties as Props;
using Toybox.Position as Pos;

(:glance)
class GpsPositionWidget extends App.AppBase {

    hidden var geoFormat = :const_dms;
    hidden var currentPosInfo = null;
    hidden var posLocationMode = Pos.LOCATION_CONTINUOUS;
    
    function initialize() {
        AppBase.initialize();
    }
    
    // property store can't handle symbol types 
    // this method converts from symbol to number for writing to properties
    function geoFormatSymbolToNumber(sym) {
        if (sym == :const_deg) {
             return 0; // Degs
        } else if (sym == :const_dm) {
             return 1; // Degs/Mins
        } else if (sym == :const_dms) {
             return 2; // Degs/Mins/Secs
        } else if (sym == :const_utm) {
             return 3; // UTM (WGS84)
        } else if (sym == :const_usng) {
             return 4; // USNG (WGS84)
        } else if (sym == :const_mgrs) {
             return 5; // MGRS (WGS84)
        } else if (sym == :const_ukgr) {
             return 6; // UK Grid (OSGB36)
        } else if (sym == :const_qth) {
             return 7; // Maidenhead Locator / QTH Locator / IARU Locator
        } else if (sym == :const_sgrlv95) {
             return 8; // Swiss Grid LV95
        } else if (sym == :const_sgrlv03) {
             return 9; // Swiss Grid LV03
        } else if (sym == :const_sk42_deg) {
             return 10; // SK-42 (Degrees)
        } else if (sym == :const_sk42_grid) {
             return 11; // SK-42 (Orthogonal)
        } else {
            return -1; // Error condition
        }
    }
    
    // property store can't handle symbol types 
    // this method converts from number to symbol for reading from properties
    function geoFormatNumberToSymbol(num) {
        if (num == 0) {
             return :const_deg;  // Degs
        } else if (num == 1) {
             return :const_dm;   // Degs/Mins
        } else if (num == 2) {
             return :const_dms;  // Degs/Mins/Secs
        } else if (num == 3) {
             return :const_utm;  // UTM (WGS84)
        } else if (num == 4) {
             return :const_usng; // USNG (WGS84)
        } else if (num == 5) {
             return :const_mgrs; // MGRS (WGS84)
        } else if (num == 6) {
             return :const_ukgr; // UK Grid (OSGB36)
        } else if (num == 7) {
             return :const_qth;  // Maidenhead Locator / QTH Locator / IARU Locator
        } else if (num == 8) {
             return :const_sgrlv95; // Swiss Grid LV95
        } else if (num == 9) {
             return :const_sgrlv03; // Swiss Grid LV03
        } else if (num == 10) {
             return :const_sk42_deg; // SK-42 (Degrees)
        } else if (num == 11) {
             return :const_sk42_grid; // SK-42 (Orthogonal)
        } else {
             return :const_dms;  // Degs/Mins/Secs (default)
        }
    }
    
    // set geoFormat var and write to properties
    function setGeoFormat(format) {
        geoFormat = format;
        setPropertySafe("geo", geoFormatSymbolToNumber(format));
    }
    
    // return current geoFormat
    function getGeoFormat() {
        return geoFormat;
    }
    
    // initialize geoFormat var to current value in properties (called at app startup)
    function initGeoFormat() {
        var formatNum = getPropertySafe("geo");
        if (formatNum != null && formatNum != -1) {
            setGeoFormat(geoFormatNumberToSymbol(formatNum));
        } else {
            setGeoFormat(:const_dms);
        }
    }

	function setPropertySafe(key, val) {
        var deviceSettings = Sys.getDeviceSettings();
        var ver = deviceSettings.monkeyVersion;
        if ( ver != null && ver[0] != null && ver[1] != null && 
            ( (ver[0] == 2 && ver[1] >= 4) || ver[0] > 2 ) ) {
            // new school devices (>2.4.0) use Storage
            Props.setValue(key, val);
        } else {
            // old school devices use AppBase properties
            setProperty(key, val);
        }
    }
    
    function getPropertySafe(key) {
        var deviceSettings = Sys.getDeviceSettings();
        var ver = deviceSettings.monkeyVersion;
        if ( ver != null && ver[0] != null && ver[1] != null && 
            ( (ver[0] == 2 && ver[1] >= 4) || ver[0] > 2 ) ) {
            // new school devices (>2.4.0) use Storage
            return Props.getValue(key);
        } else {
            // old school devices use AppBase properties
            return getProperty(key);
        }
    }

    //! onStart() is called on application start up
    function onStart(state) {
        initGeoFormat();
        // startPositioning() call moved to Views
        //startPositioning();
    }
    
    function startPositioning(locationMode) {
        posLocationMode = locationMode;
        var deviceSettings = System.getDeviceSettings();
        var ver = deviceSettings.monkeyVersion;
        
        // custom configurations only in CIQ >= 3.3.6 (using 3.4.0 for our purposes)
        if ( ver != null && ver[0] != null && ver[1] != null && 
            ( (ver[0] == 3 && ver[1] >= 4) || ver[0] > 3 ) ) {
            if (Pos has :CONFIGURATION_GPS_GLONASS_GALILEO_BEIDOU_L1_L5 && 
		        Pos.hasConfigurationSupport(Pos.CONFIGURATION_GPS_GLONASS_GALILEO_BEIDOU_L1_L5)) {
                if (enablePositioningWithConfiguration(Pos.CONFIGURATION_GPS_GLONASS_GALILEO_BEIDOU_L1_L5)) {
                    System.println("Configuration: GPS/GLO/GAL/BEI/L1/L5");
                    return true;
                }
            } else if (Pos has :CONFIGURATION_GPS_GLONASS_GALILEO_BEIDOU_L1 &&
		               Pos.hasConfigurationSupport(Pos.CONFIGURATION_GPS_GLONASS_GALILEO_BEIDOU_L1)) {
                if (enablePositioningWithConfiguration(Pos.CONFIGURATION_GPS_GLONASS_GALILEO_BEIDOU_L1)) {
		            System.println("Configuration: GPS/GLO/GAL/BEI/L1");
                    return true;
                }
            } else if (Pos has :CONFIGURATION_GPS_GLONASS &&
		               Pos.hasConfigurationSupport(Pos.CONFIGURATION_GPS_GLONASS)) {
                if (enablePositioningWithConfiguration(Pos.CONFIGURATION_GPS_GLONASS)) {
		            System.println("Configuration: GPS/GLO");
                    return true;
                }
            } else if (Pos has :CONFIGURATION_GPS_GALILEO &&
		               Pos.hasConfigurationSupport(Pos.CONFIGURATION_GPS_GALILEO)) {
                if (enablePositioningWithConfiguration(Pos.CONFIGURATION_GPS_GALILEO)) {
		            System.println("Configuration: GPS/GAL");
                    return true;
                }
            } else if (Pos has :CONFIGURATION_GPS_BEIDOU &&
		               Pos.hasConfigurationSupport(Pos.CONFIGURATION_GPS_BEIDOU)) {
                if (enablePositioningWithConfiguration(Pos.CONFIGURATION_GPS_BEIDOU)) {
		            System.println("Configuration: GPS/BEI");
                    return true;
                }
            } else if (Pos has :CONFIGURATION_GPS &&
		               Pos.hasConfigurationSupport(Pos.CONFIGURATION_GPS)) {
                if (enablePositioningWithConfiguration(Pos.CONFIGURATION_GPS)) {
		            System.println("Configuration: GPS");
                    return true;
                }
            }
        } 
        
        // custom constellations only in CIQ >= 3.2.0
        if ( ver != null && ver[0] != null && ver[1] != null && 
            ( (ver[0] == 3 && ver[1] >= 2) || ver[0] > 3 ) ) {
            if (enablePositioningWithConstellations([
                    Pos.CONSTELLATION_GPS,
                    Pos.CONSTELLATION_GLONASS, 
                    Pos.CONSTELLATION_GALILEO
            ])) {
                System.println("Constellations: GPS/GLO/GAL");
                return true;
            }
            if (enablePositioningWithConstellations([
                    Pos.CONSTELLATION_GPS,
                    Pos.CONSTELLATION_GLONASS
            ])) {
                System.println("Constellations: GPS/GLO");
                return true;
            }
            if (enablePositioningWithConstellations([
                    Pos.CONSTELLATION_GPS,
                    Pos.CONSTELLATION_GALILEO,
            ])) {
                System.println("Constellations: GPS/GAL");
                return true;
            }
            if (enablePositioningWithConstellations([
                    Pos.CONSTELLATION_GPS
            ])) {
                System.println("Constellation: GPS");
                return true;
            }
        } else {
            Pos.enableLocationEvents(posLocationMode, method(:onPosition));
            System.println("GPS (Legacy Mode)");
        }
        return true;
    }
    
    function enablePositioningWithConstellations(constellations) {
        var success = false;
        try {
            Pos.enableLocationEvents({
                    :acquisitionType => posLocationMode,
                    :constellations => constellations
                },
                method(:onPosition)
            );
            success = true;
        } catch (ex) {
            System.println(ex.getErrorMessage() + ": " + constellations.toString());
            success = false;
        }
        return success;
    }
    
    function enablePositioningWithConfiguration(configuration) {
        var success = false;
        try {
            Pos.enableLocationEvents({
                    :acquisitionType => posLocationMode,
                    :configuration => configuration
                },
                method(:onPosition)
            );
            success = true;
        } catch (ex) {
            System.println(ex.getErrorMessage() + ": " + configuration.toString());
            success = false;
        }
        return success;
    }
    
    function stopPositioning() {
        Pos.enableLocationEvents(Pos.LOCATION_DISABLE, method(:onPosition));
    }
    
    // position change callback
    function onPosition(info) {
        currentPosInfo = info;
        Ui.requestUpdate();
    }
    
    function getCurrentPosition() {
        return currentPosInfo;
    }
    
    //! onStop() is called on application shutdown
    function onStop(state) {
        // stopPositioning() call moved to Views
        //stopPositioning();
    }

    //! Return the initial view of your application here
    function getInitialView() {
        return [ new GpsPositionView(), new GpsPositionDelegate() ];
    }
    
    function getGlanceView() {
        return [ new GpsPositionGlanceView() ];
    }

}