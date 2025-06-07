# 首页

<h4>在路上原创精品</h4>

<div class="home-book-list">
    <!-- makefile -->
    <div class="home-book-list-item">
        <a href="./books/gitsite-guide/index.html" class="home-book-list-image">
            <div>
                <img src="./static/cover/makefile.jpg" />
            </div>
            <div class="home-book-list-title">
                MarkDown教程
            </div>
            <div class="home-book-list-desc">
                入门Markdown，从零开始,不要看我说的是什么，看我写的是什么！
            </div>
        </a>
    </div>
</div>

<h4>最新发表的博客文章：</h4>

<div id="home-blog-list" class="home-blog-list"></div>

<script>
    documentReady(async ()=>{
        const resp = await fetch('./blogs/How2MakeMoney/index.json');
        let blogs = await resp.json();
        if (blogs.length > 20) {
            blogs = blogs.slice(0, 20);
        }
        console.log(JSON.stringify(blogs));
        const items = blogs.map(blog => {
            let date = new Date(blog.date).toLocaleDateString(undefined, { year: 'numeric', month: 'long', day: 'numeric' });
            return `
<div class="home-blog-list-item">
    <div><span class="text-sm font-semibold uppercase">${date}</span></div>
    <div><a href=".${blog.uri}">${gitsite.encodeHtml(blog.title)}</a></div>
</div>`;
        });
        document.getElementById('home-blog-list').innerHTML = items.join('');
    });
</script>
