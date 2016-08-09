###############################################################################
##
##   Dornier DO J II - f - Bos (Wal)
##   by Marc Kraus :: Lake of Constance Hangar
##
##   Copyright (C) 2012 - 2016  Marc Kraus  (info(at)marc-kraus.de)
##
###############################################################################
# =============================================================================
#                    Start up engine by engine            
# =============================================================================

setlistener("/controls/switches/start-one", func(st1) {
   var status1 = getprop("engines/engine[0]/running") or 0;
   if (st1.getBoolValue() and !status1) {
      var r1 = 300;
      var mix = 1.0;

      if (getprop("/controls/engines/engine[0]/magnetos") == 3 ){
        setprop("/controls/engines/engine[0]/cutoff", 0);
        setprop("/controls/engines/engine[0]/starter", 1);
      }

      setprop("engines/engine[0]/rpm", r1);
      setprop("engines/engine[0]/mixture", mix);
      settimer(func { setprop("/controls/engines/engine[0]/starter", 0); }, 4.0);

   }else{
      if (status1) {
        switchEngine(0);
      }
   }
});

setlistener("/controls/switches/start-two", func(st2) {
   var status2 = getprop("engines/engine[1]/running") or 0;
   if (st2.getBoolValue() and !status2) {
      var r1 = 300;
      var mix = 1.0;

      if (getprop("/controls/engines/engine[1]/magnetos") == 3 ){
        setprop("/controls/engines/engine[1]/cutoff", 0);
        setprop("/controls/engines/engine[1]/starter", 1);
      }

      setprop("engines/engine[1]/rpm", r1);
      setprop("engines/engine[1]/mixture", mix);
      settimer(func { setprop("/controls/engines/engine[1]/starter", 0); }, 4.0);

   }else{
      if (status2) {
        switchEngine(0);
      }
   }
});

####################  Controll of the Engines  ###################################
var switchEngine = func(eng){
  var status = getprop("engines/engine["~eng~"]/running");
  var clutch = getprop("engines/engine["~eng~"]/clutch");
  var as = getprop("/instrumentation/airspeed-indicator/true-speed-kt");
  var mix = getprop("engines/engine["~eng~"]/mixture");
  var r1 = getprop("engines/engine["~eng~"]/rpm");
  var magnetos = props.globals.getNode("/controls/engines/engine["~eng~"]/magnetos", 1);
  var cutoff = props.globals.getNode("/controls/engines/engine["~eng~"]/cutoff", 1);
  var mpinhg = props.globals.getNode("/controls/engines/engine["~eng~"]/mp-inhg", 1);
  var mposi = props.globals.getNode("/controls/engines/engine["~eng~"]/mp-osi", 1);
  var starter = props.globals.getNode("/controls/engines/engine["~eng~"]/starter", 1);
  var cranking = props.globals.getNode("/controls/engines/engine["~eng~"]/cranking", 1);

  # engine is running
  # speed is not above 35kt (80 km/h)
  # speed is higher than 35kt, clutch must be unlocked
  if (status == 1){
    if (as < 35){
        r1 = 10;
        mix = 0.0;
        magnetos.setValue(0);
        mpinhg.setValue(0);
        mposi.setValue(0);
        cutoff.setValue(1);

        if(eng == 0) {
            screen.log.write("WARNING: front engine -> off", 1.0, 0.1, 0.1);
        }elsif(eng == 1){
            screen.log.write("WARNING: back engine -> off", 1.0, 0.1, 0.1);
        }else{
            screen.log.write("NOTHING TO DO!", 1.0, 0.1, 0.1);
        }
        interpolate("/engines/engine["~eng~"]/rpm",300,0.25);
    }elsif (clutch == 0){
        r1 = 10;
        mix = 0.0;
        magnetos.setValue(0);
        mpinhg.setValue(0);
        mposi.setValue(0);
        cutoff.setValue(1);

        if(eng == 0) {
            screen.log.write("WARNING: front engine -> off", 1.0, 0.1, 0.1);
        }elsif(eng == 1){
            screen.log.write("WARNING: back engine -> off", 1.0, 0.1, 0.1);
        }else{
            screen.log.write("NOTHING TO DO!", 1.0, 0.1, 0.1);
        }
        interpolate("/engines/engine["~eng~"]/rpm",300,0.25);
    }else{
        screen.log.write("Unlock this engine first - you are to faster than 80 km/h!", 1.0, 0.7, 0.0);
    }
  # or start up this engine
  }else {
      setprop("/controls/electric/battery-switch",1);
    if (eng == 0) {
      setprop("/controls/switches/start-one", 1);
      setprop("/engines/engine[0]/clutch", 1);
      setprop("/controls/switches/clutch1-cover", 0);
    }
    if (eng == 1) {
      setprop("/controls/switches/start-two", 1);
      setprop("/engines/engine[1]/clutch", 1);
      setprop("/controls/switches/clutch2-cover", 0);
    }
    r1 = 300;
    mix = 1.0;

    starter.setValue(1);
    cranking.setValue(1);

    magnetos.setValue(3);
    cutoff.setValue(0);
  }
  setprop("engines/engine["~eng~"]/rpm", r1);
  setprop("engines/engine["~eng~"]/mixture", mix);
  # switch starter of if engine is running
  if (status == 1 ){
    starter.setValue(0);
    cranking.setValue(0);
  }
}

###############  Use for keybord startup with s ###################################
var startEngines = func{

  var r0 = getprop("engines/engine[0]/running");
  var r1 = getprop("engines/engine[1]/running");

  if(!r0) {
    switchEngine(0);
    return
  }else{
    setprop("/controls/engines/engine[0]/starter", 0);
    setprop("/controls/engines/engine[0]/cranking", 0);
  }
  if(!r1) {
    switchEngine(1);
    return
  }else{
    setprop("/controls/engines/engine[1]/starter", 0);
    setprop("/controls/engines/engine[1]/cranking", 0);
  }
}

###############  use for keybord cutoff with S ###################################
var stopEngines = func{

  var r0 = getprop("engines/engine[0]/running");
  var r1 = getprop("engines/engine[1]/running");

  if(r1) {
    switchEngine(1);
    return
  }
  if(r0) {
    switchEngine(0);
    return
  }
}
