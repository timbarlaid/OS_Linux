#!/bin/bash

# Глобальные переменные
answer=""
readable_files=()
check_method=""

# Функция выбора директории
Choose_direct() {
    while true; do
        until [ -d "$answer" ]; do
            read -p "Напишите абсолютный путь до директории (0 - остаться в текущей): " answer

            # Проверка на выход
            if [ "$answer" == "exit" ] || [ "$answer" == "quit" ]; then
                echo "Выход из программы."
                exit 0
            fi

            if [ "$answer" == "0" ]; then
                answer=$PWD
                echo "Выбрана текущая директория: $answer"
            fi

            # Проверка существования директории
            if [ ! -d "$answer" ]; then
                echo "Ошибка: Директория '$answer' не существует или не является директорией."
                unset answer
            fi
        done

        # Проверка прав на чтение директории
        if [ ! -r "$answer" ]; then
            echo "Ошибка: Нет прав на чтение директории '$answer'."
            unset answer
            continue
        fi

        Find_readable_files

        if [ ${#readable_files[@]} -ne 0 ]; then
            break
        fi

        echo "В выбранной директории нет читаемых файлов. Попробуйте другую директорию."
        unset answer
    done
}

# Функция поиска читаемых файлов
Find_readable_files() {
    readable_files=()
    echo "Поиск читаемых файлов в: $answer"
    echo "----------------------------------------"

    local count=0
    while IFS= read -r -d '' file; do
        if [ -f "$file" ] && [ -r "$file" ]; then
            readable_files+=("$file")
            echo "[$count] $file"
            ((count++))
        fi
    done < <(find "$answer" -maxdepth 1 -type f -print0 2>/dev/null)

    echo "----------------------------------------"
    echo "Всего читаемых файлов: ${#readable_files[@]}"
    
    if [ ${#readable_files[@]} -eq 0 ]; then
        echo "Предупреждение: Не найдено ни одного читаемого файла."
    fi
}

# Функция выбора метода проверки
Choose_check_method() {
    while true; do
        echo ""
        echo "Выберите способ проверки на совпадения:"
        echo "1 - По словам"
        echo "2 - По индексам символов"
        echo "3 - Показать информацию о файлах"
        echo "0 - Выход"
        read -p "Ваш выбор (1-3): " method_choice

        case $method_choice in
            1)
                check_method="words"
                echo "Выбран метод проверки: по словам"
                break
                ;;
            2)
                check_method="indexes"
                echo "Выбран метод проверки: по индексам символов"
                break
                ;;
            3)
                Show_files_info
                ;;
            0)
                echo "Выход из программы."
                exit 0
                ;;
            *)
                echo "Ошибка: Неверный выбор. Попробуйте снова."
                ;;
        esac
    done
}

# Функция показа информации о файлах
Show_files_info() {
    if [ ${#readable_files[@]} -eq 0 ]; then
        echo "Нет файлов для отображения информации."
        return
    fi

    echo ""
    echo "Информация о файлах:"
    echo "----------------------------------------"
    
    for i in "${!readable_files[@]}"; do
        file="${readable_files[$i]}"
        size=$(du -h "$file" | cut -f1)
        lines=$(wc -l < "$file" 2>/dev/null || echo "N/A")
        words=$(wc -w < "$file" 2>/dev/null || echo "N/A")
        permissions=$(ls -l "$file" | cut -d' ' -f1)
        
        echo "[$i] $file"
        echo "     Размер: $size, Строк: $lines, Слов: $words"
        echo "     Права: $permissions"
        echo ""
    done
}

# Функция выбора файла для обработки
Choose_file() {
    if [ ${#readable_files[@]} -eq 0 ]; then
        echo "Ошибка: Нет файлов для обработки."
        return 1
    fi

    while true; do
        read -p "Выберите номер файла (0-$(( ${#readable_files[@]} - 1 ))) или 'all' для всех: " file_choice

        if [ "$file_choice" == "all" ]; then
            echo "Выбраны все файлы."
            return 0
        fi

        # Проверка, что ввод - число
        if ! [[ "$file_choice" =~ ^[0-9]+$ ]]; then
            echo "Ошибка: Введите число или 'all'."
            continue
        fi

        if [ "$file_choice" -ge 0 ] && [ "$file_choice" -lt ${#readable_files[@]} ]; then
            selected_file="${readable_files[$file_choice]}"
            echo "Выбран файл: $selected_file"
            return 0
        else
            echo "Ошибка: Неверный номер файла. Доступные номера: 0-$(( ${#readable_files[@]} - 1 ))"
        fi
    done
}

# Функция проверки по словам
Check_by_words() {
    local file="$1"
    echo "Проверка по словам в файле: $file"
    
    # Здесь реализация проверки по словам
    # Например, поиск повторяющихся слов
    echo "Реализация проверки по словам..."
}

# Функция проверки по индексам
Check_by_indexes() {
    local file="$1"
    echo "Проверка по индексам символов в файле: $file"
    
    # Здесь реализация проверки по индексам
    # Например, анализ позиций символов
    echo "Реализация проверки по индексам..."
}

# Основная функция выполнения проверки
Perform_check() {
    local files_to_process=()

    if [ "$file_choice" == "all" ]; then
        files_to_process=("${readable_files[@]}")
    else
        files_to_process=("${readable_files[$file_choice]}")
    fi

    for file in "${files_to_process[@]}"; do
        echo ""
        echo "Обработка файла: $file"
        
        # Дополнительные проверки валидности файла
        if [ ! -f "$file" ]; then
            echo "Ошибка: '$file' не является файлом."
            continue
        fi

        if [ ! -r "$file" ]; then
            echo "Ошибка: Нет прав на чтение файла '$file'."
            continue
        fi

        if [ ! -s "$file" ]; then
            echo "Предупреждение: Файл '$file' пуст."
            continue
        fi

        # Выбор метода проверки
        case $check_method in
            "words")
                Check_by_words "$file"
                ;;
            "indexes")
                Check_by_indexes "$file"
                ;;
            *)
                echo "Ошибка: Неизвестный метод проверки."
                return 1
                ;;
        esac
    done
}

# Главная функция программы
Main() {
    echo "=== Программа анализа файлов ==="
    echo "Для выхода введите 'exit' или 'quit'"
    echo ""

    # Выбор директории
    Choose_direct

    # Выбор метода проверки
    Choose_check_method

    # Показать информацию о файлах
    Show_files_info

    # Выбор файла
    Choose_file
    if [ $? -ne 0 ]; then
        return 1
    fi

    # Выполнение проверки
    Perform_check
}

# Обработка сигналов и ошибок
set -euo pipefail
trap "echo 'Программа прервана.'; exit 1" INT TERM

# Запуск главной функции
while true; do
    Main
    echo ""
    read -p "Хотите продолжить с другой директорией? (y/n): " continue_choice
    if [[ ! "$continue_choice" =~ ^[YyДд] ]]; then
        echo "Выход из программы."
        exit 0
    fi
    unset answer readable_files check_method
done