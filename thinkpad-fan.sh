#!/bin/bash

INTERVAL=5
AVG_COUNT=5         # усреднение по 5 измерениям
HYST_TEMP=3         # гистерезис для температуры
temps=()

# Поиск датчиков
CPU_TEMP_FILE=""
for f in /sys/class/hwmon/hwmon*/name; do
    if grep -q "coretemp" "$f"; then
        CPU_TEMP_FILE="$(dirname "$f")/temp1_input"
        break
    fi
done

NVME_TEMP_FILE=""
for f in /sys/class/hwmon/hwmon*/name; do
    if grep -q "nvme" "$f"; then
        NVME_TEMP_FILE="$(dirname "$f")/temp1_input"
        break
    fi
done

if [[ ! -f "$CPU_TEMP_FILE" ]]; then
    echo "Ошибка: не найден датчик CPU."
    exit 1
fi

get_temp() {
    [[ -f "$1" ]] || { echo 0; return; }
    echo $(( $(cat "$1") / 1000 ))
}

get_fan_level() {
    local t=$1
    if (( t < 50 )); then echo 0
    elif (( t < 55 )); then echo 1
    elif (( t < 60 )); then echo 2
    elif (( t < 65 )); then echo 3
    elif (( t < 70 )); then echo 4
    elif (( t < 75 )); then echo 5
    elif (( t < 80 )); then echo 6
    else echo 7
    fi
}

last_fan=-1
last_temp=0

while true; do
    cpu=$(get_temp "$CPU_TEMP_FILE")
    nvme=$(get_temp "$NVME_TEMP_FILE")
    cur=$(( cpu > nvme ? cpu : nvme ))

    # --- усреднение ---
    temps+=("$cur")
    if (( ${#temps[@]} > AVG_COUNT )); then
        temps=("${temps[@]:1}")
    fi
    sum=0
    for t in "${temps[@]}"; do sum=$((sum + t)); done
    avg=$(( sum / ${#temps[@]} ))
    # ------------------

    desired=$(get_fan_level "$avg")

    # --- гистерезис уровней ---
    if (( last_fan != -1 )); then
        # если температура изменилась мало → оставляем старый уровень
        if (( desired > last_fan )) && (( avg < last_temp + HYST_TEMP )); then
            desired=$last_fan
        fi
        if (( desired < last_fan )) && (( avg > last_temp - HYST_TEMP )); then
            desired=$last_fan
        fi
    fi
    # ---------------------------

    echo "level $desired" | sudo tee /proc/acpi/ibm/fan > /dev/null

    echo "CPU: ${cpu}°C | NVMe: ${nvme}°C | avg: ${avg}°C | Fan: $desired"

    last_fan=$desired
    last_temp=$avg

    sleep "$INTERVAL"
done
