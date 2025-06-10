<p style="display: flex; flex-direction: column; align-items: center; gap: 1rem; width: 100%;">
    <div style="text-align: center; width: 100%; display: flex; flex-direction: column; align-items: center;">
        <img src="../../../static/cover/my_qrcode.png" style="max-width: 200px; width: 100%; height: auto; border-radius: 8px; display: block; margin: 0 auto;">
        <p style="margin-top: 0.5rem; font-size: 0.9rem; color: #666;">扫码关注我的微信</p>
    </div>
    <div style="display: flex; gap: 1rem; justify-content: center; width: 100%;">
    <span style="line-height: 24px;">分享到:</span>
    <a href="#0" title="分享到Twitter" onclick="previewSVG(this.querySelector('svg'))">
        <svg viewBox="0 0 18 14" xmlns="http://www.w3.org/2000/svg" fill="currentColor" style="width: 24px; height: 24px; cursor: pointer;">
            <path d="M5.90944 13.7676C7.18903 13.7764 8.45762 13.5308 9.64152 13.0452C10.8254 12.5596 11.901 11.8436 12.8058 10.9387C13.7107 10.0339 14.4267 8.95831 14.9123 7.77442C15.398 6.59052 15.6435 5.32193 15.6347 4.04234C15.6347 3.89424 15.6318 3.74692 15.6251 3.6004C16.294 3.11637 16.8714 2.51704 17.3301 1.83048C16.7065 2.10711 16.0448 2.28853 15.3673 2.36867C16.081 1.9415 16.6151 1.26951 16.8702 0.47784C16.1993 0.875917 15.4653 1.15658 14.7 1.30773C14.1847 0.759649 13.5031 0.396688 12.7607 0.275024C12.0184 0.153359 11.2566 0.279775 10.5933 0.634706C9.93003 0.989637 9.40223 1.55329 9.09159 2.23844C8.78095 2.92358 8.7048 3.69201 8.87492 4.4248C7.51583 4.35687 6.18622 4.00382 4.97245 3.38858C3.75868 2.77334 2.6879 1.90967 1.82965 0.853666C1.39239 1.60611 1.2584 2.49693 1.45497 3.3447C1.65154 4.19248 2.16388 4.93344 2.88765 5.41668C2.34485 5.40017 1.81395 5.25358 1.33958 4.98925C1.3388 5.00353 1.3388 5.01782 1.3388 5.03287C1.33896 5.82207 1.61213 6.58691 2.11194 7.19765C2.61176 7.8084 3.30746 8.22744 4.08103 8.38371C3.57776 8.52103 3.0497 8.5411 2.53745 8.4424C2.75578 9.12162 3.18095 9.7156 3.75349 10.1413C4.32603 10.5669 5.01731 10.803 5.73063 10.8164C4.51983 11.7668 3.02454 12.2822 1.48533 12.2798C1.21283 12.2799 0.940561 12.264 0.669922 12.2322C2.23287 13.2363 4.05177 13.7693 5.90944 13.7676Z"></path>
        </svg>
    </a>
    <a href="#0" title="分享到Facebook" onclick="previewSVG(this.querySelector('svg'))">
        <svg viewBox="0 0 20 20" xmlns="http://www.w3.org/2000/svg" fill="currentColor" style="width: 24px; height: 24px; cursor: pointer;">
            <path d="M19.375 10.06a9.383 9.383 0 0 1-7.907 9.257V12.77h2.185l.408-2.71h-2.593V8.3a1.356 1.356 0 0 1 1.521-1.468h1.2V4.53a14.7 14.7 0 0 0-2.1-.182 3.31 3.31 0 0 0-3.547 3.643v2.068h-2.38v2.71h2.38v6.546a9.374 9.374 0 1 1 10.843-9.257z"></path>
        </svg>
    </a>
    <a href="#0" title="分享到Telegram" onclick="previewSVG(this.querySelector('svg'))">
        <svg viewBox="0 0 18 16" xmlns="http://www.w3.org/2000/svg" fill="currentColor" style="width: 24px; height: 24px; cursor: pointer;">
            <path d="M16.5257 0.95613L0.992894 6.94483C-0.066948 7.37023 -0.061323 7.96196 0.800144 8.22551L4.78605 9.46968L14.0138 3.64787C14.4499 3.3832 14.8494 3.52537 14.5213 3.81704L7.04397 10.5643L7.12095 10.6987L7.04397 10.5649L6.76974 14.675C6.92584 14.6731 7.07947 14.6358 7.21913 14.566C7.35878 14.4963 7.48083 14.3958 7.57613 14.2721L9.51318 12.389L13.5423 15.3662C14.2841 15.7748 14.8191 15.5629 15.004 14.6773L17.6491 2.21212C17.9199 1.12644 17.2349 0.634171 16.5258 0.956163"></path>
        </svg>
    </a>
</div>
</p>

<style>
.svg-preview {
    position: fixed;
    top: 50%;
    left: 50%;
    transform: translate(-50%, -50%);
    background: white;
    padding: 20px;
    border-radius: 8px;
    box-shadow: 0 0 20px rgba(0,0,0,0.2);
    z-index: 1000;
    display: none;
}

.svg-preview svg {
    width: 200px;
    height: 200px;
}

.svg-preview-overlay {
    position: fixed;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    background: rgba(0,0,0,0.5);
    z-index: 999;
    display: none;
}
</style>

<div id="svgPreview" class="svg-preview"></div>
<div id="svgPreviewOverlay" class="svg-preview-overlay"></div>

<script>
function previewSVG(svg) {
    const preview = document.getElementById('svgPreview');
    const overlay = document.getElementById('svgPreviewOverlay');
    
    // 克隆SVG并设置大小
    const clonedSvg = svg.cloneNode(true);
    clonedSvg.style.width = '200px';
    clonedSvg.style.height = '200px';
    
    // 显示预览
    preview.innerHTML = '';
    preview.appendChild(clonedSvg);
    preview.style.display = 'block';
    overlay.style.display = 'block';
    
    // 点击遮罩关闭预览
    overlay.onclick = function() {
        preview.style.display = 'none';
        overlay.style.display = 'none';
    };
}
</script>
