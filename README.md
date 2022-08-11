# OCR 操作流程

如何利用 OCR 辨識漢羅台文、白話字、全羅等等語言

## 安裝環境

下載 repository

```
git clone https://github.com/leon0719/OCR.git
```

利用 Docker image 來建立環境，安裝函式庫 、 CUDA 及 CUDA Toolkit

```
#建立 資料夾儲存圖片
mkdir img_data

docker run --gpus all -it --name OCR_ENV -v /path/to/OCR:/workspace/ -v /path/to/img_data:/train_data/ --shm-size=120g --ulimit memlock=-1 leonhilty/ocr_search:v1.0.6 /bin/bash

```

確認進入 Docker 環境

![image](/images/Docker_env.jpg "Docker環境")

## 產生 DATASET

使用 tools/train_test_split.py 生成 中、英、日、白話字、漢羅、台羅等文字圖片並切割訓練(90%)驗證(10%)，
與模擬的測試資料

```
cd tools/
python train_test_split.py
```

生成結果

![image](images/ch.png "中")
![image](images/en.jpg "英")
![image](images/jp.jpg "日")
![image](images/POJ.jpg "白話字")
![image](images/TAI_LO.jpg "台羅")
![image](images/HAN_LO.jpg "漢羅")

訓練集與驗證集

|        | 訓練集 | 驗證集 |
| ------ | ------ | ------ |
| 中     | 9000   | 1000   |
| 英     | 9000   | 1000   |
| 日     | 9000   | 1000   |
| 白話字 | 9000   | 1000   |
| 台羅   | 9000   | 1000   |
| 漢羅   | 9000   | 1000   |
| 總共   | 54000  | 6000   |

資料夾樹狀圖

```
/train_data/
    (模擬測試資料)
    ├── test_ch
    ├── test_en
    ├── test_HAN_LO
    ├── test_jp
    ├── test_POJ
    ├── test_TAI_LO
    └── train_data
        ├── test (驗證集 Img)
        ├── test_label.txt (驗證集 Label)
        ├── train (訓練集 Img)
        └── train_label.txt (訓練集 Label)
```

## 如何訓練

修改 PaddleOCR/configs/rec/PP-OCRv3/PP-OCRv3_rec.yml 設定檔

|                         | 修改為                                                                                |
| ----------------------- | ------------------------------------------------------------------------------------- |
| num_workers             | GPU 個數                                                                              |
| character_dict_path     | 字典路徑 e.x. ppocr/utils/dict/total_dic.txt                                          |
| Architecture-algorithm: | SVTR、PREN、Rosetta、RARE、STARNet、SRN、NRTR、CRNN、SEED、SAR                        |
| Architecture-Backbone:  | MobileNetV1Enhance、EfficientNetb3_PREN、MobileNetV3、SVTRNet、ResNetFPN、MTB、ResNet |

修改後即可開始訓練

```
cd PaddleOCR
sh train.sh
```

若想暫時中斷訓練可使用 re-train.sh 恢復訓練

```
cd PaddleOCR
sh re-train.sh
```

訓練完成後在 output 目錄下會有保存後的模型與訓練目錄

```
my_ocr_model/
├── best_accuracy.pdopt
├── best_accuracy.pdparams
├── best_accuracy.states
├── config.yml
├── latest.pdopt
├── latest.pdparams
├── latest.states
└── train.log
```

## 各個語言預測結果

使用 tools/test_data_predict.py 對模擬的測試圖片資料進行預測並計算 CER

```
cd tools/
python test_data_predict.py
```

# 預測結果 (CER)

使用架構 **SVTR** Backbone **MobileNetV1Enhance**

| 中    | 英     | 日      | 白話字 | 漢羅   | 台羅   |
| ----- | ------ | ------- | ------ | ------ | ------ |
| 4.83% | 9.207% | 11.466% | 1.576% | 0.862% | 0.596% |
