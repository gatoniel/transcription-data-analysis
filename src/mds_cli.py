from pytorch_lightning.utilities.cli import LightningCLI

from stereographic_link_prediction.Models.MDS import MDS


cli = LightningCLI(
    MDS,
    trainer_defaults={
        "precision": 64,
        "auto_lr_find": True,
        "gpus": 1,
    },
)
