# git-modified-search.nvim

Displays quick fixes for lines added between HEAD~1 and HEAD.
```
:GitModifiedSearch
```

If HEAD~2 and HEAD:
```
:GitModifiedSearch HEAD~2
```

You can narrow down the target.
If the word HELLO is included:

```
:GitModifiedSearch HEAD~1 HELLO
```

