Find_common_words() {
    local file1=$1
    local file2=$2
    local file3=$3
    local output_file=$4

    local temp1=$(mktemp)
    local temp2=$(mktemp)
    local temp3=$(mktemp)

    grep -oE '\w+' "$file1" | tr '[:upper:]' '[:lower:]' | sort -u > "$temp1"
    grep -oE '\w+' "$file2" | tr '[:upper:]' '[:lower:]' | sort -u > "$temp2"
    grep -oE '\w+' "$file3" | tr '[:upper:]' '[:lower:]' | sort -u > "$temp3"

    comm -23 "$temp1" "$temp2" | comm -23 - "$temp3" > "${output_file}_only_in_file1.txt"

    comm -23 "$temp2" "$temp1" | comm -23 - "$temp3" > "${output_file}_only_in_file2.txt"

    comm -23 "$temp3" "$temp1" | comm -23 - "$temp2" > "${output_file}_only_in_file3.txt"

    comm -12 "$temp1" "$temp2" | comm -23 - "$temp3" > "${output_file}_in_1_2_not_3.txt"

    comm -12 "$temp1" "$temp3" | comm -23 - "$temp2" > "${output_file}_in_1_3_not_2.txt"

    comm -12 "$temp2" "$temp3" | comm -23 - "$temp1" > "${output_file}_in_2_3_not_1.txt"

    comm -12 "$temp1" "$temp2" | comm -12 - "$temp3" > "${output_file}_common_all.txt"

    rm "$temp1" "$temp2" "$temp3"
}

Find_common_sym() {
    local file1=$1
    local file2=$2
    local file3=$3
    local output_file=$4

    local temp1=$(mktemp)
    local temp2=$(mktemp)
    local temp3=$(mktemp)

    grep -o . "$file1" | tr '[:upper:]' '[:lower:]' | sort -u > "$temp1"
    grep -o . "$file2" | tr '[:upper:]' '[:lower:]' | sort -u > "$temp2"
    grep -o . "$file3" | tr '[:upper:]' '[:lower:]' | sort -u > "$temp3"

    comm -23 "$temp1" "$temp2" | comm -23 - "$temp3" > "${output_file}_only_in_file1.txt"

    comm -23 "$temp2" "$temp1" | comm -23 - "$temp3" > "${output_file}_only_in_file2.txt"

    comm -23 "$temp3" "$temp1" | comm -23 - "$temp2" > "${output_file}_only_in_file3.txt"

    comm -12 "$temp1" "$temp2" | comm -23 - "$temp3" > "${output_file}_in_1_2_not_3.txt"

    comm -12 "$temp1" "$temp3" | comm -23 - "$temp2" > "${output_file}_in_1_3_not_2.txt"

    comm -12 "$temp2" "$temp3" | comm -23 - "$temp1" > "${output_file}_in_2_3_not_1.txt"

    comm -12 "$temp1" "$temp2" | comm -12 - "$temp3" > "${output_file}_common_all.txt"

    rm "$temp1" "$temp2" "$temp3"
}

Choose_type_of_analysis() {
    while true; do
        echo ""
        echo "1 - Выполнить поиск одинаковых слов"
        echo "2 - Выполнить поиск одинаковых символов (без учёта индекса)"
        read -p "Выберите вариант (1-3): " choice
        local i

        case $choice in
            1)
                for ((i=0; i < (${#selected_files[@]} - 2); i++)); do
                    for ((j=i+1; j < (${#selected_files[@]})-1; j++)); do
                        for ((z=j+i+1; z < ${#selected_files[@]}; z++)); do
                            Find_common_words "${selected_files[i]}" "${selected_files[j]}" "${selected_files[z]}" "_"
                        done
                    done
                done 
                break
                ;;
            2)
               for ((i=0; i < (${#selected_files[@]} - 2); i++)); do
                    for ((j=i+1; j < (${#selected_files[@]} - 1); j++)); do
                        for ((z=j+i+1; z < ${#selected_files[@]}; z++)); do
                            Find_common_sym "${selected_files[i]}" "${selected_files[j]}" "${selected_files[z]}" "_"
                        done
                    done
                done 
                break
                ;;
            *)
                echo "Неверный выбор. Попробуйте снова."
                ;;
        esac
    done
}

Select_files() {
    selected_files=()
    while true; do
        echo ""
        echo "1 - Выбрать ВСЕ файлы"
        echo "2 - Выбрать ОТДЕЛЬНЫЕ файлы"
        echo "3 - Назад к выбору директории"
        read -p "Выберите вариант (1-3): " choice

        case $choice in
            1)
                selected_files=("${readable_files[@]}")
                echo "Выбраны все файлы (${#selected_files[@]} шт.)"
                Choose_type_of_analysis
                break
                ;;
            2)
                echo "Доступные файлы:"
                for i in "${!readable_files[@]}"; do
                    filename=$(basename "${readable_files[$i]}")
                    echo "$((i+1)) - $filename"
                done
                echo ""
                read -p "Введите номера файлов через пробел (например: 1 3 5): " file_numbers

                old_IFS=$IFS
                IFS=' ' read -ra numbers <<< "$file_numbers"
                IFS=$old_IFS

                for num in "${numbers[@]}"; do
                    if ! [[ "$num" =~ ^[0-9]+$ ]]; then
                        echo "Ошибка: '$num' не является числом"
                        continue
                    fi

                    index=$((num-1))
                    if [ $index -ge 0 ] && [ $index -lt ${#readable_files[@]} ]; then
                        selected_files+=("${readable_files[$index]}")
                    else
                        echo "Введен некорректный индекс: $num (доступно: 1-${#readable_files[@]})"
                    fi
                done

                if [ ${#selected_files[@]} -gt 2 ]; then
                    echo ""
                    echo "Выбраны файлы:"
                    for file in "${selected_files[@]}"; do
                        echo "  - $(basename "$file")"
                    done
                    echo ""
                    Choose_type_of_analysis
                    break
                else
                    echo ""
                    echo "Выбрано менее трех файлов. Попробуйте снова."
                    echo ""
                fi
                ;;
            3)
		        unset answer
                Choose_direct
                return
                ;;
            *)
                echo "Неверный выбор. Попробуйте снова."
                ;;
        esac
    done
}

Find_readable_files () {
    readable_files=()
    echo "Файлы в директории:"

    for file in $answer/*; do
        [ -f "$file" ] && [ -r "$file" ] && readable_files+=("$file")
        echo "  - $(basename "$file")"
    done

    echo "Всего читаемых файлов: ${#readable_files[@]}"
    echo ""

    if ! [ ${#readable_files[@]} -gt 2 ]; then
        echo "Читаемых файлов меннее трех, сравнение невозможно. Попробуйте еще раз."
        Choose_direct
    fi
}

Choose_direct () {
    while true; do
        until [ -d "$answer" ]; do
            read -p "Напишите абсолютный путь до директории (0-остаться в текущей): " answer

            if [ "$answer" == "0" ]; then
                answer=$PWD
            fi
        done

        Find_readable_files

        if [ ${#readable_files[@]} -ne 0 ]; then
	    Select_files
	    break
        fi

        echo "В выбранной директории нет читаемых файлов. Попробуйте другую директорию."
        unset answer
    done
}
Choose_direct


