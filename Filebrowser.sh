#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
#=================================================
#       System Required: CentOS/Debian/Ubuntu
#       Description: Filebrowser Install
#       Version: 2.0.0
#       Author: vinew
#       Blog: https://vinew.cc/
#=================================================
file="/etc/filebrowser/"
filebrowser_bin="/etc/filebrowser/filebrowser"
filebrowser_db_file="/etc/filebrowser/database.db"
Info_font_prefix="\033[32m" && Error_font_prefix="\033[31m" && Info_background_prefix="\033[42;37m" && Error_background_prefix="\033[41;37m" && Font_suffix="\033[0m"

check_sys(){
	if [[ -f /etc/redhat-release ]]; then
		release="centos"
	elif cat /etc/issue | grep -q -E -i "debian"; then
		release="debian"
	elif cat /etc/issue | grep -q -E -i "ubuntu"; then
		release="ubuntu"
	elif cat /etc/issue | grep -q -E -i "centos|red hat|redhat"; then
		release="centos"
	elif cat /proc/version | grep -q -E -i "debian"; then
		release="debian"
	elif cat /proc/version | grep -q -E -i "ubuntu"; then
		release="ubuntu"
	elif cat /proc/version | grep -q -E -i "centos|red hat|redhat"; then
		release="centos"
    fi
	bit=`uname -m`
}
check_installed_status(){
	[[ ! -e ${filebrowser_bin} ]] && echo -e "${Error_font_prefix}[错误]${Font_suffix} filebrowser 没有安装，请检查 !" && exit 1
}
Download_filebrowser(){
	[[ ! -e ${file} ]] && mkdir "${file}" 
	if [[ ! -e ${filebrowser_db_file} ]]; then
    echo "请输入Filebrowser文件目录"
    read -p "(默认目录: /Cloud):" file_dir
    [ -z "${file_dir}" ] && file_dir="/Cloud"
    echo
    echo "---------------------------"
    echo "文件目录 = ${file_dir}"
    echo "---------------------------"
    echo
	[[ ! -e ${file_dir} ]] && mkdir -p "${file_dir}"
	echo "请输入Filebrowser用户名"
    read -p "(默认用户名: admin):" file_user
    [ -z "${file_user}" ] && file_user="admin"
    echo
    echo "---------------------------"
    echo "用户名 = ${file_user}"
    echo "---------------------------"
    echo
    echo "请输入Filebrowser密码"
    read -p "(默认密码: admin):" file_pw
    [ -z "${file_pw}" ] && file_pw="admin"
    echo
    echo "---------------------------"
    echo "密码 = ${file_pw}"
    echo "---------------------------"
    echo
    while true
    do
    dport=$(shuf -i 9000-19999 -n 1)
    echo -e "请输入Filebrowser服务端口[1-65535]"
    read -p "(默认端口: ${dport}):" port
    [ -z "$port" ] && port=${dport}
    expr ${port} + 1 &>/dev/null
    if [ $? -eq 0 ]; then
        if [ ${port} -ge 1 ] && [ ${port} -le 65535 ] && [ ${port:0:1} != 0 ]; then
            echo
            echo "---------------------------"
            echo "服务端口 = ${port}"
            echo "---------------------------"
            echo
            break
        fi
    fi
    echo -e "${Error_font_prefix}[错误]${Font_suffix} 请输入正确端口，端口范围 [1-65535]"
    done
	fi
	cd "/tmp"
	PID=$(ps -ef |grep "filebrowser" |grep -v "grep" |grep -v "init.d" |grep -v "service" |grep -v "filebrowser_install" |awk '{print $2}')
	[[ ! -z ${PID} ]] && kill -9 ${PID}
	[[ -e "Filebrowser.tar.gz" ]] && rm -rf "Filebrowser.tar.gz"
	
	if [[ $bit == "i386" || $bit == "i686" ]]; then
	filebrowser="linux-386-filebrowser.tar.gz"
    elif [[ $bit == "x86_64" ]]; then
	filebrowser="linux-386-filebrowser.tar.gz"
	else
		echo -e "${Error_font_prefix}[错误]${Font_suffix} 不支持 ${bit} !" && exit 1
	fi

    ver=$(curl -s https://api.github.com/repos/filebrowser/filebrowser/releases/latest | grep 'tag_name' | cut -d\" -f4)
	Filebrowser_download_link="https://github.com/filebrowser/filebrowser/releases/download/$ver/$filebrowser"
    
    if ! wget --no-check-certificate --no-cache -O "/tmp/Filebrowser.tar.gz" $Filebrowser_download_link; then
		echo -e "${Error_font_prefix}[错误]${Font_suffix} Filebrowser 下载失败 !" && exit 1
	fi

    mkdir Filebrowser
    tar zxf /tmp/Filebrowser.tar.gz -C /tmp/Filebrowser
	cp -f /tmp/Filebrowser/filebrowser ${filebrowser_bin}
	rm -rf /tmp/Filebrowser*
	[[ ! -e ${filebrowser_bin} ]] && echo -e "${Error_font_prefix}[错误]${Font_suffix} Filebrowser 解压失败或压缩文件错误 !" && exit 1
	chmod +x ${filebrowser_bin}
}
Service_filebrowser(){
	if [[ ! -e /etc/init.d/filebrowser ]]; then
	if [[ ${release} = "centos" ]]; then
	    if ! wget --no-check-certificate https://raw.githubusercontent.com/vinewx/script/master/requirement/filebrowser_centos -O /etc/init.d/filebrowser; then
			echo -e "${Error_font_prefix}[错误]${Font_suffix} Filebrowser服务 管理脚本下载失败 !" && exit 1
		fi
		chmod +x /etc/init.d/filebrowser
		chkconfig --add filebrowser
		chkconfig filebrowser on
	else
		if ! wget --no-check-certificate https://raw.githubusercontent.com/vinewx/script/master/requirement/filebrowser_debian -O /etc/init.d/filebrowser; then
			echo -e "${Error_font_prefix}[错误]${Font_suffix} Filebrowser服务 管理脚本下载失败 !" && exit 1
		fi
		chmod +x /etc/init.d/filebrowser
		update-rc.d -f filebrowser defaults
	fi
	fi
}
check_database(){
	if [[ ! -e ${filebrowser_db_file} ]]; then
	"$filebrowser_bin" -d "$filebrowser_db_file" config init
	"$filebrowser_bin" -d "$filebrowser_db_file" config set --address 0.0.0.0 --port ${port} --root ${file_dir}
	"$filebrowser_bin" -d "$filebrowser_db_file" users add ${file_user} ${file_pw} --perm.admin
	ip=$(curl -s ipinfo.io/ip)
	clear
	echo -e "
		访问地址: ${yellow}http://${ip}:${port}/$none

		文件上传目录：${green}${file_dir}

		用户名: ${Info_font_prefix}${file_user}${Font_suffix}

		密码: ${Info_font_prefix}${file_pw}${Font_suffix}

		"
	echo -e "${Info_font_prefix}[信息]${Font_suffix} Filebrowser 安装完成！"
    else
    clear
    echo -e "${Error_font_prefix}[信息]${Font_suffix} 更新成功！"
	fi
}
install_filebrowser(){
	if [[ -e ${filebrowser_bin} ]]; then
		echo && echo -e "${Error_font_prefix}[信息]${Font_suffix} 检测到 Filebrowser 已安装，是否继续安装(更新)？[y/N]"
		stty erase '^H' && read -p "(默认: n):" yn
		[[ -z ${yn} ]] && yn="n"
		if [[ ${yn} == [Nn] ]]; then
			echo && echo "已取消..." && exit 1
		fi
	fi
	Download_filebrowser
	Service_filebrowser
	check_database
	/etc/init.d/filebrowser start
	echo && echo -e " filebrowser 数据文件：${filebrowser_db_file} \n 使用说明：/etc/init.d/filebrowser start | stop | restart | status " && echo
}
uninstall_filebrowser(){
	check_installed_status
	echo && echo "确定要卸载 Filebrowser ? [y/N]"
	stty erase '^H' && read -p "(默认: n):" unyn
	[[ -z ${unyn} ]] && unyn="n"
	if [[ ${unyn} == [Yy] ]]; then
		PID=`ps -ef |grep "filebrowser" |grep -v "grep" |grep -v "init.d" |grep -v "service" |grep -v "filebrowser_install" |awk '{print $2}'`
		[[ ! -z ${PID} ]] && kill -9 ${PID}
		if [[ ${release} = "centos" ]]; then
			chkconfig --del filebrowser
		else
			update-rc.d -f filebrowser remove
		fi
		rm -rf ${filebrowser_bin}
		rm -rf ${filebrowser_conf_file}
		rm -rf /etc/init.d/filebrowser
		[[ ! -e ${filebrowser_bin} ]] && echo && echo -e "${Info_font_prefix}[信息]${Font_suffix} Filebrowser 卸载完成 !" && echo && exit 1
		echo && echo -e "${Error_font_prefix}[错误]${Font_suffix} Filebrowser 卸载失败 !" && echo
	else
		echo && echo "卸载已取消..." && echo
	fi
}
check_sys
while :; do
	clear
    echo
	echo -e "${Info_font_prefix}........... Filebrowser 一键脚本 ...........${Font_suffix}"
	echo
	echo -e "${Info_font_prefix}[Author]${Font_suffix}: vinewx"
	echo
	echo -e "${Info_font_prefix}[github]${Font_suffix}: https://github.com/vinewx/script"
	echo
	echo " 1. 安装"
	echo
	echo " 2. 卸载"
	echo
	read -p "请选择[1-2]:" choose
	case $choose in
	1)
		install_filebrowser
		break
		;;
	2)
		uninstall_filebrowser
		break
		;;
	*)
		error
		;;
	esac
done
