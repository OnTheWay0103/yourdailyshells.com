# GitHub SSH 问题

## 让 Git 在使用 SSH 时自动使用你的密钥进行认证

### 一、解决方法：启动 ssh-agent 并添加你的 SSH 私钥

在 Git Bash 中，你需要手动启动 ssh-agent，然后再运行 ssh-add 来添加你的私钥。

步骤如下：

1. 启动 ssh-agent（在 Git Bash 中运行以下命令）：

```bash
eval "$(ssh-agent -s)"
```

这条命令会启动 ssh-agent 并设置必要的环境变量，使得当前 Shell 可以与它通信。

2. 添加你的 SSH 私钥（通常是 id_rsa）：

```bash
ssh-add ~/.ssh/id_rsa
```

如果你使用的是默认的 SSH 密钥对（即 id_rsa 和 id_rsa.pub），就可以用上面的命令。

如果你使用了其他名称的密钥文件，比如 my_key，那么命令应该是：

```bash
ssh-add ~/.ssh/my_key
```

3. 验证是否添加成功：

```bash
ssh-add -l
```

如果成功，你会看到类似这样的输出，显示已加载的 SSH 公钥指纹：

```
2048 SHA256:xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx your_email@example.com (RSA)
```

### 二、（可选）让 ssh-agent 在每次打开 Git Bash 时自动启动

为了避免每次打开 Git Bash 都要手动运行 `eval "$(ssh-agent -s)"`，你可以将启动命令添加到你的 Shell 配置文件中，比如 `~/.bashrc` 或 `~/.bash_profile`。

步骤如下：

1. 打开 `~/.bashrc` 文件（如果不存在可以创建）：

```bash
nano ~/.bashrc
```

或者使用其他编辑器如 vim 或 notepad（在 Git Bash 中）：

```bash
notepad ~/.bashrc
```

2. 在文件末尾添加以下内容：

```bash
# 启动 ssh-agent
if [ -z "$SSH_AUTH_SOCK" ]; then
  eval "$(ssh-agent -s)"
fi
```

3. 保存文件并退出编辑器。

4. 让配置生效：

```bash
source ~/.bashrc
```

这样，每次你打开 Git Bash 时，ssh-agent 就会自动启动，你就不需要手动执行 `eval "$(ssh-agent -s)"` 了。

### 三、总结

你现在遇到的问题是：

- `ssh-add -l` 提示无法连接 ssh-agent，因为 ssh-agent 没有运行。

解决方法是：

1. 运行 `eval "$(ssh-agent -s)"` 启动它
2. 然后运行 `ssh-add ~/.ssh/id_rsa` 添加你的私钥
3. （可选）配置 `~/.bashrc` 让 ssh-agent 自动启动

完成这些步骤后，你的 SSH 密钥就会被正确加载，Git 在使用 SSH 与 GitHub 通信时就可以自动使用你的密钥进行认证了。
