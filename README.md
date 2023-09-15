# Build icu2c with bazel


## Build for MacOS

```
bazel build :main --config=macos
```

## Build for WASM

```
bazel build :wasm-main
```


## Success Ouput


```
name: UTF-8
count: 232
0: UTF-8
1: ibm-1208
2: ibm-1209
3: ibm-5304
...
```