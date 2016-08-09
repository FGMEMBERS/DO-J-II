###############################################################################
##
##   Dornier DO J II - f - Bos (Wal)
##   by Marc Kraus :: Lake of Constance Hangar
##
##   Copyright (C) 2012 - 2016  Marc Kraus  (info(at)marc-kraus.de)
##
###############################################################################
# =============================================================================
#                      Main Functions (only for Copilot)              
# =============================================================================

setlistener("/sim/signals/fdm-initialized", func {
    # init copilot-pos
    setprop("/controls/special/copilot-pos/", 0);
});
###############################################################################
setlistener("/sim/signals/fdm-initialized", func {
    setprop("/controls/special/copilot-pos/", 0);
    # Disable the autopilot menu.
    gui.menuEnable("autopilot", 0);
});

# say the pilot, where you are in the aircraft
setlistener("/sim/current-view/view-number", func(v1) {
    var v1 = v1.getValue() or 0;
    setprop("/controls/special/copilot-pos/", v1);
    # open hatch, if copilot stand up
    if (v1 == 8){
      interpolate("/controls/doors/position-norm[1]", 1  , 2);
    } 
});

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

# The not used function from the starter.nas file
# ==================================================
####################  Controll of the Engines  ###################################
var switchEngine = func(eng){
  # nothing to do
}

###############  Use for keybord startup with s ###################################
var startEngines = func{
  # nothing to do
}

###############  use for keybord cutoff with S ###################################
var stopEngines = func{
  # nothing to do
}

# If trim wheels are not on 0 and you click the center of this wheel
var trimBackTime = 0.0;
var applyTrimWheels = func(v, which = 0) {
  # nothing to do for the copilot
}

var changeView = func (n){
  var actualView = props.globals.getNode("/sim/current-view/view-number", 1);
  if (actualView.getValue() == 8){
    # if we leave the stand up place, close the hatch
    interpolate("/controls/doors/position-norm[1]", 0  , 2);
  }
  if (actualView.getValue() == n){
    actualView.setValue(0);
  }else{
    actualView.setValue(n);
  }
}

var hookTheCatapult = func {
  # nothing to do
}
