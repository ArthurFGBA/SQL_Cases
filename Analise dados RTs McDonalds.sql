with base as 
(select distinct (p.storekeeper_id) as storekeeper_id, lv.city,
CASE    WHEN p.vehicle_tag = 512 THEN 'Bicycle'
        WHEN p.vehicle_tag = 768 THEN 'Motorcycle'
        WHEN p.vehicle_tag = 1024 THEN 'Car'
    END AS vehicle_type,
    lv.level_name as level
from   OPS_GLOBAL.GLOBAL_ORDERS GO 
left join predictions.courier_productivity p  on p.storekeeper_id = go.storekeeper_id
left join ops_global.history_levels lv on lv.storekeeper_id=p.storekeeper_id

where p.storekeeper_id in ()
and lv.level_starts_at = '2024-02-19'
and p.time_frame = '4_dinner'
and p.date >= '2024-02-19'
and lv.country='BR'
group by 1,2,3,4
order by 1,2,3 
), 

Finished AS (
SELECT distinct(storekeeper_id), COUNT(distinct GO.ORDER_ID) as finished_orders
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
SELECT distinct(storekeeper_id), COUNT(distinct GO.ORDER_ID) as canceled_orders
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
SELECT distinct(mod.storekeeper_id), COUNT(distinct GO.ORDER_ID) as released_orders
FROM OPS_GLOBAL.GLOBAL_ORDERS GO 
left join br_core_orders_public.order_modifications mod on mod.order_id=go.order_id
WHERE  mod.type = 'release_storekeeper'
and go.created_at between current_date-60 and current_date-1 
and go.country='BR'
and go.store_name ilike'%McDonald%' 
and go.storekeeper_id is not null
group by 1 
order by 2 desc
)

select b.storekeeper_id, b.city, b.vehicle_type, b.level, f.finished_orders, c.canceled_orders, r.released_orders 
from base b 
left join finished f on b.storekeeper_id = f.storekeeper_id 
left join cancel c on  b.storekeeper_id=c.storekeeper_id 
left join release r on  b.storekeeper_id = r.storekeeper_id 
order by 1
