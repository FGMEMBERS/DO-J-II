###############################################################################
##
##   Dornier DO J II - f - Bos (Wal)
##   by Marc Kraus :: Lake of Constance Hangar
##
##   Copyright (C) 2012 - 2016  Marc Kraus  (info(at)marc-kraus.de)
##
###############################################################################
# =============================================================================
#                               Main Functions (only for Pilot)              
# =============================================================================

setlistener("/sim/signals/fdm-initialized", func {
    setprop("/engines/engine[0]/rpm", 10);
    setprop("/engines/engine[1]/rpm", 6);
    # init pilot-pos
    setprop("/controls/special/pilot-pos/", 0);
    # fire up
    ground_control();
    do_j_controller();
});

# help on water control the rudder with towel thruster
setlistener("/controls/flight/rudder", func(r) {
    var r = r.getValue() or 0;
    var a = getprop("/position/altitude-agl-ft") or 0;
    if (a < 3) setprop("/controls/special/catapult-carrier-crane/towel/", r * 0.2);
}, 0, 1);

# say the world, where you are in the aircraft
setlistener("/sim/current-view/view-number", func(p1) {
    var p1 = p1.getValue() or 0;
    setprop("/controls/special/pilot-pos/", p1);
    # open hatch, if copilot stand up
    if (p1 == 8){
      interpolate("/controls/doors/position-norm[0]", 1  , 2);
    } 
});

  # fake for give the feeling of an unclutched engine
setlistener("/engines/engine[0]/clutch", func(c1) {
    if (c1.getBoolValue()) { 
      setprop("/controls/engines/engine[0]/mixture/", 1.0); 
    }else{ 
      setprop("/controls/engines/engine[0]/mixture/", 0.2) 
    };
});

setlistener("/engines/engine[0]/clutch", func(c2) {
    if (c2.getBoolValue()) { 
      setprop("/controls/engines/engine[1]/mixture/", 1.0); 
    }else{ 
      setprop("/controls/engines/engine[1]/mixture/", 0.2) 
    };
});

var do_j_controller = func() {
  # look for the clutch status

  if (getprop("/engines/engine[1]/clutch")) { setprop("/controls/engines/engine[1]/mixture/", 1.0) }else{ setprop("/controls/engines/engine[1]/mixture/", 0.3) };

  # smooth turning propeller if engines of with airspeed
  for(var n = 0; n <= 1; n += 1){
     var thisengine = props.globals.getNode("/engines/engine["~n~"]");
     if (thisengine.getNode("running").getBoolValue() == 0 and getprop("/controls/engines/engine["~n~"]/starter") == 0){
        interpolate("/engines/engine["~n~"]/rpm", getprop("/instrumentation/airspeed-indicator/true-speed-kt") or 0, 2);
     }
  }

  settimer(func { do_j_controller(); }, 2.0);
}


# ground control
var ground_control = func {
  var wakes = props.globals.getNode("/controls/special/wakes");
  var lat = getprop("/position/latitude-deg");
  var lon = getprop("/position/longitude-deg");
  var airspeed = getprop("/instrumentation/airspeed-indicator/indicated-speed-kt");
  var contact1 = getprop("/gear/gear[0]/wow"); 
  var contact2 = getprop("/gear/gear[1]/wow");
  var contact3 = getprop("/gear/gear[2]/wow");
  var contact4 = getprop("/gear/gear[3]/wow"); 
  var water = 0;
  var info = geodinfo(lat, lon);
  var kaputt = getprop("/sim/crashed");

  # where we are
  if (info != nil) {
    if (info[1] != nil and info[1].solid !=nil){
      if (!info[1].solid){
        water = 1;
      }else{
        water = 0;
      }
    } 
  }

  if (water and airspeed > 15 and !kaputt and (contact1 or contact2 or contact3 or contact4)){
    wakes.setBoolValue(1);
  }else{
    wakes.setBoolValue(0);
  }

  settimer(func { ground_control(); }, 0.1);
}

# Door action
var PilotDoor = func {
   var pilot = getprop("/controls/doors/position-norm[0]") or 0;
   if (pilot < 1){
      interpolate("/controls/doors/position-norm[0]", 1  , 2);
   }else{
      interpolate("/controls/doors/position-norm[0]", 0  , 2);
   }
}
var CopilotDoor = func {
   var copilot = getprop("/controls/doors/position-norm[1]") or 0;
   if (copilot < 1){
      interpolate("/controls/doors/position-norm[1]", 1  , 2);
   }else{
      interpolate("/controls/doors/position-norm[1]", 0  , 2);
   }
}
var FreightHatch = func {
   var freight = getprop("/controls/doors/position-norm[2]") or 0;
   if (freight < 1){
      interpolate("/controls/doors/position-norm[2]", 1  , 1);
   }else{
      interpolate("/controls/doors/position-norm[2]", 0  , 1);
   }
}
var CockpitDoor = func {
   var cockpit = getprop("/controls/doors/position-norm[3]") or 0;
   if (cockpit < 1){
      interpolate("/controls/doors/position-norm[3]", 1  , 1);
   }else{
      interpolate("/controls/doors/position-norm[3]", 0  , 1);
   }
}
var FreightDoor = func {
   var freight_d = getprop("/controls/doors/position-norm[4]") or 0;
   if (freight_d < 1){
      interpolate("/controls/doors/position-norm[4]", 1  , 1);
   }else{
      interpolate("/controls/doors/position-norm[4]", 0  , 1);
   }
}

# If trim wheels are not on 0 and you click the center of this wheel
var trimBackTime = 4.0;
var applyTrimWheels = func(v, which = 0) {
    if (which == 0) { interpolate("/controls/flight/elevator-trim", v, trimBackTime); }
    if (which == 1) { interpolate("/controls/flight/rudder-trim", v, trimBackTime); }
    if (which == 2) { interpolate("/controls/flight/aileron-trim", v, trimBackTime); }
}

var changeView = func (n){
  var actualView = props.globals.getNode("/sim/current-view/view-number", 1);
  if (actualView.getValue() == 8){
    # if we leave the stand up place, close the hatch
    interpolate("/controls/doors/position-norm[0]", 0  , 2);
  }
  if (actualView.getValue() == n){
    actualView.setValue(0);
  }else{
    actualView.setValue(n);
  }
}
