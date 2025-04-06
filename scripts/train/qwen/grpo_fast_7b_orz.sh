python mason.py \
    --cluster ai2/jupiter-cirrascale-2 \
    --workspace ai2/tulu-3-dev \
    --priority high \
    --image nathanl/open_instruct_auto --pure_docker_mode \
    --preemptible \
    --num_nodes 4 \
    --budget ai2/oe-adapt \
    --gpus 8 -- source configs/beaker_configs/ray_node_setup.sh \&\& python open_instruct/grpo_fast.py \
    --exp_name qwen2.5_7b_grpo_fast_zero_orz \
    --beta 0.0 \
    --num_unique_prompts_rollout 128 \
    --num_samples_per_prompt_rollout 64 \
    --kl_estimator kl3 \
    --learning_rate 5e-7 \
    --dataset_mixer_list ai2-adapt-dev/rlvr_open_reasoner_math 1.0 \
    --dataset_mixer_list_splits train \
    --dataset_mixer_eval_list ai2-adapt-dev/rlvr_open_reasoner_math 16 \
    --dataset_mixer_eval_list_splits train \
    --max_token_length 8192 \
    --max_prompt_token_length 2048 \
    --response_length 8192 \
    --pack_length 16384 \
    --model_name_or_path Qwen/Qwen2.5-7B \
    --stop_strings '"</answer>"' \
    --apply_r1_style_format_reward True \
    --apply_verifiable_reward True \
    --non_stop_penalty True \
    --non_stop_penalty_value 0.0 \
    --chat_template_name r1_simple_chat_postpend_think \
    --oe_eval_tasks minerva_math::hamish_zs_reasoning,bbh:cot::hamish_zs_reasoning,gsm8k::hamish_zs_reasoning,minerva_math_500::hamish_zs_reasoning,zebralogic::hamish_zs_reasoning,aime::hamish_zs_reasoning,agi_eval_english:0shot_cot::hamish_zs_reasoning,gpqa:0shot_cot::hamish_zs_reasoning \
    --oe_eval_max_length 8192 \
    --temperature 1.0 \
    --masked_mean_axis 1 \
    --total_episodes 10000000 \
    --deepspeed_stage 2 \
    --per_device_train_batch_size 1 \
    --num_mini_batches 1 \
    --num_learners_per_node 8 8 \
    --num_epochs 1 \
    --vllm_tensor_parallel_size 1 \
    --vllm_num_engines 16 \
    --lr_scheduler_type linear \
    --seed 3 \
    --num_evals 200 \
    --save_freq 40 \
    --try_launch_beaker_eval_jobs_on_weka \
    --gradient_checkpointing \
    --with_tracking