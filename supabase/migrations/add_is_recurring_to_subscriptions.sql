-- Add is_recurring column to subscriptions table
ALTER TABLE subscriptions ADD COLUMN is_recurring BOOLEAN DEFAULT TRUE;

-- Update existing records to be recurring by default
UPDATE subscriptions SET is_recurring = TRUE;
