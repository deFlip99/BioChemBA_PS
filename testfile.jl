using Pkg
Pkg.activate(".")

using BiochemicalAlgorithms
using BiochemicalVisualization
using BiochemicalVisualization:display_model

fdb = FragmentDB()
AlaAla = load_pdb(ball_data_path("../test/data/AlaAla.pdb"))
normalize_names!(AlaAla, fdb);
build_bonds!(AlaAla, fdb);
reconstruct_fragments!(AlaAla, fdb);

display_model(AlaAla)

atoms(AlaAla)

