using Pkg
Pkg.activate(".")
using Bonito: Observable
using BiochemicalAlgorithms
using BiochemicalVisualization
using BiochemicalVisualization:display_model


include("src/jl_utils/system_utils.jl")


fdb = FragmentDB()
AlaAla = load_pdb(ball_data_path("../test/data/AlaAla.pdb"))
normalize_names!(AlaAla, fdb);
build_bonds!(AlaAla, fdb);
reconstruct_fragments!(AlaAla, fdb);


#Test normal
AlaObs = Observable(AlaAla)
display_model(AlaObs)


#test mit AmberFF
# AlaFF = Observable(AmberFF(AlaAla))
# ball_and_stick(map(AlaFF -> AlaFF.system, AlaFF))
# optimize_structure!(AlaFF)

