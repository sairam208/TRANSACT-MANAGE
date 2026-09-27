-- ============================================================
-- TRANSACT-MANAGE
-- Initial Database Schema
-- ============================================================


-- ============================================================
-- 1. PROFILES
-- Links application user information to Supabase Auth users
-- ============================================================

CREATE TABLE public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,

    full_name TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);


-- ============================================================
-- 2. CATEGORIES
-- Example: Food, Travel, Shopping, Education
-- ============================================================

CREATE TABLE public.categories (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    name TEXT NOT NULL UNIQUE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);


-- ============================================================
-- 3. PAYMENT METHODS
-- Example: Cash, UPI, Credit Card
-- ============================================================

CREATE TABLE public.payment_methods (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    name TEXT NOT NULL UNIQUE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);


-- ============================================================
-- 4. TRANSACTIONS
-- One row represents one complete bill/payment
-- ============================================================

CREATE TABLE public.transactions (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    user_id UUID NOT NULL
        REFERENCES public.profiles(id)
        ON DELETE CASCADE,

    category_id BIGINT
        REFERENCES public.categories(id)
        ON DELETE SET NULL,

    payment_method_id BIGINT
        REFERENCES public.payment_methods(id)
        ON DELETE SET NULL,

    transaction_date TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    -- How the date was obtained:
    -- bill / user / today
    date_source TEXT NOT NULL DEFAULT 'today',

    merchant_name TEXT,

    description TEXT,

    total_amount NUMERIC(12,2) NOT NULL,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT transactions_total_amount_positive
        CHECK (total_amount >= 0),

    CONSTRAINT transactions_date_source_valid
        CHECK (date_source IN ('bill', 'user', 'today'))
);


-- ============================================================
-- 5. TRANSACTION ITEMS
-- Individual items inside a transaction/bill
-- ============================================================

CREATE TABLE public.transaction_items (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    transaction_id BIGINT NOT NULL
        REFERENCES public.transactions(id)
        ON DELETE CASCADE,

    item_name TEXT NOT NULL,

    quantity NUMERIC(10,2) NOT NULL DEFAULT 1,

    unit_price NUMERIC(12,2) NOT NULL,

    total_price NUMERIC(12,2) NOT NULL,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT transaction_items_quantity_positive
        CHECK (quantity > 0),

    CONSTRAINT transaction_items_unit_price_positive
        CHECK (unit_price >= 0),

    CONSTRAINT transaction_items_total_price_positive
        CHECK (total_price >= 0)
);


-- ============================================================
-- INDEXES
-- Optimized for AI queries and normal application queries
-- ============================================================

CREATE INDEX idx_transactions_user_date
ON public.transactions(user_id, transaction_date);


CREATE INDEX idx_transactions_user_category_date
ON public.transactions(user_id, category_id, transaction_date);


CREATE INDEX idx_transactions_payment_method
ON public.transactions(payment_method_id);


CREATE INDEX idx_transaction_items_transaction
ON public.transaction_items(transaction_id);


CREATE INDEX idx_transaction_items_name
ON public.transaction_items(item_name);


-- ============================================================
-- INITIAL CATEGORIES
-- ============================================================

INSERT INTO public.categories (name)
VALUES
    ('Food'),
    ('Travel'),
    ('Shopping'),
    ('Education'),
    ('Entertainment'),
    ('Bills'),
    ('Healthcare'),
    ('Groceries'),
    ('Other');


-- ============================================================
-- INITIAL PAYMENT METHODS
-- ============================================================

INSERT INTO public.payment_methods (name)
VALUES
    ('Cash'),
    ('UPI'),
    ('Credit Card'),
    ('Debit Card'),
    ('Net Banking'),
    ('Other');