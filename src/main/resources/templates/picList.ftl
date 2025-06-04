<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>图片列表展示</title>
    <link rel="stylesheet" href="/base.css">
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
            margin: 0;
            background-color: #f4f7f6;
            color: #333;
            padding: 20px;
        }
        .container {
            max-width: 1800px;
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
            margin: 0 5px;
        }
        .controls button:hover {
            background-color: #0056b3;
        }
        .controls button:disabled {
            background-color: #cccccc;
            cursor: not-allowed;
        }

        /* 新增：图片组名称显示 */
        .gallery-title-container {
            display: flex;
            justify-content: center;
            align-items: center;
            margin: 20px 0;
        }

        .gallery-title {
            font-size: 1.5em;
            color: #2c3e50;
            font-weight: 500;
            margin-right: 10px;
        }

        /* 图片网格布局 */
        .image-gallery {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
            grid-gap: 10px;
            grid-auto-flow: dense;
            justify-content: center;
            margin: 0 auto;
            max-width: 1800px;
        }

        .image-gallery .img-container {
            position: relative;
            overflow: hidden;
            border-radius: 4px;
            background-color: #f0f0f0;
            cursor: pointer;
            transition: transform 0.2s;
        }

        .image-gallery .img-container:hover {
            transform: scale(1.02);
        }

        .image-gallery img {
            width: 100%;
            height: 100%;
            object-fit: cover;
            border-radius: 4px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
            transition: opacity 0.3s;
        }

        .image-gallery img:hover {
            opacity: 0.9;
        }

        .status-message {
            text-align: center;
            padding: 20px;
            font-size: 1.1em;
            color: #555;
        }

        /* 图片查看器模态框样式 */
        .image-viewer {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0, 0, 0, 0.85);
            display: flex;
            justify-content: center;
            align-items: center;
            z-index: 1000;
            opacity: 0;
            visibility: hidden;
            transition: opacity 0.3s, visibility 0.3s;
        }

        .image-viewer.active {
            opacity: 1;
            visibility: visible;
        }

        .image-viewer-content {
            max-width: 90%;
            max-height: 90%;
            position: relative;
        }

        .image-viewer img {
            max-width: 100%;
            max-height: 85vh;
            object-fit: contain;
            box-shadow: 0 0 20px rgba(0, 0, 0, 0.5);
            border-radius: 4px;
        }

        .close-btn {
            position: absolute;
            top: -40px;
            right: 0;
            color: #fff;
            font-size: 30px;
            cursor: pointer;
            transition: color 0.2s;
        }

        .close-btn:hover {
            color: #ccc;
        }

        /* 图片导航按钮 */
        .nav-btn {
            position: absolute;
            top: 50%;
            transform: translateY(-50%);
            color: #fff;
            font-size: 36px;
            cursor: pointer;
            transition: color 0.2s;
            padding: 20px;
        }

        .nav-btn:hover {
            color: #ccc;
        }

        .prev-btn {
            left: -60px;
        }

        .next-btn {
            right: -60px;
        }

        /* 下载按钮样式 */
        .download-btn {
            position: absolute;
            bottom: 8px;
            right: 8px;
            background-color: rgba(0, 0, 0, 0.6);
            color: white;
            border: none;
            border-radius: 4px;
            padding: 6px 10px;
            font-size: 14px;
            cursor: pointer;
            opacity: 0;
            transition: opacity 0.3s;
            z-index: 10;
            display: flex;
            align-items: center;
        }

        .download-btn:hover {
            background-color: rgba(0, 0, 0, 0.8);
        }

        .img-container:hover .download-btn {
            opacity: 1;
        }

        /* 响应式调整 */
        @media (max-width: 768px) {
            .image-viewer-content {
                max-width: 95%;
            }

            .close-btn {
                top: -30px;
                font-size: 24px;
            }

            .nav-btn {
                font-size: 28px;
                padding: 10px;
            }

            .prev-btn {
                left: -40px;
            }

            .next-btn {
                right: -40px;
            }

            .image-gallery {
                grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
            }

            .gallery-title {
                font-size: 1.2em;
            }

            .download-btn {
                opacity: 1;
                padding: 4px 8px;
                font-size: 12px;
            }
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

    <!-- 修改：图片组名称和下载全部按钮 -->
    <div class="gallery-title-container">
        <div id="galleryTitle" class="gallery-title">加载中...</div>
        <button id="downloadAllBtn" class="controls button" disabled>
            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-download" viewBox="0 0 16 16" style="margin-right: 5px;">
                <path d="M.5 9.9a.5.5 0 0 1 .5.5v2.5a1 1 0 0 0 1 1h12a1 1 0 0 0 1-1v-2.5a.5.5 0 0 1 1 0v2.5a2 2 0 0 1-2 2H2a2 2 0 0 1-2-2v-2.5a.5.5 0 0 1 .5-.5z"/>
                <path d="M7.646 11.854a.5.5 0 0 0 .708 0l3-3a.5.5 0 0 0-.708-.708L8.5 10.293V1.5a.5.5 0 0 0-1 0v8.793L5.354 8.146a.5.5 0 1 0-.708.708l3 3z"/>
            </svg>
            下载全部
        </button>
    </div>

    <div id="imageGallery" class="image-gallery">
        desgaste</div>
    <div id="statusMessage" class="status-message" style="display: none;"></div>
</div>

<!-- 图片查看器模态框 -->
<div id="imageViewer" class="image-viewer">
    <div class="image-viewer-content">
        <span class="close-btn" id="closeViewer">&times;</span>
        <span class="nav-btn prev-btn" id="prevImage">&larr;</span>
        <span class="nav-btn next-btn" id="nextImage">&rarr;</span>
        <img id="fullsizeImage" src="" alt="大图预览">
    </div>
</div>

<script>
    document.addEventListener('DOMContentLoaded', function () {
        const gallery = document.getElementById('imageGallery');
        const refreshButton = document.getElementById('refreshImageListBtn');
        const statusMessage = document.getElementById('statusMessage');
        const galleryTitle = document.getElementById('galleryTitle');
        const downloadAllBtn = document.getElementById('downloadAllBtn'); // 新增

        // 图片查看器相关元素
        const imageViewer = document.getElementById('imageViewer');
        const fullsizeImage = document.getElementById('fullsizeImage');
        const closeViewer = document.getElementById('closeViewer');
        const prevImage = document.getElementById('prevImage');
        const nextImage = document.getElementById('nextImage');

        // 存储当前图片索引和所有图片URL
        let currentImageIndex = 0;
        let allImageUrls = [];

        function showStatus(message, isError = false) {
            statusMessage.textContent = message;
            statusMessage.style.color = isError ? 'red' : '#555';
            statusMessage.style.display = 'block';
            gallery.innerHTML = ''; // 清空画廊内容
            downloadAllBtn.disabled = true; // 禁用下载全部按钮
        }

        function displayImages(data) {
            gallery.innerHTML = ''; // 清空之前的图片
            statusMessage.style.display = 'none'; // 隐藏状态消息
            allImageUrls = []; // 重置图片URL数组

            // 解析新的返回格式
            try {
                // 尝试解析JSON格式
                const parsedData = typeof data === 'string' ? JSON.parse(data) : data;

                // 获取图片组名称和图片URL列表
                const galleryName = Object.keys(parsedData)[0];
                let imageUrls = parsedData[galleryName];

                // 如果图片URL是字符串格式，解析为数组
                if (typeof imageUrls === 'string') {
                    if (imageUrls.startsWith('[') && imageUrls.endsWith(']')) {
                        const urlsString = imageUrls.substring(1, imageUrls.length - 1);
                        imageUrls = urlsString.split(',').map(url => url.trim());
                    } else {
                        // 单个URL的情况
                        imageUrls = [imageUrls.trim()];
                    }
                }

                // 更新标题显示
                galleryTitle.textContent = galleryName || '未命名图片组';

                // 显示图片
                if (!imageUrls || imageUrls.length === 0) {
                    showStatus('图片列表为空。');
                    return;
                }

                // 启用下载全部按钮
                downloadAllBtn.disabled = false;

                imageUrls.forEach(url => {
                    if (url && url.trim() !== '') {
                        const imgUrl = url.trim();
                        allImageUrls.push(imgUrl);

                        const imgContainer = document.createElement('div');
                        imgContainer.className = 'img-container';

                        const img = document.createElement('img');
                        img.src = imgUrl;
                        img.alt = '套图图片';
                        img.onerror = function() {
                            this.alt = '图片加载失败';
                            this.parentElement.style.border = '1px solid red';
                            console.warn('图片加载失败: ' + this.src);
                        };

                        // 图片加载完成后获取宽高比例
                        img.onload = function() {
                            const ratio = this.naturalWidth / this.naturalHeight;

                            // 横屏图片
                            if (ratio > 1.2) {
                                imgContainer.style.gridColumnEnd = 'span 2';
                            }
                            // 超长竖屏图片
                            else if (ratio < 0.7) {
                                imgContainer.style.gridRowEnd = 'span 2';
                            }
                        };

                        // 为图片添加点击事件
                        imgContainer.addEventListener('click', function() {
                            currentImageIndex = allImageUrls.indexOf(imgUrl);
                            openImageViewer(imgUrl);
                        });

                        // 添加下载按钮
                        const downloadBtn = document.createElement('button');
                        downloadBtn.className = 'download-btn';
                        downloadBtn.innerHTML = `
                            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-download" viewBox="0 0 16 16">
                                <path d="M.5 9.9a.5.5 0 0 1 .5.5v2.5a1 1 0 0 0 1 1h12a1 1 0 0 0 1-1v-2.5a.5.5 0 0 1 1 0v2.5a2 2 0 0 1-2 2H2a2 2 0 0 1-2-2v-2.5a.5.5 0 0 1 .5-.5z"/>
                                <path d="M7.646 11.854a.5.5 0 0 0 .708 0l3-3a.5.5 0 0 0-.708-.708L8.5 10.293V1.5a.5.5 0 0 0-1 0v8.793L5.354 8.146a.5.5 0 1 0-.708.708l3 3z"/>
                            </svg>
                            下载
                        `;
                        downloadBtn.addEventListener('click', function(e) {
                            e.stopPropagation(); // 阻止事件冒泡到图片容器
                            downloadImage(imgUrl);
                        });

                        imgContainer.appendChild(img);
                        imgContainer.appendChild(downloadBtn);
                        gallery.appendChild(imgContainer);
                    }
                });

            } catch (error) {
                console.error('解析图片数据失败:', error);
                showStatus('解析图片数据失败: ' + error.message, true);
            }
        }

        // 下载单个图片的函数
        function downloadImage(url) {
            // 创建一个a标签
            const a = document.createElement('a');

            // 提取文件名
            const fileName = url.substring(url.lastIndexOf('/') + 1) || 'image.jpg';

            // 设置a标签的href属性为图片URL
            a.href = url;
            a.download = fileName;

            // 将a标签添加到文档中
            document.body.appendChild(a);

            // 触发点击事件
            a.click();

            // 移除a标签
            document.body.removeChild(a);
        }

        // 下载全部图片的函数
        function downloadAllImages() {
            if (allImageUrls.length === 0) {
                alert('没有图片可下载');
                return;
            }

            // 逐个下载图片，延迟执行以避免浏览器限制
            allImageUrls.forEach((url, index) => {
                setTimeout(() => {
                    downloadImage(url);
                }, index * 500); // 每张图片间隔500毫秒
            });
        }

        function fetchAndDisplayImages() {
            refreshButton.disabled = true;
            refreshButton.textContent = '加载中...';
            gallery.innerHTML = ''; // 清空现有图片
            statusMessage.textContent = '正在加载图片列表...';
            statusMessage.style.color = '#555';
            statusMessage.style.display = 'block';
            galleryTitle.textContent = '加载中...';
            downloadAllBtn.disabled = true; // 禁用下载全部按钮

            fetch('/pic/list')
                .then(response => {
                    if (!response.ok) {
                        throw new Error('网络响应错误: ' + response.statusText + ' (状态码: ' + response.status + ')');
                    }
                    return response.text();
                })
                .then(dataString => {
                    displayImages(dataString);
                })
                .catch(error => {
                    console.error('获取图片列表失败:', error);
                    showStatus('获取图片列表失败: ' + error.message, true);
                    galleryTitle.textContent = '加载失败';
                })
                .finally(() => {
                    refreshButton.disabled = false;
                    refreshButton.textContent = '刷新图片列表';
                });
        }

        refreshButton.addEventListener('click', fetchAndDisplayImages);
        downloadAllBtn.addEventListener('click', downloadAllImages); // 新增

        // 页面初始加载时获取图片
        fetchAndDisplayImages();

        // 打开图片查看器
        function openImageViewer(imgUrl) {
            fullsizeImage.src = imgUrl;
            imageViewer.classList.add('active');
            document.body.style.overflow = 'hidden';
            updateNavButtons();
        }

        // 关闭图片查看器
        function closeImageViewer() {
            imageViewer.classList.remove('active');
            document.body.style.overflow = '';
        }

        // 更新导航按钮状态
        function updateNavButtons() {
            if (allImageUrls.length <= 1) {
                prevImage.style.display = 'none';
                nextImage.style.display = 'none';
            } else {
                prevImage.style.display = 'block';
                nextImage.style.display = 'block';
            }
        }

        // 显示上一张图片
        function showPreviousImage() {
            if (allImageUrls.length > 0) {
                currentImageIndex = (currentImageIndex - 1 + allImageUrls.length) % allImageUrls.length;
                fullsizeImage.src = allImageUrls[currentImageIndex];
            }
        }

        // 显示下一张图片
        function showNextImage() {
            if (allImageUrls.length > 0) {
                currentImageIndex = (currentImageIndex + 1) % allImageUrls.length;
                fullsizeImage.src = allImageUrls[currentImageIndex];
            }
        }

        // 添加事件监听器
        closeViewer.addEventListener('click', closeImageViewer);
        prevImage.addEventListener('click', showPreviousImage);
        nextImage.addEventListener('click', showNextImage);

        // 点击模态框背景关闭
        imageViewer.addEventListener('click', function(e) {
            if (e.target === imageViewer) {
                closeImageViewer();
            }
        });

        // 键盘导航支持
        document.addEventListener('keydown', function(e) {
            if (!imageViewer.classList.contains('active')) return;

            if (e.key === 'Escape') {
                closeImageViewer();
            } else if (e.key === 'ArrowLeft') {
                showPreviousImage();
            } else if (e.key === 'ArrowRight') {
                showNextImage();
            }
        });
    });
</script>
</body>
</html>