SELECT TO_CHAR(drd.expected_start_time, 'MM/DD') AS month_day, m.title as shift,dr.id,
(a.first_name ||' ' || a.last_name) as dispatcher_name, d.id as driver_id,
    (d.first_name || ' ' || d.last_name) as driver_name, rr.name as region,

    orgs.name as client,
    CASE  
    WHEN    d.driver_type = 1 THEN 'Brand Ambassador'
    WHEN    d.driver_type = 0 AND packages.serving_size >= 60 THEN 'Large (60+)'
    WHEN    d.driver_type = 0 AND packages.serving_size < 60 THEN 'Small (-60)'
    END AS serving_size,
    --Time asked to start
    CASE 
    --east coast
    WHEN rr.area_id = 1 
    THEN TO_CHAR(drd.expected_start_time AT TIME ZONE 'UTC' AT TIME ZONE 'America/New_York','HH:MI AM') 
    --bay area
    WHEN rr.area_id = 2
    THEN TO_CHAR(drd.expected_start_time AT TIME ZONE 'UTC' AT TIME ZONE 'America/Los_Angeles','HH:MI AM') 
    END
    AS time_asked_start,
    --Actual time of arrival

    CASE 
    --east coast
    WHEN rr.area_id = 1 
    THEN TO_CHAR(drd.actual_start_time AT TIME ZONE 'UTC' AT TIME ZONE 'America/New_York','HH:MI AM') 
    --bay area
    WHEN rr.area_id = 2
    THEN TO_CHAR(drd.actual_start_time AT TIME ZONE 'UTC' AT TIME ZONE 'America/Los_Angeles','HH:MI AM') 
    END
    AS actual_time_of_arrival,

    --TO_CHAR(drd.actual_start_time,'HH:MI AM') AS actual_time_of_arrival,

    --End timestamp


    CASE 
    --east coast
    WHEN rr.area_id = 1 
    THEN TO_CHAR(drd.actual_finish_time AT TIME ZONE 'UTC' AT TIME ZONE 'America/New_York','HH:MI AM') 
    --bay area
    WHEN rr.area_id = 2
    THEN TO_CHAR(drd.actual_finish_time AT TIME ZONE 'UTC' AT TIME ZONE 'America/Los_Angeles','HH:MI AM') 
    END
    AS end_timestamp,


    --TO_CHAR(drd.actual_finish_time,'HH:MI AM') AS end_timestamp,



    CASE WHEN drd.actual_start_time > drd.expected_start_time
    THEN
    EXTRACT(EPOCH FROM (drd.actual_start_time - drd.expected_start_time)) / 60 
    ELSE 0
    END
    AS late_for_pickup,

    --COAST INDICATOR

    CASE 
    WHEN rr.area_id = 1 THEN 'EC'
    WHEN rr.area_id = 2 THEN 'WC'
    END AS coast,
    
    -- used just for ordering
    dr.meal_id

    FROM driver_routes AS dr

    -- stops to drv routes
    LEFT JOIN route_stops rs ON rs.driver_route_id = dr.id
    -- stops to packages
    LEFT JOIN packages on rs.package_id = packages.id
    -- packages to orgs
    LEFT JOIN organizations orgs on packages.organization_id = orgs.id
    -- routes to route details
    LEFT JOIN driver_route_details drd ON dr.id = drd.driver_route_id
    -- routes to drivers
    LEFT JOIN drivers d on dr.driver_id = d.id
    -- routes to dispatchers
    LEFT JOIN admins a ON a.id = dr.dispatcher_id 
    -- routes to regions
    LEFT JOIN route_regions rr ON rr.id = dr.route_region_id
    -- routes to meals
    LEFT JOIN meals m on m.id = dr.meal_id 

-- Filter based on local times
    WHERE DATE_TRUNC('day',

    CASE 
    --east coast
    WHEN rr.area_id = 1 
    THEN drd.expected_start_time AT TIME ZONE 'UTC' AT TIME ZONE 'America/New_York'
    --bay area
    WHEN rr.area_id = 2
    THEN drd.expected_start_time AT TIME ZONE 'UTC' AT TIME ZONE 'America/Los_Angeles'
    END

    ) = CURRENT_DATE
    --ensures route stops dont result in route duplication, arbitrary to choose between deliver or pickup
    AND rs.stop_type = 'deliverShipment'
    -- orders resulting query  
    ORDER BY coast, dr.meal_id,driver_name
    ;
