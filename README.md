# TCL语言的通道封装
1、用过tcl的都知道，tcl的拓展包相当少。
2、ssh的拓展包expect相当难用。
于是计划封装一个继承以下几种通道的拓展包：
1、ssh通道、serial通道，封装plink命令。
2、socket通道，telnet等。
3、irb通道，封装irb,用于操作ruby交互。
4、adb通道，封装adb.exe,用于操作安卓手机的adb shell通道交互。

备注：
本代码只提供思路，由于一些私有库不会上传，因此本代码无法直接在普通的tcl解释器运行。
