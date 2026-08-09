"""
Экспорт аналитических VIEW из PostgreSQL в CSV-файлы для дашборда.

Что делает скрипт:
- Подключается к базе bank_loans_project
- По очереди выгружает каждый VIEW в отдельный CSV-файл в data/processed/
- Выводит в консоль количество строк по каждому файлу для проверки

Запуск: python3 export_views.py
(запускать из корня проекта bank-loans-project/, либо поправить OUTPUT_DIR ниже)
"""

import psycopg2
import pandas as pd
from pathlib import Path

# --- НАСТРОЙКИ ПОДКЛЮЧЕНИЯ ---
# Замените значения на свои, если они отличаются
DB_CONFIG = {
    "host": "localhost",
    "port": 5432,
    "dbname": "bank_loans_project",
    "user": "dmitrij",          # ваше системное имя пользователя Mac
    "password": "postgres123",  # пароль, который вы задавали командой ALTER USER
}

# Папка, куда сохранять CSV — относительно места запуска скрипта
OUTPUT_DIR = Path(__file__).resolve().parent.parent / "data" / "processed"

# Список VIEW для экспорта: (имя VIEW в базе, имя итогового CSV-файла)
VIEWS_TO_EXPORT = [
    ("v_loan_risk_segments", "loan_risk_segments.csv"),
    ("v_portfolio_summary", "portfolio_summary.csv"),
    ("v_default_by_risk_segment", "default_by_risk_segment.csv"),
    ("v_default_by_purpose_ownership", "default_by_purpose_ownership.csv"),
    ("v_default_by_income_quartile", "default_by_income_quartile.csv"),
]


def main():
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    print(f"Подключаюсь к базе {DB_CONFIG['dbname']}...")
    conn = psycopg2.connect(**DB_CONFIG)

    try:
        for view_name, file_name in VIEWS_TO_EXPORT:
            print(f"Выгружаю {view_name}...")
            query = f"SELECT * FROM {view_name};"
            df = pd.read_sql_query(query, conn)

            output_path = OUTPUT_DIR / file_name
            df.to_csv(output_path, index=False, encoding="utf-8")

            print(f"  -> Сохранено: {output_path} ({len(df)} строк)")

        print("\nГотово! Все файлы сохранены в data/processed/")

    except Exception as e:
        print(f"Ошибка при экспорте: {e}")

    finally:
        conn.close()


if __name__ == "__main__":
    main()