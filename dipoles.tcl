#this is a script to run with VMD version 1.9
#script needs plugin pbctools 2.5 for pbc wrapping

package require pbctools 2.5
#import psf
set molecule [mol new /path/to/your/psffile/yourpsf.psf type psf]

#set outputfile
set outputfile [open "your_outputfile.dat" w]

#set timer
set tcheck1 [clock clicks -milliseconds]

#import first frame of dcd for comparison of molecule to initial structure
#enter for time step at place of 0 the first time step of your dcd loop !!!
mol addfile /path/to/your/trajectory/yourtrajectory.dcd type dcd first 3 last 5 step 1

#set your reference selection e. g. ATP heavy atoms only
set reference [atomselect top "resname ATP and not hydrogen" frame 6444]

#select a random water molecule from your system by its resid to calculate dipole moments
set a_watermolecule [atomselect top "resid 666" frame 6444]

set dipol_moment_of_one_water_molecule [measure dipole $a_watermolecule]
set modulus_dipole [veclength $dipol_moment_of_one_water_molecule]

#loop over frames
for {set j 4} {$j <= 333} {incr j} {
	#set your dcd file to loop over
	animate read dcd /path/to/your/trajectory/yourtrajectory.dcd beg $j end $j $molecule
	pbc wrap -centersel "resname ATP and not hydrogen" -center com -compound residue -all
	#get actual atp structure and calculate transformation matrix
	set compare [atomselect top "resname ATP and not hydrogen"]
	#realignment of the reference structure to account for translation and rotation
	set trans_mat [measure fit $compare $reference]
	# do the alignment by moving current atp selection by transformation matrix
	$compare move $trans_mat
	
	#select atoms whose bonding axes you want to project your dipole moment onto
	#if you prefer projecting onto a fixed coordinate vector, comment the axis variables and all their dependencies and replace part by your chosen coordinate vector
	set sel_pa [atomselect top "resname ATP and name PA"]
	set sel_pb [atomselect top "resname ATP and name PB"]
	set sel_pg [atomselect top "resname ATP and name PG"]
	set sel_ox_o5 [atomselect top "resname ATP and name O5'"]
	set sel_ox_o3b [atomselect top "resname ATP and name O3B"]
	set sel_ox_o3a [atomselect top "resname ATP and name O3A"]
	
	#This is the version for TIP3P water. For other water models change selection of resname accordingly!
	
	set water [atomselect top "same residue as ((resname TIP3) and ((within 7 of resname ATP) and not (within 5 of resname ATP)))"]
	set N_atoms [$water num]
	set N_molecule [expr $N_atoms/3]
	set normalization [expr $modulus_dipole*$N_molecule]
	set nenner_normalization [expr 1/$normalization]
	
	#get coordinates for each selection, lindex used to return coordinate array which is an array of arrays
		
	set coord_pa [lindex [$sel_pa get {x y z}] 0]
	set coord_pb [lindex [$sel_pb get {x y z}] 0]
	set coord_pg [lindex [$sel_pg get {x y z}] 0]
	set coord_o5 [lindex [$sel_ox_o5 get {x y z}] 0]
	set coord_ob [lindex [$sel_ox_o3b get {x y z}] 0]
	set coord_oa [lindex [$sel_ox_o3a get {x y z}] 0]
	
	#calculate axes between phosphates and oxygens in phosphate groups and normalize the axes to norm 1
		
	set axis_1 [vecsub $coord_pg $coord_ob]
	set axis_1_normalized [vecnorm $axis_1]
	set axis_2 [vecsub $coord_pb $coord_ob]
	set axis_2_normalized [vecnorm $axis_2]
	set axis_3 [vecsub $coord_pb $coord_oa]
	set axis_3_normalized [vecnorm $axis_3]
	set axis_4 [vecsub $coord_pa $coord_oa]
	set axis_4_normalized [vecnorm $axis_4]
	set axis_5 [vecsub $coord_pa $coord_o5]
	set axis_5_normalized [vecnorm $axis_5]
	
	#measure dipole moment vector of ALL water molecules in your selection. This avoids looping over the water molecules and thus decreases running time
	#for this script from 2.7 days on a high performance cluster to 45 minutes for a system with 100000 time steps and approx. 25000 atoms
	#It can be proven that the projection of the overall dipole moment on the axis/axes times proper normalization equals projecting each water molecule
	#on the axis and then averaging over all water molecules in your selection
	set dipole [measure dipole $water]
	set normalized_dipole [vecscale $dipole $nenner_normalization]
	set projection_1 [vecdot $axis_1_normalized $normalized_dipole]
	set projection_2 [vecdot $axis_2_normalized $normalized_dipole]
	set projection_3 [vecdot $axis_3_normalized $normalized_dipole]
	set projection_4 [vecdot $axis_4_normalized $normalized_dipole]
	set projection_5 [vecdot $axis_5_normalized $normalized_dipole]
	set sum_projection [vecadd $projection_1 $projection_2 $projection_3 $projection_4 $projection_5]
	set average_projection [vecscale $sum_projection 0.2]
	puts $outputfile $average_projection
	array unset $normalized_dipole
	array unset $projection_1
	array unset $projection_2
	array unset $projection_3
	array unset $projection_4
	array unset $projection_5
	array unset $sum_projection
	$water delete
	$sel_pa delete
	$sel_pb delete
	$sel_pg delete
	$sel_ox_o5 delete
	$sel_ox_o3b delete
	$sel_ox_o3a delete
	animate delete all
	#unset $coord_pa
	#unset $coord_pb
	#unset $coord_pg
	#unset $coord_o5
	#unset $coord_oa
	#unset $coord_ob
	#unset $coord_atp
}
close $outputfile
set tcheck [expr [clock clicks -milliseconds] - $tcheck1]
set tcheck [format %.1f [expr $tcheck / 60000.]]
puts "======================================================="
puts "RUNNING TIME: $tcheck min"
puts "======================================================="
