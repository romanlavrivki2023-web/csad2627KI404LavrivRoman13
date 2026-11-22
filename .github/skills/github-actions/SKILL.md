---
name: github-actions
description: "Застосовувати для створення та перевірки кросплатформного GitHub Actions workflow CMake/C++ проєкту без прямих cmake/ctest команд у YAML."
---

# GitHub Actions

## Вхід

Для створення workflow мають бути доступні локальні entrypoint-скрипти:

- `ci.sh` — для Linux і macOS
- `ci.bat` — для Windows

Workflow має використовувати ці скрипти як єдині точки запуску збірки й тестів.
Не дублюй логіку configure, build або CTest безпосередньо у YAML.

## Вихід

Створити `.github/workflows/ci.yml` з:

- тригерами `push` і `pull_request`;
- гілками `develop` і `master`;
- однією job із matrix для:
  - `ubuntu-latest`
  - `windows-latest`
  - `macos-latest`
- `fail-fast: false`;
- без використання секретів, токенів або паролів.

Обов'язкові кроки:

1. Checkout: `actions/checkout@v4`.
2. На не-Windows-системах запуск `./ci.sh` через `shell: bash`.
3. На Windows запуск `ci.bat` через `shell: cmd`.
4. Завантаження каталогу `dist/` через `actions/upload-artifact@v4`.
5. Унікальна назва артефакту:
   `hello-${{ matrix.os }}`
6. Параметр `if-no-files-found: error`.

Приклад очікуваного YAML:

```yaml
name: CI

on:
  push:
    branches:
      - develop
      - master
  pull_request:
    branches:
      - develop
      - master

jobs:
  build-and-test:
    runs-on: ${{ matrix.os }}
    strategy:
      fail-fast: false
      matrix:
        os:
          - ubuntu-latest
          - windows-latest
          - macos-latest

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Run Unix CI
        if: runner.os != 'Windows'
        shell: bash
        run: ./ci.sh

      - name: Run Windows CI
        if: runner.os == 'Windows'
        shell: cmd
        run: ci.bat

      - name: Upload hello artifact
        uses: actions/upload-artifact@v4
        with:
          name: hello-${{ matrix.os }}
          path: dist/
          if-no-files-found: error
```

У кроках `run` не дозволені прямі команди `cmake` або `ctest`. Кожна операція має
бути делегована `./ci.sh` або `ci.bat`.

## Правила безпеки

- Не використовувати секрети або змінні, що містять credentials.
- Не читати, не створювати і не публікувати токени або паролі.
- Не додавати секрети у names, run-команди, env або артефакти.
- Не застосовувати external publish або інші дії для публікації даних.
- Артефакт має містити лише результат локальної збірки з `dist/`.

## Перевірки

Перед оголошенням успіху перевірити:

- [ ] YAML успішно розпізнається як валідний документ.
- [ ] Є тригери `push` і `pull_request`.
- [ ] Для обох тригерів указані гілки `develop` і `master`.
- [ ] Є matrix із `ubuntu-latest`, `windows-latest`, `macos-latest`.
- [ ] Параметр `fail-fast` дорівнює `false`.
- [ ] Checkout використовує `actions/checkout@v4`.
- [ ] Не-Windows-крок запускає `./ci.sh` через `shell: bash`.
- [ ] Windows-крок запускає `ci.bat` через `shell: cmd`.
- [ ] Усі run-кроки запускають лише локальний entrypoint.
- [ ] У workflow немає прямих команд `cmake` або `ctest`.
- [ ] Використано `actions/upload-artifact@v4`.
- [ ] Артефакт називається `hello-${{ matrix.os }}`.
- [ ] `if-no-files-found` дорівнює `error`.
- [ ] У файлі немає слів `token`, `password` і `secret`.

Для перевірки YAML можна виконати:

```bash
python -c "import yaml; yaml.safe_load(open('.github/workflows/ci.yml', encoding='utf-8'))"
```

Якщо доступний `actionlint`, додатково перевірити workflow ним.

## Типова помилка

### ci.sh без прав на виконання

Якщо запуск `./ci.sh` завершується `Permission denied`, не змінюй саму збірку:

```bash
chmod +x ci.sh
git update-index --chmod=+x ci.sh
```

Зупини workflow-перевірку до усунення проблеми прав доступу.

## Ідемпотентність

- Не дублюй matrix entries і job кроки.
- Не перезаписуй існуючий файл без перевірки його відмінностей.
- Повторний запуск має зберігати той самий набір тригерів, ОС, кроків і артефактів.
- Якщо workflow уже містить очікувану конфігурацію, залиш його без змін.

## Приклад входу

```text
ci.sh
ci.bat
dist/
```

## Очікуваний результат

- Створено валідний `.github/workflows/ci.yml`.
- Push та pull request обмежені гілками `develop` і `master`.
- Одна job запускається на Ubuntu, Windows і macOS.
- Linux/macOS використовують `./ci.sh`, Windows використовує `ci.bat`.
- Workflow не містить прямих `cmake`/`ctest` команд і не використовує секрети.
- Для кожної ОС завантажується артефакт `hello-${{ matrix.os }}` з `dist/`.
