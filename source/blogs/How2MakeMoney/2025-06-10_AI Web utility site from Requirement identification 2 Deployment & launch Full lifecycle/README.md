# AI Web utility site from Requirement identification 2 Deployment & launch Full lifecycle

## 总纲

找到需求，满足需求

## 两个目标

- 借助 AI 工具发布第一个海外网站
- 通过 SEO/AdSense 实现盈利 AdSense - 数据追踪与广告系统

### 盈利方式

#### Google Ads 广告

1. 联盟广告：
   如何开通 https://adsense.com https://www.google.com/adsense/ Google AdSense (几个条件：网站有价值，UV>500,AGE>18)
   1. 注册账号
   2. 添加并验证网站 （国家地区根据人在的位置选择就可以），获取广告代码
   3. 关联网站
   4. 实名认证（>100$ google 才会付款) 需要接收 google 的一个 pin 码
      也可以后台申请线上实名认证 https://support.google.com/adsense/workflow/11033519
   5. 收款 建议招行电汇 搜索 China Merchants Bank Adsense,查找教程

#### 付费定阅，推广分成，捐赠等

## 一。图片类的网站如何找到需求并实现

1. 查看 AI 图片类榜单（推荐工具：toolify.ai）
2. 使用工具导出网站关键词（推荐工具：Google keyword Planer,SEMRush 等）
3. 使用关键词工具调研，找到值得做的需求(./利用关键词工具...找到值得做的需求.md)
4. 实现需求 - 使用模板或者 AI 协助开发：
   - 使用 https://vercel.com 练习上站
   - https://supabase.com (DB) github 账号授权登录
   - https://www.astria.ai (API KEY)
5. 网站优化和推广 （发外链）（可以用 ahrefs 工具查看竞品的发外链目标地）- 如何发外链？
6. 重复 1~5 步骤

### 上站实践

1. 选 keywords 关键词，并判断出是否可以做（需要经验积累与一些感觉判断），尽量找新词
2. 使用 模板直接发布 网站 （可以在 github 上找模板或者在 vercel.com 上找模板）可以先随意找几个模板试一下流程
3. 在 vercel.com 选好模板，deploy,然后关联 vercel 和 github 的账号（如已关联，跳过关联步骤）
4. 在 https://supabase.com 创建免费数据库
5. 在 https://www.astria.ai 创建密钥
6. 部署成功后，再上线域名等，修改 DNS 等
7. 网站优化和推广
8. 其他：（免费域名 Dot.tk, https://www.infinityfree.com/ vercel.com 也会生成一个免费域名，还有 cloudflare.com， https://pages.github.com/ 等）
9. Next.js 的网站建议在 vercel.com 上发, HTML 静态页面在 cloudflare 上发
10. 数据分析与网站调整：Google Search Console (这个工具需要查一下); Google Analytics;注册的账号密码要牢记

### 进阶优化与推广策略

- 优化是个漫长的过程
- 推广的方法之一：发外链，参考竞品的外链

## 二。H5 游戏聚合网站

使用 IFrame 把 H5 游戏聚合到一起，靠广告等收入 - 怎么找哪些游戏可能会火？
可以到 github 上找开源的 H5 小游戏，或者找游戏发布平台。

1. 在 spaceship.com 上注册域名，支持支付宝付款，然后在 Cloudflare.com 上托管（先用免费套餐）
2. 单网页游戏 AI 开发提示词：

```html
你是一位精通谷歌 SEO 和 HTML& Tailwind 语法的十年全栈工程师
我要做一个单页H5游戏网站，域名是 xxx.com，游戏名字即关键词是 xxx ，在线游戏的
iframe 地址是 https://cloud.onlinegames.io/xxx.html 请帮我输出一个完整版的 HTML
和 CSS 代码，游戏标题，一句话介绍，在线游戏的 IFRAME 内容，游戏基本情况叙述
要求这个网站在 PC 和移动端适配性良好，配色采用苹果典型色系，包含一个一级 H1
标签和多个 H2 标签，有 canonical url，网站语言是地道英文
```

3. 多游戏多网页游戏站：（是不是类似 17173.com 我很 9 之前听过这个游戏网站）
   如何做到模板化和自动化来批量添加游戏？

   1. 通用游戏模板页面
   2. IFrame 嵌入标准化
   3. 编写自动化脚本
   4. 丰富游戏页面内容，吸引和留住用户
   5. 互动功能：社交分享等

4. 游戏站优化与推广
   1. SEO : 高质量内容，站点地图等
   2. 推广与流量获取：做媒体宣传内容，与一些站长建立合作关系，获得外部链接
   3. 数据分析与调整：Google Analytics, GSC 监控，定期更新

### 小结

重点是验证需求，有需求才会自然增长，这比研究技术和做的好看更有意义

## 三。导航网站 - 略

## 支付相关

1. 收款渠道：LemonSqueezy, Stripe(用公司注册比较好)，推荐使用 creem.io 收单平台（可以收全球信用卡和 Paypal 支付，用境内银行卡人民币结算)
2. 支付方式：MasterCard, Visa
