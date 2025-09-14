## JPG_codec
本实验实现了JPEG图像压缩算法的编码解码的完整过程， 包括**图像分块 → DCT 变换 → 量化 → Zigzag 扫描 → AC/DC 编码 → 解码重构** 的部分。

This experiment implements the complete process of encoding and decoding for a JPEG image compression algorithm, including image blocking → DCT transformation → quantization → zigzag scanning → AC/DC encoding → decoding and reconstruction.


编码过程：
颜色空间转换：如果图像不是YCbCr颜色空间，则将其转换为YCbCr。
图像分块：将图像分成8x8像素的小块。
离散余弦变换（DCT）：对每个8x8像素块执行DCT变换。
量化：对DCT系数进行量化，从而减少高频信息。
Zigzag扫描：将量化后的DCT系数按照它们的重要性排列成一维数组。
熵编码：对zigzag扫描后的系数进行熵编码。
数据格式化：将所有编码数据组合成一个连续的数据流。

解码过程：
数据解析：从数据流中解析出编码数据。
熵解码：对编码的系数进行解码，恢复为zigzag扫描后的系数。
反量化：对解码后的系数进行反量化，乘以量化表。
反离散余弦变换（IDCT）：对反量化后的系数进行逆DCT变换，将频域信号转换回空域。
重构图像：将逆DCT变换后的小块组合成完整的图像。
颜色空间逆转换：如果需要，将图像从YCbCr颜色空间转换回原始颜色空间。
