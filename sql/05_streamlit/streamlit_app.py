"""
MerchMasters: Tournament Merchandise Dashboard
===============================================
A Streamlit in Snowflake dashboard for golf shop merchandise analytics.

Author: SE Community
Expires: 2025-12-31
"""

import streamlit as st
import pandas as pd
from snowflake.snowpark.context import get_active_session

# =============================================================================
# PAGE CONFIGURATION
# =============================================================================
st.set_page_config(
    page_title="MerchMasters Dashboard",
    page_icon="⛳",
    layout="wide",
    initial_sidebar_state="expanded"
)

# =============================================================================
# CUSTOM STYLING
# =============================================================================
st.markdown("""
<style>
    /* Main theme - Golf green inspired */
    .stApp {
        background: linear-gradient(180deg, #f8faf8 0%, #e8f5e9 100%);
    }
    
    /* Header styling */
    .main-header {
        background: linear-gradient(135deg, #1b5e20 0%, #2e7d32 50%, #388e3c 100%);
        padding: 1.5rem 2rem;
        border-radius: 12px;
        margin-bottom: 1.5rem;
        box-shadow: 0 4px 12px rgba(27, 94, 32, 0.3);
    }
    
    .main-header h1 {
        color: white;
        margin: 0;
        font-size: 2rem;
        font-weight: 600;
        letter-spacing: -0.5px;
    }
    
    .main-header p {
        color: rgba(255, 255, 255, 0.9);
        margin: 0.5rem 0 0 0;
        font-size: 1rem;
    }
    
    /* KPI Cards */
    .kpi-card {
        background: white;
        padding: 1.25rem;
        border-radius: 10px;
        box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
        border-left: 4px solid #2e7d32;
        transition: transform 0.2s, box-shadow 0.2s;
    }
    
    .kpi-card:hover {
        transform: translateY(-2px);
        box-shadow: 0 4px 16px rgba(0, 0, 0, 0.12);
    }
    
    .kpi-value {
        font-size: 2rem;
        font-weight: 700;
        color: #1b5e20;
        margin: 0;
    }
    
    .kpi-label {
        font-size: 0.875rem;
        color: #666;
        text-transform: uppercase;
        letter-spacing: 0.5px;
        margin-top: 0.25rem;
    }
    
    .kpi-delta-positive {
        color: #2e7d32;
        font-size: 0.875rem;
        font-weight: 500;
    }
    
    .kpi-delta-negative {
        color: #c62828;
        font-size: 0.875rem;
        font-weight: 500;
    }
    
    /* Section headers */
    .section-header {
        font-size: 1.25rem;
        font-weight: 600;
        color: #1b5e20;
        margin: 1.5rem 0 1rem 0;
        padding-bottom: 0.5rem;
        border-bottom: 2px solid #c8e6c9;
    }
    
    /* Alert cards */
    .alert-critical {
        background: #ffebee;
        border-left: 4px solid #c62828;
        padding: 0.75rem 1rem;
        border-radius: 6px;
        margin: 0.5rem 0;
    }
    
    .alert-warning {
        background: #fff8e1;
        border-left: 4px solid #f9a825;
        padding: 0.75rem 1rem;
        border-radius: 6px;
        margin: 0.5rem 0;
    }
    
    .alert-success {
        background: #e8f5e9;
        border-left: 4px solid #2e7d32;
        padding: 0.75rem 1rem;
        border-radius: 6px;
        margin: 0.5rem 0;
    }
    
    /* Data tables */
    .dataframe {
        font-size: 0.875rem;
    }
    
    /* Sidebar */
    .css-1d391kg {
        background: #f1f8e9;
    }
    
    /* Hide Streamlit branding */
    #MainMenu {visibility: hidden;}
    footer {visibility: hidden;}
</style>
""", unsafe_allow_html=True)

# =============================================================================
# DATABASE CONNECTION
# =============================================================================
@st.cache_resource
def get_session():
    """Get the Snowflake session."""
    return get_active_session()

session = get_session()

# =============================================================================
# DATA QUERIES
# =============================================================================
@st.cache_data(ttl=300)  # Cache for 5 minutes
def get_kpi_summary(tournament_year: int) -> pd.DataFrame:
    """Get high-level KPIs for the selected tournament year."""
    query = f"""
    SELECT 
        SUM(total_amount) AS total_revenue,
        SUM(quantity_sold) AS total_units,
        SUM(gross_margin) AS total_margin,
        COUNT(DISTINCT transaction_id) AS transaction_count,
        AVG(total_amount) AS avg_transaction_value,
        COUNT(DISTINCT style_number) AS products_sold
    FROM SNOWFLAKE_EXAMPLE.SFE_MERCH_ANALYTICS.SFE_FCT_SALES s
    JOIN SNOWFLAKE_EXAMPLE.SFE_MERCH_ANALYTICS.SFE_DIM_TOURNAMENTS t 
        ON s.tournament_id = t.tournament_id
    WHERE t.tournament_year = {tournament_year}
    """
    return session.sql(query).to_pandas()

@st.cache_data(ttl=300)
def get_yoy_comparison() -> pd.DataFrame:
    """Get year-over-year comparison metrics."""
    query = """
    SELECT 
        t.tournament_year,
        SUM(s.total_amount) AS revenue,
        SUM(s.quantity_sold) AS units,
        SUM(s.gross_margin) AS margin,
        COUNT(DISTINCT s.transaction_id) AS transactions
    FROM SNOWFLAKE_EXAMPLE.SFE_MERCH_ANALYTICS.SFE_FCT_SALES s
    JOIN SNOWFLAKE_EXAMPLE.SFE_MERCH_ANALYTICS.SFE_DIM_TOURNAMENTS t 
        ON s.tournament_id = t.tournament_id
    GROUP BY t.tournament_year
    ORDER BY t.tournament_year
    """
    return session.sql(query).to_pandas()

@st.cache_data(ttl=300)
def get_daily_sales(tournament_year: int) -> pd.DataFrame:
    """Get daily sales trend for the selected tournament."""
    query = f"""
    SELECT 
        d.full_date,
        d.tournament_day_label,
        d.day_name,
        SUM(s.total_amount) AS revenue,
        SUM(s.quantity_sold) AS units,
        COUNT(DISTINCT s.transaction_id) AS transactions
    FROM SNOWFLAKE_EXAMPLE.SFE_MERCH_ANALYTICS.SFE_FCT_SALES s
    JOIN SNOWFLAKE_EXAMPLE.SFE_MERCH_ANALYTICS.SFE_DIM_DATES d 
        ON s.date_key = d.date_key
    JOIN SNOWFLAKE_EXAMPLE.SFE_MERCH_ANALYTICS.SFE_DIM_TOURNAMENTS t 
        ON s.tournament_id = t.tournament_id
    WHERE t.tournament_year = {tournament_year}
    GROUP BY d.full_date, d.tournament_day_label, d.day_name
    ORDER BY d.full_date
    """
    return session.sql(query).to_pandas()

@st.cache_data(ttl=300)
def get_category_sales(tournament_year: int) -> pd.DataFrame:
    """Get sales breakdown by category."""
    query = f"""
    SELECT 
        p.category,
        SUM(s.total_amount) AS revenue,
        SUM(s.quantity_sold) AS units,
        SUM(s.gross_margin) AS margin,
        COUNT(DISTINCT s.transaction_id) AS transactions,
        COUNT(DISTINCT p.style_number) AS products
    FROM SNOWFLAKE_EXAMPLE.SFE_MERCH_ANALYTICS.SFE_FCT_SALES s
    JOIN SNOWFLAKE_EXAMPLE.SFE_MERCH_ANALYTICS.SFE_DIM_PRODUCTS p 
        ON s.style_number = p.style_number
    JOIN SNOWFLAKE_EXAMPLE.SFE_MERCH_ANALYTICS.SFE_DIM_TOURNAMENTS t 
        ON s.tournament_id = t.tournament_id
    WHERE t.tournament_year = {tournament_year}
    GROUP BY p.category
    ORDER BY revenue DESC
    """
    return session.sql(query).to_pandas()

@st.cache_data(ttl=300)
def get_location_sales(tournament_year: int) -> pd.DataFrame:
    """Get sales breakdown by location."""
    query = f"""
    SELECT 
        l.location_name,
        l.location_type,
        SUM(s.total_amount) AS revenue,
        SUM(s.quantity_sold) AS units,
        COUNT(DISTINCT s.transaction_id) AS transactions,
        AVG(s.total_amount) AS avg_transaction
    FROM SNOWFLAKE_EXAMPLE.SFE_MERCH_ANALYTICS.SFE_FCT_SALES s
    JOIN SNOWFLAKE_EXAMPLE.SFE_MERCH_ANALYTICS.SFE_DIM_LOCATIONS l 
        ON s.location_id = l.location_id
    JOIN SNOWFLAKE_EXAMPLE.SFE_MERCH_ANALYTICS.SFE_DIM_TOURNAMENTS t 
        ON s.tournament_id = t.tournament_id
    WHERE t.tournament_year = {tournament_year}
    GROUP BY l.location_name, l.location_type
    ORDER BY revenue DESC
    """
    return session.sql(query).to_pandas()

@st.cache_data(ttl=300)
def get_top_products(tournament_year: int, limit: int = 10) -> pd.DataFrame:
    """Get top selling products."""
    query = f"""
    SELECT 
        p.style_number,
        p.product_name,
        p.category,
        p.vendor,
        SUM(s.total_amount) AS revenue,
        SUM(s.quantity_sold) AS units,
        SUM(s.gross_margin) AS margin,
        ROUND(SUM(s.gross_margin) / NULLIF(SUM(s.total_amount), 0) * 100, 1) AS margin_pct
    FROM SNOWFLAKE_EXAMPLE.SFE_MERCH_ANALYTICS.SFE_FCT_SALES s
    JOIN SNOWFLAKE_EXAMPLE.SFE_MERCH_ANALYTICS.SFE_DIM_PRODUCTS p 
        ON s.style_number = p.style_number
    JOIN SNOWFLAKE_EXAMPLE.SFE_MERCH_ANALYTICS.SFE_DIM_TOURNAMENTS t 
        ON s.tournament_id = t.tournament_id
    WHERE t.tournament_year = {tournament_year}
    GROUP BY p.style_number, p.product_name, p.category, p.vendor
    ORDER BY revenue DESC
    LIMIT {limit}
    """
    return session.sql(query).to_pandas()

@st.cache_data(ttl=300)
def get_inventory_status(tournament_year: int) -> pd.DataFrame:
    """Get current inventory status with alerts."""
    query = f"""
    WITH latest_inventory AS (
        SELECT 
            i.style_number,
            i.location_id,
            i.ending_qty,
            i.stock_status,
            i.inventory_value_retail,
            ROW_NUMBER() OVER (
                PARTITION BY i.style_number, i.location_id 
                ORDER BY i.snapshot_date DESC
            ) AS rn
        FROM SNOWFLAKE_EXAMPLE.SFE_MERCH_ANALYTICS.SFE_FCT_INVENTORY i
        JOIN SNOWFLAKE_EXAMPLE.SFE_MERCH_ANALYTICS.SFE_DIM_TOURNAMENTS t 
            ON i.tournament_id = t.tournament_id
        WHERE t.tournament_year = {tournament_year}
    )
    SELECT 
        p.style_number,
        p.product_name,
        p.category,
        l.location_name,
        li.ending_qty AS on_hand,
        li.stock_status,
        li.inventory_value_retail AS value
    FROM latest_inventory li
    JOIN SNOWFLAKE_EXAMPLE.SFE_MERCH_ANALYTICS.SFE_DIM_PRODUCTS p 
        ON li.style_number = p.style_number
    JOIN SNOWFLAKE_EXAMPLE.SFE_MERCH_ANALYTICS.SFE_DIM_LOCATIONS l 
        ON li.location_id = l.location_id
    WHERE li.rn = 1
    ORDER BY 
        CASE li.stock_status 
            WHEN 'Critical' THEN 1 
            WHEN 'Low' THEN 2 
            WHEN 'Medium' THEN 3 
            ELSE 4 
        END,
        li.ending_qty
    """
    return session.sql(query).to_pandas()

@st.cache_data(ttl=300)
def get_vendor_performance(tournament_year: int) -> pd.DataFrame:
    """Get vendor performance metrics."""
    query = f"""
    SELECT 
        p.vendor,
        COUNT(DISTINCT p.style_number) AS products,
        SUM(s.total_amount) AS revenue,
        SUM(s.quantity_sold) AS units,
        SUM(s.gross_margin) AS margin,
        ROUND(SUM(s.gross_margin) / NULLIF(SUM(s.total_amount), 0) * 100, 1) AS margin_pct
    FROM SNOWFLAKE_EXAMPLE.SFE_MERCH_ANALYTICS.SFE_FCT_SALES s
    JOIN SNOWFLAKE_EXAMPLE.SFE_MERCH_ANALYTICS.SFE_DIM_PRODUCTS p 
        ON s.style_number = p.style_number
    JOIN SNOWFLAKE_EXAMPLE.SFE_MERCH_ANALYTICS.SFE_DIM_TOURNAMENTS t 
        ON s.tournament_id = t.tournament_id
    WHERE t.tournament_year = {tournament_year}
    GROUP BY p.vendor
    ORDER BY revenue DESC
    """
    return session.sql(query).to_pandas()

# =============================================================================
# HELPER FUNCTIONS
# =============================================================================
def format_currency(value: float) -> str:
    """Format value as currency."""
    if value >= 1_000_000:
        return f"${value/1_000_000:.1f}M"
    elif value >= 1_000:
        return f"${value/1_000:.1f}K"
    else:
        return f"${value:.0f}"

def format_number(value: float) -> str:
    """Format large numbers with K/M suffix."""
    if value >= 1_000_000:
        return f"{value/1_000_000:.1f}M"
    elif value >= 1_000:
        return f"{value/1_000:.1f}K"
    else:
        return f"{value:.0f}"

def calculate_yoy_change(current: float, prior: float) -> tuple:
    """Calculate year-over-year change and return (change_pct, is_positive)."""
    if prior == 0:
        return (0, True)
    change = ((current - prior) / prior) * 100
    return (change, change >= 0)

# =============================================================================
# SIDEBAR
# =============================================================================
with st.sidebar:
    st.markdown("### 🏌️ Tournament Selection")
    
    tournament_year = st.selectbox(
        "Select Tournament Year",
        options=[2025, 2024],
        index=0,
        help="Choose the tournament year to analyze"
    )
    
    st.markdown("---")
    
    st.markdown("### 📊 Dashboard Sections")
    show_summary = st.checkbox("Executive Summary", value=True)
    show_sales = st.checkbox("Sales Performance", value=True)
    show_inventory = st.checkbox("Inventory Status", value=True)
    show_products = st.checkbox("Product Analysis", value=True)
    show_locations = st.checkbox("Location Analysis", value=True)
    
    st.markdown("---")
    
    st.markdown("### ℹ️ About")
    st.markdown("""
    **MerchMasters Dashboard**  
    Tournament Merchandise Analytics
    
    *Author:* SE Community  
    *Expires:* 2025-12-31
    """)

# =============================================================================
# MAIN HEADER
# =============================================================================
st.markdown("""
<div class="main-header">
    <h1>⛳ MerchMasters Dashboard</h1>
    <p>Tournament Merchandise Intelligence • Real-time Analytics</p>
</div>
""", unsafe_allow_html=True)

# =============================================================================
# EXECUTIVE SUMMARY SECTION
# =============================================================================
if show_summary:
    st.markdown('<div class="section-header">📈 Executive Summary</div>', unsafe_allow_html=True)
    
    # Get data
    kpi_df = get_kpi_summary(tournament_year)
    yoy_df = get_yoy_comparison()
    
    # Calculate YoY changes
    current_data = yoy_df[yoy_df['TOURNAMENT_YEAR'] == tournament_year].iloc[0] if len(yoy_df[yoy_df['TOURNAMENT_YEAR'] == tournament_year]) > 0 else None
    prior_data = yoy_df[yoy_df['TOURNAMENT_YEAR'] == tournament_year - 1].iloc[0] if len(yoy_df[yoy_df['TOURNAMENT_YEAR'] == tournament_year - 1]) > 0 else None
    
    # KPI Cards
    col1, col2, col3, col4 = st.columns(4)
    
    with col1:
        revenue = kpi_df['TOTAL_REVENUE'].iloc[0] if len(kpi_df) > 0 else 0
        if prior_data is not None and current_data is not None:
            change, is_positive = calculate_yoy_change(current_data['REVENUE'], prior_data['REVENUE'])
            delta_html = f'<span class="kpi-delta-{"positive" if is_positive else "negative"}">{"↑" if is_positive else "↓"} {abs(change):.1f}% YoY</span>'
        else:
            delta_html = ""
        st.markdown(f"""
        <div class="kpi-card">
            <p class="kpi-value">{format_currency(revenue)}</p>
            <p class="kpi-label">Total Revenue</p>
            {delta_html}
        </div>
        """, unsafe_allow_html=True)
    
    with col2:
        units = kpi_df['TOTAL_UNITS'].iloc[0] if len(kpi_df) > 0 else 0
        if prior_data is not None and current_data is not None:
            change, is_positive = calculate_yoy_change(current_data['UNITS'], prior_data['UNITS'])
            delta_html = f'<span class="kpi-delta-{"positive" if is_positive else "negative"}">{"↑" if is_positive else "↓"} {abs(change):.1f}% YoY</span>'
        else:
            delta_html = ""
        st.markdown(f"""
        <div class="kpi-card">
            <p class="kpi-value">{format_number(units)}</p>
            <p class="kpi-label">Units Sold</p>
            {delta_html}
        </div>
        """, unsafe_allow_html=True)
    
    with col3:
        margin = kpi_df['TOTAL_MARGIN'].iloc[0] if len(kpi_df) > 0 else 0
        margin_pct = (margin / revenue * 100) if revenue > 0 else 0
        st.markdown(f"""
        <div class="kpi-card">
            <p class="kpi-value">{format_currency(margin)}</p>
            <p class="kpi-label">Gross Margin ({margin_pct:.1f}%)</p>
        </div>
        """, unsafe_allow_html=True)
    
    with col4:
        transactions = kpi_df['TRANSACTION_COUNT'].iloc[0] if len(kpi_df) > 0 else 0
        avg_value = kpi_df['AVG_TRANSACTION_VALUE'].iloc[0] if len(kpi_df) > 0 else 0
        st.markdown(f"""
        <div class="kpi-card">
            <p class="kpi-value">{format_number(transactions)}</p>
            <p class="kpi-label">Transactions (${avg_value:.0f} avg)</p>
        </div>
        """, unsafe_allow_html=True)

# =============================================================================
# SALES PERFORMANCE SECTION
# =============================================================================
if show_sales:
    st.markdown('<div class="section-header">💰 Sales Performance</div>', unsafe_allow_html=True)
    
    col1, col2 = st.columns(2)
    
    with col1:
        st.markdown("##### Daily Sales Trend")
        daily_df = get_daily_sales(tournament_year)
        if len(daily_df) > 0:
            # Create a simple bar chart
            chart_data = daily_df[['TOURNAMENT_DAY_LABEL', 'REVENUE']].copy()
            chart_data.columns = ['Day', 'Revenue']
            st.bar_chart(chart_data.set_index('Day'))
        else:
            st.info("No daily sales data available")
    
    with col2:
        st.markdown("##### Sales by Category")
        category_df = get_category_sales(tournament_year)
        if len(category_df) > 0:
            # Format for display
            display_df = category_df[['CATEGORY', 'REVENUE', 'UNITS', 'MARGIN']].copy()
            display_df['REVENUE'] = display_df['REVENUE'].apply(lambda x: f"${x:,.0f}")
            display_df['MARGIN'] = display_df['MARGIN'].apply(lambda x: f"${x:,.0f}")
            display_df.columns = ['Category', 'Revenue', 'Units', 'Margin']
            st.dataframe(display_df, use_container_width=True, hide_index=True)
        else:
            st.info("No category data available")

# =============================================================================
# INVENTORY STATUS SECTION
# =============================================================================
if show_inventory:
    st.markdown('<div class="section-header">📦 Inventory Status</div>', unsafe_allow_html=True)
    
    inventory_df = get_inventory_status(tournament_year)
    
    if len(inventory_df) > 0:
        # Summary metrics
        critical_count = len(inventory_df[inventory_df['STOCK_STATUS'] == 'Critical'])
        low_count = len(inventory_df[inventory_df['STOCK_STATUS'] == 'Low'])
        adequate_count = len(inventory_df[inventory_df['STOCK_STATUS'] == 'Adequate'])
        
        col1, col2, col3 = st.columns(3)
        
        with col1:
            if critical_count > 0:
                st.markdown(f"""
                <div class="alert-critical">
                    <strong>🚨 {critical_count} Critical</strong><br>
                    Items with ≤10 units remaining
                </div>
                """, unsafe_allow_html=True)
            else:
                st.markdown("""
                <div class="alert-success">
                    <strong>✓ No Critical Items</strong><br>
                    All items above minimum threshold
                </div>
                """, unsafe_allow_html=True)
        
        with col2:
            if low_count > 0:
                st.markdown(f"""
                <div class="alert-warning">
                    <strong>⚠️ {low_count} Low Stock</strong><br>
                    Items with 11-25 units
                </div>
                """, unsafe_allow_html=True)
            else:
                st.markdown("""
                <div class="alert-success">
                    <strong>✓ Stock Healthy</strong><br>
                    No low stock warnings
                </div>
                """, unsafe_allow_html=True)
        
        with col3:
            st.markdown(f"""
            <div class="alert-success">
                <strong>✓ {adequate_count} Adequate</strong><br>
                Items with healthy stock levels
            </div>
            """, unsafe_allow_html=True)
        
        # Show critical/low items table
        st.markdown("##### Items Requiring Attention")
        attention_df = inventory_df[inventory_df['STOCK_STATUS'].isin(['Critical', 'Low'])].head(15)
        if len(attention_df) > 0:
            display_df = attention_df[['STYLE_NUMBER', 'PRODUCT_NAME', 'CATEGORY', 'LOCATION_NAME', 'ON_HAND', 'STOCK_STATUS']].copy()
            display_df.columns = ['Style', 'Product', 'Category', 'Location', 'On Hand', 'Status']
            st.dataframe(display_df, use_container_width=True, hide_index=True)
        else:
            st.success("No items require immediate attention!")
    else:
        st.info("No inventory data available")

# =============================================================================
# PRODUCT ANALYSIS SECTION
# =============================================================================
if show_products:
    st.markdown('<div class="section-header">🏆 Product Analysis</div>', unsafe_allow_html=True)
    
    col1, col2 = st.columns(2)
    
    with col1:
        st.markdown("##### Top 10 Products by Revenue")
        top_products_df = get_top_products(tournament_year, 10)
        if len(top_products_df) > 0:
            display_df = top_products_df[['STYLE_NUMBER', 'PRODUCT_NAME', 'CATEGORY', 'REVENUE', 'UNITS']].copy()
            display_df['REVENUE'] = display_df['REVENUE'].apply(lambda x: f"${x:,.0f}")
            display_df.columns = ['Style', 'Product', 'Category', 'Revenue', 'Units']
            st.dataframe(display_df, use_container_width=True, hide_index=True)
        else:
            st.info("No product data available")
    
    with col2:
        st.markdown("##### Vendor Performance")
        vendor_df = get_vendor_performance(tournament_year)
        if len(vendor_df) > 0:
            display_df = vendor_df[['VENDOR', 'PRODUCTS', 'REVENUE', 'MARGIN_PCT']].copy()
            display_df['REVENUE'] = display_df['REVENUE'].apply(lambda x: f"${x:,.0f}")
            display_df['MARGIN_PCT'] = display_df['MARGIN_PCT'].apply(lambda x: f"{x:.1f}%")
            display_df.columns = ['Vendor', 'Products', 'Revenue', 'Margin %']
            st.dataframe(display_df, use_container_width=True, hide_index=True)
        else:
            st.info("No vendor data available")

# =============================================================================
# LOCATION ANALYSIS SECTION
# =============================================================================
if show_locations:
    st.markdown('<div class="section-header">📍 Location Analysis</div>', unsafe_allow_html=True)
    
    location_df = get_location_sales(tournament_year)
    
    if len(location_df) > 0:
        col1, col2 = st.columns([2, 1])
        
        with col1:
            st.markdown("##### Revenue by Location")
            chart_data = location_df[['LOCATION_NAME', 'REVENUE']].copy()
            chart_data.columns = ['Location', 'Revenue']
            st.bar_chart(chart_data.set_index('Location'))
        
        with col2:
            st.markdown("##### Location Metrics")
            display_df = location_df[['LOCATION_NAME', 'REVENUE', 'TRANSACTIONS', 'AVG_TRANSACTION']].copy()
            display_df['REVENUE'] = display_df['REVENUE'].apply(lambda x: f"${x:,.0f}")
            display_df['AVG_TRANSACTION'] = display_df['AVG_TRANSACTION'].apply(lambda x: f"${x:.0f}")
            display_df.columns = ['Location', 'Revenue', 'Trans.', 'Avg $']
            st.dataframe(display_df, use_container_width=True, hide_index=True)
    else:
        st.info("No location data available")

# =============================================================================
# FOOTER
# =============================================================================
st.markdown("---")
st.markdown("""
<div style="text-align: center; color: #666; font-size: 0.875rem;">
    <p>MerchMasters Dashboard • Built with Streamlit in Snowflake • Author: SE Community</p>
    <p>⛳ The Championship Invitational • Tournament Merchandise Intelligence</p>
</div>
""", unsafe_allow_html=True)

