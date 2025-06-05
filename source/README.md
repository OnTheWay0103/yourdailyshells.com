# 首页

<h4><a href="https://ontheway0103.github.io/dailyshells.com/">在路上的官方网站</a></h4>

<h4>最新发表的博客文章：</h4>

<div id="home-blog-list" class="home-blog-list"></div>

<script>
    documentReady(async ()=>{
        const resp = await fetch('/blogs/tech/index.json');
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
    <div><a href="${blog.uri}">${gitsite.encodeHtml(blog.title)}</a></div>
</div>`;
        });
        document.getElementById('home-blog-list').innerHTML = items.join('');
    });
</script>
