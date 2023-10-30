# Установка начальных значений переменных
TEMPLATE="yes" # Параметр для поиска 
PATTERN="test_files/grep_pattern.txt" # Путь до файла с паттернами 
TEMPLATE_FILE="test_files/grep_test.txt" # Путь до файла с параметрами 
TEST_FILE="test_files/grep_test.txt" # Путь до файла тестируемого
S21="./s21_grep" # Исполняемый
GREP="grep.txt" # Файл для записи логов грепа заводского
S21_GREP="s21_grep.txt" # Файл для записи логов тестируемого грепа
LOG="grep_log.txt" # Файл для записи логов

SUCCESS=0
FAIL=0

# Очистка лог-файла
echo "" > $LOG

# Вывод информации о файлах для тестирования
echo Testing file: $TEST_FILE
echo Template file: $TEMPLATE_FILE

# Тестирование параметров для grep и s21_grep на первом файле
for var in -e -i -v -c -l -n -h -s -o
do
    # Запуск s21_grep с текущим параметром и сохранение вывода в файл s21_grep.txt
    $S21 $var $TEMPLATE $TEMPLATE_FILE  > $S21_GREP 
    # Запуск grep с текущим параметром и сохранение вывода в файл grep.txt
    grep $var $TEMPLATE $TEMPLATE_FILE > $GREP 

    # Сравнение файлов s21_grep.txt и grep.txt. Если они одинаковы, то тест прошел успешно
    if cmp -s $S21_GREP $GREP; then
        (( SUCCESS++ ))
    else
        # Иначе добавляем текущий параметр в лог-файл и увеличиваем счетчик неудачных тестов
        echo "$var" >> $LOG
        echo "$var" 
        (( FAIL++ ))
    fi
    # Удаление временных файлов s21_grep.txt и grep.txt
    rm $S21_GREP $GREP
done

# Тестирование параметров для grep и s21_grep на втором файле
for var in -e -i -v -c -l -h -s -o -n
do
    param=$(echo "$@" | sed "s/FLAGS/$var/")
    $S21 $var $TEMPLATE $TEMPLATE_FILE test_files/grep_test_2.txt > $S21_GREP 
    grep $var $TEMPLATE $TEMPLATE_FILE test_files/grep_test_2.txt > $GREP 
    if cmp -s $S21_GREP $GREP; then
        (( SUCCESS++ ))
    else
        echo "$var" >> $LOG
        echo "$var" 
        (( FAIL++ ))
    fi
    rm $S21_GREP $GREP
done

# Цикл по набору опций для поиска с помощью команды $S21
for var in -c -ce -ch -cn -co -cs -he -ho -hs -ic -ie -ih -il -in -io -is -iv -l -le -lh -ln -lo -ls -n -ne
do
    # Выполнение команды $S21 с текущей опцией $var и запись результата в файл $S21_GREP
    $S21 $var $TEMPLATE $TEMPLATE_FILE  > $S21_GREP 
    # Поиск с помощью grep с текущей опцией $var и запись результата в файл $GREP
    grep $var $TEMPLATE $TEMPLATE_FILE > $GREP 
    # Сравнение файлов $S21_GREP и $GREP. Если они одинаковы, то увеличиваем счетчик успешных проверок
    if cmp -s $S21_GREP $GREP; then
        (( SUCCESS++ ))
    else
        # Если файлы не одинаковы, то записываем опцию в файл $LOG и увеличиваем счетчик неуспешных проверок
        # Выводим неуспешные на экран для удобства
        echo "$var" >> $LOG
        echo "$var" 
        (( FAIL++ ))
    fi
    # Удаление временных файлов
    rm $S21_GREP $GREP
done

# Цикл по набору опций для поиска с помощью команды $S21
for var in -f -cf -hf -lf -nf -nh -no -ns -o -oe -se -v -vc -ve -vh -vl -vn -vs
do
    # Выполнение команды $S21 с текущей опцией $var и запись результата в файл $S21_GREP
    $S21 $var $PATTERN $TEMPLATE_FILE  > $S21_GREP 
    # Поиск с помощью grep с текущей опцией $var и запись результата в файл $GREP 
    grep $var $PATTERN $TEMPLATE_FILE > $GREP 
    # Сравнение файлов $S21_GREP и $GREP. Если они одинаковы, то увеличиваем счетчик успешных проверок
    if cmp -s $S21_GREP $GREP; then
        (( SUCCESS++ ))
    else
        # Если файлы не одинаковы, то записываем опцию в файл $LOG и увеличиваем счетчик неуспешных проверок
        echo "$var" >> $LOG
        echo "$var" 
        (( FAIL++ ))
    fi
    # Удаление временных файлов
    rm $S21_GREP $GREP
done


# поиск строк, содержащих шаблон и "who" в файле шаблона, вывод в файл
grep -e $TEMPLATE -e who $TEMPLATE_FILE > $GREP
# аналогичный поиск с помощью программы $S21, вывод в файл
$S21 -e $TEMPLATE -e who $TEMPLATE_FILE > $S21_GREP
# если содержимое файлов $S21_GREP и $GREP идентичны, увеличить значение переменной SUCCESS на 1, иначе на 1 для переменной FAIL
if cmp -s $S21_GREP $GREP; then
    (( SUCCESS++ ))
else
    (( FAIL++ ))
fi
# удалить созданные временные файлы
rm $S21_GREP $GREP

# поиск строк, соответствующих паттерну в файле для тестирования, вывод в файл
grep -f $PATTERN -e tyt $TEST_FILE > $GREP
# аналогичный поиск с помощью программы $S21, вывод в файл
$S21 -f $PATTERN -e tyt $TEST_FILE > $S21_GREP 
# если содержимое файлов $S21_GREP и $GREP идентичны, увеличить значение переменной SUCCESS на 1
#, иначе на 1 для переменной FAIL, и записать "-f -e" в файл $LOG
if cmp -s $S21_GREP $GREP; then
    (( SUCCESS++ ))
else
    echo "-f -e" >> $LOG
    (( FAIL++ ))
fi

# поиск строк, содержащих шаблон в файле для тестирования и файле grep_s21.h, вывод в файл
grep -h $TEMPLATE $TEST_FILE grep_s21.h > $GREP
# аналогичный поиск с помощью программы $S21, вывод в файл
$S21 -h $TEMPLATE $TEST_FILE grep_s21.h > $S21_GREP
# если содержимое файлов $S21_GREP и $GREP идентичны, увеличить значение переменной SUCCESS на 1, иначе на 1 для переменной FAIL, и записать "-h" в файл $LOG
if cmp -s $S21_GREP $GREP; then
    (( SUCCESS++ ))
else
    echo "-h" >> $LOG
    (( FAIL++ ))
fi

# удалить созданные временные файлы
rm $GREP $S21_GREP

# если значение переменной FAIL не равно 0, вывести количество успешных и неуспешных тестов, завершить скрипт с кодом 9,
# иначе удалить файл $LOG и вывести количество успешных и неуспешных тестов
if [ $FAIL != 0 ]
then
    echo "SUCCESS: $SUCCESS"
    echo "FAIL: $FAIL"
    exit 1
else
    rm $LOG
    echo "SUCCESS: $SUCCESS"
    echo "FAIL: $FAIL"
    exit 0
fi