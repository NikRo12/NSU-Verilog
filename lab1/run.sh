#!/bin/bash
# Использование: ./run.sh <тестбенч.sv> <файл1.sv> [файл2.sv ...]
# Пример:        ./run.sh tb/tb_lab1.sv rtl/basic_gates.sv
# Имя верхнего модуля = имя файла тестбенча без расширения.

if [ $# -lt 2 ]; then
    echo "Использование: ./run.sh <тестбенч.sv> <файл1.sv> [файл2.sv ...]"
    echo "Пример:        ./run.sh tb/tb_lab1.sv rtl/basic_gates.sv"
    exit 1
fi

TB="$1"
TOP=$(basename "$TB" .sv)
TOP=$(basename "$TOP" .v)

mkdir -p build

echo "=== Компиляция (top: $TOP) ==="
iverilog -g2012 -Wall -s "$TOP" -o build/sim.vvp "${@:2}" "$TB" || { echo "!!! Ошибка компиляции"; exit 1; }

echo "=== Запуск ==="
( cd build && vvp sim.vvp ) || { echo "!!! Ошибка запуска"; exit 1; }

echo "=== Файлы волн ==="
ls build/*.vcd 2>/dev/null || echo "(.vcd не создан - проверь \$dumpfile в тестбенче)"
