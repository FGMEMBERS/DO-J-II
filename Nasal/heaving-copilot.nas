###############################################################################
##
##   Dornier DO J II - f - Bos (Wal)
##   by Marc Kraus :: Lake of Constance Hangar
##
##   Copyright (C) 2012 - 2014  Marc Kraus  (info(at)marc-kraus.de)
##
###############################################################################
var debug_sc = 0;
var debug_cc = 0;

# =============================================================================
#                       Heaving action for copilot             
# =============================================================================
var schwabenland_index = -1;    # the index of the /ai/models/carrier [is_cam_carrier]
var westfalen_index    = -1;
var is_engaged = -1;  # the index of the /ai/models/multiplayer/ - aircraft on that position [is_other]
var is_heaving = -1;  # the index of th  /ai/models/multiplayer/ - aircraft on that position [is_other]

setlistener("/sim/signals/fdm-initialized", func {
    # init the cargo on board
    settimer(func{ is_cam_carrier(); }, 0.25); 
    settimer(func{ init_cargo(); }, 1); # if nobody is on crane or heaving an we start later look for cargo
    settimer(func{ show_crane_state(); }, 2); # if nobody is on crane or heaving an we start later look for cargo 
},1,0);
found_cargo = 0;

############################################# Heaving procedure ########################################
# find always an active mp DO-J or yourself for the crane anmimation on board
var show_crane_state = func() {

    is_other();

    if(debug_sc){
      print ("schwabenland_index is: "~schwabenland_index);
      print ("is_engaged is: "~is_engaged);
      print ("is_heaving is: "~is_heaving);
    }

    if (schwabenland_index >= 0) {

      # if there is no other aircraft
      if (is_heaving < 0 and is_engaged < 0){
          setprop("/ai/models/carrier["~schwabenland_index~"]/surface-positions/crane-turn",
                  getprop("/controls/special/catapult-carrier-crane/multi-turn") or 0);
          setprop("/ai/models/carrier["~schwabenland_index~"]/surface-positions/crane-stand",
                  getprop("/controls/special/catapult-carrier-crane/multi-stand") or 0);
          setprop("/ai/models/carrier["~schwabenland_index~"]/surface-positions/crane-hook-locked",
                  getprop("/controls/special/catapult-carrier-crane/hook-locked") or 0);
          # cargo
          setprop("/ai/models/carrier["~schwabenland_index~"]/controls/cargo",
                  getprop("/controls/special/catapult-carrier-crane/cargo-schwabenland") or 0);
          # nobody can hook the cat, if somebody is on the crane
          setprop("/controls/special/catapult-carrier-crane/crane-is-free", 1);
          # if nobody (we also) is on the hook or catapult the crane stand up.
          var gls = getprop("/gear/launchbar/state") or "";
          var scn = getprop("/controls/special/catapult-carrier-crane/search-carrier") or 0;
          var mst = getprop("/controls/special/catapult-carrier-crane/multi-stand") or 0;
          if ( mst < 1.0 and !scn and gls == "Disengaged"){
             interpolate("/controls/special/catapult-carrier-crane/multi-stand", 0.0, 6);
             interpolate("/controls/special/catapult-carrier-crane/multi-turn", 0.0, 6);
          }

      }else{
          var mp_index = -1;
          if (is_heaving >= 0 ) mp_index = is_heaving;
          if (is_engaged >= 0 ) mp_index = is_engaged;
          # set on the carrier
          setprop("/ai/models/carrier["~schwabenland_index~"]/surface-positions/crane-turn",
                  getprop("/ai/models/multiplayer["~mp_index~"]/sim/multiplay/generic/float[12]") or 0);
          setprop("/ai/models/carrier["~schwabenland_index~"]/surface-positions/crane-stand",
                  getprop("/ai/models/multiplayer["~mp_index~"]/sim/multiplay/generic/float[13]") or 0);
          setprop("/ai/models/carrier["~schwabenland_index~"]/surface-positions/crane-hook-locked",
                  getprop("/ai/models/multiplayer["~mp_index~"]/sim/multiplay/generic/int[19]") or 0);
          # cargo
          setprop("/ai/models/carrier["~schwabenland_index~"]/controls/cargo",
                  getprop("/ai/models/multiplayer["~mp_index~"]/sim/multiplay/generic/float[15]") or 0);
          # and the same on your local aircraft
          setprop("/controls/special/catapult-carrier-crane/multi-turn",
                  getprop("/ai/models/multiplayer["~mp_index~"]/sim/multiplay/generic/float[12]") or 0);
          setprop("/controls/special/catapult-carrier-crane/multi-stand",
                  getprop("/ai/models/multiplayer["~mp_index~"]/sim/multiplay/generic/float[13]") or 0);

          setprop("/controls/special/catapult-carrier-crane/cargo-schwabenland",
                  getprop("/ai/models/multiplayer["~mp_index~"]/sim/multiplay/generic/float[15]") or 0);
          # nobody can hook the cat, if somebody is on the crane
          setprop("/controls/special/catapult-carrier-crane/crane-is-free", 0);
      }


    } # end schwabenland_index

    settimer(show_crane_state, 0);
}

# cam (catapult aircraft merchantman) in range all 11.125 sec. only
var is_cam_carrier = func {
    if (debug_cc) print("Suchfunktion is_cam_carrier aufgerufen."); 
    var mp_cat = props.globals.getNode("/ai/models").getChildren("carrier");
    var tt = size(mp_cat);

    var shipsName = "";
    schwabenland_index = -1;
    westfalen_index = -1;

    settimer(func{ is_cam_carrier(); }, 11.125);

    for(var i = 0; i < tt; i += 1) {
        if (mp_cat[i].getNode("name") != nil) var shipsName = mp_cat[i].getNode("name").getValue();
        if (shipsName == "Schwabenland"){
          if (debug_cc) print(shipsName~" gefunden");
          schwabenland_index = i;
          return;
        }elsif (shipsName == "Westfalen"){
          if (debug_cc) print(shipsName~" gefunden");
          westfalen_index = i;
          return;
        }else{
          if (debug_cc) print(shipsName~" gefunden, suche weiter");
          schwabenland_index = -1;
        }
    }
}

# main function to look always, who is the master of cargo and crane :-)
var is_other = func {

    var mpOther = props.globals.getNode("/ai/models").getChildren("multiplayer");
    var otherNr = size(mpOther);

    is_engaged = -1;
    is_heaving = -1;
    
    if (debug_sc) print("otherNr:" ~otherNr);

    # find other DO-J which are on cat or crane
    for(var v = 0; v < otherNr; v += 1) {

       if (mpOther[v].getNode("sim/model/path").getValue() == "Aircraft/DO-J-II/Models/DO-J-II.xml" and
           mpOther[v].getNode("id").getValue() >= 0 ) {

           var searchCrane = mpOther[v].getNode("sim/multiplay/generic/int[18]").getValue() or 0;

           if (( mpOther[v].getNode("sim/multiplay/generic/string[1]").getValue() == "Engaged" or 
                 mpOther[v].getNode("sim/multiplay/generic/string[1]").getValue() == "Launching")){
               if(is_engaged >= 0){ 
                  is_engaged = is_engaged;
               }else{
                  is_engaged = v;
               }
           }

           if (searchCrane){
               if(is_heaving >= 0){ 
                  is_heaving = is_heaving;
               }else{
                  is_heaving = v;
               }
           }
       }
    }
}

# only for start-up, if other multiplayer are not on cat or crane action but in range
var init_cargo = func {
    var mpDos = props.globals.getNode("/ai/models").getChildren("multiplayer");
    var otherdos = size(mpDos);

    for(var d = 0; d < otherdos; d += 1) {

        if (mpDos[d].getNode("sim/model/path").getValue() == "Aircraft/DO-J-II/Models/DO-J-II.xml" and
          mpDos[d].getNode("id").getValue() >= 0 and
          found_cargo != 1) {

          setprop("/controls/special/catapult-carrier-crane/cargo-schwabenland",
                  getprop("/ai/models/multiplayer["~d~"]/sim/multiplay/generic/float[15]") or 0);

          var nameOf = getprop("/ai/models/multiplayer["~d~"]/callsign");
          screen.log.write("You recept loading informations from "~ nameOf ~".", 0.9, 0.8, 0.0); 
          found_cargo = 1;
      }
    }

}

##################### Take cargo on Schwabenland #####################################
# nothing todo fot the Copilot
var take_cargo = func {
    screen.log.write("This is not your job!", 1.0, 0.7, 0.0);
}




