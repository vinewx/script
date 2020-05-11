#!/usr/bin/env bash
#============================================
#       System Required: Linux/Unix
#       Description: GoCC Install
#       Version: 1.0.0
#       Author: vinew
#       Blog: https://vinew.cc/
#============================================
file="/usr/local/share/gocc"
gocc_bin="/usr/bin/gocc"
gocc_config="/usr/local/share/gocc/config"
gocc_dictionary="/usr/local/share/gocc/dictionary"
Info_font_prefix="\033[32m" && Error_font_prefix="\033[31m" && Info_background_prefix="\033[42;37m" && Error_background_prefix="\033[41;37m" && Font_suffix="\033[0m"

check_installed_status(){
	[[ ! -e ${gocc_bin} ]] && echo -e "${Error_font_prefix}[错误]${Font_suffix} gocc 没有安装，请检查 !" && exit 1
}
Download_gocc(){
	cd "/tmp"
	[[ -e "gocc.tar.gz" ]] && rm -rf "gocc.tar.gz"
	
	if [[ $bit == "i386" || $bit == "i686" ]]; then
	gocc="gocc-linux-386.tar.gz"
	elif [[ $bit == "x86_64" ]]; then
	gocc="gocc-linux-amd64.tar.gz"
	elif [[ $bit == "aarch64" ]]; then
	gocc="gocc-linux-arm64.tar.gz"
	else
		echo -e "${Error_font_prefix}[错误]${Font_suffix} 不支持 ${bit} !" && exit 1
	fi

	ver=$(curl -s https://api.github.com/repos/vinewx/gocc/releases/latest | grep 'tag_name' | cut -d\" -f4)
	gocc_download_link="https://github.com/vinewx/gocc/releases/download/$ver/$gocc"
	
	if ! wget --no-check-certificate --no-cache -O "/tmp/gocc.tar.gz" $gocc_download_link; then
		echo -e "${Error_font_prefix}[错误]${Font_suffix} gocc 下载失败 !" && exit 1
	fi

	if ! wget --no-check-certificate --no-cache -O "/tmp/gocc.zip" https://github.com/vinewx/gocc/archive/master.zip; then
		echo -e "${Error_font_prefix}[错误]${Font_suffix} gocc配置文件 下载失败 !" && exit 1
	fi

	mkdir -p gocc ${file}
	tar zxf /tmp/gocc.tar.gz -C /tmp/gocc
	cp -f /tmp/gocc/gocc ${gocc_bin}
	unzip -j -o gocc.zip "*master/config/*" -d ${gocc_config}
	unzip -j -o gocc.zip "gocc-master/dictionary/*" -d ${gocc_dictionary}
	rm -rf /tmp/gocc*
	[[ ! -e ${gocc_bin} ]] && echo -e "${Error_font_prefix}[错误]${Font_suffix} gocc 解压失败或压缩文件错误 !" && exit 1
	chmod +x ${gocc_bin}
}
install_gocc(){
	if [[ -e ${gocc_bin} ]]; then
        clear
        echo
        echo -e "${Info_font_prefix}........... GoCC 一键脚本 ...........${Font_suffix}"
        echo
        echo -e "${Info_font_prefix}[Author]${Font_suffix}: vinewx"
        echo
        echo -e "${Info_font_prefix}[github]${Font_suffix}: https://github.com/vinewx/script"
        echo
        echo " 1. 确定"
        echo
        echo " 2. 取消"
        echo
        read -p "检测到 GoCC 已安装，是否继续安装(更新) ? [1-2]:" choose
        case $choose in
        1)
            Download_gocc
            ;;
        2)
            echo && echo "安装已取消..."  && echo && exit 1
            ;;
            *)
        error
        ;;
        esac
    else
        Download_gocc
    fi
    clear
	echo && echo -e "${Info_font_prefix}[信息]${Font_suffix} GoCC 安装完成！" && echo -e " 数据文件：${file} \n 使用说明：gocc --help " && echo
}
uninstall_gocc(){
	check_installed_status
	clear
	echo
	echo -e "${Info_font_prefix}........... GoCC 一键脚本 ...........${Font_suffix}"
	echo
	echo -e "${Info_font_prefix}[Author]${Font_suffix}: vinewx"
	echo
	echo -e "${Info_font_prefix}[github]${Font_suffix}: https://github.com/vinewx/script"
	echo
	echo " 1. 确定"
	echo
	echo " 2. 取消"
	echo
	read -p "确定要卸载 gocc ? [1-2]:" choose
	case $choose in
	1)
		rm -rf ${file}
		rm -rf ${gocc_bin}
		[[ ! -e ${gocc_bin} ]] && echo && echo -e "${Info_font_prefix}[信息]${Font_suffix} gocc 卸载完成 !" && echo && exit 1
		echo && echo -e "${Error_font_prefix}[错误]${Font_suffix} gocc 卸载失败 !" && echo
		;;
	2)
		echo && echo "卸载已取消..." && echo
		;;
	*)
		error
		;;
	esac
}
bit=`uname -m`
while :; do
	clear
	echo
	echo -e "${Info_font_prefix}........... GoCC 一键脚本 ...........${Font_suffix}"
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
		install_gocc
		break
		;;
	2)
		uninstall_gocc
		break
		;;
	*)
		error
		;;
	esac
done
