---
description: "Створити кросплатформний GitHub Actions workflow через локальні ci.sh і ci.bat."
agent: build-engineer
---

# Create Actions

## Передумови

- Поточний каталог має бути git-репозиторієм.
- Має існувати локальний Unix-сценарій `ci.sh`.
- Має існувати локальний Windows-сценарій `ci.bat`.
- Сценарії мають виконувати configure, build і CTest.

Перевір prerequisites:

```bash
test -f ci.sh
test -f ci.bat
git rev-parse --is-inside-work-tree
```

Якщо хоча б одна перевірка не пройшла, зупинись і не створюй workflow.

## Дії

1. Завантаж і виконуй інструкції зі skill:
   `.github/skills/github-actions/SKILL.md`.
2. Створити `.github/workflows/ci.yml`.
3. Налаштувати тригери `push` і `pull_request` для гілок `develop` і `master`.
4. Створити одну job із matrix:
   `ubuntu-latest`, `windows-latest`, `macos-latest`.
5. Встановити `fail-fast: false`.
6. Додати checkout через `actions/checkout@v4`.
7. На не-Windows runners запускати лише `./ci.sh` через `shell: bash`.
8. На Windows запускати лише `ci.bat` через `shell: cmd`.
9. Додати `actions/upload-artifact@v4` для `dist/` з назвою
   `hello-${{ matrix.os }}` і `if-no-files-found: error`.
10. Не використовувати секрети і не розміщувати прямі команди `cmake` або `ctest`
    у кроках workflow.

## Очікувані файли

- `.github/workflows/ci.yml`

Ніякі інші build-файли або CI-файли не мають створюватися цією prompt-командою.

## Команди перевірки

Перевір YAML:

```bash
python -c "import yaml; yaml.safe_load(open('.github/workflows/ci.yml', encoding='utf-8'))"
```

Якщо доступний `actionlint`:

```bash
actionlint
```

Також перевір:

- matrix містить `ubuntu-latest`, `windows-latest` і `macos-latest`;
- workflow викликає лише `./ci.sh` або `ci.bat`;
- у кроках `run` немає `cmake` і `ctest`;
- тригери cover `develop` і `master`;
- немає слів `token`, `password` або `secret`;
- upload-artifact завантажує `dist/`.

## Повідомлення про помилку

- Якщо `ci.sh` або `ci.bat` відсутній:
  `Відсутній локальний CI entrypoint. Створення workflow скасовано.`
- Якщо YAML не валідний, показати помилку парсера і не оголошувати workflow успішним.
- Якщо у workflow знайдено прямі `cmake` або `ctest`, видалити лише дублюючу
  логіку після окремої перевірки і замінити її викликом відповідного скрипта.
- Якщо прав на виконання `ci.sh` недостатньо:
  `ci.sh без прав на виконання. Виконайте chmod +x ci.sh і git update-index --chmod=+x ci.sh.`
- Не продовжуй наступні кроки після помилки конфігурації.

## Ідемпотентність

- Повторний запуск не додає дублікати тригерів, matrix entries або кроків.
- Якщо `.github/workflows/ci.yml` уже має очікуваний вміст, залишити файл без змін.
- Наявний відмінний workflow не перезаписувати: показати diff або опис конфлікту.
