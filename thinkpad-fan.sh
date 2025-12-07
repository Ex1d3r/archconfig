#!/bin/bash
# ------------------------------------------------------------------
# Авто-регулировка вентилятора ThinkPad по CPU/NVMe
# Работает с /proc/acpi/ibm/fan, полностью заменяет thinkfan
# ------------------------------------------------------------------

# Период проверки (секунды)
INTERVAL=5

# Динамический поиск CPU датчика
CPU_TEMP_FILE=""
for f in /sys/class/hwmon/hwmon*/name; do
    if grep -q "coretemp" "$f"; then
        CPU_TEMP_FILE="$(dirname "$f")/temp1_input"
        break
    fi
done

# Динамический поиск NVMe датчика
NVME_TEMP_FILE=""
for f in /sys/class/hwmon/hwmon*/name; do
    if grep -q "nvme" "$f"; then
        NVME_TEMP_FILE="$(dirname "$f")/temp1_input"
        break
    fi
done

# Проверка, что CPU датчик найден
if [[ ! -f "$CPU_TEMP_FILE" ]]; then
    echo "Ошибка: не найден датчик CPU."
    exit 1
fi

# Функция получения температуры в градусах
get_temp() {
    local file="$1"
    if [[ -f "$file" ]]; then
        local temp_raw
        temp_raw=$(cat "$file")
        echo $((temp_raw / 1000))
    else
        echo 0
    fi
}

# Функция выбора уровня вентилятора по температуре
get_fan_level() {
    local temp=$1
    if (( temp < 50 )); then
        echo 0
    elif (( temp < 55 )); then
        echo 1
    elif (( temp < 60 )); then
        echo 2
    elif (( temp < 65 )); then
        echo 3
    elif (( temp < 70 )); then
        echo 4
    elif (( temp < 75 )); then
        echo 5
    elif (( temp < 80 )); then
        echo 6
    else
        echo 7
    fi
}

# Главный цикл
while true; do
    cpu_temp=$(get_temp "$CPU_TEMP_FILE")
    nvme_temp=$(get_temp "$NVME_TEMP_FILE")

    # Берем максимальную температуру CPU/NVMe
    max_temp=$(( cpu_temp > nvme_temp ? cpu_temp : nvme_temp ))

    fan_level=$(get_fan_level "$max_temp")

    # Устанавливаем уровень вентилятора
    echo "level $fan_level" | sudo tee /proc/acpi/ibm/fan > /dev/null

    # Отладка
    echo "CPU: ${cpu_temp}°C | NVMe: ${nvme_temp}°C | Fan level: $fan_level"

    sleep $INTERVAL
done
