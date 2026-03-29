#!/bin/bash
# Run InstantSplat on the custom indoor scene (29 views).
# Usage: bash scripts/run_custom.sh [GPU_ID]
# Example: bash scripts/run_custom.sh 0

GPU_ID=${1:-0}
SOURCE_PATH="./assets/custom/indoor/"
MODEL_PATH="./output_custom/indoor/29_views"
N_VIEWS=29
GS_ITER=2000

mkdir -p ${MODEL_PATH}

echo "======================================================="
echo "InstantSplat: custom indoor scene (${N_VIEWS} views, ${GS_ITER} iters)"
echo "======================================================="

# (1) MASt3R geometry initialization
echo "[$(date)] Step 1: MASt3R geometry initialization..."
CUDA_VISIBLE_DEVICES=${GPU_ID} python -W ignore ./init_geo.py \
  -s ${SOURCE_PATH} \
  -m ${MODEL_PATH} \
  --n_views ${N_VIEWS} \
  --focal_avg \
  --co_vis_dsp \
  --conf_aware_ranking \
  --infer_video \
  2>&1 | tee ${MODEL_PATH}/01_init_geo.log
echo "[$(date)] Step 1 done."

# (2) Train with joint pose optimization
echo "[$(date)] Step 2: Training (joint pose + Gaussian optimization)..."
CUDA_VISIBLE_DEVICES=${GPU_ID} python ./train.py \
  -s ${SOURCE_PATH} \
  -m ${MODEL_PATH} \
  -r 1 \
  --n_views ${N_VIEWS} \
  --iterations ${GS_ITER} \
  --pp_optimizer \
  --optim_pose \
  2>&1 | tee ${MODEL_PATH}/02_train.log
echo "[$(date)] Step 2 done."

# (3) Render interpolated video
echo "[$(date)] Step 3: Rendering video..."
CUDA_VISIBLE_DEVICES=${GPU_ID} python ./render.py \
  -s ${SOURCE_PATH} \
  -m ${MODEL_PATH} \
  -r 1 \
  --n_views ${N_VIEWS} \
  --iterations ${GS_ITER} \
  --infer_video \
  2>&1 | tee ${MODEL_PATH}/03_render.log
echo "[$(date)] Step 3 done."

echo "======================================================="
echo "Done! Results in ${MODEL_PATH}"
echo "======================================================="
