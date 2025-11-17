FROM python:3.12-slim

# Установка системных зависимостей
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    build-essential \
    libpq-dev \
    wget \
    gnupg \
    && rm -rf /var/lib/apt/lists/*

# Установка Chrome для Selenium
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list \
    && apt-get update \
    && apt-get install -y google-chrome-stable \
    && rm -rf /var/lib/apt/lists/*

# Создание пользователя приложения
RUN groupadd --gid 2000 app && useradd --uid 2000 --gid 2000 -m -d /app app

WORKDIR /app

# Копирование requirements.txt первым для кэширования
COPY --chown=app:app requirements.txt .

# Обновление pip и установка зависимостей
RUN pip install --no-cache-dir --upgrade pip
RUN pip install --no-cache-dir -r requirements.txt

# Копирование остального кода
COPY --chown=app:app . .

# Переключение на пользователя app
USER app

# Команда запуска
CMD ["python", "main.py"]
