<!DOCTYPE html>
<html>
<head>
    <link rel="stylesheet" href="/base.css" />
    <style>
        body {
            text-align: center;
            padding: 20px;
        }
        img {
            max-width: 100%;
            height: auto;
            border: 1px solid #ddd;
            border-radius: 8px;
            margin-bottom: 20px;
        }
        button {
            padding: 10px 20px;
            font-size: 16px;
            cursor: pointer;
            border: none;
            background-color: #4CAF50;
            color: white;
            border-radius: 5px;
        }
        button:hover {
            background-color: #45a049;
        }
    </style>
</head>
<body>

<img src="${url!}" alt="图片加载失败" />

<br/>

<button onclick="refreshPage()">刷新</button>

<script>
    function refreshPage() {
        location.reload();
    }
</script>

</body>
</html>
