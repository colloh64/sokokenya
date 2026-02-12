-- ==========================================
-- EXTENSIONS
-- ==========================================
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ==========================================
-- PROFILES TABLE (User Management)
-- ==========================================
CREATE TABLE profiles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(20) UNIQUE NOT NULL,
    full_name VARCHAR(255) NOT NULL,
    business_name VARCHAR(255),
    business_description TEXT,
    county VARCHAR(100) NOT NULL,
    constituency VARCHAR(100) NOT NULL,
    ward VARCHAR(100) NOT NULL,
    exact_location TEXT NOT NULL,
    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'suspended', 'pending', 'banned')),
    role VARCHAR(20) DEFAULT 'seller' CHECK (role IN ('seller', 'admin', 'moderator')),
    is_verified BOOLEAN DEFAULT FALSE,
    verification_status VARCHAR(20) DEFAULT 'unverified' CHECK (verification_status IN ('unverified', 'pending', 'approved', 'rejected')),
    id_number VARCHAR(50),
    id_document_front TEXT,
    id_document_back TEXT,
    id_selfie TEXT,
    business_registration VARCHAR(100),
    current_plan VARCHAR(20) DEFAULT 'starter' CHECK (current_plan IN ('starter', 'pro', 'premium')),
    plan_expires_at TIMESTAMP WITH TIME ZONE,
    subscription_status VARCHAR(20) DEFAULT 'inactive' CHECK (subscription_status IN ('active', 'inactive', 'pending', 'cancelled')),
    uploads_this_week INTEGER DEFAULT 0,
    max_uploads INTEGER DEFAULT 2,
    week_reset_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    total_products INTEGER DEFAULT 0,
    total_views INTEGER DEFAULT 0,
    total_sales INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    last_login TIMESTAMP WITH TIME ZONE,
    suspended_until TIMESTAMP WITH TIME ZONE,
    suspension_reason TEXT,
    suspension_count INTEGER DEFAULT 0
);

-- ==========================================
-- PRODUCTS TABLE
-- ==========================================
CREATE TABLE products (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    seller_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    category VARCHAR(100) NOT NULL,
    condition VARCHAR(50) NOT NULL CHECK (condition IN ('New', 'Used - Like New', 'Used - Good', 'Used - Fair', 'Refurbished')),
    price DECIMAL(12, 2) NOT NULL,
    county VARCHAR(100) NOT NULL,
    constituency VARCHAR(100) NOT NULL,
    ward VARCHAR(100) NOT NULL,
    exact_location TEXT NOT NULL,
    main_image TEXT NOT NULL,
    additional_images TEXT[] DEFAULT '{}',
    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'sold', 'reserved', 'hidden', 'deleted')),
    is_boosted BOOLEAN DEFAULT FALSE,
    boost_type VARCHAR(20),
    boost_expires_at TIMESTAMP WITH TIME ZONE,
    boost_payment_code VARCHAR(100),
    views INTEGER DEFAULT 0,
    contact_clicks INTEGER DEFAULT 0,
    wishlist_count INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    sold_at TIMESTAMP WITH TIME ZONE
);

-- ==========================================
-- PRODUCT IMAGES TABLE
-- ==========================================
CREATE TABLE product_images (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    product_id UUID REFERENCES products(id) ON DELETE CASCADE,
    image_url TEXT NOT NULL,
    is_main BOOLEAN DEFAULT FALSE,
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ==========================================
-- SUBSCRIPTIONS TABLE
-- ==========================================
CREATE TABLE subscriptions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    seller_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    plan_type VARCHAR(20) NOT NULL CHECK (plan_type IN ('starter', 'pro', 'premium')),
    billing_cycle VARCHAR(20) NOT NULL CHECK (billing_cycle IN ('monthly', 'annual')),
    amount DECIMAL(10, 2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'KES',
    payment_method VARCHAR(50),
    payment_code VARCHAR(100),
    payment_status VARCHAR(20) DEFAULT 'pending' CHECK (payment_status IN ('pending', 'completed', 'failed', 'refunded')),
    starts_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    expires_at TIMESTAMP WITH TIME ZONE,
    is_active BOOLEAN DEFAULT FALSE,
    auto_renew BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ==========================================
-- BOOST PURCHASES TABLE
-- ==========================================
CREATE TABLE boost_purchases (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    seller_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    product_id UUID REFERENCES products(id) ON DELETE CASCADE,
    boost_type VARCHAR(20) NOT NULL CHECK (boost_type IN ('1day', '5day', '10day', '30day')),
    price DECIMAL(10, 2) NOT NULL,
    expected_reach INTEGER NOT NULL,
    payment_code VARCHAR(100),
    payment_status VARCHAR(20) DEFAULT 'pending' CHECK (payment_status IN ('pending', 'completed', 'failed')),
    starts_at TIMESTAMP WITH TIME ZONE,
    expires_at TIMESTAMP WITH TIME ZONE,
    actual_views INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ==========================================
-- MESSAGES / INBOX
-- ==========================================
CREATE TABLE messages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    sender_id UUID REFERENCES profiles(id) ON DELETE SET NULL,
    sender_type VARCHAR(20) DEFAULT 'admin' CHECK (sender_type IN ('admin', 'system', 'buyer', 'seller')),
    recipient_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    subject VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    related_type VARCHAR(50),
    related_id UUID,
    is_read BOOLEAN DEFAULT FALSE,
    read_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ==========================================
-- SUSPENSION APPEALS
-- ==========================================
CREATE TABLE suspension_appeals (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    seller_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    appeal_text TEXT NOT NULL,
    supporting_documents TEXT[] DEFAULT '{}',
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected')),
    admin_response TEXT,
    reviewed_by UUID REFERENCES profiles(id),
    reviewed_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ==========================================
-- SELLER NOTEBOOKS
-- ==========================================
CREATE TABLE seller_notebooks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    seller_id UUID REFERENCES profiles(id) ON DELETE CASCADE UNIQUE,
    content TEXT DEFAULT '',
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ==========================================
-- ANALYTICS DAILY
-- ==========================================
CREATE TABLE analytics_daily (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    seller_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    date DATE NOT NULL,
    product_views INTEGER DEFAULT 0,
    contact_clicks INTEGER DEFAULT 0,
    new_listings INTEGER DEFAULT 0,
    UNIQUE(seller_id, date)
);

-- ==========================================
-- WISHLISTS
-- ==========================================
CREATE TABLE wishlists (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    product_id UUID REFERENCES products(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, product_id)
);

-- ==========================================
-- REPORTS
-- ==========================================
CREATE TABLE reports (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    reporter_id UUID REFERENCES profiles(id) ON DELETE SET NULL,
    reported_seller_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    product_id UUID REFERENCES products(id) ON DELETE SET NULL,
    reason VARCHAR(50) NOT NULL CHECK (reason IN ('scam', 'fake', 'misleading', 'other')),
    description TEXT,
    evidence_urls TEXT[] DEFAULT '{}',
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'investigating', 'resolved', 'dismissed')),
    admin_notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    resolved_at TIMESTAMP WITH TIME ZONE
);

-- ==========================================
-- ADMIN LOGS
-- ==========================================
CREATE TABLE admin_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    admin_id UUID REFERENCES profiles(id),
    action_type VARCHAR(50) NOT NULL,
    target_type VARCHAR(50) NOT NULL,
    target_id UUID,
    details JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ==========================================
-- INDEXES
-- ==========================================
CREATE INDEX idx_products_seller ON products(seller_id);
CREATE INDEX idx_products_status ON products(status);
CREATE INDEX idx_products_county ON products(county);
CREATE INDEX idx_products_boosted ON products(is_boosted) WHERE is_boosted = TRUE;
CREATE INDEX idx_products_category ON products(category);
CREATE INDEX idx_products_price ON products(price);
CREATE INDEX idx_messages_recipient ON messages(recipient_id, is_read);
CREATE INDEX idx_subscriptions_seller ON subscriptions(seller_id, is_active);
CREATE INDEX idx_boost_purchases_seller ON boost_purchases(seller_id, is_active);
CREATE INDEX idx_reports_status ON reports(status);

-- ==========================================
-- FUNCTIONS & TRIGGERS
-- ==========================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_profiles_updated_at BEFORE UPDATE ON profiles
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_products_updated_at BEFORE UPDATE ON products
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_subscriptions_updated_at BEFORE UPDATE ON subscriptions
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE OR REPLACE FUNCTION reset_weekly_uploads()
RETURNS void AS $$
BEGIN
    UPDATE profiles
    SET uploads_this_week = 0,
        week_reset_at = NOW()
    WHERE week_reset_at < NOW() - INTERVAL '7 days';
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION increment_product_views(product_uuid UUID)
RETURNS void AS $$
BEGIN
    UPDATE products
    SET views = views + 1
    WHERE id = product_uuid;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION check_subscription_status()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE subscriptions
    SET is_active = FALSE
    WHERE expires_at < NOW() AND is_active = TRUE;
    UPDATE profiles p
    SET current_plan = 'starter',
        max_uploads = 2
    FROM subscriptions s
    WHERE p.id = s.seller_id
    AND s.is_active = FALSE
    AND p.current_plan != 'starter';
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- ==========================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- ==========================================
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE subscriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE boost_purchases ENABLE ROW LEVEL SECURITY;
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE seller_notebooks ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own profile"
    ON profiles FOR SELECT
    USING (auth.uid() = id OR EXISTS (
        SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin'
    ));

CREATE POLICY "Users can update own profile"
    ON profiles FOR UPDATE
    USING (auth.uid() = id);

CREATE POLICY "Sellers can manage own products"
    ON products FOR ALL
    USING (seller_id = auth.uid());

CREATE POLICY "Public can view active products"
    ON products FOR SELECT
    USING (status = 'active');

CREATE POLICY "Sellers can view own subscriptions"
    ON subscriptions FOR SELECT
    USING (seller_id = auth.uid());

CREATE POLICY "Users can view own messages"
    ON messages FOR SELECT
    USING (recipient_id = auth.uid() OR sender_id = auth.uid());

CREATE POLICY "Sellers can manage own notebook"
    ON seller_notebooks FOR ALL
    USING (seller_id = auth.uid());

-- ==========================================
-- VIEWS
-- ==========================================
CREATE VIEW active_products_with_sellers AS
SELECT 
    p.*,
    pr.full_name as seller_name,
    pr.is_verified as seller_verified,
    pr.phone as seller_phone,
    pr.county as seller_county
FROM products p
JOIN profiles pr ON p.seller_id = pr.id
WHERE p.status = 'active';

CREATE VIEW seller_dashboard_summary AS
SELECT 
    p.id,
    p.full_name,
    p.business_name,
    p.status,
    p.is_verified,
    p.current_plan,
    p.subscription_status,
    p.uploads_this_week,
    p.max_uploads,
    p.total_products,
    p.total_views,
    COUNT(DISTINCT prod.id) as active_products,
    COUNT(DISTINCT b.id) as active_boosts,
    COUNT(DISTINCT m.id) FILTER (WHERE m.is_read = FALSE) as unread_messages
FROM profiles p
LEFT JOIN products prod ON p.id = prod.seller_id AND prod.status = 'active'
LEFT JOIN boost_purchases b ON p.id = b.seller_id AND b.is_active = TRUE
LEFT JOIN messages m ON p.id = m.recipient_id
GROUP BY p.id;

-- ==========================================
-- SEED ADMIN USERS
-- ==========================================
INSERT INTO profiles (email, phone, full_name, role, status, is_verified)
VALUES 
    ('admin@resellkenya.co.ke', '0700000000', 'System Admin', 'admin', 'active', TRUE),
    ('globalventures809@gmail.com', '0718397891', 'Main Admin', 'admin', 'active', TRUE)
ON CONFLICT (email) DO NOTHING;
