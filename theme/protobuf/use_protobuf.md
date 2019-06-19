
[protobuf](https://github.com/protocolbuffers/protobuf)

[protobuf download](https://developers.google.com/protocol-buffers/docs/downloads)


1. 安装 `protoc`, 用于解析 `.proto` 文件, 生成解析类
2. 编写 `.proto` 文件
3. 执行 `protoc`

---

对于 cpp:

执行 `protoc -I=$SRC_DIR --cpp_out=$DST_DIR $SRC_DIR/addressbook.proto`

生成 `addressbook.pb.h`, `addressbook.pb.cc`

运行 CMake 可以构建出 VS 项目工程, 能够直接编译出 `libprotobuf.lib`, `libprotobufd.lib` 等.

`extract_includes.bat`, 可以抽取出protobuf的头文件.


---

对于 Node.js:

执行 `protoc --js_out=import_style=commonjs,binary:out addressbook.proto`, out 是导出目录

生成 `addressbook_pb.js`

`npm install google-protobuf`, 本地安装 `google-protobuf`
