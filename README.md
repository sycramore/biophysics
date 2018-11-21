# biophysics
My biophysics collection containing data analysis scripts for molecular dynamics simulation

Dipole moment script (dipoles.tcl)

This script is written for VMD. It projects water dipole moments to a chosen axis and then averages the projection over all dipole moments. I wrote this script for my bachelor thesis in 2017. It uses the fact that taking the overall dipole moment of all water molecules in a given selection and then projected and averaged is the same as projecting each single dipole moment and average afterwards. This avoids looping over the water molecules and thus reduces running time of the script from 2.7 days to 45 minutes on a 16 CPU HPC.

Todo

Mean and std collection

Time correlation functions

Ramachandran plots
