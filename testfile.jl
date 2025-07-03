using Pkg
Pkg.activate(".")
using Bonito
using Bonito: Observable
using BiochemicalAlgorithms
using BiochemicalVisualization
using BiochemicalVisualization:display_model


fdb = FragmentDB()
AlaAla = load_pdb(ball_data_path("../test/data/AlaAla.pdb"))
normalize_names!(AlaAla, fdb);
build_bonds!(AlaAla, fdb);
reconstruct_fragments!(AlaAla, fdb);


#Test normal
# AlaObs = Observable(AlaAla)
# display_model(AlaObs, app_mode=true)

#Test large
#Pti = load_pdb(ball_data_path("../test/data/5PTI.pdb"))
#normalize_names!(Pti, fdb);
#build_bonds!(Pti, fdb);
#reconstruct_fragments!(Pti, fdb);
#PtiObs = Observable(Pti)
#display_model(PtiObs, app_mode=true)

#test mit AmberFF
#AlaFF = Observable(AmberFF(AlaAla))
#ball_and_stick(map(AlaFF -> AlaFF.system, AlaFF), app_mode=true)
#optimize_structure!(AlaFF)

# create a new system
h2o = System()
#test = System()
#double_sys = System()
# create system atoms
o1 = Atom(h2o, 1, Elements.O)
h1 = Atom(h2o, 2, Elements.H)
h2 = Atom(h2o, 3, Elements.H)


# set positions of the atoms
o1.r = Vector3{Float32}(3, 3, 3)
h1.r = Vector3{Float32}(4, 4, 4)
h2.r = Vector3{Float32}(4, 3, 3)

# add bonds
Bond(h2o, o1.idx, h1.idx, BondOrder.Single)
Bond(h2o, o1.idx, h2.idx, BondOrder.Single)

Molecule(h2o, name="H2O")

# h3 = Atom(test, 1, Elements.H)
# h3.r = Vector3{Float32}(2, 2, 2)
# o2 = Atom(test, 2, Elements.O)
# o2.r = Vector3{Float32}(3, 3, 3)
# Bond(test, h3.idx, o2.idx, BondOrder.Single)

# Molecule(test, name="tester")

#h2o_obs = Observable(h2o)
#test_obs = Observable(test)
doublesys = Observable([AlaAla, h2o]) 
display_model(doublesys, app_mode=true)

# @show atoms(h2o).idx
# @show atoms(AlaAla).idx
# prepare_model(AlaAla).meta_data
# AlaAla.name