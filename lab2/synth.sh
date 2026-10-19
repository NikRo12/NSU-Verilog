#!/bin/bash
# Использование: ./synth.sh <top_модуль> <файл1.sv> [файл2.sv ...]
# Пример:        ./synth.sh basic_gates rtl/basic_gates.sv

if [ $# -lt 2 ]; then
    echo "Использование: ./synth.sh <top_модуль> <файл1.sv> [файл2.sv ...]"
    exit 1
fi

TOP="$1"; shift
LOG=build/synth_$TOP.log
mkdir -p build

yosys -q -l "$LOG" -p "read_verilog -sv $*; synth -top $TOP; stat" > /dev/null \
    || { echo "!!! Ошибка синтеза, смотри $LOG"; exit 1; }

# берём только последний блок статистики (работает и в старых, и в новых версиях Yosys)
STAT=$(awk '/Printing statistics/{buf=""} {buf=buf"\n"$0} END{print buf}' "$LOG")
CELLS=$(echo "$STAT" | grep -E '^ +([0-9]+ +)?\$[_a-z]' )

echo "=== Элементы в схеме $TOP ==="
echo "$STAT" | grep -E 'cells' | head -1
echo "$CELLS"

if [ -z "$CELLS" ]; then
    echo ">>> НЕ УДАЛОСЬ разобрать вывод синтеза, смотри $LOG"
    exit 1
elif echo "$CELLS" | grep -qE 'DFF|DLATCH|_SR|mem|MEM|dff|dlatch'; then
    echo ">>> ВНИМАНИЕ: найдена память (триггер/latch)!"
else
    echo ">>> OK: памяти (триггеров и latch) нет"
fi
