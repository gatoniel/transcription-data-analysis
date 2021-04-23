from itertools import product
from snakemake.utils import Paramspace
import pandas as pd

replicas = [1, 2, 3]
hyperbolic_dims = [2, 3, 4, 5, 10, 20]
df = []
for replica, hyperbolic_dim in product(replicas, hyperbolic_dims):
    df.append({"replica": replica, "hyperbolic_dim": hyperbolic_dim})
df = pd.DataFrame(df)
paramspace = Paramspace(df, filename_params=["replica", "hyperbolic_dim"])

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

rule all:
    input:
        expand("config/mds/{params}.yaml", params=paramspace.instance_patterns),
