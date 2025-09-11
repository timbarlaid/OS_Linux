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

                if [ ${#selected_files[@]} -gt 0 ]; then
                    echo ""
                    echo "Выбраны файлы:"
                    for file in "${selected_files[@]}"; do
                        echo "  - $(basename "$file")"
                    done
                    echo ""
                    break
                else
                    echo ""
                    echo "Не выбрано ни одного файла. Попробуйте снова."
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
for element in "${selected_files[@]}"; do
    echo "$element"
done

