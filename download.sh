#!/bin/bash

# Copyright (c) Meta Platforms, Inc. and affiliates.
# This software may be used and distributed according to the terms of the Llama 2 Community License Agreement.

read -p "Enter the URL from email: " PRESIGNED_URL
echo ""
ALL_MODELS="7b,13b,34b,7b-Python,13b-Python,34b-Python,7b-Instruct,13b-Instruct,34b-Instruct"
read -p "Enter the list of models to download without spaces ($ALL_MODELS), or press Enter for all: " MODEL_SIZE
TARGET_FOLDER="."             # where all files should end up
mkdir -p ${TARGET_FOLDER}

if [[ $MODEL_SIZE == "" ]]; then
    MODEL_SIZE=$ALL_MODELS
fi

echo "Downloading LICENSE and Acceptable Usage Policy"
wget ${PRESIGNED_URL/'*'/"LICENSE"} -O ${TARGET_FOLDER}"/LICENSE"
wget ${PRESIGNED_URL/'*'/"USE_POLICY.md"} -O ${TARGET_FOLDER}"/USE_POLICY.md"
${MODEL_PATH}="https://download2.llamameta.net/*?Policy=eyJTdGF0ZW1lbnQiOlt7InVuaXF1ZV9oYXNoIjoicGcyeXV4a2ZkcWwzajE5cnFhMnAzanZkIiwiUmVzb3VyY2UiOiJodHRwczpcL1wvZG93bmxvYWQyLmxsYW1hbWV0YS5uZXRcLyoiLCJDb25kaXRpb24iOnsiRGF0ZUxlc3NUaGFuIjp7IkFXUzpFcG9jaFRpbWUiOjE2OTMzNzkxNjl9fX1dfQ__&Signature=Ny8QMz8ZYdSGexY4bUgd5NwaZXJmVUr066nZ%7EFKFS7CaW08Nr0CLj9LfCJvTvb3jVNs3nqivIsrnwOJ3%7Ewkfsfzryosw4v9nN78E%7EQApLz0kGw7JLKYtBWg1xXn0c09LYmA4VrLd9RXNc6YQ2RRRHH9ov0irFwYXrBNT44ha9HVgDwNEwbE0hfuwltL8CSbVqzPKKPgLmkV8mVQmmCvCaETzzm1SWxff2keyHrA8NrTPu1HdqH1%7E6jwgjdN8rb4es1SVsh745AbzRccafki00-Q2xgJN1GTCGCfGEAVYhKSlUqJeUl7RRJj4k-zgq9KbClUjPdRZ6teqAYLCgipgFA__&Key-Pair-Id=K15QRJLYKIFSLZ&Download-Request-ID=330010089591446"
for m in ${MODEL_SIZE//,/ }
do
    case $m in
      7b)
        SHARD=0 ;;
      13b)
        SHARD=1 ;;
      34b)
        SHARD=3 ;;
      7b-Python)
        SHARD=0 ;;
      13b-Python)
        SHARD=1 ;;
      34b-Python)
        SHARD=3 ;;
      7b-Instruct)
        SHARD=0 ;;
      13b-Instruct)
        SHARD=1 ;;
      34b-Instruct)
        SHARD=3 ;;
      *)
        echo "Unknown model: $m"
        exit 1
    esac

    MODEL_PATH="CodeLlama-$m"
    echo "Downloading ${MODEL_PATH}"
    mkdir -p ${TARGET_FOLDER}"/${MODEL_PATH}"

    for s in $(seq -f "0%g" 0 ${SHARD})
    do
        wget ${PRESIGNED_URL/'*'/"${MODEL_PATH}/consolidated.${s}.pth"} -O ${TARGET_FOLDER}"/${MODEL_PATH}/consolidated.${s}.pth"
    done

    wget ${PRESIGNED_URL/'*'/"${MODEL_PATH}/params.json"} -O ${TARGET_FOLDER}"/${MODEL_PATH}/params.json"
    wget ${PRESIGNED_URL/'*'/"${MODEL_PATH}/tokenizer.model"} -O ${TARGET_FOLDER}"/${MODEL_PATH}/tokenizer.model"
    wget ${PRESIGNED_URL/'*'/"${MODEL_PATH}/checklist.chk"} -O ${TARGET_FOLDER}"/${MODEL_PATH}/checklist.chk"
    echo "Checking checksums"
    (cd ${TARGET_FOLDER}"/${MODEL_PATH}" && md5sum -c checklist.chk)
done
