#!/bin/bash
shopt -s nullglob

success_count=0
fail_count=0
total_count=0

for file in "compile"/*.c; do
    total_count=$((total_count + 1))
    # echo "Trying: $file"
    ../../riscv32-ilp32-tcc -c "$file" -o /dev/null -w
    if [ $? -ne 0 ]; then
        ../../../tcc-diverge-point/tcc -c "$file" -o /dev/null -w 2>&1 1>/dev/null
        if [ $? -eq 0 ]; then
            echo "Failed: $file"
            fail_count=$((fail_count + 1))
        else
            echo "Both failed: $file"
        fi
    else
    	success_count=$((success_count + 1))
    fi
done

echo ""
echo "Total: $total_count"
if [ $fail_count -gt 0 ]; then
    echo "Failed: $fail_count   Success: $success_count"
    exit 1
else
    echo "PASS"
    exit 0
fi

