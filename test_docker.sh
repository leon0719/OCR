docker run --gpus all -it --name test_GPU3 \
    -v /nfs/GPU3/home/leon/taigiOCR/:/workspace/ \
    -v /nfs/TS-1635AX/WorkSpace/leon/GPU2/train_data/ \
    --shm-size=120g --ulimit memlock=-1 leonhilty/ocr_search:v1.0.6 /bin/bash

# -u $(id -u):$(id -g)