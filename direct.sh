Choose_direct() {
    while true; do
        until [ -d "$answer" ]; do
            read -p "Напишите абсолютный путь до директории (0-остаться в текущей): " answer

            if [ "$answer" == "0" ]; then
                answer=$PWD
            fi
        done

        Find_readable_files


        if [ ${#readable_files[@]} -ne 0 ]; then
            break
        fi

        echo "В выбранной директории нет читаемых файлов. Попробуйте другую директорию."
        unset answer
    done
}

Find_readable_files () {
  readable_files=()
  echo "Подходящие файлы:"

  for file in $answer/*; do
	  [ -f "$file" ] && [ -r "$file" ] && readable_files+=("$file") && echo "$file"
  done

  echo "Всего читаемых файлов: ${#readable_files[@]}"
}
Choose_direct

