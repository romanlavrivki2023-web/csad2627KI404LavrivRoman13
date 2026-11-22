---
description: "Перевірити наявність, збірку, тести, CI і Git-ігнорування без змін у проєкті."
agent: build-engineer
---

# Check

## Режим роботи

- Виконувати лише перевірки в режимі читання.
- Не створювати і не змінювати файли проєкту.
- Тимчасовий каталог `build/` дозволено створювати для configure/build; він має
  залишатися ігнорованим у `.gitignore`.
- Не видаляти наявні файли або каталоги.
- Не змінювати Git-історію, гілки, токени або налаштування захисту.
- У разі помилки збірки не перезаписувати конфігурацію для приховання помилки.

## Передумови

- Поточний каталог має бути коренем git-репозиторію.
- Команди `git`, `cmake` і CTest мають бути доступні в середовищі.
- Для перевірки Windows-виконуваного файла допускається перевірка тільки наявного
  build-artifact залежно від поточної платформи.

Перед перевірками виконати:

```bash
git rev-parse --is-inside-work-tree
```

Якщо git-репозиторій не знайдено або потрібна команда недоступна, створити FAIL
для відповідної перевірки і продовжити решту перевірок, де це можливо.

## Перевірки

Показати підсумкову таблицю у форматі `PASS/FAIL`.

| № | Перевірка | Результат |
|---|---|---|
| 1 | Інструкції агента і skills існують | |
| 2 | Кожен skill містить розділи Вхід, Вихід, Перевірки | |
| 3 | Очікувані source-, test-, build- і CI-файли існують | |
| 4 | CMake configure/build проходять | |
| 5 | CTest показує, що BasicAddition passed | |
| 6 | Виконуваний hello існує | |
| 7 | ci.yml валідний і містить три ОС без прямих cmake/ctest у run | |
| 8 | build/, dist/, .env, *.key, *.pem не відстежуються Git | |
| 9 | `.gitignore` містить build/ і dist/ | |

### 1. Агенти та skills

Перевірити:

- `.github/agents/build-engineer.agent.md`
- `.github/skills/project-scaffold/SKILL.md`
- `.github/skills/build-and-test/SKILL.md`
- `.github/skills/github-actions/SKILL.md`

Кожен порожній або відсутній required-файл є FAIL.

### 2. Структура skills

Для кожного зі three skill-файлів перевірити наявність Markdown-заголовків або
розділів з назвами:

- `Вхід`
- `Вихід`
- `Перевірки`

Відсутність хоча б одного розділу в одному skill-файлі дає FAIL.

### 3. Очікувані файли проєкту

Перевірити:

- `src/main.cpp`
- `src/add.h`
- `src/add.cpp`
- `tests/test_basic.cpp`
- `CMakeLists.txt`
- `ci.sh`
- `ci.bat`

Відсутність хоча б одного файла дає FAIL.

### 4. CMake configure/build

Виконати:

```bash
cmake -S . -B build && cmake --build build --config Release
```

Будь-який ненульовий exit code означає FAIL із причиною і текстом помилки.

### 5. CTest

Виконати:

```bash
ctest --test-dir build -C Release --output-on-failure
```

Знайти вивід тесту `BasicAddition` зі статусом passed.
Якщо тест відсутній або не passed, перевірка FAIL.

### 6. Виконуваний hello

Перевірити:

- Windows: `build\Release\hello.exe`
- Linux/macOS: `build/hello`

Файл має існувати і бути виконуваним за можливості платформи:

```bash
test -f build/hello
test -f build/Release/hello.exe
```

На поточній платформі очікується відповідний executable; відсутність означає FAIL.

### 7. GitHub Actions workflow

Перевірити `.github/workflows/ci.yml`:

- YAML валідний:

  ```bash
  python -c "import yaml; yaml.safe_load(open('.github/workflows/ci.yml', encoding='utf-8'))"
  ```

- містить `ubuntu-latest`, `windows-latest`, `macos-latest`;
- matrix має `fail-fast: false`;
- кроки `run` викликають лише `./ci.sh` або `ci.bat`;
- у `run` немає прямих `cmake` або `ctest`;
- без слів `token`, `password`, `secret` необов'язково для перевірки цього prompt,
  але використання секретів не дозволено.

Якщо YAML не знайдено або не валідний, перевірка FAIL.

### 8. Git tracked-файли

Виконати:

```bash
git ls-files
```

Перевірити, що результат не містить:

- `build/`
- `dist/`
- `.env`
- шаблонів `*.key`
- шаблонів `*.pem`

Жоден matching-файл не має бути tracked. Наявність дає FAIL.

### 9. .gitignore

Перевірити наявність точних рядків:

```text
build/
dist/
```

Відсутність хоча б одного рядка дає FAIL.

## Підсумок

Вивести таблицю PASS/FAIL для дев'яти перевірок.

- Якщо хоча б один результат FAIL: вказати конкретну перевірку з причиною і вивести
  фінальний рядок `FAILED`.
- Якщо всі дев'ять перевірок PASS: вивести `PASSED`.

## Повідомлення про помилку

- Для кожної помилки вказувати номер перевірки, назву і конкретну причину.
- Не приховувати помилки configure/build/CTest.
- Не змінювати файли, якщо перевірка виявила FAIL.
- Не вважати перевірку успішною без пройденого фактичного факту.
- Якщо є хоча б один FAIL, завершити повідомленням `FAILED`.
