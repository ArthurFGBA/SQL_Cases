with base as (
select distinct(go.city) from OPS_GLOBAL.GLOBAL_ORDERS GO where go.country='BR' and order_state ilike '%Cancel%'
),

Finished AS (
SELECT distinct(go.city), COUNT(distinct GO.ORDER_ID) as finished_orders
FROM OPS_GLOBAL.GLOBAL_ORDERS GO 
WHERE GO.ORDER_STATE ilike any ('%finish%','%pending%') --and GO.count_to_gmv = TRUE
and go.created_at between current_date-60 and current_date-1 
and go.country='BR'
and go.store_name ilike'%McDonald%'
and go.storekeeper_id is not null
group by 1 
order by 2 desc 
),

Cancel as (
SELECT distinct(go.city), COUNT(distinct GO.ORDER_ID) as canceled_orders
FROM OPS_GLOBAL.GLOBAL_ORDERS GO 
WHERE GO.ORDER_STATE ilike any ('%cancel%')
and go.created_at between current_date-60 and current_date-1 
and go.country='BR'
and go.store_name ilike'%McDonald%'
and go.storekeeper_id is not null
group by 1 
order by 2 desc
), 

Release as (
SELECT distinct(go.city), COUNT(distinct GO.ORDER_ID) as released_orders
FROM OPS_GLOBAL.GLOBAL_ORDERS GO left join br_core_orders_public.order_modifications mod on mod.order_id=go.order_id
WHERE  mod.type = 'release_storekeeper'
and go.created_at between current_date-60 and current_date-1 
and go.country='BR'
and go.store_name ilike'%McDonald%' 
and go.storekeeper_id is not null
group by 1 
order by 2 desc
)

select b.city, f.finished_orders, c.canceled_orders, r.released_orders from base b 
left join finished f on b.city = f.city
left join cancel c on  b.city=c.city 
left join release r on  b.city = r.city 
order by 3 desc