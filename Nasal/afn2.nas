###############################################################################
##
##   Dornier DO J II - f - Bos (Wal)
##   by Marc Kraus :: Lake of Constance Hangar
##
##   Copyright (C) 2012 - 2016  Marc Kraus  (info(at)marc-kraus.de)
##
###############################################################################
# =============================================================================
#                        AFN2 is working on VOR-DME               
# =============================================================================


var afn2Direction = func{
  var state =  props.globals.getNode("/instrumentation/nav/dme-in-range", 1);

  if (state.getBoolValue()){
    var th = getprop("/instrumentation/heading-indicator/indicated-heading-deg") or 0.0;
    var navh = getprop("/instrumentation/nav/heading-deg") or 0.0;

    # Heading correction
    var rotDiff = 0.0;
    rotDiff = navh - th;
    if (rotDiff > 180){
      rotDiff = -(360 - rotDiff);
    }

    setprop("/instrumentation/afn2/heading-correction",rotDiff);
  
  }else{
    setprop("/instrumentation/afn2/heading-correction",0);
  }

  settimer(afn2Direction, 0.125);

};

afn2Direction();
