# DB Tools Factory v2 (SQLite + Relational + Mongo)

This package provides:
- Separate connection tools per database:
  - `SQLiteConnectionTool`
  - `MSSQLConnectionTool`
  - `PostgresConnectionTool`
  - `MySQLConnectionTool`
  - `MongoConnectionTool`
- A `create_db(name, env)` factory that selects the correct tool by `DB__<NAME>__TYPE`.
- Clear separation:
  - Relational DBs via SQLAlchemy (`db/relational.py`)
  - MongoDB via PyMongo (`db/nonrelational.py`)

## Intended use in your Django backend

Your backend mainly does:
- API
- scheduled jobs / ETL
- plus Django admin/auth/session for management UI

Recommended pattern:
- Keep Django's internal DB under a separate name, e.g. `DJANGO` (often SQLite locally).
- Keep business/analytics DBs under `DEFAULT`, `MONGO`, etc.
- Use these tools for your custom data access layer. Django ORM remains independent.

## 1) Install dependencies

Core:
```bash
pip install sqlalchemy python-dotenv
```

Relational drivers (install what you use):
- SQLite: built-in (no extra pip package)
- MSSQL:
```bash
pip install pyodbc
```
- Postgres:
```bash
pip install psycopg
```
- MySQL:
```bash
pip install pymysql
```

Mongo:
```bash
pip install pymongo
```

## 2) Configure `.env`

Copy `.env.example` to `.env` and fill values:

```bash
cp .env.example .env
```

Naming convention (namespace simulation):
- `DB__<NAME>__TYPE`
- `DB__<NAME>__URL` (SQL databases)
- `DB__<NAME>__URI`, `DB__<NAME>__DB` (Mongo)

Minimal example for Django admin/auth/session using SQLite:
```env
DB__DJANGO__TYPE=sqlite
DB__DJANGO__URL=sqlite:///./db.sqlite3
```

## 3) Usage

Load `.env` once at program startup:

```python
from dotenv import load_dotenv
load_dotenv(".env")
```

Then create tools with the factory:

### 3.1 Read Django internal tables (admin/auth/session) via SQLite

```python
from settings_provider import EnvDbSettings
from factory import create_db

env = EnvDbSettings()

with create_db("DJANGO", env) as db:
    sessions = db.select("django_session")
    users = db.select("auth_user")
    print(len(sessions), len(users))
```

### 3.2 Use Postgres/MySQL/MSSQL for your business data

```python
from settings_provider import EnvDbSettings
from factory import create_db

env = EnvDbSettings()

with create_db("DEFAULT", env) as db:
    rows = db.select("public.some_table", {"id": 1})
    print(rows)
```

### 3.3 Use MongoDB for document data

```python
from settings_provider import EnvDbSettings
from factory import create_db

env = EnvDbSettings()

with create_db("MONGO", env) as mg:
    _id = mg.insert_one("users", {"name": "Louis"})
    docs = mg.find("users", {"name": "Louis"})
    print(_id, docs)
```

## 4) Notes & best practices

- `.env` should NOT be committed to git.
- In production, prefer OS environment variables (Render) over local `.env`.
- SQLite has concurrency limits; avoid heavy concurrent writes (multiple workers).
  If Django admin/auth/session become busy in production, consider moving Django's DB to Postgres.
- SQL vs Mongo CRUD are intentionally different APIs:
  - SQL uses `execute/insert/update/delete/select`
  - Mongo uses `insert_one/find/update_many/delete_many`
  This avoids forcing SQL semantics onto MongoDB.

## 5) Folder structure

```text
dbtools_factory_v2/
  settings_provider.py
  factory.py
  .env.example
  README.md
  db/
    __init__.py
    base.py
    relational.py
    nonrelational.py
```
