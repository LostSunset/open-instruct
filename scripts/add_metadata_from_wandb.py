from dataclasses import dataclass
from typing import Optional
from transformers import HfArgumentParser
import wandb

from open_instruct.utils import upload_metadata_to_hf

api = wandb.Api()

"""
# python scripts/add_metadata_from_wandb.py --wandb_run_id ai2-llm/open_instruct_internal/runs/fjclmg47
or
python scripts/add_metadata_from_wandb.py --hf_repo_revision costa_finetune_tulu3_8b_norobot__meta-llama_Meta-Llama-3.1-8B__42__1725559869
"""
@dataclass
class Args:
    wandb_run_id: Optional[str] = None
    hf_repo_revision: Optional[str] = None

new_args = HfArgumentParser(Args).parse_args_into_dataclasses()[0]

if new_args.wandb_run_id is not None:
    wandb_run = api.run(new_args.wandb_run_id)
elif new_args.hf_repo_revision is not None:
    runs = api.runs("ai2-llm/open_instruct_internal", filters={
        "config.hf_repo_revision": new_args.hf_repo_revision
    })
    assert len(runs) == 1, f"Expected 1 run, got {len(runs)}"
    wandb_run = runs[0]

args = wandb_run.config


# dpo script only supports these two options right now for datasets
if args["dataset_mixer"]:
    dataset_list = args["dataset_mixer"].keys()
elif args["dataset_mixer_list"]:
    dataset_list = args["dataset_mixer_list"][::2]  # even indices
elif args["dataset_name"]:
    dataset_list = [args["dataset_name"]]
else:
    dataset_list = [args["train_file"]]
# mainly just focussing here on what would be useful for the leaderboard.
# wandb will have even more useful information.
metadata_blob = {
    "model_name": args["exp_name"],
    "model_type": "sft",
    "datasets": dataset_list,
    "base_model": args["model_name_or_path"],
    "wandb_path": wandb_run.url,
    "beaker_experiment": args["beaker_experiment_url"],
    "beaker_datasets": args["beaker_dataset_id_urls"],
}

# upload metadata to the dataset if set
hf_metadata_dataset = "allenai/tulu-3-evals"
if hf_metadata_dataset:
    upload_metadata_to_hf(
        metadata_blob,
        "metadata.json",
        hf_metadata_dataset,
        "results/" + args["hf_repo_revision"],  # to match what the auto-evals name as.
    )