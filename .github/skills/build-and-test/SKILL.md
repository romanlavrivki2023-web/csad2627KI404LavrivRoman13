---
name: build-and-test
description: "Застосовувати для налаштування CMake/C++17, бібліотеки add_lib, GoogleTest/CTest, локальних скриптів збірки та перевірки виконуваного hello."
---

# Build and Test

## Вхід

Для виконання потрібні наявні файли:

- `src/add.h`
- `src/add.cpp`
- `src/main.cpp`

Перед початком перевір, що всі три файли існують і доступні для читання.
Якщо хоча б один відсутній, зупинись і повідом про неможливість налаштування збірки.

## Вихід

- Створити або перевірити `CMakeLists.txt` з конфігурацією C++17.
- Створити `tests/test_basic.cpp` з тестом GoogleTest `BasicAddition`.
- Створити виконуваний скрипт `ci.sh` для bash.
- Створити скрипт `ci.bat` для Windows CMD.
- Під час перевірки зібрати виконуваний файл `hello`.
- Скопіювати виконуваний файл у каталог `dist/`.

`CMakeLists.txt` має містити:

- `cmake_minimum_required(VERSION 3.14)`
- стандарт C++17 із вимкненим поширенням старших стандартів
- бібліотеку `add_lib` на основі `src/add.cpp`
- заголовки `src/` для цільових, що потребують `add.h`
- виконуваний файл `hello` на основі `src/main.cpp`
- GoogleTest через `FetchContent`
- виклик `enable_testing()`
- підключення CTest
- виклик `gtest_discover_tests`
- тест `BasicAddition`, який перевіряє результат `add`

Приклад очікуваної структури тесту:

```cpp
#include "add.h"
#include <gtest/gtest.h>

TEST(BasicAddition, BasicAddition) {
    EXPECT_EQ(add(20, 22), 42);
}
```

## Скрипти перевірки

### ci.sh

Скрипт `ci.sh` для Linux/macOS має виконувати configure, build, CTest і копіювання
виконуваного файла:

```bash
#!/usr/bin/env bash
set -euo pipefail

cmake -S . -B build
cmake --build build
ctest --test-dir build --output-on-failure

mkdir -p dist
cp build/hello dist/hello
```

Після створення або зміни `ci.sh` позначити файл виконуваним:

```bash
git update-index --chmod=+x ci.sh
```

### ci.bat

Скрипт `ci.bat` для Windows має перевіряти `errorlevel` після кожної команди.
При помилці завершуватися з ненульовим кодом і не продовжувати наступні кроки.

```bat
@echo off
setlocal

cmake -S . -B build
if errorlevel 1 exit /b 1

cmake --build build --config Release
if errorlevel 1 exit /b 1

ctest --test-dir build -C Release --output-on-failure
if errorlevel 1 exit /b 1

if not exist dist mkdir dist
if errorlevel 1 exit /b 1

copy /Y build\Release\hello.exe dist\hello.exe
if errorlevel 1 exit /b 1

exit /b 0
```

Після успішної збірки виконуваний файл знаходиться:

- Windows: `build\Release\hello.exe`
- Linux/macOS: `build/hello`

## Правила роботи з файлами

- Не перезаписуй наявні файли без перевірки поточного вмісту.
- Якщо файл існує і повністю відповідає очікуваній конфігурації, пропустити зміни.
- Якщо файл відрізняється, повідомити конфлікт і не перезаписувати файл.
- Повторний запуск має бути ідемпотентним.
- Не дублювати блоки `FetchContent`, `enable_testing()` або
  `gtest_discover_tests` у `CMakeLists.txt`.
- Скрипти повинні зупинятися при першій помилці.

## Перевірки

Перед оголошенням успіху виконати та перевірити:

- [ ] `CMakeLists.txt` успішно проходить configure.
- [ ] CMake успішно збирає проєкт.
- [ ] CTest показує `BasicAddition` зі статусом `Passed`.
- [ ] Існує виконуваний файл `hello`:
  - Linux/macOS: `build/hello`
  - Windows: `build\Release\hello.exe`
- [ ] Файл `tests/test_basic.cpp` містить тест `BasicAddition`.
- [ ] `ci.sh` запускається з bash і завершується лише при успішних кроках.
- [ ] `ci.bat` перевіряє `errorlevel` після кожної команди.
- [ ] Зібраний файл скопійовано до `dist/`.
- [ ] Повторний запуск не дублює конфігураційні блоки.

## Типові помилки

### Не знайдено компілятор

Якщо CMake або build завершується через відсутній C/C++ компілятор:

```text
Не знайдено C++ компілятор. Встановіть підтримуваний компілятор і повторіть перевірку.
```

Не оголошуй збірку успішною і не переходь до наступних етапів.

### Неправильне розташування hello на Windows

Не вважай помилкою відсутність `build\hello.exe`, якщо збірка виконана у конфігурації
Release. Очікуване розташування:

```text
build\Release\hello.exe
```

### Неправильне розташування hello на Linux/macOS

Очікуване розташування:

```text
build/hello
```

## Приклад входу

```text
src/add.h
src/add.cpp
src/main.cpp
```

## Очікуваний результат

- Створено коректний CMake проєкт із `add_lib`, `hello` і GoogleTest.
- Створено `tests/test_basic.cpp` із тестом `BasicAddition`.
- Створено і перевірено `ci.sh` та `ci.bat`.
- Configure, build і CTest завершуються успішно.
- CTest показує `BasicAddition passed`.
- Виконуваний `hello` існує в платформи-залежному build-каталозі і копіюється в `dist/`.
