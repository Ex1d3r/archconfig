#!/bin/bash
# /usr/local/bin/waybar-fan.sh

# Динамический поиск CPU датчика
CPU_TEMP_FILE=""
for f in /sys/class/hwmon/hwmon*/name; do
    if grep -q "coretemp" "$f"; then
        CPU_TEMP_FILE="$(dirname "$f")/temp1_input"
        break
    fi
done

FAN_FILE="/proc/acpi/ibm/fan"

# Проверка, что файл существует
if [[ ! -f "$CPU_TEMP_FILE" ]]; then
    echo "Ошибка: не найден датчик CPU."
    exit 1
fi

# Чтение температуры CPU
cpu_temp=$(( $(cat "$CPU_TEMP_FILE") / 1000 ))

# Чтение уровня вентилятора
fan_level=$(grep 'level' "$FAN_FILE" | awk '{print $2}')

# Вывод для waybar
echo "龍 CPU: ${cpu_temp}°C | Fan: $fan_level"
