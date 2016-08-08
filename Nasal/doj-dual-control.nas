###############################################################################
##  Nasal for dual control the DO-J-II f Bos over the multiplayer network.
##
##  Copyright (C) 2007 - 2008  Anders Gidenstam  (anders(at)gidenstam.org)
##  This file is licensed under the GPL license version 2 or later.
##
##  For the DO-J-II f Bos, written in August 2012 by Marc Kraus
##
###############################################################################

## Renaming (almost :)
var DCT = dual_control_tools;

## Pilot/copilot aircraft identifiers. Used by dual_control.
var pilot_type   = "Aircraft/DO-J-II/Models/DO-J-II.xml";
var copilot_type = "Aircraft/DO-J-II/Models/DO-J-cp.xml";

############################ PROPERTIES MP ###########################
var copilot_pos                 = "sim/multiplay/generic/int[3]";
var copilot_rdf_power_on        = "sim/multiplay/generic/int[0]";
var copilot_select_vor_or_ndb   = "sim/multiplay/generic/int[1]";
var copilot_adf_selected        = "sim/multiplay/generic/int[2]";
var copilot_nav_selected        = "sim/multiplay/generic/float[0]";
var copilot_rdf_rotation_deg    = "sim/multiplay/generic/float[1]";
var copilot_heading_correction_msg = "sim/multiplay/generic/string[0]"; 
var copilot_hatch               = "sim/multiplay/generic/float[2]";
var copilot_freight_hatch       = "sim/multiplay/generic/float[3]";
var copilot_cockpit_door        = "sim/multiplay/generic/float[4]";
var copilot_freight_door        = "sim/multiplay/generic/float[5]";
var copilot_headset             = "sim/multiplay/generic/int[5]";

var pilot_copilot_pos           = "/controls/special/copilot-pos"; 
var pilot_rdf_power_on          = "/instrumentation/rdf/power-on";
var pilot_select_vor_or_ndb     = "/instrumentation/rdf/frequency-select-knob"; 
var pilot_adf_selected          = "/instrumentation/adf/frequencies/selected-khz";  
var pilot_nav_selected          = "/instrumentation/nav/frequencies/selected-mhz";                   
var pilot_rdf_rotation_deg      = "/instrumentation/rdf/rotation-deg";       
var heading_correction_msg      = "/instrumentation/rdf/message-to-pilot";  
var pilot_copilot_hatch         = "/controls/doors/position-norm[1]";
var pilot_copilot_freight_hatch = "/controls/doors/position-norm[2]";
var pilot_copilot_cockpit_door  = "/controls/doors/position-norm[3]";
var pilot_copilot_freight_door  = "/controls/doors/position-norm[4]";
var pilot_copilot_headset       = "/instrumentation/rdf/headset/position";

# bool
var div_bool                    = ["/controls/lighting/beacon",
                                   "/controls/lighting/strobe",
                                   "/controls/switches/clutch1-cover",
                                   "/controls/switches/clutch2-cover",
                                   "/controls/switches/start-one",
                                   "/controls/switches/start-two",
                                   "/engines/engine[0]/clutch",
                                   "/engines/engine[1]/clutch",
                                   "/controls/electric/battery-switch",
                                   "/instrumentation/k4/clutch",
                                   "/engines/engine[0]/running", 
                                   "/engines/engine[1]/running", 
                                   "/engines/engine[0]/cranking", 
                                   "/engines/engine[1]/cranking"];

# doubles
var div_double                  = ["/controls/engines/engine[0]/magnetos",
                                   "/controls/engines/engine[1]/magnetos",
                                   "/instrumentation/frw/flight-time/hours", 
                                   "/instrumentation/frw/flight-time/minutes", 
                                   "/instrumentation/frw/flight-time/seconds",
                                   "/instrumentation/heading-indicator/offset-deg",
                                   "/controls/engines/engine[0]/throttle",
                                   "/controls/engines/engine[1]/throttle",
                                   "/controls/flight/aileron-trim",
                                   "/controls/flight/elevator-trim",
                                   "/controls/flight/rudder-trim",
                                   "/instrumentation/k4/dir-pos-knob",
                                   "/instrumentation/k4/hydraulic-aileron",
                                   "/instrumentation/k4/hydraulic-elevator",
                                   "/instrumentation/k4/hydraulic-press-a",
                                   "/instrumentation/k4/hydraulic-press-e"];  

var switch_mpp     = "sim/multiplay/generic/int[0]";
var TDM_mpp        = "sim/multiplay/generic/string[0]";

var l_dual_control  = "/dual-control/active";

######################################################################
###### Used by dual_control to set up the mappings for the pilot #####
######################## PILOT TO COPILOT ############################
######################################################################

var pilot_connect_copilot = func (copilot) {
  # Make sure dual-control is activated in the FDM FCS.
  print("Pilot section");
  setprop(l_dual_control, 1);

  # if copilot is comming on board set position and enabled for rdf action on zero
  if(getprop("/instrumentaion/rdf/headset/enabled")){
      setprop("/instrumentation/rdf/headset/position", 1);
  }else{
      setprop("/instrumentation/rdf/headset/position", 0);
  }

  return [
      ##################################################
      # Map copilot properties to buffer properties

       ######################################################################
       ######################## COPILOT TO PILOT ############################
       # Process properties to send.
       ######################################################################
       DCT.Translator.new
       (copilot.getNode(copilot_pos),
        props.globals.getNode(pilot_copilot_pos, 1)),

       DCT.Translator.new
       (copilot.getNode(copilot_rdf_power_on),
        props.globals.getNode(pilot_rdf_power_on, 1)),

       DCT.Translator.new
       (copilot.getNode(copilot_select_vor_or_ndb),
        props.globals.getNode(pilot_select_vor_or_ndb, 1)),

       DCT.Translator.new
       (copilot.getNode(copilot_adf_selected),
        props.globals.getNode(pilot_adf_selected, 1)),

       DCT.Translator.new
       (copilot.getNode(copilot_nav_selected),
        props.globals.getNode(pilot_nav_selected, 1)),

       DCT.Translator.new
       (copilot.getNode(copilot_rdf_rotation_deg),
        props.globals.getNode(pilot_rdf_rotation_deg, 1)),

       DCT.Translator.new
       (copilot.getNode(copilot_heading_correction_msg),
        props.globals.getNode(heading_correction_msg, 1)),

       DCT.Translator.new
       (copilot.getNode(copilot_hatch),
        props.globals.getNode(pilot_copilot_hatch, 1)),

       DCT.Translator.new
       (copilot.getNode(copilot_freight_hatch),
        props.globals.getNode(pilot_copilot_freight_hatch, 1)),

       DCT.Translator.new
       (copilot.getNode(copilot_cockpit_door),
        props.globals.getNode(pilot_copilot_cockpit_door, 1)),

       DCT.Translator.new
       (copilot.getNode(copilot_freight_door),
        props.globals.getNode(pilot_copilot_freight_door, 1)),

       DCT.Translator.new
       (copilot.getNode(copilot_headset),
        props.globals.getNode(pilot_copilot_headset, 1)),

      ############################# COPILOT GET FROM PILOT ##############################
 
       DCT.SwitchEncoder.new
        ([
          props.globals.getNode(div_bool[0]),
          props.globals.getNode(div_bool[1]),
          props.globals.getNode(div_bool[2]),
          props.globals.getNode(div_bool[3]),
          props.globals.getNode(div_bool[4]),
          props.globals.getNode(div_bool[5]),
          props.globals.getNode(div_bool[6]),
          props.globals.getNode(div_bool[7]),
          props.globals.getNode(div_bool[8]),
          props.globals.getNode(div_bool[9]),
          props.globals.getNode(div_bool[10]),
          props.globals.getNode(div_bool[11]),
          props.globals.getNode(div_bool[12]),
          props.globals.getNode(div_bool[13])
         ], props.globals.getNode(switch_mpp))
  ];
}

##############
var pilot_disconnect_copilot = func {
  setprop(l_dual_control, 0);
  setprop("/controls/special/copilot-pos", 999);
}

######################################################################
##### Used by dual_control to set up the mappings for the copilot ####
######################## PILOT TO COPILOT ############################
######################################################################

var copilot_connect_pilot = func (pilot) {
  # Make sure dual-control is activated in the FDM FCS.
  print("Copilot section");
  setprop(l_dual_control, 1);

  return [

      ##################################################
      # Map pilot properties to copilot internal properties
      DCT.Translator.new(pilot.getNode("sim/multiplay/generic/float[0]"),
                         props.globals.getNode("/position/altitude-agl-ft", 1),1),
      DCT.Translator.new(pilot.getNode("engines/engine[0]/rpm"),
                         props.globals.getNode("engines/engine[0]/rpm", 1),1),
      DCT.Translator.new(pilot.getNode("engines/engine[1]/rpm"),
                         props.globals.getNode("engines/engine[1]/rpm", 1),1),

      DCT.SwitchDecoder.new
        (pilot.getNode(switch_mpp),
        [
         func(b){props.globals.getNode(div_bool[0]).setValue(b);},
         func(b){props.globals.getNode(div_bool[1]).setValue(b);},
         func(b){props.globals.getNode(div_bool[2]).setValue(b);},
         func(b){props.globals.getNode(div_bool[3]).setValue(b);},
         func(b){props.globals.getNode(div_bool[4]).setValue(b);},
         func(b){props.globals.getNode(div_bool[5]).setValue(b);},
         func(b){props.globals.getNode(div_bool[6]).setValue(b);},
         func(b){props.globals.getNode(div_bool[7]).setValue(b);},
         func(b){props.globals.getNode(div_bool[8]).setValue(b);},
         func(b){props.globals.getNode(div_bool[9]).setValue(b);},
         func(b){props.globals.getNode(div_bool[10]).setValue(b);},
         func(b){props.globals.getNode(div_bool[11]).setValue(b);},
         func(b){props.globals.getNode(div_bool[12]).setValue(b);},
         func(b){props.globals.getNode(div_bool[13]).setValue(b);}
        ]),

        DCT.Translator.new(props.globals.getNode(div_bool[0], 1), pilot.getNode("/"~div_bool[0])),
        DCT.Translator.new(props.globals.getNode(div_bool[1], 1), pilot.getNode("/"~div_bool[1])),
        DCT.Translator.new(props.globals.getNode(div_bool[2], 1), pilot.getNode("/"~div_bool[2])),
        DCT.Translator.new(props.globals.getNode(div_bool[3], 1), pilot.getNode("/"~div_bool[3])),
        DCT.Translator.new(props.globals.getNode(div_bool[4], 1), pilot.getNode("/"~div_bool[4])),
        DCT.Translator.new(props.globals.getNode(div_bool[5], 1), pilot.getNode("/"~div_bool[5])),
        DCT.Translator.new(props.globals.getNode(div_bool[6], 1), pilot.getNode("/"~div_bool[6])),
        DCT.Translator.new(props.globals.getNode(div_bool[7], 1), pilot.getNode("/"~div_bool[7])),
        DCT.Translator.new(props.globals.getNode(div_bool[8], 1), pilot.getNode("/"~div_bool[8])),
        DCT.Translator.new(props.globals.getNode(div_bool[9], 1), pilot.getNode("/"~div_bool[9])),
        DCT.Translator.new(props.globals.getNode(div_bool[10], 1), pilot.getNode("/"~div_bool[10])),
        DCT.Translator.new(props.globals.getNode(div_bool[11], 1), pilot.getNode("/"~div_bool[11])),
        DCT.Translator.new(props.globals.getNode(div_bool[12], 1), pilot.getNode("/"~div_bool[12])),
        DCT.Translator.new(props.globals.getNode(div_bool[13], 1), pilot.getNode("/"~div_bool[13]))
    ];
}

var copilot_disconnect_pilot = func {
  setprop(l_dual_control, 0);
  # if copilot is going from board set position and enabled for rdf action on zero
  if(getprop("/instrumentaion/rdf/headset/enabled")){
      setprop("/instrumentation/rdf/headset/position", 1);
  }else{
      setprop("/instrumentation/rdf/headset/position", 0);
  }
  setprop("/controls/special/copilot-pos", 999);
}
