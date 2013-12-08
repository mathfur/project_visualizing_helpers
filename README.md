project_visualizing_helpers
===========================

Install
-------
```shell
brew install libmagic
```

Usage
-----
hook_method,include2csvは外部プロジェクトで使う。
適当な場所にlib/project_visualizing_helpers/{hook_method,include2csv}.rbをコピーしてrequireする。
```ruby
require "hook_method"
f = open(ファイル名, "w")
ProjectVisualizingHelpers::HookMethod.hook(DummyClassForHookMethod, f)
f.close
```

```
require "include2csv"
puts ProjectVisualizingHelpers::Include2CSV.new.to_csv
```

drill_down Usage
----------------
1. Write config/relation.yml
2. Write config/models.yml
3. Create table to main.db
