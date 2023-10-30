#!/bin/bash

# Задаем переменные для подсчета количества успешных и неуспешных тестов, а также общего количества тестов.
SUCCESS=0
FAIL=0
COUNTER=0
DIFF=""

# Задаем команды для нашей программы и стандартной утилиты "cat".
s21_command=(
    "./s21_cat"
    )
sys_command=(
    "cat"
    )

# Создаем массив тестов, которые будем запускать, и массив флагов, с которыми будем их запускать.
tests=(
"FLAGS test_files/test_case_cat.txt"
"FLAGS test_files/test_case_cat.txt test_files/test_1_cat.txt"
)
flags=(
    "e"
    "s"
    "t"
    "v"
)

# Создаем массив для ручных тестов и массив для тестов, запускаемых с помощью стандартной утилиты "cat".
manual=(
"-s test_files/test_1_cat.txt"
"-e -s -t -v test_files/test_1_cat.txt"
"-b test_files/test_1_cat.txt nofile.txt"
"-t test_files/test_3_cat.txt"
"-v test_files/test_5_cat.txt"
"-- test_files/test_5_cat.txt"
)

# Создаем массив для тестов, запускаемых с помощью утилиты GNU cat.
gnu=(
"-T test_files/test_1_cat.txt"
"-E test_files/test_1_cat.txt"
"-vT test_files/test_3_cat.txt"
"--number test_files/test_2_cat.txt"
"--squeeze-blank test_files/test_1_cat.txt"
"--number-nonblank test_files/test_4_cat.txt"
"test_files/test_1_cat.txt --number --number"
)

# Функция run_test() - выполняет тестирование команды и записывает результаты в лог-файлы
# $@ - список аргументов функции
run_test() {
    # Заменяем в параметрах команды FLAGS на текущее значение $var
    param=$(echo "$@" | sed "s/FLAGS/$var/")
    # Выполняем команду s21_command с новыми параметрами и записываем результат в лог-файл
    "${s21_command[@]}" $param > "${s21_command[@]}".log
    # Выполняем команду sys_command с новыми параметрами и записываем результат в лог-файл
    "${sys_command[@]}" $param > "${sys_command[@]}".log
    # Сравниваем лог-файлы и сохраняем результат в переменную DIFF
    DIFF="$(diff -s "${s21_command[@]}".log "${sys_command[@]}".log)"
    # Увеличиваем счетчик тестов
    let "COUNTER++"
    # Если лог-файлы идентичны, увеличиваем счетчик успешных тестов и выводим сообщение об успехе
    if [ "$DIFF" == "Files "${s21_command[@]}".log and "${sys_command[@]}".log are identical" ]
    then
        let "SUCCESS++"
    # Иначе увеличиваем счетчик неудачных тестов и выводим сообщение об ошибке
    else
        let "FAIL++"
        echo "$COUNTER - Fail $param"
    fi
    # Удаляем лог-файлы
    rm -f "${s21_command[@]}".log "${sys_command[@]}".log
}


# Выполняем ручные тесты, для каждого элемента массива manual используем функцию run_test()
for i in "${manual[@]}"
do
    var="-"
    run_test "$i"
done

# Запускаем автоматические тесты для каждого параметра
# Каждый тест выполняется для каждого значения массива tests

printf "\n"
for var1 in "${flags[@]}"
do
    for i in "${tests[@]}"
    do
        var="-$var1"
        run_test "$i"
    done
done

# Запускаем автоматические тесты для каждой пары параметров
# Каждый тест выполняется для каждого значения массива tests
printf "\n"
for var1 in "${flags[@]}"
do
    for var2 in "${flags[@]}"
    do
        # Проверяем, что параметры не совпадают
        if [ $var1 != $var2 ]
        then
            for i in "${tests[@]}"
            do
                var="-$var1 -$var2"
                run_test "$i"
            done
        fi
    done
done

# Запускаем автоматические тесты для каждой сдвоенной пары параметров
# Каждый тест выполняется для каждого значения массива tests
for var1 in "${flags[@]}"
do
    for var2 in "${flags[@]}"
    do
        # Проверяем, что параметры не совпадают
        if [ $var1 != $var2 ]
        then
            for i in "${tests[@]}"
            do
                var="-$var1$var2"
                run_test "$i"
            done
        fi
    done
done

# Выводим количество успешных, неуспешных и выполненных тестов
printf "\n"
echo "ALL: $COUNTER"
echo "SUCCESS: $SUCCESS"
echo "FAIL: $FAIL"
printf "\n"

if [[ $FAIL -ne 0 ]] 
then
    exit 1
else
    exit 0
fi