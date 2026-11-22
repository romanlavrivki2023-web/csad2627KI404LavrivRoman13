# Використання проєкту

## Запуск агента

1. Відкрийте папку репозиторію у VS Code.
2. Відкрийте Copilot Chat.
3. Виберіть агента `build-engineer`.
4. Виконайте команду:

```text
/init
```

Для фінальної перевірки виконайте:

```text
/check
```

## Локальна збірка

### Linux/macOS

```bash
./ci.sh
```

### Windows

```bat
ci.bat
```

## Запуск hello

### Linux/macOS

```bash
./dist/hello
```

### Windows

```bat
dist\hello.exe
```

## Запуск тестів

```bash
ctest --test-dir build -C Release --output-on-failure
```
