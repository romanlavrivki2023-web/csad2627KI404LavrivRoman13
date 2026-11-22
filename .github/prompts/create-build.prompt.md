---
description: "Налаштувати CMake-збірку, GoogleTest/CTest і локальні CI-скрипти."
agent: build-engineer
---

# Create Build

## Передумови

- Поточний каталог має бути git-репозиторієм.
- Мають існувати вихідні файли:
  - `src/main.cpp`
  - `src/add.h`
  - `src/add.cpp`
- Для збірки мають бути доступні CMake і C++ компілятор.

Перевір наявність початкових файлів:

```bash
test -f src/main.cpp
test -f src/add.h
test -f src/add.cpp
git rev-parse --is-inside-work-tree
```

Якщо хоча б одна перевірка не пройшла, зупинись і не створюй build-файли.

## Дії

1. Завантаж і виконуй інструкції зі skill:
   `.github/skills/build-and-test/SKILL.md`.
2. Створити або перевірити `CMakeLists.txt` для C++17.
3. Додати бібліотеку `add_lib`, виконуваний файл `hello` і GoogleTest через
   `FetchContent`.
4. Підключити CTest і `gtest_discover_tests`.
5. Створити `tests/test_basic.cpp` із тестом `BasicAddition`.
6. Створити `ci.sh` для Linux/macOS із `set -euo pipefail`.
7. Створити `ci.bat` для Windows із перевіркою `errorlevel` після кожної команди.
8. Позначити `ci.sh` виконуваним за допомогою
   `git update-index --chmod=+x ci.sh`.
9. Не перезаписуй наявні файли, якщо вони вже відповідають очікуваній конфігурації.

## Очікувані файли

- `CMakeLists.txt`
- `tests/test_basic.cpp`
- `ci.sh`
- `ci.bat`

Після виконання build-скриптів мають існувати платформи-залежні виконувані файли:

- Linux/macOS: `build/hello`
- Windows: `build\Release\hello.exe`

## Команди перевірки

Виконай перевірку для Linux/macOS:

```bash
cmake -S . -B build
cmake --build build
ctest --test-dir build --output-on-failure
```

На Windows:

```bat
cmake -S . -B build
cmake --build build --config Release
ctest --test-dir build -C Release --output-on-failure
```

Після перевірки переконайся, що:

- CMake configure і build завершилися без помилок;
- CTest показує `BasicAddition` зі статусом passed;
- існує виконуваний `hello`;
- `ci.sh` позначений як executable;
- `ci.bat` перевіряє `errorlevel` після кожної команди.

## Повідомлення про помилку

- Якщо вихідні файли відсутні:
  `Відсутній required source-файл для create-build. Створення збірки скасовано.`
- Якщо компілятор не знайдено:
  `Не знайдено C++ компілятор. Встановіть компілятор і повторіть перевірку.`
- Якщо configure, build або CTest завершується помилкою, показати текст і код помилки,
  зупинити наступні кроки і не оголошувати роботу успішною.
- Якщо наявний файл відрізняється від очікуваного вмісту, повідом про конфлікт і не
  перезаписуй його без явного рішення користувача.

## Ідемпотентність

- Повторний запуск не дублює блоки у `CMakeLists.txt`.
- Повторний запуск не дублює тестові визначення і команди build-скриптів.
- Наявні рівнозначні файли залишити без змін.
- При конфлікті вмісту показати diff або опис відмінностей і не перезаписувати файл.
