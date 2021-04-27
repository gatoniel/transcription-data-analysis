import yaml


comp_replica = int(snakemake.params.conf["comp_replica"])
replica = int(snakemake.params.conf["replica"])
hyperbolic_dim = int(snakemake.params.conf["hyperbolic_dim"])
name = snakemake.params.wildcard_pattern.format(
    comp_replica=comp_replica, replica=replica, hyperbolic_dim=hyperbolic_dim
)

with open(snakemake.input.plain) as f:
    plain_config = yaml.load(f, Loader=yaml.SafeLoader)

plain_config["trainer"]["callbacks"] = [
    {
        "class_path": "pytorch_lightning.callbacks.ModelCheckpoint",
        "init_args": {
            "monitor": "train_loss",
            "dirpath": "data/mds/models",
            "filename": name,
            "mode": "min",
            "save_last": True,
        },
    },
]
plain_config["trainer"]["logger"] = {
    "class_path": "pytorch_lightning.loggers.TensorBoardLogger",
    "init_args": {
        "save_dir": "data/mds/tensorboard",
        "name": name,
    },
}

plain_config["model"]["replica"] = replica
plain_config["model"]["hyperbolic_dim"] = hyperbolic_dim
plain_config["model"]["data_dir"] = "./data/raw/data"

with open(snakemake.output.conf, "w") as f:
    yaml.dump(plain_config, f)
