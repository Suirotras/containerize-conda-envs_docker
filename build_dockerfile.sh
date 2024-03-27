#!/bin/bash

# Error report crashes upon errors.
set -euo pipefail

# set working directory
cd $(pwd)

# create the envs folder
mkdir -p envs

# Copy the conda environments that you want in the container to the envs folder
conda_envs=(/home/jari/miniconda3/envs/Acomys_comp_genomics \
            /home/jari/miniconda3/envs/kaleido_env \
            /home/jari/miniconda3/envs/r_seurat)

for con_env in "${conda_envs[@]}"
do
   cp -r "${con_env}" envs/
done

# build the container
docker build -f Dockerfile -t "jarivdiermen/acomys_conda_environments" .

# push container to dockerhub
docker push jarivdiermen/acomys_conda_environments:latest

# rm the envs folder when it is now longer needed
rm -rf envs
