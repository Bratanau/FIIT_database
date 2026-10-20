-- Часть 4. Комплексный аналитический отчет с использованием CTE.
-- Вопрос для руководителя: как меняются объем продаж и число покупателей по месяцам?

WITH eligible_orders AS (
    -- На вход поступают заказы, не отмененные магазином.
    SELECT
        order_id,
        customer_id,
        order_date,
        status
    FROM orders
    WHERE status <> 'cancelled'
),
order_line_metrics AS (
    -- Состав заказа агрегируется до одной строки на заказ.
    SELECT
        oi.order_id,
        SUM(oi.quantity) AS units_sold,
        SUM(oi.quantity * oi.unit_price)::NUMERIC(14, 2) AS item_revenue,
        COUNT(*) AS line_count
    FROM order_items AS oi
    GROUP BY oi.order_id
),
order_metrics AS (
    -- Заказы соединяются с покупателями и агрегированными позициями.
    -- LEFT JOIN сохраняет заказы без позиций; их выручка равна нулю.
    SELECT
        eo.order_id,
        eo.customer_id,
        eo.order_date,
        eo.status,
        COALESCE(olm.units_sold, 0) AS units_sold,
        COALESCE(olm.item_revenue, 0)::NUMERIC(14, 2) AS item_revenue,
        COALESCE(olm.line_count, 0) AS line_count
    FROM eligible_orders AS eo
    LEFT JOIN order_line_metrics AS olm ON olm.order_id = eo.order_id
),
monthly_metrics AS (
    -- Промежуточные показатели сгруппированы по месяцу.
    SELECT
        DATE_TRUNC('month', om.order_date)::DATE AS sales_month,
        COUNT(*) AS order_count,
        COUNT(DISTINCT om.customer_id) AS customer_count,
        SUM(om.units_sold) AS units_sold,
        SUM(om.item_revenue)::NUMERIC(14, 2) AS revenue,
        ROUND(AVG(om.item_revenue), 2) AS average_revenue_per_order,
        SUM(om.line_count) AS order_line_count
    FROM order_metrics AS om
    GROUP BY DATE_TRUNC('month', om.order_date)
),
month_comparison AS (
    -- LAG добавляет выручку предыдущего месяца для сравнения динамики.
    SELECT
        mm.*,
        LAG(mm.revenue) OVER (ORDER BY mm.sales_month) AS previous_month_revenue
    FROM monthly_metrics AS mm
)
SELECT
    sales_month,
    order_count,
    customer_count,
    units_sold,
    order_line_count,
    revenue,
    average_revenue_per_order,
    previous_month_revenue,
    (revenue - previous_month_revenue)::NUMERIC(14, 2) AS revenue_change,
    ROUND(
        100 * (revenue - previous_month_revenue)
        / NULLIF(previous_month_revenue, 0),
        2
    ) AS revenue_change_percent
FROM month_comparison
ORDER BY sales_month;
