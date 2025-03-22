# iz-proxy

:palm_tree: `oh-my-zsh`的插件，目前是给Git、Flutter添加代理和镜像的方法

# 安装
```bash
git clone https://github.com/izven/iz-proxy.git ~/.oh-my-zsh/custom/plugins/iz-proxy
```
接着打开`~/.zshrc`文件，找到`plugins`一行，添加`iz-proxy`
```
plugins=(git iz-proxy)
```
重新打开一个终端或者运行 `source $HOME/.zshrc` 使其生效

# 使用

只需输入`izproxy`即可调用命令，根据显示的菜单进行设置即可

# 支持
目前支持:
- `Git (HTTP SOCKS5)`
- `Flutter`

# 配置
:shaved_ice: 
脚本会备份`.zshrc`文件到`~/.iz_mirror_backup`

# 删除

```bash
$ rm -rf ~/.iz_mirror_backup
$ rm -rf ~/.oh-my-zsh/custom/plugins/iz-proxy
```
