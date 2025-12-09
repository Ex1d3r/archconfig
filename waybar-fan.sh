#!/bin/bash
# /usr/local/bin/waybar-fan.sh

# --- Поиск CPU датчика по лейблу "Package id" ---
CPU_TEMP_FILE=""

for dir in /sys/class/hwmon/hwmon*; do
    if grep -q "coretemp" "$dir/name" 2>/dev/null; then
        for label in "$dir"/temp*_label; do
            if [[ -f "$label" ]] && grep -q "Package id" "$label"; then
                CPU_TEMP_FILE="${label/_label/_input}"
                break
            fi
        done
    fi
done

FAN_FILE="/proc/acpi/ibm/fan"

# Проверка
if [[ ! -f "$CPU_TEMP_FILE" ]]; then
    echo "Ошибка: не найден валидный датчик CPU."
    exit 1
fi

# Температура
cpu_temp=$(( $(cat "$CPU_TEMP_FILE") / 1000 ))

# Уровень вентилятора
fan_level=$(grep 'level' "$FAN_FILE" | awk '{print $2}')

# Вывод
echo "龍 CPU: ${cpu_temp}°C | Fan: $fan_level"
