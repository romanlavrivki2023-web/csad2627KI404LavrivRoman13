# Архітектура AI-агента build-engineer

## 1. Які проблеми вирішує агент

AI-агент `build-engineer` вирішує задачі автоматизації початкового налаштування
кросплатформного C++ проєкту:

- створює передбачуваний scaffold Hello World;
- налаштовує збірку CMake/C++17;
- додає юніт-тестування GoogleTest через CTest;
- готує локальні CI entrypoint-скрипти для Linux, macOS і Windows;
- створює GitHub Actions workflow для трьох ОС;
- перевіряє стан репозиторію, збірку, тест і артефакти;
- запобігає випадковому перезапису наявних файлів і дублюванню конфігурації.

## 2. Skills

Агент використовує три skill-модулі:

| Skill | Відповідальність |
|---|---|
| `project-scaffold` | Створює структуру C++ проєкту, вихідні файли `hello`, порожні каталоги та README за потреби |
| `build-and-test` | Налаштовує CMake, бібліотеку `add_lib`, виконуваний `hello`, GoogleTest/CTest і скрипти `ci.sh`/`ci.bat` |
| `github-actions` | Створює `.github/workflows/ci.yml` з matrix для Ubuntu, Windows і macOS та завантаженням артефактів |

## 3. Доступні commands

Користувач може викликати prompt-команди:

| Command | Призначення |
|---|---|
| `/git-init` | Перевірити Git-репозиторій і доповнити `.gitignore` |
| `/create-project` | Створити C++ scaffold |
| `/create-build` | Створити CMake-збірку, тест і локальні CI-скрипти |
| `/create-actions` | Створити GitHub Actions workflow |
| `/check` | Перевірити наявність файлів, збірку, CTest, CI і Git-стан |
| `/init` | Послідовно запустити повну підготовку проєкту та перевірку |

## 4. Передача даних між етапами

Основний потік даних від параметрів до CI:

```text
project_name=hello
  -> src/main.cpp, src/add.h, src/add.cpp
  -> CMakeLists.txt
  -> ci.sh / ci.bat
  -> .github/workflows/ci.yml
  -> dist/ артефакти
```

- `project_name=hello` визначає назву проєкту та очікуваного виконуваного файла.
- Файли `src/` передаються в CMake як вихідні дані для `add_lib` і `hello`.
- `CMakeLists.txt` формує build-конфігурацію і CTest-виконання тесту
  `BasicAddition`.
- `ci.sh` і `ci.bat` виконують configure, build, CTest і копіювання executable
  до `dist/`.
- `.github/workflows/ci.yml` викликає відповідний локальний скрипт для кожної ОС
  і завантажує артефакт з `dist/`.

## 5. Обробка помилок orchestrator init

Orchestrator `/init` має послідовно виконувати:

1. `/git-init`
2. `/create-project`
3. `/create-build`
4. `/create-actions`
5. `/check`

Правила обробки помилок:

- Кроки виконуються послідовно.
- Будь-який `FAIL` зупиняє наступні залежні кроки.
- Причина помилки має містити назву етапу, текст або exit code команди.
- Наявні конфлікти файлів не перезаписуються.
- Операція не оголошується успішною після FAILED-перевірки.
- Для помилок компілятора, configure/build, CTest або YAML потрібно повідомити
  конкретну причину і очікувану дію користувача.
- `check` є фінальною перевіркою і повертає `PASSED` лише коли всі перевірки пройдено.

## 6. Відповідність файлів ролям

| Роль | Каталог або тип файлів | Приклади |
|---|---|---|
| Agent | `.github/agents/` | `build-engineer.agent.md` |
| Skills | `.github/skills/<skill-name>/` | `project-scaffold/SKILL.md`, `build-and-test/SKILL.md`, `github-actions/SKILL.md` |
| Commands | `.github/prompts/` | `git-init.prompt.md`, `create-project.prompt.md`, `create-build.prompt.md`, `create-actions.prompt.md`, `check.prompt.md`, `init.prompt.md` |

Custom agent визначає роль і дозволені операції. Skills описують предметні
інструкції для конкретних типів задач. Prompt files є користувацькими командами,
які запускають відповідні етапи агента.

## 7. Формат VS Code Copilot

Архітектура реалізована у форматі VS Code Copilot:

- custom agents;
- prompt files;
- agent skills.
