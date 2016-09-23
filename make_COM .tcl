#�������������淶�� 
#   ȫ�ֳ���"��_�ָ��ȫ��д"  ȫ�ֱ���"��_�ָ����޵�������"�Ĵ�д�շ�ʽ  �ֲ�����"Сд�շ�ʽ"
#   pub���෽��Func_  pro/pri���෽��_Func_  pub��ʵ������[fF]unc  pro/pri��ʵ������_[fF]unc
#   pub�������Var_   pro/pri�������_Var_   pub��ʵ������Var   pro/pri��ʵ������_Var
#   ����������"��_�ָ����е�������"���շ�ʽ   �����ʴ�д��ͷ��pubMethodһ��Ϊ�ؼ��ֺ���kc/kt
#   ��������: "Сд�շ�ʽ"���������ı����� ĳ�����ı�������ǰ�����_
#   

#  [LIBDBG -Comdata 1 xxx] =>   ��Ϣ�̶���ӡ��$_Comname��־�У�
#			LIBDBG(dvCOM,stdout)��1ʱ����Ϣͬʱ��ӡ��stdout��
#  [LIBDBG -f 1 xxx] => ��Ϣ�̶���ӡ��sum��$_Comname������־�У���stdout��
#  [ff f]  => ��ӡ��LIBDBG�е���Ϣ

package require itclx
if {[itcl::find classes COM]!=""} {return "already exists Class COM"}
source lib/tclcommon.tcl
source lib/kManage.tcl

if {![info exists __tclcommon__]} {
  proc LIBDBG_set args {}
  proc LIBDBG_logOpen args {}
  proc LIBERR {args} {uplevel 1 $args}
  set Debug 1
  proc LIBDBG {args} {
    if {$::Debug} {puts $args}
  }
  set LIBDBG(fNameLs) ""
}
;

set COM_This ""   ;# ��ǰ��Ծ����$this�����ڶ�$::COM_This.f��$::COM_This._Comdata��������
#trace add variable COM_This write f_trace_varWrite
proc CLASS-COM {} {}
;# �������������з�ʽ����Ŀ�꣬��Comid��Comname(������/IP��ַ/������)�����ָ���ͨ��
class COM {   ;# ����dvCOM.tclʱ������һ��Ĭ�϶���::com0����
  public variable _Comid   {}
  public variable _Comname {}
  public variable _Comdata  {}                  ;# COMͨ���еġ�����������Ϣ��
  public variable _ComSerCfg  {9600,8,n,1,N}                ;# ���ڴ���
  public variable _chantype {}    ;#���ӷ�ʽ
  
  public method This        ;# ͨ���ı�::COM_Thisʹf���������ö����л�
  public method _init
  public variable _IfInitSuccess 0
  public method _link
  public method _login
  public method _reset
  
  public proc f             ;# ��÷�����Ϊ���ã�Ϊ����ʹ��δʹ��"f_"�����Ĺ淶����
  #public method fCmd
  public method Init
  public method adb_root
  public method _rx
  public method _tx
  public method _write_Com
  public method _read_Com                  ;# ��COMͨ���ж�<һ����ʱ��Ϣ>
  public method _collect_Comdata           ;# ��COMͨ�����ռ�������������Ϣ��

  public variable _IfTrimComdata 1      ;# �Ƿ�����������
  public variable _TrimComdataMap {
    [0m {}    [01;32m {}  [01;34m {}  [34;42m {}
    [m]0; {} ]0; {}    ~ {}        [30;42m {}
    [1;34m {}  [1;36m {}  [0m {}
  }
  public method _trim_Comdata            ;# ����������ʱ������_TrimDataMap����
  
  public variable _Counter 0           ;# ��������ÿ��f������ʱ����1
  public variable _DstInit {}          ;# ��¼����Ŀ��ĳ�ʼ����Ϣ
  public variable _Dft                 ;# Ĭ�ϵĿ�������
  public variable _MaxReadMax 1000     ;# ����maxReadֵΪ1000��Լ100��
  constructor {{dftSet ""}} {
    if {$::COM_This=="<IfInitClass_COM=0>"} {return {}}
    set ::COM_This $this
    array set _Dft {
      LoginRemind "Login"  PasswordRemind "Password" LoginLs "admin admin" MaxRead 5
      ComCfg {-blocking 0 -buffering line -buffersize 409600 -translation binary -encoding utf-8}
      ReadGap 100 ReadEnd "> # ]"
      FastRead {"Unknown" "Error" "Missing"
      "login*:" "password:" "Login:" "Password:" "Welcome to.*" "invalid command"
      "Command Groups:" "Available Commands:" "other to continue!" "Description:"
      }
    }
    array set _Dft $dftSet    ;# ע:  "-encoding"ѡ������"-translation"ѡ��֮����ܱ�֤һ����Ч
    set _Dft(RegReadEnd) [format "%s%s%s" {^.*(} [join $_Dft(ReadEnd) |] {)( *|\n*)$}]
    set _Dft(RegFastRead) [format "%s%s%s" {(?n).*(} [join $_Dft(FastRead) |] {) *}]
    puts "COM new obj {$this}"
  }
  destructor {catch {close $_Comid}}
}
;
classEnd COM

# �л������̳�����::*_This����kc/kt�л��Զ����á���Ҫ
# �����ڢ�WEB��ϵ�е�WEB_This/COM_This ��IPC��ϵ�е�COM_This
# 
proc -This {} {}
itcl::body COM::This {} {
  foreach className [$this info heritage] {
    set gloablThis "${className}_This"  ;# exam:    ::COM_This
    uplevel #0 "if \[info exists $gloablThis] {set $gloablThis $this}" 
  }
  set ::COM_This $this
}
;

proc -_init {} {}
itcl::body COM::_init {dst {loginLs "<undefined>"} {linkTryTimes 1}}  {
	LIBDBG ""
	set chanName [lindex $dst 0]
  #LIBDBG -log�ӿ���Ҫһ��logFile����¼log��Ϣ
	if {$chanName ni $::LIBDBG(fNameLs)} {LIBERR LIBDBG_logOpen $chanName}
  
  _reset
	if {![_link $dst $loginLs $linkTryTimes]} {
    set _IfInitSuccess 0
    return $::ERR
  }
  #��¼��ͨ������Ӧ�ĳ�ʼ����Ϣ����Ҫ����fc_tx�е��Զ��޸�ͨ������
  set _DstInit [list $dst $loginLs]
  set _IfInitSuccess 1
  #chan configure $_Comid {*}$_Dft(ComCfg)
  #fconfigure $_Comid -mode $ComRate,n,8,1  
  lassign $dst _Comname chanType
  set _chantype $chanType
  if {$chanType == "ssh" || $chanType == "serial"|| $chanType == "adb"} {
  fconfigure $_Comid -blocking 0  
  fconfigure $_Comid -buffering none
  fconfigure $_Comid -buffersize 409600
  fconfigure $_Comid -translation binary
  fconfigure $_Comid -encoding utf-8
  fileevent $_Comid readable "" 
  } else {
   chan configure $_Comid {*}$_Dft(ComCfg)
  }

  if {$chanType != "adb"} {LIBERR $this _login $loginLs}
  if {$chanType == "adb" && [adb_root] !=1} {return $::ERR}
  set ::COM_This $this
	return $::SUC
}
;
proc -Init {} {}
itcl::body COM::Init {{dst "192.168.21.11 ssh"} {loginLs "root tendatest"} {chanCfg ""}} {
  lassign $dst _Comname chanType
  if {$chanType != "adb"} {
	f_KillProcess -name adb.exe
  }

  set initRes [_init $dst $loginLs $chanCfg]
  LIBDBG "initRes=$initRes"
  
  if {$initRes != $::ERR && $chanType != "adb" } {f "q"}
  
  
  
  
  return $initRes
}
;

#adbͨ������root�Ự��
proc -adb_root {} {}
itcl::body COM::adb_root {} {
  set _rv 0
  for {set _i 0} {$_i<3} {incr _i} {
      f "su"
	  puts [._Comdata]
	  if {[regexp {\#} [._Comdata]] == 1} {
	    return 1 
	  }
	}
  return $_rv
}
;

;# _linkPre
proc -_reset {} {}
itcl::body COM::_reset {}  {  ;# ����ʹ��f��ֻ���õײ��catch {_tx ...}���������ѭ��
	catch {close $_Comid}
}

;# _linkPost
#proc COM-::_firtSend {}  {  ;# ����ʹ��f��ֻ���õײ��catch {_tx ...}���������ѭ��
#	catch {_tx q}
#}
;
;# �޼�Data�е����۱��루��Ҫ����ɫ���µģ�
proc -_trim_ComData {} {}
itcl::body COM::_trim_Comdata {data} {
  if {$_IfTrimComdata=="0"} {return ""}
  return [string map $_TrimComdataMap $data]
}
;
;#[������] ��ʽ����ͨ��
proc -_link {} {}
itcl::body COM::_link {dst loginLs {tryTimes 3}} {
  set _rv 0
	lassign $dst _Comname chanType
  lassign $loginLs login password
  LIBDBG -f 1 [list $dst $loginLs $tryTimes]
  set ipMode 1
	if {![f_ip_reg $_Comname]} {     #exam: dst=={plink.exe -ssh 10.0.0.10}
    #set toSet [list open "|$dst" r+]
    if {$chanType == "serial"} {
    set toSet [list open "|plink.exe -$chanType $_Comname -sercfg $_ComSerCfg" r+]
    } elseif {$chanType == "adb"} {  #ex: set fid [open "|plink.exe -ssh 10.0.0.10" r+]
		set toSet [list open "|adb.exe -s $_Comname shell" r+]
        set _rv 1
    } else {set toSet [list open "|$dst" r+]}
    set ipMode 0
    set _rv 1
  } elseif {[string is integer $chanType]} {
    if {$chanType==""} {set chanType 23}
    set toSet [list socket $_Comname $chanType]
    set _rv 1
  } elseif {$chanType == "ssh"} {  #ex: set fid [open "|plink.exe -ssh 10.0.0.10" r+]
		set toSet [list open "|plink.exe -$chanType $_Comname -l $login -pw $password" r+]
    set _rv 1
   } else {
    LIBDBG "��Ч��_link��ʽ={$dst}"
    return 0
  }
	LIBDBG "set $this._Comid \[eval {$toSet}]"
  for {set i 1} {$i<=1} {incr i} {
    if {$ipMode && [km SYS_Ping DIp=$_Comname MaxSuc=1 MaxErr=3 Debug=1 Interval=0]!=$::TSPASS} {
      LIBDBG "km SYS_ping $_Comname ʧ��"
    } elseif [catch {set _Comid [eval $toSet]} err] {
      LIBDBG "��ͨ��ʱ���쳣. err={$err}"
    } else {
      LIBDBG "���µ�$_Comname ͨ����$_Comid"
      set _rv 1
    }
    #after $_Dft(ReadGap)
  }

 #if {$_rv != 0} { 
  #for {set _i_ 0} {$_i_<30} {incr _i_} {
     # if {[catch {set comdatas [.$this._read_Com]} err]} {
     # LIBDBG "Link�������Եȴ�ͨ����ͨ����error={$err}"
     # } elseif {$comdatas!="" && [string first # $comdatas] != -1} {
     # puts "comdatas$comdatas" 
     # LIBDBG "Link������ͨsshͨ��~"
     # return 1
     # }
    # after 1000
     #puts "$_i_ [_read_Com]"
   #}
 #} 
  
  
  return $_rv
}
;
;# ��½ͨ��
proc -_login {} {}
itcl::body COM::_login {{loginLs "<undefined>"}} {
  if {$loginLs==""} {set loginLs $_Dft(LoginLs)}
  if {$loginLs=="<undefined>"} {return 1}
  lassign $loginLs login password
  
	LIBDBG " loginLs={$loginLs}"
	
  set _Comdata ""
  set _ret 1
	_write_Com "$login"
  #puts "[_read_Com]"
  #after $_Dft(ReadGap)
  if {[set iread [_read_Com]]!=""} {LIBDBG -Comdata 1 [append _Comdata "\n$iread"]}
  for {set i 0} {$i<4} {incr i} {
    if {[_rx "$_Dft(LoginRemind)" nocase]} {
      _write_Com "$login"
    } elseif [_rx "$_Dft(PasswordRemind)" nocase] {
      _write_Com "$password"
    } else {
      break
    }
    #after $_Dft(ReadGap)
    if {[set iread [_read_Com]]!=""} {LIBDBG -Comdata 1 [append _Comdata "\n$iread"]}
  }
   if {$_chantype == "serial" && [regexp {~ #} $_Comdata] != 1} {
    set _ret 0
   }
   # if {$_chantype == "adb" && [regexp {\$} $_Comdata] != 1} {
    # set _ret 0
   # }
	return $_ret
}
;
proc -_write_Com {} {}
itcl::body COM::_write_Com {cmd {noTrace 0}} {
	set _Dft(Counter) [format 0x%04x [incr _Dft(Counter)]]
	
  if {!$noTrace} {
    uplevel 1 [list LIBDBG -f 1 "[string repeat { } 6]$_Comname<$_Dft(Counter)>: {$cmd}"]
    #uplevel 1 [list LIBDBG -f 1 "  $_Comname<$_Dft(Counter)>"]
  }
	puts $_Comid $cmd
  flush $_Comid
}
;
# ����Ķ�һ��ͨ����ʱ����tempData
# һ�������tempData��_Comdataֻ�е�"Init��f -nocheck"ʱ��_read_Com��ֵ�Ż�ֱ��д��_Comdata
proc -_read_Com {} {}
itcl::body COM::_read_Com {} {
  update
  after 200
  return [_trim_Comdata [read $_Comid]]
}
;
# �ռ�������ͨ������_Comdata������3������»�����ռ�
# �����ռ���FastRead�ؼ���Ϣ �ڳ����ռ������ﵽMaxRead
# �����ռ���Ϣ��ĩ�У���ƥ��ReadEnd����ĩ�г���>�����
proc -_collect_Comdata {} {}
itcl::body COM::_collect_Comdata {{maxRead 5}} {
  set _Comdata ""
	for {set times 1} {$times<$maxRead} {incr times} {
    if {$times%20==0} {puts "  .COM._collect_Comdata: times=$times"}
    set tempData [_read_Com]
    #puts -nonewline "      itime={$times}"
    if {$tempData!=""} {
      if {[string index $_Comdata end]!="\n"} {append _Comdata "\n"}
      append _Comdata "$tempData"
      set charEnd [string trimright [lindex [split [string trim $tempData \n] \n] end]]
      set matchFast [regexp $_Dft(RegFastRead) $tempData]
      set matchEnd  [regexp $_Dft(RegReadEnd) $charEnd]
      #puts "\n  \[regexp {$_Dft(RegReadEnd)} {$charEnd}] = $matchEnd"
      #if {$matchFast || ($matchEnd && ([llength $charEnd]>$cmdLen))} {break}
      if {$matchFast || $matchEnd} {break}
    }
    after $_Dft(ReadGap)
	}
  #append _Comdata [_read_Com]      ;# ����ٱ����ռ�һ��
  set _Comdata [string trim $_Comdata]
}
;
;# ����������������յ���ĩ�����ݣ�ͨ��ƥ����ж��Ƿ�ƥ���ϣ� 
proc -_rx {} {}
itcl::body COM::_rx {match {nocase ""}} {
	set dataEnd [lindex [split $_Comdata "\n"] end]
  if {$nocase!=""} {
    return [string match -nocase "*$match*" $dataEnd]
  } else {
    return [string match "*$match*" $dataEnd]
  }
}
;
# COM com1; com1 _init ...; f "1"  ;# => puts cmd "1" to com1
# COM com2; com2 _init ...; f "2"  ;# => puts cmd "2" to com2
# f -com1 "3 x y" ;f "4"            ;# => puts cmd "3 x y" to com1; puts cmd "4" to com1
# f "-com2 5\t"                   ;# => puts cmd "-com2 5\t" to com1   
# proc -f {} {}
# itcl::body COM::f {cmd1 {cmd2 "<undefined>"}} {
  # LIBDBG ""
  # if {$cmd2 != "<undefined>"} {
    # set cmdSend $cmd2
    # set cmdOpt  $cmd1
  # } else {
    # set cmdSend $cmd1
    # set cmdOpt  ""
  # }
  
  # if {[set sId [lsearch -regexp $cmdOpt {^-[^=]+$}]] > -1} {
    # set comThis [lindex $cmdOpt $sId]
  # } else {
    # if {![uplevel 1 {info exists this}]} {
      # LIBDBG "!\[uplevel 1 {info exists this}"
      # set comThis $::COM_This
    # } else {
      # set comThis [uplevel 1 {set this}]
      # LIBDBG "\[uplevel 1 {set this}]=$comThis"
    # }
  # }
  # if {[itcl::find objects [::itclx::_nmspFull $comThis] -isa ::COM]!=""} {set ::COM_This $comThis}
  # if {$cmd2 != "<undefined>"} {
    # set opt [f_getOpt $cmd1 -*]
    # set obj [::itclx::_nmspFull $opt]
    # if {[itcl::find objects $obj -isa ::COM]!=""} {set ::COM_This $obj}
  # }
  # return [f_3op "{[$::COM_This f $cmdOpt $cmdSend]}==1" ?$::TSPASS: $::TSFAIL]
# }
# ;

# ���ݴ������ͷ�ʽ
set COM::fExpl(f) {
#�﷨: f ?cmdOpt? cmdSend
#˵��: �������������Ҫ���ڲ��������С�ͨ��::COM_This���������ֵ�ǰobj��
#      ��kc/kt�л����[$obj This]���л������̳�����::*_This��
#      ������Ȼ���ռ����(��ʱȥ��ͨ����ֱ�������Զ���������򳬳���������)
#����: cmdSend  �·�����
#      cmdOpt  ѡ��
#      -maxRead=*  �ռ��������������(Լ0.1sÿ��)�����ֻ��Ч��_MaxReadMax
#      -wait       txǰ�ȴ�waitTime��
#      -waitRead   rxǰ�ȴ�waitRead��
#      -expl=*     (����)ע��(rx���ٴ�ӡʱ��ǰ׺)
#      -nocheck    (����)��������������ʱ�·�������Ӳ�Ե�0.3s���ͨ��������
#      -noTrace    (����)txʱ�����ٴ�ӡ
#      -noPrint    (����)rxʱ�����ٴ�ӡ
#exam: f "-maxRead=10 -waitRead=1" xxx
}
proc -f {} {}
itcl::body COM::f {cmd1 {cmd2 "<undefined>"}} {
  puts "cmd1=$cmd1,$cmd2"
  if {$cmd1 == "-?"} {return [string trim [set ::COM::fExpl(f)]]}
  LIBDBG ""
  if {$cmd2 != "<undefined>"} {
    set cmdSend $cmd2
    set cmdOpt  $cmd1
  } else {
    set cmdSend $cmd1
    set cmdOpt  ""
  }
  puts "cmd2=$cmd1,$cmd2"
  set obj $::COM_This
  #set retryTimes [f_getOpt $cmdOpt -retryTimes=* 1]
  #if {$retryTimes==""} {set retryTimes 1}
  
  
  #set ::COM_This $this    ;# ���෽���в���ֱ�ӵ��ö��󷽷�������������ʱ�����f���ٷ�װһ��fCmd��
  #if {$_IfInitSuccess!=1} {
  #  return [puts "  {$this}δ��ʼ����½�ɹ������������������·�{$cmd}"]
  #}
  #�����ͨ���ڲ�����Ϣ������Ӱ��ô������
  if {[catch {set comdata [$obj _read_Com]} err]} {
    LIBDBG -f 1 "���������ͨ���ڲ�����Ϣ����error={$err}"
  } elseif {$comdata!=""} {
    LIBDBG -f 1 "\n[string repeat - 80]\n\"$comdata\"\n[string repeat - 80]"
  }
	;
  # if {$_chantype == "serial"} {
    # $obj _write_Com "\n"
    # if {[catch {set comdata [$obj _read_Com]} err]} {
    # LIBDBG -f 1 "���������ͨ���ڲ�����Ϣ����error={$err}"
    # } elseif {$comdata!="" &&} {
    # LIBDBG -f 1 "\n[string repeat - 80]\n\"$comdata\"\n[string repeat - 80]"
    # }
  # }
  
  # ��������������������ء�  #ע��ȡ�����Ի��� yjw:2015/05/05
  
  puts "fcmd=$cmdSend"
  
  
	if {![catch {$obj _tx $cmdOpt $cmdSend} err_tx]} {
    if {$_chantype == "adb" ||$_chantype == "ssh" || $_chantype == ""} {
    return $::TSPASS
    } elseif {[regexp {~ #} $_Comdata] == 1} { 
     return $::TSPASS
    }
    # if {[$obj cget -_Comdata]!=""} {return $::TSPASS}
    # LIBDBG -f 1 " [$obj cget -_Comname]ͨ����ȡֵΪ{}�����Ե�(1/1)��"
    # if {![catch {$obj _tx $cmdOpt $cmdSend} err_tx2]} {return $::TSPASS}
    # append err_tx "\n  err_tx2={$err_tx2}"
  }
  
  LIBDBG -f 1 " ��[$obj cget -_Comname]ͨ���쳣���������޸����������� ��err_tx={$err_tx}"
    lassign [$obj cget -_DstInit] dstName dstLoginLs
  
  if {$_chantype == "serial"} {
    set _i 0
    while {$_i < 30} {
      if {[$obj _login $dstLoginLs]==1} {
          LIBDBG -f 1 " �����µ�¼�ɹ��������ظ��������"
          $obj _tx $cmdOpt "\n"
          if [catch {$obj _tx $cmdOpt $cmdSend} err_tx] {
          LIBDBG -f 1 " �����µ�¼����������ʧ�ܡ�"
          return $::TSFAIL
          } else {
          return $::TSPASS
        }
      }
      LIBDBG -f 1 " �����µ�¼ʧ�ܡ�"
      incr _i
      after 500
     }
    }
  if {[$obj _init $dstName $dstLoginLs 1] != $::SUC} {
    LIBDBG -Comdata 1 " ��[$obj cget -_Comname]�޸�ͨ��  ʧ��!!!��"
    return $::TSFAIL
  }
	
  if [catch {$obj _tx $cmdOpt $cmdSend} err_tx] {
    LIBDBG -f 1 " ��[$obj cget -_Comname]�����޸�����������ʧ�ܡ�"
    return $::TSFAIL
  } else {
	#if {$_chantype == "adb" && [adb_root] !=1} {return $::TSFAIL}
    return $::TSPASS
  }
}
;
;# �������� cmd1������"{-maxRead=2 -readGap=100 -nocheck -noPrint} ls"
proc -_tx {} {}
itcl::body COM::_tx {cmd1 {cmd2 "<undefined>"}} {
	LIBDBG ""
  if {$cmd2 != "<undefined>"} {
    set cmdSend $cmd2
    set cmdOpt  $cmd1
  } else {
    set cmdSend $cmd1
    set cmdOpt  ""
  }

  set nocheck [f_3op "{[f_getOpt $cmdOpt -nocheck]}!={}" ?1: 0]  ;# ����������
  #set readGap [f_getOpt $cmdOpt -readGap=* 100]
  set maxRead [f_getOpt $cmdOpt -maxRead=* $_Dft(MaxRead)]
  if {$maxRead > $_MaxReadMax} {set maxRead $_MaxReadMax}
  
  set noTrace [f_3op "{[f_getOpt $cmdOpt -noTrace]}!={}" ?1: 0]  ;# txʱ������
  set noPrint [f_3op "{[f_getOpt $cmdOpt -noPrint]}!={}" ?1: 0]  ;# rxʱ����ӡ
  set expl [f_getOpt $cmdOpt -expl=* ""]    ;# ע��

  set waitTime [f_getOpt $cmdOpt -wait=* 0.0]
  set waitRead [f_getOpt $cmdOpt -waitRead=* 0.0]
  #if {![string is double $waitTime]} {set waitTime 0.0}
  #if {![string is double $waitTime]} {set waitRead 0.0}
  
  LIBDBG "maxRead=$maxRead nocheck=$nocheck waitRead=$waitRead waitTime=$waitTime"
  
  if {$waitTime>0.3} {puts "       ... �����·�����ǰwait ${waitTime}s"}
  after [format "%.0f" [expr 1000*$waitTime]]
	_write_Com $cmdSend $noTrace
	if {$nocheck} {
		after 300 ; flush $_Comid ; LIBDBG -Comdata 1 [set _Comdata [_read_Com]]
    return 1
	}
	#
  
  if {$waitRead>0.3} {puts "       ... ���ζ�ȡǰwait ${waitRead}s"}
  after [format "%.0f" [expr 1000*$waitRead]]
  _collect_Comdata $maxRead
  if {!$noPrint && $_Comdata!=""} {     ;# 
    if {$expl != ""} {set dataPre "{$expl} : "} else {set dataPre ""}
    LIBDBG -Comdata 1 "[string repeat { } 6]$_Comname<Read>  : $dataPre{$_Comdata}"
  }
	if {$_Comdata==""} {return 0} else {return 1}
}
;


proc COM_END {} {
}
namespace eval COM {
  namespace export f
}
namespace import COM::*
puts "Success for load dvCOM.tcl"
  

#��plink.exe�򿪵Ľ��̣��رչܵ������ر�tcl��������ý����Դ��ڣ��˴�����ʱ��ɱ1��
f_KillProcess -name plink.exe


