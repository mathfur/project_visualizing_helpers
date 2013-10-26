project_visualizing_helpers
===========================

Install
-------
```shell
brew install libmagic
```

Usage
-----
HookMethodを外部プロジェクトで使う場合は
lib/project_visualizing_helpers/hook_method.rbを適当な場所にコピーして使う。
```
require "hook_method"
f = open(ファイル名, "w")
ProjectVisualizingHelpers::HookMethod.hook(DummyClassForHookMethod, f)
f.close
```
