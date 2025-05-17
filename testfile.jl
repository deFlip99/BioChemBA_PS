using Pkg
Pkg.activate(".")
using Bonito: Observable
using BiochemicalAlgorithms
using BiochemicalVisualization
using BiochemicalVisualization:display_model

include("src/utils/system_utils.jl")

fdb = FragmentDB()
AlaAla = load_pdb(ball_data_path("../test/data/AlaAla.pdb"))
normalize_names!(AlaAla, fdb);
build_bonds!(AlaAla, fdb);
reconstruct_fragments!(AlaAla, fdb);


AlaObs = Observable(AlaAla)
display_model(AlaObs)


# updateAtomsInSystem(AlaAla, Dict("5" => Dict("r" => [2.0, 2.0, 2.0])))