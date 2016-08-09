###############################################################################
##
##   Dornier DO J II - f - Bos (Wal)
##   by Marc Kraus :: Lake of Constance Hangar
##
##   Copyright (C) 2012 - 2016  Marc Kraus  (info(at)marc-kraus.de)
##
###############################################################################
# =============================================================================
#                   Siemens Autopilot K4 G for flightgear          
# =============================================================================

setlistener("/sim/signals/fdm-initialized", func {
      setprop("/autopilot/locks/altitude", "");
      setprop("/autopilot/locks/heading", "");
      setprop("/autopilot/locks/speed", "");
      setprop("/autopilot/settings/heading-bug-deg", getprop("/instrumentation/heading-indicator/indicated-heading-deg"));
});

setlistener("/autopilot/locks/heading", func(hdgAuto){
      var hdgAuto = hdgAuto.getValue();
      if (hdgAuto) {
        setprop("/instrumentation/k4/clutch", 1);
      } elsif (hdgAuto != "" and !getprop("/instrumentation/k4/clutch")){
        setprop("/instrumentation/k4/clutch", 1);
      }else{
        setprop("/instrumentation/k4/clutch", 0);
      }
});

# if Siemens K4 is activated by EIN-AUS (clutch)
setlistener("/instrumentation/k4/clutch", func (clutch){
    var clutch = clutch.getBoolValue();

    if (clutch == 1){
      # if clutch is on, take the k4 like a wings-leveler
      # but its better for the following steering to go with heading-hold :-)
      setprop("/autopilot/locks/heading", "dg-heading-hold");
      setprop("/autopilot/locks/altitude", "altitude-hold");
      setprop("/autopilot/settings/target-altitude-ft", getprop("/position/altitude-ft"));

      # give a taste of slow hydraulic pressure
      interpolate("/instrumentation/k4/hydraulic-press-e", 1.0, 3);
      interpolate("/instrumentation/k4/hydraulic-press-a", 1.0, 4);

      # give a taste of the slow working hydraulic control
      setPressure();
  
    }else{
      setprop("/autopilot/locks/altitude", "");
      setprop("/autopilot/locks/heading", "");
      setprop("/autopilot/locks/speed", "");
      doj.applyTrimWheels(0, 0);
      doj.applyTrimWheels(0, 1);
      doj.applyTrimWheels(0, 2);

      # give a taste of slow hydraulic pressure
      interpolate("/instrumentation/k4/hydraulic-press-e", 0.0, 2);
      interpolate("/instrumentation/k4/hydraulic-press-a", 0.0, 2.4);

      # give a taste of the slow working hydraulic control
      interpolate("/instrumentation/k4/hydraulic-aileron", 0.0, 1.4);
      interpolate("/instrumentation/k4/hydraulic-elevator", 0.0, 1.6);
    }
});

var setPressure = func {
    if(getprop("/instrumentation/k4/clutch")){

      setprop("/instrumentation/k4/hydraulic-aileron", getprop("surface-positions/aileron-pos-norm"));
      setprop("/instrumentation/k4/hydraulic-elevator", getprop("surface-positions/elevator-pos-norm"));
      settimer(setPressure, 0);
    }
}



