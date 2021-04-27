from itertools import product
from snakemake.utils import Paramspace
import pandas as pd

comp_replicas = range(2)
replicas = [1, 2]
hyperbolic_dims = [2, 3]
# comp_replicas = range(3)
# replicas = [1, 2, 3]
# hyperbolic_dims = [2, 3, 4, 5, 10, 20]
df = []
for comp_replica, replica, hyperbolic_dim in product(
    comp_replicas, replicas, hyperbolic_dims
):
    df.append({
        "comp_replica": comp_replica,
        "replica": replica, "hyperbolic_dim": hyperbolic_dim
    })
df = pd.DataFrame(df)
paramspace = Paramspace(df, filename_params=[
    "comp_replica", "replica", "hyperbolic_dim"
])

localrules: all, create_plain_config, generate_config_files

rule all:
    input:
        expand("data/mds/models/{params}.ckpt", params=paramspace.instance_patterns),

rule create_plain_config:
    output: "config/mds_plain_config.yaml"
    input: "src/mds_cli.py"
    conda: "../envs/stereographic-link-prediction.yaml"
    shell: "python {input} --print_config > {output}"

rule generate_config_files:
    output:
        conf=f"config/mds/{paramspace.wildcard_pattern}.yaml"
    input:
        plain=rules.create_plain_config.output[0],
        script="src/mds_create_configs.py",
    params:
        conf=paramspace.instance,
        wildcard_pattern=paramspace.wildcard_pattern,
    conda: "../envs/stereographic-link-prediction.yaml"
    log: f"logs/{paramspace.wildcard_pattern}_generate_config_files.log"
    script: "../../src/mds_create_configs.py"

rule run_fits:
    output: f"data/mds/models/{paramspace.wildcard_pattern}.ckpt"
    input:
        config=rules.generate_config_files.output.conf,
        files1="data/raw/data/Rep{replica}_distance.csv",
        files2="data/raw/data/Rep{replica}_spacetime.csv",
        files3="data/raw/data/Rep{replica}_mds.csv",
        files4="data/raw/data/Rep{replica}_outliers.yaml",
        script="src/mds_cli.py",
    resources:
        time="02:00:00",
    conda: "../envs/stereographic-link-prediction.yaml"
    log: f"logs/{paramspace.wildcard_pattern}_run_fits.log"
    shell: "python {input.script} --config {input.config} > {log} 2>&1"
