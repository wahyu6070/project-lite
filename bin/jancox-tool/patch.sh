#!/system/bin/sh
# Jancox-Tool-Android
# by wahyu6070

ch_con(){
		chcon -h u:object_r:system_file:s0 "$1" || sedlog "Failed chcon $1"
		}
		
MODULE_INSTALL(){
	local DIR_BACKUP=$LITEGAPPS/backup
	local packagename=`getp package.name $MODULE_TMP/litegapps-prop`
	local packageid=`getp package.id $MODULE_TMP/litegapps-prop`
	local packagesize=`getp package.size $MODULE_TMP/litegapps-prop`
	

	# remove file and backup
	for Y in $SYSTEM $PRODUCT $SYSTEM_EXT; do
     for G in app priv-app; do
        for P in $(cat $MODULE_TMP/list-rm); do
           if [ -d $Y/$G/$P ]; then
               #[ ! -d $MODPATH/system/etc/kopi/modules/litegapps ] && mkdir -p $MODPATH/system/etc/kopi/modules/litegapps
               [ ! -d $KOPIMOD ] && mkdir -p $KOPIMOD
               print "-+ Removing  $Y/$G/$P"
               del $Y/$G/$P
             
           fi
        done
     done
	done

	# Copying files
	print "- Copying <$MODULE_TMP/system> to <$MODPATH/system>"
	cp -rdf $MODULE_TMP/system/system/* $SYSTEM/ 2>/dev/null
	
	
	print "- Copying <$MODULE_TMP/product> to <$MODPATH/product>"
	cp -rdf $MODULE_TMP/system/product/* $PRODUCT/ 2>/dev/null
	
	
	print "- Copying <$MODULE_TMP/system_ext> to <$MODPATH/system_ext>"
	cp -rdf $MODULE_TMP/system/system_ext/* $SYSTEM_EXT/ 2>/dev/null
	
	
	print "- Copying <$MODULE_TMP/vendor> to <$MODPATH/vendor>"
	cp -rdf $MODULE_TMP/system/vendor/* $VENDOR/ 2>/dev/null
	
	
	if [ $packageid = "SetupWizard" ]; then
		#add buildprop config
		print "-+ Add config Setup Wizard in build.prop"
		#SETUP_WIZARD
	fi
}
#PATH
jancox=`dirname "$(readlink -f $0)"`
#functions
. $jancox/bin/functions
bin=$jancox/bin/$ARCH32

SYSTEM=$jancox/editor/system/system
PRODUCT=$jancox/editor/product
SYSTEM_EXT=$jancox/editor/system_ext
VENDOR=$jancox/editor/vendor

SDK=`getp ro.build.version.sdk $SYSTEM/build.prop`


print "| SDK : $SDK";
print "- installing package"

TMPDIR=$jancox/files/tmpdir
MODULES=$jancox/files/modules
MODULE_TMP=$TMPDIR/module_tmp

if [ -d $MODULES ] && ! rmdir $MODULES 2>/dev/null; then
	print "- Modules Detected"
	for LIST_MODULES in $(find $MODULES -type f); do
		if [ -f $LIST_MODULES ]; then
		print "- Extracting <$LIST_MODULES>"
			del $MODULE_TMP
			cdir $MODULE_TMP
			print "- Unzip <$LIST_MODULES> to <$MODULE_TMP>"
			unzip -o $LIST_MODULES -d $MODULE_TMP >/dev/null
			
			if [ -f $MODULE_TMP/litegapps-prop ]; then
				MODULE_INSTALL
				#print "- Remove $LIST_MODULES"
				#del $LIST_MODULES
			else
				print "! Failed installing module <$(basename $LIST_MODULES)> skipping"
				continue
			fi
			del $MODULE_TMP
		fi
	done
fi

print "- Update Permissions"
for G1 in $SYSTEM $PRODUCT $SYSTEM_EXT; do
	for G2 in priv-app app; do
		for G3 in $(ls -1 $G1/$G2); do
			if [ -d $G1/$G2/$G3 ]; then
			#print "- set chmod 755 dir $G1/$G2/$G3"
			chmod 755 $G1/$G2/$G3
			#print "- set selinux $G1/$G2/$G3"
			ch_con $G1/$G2/$G3
			chown 0:0 $G1/$G2/$G3
			fi
			if [ -f $G1/$G2/$G3/${G3}.apk ]; then
			#print "- set chmod 644 file $G1/$G2/$G3/${G3}.apk"
			chmod 644 $G1/$G2/$G3/${G3}.apk
			#print "- set selinux file $G1/$G2/$G3/${G3}.apk"
			ch_con $G1/$G2/$G3/${G3}.apk
			chown 0:0 $G1/$G2/$G3/${G3}.apk
			fi
		done
	done
done

for G1 in $SYSTEM/etc $PRODUCT/etc $SYSTEM_EXT/etc; do
	for G2 in permissions sysconfig; do
		for G3 in $(ls -1 $G1/$G2); do
			if [ -f $G1/$G2/$G3 ]; then
			#print "- set chmod 644 file $G1/$G2/$G3"
			chmod 644 $G1/$G2/$G3
			#print "- set selinux file $G1/$G2/$G3"
			ch_con $G1/$G2/$G3
			chown 0:0 $G1/$G2/$G3
			fi
		done
	done
done

for G1 in $SYSTEM/media $PRODUCT/media $SYSTEM_EXT/media; do
			BOOTANIM=$G1/bootanimation.zip
			if [ -f $G1/bootanimation.zip ]; then
				print "- Install bootanimation $BOOTANIM"
				cp -pf $jancox/files/bootanimation.zip  $BOOTANIM
				print "- set chmod 644 file $BOOTANIM"
				chmod 644 $BOOTANIM
				print "- set selinux file $BOOTANIM"
				ch_con $BOOTANIM
				chown 0:0 $BOOTANIM
				break
			fi
done


list_rm="
Updater
Jelly
messaging
Twelve
Recorder
Gallery2
Glimpse
ExactCalculator
Etar
DeskClock
Camelot
Dialer
Contacts
Stk
Seedvault
MatLog
"

print "- Debloating"
for J in $list_rm; do
for G1 in $SYSTEM $PRODUCT $SYSTEM_EXT; do
	for G2 in priv-app app; do
			if [ -d $G1/$G2/$J ]; then
			print "- Remove file $G1/$G2/$J"
			rm -rf  $G1/$G2/$J 
			fi
	done
done
done
