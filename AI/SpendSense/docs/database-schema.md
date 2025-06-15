# SpendSense Database Schema

## Overview
This document outlines the SQLite database schema for the SpendSense expense tracking application. The schema is designed to support offline-first functionality with local storage on the device.

## Database Tables

### 1. Expenses Table
Primary table for storing expense records.

```sql
CREATE TABLE expenses (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    date DATE NOT NULL,
    category_id INTEGER,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES categories(id)
);
```

#### Fields Description:
- `id`: Unique identifier for each expense
- `title`: Description of the expense
- `amount`: Expense amount (supports 2 decimal places)
- `date`: Date of the expense
- `category_id`: Reference to the category (optional)
- `notes`: Additional notes about the expense (optional)
- `created_at`: Timestamp of record creation
- `updated_at`: Timestamp of last update

### 2. Categories Table
Stores expense categories for better organization.

```sql
CREATE TABLE categories (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    color TEXT NOT NULL,
    icon TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

#### Fields Description:
- `id`: Unique identifier for each category
- `name`: Category name
- `color`: Color code for UI representation
- `icon`: Icon identifier for category
- `created_at`: Timestamp of record creation

### 3. Monthly_Summaries Table
Stores pre-calculated monthly summaries for quick access.

```sql
CREATE TABLE monthly_summaries (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    year INTEGER NOT NULL,
    month INTEGER NOT NULL,
    total_amount DECIMAL(10,2) NOT NULL,
    expense_count INTEGER NOT NULL,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(year, month)
);
```

#### Fields Description:
- `id`: Unique identifier for each summary
- `year`: Year of the summary
- `month`: Month of the summary (1-12)
- `total_amount`: Total expenses for the month
- `expense_count`: Number of expenses in the month
- `last_updated`: Timestamp of last update

## Indexes

```sql
-- Index for faster date-based queries
CREATE INDEX idx_expenses_date ON expenses(date);

-- Index for faster category-based queries
CREATE INDEX idx_expenses_category ON expenses(category_id);

-- Index for faster monthly summary lookups
CREATE INDEX idx_monthly_summaries_year_month ON monthly_summaries(year, month);
```

## Default Categories
Initial categories to be inserted when the database is first created:

```sql
INSERT INTO categories (name, color, icon) VALUES
    ('Food & Dining', '#FF5722', 'restaurant'),
    ('Transportation', '#2196F3', 'directions_car'),
    ('Shopping', '#9C27B0', 'shopping_cart'),
    ('Bills & Utilities', '#F44336', 'receipt'),
    ('Entertainment', '#4CAF50', 'movie'),
    ('Health', '#00BCD4', 'local_hospital'),
    ('Education', '#FFC107', 'school'),
    ('Other', '#9E9E9E', 'more_horiz');
```

## Database Version Management

```sql
CREATE TABLE db_version (
    version INTEGER PRIMARY KEY,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

## Triggers

### 1. Update Timestamp Trigger
Automatically updates the `updated_at` timestamp when an expense record is modified:

```sql
CREATE TRIGGER update_expense_timestamp 
AFTER UPDATE ON expenses
BEGIN
    UPDATE expenses SET updated_at = CURRENT_TIMESTAMP
    WHERE id = NEW.id;
END;
```

### 2. Monthly Summary Update Trigger
Updates the monthly summary when an expense is added, modified, or deleted:

```sql
CREATE TRIGGER update_monthly_summary
AFTER INSERT OR UPDATE OR DELETE ON expenses
BEGIN
    -- Update or insert monthly summary
    INSERT INTO monthly_summaries (year, month, total_amount, expense_count)
    SELECT 
        strftime('%Y', date) as year,
        strftime('%m', date) as month,
        SUM(amount) as total_amount,
        COUNT(*) as expense_count
    FROM expenses
    WHERE strftime('%Y', date) = strftime('%Y', NEW.date)
    AND strftime('%m', date) = strftime('%m', NEW.date)
    GROUP BY year, month
    ON CONFLICT(year, month) DO UPDATE SET
        total_amount = excluded.total_amount,
        expense_count = excluded.expense_count,
        last_updated = CURRENT_TIMESTAMP;
END;
```

## Data Integrity Constraints

1. Amount must be positive:
```sql
CREATE TRIGGER check_positive_amount
BEFORE INSERT ON expenses
BEGIN
    SELECT CASE 
        WHEN NEW.amount <= 0 
        THEN RAISE(ABORT, 'Amount must be positive')
    END;
END;
```

2. Date must not be in the future:
```sql
CREATE TRIGGER check_future_date
BEFORE INSERT ON expenses
BEGIN
    SELECT CASE 
        WHEN NEW.date > date('now')
        THEN RAISE(ABORT, 'Date cannot be in the future')
    END;
END;
```

## Backup and Recovery
The database file will be stored in the app's private storage directory:
- Android: `/data/data/com.spendsense/databases/spendsense.db`
- iOS: `/Documents/spendsense.db`

## Notes
1. All monetary values are stored as DECIMAL(10,2) to ensure precise calculations
2. Timestamps are stored in UTC format
3. The schema supports future expansion for features mentioned in the PRD's future scope
4. Indexes are created to optimize common query patterns
5. Triggers maintain data consistency and automate summary calculations 