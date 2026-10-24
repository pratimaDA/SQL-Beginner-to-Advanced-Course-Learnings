-- Give me items which are gluten free.
select * from items
WHERE properties-> "$.gluteactorsn_free"=1;

-- Give me items which are have gluten free.actors
select * from items
WHERE isnull(properties-> "$.gluten_free");
