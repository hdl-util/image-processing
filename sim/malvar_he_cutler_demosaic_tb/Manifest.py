action = "simulation"
sim_tool = "modelsim"
sim_top = "malvar_he_cutler_demosaic_tb"

sim_post_cmd = "vsim -novopt -do ../vsim.do -c malvar_he_cutler_demosaic_tb"

modules = {
  "local" : [ "../../test/" ],
}
