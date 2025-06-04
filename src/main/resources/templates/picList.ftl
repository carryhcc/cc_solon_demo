<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>图片列表展示</title>
    <link rel="stylesheet" href="/base.css">
    <link rel="stylesheet" href="/css/image-gallery.css">
        <!-- 免费版本（推荐） -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
</head>
<body>
<div class="container">
    <header>
        <h1>随机套图</h1>
    </header>

    <div class="controls">
        <button id="refreshImageListBtn">刷新图片列表</button>
    </div>

    <div id="galleryTitle" class="gallery-title">加载中...</div>

    <div id="imageGallery" class="image-gallery">
        desgaste
    </div>
    <div id="statusMessage" class="status-message" style="display: none;"></div>
</div>

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

        const imageViewer = document.getElementById('imageViewer');
        const fullsizeImage = document.getElementById('fullsizeImage');
        const closeViewer = document.getElementById('closeViewer');
        const prevImage = document.getElementById('prevImage');
        const nextImage = document.getElementById('nextImage');

        let currentImageIndex = 0;
        let allImageUrls = [];

        function showStatus(message, isError = false) {
            statusMessage.textContent = message;
            statusMessage.style.color = isError ? 'red' : '#555';
            statusMessage.style.display = 'block';
            gallery.innerHTML = '';
        }

        function displayImages(data) {
            gallery.innerHTML = '';
            statusMessage.style.display = 'none';
            allImageUrls = [];

            try {
                const parsedData = typeof data === 'string' ? JSON.parse(data) : data;

                const galleryName = Object.keys(parsedData)[0];
                let imageUrls = parsedData[galleryName];

                if (typeof imageUrls === 'string') {
                    if (imageUrls.startsWith('[') && imageUrls.endsWith(']')) {
                        const urlsString = imageUrls.substring(1, imageUrls.length - 1);
                        imageUrls = urlsString.split(',').map(url => url.trim());
                    } else {
                        imageUrls = [imageUrls.trim()];
                    }
                }

                galleryTitle.textContent = galleryName || '未命名图片组';

                if (!imageUrls || imageUrls.length === 0) {
                    showStatus('图片列表为空。');
                    return;
                }

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

                        img.onload = function() {
                            const ratio = this.naturalWidth / this.naturalHeight;

                            if (ratio > 1.2) {
                                imgContainer.style.gridColumnEnd = 'span 2';
                            }
                            else if (ratio < 0.7) {
                                imgContainer.style.gridRowEnd = 'span 2';
                            }
                        };

                        // 创建下载按钮
                        const downloadBtn = document.createElement('button');
                        downloadBtn.className = 'download-btn';
                        downloadBtn.innerHTML = '<i class="fa fa-download"></i>';
                        downloadBtn.onclick = function(e) {
                            e.stopPropagation(); // 防止触发图片点击事件
                            downloadImage(imgUrl);
                        };

                        imgContainer.appendChild(img);
                        imgContainer.appendChild(downloadBtn);
                        gallery.appendChild(imgContainer);

                        // 为图片添加点击事件
                        imgContainer.addEventListener('click', function() {
                            currentImageIndex = allImageUrls.indexOf(imgUrl);
                            openImageViewer(imgUrl);
                        });
                    }
                });

            } catch (error) {
                console.error('解析图片数据失败:', error);
                showStatus('解析图片数据失败: ' + error.message, true);
            }
        }

        function downloadImage(url) {
            // 创建 XMLHttpRequest 对象
            const xhr = new XMLHttpRequest();
            xhr.open('GET', url, true);
            xhr.responseType = 'blob'; // 设置响应类型为 Blob

            xhr.onload = function() {
                if (xhr.status === 200) {
                    const blob = xhr.response;
                    // 创建下载链接
                    const link = document.createElement('a');
                    link.href = URL.createObjectURL(blob);
                    link.download = url.split('/').pop(); // 提取文件名（如 image.jpg）

                    // 添加到文档并触发点击
                    document.body.appendChild(link);
                    link.click();

                    // 清理临时链接
                    URL.revokeObjectURL(link.href);
                    document.body.removeChild(link);
                }
            };

            xhr.onerror = function() {
                console.error('下载图片失败:', xhr.statusText);
            };

            xhr.send();
        }

        function fetchAndDisplayImages() {
            refreshButton.disabled = true;
            refreshButton.textContent = '加载中...';
            gallery.innerHTML = '';
            statusMessage.textContent = '正在加载图片列表...';
            statusMessage.style.color = '#555';
            statusMessage.style.display = 'block';
            galleryTitle.textContent = '加载中...';

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
        fetchAndDisplayImages();

        function openImageViewer(imgUrl) {
            fullsizeImage.src = imgUrl;
            imageViewer.classList.add('active');
            document.body.style.overflow = 'hidden';
            updateNavButtons();
        }

        function closeImageViewer() {
            imageViewer.classList.remove('active');
            document.body.style.overflow = '';
        }

        function updateNavButtons() {
            if (allImageUrls.length <= 1) {
                prevImage.style.display = 'none';
                nextImage.style.display = 'none';
            } else {
                prevImage.style.display = 'block';
                nextImage.style.display = 'block';
            }
        }

        function showPreviousImage() {
            if (allImageUrls.length > 0) {
                currentImageIndex = (currentImageIndex - 1 + allImageUrls.length) % allImageUrls.length;
                fullsizeImage.src = allImageUrls[currentImageIndex];
            }
        }

        function showNextImage() {
            if (allImageUrls.length > 0) {
                currentImageIndex = (currentImageIndex + 1) % allImageUrls.length;
                fullsizeImage.src = allImageUrls[currentImageIndex];
            }
        }

        closeViewer.addEventListener('click', closeImageViewer);
        prevImage.addEventListener('click', showPreviousImage);
        nextImage.addEventListener('click', showNextImage);

        imageViewer.addEventListener('click', function(e) {
            if (e.target === imageViewer) {
                closeImageViewer();
            }
        });

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