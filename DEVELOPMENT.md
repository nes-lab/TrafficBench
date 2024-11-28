# DEV

## Push to all Remote Repos

```Shell
git push github main
git push gitlab main
git push aachen main
```

when content of `/.git/config` is

```
[core]
	repositoryformatversion = 0
	filemode = false
	bare = false
	logallrefupdates = true
	symlinks = false
	ignorecase = true
[submodule]
	active = .
[remote "gitlab"]
	url = https://gitlab.com/nes-lab/trafficbench.git
	fetch = +refs/heads/*:refs/remotes/gitlab/*
[branch "main"]
	remote = github
	merge = refs/heads/main
[lfs]
	repositoryformatversion = 0
[remote "aachen"]
	url = https://git.rwth-aachen.de/nes-lab/trafficbench.git
	fetch = +refs/heads/*:refs/remotes/aachen/*
[remote "github"]
	url = https://github.com/nes-lab/TrafficBench
	fetch = +refs/heads/*:refs/remotes/github/*
```