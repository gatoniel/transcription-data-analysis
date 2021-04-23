import yaml


replica = int(snakemake.params.conf["replica"])
hyperbolic_dim = int(snakemake.params.conf["hyperbolic_dim"])

with open(snakemake.input.plain) as f:
    plain_config = yaml.load(f, Loader=yaml.SafeLoader)

plain_config["trainer"]["callbacks"] = [
    {
        "class_path": "pytorch_lightning.callbacks.ModelCheckpoint",
        "init_args": {
            "monitor": "train_loss",
            "dirpath": "data/models",
            "filename": snakemake.params.wildcard_pattern.format(
                replica=replica, hyperbolic_dim=hyperbolic_dim
            ),
            "mode": "min",
        },
    },
]

plain_config["model"]["replica"] = replica
plain_config["model"]["hyperbolic_dim"] = hyperbolic_dim
plain_config["model"]["data_dir"] = "./data/raw/data"

with open(snakemake.output.conf, "w") as f:
    yaml.dump(plain_config, f)
