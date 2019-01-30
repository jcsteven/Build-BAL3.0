#!/bin/bash
# -------------------------------------------------------
# Automatic preparation script for rtk_openwrt
# JC Yu,     Novenber 26,2015
# -------------------------------------------------------
# IMPORTANT:
#   When use: './<this script file>  '
# -------------------------------------------------------
TODAY=`date +"%Y-%m%d-%H%M"`
source build_comm-BAL.sh

echo "BALSRC_ZIPNAME=${BALSRC_ZIPNAME}"
echo "SDK_FILE=${SDK_FILE}"
echo "PATCH_FILENAME=${PATCH_FILENAME}"



[ -d $BLOG_DIR_WK ] || mkdir $BLOG_DIR_WK
s_time=$(date +%s)
echo "==============================================================================" |  tee -a $Record_File
echo ".............................................................................." |  tee -a $Record_File
echo "Start:Prepare :${TODAY}=> ${ONL_DIR}-BAL}" | tee -a $Record_File

#--- Check out the specified ONL code from git Hub
#TO_UPDATE_ONL="y"
if [[ "${TO_UPDATE_ONL}" == "y" ]]; then
	git clone ${ONL_GIT_NAME} -b ${ONL_GIT_B} ./${ONL_NAME}
	#cd ./${ONL_NAME}
	#git checkout ${CMM_ID}
	#cd ..

fi


#----Prepare workspace for BAL
TO_PREPARE_BAL="y"
if [[ "${TO_PREPARE_BAL}" == "y" ]]; then
	if [ ! -d $BROADCOM_DOWNLOAD_DIR ]; then
	   echo $LINENO "missing ${BROADCOM_DOWNLOAD_DIR}" |  tee -a $Record_File
	   exit -1
	fi

	if [ ! -d ${EDGECORE_DOWNLOAD_DIR} ]; then
	   echo $LINENO "missing ${EDGECORE_DOWNLOAD_DIR}" |  tee -a $Record_File
	   exit -1
	fi

	if [ ! -d ${ONL_DIR} ]; then
	   echo $LINENO "missing ${ONL_DIR}" |  tee -a $Record_File
	   exit -1
	fi

	if [ ! -f ${BROADCOM_DOWNLOAD_DIR}/${BALSRC_ZIPNAME} ]; then
	   echo $LINENO "missing ${BROADCOM_DOWNLOAD_DIR}/${BALSRC_ZIPNAME}" |  tee -a $Record_File
	   exit -1
	fi

	if [ ! -f "${BROADCOM_DOWNLOAD_DIR}/${SDK_FILE}" ]; then
	   echo $LINENO "missing ${BROADCOM_DOWNLOAD_DIR}/${SDK_FILE}" |  tee -a $Record_File
	   exit -1
	fi

	if [ ! -f "${EDGECORE_DOWNLOAD_DIR}/${PATCH_FILENAME}" ]; then
	   echo $LINENO "missing ${BROADCOM_DOWNLOAD_DIR}/${PATCH_FILENAME}" |  tee -a $Record_File
	   exit -1
	fi

	
	echo "1. Prepare  BAL "
    mkdir -p ./${BAL_NAME}
	#unzip BAL src
	#unzip ${BROADCOM_DOWNLOAD_DIR}/${BALSRC_ZIPNAME} -d ./${BAL_NAME}
	tar zxf ${BROADCOM_DOWNLOAD_DIR}/${BALSRC_ZIPNAME} -C ./${BAL_NAME} --strip-components=1
  
  
	#copy SDK
	cp ${BROADCOM_DOWNLOAD_DIR}/${SDK_FILE}  ./${BAL_NAME}/switch_sdk/${SDK_VERSION}/.

	# Patch to origin BAL :
	#chmod -R 744 ./${BAL_NAME}
	cd  ./${BAL_NAME}
	cat ${EDGECORE_DOWNLOAD_DIR}/${PATCH_FILENAME} | patch -p1
	cd ..
fi

#TO_ONL_LINK="y"
if [[ "${TO_ONL_LINK}" == "y" ]]; then
	cd ${ONL_DIR}

	#Create the link to the kernel source:
	echo "BAL_NAME=${BAL_NAME}"
	cd ./${BAL_NAME}/bcm68620_release
	mkdir -p ./asfvolt16/kernels
		cd ./asfvolt16/kernels
		ln -s ../../../../packages/base/amd64/kernels/kernel-4.14-lts-x86-64-all/builds/jessie/linux-4.14.49 linux-4.14.49
		ln -s ../../../../packages/base/any/kernels/archives/linux-4.14.49.tar.xz linux-4.14.49.tar.xz
		ln -s ../../../../packages/base/any/kernels/4.14-lts/configs/x86_64-all/x86_64-all.config x86_64-all.config
		cd ../..
	cd ../..

fi

cd  ${PPWW}


e_time=$(date +%s)
elap_s=$((e_time-s_time))
ss=$((elap_s%60))
mm=$(((elap_s/60)%60))
hh=$((elap_s/3600))
echo "==============================================================================" | tee -a $Record_File
echo "End  :Prepare :${TODAY}=> ${ONL_DIR}-BAL}" | tee -a $Record_File
echo "Build total time: $hh:$mm:$ss" | tee -a $Record_File
echo "==============================================================================" | tee -a $Record_File

