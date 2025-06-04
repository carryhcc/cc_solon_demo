<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>图片列表展示</title>
    <link rel="stylesheet" href="/base.css"> <#-- 假设 base.css 在 static 文件夹中 -->
    <#-- 您可以链接到 pic-styles.css 或在此处添加新样式 -->
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
            margin: 0;
            background-color: #f4f7f6;
            color: #333;
            padding: 20px;
        }
        .container {
            max-width: 1200px;
            margin: 0 auto;
            background-color: #fff;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.1);
        }
        header {
            text-align: center;
            margin-bottom: 20px;
        }
        header h1 {
            color: #2c3e50;
        }
        .controls {
            text-align: center;
            margin-bottom: 20px;
        }
        .controls button {
            padding: 10px 20px;
            font-size: 1em;
            color: #fff;
            background-color: #007bff;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            transition: background-color 0.3s ease;
        }
        .controls button:hover {
            background-color: #0056b3;
        }
        .controls button:disabled {
            background-color: #cccccc;
            cursor: not-allowed;
        }
        .image-gallery {
            display: flex;
            flex-wrap: wrap;
            gap: 10px; /* 图片之间的间距 */
            justify-content: center; /* 图片居中对齐 */
        }
        .image-gallery img {
            width: 100%; /* 图片宽度充满容器 */
            max-width: 200px; /* 每张图片的最大宽度 */
            height: auto; /* 高度自适应 */
            border-radius: 4px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
            object-fit: cover; /* 保持图片比例，裁剪多余部分 */
            aspect-ratio: 1 / 1; /* 可选：使图片容器为正方形 */
        }
        .image-gallery .img-container {
            width: 200px; /* 固定容器宽度，与max-width一致 */
            height: 200px; /* 固定容器高度，如果设置了aspect-ratio则可以省略 */
            display: flex;
            justify-content: center;
            align-items: center;
            overflow: hidden; /* 配合object-fit */
            background-color: #f0f0f0; /* 图片加载前的占位背景 */
        }
        .status-message {
            text-align: center;
            padding: 20px;
            font-size: 1.1em;
            color: #555;
        }
    </style>
</head>
<body>
<div class="container">
    <header>
        <h1>随机套图</h1>
    </header>

    <div class="controls">
        <button id="refreshImageListBtn">刷新图片列表</button>
    </div>

    <div id="imageGallery" class="image-gallery">
        desgaste</div>
    <div id="statusMessage" class="status-message" style="display: none;"></div>
</div>

<script>
    document.addEventListener('DOMContentLoaded', function () {
        const gallery = document.getElementById('imageGallery');
        const refreshButton = document.getElementById('refreshImageListBtn');
        const statusMessage = document.getElementById('statusMessage');

        function showStatus(message, isError = false) {
            statusMessage.textContent = message;
            statusMessage.style.color = isError ? 'red' : '#555';
            statusMessage.style.display = 'block';
            gallery.innerHTML = ''; // 清空画廊内容
        }

        function displayImages(urls) {
            gallery.innerHTML = ''; // 清空之前的图片
            statusMessage.style.display = 'none'; // 隐藏状态消息

            if (!urls || urls.length === 0) {
                showStatus('未能获取到图片列表，或列表为空。');
                return;
            }

            urls.forEach(url => {
                if (url && url.trim() !== '') { // 确保URL有效
                    const imgContainer = document.createElement('div');
                    imgContainer.className = 'img-container';
                    const img = document.createElement('img');
                    img.src = url.trim();
                    img.alt = '套图图片';
                    img.onerror = function() {
                        // 处理单个图片加载失败的情况
                        this.alt = '图片加载失败';
                        this.parentElement.style.border = '1px solid red'; // 简单提示
                        console.warn('图片加载失败: ' + this.src);
                    };
                    imgContainer.appendChild(img);
                    gallery.appendChild(imgContainer);
                }
            });
        }

        function fetchAndDisplayImages() {
            refreshButton.disabled = true;
            refreshButton.textContent = '加载中...';
            gallery.innerHTML = ''; // 清空现有图片
            statusMessage.textContent = '正在加载图片列表...';
            statusMessage.style.color = '#555';
            statusMessage.style.display = 'block';

            fetch('/pic/list') // 调用PicController中的@Mapping("/pic/list")接口
                .then(response => {
                    if (!response.ok) {
                        throw new Error('网络响应错误: ' + response.statusText + ' (状态码: ' + response.status + ')');
                    }
                    return response.text(); // 接口返回的是字符串形式的列表
                })
                .then(dataString => {
                    // 后端返回的是类似 "[url1, url2, url3]" 的字符串
                    // 需要进行解析
                    if (dataString && dataString.startsWith('[') && dataString.endsWith(']')) {
                        const urlsString = dataString.substring(1, dataString.length - 1);
                        if (urlsString.trim() === '') { // 处理空列表 "[]"
                            return [];
                        }
                        const urlsArray = urlsString.split(',').map(url => url.trim());
                        displayImages(urlsArray);
                    } else {
                        throw new Error('图片列表数据格式不正确: ' + dataString);
                    }
                })
                .catch(error => {
                    console.error('获取图片列表失败:', error);
                    showStatus('获取图片列表失败: ' + error.message, true);
                })
                .finally(() => {
                    refreshButton.disabled = false;
                    refreshButton.textContent = '刷新图片列表';
                });
        }

        refreshButton.addEventListener('click', fetchAndDisplayImages);

        // 页面初始加载时获取图片
        fetchAndDisplayImages();
    });
</script>
</body>
</html>