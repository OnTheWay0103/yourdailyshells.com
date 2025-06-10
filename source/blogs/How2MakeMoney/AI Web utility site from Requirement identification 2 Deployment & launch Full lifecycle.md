# AI Web utility site from Requirement identification 2 Deployment & launch Full lifecycle

## 总纲：
	找到需求，满足需求

## 两个目标
	- 借助AI工具发布第一个海外网站
	- 通过SEO/AdSense实现盈利 AdSense - 数据追踪与广告系统

### 盈利方式：
 #### Google Ads广告：

	1. 联盟广告： 
	   如何开通 https://adsense.com https://www.google.com/adsense/  Google AdSense (几个条件：网站有价值，UV>500,AGE>18)
		1.1 注册账号
		1.2 添加并验证网站 （国家地区根据人在的位置选择就可以），获取广告代码
		1.3 关联网站
		1.4 实名认证（>100$ google才会付款) 需要接收google的一个pin码
			也可以后台申请线上实名认证 https://support.google.com/adsense/workflow/11033519
		1.5 收款 建议招行电汇 搜索 China Merchants Bank Adsense,查找教程
 #### 付费定阅，推广分成，捐赠等
 

## 一。图片类的网站如何找到需求并实现：
	1. 查看AI图片类榜单（推荐工具：toolify.ai）
	2. 使用工具导出网站关键词（推荐工具：Google keyword Planer,SEMRush等）
	3. 使用关键词工具调研，找到值得做的需求(./利用关键词工具...找到值得做的需求.md)
	4. 实现需求 - 使用模板或者AI协助开发：
		使用 https://vercel.com 练习上站 
		https://supabase.com (DB) 
		https://www.astria.ai (API KEY)
	5. 网站优化和推广 （发外链）（可以用 ahrefs 工具查看竞品的发外链目标地）- 如何发外链？
	6. 重复 1~5 步骤
	

### 上站实践：
	0. 选keywords关键词，并判断出是否可以做（需要经验积累与一些感觉判断），尽量找新词
	1. 使用 模板直接发布 网站 （可以在github上找模板或者在 vercel.com 上找模板）可以先随意找几个模板试一下流程
	2. 在 vercel.com 选好模板，deploy,然后关联vercel和github的账号（如已关联，跳过关联步骤）
	3. 在 https://supabase.com 创建数据库
	4. 在 https://www.astria.ai  创建密钥
	5. 部署成功后，再上线域名等，修改DNS等
	6. 网站优化和推广
	7. 其他：（免费域名 Dot.tk, https://www.infinityfree.com/  vercel.com也会生成一个免费域名，还有cloudflare.com， https://pages.github.com/ 等）
	8. Next.js的网站建议在vercel.com上发, HTML静态页面在cloudflare上发
	9. 数据分析与网站调整：Google Search Console (这个工具需要查一下); Google Analytics;注册的账号密码要牢记

### 进阶优化与推广策略
	- 优化是个漫长的过程
	- 推广的方法之一：发外链，参考竞品的外链

## 二。H5游戏聚合网站
	使用IFrame把H5游戏聚合到一起，靠广告等收入 - 怎么找哪些游戏可能会火？
	可以到github上找开源的H5小游戏，或者找游戏发布平台。
	1. 在spaceship.com上注册域名，支持支付宝付款，然后在Cloudflare.com上托管（先用免费套餐）
	2. 单网页游戏AI开发提示词：
		```
		你是一位精通谷歌 SEO 和 HTML& Tailwind 语法的十年全栈工程师

		我要做一个单页H5游戏网站，域名是 xxx.com，游戏名字即关键词是 xxx ，在线游戏的 iframe 地址是 https://cloud.onlinegames.io/xxx.html

		请帮我输出一个完整版的 HTML 和 CSS 代码，游戏标题，一句话介绍，在线游戏的 IFRAME 内容，游戏基本情况叙述

		要求这个网站在 PC 和移动端适配性良好，配色采用苹果典型色系，包含一个一级 H1 标签和多个 H2 标签，有 canonical url，网站语言是地道英文
		```
	3、多游戏多网页游戏站：（是不是类似17173.com  我很9之前听过这个游戏网站）
		如何做到模板化和自动化来批量添加游戏？
		3.1 通用游戏模板页面
		3.2 IFrame嵌入标准化
		3.3 编写自动化脚本
		3.4 丰富游戏页面内容，吸引和留住用户
		3.5 互动功能：社交分享等

	4. 游戏站优化与推广
		4.1 SEO : 高质量内容，站点地图等
		4.2 推广与流量获取：做媒体宣传内容，与一些站长建立合作关系，获得外部链接
		4.3 数据分析与调整：Google Analytics, GSC监控，定期更新

	---
### 小结
	重点是验证需求，有需求才会自然增长，这比研究技术和做的好看更有意义	



## 三。导航网站 - 略

## 支付相关：
	1. 收款渠道：LemonSqueezy, Stripe(用公司注册比较好)，推荐使用 creem.io 收单平台（可以收全球信用卡和Paypal支付，用境内银行卡人民币结算)
	2. 支付方式：MasterCard, Visa

