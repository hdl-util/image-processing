action = "simulation"
sim_tool = "modelsim"
sim_top = "demosaic_tb"

sim_post_cmd = "vsim -novopt -do ../vsim.do -c demosaic_tb"

modules = {
  "local" : [ "../../test/" ],
}
