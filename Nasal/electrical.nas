###############################################################################
##
##   Dornier DO J II - f - Bos (Wal)
##   by Marc Kraus :: Lake of Constance Hangar
##
##   Copyright (C) 2012 - 2016  Marc Kraus  (info(at)marc-kraus.de)
##
###############################################################################
# =============================================================================
#                          electrical settings             
# =============================================================================

strobe_switch = props.globals.getNode("controls/lighting/strobe", 0);
aircraft.light.new("controls/lighting/strobe-state", [0.05,0.1,0.05,0.1,0.05,1.30], strobe_switch);

beacon_switch = props.globals.getNode("controls/lighting/beacon", 1);
aircraft.light.new("controls/lighting/beacon-state", [1.0, 1.0], beacon_switch);
