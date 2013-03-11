@echo off
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: 功能: 监控SVN版本库项目,发现更新自动发送邮件通知 
:: 工具: 
::			subversion	www.sourceforge.net/projects/win32svn
::			blat		www.blat.net
:: 历史:
::		v1.00	2012-12-12	Dennis	create project
::		v1.01	2012-12-13	Dennis	修改邮件附件发送为文本内容发送 
::									增加自动更新配置文件中的版本号 
::		v1.02	2012-12-14	Dennis	增加单件实现
::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
setlocal enabledelayedexpansion

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: run as a singleton
set "app_title=pmt"
tasklist /v | find "%app_title%">nul && goto _EXIT
title %app_title%

:: 切换到批处理文件所在目录 
cd /d %~dp0

set app_log=pmt.log
set log_file=svnlog.txt
set cfg_path=%cd%\conf
set cfg_file=%cfg_path%\*.conf
echo %date% %time% start application >> %app_log%

set /a prj_index=1
for /f "tokens=* delims=" %%i in ('dir /s /b /a-d "%cfg_file%"') do (
	echo call :_CONF_INFO "%%i" !prj_index! >> %app_log%
	call :_CONF_INFO "%%i" !prj_index!
	set prj_!prj_index!_file="%%i"
	set /a prj_index+=1
)

set /a prj_count=!prj_index!-1
echo Monitor %prj_count% project >> %app_log%
set /a last_rev=0

set "pmt_mail=example@gmail.com"
set "f=-f %pmt_mail%"
set "c=-charset GBK"
:_CHK_REV
:: Check svn revision
:: Send mail by blat when there exist new revision in svn repository
for /l %%i in (1,1,%prj_count%) do (
	echo call :_SVN_LAST_REV !prj_%%i_url! last_rev >> %app_log%
	call :_SVN_LAST_REV !prj_%%i_url! last_rev
	if !last_rev! GTR !prj_%%i_rev! (
		echo !prj_%%i_url! !last_rev! ^> !prj_%%i_rev!
		set /a prj_%%i_rev+=1
		echo project: !prj_%%i_name! > %log_file%
		echo url    : !prj_%%i_url! >> %log_file%
		svn log !prj_%%i_url! -r !last_rev!:!prj_%%i_rev! >> %log_file%

		echo send mail to !prj_%%i_mail! >> %app_log%

		set "s=-s "[svn monitor] !prj_%%i_name! update""
		set "t=-t !prj_%%i_mail!"
		blat %log_file% !s! %f% !t! %c%
		set prj_%%i_rev=!last_rev!

		:: 更新配置文件版本号 
		:: sed的组括号为批处理特殊字符,需使用^转义 
		:: 如果不转义, 可以采用call的方式 
		:: call :_UPDATE_REV !prj_%%i_file! !last_rev!
		sed -i '/rev=/{s/\^(rev=\^)[0-9]\+/\1!last_rev!/}' !prj_%%i_file!
	)
)
:: sleep 5 seconds
ping -n 5 127.1 > nul	
goto :_CHK_REV

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::exit
:_EXIT
pause
exit /b 0


::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::Function

:_CONF_INFO <config file> <project index>
:: Get configure info
:: usebackq 用以解决文件路径中包含空格的情况 
FOR /F "usebackq tokens=1,2* delims==" %%i in (%1) do (
	set "prj_%2_%%i=%%j"
)
GOTO :EOF

:_SVN_LAST_REV <url> [retvar]
:: Get lastest revision
for /f "skip=7 delims=: tokens=2" %%i in ('svn info %1') do (
	(if %2. neq . (set/a%2=%%i)else echo %%i)&goto :eof
)
GOTO :EOF

REM :_UPDATE_REV <file> <revision>
REM :: Update revision
REM sed -i '/rev=/{s/\(rev=\)[0-9]\+/\1%2/}' %1
REM GOTO :EOF
