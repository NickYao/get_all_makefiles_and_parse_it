#!/bin/sh
set -e
if [ $# -gt 0 ]; then
    if [ $1 == debug ]; then
        set -x
    fi
fi
all_makefiles=$(find device/google/ -name 'Android.mk')
all_bps=$(find device/google/atv -name 'Android.bp')
rm -f makefiles.txt
rm -f mk_templates.txt bp_templates.txt

for f in $all_makefiles $all_bps
do
    filename=$(basename -- $f)
    ext=${f##*.}

    if [ ${ext} == "bp" ]; then
        count=$(rg -e '\w+\s+\{$' $f | wc -l)
        if [ $count -gt 0 ]; then
            rg -e '\w+\s+\{$' $f >> bp_templates.txt
            rg -w 'name' $f >> bp_templates.txt
            count=$(rg -e 'export_include_dirs|export_shared_lib_headers|export_static_lib_headers|export_header_lib_headers' $f | wc -l)
            if [ $count -gt 0 ]; then
                rg -e 'export_include_dirs|export_shared_lib_headers|export_static_lib_headers|export_header_lib_headers' $f >> bp_templates.txt
            fi
            echo $f >> makefiles.txt
        fi
    fi

    if [ ${ext} == "mk" ]; then
        count=$(rg -e 'include\s+\$\(BUILD_' $f | wc -l)
        if [ $count -gt 0 ]; then
            rg -e 'include\s+\$\(BUILD_' $f  >> mk_templates.txt
            rg -e 'LOCAL_MODULE\s*:=' $f >> mk_templates.txt
            count=$(rg -e 'LOCAL_EXPORT_C_INCLUDE_DIRS|LOCAL_EXPORT_SHARED_LIBRARY_HEADERS|LOCAL_EXPORT_STATIC_LIBRARY_HEADERS|LOCAL_EXPORT_HEADER_LIBRARY_HEADERS' $f|wc -l)
            if [ $count -gt 0 ]; then
                rg -e 'LOCAL_EXPORT_C_INCLUDE_DIRS|LOCAL_EXPORT_SHARED_LIBRARY_HEADERS|LOCAL_EXPORT_STATIC_LIBRARY_HEADERS|LOCAL_EXPORT_HEADER_LIBRARY_HEADERS' $f >> mk_templates.txt
            fi
            echo $f >> makefiles.txt
        fi
    fi
done

tmpfile=$(mktemp)
cat mk_templates.txt | cut -d : -f 1 | sort | uniq |  tee ${tmpfile}
cp ${tmpfile} mk_templates.txt
cat bp_templates.txt | cut -d : -f 1 | sort | uniq | cut -d '{' -f 1 | tee ${tmpfile}
cp ${tmpfile} bp_templates.txt
sed -i '/package/d' bp_templates.txt
sed -i '/notice/d' bp_templates.txt
sed -i '/license/d' bp_templates.txt
rm ${tmpfile}

